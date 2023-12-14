package egovframework.coviframework.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.security.SecureRandom;
import java.util.StringTokenizer;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * 공통 String Util org.apache.commons.lang.StringUtils 상속후 필요 메소드 추가 자세한 기타 자세한
 * 스펙은 org.apache.commons.lang.StringUtils 참조 (url :
 * http://jakarta.apache.org/commons
 * /lang/api-release/org/apache/commons/lang/StringUtils.html)
 */
public class StringUtil extends StringUtils {

	private static Logger LOGGER = LogManager.getLogger(StringUtil.class);
	
	public static String nullToZero(String value) {
		if (value == null || value.equals("")) {
			value = "0";
		}
		return value;
	}

	/**
	 * 문자열 좌측의 공백을 제거하는 메소드
	 * 
	 * @param str 대상 문자열
	 * @return trimed string with white space removed from the front.
	 */
	public static String ltrim(String str) {
		int len = str.length();
		int idx = 0;
		while ((idx < len) && (str.charAt(idx) <= ' ')) {
			idx++;
		}
		return str.substring(idx, len);
	}

	/**
	 * 문자열 우측의 공백을 제거하는 메소드
	 * 
	 * @param str 대상 문자열
	 * @return trimed string with white space removed from the end.
	 */
	public static String rtrim(String str) {
		int len = str.length();
		while ((0 < len) && (str.charAt(len - 1) <= ' ')) {
			len--;
		}
		return str.substring(0, len);
	}

	/**
	 * 단위 표시 처리(ex: 100,000)
	 * 
	 * @param str
	 * @return
	 */
	public static String changeMoney(String str) {
		DecimalFormat df = new DecimalFormat("###,###");
		return df.format(parseInt(str));
	}

	/**
	 * 파라미터로 넘어오는 String을 , 를 제거해준다.
	 *
	 * @param s java.lang.String
	 * @return java.lang.String
	 */
	public static String removeComma(String str) {
		String rtnValue = str;
		if (isNull(str)) {
			return "";
		}
		rtnValue = replace(rtnValue, ",", "");
		return rtnValue;
	}

	/**
	 * 숫자 0이 넘어오면 ""로 대치
	 * 
	 * @param int 대상 숫자
	 * @return java.lang.String
	 */
	public static String isOneNull(int num) {
		if (num == 0)
			return "";
		else
			return Integer.toString(num);
	}

	/**
	 * str이 null 이거나 "", "    " 일경우 return true
	 * 
	 * @param str
	 * @return
	 */
	public static boolean isNull(String str) {
		return (str == null || (str.trim().length()) == 0 || str.equalsIgnoreCase("null"));
	}

	public static boolean isNull(Object obj) {
		String str = null;
		if (obj instanceof String) {
			str = (String) obj;
		} else {
			return true;
		}
		return isNull(str);
	}

	/**
	 * null이 아닐때.
	 * 
	 * @param str
	 * @return
	 */
	public static boolean isNotNull(String str) {
		/**
		 * isNull이 true이면 false false이면 true
		 */
		if (isNull(str)) {
			return false;
		} else {
			return true;
		}
	}

	/***
	 * 널체크
	 * 
	 * @param obj
	 * @return
	 */
	public static boolean isNotNull(Object obj) {
		String str = null;
		if (obj instanceof String) {
			str = (String) obj;
		} else {
			return false;
		}
		return isNotNull(str);
	}

	/**
	 * 파라미터가 null 이거나 공백이 있을경우 "" 로 return
	 * 
	 * @param value
	 * @return
	 */
	public static String replaceNull(String value) {
		return replaceNull(value, "");
	}

	/**
	 * Object를 받아서 String 형이 아니거나 NULL이면 ""를 return String 형이면 형 변환해서 넘겨준다.
	 * 
	 * @param value
	 * @return
	 */
	public static String replaceNull(Object value) {
		Object rtnValue = value;
		if (rtnValue != null){//"java.lang.String".equals(rtnValue.getClass().getName()
			if ("java.lang.String".equals(rtnValue.getClass().getName())) {
				return replaceNull((String) rtnValue, "");
			}else if 	("java.lang.Integer".equals(rtnValue.getClass().getName())) {
				return replaceNull(((Integer) rtnValue).toString(),"");
			}else if 	("java.lang.Long".equals(rtnValue.getClass().getName())) {
				return replaceNull(((Long) rtnValue).toString(),"");
			}else {
				return replaceNull(rtnValue.toString(),"");
			}
		}
		else{
			return "";
		}
	}

