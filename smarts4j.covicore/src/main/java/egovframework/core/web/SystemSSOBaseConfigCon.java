package egovframework.core.web;

import java.util.Enumeration;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.SystemSsoBaseConfigSvc;
import egovframework.core.sso.oauth.OAuth2Util;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : SystemSSOBaseConfigCon.java
 * @Description : 시스템 - Single Sign-on 관리
 * @Modification Information 
 * @ 2017.07.13 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.07.13
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class SystemSSOBaseConfigCon {

	private Logger LOGGER = LogManager.getLogger(SystemSSOBaseConfigCon.class);
	
	@Autowired
	private SystemSsoBaseConfigSvc sysSsoBaseConfigSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getDataSSOBaseConfig : 시스템 관리 - Single Sign-on 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "layout/getdatassobaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDataSSOBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String domain = request.getParameter("domain");
			String worktype = request.getParameter("worktype");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			String ssotype = request.getParameter("ssotype");
			String domainID = SessionHelper.getSession("DN_ID");
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("domain", domain);
			params.put("worktype", worktype);
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			params.put("ssotype",ssotype);
			params.put("domainID",domainID);
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}		
			
			resultList = sysSsoBaseConfigSvc.select(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * updateIsussedSSOBaseConfig : Single Sign-on 관리에서  사용여부 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "layout/updateisussedssobaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsussedSSOBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			SessionHelper.setExpireTime();
			String dic_id = request.getParameter("DIC_ID");
			String isUse = request.getParameter("IsUse");
			String modId = SessionHelper.getSession("USERID");
			String domainID = SessionHelper.getSession("DN_ID");
			
			CoviMap params = new CoviMap();
			
			//날짜의 경우 timezone 적용 할 것
			params.put("DIC_ID", dic_id);
			params.put("IsUse", isUse);
			params.put("ModID", modId);
			params.put("Code", request.getParameter("Code"));
			params.put("DomainID", domainID);
			
			returnList.put("object", sysSsoBaseConfigSvc.updateIsUse(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * selectOneSSOBaseConfig : Single Sign-on 관리에서  하나의 데이터 셀렉트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "layout/selectonessobaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectOneSSOBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{

		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			StringUtil func = new StringUtil();
			CoviMap params = new CoviMap();
			
			String type = request.getParameter("type");
			String domainID = SessionHelper.getSession("DN_ID");
			
			params.put("SsoAuthType", type);
			params.put("DomainID", domainID);
			
			resultList = sysSsoBaseConfigSvc.selectList(params);
			
			returnList.put("list", resultList.get("list"));
			
			SessionHelper.setExpireTime();
			
			String usrId = SessionHelper.getSession("USERID");
			
			if(!func.f_NullCheck(usrId).equals("")){
				CoviMap clientList = new CoviMap();
				resultList = sysSsoBaseConfigSvc.selectClientList(usrId);
				clientList = (CoviMap) resultList.get("list");
				returnList.put("clientid", clientList.get("client_id"));
				returnList.put("clientsecret", clientList.get("client_secret"));
				returnList.put("clientname", clientList.get("client_name"));
				returnList.put("redirectUri", clientList.get("redirect_uri"));
			}
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/**
	 * updateSSOBaseConfig : Single Sign-on 관리 설정 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "layout/updatessobaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateSSOBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String server = request.getParameter("Server");
			String path = request.getParameter("Path");
			String day = request.getParameter("Day");
			
			if(!ssoUpdate("sso_server",server)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_storage_path",path)){
						
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
						
				return returnList;
			}
			
			if(!ssoUpdate("sso_expiration_day",day)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "layout/updatesamlbaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateSAMLBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			String url = request.getParameter("Url");
			String acsUrl = request.getParameter("AcsURL");
			String rsUrl = request.getParameter("RsURL"); 
			
			
			if(!ssoUpdate("sso_sp_url",url)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_spacs_url",acsUrl)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_rs_url",rsUrl)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "layout/updateoauthbaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateOAuthBaseConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			String clientId = request.getParameter("clientId");
			String clientKey = request.getParameter("clientKey");
			String authorizeUrl = request.getParameter("authorizeUrl");
			String responseType = request.getParameter("responseType");
			String redirectUrl = request.getParameter("redirectUrl");
			String clientName = request.getParameter("clientName");
			String redirectGoogleUrl = request.getParameter("redirectGoogleUrl");
			
			if(!ssoUpdate("sso_goclient_id",clientId)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_goclient_key",clientKey)){
						
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
						
				return returnList;
			}
			
			if(!ssoUpdate("sso_goauthorize_url",authorizeUrl)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_response_type",responseType)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			if(!ssoUpdate("sso_redirect_url",redirectGoogleUrl)){
				
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				
				return returnList;
			}
			
			
			SessionHelper.setExpireTime();
			String usrId = SessionHelper.getSession("USERID");
			if(!func.f_NullCheck(usrId).equals("")){
				CoviMap clientList = new CoviMap();
				resultList = sysSsoBaseConfigSvc.selectClientList(usrId);
				clientList = (CoviMap) resultList.get("list");
				
				CoviMap params = new CoviMap();
				
				params.put("ur_code", usrId);	
				params.put("client_name", clientName);
				params.put("redirect_uri", redirectUrl);
				
				if(clientList.size() > 0 ){
					if(!sysSsoBaseConfigSvc.updateClient(params)){

						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						
						return returnList;
					}
					
				}
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * addSSOBaseConfigLayerPopup : 시스템 관리 - Single Sign-on 관리 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "system/ssobaseconfigmanage.do", method = RequestMethod.GET)
	public ModelAndView addSSOBaseConfigManagement(Locale locale, Model model) {
		String returnURL = "system/ssobaseconfigmanage.admin";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	public boolean ssoUpdate(String code, String settingValue){
		boolean flag = false;
		
		CoviMap params = new CoviMap();
		
		try {
			params.put("Code", code);
			params.put("SettingValue", settingValue);
			params.put("DomainID", SessionHelper.getSession("DN_ID"));
			
			if(sysSsoBaseConfigSvc.update(params)){
				flag = true;
			}
		} catch (NullPointerException e) {
			flag = false;
		} catch (Exception e) {
			flag = false;
		}
		
		return flag;
	}
	
	@RequestMapping(value = "layout/createoauthbaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createoauthbaseconfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		StringUtil func = new StringUtil();
		OAuth2Util oUtil = new OAuth2Util();
		CoviMap params = new CoviMap();
		try {
			
			SessionHelper.setExpireTime();
			String usrId = SessionHelper.getSession("USERID");
			
			if(!func.f_NullCheck(usrId).equals("")){
				
				String clientId = oUtil.generateClientID();
				String clientSecret = oUtil.generateClientSecret();
				
				params.put("client_id", clientId);
				params.put("client_secret", clientSecret);
				params.put("ur_code", usrId);
				params.put("client_type", "code");
				params.put("scope", "personalinfo");
				params.put("redirect_uri", request.getParameter("redirectUrl"));
				
				if(sysSsoBaseConfigSvc.selectClient(params) < 1){
					
					params.put("domainURL", sysSsoBaseConfigSvc.getDomainURL(params));
					
					if(!sysSsoBaseConfigSvc.createClient(params)){
						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						
						return returnList;
					}
				}else{
					returnList.put("result", "exists");
					returnList.put("status", Return.FAIL);
					
					return returnList;
				}
			}
		
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	@RequestMapping(value = "layout/deleteoauthbaseconfig.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteoauthbaseconfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		try {
			
			SessionHelper.setExpireTime();
			String usrId = SessionHelper.getSession("USERID");
			
			if(!func.f_NullCheck(usrId).equals("")){
				
				params.put("ur_code", usrId);
				
				// 확인 후 삭제 하는 기능 필요.
				if(sysSsoBaseConfigSvc.selectToken(params) > 0){
					if(!sysSsoBaseConfigSvc.deleteToken(params)){
						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						
						return returnList;
					}
				}
				if(sysSsoBaseConfigSvc.selectClient(params) > 0){
					if(!sysSsoBaseConfigSvc.deleteClient(params)){
						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						
						return returnList;
					}
				}
			}
		
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
}
