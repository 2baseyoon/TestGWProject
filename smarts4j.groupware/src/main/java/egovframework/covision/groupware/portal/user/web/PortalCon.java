package egovframework.covision.groupware.portal.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.portal.admin.service.WebpartManageSvc;
import egovframework.covision.groupware.portal.user.service.PNPortalSvc;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import egovframework.coviframework.service.FileUtilService;

import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;

import egovframework.baseframework.util.json.JSONParser;

/**
 * @Class Name : PortalCon.java
 * @Description : 포탈 공통 컨테이너 Controller
 * @Modification Information 
 * @ 2017.06.19 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.19
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class PortalCon {
	
	private static final Logger LOGGER = LogManager.getLogger(PortalCon.class);
	
	@Autowired
	private PortalSvc portalSvc;
	
	@Autowired
	private PNPortalSvc pnPortalSvc;
	
	@Autowired
	private FileUtilService fileUtilSvc;

	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	private WebpartManageSvc webpartManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "portal/home.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getPortalHome(@RequestParam(value = "portalID", required = true, defaultValue="") String portalID, HttpServletRequest request) throws Exception {
		String returnURL = "home";
		ModelAndView mav = new ModelAndView(returnURL);
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		String key = cUtil.getCooiesValue(request);
		
		try{
			
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile, key);
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "PT", "", "V");
			
			String initPortalID = Objects.toString(userDataObj.getString("UR_InitPortal"),"0");
			String licInitPortal = Objects.toString(userDataObj.getString("UR_LicInitPortal"),"0");
			
			String userID = userDataObj.getString("USERID");
			
			// #1 조회할 포탈 ID 결정.
			if (licInitPortal.isEmpty() || licInitPortal.equals("0")){
				if(! portalID.isEmpty()){
					if(authorizedObjectCodeSet.contains(portalID)){
						if(initPortalID.equals("0")){
							CoviMap initParam = new CoviMap();
							initParam.put("userCode", userID);
							initParam.put("initPortalID", portalID);
							
							portalSvc.updateInitPortal(initParam);
							
						}
					}else{
						portalID = "0"; 	//권한 없음
					}
				}else{
					if( !(initPortalID.equals("0")) && authorizedObjectCodeSet.contains(initPortalID)){
						
						portalID = initPortalID;
					}else{
						String authPortalID = portalSvc.setInitPortal(authorizedObjectCodeSet, userID);
						//portalID = authPortalID.equals("0") ? "0" : authPortalID
						if(authPortalID.equals("0")){
							portalID = "0"; 	//권한 없음
							if(!initPortalID.equals("0")){
								CoviMap initParam = new CoviMap();
								initParam.put("userCode", userID);
								initParam.put("initPortalID", "0");
								
								portalSvc.updateInitPortal(initParam);
								
								SessionCommonHelper.setSimpleSession("UR_InitPortal", "0", isMobile, key);
							}
						}else{
							portalID = authPortalID;
						}
					}
				}
				
				// #2 권한이 없을 경우 종료.
				if(portalID.equals("0")){ //권한 없음
					SessionCommonHelper.setSimpleSession("UR_ThemeCode", "default", isMobile, key);
					
					mav.addObject("access", Return.NOT_AHTHENTICATION);
					mav.addObject("portalInfo", new CoviMap());
					mav.addObject("incResource", "");
					mav.addObject("layout", "");
					mav.addObject("javascriptString","");
					mav.addObject("data",new CoviList());
					return mav; 
				}
				
				// #3 포탈에 따라 테마 지정 및 세션값 업데이트
				if( !portalID.isEmpty() ){
					CoviMap themeMap = portalSvc.getPortalTheme(portalID);
					
					SessionCommonHelper.setSimpleSession("UR_ThemeCode", themeMap.getString("ThemeCode"), isMobile, key);
					SessionCommonHelper.setSimpleSession("UR_PortalCode", themeMap.getString("PortalCode"), isMobile, key);
				}
				
				if( ! portalID.equals(initPortalID) ){ 
					SessionCommonHelper.setSimpleSession("UR_InitPortal", portalID, isMobile, key);
				}
			}else{
				String userId = userDataObj.getString("USERID");
				String jobSeq = userDataObj.getString("URBG_ID");	// 본직, 겸직 Seq 값
				String domainID = userDataObj.getString("DN_ID");
				//RedisDataUtil.setACL(userId + "_" + jobSeq, domainID, "PT", "", 7200);
						
				portalID = licInitPortal;
			}
			// #4 포탈 정보 조회
			CoviMap portalParma = new CoviMap();
			portalParma.put("portalID", portalID);
			CoviMap portalInfo = portalSvc.getPortalInfo(portalParma);
			if(!(func.f_NullCheck(portalInfo.get("URL").toString()).equals(""))){
				returnURL = "redirect:";
				
				if (portalInfo.get("PortalType").toString().equals("License"))
					returnURL += request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
				
				returnURL += portalInfo.getString("URL");		
				mav.setViewName(returnURL);
				return mav;
			}
			
			CoviList webpartList = portalSvc.getWebpartList(portalParma);
			
//				String javascriptString =  portalSvc.getJavascriptString(SessionCommonHelper.getSession("lang", isMobile),webpartList);
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList);
			String layoutTemplate = portalSvc.getLayoutTemplate(webpartList, portalParma);
			String incResource = portalSvc.getIncResource(webpartList);
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj);
			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
			mav.addObject("portalInfo", portalInfo);
			mav.addObject("incResource", incResource);
			mav.addObject("layout", layoutTemplate);
			mav.addObject("javascriptString",javascriptString);
			mav.addObject("data",webpartData);
			
			return mav;
			
		} catch(NullPointerException e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		}
		
	}
	@RequestMapping(value = "portal/ceo_portal.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getCeoPortalHome(ModelAndView mav, HttpServletRequest request) throws Exception {
		String returnURL = "ceo_portal";

		boolean isMobile = ClientInfoHelper.isMobile(request);
		CookiesUtil cUtil = new CookiesUtil();
		String portalID = SessionCommonHelper.getSession("UR_InitPortal", isMobile);
		String key = cUtil.getCooiesValue(request);
		try{
			CoviMap portalParma = new CoviMap();
			portalParma.put("portalID", portalID);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile, key);
			
			CoviList webpartList = portalSvc.getWebpartList(portalParma);
			
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList);
			String layoutTemplate = portalSvc.getLayoutTemplate(webpartList, portalParma);
			String incResource = portalSvc.getIncResource(webpartList);
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj);
			
			
			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
//			mav.addObject("portalInfo", portalInfo);
			mav.addObject("incResource", incResource);
			mav.addObject("layout", layoutTemplate);
			mav.addObject("javascriptString",javascriptString);
			mav.addObject("data",webpartData);
			
			return mav;
		} catch(NullPointerException e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		}
	}
	
	@RequestMapping(value = "portal/pn_portal.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getPNPortalHome(ModelAndView mav, HttpServletRequest request) throws Exception {
		String returnURL = "pn_portal";
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CookiesUtil cUtil = new CookiesUtil();
		String portalID = SessionCommonHelper.getSession("UR_InitPortal", isMobile);
		String key = cUtil.getCooiesValue(request);
		try{
			CoviMap portalParma = new CoviMap();
			portalParma.put("portalID", portalID);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile, key);
			
			CoviList webpartList = portalSvc.getWebpartList(portalParma);
			
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList);
			String layoutTemplate = portalSvc.getLayoutTemplate(webpartList, portalParma);
			String incResource = portalSvc.getIncResource(webpartList);
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj);
			
			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
//			mav.addObject("portalInfo", portalInfo);
			mav.addObject("incResource", incResource);
			mav.addObject("layout", layoutTemplate);
			mav.addObject("javascriptString",javascriptString);
			mav.addObject("data",webpartData);
			
			return mav;
		} catch(NullPointerException e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		}
	}
	
	//신규 포탈 개선
	@RequestMapping(value = "portal/portal.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getPortalEx(ModelAndView mav, HttpServletRequest request) throws Exception {
		String returnURL = "portal";
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CookiesUtil cUtil = new CookiesUtil();
		String portalID = SessionCommonHelper.getSession("UR_InitPortal", isMobile);
		String key = cUtil.getCooiesValue(request);
		try{
			CoviMap portalParam = new CoviMap();
			portalParam.put("portalID", portalID);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile, key);
			
			CoviList webpartList = portalSvc.getWebpartList(portalParam);
			
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj);
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList, "FUNC");
//			String layoutTemplate = portalSvc.getLayoutTemplate(webpartList, portalParma);
			String incResource = portalSvc.getIncResource(webpartList);
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "WP", "", "V");
			
			// 신규 웹파트 정보--위젯
			portalParam.put("webpartIDs", authorizedObjectCodeSet);
			portalParam.put("domainCode", userDataObj.getString("DN_Code"));
			portalParam.put("userCode", userDataObj.getString("UR_Code"));
			portalParam.put("serviceDevice", "P");

			portalParam.put("lang", userDataObj.getString("lang"));
			portalParam.put("cMode", "Widget");
			portalParam.putOrigin("bizSectionArr", StringUtil.toTokenArray(userDataObj.getString("UR_AssignedBizSection"),"|"));
			
			CoviList myWidget = (CoviList)portalSvc.getMyContentSetWebpartList(portalParam);
			String myWidgetScripts =  portalSvc.getJavascriptString(userDataObj.getString("lang"),myWidget, "FUNC");
			// 신규 웹파트 정보--컨텐츠
			portalParam.put("cMode", "Contents");
			CoviList myContents = (CoviList)portalSvc.getMyContentSetWebpartList(portalParam);
			String myContentsScripts =  portalSvc.getJavascriptString(userDataObj.getString("lang"),myContents, "FUNC");


			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
			mav.addObject("incResource", incResource);

			mav.addObject("webpart",webpartData);
			mav.addObject("javascriptString",javascriptString);

			mav.addObject("myWidget",myWidget);
			mav.addObject("myWidgetScripts",myWidgetScripts);
			mav.addObject("myContents",myContents);
			mav.addObject("myContentsScripts",myContentsScripts);

			return mav;
		} catch(NullPointerException e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			mav.addObject("access", Return.FAIL);
			return mav;
		}
	}
	
	/**
	 * goMyContentsSetPopup: 마이컨텐츠 설정 팝업 오픈
	 * @return mav
	 * @throws Exception
	 */
	@RequestMapping(value = "mycontents/goMyContentsSetPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goMyContentsSetPopup(HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/portal/MyContentsSetPopup");
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionCommonHelper.getSession(isMobile);		
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "WP", "", "V");
		
		CoviMap params = new CoviMap();
		params.put("webpartIDs", authorizedObjectCodeSet);
		params.put("lang", SessionCommonHelper.getSession("lang"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("cMode", request.getParameter("contentsMode"));
		params.putOrigin("bizSectionArr", StringUtil.toTokenArray(userDataObj.getString("UR_AssignedBizSection"),"|"));
		
		CoviList list = portalSvc.getMyContentsWebpartList(params);
/*		CoviList retList = new CoviList();
		for (int i=0; i< list.size();i++){
			CoviMap cmap = list.getMap(i);
			if (ComUtils.getAssignedBizSection(cmap.getString("BizSection"))){
				retList.add(cmap);
			}
		}*/
		mav.addObject("webpartList", list);
		
		return mav;
	}


	/**
	 * saveMyContentsSetting - 마이컨텐츠 설정 저장
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "mycontents/saveMyContentsSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveMyContentsSetting(
			@RequestParam(value = "webparts", required = true, defaultValue="") String webparts,
			@RequestParam(value = "contentsMode", required = true, defaultValue="") String contentsMode	) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] webpartArr  = webparts.split("-"); 
		 
			CoviMap params = new CoviMap();
			params.put("cMode", contentsMode);
			params.put("userCode",SessionCommonHelper.getSession("UR_Code"));
			if(!webparts.equals("")){
				params.put("webpartArr",webpartArr);
			}
			
			portalSvc.saveMyContentsSetting(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getMyContentSetWebpartList - 마이컨텐츠 설정 가져오기
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "mycontents/getMyContentSetWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyContentSetWebpartList(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "WP", "", "V");
			
			params.put("webpartIDs", authorizedObjectCodeSet);
			params.put("userCode", userDataObj.getString("UR_Code"));
			params.put("CompanyCode", userDataObj.getString("DN_Code"));
			params.put("cMode", request.getParameter("contentsMode"));
			params.putOrigin("bizSectionArr", StringUtil.toTokenArray(userDataObj.getString("UR_AssignedBizSection"),"|"));
			
			CoviList webpartList = portalSvc.getMyContentSetWebpartList(params);
			//CoviList list = portalSvc.getMyContentsWebpartList(params);
/*			CoviList retList = new CoviList();
			for (int i=0; i< webpartList.size();i++){
				CoviMap cmap = webpartList.getMap(i);
				if (ComUtils.getAssignedBizSection(cmap.getString("BizSection"))){
					retList.add(cmap);
				}
			}
*/
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList);
			
			returnData.put("webpartList", webpartList);
			returnData.put("myContentsJavaScript", javascriptString);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * getMyContentWebpartList - 마이컨텐츠  웹파트 가져오기
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "mycontents/getMyContentWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyContentWebpartList(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			String webpartID = request.getParameter("webpartID");
			params.put("webpartID", webpartID == null ? "" : webpartID);
			
			CoviList webpartList = portalSvc.getMyContentWebpartList(params);
			
			String javascriptString =  portalSvc.getJavascriptString(userDataObj.getString("lang"),webpartList);
			
			returnData.put("webpartList", webpartList);
			returnData.put("myContentsJavaScript", javascriptString);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	/**
	 * goMyContentsSetPopup: 임직원 소식 팝업 오픈
	 * @return mav
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/goEmployeesNoticeListPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView goEmployeesNoticeListPopup() throws Exception {
		ModelAndView mav = new ModelAndView("user/portal/EmployeesNoticePopup");		
		
		return mav;
	}
	
	/**
	 * getEmployeesNoticeList - 임직원 소식 팝업/웹파트
	 * @param page, paging, mode 
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getEmployeesNoticeList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getEmployeesNoticeList(@RequestParam(value = "page", required = true, defaultValue="0") String page,
			@RequestParam(value = "selMode", required = true, defaultValue="ALL") String selMode,
			@RequestParam(value = "noticeCount", required = true, defaultValue="5") String noticeCount,
			@RequestParam(value = "addinterval", required = true, defaultValue="0") String addinterval,
			@RequestParam(value = "searchName", required = false, defaultValue="") String searchName,
			@RequestParam(value = "birthMode", required = true, defaultValue="D") String birthMode,
			@RequestParam(value = "enterInterval", required = true, defaultValue="14") String enterInterval,
			@RequestParam(value = "callerId",required = true, defaultValue="") String callerId
			) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			String domainID = SessionCommonHelper.getSession("DN_ID");

			String option = "";
			option = RedisDataUtil.getBaseConfig("Employees_WebpartDisplayOption");
			CoviList BaseOptionSet = RedisDataUtil.getBaseCode("EmployeesNotice"); 
			if(!option.equals("")) {
				String[] optionSet = option.split(";");
				if(optionSet != null) {
					for(int i=0; i<optionSet.length; i++) {
						params.put(optionSet[i],"Y");
					}
				}
			}else if(BaseOptionSet != null && !BaseOptionSet.isEmpty()){ //기초설정값이 없을 때 기초코드 참조
				for(int i=0; BaseOptionSet != null && i<BaseOptionSet.size(); i++) {
					CoviMap omap = BaseOptionSet.getMap(i);
					params.put(omap.getString("Code"),"Y");
				}
			}else{
				params.put("Birth","Y");
			}
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}
			
			params.put("page",Integer.parseInt(page));
			
			if(callerId.equals("webpart")) {
				params.put("rowStart", Integer.parseInt(page) + 1);
	    		params.put("rowEnd", Integer.parseInt(page) + 5);
	    		params.put("paging","portal");
	    		params.put("count",Integer.parseInt(noticeCount));
			}else {
				params.put("paging","popup");
			} 
			
			params.put("selMode",selMode);
			params.put("searchName",searchName);
			params.put("lang",SessionCommonHelper.getSession("lang"));	
			params.put("DN_Code", SessionCommonHelper.getSession("DN_Code"));
			params.put("addinterval",addinterval);
			params.put("birthMode",birthMode);
			params.put("enterInterval",enterInterval);
			
			CoviMap employeesList = portalSvc.getEmployeesNoticeList(params);
			
			returnData.put("employeesList", employeesList);
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		}

		return returnData;
	}
	
	/**
	 * Exchange 메일을 위한 파일 다운로드 (인증없이 fileID만으로 다운로드)
	 * @param fileID 
	 * */
	@RequestMapping(value="portal/exchFileDown.do")
	public void exchFileDown(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		@SuppressWarnings("unused")
		CoviMap fileResult = new CoviMap();
		
		String fileID = "";
		fileID = StringUtil.replaceNull(request.getParameter("fileID"),"");
		
		String companyCode = "";
		String filePath = "";
		String orgFileName = "";
		
		InputStream in = null;
		OutputStream os = null; // 일반첨부파일

		try {
			params.put("FileID", fileID);
			CoviMap fileMap = fileUtilSvc.selectOne(params);
			companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");
			
			if (fileMap.getString("SaveType").equals("INLINE")) {
				filePath = fileMap.getString("InlinePath");
			    
				orgFileName = fileMap.getString("FileName");
				filePath = filePath.replace("{0}", companyCode)+fileMap.getString("FilePath");
				
				String SavedName = fileMap.getString("SavedName");
				
				String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
				String savePath = FileUtil.checkTraversalCharacter(attachRootPath + filePath);
				
				File file = new File(savePath, SavedName);
				
				if (file.exists() && file.isFile()) {
			        // 파일 다운로드 헤더 지정
					response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
					String disposition = FileUtil.getDisposition(orgFileName, FileUtil.getBrowser(request));
					response.setHeader("Content-Disposition", disposition);

					os = response.getOutputStream();
					in = new FileInputStream(file);
					
					byte b[] = new byte[8192];
					int leng = 0;

					int bytesBuffered=0;
						os.write(b,0, leng);
						while ( (leng = in.read(b)) > -1){
						bytesBuffered += leng;
						if(bytesBuffered > 1024 * 1024){ //flush after 1M
							bytesBuffered = 0;
							os.flush();
						}
					}
					os.flush();
				}
			}else {
				CoviMap fileParam = new CoviMap();
				//filePath = fileMap.getString("StorageFilePath");
				fileParam.put("fileID",fileID);
				fileParam.put("fileUUID","");
				fileParam.put("fileToken","");
				fileParam.put("tokenCheckTime","N");
				fileParam.put("userCode","");
				fileParam.put("companyCode",companyCode);
				
				fileResult = fileUtilSvc.fileDownloadByID(request, response, fileParam, false, true);
			}
		}catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
	    }catch(Exception e){
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	    	if(os != null) {
	    		try {
					os.close();
				} catch (IOException e) {
					LOGGER.debug(e.getLocalizedMessage(), e);
				}
	    	}
	    	if(in != null) {
	    		try {
					in.close();
				} catch (IOException e) {
					LOGGER.debug(e.getLocalizedMessage(), e);
				}
	    	}
	    }
	}
	
	/**
	 * Exchange 메일을 위한 파일 조회
	 * @param messageID
	 * */
	@RequestMapping(value="portal/exchFileList.do")
	public @ResponseBody CoviMap exchFileList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();

		String messageID = StringUtil.replaceNull(request.getParameter("MessageID"),"");
		
		params.put("MessageID", messageID );
		
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap exchFileList = portalSvc.exchFileList(params);
			
			returnData.put("result", exchFileList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		}
		

		return returnData;
	}	
	
	/**
	 * saveMyContentsSetting - 마이컨텐츠 설정 저장-신포탈
	 * @param portalID
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/saveMyContents.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveMyContents(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
//			String[] webpartArr  = webparts.split("-"); 
		 
			CoviMap params = new CoviMap();
			params.put("saveMode", request.getParameter("saveMode"));
			
			params.put("webpartId", request.getParameter("webpartId"));
			params.put("cMode", request.getParameter("cMode"));
			params.put("serviceDevice", request.getParameter("serviceDevice"));
			params.put("userCode",SessionCommonHelper.getSession("UR_Code"));
			params.put("sortKey", request.getParameter("sortKey"));
			
			portalSvc.saveMyContents(params);
			
			if ("I".equals(request.getParameter("saveMode"))){ //추가이면
				params.put("webpartID", request.getParameter("webpartId"));
				CoviList webpartList = portalSvc.getMyContentWebpartList(params);
				
				String javascriptString =  portalSvc.getJavascriptString(SessionCommonHelper.getSession("lang"),webpartList, "FUNC");
				
				returnData.put("webpartData", webpartList.get(0));
//				returnData.put("webpartList", webpartList.get(index));
				returnData.put("myContentsJavaScript", javascriptString);
				returnData.put("status", Return.SUCCESS);
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	//웹파트 추가 삭제 -한꺼번에 저장
	/*@RequestMapping(value = "/saveTask.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveTask(@RequestParam(value = "file", required = false)  MultipartFile[] uploadfile
			, @RequestParam Map<String, Object> params
			, HttpServletResponse response) throws Exception{
*/
	@RequestMapping(value = "portal/savePortalWebpart.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap savePortalWebpart(@RequestParam(value = "file", required = false)  MultipartFile[] mf, @RequestParam Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		String companyCode = SessionHelper.getSession("DN_Code");
		String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
		String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
		String portalBgPath= "";
		try {
			CoviMap reqMap = new CoviMap();
			
			CoviMap cmap =	SessionCommonHelper.getSessionMap("PortalOption");
			JSONParser parser = new JSONParser();
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("serviceDevice", params.get("serviceDevice"));
			reqMap.put("widgetList", (List)parser.parse((String)params.get("widgetList")));
			reqMap.put("contentsList", (List)parser.parse((String)params.get("contentsList")));

			
			Map portalOption = (Map)parser.parse((String)params.get("portalOption"));
			if (portalOption.size()>0) {
				cmap.putAll(portalOption);
				//배경 이미지 upload가 있으면
				if(mf != null && mf.length>0) {
					List<MultipartFile> mockedFileList = new ArrayList<>();
					for (int i=0; i < mf.length; i++){
						if(mf[i] != null && mf[i].getSize()>0) {
							mockedFileList.add(mf[i]);
						}	
					}	
					String originalfileName = mockedFileList.get(0).getOriginalFilename();
					String ext = FilenameUtils.getExtension(originalfileName);
					
					String fileName = "portal_bg_"+SessionHelper.getSession("USERID")+"_1."+ext;
					
					String fullFileNamePath = FileUtil.checkTraversalCharacter(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path+fileName);
					File originFile = new File(fullFileNamePath);
					fileUtilSvc.transferTo(mockedFileList.get(0), originFile, ext);
					portalBgPath = backStorage + path + fileName;
					cmap.put("portalBgPath", portalBgPath);
				}
				reqMap.put("portalOption", cmap);
			}	
			
			portalSvc.savePortalWebpart(reqMap);
			if (portalOption.size()>0){
				SessionCommonHelper.setSession("PortalOption", cmap);
			}	

			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	@RequestMapping(value = "portal/saveMyContentsOrder.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveMyContentsOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("cMode",  params.get("cMode"));
			reqMap.put("serviceDevice", params.get("serviceDevice"));
			reqMap.put("webpartList", (List)params.get("webpartList"));

			//portalSvc.saveMyContentsOrder(reqMap);
			CoviMap cmap =	SessionCommonHelper.getSessionMap("PortalOption");
			Map portalOption = (Map)params.get("portalOption");
			if (portalOption.size()>0) {
				cmap.putAll(portalOption);
				reqMap.put("portalOption", cmap);
			}	
			
			portalSvc.savePortalWebpart(reqMap);
			if (portalOption.size()>0){
				SessionCommonHelper.setSession("PortalOption", cmap);
			}	
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	
	@RequestMapping(value = "portal/saveMyContentsWebpartColor.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveMyContentsWebpartColor(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("webpartColor",  request.getParameter("webpartColor"));
			reqMap.put("serviceDevice", request.getParameter("serviceDevice"));
			reqMap.put("webpartId", request.getParameter("webpartId"));

			portalSvc.saveMyContentsWebpartColor(reqMap);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	/**
	 * saveUserPortalOption - 사용자 포탈 옵션 저장
	 * @param request
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/saveUserPortalOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveUserPortalOption(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			//CoviMap ;//obj.put("PortalOption");
			CoviMap userDataObj = SessionCommonHelper.getSession();
			CoviMap cmap =	(CoviMap)userDataObj.get("PortalOption");
			cmap.put(request.getParameter("key"), request.getParameter("val"));
			params.put("userCode", userDataObj.getString("UR_Code"));
			params.put("portalOption", cmap);

			int result = pnPortalSvc.saveUserPortalOption(params);
			
			if(result > 0){
				returnData.put("status", Return.SUCCESS);
			}else{
				returnData.put("status", Return.FAIL);
			}
			
			if (StringUtil.replaceNull(request.getParameter("key"),"").equals("isDark") ){
				String isDark = request.getParameter("val") == null ? "N" : request.getParameter("val");
				SessionCommonHelper.setSession("DarkMode", isDark);
			}	
			SessionCommonHelper.setSession("PortalOption", cmap);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * saveUserPortalOption - 사용자 포탈 옵션 저장
	 * @param request
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/resetPortalOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap resetPortalOption(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			portalSvc.resetPortalOption(params);
			CoviMap portalOption = new CoviMap();
			SessionCommonHelper.setSession("PortalOption", portalOption);

			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * getUserPortalOption - 사용자 포탈 옵션 가져오기
	 * @param request
	 * @return returnData
	 * @throws Exception
	
	public static String getUserPortalOption() throws Exception{
		String result = "";
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionCommonHelper.getSession("UR_Code"));
			params.put("lang",  SessionCommonHelper.getSession("lang"));

			PNPortalSvc pnPortalModeSvc = StaticContextAccessor.getBean(PNPortalSvc.class);
			result = pnPortalModeSvc.selectUserPortalOption(params);
		} catch (NullPointerException e) {
			return "";
		} catch (Exception e) {
			return "";
		}
		
		return result;
	} */
	
	/**
	 * 신포탈 자유게시판.
	 * 사용자가 웹파트의 설정에서 folderID를 변경하여 해당 게시판의 데이터를 조회.
	 * @parameter 	folderID
	 * @return 		folderID에 해당하는 데이터 조회 결과.
	 * @throws 		Exception
	 */
	@RequestMapping(value = "portal/changeFolderidOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap changeFolderidOption(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String strSettingKey = StringUtil.replaceNull(request.getParameter("setKeyID"), "");
			String strChangeValue = StringUtil.replaceNull(request.getParameter("changeConfVal"), "");
			String strDomainID = SessionCommonHelper.getSession("DN_ID");
			
			params.put("settingKey", strSettingKey);
			params.put("domainId", strDomainID);
			params.put("settingVal", strChangeValue);
			params.put("UserCode", SessionCommonHelper.getSession("USERID"));
			
			// 1. 관리자 확인(변경은 관리자만 가능).
			if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) {
				portalSvc.updateWebpartSettingKey(params); 	// 2. 기초설정 값 없으면 insert, 있으면 update.
			
				returnData.put("status", Return.SUCCESS);
			} else {
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", DicHelper.getDic("lbl_noAuth"));   	// 권한이 없습니다.
			}
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * goSiteLinkListPopup - ceo message  수정 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "portal/CeoMessagePopup.do", method = RequestMethod.GET)
	public ModelAndView ceoMessagePopup(HttpServletRequest request )throws Exception {
		String returnURL = "user/portal/CeoMessagePopup";
		CoviMap params = new CoviMap();
		params.put("domainId",SessionHelper.getSession("DN_ID"));
		params.put("settingKey",request.getParameter("settingKey"));
		CoviMap map = portalSvc.selectWebpartSettingKey(params);
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("webpartID",request.getParameter("webpartID").replace("WP", ""));
		mav.addObject("settingKey",request.getParameter("settingKey"));
		if (map !=null){
			mav.addObject("messsage",map.getString("SettingValue"));
		}	
		return mav;
		
	}

	/**
	 * ceo message
	 * ceo message 수정
	 */
	@RequestMapping(value = "portal/saveCeoMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveCeoMessage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("domainId",SessionCommonHelper.getSession("DN_ID"));
			params.put("settingKey",request.getParameter("settingKey"));
			params.put("settingVal",request.getParameter("settingVal"));
//			RedisDataUtil.getBaseConfig("");
			String[] arrList = RedisDataUtil.getBaseConfig("ceoMsgAuth").split(";",-1);
			
			portalSvc.updateWebpartSettingKey(params);
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "portal/updateSettingKey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSettingKey(@RequestBody CoviMap params) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			params.put("domainId",SessionCommonHelper.getSession("DN_ID"));
			params.put("UserCode",SessionCommonHelper.getSession("USERID"));
			
			portalSvc.updateWebpartSettingKey(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 웹파트 통합게시(ctn_multitab_notice.js/.html)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="portal/getBoardFolderInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBoardFolderInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		CoviMap params = new CoviMap();
		String strMultiBoard = request.getParameter("multiBoard");
		
		params.put("domainId", SessionCommonHelper.getSession("DN_ID"));
		params.put("lang", SessionCommonHelper.getSession("lang"));
		
		try {
			if (strMultiBoard != null && !strMultiBoard.isEmpty()) {
				String[] arrStrBoard = strMultiBoard.split(",");
				CoviList tmpList = new CoviList();
				for (String folderID : arrStrBoard) {
					params.put("limitFolderID", folderID);
					tmpList = portalSvc.selectBoardFolderByType(params);
					if (tmpList != null && tmpList.size() == 1) {
						returnList.add(tmpList.get(0));
					}
				}
			}
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException npe) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?npe.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 퍼스널 포털 웹파트 수정 팝업
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/setWebpartPopup.do", method = RequestMethod.GET)
	public ModelAndView setWebpartPopup(HttpServletRequest request, HttpServletResponse response)throws Exception {
		String returnURL = "user/portal/setWebpartPopup";
		ModelAndView mav = new ModelAndView(returnURL);

		mav.addObject("webpartID", (String)request.getParameter("webpartID"));
		mav.addObject("popupType", (String)request.getParameter("popupType"));
		mav.addObject("currentValue", (String)request.getParameter("currentValue"));
			
		return mav;
	}
	
}