	/**
	 * 파라미터로 넘어온 값이 null 이거나 공백이 포함된 문자라면 defaultValue를 return 아니면 값을 trim해서
	 * 넘겨준다.
	 * 
	 * @param value
	 * @param repStr
	 * @return
	 */
	public static String replaceNull(String value, String defaultValue) {
		if (isNull(value)) {
			return defaultValue;
		}
		return value.trim();
	}

	/**
	 * Object를 받아서 String 형이 아니거나 NULL이면 defaultValue를 return String 형이면 형 변환해서
	 * 넘겨준다.
	 * 
	 * @param value
	 * @param repStr
	 * @return
	 */
	public static String replaceNull(Object value, String defaultValue) {
		String valueStr = replaceNull(value);
		if (isNull(valueStr)) {
			return defaultValue;
		}
		return valueStr.trim();
	}

	/**
	 * Method ksc2asc. 8859-1를 euc-kr로 인코딩하는 함수
	 * 
	 * @param str
	 *            - String
	 * @return String
	 */
	public static String ksc2asc(String str) {
		String result = "";
		if (isNull(str)) {
			result = "";
		} else {
			try {
				result = new String(str.getBytes("euc-kr"), "8859_1");
			} catch (NullPointerException e) {
				result = "";
			} catch (Exception e) {
				result = "";
			}
		}
		return result;
	}

	/**
	 * Method asc2ksc. euc-kr을 8859-1로 인코딩하는 함수
	 * 
	 * @param str
	 *            - String
	 * @return String
	 */
	public static String asc2ksc(String str) {
		String result = "";
		if (isNull(str)) {
			result = "";
		} else {
			try {
				result = new String(str.getBytes("8859_1"), "euc-kr");
			} catch (NullPointerException e) {
				result = "";
			} catch (Exception e) {
				result = "";
			}
		}
		return result;
	}

	/**************************************************************************************/
	/* parse method start */

	/**
	 * String을 int형으로
	 * 
	 * @param value
	 * @return
	 */
	public static int parseInt(String value) {
		return parseInt(value, 0);
	}

	/**
	 * Object를 int형으로 defaultValue는 0이다.
	 * 
	 * @param value
	 * @return
	 */
	public static int parseInt(Object value) {
		String valueStr = replaceNull(value);
		return parseInt(valueStr, 0);
	}

	/**
	 * Object를 int형으로 Object가 null이면 defaultValue return
	 * 
	 * @param value
	 * @param defaultValue
	 * @return
	 */
	public static int parseInt(Object value, int defaultValue) {
		String valueStr = replaceNull(value);
		return parseInt(valueStr, defaultValue);
	}

	/**
	 * String을 int형으로 String이 숫자 형식이 아니면 defaultValue return
	 * 
	 * @param value
	 * @param defaultValue
	 * @return
	 */
	public static int parseInt(String value, int defaultValue) {
		int returnValue = 0;
		if (isNull(value)) {
			returnValue = defaultValue;
		} else if (!isNumeric(value)) {
			returnValue = defaultValue;
		} else {
			returnValue = Integer.parseInt(value);
		}
		return returnValue;
	}

	/**
	 * String을 long형으로 defaultValue는 0이다.
	 * 
	 * @param value
	 * @return
	 */
	public static long parseLong(String value) {
		return parseLong(value, 0);
	}

	/**
	 * String을 long형으로 잘못된 데이타 일시 return은 defaultValue
	 * 
	 * @param value
	 * @return
	 */
	public static long parseLong(String value, long defaultValue) {
		long returnValue = 0;
		if (isNull(value)) {
			returnValue = defaultValue;
		} else if (!isNumeric(value)) {
			returnValue = defaultValue;
		} else {
			returnValue = Long.parseLong(value);
		}
		return returnValue;
	}

	/**
	 * Exception을 String으로 뽑아준다.
	 * 
	 * @param ex
	 * @return
	 */
	public static String stackTraceToString(Throwable e) {
		try {
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			LOGGER.error("StringUtil", pw);
			return "------\r\n" + sw.toString() + "------\r\n";
		} catch (NullPointerException e2) {
			return StringUtil.stackTraceToString2(e);
		} catch (Exception e2) {
			return StringUtil.stackTraceToString2(e);
		}
	}

