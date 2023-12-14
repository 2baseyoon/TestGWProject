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
        5: '#,##0 "₽";-#,##0 "₽"',
        6: '#,##0 "₽";[Red]-#,##0 "₽"',
        7: '#,##0.00 "₽";-#,##0.00 "₽"',
        8: '#,##0.00 "₽";[Red]-#,##0.00 "₽"',
        9: '0%',
        10: '0.00%',
        11: '0.00E+00',
        12: '# ?/?',
        13: '# ??/??',
        14: 'dd/mm/yyyy',
        15: 'yy-mmm-dd',
        16: 'yy-mm',
        17: 'mm-dddd',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'h:mm',
        21: 'h:mm:ss',
        22: 'dd/mm/yyyy h:mm',
        23: '$#,##0_);($#,##0)',
        24: '$#,##0_);[Red]($#,##0)',
        25: '$#,##0.00_);($#,##0.00)',
        26: '$#,##0.00_);[Red]($#,##0.00)',
        27: 'dd/mm/yyyy',
        28: 'dd/mm/yyyy',
        29: 'dd/mm/yyyy',
        30: 'dd/mm/yyyy',
        31: 'dd/mm/yyyy',
        32: 'h:mm:ss',
        33: 'h:mm:ss',
        34: 'h:mm:ss',
        35: 'h:mm:ss',
        36: 'dd/mm/yyyy',
        37: '#,##0;-#,##0',
        38: '#,##0;[Red]-#,##0',
        39: '#,##0.00;-#,##0.00',
        40: '#,##0.00;[Red]-#,##0.00',
        41: '_-* #,##0_р_._-;-* #,##0_р_._-;_-* "-"_р_._-;_-@_-',
        42: '_-* #,##0 "₽"_-;-* #,##0 "₽"_-;_-* "-""₽"_-;_-@_-',
        43: '_-* #,##0.00_р_._-;-* #,##0.00_р_._-;_-* "-"??_р_._-;_-@_-',
        44: '_-* #,##0.00 "₽"_-;-* #,##0.00 "₽"_-;_-* "-"?? "₽"_-;_-@_-',
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
        number  :   [2  , '0.00'], // NumberPatterns[0]
        currency:   [164, '#,##0.00 "₽"'], // CurrencyPatterns[0]
        account :   [44 , '_-* #,##0.00 "₽"_-;-* #,##0.00 "₽"_-;_-* "-"?? "₽"_-;_-@_-'],
        date    :   [14 , 'dd/mm/yyyy'],
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'],
        time    :   [164, '[$-F400]h:mm:ss AM/PM'],
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_-* #,##0.00_р_._-;-* #,##0.00_р_._-;_-* "-"??_р_._-;_-@_-']
    },

    LocaleName: "ru",

    GeneralName: "Основной", // 숫자 일반 서식

    DefaultDatePatterns: [
        "dd.mm.yyyy hh:mm:ss", // full date time
        "dd.mm.yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'd mmmm yyyy "r".',
        'h:mm:ss'
    ],

    // 1000 단위 기호 패턴
    ThousandsSeparatorPatterns: [
        '#,##0.00',
        '#,##0.00;[Red]#,##0.00',
        '#,##0.00_ ;-#,##0.00\\ ',
        '#,##0.00_ ;[Red]-#,##0.00\\ '
    ],

    // 음수 패턴
    NegativePatterns: [
        '0.00',
        '0.00;[Red]0.00',
        '0.00_ ;-0.00\\ ',
        '0.00_ ;[Red]-0.00\\ '
    ],

    // default 소수 자릿수 2
    CurrencyPatterns: [
        '#,##0.00 "₽"',
        '#,##0.00 "₽";[Red]#,##0.00 "₽"',
        '#,##0.00 "₽";-#,##0.00 "₽"',
        '#,##0.00 "₽";[Red]-#,##0.00 "₽"',
    ],

    DatePatterns: [
        "dd/mm/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "d/m;@",
        "d/m/yy;@",
        "dd/mm/yy;@",
        "[$-419]d mmm;@",
        "[$-419]d mmm yy;@",
        "[$-419]dd mmm yy;@",
        "[$-F419]yyyy, mmmm;@",
        "[$-419]mmmm yyyy;@",
        '[$-FC19]dd mmmm yyyy "г".;@',
        "[$-409]dd/mm/yy h:mm AM/PM;@",
        "dd/mm/yy h:mm;@",
        "[$-419]mmmm;@",
        "[$-FC19]yyyy, dd mmmm;@",
        "d/m/yyyy;@",
        "[$-419]d-mmm-yyyy;@"
    ],

    TimePatterns: [
        "[$-F400]h:mm:ss AM/PM",
        "h:mm;@",
        "[$-409]h:mm AM/PM;@",
        "h:mm:ss;@",
        "[$-409]h:mm:ss AM/PM;@",
        "mm:ss.0;@",
        "[h]:mm:ss;@",
        "[$-409]dd/mm/yy h:mm AM/PM;@",
        "dd/mm/yy h:mm;@"
    ],

    SpecialPatterns: [
        '000000',
        '00000-0000',
        '[<=9999999]###-####;(###) ###-####',
        '0000'
    ],

    SpecialTypes: [
        'Почтовый индекс',
        'Индекс + 4',
        'Номер телефона',
        'Табельный номер'
    ],

    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0_р_.;-#,##0_р_.',
        '#,##0_р_.;[Red]-#,##0_р_.',
        '#,##0.00_р_.;-#,##0.00_р_.',
        '#,##0.00_р_.;[Red]-#,##0.00_р_.',
        '#,##0 "₽";-#,##0 "₽"',
        '#,##0 "₽";[Red]-#,##0 "₽"',
        '#,##0.00 "₽";-#,##0.00 "₽"',
        '#,##0.00 "₽";[Red]-#,##0.00 "₽"',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '#" "?/?',
        '#" "??/??',
        'dd/mm/yyyy',
        'dd/mmm/yy',
        'dd/mmm',
        'mmm/yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'dd/mm/yyyy h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-* #,##0 "₽"_-;-* #,##0 "₽"_-;_-* "-""₽"_-;_-@_-',
        '_-* #,##0 _р_-;-* #,##0 _р_-;_-* "-" _р_-;_-@_-',
        '_-* #,##0.00 "₽"_-;-* #,##0.00 "₽"_-;_-* "-"?? "₽"_-;_-@_-',
        '_-* #,##0.00 _р_-;-* #,##0.00 _р_-;_-* "-"?? _р_-;_-@_-',
    ],

    ColorElements: ['Черный', 'Синий', 'Голубой', 'Зеленый', 'Фиолетовый', 'Красный', 'Белый', 'Желтый'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "AD"],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "Г", // year symbols
        "М", // month symbols
        "Д", // day symbols
        ".",
        "ч", // hour symbol
        "м", // minute symbol
        "с", // second symbol
        ":" // time seperator
    ],

    NumberElements: [
        ",", // decimal separator
        " ", // group (thousands) separator
        ";" // function param separator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "₽", // local currency symbol
        "2", // currency fraction digit count
        "f" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["вос", "воскресенье"],
        ["пон", "понедельник"],
        ["вто", "вторник"],
        ["сре", "среда"],
        ["чет", "четверг"],
        ["пят", "пятница"],
        ["суб", "суббота"]
    ],

    /*
     러시아 월 문구에대한 QA측 정보 (https://wiki.hancom.com:8443/pages/viewpage.action?pageId=28330600&focusedCommentId=28330906#comment-28330906)
     TODO $-F800, $-FC19 서식의 경우 MMMM 서식일 경우 3월과 8월의 문구가 다르다. 이부분은 추후 로컬 사용자에 대한 이슈 제기시 다시 검토
     (3월 : марта 8월 : Августа)
     */
    MonthsLocale: [
        ["я", "янв", "январь"],
        ["ф", "фев", "февраль"],
        ["м", "мар", "март"],
        ["а", "апр", "апрель"],
        ["м", "маи", "маи"],
        ["и", "июн", "июнь"],
        ["и", "июл", "июль"],
        ["а", "авг", "август"],
        ["с", "сен", "сентябрь"],
        ["о", "окт", "октябрь"],
        ["н", "ноя", "ноябрь"],
        ["д", "дек", "декабрь"]
    ],

    FormulaElements: [
        ";",  // function param separator
        ";",  // array column separator
        ";",  // union operator
        ":"   // array row separator
    ],

    LogicalValues: [
        "ЛОЖЬ", "ИСТИНА"
    ],

    ErrorValues: [
        "#ДЕЛ/0!", "#Н/Д", "#ИМЯ?", "#ПУСТО!", "#ЧИСЛО!", "#ССЫЛКА!", "#ЗНАЧ!"
    ]
});