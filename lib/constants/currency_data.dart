import '../models/app_currency.dart';

/// Every active ISO 4217 currency (as of 2026), sorted by code.
abstract final class CurrencyData {
  /// Used when the device region has no known currency.
  static const String fallbackCode = 'USD';

  static const List<AppCurrency> all = [
    AppCurrency('AED', 'UAE Dirham', ['AE']),
    AppCurrency('AFN', 'Afghan Afghani', ['AF']),
    AppCurrency('ALL', 'Albanian Lek', ['AL']),
    AppCurrency('AMD', 'Armenian Dram', ['AM']),
    AppCurrency('AOA', 'Angolan Kwanza', ['AO']),
    AppCurrency('ARS', 'Argentine Peso', ['AR']),
    AppCurrency('AUD', 'Australian Dollar', [
      'AU',
      'CX',
      'CC',
      'HM',
      'KI',
      'NR',
      'NF',
      'TV',
    ]),
    AppCurrency('AWG', 'Aruban Florin', ['AW']),
    AppCurrency('AZN', 'Azerbaijani Manat', ['AZ']),
    AppCurrency('BAM', 'Bosnia-Herzegovina Convertible Mark', ['BA']),
    AppCurrency('BBD', 'Barbadian Dollar', ['BB']),
    AppCurrency('BDT', 'Bangladeshi Taka', ['BD']),
    AppCurrency('BHD', 'Bahraini Dinar', ['BH']),
    AppCurrency('BIF', 'Burundian Franc', ['BI']),
    AppCurrency('BMD', 'Bermudian Dollar', ['BM']),
    AppCurrency('BND', 'Brunei Dollar', ['BN']),
    AppCurrency('BOB', 'Bolivian Boliviano', ['BO']),
    AppCurrency('BRL', 'Brazilian Real', ['BR']),
    AppCurrency('BSD', 'Bahamian Dollar', ['BS']),
    AppCurrency('BTN', 'Bhutanese Ngultrum', ['BT']),
    AppCurrency('BWP', 'Botswana Pula', ['BW']),
    AppCurrency('BYN', 'Belarusian Ruble', ['BY']),
    AppCurrency('BZD', 'Belize Dollar', ['BZ']),
    AppCurrency('CAD', 'Canadian Dollar', ['CA']),
    AppCurrency('CDF', 'Congolese Franc', ['CD']),
    AppCurrency('CHF', 'Swiss Franc', ['CH', 'LI']),
    AppCurrency('CLP', 'Chilean Peso', ['CL']),
    AppCurrency('CNY', 'Chinese Yuan', ['CN']),
    AppCurrency('COP', 'Colombian Peso', ['CO']),
    AppCurrency('CRC', 'Costa Rican Colón', ['CR']),
    AppCurrency('CUP', 'Cuban Peso', ['CU']),
    AppCurrency('CVE', 'Cape Verdean Escudo', ['CV']),
    AppCurrency('CZK', 'Czech Koruna', ['CZ']),
    AppCurrency('DJF', 'Djiboutian Franc', ['DJ']),
    AppCurrency('DKK', 'Danish Krone', ['DK', 'FO', 'GL']),
    AppCurrency('DOP', 'Dominican Peso', ['DO']),
    AppCurrency('DZD', 'Algerian Dinar', ['DZ']),
    AppCurrency('EGP', 'Egyptian Pound', ['EG']),
    AppCurrency('ERN', 'Eritrean Nakfa', ['ER']),
    AppCurrency('ETB', 'Ethiopian Birr', ['ET']),
    AppCurrency('EUR', 'Euro', [
      'AD', 'AT', 'AX', 'BE', 'BG', 'BL', 'CY', 'DE', 'EE', 'ES', 'FI', 'FR', //
      'GF', 'GP', 'GR', 'HR', 'IE', 'IT', 'LT', 'LU', 'LV', 'MC', 'ME', 'MF',
      'MQ', 'MT', 'NL', 'PM', 'PT', 'RE', 'SI', 'SK', 'SM', 'VA', 'XK', 'YT',
    ]),
    AppCurrency('FJD', 'Fijian Dollar', ['FJ']),
    AppCurrency('FKP', 'Falkland Islands Pound', ['FK']),
    AppCurrency('GBP', 'British Pound', ['GB', 'GG', 'IM', 'JE']),
    AppCurrency('GEL', 'Georgian Lari', ['GE']),
    AppCurrency('GHS', 'Ghanaian Cedi', ['GH']),
    AppCurrency('GIP', 'Gibraltar Pound', ['GI']),
    AppCurrency('GMD', 'Gambian Dalasi', ['GM']),
    AppCurrency('GNF', 'Guinean Franc', ['GN']),
    AppCurrency('GTQ', 'Guatemalan Quetzal', ['GT']),
    AppCurrency('GYD', 'Guyanese Dollar', ['GY']),
    AppCurrency('HKD', 'Hong Kong Dollar', ['HK']),
    AppCurrency('HNL', 'Honduran Lempira', ['HN']),
    AppCurrency('HTG', 'Haitian Gourde', ['HT']),
    AppCurrency('HUF', 'Hungarian Forint', ['HU']),
    AppCurrency('IDR', 'Indonesian Rupiah', ['ID']),
    AppCurrency('ILS', 'Israeli New Shekel', ['IL', 'PS']),
    AppCurrency('INR', 'Indian Rupee', ['IN']),
    AppCurrency('IQD', 'Iraqi Dinar', ['IQ']),
    AppCurrency('IRR', 'Iranian Rial', ['IR']),
    AppCurrency('ISK', 'Icelandic Króna', ['IS']),
    AppCurrency('JMD', 'Jamaican Dollar', ['JM']),
    AppCurrency('JOD', 'Jordanian Dinar', ['JO']),
    AppCurrency('JPY', 'Japanese Yen', ['JP']),
    AppCurrency('KES', 'Kenyan Shilling', ['KE']),
    AppCurrency('KGS', 'Kyrgyzstani Som', ['KG']),
    AppCurrency('KHR', 'Cambodian Riel', ['KH']),
    AppCurrency('KMF', 'Comorian Franc', ['KM']),
    AppCurrency('KPW', 'North Korean Won', ['KP']),
    AppCurrency('KRW', 'South Korean Won', ['KR']),
    AppCurrency('KWD', 'Kuwaiti Dinar', ['KW']),
    AppCurrency('KYD', 'Cayman Islands Dollar', ['KY']),
    AppCurrency('KZT', 'Kazakhstani Tenge', ['KZ']),
    AppCurrency('LAK', 'Lao Kip', ['LA']),
    AppCurrency('LBP', 'Lebanese Pound', ['LB']),
    AppCurrency('LKR', 'Sri Lankan Rupee', ['LK']),
    AppCurrency('LRD', 'Liberian Dollar', ['LR']),
    AppCurrency('LSL', 'Lesotho Loti', ['LS']),
    AppCurrency('LYD', 'Libyan Dinar', ['LY']),
    AppCurrency('MAD', 'Moroccan Dirham', ['MA', 'EH']),
    AppCurrency('MDL', 'Moldovan Leu', ['MD']),
    AppCurrency('MGA', 'Malagasy Ariary', ['MG']),
    AppCurrency('MKD', 'Macedonian Denar', ['MK']),
    AppCurrency('MMK', 'Myanmar Kyat', ['MM']),
    AppCurrency('MNT', 'Mongolian Tögrög', ['MN']),
    AppCurrency('MOP', 'Macanese Pataca', ['MO']),
    AppCurrency('MRU', 'Mauritanian Ouguiya', ['MR']),
    AppCurrency('MUR', 'Mauritian Rupee', ['MU']),
    AppCurrency('MVR', 'Maldivian Rufiyaa', ['MV']),
    AppCurrency('MWK', 'Malawian Kwacha', ['MW']),
    AppCurrency('MXN', 'Mexican Peso', ['MX']),
    AppCurrency('MYR', 'Malaysian Ringgit', ['MY']),
    AppCurrency('MZN', 'Mozambican Metical', ['MZ']),
    AppCurrency('NAD', 'Namibian Dollar', ['NA']),
    AppCurrency('NGN', 'Nigerian Naira', ['NG']),
    AppCurrency('NIO', 'Nicaraguan Córdoba', ['NI']),
    AppCurrency('NOK', 'Norwegian Krone', ['NO', 'SJ', 'BV']),
    AppCurrency('NPR', 'Nepalese Rupee', ['NP']),
    AppCurrency('NZD', 'New Zealand Dollar', ['NZ', 'CK', 'NU', 'PN', 'TK']),
    AppCurrency('OMR', 'Omani Rial', ['OM']),
    AppCurrency('PAB', 'Panamanian Balboa', ['PA']),
    AppCurrency('PEN', 'Peruvian Sol', ['PE']),
    AppCurrency('PGK', 'Papua New Guinean Kina', ['PG']),
    AppCurrency('PHP', 'Philippine Peso', ['PH']),
    AppCurrency('PKR', 'Pakistani Rupee', ['PK']),
    AppCurrency('PLN', 'Polish Złoty', ['PL']),
    AppCurrency('PYG', 'Paraguayan Guaraní', ['PY']),
    AppCurrency('QAR', 'Qatari Riyal', ['QA']),
    AppCurrency('RON', 'Romanian Leu', ['RO']),
    AppCurrency('RSD', 'Serbian Dinar', ['RS']),
    AppCurrency('RUB', 'Russian Ruble', ['RU']),
    AppCurrency('RWF', 'Rwandan Franc', ['RW']),
    AppCurrency('SAR', 'Saudi Riyal', ['SA']),
    AppCurrency('SBD', 'Solomon Islands Dollar', ['SB']),
    AppCurrency('SCR', 'Seychellois Rupee', ['SC']),
    AppCurrency('SDG', 'Sudanese Pound', ['SD']),
    AppCurrency('SEK', 'Swedish Krona', ['SE']),
    AppCurrency('SGD', 'Singapore Dollar', ['SG']),
    AppCurrency('SHP', 'St. Helena Pound', ['SH']),
    AppCurrency('SLE', 'Sierra Leonean Leone', ['SL']),
    AppCurrency('SOS', 'Somali Shilling', ['SO']),
    AppCurrency('SRD', 'Surinamese Dollar', ['SR']),
    AppCurrency('SSP', 'South Sudanese Pound', ['SS']),
    AppCurrency('STN', 'São Tomé & Príncipe Dobra', ['ST']),
    AppCurrency('SYP', 'Syrian Pound', ['SY']),
    AppCurrency('SZL', 'Swazi Lilangeni', ['SZ']),
    AppCurrency('THB', 'Thai Baht', ['TH']),
    AppCurrency('TJS', 'Tajikistani Somoni', ['TJ']),
    AppCurrency('TMT', 'Turkmenistani Manat', ['TM']),
    AppCurrency('TND', 'Tunisian Dinar', ['TN']),
    AppCurrency('TOP', 'Tongan Paʻanga', ['TO']),
    AppCurrency('TRY', 'Turkish Lira', ['TR']),
    AppCurrency('TTD', 'Trinidad & Tobago Dollar', ['TT']),
    AppCurrency('TWD', 'New Taiwan Dollar', ['TW']),
    AppCurrency('TZS', 'Tanzanian Shilling', ['TZ']),
    AppCurrency('UAH', 'Ukrainian Hryvnia', ['UA']),
    AppCurrency('UGX', 'Ugandan Shilling', ['UG']),
    AppCurrency('USD', 'US Dollar', [
      'US', 'AS', 'BQ', 'EC', 'FM', 'GU', 'IO', 'MH', 'MP', 'PR', 'PW', 'SV', //
      'TC', 'TL', 'UM', 'VG', 'VI',
    ]),
    AppCurrency('UYU', 'Uruguayan Peso', ['UY']),
    AppCurrency('UZS', 'Uzbekistani Som', ['UZ']),
    AppCurrency('VES', 'Venezuelan Bolívar', ['VE']),
    AppCurrency('VND', 'Vietnamese Dong', ['VN']),
    AppCurrency('VUV', 'Vanuatu Vatu', ['VU']),
    AppCurrency('WST', 'Samoan Tala', ['WS']),
    AppCurrency('XAF', 'Central African CFA Franc', [
      'CM',
      'CF',
      'TD',
      'CG',
      'GQ',
      'GA',
    ]),
    AppCurrency('XCD', 'East Caribbean Dollar', [
      'AG',
      'AI',
      'DM',
      'GD',
      'KN',
      'LC',
      'MS',
      'VC',
    ]),
    AppCurrency('XCG', 'Caribbean Guilder', ['CW', 'SX']),
    AppCurrency('XOF', 'West African CFA Franc', [
      'BJ',
      'BF',
      'CI',
      'GW',
      'ML',
      'NE',
      'SN',
      'TG',
    ]),
    AppCurrency('XPF', 'CFP Franc', ['PF', 'NC', 'WF']),
    AppCurrency('YER', 'Yemeni Rial', ['YE']),
    AppCurrency('ZAR', 'South African Rand', ['ZA']),
    AppCurrency('ZMW', 'Zambian Kwacha', ['ZM']),
    AppCurrency('ZWG', 'Zimbabwe Gold', ['ZW']),
  ];

  static final Map<String, AppCurrency> _byCode = {
    for (final currency in all) currency.code: currency,
  };

  static final Map<String, AppCurrency> _byCountry = {
    for (final currency in all)
      for (final country in currency.countries) country: currency,
  };

  /// The fallback currency (US Dollar).
  static AppCurrency get fallback => _byCode[fallbackCode]!;

  /// Looks up a currency by ISO code, or `null` if unknown.
  static AppCurrency? tryByCode(String? code) =>
      code == null ? null : _byCode[code.toUpperCase()];

  /// Currency for an ISO 3166 [countryCode], falling back to USD.
  static AppCurrency forCountry(String? countryCode) =>
      (countryCode == null ? null : _byCountry[countryCode.toUpperCase()]) ??
      fallback;

  /// Case-insensitive search across code and name.
  static List<AppCurrency> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return all;
    return all
        .where(
          (c) =>
              c.code.toLowerCase().contains(needle) ||
              c.name.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }
}