	/**
	 * Exception을 String으로 뽑아준다.
	 * 
	 * @param ex
	 * @return
	 */
	public static String stackTraceToString2(Throwable e) {
		ByteArrayOutputStream b = null;
		try {
			b = new ByteArrayOutputStream();
			
			try(PrintStream p = new PrintStream(b, false, "UTF-8");){
				LOGGER.error("stackTraceToString2", p);
				// p.close();
			} catch (UnsupportedEncodingException ex) {
				LOGGER.error("stackTraceToString2", ex);
			}
				
			String stackTrace = b.toString("UTF-8");
			// return convertHtmlBr(stackTrace);
			return stackTrace;
		} catch (UnsupportedEncodingException ex) {
			LOGGER.error("stackTraceToString2", ex);
			return "";
		}finally {
			if(b != null) {
				try {
					b.close();
				} catch (IOException e1) {
					LOGGER.error("stackTraceToString2", e1);
				}
			}
		}

	}

	/**
	 * Html 코드에서 &#60;br&#62; 태크 제거
	 * 
	 * @param comment
	 * @return
	 */
	public static String convertHtmlBr(String comment) {
		String rtnValue = "";
		if (isNull(comment)) {
			return "";
		}
		rtnValue = replace(comment, "\r\n", "<br>");
		return rtnValue;
	}

	/**
	 * String 배열을 List로 변환한다.
	 * 
	 * @param values
	 * @return
	 */
	public static List changeList(String[] values) {
		List list = new ArrayList();
		if (values == null) {
			return list;
		}
		for (int i = 0, n = values.length; i < n; i++) {
			list.add(values[i]);
		}
		return list;
	}

	public static String[] toTokenArray(String str, String sep) {
		String[] temp = null;
		try {
			StringTokenizer st = new StringTokenizer(str, sep);
			temp = new String[st.countTokens()];
			int index = 0;
			while (st.hasMoreTokens()) {
				temp[index++] = st.nextToken();
			}
		} catch (NullPointerException e) {
			LOGGER.error("StringUtil", e);
		} catch (Exception e) {
			LOGGER.error("StringUtil", e);
		}
		return temp;
	}

	public static String strip(String str, String str1) {
		if (str == null || "".equals(str.trim()))
			return "";
		String temp = str;
		int pos = -1;
		while ((pos = temp.indexOf(str1, pos)) != -1) {
			String left = temp.substring(0, pos);
			String right = temp.substring(pos + 1, temp.length());
			temp = left + "" + right;
			pos += 1;
		}
		return temp;
	}

	/**
	 * Method ksc2asc. euc-kr을 euc-kr로 인코딩하는 함수
	 * 
	 * @param str
	 *            - String
	 * @return String
	 */
	public static String ksc2utf8(String str) {
		String result = "";
		if (isNull(str)) {
			result = "";
		} else {
			try {
				result = new String(str.getBytes("euc-kr"), "utf-8");
			} catch (NullPointerException e) {
				result = "";
			} catch (Exception e) {
				result = "";
			}
		}
		return result;
	}

	/**
	 * string에 있는 ', ", \r\n 를 HTML 코드로 변환한다.
	 * 
	 * @param str
	 * @return
	 */
	public static String changeQuotation(String str) {
		String rtnValue = str;
		rtnValue = replaceNull(rtnValue);
		rtnValue = replace(
				replace(replace(rtnValue, "'", "&#39;"), "\"", "&#34;"),
				"\r\n", "<br>");
		return rtnValue;
	}

	public static String changeQuotation(Object obj) {
		if (isStringInteger(obj)) {
			return changeQuotation(String.valueOf(obj));
		}
		return "";
	}

	/**
	 * 해당 Object가 String or Integer 이면 true 아니면 false
	 * 
	 * @param obj
	 * @return
	 */
	public static boolean isStringInteger(Object obj) {
		boolean flag = false;
		if (obj instanceof String || obj instanceof Integer) {
			flag = true;
		}
		return flag;
	}

	/**
	 * 백분율을 구한다. %는 빼고 값만 리턴
	 * 
	 * @param value
	 * @param total
	 * @return
	 */
	public static String percentValue(int value, int total) {
		double val = Double.parseDouble(String.valueOf(value))
				/ Double.parseDouble(String.valueOf(total)) * 100;
		DecimalFormat df = new DecimalFormat("##0.0");
		return df.format(val);
	}

