package egovframework.covision.groupware.base.web;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.joda.time.DateTime;
import org.joda.time.Duration;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.Sha512;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.SessionService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.covision.groupware.base.service.LongPollingSvc;
import egovframework.covision.groupware.mobile.MobileSvc;
import egovframework.covision.groupware.portal.user.service.PortalSvc;



@Controller
@RequestMapping("/mobile")
public class MobileCommonCon {

	private Logger LOGGER = LogManager.getLogger(MobileCommonCon.class);

	private final String PARAM_SYSTEM = "CLSYS";		//board
	private final String PARAM_BIZSECTION = "CLBIZ";	//Board

	@Autowired
	PortalSvc portalSvc;
	
	@Autowired
	MobileSvc mobileSvc;

	@Autowired
	private SessionService sessionService;
	/*
	 *  layout/tiles 처리 시작
	 * 
	 * 
	 */

	//(tiles-left) 햄버거/좌측 메뉴 표시를 위해 메뉴 목록을 조회해서 넘김 
	@RequestMapping(value = "layout/left.do", method = RequestMethod.GET)
	public ModelAndView getLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		JSONSerializer jUtil = new JSONSerializer();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
				
		String domainId = userDataObj.getString("DN_ID");
		String menu = ACLHelper.getMenu(userDataObj);
		
		String isAdmin = "N";
		String menuType = "Top";
		String memberOf = "0";

