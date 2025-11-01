
#!/bin/zsh

# Stop all running Node.js services
echo "Stopping all Node.js services..."
pkill -f "node src/index.js"
pkill -f "node src/app.js"
pkill -f "node src/server.js"
sleep 2

# Start each service in the background from project root
echo "Restarting auth-service..."
(cd backend/auth-service && npm install && npm start) &

echo "Restarting user-service..."
(cd backend/user-service && npm install && npm start) &

echo "Restarting expense-service..."
(cd backend/expense-service && npm install && npm start) &

echo "Restarting timesheet-service..."
(cd backend/timesheet-service && npm install && npm start) &

echo "Restarting approval-service..."
(cd backend/approval-service && npm install && npm start) &

echo "Restarting device-service..."
(cd backend/device-service && npm install && npm start) &

echo "Restarting location-service..."
(cd backend/location-service && npm install && npm start) &

echo "Restarting notification-service..."
(cd backend/notification-service && npm install && npm start) &

echo "Restarting audit-service..."
(cd backend/audit-service && npm install && npm start) &

echo "Restarting swagger-aggregator-service..."
(cd backend/swagger-aggregator-service && npm install && npm start) &

echo "All services have been stopped and are restarting in the background."