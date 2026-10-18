enum UserRole {
  customer,
  pharmacist,
  admin,
  superadmin;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    return switch (role.trim().toLowerCase()) {
      'customer' => UserRole.customer,
      'pharmacist' => UserRole.pharmacist,
      'admin' => UserRole.admin,
      'superadmin' => UserRole.superadmin,
      _ => UserRole.customer,
    };
  }

  String get value => name;
}

class UserPermissions {
  final bool editPrice;
  final bool manageTransfers;
  final bool viewPrescriptions;
  final bool viewReports;
  final bool viewReturns;

  const UserPermissions({
    this.editPrice = false,
    this.manageTransfers = false,
    this.viewPrescriptions = false,
    this.viewReports = false,
    this.viewReturns = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPermissions &&
          runtimeType == other.runtimeType &&
          editPrice == other.editPrice &&
          manageTransfers == other.manageTransfers &&
          viewPrescriptions == other.viewPrescriptions &&
          viewReports == other.viewReports &&
          viewReturns == other.viewReturns;

  @override
  int get hashCode => Object.hash(
        editPrice,
        manageTransfers,
        viewPrescriptions,
        viewReports,
        viewReturns,
      );

  @override
  String toString() {
    return 'UserPermissions(editPrice: $editPrice, manageTransfers: $manageTransfers, '
        'viewPrescriptions: $viewPrescriptions, viewReports: $viewReports, viewReturns: $viewReturns)';
  }
}

class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final UserPermissions? permissions;
  final String? branchId;
  final bool? isActive;
  final int? monthlyTarget;
  final String? createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.permissions,
    this.branchId,
    this.isActive,
    this.monthlyTarget,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role &&
          phone == other.phone &&
          address == other.address &&
          permissions == other.permissions &&
          branchId == other.branchId &&
          isActive == other.isActive &&
          monthlyTarget == other.monthlyTarget &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        role,
        phone,
        address,
        permissions,
        branchId,
        isActive,
        monthlyTarget,
        createdAt,
      );

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, role: $role, '
        'phone: $phone, address: $address, permissions: $permissions, branchId: $branchId, '
        'isActive: $isActive, monthlyTarget: $monthlyTarget, createdAt: $createdAt)';
  }
}
