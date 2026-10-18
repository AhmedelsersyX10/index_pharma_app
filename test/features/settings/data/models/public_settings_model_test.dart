import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/settings/data/models/public_settings_model.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';

void main() {
  group('PublicSettingsModel Tests', () {
    const realSampleJson = {
      'pharmacy_name': 'Index Pharmacy',
      'home_hero_title': 'Fast & Reliable Care',
      'home_hero_subtitle': 'Prescriptions at your doorstep',
      'home_hero_desc': 'Browse our comprehensive catalog of medicine',
      'home_promo_title': 'Summer Offer',
      'home_promo_desc': 'Special deals on personal care',
      'home_promo_badge': 'SAVE 20%',
      'home_hero_bg': '/uploads/settings/hero.png',
      'home_promo_bg': '/uploads/settings/promo.png',
      'whatsapp_number': '01012345678',
    };

    test('fromJson parses verified real server payload correctly', () {
      final model = PublicSettingsModel.fromJson(realSampleJson);

      expect(model.pharmacyName, equals('Index Pharmacy'));
      expect(model.homeHeroTitle, equals('Fast & Reliable Care'));
      expect(model.homeHeroSubtitle, equals('Prescriptions at your doorstep'));
      expect(model.homeHeroDesc, equals('Browse our comprehensive catalog of medicine'));
      expect(model.homePromoTitle, equals('Summer Offer'));
      expect(model.homePromoDesc, equals('Special deals on personal care'));
      expect(model.homePromoBadge, equals('SAVE 20%'));
      expect(model.homeHeroBg, equals('/uploads/settings/hero.png'));
      expect(model.homePromoBg, equals('/uploads/settings/promo.png'));
      expect(model.whatsappNumber, equals('01012345678'));
    });

    test('fromJson handles full API response envelope {"success": true, "data": {...}}', () {
      final envelope = {
        'success': true,
        'data': realSampleJson,
      };

      final model = PublicSettingsModel.fromJson(envelope);

      expect(model.pharmacyName, equals('Index Pharmacy'));
      expect(model.whatsappNumber, equals('01012345678'));
    });

    test('fromJson handles empty data object {} gracefully (all keys null)', () {
      final model = PublicSettingsModel.fromJson(const {});

      expect(model.pharmacyName, isNull);
      expect(model.homeHeroTitle, isNull);
      expect(model.homeHeroSubtitle, isNull);
      expect(model.homeHeroDesc, isNull);
      expect(model.homePromoTitle, isNull);
      expect(model.homePromoDesc, isNull);
      expect(model.homePromoBadge, isNull);
      expect(model.homeHeroBg, isNull);
      expect(model.homePromoBg, isNull);
      expect(model.whatsappNumber, isNull);
    });

    test('fromJson handles envelope with empty data {"success": true, "data": {}}', () {
      final envelope = {
        'success': true,
        'data': <String, dynamic>{},
      };

      final model = PublicSettingsModel.fromJson(envelope);

      expect(model.pharmacyName, isNull);
      expect(model.whatsappNumber, isNull);
    });

    test('fromJson handles partially missing keys gracefully', () {
      final partialJson = {
        'pharmacy_name': 'Index Pharmacy',
        'whatsapp_number': '01099999999',
      };

      final model = PublicSettingsModel.fromJson(partialJson);

      expect(model.pharmacyName, equals('Index Pharmacy'));
      expect(model.whatsappNumber, equals('01099999999'));
      expect(model.homeHeroTitle, isNull);
      expect(model.homePromoDesc, isNull);
    });

    test('fromJson ignores extra or unexpected keys without throwing', () {
      final jsonWithExtras = {
        'pharmacy_name': 'Index Pharmacy',
        'unexpected_future_key': 'future_value',
        'another_extra_key': 12345,
        'nested_extra': {'a': 1, 'b': 2},
      };

      final model = PublicSettingsModel.fromJson(jsonWithExtras);

      expect(model.pharmacyName, equals('Index Pharmacy'));
      expect(model.homeHeroTitle, isNull);
    });

    test('fromJson converts non-string values safely using toString()', () {
      final nonStringJson = {
        'pharmacy_name': 'Index Pharmacy',
        'whatsapp_number': 1012345678, // integer instead of string
      };

      final model = PublicSettingsModel.fromJson(nonStringJson);

      expect(model.whatsappNumber, equals('1012345678'));
    });

    test('toJson serializes model correctly', () {
      const model = PublicSettingsModel(
        pharmacyName: 'Index Pharmacy',
        whatsappNumber: '01012345678',
      );

      final json = model.toJson();

      expect(json['pharmacy_name'], equals('Index Pharmacy'));
      expect(json['whatsapp_number'], equals('01012345678'));
      expect(json.containsKey('home_hero_title'), isFalse);
    });

    test('toEntity converts PublicSettingsModel to domain PublicSettings', () {
      const model = PublicSettingsModel(
        pharmacyName: 'Index Pharmacy',
        homeHeroTitle: 'Hero Title',
        whatsappNumber: '01012345678',
      );

      final entity = model.toEntity();

      expect(entity, isA<PublicSettings>());
      expect(entity.pharmacyName, equals('Index Pharmacy'));
      expect(entity.homeHeroTitle, equals('Hero Title'));
      expect(entity.whatsappNumber, equals('01012345678'));
    });

    test('fromEntity converts domain PublicSettings to PublicSettingsModel', () {
      const entity = PublicSettings(
        pharmacyName: 'Index Pharmacy',
        homeHeroTitle: 'Hero Title',
        whatsappNumber: '01012345678',
      );

      final model = PublicSettingsModel.fromEntity(entity);

      expect(model.pharmacyName, equals(entity.pharmacyName));
      expect(model.homeHeroTitle, equals(entity.homeHeroTitle));
      expect(model.whatsappNumber, equals(entity.whatsappNumber));
    });

    test('equality and hashCode work as expected', () {
      const model1 = PublicSettingsModel(
        pharmacyName: 'Index Pharmacy',
        whatsappNumber: '01012345678',
      );

      const model2 = PublicSettingsModel(
        pharmacyName: 'Index Pharmacy',
        whatsappNumber: '01012345678',
      );

      const model3 = PublicSettingsModel(
        pharmacyName: 'Other Pharmacy',
        whatsappNumber: '01012345678',
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
      expect(model1 == model3, isFalse);
    });
  });
}
