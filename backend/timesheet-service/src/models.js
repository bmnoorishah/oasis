// Timesheet and TimesheetEntry data models for timesheet-service

class TimesheetEntry {
  constructor({ id, userId, type, timestamp, location }) {
    this.id = id;
    this.userId = userId;
    this.type = type; // 'in' or 'out'
    this.timestamp = timestamp;
    this.location = location; // optional
  }
}

class Timesheet {
  constructor({ id, userId, entries, submittedAt, status }) {
    this.id = id;
    this.userId = userId;
    this.entries = entries; // array of TimesheetEntry
    this.submittedAt = submittedAt;
    this.status = status; // 'pending', 'approved', 'rejected'
  }
}

module.exports = { TimesheetEntry, Timesheet };