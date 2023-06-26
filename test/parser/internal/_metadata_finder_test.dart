import 'package:phone_form_field/src/phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_form_field/src/phone_numbers_parser/src/metadata/metadata_finder.dart';
import 'package:phone_form_field/src/phone_numbers_parser/src/metadata/models/phone_metadata_formats.dart';
import 'package:phone_form_field/src/phone_numbers_parser/src/metadata/models/phone_metadata_lengths.dart';
import 'package:phone_form_field/src/phone_numbers_parser/src/metadata/models/phone_metadata_patterns.dart';
import 'package:test/test.dart';

void main() {
  group('MetadataFinder', () {
    test('should get metadata for iso code', () {
      for (final isoCode in IsoCode.values) {
        expect(MetadataFinder.getMetadataForIsoCode(isoCode).isoCode,
            equals(isoCode));
      }
    });

    test('should get patterns metadata for iso code', () {
      for (final isoCode in IsoCode.values) {
        expect(MetadataFinder.getMetadataPatternsForIsoCode(isoCode),
            isA<PhoneMetadataPatterns>());
      }
    });

    test('should get lengths metadata for iso code', () {
      for (final isoCode in IsoCode.values) {
        expect(MetadataFinder.getMetadataLengthForIsoCode(isoCode),
            isA<PhoneMetadataLengths>());
      }
    });

    test('should get formats metadata for iso code', () {
      for (final isoCode in IsoCode.values) {
        expect(MetadataFinder.getMetadataFormatsForIsoCode(isoCode),
            isA<PhoneMetadataFormats>());
      }
    });

    test('should get metadata list for country calling code', () {
      expect(MetadataFinder.getMetadatasForCountryCode('33').length, equals(1));
      expect(MetadataFinder.getMetadatasForCountryCode('33')[0].isoCode,
          equals(IsoCode.FR));

      expect(MetadataFinder.getMetadatasForCountryCode('1').length,
          greaterThan(1));
      expect(MetadataFinder.getMetadatasForCountryCode('1')[0].isoCode,
          equals(IsoCode.US));
    });
  });
}
