import '../../domain/entities/public_settings.dart';

/// Data Transfer Object for public settings returned by `GET /settings/public`.
///
/// Verified schema keys:
/// ```json
/// {
///   "pharmacy_name": "",
///   "home_hero_title": "",
///   "home_hero_subtitle": "",
///   "home_hero_desc": "",
///   "home_promo_title": "",
///   "home_promo_desc": "",
///   "home_promo_badge": "",
///   "home_hero_bg": "",
///   "home_promo_bg": "",
///   "whatsapp_number": ""
/// }
/// ```
///
/// Every key is optional and completely null-safe; missing keys or extra keys
/// from future backend changes will never cause an exception.
class PublicSettingsModel extends PublicSettings {
  const PublicSettingsModel({
    super.pharmacyName,
    super.homeHeroTitle,
    super.homeHeroSubtitle,
    super.homeHeroDesc,
    super.homePromoTitle,
    super.homePromoDesc,
    super.homePromoBadge,
    super.homeHeroBg,
    super.homePromoBg,
    super.whatsappNumber,
  });

  /// Creates a [PublicSettingsModel] from a JSON map.
  ///
  /// Safely handles both unpacked payload maps and envelopes containing a `data` key.
  factory PublicSettingsModel.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'];
    final Map<String, dynamic> source = dataNode is Map
        ? Map<String, dynamic>.from(dataNode)
        : json;

    return PublicSettingsModel(
      pharmacyName: source['pharmacy_name']?.toString(),
      homeHeroTitle: source['home_hero_title']?.toString(),
      homeHeroSubtitle: source['home_hero_subtitle']?.toString(),
      homeHeroDesc: source['home_hero_desc']?.toString(),
      homePromoTitle: source['home_promo_title']?.toString(),
      homePromoDesc: source['home_promo_desc']?.toString(),
      homePromoBadge: source['home_promo_badge']?.toString(),
      homeHeroBg: source['home_hero_bg']?.toString(),
      homePromoBg: source['home_promo_bg']?.toString(),
      whatsappNumber: source['whatsapp_number']?.toString(),
    );
  }

  /// Converts this model to a JSON map conforming to the backend format.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (pharmacyName != null) map['pharmacy_name'] = pharmacyName;
    if (homeHeroTitle != null) map['home_hero_title'] = homeHeroTitle;
    if (homeHeroSubtitle != null) map['home_hero_subtitle'] = homeHeroSubtitle;
    if (homeHeroDesc != null) map['home_hero_desc'] = homeHeroDesc;
    if (homePromoTitle != null) map['home_promo_title'] = homePromoTitle;
    if (homePromoDesc != null) map['home_promo_desc'] = homePromoDesc;
    if (homePromoBadge != null) map['home_promo_badge'] = homePromoBadge;
    if (homeHeroBg != null) map['home_hero_bg'] = homeHeroBg;
    if (homePromoBg != null) map['home_promo_bg'] = homePromoBg;
    if (whatsappNumber != null) map['whatsapp_number'] = whatsappNumber;
    return map;
  }

  /// Converts this data model to the domain [PublicSettings] entity.
  PublicSettings toEntity() {
    return PublicSettings(
      pharmacyName: pharmacyName,
      homeHeroTitle: homeHeroTitle,
      homeHeroSubtitle: homeHeroSubtitle,
      homeHeroDesc: homeHeroDesc,
      homePromoTitle: homePromoTitle,
      homePromoDesc: homePromoDesc,
      homePromoBadge: homePromoBadge,
      homeHeroBg: homeHeroBg,
      homePromoBg: homePromoBg,
      whatsappNumber: whatsappNumber,
    );
  }

  /// Creates a [PublicSettingsModel] from a domain [PublicSettings] entity.
  factory PublicSettingsModel.fromEntity(PublicSettings entity) {
    return PublicSettingsModel(
      pharmacyName: entity.pharmacyName,
      homeHeroTitle: entity.homeHeroTitle,
      homeHeroSubtitle: entity.homeHeroSubtitle,
      homeHeroDesc: entity.homeHeroDesc,
      homePromoTitle: entity.homePromoTitle,
      homePromoDesc: entity.homePromoDesc,
      homePromoBadge: entity.homePromoBadge,
      homeHeroBg: entity.homeHeroBg,
      homePromoBg: entity.homePromoBg,
      whatsappNumber: entity.whatsappNumber,
    );
  }
}
