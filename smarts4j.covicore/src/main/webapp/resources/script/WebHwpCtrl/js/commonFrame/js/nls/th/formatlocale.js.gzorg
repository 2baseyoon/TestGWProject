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
        5: '"฿"#,##0;-"฿"#,##0',
        6: '"฿"#,##0;[Red]-"฿"#,##0',
        7: '"฿"#,##0.00;-"฿"#,##0.00',
        8: '"฿"#,##0.00;[Red]-"฿"#,##0.00',
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
        22: 'm/d/yyyy h:mm',
        23: 'General',
        24: 'General',
        25: 'General',
        26: 'General',
        27: 'm/d/yyyy',
        28: 'm/d/yyyy',
        29: 'm/d/yyyy',
        30: 'm/d/yyyy',
        31: 'm/d/yyyy',
        32: 'h:mm:ss',
        33: 'h:mm:ss',
        34: 'h:mm:ss',
        35: 'h:mm:ss',
        36: 'm/d/yyyy',
        37: '#,##0;-#,##0',
        38: '#,##0;[Red]-#,##0',
        39: '#,##0.00;-#,##0.00',
        40: '#,##0.00;[Red]-#,##0.00',
        41: '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        42: '_-"฿:* #,##0_-;-"฿"* #,##0_-;_-"฿"* "-"_-;_-@_-',
        43: '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
        44: '_-"฿"* #,##0.00_-;-"฿"* #,##0.00_-;_-"฿"* "-"??_-;_-@_-',
        45: 'mm:ss',
        46: '[h]:mm:ss',
        47: 'mm:ss.0',
        48: '##0.0E+0',
        49: '@',
        50: 'm/d/yyyy',
        51: 'm/d/yyyy',
        52: 'm/d/yyyy',
        53: 'm/d/yyyy',
        54: 'm/d/yyyy',
        55: 'm/d/yyyy',
        56: 'm/d/yyyy',
        57: 'm/d/yyyy',
        58: 'm/d/yyyy',
        59: '0',
        60: '0.00'
    },

    DefaultLocationFormat: {
        number  :   [2  , '0.00'],
        currency:   [164, '฿#,##0.00'],
        account :   [44 , '_-"฿"* #,##0.00_-;-"฿"* #,##0.00_-;_-"฿"* "-"??_-;_-@_-'],
        date    :   [164, '[$-1070000]d/m/yyyy;@'],
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'],
        time    :   [164, '[$-F400]h:mm:ss AM/PM'],
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-']
    },

    LocaleName: "th",

    GeneralName: "General", // 숫자 일반 서식

    DefaultDatePatterns: [
        "d-m-yyyy h:mm:ss", // full date time
        "d-m-yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'd mmmm yyyy',
        'h:mm:ss'
    ],

    // 1000 단위 기호 패턴
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
        '฿#,##0.00',
        '฿#,##0.00;[Red]฿#,##0.00',
        '฿#,##0.00;-฿#,##0.00',
        '฿#,##0.00;[Red]-฿#,##0.00'
    ],

    DatePatterns: [
        // 불교력
        // "[$-1070000]d/m/yy;@",
        // "[$-1070000]d/mm/yyyy;@",
        // '[$-1070000]d/mm/yyyy h:mm "น.";@',
        // "[$-1070409]d/mm/yyyy h:mm AM/PM;@",
        // "[$-D070000]d/m/yy;@",
        // "[$-D070000]d/mm/yyyy;@",
        // '[$-D070000]d/mm/yyyy h:mm "น.";@',
        // "[$-D07041E]d mmm yy;@",
        // "[$-D07041E]d mmmm yyyy;@",
        // "[$-107041E]d mmm yy;@",
        // "[$-107041E]d mmmm yyyy;@",

        // 서기
        "d/m/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "[$-1010000]d/m/yy;@",
        "[$-1010000]d/m/yyyy;@",
        '[$-1010000]d/m/yyyy h:mm "น.";@',
        "[$-1010409]d/m/yyyy h:mm AM/PM;@",
        "[$-D010000]d/m/yy;@",
        "[$-D010000]d/mm/yyyy;@",
        '[$-D010000]d/mm/yyyy h:mm "น.";@',
        "[$-101041E]d mmm yy;@",
        "[$-101041E]d mmmm yyyy;@",
        "[$-D01041E]d mmm yy;@",
        "[$-D01041E]d mmmm yyyy;@",
        "[$-1010409]d mmm yy;@",
        "[$-1010409]d mmmm yyyy;@"
    ],

    TimePatterns: [
        "[$-F400]h:mm:ss AM/PM",
        "[$-D000000]h:mm:ss AM/PM;@",
        "[$-D000000]h:mm:ss;@",
        '[$-D000000]h:mm "น.";@',
        "[$-D000409]h:mm AM/PM;@",
        "[$-1000000]h:mm:ss AM/PM;@",
        "[$-1000000]h:mm:ss;@",
        '[$-1000000]h:mm "น.";@',
        "[$-1000409]h:mm AM/PM;@"
    ],

    SpecialPatterns: [
        '[<=99999999][$-D000000]0-####-####;[$-D000000]#-####-####',
        '[$-D000000]00-0000000-0',
        '[$-D000000]0 0000 00000 00 0',
        '[<=99999999][$-1000000]0-####-####;[$-1000000]#-####-####',
        '[$-1000000]00-0000000-0',
        '[$-1000000]0 0000 00000 00 0'
    ],

    // TODO 임의로 번역한 것으로 확인 필요
    SpecialTypes: [
        'หมายเลขโทรศัพท์', // Phone Number
        'หมายเลขประกันสังคม', // Social Security Number
        'หมายเลขประจำตัว', // Identification Number
        'Phone Number',
        'Social Security Number',
        'Identification Number'
    ],

    CustomPatterns: [
        'General',
        '0',
        '0,00',
        '#,##0.00',
        '#,##0.00',
        '#,##0;-#,##0',
        '#,##0;[Red]-#,##0',
        '#,##0.00;-#,##0.00',
        '#,##0.00;[Red]-#,##0.00',
        '฿#,##0;-฿#,##0',
        '฿#,##0;[Red]-฿#,##0',
        '฿#,##0.00;-฿#,##0.00',
        '฿#,##0.00;[Red]-฿#,##0.00',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'd/m/yyyy',
        'd-mmm-yy',
        'd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'd/m/yyyy h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-"฿"* #,##0_-;-"฿"* #,##0_-;_-"฿"* "-"_-;_-@_-',
        '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        '_-"฿"* #,##0.00_-;-"฿"* #,##0.00_-;_-"฿"* "-"??_-;_-@_-',
        '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
        't0',
        't0.00',
        't#,##0',
        't#,##0.00',
        't฿#,##0_);(t฿#,##0)',
        't฿#,##0_);[แดง](t฿#,##0)',
        't฿#,##0.00_);(t฿#,##0.00)',
        't฿#,##0.00_);[Red](t฿#,##0.00)',
        't0%',
        't0.00%',
        't# ?/?',
        't# ??/??',
        // TODO 태국어 문자를 지원해야 가능
        // 'ว/ด/ปปปป',
        // 'ว-ดดด-ปป',
        // 'ว-ดดด',
        // 'ดดด-ปป',
        // 'ช:นน',
        // 'ช:นน:ทท',
        // 'ว/ด/ปปปป ช:นน',
        // '[ช]:นน:ทท',
        // 'นน:ทท',
        // 'นน:ทท.0',
        'd/m/bb',
    ],

    ColorElements: ['ดำ', 'น้ำเงิน', 'นํ้าเงินอมเขียว', 'เขียว', 'ม่วงมาเจนต้า', 'แดง', 'ขาว', 'เหลือง'],

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
        "฿", // local currency symbol
        "2", // currency fraction digit count
        "t" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["อา.", "อาทิตย์"],
        ["จ.", "จันทร์"],
        ["อ.", "อังคาร"],
        ["พ.", "พุธ"],
        ["พฤ.", "พฤหัสบดี"],
        ["ศ.", "ศุกร์"],
        ["ส.", "เสาร์"]
    ],

    MonthsLocale: [
        ["ม", "ม.ค.", "มกราคม"],
        ["ก", "ก.พ.", "กุมภาพันธ์"],
        ["ม", "มี.ค.", "มีนาคม"],
        ["เ", "เม.ย.", "เมษายน"],
        ["พ", "พ.ค.", "พฤษภาคม"],
        ["ม", "มิ.ย.", "มิถุนายน"],
        ["ก", "ก.ค.", "กรกฎาคม"],
        ["ส", "ส.ค.", "สิงหาคม"],
        ["ก", "ก.ย.", "กันยายน"],
        ["ต", "ต.ค.", "ตุลาคม"],
        ["พ", "พ.ย.", "พฤศจิกายน"],
        ["ธ", "ธ.ค.", "ธันวาคม"]
    ],

    FormulaElements: [
        ",", // function param separator
        ",", // array column separator
        ",", // union operator
        ";"  // array row separator
    ],

    LogicalValues: [
        "ONWAAR", "WAAR"
    ],

    ErrorValues: [
        "#DEEL/0!", "#N/B", "#NAAM?", "#LEEG!", "#GETAL!", "#VERW!", "#WAARDE!"
    ]

    // DaysLocale: [
    //     ["Sun", "วันอาทิตย์"],
    //     ["Mon", "วันจันทร์"],
    //     ["Tue", "วันอังคาร"],
    //     ["Wed", "วันพุธ"],
    //     ["Thu", "วันพฤหัสบดี"],
    //     ["Fri", "วันศุกร์"],
    //     ["Sat", "วันเสาร์"]
    // ],
    //
    // MonthsLocale: [
    //     ["J", "Jan", "มกราคม"],
    //     ["F", "Feb", "กุมภาพันธ์"],
    //     ["M", "Mar", "มีนาคม"],
    //     ["A", "Apr", "เมษายน"],
    //     ["M", "May", "พฤษภาคม"],
    //     ["J", "Jun", "มิถุนายน"],
    //     ["J", "Jul", "กรกฎาคม"],
    //     ["A", "Aug", "สิงหาคม"],
    //     ["S", "Sep", "กันยายน"],
    //     ["O", "Oct", "ตุลาคม"],
    //     ["N", "Nov", "พฤศจิกายน"],
    //     ["D", "Dec", "ธันวาคม"]
    // ]
});