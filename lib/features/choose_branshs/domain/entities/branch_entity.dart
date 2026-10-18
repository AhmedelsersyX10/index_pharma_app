/// Pure Domain Entity representing a physical pharmacy branch.
///
/// Contains only business attributes without dependencies on Flutter or serialization libraries.
class BranchEntity {
  const BranchEntity({
    required this.id,
    required this.name,
    this.address,
    this.phone,
  });

  /// Unique identifier of the branch.
  final String id;

  /// Display name of the branch.
  final String name;

  /// Physical address of the branch, if available.
  final String? address;

  /// Contact phone number, if available.
  final String? phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(id, name, address, phone);

  @override
  String toString() =>
      'BranchEntity(id: $id, name: $name, address: $address, phone: $phone)';
}
