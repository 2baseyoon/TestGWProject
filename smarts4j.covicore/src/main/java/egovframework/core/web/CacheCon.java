package egovframework.core.web;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;








import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mortbay.log.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.core.sevice.LoginSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : CacheCon.java
 * @Description : 캐쉬 제어 컨트롤러
 * @Modification Information 
 * @ 2017.07.24 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CacheCon {

	private Logger LOGGER = LogManager.getLogger(CacheCon.class);
	
	@Autowired
	private LoginSvc loginsvc;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//사용자 캐쉬 삭제
	@RequestMapping(value = "cache/clearUserCache.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap userCacheDelete(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
			
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String usrId = SessionHelper.getSession("USERID");
			String usrBgID = SessionHelper.getSession("URBG_ID");
			String domainID = SessionHelper.getSession("DN_ID");
			
			if(StringUtils.isNoneBlank(usrId) && StringUtils.isNoneBlank(domainID)){
				//권한 삭제
				instance.remove(RedisDataUtil.PRE_H_ACL + domainID + "_" + usrId + "_" + usrBgID);
				//메뉴 삭제
				instance.remove(RedisDataUtil.PRE_MENU + domainID + "_" + usrId + "_" + usrBgID);
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//관리자 메뉴 Redis Cache Delete
	@RequestMapping(value = "cache/remove.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap redisCacheDelete(HttpServletRequest request,
			@RequestParam(value = "replicationFlag", required = false, defaultValue = "N") String pFlag,
			@RequestParam(value = "cacheType", required = true, defaultValue = "") String pCacheType,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID,
			@RequestParam(value = "codeGroup", required = true, defaultValue = "") String pCodeGroup,
			@RequestParam(value = "code", required = true, defaultValue = "") String pCode) throws Exception
	{
		CoviMap returnList = new CoviMap();
			
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String key = "";
			switch(pCacheType){
				case "DIC":
					key = RedisDataUtil.PRE_DICTIONARY + pDomainID + "_" + pCode;
					instance.remove(key);
					break;
				case "BASECONFIG":
					key = RedisDataUtil.PRE_BASECONFIG + pDomainID + "_" + pCode;
					instance.remove(key);
					break;
				case "BASECODE":
					key = RedisDataUtil.PRE_BASECODE + pDomainID + "_" + pCodeGroup + "_" + pCode;
					instance.remove(key);
					break;
				case "FORM":
					key = "*_formTemplate"+ pDomainID +"_" + pCode;
					instance.removeAll("formTemplate", key); //다국어 별 해당 양식 데이터 삭제
					break;
				case "PORTAL":
					key = "*_portal_" + pCode;
					instance.removeAll("PORTAL", key); //다국어 별 해당 양식 데이터 삭제
					break;
				case "SESSION":
					key = pCode;
					instance.remove(key);
					break;
				case "ACL":
					key = RedisDataUtil.PRE_ACL + pDomainID + "_" + pCode + "_*";
					instance.removeAll(pDomainID, key);
					break;
				case "MENU":
					String refreshSyncKey = RedisDataUtil.refreshACLSyncKey(pDomainID, "MN");
					key = RedisDataUtil.PRE_MENU + pDomainID + "_" + pCode;
					instance.removeAll(pDomainID, key);
					break;
				case "MENU_E":
					key = RedisDataUtil.PRE_MENU_E + pDomainID + "_" + pCode;
					instance.remove(key);
					break;
				case "AUTH":
					key = RedisDataUtil.PRE_AUTH_MENU +pCode ;
					instance.remove(key);
					break;
				case "MAILAUTH":
					key = "mailauth_" + pDomainID + "_" +pCode;
					instance.removeAll("mailauth", key); //메일 조회권한 설정
					break;
				default :
					break;
			}
			
			//레디스 이중화 여부 및 이중화 대상이 되는 서버에만 호출되고 작업이 종료되도록 분기 
			if("Y".equals(pFlag)){
				HttpClientUtil httpClient = new HttpClientUtil();
				NameValuePair[] data = {
					    new NameValuePair("cacheType", pCacheType),
					    new NameValuePair("domainID", pDomainID),
					    new NameValuePair("codeGroup", pCodeGroup),
					    new NameValuePair("code", pCode),
			    };
				
				//Apache를 대상으로 요청하면 특정 서버를 대상으로 요청할 수 없으므로 Tomcat port포함하여 요청
				String url = String.format("http://%s/covicore/cache/remove.do",PropertiesUtil.getDBProperties().getProperty("db.redis.replicationServer"));
				httpClient.httpClientConnect(url, "furl", "POST", data, 4);
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		} 
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//관리자 메뉴 Redis Cache Delete all
	@RequestMapping(value = "cache/removeAll.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap redisCacheDeleteAll(HttpServletRequest request,
			@RequestParam(value = "replicationFlag", required = false, defaultValue = "N") String pFlag,
			@RequestParam(value = "cacheType", required = true, defaultValue = "") String pCacheType,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID,
			@RequestParam(value = "codeGroup", required = true, defaultValue = "") String pCodeGroup) throws Exception
	{
		CoviMap returnList = new CoviMap();
			
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String keyPattern = "";
			CoviList langCode = RedisDataUtil.getBaseCode("LanguageCode");
			switch(pCacheType){
				case "DIC":
					keyPattern = RedisDataUtil.PRE_DICTIONARY + pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					break;
				case "BASECONFIG":
					keyPattern = RedisDataUtil.PRE_BASECONFIG + pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					break;
				case "BASECODE":
					keyPattern = RedisDataUtil.PRE_BASECODE + pDomainID +"_"+ pCodeGroup + "_*";
					instance.removeAll(pCodeGroup, keyPattern);
					break;
				case "FORM":
					keyPattern = "formTemplate"+ pDomainID +"_*";
					if(StringUtil.isEmpty(pDomainID)) {
						keyPattern = "formTemplate*";
					}
					for (int i=0; i <langCode.size(); i++){
						String langStr = ((CoviMap)langCode.getMap(i)).getString("Code");
						instance.removeAll("formTemplate", langStr+"_"+keyPattern); //다국어 별 해당 양식 데이터 삭제
					}	
//					instance.removeAll("formTemplate", keyPattern);
					break;
				case "PORTAL":
					keyPattern = "portal_*";
					for (int i=0; i <langCode.size(); i++){
						String langStr = ((CoviMap)langCode.getMap(i)).getString("Code");
						instance.removeAll("PORTAL", langStr+"_"+keyPattern); //다국어 별 해당 양식 데이터 삭제
					}	
//					instance.removeAll("PORTAL", keyPattern);
					break;
				case "ACL":
					keyPattern = RedisDataUtil.PRE_ACL + pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					break;
				case "MENU":
					String refreshSyncKey = RedisDataUtil.refreshACLSyncKey(pDomainID, "MN");
					keyPattern = RedisDataUtil.PRE_MENU + pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					break;
				case "MENU_E":
					keyPattern = RedisDataUtil.PRE_MENU_E + pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					break;
				case "MAILAUTH":
					keyPattern = "mailauth_*";
					instance.removeAll("mailauth", keyPattern); //메일 조회권한 설정
					break;
				default :
					break;
			}
			
			//레디스 이중화 여부 및 이중화 대상이 되는 서버에만 호출되고 작업이 종료되도록 분기 
			if("Y".equals(pFlag)){
				HttpClientUtil httpClient = new HttpClientUtil();
				CoviMap resultDataList = new CoviMap();
				NameValuePair[] data = {
					    new NameValuePair("cacheType", pCacheType),
					    new NameValuePair("domainID", pDomainID),
					    new NameValuePair("codeGroup", pCodeGroup)
			    };
				
				//Apache를 대상으로 요청하면 특정 서버를 대상으로 요청할 수 없으므로 Tomcat port포함하여 요청
				String url = String.format("http://%s/covicore/cache/removeAll.do",PropertiesUtil.getDBProperties().getProperty("db.redis.replicationServer"));
				httpClient.httpClientConnect(url, "furl", "POST", data, 3);
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//관리자 메뉴 Redis Cache Reload
	@RequestMapping(value = "cache/reloadCache.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap redisCacheReload(HttpServletRequest request,
			@RequestParam(value = "replicationFlag", required = false, defaultValue = "N") String pFlag,
			@RequestParam(value = "domainId", required = true, defaultValue = "") String domainId,
			@RequestParam(value = "cacheType", required = true, defaultValue = "")	String pCacheType) throws Exception{
		
		CoviMap returnList = new CoviMap();
			
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			List<?> diclist;
			List<?> baseConfigList;
			List<?> baseCodelist;
			List<?> authMenu; 
			List<?> auditUrl; 
			Log.info("#################pCacheType :::::"+pCacheType);
			CoviMap param = new CoviMap();
			param.put("domainId",domainId);
			String isAuditUrl = PropertiesUtil.getSecurityProperties().getProperty("audit.url.used");
			switch(pCacheType){
				case "DIC":
					instance.removeAll(domainId, RedisDataUtil.PRE_DICTIONARY + (domainId.equals("")?"":domainId + "_")+"*");
					
					diclist = cacheLoadSvc.selectDic(param);
					instance.saveList(diclist, RedisDataUtil.PRE_DICTIONARY, "_", "DomainID", "DicCode");
					LOGGER.debug("dic is cached.");
					instance.save(RedisDataUtil.PRE_DICTIONARY + "SYNC_KEY", UUID.randomUUID().toString());
					break;
				case "BASECONFIG":
					instance.removeAll(domainId, RedisDataUtil.PRE_BASECONFIG + (domainId.equals("")?"":domainId + "_")+"*");
					//key = RedisDataUtil.PRE_BASECONFIG + pDomainID + "_" + pCode;
					baseConfigList = cacheLoadSvc.selectBaseConfig(param);
					instance.saveList(baseConfigList, RedisDataUtil.PRE_BASECONFIG, "_", "DomainID", "SettingKey");
					LOGGER.debug("baseconfig is cached.");
					instance.save(RedisDataUtil.PRE_BASECONFIG + "SYNC_KEY", UUID.randomUUID().toString());
					break;
				case "BASECODE":
					instance.removeAll(domainId, RedisDataUtil.PRE_BASECODE + (domainId.equals("")?"":domainId + "_")+ "*");
					//key = RedisDataUtil.PRE_BASECODE + pCodeGroup + "_" + pCode;
					baseCodelist = cacheLoadSvc.selectBaseCode(param);
					instance.saveList(baseCodelist, RedisDataUtil.PRE_BASECODE,  "_", "DomainID", "CodeGroup", "Code");
					LOGGER.debug("basecode is cached.");
					break;
				case "AUTH":
					instance.removeAll(RedisDataUtil.PRE_AUTH_MENU+"*");
					authMenu = cacheLoadSvc.selectAuthMenu();
					instance.saveList(authMenu,RedisDataUtil.PRE_AUTH_MENU,  "_", "UrlKey", "MenuID");
					LOGGER.info("Redis 권한 메뉴를  삭제 후 재 캐쉬하였습니다.");
					break;
				case "AUDIT":
					instance.removeAll(RedisDataUtil.PRE_AUDIT_URL+"*");
					if(isAuditUrl != null && "Y".equals(isAuditUrl)) {
						auditUrl = cacheLoadSvc.selectAuditUrl();
						instance.saveList(auditUrl,RedisDataUtil.PRE_AUDIT_URL,  "Url");
					}
					LOGGER.info("Redis 권한 url를  삭제 후 재 캐쉬하였습니다.");
					break;
				case "ALL":
					instance.flushAll();
					
					diclist = cacheLoadSvc.selectDic(null);
					instance.saveList(diclist, RedisDataUtil.PRE_DICTIONARY, "_", "DomainID", "DicCode");
					instance.save(RedisDataUtil.PRE_DICTIONARY + "SYNC_KEY", UUID.randomUUID().toString());
					
					//reloadCache
					
					LOGGER.debug("dic is cached.");
					
					//base_config 캐쉬등록
					//select dnid, key, value
					baseConfigList = cacheLoadSvc.selectBaseConfig(null);
					instance.saveList(baseConfigList, RedisDataUtil.PRE_BASECONFIG, "_", "DomainID", "SettingKey");
					instance.save(RedisDataUtil.PRE_BASECONFIG + "SYNC_KEY", UUID.randomUUID().toString());
					LOGGER.debug("baseconfig is cached.");
								
					//base_code 캐쉬등록
					baseCodelist = cacheLoadSvc.selectBaseCode(null);
					instance.saveList(baseCodelist, RedisDataUtil.PRE_BASECODE,  "_", "DomainID", "CodeGroup", "Code");
					LOGGER.debug("basecode is cached.");
					
					//권한 메뉴 캐슁
					authMenu = cacheLoadSvc.selectAuthMenu();
					instance.saveList(authMenu,RedisDataUtil.PRE_AUTH_MENU,  "_", "UrlKey", "MenuID");
					LOGGER.info("Redis 권한 메뉴를  삭제 후 재 캐쉬하였습니다.");

					if (isAuditUrl!=null && isAuditUrl.equals("Y")){
						//권한 url 캐슁
						auditUrl = cacheLoadSvc.selectAuditUrl();
						instance.saveList(auditUrl,RedisDataUtil.PRE_AUDIT_URL,  "Url");
						LOGGER.info("Redis 권한 메뉴를  삭제 후 재 캐쉬하였습니다.");
					}		

					// auth sync 대상 syncKey 등록
					Map<String, String> aclSyncMap = cacheLoadSvc.selectSyncType();
					CoviList domainList = cacheLoadSvc.selectDomain(null);
					for(int i = 0; i < domainList.size(); i++) {
						CoviMap domainInfo = domainList.getMap(i);
						instance.hmset(RedisDataUtil.PRE_H_ACL + domainInfo.getString("DomainID") + "_SYNC_MAP", aclSyncMap);
					}
					
					LOGGER.debug("aclSyncMap is cached.");
					
					break;
				default :
					break;
			}
			
			//레디스 이중화 여부 및 이중화 대상이 되는 서버에만 호출되고 작업이 종료되도록 분기 
			if("Y".equals(pFlag)){
				HttpClientUtil httpClient = new HttpClientUtil();
				NameValuePair[] data = {
					    new NameValuePair("cacheType", pCacheType)
			    };
				
				//Apache를 대상으로 요청하면 특정 서버를 대상으로 요청할 수 없으므로 Tomcat port포함하여 요청
				String url = String.format("http://%s/covicore/cache/reloadCache.do",PropertiesUtil.getDBProperties().getProperty("db.redis.replicationServer"));
				httpClient.httpClientConnect(url, "furl", "POST", data, 1);
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		} 
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//관리자 메뉴 Redis Cache get
	@RequestMapping(value = "cache/get.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap redisCacheGet(HttpServletRequest request,
			@RequestParam(value = "cacheType", required = true, defaultValue = "") String pCacheType,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String pDomainID,
			@RequestParam(value = "codeGroup", required = true, defaultValue = "") String pCodeGroup,
			@RequestParam(value = "code", required = true, defaultValue = "") String pCode) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String key = "";
			switch(pCacheType){
				case "DIC":
					key = RedisDataUtil.PRE_DICTIONARY + pDomainID + "_" + pCode;
					break;
				case "BASECONFIG":
					key = RedisDataUtil.PRE_BASECONFIG + pDomainID + "_" + pCode;
					break;
				case "BASECODE":
					key = RedisDataUtil.PRE_BASECODE + pDomainID+ "_" + pCodeGroup + "_" + pCode;
					break;
				case "FORM":
					key = "ko_formTemplate_" + pCode;
					break;
				case "PORTAL":
					key = "ko_portal_" + pCode;
					break;
				case "SESSION":
					key = pCode;
					break;
				case "MENU"://사용자 메뉴
					key = RedisDataUtil.PRE_MENU + pDomainID + "_" + pCode;
					break;
				case "AUTH"://권한 인증
					key = RedisDataUtil.PRE_AUTH_MENU+ pCode;
					break;
				case "AUDIT"://url 인증
					key = RedisDataUtil.PRE_AUDIT_URL+ pCode;
					break;
				case "MAILAUTH":
					key = "mailauth_" + pDomainID + "_" + pCode;
					break;
					
/*				case "ACL":
					key = RedisDataUtil.PRE_ACL + pDomainID + "_" + pCode + "_*";
					break;
				case "MENU_E":
					key = RedisDataUtil.PRE_MENU_E + pDomainID + "_" + pCode;
					break;*/
				default :
					break;
			}
			
			Object redisVal = instance.get(key);
			if (redisVal != null){
				returnList.put("data",redisVal);
			}	
			else{
				Set<String> names = instance.keys(pCode, key+ "_*");
				Iterator<String> it = names.iterator();
				if (it.hasNext()) {
					returnList.put("data",instance.get(it.next()));
				}	
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
		
}
