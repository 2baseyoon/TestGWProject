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
        15: 'd/mmm/yy',
        16: 'd/mmm',
        17: 'mmm/yy',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'hh:mm',
        21: 'hh:mm:ss',
        22: 'dd-mm-yyyy h:mm',
        23: 'General',
        24: 'General',
        25: 'General',
        26: 'General',
        27: 'dd-mm-yyyy',
        28: 'dd-mm-yyyy',
        29: 'dd-mm-yyyy',
        30: 'dd-mm-yyyy',
        31: 'dd-mm-yyyy',
        32: 'hh:mm:ss',
        33: 'hh:mm:ss',
        34: 'hh:mm:ss',
        35: 'hh:mm:ss',
        36: 'dd-mm-yyyy',
        37: '#,##0 _€;-#,##0 _€',
        38: '#,##0 _€;[Red]-#,##0 _€',
        39: '#,##0.00 _€;-#,##0.00 _€',
        40: '#,##0.00 _€;[Red]-#,##0.00 _€',
        41: '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        42: '_-"R$" * #,##0_-;-"R$" * #,##0_-;_-"R$" * "-"_-;_-@_-',
        43: '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
        44: '_-"R$" * #,##0.00_-;-"R$" * #,##0.00_-;_-"R$" * "-"??_-;_-@_-',
        45: 'mm:ss',
        46: '[h]:mm:ss',
        47: 'mm:ss.0',
        48: '##0.0E+0',
        49: '@',
        50: 'dd-mm-yyyy',
        51: 'dd-mm-yyyy',
        52: 'dd-mm-yyyy',
        53: 'dd-mm-yyyy',
        54: 'dd-mm-yyyy',
        55: 'dd-mm-yyyy',
        56: 'dd-mm-yyyy',
        57: 'dd-mm-yyyy',
        58: 'dd-mm-yyyy',
        59: '0',
        60: '0.00'
    },

    DefaultLocationFormat: {
        number  :   [2  , '0.00'],
        currency:   [164, 'R$ #,##0.00'],
        account :   [44 , '_-"R$" * #,##0.00_-;-"R$" * #,##0.00_-;_-"R$" * "-"??_-;_-@_-'],
        date    :   [14 , 'dd/mm/yyyy'],
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'],
        time    :   [164, '[$-F400]h:mm:ss AM/PM'],
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-']
    },

    LocaleName: "pt",

    GeneralName: "Geral", // 숫자 일반 서식

    DefaultDatePatterns: [
        "dd/mm/yyyy h:mm:ss AM/PM", // full date time
        "dd/mm/yyyy", // date
        "h:mm:ss" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'dddd, d "de" mmmm "de" yyyy',
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
        'R$ #,##0.00',
        'R$ #,##0.00;[Red]R$ #,##0.00',
        'R$ #,##0.00;-R$ #,##0.00',
        'R$ #,##0.00;[Red]-R$ #,##0.00',
    ],

    DatePatterns: [
        "dd/mm/yyyy",
        "[$-F800]dddd, mmmm dd, yyyy",
        "d/m",
        "d/m/yy;@",
        "dd/mm/yy;@",
        "[$-416]d-mmm;@",
        "[$-416]d-mmm-yy;@",
        "[$-416]dd-mmm-yy;@",
        "[$-416]mmm-yy;@",
        "[$-416]mmmm-yy;@",
        "[$-416]d;@",
        "[$-409]mmmm, yyyy;@",
        "[$-409]d/m/yy h:mm AM/PM;@",
        "d/m/yy h:mm;@",
    ],

    TimePatterns: [
        "[$-F400]h:mm:ss AM/PM",
        "h:mm;@",
        "[$-409]h:mm AM/PM;@",
        "h:mm:ss;@",
        "[$-409]h:mm:ss AM/PM;@",
        "mm:ss.0;@",
        "[h]:mm:ss;@",
        "[$-409]d/m/yy h:mm AM/PM;@",
        "d/m/yy h:mm;@"
    ],

    SpecialPatterns: [
        '00000',
        '00000-000',
        '[<=9999999]###-####;(###) ###-####',
        '000000000-00'
    ],

    SpecialTypes: [
        'CEP',
        'CEP + 3',
        'Telefone',
        'CIC'
    ],

    // ooxml format 으로 정의함
    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0;-#,##0',
        '#,##0;[Red]-#,##0',
        '#,##0.00;-#,##0.00',
        '#,##0.00;[Red]-#,##0.00',
        'R$ #,##0;-R$ #,##0',
        'R$ #,##0;[Red]-R$ #,##0',
        'R$ #,##0.00;-R$ #,##0.00',
        'R$ #,##0.00;[Red]-R$ #,##0.00',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'dd/mm/yyyy',
        'dd/mmm/yy',
        'dd/mmm',
        'mmm/yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'hh:mm',
        'hh:mm:ss',
        'dd/mm/yyyy hh:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-"R$" * #,##0_-;-"R$" * #,##0_-;_-"R$" * "-"_-;_-@_-',
        '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        '_-"R$" * #,##0.00_-;-"R$" * #,##0.00_-;_-"R$" * "-"??_-;_-@_-',
        '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
    ],

    ColorElements: ['Preto', 'Azul', 'Ciano', 'Verdo', 'Magenta', 'Vermelho', 'Branco', 'Amarelo'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "AD"],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "a", // year symbols
        "m", // month symbols
        "d", // day symbols
        "/",
        "h", // hour symbol
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
        "R$ ", // local currency symbol
        "2", // currency fraction digit count
        "t" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["Dom", "domingo"],
        ["Seg", "segunda-feira"],
        ["Ter", "terça-feira"],
        ["Qua", "quarta-feira"],
        ["Qui", "quinta-feira"],
        ["Sex", "sexta-feira"],
        ["Sáb", "Sábado"]
    ],

    MonthsLocale: [
        ["J", "jan", "janeiro"],
        ["F", "fev", "fevereiro"],
        ["M", "mar", "março"],
        ["A", "abr", "abril"],
        ["M", "mai", "maio"],
        ["J", "jun", "junho"],
        ["J", "jul", "julho"],
        ["A", "ago", "agosto"],
        ["S", "set", "setembro"],
        ["O", "out", "outubro"],
        ["N", "nov", "novembro"],
        ["D", "dez", "dezembro"]
    ],

    FormulaElements: [
        ";",  // function param separator
        "\\", // array column separator
        ";",  // union operator
        ";"   // array row separator
    ],

    LogicalValues: [
        "FALSO", "VERDADEIRO"
    ],

    ErrorValues: [
        "#DIV/0!", "#N/D", "#NOME?", "#NULO!", "#NÚM!", "#REF!", "#VALOR!"
    ]
});