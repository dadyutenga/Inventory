# syntax=docker/dockerfile:1
# check=error=true

# =============================================================================
# PRODUCTION-GRADE MULTI-STAGE DOCKERFILE
# Ultra-slim, high-performance Rails deployment
# =============================================================================

ARG RUBY_VERSION=3.3.1

# =============================================================================
# STAGE 1: BUILD STAGE
# Contains all build tools, compilers, dev headers - discarded after build
# =============================================================================
FROM docker.io/library/ruby:$RUBY_VERSION-alpine AS builder

# Install build dependencies only - these won't be in final image
RUN apk add --no-cache \
    build-base \
    git \
    libpq-dev \
    libyaml-dev \
    vips-dev \
    tzdata \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Configure bundler for production - exclude dev/test groups
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3"

# Install gems first (layer caching optimization)
COPY Gemfile Gemfile.lock ./
COPY vendor ./vendor

RUN bundle config set --local without 'development test' && \
    bundle install --jobs=4 --retry=3 && \
    # Strip gem caches, git dirs, build artifacts
    rm -rf ~/.bundle/ \
           "${BUNDLE_PATH}"/ruby/*/cache \
           "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git \
           "${BUNDLE_PATH}"/ruby/*/gems/*/ext \
           "${BUNDLE_PATH}"/ruby/*/gems/*/test \
           "${BUNDLE_PATH}"/ruby/*/gems/*/spec \
           "${BUNDLE_PATH}"/ruby/*/gems/*/*.md \
           "${BUNDLE_PATH}"/ruby/*/gems/*/*.txt

# Copy application code
COPY . .

# Precompile bootsnap for faster boot
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompile assets (dummy secret for build phase)
ENV SECRET_KEY_BASE_DUMMY=1 \
    RAILS_ENV=production
RUN ./bin/rails assets:precompile && \
    # Clean up asset build artifacts
    rm -rf node_modules tmp/cache app/assets/builds/*.map

# =============================================================================
# STAGE 2: PRODUCTION RUNTIME
# Minimal Alpine with only runtime dependencies
# =============================================================================
FROM docker.io/library/ruby:$RUBY_VERSION-alpine AS runtime

# Install ONLY runtime dependencies - no build tools
RUN apk add --no-cache \
    libpq \
    libyaml \
    vips \
    tzdata \
    curl \
    tini \
    && rm -rf /var/cache/apk/* /tmp/*

# Create non-root user for security
RUN addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails -h /app -s /bin/sh

WORKDIR /app

# Production environment configuration
ENV RAILS_ENV="production" \
    RAILS_LOG_TO_STDOUT="true" \
    RAILS_SERVE_STATIC_FILES="true" \
    RUBY_YJIT_ENABLE="1" \
    MALLOC_ARENA_MAX="2" \
    PORT="7000" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_APP_CONFIG="/app/.bundle"

# Copy gems from builder
COPY --from=builder --chown=rails:rails /usr/local/bundle /usr/local/bundle

# Copy application from builder
COPY --from=builder --chown=rails:rails /app /app

# Switch to non-root user
USER rails:rails

# Expose port 7000
EXPOSE 7000

# Health check hitting the app on port 7000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:7000/up || exit 1

# Use tini as init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--", "/app/bin/docker-entrypoint"]

# Start Puma directly on port 7000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:7000"]