	/**
	 * XSS(Cross Site Scripting) 취약점 해결을 위한 처리
	 *
	 * @param sourceString
	 *            String 원본문자열
	 * @return String 변환문자열
	 */
	public static String replaceXSS(String sourceString) {
		String rtnValue = null;
		if (sourceString != null) {
			rtnValue = sourceString;
			if (rtnValue.indexOf("<x-") == -1) {
				rtnValue = rtnValue
						.replaceAll(
								"< *(j|J)(a|A)(v|V)(a|A)(s|S)(c|C)(r|R)(i|I)(p|P)(t|T)",
								"<x-javascript");
				rtnValue = rtnValue.replaceAll(
						"< *(v|V)(b|B)(s|S)(c|C)(r|R)(i|I)(p|P)(t|T)",
						"<x-vbscript");
				rtnValue = rtnValue.replaceAll(
						"< *(s|S)(c|C)(r|R)(i|I)(p|P)(t|T)", "<x-script");
				rtnValue = rtnValue.replaceAll(
						"< *(i|I)(f|F)(r|R)(a|A)(m|M)(e|E)", "<x-iframe");
				rtnValue = rtnValue.replaceAll("< *(f|F)(r|R)(a|A)(m|M)(e|E)",
						"<x-frame");
				rtnValue = rtnValue.replaceAll(
						"(e|E)(x|X)(p|P)(r|R)(e|E)(s|S)(s|S)(i|I)(o|O)(n|N)",
						"x-expression");
				rtnValue = rtnValue.replaceAll("(a|A)(l|L)(e|E)(r|R)(t|T)",
						"x-alert");
				rtnValue = rtnValue.replaceAll(".(o|O)(p|P)(e|E)(n|N)",
						".x-open");
				rtnValue = rtnValue.replaceAll(
						"< *(m|M)(a|A)(r|R)(q|Q)(u|U)(e|E)(e|E)", "<x-marquee");
				rtnValue = rtnValue.replaceAll("&#", "&amp;#");
			}
		}
		return rtnValue;
	}

	/**
	 * 특정문자를 HTML TAG형식으로 변경하는 메소드.
	 *
	 * <xmp> & --> &amp; < --> &lt; > --> &gt; " --> &quot; ' --> &#039;
	 * ----------------------------------------------------------------- <option
	 * type=radio name=r value="xxxxxxxx"> yyyyyyy <input type=hidden name=h
	 * value="xxxxxxxx"> <input type=text name=t value="xxxxxxxx"> <textarea
	 * name=msg rows=20 cols=53>xxxxxxx</textarea> - 위와 같은 HTML 소스를 생성할 때,
	 * xxxxxxx 부분의 문자열 중에서 아래에 있는 몇가지 특별한 문자들을 변환하여야 합니다. 만약 JSP 라면 미리 변환하여 HTML
	 * 전체 TAG를 만들거나, 혹은 아래처럼 사용하세요. - <option type=radio name=r
	 * value="<%= StringUtil.translate(s) %>"> yyyyyyy <input type=hidden name=n
	 * value="<%= StringUtil.translate(s) %>"> <input type=text name=n
	 * value="<%= StringUtil.translate(s) %>"> <textarea name=body rows=20
	 * cols=53><%= StringUtil.translate(s) %></textarea> - 또 필요하다면 yyyyyyy 부분도
	 * translate(s)를 할 필요가 있을 겁니다. 필요할 때 마다 사용하세요. - </xmp>
	 *
	 * @return the translated string.
	 * @param str
	 *            java.lang.String
	 */
	public static String translate(String str) {
		if (str == null)
			return null;
		StringBuffer buf = new StringBuffer();
		char[] c = str.toCharArray();
		int len = c.length;
		for (int i = 0; i < len; i++) {
			if (c[i] == '&')
				buf.append("&amp;");
			else if (c[i] == '<')
				buf.append("&lt;");
			else if (c[i] == '>')
				buf.append("&gt;");
			else if (c[i] == '"')
				buf.append("&quot;"); // (char)34
			else if (c[i] == '\'')
				buf.append("&#039;"); // (char)39
			else
				buf.append(c[i]);
		}
		return buf.toString();
	}

