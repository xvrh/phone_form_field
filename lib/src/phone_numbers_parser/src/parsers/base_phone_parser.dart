import '../../phone_numbers_parser.dart';
import '_text_parser.dart';

/// {@template phoneNumber}
/// The [phoneNumber] can be of the sort:
///  +33 478 88 88 88,
///  0478 88 88 88,
///  478 88 88 88
/// {@endtemplate}

/// base class for PhoneParser and LightPhoneParser
abstract class BasePhoneParser {
  /// parses a [phoneNumber] given an [isoCode]
  ///
  /// {@macro phoneNumber}
  ///
  /// throws a PhoneNumberException if the isoCode is invalid
  PhoneNumber parseWithIsoCode(String isoCode, String phoneNumber);

  /// parses a [phoneNumber] given a [dialCode]
  ///
  /// Use parseWithIsoCode when possible at multiple countries
  /// use the same dial code.
  ///
  /// {@macro phoneNumber}
  ///
  /// throws a PhoneNumberException if the dial code is invalid
  PhoneNumber parseWithDialCode(String dialCode, String phoneNumber);

  /// parses a [phoneNumber] given a [dialCode]
  ///
  /// Use parseWithIsoCode when possible at multiple countries
  /// use the same dial code.
  ///
  /// This assumes the phone number starts with the dial code
  ///
  /// throws a PhoneNumberException if the dial code is invalid
  PhoneNumber parseRaw(String phoneNumber);

  /// Validates a phone number using length information
  ///
  /// To validate with pattern use the PhoneParser.validate
  ///
  /// if a [type] is added, will validate against a specific type
  bool validate(PhoneNumber phoneNumber, [PhoneNumberType? type]);

  /// change the iso code of a phone number
  ///
  /// return a new [PhoneNumber] with a new isoCode and an nsn that might have
  /// been modified
  PhoneNumber copyWithIsoCode(PhoneNumber phoneNumber, String isoCode) {
    return parseWithIsoCode(isoCode, phoneNumber.nsn);
  }

  /// Extracts phone numbers from a [text].
  /// The potential phone numbers returned are not checked for their validity.
  /// It is possible that a match could be a date or anything else ressembling a phone number.
  /// To verify it is in fact a phone number you can parse it and check its validity
  Iterable<Match> findPotentialPhoneNumbers(String text) {
    return TextParser.findPotentialPhoneNumbers(text);
  }
}
