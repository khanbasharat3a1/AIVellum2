import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppConstants.textTertiary.withOpacity(0.2),
        ),
        boxShadow: [AppConstants.cardShadow],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppConstants.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search prompts, categories, tags...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppConstants.textTertiary,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Icon(
              Icons.search_rounded,
              color: AppConstants.textTertiary,
              size: AppConstants.iconSizeSmall,
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(AppConstants.paddingS),
                  child: IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppConstants.textTertiary,
                      size: AppConstants.iconSizeSmall,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: const BorderSide(
              color: AppConstants.vaultRed,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppConstants.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingM,
          ),
        ),
      ),
    );
  }
}