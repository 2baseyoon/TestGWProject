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
        5: '"$"#,##0_);("$"#,##0)',
        6: '"$"#,##0_);[Red]("$"#,##0)',
        7: '"$"#,##0.00_);("$"#,##0.00)',
        8: '"$"#,##0.00_);[Red]("$"#,##0.00)',
        9: '0%',
        10: '0.00%',
        11: '0.00E+00',
        12: '# ?/?',
        13: '# ??/??',
        14: 'm/d/yyyy',
        15: 'd-mmm-yy',
        16: 'd-mmm',
        17: 'mmm-yy',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'h:mm',
        21: 'h:mm:ss',
        22: 'd/mm/yyyy h:mm',
        23: 'General',
        24: 'General',
        25: 'General',
        26: 'General',
        27: 'd/mm/yyyy',
        28: 'd/mm/yyyy',
        29: 'd/mm/yyyy',
        30: 'd/mm/yyyy',
        31: 'd/mm/yyyy',
        32: 'h:mm:ss',
        33: 'h:mm:ss',
        34: 'h:mm:ss',
        35: 'h:mm:ss',
        36: 'd/mm/yyyy',
        37: '#,##0_);(#,##0)',
        38: '#,##0_);[Red](#,##0)',
        39: '#,##0.00_);(#,##0.00)',
        40: '#,##0.00_);[Red](#,##0.00)',
        41: '_(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)',
        42: '_("$"* #,##0_);_("$"* (#,##0);_("$"* "-"_);_(@_)',
        43: '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)',
        44: '_("$"* #,##0.00_);_("$"* (#,##0.00);_("$"* "-"??_);_(@_)',
        45: 'mm:ss',
        46: '[h]:mm:ss',
        47: 'mm:ss.0',
        48: '##0.0E+0',
        49: '@',
        50: 'd/mm/yyyy',
        51: 'd/mm/yyyy',
        52: 'd/mm/yyyy',
        53: 'd/mm/yyyy',
        54: 'd/mm/yyyy',
        55: 'd/mm/yyyy',
        56: 'd/mm/yyyy',
        57: 'd/mm/yyyy',
        58: 'd/mm/yyyy',
        59: '0',
        60: '0.00'
    },

    /**
     * 메뉴에서 숫자서식 지정시 로케이션별로 formatID/formatString 다르게 설정됨에 따라
     * 로케이션별 dataSet 지정
     * ex) number의 경우 ko -> 1:'0', en -> 2:'0,00'
     */
    DefaultLocationFormat: {
        number  :   [2  , '0.00'], // NumberPatterns[0]
        currency:   [164, '$#,##0.00'], // CurrencyPatterns[0]
        account :   [44 , '_("$"* #,##0.00_);_("$"* (#,##0.00);_("$"* "-"??_);_(@_)'],
        date    :   [14 , 'm/d/yyyy'], // DatePatterns[0]
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'], // DatePatterns[1]
        time    :   [164, '[$-F400]h:mm:ss AM/PM'], // TimePatterns[0]
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)'] // account 에서 기호없는 패턴
    },

    LocaleName: "es_us",

    GeneralName: "General", // 숫자 일반 서식

    DefaultDatePatterns: [
        "d-m-yy h:mm:ss", // full date time
        "dd-mm-yyyy", // date
        "h:mm:ss" // time
    ],

    DatePatterns: [
        'm/d/yyyy',
        '[$-F800]dddd, mmmm dd, yyyy',
        '[$-40A]m/d/yyyy;@',
        '[$-40A]m/d/yy;@',
        '[$-40A]mm/dd/yy;@',
        '[$-40A]mm/dd/yyyy;@',
        '[$-40A]yy/mm/dd;@',
        '[$-40A]yyyy-mm-dd;@',
        '[$-40A]dd-mmm-yy;@',
        '[$-40A]dddd, mmmm dd, yyyy;@',
        '[$-40A]mmmm dd, yyyy;@',
        '[$-40A]dddd, dd mmmm, yyyy;@',
        '[$-40A]dd mmmm, yyyy;@'
    ],

    TimePatterns: [
        '[$-F400]h:mm:ss AM/PM',
        '[$-409]h:mm:ss AM/PM;@',
        '[$-409]hh:mm:ss AM/PM;@',
        '[$-40A]h:mm:ss;@',
        '[$-40A]hh:mm:ss;@'
    ],

    ColorElements: ['Black', 'Blue', 'Cyan', 'Green', 'Magenta', 'Red', 'White', 'Yellow'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "AD"],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "y", // year symbols
        "m", // month symbols
        "d", // day symbols
        "/", // date seperator
        "h", // hour symbol
        "m", // minute symbol
        "s", // second symbol
        ":" // time seperator
    ],

    NumberElements: [
        ".", // decimal separator
        ",", // group (thousands) separator
        "," // function param separator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "$", // local currency symbol
        "2", // currency fraction digit count
        "t" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["Dom", "Domingo"],
        ["Lun", "Lunes"],
        ["Mar", "Martes"],
        ["Mi\u00e9", "Mi\u00e9rcoles"],
        ["Jue", "Jueves"],
        ["Vie", "Viernes"],
        ["S\u00e1b", "S\u00e1bado"]
    ],

    MonthsLocale: [
        ["E", "Ene", "Enero"],
        ["F", "Feb", "Febrero"],
        ["M", "Mar", "Marzo"],
        ["A", "Abr", "Abril"],
        ["M", "May", "Mayo"],
        ["J", "Jun", "Junio"],
        ["J", "Jul", "Julio"],
        ["A", "Ago", "Agosto"],
        ["S", "Sep", "Septiembre"],
        ["O", "Oct", "Octubre"],
        ["N", "Nov", "Noviembre"],
        ["D", "Dic", "Diciembre"]
    ],

    FormulaElements: [
        ",", // function param separator
        ",", // array column separator
        ",", // union operator
        ";"  // array row separator
    ]
});