import 'dart:math';

import '../../phone_numbers_parser.dart';
import '../constants/constants.dart';
import '../models/phone_number_exceptions.dart';
import '../metadata/metadata_finder.dart';

import '_text_parser.dart';

abstract class CountryCodeParser {
  /// normalize a country calling code to return only digits
  static String normalizeCountryCode(String countryCode) {
    countryCode = TextParser.normalize(countryCode);

    if (countryCode.startsWith('+')) {
      countryCode = countryCode.replaceFirst('+', '');
    }
    // country code don't start with zero
    if (countryCode.startsWith('0')) {
      throw PhoneNumberException(
          code: Code.invalidCountryCallingCode,
          description:
              'country calling code do not start with 0, was $countryCode');
    }
    if (int.tryParse(countryCode) == null) {
      throw PhoneNumberException(
          code: Code.invalidCountryCallingCode,
          description: 'country calling code must be digits, was $countryCode. '
              'Maybe you wanted to parseWithIsoCode ?');
    }
    if (countryCode.length < Constants.minLengthCountryCallingCode ||
        countryCode.length > Constants.maxLengthCountryCallingCode) {
      throw PhoneNumberException(
          code: Code.invalidCountryCallingCode,
          description:
              'country calling code has an invalid length, was $countryCode');
    }
    return countryCode;
  }

  /// tries to find a country calling code at the start of a phone number
  static String extractCountryCode(String phoneNumber) {
    final maxLength =
        min(phoneNumber.length, Constants.maxLengthCountryCallingCode);
    var potentialCountryCode = phoneNumber.substring(0, maxLength);
    potentialCountryCode = normalizeCountryCode(potentialCountryCode);
    for (var i = 1; i <= potentialCountryCode.length; i++) {
      try {
        final potentialCountryCodeFit = potentialCountryCode.substring(0, i);
        MetadataFinder.getMetadatasForCountryCode(potentialCountryCodeFit);
        return potentialCountryCodeFit;
        // ignore: empty_catches
      } catch (e) {}
    }
    throw PhoneNumberException(
        code: Code.notFound,
        description:
            'country calling code not found in phone number $phoneNumber');
  }

  // removes the country code at the start of a phone number
  static String removeCountryCode(String phoneNumber, String countryCode) {
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.substring(countryCode.length);
    }
    return phoneNumber;
  }
}
