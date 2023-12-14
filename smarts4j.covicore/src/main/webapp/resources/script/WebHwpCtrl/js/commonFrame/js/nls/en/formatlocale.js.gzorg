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

    LocaleName: "en",

    GeneralName: "General", // 숫자 일반 서식

    DefaultDatePatterns: [
        "mm/dd/yyyy h:mm:ss AM/PM", // full date time
        "mm/dd/yyyy", // date
        "h:mm:ss AM/PM" // time
    ],

    // F800, F400 등 system data time 에 대한 로케일 서식
    SystemDateTimePatterns: [
        'dddd, mmmm d, yyyy',
        'h:mm:ss AM/PM'
    ],

    // 1000 단위 기호 패턴
    ThousandsSeparatorPatterns: [
        // 1000 단위 기호 패턴
        '#,##0.00',
        '#,##0.00;[Red]#,##0.00',
        '#,##0.00_);(#,##0.00)',
        '#,##0.00_);[Red](#,##0.00)'
    ],

    // 음수 패턴, default 소수 자릿수 2
    NegativePatterns: [
        '0.00',
        '0.00;[Red]0.00',
        '0.00_);(0.00)',
        '0.00_);[Red](0.00)',
    ],

    // default 소수 자릿수 2
    CurrencyPatterns: [
        '$#,##0.00',
        '$#,##0.00;[Red]$#,##0.00',
        '$#,##0.00_);($#,##0.00)',
        '$#,##0.00_);[Red]($#,##0.00)',
    ],

    DatePatterns: [
        "m/d/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "m/d;@",
        "m/d/yy;@",
        "mm/dd/yy;@",
        "[$-409]d-mmm;@",
        "[$-409]d-mmm-yy;@",
        "[$-409]dd-mmm-yy;@",
        "[$-409]mmm-yy;@",
        "[$-409]mmmm-yy;@",
        "[$-409]mmmm d, yyyy;@",
        "[$-409]m/d/yy h:mm AM/PM;@",
        "m/d/yy h:mm;@",
        "[$-409]mmmmm;@",
        "[$-409]mmmmm-yy;@",
        "m/d/yyyy;@",
        "[$-409]d-mmm-yyyy;@"
    ],

    TimePatterns: [
        "[$-F400]h:mm:ss AM/PM",
        "h:mm;@",
        "[$-409]h:mm AM/PM;@",
        "h:mm:ss;@",
        "[$-409]h:mm:ss AM/PM;@",
        "mm:ss.0;@",
        "[h]:mm:ss;@",
        "[$-409]m/d/yy h:mm AM/PM;@",
        "m/d/yy h:mm;@"
    ],

    // SpecialTypes 과 순서 및 갯수 동일해야함
    SpecialPatterns: [
        "00000",
        "00000-0000",
        "[<=9999999]###-####;(###) ###-####",
        "000-00-0000"
    ],

    // SpecialPatterns 과 순서 및 갯수 동일해야함
    SpecialTypes: [
        "Zip Code",
        "Zip Code + 4",
        "Phone Number",
        "Social Security Number"
    ],

    // only en, FractionTypes 과 동일한 순서와 개수
    FractionPatterns: [
        '# ?/?',
        '# ??/??',
        '# ???/???',
        '# ?/2',
        '# ?/4',
        '# ?/8',
        '# ??/16',
        '# ?/10',
        '# ??/100',
    ],

    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0_);(#,##0)',
        '#,##0_);[Red](#,##0)',
        '#,##0.00_);(#,##0.00)',
        '#,##0.00_);[Red](#,##0.00)',
        '$#,##0_);($#,##0)',
        '$#,##0_);[Red]($#,##0)',
        '$#,##0.00_);($#,##0.00)',
        '$#,##0.00_);[Red]($#,##0.00)',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'm/d/yyyy',
        'd-mmm-yy',
        'd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'm/d/yyyy h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_("$"* #,##0_);_("$"* (#,##0);_("$"* "-"_);_(@_)',
        '_(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)',
        '_("$"* #,##0.00_);_("$"* (#,##0.00);_("$"* "-"??_);_(@_)',
        '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)',
],

    ColorElements: ['Black', 'Blue', 'Cyan', 'Green', 'Magenta', 'Red', 'White', 'Yellow'],

    // 숫자 매핑, 자릿수 매핑, 0무시, 1무시
    NumDB: ['０一二三四五六七八九', '十百千万億兆', 'Y', 'Y', '零壹貳\u53c2四伍六七八九', '拾百阡萬億兆', 'Y', 'N', '', '十百千万億兆', 'Y', 'Y', '', '', 'N', 'N'],

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
        ["Sun", "Sunday"],
        ["Mon", "Monday"],
        ["Tue", "Tuesday"],
        ["Wed", "Wednesday"],
        ["Thu", "Thursday"],
        ["Fri", "Friday"],
        ["Sat", "Saturday"]
    ],

    MonthsLocale: [
        ["J", "Jan", "January"],
        ["F", "Feb", "February"],
        ["M", "Mar", "March"],
        ["A", "Apr", "April"],
        ["M", "May", "May"],
        ["J", "Jun", "June"],
        ["J", "Jul", "July"],
        ["A", "Aug", "August"],
        ["S", "Sep", "September"],
        ["O", "Oct", "October"],
        ["N", "Nov", "November"],
        ["D", "Dec", "December"]
    ],

    FormulaElements: [
        ",", // function param separator
        ",", // array column separator
        ",", // union operator
        ";" // array row separator
    ],

    LogicalValues: [
        "FALSE", "TRUE"
    ],

    ErrorValues: [
        "#DIV/0!", "#N/A", "#NAME?", "#NULL!", "#NUM!", "#REF!", "#VALUE!"
    ]
});