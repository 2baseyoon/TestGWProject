package egovframework.covision.coviflow.govdocs.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import egovframework.coviframework.util.ComUtils;

public class PrivacyInfoMaskingUtil {

	private static List<String> regExpList = null;
	
	public static void init() {
		//if(regExpList == null) {
			//opendoc.private.info.regexp
			regExpList = new ArrayList<String>();
			Set<String> pKeys = ComUtils.getProperties("govdocs.properties").stringPropertyNames();
			for(String key : pKeys) {
				if(key.startsWith("opendoc.private.info.regexp")) {
					String regexp = ComUtils.getProperties("govdocs.properties").getProperty(key);
					regExpList.add(regexp);
				}
			}// end for
		//}
	}
	public static String getMaskContents (String content) {
		String newContent = content;
		try {
			init();
			StringBuffer buf = new StringBuffer();
			for(String regExpStr : regExpList) {
				buf = new StringBuffer();
				Pattern p = Pattern.compile(regExpStr, Pattern.CASE_INSENSITIVE);
				Matcher m = p.matcher(newContent);
				while (m.find()) {
					String group = m.group();
					int len = group.length();
					char[] c = new char[len];
					Arrays.fill(c, '*');
					
					
					m.appendReplacement(buf, String.valueOf(c));
				}
				m.appendTail(buf);
				newContent = buf.toString();
			}
			return newContent;
		}catch(ArrayIndexOutOfBoundsException aioobE) {
			return content;
		}catch(NullPointerException npE) {
			return content;
		}catch(Exception e) {
			return content;
		}
	}
}
