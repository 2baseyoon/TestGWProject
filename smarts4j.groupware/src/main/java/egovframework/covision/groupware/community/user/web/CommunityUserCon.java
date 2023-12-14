package egovframework.covision.groupware.community.user.web;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.auth.CommunityAuth;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import egovframework.covision.groupware.util.BoardUtils;


import egovframework.baseframework.util.json.JSONSerializer;


@Controller
public class CommunityUserCon {
	
	private Logger LOGGER = LogManager.getLogger(CommunityUserCon.class);
	
	LogHelper logHelper = new LogHelper();
	
	@Autowired
	CommunityUserSvc communitySvc;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	PortalSvc portalSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	@RequestMapping(value = "layout/communityFavoritesSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityFavoritesSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();

			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_CODE", userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			
			resultList = communitySvc.communityFavoritesSetting(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/communityFavoritesDelete.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityFavoritesDelete(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			params.put("UR_CODE", SessionHelper.getSession("USERID") );
			params.put("CU_ID", request.getParameter("CU_ID"));
			
			if(!communitySvc.communityFavoritesDelete(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectUserJoinCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserJoinCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();

			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_CODE",userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("LIMIT", "");
			
			resultList = communitySvc.selectUserJoinCommunity(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/communityHotStorySetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityHotStorySetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("isSaaS", isSaaS);
			
			resultList = communitySvc.selectCommunityHotStory(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/communityFavoriteSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityFavoriteSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("UR_CODE", userDataObj.getString("USERID"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			
			resultList = communitySvc.selectCommunityFavorite(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/communitySearchWord.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySearchWord(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			params.put("isSaaS", isSaaS);
			
			resultList = communitySvc.selectCommunitySearchWord(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/communityNotice.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityNotice(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("UR_Code", userDataObj.getString("USERID"));
			params.put("bizSection",request.getParameter("bizSection"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Community", "V");
			if(authorizedObjectCodeSet.size() < 1) {
				authorizedObjectCodeSet.add("-1");
			}
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");
			params.put("isCommunityAdmin", SessionHelper.getSession("UR_Code"));
			
			int cnt = communitySvc.selectCommunityNoticeCnt(params);
			
			if(cnt > 0){
				resultList = communitySvc.selectCommunityNotice(params);				
				returnData.put("cnt",cnt);				
				returnData.put("list", resultList.get("list"));
			}else{
				returnData.put("cnt",cnt);
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
	
	@RequestMapping(value = "layout/communityFrequent.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityFrequent(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("UR_Code",userDataObj.getString("USERID"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			
			resultList = communitySvc.selectCommunityFrequent(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/newCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap newCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang", userDataObj.getString("lang"));
			params.put("UR_Code", userDataObj.getString("USERID"));
			params.put("DN_ID", userDataObj.getString("DN_ID"));
			
			resultList = communitySvc.selectNewCommunity(params);
			
			returnData.put("list", resultList.get("list"));
			
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
	
	@RequestMapping(value = "layout/selectUserCommunityGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserCommunityGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			
			if(params.get("sortBy") != null){
				params.put("sortColumn", params.get("sortBy").toString().split(" ")[0]);
				params.put("sortDirection", params.get("sortBy").toString().split(" ")[1]);
			}
			
			int cnt = communitySvc.selectUserCommunityGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectUserCommunityGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
 
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectCommunityTreeData.do" )
	public  @ResponseBody CoviMap selectCommunityTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		params.put("DN_ID", userDataObj.getString("DN_ID"));
		params.put("lang", userDataObj.getString("lang"));
		params.put("isSaaS", isSaaS);
		
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		result = (CoviList) communitySvc.selectCommunityTreeData(params).get("list");
		
		for(Object jsonobject : result){
			CoviMap folderData = new CoviMap();
			folderData = (CoviMap) jsonobject;
			
			String strDisplayName = "";
			strDisplayName = DicHelper.getDic(Integer.parseInt(params.get("DN_ID").toString()), "CUCT_"+folderData.get("FolderID"));
			strDisplayName = strDisplayName.equals("CUCT_"+folderData.get("FolderID")) ? folderData.get("DisplayName").toString() : strDisplayName;
			
			// 트리를 그리기 위한 데이터
			folderData.put("no", folderData.get("FolderID"));
			folderData.put("nodeName", strDisplayName);
			folderData.put("nodeValue", folderData.get("FolderID"));
			folderData.put("pno", folderData.get("MemberOf"));
			folderData.put("chk", "N");
			folderData.put("rdo", "N");
			//folderData.put("url", "javascript:selectCommunityTreeListByTree(\"" + folderData.get("FolderID") + "\", \"" + folderData.get("FolderType") + "\", \"" + folderData.get("FolderPath") + "\", \"" + folderData.get("FolderName") + "\" );");
			
			resultList.add(folderData);
		}
		returnList.put("list", resultList);
		returnList.put("result", "ok");
		
		return returnList;
		
	}
	
	@RequestMapping(value = "layout/communitySelectCreateId.do" )
	public  @ResponseBody CoviMap communitySelectCreateId(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String id = communitySvc.communitySelectCreateId(params);
			
			returnData.put("id", id);
			returnData.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
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
	
	@RequestMapping(value = "layout/selectParentSearch.do", method = RequestMethod.GET)
	public ModelAndView selectParentSearch(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/community/CommunityCategoryTreePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
			
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("CategoryID", request.getParameter("CategoryID"));
		mav.addObject("target", request.getParameter("target"));
		return mav;
	}
	
	@RequestMapping(value = "layout/checkCommunityName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkCommunityName(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		params.put("DisplayName",request.getParameter("DisplayName"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		if(communitySvc.checkCommunityNameCount(params) > 0){
			returnData.put("status", Return.FAIL);
		}else{
			returnData.put("status", Return.SUCCESS);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/selectCommunityBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityBaseCode(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			resultList = communitySvc.selectCommunityBaseCode(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	
	@RequestMapping(value = "layout/CommunityCreateSite.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityCreateSite(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		BoardUtils.setRequestParam(request, params);
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("txtOperator", userDataObj.getString("USERID"));
			params.put("userID",  userDataObj.getString("USERID")); 
			
			if(!communitySvc.communityNewCreateSite(params)){
				returnData.put("status", Return.FAIL);
			}else{
				params.put("UR_Code", userDataObj.getString("USERID")); 
				
				if(communitySvc.clearRedisCache(params)){
					
				}
				
				returnData.put("status", Return.SUCCESS);
			}
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	public boolean ACL(String ObjectID,String ObjectType,String SubjectCode,String SubjectType, String AclList, String Security, String Create, String Delete, String Modify, String Execute, String View, String Read, String Type, String userID, String IsInclude){
		CoviMap aclParams = new CoviMap();
		
		StringUtil func = new StringUtil();
		
		aclParams.put("ObjectID", ObjectID);
		aclParams.put("ObjectType", ObjectType);
		aclParams.put("SubjectCode", SubjectCode);
		aclParams.put("SubjectType", SubjectType);
		aclParams.put("AclList", AclList);
		aclParams.put("Security", Security);
		aclParams.put("Create", Create);
		aclParams.put("Delete", Delete);
		aclParams.put("Modify", Modify);
		aclParams.put("Execute", Execute);
		aclParams.put("View", View);
		aclParams.put("Read", Read);
		aclParams.put("IsInclude", IsInclude);
		aclParams.put("userCode", userID);
		try {
			if(func.f_NullCheck(Type).equals("U")){
				
				if(!communitySvc.updateCommunityACL(aclParams)){
					//return false;
				}
				
			}else if(func.f_NullCheck(Type).equals("C")){
				
				if(!communitySvc.createCommunityACL(aclParams)){
					return false;
				}
				
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}	  
		return true;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityMain.do")
	public ModelAndView communityMain(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "community.CommunityMain.communityMain";
		
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		
		params.put("UR_Code", SessionHelper.getSession("USERID")); 
		params.put("DN_ID", SessionHelper.getSession("DN_ID")); 
		params.put("CU_ID", request.getParameter("C")); 
		
		
   		if(communitySvc.selectCommunityApprovCheck(params) > 0){
			
			returnURL = "error";
			
			ModelAndView  mav = new ModelAndView(returnURL);
			
			return mav;
		}else if( communitySvc.selectCommunityHomepageCheck(params) == 0){
			returnURL = "error";
			
			ModelAndView  mav = new ModelAndView(returnURL);
			
			return mav;
		}
		
		if(communitySvc.selectCommunityVisitCnt(params) < 1 ){
			if(!communitySvc.insertCommunityVisit(params)){
				//실패 처리 없음.
			}
		}
		
		
		if(communitySvc.clearRedisCache(params)){
			
		}
		
		/*if(communitySvc.communityGroupMember(params)){
			if(communitySvc.clearRedisCache(params)){
				
			}
		}*/
		
		String checkValue = communitySvc.selectCommunityUserLevelCheck(params);
		String checkType = communitySvc.selectCommunityTypeCheck(params);
		
		String returnValue = "Y";
		
		if(!func.f_NullCheck(checkType).equals("") && func.f_NullCheck(checkType).equals("C")){
			if(func.f_NullCheck(checkValue).equals("") || func.f_NullCheck(checkValue).equals("0")){
				returnValue = "N";
			}
		}
		
		if(func.f_NullCheck(returnValue).equals("N")){
			returnURL = "community.CommunityInfo.communityMain";
		}
		
		CoviList webpartList = communitySvc.getWebpartList(params);
		String layoutTemplate = communitySvc.getLayoutTemplate(webpartList, params);
		
		CoviList webpartData = (CoviList)communitySvc.getWebpartData(webpartList);
		String javascriptString = communitySvc.getJavascriptString(webpartList);
		
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("javascriptString",javascriptString);
		mav.addObject("layout", layoutTemplate);
		mav.addObject("data",webpartData);
		mav.addObject("C", request.getParameter("C"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("CU_ID", request.getParameter("communityID"));
			params.put("DN_ID",userDataObj.getString("DN_ID"));
			params.put("UR_Code", userDataObj.getString("USERID")); 
			params.put("lang",userDataObj.getString("lang"));
			
			resultList = communitySvc.selectcommunityHeaderSetting(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySubHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySubHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID")); 
			
			resultList = communitySvc.communitySubHeaderSetting(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityLeftUserInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLeftUserInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("lang",userDataObj.getString("lang"));
			params.put("UR_Code",userDataObj.getString("USERID"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("IsAdmin", StringUtil.replaceNull(userDataObj.get("communityAdmin"),"N"));
			
			resultList = communitySvc.communityLeftUserInfo(params);
			
			returnData.put("USERNAME",userDataObj.getString("USERNAME"));
			returnData.put("UR_Code", userDataObj.getString("USERID"));
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}

	@RequestMapping(value = "layout/userCommunity/communityFavoritesAdd.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityFavoritesAdd(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			
			params.put("UR_CODE", SessionHelper.getSession("USERID") );
			params.put("CU_ID", request.getParameter("CU_ID"));
			
			if(!communitySvc.communityFavoritesInsert(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}

	@RequestMapping(value = "layout/userCommunity/setTopMenuPopup.do")
	public ModelAndView setTopMenuPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/community/CommunityTopMenuPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
			
		mav.addObject("C", request.getParameter("C"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityTopMenu.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityTopMenu(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityTopMenu(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}

	@RequestMapping(value = "layout/userCommunity/updateCommunityTopMenuUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCommunityTopMenuUse(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		try {
			
			if(!communitySvc.updateCommunityTopMenuUse(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}

			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/updateCommunityTopMenuSort.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCommunityTopMenuSort(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		BoardUtils.setRequestParam(request, params);
		
		try {
			if(!communitySvc.updateCommunityTopMenuSort(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", userDataObj.getString("USERID") );
			params.put("lang",userDataObj.getString("lang"));
			params.put("IsAdmin", StringUtil.replaceNull(userDataObj.get("communityAdmin"),"N"));
			
			if(communityUserInfoCheck(params)){
				
				if (StringUtil.replaceNull(userDataObj.get("communityAdmin"),"N").equals("N")) {
					Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Community", "V");
					if(authorizedObjectCodeSet.size() < 1) {
						authorizedObjectCodeSet.add("-1");
					}
					String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
					
					params.put("aclDataArr", objectArray);
					params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
					params.put("objectType", "FD");
					params.put("bizSection", "Community");
				}
				
				resultList = communitySvc.selectCommunityHeaderSettingList(params);
			}
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityBoardLeft.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityBoardLeft(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		CoviList result = new CoviList();
		
		boolean flag = true;
		String checkValue = "";
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_Code", userDataObj.getString("USERID") );
			params.put("lang", userDataObj.getString("lang"));
			
			String hasAdminAuth = (CommunityAuth.getAdminAuth(params)) ? "Y" : "N";
			String referer = request.getHeader("Referer");
			if (referer != null &&(referer.indexOf("CLMD=admin") > -1 || referer.indexOf("CLMD=manage") > -1)){
				hasAdminAuth = "Y";
			}
			params.put("IsAdmin", hasAdminAuth);
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Community", "V");
			if(authorizedObjectCodeSet.size() < 1) {
				authorizedObjectCodeSet.add("-1");
			}
			
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");
			
			if (StringUtil.replaceNull(userDataObj.get("communityAdmin"),"N").equals("Y")) {
				flag = true;
			} else {
				flag = communityUserInfoCheck(params);
			}
					
			result = (CoviList) communitySvc.selectCommunityBoardLeft(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", StringUtil.getSortNo(folderData.get("SortPath").toString()));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", StringUtil.getParentSortNo(folderData.get("SortPath").toString()));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				
				/*if(func.f_NullCheck(folderData.get("itemType")).equals("Root") || func.f_NullCheck(folderData.get("itemType")).equals("Folder")){
					folderData.put("url", "");
				}else{
					folderData.put("url", "javascript:goFolderContents(\"" + "Board" + "\", \"" + folderData.get("MenuID")+"\", \""+folderData.get("FolderID")+"\", \""+folderData.get("FolderType")+"\", \""+"1" + "\");");
				}*/
				 
				resultList.add(folderData);
			}
			
			if (StringUtil.replaceNull(userDataObj.get("communityAdmin"),"N").equals("Y")) {
				checkValue =  "9";
			} else {
				checkValue =  communitySvc.selectCommunityUserLevelCheck(params);
			}

			// 공개, 비공개 여부 조회
			String checkType = communitySvc.selectCommunityTypeCheck(params);
			
			returnData.put("memberLevel", checkValue);
			returnData.put("communityType", checkType);
			returnData.put("flag", flag);
			returnData.put("list", resultList);
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySelectTagCloud.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectTagCloud(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			resultList = communitySvc.selectCommunityTagCloud(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySelectNotice.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectNotice(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			params.put("UR_Code", userDataObj.getString("USERID") );
			params.put("lang", userDataObj.getString("lang"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Community", "V");
			if(authorizedObjectCodeSet.size() < 1) {
				authorizedObjectCodeSet.add("-1");
			}
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");
			params.put("isCommunityAdmin", SessionHelper.getSession("UR_Code"));
			
			int cnt = 0;
					
			cnt = communitySvc.selectCommunitySelectNoticeCount(params);
				
			params.addAll(ComUtils.setPagingData(params,cnt));	
				
			resultList = communitySvc.selectCommunitySelectNoticeList(params);
			
			returnData.put("pageSize", params.get("pageSize"));
			returnData.put("pageCount", params.get("pageCount"));
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	

	@RequestMapping(value = "layout/userCommunity/communitySelectActivity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectActivity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		List<String> paramList = new ArrayList<String>();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			StringBuilder dateArray = new StringBuilder();
			
			for(int i=18; i >= 0; i--){
				paramList.add(func.previousDate(i*-1));
				dateArray.append(func.previousDate(i*-1)).append(",");
			}
			
			String dateArrayStr = dateArray.substring(0, dateArray.length()-1);
			
			params.put("paramList", paramList);
			
			resultList = communitySvc.selectCommunityActivity(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("splitDate", dateArrayStr);
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityAuthCheck.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityAuthCheck(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			
			String checkValue = communitySvc.selectCommunityUserLevelCheck(params);
			String checkType = communitySvc.selectCommunityTypeCheck(params);
			
			String returnValue = "Y";
			
			if(!func.f_NullCheck(checkType).equals("") && func.f_NullCheck(checkType).equals("C")){
				if(func.f_NullCheck(checkValue).equals("")){
					returnValue = "N";
				}
			}
			
			returnData.put("value", returnValue);
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	
	public boolean communityUserInfoCheck(CoviMap params){
		StringUtil func = new StringUtil();
		
		try {
			if (StringUtil.replaceNull(SessionHelper.getSession("communityAdmin")).equals("Y")) {
				return true;
			} else {
				String checkValue = communitySvc.selectCommunityUserLevelCheck(params);
				if(!func.f_NullCheck(checkValue).equals("") && !func.f_NullCheck(checkValue).equals("0")){
					return true;
				}else{
					return false;
				}
			}
			
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
		
	}
	@RequestMapping(value = "layout/userCommunity/communityMovePagePopUp.do", method = RequestMethod.GET)//팝업
	public ModelAndView communityMovePagePopUp(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		String returnURL = "user/community/CommunityMemberLeavePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
	
		mav.addObject("cId", request.getParameter("cId"));
		mav.addObject("UName",request.getParameter("UName"));
		mav.addObject("URcode",request.getParameter("URcode"));
		mav.addObject("Type", "force");
		
		return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityMovePage.do", method = RequestMethod.GET)
	public ModelAndView communityInfoPage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "community."+request.getParameter("move")+".communityMain";
		ModelAndView  mav = new ModelAndView(returnURL);
	
		mav.addObject("C", request.getParameter("C"));
		return mav;
	}
	
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("CU_ID",request.getParameter("CU_ID"));
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityDetailInfo(params);
			
			returnData.put("list", resultList.get("list"));
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/setCurrentLocation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCurrentLocation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("CategoryID",request.getParameter("CategoryID"));
            params.put("lang", SessionHelper.getSession("lang"));
            
			resultList = communitySvc.selectCurrentLocation(params);
			
			returnData.put("list", resultList.get("list"));
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	@RequestMapping(value = "layout/userCommunity/communityVisitList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityVisitList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityVisitList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityUserJoin.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityUserJoin(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("RegMessage", request.getParameter("RegMessage") );
			params.put("MailAddress", request.getParameter("MailAddress") );
			params.put("NickName", request.getParameter("NickName") );
			params.put("CU_ID", request.getParameter("CU_ID") );
			
			if(communitySvc.selectCommunityMemberDuplyCnt(params) > 0){
				if(func.f_NullCheck( request.getParameter("JoinOption")).equals("A")){
					//즉시 승인.
					if(!communitySvc.communityJoinProcess(params,"CC")){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}else{
					//승인
					if(!communitySvc.communityJoinProcess(params,"PP")){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}
			}else{
				if(func.f_NullCheck( request.getParameter("JoinOption")).equals("A")){
					//즉시 승인.
					if(!communitySvc.communityUserJoin(params,request.getParameter("JoinOption"))){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}else{
					//승인
					if(!communitySvc.communityUserJoin(params,request.getParameter("JoinOption"))){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}
			}

			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityMemberManageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityMemberManageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityMemberManageGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityMemberManageGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/communityDeleteMemberGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityDeleteMemberGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityDeleteMemberGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityDeleteMemberGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityMemberGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityMemberGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityMemberGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityMemberGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/communityJoinProcess.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityJoinProcess(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", request.getParameter("UserCode"));
			params.put("userID", request.getParameter("UserCode"));
			params.put("CU_ID", request.getParameter("CU_ID"));
			
			//즉시 승인.
			if(!communitySvc.communityJoinProcess(params,request.getParameter("Type"))){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "layout/userCommunity/communityMemberMenageListExcelDownload.do")
	public ModelAndView communityMemberMenageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
			ModelAndView mav = new ModelAndView();
			String returnURL = "UtilExcelView";
			CoviMap resultList = new CoviMap();
			CoviMap viewParams = new CoviMap();
			try {
				String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
				
				String sortKey = request.getParameter("sortKey");
				String sortDirec = request.getParameter("sortWay");
				String[] headerNames = headerName.split("\\|");
				
				CoviMap params = new CoviMap();
				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("CU_ID", request.getParameter("CU_ID") );
				params.put("MemberLevel", '0' );
				
				resultList = communitySvc.communityMemberMenageListExcelList(params);
				
				viewParams.put("list", resultList.get("list"));
				viewParams.put("cnt", resultList.get("cnt"));
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "Community_JoinMember");
				
				mav = new ModelAndView(returnURL, viewParams);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			return mav;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "layout/userCommunity/communityDeleteMemberListExcelDownload.do")
	public ModelAndView communityDeleteMemberListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
			ModelAndView mav = new ModelAndView();
			String returnURL = "UtilExcelView";
			CoviMap resultList = new CoviMap();
			CoviMap viewParams = new CoviMap();
			try {
				String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
				
				String sortKey = request.getParameter("sortKey");
				String sortDirec = request.getParameter("sortWay");
				String[] headerNames = headerName.split("\\|");
				
				CoviMap params = new CoviMap();
				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("CU_ID", request.getParameter("CU_ID") );
				
				resultList = communitySvc.communityDeleteMemberListExcelList(params);
				
				viewParams.put("list", resultList.get("list"));
				viewParams.put("cnt", resultList.get("cnt"));
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "Community_SecessionMember");
				
				mav = new ModelAndView(returnURL, viewParams);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			return mav;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "layout/userCommunity/communityMemberListExcelDownload.do")
	public ModelAndView communityMemberListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
			ModelAndView mav = new ModelAndView();
			String returnURL = "UtilExcelView";
			CoviMap resultList = new CoviMap();
			CoviMap viewParams = new CoviMap();
			try {
				String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
				
				String sortKey = request.getParameter("sortKey");
				String sortDirec = request.getParameter("sortWay");
				String[] headerNames = headerName.split("\\|");
				
				CoviMap params = new CoviMap();
				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("CU_ID", request.getParameter("CU_ID") );
				
				resultList = communitySvc.communityMemberListExcelList(params);
				
				viewParams.put("list", resultList.get("list"));
				viewParams.put("cnt", resultList.get("cnt"));
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "Community_Member");
				
				mav = new ModelAndView(returnURL, viewParams);
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/selectMemberLevelBox.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMemberLevelBox(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			resultList = communitySvc.selectMemberLevelBox(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/communityMemberLevelChange.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityMemberLevelChange(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", request.getParameter("UserCode") );
			params.put("CU_ID", request.getParameter("CU_ID") );
			params.put("memberLevel", request.getParameter("memberLevel") );
			
			if(!communitySvc.communityMemberLevelChange(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityLeaveInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityLeaveInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityLeaveInfo(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/CommunityMemberLeavePopup.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityMemberLeavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();			
			params.put("UR_Code", request.getParameter("UR_Code"));
			params.put("CU_ID", request.getParameter("CU_ID"));
			params.put("LeaveMessage", request.getParameter("LeaveMessage"));
			params.put("isForce", request.getParameter("isForce"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			//즉시 승인.
			if(!communitySvc.communityMemberLeave(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	
	
	@RequestMapping(value = "layout/userCommunity/CommunityMemberLeave.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityMemberLeave(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			params.put("CU_ID", request.getParameter("CU_ID") );
			params.put("LeaveMessage", request.getParameter("LeaveMessage"));
			params.put("isForce", false);
			params.put("lang", SessionHelper.getSession("lang"));
			
			//즉시 승인.
			if(!communitySvc.communityMemberLeave(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityBoardRankInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityBoardRankInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityBoardRankInfo(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityVisitRankInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityVisitRankInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityVisitRankInfo(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityCallMember.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityCallMember(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityCallMember(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/CommunityCallMemberSendMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityCallMemberSendMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			CoviMap subParams = new CoviMap();
			
			String sendMail = request.getParameter("sendMail");
			String sendTodo = request.getParameter("sendTodo");
			CoviMap resultList = new CoviMap();
			int status = 0;
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("lang",SessionHelper.getSession("lang"));
		
			//커뮤니티 ID 가져오기 
			String cuName = communitySvc.selectCommunityName(params);
			params.put("communityName", "["+cuName+"] 커뮤니티 알림");
	
			String paramArr = StringUtil.replaceNull(request.getParameter("sendUserArr"), "");
			String[] paramValue = paramArr.split(";");

			String userID = "";
			String bodyText = "";
			String targetMail = "";
			
			CookiesUtil cUtil = new CookiesUtil();
			
			String key = cUtil.getCooiesValue(request);
			
			TokenHelper tokenHelper = new TokenHelper();
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			String decodeKey = tokenHelper.getDecryptToken(key);
			
			Map map = new HashMap();
			
			map = tokenParserHelper.getSSOToken(decodeKey);
			
			if(paramValue.length > 0){
					
				for(int num = 0; num < paramValue.length; num++){
					subParams = null;
					subParams = params;
																	  
					if(func.f_NullCheck(paramValue[num]).equals("")){ 
						subParams.put("UR_Code", paramArr);
						userID = paramArr;
					}else{
						subParams.put("UR_Code", paramValue[num]);
						userID = paramValue[num];
					}
					
					if(func.f_NullCheck(sendTodo).equals("Y")){
						//Message 업데이트 
						if(!communitySvc.communityCallMemberSendMessage(subParams)){
							status = 1;
						}
					}
					
					bodyText = callMemberSendMessageHtmlText(cuName, request.getParameter("sendMessageTxt") );
					
					if(func.f_NullCheck(sendMail).equals("Y")){
						targetMail = communitySvc.selectTargetCallMemberSendMessage(subParams);
						
						if(!func.f_NullCheck(targetMail).equals("")){
							LoggerHelper.auditLogger(userID, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "MailAddress");
							MessageHelper.getInstance().sendSMTP(map.get("name").toString(), map.get("mail").toString(), targetMail, "커뮤니티 연락 메일", bodyText, true); 
						}
						
					}
					
				}
			}else{
				status = 1;
			}
			
			
			if(status > 0){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	public String callMemberSendMessageHtmlText(String community, String text){
		String bodyText = "";
		
			bodyText = "<html>";
			bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
				bodyText += "<tbody>";
					bodyText += "<tr>";
						bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#b8bbbd'>";
							bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
										bodyText += community +" 연락 메일";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";	
					bodyText += "<tr>";
						bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4; border-bottom: 1px solid #d4d4d4;'>";
							bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
											bodyText += "<span style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">"+text+"</span>";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";
				
					bodyText += "<tr>";
						bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
						bodyText += "</td>";
					bodyText += "</tr>";	
				bodyText += "</tbody>";
			bodyText += "</table>";
		bodyText += "</html>";
		
		return bodyText;
	}
	
	
	@RequestMapping(value = "layout/userCommunity/CommunityUpdateInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityUpdateInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("userID", SessionHelper.getSession("USERID"));
			
			if(!communitySvc.communityUpdateInfo(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}else{
				params.put("UR_Code", request.getParameter("operatorCode")); 
				
				if(communitySvc.clearRedisCache(params)){
					
				}
			}
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/InviteCommunity.do", method = RequestMethod.GET)
	public ModelAndView inviteCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/community/CommunityInvitePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		mav.addObject("CU_ID", request.getParameter("CU_ID"));
		return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/selectCommunityAllianceGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityAllianceGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("isSaaS", isSaaS);
			
			int cnt = communitySvc.selectCommunityAllianceGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			returnData.put("page", params);
			
			resultList = communitySvc.selectCommunityAllianceGridList(params);
			
			returnData.put("list", resultList.get("list"));
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
	
	@RequestMapping(value = "layout/userCommunity/selectAlianceType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectAlianceType(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		params.put("codeGroup", request.getParameter("codeGroup"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		CoviMap listData = communitySvc.selectAlianceType(params);
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityAlliancePopup.do")
	public ModelAndView communityAlliancePopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/community/CommunityAlliancePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("CommunityID", request.getParameter("CommunityID"));
		mav.addObject("RecipientID", request.getParameter("RecipientID"));
		mav.addObject("status", request.getParameter("status"));
		mav.addObject("PartiID", request.getParameter("PartiID"));
		return mav;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityAllianceApprove.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityAllianceApprove(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("CU_ID", request.getParameter("communityID"));
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			String checkNum = "";
			
			if(func.f_NullCheck(request.getParameter("PartiID")).equals("")){
				checkNum = "X";
			}else{
				checkNum = "O";
			}
			
			
			if(!communitySvc.updateAllianceApprove(params, checkNum)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityAllianceList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityAllianceList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		params.put("lang",SessionHelper.getSession("lang"));

		CoviMap listData = communitySvc.communityAllianceList(params);
		
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/CommunityClosingUpdate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityClosingUpdate(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("lang",SessionHelper.getSession("lang"));

			if(!communitySvc.communityClosingUpdate(params)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityLayoutHeaderSet.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLayoutHeaderSet(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCord", SessionHelper.getSession("USERID"));
			
			if(!communitySvc.communityLayoutHeaderSet(params)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityLayoutDoorSet.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLayoutDoorSet(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			if(func.f_NullCheck(request.getParameter("Type")).equals("C")){
				if(!communitySvc.communityLayoutDoorSet(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}else if(func.f_NullCheck(request.getParameter("Type")).equals("D")){
				if(!communitySvc.communityLayoutDoorDelete(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}else if(func.f_NullCheck(request.getParameter("Type")).equals("U")){
				if(!communitySvc.communityLayoutDoorUpdate(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}else{
				returnData.put("status", Return.FAIL);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityDoorList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityDoorList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		CoviMap listData = communitySvc.selectCommunityDoorList(params);
		
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySelectDoorText.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectDoorText(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("DoorText", communitySvc.selectCommunityDoorText(params));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityLayoutDoorChange.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLayoutDoorChange(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCord", SessionHelper.getSession("USERID"));
			
			if(!communitySvc.communityLayoutDoorChange(params)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySelectDoor.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectDoor(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
	
		BoardUtils.setRequestParam(request, params);
		
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("BodyText", communitySvc.communitySelectDoor(params));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityImgSet.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityImgSet(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			//커뮤니티 용량 체크 필요
			if(communitySvc.selectCurrentFileSizeByCommunity(params) > 0){
				returnData.put("status", "MAX");
			}else{
				if(!communitySvc.communityImgSet(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communitySelectImage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectImage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		CoviMap listData = communitySvc.selectCommunityImageList(params);
		
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityImgDel.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityImgDel(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			if(!communitySvc.communityImgDel(params)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/communityImgChoice.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityImgChoice(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			if(!communitySvc.communityImgChoice(params)){
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/communitySearchWordPoint.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySearchWordPoint(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			if(!func.f_NullCheck(request.getParameter("SearchWord")).equals("")){
				if(!communitySvc.communitySearchWordPoint(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "layout/userCommunity/setCommunityStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCommunityStatus(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			if(communitySvc.updateCommunityStatus(params)){
				returnData.put("status", Return.SUCCESS);
			}else{
				returnData.put("status", Return.FAIL);
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}

	@RequestMapping(value = "/layout/communitySendSimpleMail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap communitySendSimpleMail(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			String receiverCode = request.getParameter("userCode");
			String bodyText = StringUtil.replaceNull(request.getParameter("bodyText"), "");

			params.put("receiverCode", receiverCode);
			params.put("bodyText", bodyText);
			params.put("CU_ID", request.getParameter("cid"));

			params.put("Code", "Invited");
			
			communitySvc.communitySendSimpleMail(params);
			
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException ex) {
			 LOGGER.debug("communitySendSimpleMail Failed [" + ex.getMessage() + "]");
			 LOGGER.error(ex.getLocalizedMessage(), ex);
			 returnList.put("status", Return.FAIL);
			 returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			 LOGGER.debug("communitySendSimpleMail Failed [" + ex.getMessage() + "]");
			 LOGGER.error(ex.getLocalizedMessage(), ex);
			 returnList.put("status", Return.FAIL);
			 returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	 }
	
	//커뮤니티 알림 메시지 Parameter 셋팅
	public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
		CoviMap notiParam = new CoviMap();
		notiParam.put("ObjectType", "CU");
		notiParam.put("ServiceType", "Community");
		notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
		notiParam.put("PopupURL", pNotifyParam.getString("URL"));
		notiParam.put("GotoURL", pNotifyParam.getString("URL"));
		notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
		notiParam.put("OpenType", "PAGEMOVE");									//페이지 이동 처리
		notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
		notiParam.put("MessageContext", pNotifyParam.get("Message"));
		notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
		notiParam.put("SenderCode", SessionHelper.getSession("USERID"));		//송신자 (세션 값 참조)
		notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
		notiParam.put("ReceiversCode", pNotifyParam.getString("UserCode"));		//조회된 수신자 코드
		notiParam.put("DomainID", SessionHelper.getSession("DN_ID"));
		MessageHelper.getInstance().createNotificationParam(notiParam);
		messageSvc.insertMessagingData(notiParam);
	}
	
	/**
	 * 수정요청/삭제/잠금 등의 코멘트 설정용 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "tf/goCommentPopup.do", method = RequestMethod.GET)
	public ModelAndView goCommentPopup(HttpServletRequest request) throws Exception{
		String returnURL = "user/tf/commentPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 운영자 변경 팝업
	 * 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "layout/userCommunity/ManagerChange.do", method = RequestMethod.GET)
	public ModelAndView ManagerChange(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/community/CommunityManagerChangePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		mav.addObject("CU_ID", request.getParameter("CU_ID"));
		return mav;
	}

	// 웹파트 커뮤니티 데이터 조회
	@RequestMapping(value = "layout/selectCommunityDataWebpart.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityDataWebpart(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			param.put("lang", userDataObj.getString("lang"));
			param.put("domainID", userDataObj.getString("DN_ID"));
				
			returnList.put("data", communitySvc.selectCommunityDataWebpart(param).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "community/communityJoinInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityJoinInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviMap resultUser = new CoviMap();
		CoviMap resultCommunity = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("CU_ID", request.getParameter("CU_ID"));
			
			resultUser = communitySvc.selectCommunityJoinUserInfo(params);
			resultCommunity = communitySvc.selectCommunityDetailInfo(params);
			
			returnData.put("userInfo", resultUser.get("list"));
			returnData.put("communityInfo", resultCommunity.get("list"));
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
}
