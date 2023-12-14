package egovframework.coviframework.util;

import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class XSSUtils  {

	private static Logger logger = LogManager.getLogger(XSSUtils.class);

	public static String XSSFilter(String orgValue){
		return XSSFilter(orgValue, false);
	}
	public static String XSSFilter(String orgValue, Boolean isJsonEscape){
		if (orgValue  == null) return orgValue;
		String value = orgValue;
		/* sql injection */
		// Regex for detection of SQL meta-characters
		// value = value.replaceAll("/(\\%27)|(\\')|(\\-\\-)|(\\%23)|(#)/ix","");
		// value = value.replaceAll("/((\\%3D)|(=))[^\n]*((\\%27)|(\\')|(\\-\\-)|(\\%3B)|(;))/i","");
		// value = value.replaceAll("/\\w*((\\%27)|(\\'))((\\%6F)|o|(\\%4F))((\\%72)|r|(\\%52))/ix","");
		value = value.replaceAll("/exec(\\s|\\+)+(s|x)p\\w+/ix","");
		value = value.replaceAll("insert\\s+|update\\s+|delete\\s+|having\\s+|drop\\s+|(\'|%27).(and|or).(\'|%27)|(\'|%27).%7C{0,2}|%7C{2}","");  
	
		/*XSS Filter*/
		// Avoid null characters
        value = value.replaceAll("", "");

        // Avoid anything between script tags
        Pattern scriptPattern = Pattern.compile("<script>(.*?)</script>", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");

        scriptPattern = Pattern.compile("%3Cscript%3E(.*?)%3C%2Fscript%3E", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");
        
        // Avoid anything in a src='...' type of expression
        scriptPattern = Pattern.compile("src[\r\n]*=[\r\n]*\\\'(.*?)\\\'", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        scriptPattern = Pattern.compile("src[\r\n]*=[\r\n]*\\\"(.*?)\\\"", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        // Remove any lonesome </script> tag
        scriptPattern = Pattern.compile("</script>", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");

        scriptPattern = Pattern.compile("%3C%2Fscript%3E", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");

        // Remove any lonesome <script ...> tag
        scriptPattern = Pattern.compile("<script(.*?)>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        scriptPattern = Pattern.compile("%3Cscript%3E(.*?)>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        scriptPattern = Pattern.compile("&lt;script&gt;(.*?)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");
        scriptPattern = Pattern.compile("&lt;/script&gt;", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");
        
        // Avoid eval(...) expressions
        scriptPattern = Pattern.compile("eval\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid alert(...) expressions
        scriptPattern = Pattern.compile("alert\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid prompt(...) expressions
        scriptPattern = Pattern.compile("prompt\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid expression(...) expressions
        scriptPattern = Pattern.compile("expression\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid javascript:... expressions
        scriptPattern = Pattern.compile("javascript:", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid vbscript:... expressions
        scriptPattern = Pattern.compile("vbscript:", Pattern.CASE_INSENSITIVE);
        value = scriptPattern.matcher(value).replaceAll("");

        // Avoid onload= expressions
        String[] evenArray = {"onblur","onclick","ondragend","onfocus", "onkeydown", "onload","onmouseover","onmousedown","onmousemove","onmouseup", "onpointermove", "onpointerup","onresize", "ontoggle", "ontouchend","ontouchmove","ontouchstart","onerror","onpointerenter","onpointerrawupdate"};
        
        for (int i=0; i < evenArray.length;i++ ){
        	//''로 쌓은 event
        	// 이벤트가 연속되는 경우 "=" 도 중간문자열로 인식하고 다음 "=" 위치까지 제거되므로 수정
        	// ex) 원본 : "<diva onpointerenter='prompt(aaa)'><divb onpointerenter=\"prompt('bbb')\"><divc onpointerenter='prompt(ccc)'><divd onpointerenter=\"prompt('ddd')\">"
        	// ex) 변환 : "<diva ><divb ><divd onpointerenter=\"prompt('ddd')\">"
        	//scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(.*?)=[\r\n]*\\\'(.*?)\\\'", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
        	scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(\\s*)=(\\s*)[\r\n]*\\\'(.*?)\\\'", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            value = scriptPattern.matcher(value).replaceAll("");
            
        	//""로 쌓은 event
        	//scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(.*?)=[\r\n]*\\\"(.*?)\\\"", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(\\s*)=(\\s*)[\r\n]*\\\"(.*?)\\\"", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
        	if(isJsonEscape) scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(\\s*)=(\\s*)[\r\n]*\\\\\\\"(.*?)\\\\\\\"", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            value = scriptPattern.matcher(value).replaceAll("");

        	//공백전까지
            scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(.*?)=(.*?)\\s", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            value = scriptPattern.matcher(value).replaceAll("");

        	//>전까지
            scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(.*?)=(.*?)>", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            value = scriptPattern.matcher(value).replaceAll(">");

            scriptPattern = java.util.regex.Pattern.compile(evenArray[i]+"(.*?)=", java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.DOTALL);
            value = scriptPattern.matcher(value).replaceAll("");
        }    
        
		if (logger.isDebugEnabled()) {
			if (value!= null && !orgValue.equalsIgnoreCase(value)) {
				logger.debug("orgValue :"+ orgValue+", chnValue : "+value);
			}
		}
		
		return ComUtils.RemoveScriptTag(value);
    }

	public static String removeXSSScript(String orgValue){
		if (orgValue == null) return orgValue;
		String value = XSSFilter(orgValue);//혹시 몰라 한번더 
		Pattern rgCookie = Pattern.compile("document.*?cookie", Pattern.DOTALL );   
		value = rgCookie.matcher(value).replaceAll("");
		return value;
	}

}
