import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_form_field/src/country_selector.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'country_button.dart';

enum Display {
  prefix,
  prefixIcon,
  icon,
}

class PhoneFormField extends FormField<PhoneNumber> {
  final Display display;
  final bool autofocus;
  final bool showFlagInInput;
  final InputDecoration decoration;
  final TextStyle inputTextStyle;
  final ValueChanged<PhoneNumber?>? onChanged;

  static String? _defaultValidator(PhoneNumber? phoneNumber) {
    return phoneNumber == null || phoneNumber.valid || phoneNumber.nsn == ''
        ? null
        : 'Invalid phone number';
  }

  PhoneFormField({
    // form field params
    Key? key,
    void Function(PhoneNumber)? onSaved,
    PhoneNumber? initialValue,
    bool enabled = true,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    // our params
    this.onChanged,
    this.display = Display.prefixIcon,
    this.autofocus = false,
    this.showFlagInInput = true,
    this.decoration = const InputDecoration(border: UnderlineInputBorder()),
    this.inputTextStyle = const TextStyle(fontSize: 16),
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: (p) => onSaved != null ? onSaved(p!) : (p) {},
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          validator: (p) => _defaultValidator(p),
          builder: (field) {
            final state = field as _PhoneFormFieldState;
            return state.builder();
          },
        );

  @override
  _PhoneFormFieldState createState() => _PhoneFormFieldState();
}

class _PhoneFormFieldState extends FormFieldState<PhoneNumber> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Country _selectedCountry = Country.fromIsoCode('us');

  _PhoneFormFieldState();

  @override
  PhoneFormField get widget => super.widget as PhoneFormField;

  @override
  void didChange(PhoneNumber? phoneNumber) {
    super.didChange(phoneNumber);
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onNationalNumberChanges);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onNationalNumberChanges() {
    final phoneNumber = PhoneNumber.fromIsoCode(
      _selectedCountry.isoCode,
      _controller.text,
    );
    didChange(phoneNumber);
  }

  _onCountrySelected(Country country) {
    _selectedCountry = country;
    PhoneNumber newPhoneNumber;
    if (value != null) {
      newPhoneNumber = value!.copyWithIsoCode(
        country.isoCode,
      );
    } else {
      newPhoneNumber = PhoneNumber.fromIsoCode(country.isoCode, '');
    }
    didChange(newPhoneNumber);
  }

  openCountrySelection() {
    showModalBottomSheet(
      context: context,
      builder: (_) => CountrySelector(
        onCountrySelected: _onCountrySelected,
      ),
    );
  }

  String? _getErrorText() {
    if (errorText == null) return null;
    return PhoneFieldLocalization.of(context)?.translate(errorText!) ??
        errorText;
  }

  Color? _getCursorColor() {
    if (errorText != null) {
      return _outterInputDecoration().border?.borderSide.color ??
          Colors.red.shade800;
    }
    return _outterInputDecoration().focusedBorder?.borderSide.color;
  }

  Widget builder() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      cursorColor: _getCursorColor(),
      onSubmitted: (p) => widget.onSaved!(value),
      style: widget.inputTextStyle,
      autofocus: widget.autofocus,
      autofillHints: widget.enabled ? [AutofillHints.telephoneNumber] : null,
      enabled: widget.enabled,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,30}$'))
      ],
      decoration: _outterInputDecoration(),
    );
    // return InputDecorator(
    //   // when the input has focus
    //   isFocused: _focusNode.hasFocus,
    //   decoration: _outterInputDecoration(),
    //   child: Row(
    //     children: [
    //       _countryButton(),
    //       // need to use expanded to make the text field fill the remaining space
    //       Expanded(
    //         child: Padding(
    //           padding: const EdgeInsets.all(12.0),
    //           child: _textField(),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  MaterialButton _countryButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      minWidth: 50,
      padding: const EdgeInsets.all(24),
      onPressed: widget.enabled ? openCountrySelection : null,
      child: CircleFlag(
        value?.country.isoCode ?? 'us',
        size: 20,
      ),
    );
  }

  InputDecoration _outterInputDecoration() {
    var decoration = widget.decoration.copyWith(
      // isDense: false,
      // contentPadding: EdgeInsets.all(0),
      errorText: _getErrorText(),
      // floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
    // depending on the display we need to take care of the button
    // display as it changes the way the input displays
    final fontSize = widget.inputTextStyle.fontSize!;
    var icon = SizedOverflowBox(
      size: Size(fontSize, fontSize),
      child: _countryButton(),
    );
    switch (widget.display) {
      case Display.icon:
        return decoration.copyWith(
          icon: SizedOverflowBox(
            size: Size(24, 24),
            child: _countryButton(),
          ),
          // icon: Icon(Icons.phone),
        );
      case Display.prefix:
        return decoration.copyWith(
          prefix: SizedOverflowBox(
            alignment: Alignment.centerLeft,
            size: Size(45, fontSize),
            // not displayed when no focus to prevent clicks, since we cannot
            // see it anyway
            child: _focusNode.hasFocus ? _countryButton() : null,
          ),
        );
      case Display.prefixIcon:
        // we make the box of the flag be the font size

        // so the flag doesn't push FormField label around
        return decoration.copyWith(prefixIcon: _countryButton());
    }
  }
}
