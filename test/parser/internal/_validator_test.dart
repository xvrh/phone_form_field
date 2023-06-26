import 'package:phone_form_field/src/phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_form_field/src/phone_numbers_parser/src/parsers/_validator.dart';
import 'package:test/test.dart';

void main() {
  group('_Validator', () {
    group('ValidateWithLength()', () {
      test('BE', () {
        final beValidMobilePhone = '479554265';
        final beInvalidMobilePhone = '4795542650';

        expect(
          Validator.validateWithLength(
            PhoneNumber(nsn: beValidMobilePhone, isoCode: IsoCode.BE),
          ),
          isTrue,
        );
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: beValidMobilePhone, isoCode: IsoCode.BE),
                PhoneNumberType.mobile),
            isTrue);
        // not a fixed line
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: beValidMobilePhone, isoCode: IsoCode.BE),
                PhoneNumberType.fixedLine),
            isFalse);
        // and not a general
        expect(
            Validator.validateWithLength(
              PhoneNumber(nsn: beInvalidMobilePhone, isoCode: IsoCode.BE),
            ),
            isFalse);
      });

      test('US', () {
        final validUs = '2025550128';
        final invalidUs = '479554265';
        // invalid for US
        expect(
            Validator.validateWithLength(
              PhoneNumber(nsn: invalidUs, isoCode: IsoCode.US),
            ),
            isFalse);
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: invalidUs, isoCode: IsoCode.US),
                PhoneNumberType.fixedLine),
            isFalse);
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: invalidUs, isoCode: IsoCode.US),
                PhoneNumberType.mobile),
            isFalse);
        // valid US
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: validUs, isoCode: IsoCode.US)),
            isTrue);
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: validUs, isoCode: IsoCode.US),
                PhoneNumberType.fixedLine),
            isTrue);
        expect(
            Validator.validateWithLength(
                PhoneNumber(nsn: validUs, isoCode: IsoCode.US),
                PhoneNumberType.mobile),
            isTrue);
      });

      test('zeroes', () {
        expect(
          Validator.validateWithLength(
              PhoneNumber(isoCode: IsoCode.GB, nsn: '7000000002')),
          isTrue,
        );
      });
    });

    group('ValidateWithPattern()', () {
      test('BE', () {
        final validMobileBE = '479889855';
        final validFixedBE = '64223344';
        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.BE, nsn: validMobileBE),
                PhoneNumberType.mobile),
            isTrue);
        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.BE, nsn: validMobileBE),
                PhoneNumberType.fixedLine),
            isFalse);
        // fixed
        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.BE, nsn: validFixedBE),
                PhoneNumberType.fixedLine),
            isTrue);
        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.BE, nsn: validFixedBE),
                PhoneNumberType.mobile),
            isFalse);
      });

      test('CA', () {
        expect(
            Validator.validateWithPattern(
              PhoneNumber(isoCode: IsoCode.CA, nsn: '7205754713'),
            ),
            isFalse);
        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.CA, nsn: '6135550165')),
            isTrue);
      });

      test('US', () {
        expect(
            Validator.validateWithPattern(
              PhoneNumber(isoCode: IsoCode.US, nsn: '7205754713'),
            ),
            isTrue);

        expect(
            Validator.validateWithPattern(
                PhoneNumber(isoCode: IsoCode.US, nsn: '6135550165')),
            isFalse);
      });
    });
  });
}
