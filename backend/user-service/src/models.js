// User and Role data models for user-service

class User {
  constructor({ id, name, email, passwordHash, role, createdAt }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.passwordHash = passwordHash;
    this.role = role; // e.g., 'employee', 'manager', 'admin'
    this.createdAt = createdAt;
  }
}

class Role {
  constructor({ id, name, permissions }) {
    this.id = id;
    this.name = name; // e.g., 'employee', 'manager', 'admin'
    this.permissions = permissions; // array of permission strings
  }
}

module.exports = { User, Role };