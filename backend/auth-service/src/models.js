// AuthToken data model for auth-service
class AuthToken {
  constructor({ token, userId, issuedAt, expiresAt }) {
    this.token = token;
    this.userId = userId;
    this.issuedAt = issuedAt;
    this.expiresAt = expiresAt;
  }
}
module.exports = { AuthToken };