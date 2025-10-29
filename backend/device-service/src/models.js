// Device data model for device-service
class Device {
  constructor({ id, userId, type, os, registeredAt, metadata }) {
    this.id = id;
    this.userId = userId;
    this.type = type; // e.g., 'mobile', 'desktop'
    this.os = os;
    this.registeredAt = registeredAt;
    this.metadata = metadata; // optional
  }
}
module.exports = { Device };