# =============================================================================
# PRODUCTION-OPTIMIZED PUMA CONFIGURATION
# =============================================================================
#
# Tuned for containerized deployments with low memory footprint and fast boot.
# Reads all configuration from environment variables for 12-factor compliance.

# -----------------------------------------------------------------------------
# THREAD CONFIGURATION
# -----------------------------------------------------------------------------
# Thread count affects memory usage and concurrency. Due to Ruby's GVL,
# diminishing returns above 5 threads. Default 3 is a good balance.
max_threads = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
min_threads = ENV.fetch("RAILS_MIN_THREADS", max_threads).to_i
threads min_threads, max_threads

# -----------------------------------------------------------------------------
# WORKER CONFIGURATION (Cluster Mode)
# -----------------------------------------------------------------------------
# Workers = forked processes. Set WEB_CONCURRENCY based on container memory.
# Rule of thumb: ~256MB per worker for typical Rails app.
# Use 0 for single process mode (lower memory, suitable for small containers).
workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

# Preload app for Copy-on-Write memory savings in cluster mode
preload_app!

# -----------------------------------------------------------------------------
# PORT BINDING
# -----------------------------------------------------------------------------
# Bind to 0.0.0.0:7000 for container networking
# PORT env var overrides default (set to 7000 in Dockerfile)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 7000)}"

# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
environment ENV.fetch("RAILS_ENV", "production")

# -----------------------------------------------------------------------------
# PERFORMANCE OPTIMIZATIONS
# -----------------------------------------------------------------------------
# Reduce memory bloat with periodic worker restarts
worker_timeout 60

# Fork workers after boot for faster startup
fork_worker 1000

# Nakayoshi GC reduces memory fragmentation during fork
nakayoshi_fork true if respond_to?(:nakayoshi_fork)

# Wait for workers to boot before marking healthy
wait_for_less_busy_worker 0.001

# Lower latency through TCP optimizations
first_data_timeout 30
persistent_timeout 20

# -----------------------------------------------------------------------------
# HOOKS
# -----------------------------------------------------------------------------
# Reconnect to database after forking workers
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Solid Queue integration (optional - runs queue in Puma process)
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"] == "true"

# -----------------------------------------------------------------------------
# MISC
# -----------------------------------------------------------------------------
# PID file location (optional, for external process managers)
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Quiet mode - reduce logging noise
quiet

# stdout/stderr for container logging
stdout_redirect(nil, nil, true) if ENV["RAILS_LOG_TO_STDOUT"]

# Allow restart via tmp/restart.txt
plugin :tmp_restart
