import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart';

void main() {
  group('PhoneFormField', () {
    Widget getWidget({
      Function(PhoneNumber?)? onChanged,
      Function(PhoneNumber?)? onSaved,
      PhoneNumber? initialValue,
      PhoneController? controller,
      bool showFlagInInput = true,
      String defaultCountry = 'US',
    }) =>
        MaterialApp(
          home: Scaffold(
            body: PhoneFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              onSaved: onSaved,
              showFlagInInput: showFlagInInput,
              controller: controller,
              defaultCountry: defaultCountry,
            ),
          ),
        );

    testWidgets('Should display input', (tester) async {
      await tester.pumpWidget(getWidget());
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Should open dialog when dial code is clicked', (tester) async {
      await tester.pumpWidget(getWidget());
      expect(find.byType(CountrySelector), findsNothing);
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlagDialCodeChip).last);
      await tester.pumpAndSettle();
      expect(find.byType(CountrySelector), findsOneWidget);
    });

    testWidgets('Should have a default country', (tester) async {
      await tester.pumpWidget(getWidget(defaultCountry: 'FR'));
      expect(find.text('+ 33'), findsOneWidget);
    });

    testWidgets('Should display initial value', (tester) async {
      await tester.pumpWidget(getWidget(
          initialValue: PhoneParser().parseWithIsoCode('FR', '478787827')));
      expect(find.text('+ 33'), findsOneWidget);
      expect(find.text('478787827'), findsOneWidget);
    });

    testWidgets('Should change value of controller', (tester) async {
      final controller = PhoneController(null);
      PhoneNumber? newValue;
      controller.addListener(() {
        newValue = controller.value;
      });
      await tester
          .pumpWidget(getWidget(controller: controller, defaultCountry: 'US'));
      final textField = find.byType(TextFormField);
      await tester.tap(textField);
      // non digits should not work
      await tester.enterText(textField, '123456789');
      expect(
          newValue, equals(PhoneParser().parseWithIsoCode('US', '123456789')));
    });

    testWidgets('Should change value of input when controller changes',
        (tester) async {
      final controller = PhoneController(null);
      // ignore: unused_local_variable
      PhoneNumber? newValue;
      controller.addListener(() {
        newValue = controller.value;
      });
      await tester
          .pumpWidget(getWidget(controller: controller, defaultCountry: 'US'));
      controller.value = PhoneParser().parseWithIsoCode('FR', '488997722');
      expect(find.text('+ 33'), findsOneWidget);
      expect(find.text('488997722'), findsOneWidget);
    });

    testWidgets(
        'Should change value of dial code chip when full number written',
        (tester) async {
      final controller = PhoneController(null);
      // ignore: unused_local_variable
      PhoneNumber? newValue;
      controller.addListener(() {
        newValue = controller.value;
      });
      await tester
          .pumpWidget(getWidget(controller: controller, defaultCountry: 'US'));
      final textField = find.byType(TextFormField);
      await tester.tap(textField);
      // non digits should not work
      await tester.enterText(textField, '+33 0488 99 77 22');
      expect(controller.value?.isoCode, equals('FR'));
      expect(controller.value?.nsn, equals('488997722'));
    });

    testWidgets('Should call onChange', (tester) async {
      bool changed = false;
      PhoneNumber? phoneNumber = PhoneParser().parseWithIsoCode('FR', '');
      final onChanged = (p) {
        changed = true;
        phoneNumber = p;
      };
      await tester.pumpWidget(
        getWidget(
          initialValue: phoneNumber,
          onChanged: onChanged,
        ),
      );
      final textField = find.byType(TextFormField);
      await tester.tap(textField);
      // non digits should not work
      await tester.enterText(textField, 'aaa');
      await tester.pumpAndSettle();
      expect(changed, equals(false));
      await tester.enterText(textField, '123');
      await tester.pumpAndSettle();
      expect(phoneNumber, equals(PhoneParser().parseWithIsoCode('FR', '123')));
    });

    testWidgets('Should call onSaved', (tester) async {
      bool saved = false;
      PhoneNumber? phoneNumber = PhoneParser().parseWithIsoCode('FR', '');
      final onSaved = (p) {
        saved = true;
        phoneNumber = p;
      };
      await tester.pumpWidget(
        getWidget(
          initialValue: phoneNumber,
          onSaved: onSaved,
        ),
      );
      final foundTextField = find.byType(TextFormField);
      final textField = tester.widget<TextFormField>(foundTextField);
      // non digits should not work
      await tester.enterText(foundTextField, '479281938');
      textField.onSaved?.call(textField.controller?.text);
      await tester.pumpAndSettle();
      expect(saved, isTrue);
      expect(phoneNumber,
          equals(PhoneParser().parseWithIsoCode('FR', '479281938')));
    });

    // skipped because the test don't go through but it passed manual testing
    testWidgets('Should tell when a phone number is not valid', (tester) async {
      PhoneNumber? phoneNumber = PhoneParser().parseWithIsoCode('FR', '444444');
      await tester.pumpWidget(getWidget(initialValue: phoneNumber));
      final foundTextField = find.byType(TextFormField);
      await tester.enterText(foundTextField, '9984');
      await tester.pumpAndSettle();
      expect(find.text('Invalid'), findsOneWidget);
    });

    testWidgets('Should show / not show flag', (tester) async {
      await tester.pumpWidget(getWidget(showFlagInInput: true));
      expect(find.byType(CircleFlag), findsOneWidget);
      await tester.pumpWidget(getWidget(showFlagInInput: false));
      expect(find.byType(CircleFlag), findsNothing);
    });
  });
}