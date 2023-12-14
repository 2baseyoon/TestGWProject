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
        5: '"₩"#,##0;-"₩"#,##0',
        6: '"₩"#,##0;[Red]-"₩"#,##0',
        7: '"₩"#,##0.00;-"₩"#,##0.00',
        8: '"₩"#,##0.00;[Red]-"₩"#,##0.00',
        9: '0%',
        10: '0.00%',
        11: '0.00E+00',
        12: '# ?/?',
        13: '# ??/??',
        14: 'yyyy-mm-dd',
        15: 'dd-mmm-yy',
        16: 'dd-mmm',
        17: 'mmm-yy',
        18: 'h:mm AM/PM',
        19: 'h:mm:ss AM/PM',
        20: 'h:mm',
        21: 'h:mm:ss',
        22: 'yyyy-mm-dd h:mm',
        23: '$#,##0_);($#,##0)',
        24: '$#,##0_);[Red]($#,##0)',
        25: '$#,##0.00_);($#,##0.00)',
        26: '$#,##0.00_);[Red]($#,##0.00)',
        27: 'yyyy"年" mm"月" dd"日"',
        28: 'mm-dd',
        29: 'mm-dd',
        30: 'mm-dd-yy',
        31: 'yyyy"년" mm"월" dd"일"',
        32: 'h"시" mm"분"',
        33: 'h"시" mm"분" ss"초"',
        34: 'yyyy-mm-dd',
        35: 'yyyy-mm-dd',
        36: 'yyyy"年" mm"月" dd"日"',
        37: '#,##0;-#,##0',
        38: '#,##0;[Red]-#,##0',
        39: '#,##0.00;-#,##0.00',
        40: '#,##0.00;[Red]-#,##0.00',
        41: '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        42: '_-"₩"* #,##0_-;-"₩"* #,##0_-;_-"₩"* "-"_-;_-@_-',
        43: '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
        44: '_-"₩"* #,##0.00_-;-"₩"* #,##0.00_-;_-"₩"* "-"??_-;_-@_-',
        45: 'mm:ss',
        46: '[h]:mm:ss',
        47: 'mm:ss.0',
        48: '##0.0E+0',
        49: '@',
        50: 'yyyy"年" mm"月" dd"日"',
        51: 'mm-dd',
        52: 'yyyy-mm-dd',
        53: 'yyyy-mm-dd',
        54: 'mm-dd',
        55: 'yyyy-mm-dd',
        56: 'yyyy-mm-dd',
        57: 'yyyy"年" mm"月" dd"日"',
        58: 'mm-dd',
        59: '0',
        60: '0.00'
    },

    DefaultLocationFormat: {
        number  :   [1  , '0'], // NumberPatterns[0]
        currency:   [164, '"₩"#,##0'], // CurrencyPatterns[0]
        account :   [42 , '_-"₩"* #,##0_-;-"₩"* #,##0_-;_-"₩"* "-"_-;_-@_-'],
        date    :   [14 , 'yyyy-mm-dd'], // DatePatterns[0]
        longDate:   [164, '[$-F800]dddd, mmmm dd, yyyy'], // DatePatterns[1]
        time    :   [164, '[$-F400]h:mm:ss AM/PM'], // TimePatterns[0]
        percentage: [9 , '0%'],
        fraction:   [12 , '# ?/?'],
        scientific: [164, '0.E+00'],
        comma   :   [41 , '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-'] // account 에서 기호없는 패턴
    },

    LocaleName: "ko",

    GeneralName: "G/표준", // 숫자 일반 서식

    DefaultDatePatterns: [
        "yyyy-mm-dd h:mm:ss AM/PM", // full date time
        "yyyy-mm-dd", // date
        "h:mm:ss AM/PM" // time
    ],

    // F800, F400
    SystemDateTimePatterns: [
        'yyyy"년" mmmm d"일" dddd',
        'AM/PM h:mm:ss'
    ],

    // 1000 단위 기호 패턴
    ThousandsSeparatorPatterns: [
        // 1000 단위 기호 패턴
        '#,##0_);[Red]\\(#,##0\\)',
        '#,##0_);\\(#,##0\\)',
        '#,##0;[Red]#,##0',
        '#,##0_ ',
        '#,##0_ ;[Red]-#,##0 '
    ],

    // 음수 패턴
    NegativePatterns: [
        '0_);[Red]\\(0\\)',
        '0_);\\(0\\)',
        '0;[Red]0',
        '0_ ',
        '0_ ;[Red]-0 '
    ],

    // 원(₩)단위 기호의 경우 기호 그대로 TFO 엔진 저장시 escape처리(!₩..)되므로 doublequotation을 붙여준다.
    // 엑셀의 경우도 원단위는 저장 후 ooxml정보를 확인하면 doublequotation이 붙어있음.
    // action이나 서버에서 치환할경우 OT 정보가 틀어지므로 초기값을 바꾼다.
    // 사용자 서식의 경우는 다이얼로그에 노출이되고 escape처리되더라도 결국 사용자서식으로 보여지므로 일단 그대로 둔다.
    CurrencyPatterns: [
        '"₩"#,##0_);[Red]("₩"#,##0)',
        '"₩"#,##0_);("₩"#,##0)',
        '"₩"#,##0;[Red]"₩"#,##0',
        '"₩"#,##0',
        '"₩"#,##0;[Red]-"₩"#,##0'
    ],

    // 409: AM/PM, 412: 오전/오후
    DatePatterns: [
        'yyyy-mm-dd',
        '[$-F800]dddd, mmmm dd, yyyy',
        'yyyy"년" m"월" d"일";@',
        'yy"年" m"月" d"日";@',
        'yyyy"년" m"월";@',
        'm"월" d"일";@',
        'yy"-"m"-"d;@',
        'yy"-"m"-"d h:mm;@',
        '[$-412]yy"-"m"-"d AM/PM h:mm;@',
        '[$-409]yy"-"m"-"d h:mm AM/PM;@',
        'yy"/"m"/"d;@',
        'yyyy"-"m"-"d;@',
        'yyyy"/"m"/"d;@',
        'm"/"d;@',
        'm"/"d"/"yy;@',
        'mm"/"dd"/"yy;@',
        '[$-409]d"-"mmm;@',
        '[$-409]d"-"mmm"-"yy;@',
        '[$-409]mmm"-"yy;@',
        '[$-409]mmmm"-"yy;@',
        '[$-409]mmmmm;@',
        '[$-409]mmmmm-yy;@'
    ],

    TimePatterns: [
        '[$-F400]h:mm:ss AM/PM',
        'h:mm;@',
        'h:mm:ss;@',
        '[$-412]AM/PM h:mm;@',
        '[$-412]AM/PM h:mm:ss;@',
        '[$-409]h:mm AM/PM;@',
        '[$-409]h:mm:ss AM/PM;@',
        'yyyy"-"m"-"d h:mm;@',
        '[$-412]yyyy"-"m"-"d AM/PM h:mm;@',
        '[$-409]yyyy"-"m"-"d h:mm AM/PM;@',
        'h"시" mm"분";@',
        'h"시" mm"분" ss"초";@',
        '[$-412]AM/PM h"시" mm"분";@'
    ],

    // 로케일별로 SpecialTypes 과 순서 및 개수 동일해야함
    SpecialPatterns: [
        '000-000',
        '[<=999999]####-####;(0##) ####-####',
        '[<=9999999]###-####;(0##) ###-####',
        '000000-0000000',
        '[DBNum1][$-412]General',
        '[DBNum2][$-412]General',
        '[DBNum4][$-412]General'
    ],

    // 로케일별로 SpecialPatterns 과 순서 및 개수 동일해야함
    SpecialTypes: [
        "우편번호",
        "전화 번호 (국번 4자리)",
        "전화 번호 (국번 3자리)",
        "주민등록번호",
        "숫자(한자)",
        "숫자(한자-갖은자)",
        "숫자(한글)"
    ],

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
        '₩#,##0;-₩#,##0',
        '₩#,##0;[Red]-₩#,##0',
        '₩#,##0.00;-₩#,##0.00',
        '₩#,##0.00;[빨강]-₩#,##0.00',
        '0%',
        '0.00%',
        '0.00E+00',
        '##0.0E+0',
        '# ?/?',
        '# ??/??',
        'yyyy-mm-dd',
        'dd-mmm-yy',
        'dd-mmm',
        'mmm-yy',
        'h:mm AM/PM',
        'h:mm:ss AM/PM',
        'h:mm',
        'h:mm:ss',
        'yyyy-mm-dd h:mm',
        'mm:ss',
        'mm:ss.0',
        '@',
        '[h]:mm:ss',
        '_-"₩"* #,##0_-;-"₩"* #,##0_-;_-"₩"* "-"_-;_-@_-',
        '_-* #,##0_-;-* #,##0_-;_-* "-"_-;_-@_-',
        '_-"₩"* #,##0.00_-;-"₩"* #,##0.00_-;_-"₩"* "-"??_-;_-@_-',
        '_-* #,##0.00_-;-* #,##0.00_-;_-* "-"??_-;_-@_-',
    ],

    ColorElements: ["검정", "파랑", "녹청", "녹색", "자홍", "빨강", "흰색", "노랑"],

    // 숫자 매핑, 자릿수 매핑, 0무시, 1무시
    NumDB: ["０一二三四五六七八九", "十百千万億兆", "Y", "N", "零壹貳參四伍六七八九", "拾百阡萬億兆", "Y", "N", "", "十百千万億兆", "Y", "Y", "영일이삼사오육칠팔구", "십백천만억조", "Y", "N"],

    AmPmMarkers: ["A", "P", "오전", "오후"],

    CharSeperator: ["!"],

    DateElements: [
        "y", // year symbols
        "m", // month symbols
        "d", // day symbols
        "-", // date seperator
        "h", // hour symbol
        "m", // minute symbol
        "s", // second symbol
        ":" // time seperator
    ],

    // local currency symbol, currency fraction digit count, head position ? tail position ?
    CurrencyElements: [
        "₩", // local currency symbol
        "0", // currency fraction digit count
        "t" // head position ? , tail position ?
    ],

    DaysLocale: [
        ["일", "일요일"],
        ["월", "월요일"],
        ["화", "화요일"],
        ["수", "수요일"],
        ["목", "목요일"],
        ["금", "금요일"],
        ["토", "토요일"]
    ],

    MonthsLocale: [
        ["J", "1월", "1월"],
        ["F", "2월", "2월"],
        ["M", "3월", "3월"],
        ["A", "4월", "4월"],
        ["M", "5월", "5월"],
        ["J", "6월", "6월"],
        ["J", "7월", "7월"],
        ["A", "8월", "8월"],
        ["S", "9월", "9월"],
        ["O", "10월", "10월"],
        ["N", "11월", "11월"],
        ["D", "12월", "12월"]
    ]
});