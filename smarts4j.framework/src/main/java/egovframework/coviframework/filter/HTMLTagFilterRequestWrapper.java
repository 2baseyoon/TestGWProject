package egovframework.coviframework.filter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

/**
 * 전자정부 프레임웍의 egovframework.rte.ptl.mvc.filter.HTMLTagFilter 버젼이 변경(4.0) 되면서 사이드이펙트 발생
 * 3.9 버젼과 동일하게 자체 Filter 처리하며, 이후 필요시 여기를 수정. 
 * 
 * 3.9 버젼은 getParameterMap() 을 Override 하지 않았음
 * 영향도 > Controller 에서 @RequestParam 을 Map 으로 선언한 경우 Binding 될때 escape 되지 않음을 고려하여 사용한 코드가 존재함.
 * @author hgsong
 */
public class HTMLTagFilterRequestWrapper extends HttpServletRequestWrapper {
	public HTMLTagFilterRequestWrapper(HttpServletRequest request) {
		super(request);
	}

	public String[] getParameterValues(String parameter) {
		String[] values = super.getParameterValues(parameter);
		if (values == null) {
			return null;
		}
		for (int i = 0; i < values.length; i++) {
			if (values[i] != null) {
				values[i] = getSafeParamData(values[i]);
			} else {
				values[i] = null;
			}
		}
		return values;
	}

	public String getParameter(String parameter) {
		String value = super.getParameter(parameter);
		if (value == null) {
			return null;
		}
		value = getSafeParamData(value);
		return value;
	}

	public String getSafeParamData(String value) {
		StringBuilder stringBuilder = new StringBuilder();
		for (int i = 0; i < value.length(); i++) {
			char c = value.charAt(i);
			switch (c) {
			case '<':
				stringBuilder.append("&lt;");
				break;
			case '>':
				stringBuilder.append("&gt;");
				break;
			case '&':
				stringBuilder.append("&amp;");
				break;
			case '"':
				stringBuilder.append("&quot;");
				break;
			case '\'':
				stringBuilder.append("&apos;");
				break;
			default:
				stringBuilder.append(c);
				break;
			}
		}
		value = stringBuilder.toString();
		return value;
	}
}
