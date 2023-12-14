package egovframework.core.sso.oauth;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.TreeMap;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

public class OAuth2Scope {

	public static final String SCOPE_PERSONAL_INFO = "personalinfo";

	// 각 REST 엔드포인트마다 허용할 scope 지정
	private static final HashMap<String, String> scopeUrlMap;
	// Client 등록 화면에 보여줄 scope 지정
	private static final TreeMap<String,String> scopeMsgMap;
	
	static {
		scopeUrlMap = new HashMap<String, String>();
		scopeMsgMap = new TreeMap<String, String>();
		
		scopeUrlMap.put("GET /resource/myinfo.do", SCOPE_PERSONAL_INFO);
		
		try {
			scopeMsgMap.put(SCOPE_PERSONAL_INFO, getMsg());
		} catch (NullPointerException e) {
			scopeMsgMap.put(SCOPE_PERSONAL_INFO, "개인 정보를 관리합니다.");
		} catch (Exception e) {
			scopeMsgMap.put(SCOPE_PERSONAL_INFO, "개인 정보를 관리합니다.");
		}
	}
	
	public static String getScopeFromURI(String uri) {
		return scopeUrlMap.get(uri);
	}

	public static String getScopeMsg(String scopeKey) {
		return scopeMsgMap.get(scopeKey);
	}
	
	public static boolean isScopeExistInMap(String strScope) {
		boolean isValid = true;
		String[] scopes = strScope.split(",");
		for (int i=0; i < scopes.length; i++) {
			String v = getScopeMsg(scopes[i]);
			if (v == null) {
				isValid = false; break;
			}
		}
		
		return isValid;
	}
	
	public static boolean isScopeValid(String receivedScope, String registeredClientScope) {
		String rscopes[] = receivedScope.split(",");
		String temp[] = registeredClientScope.split(",");
		
		List<String> sscopes = Arrays.asList(temp);
		boolean isValid = true;
		for (int i=0; i < rscopes.length; i++) {
			if (sscopes.contains(rscopes[i]) == false) {
				isValid = false;
				break;
			}
		}
		return isValid;
	}

	public static boolean isUriScopeValid(String uriScope, String tokenScopes) {
		String temp[] = tokenScopes.split(",");
		List<String> sscopes = Arrays.asList(temp);
		if (sscopes.contains(uriScope))
			return true;
		else
			return false;
	}
	
	public static String getMsg(){
		String msg = "";
		StringUtil func = new StringUtil();
		
		SessionHelper.setExpireTime();
		String lang = SessionHelper.getSession("lang");
		
		if(func.f_NullCheck(lang).equals("")){
			msg = "개인 정보를 관리합니다.";
		}else{
			if("ko".equals(lang)){
				msg = "개인 정보를 관리합니다.";
			}else if("ja".equals(lang)){
				msg = "個人情報を管理します.";
			}else if("za".equals(lang)){
				msg = "我们管理个人信息.";
			}else{
				msg = "We manage personal information.";
			}
			
		}
		
		return msg;
	}
}
