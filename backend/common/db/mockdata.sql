-- Roles
INSERT INTO roles (name, permissions) VALUES
  ('employee', ARRAY['view_timesheet']),
  ('manager', ARRAY['approve_timesheet','view_report']),
  ('admin', ARRAY['manage_users','all']);

-- Users
INSERT INTO users (name, email, password_hash, role) VALUES
  ('Alice Employee', 'alice@company.com', 'hashed_password1', 'employee'),
  ('Bob Manager', 'bob@company.com', 'hashed_password2', 'manager'),
  ('Carol Admin', 'carol@company.com', 'hashed_password3', 'admin');

-- Devices
INSERT INTO devices (user_id, type, os, metadata) VALUES
  (1, 'mobile', 'iOS', '{"imei": "1234567890"}'),
  (2, 'desktop', 'Windows', '{"serial": "ABCDEF"}');

-- Locations
INSERT INTO locations (user_id, latitude, longitude, description) VALUES
  (1, 37.7749, -122.4194, 'San Francisco HQ'),
  (2, 40.7128, -74.0060, 'NYC Office');

-- Timesheet Entries
INSERT INTO timesheet_entries (user_id, type, timestamp, location) VALUES
  (1, 'in', '2025-10-28 09:00:00', 'San Francisco HQ'),
  (1, 'out', '2025-10-28 17:00:00', 'San Francisco HQ'),
  (2, 'in', '2025-10-28 08:30:00', 'NYC Office'),
  (2, 'out', '2025-10-28 16:30:00', 'NYC Office');

-- Timesheets
INSERT INTO timesheets (user_id, submitted_at, status) VALUES
  (1, '2025-10-28 18:00:00', 'pending'),
  (2, '2025-10-28 17:00:00', 'approved');

-- Timesheet Entry Map
INSERT INTO timesheet_entry_map (timesheet_id, entry_id) VALUES
  (1, 1), (1, 2), (2, 3), (2, 4);

-- Approvals
INSERT INTO approvals (timesheet_id, approver_id, status, comment) VALUES
  (2, 2, 'approved', 'Looks good!'),
  (1, 3, 'pending', 'Waiting for review');

-- Notifications
INSERT INTO notifications (user_id, message, type, sent_at, read) VALUES
  (1, 'Your timesheet is pending approval.', 'info', '2025-10-28 18:05:00', false),
  (2, 'Timesheet approved.', 'success', '2025-10-28 17:05:00', true);

-- Audit Logs
INSERT INTO audit_logs (user_id, action, details) VALUES
  (1, 'login', 'User logged in'),
  (2, 'approve_timesheet', 'Approved timesheet for Alice');

-- Auth Tokens
INSERT INTO auth_tokens (token, user_id, issued_at, expires_at) VALUES
  ('token-1-1698500000000', 1, '2025-10-28 09:00:00', '2025-10-28 10:00:00'),
  ('token-2-1698500000001', 2, '2025-10-28 08:30:00', '2025-10-28 09:30:00');
