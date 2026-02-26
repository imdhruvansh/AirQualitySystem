#!/bin/bash

echo "Air Quality Prediction System - Quick Start"
echo "============================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

echo "Docker is running"
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    exit 1
fi

echo "docker-compose is available"
echo ""

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose down 2>/dev/null

# Build and start containers
echo "Building containers (this may take a few minutes)..."
docker-compose up --build -d

echo ""
echo "Waiting for services to start..."
sleep 10

# Check service health
echo ""
echo "Checking service health..."
echo ""

# Check database
if docker ps | grep -q airquality_db; then
    echo "Database is running"
else
    echo "Database failed to start"
fi

# Check backend
if docker ps | grep -q airquality_backend; then
    echo "Backend is running"
else
    echo "Backend failed to start"
fi

# Check frontend
if docker ps | grep -q airquality_frontend; then
    echo "Frontend is running"
else
    echo "Frontend failed to start"
fi

# Check nginx
if docker ps | grep -q airquality_nginx; then
    echo "Nginx is running"
else
    echo "Nginx failed to start"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Access the application:"
echo "   Frontend:  http://localhost"
echo "   API:       http://localhost/api"
echo "   Health:    http://localhost/api/health"
echo ""
echo "View logs:"
echo "   All:       docker-compose logs -f"
echo "   Backend:   docker-compose logs -f backend"
echo "   Frontend:  docker-compose logs -f frontend"
echo ""
echo "Stop the system:"
echo "   docker-compose down"
echo ""
echo "Tip: Wait 30 seconds for the ML model to train on first startup"
echo ""