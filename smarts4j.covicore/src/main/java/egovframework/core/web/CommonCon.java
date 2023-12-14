package egovframework.core.web;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.core.common.enums.SyncObjectType;
import egovframework.core.sevice.LocalBaseSyncSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.s3.AwsS3;

import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.LocalStorageSyncSvc;
import egovframework.core.sso.oauth.RequestAuthVO;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
/**
 * @Class Name : CommonCon.java
 * @Description : 공통컨트롤러
 * @Modification Information 
 * @ 2016.05.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 05.20
 * @version 1.0
 * @see Copyright(C) by Covision All right reserved.
 */
@Controller
public class CommonCon {

	private Logger LOGGER = LogManager.getLogger(CommonCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	private LocalStorageSyncSvc syncSvc;

    @Autowired
    private LocalBaseSyncSvc syncBase;
    
	@Autowired
	private AuthorityService authSvc;    
	
	//공통처리 시작
	//세션 조회
	@RequestMapping(value="common/getSession.do")
	public @ResponseBody CoviMap getSession(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		StringUtil func = new StringUtil();
		try {
			String strKey = "";
			CoviMap obj = new CoviMap();
			
			/*if(request.getParameter("key") != null && !request.getParameter("key").equals("")){*/
				strKey = request.getParameter("key");
			/*} */
			
			if(func.f_NullCheck(strKey).equals("")){
				obj = SessionHelper.getSession();
			} else {
				obj.put(strKey, func.f_NullCheck(SessionHelper.getSession(strKey)));
			}
			
			returnList.put("resultList", obj);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} 
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//baseconfig 값 조회
	@RequestMapping(value = "common/getbaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseConfig(HttpServletRequest request, 
			@RequestParam(value = "dn_id", required = false) String pDomainID,
			@RequestParam(value = "key", required = true, defaultValue = "") String pKey) throws Exception{
		CoviMap returnList = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			if(func.f_NullCheck(pDomainID).equals("")){
				pDomainID = SessionHelper.getSession("DN_ID");
			}
			
			returnList.put("value", RedisDataUtil.getBaseConfig(pKey, pDomainID));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * @param request
	 * @param pDomainID
	 * @param pConfigMap
	 * @return
	 * @throws Exception
	 * @description 기초코드 일괄 조회용 
	 */
	@RequestMapping(value = "common/getBaseConfigList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseConfigList(HttpServletRequest request,
			@RequestParam(value = "dn_id", required = false) String pDomainID,
			@RequestParam(value = "configArray", required = true, defaultValue = "[]") String pConfigArray
			) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap configMap = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			
			if(func.f_NullCheck(pDomainID).equals("")){
				pDomainID = SessionHelper.getSession("DN_ID");
			}
			
			CoviList dicArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(pConfigArray, "utf-8"));	//(JSON Array) 기초설정 key parameter 
			for(int i = 0; i < dicArray.size(); i++){
				String keys = dicArray.getString(i);
				configMap.put(keys, RedisDataUtil.getBaseConfig(keys, pDomainID));		//(CoviMap) {설정키1: 설정값1, 설정키2: 설정2, 설정키3: 설정3, ...} 
			}
			
			returnList.put("configMap", configMap);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} 
		catch(UnsupportedEncodingException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//basecode 값 조회
	@RequestMapping(value = "common/getbasecode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseConfig(HttpServletRequest request, 
			@RequestParam(value = "key", required = true, defaultValue = "") String pKey) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap baseCodeObj= new CoviMap();
			
//			baseCodeObj.put("CacheData",RedisDataUtil.getBaseCode(pKey));
			baseCodeObj.put("CacheData",syncBase.getBaseCode(pKey));
			
			returnList.put("value",baseCodeObj);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @param pCodeMap
	 * @return
	 * @throws Exception
	 * @description 기초코드 일괄 조회용 
	 */
	@RequestMapping(value = "common/getBaseCodeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCodeList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap codeMap = new CoviMap();
		try {
			
			CoviList dicArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(request.getParameter("codeGroupArray"), "utf-8"));	//(JSON Array) 기초코드key parameter 
			for(int i = 0; i < dicArray.size(); i++){
				String keys = dicArray.getString(i);
				//codeMap.put(keys, RedisDataUtil.getBaseCode(keys));		//(CoviMap) 
				codeMap.put(keys, syncBase.getBaseCode(keys));		//(CoviMap) 
			}
			
			returnList.put("codeMap", codeMap);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	//다국어 데이터 조회
	@RequestMapping(value = "common/getdicall.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDicAll(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			String keys = StringUtil.replaceNull(request.getParameter("keys"), "");
			String locale = (request.getParameter("locale") == null || request.getParameter("locale").equals("")) ? LocaleContextHolder.getLocale().getLanguage() : request.getParameter("locale");
			boolean dicType = Boolean.valueOf(request.getParameter("dicType"));
			
			if(StringUtil.replaceNull(keys).indexOf(";") > -1){
				returnList.put("list", DicHelper.getDicAll(keys, dicType, locale));
			}else{
				returnList.put("list", DicHelper.getDic(keys, dicType, locale));
			}
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 다국어 일괄 조회용 
	 */
	@RequestMapping(value = "common/getDicList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDicList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap dicMap = new CoviMap();
		try {
			String locale = (request.getParameter("locale") == null || request.getParameter("locale").equals("")) ? LocaleContextHolder.getLocale().getLanguage() : request.getParameter("locale");
			boolean dicType = Boolean.valueOf(request.getParameter("dicType"));
			
			CoviList dicArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(request.getParameter("dicArray"), "utf-8"));	//(JSON Array) 다국어 key parameter 
			for(int i = 0; i < dicArray.size(); i++){
				String keys = dicArray.getString(i);
				dicMap.put(keys, DicHelper.getDic(keys, dicType, locale));		//(CoviMap) {다국어키1: 다국어1, 다국어키2: 다국어2, 다국어키3: 다국어3, ...} 
			}
			
			returnList.put("dicMap", dicMap);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * Local Storage 다국어 데이터 동기화
	 * @param request
	 * @return JSONArray
	 * @throws Exception
	 * @author dyjo
	 * @since 2019.04.16
	 */
	@RequestMapping(value = "common/syncStorage.do", method=RequestMethod.POST)
	@ResponseBody
	public CoviMap syncStorage(@RequestBody CoviMap params, HttpServletRequest request) throws Exception {
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		CoviMap syncTarget = syncSvc.getSyncTargetList(params, userDataObj);
		return syncTarget;
	}

    /**
     * Local Stroage 기초 설정 및 기초 코드 동기화
	 *
	 * @since 2019. 04. 23
	 * @author 지윤성
     * @param params 요청 데이터
     * @return 기초 설정 및 기초 코드 데이터
     * @throws Exception 예외
     */
    @RequestMapping(value = "common/syncBaseCfNCd.do", method=RequestMethod.POST)
    public @ResponseBody CoviMap syncBaseCfNCd(@RequestBody CoviMap params) throws Exception {
//		CoviMap syncTarget = syncBase.getSyncTargetList( SyncObjectType.BASE_CONFIG, params );
//    	CoviMap syncTarget = syncSvc.getSyncTargetList(params);
        return syncBase.getSyncTargetList( SyncObjectType.BASE_CONFIG, params );
    }
	
	//helper -> common으로 변경할 것
	@RequestMapping(value = "/helper/getglobalproperties.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGlobalProperties(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String key = StringUtil.replaceNull(request.getParameter("key"));
			String value = PropertiesUtil.getGlobalProperties().getProperty(key);
			
			returnList.put("value", value);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}

	@RequestMapping(value = "/helper/getS3properties.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getS3Properties(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			String key = StringUtil.replaceNull(request.getParameter("key"));
			String value = AwsS3.getInstance().getS3Properties().getProperty(key);

			returnList.put("value", value);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}

		return returnList;
	}
	
	//helper -> common으로 변경할 것
	@RequestMapping(value = "/helper/getsecurityproperties.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSecurityProperties(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String key = StringUtil.replaceNull(request.getParameter("key"));
			String value = PropertiesUtil.getSecurityProperties().getProperty(key);
			
			returnList.put("value", value);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}
	
	//helper -> common으로 변경할 것
	@RequestMapping(value = "/helper/getextensionproperties.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getExtensionProperties(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String key = StringUtil.replaceNull(request.getParameter("key"));
			String value = PropertiesUtil.getExtensionProperties().getProperty(key);
			
			returnList.put("value", value);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}
	
	//google
	@RequestMapping(value = "/oauth2callback.do", method = RequestMethod.GET)
	public ModelAndView oAuth2Callback(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.info(request.getQueryString());
		//계정 쪽에 token을 저장하는 처리가 필요한 부분
		return new ModelAndView("core");
	}
	
	@RequestMapping(value = "/helper/agentFilterGetData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap agentFilterGetData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		StringUtil func = new StringUtil();
		
		String value = "";
		try {
			String key = request.getParameter("key");
			String pType = request.getParameter("pType");
			
			if(func.f_NullCheck(pType).equals("P")){
				if(ClientInfoHelper.isMobile(request)){
					value = PropertiesUtil.getGlobalProperties().getProperty("mobile."+key);
				}else{
					value = PropertiesUtil.getGlobalProperties().getProperty(key);
				}
				
				returnList.put("status", Return.SUCCESS);
			}else{
				returnList.put("status", Return.FAIL);
			}
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}		
		
		returnList.put("value", value);
		return returnList;
	}
	
	@RequestMapping(value = "/coviException.do")
	public ModelAndView coviException(HttpServletRequest request){
		
		ModelAndView mav = new ModelAndView();
		String returnURL = "coviException";
		mav.addObject("exceptionType", StringUtil.replaceNull(request.getParameter("exceptionType"), ""));
		mav.setViewName(returnURL);
		
		return mav;
	}
	

	private String makePrefix(String systemName, String mode, String bizSection){
		String prefix = "";
		if(StringUtils.isNoneBlank(systemName)){
			String capSysName = systemName.substring(0, 1).toUpperCase() + systemName.substring(1);
			if(systemName.equalsIgnoreCase("core")){
				if(!bizSection.equalsIgnoreCase("organization")){
					prefix = capSysName;
				} else{
					String capsBiz = bizSection.substring(0, 1).toUpperCase() + bizSection.substring(1);
					prefix = capSysName + capsBiz;
				}
			} else {
				if(StringUtils.isNoneBlank(mode)){
					String capMode = mode.substring(0, 1).toUpperCase() + mode.substring(1);
					prefix = capSysName + capMode;	
				}
			}	
		}
		return prefix;
	}
	
	private Map<String, String> splitQuery(String url) throws UnsupportedEncodingException {
	    Map<String, String> query_pairs = new LinkedHashMap<String, String>();
	    if (url != null) {
		    String[] pairs = url.split("&");
		    for (String pair : pairs) {
		        int idx = pair.indexOf("=");
		        if (idx > -1) query_pairs.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"), URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
		    }
	    }    
	    return query_pairs;
	}
	
	@RequestMapping(value = "common/jwtToken.do")
	public @ResponseBody CoviMap jwtToken(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		// 토큰 발급 서비스 사용을 위한 param
		CoviMap param = new CoviMap();
		
		// 토큰 발급 데이터 세팅 ID, Mail, 사번
		String userID = SessionHelper.getSession("USERID");
		String LogonID = SessionHelper.getSession("LogonID");
		String UserCode = SessionHelper.getSession("UR_Code");
		String isAdmin = SessionHelper.getSession("isAdmin");
		String newPass = "";
		
		// param 세팅
		param.put("userID", userID);
		param.put("LogonID", LogonID);
		param.put("UserCode", UserCode);
		param.put("isAdmin", isAdmin);
		param.put("newPass", newPass);

		String jwtString = ComUtils.jwtToken(param);
		
		returnList.put("JWTtoken", jwtString);

		return returnList;
	}
}
