package egovframework.covision.groupware.portal.user.service.impl;

import java.lang.reflect.Method;
import java.util.Map;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.base.ThreadExecutorBean;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.CoviLoggerHelper;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import egovframework.covision.groupware.portal.user.service.TemplateFileCacheSvc;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.baseframework.util.SessionHelper;

@Service("portalService")
public class PortalSvcImpl extends EgovAbstractServiceImpl implements PortalSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private TemplateFileCacheSvc templateFileCacheSvc;
	
	private static final Logger LOGGER = LogManager.getLogger(PortalSvcImpl.class);
	
	//ThreadPool 전역변수 사용방식 변경
	//클래스로 빼서 Spring Bean 등록하여 톰캣 종료시 shutdown 하는 방법으로 변경
	/*
	int poolSize = 2;
    int maxPoolSize = 2;
    long keepAliveTime = 10;
    final ArrayBlockingQueue<Runnable> queue = new ArrayBlockingQueue<Runnable>(5);
	
    ThreadPoolExecutor executor = new ThreadPoolExecutor(poolSize, maxPoolSize, keepAliveTime, TimeUnit.SECONDS, queue);
	*/
	
//    private CoviMap sessionObj;
    //private CoviList aclArray;
	private final String jsPath = initJSFilePath();
	private final String htmlPath = initHTMLFilePath();
	private static final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	
	// 포탈 로딩 관련 method 시작
	private static String initHTMLFilePath(){
		String ret;
		if(osType.equals("WINDOWS")){
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalHTML.WINDOW.path");
		} else {
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalHTML.UNIX.path");
		}
		return ret;
	}
	
	private static String initJSFilePath(){
		String ret;
		if(osType.equals("WINDOWS")){
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalJS.WINDOW.path");
		} else {
			ret = PropertiesUtil.getGlobalProperties().getProperty("portalJS.UNIX.path");
		}
		return ret;
	}
	
	@Override
	public Object getWebpartData(final CoviList webPartArray, CoviMap userDataObj) throws Exception {
		return getWebpartData(webPartArray, userDataObj, "N");
	}
	
	@Override
	public Object getWebpartData(final CoviList webPartArray, CoviMap userDataObj, final String isMobile) throws Exception {
		CoviMap		sessionObj = userDataObj;
		// aclArray = CoviList.fromObject(RedisDataUtil.getACL(sessionObj.getString("USERID"), sessionObj.getString("DN_ID"))); 
		CoviList retWebPartArr = new CoviList();
//		Set<Future<Object>> set = new HashSet<Future<Object>>();
		Set<Callable<Object>> set = new HashSet<Callable<Object>>();

		for (final Object webPart: webPartArray) {
			// pass servletrequest
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
			((CoviMap)webPart).setRequest(request);

			CoviMap webTmp  = (CoviMap)webPart;
			
			String viewHtml = "";
			
			if(webTmp.has("HtmlFilePath") && (!webTmp.getString("HtmlFilePath").equals("")) ){
				String webpartPath = ((webTmp.getString("HtmlFilePath").indexOf("mobile")==0) ? htmlPath.replace("/user", "") : htmlPath) + webTmp.getString("HtmlFilePath");
				
				viewHtml = new String(Base64.encodeBase64(
						templateFileCacheSvc.readAllText(sessionObj.getString("lang"), webpartPath, "UTF8").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
			}

			String initMethod = new String(Base64.encodeBase64(webTmp.getString("ScriptMethod").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);

			CoviMap callRet  = new CoviMap();
			callRet.put("viewHtml", viewHtml);
			callRet.put("initMethod", initMethod);
			
			//데이타 재세팅
			callRet.put("WebpartID", webTmp.getString("WebpartID"));	
			callRet.put("WebpartOrder", webTmp.getString("WebpartOrder"));
			
			callRet.put("ExtentionJSON", webTmp.getString("ExtentionJSON"));
			callRet.put("DisplayName", webTmp.getString("DisplayName"));
			
			callRet.put("Reserved1", webTmp.getString("Reserved1"));
			callRet.put("Reserved2", webTmp.getString("Reserved2"));
			callRet.put("Reserved3", webTmp.getString("Reserved3"));
			callRet.put("Reserved4", webTmp.getString("Reserved4"));
			callRet.put("Reserved5", webTmp.getString("Reserved5"));
			callRet.put("WebpartColor", webTmp.getString("WebpartColor"));
			
			
			callRet.put("JsFilePath", webTmp.getString("JsFilePath"));
			callRet.put("JsModuleName", webTmp.getString("JsModuleName"));
			callRet.put("ScriptMethod", webTmp.getString("ScriptMethod"));
			callRet.put("SortKey", webTmp.getString("SortKey"));
			
			if(webTmp.getString("WebpartOrder").indexOf('-')>-1 || (webTmp.has("DataJSON") && (!webTmp.getString("DataJSON").equals("[]"))) ){
				Callable<Object> task = new Callable<Object>() {
					@Override
					public Object call() throws Exception {
						//Server-SideRendering
						if(webTmp.getString("WebpartOrder").indexOf('-')>-1 || (webTmp.has("DataJSON") && (!webTmp.getString("DataJSON").equals("[]"))) ){
							//webTmp.put("extentionJSON", webTmp.getString("ExtentionJSON"));
							callRet.put("data", getWebpartQueryData(webTmp, sessionObj));
						}
	
						return callRet;
					}
				};
	//			Future<Object> future = ThreadExecutorBean.getInstance().submit(task);
				set.add(task);
			}	else{
				retWebPartArr.add(callRet);
			}
		}

		int iTimeout = StringUtil.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("PortalTimeout"),"300"),300);
		int iPool = StringUtil.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("PortalPool"),"10"),10);
		
		long startTime = System.currentTimeMillis();
		//서버 랜더링 병렬및 타임아웃 추가
		java.util.concurrent.ExecutorService executorService = java.util.concurrent.Executors.newFixedThreadPool(iPool);
		List<Future<Object>> futures = executorService.invokeAll(set, iTimeout, java.util.concurrent.TimeUnit.MILLISECONDS);
	    for(Future<Object> f : futures) {
	    	try{
				CoviMap futureObj = new CoviMap();
				futureObj = (CoviMap)f.get(iTimeout, java.util.concurrent.TimeUnit.MILLISECONDS);
				futureObj.put("data", futureObj.getString("data"));
				retWebPartArr.add(futureObj);
	    	}catch (java.util.concurrent.TimeoutException e) {
		    	long currentTime = System.currentTimeMillis();
		    	long prossTime = currentTime - startTime;
//				System.out.println("timeout:["+prossTime+"]"+java.time.LocalDateTime.now());
	        	LoggerHelper.errorLogger(new Exception(e), "Webpart ServerLandering Timeout[Webpart]"+ iTimeout+":"+prossTime, "Timeout");
		    }	catch(Exception e1){
				LOGGER.error("PortalSvcImpl", e1);
			}	
	    }
	    executorService.shutdown();
	    
	    for (final Object webPart: webPartArray) {
			CoviMap webPartData  = (CoviMap)webPart;
			boolean bFind = false;
			for (final Object retWebPart: retWebPartArr) {
				CoviMap callRet  = (CoviMap)retWebPart;
				if (webPartData.getString("WebpartID").equals(callRet.getString("WebpartID"))){
					bFind=true;
					break;
				}
			}
			if (!bFind){
	        	LoggerHelper.errorLogger(new Exception("Webpart ServerLandering Timeout2[Webpart : "+webPartData.getString("WebpartID")+"]"+iTimeout), "Webpart ServerLandering Timeout[Webpart : "+webPartData.getString("WebpartID")+"]", "Timeout");
//	        	webPartData.put("WebpartID", webPartData.getString("WebpartID"));	
//	        	webPartData.put("ExtentionJSON", webPartData.getString("ExtentionJSON"));
				retWebPartArr.add(webPartData);
			}
				
		}
	    
		return retWebPartArr;
		
