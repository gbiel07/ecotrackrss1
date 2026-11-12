import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Rótulo acima do campo (label do CSS).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.topSpacing = 17});

  final String text;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: 8),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

/// Campo de texto padrão (input / textarea).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.inputFormatters,
    this.dense = false,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool dense;
  final Widget? prefixIcon;

  /// Área de texto com altura mínima de ~90 px, como o textarea da web.
  const AppTextField.multiline({
    super.key,
    this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
  })  : obscureText = false,
        keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        onSubmitted = null,
        autofillHints = null,
        inputFormatters = null,
        dense = false,
        prefixIcon = null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      style: AppTextStyles.input.copyWith(fontSize: dense ? 12 : 14),
      decoration: AppInputDecoration.build(hint: hint, dense: dense, prefixIcon: prefixIcon),
    );
  }
}

/// Opção de uma lista suspensa.
class AppSelectItem<T> {
  const AppSelectItem(this.value, this.label);

  final T value;
  final String label;
}

/// Lista suspensa padrão (select), com validação opcional dentro de um Form.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
    this.dense = false,
  });

  final List<AppSelectItem<T>> items;
  final ValueChanged<T?> onChanged;

  /// Valor inicial. Para trocar o valor por código, mude também a `key`.
  final T? value;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.input.copyWith(fontSize: dense ? 12 : 14);
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: AppInputDecoration.build(errorText: field.errorText, dense: dense),
          isEmpty: field.value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: field.value,
              isExpanded: true,
              isDense: true,
              hint: hint == null
                  ? null
                  : Text(hint!, style: AppTextStyles.hint.copyWith(fontSize: dense ? 12 : 14)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.muted),
              borderRadius: BorderRadius.circular(9),
              dropdownColor: AppColors.white,
              style: textStyle,
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(item.label, overflow: TextOverflow.ellipsis, style: textStyle),
                  ),
              ],
              onChanged: (selected) {
                field.didChange(selected);
                onChanged(selected);
              },
            ),
          ),
        );
      },
    );
  }
}

/// Converte listas de texto em opções (valor = rótulo).
List<AppSelectItem<String>> stringItems(Iterable<String> values) =>
    [for (final value in values) AppSelectItem<String>(value, value)];