	/**
	 * String 앞 또는 뒤를 특정문자로 지정한 길이만큼 채워주는 함수 <BR>
	 * (예) pad("1234","0", 6, 1) --> "123400" <BR>
	 *
	 * @param src
	 *            Source string
	 * @param pad
	 *            pad string
	 * @param totLen
	 *            total length
	 * @param mode
	 *            앞/뒤 구분 (-1:front, 1:back)
	 * @return String
	 */
	public static String pad(String src, String pad, int totLen, int mode) {
		String paddedString = "";
		if (src == null)
			return "";
		int srcLen = src.length();
		if ((totLen < 1) || (srcLen >= totLen))
			return src;
		for (int i = 0; i < (totLen - srcLen); i++) {
			paddedString += pad;
		}
		if (mode == -1)
			paddedString += src; // front padding
		else
			paddedString = src + paddedString; // back padding
		return paddedString;
	}

	/**
	 * 주어진 길이(iLength)만큼 주어진 문자(cPadder)를 strSource의 왼쪽에 붙혀서 보내준다. ex)
	 * lpad("abc", 5, '^') ==> "^^abc" lpad("abcdefghi", 5, '^') ==> "abcde"
	 * lpad(null, 5, '^') ==> "^^^^^"
	 *
	 * @param strSource
	 * @param iLength
	 * @param cPadder
	 */
	public static String lpad(String strSource, int iLength, char cPadder) {
		StringBuffer sbBuffer = null;
		if (!isEmpty(strSource)) {
			int iByteSize = getByteSize(strSource);
			if (iByteSize > iLength) {
				return strSource.substring(0, iLength);
			} else if (iByteSize == iLength) {
				return strSource;
			} else {
				int iPadLength = iLength - iByteSize;
				sbBuffer = new StringBuffer();
				for (int j = 0; j < iPadLength; j++) {
					sbBuffer.append(cPadder);
				}
				sbBuffer.append(strSource);
				return sbBuffer.toString();
			}
		}
		// int iPadLength = iLength;
		sbBuffer = new StringBuffer();
		for (int j = 0; j < iLength; j++) {
			sbBuffer.append(cPadder);
		}
		return sbBuffer.toString();
	}

	/**
	 * 주어진 길이(iLength)만큼 주어진 문자(cPadder)를 strSource의 오른쪽에 붙혀서 보내준다. ex)
	 * lpad("abc", 5, '^') ==> "abc^^" lpad("abcdefghi", 5, '^') ==> "abcde"
	 * lpad(null, 5, '^') ==> "^^^^^"
	 *
	 * @param strSource
	 * @param iLength
	 * @param cPadder
	 */
	public static String rpad(String strSource, int iLength, char cPadder) {
		StringBuffer sbBuffer = null;
		if (!isEmpty(strSource)) {
			int iByteSize = getByteSize(strSource);
			if (iByteSize > iLength) {
				return strSource.substring(0, iLength);
			} else if (iByteSize == iLength) {
				return strSource;
			} else {
				int iPadLength = iLength - iByteSize;
				sbBuffer = new StringBuffer(strSource);
				for (int j = 0; j < iPadLength; j++) {
					sbBuffer.append(cPadder);
				}
				return sbBuffer.toString();
			}
		}
		sbBuffer = new StringBuffer();
		for (int j = 0; j < iLength; j++) {
			sbBuffer.append(cPadder);
		}
		return sbBuffer.toString();
	}

	/**
	 * byte size를 가져온다.
	 *
	 * @param str
	 *            String target
	 * @return int bytelength
	 */
	public static int getByteSize(String str) {
		if (str == null || str.length() == 0)
			return 0;
		byte[] byteArray = null;
		try {
			byteArray = str.getBytes("UTF-8");
		} catch (UnsupportedEncodingException ex) {
			LOGGER.warn(ex.getLocalizedMessage(), ex);
		}
		if (byteArray == null)
			return 0;
		return byteArray.length;
	}

