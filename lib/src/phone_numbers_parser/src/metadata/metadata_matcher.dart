import '../models/phone_number.dart';
import '../parsers/_validator.dart';

import 'models/phone_metadata.dart';

abstract class MetadataMatcher {
  static PhoneMetadata getMatchUsingPatterns(
    String nationalNumber,
    List<PhoneMetadata> potentialFits,
  ) {
    if (potentialFits.length == 1) return potentialFits[0];
    potentialFits = reducePotentialMetadatasFits(nationalNumber, potentialFits);
    for (var fit in potentialFits) {
      final isValidForIso = Validator.validateWithPattern(
          PhoneNumber(nsn: nationalNumber, isoCode: fit.isoCode));
      if (isValidForIso) {
        return fit;
      }
    }
    return potentialFits[0];
  }

  /// Given a list of metadata fits, return the ones that fit a national number
  ///
  /// Expects a normalized [nationalNumber] that is in its international form
  static List<PhoneMetadata> reducePotentialMetadatasFits(
    String nationalNumber,
    List<PhoneMetadata> potentialFits,
  ) {
    if (potentialFits.length == 1) {
      return potentialFits;
    }

    for (var fit in potentialFits) {
      // if multiple fits, check leading digits to see if there is a fit
      final leadingDigits = fit.leadingDigits;

      if (leadingDigits != null && nationalNumber.startsWith(leadingDigits)) {
        return [fit];
      }
    }

    return potentialFits;
  }
}
