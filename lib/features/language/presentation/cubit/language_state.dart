/// State for language selection and configuration.
class LanguageState {
  const LanguageState({
    required this.selectedLocale,
    this.isApplying = false,
  });

  /// The currently selected language code ('ar' or 'en').
  final String selectedLocale;

  /// Whether a language transition/persistence operation is in progress.
  final bool isApplying;

  LanguageState copyWith({
    String? selectedLocale,
    bool? isApplying,
  }) {
    return LanguageState(
      selectedLocale: selectedLocale ?? this.selectedLocale,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageState &&
          runtimeType == other.runtimeType &&
          selectedLocale == other.selectedLocale &&
          isApplying == other.isApplying;

  @override
  int get hashCode => selectedLocale.hashCode ^ isApplying.hashCode;
}
