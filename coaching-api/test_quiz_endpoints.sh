#!/bin/bash
# Test script for quiz API endpoints
# Requires the FastAPI server to be running on http://localhost:8000

BASE_URL="http://localhost:8000"

echo "=========================================="
echo "Testing Quiz API Endpoints"
echo "=========================================="
echo ""

# Test 1: Health check
echo "[1] Testing health check endpoint..."
curl -X GET "$BASE_URL/health" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

# Test 2: Get all quiz modules
echo "[2] Testing /api/quiz/modules endpoint..."
curl -X GET "$BASE_URL/api/quiz/modules" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

# Test 3: Get questions for first module (adjust module_id if needed)
echo "[3] Testing /api/quiz/module/{module_id}/questions endpoint..."
MODULE_ID=$(curl -s -X GET "$BASE_URL/api/quiz/modules" \
  -H "Content-Type: application/json" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$MODULE_ID" ]; then
  echo "Using MODULE_ID: $MODULE_ID"
  curl -X GET "$BASE_URL/api/quiz/module/$MODULE_ID/questions" \
    -H "Content-Type: application/json" \
    -w "\nStatus: %{http_code}\n\n"
else
  echo "Could not extract module ID. Skipping test."
fi

# Test 4: Get randomized quiz (16 MCQ + 4 scenarios)
echo "[4] Testing /api/quiz/module/{module_id}/random endpoint..."
if [ -n "$MODULE_ID" ]; then
  echo "Using MODULE_ID: $MODULE_ID"
  curl -X GET "$BASE_URL/api/quiz/module/$MODULE_ID/random" \
    -H "Content-Type: application/json" \
    -w "\nStatus: %{http_code}\n\n"
else
  echo "Could not extract module ID. Skipping test."
fi

# Test 5: Error handling - non-existent module
echo "[5] Testing error handling with non-existent module..."
curl -X GET "$BASE_URL/api/quiz/module/nonexistent_module/random" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "=========================================="
echo "Tests complete!"
echo "=========================================="
