/**
 * @author jhmoon
 */
define({
    InternalFormatString: {
        0: 'General',
        1: '0',
        2: '0.00',
        3: '#,##0',
        4: '#,##0.00',
        5: '#,##0 "€";-#,##0 "€"',
        6: '#,##0 "€";[Red]-#,##0 "€"',
        7: '#,##0.00 "€";-#,##0.00 "€"',
        8: '#,##0.00 "€";[Red]-#,##0.00 "€"',
        9: '0%',
        10: '0.00%',
        11: '0.00E+00',
        12: '# ?/?',
        13: '# ??/??',
        14: 'dd/mm/yyyy',
        15: 'dd/mmm/yy',
        16: 'dd/mmm',
        17: 'mmm/yy',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'hh:mm',
        21: 'hh:mm:ss',
        22: 'dd/mm/yyyy h:mm',
        23: 'General',
        24: 'General',
        25: 'General',
        26: 'General',
        27: 'dd/mm/yyyy',
        28: 'dd/mm/yyyy',
        29: 'dd/mm/yyyy',
        30: 'dd/mm/yyyy',
        31: 'dd/mm/yyyy',
        32: 'hh:mm:ss',
        33: 'hh:mm:ss',
        34: 'hh:mm:ss',
        35: 'hh:mm:ss',
        36: 'dd/mm/yyyy',
        37: '#,##0 _€;-#,##0 _€',
        38: '#,##0 _€;[Red]-#,##0 _€',
        39: '#,##0.00 _€;-#,##0.00 _€',
        40: '#,##0.00 _€;[Red]-#,##0.00 _€',
        41: '_-* #,##0 _€_-;-* #,##0 _€_-;_-* "-" _€_-;_-@_-',
        42: '_-* #,##0 "€"_-;-* #,##0 "€"_-;_-* "-" "€"_-;_-@_-',
        43: '_-* #,##0.00 _€_-;-* #,##0.00 _€_-;_-* "-"?? _€_-;_-@_-',
        44: '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-',
        45: 'mm:ss',
        46: '[h]:mm:ss',
        47: 'mm:ss.0',
        48: '##0.0E+0',
        49: '@',
        50: 'dd/mm/yyyy',
        51: 'dd/mm/yyyy',
        52: 'dd/mm/yyyy',
        53: 'dd/mm/yyyy',
        54: 'dd/mm/yyyy',
        55: 'dd/mm/yyyy',
        56: 'dd/mm/yyyy',
        57: 'dd/mm/yyyy',
        58: 'dd/mm/yyyy',
        59: '0',
        60: '0.00'
    },

    DefaultLocationFormat: {
        number  :   [2  , '0.00'],
        currency:   [164, '#,##0.00 €'],
        account :   [44 , '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-'],
        date    :   [14 , 'dd/mm/yyyy'],
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'],
        time    :   [164, '[$-F400]h:mm:ss AM/PM'],
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_-* #,##0.00 _€_-;-* #,##0.00 _€_-;_-* "-"?? _€_-;_-@_-']
    },

    LocaleName: "de",

    GeneralName: "Standard", // 숫자 일반 서식

    DefaultDatePatterns: [
        "dd/mm/yyyy h:mm:ss AM/PM", // full date time
        "dd/mm/yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'dddd, d. mmmm yyyy',
        'h:mm:ss'
    ],

    // 1000 단위 기호 패턴
    ThousandsSeparatorPatterns: [
        '#,##0.00',
        '#,##0.00;[Red]#,##0.00',
        '#,##0.00_ ;-#,##0.00 ',
        '#,##0.00_ ;[Red]-#,##0.00 '
    ],

    // 음수 패턴
    NegativePatterns: [
        '0.00',
        '0.00;[Red]0.00',
        '0.00_ ;-0.00 ',
        '0.00_ ;[Red]-0.00 '
    ],

    // default 소수 자릿수 2
    CurrencyPatterns: [
        '#,##0.00 €',
        '#,##0.00 €;[Red]#,##0.00 €',
        '#,##0.00 €;-#,##0.00 €',
        '#,##0.00 €;[Red]-#,##0.00 €',
    ],

    DatePatterns: [
        "dd/mm/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "d/m;@",
        "d/m/yy;@",
        "dd/mm/yy;@",
        "[$-407]d/ mmm/;@",
        "[$-407]d/ mmm/ yy;@",
        "[$-407]d/ mmm yy;@",
        "[$-407]mmm/ yy;@",
        "[$-407]mmmm yy;@",
        "[$-407]d/ mmmm yyyy;@",
        "[$-409]d/m/yy h:mm AM/PM;@",
        "d/m/yy h:mm;@",
        "[$-407]mmmmm;@",
        "[$-407]mmmmm yy;@",
        "d/m/yyyy;@",
        "[$-407]d/ mmm/ yyyy;@"
    ],

    TimePatterns: [
        '[$-F400]h:mm:ss AM/PM', // 9:30:55 AM
        'h:mm;@',
        '[$-409]h:mm AM/PM;@',
        'h:mm:ss;@',
        '[$-409]h:mm:ss AM/PM;@',
        'mm:ss.0;@',
        '[h]:mm:ss;@',
        '[$-409]m/d/yy h:mm AM/PM;@',
        'm/d/yy h:mm;@'
    ],

    SpecialPatterns: [
        '00000',
        '\\A-00000',
        'C\\H-00000',
        '\\D-00000',
        '\\L-00000',
        '\\[@\\]',
        '0000-00 00 00',
        '000\\.00\\.000\\.000',
        'I\\S\\B\\N #-###-#####-#',
        'I\\S\\B\\N #-####-####-#',
        'I\\S\\B\\N #-#####-###-#'
    ],

    SpecialTypes: [
        'Postleitzahl',
        'Postleitzahl (A)',
        'Postleitzahl (CH)',
        'Postleitzahl (D)',
        'Postleitzahl (L)',
        'Versicherungsnachweis-Nr. (D)',
        'Sozialversicherungsnummer (A)',
        'Sozialversicherungsnummer (CH)',
        'ISBN-Format (ISBN x-xxx-xxxxx-x)',
        'ISBN-Format (ISBN x-xxxx-xxxx-x)',
        'ISBN-Format (ISBN x-xxxxx-xxx-x)'
    ],

    // ooxml format 으로 정의함
    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0 _€;-#,##0 _€',
        '#,##0 _€;[Rot]-#,##0 _€',
        '#,##0.00 _€;-#,##0.00 _€',
        '#,##0.00 _€;[Rot]-#,##0.00 _€',
        '#,##0 €;-#,##0 €',
        '#,##0 €;[Rot]-#,##0 €',
        '#,##0,00 €;-#,##0.00 €',
        '#,##0,00 €;[Rot]-#,##0.00 €',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'dd.mm.yyyy',
        'dd. mmm yy',
        'dd. mmm',
        'mmm yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'hh:mm',
        'hh:mm:ss',
        'dd.mm.yyyy hh:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-* #,##0 "€"_-;-* #,##0 "€"_-;_-* "-" "€"_-;_-@_-',
        '_-* #,##0 _€_-;-* #,##0 _€_-;_-* "-" _€_-;_-@_-',
        '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-',
        '_-* #,##0.00 _€_-;-* #,##0.00 _€_-;_-* "-"?? _€_-;_-@_-',
    ],

    ColorElements: ['Schwarz', 'Blau', 'Cyon', 'Vert', 'Grün', 'Rot', 'Weiß', 'Gelb'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["v. Chr.", "n. Chr."],

    YearTables: ["0"],

    CharSeperator: ["!"],

    DateElements: [
        "J", // year symbols
        "M", // month symbols
        "T", // day symbols
        ".", // date seperator
        "h", // hour symbol
        "m", // minute symbol
        "s", // second symbol
        ":" // time seperator
    ],

    NumberElements: [
        ",", // decimal separator
        ".", // group (thousands) separator
        ";" // list separator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "€", // euro currency symbol
        "2", // currency fraction digit count
        "f" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["So", "Sonntag"],
        ["Mo", "Montag"],
        ["Di", "Dienstag"],
        ["Mi", "Mittwoch"],
        ["Do", "Donnerstag"],
        ["Fr", "Freitag"],
        ["Sa", "Samstag"]
    ],

    MonthsLocale: [
        ["J", "Jan", "Januar"],
        ["F", "Feb", "Februar"],
        ["M", "Mrz", "M\u00e4rz"],
        ["A", "Apr", "April"],
        ["M", "Mai", "Mai"],
        ["J", "Jun", "Juni"],
        ["J", "Jul", "Juli"],
        ["A", "Aug", "August"],
        ["S", "Sep", "September"],
        ["O", "Okt", "Oktober"],
        ["N", "Nov", "November"],
        ["D", "Dez", "Dezember"]
    ],

    FormulaElements: [
        ";", // function param separator
        ".", // array column separator
        ";", // union operator
        ";"  // array row separator
    ],

    LogicalValues: [
        "FALSCH", "WAHR"
    ],

    ErrorValues: [
        "#DIV/0!", "#NV", "#NAME?", "#NULL!", "#ZAHL!", "#BEZUG!", "#WERT!"
    ]
});