	/**
	 * 긴 문자열 자르기
	 * 
	 * @param srcString
	 *            대상문자열
	 * @param nLength
	 *            길이
	 * @param isNoTag
	 *            테그 제거 여부
	 * @param isAddDot
	 *            "..."을추가 여부
	 * @return
	 */
	public static String strCut(String srcString, int nLength, boolean isNoTag,
			boolean isAddDot) { // 문자열 자르기
		String rtnVal = srcString;
		int oF = 0, oL = 0, rF = 0, rL = 0;
		int nLengthPrev = 0;
		// 태그 제거
		if (isNoTag) {
			Pattern p = Pattern.compile("<(/?)([^<>]*)?>",
					Pattern.CASE_INSENSITIVE); // 태그제거 패턴
			rtnVal = p.matcher(rtnVal).replaceAll("");
		}
		rtnVal = rtnVal.replaceAll("&amp;", "&");
		rtnVal = rtnVal.replaceAll("(!/|\r|\n|&nbsp;)", ""); // 공백제거
		try {
			byte[] bytes = rtnVal.getBytes("UTF-8"); // 바이트로 보관
			// x부터 y길이만큼 잘라낸다. 한글안깨지게.
			int j = 0;
			if (nLengthPrev > 0)
				while (j < bytes.length) {
					if ((bytes[j] & 0x80) != 0) {
						oF += 2;
						rF += 3;
						if (oF + 2 > nLengthPrev) {
							break;
						}
						j += 3;
					} else {
						if (oF + 1 > nLengthPrev) {
							break;
						}
						++oF;
						++rF;
						++j;
					}
				}
			j = rF;
			while (j < bytes.length) {
				if ((bytes[j] & 0x80) != 0) {
					if (oL + 2 > nLength) {
						break;
					}
					oL += 2;
					rL += 3;
					j += 3;
				} else {
					if (oL + 1 > nLength) {
						break;
					}
					++oL;
					++rL;
					++j;
				}
			}
			rtnVal = new String(bytes, rF, rL, "UTF-8"); // charset 옵션
			if (isAddDot && rF + rL + 3 <= bytes.length) {
				rtnVal += "...";
			} // ...을 붙일지말지 옵션
		} catch (UnsupportedEncodingException e) {
			LOGGER.error("StringUtil", e);
			return srcString;
		}
		return rtnVal;
	}

	/**
	 * total과 success 로 % 구하고 소수점 1자리까지 계산
	 * 
	 * @param int success
	 * @param int total
	 * @return String %
	 */
	public static String calculatePercent(int success, int total) {
		String result = "0";

		if (total == 0) {

		} else {

			Double tempSuccess = new Double(success + ".0");
			Double tempTotal = new Double(total + ".0");
			Double tempPercent = new Double(100 + ".0");

			double cal = tempSuccess.doubleValue() * tempPercent.doubleValue()
					/ tempTotal.doubleValue();

			result = new java.text.DecimalFormat("#.#").format(cal);

		}

		return result;
	}
	
	/**
	 * 현재시각을 특정 포맷으로 리턴
	 * 
	 * @param string time format
	 * @return String format
	 */
	public static String getNowDate(String format){
    	// (1) 시스템의 시간정보를 얻는다.
    	long curr = System.currentTimeMillis();  // 또는 System.nanoTime();

    	// (2) 출력 형태를 지정하기 위해 Formatter를 얻는다.
    	SimpleDateFormat sdf2 = new SimpleDateFormat(format);

    	// (3) 출력 형태에 맞는 문자열을 얻는다.
    	String datetime2 = sdf2.format(new Date(curr));
    	
    	return datetime2;
    }
	
	//SortPath를 통해  간략화된 SortNo 생성
	public static String getSortNo(String pStr){
		if(pStr == null || pStr.equals("")) {
			return "";
		} else {
			String[] strArr = pStr.split(";");
			String strReturn = "";
			
			for(String str : strArr){
				strReturn += Integer.parseInt(str);
			}
			
			return strReturn;	
		}
	}
	
	//SortPath를 통해 부모의 SortNo 생성
	public static String getParentSortNo(String pStr){
		String[] strArr = pStr.split(";");
		String resultStr = "";
		
		for(int i=0;i<strArr.length - 1;i++){
			resultStr += strArr[i] + ";";
		}
		
		return getSortNo(resultStr);
	}
	
	//NULL 체크 확인.
	public Object f_NullCheck(Object arg){
		
	  return arg == null||arg.equals("")? null : arg;
	}
	public String f_NullCheck(String arg){
	  return arg == null||"null".equals(arg)||"NULL".equals(arg)? "" : arg.trim();
	}
	
	//현재 년월일시분
	public String getOutputId(){
	  	Calendar oCalendar = Calendar.getInstance();
	  	   
	  	String year;
	  	String month;
	  	String day;
	  	String hour;
	  	String min;
	  	   
	  	year = oCalendar.get(Calendar.YEAR)+"";
	  	month = prepandZero(oCalendar.get(Calendar.MONTH)+1+"");
	  	day = prepandZero(oCalendar.get(Calendar.DAY_OF_MONTH)+"");
	  	hour = prepandZero(oCalendar.get(Calendar.HOUR_OF_DAY)+"");
	  	min = prepandZero(oCalendar.get(Calendar.MINUTE)+"");
	  	   
	  	return year+month+day+hour+min;
	}	
	
