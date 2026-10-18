import '../../domain/entities/user.dart';

class UserPermissionsModel {
  final bool editPrice;
  final bool manageTransfers;
  final bool viewPrescriptions;
  final bool viewReports;
  final bool viewReturns;

  const UserPermissionsModel({
    this.editPrice = false,
    this.manageTransfers = false,
    this.viewPrescriptions = false,
    this.viewReports = false,
    this.viewReturns = false,
  });

  factory UserPermissionsModel.fromJson(Map<String, dynamic> json) {
    return UserPermissionsModel(
      editPrice: json['editPrice'] == true,
      manageTransfers: json['manageTransfers'] == true,
      viewPrescriptions: json['viewPrescriptions'] == true,
      viewReports: json['viewReports'] == true,
      viewReturns: json['viewReturns'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'editPrice': editPrice,
      'manageTransfers': manageTransfers,
      'viewPrescriptions': viewPrescriptions,
      'viewReports': viewReports,
      'viewReturns': viewReturns,
    };
  }

  UserPermissions toEntity() {
    return UserPermissions(
      editPrice: editPrice,
      manageTransfers: manageTransfers,
      viewPrescriptions: viewPrescriptions,
      viewReports: viewReports,
      viewReturns: viewReturns,
    );
  }

  factory UserPermissionsModel.fromEntity(UserPermissions entity) {
    return UserPermissionsModel(
      editPrice: entity.editPrice,
      manageTransfers: entity.manageTransfers,
      viewPrescriptions: entity.viewPrescriptions,
      viewReports: entity.viewReports,
      viewReturns: entity.viewReturns,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPermissionsModel &&
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
    return 'UserPermissionsModel(editPrice: $editPrice, manageTransfers: $manageTransfers, '
        'viewPrescriptions: $viewPrescriptions, viewReports: $viewReports, viewReturns: $viewReturns)';
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final UserPermissionsModel? permissions;
  final String? branchId;
  final bool? isActive;
  final int? monthlyTarget;
  final String? createdAt;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    UserPermissionsModel? permissionsModel;
    if (rawPermissions is Map<String, dynamic>) {
      permissionsModel = UserPermissionsModel.fromJson(rawPermissions);
    } else if (rawPermissions is Map) {
      permissionsModel = UserPermissionsModel.fromJson(
        Map<String, dynamic>.from(rawPermissions),
      );
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      permissions: permissionsModel,
      branchId: json['branchId']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      monthlyTarget: json['monthlyTarget'] is num
          ? (json['monthlyTarget'] as num).toInt()
          : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (permissions != null) {
      map['permissions'] = permissions!.toJson();
    } else {
      map['permissions'] = null;
    }
    if (branchId != null) map['branchId'] = branchId;
    if (isActive != null) map['isActive'] = isActive;
    if (monthlyTarget != null) map['monthlyTarget'] = monthlyTarget;
    if (createdAt != null) map['createdAt'] = createdAt;
    return map;
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: UserRole.fromString(role),
      phone: phone,
      address: address,
      permissions: permissions?.toEntity(),
      branchId: branchId,
      isActive: isActive,
      monthlyTarget: monthlyTarget,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
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
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, '
        'phone: $phone, address: $address, permissions: $permissions, branchId: $branchId, '
        'isActive: $isActive, monthlyTarget: $monthlyTarget, createdAt: $createdAt)';
  }
}
