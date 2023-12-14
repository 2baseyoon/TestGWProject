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
        15: 'dd-mmm-yy',
        16: 'dd-mmm',
        17: 'mmm-yy',
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
        41: '_-* #,##0\ _€_-;-* #,##0\ _€_-;_-* "-" _€_-;_-@_-',
        42: '_-* #,##0 "€"_-;-* #,##0 "€"_-;_-* "-" "€"_-;_-@_-',
        43: '_-* #,##0.00\ _€_-;-* #,##0.00\ _€_-;_-* "-"??\ _€_-;_-@_-',
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
        comma   :   [43 , '_-* #,##0.00\ _€_-;-* #,##0.00\ _€_-;_-* "-"??\ _€_-;_-@_-']
    },

    LocaleName: "fr",

    GeneralName: "Standard", // 숫자 일반 서식

    DefaultDatePatterns: [
        "dd/mm/yyyy h:mm:ss AM/PM", // full date time
        "dd/mm/yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'dddd d mmmm yyyy',
        'h:mm:ss'
    ],

    // 1000 단위 기호 패턴
    ThousandsSeparatorPatterns: [
        '#,##0.00',
        '#,##0.00;[Red]#,##0.00',
        '#,##0.00_ ;-#,##0.00\\ ',
        '#,##0.00_ ;[Red]-#,##0.00\\ '
    ],

    // 음수 패턴, default 소수 자릿수 2
    NegativePatterns: [
        '0.00',
        '0.00;[Red]0.00',
        '0.00_ ;-0.00\\ ',
        '0.00_ ;[Red]-0.00\\ '
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
        "[$-40C]d-mmm;@",
        "[$-40C]d-mmm-yy;@",
        "[$-40C]dd-mmm-yy;@",
        "[$-40C]mmm-yy;@",
        "[$-40C]mmmm-yy;@",
        "[$-40C]d mmmm yyyy;@",
        "[$-409]d/m/yy h:mm AM/PM;@",
        "d/m/yy h:mm;@",
        "[$-40C]mmmmm;@",
        "[$-40C]mmmmm-yy;@",
        "m/d/yyyy;@",
        "[$-40C]d-mmm-yyyy;@"
    ],

    TimePatterns: [
        '[$-F400]h:mm:ss AM/PM', // 9:30:55 AM
        'h:mm;@',
        '[$-409]h:mm AM/PM;@',
        'h:mm:ss;@',
        '[$-409]h:mm:ss AM/PM;@',
        'mm:ss.0;@', // fr os : mm:ss,0;@
        '[h]:mm:ss;@',
        '[$-409]d/m/yy h:mm AM/PM;@',
        'd/m/yy h:mm;@'
    ],

    SpecialPatterns: [
        '00000',
        '[>=3000000000000]#" "##" "##" "##" "###" "###" | "##;#" "##" "##" "##" "###" "###',
        '0#" "##" "##" "##" "##',
        '0##-000" "00" "00',
        '[>=10000000000]#-###-###-###;[>=10000000](###)" "###-####;000-0000',
        '##" "00" "00',
        '#" "00" "00" "00',
        '0##"/"000" "00" "00'
    ],

    SpecialTypes: [
        'code postal',
        'Numéro de sécurité sociale',
        'Numéro de téléphone',
        'Numéro de téléphone (Belgique)',
        'Numéro de téléphone (Canada)',
        'Numéro de téléphone (Luxembourg)',
        'Numéro de téléphone (Maroc)',
        'Numéro de téléphone (Suisse)'
    ],

    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0\\ _€;-#,##0\ _€',
        '#,##0\\ _€;[Red]-#,##0\\ _€',
        '#,##0.00\\ _€;-#,##0.00\\ _€',
        '#,##0.00\\ _€;[Red]-#,##0.00\\ _€',
        '#,##0 €;-#,##0 €',
        '#,##0 €;[Red]-#,##0 €',
        '#,##0.00 €;-#,##0.00 €',
        '#,##0.00 €;[Red]-#,##0.00 €',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '#" "?/?',
        '#" "??/??',
        'dd/mm/yyyy',
        'dd-mmm-yy',
        'dd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'hh:mm',
        'hh:mm:ss',
        'dd/mm/yyyy hh:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-* #,##0 "€"_-;-* #,##0 "€"_-;_-* "-" "€"_-;_-@_-',
        '_-* #,##0\\ _€_-;-* #,##0\\ _€_-;_-* "-" _€_-;_-@_-',
        '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-',
        '_-* #,##0.00\\ _€_-;-* #,##0.00\\ _€_-;_-* "-"??\\ _€_-;_-@_-',
    ],

    ColorElements: ['Noir', 'Blue', 'Turquoise', 'Vert', 'Rose', 'Rouse', 'Blanc', 'Jaune'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "ap. J.-C."],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "a", // year symbols
        "m", // month symbols
        "j", // day symbols
        "/", // date seperator
        "h", // hour symbol
        "m", // minute symbol
        "s", // second symbol
        ":" // time seperator
    ],

    NumberElements: [
        ",", // decimal separator
        " ", // group (thousands) separator
        ";" // function param separator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "€", // local currency symbol
        "2", // currency fraction digit count
        "f" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["dim.", "dimanche"],
        ["lun.", "lundi"],
        ["mar.", "mardi"],
        ["mer.", "mercredi"],
        ["jeu.", "jeudi"],
        ["ven.", "vendredi"],
        ["sam.", "samedi"]
    ],

    MonthsLocale: [
        ["J", "janv", "janvier"],
        ["F", "f\u00e9vr.", "f\u00e9vrier"],
        ["M", "mars", "mars"],
        ["A", "avr", "avril"],
        ["M", "mai", "mai"],
        ["J", "juin", "juin"],
        ["J", "juil.", "juillet"],
        ["A", "ao\u00fbt", "ao\u00fbt"],
        ["S", "sept.", "septembre"],
        ["O", "oct.", "octobre"],
        ["N", "nov", "novembre"],
        ["D", "d\u00e9c.", "d\u00e9cembre"]
    ],

    FormulaElements: [
        ";", // function param separator
        ".", // array column separator
        ";", // union operator
        ";"  // array row separator
    ],

    LogicalValues: [
        "EPÄTOSI", "TOSI"
    ],

    ErrorValues: [
        "#JAKO/0!", "#PUUTTUU", "#NIMI?", "#TYHJÄ!", "#LUKU!", "#VIITTAUS!", "#ARVO!"
    ]
});