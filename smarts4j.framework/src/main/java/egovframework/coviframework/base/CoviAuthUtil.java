package egovframework.coviframework.base;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import egovframework.baseframework.util.json.JSONParser;


import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ACLHelper;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;



import javax.servlet.http.HttpServletRequest;

import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.RedisShardsUtil;
public class CoviAuthUtil {
	public static final Logger logger = Logger.getLogger(CoviAuthUtil.class);
	private static final String[] exceptKey = new String[] { 
			"CLSYS", 
			"CLMD",
			"CLBIZ"/*,
			"CSMU",*/
		};

	private static final HashMap<String,String> exceptVal = new HashMap<String,String>(){{//초기값 지정
	    put("boardType","Normal");
	}};
	
	private static boolean getExceptKey(String id){
		for (String s : exceptKey) {
			if(id.contains(s)){
				return true;
			}
		}
		return false;
	}
	
	private static boolean getExceptVal(String key, String val){
		if (exceptVal.get(key) != null && exceptVal.get(key).equalsIgnoreCase(val)) return true;
		else 		return false;
		
	}
	
	public static boolean getUrlAudit(String menuUrl, HttpServletRequest request){
		JSONSerializer jUtil = new JSONSerializer();
		try{
			//김사 url 체크
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String auditInfo = instance.get(RedisDataUtil.PRE_AUDIT_URL + menuUrl );
			if (auditInfo != null){
				CoviMap obj = CoviMap.fromObject(auditInfo);
				CoviMap userDataObj = SessionHelper.getSession(ClientInfoHelper.isMobile(request));
				
				if (obj.getString("IsAdmin").equals("Y") && !userDataObj.getString("isAdmin").equals("Y")){
					LoggerHelper.pageMoveLoggerForSQL(menuUrl, "NOAUDIT");
					
					// 권한 오류 로그
					LoggerHelper.authErrorLogger(menuUrl, "NOAUDIT", obj.getString("AuditClass"), obj.getString("AuditMethod"), "Audit unauthorized : Administrator only access", "");
					return false;
				}
				
				//메뉴 권한 확인
				if (obj.get("AuditMenuIDs") != null && !obj.getString("AuditMenuIDs").equals("") && !obj.getString("AuditMenuIDs").equals("null")){
					boolean bFind = false;
					String[] authMenu = obj.getString("AuditMenuIDs").split(",");
					String menuStr = ACLHelper.getMenu(userDataObj);

					try {
						if (StringUtils.isNoneBlank(menuStr)) {
							CoviList menuArray = jUtil.jsonGetObject(menuStr);
							for (int j=0; j< authMenu.length; j++){
								for (int i = 0; i < menuArray.size(); i++) {
									CoviMap menuObj = (CoviMap) menuArray.get(i);
									if (authMenu[j].equals(menuObj.get("MenuID")) ||
											authMenu[j].equals(menuObj.get("OriginMenuID")) ){
										bFind=true;
										break;
									}	
								}	
								if (bFind==true) break;
							}	
						}
						
						if (bFind == false){
							LoggerHelper.pageMoveLoggerForSQL(menuUrl, "NOAUDIT");
							
							// 권한 오류 로그
							LoggerHelper.authErrorLogger(menuUrl, "NOAUDIT", "", "", "Audit unauthorized : No menu permission", "");
							return false;
						}
					} catch(NullPointerException e){				
						logger.debug(e);
					} catch(Exception e){
						logger.debug(e);
					}
				}	

				//권한 클래스 확인
				String className = obj.getString("AuditClass");
				String methodName  = obj.getString("AuditMethod");
				CoviMap cmap = new CoviMap();
				if (obj.getString("IsAudit").equals("Y") && !className.equals("null") && !className.equals("") 
							&& !methodName.equals("null") &&  !methodName.equals("")) {
					try {
						Class<?> c = Class.forName(className);
						Method method = c.getMethod(methodName, CoviMap.class);
						cmap = ComUtils.requestToCoviMap(request);
						cmap.put("menuUrl", menuUrl);
						
						boolean result = (boolean) method.invoke(c, cmap);
						
						if (result == false){							
							LoggerHelper.pageMoveLoggerForSQL(menuUrl, "NOAUDIT");
							
							// 권한 오류 로그
							LoggerHelper.authErrorLogger(menuUrl, "NOAUDIT", className, methodName, "Audit unauthorized : No audit permission", "");
						}	
						return result;
					} catch(NoSuchMethodException e1) {	//메소드가 없는 경우  true로
						return true;
					} catch(Exception e) {
						LoggerHelper.pageMoveLoggerForSQL(menuUrl, "NOAUDIT");
						
						// 권한 오류 로그
						LoggerHelper.authErrorLogger(menuUrl, "NOAUDIT", className, methodName, e.getMessage(), "");
						return false;
					}
				}	
			}
		} catch(NullPointerException e){
			return false;
		}catch(Exception e){
			return false;
		}
		return true;
	}	
	