		CoviList menuArray = null;
		CoviList queriedMenu = null;
		if (StringUtils.isNoneBlank(menu)) {
			menuArray = jUtil.jsonGetObject(menu);
			queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, menuType, memberOf, menuArray, "M");
		}

		String returnURL = "mobile/MobileLeft";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("themeColor", RedisDataUtil.getBaseCode("ThemeColor"));
		mav.addObject("MenuData", queriedMenu);
		
		String communityID = request.getParameter("cuid");
		if (communityID != null) mav.addObject("communityID", communityID);
		
		return mav;
	}
	
	//(tiles-content) 상단 메뉴 목록을 조회해서 넘김(list만)
	@RequestMapping(value = "/{programName}/go{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getTopMenu(HttpServletRequest request, HttpServletResponse response,
			@PathVariable String programName,
			@PathVariable String pageName) throws Exception {
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		String domainId = userDataObj.getString("DN_ID");
		String returnURL = "mobile/" + programName + "/" + pageName;
		String hasTopMenu = RedisDataUtil.getBaseConfig("hasTopMenu", domainId);
		if(StringUtils.isBlank(hasTopMenu)) {
			hasTopMenu = "";
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		if(hasTopMenu.indexOf(programName + "/" + pageName) > -1) {
			mav.addObject("Menu", getTopMenuList(programName, userDataObj));
		}else{//2022.01.10 nkpark 메뉴 정보 없어도 공백 구조체 넣어줘야함.
			mav.addObject("Menu", "{}");
		}
		
		String communityID = request.getParameter("cuid");
		if (communityID != null) mav.addObject("communityID", communityID);

		if(RedisDataUtil.getBaseConfig("UseWaterMark",domainId).equals("Y")) {
			//워터마크 추가
			String userCode = userDataObj.getString("USERID");
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
			String date = formatter.format(new Date());
			String watermark_data = userCode + " " + date;
			
			mav.addObject("WaterMark", watermark_data);
		}
		
		return mav;
	}
	
	//상단 메뉴를 조회
	private CoviList getTopMenuList(String bizSection, CoviMap userDataObj) {
		CoviList result = null;
		JSONSerializer jUtil = new JSONSerializer();
		
		String domainId = userDataObj.getString("DN_ID");
		String isAdmin = "N";
		String menuType = "Left";
		
		String menu = "";
		
		try {
			menu = ACLHelper.getMenu(userDataObj);
			
			if (StringUtils.isNoneBlank(menu)) {
				result = jUtil.jsonGetObject(menu);
				result = ACLHelper.parseMenuByBiz(domainId, isAdmin, bizSection, menuType, result, userDataObj.getString("lang"), "M");
			}
			
		} catch(NullPointerException e){
			LOGGER.debug(e);
		} catch(Exception e){
			LOGGER.debug(e);
		}
		
		return result;
	}
	
	
	
	
	/*
	 *  layout/tiles 처리 끝
	 * 
	 * 
	 */
	
	
	// 일반 페이지 호출 처리 
	// ex> /mobile/board/list.do 
	//       => /mobile/board/list.mobile
	//       => /WEB-INF/views/mobile/board/list.jsp
	@RequestMapping(value = "/{programName}/{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getContent(HttpServletRequest request, HttpServletResponse response, 
				@PathVariable String programName, 
				@PathVariable String pageName) throws Exception {
			
		//String returnURL = "mobile/" + programName.toLowerCase() + "/" + pageName + ".mobile";
		
		String isPopup = StringUtil.replaceNull(request.getParameter("IsPopup"), "N");
		String returnURL = "mobile/" + programName.toLowerCase() + "/" + pageName + ((StringUtils.isNoneBlank(isPopup) && isPopup.equals("Y")) ? "" : ".mobile");
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("QueryString", request.getQueryString());
	
		return mav;
	}
	
	//메인페이지 URL 호출에 대한 처리 
	@RequestMapping(value = "portal/home.do", method = RequestMethod.GET)
	public ModelAndView getPortalHome(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		return new ModelAndView("mobile/portal/home.mobile");
	}
	
	@RequestMapping(value = "portal/main.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getPortalHome(@RequestParam(value = "portalid", required = true, defaultValue="21") String portalID, HttpServletRequest request) throws Exception {
		String returnURL = "mobile/portal/main.mobile";
		ModelAndView mav = new ModelAndView(returnURL);
		StringUtil func = new StringUtil();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		try{
			String initPortal = Objects.toString(RedisDataUtil.getBaseConfig("MobilePortalID", isMobile),"");
			String licSeq =  StringUtil.replaceNull(userDataObj.get("UR_LicSeq"),"");
			String licInitPortal = Objects.toString(userDataObj.getString("UR_LicInitPortal"),"0");
			String licIsMbPortal = Objects.toString(userDataObj.getString("UR_LicIsMbPortal"),"Y");
			
			String theme = Objects.toString(userDataObj.getString("DN_Theme"),"").split("[|]")[0];
			
			if(!initPortal.isEmpty()){
				portalID = initPortal;
			}
			
			//모바일이 퐅탈이 없는 라이선스인 경우
			if (licIsMbPortal.equals("N")){
				returnURL = "mobile/portal/banner.mobile";
				mav.setViewName(returnURL);
				return mav;
			}
			
			//portalID.equals("")  = portalID.isEmpty()		
/*			if( ( ! portalID.isEmpty() ) && theme.indexOf(portalID) <=-1 && RedisDataUtil.getBaseConfig("ChangeThemeForPotal",isMobile).equals("Y") ){
				//테마 전역 설정 여부
				CoviMap themeMap = portalSvc.getPortalTheme(portalID);
				String newTheme = themeMap.getString("ThemeCode");
				SessionHelper.setSession("DN_Theme", userDataObj.getString("DN_Theme").replace(theme+"|", newTheme+"|"), isMobile);
			}
*/			
			CoviMap params = new CoviMap();
			params.put("portalID", portalID);
			params.put("userCode", userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			
			CoviMap portalInfo = portalSvc.getPortalInfo(params);
			
			if(!(portalInfo.getString("URL").equals(""))){
				returnURL = "redirect:"+portalInfo.getString("URL");
				mav.setViewName(returnURL);
				return mav;
			}
			
			params.put("initPortal", initPortal);
			CoviList webpartList = portalSvc.getWebpartList(params);
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj, "Y");
			String javascriptString =  portalSvc.getJavascriptString("ko",webpartList, "FUNC");

			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
			mav.addObject("portalInfo", portalInfo);
			mav.addObject("webpart",webpartData);
			mav.addObject("javascriptString",javascriptString);
			
			javascriptString =  portalSvc.getJavascriptString("ko",webpartList, "FUNC");
			Set<String> webpartIDs = ACLHelper.getACL(userDataObj, "WP", "", "V");
			params.put("webpartIDs", webpartIDs);
			params.putOrigin("bizSectionArr", StringUtil.toTokenArray(userDataObj.getString("UR_AssignedBizSection"),"|"));
			//widget(포탈)
			params.put("cMode", "Widget");
			params.put("serviceDevice", "M");
			CoviList myWidget = (CoviList)portalSvc.getMyContentSetWebpartList(params);
			String myWidgetScripts =  portalSvc.getJavascriptString(userDataObj.getString("lang"),myWidget, "FUNC");
			//컨텐츠
			params.put("cMode", "Contents");
			CoviList myContents = (CoviList)portalSvc.getMyContentSetWebpartList(params);
			String myContentsScripts =  portalSvc.getJavascriptString(userDataObj.getString("lang"),myContents, "FUNC");
			//myContents.sort();
			
			mav.addObject("myWidget",ComUtils.sortCoviList(myWidget,"SortKey"));
			mav.addObject("myWidgetScripts",myWidgetScripts);
			mav.addObject("myContents",ComUtils.sortCoviList(myContents,"SortKey"));
			mav.addObject("myContentsScripts",myContentsScripts);
			CoviMap returnMap = sessionService.getMyBaseData(params);
			
			mav.addObject("myWidgetCnt", returnMap.get("myWidgetCnt"));
			mav.addObject("myAllWidget", returnMap.get("myWidget"));
			mav.addObject("myContentsCnt", returnMap.get("myContentsCnt"));
			mav.addObject("myAllContents", returnMap.get("myContents"));
			mav.addObject("myPortalOption", userDataObj.get("PortalOption"));
			
			mav.addObject("themeColor", RedisDataUtil.getBaseCode("ThemeColor"));
			mav.addObject("portalBg", RedisDataUtil.getBaseCode("PortalBg"));
			mav.addObject("portalColor", RedisDataUtil.getBaseCode("PortalColor"));
			mav.addObject("MobileHomeTab", RedisDataUtil.getBaseConfig("MobileHomeTab"));
			mav.addObject("isUseMail", RedisDataUtil.getBaseConfig("isUseMail"));
			
			return mav;
		
		} catch(NullPointerException e){
			LOGGER.error(e);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			return mav;
		}
	}


	
	//App에서 push서버 URL 확인을 요한 요청
	@RequestMapping(value = "getServerInfo.do", method = RequestMethod.POST)
	public @ResponseBody String getServerInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String sRet = "";
		
		try	{
			sRet = RedisDataUtil.getBaseConfig("MobilePushServerURL");
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return sRet;
	}
	
	//App에서 문서변환서버 URL 확인을 요한 요청
	@RequestMapping(value = "getDocConverterServer.do", method = RequestMethod.POST)
	public @ResponseBody String getDocConverterServer(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String sRet = "";
		
		try	{
			sRet = RedisDataUtil.getBaseConfig("MobileDocConverterServerURL");
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return sRet;
	}

	
	//App에서 전화번호 검색을 요청
	@RequestMapping(value = "searchPhoneNumber.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap searchPhoneNumber(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String phonenumber = request.getParameter("PhoneNumber");
		
		CoviMap jsonRet = null;
		
		try	{
			jsonRet = mobileSvc.getPhoneNumberSearch(phonenumber);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return jsonRet;
	}
	
	
	//App에서 전화번호 목록을 요청
	@RequestMapping(value = "getPhoneNumberList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPhoneNumberList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap jsonRet = null;
		
		try	{
			jsonRet = mobileSvc.getPhoneNumberList();
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return jsonRet;
	}

	@Autowired
    private SessionService sessionSvc;
    private LongPollingSvc longPollingSvc; 
    
//	App에서 메일/결재/일정/알림 카운트 요청 (모바일)
	@RequestMapping(value = "getQuickDataForMobile.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getQuickDataForMobile(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviMap userDataObj = new CoviMap();
		
		StringUtil func = new StringUtil();
		TokenHelper tokenHelper = new TokenHelper();
		CookiesUtil cUtil = new CookiesUtil();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();
		
		String WidgetInfo = request.getParameter("WidgetInfo");
		LOGGER.debug("WIDGET WidgetInfo: " + WidgetInfo);
		
		String menuListStr = StringUtil.replaceNull(request.getParameter("menuListStr"), "");
		LOGGER.debug("WIDGET menuListStr: " + menuListStr);
		ArrayList<String> menuList = new ArrayList<String>(Arrays.asList(menuListStr.split(";")));
		
		String key = cUtil.getCooiesValue(request);
		LOGGER.debug("WIDGET key: " + key);
		
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		String aestokenkey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.token.key"));
		String systemCode = PropertiesUtil.getSecurityProperties().getProperty("coviSignOne.system.code");
		
		String decodeKey = "";
		String ssoLogOut = "";
		String subDomain = "";
		
		Map map = new HashMap();
		
		AES aes = new AES(aeskey, "N");
		
		try {
			if(aes != null) {
				LOGGER.debug("WIDGET_AES Not NULL - " + aes.decrypt(WidgetInfo));				
				String[] _decryptMobileToken = aes.decrypt(WidgetInfo).split("\\|");
				
	            String sUserId = _decryptMobileToken[0];
	            String sUserpwd = _decryptMobileToken[1];
	            String sLang = _decryptMobileToken[2];
		        // String sDeviceID = _decryptMobileToken[3];
	            String linfo = "";
	            if(_decryptMobileToken.length > 6) {
	            	linfo = _decryptMobileToken[6];
					
					if(!func.f_NullCheck(linfo).equals("")) {
						aes = new AES(aestokenkey, "N");
						linfo = aes.decrypt(linfo);
						
						sUserId = linfo.split("\\|")[1];
						sUserpwd = linfo.split("\\|")[2];
					}
	            }
	            LOGGER.debug("WIDGET__decryptMobileToken : UserID = " + sUserId);
				
				
				//세션 정보가 없으면
				if (true) {
					//모바일 자동로그인 처리 - 모바일이면서 header에 특정 정보가 있는 경우
				    if(WidgetInfo != null){			            
				    	//yyyy-MM-dd_HHmmss
			            String[] splittedDate = _decryptMobileToken[4].split("_");
			            String sDate = splittedDate[0];
			            String sTime = splittedDate[1];
			            
			            String formattedTime = sTime.substring(0, 2) + ":" + sTime.substring(2, 4) + ":" + sTime.substring(4, 6);
			            
			            DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");
			            DateTime dtCreateDate = formatter.parseDateTime(sDate + " " + formattedTime);
			            
			           // String sPackageName = _decryptMobileToken[5];
			            
			            LOGGER.debug("WIDGET__dtCreateDate : " + dtCreateDate);

			            //계정 잠금여부 확인
			            int lockCount = sessionSvc.selectAccountLock(sUserId);
			            
			    		if(lockCount > 0 ){
			    			LOGGER.debug("WIDGET__lockCount - 계정 잠김");
			    			returnData.put("status","LOCKED");
			    		} else {
			    			LOGGER.debug("WIDGET__lockCount - 정상");
			    		}
			            
			            // 3. 계정 체크
			            DateTime dtNow = new DateTime();
			            Duration dur = new Duration(dtCreateDate, dtNow);
			            long diffSeconds = dur.getStandardSeconds();
			            LOGGER.debug("WIDGET__check 1 - diffSeconds : " + diffSeconds);
			            
						String pId = sessionSvc.selectUserAuthetication(sUserId, sUserpwd) ;
			            
			            if (!"".equals(func.f_NullCheck(pId)) && diffSeconds < 60){
//			            if (true){
			            	//인증체크 로직 수행
							CoviMap resultList = sessionSvc.checkAuthetication("SSO", sUserId, sUserpwd, sLang);
							
							// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
							String status = resultList.get("status").toString();
							CoviMap account = (CoviMap) resultList.get("account");
							userDataObj = account;
							
							//인증 성공 시
							if (func.f_NullCheck(status).equals("OK")) {
								String date = sessionSvc.checkSSO("DAY");
								String dn = sessionSvc.selectUserMailAddress(sUserId);
								key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, sUserpwd, sLang, 
										 dn, account.get("DN_Code").toString(), account.get("UR_EmpNo").toString(), account.get("DN_Name").toString()
										 , account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString()
										 , account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString());

								String accessDate = tokenHelper.selCookieDate(date,"");
								cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
							}
			            }else{
			            	returnData.put("status","FAIL");
			            }
					} else {
						returnData.put("status","LINFOERROR");
						/*
						 * if (func.f_NullCheck(sUserId).equals("") &&
						 * !func.f_NullCheck(key).equals("")) { decodeKey =
						 * tokenHelper.getDecryptToken(key);
						 * 
						 * map = tokenParserHelper.getSSOToken(decodeKey);
						 * 
						 * String id = (String) map.get("id"); String pw = (String) map.get("pw");
						 * String lang = (String) map.get("lang");
						 * 
						 * System.out.println("WIDGET : ELSE - id = " + id + "/ pw = " + pw +
						 * "/ lang = " + lang);
						 * 
						 * request.setAttribute("id", id); request.setAttribute("password", pw);
						 * request.setAttribute("language", lang);
						 * 
						 * //locale 정보 하드코딩을 제거 할 것. // setLocale(request, response, lang);
						 * 
						 * //권한 확인 및 생성 //setAuthority(SessionHelper.getSession("DN_ID"),
						 * SessionHelper.getSession("USERID"));
						 * 
						 * CoviMap resultList = new CoviMap(); resultList =
						 * sessionSvc.checkAuthetication("SSO", id, pw, lang);
						 * 
						 * String status = resultList.get("status").toString(); CoviMap account =
						 * (CoviMap) resultList.get("account");
						 * 
						 * //인증 성공 시 if (func.f_NullCheck(status).equals("OK")) {
						 * System.out.println("WIDGET - 인증 성공"); //세션 생성 //
						 * session.getServletContext().setAttribute(key,
						 * account.get("UR_ID").toString()); // // session.setAttribute("USERID",
						 * account.get("UR_ID").toString()); // session.setAttribute("LOGIN", "Y"); //
						 * session.setAttribute("KEY", key); // // //redis에 세션 저장 // //String authType =
						 * SessionHelper.getSession("SSO"); // //
						 * SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account,
						 * isMobile, key); //SessionHelper.setSession("SSO", authType);
						 * //SessionHelper.setSession("lang", lang, isMobile); }
						 * 
						 * //권한 확인 및 생성 //setAuthority(SessionHelper.getSession(isMobile, key),
						 * isMobile);
						 * 
						 * // return true;
						 * 
						 * }
						 * 
						 */}
				}
				
				
				
				CoviMap params = new CoviMap();
				params.put("menuList", menuList);
				params.put("userID", userDataObj.get("UR_Code").toString());
				LOGGER.info("----------------------getQuickDataForMobile : " + sUserId);
				userDataObj.put("USERID", userDataObj.get("UR_Code").toString());
				userDataObj.put("DEPTID", userDataObj.get("GR_Code").toString());
				LOGGER.debug("WIDGET__userDataObj : " + userDataObj);
				
				// 사용자 타임존의 현재일 검색 범위의 일정 검색
                params.put("StartDate", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat)+" 00:00",ComUtils.ServerDateFormat));
                params.put("EndDate", ComUtils.TransServerTime(DateHelper.getAddDate(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat), 1)+" 23:59", ComUtils.ServerDateFormat));
                
				resultObj = mobileSvc.getQuickMenuCount(params, userDataObj); 
				
				returnData.put("status", Return.SUCCESS);
				returnData.put("countObj",resultObj);
			}
		} catch(ArrayIndexOutOfBoundsException e) {
			LOGGER.error("WIDGET_Exception : " + e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error("WIDGET_Exception : " + e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error("WIDGET_Exception : " + e.getLocalizedMessage(), e);
		}
		return returnData;
	}

}
