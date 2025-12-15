# API Testing Script
# This file contains example requests to test the new Products API

# First, let's start the Rails server to test the API
# Run this in terminal: rails server

# Test 1: Get all products
echo "=== Test 1: Get all products ==="
curl -X GET "http://localhost:3000/api/v1/products" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 2: Get laptops only
echo "=== Test 2: Get laptops only ==="
curl -X GET "http://localhost:3000/api/v1/products/laptop" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 3: Get mice only
echo "=== Test 3: Get mice only ==="
curl -X GET "http://localhost:3000/api/v1/products/mouse" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 4: Get desktop PCs only
echo "=== Test 4: Get desktop PCs only ==="
curl -X GET "http://localhost:3000/api/v1/products/desktop_pc" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 5: Get servers only
echo "=== Test 5: Get servers only ==="
curl -X GET "http://localhost:3000/api/v1/products/server" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 6: Get accessories only
echo "=== Test 6: Get accessories only ==="
curl -X GET "http://localhost:3000/api/v1/products/accessory" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 7: Get keyboards (may be empty)
echo "=== Test 7: Get keyboards ==="
curl -X GET "http://localhost:3000/api/v1/products/keyboard" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 8: Test invalid product type (should return 404 error)
echo "=== Test 8: Invalid product type ==="
curl -X GET "http://localhost:3000/api/v1/products/invalid_type" \
  -H "Accept: application/json" \
  -H "User-Agent: API-Test-Script"

echo -e "\n\n"

# Test 9: Test rate limiting (run this multiple times quickly)
echo "=== Test 9: Rate limiting test ==="
for i in {1..10}; do
  echo "Request $i:"
  curl -X GET "http://localhost:3000/api/v1/products" \
    -H "Accept: application/json" \
    -H "User-Agent: API-Test-Script-$i" \
    -w "HTTP Status: %{http_code}\n" \
    -s -o /dev/null
done

echo -e "\n"

# Test 10: Performance/caching test
echo "=== Test 10: Cache performance test ==="
echo "First request (cache miss):"
time curl -s -X GET "http://localhost:3000/api/v1/products" -H "Accept: application/json" > /dev/null

echo "Second request (cache hit):"
time curl -s -X GET "http://localhost:3000/api/v1/products" -H "Accept: application/json" > /dev/null

echo -e "\n"

# Test 6: Test with Python
# python3 -c "
# import requests
# import json
# 
# response = requests.get('http://localhost:3000/api/v1/products')
# if response.status_code == 200:
#     data = response.json()
#     print(f'Success: {data[\"success\"]}')
#     print(f'Total products: {data[\"meta\"][\"total_count\"]}')
#     print(f'Cached: {data[\"meta\"][\"cached\"]}')
# else:
#     print(f'Error: {response.status_code}')
# "

# Test 7: JavaScript/Node.js example
# node -e "
# const fetch = require('node-fetch'); // npm install node-fetch
# 
# async function testAPI() {
#   try {
#     const response = await fetch('http://localhost:3000/api/v1/products/laptop');
#     const data = await response.json();
#     
#     if (data.success) {
#       console.log(\`Found \${data.meta.total_count} laptops\`);
#       data.data.forEach(product => {
#         console.log(\`- \${product.name} (\${product.brand} \${product.model})\`);
#       });
#     } else {
#       console.log('API Error:', data.message);
#     }
#   } catch (error) {
#     console.error('Request failed:', error);
#   }
# }
# 
# testAPI();
# "

# Performance test - check caching
echo "Testing cache performance..."
echo "First request (should be slower, cache miss):"
time curl -s -X GET "http://localhost:3000/api/v1/products" > /dev/null

echo "Second request (should be faster, cache hit):"
time curl -s -X GET "http://localhost:3000/api/v1/products" > /dev/null
