// Approval data model for approval-service
class Approval {
  constructor({ id, timesheetId, approverId, status, comment, decidedAt }) {
    this.id = id;
    this.timesheetId = timesheetId;
    this.approverId = approverId;
    this.status = status; // 'approved', 'rejected', 'pending'
    this.comment = comment;
    this.decidedAt = decidedAt;
  }
}
module.exports = { Approval };