	public static boolean getMenuAuth(String menuUrl, String menuQuery, HttpServletRequest request){
		boolean bOK = false;
		boolean isMobile = false;
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		Map<String, String> menuQueries = new LinkedHashMap<String, String>();
		if (userDataObj == null) return true;

		if (menuQuery != null && !menuQuery.equals("")){
			menuQueries = splitQuery(menuQuery);
		}

		try{
			String authMenuStr = ACLHelper.getMenu(userDataObj);
			JSONSerializer jUtil = new JSONSerializer();
			if(StringUtils.isNoneBlank(authMenuStr)){
				CoviList menuArray = jUtil.jsonGetObject(authMenuStr);
				for (int i = 0; i < menuArray.size(); i++) {
					CoviMap menuObj = (CoviMap) menuArray.get(i);
					if(menuObj != null && !menuObj.isEmpty()) {
						String authMenuUrl = (String)menuObj.get("URL");
						String reserved5 = (String)menuObj.get("Reserved5");
						if (!reserved5.equals("")) authMenuUrl = reserved5;
						
						if (authMenuUrl.indexOf(menuUrl)>-1){
							Map<String, String> authMenuQueries = new LinkedHashMap<String, String>();
							if (authMenuUrl.indexOf("?")>-1){
								authMenuQueries = splitQuery(authMenuUrl.substring(authMenuUrl.indexOf("?")+1 ));
							}
							
							Set<String> set =(authMenuQueries).keySet();
							String[] keys = set.toArray(new String[set.size()]);
							boolean bDiff = false;
							for (int j=0 ; j < keys.length; j++){
								String key = keys[j];
								if (!((String)authMenuQueries.get(key)).equalsIgnoreCase((String)menuQueries.get(key))
										&& !getExceptKey(key)
										&& !getExceptVal(key, (String)menuQueries.get(key))	){
									bDiff = true;
									break;
								}
							}
							if (bDiff == false) {
								return getUrlAudit(menuUrl, request);
							}
						}
					}
				}
			}
		} catch(NullPointerException e){	
			logger.error(e);
		} catch (Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		
		try{
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			//권한 메뉴 전체 목록 
			Set<String> names = instance.keys(menuUrl, RedisDataUtil.PRE_AUTH_MENU + menuUrl + "_*");
			Iterator<String> it = names.iterator();
			while (it.hasNext()) {
				String authMenuStr = instance.get(it.next());
				if(authMenuStr != null && !authMenuStr.isEmpty()) {
					JSONParser jsonObjParser = new JSONParser();
					
					CoviMap menuObj = (CoviMap)jsonObjParser.parse(authMenuStr);
					String authMenuUrl = (String)menuObj.get("URL");
					if (authMenuUrl.indexOf(menuUrl)>-1){
						Map<String, String> authMenuQueries = new LinkedHashMap<String, String>();
						if (authMenuUrl.indexOf("?")>-1){
							authMenuQueries = splitQuery(authMenuUrl.substring(authMenuUrl.indexOf("?")+1 ));
						}
	
						Set<String> set =(authMenuQueries).keySet();
						String[] keys = set.toArray(new String[set.size()]);
						boolean bSame = true;
						for (int j=0 ; j < keys.length; j++){
							String key = keys[j];
							if (!((String)authMenuQueries.get(key)).equalsIgnoreCase((String)menuQueries.get(key))
									&& !getExceptKey(key)	){
								bSame = false;
								break;
							}
						}
						if (bSame == true) {
							LoggerHelper.pageMoveLoggerForSQL(menuUrl, "NOAUTH");
							
							// 권한 오류 로그
							LoggerHelper.authErrorLogger(menuUrl, "NOAUTH", "", "", "Auth unauthorized : No menu permission", "");
							return false;
						}
					}
				}
			}	
		} catch(NullPointerException e){	
			logger.error(e);
		}catch (Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}

		return getUrlAudit(menuUrl, request);
	}
	
	private static Map<String, String> splitQuery(String url) {
	    Map<String, String> query_pairs = new LinkedHashMap<String, String>();
	    if (url != null) {
		    String[] pairs = url.split("&");
		    for (String pair : pairs) {
		        int idx = pair.indexOf("=");
		        if (idx > -1)	query_pairs.put(pair.substring(0, idx),pair.substring(idx + 1));
		    }
	    }    
	    return query_pairs;
	}
}
