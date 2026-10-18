/// Domain entity representing public pharmacy and store settings.
///
/// Strictly adheres to verified server keys from `GET /settings/public`:
/// - pharmacy_name
/// - home_hero_title
/// - home_hero_subtitle
/// - home_hero_desc
/// - home_promo_title
/// - home_promo_desc
/// - home_promo_badge
/// - home_hero_bg
/// - home_promo_bg
/// - whatsapp_number
///
/// Every field is optional and null-safe so that missing keys or empty payloads
/// will never crash the application.
class PublicSettings {
  const PublicSettings({
    this.pharmacyName,
    this.homeHeroTitle,
    this.homeHeroSubtitle,
    this.homeHeroDesc,
    this.homePromoTitle,
    this.homePromoDesc,
    this.homePromoBadge,
    this.homeHeroBg,
    this.homePromoBg,
    this.whatsappNumber,
  });

  final String? pharmacyName;
  final String? homeHeroTitle;
  final String? homeHeroSubtitle;
  final String? homeHeroDesc;
  final String? homePromoTitle;
  final String? homePromoDesc;
  final String? homePromoBadge;
  final String? homeHeroBg;
  final String? homePromoBg;
  final String? whatsappNumber;

  PublicSettings copyWith({
    String? pharmacyName,
    String? homeHeroTitle,
    String? homeHeroSubtitle,
    String? homeHeroDesc,
    String? homePromoTitle,
    String? homePromoDesc,
    String? homePromoBadge,
    String? homeHeroBg,
    String? homePromoBg,
    String? whatsappNumber,
  }) {
    return PublicSettings(
      pharmacyName: pharmacyName ?? this.pharmacyName,
      homeHeroTitle: homeHeroTitle ?? this.homeHeroTitle,
      homeHeroSubtitle: homeHeroSubtitle ?? this.homeHeroSubtitle,
      homeHeroDesc: homeHeroDesc ?? this.homeHeroDesc,
      homePromoTitle: homePromoTitle ?? this.homePromoTitle,
      homePromoDesc: homePromoDesc ?? this.homePromoDesc,
      homePromoBadge: homePromoBadge ?? this.homePromoBadge,
      homeHeroBg: homeHeroBg ?? this.homeHeroBg,
      homePromoBg: homePromoBg ?? this.homePromoBg,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicSettings &&
          runtimeType == other.runtimeType &&
          pharmacyName == other.pharmacyName &&
          homeHeroTitle == other.homeHeroTitle &&
          homeHeroSubtitle == other.homeHeroSubtitle &&
          homeHeroDesc == other.homeHeroDesc &&
          homePromoTitle == other.homePromoTitle &&
          homePromoDesc == other.homePromoDesc &&
          homePromoBadge == other.homePromoBadge &&
          homeHeroBg == other.homeHeroBg &&
          homePromoBg == other.homePromoBg &&
          whatsappNumber == other.whatsappNumber;

  @override
  int get hashCode => Object.hash(
        pharmacyName,
        homeHeroTitle,
        homeHeroSubtitle,
        homeHeroDesc,
        homePromoTitle,
        homePromoDesc,
        homePromoBadge,
        homeHeroBg,
        homePromoBg,
        whatsappNumber,
      );

  @override
  String toString() {
    return 'PublicSettings('
        'pharmacyName: $pharmacyName, '
        'homeHeroTitle: $homeHeroTitle, '
        'homeHeroSubtitle: $homeHeroSubtitle, '
        'homeHeroDesc: $homeHeroDesc, '
        'homePromoTitle: $homePromoTitle, '
        'homePromoDesc: $homePromoDesc, '
        'homePromoBadge: $homePromoBadge, '
        'homeHeroBg: $homeHeroBg, '
        'homePromoBg: $homePromoBg, '
        'whatsappNumber: $whatsappNumber'
        ')';
  }
}