/*		for (Callable<Object> task : set) {
			CoviMap futureObj = new CoviMap();
			long startTime = System.currentTimeMillis();
			try {
//				System.out.println("start:"+java.time.LocalDateTime.now());
				
				Future<Object> future = ThreadExecutorBean.getInstance().submit(task);
				futureObj = (CoviMap)future.get(iTimeout, java.util.concurrent.TimeUnit.MILLISECONDS);
				//asis 때문
				futureObj.put("webPartID", futureObj.getString("WebpartID"));	
				futureObj.put("jsModuleName", futureObj.getString("JsModuleName"));
				futureObj.put("webpartOrder", futureObj.getString("WebpartOrder"));
				futureObj.put("extentionJSON", futureObj.getString("ExtentionJSON"));
				futureObj.put("displayName", futureObj.getString("DisplayName"));
				
				if(futureObj.getString("WebpartOrder").indexOf('-')>-1 || futureObj.get("data") != null){
					futureObj.put("data", futureObj.getString("data"));
				}
				retWebPartArr.add(futureObj);
		    	long currentTime = System.currentTimeMillis();
		    	long prossTime = currentTime - startTime;
//				System.out.println("end:["+futureObj.getString("WebpartID")+":"+prossTime+"]"+java.time.LocalDateTime.now());
			}catch (java.util.concurrent.TimeoutException e) {
		    	long currentTime = System.currentTimeMillis();
		    	long prossTime = currentTime - startTime;
//				System.out.println("timeout:["+prossTime+"]"+java.time.LocalDateTime.now());
	        	LoggerHelper.errorLogger(new Exception(e), "Webpart ServerLandering Timeout[Webpart]"+ iTimeout+":"+prossTime, "Timeout");
		    }	
		}
		
		//timeout 난  webpart 다시 세팅
		for (final Object webPart: webPartArray) {
			CoviMap webPartData  = (CoviMap)webPart;
			boolean bFind = false;
			for (final Object retWebPart: retWebPartArr) {
				CoviMap callRet  = (CoviMap)retWebPart;
				if (webPartData.getString("WebpartID").equals(callRet.getString("WebpartID"))){
					bFind=true;
					break;
				}
			}
			if (!bFind){
	        	LoggerHelper.errorLogger(new Exception("Webpart ServerLandering Timeout2[Webpart : "+webPartData.getString("WebpartID")+"]"+iTimeout), "Webpart ServerLandering Timeout[Webpart : "+webPartData.getString("WebpartID")+"]", "Timeout");
				retWebPartArr.add(webPartData);
			}
				
		}
*/		
	}
	
	
	
	public CoviList getWebpartQueryData(CoviMap webpart, CoviMap sessionObj) throws Exception{
		CoviList returnWebPartData = new CoviList();
		CoviList dataJson = webpart.getJSONArray("DataJSON");
//		System.out.println("start:"+java.time.LocalDateTime.now()+":"+webpart.get("WebpartID"));
		for(int i = 0 ; i < dataJson.size(); i++){
			try{
				CoviMap oWebpart = dataJson.getJSONObject(i);
				CoviMap param = new CoviMap();
				param.setRequest(webpart.getRequest());
				
				CoviList xmlParamData = oWebpart.getJSONArray("paramData");
				for(int j = 0; j<xmlParamData.size();j++){
					CoviMap obj = xmlParamData.getJSONObject(j);
					String key = obj.getString("key");
					Object value = getXmlParamData(sessionObj, obj.getString("value"), obj.getString("type"));
					
					param.put(key, value);
					if (obj.getString("type").equals("acl") || value != null){
						if(value.toString().indexOf(",") > -1 && value.toString().split(",").length > 1) {
							value = value.toString().substring(1,value.toString().length()-2);
							param.put(key + "Arr", value.toString().split(","));
						}
					}
				}	
				
				CoviList list = null;
				if (oWebpart.get("className") != null){
					try {
						list = new CoviList();
						param.put("userDataObj", sessionObj);	
						param.put("webpart", webpart);	
						String className = oWebpart.getString("className");
						String methodName = oWebpart.getString("methodName");;
						Class<?> c = Class.forName(className);
						Method method = c.getMethod(methodName, CoviMap.class);
						CoviMap map = (CoviMap) method.invoke(c, param);
						if (map.getString("status").equals("FAIL")){
							CoviMap resultMap = new CoviMap();
							resultMap.put("status","FAIL");
							list.add(resultMap);
						}else{
							list.add(map);
						}
					} catch(NoSuchMethodException e1) {	//메소드가 없는 경우  true로
						LOGGER.error(e1.getLocalizedMessage(), e1);
					} catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}else if (oWebpart.get("queryID") != null){
					LOGGER.info("start: "+ oWebpart.getString("queryID"));
					list = coviMapperOne.list(oWebpart.getString("queryID"),param);
					LOGGER.info("end: "+ oWebpart.getString("queryID"));
				}
				returnWebPartData.add(list);
//				returnWebPartData.add(CoviSelectSet.coviSelectJSON(list,oWebpart.getString("resultKey")));
			} catch(NullPointerException e){
				LOGGER.error("PortalSvcImpl", e);
				returnWebPartData.add(new CoviList());
			} catch(Exception e){
				LOGGER.error("PortalSvcImpl", e);
				returnWebPartData.add(new CoviList());
			}
		}
		
		return returnWebPartData;
	}
	
	//xml Parameter 값을 실제 값으로 변경
	private Object getXmlParamData(CoviMap sessionObj, String value, String type ){
		Object result = "";
		try{
			if(value!=null){
				switch (type) {
				case "session":
					result = sessionObj.getString(value);
					break;
				case "fixed":
					result = value;
					break;
				case "config":
					result = RedisDataUtil.getBaseConfig(value, sessionObj.getString("DN_ID"));
					break;
				case "acl":  
//				case "aclArray":  
					/**
					 * ACL 정보를 조회하여 IN 절로 생성
					 * Data Format : ObjectType|aclColName|aclValue 
					 * Ex). FD|View|V
					 */
					String[] aclConf = (value.equals("") ? "FD|View|V|Board".split("[|]") : value.split("[|]") ) ;
					
					String objectType = (aclConf.length > 0 ? aclConf[0] : "FD");
					// String aclColName = (aclConf.length > 1 ? aclConf[1] : "View");
					String aclValue = (aclConf.length > 2 ? aclConf[2] : "V");
					String serviceType = (aclConf.length > 3 ? aclConf[3] : "Board");
					
					Set<String> authorizedObjectCodeSet = ACLHelper.getACL(sessionObj, objectType, serviceType, aclValue);
			
					String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
					if (type.equals("acl") ){
						if(objectArray.length > 0){
							result = "(" + ACLHelper.join(objectArray, ",") + ")";
						}
					}else{
						result = objectArray;
					}
					break;
				case "current":
					result = ComUtils.GetLocalCurrentDate(value, 0, sessionObj.getString("UR_TimeZone"));
					break;
				default:
					result = "";
					break;
				}
			}
		} catch(NullPointerException e){
			LOGGER.error("PortalSvcImpl", e);
			result ="";
		} catch(Exception e){
			LOGGER.error("PortalSvcImpl", e);
			result ="";
		}
		
		return result;
	}

	@Override
	public String getLayoutTemplate(CoviList webPartList, CoviMap params) throws Exception {
		Pattern p = null;
		Matcher m = null;
		
		String portalTag = Objects.toString(coviMapperOne.selectOne("user.portal.selectPortalTag",params), "");
		
		String layoutHTML = new String(Base64.decodeBase64(portalTag), StandardCharsets.UTF_8);
		StringBuilder builder = new StringBuilder(layoutHTML);

		p = Pattern.compile("\\{\\{\\s*doc.layout.div(\\d+)\\s*\\}\\}");
		m = p.matcher(builder.toString());

		StringBuffer layoutResult = new StringBuffer(builder.length());
		
		while(m.find()){ 
			StringBuilder divHtml = new StringBuilder("");
			for(int i = 0;i<webPartList.size();i++){
				CoviMap webpart = webPartList.getJSONObject(i);
				
				if(webpart.getString("LayoutDivNumber").equals(m.group(1))){
					String webpartID = webpart.getString("WebpartID");
					String preview = new String(Base64.decodeBase64(webpart.getString("Preview")), StandardCharsets.UTF_8);
					int minHeight = webpart.getInt("MinHeight");
					//html 링크가 없을 경우만 미리보기로 연결 
					divHtml.append(String.format("<div id=\"WP%s\" data-wepart-id=\"%s\" style=\"min-height:%dpx;\">%s</div>",webpartID, webpartID, minHeight, webpart.getString("HtmlFilePath").equals("")?preview:""));
					
					// 2022.12.20 클라이언트 렌더링으로 웹파트 설정 시 웹파트 html에 center 태그로 감싸는 구문 사용하지 않도록 변경.
//					if(webpart.getString("WebpartOrder").indexOf('-')>-1){ //Server-Rendering
//						divHtml.append(String.format("<div id=\"WP%s\" data-wepart-id=\"%s\" style=\"min-height:%dpx;\">%s</div>",webpartID, webpartID, minHeight, preview));
//					}else{  //Client-Rendering
//						divHtml.append(String.format("<div id=\"WP%s\" style=\"min-height:%dpx;\" ><center>%s</center></div>", webpartID, minHeight, preview));
//					}
				}
				
			}
			m.appendReplacement(layoutResult,divHtml.toString());
		}
		m.appendTail(layoutResult);
		
		return layoutResult.toString();
	}
	
	@Override
	public String getJavascriptString(String lang, CoviList webPartList) throws Exception {
		return getJavascriptString(lang, webPartList, "");
	}
	@Override
	public String getJavascriptString(String lang, CoviList webPartList, String sMethod) throws Exception {
		StringBuilder builder = new StringBuilder();
		CoviList jsFiles = new CoviList();
		String lineSeparator = System.getProperty("line.separator");
		
		for(int i = 0 ; i < webPartList.size(); i++){
			String jsFilePath = webPartList.getJSONObject(i).getString("JsFilePath");
			
			if(jsFilePath==null || jsFilePath.equals("") || jsFiles.indexOf(jsFilePath) > -1){
				continue;
			}
			
			String sCurrentJS = "";
			if (sMethod.equals("FUNC")){
				sCurrentJS = "function "+webPartList.getJSONObject(i).getString("JsModuleName")+"Obj(pData, pExt, pCaller, pWebPartID){\n";
			}
			sCurrentJS += templateFileCacheSvc.readAllText(lang, jsPath+jsFilePath, "UTF8");
			if (sMethod.equals("FUNC")){
				sCurrentJS+= webPartList.getJSONObject(i).getString("ScriptMethod")+"(pData, pExt, pCaller, pWebPartID);\n"+
				"		return "+webPartList.getJSONObject(i).getString("JsModuleName")+";\n"+
				"}\n";
			}	
			builder.append(sCurrentJS+lineSeparator);
			
			jsFiles.add(jsFilePath);
		}
		
		return builder.toString();
	}

	@Override
	public CoviMap getPortalTheme(String portalID) throws Exception {
		CoviMap param = new CoviMap();
		param.put("portalID", portalID);
		
		CoviMap retMap = coviMapperOne.selectOne("user.portal.selectPortalTheme", param);
		
//		retTheme = retMap.getString("ThemeCode")== null? "": retMap.getString("ThemeCode");
		
		return retMap;
	}

	@Override
	public CoviList getWebpartList(CoviMap params) throws Exception {
		CoviList webpartList  = new CoviList();
		CoviList list = coviMapperOne.list("user.portal.selectPortalWebpart", params);
		
		if(! list.isEmpty()){
			webpartList = list;
		}
		
		return webpartList;
	}

	@Override
	public CoviMap getPortalInfo(CoviMap params) throws Exception {
		CoviMap portalObj = new CoviMap();
		CoviMap portalInfo = coviMapperOne.selectOne("user.portal.selectLayoutInfo", params);
		
		if(portalInfo == null){
			portalObj.put("URL", "");
			portalObj.put("IsDefault", "N");
			portalObj.put("LayoutType", "0");
		}else{
			portalObj = CoviSelectSet.coviSelectJSON(portalInfo, "URL,IsDefault,LayoutType,PortalType").getJSONObject(0);
		}

		portalObj.put("PortalID", params.getString("portalID"));
		
		return portalObj;
	}

	@Override
	public String getIncResource(CoviList webpartList) throws Exception {
		StringBuilder incResource = new StringBuilder();
		StringUtil func = new StringUtil();
		
		String lineSeparator = System.getProperty("line.separator");
		
		for(int i = 0 ; i < webpartList.size(); i++){
			String resource = webpartList.getJSONObject(i).getString("Resource");
			
			if(func.f_NullCheck(resource).equals("")){
				continue;
			}
			
			for(String ref : resource.split(";")){
				if(ref.lastIndexOf(".js")==ref.length()-3){
					incResource.append("<script type=\"text/javascript\" src=\""+ ref +"\"></script>");
				}else if(ref.lastIndexOf(".css")==ref.length()-4){
					incResource.append("<link type=\"text/css\" rel=\"stylesheet\" href=\""+ ref +"\"></script>");
				}
			}
		
			incResource.append(lineSeparator);
		}
		
		return incResource.toString();
	}
	
	@Override
	public String setInitPortal(Set<String> authorizedObjectCodeSet, String userID) throws Exception {
		String initPortalID = "0";
		
		//JSONArray aclArray = CoviList.fromObject(RedisDataUtil.getACL(SessionHelper.getSession("USERID"), SessionHelper.getSession("DN_ID")) ); 
		//Set<String> authorizedObjectCodeSet  = ACLHelper.queryObjectFromACL("PT", aclArray, "View", "V");	
		String[] aclPortalArr = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		
		
		if(aclPortalArr.length > 0){
				
			CoviMap params = new CoviMap();
			params.put("aclPortalArr", aclPortalArr);
			
			initPortalID = coviMapperOne.getString("user.portal.selectDefaultInitPortalID", params);
			
			if(!initPortalID.equals("0")){
				params.clear();
				params.put("userCode", userID);
				params.put("initPortalID", initPortalID);
				coviMapperOne.update("user.portal.updateUserInitPortal", params);
			}
		}
		
		return initPortalID;
	}
	
	@Override
	public int updateInitPortal(CoviMap params) throws Exception {
		return (coviMapperOne.update("user.portal.updateUserInitPortal", params));
	}
	// 포탈 로딩 관련 method 끝

	
	
	// 마이컨텐츠 관련 method 시작
	@Override
	public CoviList getMyContentsWebpartList(CoviMap params) throws Exception {
		return coviMapperOne.list("user.portal.selectMyContentsWebpartList", params);
	}
	
	@Override
	public void saveMyContentsSetting(CoviMap params) throws Exception {
		coviMapperOne.delete("user.portal.deleteMyContentsSetting",params);
		if(params.containsKey("webpartArr")){
			coviMapperOne.insert("user.portal.insertMyContentsSetting", params);
		}
		
		int setCnt = (int) coviMapperOne.getNumber("user.portal.selectMyContentsCnt", params);
		
		if(setCnt >=1){
			 coviMapperOne.update("user.portal.updateMyContents", params);
		}else{
			coviMapperOne.insert("user.portal.insertMyContents", params);
		}
	}


	@Override
	public void saveMyContents(CoviMap params) throws Exception {
		if (params.getString("saveMode").equals("D")){
			coviMapperOne.delete("user.portal.deleteMyContentsWebpart",params);
		}else{
			coviMapperOne.insert("user.portal.saveMyContentsWebpart", params);
		}
	}

	//순서변경
	public void saveMyContentsOrder  (CoviMap params) throws Exception {
		coviMapperOne.delete("user.portal.deleteMyContentsWebpart",params);
		
		coviMapperOne.insert("user.portal.saveMyContentsOrder", params);
	}	
		
	//웹파트 순서및 추가 삭제
	public void savePortalWebpart  (CoviMap params) throws Exception {
		if (params.get("portalOption") != null){
			coviMapperOne.insert("pn.portal.saveUserPortalOption", params);
		}
		
		if (params.get("cMode") == null){
			params.put("cMode", "Widget");
			params.put("webpartList",params.get("widgetList"));
			coviMapperOne.delete("user.portal.deleteMyContentsWebpart",params);

			if (((List)params.get("widgetList")).size() > 0){
				coviMapperOne.insert("user.portal.saveMyContentsOrder", params);
			}
			
			if (((List)params.get("contentsList")).size() > 0){
				params.put("cMode", "Contents");
				params.put("webpartList",params.get("contentsList"));
				coviMapperOne.delete("user.portal.deleteMyContentsWebpart",params);
				coviMapperOne.insert("user.portal.saveMyContentsOrder", params);
			}	
		}else{//포탈dml 마이컨텐츠 설정에서 저장 
			params.put("cMode", params.get("cMode"));
			params.put("webpartList",params.get("webpartList"));
			coviMapperOne.delete("user.portal.deleteMyContentsWebpart",params);
			if (((List)params.get("webpartList")).size() > 0){
				coviMapperOne.insert("user.portal.saveMyContentsOrder", params);
			}	
			
		}
	}
	
	@Override
	public void saveMyContentsWebpartColor(CoviMap params) throws Exception {
		coviMapperOne.insert("user.portal.saveMyContentsWebpartColor", params);
	}
	

	@Override
	public void resetPortalOption(CoviMap params) throws Exception {
		coviMapperOne.insert("pn.portal.saveUserPortalOption", params);
		params.put("cMode", "Widget");
		coviMapperOne.insert("user.portal.deleteMyContentsSetting", params);
		params.put("cMode", "Contents");
		coviMapperOne.insert("user.portal.deleteMyContentsSetting", params);
	}
	
	@Override
	public CoviList getMyContentSetWebpartList(CoviMap params) throws Exception {
			
		CoviList webpartList  = new CoviList();
		if (params.get("serviceDevice") != null){	//신포탈 관련
			long webpartCnt = coviMapperOne.getNumber("framework.common.getExistsContentsMyWebpart", params);
			if (webpartCnt == 0) params.put("method","DEF");
			else params.put("method","");
			
			webpartList = coviMapperOne.list("user.portal.selectContentsWebpart", params);
		}
		else{
			int setCnt = (int) coviMapperOne.getNumber("user.portal.selectMyContentsCnt", params);
			CoviList list  = new CoviList();
			
			if(setCnt >=1){
				 list = coviMapperOne.list("user.portal.selectMyContentSetWebpartList", params);
			}else{
				 list = coviMapperOne.list("user.portal.selectMyContentAllWebpartList", params);
			}
			if(! list.isEmpty()){
				webpartList =list;
			}
			
		}	
		
		CoviList retWebPartArr = (CoviList)getWebpartData(webpartList, SessionHelper.getSession());
		//server 랜더링 때문에 정렬 다시ㅣ 하기
		return ComUtils.sortCoviList(retWebPartArr,"SortKey");

	}
	
	@Override
	public CoviList getMyContentWebpartList(CoviMap params) throws Exception {
		CoviList webpartList = coviMapperOne.list("user.portal.selectMyContentWebpartList", params);
		CoviMap sessionObj = SessionHelper.getSession();
		
		for(int i = 0 ; i < webpartList.size(); i++){
			String viewHtml = ""; 
			CoviMap webpartObj = webpartList.getJSONObject(i);
			
			if(webpartObj.has("HtmlFilePath") && (!webpartObj.getString("HtmlFilePath").equals("")) ){
	    		viewHtml = new String(Base64.encodeBase64(templateFileCacheSvc.readAllText(sessionObj.getString("lang"),htmlPath+webpartObj.getString("HtmlFilePath"), "UTF8").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
	    	}
        	String initMethod = new String(Base64.encodeBase64(webpartObj.getString("ScriptMethod").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
/*
        	webpartList.getJSONObject(i).put("extentionJSON", webpartObj.getString("ExtentionJSON"));
			webpartList.getJSONObject(i).put("viewHtml", viewHtml);
			webpartList.getJSONObject(i).put("initMethod", initMethod);
			webpartList.getJSONObject(i).put("preview", webpartObj.getString("Preview"));
*/
			webpartList = (CoviList)getWebpartData(webpartList, SessionHelper.getSession());
			//server 랜더링 때문에 정렬 다시ㅣ 하기
//			return ComUtils.sortCoviList(retWebPartArr,"SortKey");

		}
		
		return webpartList;
		
	}

	// 마이컨텐츠 관련 method 끝
	
	@Override
	public CoviMap getEmployeesNoticeList(CoviMap params) throws Exception {
		CoviMap retrunList  = new CoviMap();
		CoviList resultList  = new CoviList();
		CoviMap sessionObj = SessionHelper.getSession();
		params.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat, 0, sessionObj.getString("UR_TimeZone"))); //timezone 적용 현재시간(now() 사용하지 못해 추가)
		
		int setCnt = 0;
		CoviMap employrs = coviMapperOne.selectOne("webpart.board.selectEmployeesNoticeCount",params);
		if(!"".equals(employrs.get("Cnt").toString())) setCnt = Integer.parseInt(employrs.get("Cnt").toString());
				
		CoviList list  = new CoviList();
		list = coviMapperOne.list("webpart.board.selectEmployeesNotice", params);		
		resultList = CoviSelectSet.coviSelectJSON(list, "UserName,JobLevelName,JobTitleName,JobPositionName,MailAddress,PhotoPath,UserCode,Type,DateDiv,Date,offFlag");
		
		retrunList.put("list", resultList);
		retrunList.put("Count", setCnt);
		
		return retrunList;
		
	}
	
	@Override
	public CoviMap exchFileList(CoviMap params) throws Exception {
		CoviMap retrunList  = new CoviMap();
		CoviList resultList  = new CoviList();
		
		CoviList list  = new CoviList();
		list = coviMapperOne.list("webpart.board.selectExchFile", params);		
		resultList = CoviSelectSet.coviSelectJSON(list, "FileID,SaveType,FileName,SavedName,ServiceType,FilePath,Extention");
		
		retrunList.put("list", resultList);
		
		return retrunList;
	}
	
	@Override
	public CoviMap updateWebpartExtjson(CoviMap params) throws Exception {
		CoviMap returnMap  = new CoviMap();
		coviMapperOne.update("user.portal.updateWebpartExtJson", params);
		return returnMap;
	}
	
	@Override
	public CoviMap selectWebpartSettingKey(CoviMap params) throws Exception {
		CoviMap returnMap  = new CoviMap();
		return coviMapperOne.selectOne("user.portal.selectWebpartSettingKey", params);
	}

	@Override
	public void updateWebpartSettingKey(CoviMap params) throws Exception {
		CoviMap returnMap  = new CoviMap();
		coviMapperOne.update("user.portal.updateWebpartSettingKey", params);
	}
	
	@Override
	public CoviList selectBoardFolderByType(CoviMap params) throws Exception {
		CoviList list  = new CoviList();
		CoviList resultList  = new CoviList();
		
		list = coviMapperOne.list("user.portal.selectBoardFolderByType", params);		
		resultList = CoviSelectSet.coviSelectJSON(list, "FolderID,DisplayName");
				
		return resultList;
	}

}
