package egovframework.covision.groupware.portal.admin.web;

import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.portal.admin.service.WebpartSettingSvc;
import egovframework.covision.groupware.portal.user.service.PortalSvc;


/**
 * @Class Name : WebpartSettingCon.java
 * @Description : 웹파트 배치화면 요청 처리
 * @Modification Information 
 * @ 017.06.09 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.06.09
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class WebpartSettingCon {

	private Logger LOGGER = LogManager.getLogger(WebpartSettingCon.class);
	
	@Autowired
	private WebpartSettingSvc webpartSettingSvc;

	@Autowired
	private PortalSvc portalSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * goWebpartManageSetPopup : 웹파트 관리 - 웹파트 관리 설정 팝업 표시 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/goWebpartSetting.do", method ={ RequestMethod.GET , RequestMethod.POST})
	public ModelAndView goLayoutManageSetPopup(Locale locale, Model model) {
		String returnURL = "admin/portal/WebpartSetting";
		
		return (new ModelAndView(returnURL));
	}

	/**
	 * getPortalSettingData - 포탈 설정 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getPortalSettingData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPortalData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String portalID = request.getParameter("portalID");
			CoviMap params = new CoviMap();
			
			params.put("objectID", portalID);
			
			resultList = webpartSettingSvc.getPortalSettingData(params);
			
			returnData.put("layout",resultList.get("layout"));
			returnData.put("webpart",resultList.get("webpart"));
			returnData.put("portal",resultList.get("portal"));
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
	 * getSettingLayoutList - 레이아웃 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getSettingLayoutList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getlayoutList(
			@RequestParam(value = "isCommunity", required=false, defaultValue="N") String isCommunity ) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("isCommunity", isCommunity);
			
			resultList = webpartSettingSvc.getLayoutList(params);
			
			returnData.put("list",resultList.get("list"));
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
	 * getSettingWebpartList - 웹파트 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getSettingWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSettingWebpartList(
			@RequestParam(value = "isCommunity", required=false, defaultValue="N") String isCommunity,
			@RequestParam(value = "searchWord", required=false) String searchWord,
			@RequestParam(value = "CU_ID", required=false) String communityID
			) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("isCommunity", isCommunity);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("CU_ID", communityID);
			
			resultList = webpartSettingSvc.getWebpartList(params);
			
			returnData.put("list",resultList.get("list"));
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
	 * setPortalData - 웹파트 데이터 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/setPortalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setPortalData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		String portalID = request.getParameter("portalID");
		String layoutID = request.getParameter("layoutID");
		String isDefault = request.getParameter("isDefault");
		String webpartList = request.getParameter("webpartList");
		String portalTag = request.getParameter("layoutTag");
		String layoutSizeTag = request.getParameter("layoutWidthInfo");
		
		try {
			CoviMap params = new CoviMap();
			params.put("portalID", portalID);
			params.put("layoutID", layoutID);
			params.put("isDefault", isDefault);
			params.put("webpartList", webpartList);
			params.put("portalTag", portalTag);
			params.put("layoutSizeTag", layoutSizeTag);
			
			webpartSettingSvc.setPortalData(params);
			
			returnData.put("list",resultList.get("list"));
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
	
	@RequestMapping(value = "portal/goWebpartSettingPreview.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getPortalHome(@RequestParam(value = "previewData", required = false, defaultValue="") String previewDataStr,
			@RequestParam(value = "portalInfo", required = false, defaultValue="") String portalInfoStr,
			@RequestParam(value = "portalID", required = true) String portalID, HttpServletRequest request) throws Exception {
		String returnURL = "home";
		ModelAndView mav = new ModelAndView(returnURL);
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		String key = cUtil.getCooiesValue(request);
		try{
			CoviMap previewData = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(previewDataStr));
			CoviMap portalInfo = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(portalInfoStr));
			
			String webparts = previewData.getString("webpartList");

			CoviMap params = new CoviMap();
			params.put("portalID", portalID);
			params.put("webparts", webparts);
			params.put("layoutTag", previewData.getString("layoutTag"));
			params.put("isDefault", previewData.getString("isDefault"));
		
			// #3 포탈에 따라 테마 지정 및 세션값 업데이트
			if( !portalID.isEmpty() ){
				CoviMap themeMap = portalSvc.getPortalTheme(portalID);
				
				SessionCommonHelper.setSimpleSession("UR_ThemeCode", themeMap.getString("ThemeCode"), isMobile, key);
				SessionCommonHelper.setSimpleSession("UR_PortalCode", themeMap.getString("PortalCode"), isMobile, key);
			}
			
			// #4 포탈 정보 조회
			CoviMap portalParma = new CoviMap();
			portalParma.put("portalID", portalID);
			CoviMap portalInfoTemp = portalSvc.getPortalInfo(portalParma);
			if(!(func.f_NullCheck(portalInfoTemp.get("URL").toString()).equals(""))){
				if (portalInfoTemp.get("PortalType").toString().equals("License")) {
					returnURL = "redirect:";
					returnURL += request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + portalInfoTemp.getString("URL");
					mav.setViewName(returnURL);
					return mav;
				} else {
					returnURL = portalInfoTemp.getString("URL").split("\\.")[0];	
				}
			}
			
			CoviList webpartList = webpartSettingSvc.getPreviewWebpartList(params);
			String javascriptString =  portalSvc.getJavascriptString("ko",webpartList);
			String layoutTemplate = webpartSettingSvc.getLayoutTemplate(webpartList, params);
			String incResource = portalSvc.getIncResource(webpartList);
			
			CoviMap userDataObj = SessionHelper.getSession();
			
			CoviList webpartData = (CoviList)portalSvc.getWebpartData(webpartList, userDataObj);
			
			mav.setViewName(returnURL);
			mav.addObject("access", Return.SUCCESS);
			mav.addObject("incResource", incResource);
			mav.addObject("layout", layoutTemplate);
			mav.addObject("javascriptString",javascriptString);
			mav.addObject("data",webpartData);
			mav.addObject("portalInfo",portalInfo);
			
			return mav;
		} catch(NullPointerException e){
			LOGGER.error(e);
			return mav;
		} catch(Exception e){
			LOGGER.error(e);
			return mav;
		}
	}
	
}
