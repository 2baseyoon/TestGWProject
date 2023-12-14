package egovframework.coviframework.base;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.SessionService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.CommonUtil;
import  egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;

import java.util.List;

import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.LicenseHelper;

import java.util.Set;

/**
 * @Class Name : CommonCon.java
 * @Description : 공통컨트롤러
 * @Modification Information 
 * @ 2016.05.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 05.20
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BaseCommonCon {

	private Logger LOGGER = LogManager.getLogger(BaseCommonCon.class);
	
	private final String PARAM_SYS = "CLSYS";
	private final String PARAM_MODE = "CLMD";
	private final String PARAM_BIZ = "CLBIZ";
	private final String PARAM_SMU = "CSMU";
	
	@Autowired
	private AuthorityService authSvc;

	@Autowired
	private SessionService sessionService;
	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//layout 처리 시작
	@RequestMapping(value = "layout/include.do")
	public ModelAndView getInclude(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Map<String, String> queries = splitQuery(request.getQueryString());
		String systemName =  Objects.toString(queries.get(PARAM_SYS), "core");
		String mode =  Objects.toString(queries.get(PARAM_MODE), "");
		CoviList jsonList = new CoviList();
		String headerName = "";
		if(systemName.equalsIgnoreCase("core")){
			headerName = "Admin";	// 22.11.23 include파일들이 framework 프로젝트로 이동하여, core인 경우도 admin을 바라보도록 변경
		} else {
			if(mode.equalsIgnoreCase("admin")){
				headerName = "Admin";
			}else{
				headerName = "User";
			}
		}
		String returnURL = "cmmn/" + headerName + "Include";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("sysAdminInclude", jsonList);
		return mav;
	}
	
	//header
	@RequestMapping(value = "layout/header.do")
	public ModelAndView getHeader(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CommonUtil commonUtil = new CommonUtil();
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		JSONSerializer jUtil = new JSONSerializer();
		
		Map<String, String> queries = splitQuery(request.getQueryString());
		String systemName =  Objects.toString(queries.get(PARAM_SYS), "core");
		String mode =  Objects.toString(queries.get(PARAM_MODE), "");
		String headerName = "";
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		if(systemName.equalsIgnoreCase("core")){
			headerName = "admin";
		} else {
			if(mode.equalsIgnoreCase("admin")){
				headerName = "admin";
			}else{
				headerName = "user";
			}
		}
		
		String returnURL = "cmmn/"+headerName+"_header";
		String domainId = userDataObj.getString("DN_ID");
		
		String menuStr = ACLHelper.getMenu(userDataObj);
		String isAdmin = "N";
		if(mode.equals("admin")){
			isAdmin = "Y";
		}
		
		CoviMap myInfoData = commonUtil.makeMyInfoData(userDataObj, func.getRemoteIP(request));	//MyInfo 사이드 메뉴 전용
		
		CoviList queriedMenu = null;
		if(StringUtils.isNoneBlank(menuStr)){
			CoviList menuArray = jUtil.jsonGetObject(menuStr);
			// menuArray로 부터 menuType, BizSection별로 쿼리
			queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, "Top", "0", menuArray);
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("topMenuData", queriedMenu);
		mav.addObject("myInfoData", myInfoData);
		
		if (isAdmin.equalsIgnoreCase("N")){
			String topMenuConf= SessionHelper.getSession("TopMenuConf");
			if(topMenuConf.indexOf("@@")>-1){
				String[] arrTopMenu = topMenuConf.split("@@");
				for(int i=0;i<arrTopMenu.length;i++){
					if(arrTopMenu[i].equals(SessionHelper.getSession("DN_ID"))){//해당 domain
						topMenuConf = arrTopMenu[i+1];
						break;
					}
				}
			}
			
			CoviList myTopMenuData = new CoviList();
			String[] topMenuConfArry = topMenuConf.split(";");
			if (topMenuConf.equals("") || topMenuConfArry.length==0){
				for (int i=0; i < queriedMenu.size(); i++){
					myTopMenuData.add(queriedMenu.getMap(i));
				}
			}else{
				for (int j=0; j < topMenuConfArry.length; j++){
					for (int i=0; i < queriedMenu.size(); i++){
						CoviMap thisMenu = queriedMenu.getMap(i);
						if (topMenuConfArry[j].equals(thisMenu.get("MenuID"))){
							myTopMenuData.add(queriedMenu.getMap(i));
							continue;
						}
					}
				}	
			}
			
			mav.addObject("myBaseData", userDataObj);
			mav.addObject("myPortalOption", userDataObj.get("PortalOption"));
			mav.addObject("myTopMenuConf", myTopMenuData);
			//포탈
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "PT", "", "V");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("aclPortalArr", authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]));
			params.put("userId",userDataObj.getString("USERID"));
			params.put("userCode", userDataObj.getString("USERID"));
			params.put("isAll","Y");
			params.put("serviceDevice","P");
			
	//		mav.addObject("myInitPortal", userDataObj.getString("UR_InitPortal"));
	
			authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Board", "V");			
			// 보기 권한이 있는 커뮤니티 목록 조회
			Set<String> authorizedCommunitySet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", "V");
			authorizedObjectCodeSet.addAll(authorizedCommunitySet);
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			params.put("aclDataArr", objectArray);
			
			Set<String> webpartIDs = ACLHelper.getACL(userDataObj, "WP", "", "V");
			params.put("webpartIDs", webpartIDs);
			params.put("portalCode",SessionHelper.getSession("UR_PortalCode"));
			params.putOrigin("bizSectionArr", StringUtil.toTokenArray(userDataObj.getString("UR_AssignedBizSection"),"|"));
			CoviMap returnMap = sessionService.getMyBaseData(params);
			
			mav.addObject("myAddJobList", returnMap.get("myAddJobList"));
			mav.addObject("myPortalList", returnMap.get("myPortalList"));
			mav.addObject("myFavorite", returnMap.get("myFavorite"));
			
			mav.addObject("myWidgetCnt", returnMap.get("myWidgetCnt"));
			mav.addObject("myWidget", returnMap.get("myWidget"));
			mav.addObject("myContents", returnMap.get("myContents"));
	
			mav.addObject("langCode", RedisDataUtil.getBaseCode("LanguageCode"));
			mav.addObject("themeColor", RedisDataUtil.getBaseCode("ThemeColor"));
			mav.addObject("portalBg", RedisDataUtil.getBaseCode("PortalBg"));
			mav.addObject("portalColor", RedisDataUtil.getBaseCode("PortalColor"));
			mav.addObject("siteLinkList", RedisDataUtil.getBaseCode("SiteLinkList"));
		}
		
		return mav;
	}
	
	//dock 처리 시작
	@RequestMapping(value = "layout/dock.do")
	public ModelAndView dock(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "cmmn/user_dock";
		//퀵메뉴 세팅
		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userId",SessionHelper.getSession("USERID"));
		CoviMap myInfo = sessionService.getMyInfo(params);

		CoviList allQuickMenu = RedisDataUtil.getBaseCode("QuickNotification");
		String quickMenuConf= myInfo.get("QuickMenuConf")!=null?((CoviMap)myInfo.get("QuickMenuConf")).getString("ShowList"):"";
		CoviList quickMenuData = new CoviList();
		String[] arrQuickMenu = quickMenuConf.split(";");
		
		for (int i=0; i < arrQuickMenu.length; i++){
			for (int j=0; j < allQuickMenu.size(); j++){
				CoviMap map = allQuickMenu.getJSONObject(j);
//				String myUse = "N";
				if(arrQuickMenu[i].equals(map.get("Code"))){
					quickMenuData.add(map);
//					myUse = "Y";
					break;
				}
//				map.put("MyUse",myUse);
			}
		}
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("myQuickMenu", quickMenuData);
		mav.addObject("lang", SessionHelper.getSession("lang"));
		mav.addObject("allQuickMenu", allQuickMenu);
		
		return mav;
	}
		
	
	@RequestMapping(value = "layout/home.do")
	public ModelAndView getHome(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Map<String, String> queries = splitQuery(request.getQueryString());
		String systemName =  Objects.toString(queries.get(PARAM_SYS), "core");
		String mode =  Objects.toString(queries.get(PARAM_MODE), "");
		String returnURL = "";
		if(systemName.equals("core")){
			returnURL = "core/Home";	
		} else {
			returnURL = mode.toLowerCase() + "/" + systemName.toLowerCase() + "/Home";
		}
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "layout/left.do")
	public ModelAndView getLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		List<CoviMap> licenseInfo=null;
		Map<String, String> queries = splitQuery(request.getQueryString());
		StringUtil func = new StringUtil();
		JSONSerializer jUtil = new JSONSerializer();
		String systemName =  Objects.toString(request.getParameter(PARAM_SYS), "core");
		String mode =  Objects.toString(request.getParameter(PARAM_MODE), "");
		String bizSect = Objects.toString(request.getParameter(PARAM_BIZ), "");
		//String menuId =  Objects.toString(queries.get("menuid"), "NONE");
		String loadContent =  Objects.toString(request.getParameter("loadContent"), "false");
		String approvalPage = Objects.toString(request.getParameter("mode"), "");
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		
		String domainId = userDataObj.getString("DN_ID");
		String domainCode = userDataObj.getString("DN_Code");
		String menuStr = ACLHelper.getMenu(userDataObj);
		String isAdmin = "N";
		String returnURL = "";
		
		if(mode.equalsIgnoreCase("admin")){
			isAdmin = "Y";
		}
		
		CoviList queriedMenu = null;
		
		if(StringUtils.isNoneBlank(menuStr)){
			CoviList menuArray = jUtil.jsonGetObject(menuStr);
			// menuArray로 부터 menuType, BizSection별로 쿼리
			queriedMenu = ACLHelper.parseMenuByBiz(domainId, isAdmin, bizSect, "Left", menuArray, userDataObj.getString("lang"));
		}
		
		if (mode.equals("manage")){	//라이선스 조회
			licenseInfo = ComUtils.getLicenseInfo(domainId);
			if (!SessionHelper.getSession("isAdmin").equals("Y")){// 관리자가 아닌데 메뉴인증을 통과했으면 간편관리자임. 
				SessionHelper.setSession("isEasyAdmin","Y");
			}	
		}
		returnURL = "cmmn/menu/" + makePrefix(systemName, mode, bizSect) + "Left";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("domainId", domainId);
		mav.addObject("domainCode", domainCode);
		mav.addObject("isAdmin", isAdmin);
		mav.addObject("leftMenuData", queriedMenu);
		mav.addObject("loadContent", loadContent);
		
		mav.addObject("licenseInfo", licenseInfo);
		mav.addObject("menuId",  Objects.toString(queries.get("menuid"), ""));
		mav.addObject("selDomainid", Objects.toString(queries.get("seldomainid"), ""));
		mav.addObject("seldomaincode", Objects.toString(queries.get("seldomaincode"), ""));
		if(systemName.equalsIgnoreCase("approval") && !"".equals(approvalPage)) {
			mav.addObject("approvalPage", approvalPage);
		}
		return mav;
	}
	
	@RequestMapping(value = "layout/footer.do")
	public ModelAndView getFooter(Locale locale, Model model) {
		return new ModelAndView("layout/footer");
	}
	
	//ajax 컨텐트 처리
	@RequestMapping(value = "layout/{programName}_{pageName}.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getContent(HttpServletRequest request, HttpServletResponse response, 
			@PathVariable String programName, 
			@PathVariable String pageName) throws Exception {
		StringUtil func = new StringUtil();
		
		String returnURL= "";
		Map<String, String> queries = splitQuery(request.getQueryString());
		String systemName =  Objects.toString(queries.get(PARAM_SYS), "core");
		String mode =  Objects.toString(queries.get(PARAM_MODE), "");
		
		if(systemName.equalsIgnoreCase("core")){
			returnURL = programName.toLowerCase() + "/" + pageName + ".core.content";
		}else if (systemName.equalsIgnoreCase("webhard")){
			returnURL = programName.toLowerCase() + "/" + pageName + ".webhard." + programName + "Content";
		}else if (systemName.equalsIgnoreCase("account")){
			returnURL = programName.toLowerCase() + "/" + pageName + "." + mode.toLowerCase() + ".accountcontent";
		}else if (systemName.equalsIgnoreCase("feed")){
			returnURL = programName.toLowerCase() + "/" + pageName + "." + mode.toLowerCase() + ".feedcontent";
		}else{
/*			if(pageName.equalsIgnoreCase("DefaultSetting")){
				Thread.sleep(400);
			}
*/			
			returnURL = programName.toLowerCase() + "/" + pageName + "." + mode.toLowerCase() + ".content";
		}
		
		if(func.f_NullCheck(Objects.toString(queries.get(PARAM_SMU), "")).equals("C")){
			returnURL = programName+"."+pageName+".communityMain";
			ModelAndView  mav = new ModelAndView(returnURL);
			mav.addObject("C", queries.get("communityId"));
			mav.addObject("communityId", queries.get("communityId"));
			mav.addObject("activeKey", queries.get("activeKey"));
			return mav;
		}else if(func.f_NullCheck(Objects.toString(queries.get(PARAM_SMU), "")).equals("CU")){
			returnURL = programName+"."+pageName+".communityWebPart";
			ModelAndView  mav = new ModelAndView(returnURL);
			mav.addObject("C", queries.get("communityId"));
			mav.addObject("communityId", queries.get("communityId"));
			mav.addObject("part", queries.get("part"));
			return mav;
		}else if(queries.containsKey("GovDocs")){
			returnURL = programName.toLowerCase() + "/" + pageName + "." + mode.toLowerCase() + ".content";
			return new ModelAndView(returnURL).addAllObjects(queries);
		}
		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * for Simple page move
	 * @param request
	 * @param response
	 * @param programName1
	 * @param programName2
	 * @param pageName
	 * @return
	 * @throws Exception
	 * 
	 *  /WEB-INF/views/programName1/programName2/pageName.jsp 호출
	 */
	@RequestMapping(value = "common_popup/{programName1}_{programName2}_{pageName}.do", method = RequestMethod.GET)
	public ModelAndView goDirectPage(HttpServletRequest request, HttpServletResponse response, 
			@PathVariable String programName1,  @PathVariable String programName2,  @PathVariable String pageName) throws Exception {
		String rtnUrl = programName1 + "/" + programName2 + "/" + pageName;
		return new ModelAndView(rtnUrl);
	}
	
	@RequestMapping(value = "/home.do", method = RequestMethod.GET)
	public ModelAndView goHome(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Map<String, String> queries = splitQuery(request.getQueryString());
		String systemName =  Objects.toString(queries.get(PARAM_SYS), "core");
		String mode =  Objects.toString(queries.get(PARAM_MODE), "");
		String returnURL = "";
		
		if(systemName.equalsIgnoreCase("Core")){
			returnURL = "core";
		} else {
			returnURL = systemName.toLowerCase() + "." + mode.toLowerCase();
		}
		
		return new ModelAndView(returnURL);
	}
	//layout 처리 끝
	
	@RequestMapping(value = "/control/removeLicenseCache.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap removeLicenseCache(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
			String removeMailCache = Objects.toString(request.getParameter("removeMailCache"), "N");
			String domainID = request.getParameter("domainID");
			
			//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리 
			if(isSaaS.equalsIgnoreCase("N")){
				domainID = "0";
			}else if(isSaaS.equalsIgnoreCase("Y") && domainID == null) {
				domainID = SessionHelper.getSession("DN_ID");
			}
			
			if(domainID != null) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + LicenseHelper.SUF_LIC_INFO);
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_CHECK);
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_STATE);				
	
				if(removeMailCache.equalsIgnoreCase("Y")) {
					instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_MAIL);
				}
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_INFO);
				CoviList clist = ComUtils.getLicenseInfo(domainID);
				
				for (int i=0; i< clist.size(); i++){
					CoviMap licenseData =clist.getMap(i);
					String licSeq = licenseData.getString("LicSeq");
					LicenseHelper.resetLicenseSortKey(domainID+"_"+licSeq);
				}	
//				LicenseHelper.resetLicenseSortKey(domainID+"_"+licSeq);
			}
			
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e){	
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}
	//Front Upload 
	@RequestMapping(value = "control/uploadToFront.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap uploadToFront(MultipartHttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviList fileInfos = CoviList.fromObject(request.getParameter("fileInfos"));
			List<MultipartFile> mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(FileUtil.isEnableExtention(mf)){
				returnList.put("list", fileSvc.uploadToFront(fileInfos, mf, FileUtil.checkTraversalCharacter(request.getParameter("servicePath"))));
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			} else {
				returnList.put("list", "0");
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
			}
		} catch(NullPointerException e){	
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
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
		if (url == null) return query_pairs;
	    String[] pairs = url.split("&");
	    for (String pair : pairs) {
	        int idx = pair.indexOf("=");
	        if (idx>0){
		        query_pairs.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"), URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
	        } 
	    }
	    return query_pairs;
	}
}
