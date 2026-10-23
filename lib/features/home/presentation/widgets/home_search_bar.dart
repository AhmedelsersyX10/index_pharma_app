import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_text_fields.dart';

/// Clinical Search Bar for B2 Home Screen.
///
/// Complies with design constraints:
/// - Barcode scanner icon is REMOVED (deferred).
/// - Clean, accessible search field built on [AppSearchBar] for shared styling.
/// - Submitting with a non-empty (trimmed) query navigates to
///   `/browse?q={query}`. Empty input does nothing.
/// - Callers can override navigation by providing [onSubmitted].
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    this.onSubmitted,
    this.onTap,
  });

  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String raw) {
    final query = raw.trim();
    if (query.isEmpty) return;
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(query);
    } else {
      context.go(AppRouter.browsePath(q: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: _controller,
      hintText: AppLocaleKeys.homeSearchHint.tr(),
      textInputAction: TextInputAction.search,
      onSubmitted: _handleSubmit,
      onChanged: (_) {},
    );
  }
}
