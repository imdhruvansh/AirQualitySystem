# API Testing Guide

This guide provides example requests for testing all API endpoints.

## Prerequisites

- System is running: `docker-compose up`
- Base URL: `http://localhost`

## 1. Health Check

```bash
curl http://localhost/api/health
```

Expected Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-02-12T10:30:00.000000"
}
```

## 2. Get Available Locations

```bash
curl http://localhost/api/locations
```

Expected Response:
```json
{
  "locations": ["Bangalore", "Chennai", "Delhi", "Hyderabad", "Kolkata", "Mumbai"]
}
```

## 3. Get Current Air Quality

```bash
curl http://localhost/api/current/Delhi
```

Expected Response:
```json
{
  "id": 15,
  "timestamp": "2024-02-12T10:00:00",
  "location": "Delhi",
  "pm25": 165.2,
  "pm10": 220.3,
  "no2": 48.5,
  "so2": 13.2,
  "co": 1.3,
  "o3": 68.2,
  "temperature": 27.8,
  "humidity": 64.0,
  "wind_speed": 3.0,
  "aqi": 212,
  "category": "Very Unhealthy"
}
```

## 4. Get Historical Data

### All locations (last 50 records)
```bash
curl "http://localhost/api/data?limit=50"
```

### Specific location
```bash
curl "http://localhost/api/data?location=Mumbai&limit=20"
```

Expected Response:
```json
{
  "data": [
    {
      "id": 1,
      "timestamp": "2024-02-02T10:00:00",
      "location": "Mumbai",
      "pm25": 78.5,
      "pm10": 105.2,
      ...
    }
  ],
  "count": 20
}
```

## 5. Get Statistics

```bash
curl http://localhost/api/stats/Delhi
```

Expected Response:
```json
{
  "avg_aqi": 195.5,
  "max_aqi": 212,
  "min_aqi": 178,
  "avg_pm25": 147.25,
  "total_readings": 4
}
```

## 6. Generate Prediction

```bash
curl -X POST http://localhost/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Delhi",
    "hours_ahead": 24
  }'
```

Expected Response:
```json
{
  "location": "Delhi",
  "prediction_time": "2024-02-13T10:00:00",
  "hours_ahead": 24,
  "predicted_pm25": 158.42,
  "predicted_aqi": 205,
  "category": "Very Unhealthy",
  "confidence": 0.85
}
```

## 7. Add New Data

```bash
curl -X POST http://localhost/api/add-data \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Pune",
    "pm25": 65.5,
    "pm10": 95.3,
    "no2": 28.5,
    "so2": 8.2,
    "co": 0.85,
    "o3": 45.3,
    "temperature": 29.5,
    "humidity": 58.0,
    "wind_speed": 4.5
  }'
```

Expected Response:
```json
{
  "message": "Data added successfully",
  "aqi": 153,
  "category": "Unhealthy"
}
```

## 8. Train Model

```bash
curl -X POST http://localhost/api/train
```

Expected Response:
```json
{
  "message": "Model trained successfully",
  "status": "success"
}
```

## Testing Workflow

### Complete Test Sequence

```bash
# 1. Check system health
echo "1. Health Check"
curl http://localhost/api/health
echo -e "\n\n"

# 2. Get locations
echo "2. Available Locations"
curl http://localhost/api/locations
echo -e "\n\n"

# 3. Get current data for Delhi
echo "3. Current Data - Delhi"
curl http://localhost/api/current/Delhi
echo -e "\n\n"

# 4. Get historical data
echo "4. Historical Data - Last 10 records"
curl "http://localhost/api/data?limit=10"
echo -e "\n\n"

# 5. Get statistics
echo "5. Statistics - Delhi"
curl http://localhost/api/stats/Delhi
echo -e "\n\n"

# 6. Make prediction
echo "6. Prediction - Delhi 24h"
curl -X POST http://localhost/api/predict \
  -H "Content-Type: application/json" \
  -d '{"location": "Delhi", "hours_ahead": 24}'
echo -e "\n\n"

# 7. Add new data
echo "7. Add New Data - Ahmedabad"
curl -X POST http://localhost/api/add-data \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Ahmedabad",
    "pm25": 88.5,
    "pm10": 125.3,
    "no2": 35.2,
    "so2": 9.8,
    "co": 1.1,
    "o3": 52.3,
    "temperature": 32.5,
    "humidity": 45.0,
    "wind_speed": 5.2
  }'
echo -e "\n\n"

echo "✅ All tests completed!"
```

Save this as `test-api.sh` and run:
```bash
chmod +x test-api.sh
./test-api.sh
```

## Using Python Requests

```python
import requests
import json

BASE_URL = "http://localhost/api"

# Health check
response = requests.get(f"{BASE_URL}/health")
print("Health:", response.json())

# Get locations
response = requests.get(f"{BASE_URL}/locations")
print("Locations:", response.json())

# Get current data
response = requests.get(f"{BASE_URL}/current/Delhi")
print("Current:", response.json())

# Make prediction
payload = {
    "location": "Delhi",
    "hours_ahead": 24
}
response = requests.post(f"{BASE_URL}/predict", json=payload)
print("Prediction:", response.json())

# Add data
new_data = {
    "location": "Surat",
    "pm25": 72.5,
    "pm10": 98.3,
    "no2": 30.5,
    "so2": 8.5,
    "co": 0.9,
    "o3": 48.2,
    "temperature": 31.0,
    "humidity": 52.0,
    "wind_speed": 4.8
}
response = requests.post(f"{BASE_URL}/add-data", json=new_data)
print("Add Data:", response.json())
```

## Using Postman

1. Import the collection by creating new requests for each endpoint
2. Set base URL: `http://localhost/api`
3. For POST requests:
   - Set Content-Type: `application/json`
   - Add request body in JSON format

## Error Codes

- `200` - Success
- `404` - Location/Resource not found
- `500` - Server error (check backend logs)

## Debugging

If requests fail:

1. Check if all containers are running:
   ```bash
   docker ps
   ```

2. Check backend logs:
   ```bash
   docker logs airquality_backend
   ```

3. Verify database connection:
   ```bash
   docker exec -it airquality_db psql -U admin -d airquality -c "SELECT COUNT(*) FROM air_quality_data;"
   ```

4. Check Nginx logs:
   ```bash
   docker logs airquality_nginx
   ```
