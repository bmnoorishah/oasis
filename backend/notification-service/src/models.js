// Notification data model for notification-service
class Notification {
  constructor({ id, userId, message, type, sentAt, read }) {
    this.id = id;
    this.userId = userId;
    this.message = message;
    this.type = type; // e.g., 'info', 'alert', 'reminder'
    this.sentAt = sentAt;
    this.read = read;
  }
}
module.exports = { Notification };