	//현재 년월일
	public String getOutputYear(){
		  	Calendar oCalendar = Calendar.getInstance();
		  	   
		  	String year;
		  	String month;
		  	String day;
		  	   
		  	year = oCalendar.get(Calendar.YEAR)+"";
		  	month = prepandZero(oCalendar.get(Calendar.MONTH)+1+"");
		  	day = prepandZero(oCalendar.get(Calendar.DAY_OF_MONTH)+"");
		  	   
		  	return year+"-"+month+"-"+day;
	 }	
	 
	//자리수
	 public static String prepandZero(String arg){
	 	if(arg.length()==1){
	 		arg = "0"+arg;
	 	}
	 	return arg;
	 }
	 
	//원하는 날짜 구하기
	public String previousDate(int previous){
		Calendar cal = new GregorianCalendar();
		cal.add(Calendar.DATE, previous);
		
		String year;
	  	String month;
	  	String day;
	  	
		year = cal.get(Calendar.YEAR)+"";
	  	month = prepandZero(cal.get(Calendar.MONTH)+1+"");
	  	day = prepandZero(cal.get(Calendar.DAY_OF_MONTH)+"");
	  	
		return 	year+"."+month+"."+day;
	}
	
	 /**
	 * 현재 시간 호출
	 * @return
	 */
	public String getCurrentTimeStr(){
	    long time = System.currentTimeMillis(); 
		SimpleDateFormat dayTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return dayTime.format(new Date(time));
	 }    
	
	 /**
	  * 난수 생성
	 * @param type
	 * @param cnt
	 * @return
	 */
	public static String randomValue(String type, int cnt) {

		 StringBuffer strPwd = new StringBuffer();

		 char str[] = new char[1];
		 
		 if (type.equals("P")) {
			// 특수기호 포함
			 for (int i = 0; i < cnt; i++) {
	
				 str[0] = (char) ((new SecureRandom().nextDouble() * 94) + 33);
		
				 strPwd.append(str);
	
			 }
	
		 } else if (type.equals("A")) {
			 // 대문자로만
			 for (int i = 0; i < cnt; i++) {
		
				 str[0] = (char) ((new SecureRandom().nextDouble() * 26) + 65);
		
				 strPwd.append(str);
	
			 }
	
			

		 } else if (type.equals("S")) {
			 // 소문자로만	
			 for (int i = 0; i < cnt; i++) {
	
				 str[0] = (char) ((new SecureRandom().nextDouble() * 26) + 97);
		
				 strPwd.append(str);
	
			 }

		 } else if (type.equals("I")) {
			// 숫자형으로
			 int strs[] = new int[1];
	
			 for (int i = 0; i < cnt; i++) {
		
				 strs[0] = (int) (new SecureRandom().nextDouble() * 9);
		
				 strPwd.append(strs[0]);
	
			 }

		 } else if (type.equals("C")) {
			// 소문자, 숫자형
			 SecureRandom rnd = new SecureRandom();

			 for (int i = 0; i < cnt; i++) {
	
				 if (rnd.nextBoolean()) {
		
					 strPwd.append((char) ((int) (rnd.nextInt(26)) + 97));
	
				 } else {
			
					 strPwd.append((rnd.nextInt(10)));
			
				 }

			}
		 }

		 return strPwd.toString();
	}    
	
	/**
	 * 짝수 단위 16진수 생성
	 * @param hex
	 * @return
	 * @throws IllegalArgumentException
	 */
	public static byte[] hex2byte( String hex ) throws IllegalArgumentException
	{
	    if ( hex.length( ) % 2 != 0 )
	    {
	        throw new IllegalArgumentException( );
	    }
	    char[] arr = hex.toCharArray( );
	    byte[] b = new byte[hex.length( ) / 2];
	    for ( int i = 0 , j = 0 , l = hex.length( ) ; i < l ; i++ , j++ )
	    {
	         String swap = "" + arr[ i++ ] + arr[ i ];
	         int byteint = Integer.parseInt( swap , 16 ) & 0xFF;
	         b[ j ] = Integer.valueOf( byteint ).byteValue();
	    }
	    
	    return b;
	}

