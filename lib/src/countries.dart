import 'package:dart_countries/dart_countries.dart';

final countries = isoCodes

    /// those 3 (small) islands dont have flags in the circle_flags library
    /// it's unlikely anyone with a phone will be from there anyway
    /// those will be added when added to the circle_flags library
    .where((iso) => iso != 'AC' && iso != 'BQ' && iso != 'TA')
    .map((iso) => Country(iso))
    .toList();

/// Country regroup informations for displaying a list of countries
class Country {
  final String isoCode;

  /// English name of the country
  String get name => countriesName[isoCode]!;

  /// country dialing code to call them internationally
  String get dialCode => countriesDialCode[isoCode]!;

  /// returns "+ [dialCode]"
  String get displayDialCode => '+ $dialCode';

  Country(this.isoCode) : assert(isoCodes.contains(isoCode));
}
