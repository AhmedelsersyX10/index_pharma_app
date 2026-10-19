import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

/// Data Transfer Object representing the server response for a branch.
///
/// Strictly conforms to the verified real sample from `GET /store/branches`:
/// ```json
/// {
///   "id": "b18f3a22-3118-4089-9e8c-529a6e118901",
///   "name": "Main Branch",
///   "address": "Cairo",
///   "phone": "01012345678"
/// }
/// ```
class BranchModel {
  const BranchModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String? address;
  final String? phone;

  /// Creates a [BranchModel] from a JSON map.
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
    };
    if (address != null) map['address'] = address;
    if (phone != null) map['phone'] = phone;
    return map;
  }

  /// Maps this data model to the domain [BranchEntity].
  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
    );
  }

  /// Creates a [BranchModel] from a domain [BranchEntity].
  factory BranchModel.fromEntity(BranchEntity entity) {
    return BranchModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(id, name, address, phone);

  @override
  String toString() =>
      'BranchModel(id: $id, name: $name, address: $address, phone: $phone)';
}