	/**
	 * 16진수 변환
	 * @param base
	 * @return
	 */
	public static String stringToHex(String base)
    {
	     StringBuffer buffer = new StringBuffer();
	     int intValue;
	     for(int x = 0; x < base.length(); x++)
	         {
	         int cursor = 0;
	         intValue = base.charAt(x);
	         String binaryChar = Integer.toBinaryString(base.charAt(x));
	         for(int i = 0; i < binaryChar.length(); i++)
	             {
	             if(binaryChar.charAt(i) == '1')
	                 {
	                 cursor += 1;
	             }
	         }
	         if((cursor % 2) > 0)
	             {
	             intValue += 128;
	         }
	         buffer.append(Integer.toHexString(intValue) + " ");
	     }
	     return buffer.toString();
    }
	
	/**
	 * Client IP 추출
	 * @param req
	 * @return
	 */
	public String getRemoteIP(HttpServletRequest req){
		
		String ip = req.getHeader("X-Forwarded-For");
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {  
		    ip = req.getHeader("Proxy-Client-IP");  
		}  
		
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {  
		    ip = req.getHeader("WL-Proxy-Client-IP");  
		}  
		
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {  
		    ip = req.getHeader("HTTP_CLIENT_IP");  
		}  
		
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {  
		    ip = req.getHeader("HTTP_X_FORWARDED_FOR");
		}  
		
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {  
		    ip = req.getRemoteAddr();  
		}
		
		if(f_NullCheck(ip).equals("") || f_NullCheck(ip).equals("0:0:0:0:0:0:0:1") || f_NullCheck(ip).equals("127.000.000.1") || f_NullCheck(ip).equals("127.000.000.001")){
			ip = "127.0.0.1";
        }
		
		return ip;
	}
	
	 private static String regexIPv4 = "^(25[0-5]|2[0-4]\\d|[0-1]?\\d?\\d)(\\.(25[0-5]|2[0-4]\\d|[0-1]?\\d?\\d)){3}$";
	 private static String regexIPv6 = "^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$";
	 private static String regexIPv4andIPv6 = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$";
	 
	 /**
	 * IPv4, IPv6 타입 추출 
	 * @param ipAddress
	 * @return
	 */
	public static boolean checkIp(String ipAddress) {
	        Pattern pattern;
	 
	        pattern = Pattern.compile(regexIPv4andIPv6);
	        if (ipAddress == null || pattern.matcher(ipAddress).matches() == false) {
	            return false;
	        } else {
	            // IPv4
	            pattern = Pattern.compile(regexIPv4);
	            if (pattern.matcher(ipAddress).matches() == true) {
	            	return true;
	            }
	 
	            // IPv6
	            pattern = Pattern.compile(regexIPv6);
	            if (pattern.matcher(ipAddress).matches() == true) {
	            	return true;
	            }
	            
	            
	            return true;
	        }
	 
	 }
	 
	 /**
	 * 난수 생성
	 * @return
	 */
	public String RandomNum(){
		 StringBuffer buffer = new StringBuffer();
		 for(int i = 0; i<= 3; i++){
			 int n = (int) (new SecureRandom().nextDouble() * 10);
			 buffer.append(n);
		 }
		 
		 return buffer.toString();
	 }
	 
	 /**
	  * %, ; 문자열 공백처리
	 * @param str
	 * @return
	 */
	public String StringFileNameReplace(String str){       
		 
		 str = str.replaceAll("%", ""); 
		 str = str.replaceAll(";", ""); 
		 
	     return str;
	 }
	 
	 /**
	 * 난수 생성
	 * @return
	 */
	public String getRandom(){
		 StringBuffer temp = new StringBuffer();
		 SecureRandom rnd = new SecureRandom();
		 for (int i = 0; i < 20; i++) {
			 int rIndex = rnd.nextInt(3);
			 switch (rIndex) {
			 case 0:
				 // a-z
				 temp.append((char) ((int) (rnd.nextInt(26)) + 97));
				 break;
			 case 1:
				 // A-Z
				 temp.append((char) ((int) (rnd.nextInt(26)) + 65));
				 break;
			 case 2:
				 // 0-9
				 temp.append((rnd.nextInt(10)));
				 break;
			 default : 
				 break;
			 }
		 }
		 
		 
		 return temp.toString();
		 
	 }
	 

	/**
	 * java.nio.charset.CharsetDecoder 대신 사용.
	 * @param input
	 * @return
	 */
	public static String removeNonUnicodeCharacters(String input) {
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            if(Character.compare(c, '\u0000') >= 0 && Character.compare(c, '\uFFFF') <= 0) {
                stringBuilder.append(c);
            }
        }
        return stringBuilder.toString();
	}
}
