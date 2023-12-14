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
        5: '"€"#,##0_);("€"#,##0)',
        6: '"€"#,##0_);[Red]("€"#,##0)',
        7: '"€"#,##0.00_);("€"#,##0.00)',
        8: '"€"#,##0.00_);[Red]("€"#,##0.00)',
        9: '0%',
        10: '0.00%',
        11: '0.00E+00',
        12: '# ?/?',
        13: '# ??/??',
        14: 'd/m/yyyy',
        15: 'd/m/yyyy',
        16: 'd/m',
        17: 'm/yyyy',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'h:mm',
        21: 'h:mm:ss',
        22: 'd/m/yyyy h:mm',
        23: 'General',
        24: 'General',
        25: 'General',
        26: 'General',
        27: 'd/m/yyyy',
        28: 'd/m/yyyy',
        29: 'd/m/yyyy',
        30: 'd/m/yyyy',
        31: 'd/m/yyyy',
        32: 'h:mm:ss',
        33: 'h:mm:ss',
        34: 'h:mm:ss',
        35: 'h:mm:ss',
        36: 'd/m/yyyy',
        37: '#,##0_-;#,##0\-',
        38: '#,##0_-;[Red]#,##0-',
        39: '#,##0.00_-;#,##0.00-',
        40: '#,##0.00_-;[Red]#,##0.00-',
        41: '_ * #,##0_ ;_ * -#,##0_ ;_ * "-"_ ;_ @_',
        42: '_ "€" * #,##0_ ;_ "€" * -#,##0_ ;_ "€" * "-"_ ;_ @_',
        43: '_ * #,##0.00_ ;_ * -#,##0.00_ ;_ * "-"??_ ;_ @_',
        44: '_ "€" * #,##0.00_ ;_ "€" * -#,##0.00_ ;_ "€" * "-"??_ ;_ @_',
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
        currency:   [164, '€ #,##0.00'],
        account :   [44 , '_ "€" * #,##0.00_ ;_ "€" * -#,##0.00_ ;_ "€" * "-"??_ ;_ @_'],
        date    :   [14 , 'd/m/yyyy'],
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'],
        time    :   [164, '[$-F400]h:mm:ss AM/PM'],
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_ * #,##0.00_ ;_ * -#,##0.00_ ;_ * "-"??_ ;_ @_']
    },

    LocaleName: "nl",

    GeneralName: "General", // 숫자 일반 서식

    DefaultDatePatterns: [
        "d-m-yyyy h:mm:ss AM/PM", // full date time
        "d-m-yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'dddd d mmmm yyyy',
        'h:mm:ss'
    ],

    ThousandsSeparatorPatterns: [
        // 1000 단위 기호 패턴
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
        '€ #,##0.00',
        '€ #,##0.00;[Red]€ #,##0.00',
        '€ #,##0.00;€ -#,##0.00',
        '€ #,##0.00;[Red]€ -#,##0.00',
    ],

    DatePatterns: [
        "d/m/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "d/m;@",
        "d/mm/yy;@",
        "dd/mm/yy;@",
        "[$-413]d/mmm;@",
        "[$-413]d/mmm/yy;@",
        "[$-413]dd/mmm/yy;@",
        "[$-413]mmm/yy;@",
        "[$-413]mmmm/yy;@",
        "[$-413]d mmmm yyyy;@",
        "[$-409]d/mm/yy h:mm AM/PM;@",
        "d/mm/yy h:mm;@",
        "[$-413]mmmmm;@",
        "[$-413]mmmmm/yy;@",
        "m/d/yyyy;@",
        "[$-413]d/mmm/yyyy;@"
    ],

    TimePatterns: [
        "[$-F400]h:mm:ss AM/PM",
        "h:mm;@",
        "[$-409]h:mm AM/PM;@",
        "h:mm:ss;@",
        "[$-409]h:mm:ss AM/PM;@",
        "mm:ss.0;@",
        "[h]:mm:ss;@",
        "[$-409]d/mm/yy h:mm AM/PM;@",
        "d/mm/yy h:mm;@"
    ],

    SpecialPatterns: [
        '00.00.00.000',
        '0#########',
        '####-##-###',
        '0#-#######',
        '0##-#######',
        '0###-######'
    ],

    SpecialTypes: [
        'Rekeningnummer',
        'Telefoonnummer',
        'Sofi-nummer',
        'Gratis telefoonnummer',
        'Plaats',
        'Regionaal'
    ],

    // ooxml format 으로 정의함
    CustomPatterns: [
        'Standaard',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0;-#,##0',
        '#,##0;[Red]-#,##0',
        '#,##0.00;-#,##0.00',
        '#,##0.00;[Red]-#,##0.00',
        '€ #,##0;€ -#,##0',
        '€ #,##0;[Red]€ -#,##0',
        '€ #,##0.00;€ -#,##0.00',
        '€ #,##0.00;[Red]€ -#,##0.00',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'd-m-yyyy',
        'd-mmm-yy',
        'd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'd-m-yyyy h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_ "€" * #,##0_ ;_ "€" * -#,##0_ ;_ "€" * "-"_ ;_ @_',
        '_ * #,##0_ ;_ * -#,##0_ ;_ * "-"_ ;_ @_',
        '_ "€" * #,##0.00_ ;_ "€" * -#,##0.00_ ;_ "€" * "-"??_ ;_ @_',
        '_ * #,##0.00_ ;_ * -#,##0.00_ ;_ * "-"??_ ;_ @_',
    ],

    ColorElements: ['Zwart', 'Blauw', 'Cyaan', 'Groen', 'Magenta', 'Rood', 'Wit', 'Geel'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "AD"],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "j", // year symbols
        "m", // month symbols
        "d", // day symbols
        "-",
        "u", // hour symbol
        "m", // minute symbol
        "s", // second symbol
        ":" // time seperator
    ],

    NumberElements: [
        ",", // decimal separator
        ".", // group (thousands) separator
        ";" // function param separator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "€", // local currency symbol
        "2", // currency fraction digit count
        "t" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["zon", "zondag"],
        ["maa", "maandag"],
        ["din", "dinsdag"],
        ["woe", "woensdag"],
        ["don", "donderdag"],
        ["vri", "vrijdag"],
        ["zat", "zaterdag"]
    ],

    MonthsLocale: [
        ["j", "jan", "januari"],
        ["f", "feb", "februari"],
        ["m", "mrt", "maart"],
        ["a", "apr", "april"],
        ["m", "mei", "mei"],
        ["j", "jun", "juni"],
        ["j", "jul", "juli"],
        ["a", "aug", "augustus"],
        ["s", "sep", "september"],
        ["o", "okt", "oktober"],
        ["n", "nov", "november"],
        ["d", "dec", "december"]
    ],

    FormulaElements: [
        ";",  // function param separator
        "\\", // array column separator
        ";",  // union operator
        ";"   // array row separator
    ],

    LogicalValues: [
        "ONWAAR", "WAAR"
    ],

    ErrorValues: [
        "#DEEL/0!", "#N/B", "#NAAM?", "#LEEG!", "#GETAL!", "#VERW!", "#WAARDE!"
    ]
});