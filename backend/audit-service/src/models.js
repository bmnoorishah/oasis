// AuditLog data model for audit-service
class AuditLog {
  constructor({ id, userId, action, details, timestamp }) {
    this.id = id;
    this.userId = userId;
    this.action = action;
    this.details = details;
    this.timestamp = timestamp;
  }
}
module.exports = { AuditLog };