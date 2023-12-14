package egovframework.covision.groupware.base.web;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
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
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.CommonUtil;
import egovframework.covision.groupware.auth.CommunityAuth;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;


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
public class CommonCon {

	private Logger LOGGER = LogManager.getLogger(CommonCon.class);
	
	@Autowired
	private AuthorityService authSvc;
	
	@Autowired
	CommunityUserSvc communitySvc;

	@RequestMapping(value = "layout/CommunitySiteLeft.do")
	public ModelAndView communitySiteLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String returnURL = "cmmn/menu/CommunitySiteLeft";
		ModelAndView  mav = new ModelAndView(returnURL);
		StringUtil func = new StringUtil();
		String checkValue;
		CoviMap params = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("USERID")); 
		
		String cuID = request.getParameter("C");
		if(!StringUtil.isNull(request.getParameter("communityId"))) {
			cuID = request.getParameter("communityId");
		}

		params.put("CU_ID", cuID);
		//params.put("IsAdmin", func.replaceNull(request.getParameter("IsAdmin")));
		//if (!func.f_NullCheck(params.get("IsAdmin").toString()).trim().equals("") && params.get("IsAdmin").toString().trim().equals("Y")) {
		
		if (StringUtil.replaceNull(SessionHelper.getSession("communityAdmin"),"N").equals("Y")){
			checkValue =  "9";
		} else {
			checkValue =  communitySvc.selectCommunityUserLevelCheck(params);
		}

		if (checkValue==null || checkValue.equals("")) checkValue="0";
		 
		String communityType = communitySvc.selectCommunityTypeCheck(params);
		
		String hasAdminAuth = (CommunityAuth.getAdminAuth(params)) ? "Y" : "N";
		String referer = request.getHeader("Referer");
		String callByAdmin = referer != null && ((referer.indexOf("CLMD=admin") > -1 || referer.indexOf("CLMD=manage") > -1)) ? "Y" : "N";
		
		mav.addObject("hasAdminAuth", hasAdminAuth);
		mav.addObject("callByAdmin", callByAdmin);
		mav.addObject("memberLevel", checkValue);
		mav.addObject("communityType", communityType);
		return mav;
	}
	
	@RequestMapping(value = "layout/tab.do")
	public ModelAndView getTap(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "layout/tab";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "layout/multiTab.do")
	public ModelAndView getMultiTap(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "layout/multiTab";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "layout/workPortal.do", method=RequestMethod.GET)
	public ModelAndView getWorkPortal(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "layout/work_portal";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
		
	@RequestMapping(value = "menu/goTopMenuManagePopup.do", method=RequestMethod.GET)
	public ModelAndView gogoTopMenuManagePopup(HttpServletRequest request, Locale locale, Model model) throws Exception {
		String returnURL = "cmmn/TopMenuManagePopup";
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		String domainId = SessionHelper.getSession("DN_ID");
		String menuStr = ACLHelper.getMenu(userDataObj);
		
		JSONSerializer jUtil = new JSONSerializer();
		
		CoviList queriedMenu = null;
		if(StringUtils.isNoneBlank(menuStr)){
			CoviList menuArray = jUtil.jsonGetObject(menuStr);
			// menuArray로 부터 menuType, BizSection별로 쿼리
			queriedMenu = ACLHelper.parseMenu(domainId, "N", "Top", "0", menuArray);
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("topMenuData", queriedMenu);
		return mav;
	}
}
