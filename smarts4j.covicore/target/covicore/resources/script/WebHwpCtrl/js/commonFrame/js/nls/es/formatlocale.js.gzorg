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
        20: 'h:mm',
        21: 'h:mm:ss',
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
        32: 'h:mm:ss',
        33: 'h:mm:ss',
        34: 'h:mm:ss',
        35: 'h:mm:ss',
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
        number  :   [2  , '0.00'], // NumberPatterns[0]
        currency:   [164, '#,##0.00 €'], // CurrencyPatterns[0]
        account :   [44 , '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-'],
        date    :   [14 , 'dd/mm/yyyy'], // DatePatterns[0]
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'], // DatePatterns[1]
        time    :   [164, '[$-F400]h:mm:ss AM/PM'], // TimePatterns[0]
        percentage: [10 , '0.00%'],
        fraction:   [12 , '# ?/?'],
        scientific: [11 , '0.00E+00'],
        comma   :   [43 , '_-* #,##0.00 _€_-;-* #,##0.00 _€_-;_-* "-"?? _€_-;_-@_-'] // account 에서 기호없는 패턴
    },

    LocaleName: "es",

    GeneralName: "General", // 숫자 일반 서식

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
        '#,##0.00_ ;-#,##0.00',
        '#,##0.00_ ;[Red]-#,##0.00'
    ],

    // 음수 패턴, default 소수 자릿수 2
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
        'dd/mm/yyyy',
        '[$-F800]dddd, mmmm dd, yyyy',
        'd-m;@',
        'd-m-yy;@',
        'dd-mm-yy;@',
        '[$-C0A]d-mmm;@',
        '[$-C0A]d-mmm-yy;@',
        '[$-C0A]dd-mmm-yy;@',
        '[$-C0A]mmm-yy;@',
        '[$-C0A]mmmm-yy;@',
        '[$-C0A]d "de" mmmm "de" yyyy;@',
        '[$-409]d-m-yy h:mm AM/PM;@',
        'd-m-yy h:mm;@',
        '[$-C0A]mmmmm;@',
        '[$-C0A]mmmmm-yy;@',
        'd-m-yyyy;@',
        '[$-C0A]d-mmm-yyyy;@',
    ],

    TimePatterns: [
        '[$-F400]h:mm:ss AM/PM',
        'h:mm;@',
        '[$-409]h:mm AM/PM;@',
        'h:mm:ss;@',
        '[$-409]h:mm:ss AM/PM;@',
        "mm:ss.0;@", // es os : mm:ss,0;@ es os 에서 "," 그대로 처리함. 보통 유럽권 날짜 구분자를 "." 쓰기도 하는데 ","는 숫자 gropSeparator과 같은 의미라 현재 webCell parser에서 정확히 파싱하지 못하므로 "."으로 설정함.
        '[h]:mm:ss;@',
        '[$-409]d-m-yy h:mm AM/PM;@',
        'd-m-yy h:mm;@'
    ],

    SpecialPatterns: [
        '00000',
        '00000-0000',
        '[<=9999999]###-####;(###) ###-####',
        '000-00-0000'
    ],

    SpecialTypes: [
        'Código postal',
        'Código postal + 4',
        'Número de teléfono',
        'Número del seguro social'
    ],

    CustomPatterns: [
        'General',
        '0',
        '0.00',
        '#,##0',
        '#,##0.00',
        '#,##0 _€;-#,##0 _€',
        '#,##0 _€;[Red]-#,##0 _€',
        '#,##0.00 _€;-#,##0.00 _€',
        '#,##0.00 _€;[Red]-#,##0.00 _€',
        '#,##0 €;-#,##0 €',
        '#,##0 €;[Red]-#,##0 €',
        '#,##0.00 €;-#,##0.00 €',
        '#,##0.00 €;[Red]-#,##0.00 €',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'dd/mm/yyyy',
        'dd-mmm-yy',
        'dd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'dd/mm/yyyy h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-* #,##0 "€"_-;-* #,##0 "€"_-;_-* "-" "€"_-;_-@_-',
        '_-* #,##0 _€_-;-* #,##0 _€_-;_-* "-" _€_-;_-@_-',
        '_-* #,##0.00 "€"_-;-* #,##0.00 "€"_-;_-* "-"?? "€"_-;_-@_-',
        '_-* #,##0.00 _€_-;-* #,##0.00 _€_-;_-* "-"?? _€_-;_-@_-',
    ],

    ColorElements: ['Negro', 'Azul', 'Aguamarina', 'Verde', 'Fucsia', 'Rojo', 'Blanco', 'Amarillo'],

    AmPmMarkers: ["A", "P", "AM", "PM"],

    Eras: ["BC", "AD"],

    YearTables: ["0"],

    CharSeperator: ["\\"],

    DateElements: [
        "a", // year symbols
        "m", // month symbols
        "d", // day symbols
        "/", // date seperator
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
        "€", // local currency symbol
        "2", // currency fraction digit count
        "f" // head position ? , tail position ?
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
        ["E", "Ene.", "Enero"],
        ["F", "Feb.", "Febrero"],
        ["M", "Mar.", "Marzo"],
        ["A", "Abr.", "Abril"],
        ["M", "May.", "Mayo"],
        ["J", "Jun.", "Junio"],
        ["J", "Jul.", "Julio"],
        ["A", "Ago.", "Agosto"],
        ["S", "Sep.", "Septiembre"],
        ["O", "Oct.", "Octubre"],
        ["N", "Nov.", "Noviembre"],
        ["D", "Dic.", "Diciembre"]
    ],

    FormulaElements: [
        ";",  // function param separator
        "\\", // array column separator
        ";",  // union operator
        ";"   // array row separator
    ],

    LogicalValues: [
        "FALSO", "VERDADERO"
    ],

    ErrorValues: [
        "#¡DIV/0!", "#N/A", "#¿NOMBRE?", "#¡NULO!", "#¡NUM!", "#¡REF!", "#¡VALOR!"
    ]
});