import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/choose_branches/data/models/branch_model.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

void main() {
  group('BranchModel Tests', () {
    const realSampleJson = {
      'id': 'b18f3a22-3118-4089-9e8c-529a6e118901',
      'name': 'Main Branch',
      'address': 'Cairo',
      'phone': '01012345678',
    };

    test('fromJson parses verified real server payload correctly', () {
      final model = BranchModel.fromJson(realSampleJson);

      expect(model.id, equals('b18f3a22-3118-4089-9e8c-529a6e118901'));
      expect(model.name, equals('Main Branch'));
      expect(model.address, equals('Cairo'));
      expect(model.phone, equals('01012345678'));
    });

    test('fromJson handles null address and phone gracefully', () {
      final minimalJson = {
        'id': 'branch-minimal-01',
        'name': 'Minimal Branch',
      };

      final model = BranchModel.fromJson(minimalJson);

      expect(model.id, equals('branch-minimal-01'));
      expect(model.name, equals('Minimal Branch'));
      expect(model.address, isNull);
      expect(model.phone, isNull);
    });

    test('toJson serializes model correctly', () {
      const model = BranchModel(
        id: 'branch-1',
        name: 'Nasr City',
        address: 'Abbas El Akkad',
        phone: '0222718900',
      );

      final json = model.toJson();

      expect(json['id'], equals('branch-1'));
      expect(json['name'], equals('Nasr City'));
      expect(json['address'], equals('Abbas El Akkad'));
      expect(json['phone'], equals('0222718900'));
    });

    test('toEntity converts BranchModel to pure BranchEntity', () {
      const model = BranchModel(
        id: 'branch-1',
        name: 'Nasr City',
        address: 'Abbas El Akkad',
        phone: '0222718900',
      );

      final entity = model.toEntity();

      expect(entity, isA<BranchEntity>());
      expect(entity.id, equals('branch-1'));
      expect(entity.name, equals('Nasr City'));
      expect(entity.address, equals('Abbas El Akkad'));
      expect(entity.phone, equals('0222718900'));
    });

    test('fromEntity converts BranchEntity to BranchModel', () {
      const entity = BranchEntity(
        id: 'branch-1',
        name: 'Nasr City',
        address: 'Abbas El Akkad',
        phone: '0222718900',
      );

      final model = BranchModel.fromEntity(entity);

      expect(model.id, equals(entity.id));
      expect(model.name, equals(entity.name));
      expect(model.address, equals(entity.address));
      expect(model.phone, equals(entity.phone));
    });
  });
}
