// Location data model for location-service
class Location {
  constructor({ id, userId, latitude, longitude, timestamp, description }) {
    this.id = id;
    this.userId = userId;
    this.latitude = latitude;
    this.longitude = longitude;
    this.timestamp = timestamp;
    this.description = description; // optional
  }
}
module.exports = { Location };