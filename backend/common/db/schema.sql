-- User table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role table
CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  permissions TEXT[]
);

-- TimesheetEntry table
CREATE TABLE IF NOT EXISTS timesheet_entries (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  type VARCHAR(10) NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  location VARCHAR(255)
);

-- Timesheet table
CREATE TABLE IF NOT EXISTS timesheets (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'pending'
);

-- Timesheet <-> TimesheetEntry relation
CREATE TABLE IF NOT EXISTS timesheet_entry_map (
  timesheet_id INTEGER REFERENCES timesheets(id),
  entry_id INTEGER REFERENCES timesheet_entries(id),
  PRIMARY KEY (timesheet_id, entry_id)
);

-- Approval table
CREATE TABLE IF NOT EXISTS approvals (
  id SERIAL PRIMARY KEY,
  timesheet_id INTEGER REFERENCES timesheets(id),
  approver_id INTEGER REFERENCES users(id),
  status VARCHAR(20) NOT NULL,
  comment TEXT,
  decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Device table
CREATE TABLE IF NOT EXISTS devices (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  type VARCHAR(20) NOT NULL,
  os VARCHAR(50) NOT NULL,
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metadata JSONB
);

-- Location table
CREATE TABLE IF NOT EXISTS locations (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  description VARCHAR(255)
);

-- Notification table
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  message TEXT NOT NULL,
  type VARCHAR(20) NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read BOOLEAN DEFAULT FALSE
);

-- AuditLog table
CREATE TABLE IF NOT EXISTS audit_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  details TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AuthToken table
CREATE TABLE IF NOT EXISTS auth_tokens (
  token VARCHAR(255) PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP
);
