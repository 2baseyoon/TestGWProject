package egovframework.covision.groupware.community.admin.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;
import egovframework.covision.groupware.util.BoardUtils;



@Controller
public class CommunityCon {
	
	private Logger LOGGER = LogManager.getLogger(CommunityCon.class);
	
	@Autowired
	CommunitySvc communitySvc;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "layout/community/selectCommunityD.do" )
	public @ResponseBody CoviMap selectCommunityDomain(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		CoviList domainList = ComUtils.getAssignedDomainID();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("assignedDomain", domainList);
		
		CoviMap listData = communitySvc.selectCommunityDomain(params);
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityTreeData.do" )
	public @ResponseBody CoviMap selectCommunityTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		params.put("DN_ID", request.getParameter("domain"));
		params.put("lang",SessionHelper.getSession("lang"));
		
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		result = (CoviList) communitySvc.selectCommunityTreeData(params).get("list");
		
		int i = 0;
		
		for(Object jsonobject : result){
			CoviMap folderData = new CoviMap();
			folderData = (CoviMap) jsonobject;
			// 트리를 그리기 위한 데이터
			
			if(folderData.get("FolderType").equals("Root") && i == 0){
				params.put("pFolderID",  folderData.get("FolderID"));
				params.put("pFolderType", folderData.get("FolderType"));
				params.put("pFolderPath",  folderData.get("FolderPath"));
				i=1;
			}
			
			folderData.put("no", folderData.get("FolderID"));
			folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
			folderData.put("nodeValue", folderData.get("FolderID"));
			folderData.put("pno", folderData.get("MemberOf"));
			folderData.put("chk", "N");
			folderData.put("rdo", "N");
			
			/*if(folderData.get("FolderType").equals("Root") && folderData.get("FolderPath").equals("")){
				folderData.put("url", "javascript:selectCommunityTreeListByTree(\"" + folderData.get("FolderID") + "\", \"" + folderData.get("FolderType") + "\", \"" + "0" + "\", \"" + folderData.get("FolderName") + "\" );");
			}else{
				folderData.put("url", "javascript:selectCommunityTreeListByTree(\"" + folderData.get("FolderID") + "\", \"" + folderData.get("FolderType") + "\", \"" + folderData.get("FolderPath") + "\", \"" + folderData.get("FolderName") + "\" );");
			}*/
			
			resultList.add(folderData);
		}
		
		if(i==0){
			params.put("pFolderID", "");
			params.put("pFolderType", "");
			params.put("pFolderPath", "");
		}else{
			if(params.get("pFolderPath").equals("")){
				params.put("pFolderPath", "0");
			}
		}
		
		returnList.put("pFolderID", params.get("pFolderID"));
		returnList.put("pFolderType", params.get("pFolderType"));
		returnList.put("pFolderPath", params.get("pFolderPath"));
		returnList.put("list", resultList);
		returnList.put("result", "ok");
		
		return returnList;
	}

	@RequestMapping(value = "layout/community/selectCommunityTreeDataAll.do" )
	public @ResponseBody CoviMap selectCommunityTreeDataAll(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		params.put("DN_ID", request.getParameter("domain"));
		params.put("lang",SessionHelper.getSession("lang"));

		CoviList result = new CoviList();
		CoviList result2 = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		result = (CoviList) communitySvc.selectCommunityTreeData(params).get("list");
		result2 = (CoviList) communitySvc.selectCommunitySubGridList(params).get("list");;
		int i = 0;
		
		for(Object jsonobject : result){
			CoviMap folderData = new CoviMap();
			folderData = (CoviMap) jsonobject;
			folderData.put("CommunityName", folderData.get("FolderName"));	//추후 다국어로 변경
			folderData.put("CategoryID", folderData.get("MemberOf"));	//부모키
			folderData.put("CU_Code", folderData.get("FolderID"));	//추후 다국어로 변경
			folderData.put("CU_ID", "");	//추후 다국어로 변경
			folderData.put("DisplayName",folderData.get("RegisterCode"));	//추후 다국어로 변경
			resultList.add(folderData);
		}
		
		resultList.addAll(result2);
		returnList.put("list", resultList);
		returnList.put("result", "ok");
		
		return returnList;
	}
	
	
	@RequestMapping(value = "layout/community/selectCommunityGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/selectCommunitySubGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunitySubGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunitySubGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunitySubGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/categoryUseChange.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap categoryUseChange(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("CategoryID", request.getParameter("CategoryID"));
		params.put("IsUse", request.getParameter("IsUse"));
		
		try {
			if(!communitySvc.updateCategoryUseChange(params)){
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
	
	@RequestMapping(value = "layout/community/setCurrentLocation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCurrentLocation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			StringUtil func = new StringUtil();
			
			BoardUtils.setRequestParam(request, params);
			
			String categoryID = request.getParameter("CategoryID");
			
			if(func.f_NullCheck(categoryID).equals("")){
				categoryID = communitySvc.selectCategoryID(params);
				params.put("CategoryID", categoryID);
			}
			
			resultList = communitySvc.setCurrentLocation(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityBaseCode(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("domainID", params.getString("DomainID") == null ? SessionHelper.getSession("DN_ID") : params.getString("DomainID"));
			
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
	
	@RequestMapping(value = "community/communityProperty.do", method = RequestMethod.GET)
	public ModelAndView communityProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityPropertyPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("CategoryID", request.getParameter("CategoryID"));
		mav.addObject("MemberOf", request.getParameter("MemberOf"));
		mav.addObject("pType", request.getParameter("pType"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "community/selectProperty.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectProperty(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "community/updateCommunityProperty.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCommunityProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			BoardUtils.setRequestParam(request, params);
			params.put("userID", SessionHelper.getSession("USERID"));
			
			if(func.f_NullCheck(request.getParameter("MemberOf")).equals("") || func.f_NullCheck(request.getParameter("MemberOf")).equals("0")){
				params.put("FolderType", "Root");
				params.put("MemberOf", "0");
			}
			
			if(communitySvc.selectCommunitySortDuplyCount(params) > 0){
				returnData.put("status", Return.FAIL);
				returnData.put("errorType","Sort");
				return returnData;
			}
			
			if(func.f_NullCheck(request.getParameter("mode")).equals("E")){
				if(!communitySvc.updateCommunityProperty(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}else{
					if(!communitySvc.updateCommunitySortProperty(params)){
						returnData.put("status", Return.FAIL);
						return returnData;
					}else{
						CoviMap subProperties = communitySvc.selectCommunitySubProperty(params);
						
						if(subProperties.getInt("cnt") > 0){
							params.put("subCnt", subProperties.getString("cnt"));
							params.put("subCategoryID", subProperties.getString("subCategoryID"));
							
							if(!communitySvc.updateCommunitySubProperty(params)){
								returnData.put("status", Return.FAIL);
								return returnData;
							}else{
								returnData.put("status", Return.SUCCESS);
							}
						}else{
							returnData.put("status", Return.SUCCESS);
						}
					}
				}
			}else if(func.f_NullCheck(request.getParameter("mode")).equals("C")){
				if(!communitySvc.createCommunityProperty(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}else{
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			if(communitySvc.communityDictionaryCnt(params) > 0){
				if(!communitySvc.updateCommunityDictionary(params)){
					returnData.put("status", Return.FAIL);
				}
			}else{
				if(!communitySvc.createCommunityDictionary(params)){
					returnData.put("status", Return.FAIL);
				}
			}
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "community/selectParentSearch.do", method = RequestMethod.GET)
	public ModelAndView selectParentSearch(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityCategoryTreePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("CategoryID", request.getParameter("CategoryID"));
		mav.addObject("target", request.getParameter("target"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/deleteCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID);
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("paramArr", paramArr);
				}else{
					params.put("paramArr", paramValue[num]);
				}
				
				if(!communitySvc.deleteCategory(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}
			returnData.put("status", Return.SUCCESS);
		}else{
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "community/CommunityCategoryMove.do", method = RequestMethod.GET)
	public ModelAndView communityCategoryMove(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityCategoryMoveTreePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("paramArr", request.getParameter("paramArr"));
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/moveCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
			String paramValue[] = paramArr.split(",");
			String userID = SessionHelper.getSession("USERID");
			String selTreeId = StringUtil.replaceNull(request.getParameter("_selTreeId"), "");
			
			if(paramValue.length > 0){
				for(int num = 0; num < paramValue.length; num++){
					params.clear();
					params.put("userID", userID );
					if(func.f_NullCheck(paramValue[num]).equals("")){
						params.put("paramArr", paramArr);
					}else{
						params.put("paramArr", paramValue[num]);
					}
					params.put("MemberOf", request.getParameter("_selTreeId"));
					params.put("CategoryID", paramArr);
					
					if(func.f_NullCheck(params.getString("MemberOf")).equals("") || func.f_NullCheck(params.getString("MemberOf")).equals("0")){
						params.put("FolderType", "Root");
						params.put("MemberOf", "0");
					}else {
						params.put("FolderType", "Folder");
					}
					
					if(!selTreeId.equals(paramArr)){
						if(!communitySvc.moveCommunityCategory(params)){
							returnData.put("status", Return.FAIL);
							return returnData;
						}else{
							CoviMap subProperties = communitySvc.selectCommunitySubProperty(params);
							
							if(communitySvc.updateCommunitySortProperty(params) && subProperties.getInt("cnt") > 0){
								params.put("subCnt", subProperties.getString("cnt"));
								params.put("subCategoryID", subProperties.getString("subCategoryID"));
								
								if(!communitySvc.updateCommunitySubProperty(params)){
									returnData.put("status", Return.FAIL);
									return returnData;
								}
							}
						}
					}
				}
				returnData.put("status", Return.SUCCESS);
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
	
	@RequestMapping(value = "layout/community/closeCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap closeCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID );
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
				}
				params.put("RegStatus", "U");
				params.put("AppStatus", "UF");
				
				if(!communitySvc.updateCommunityStatus(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
				params.put("IsDisplay",'N');
				params.put("IsUse",'Y');
				if(!communitySvc.updateCommunityGroupCode(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
				params.put("IsUse",'N');
				
				communitySvc.updateCommunityGroupFD(params);
				
				params.put("Community",'Y');
				/*communitySvc.updateCommunityCacheSync(params);*/
				
				params.put("Code","ForcedApproval");
				
				//TODO-COMMUNITY
				if(sendMessaging(params)){
					// 실패 처리 없음
				}
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/restoreCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap restoreCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID );
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
					params.put("ObjectID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
					params.put("ObjectID", paramValue[num]);
				}
				params.put("RegStatus", "R");
				params.put("AppStatus", "RS");
				
				if(!communitySvc.restoreCommunity(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
				params.put("Code","CloseRestoration");
				
				//TODO-COMMUNITY
				if(sendMessaging(params)){
					// 실패 처리 없음
				}
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	@RequestMapping(value = "community/createCommunity.do", method = RequestMethod.GET)
	public ModelAndView createCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityCreatePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/checkCommunityName.do", method = RequestMethod.POST)
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
	
	@RequestMapping(value = "layout/community/checkCommunityAlias.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkCommunityAlias(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		params.put("CU_Code",request.getParameter("DisplayCode"));
		
		if(communitySvc.checkCommunityAliasCount(params) > 0){
			returnData.put("status", Return.FAIL);
		}else{
			returnData.put("status", Return.SUCCESS);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/editCommunityInfomation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap editCommunityInfomation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		CoviMap params = new CoviMap();
		CoviMap subParams = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("userID", SessionHelper.getSession("USERID") );
		
		if(func.f_NullCheck(request.getParameter("mode")).equals("C")){
			
			params.put("opCode", params.get("txtOperator").toString()); 
			
			if(!communitySvc.communityNewCreateSite(params)){
				returnData.put("status", Return.FAIL);
			}else{
				params.put("UR_Code", params.get("txtOperator").toString()); 
				
				if(communitySvc.clearRedisCache(params)){
					
				}
				
				returnData.put("status", Return.SUCCESS);
			}
			
		}else{
			if(!communitySvc.editCommunityInfomation(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			if(communitySvc.selectCommunityDetailInfomationCount(params) > 0){
				if(!communitySvc.updateCommunityDetailInfomation(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}else{
				if(!communitySvc.createCommunityDetailInfomation(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}
			
			subParams = communitySvc.selectCommunityInfo(params);
			
			if(func.f_NullCheck(request.getParameter("ddlType")).equals("P")){
				//공개
				if(!ACL(request.getParameter("CU_ID"), "CU", subParams.get("CategoryID").toString(), "CM" ,"_____VR", "_", "_", "_", "_", "_", "V", "R", "U", params.get("userID").toString())){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}else{
				//비공개
				if(!ACL(request.getParameter("CU_ID"), "CU", subParams.get("CategoryID").toString(), "CM" ,"_______", "_", "_", "_", "_", "_", "_", "_", "U", params.get("userID").toString())){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
			}
			
			if(communitySvc.communityCnt(params) > 0){
				if(!communitySvc.updateCommunityNameDictionary(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}else{
				if(!communitySvc.createCommunityNameDictionary(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}
			
			/*params.put("UR_Code", params.get("operatorCode").toString()); 
			
			if(communitySvc.clearRedisCache(params)){
				
			}*/
		}
		
		/*if(communitySvc.communityCnt(params) > 0){
			if(!communitySvc.updateCommunityNameDictionary(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
		}else{
			if(!communitySvc.createCommunityNameDictionary(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
		}*/
		returnData.put("status", Return.SUCCESS);
		return returnData;
	}
	
	public boolean ACL(String ObjectID,String ObjectType,String SubjectCode,String SubjectType, String AclList, String Security, String Create, String Delete, String Modify, String Execute, String View, String Read, String Type, String userID){
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
	
	@RequestMapping(value = "community/modifyCommunity.do", method = RequestMethod.GET)
	public ModelAndView modifyCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityModifyPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityInfomation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityInfomation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			String DIC_Code = communitySvc.selectDICCode(params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("DIC_Code", DIC_Code);
			
			resultList = communitySvc.selectCommunityInfomation(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "community/todoOperator.do", method = RequestMethod.GET)
	public ModelAndView todoOperator(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/TodoOperatorPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("paramArr", request.getParameter("paramArr"));
		mav.addObject("notiMail", request.getParameter("notiMail"));
		mav.addObject("todoList", request.getParameter("todoList"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/todoSendMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap todoSendMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		CoviMap params = new CoviMap();
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		
		String userID = SessionHelper.getSession("USERID");
		String isMail = request.getParameter("notiMail") == null ? "" : request.getParameter("notiMail");
		String isTodo = request.getParameter("todoList") == null ? "" : request.getParameter("todoList");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID);
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
				}
				
				CoviMap result = communitySvc.selectCommunityOperatorInfo(params).getJSONArray("list").getJSONObject(0);
				String opUserCode = result.getString("OperatorCode");
				String mailAddress = result.getString("MailAddress");
				String cuName = result.getString("CommunityName");
				
				params.put("DN_ID", request.getParameter("dnID"));
				params.put("sendMessage", request.getParameter("popup_prompt"));
				params.put("url", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Communi");
				
				if(isTodo.equals("Y") && !func.f_NullCheck(opUserCode).equals("")){
					params.put("OpUR_Code", opUserCode);
					
					if(!communitySvc.insertTodoSendMessage(params)){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}
				
				if(isMail.equals("Y") && !func.f_NullCheck(mailAddress).equals("")){
					CookiesUtil cUtil = new CookiesUtil();
					String key = cUtil.getCooiesValue(request);
					TokenHelper tokenHelper = new TokenHelper();
					TokenParserHelper tokenParserHelper = new TokenParserHelper();
					String decodeKey = tokenHelper.getDecryptToken(key);
					Map map = new HashMap();
					
					map = tokenParserHelper.getSSOToken(decodeKey);
					String bodyText = callOperatorSendMessageHtmlText(cuName, request.getParameter("popup_prompt") );
					
					LoggerHelper.auditLogger(userID, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "MailAddress");
					MessageHelper.getInstance().sendSMTP(map.get("name").toString(), map.get("mail").toString(), mailAddress, "커뮤니티 운영자 연락 메일", bodyText, true); 
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		}else{
			returnData.put("status", Return.FAIL);
		}
		
		returnData.put("status", Return.SUCCESS);
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityOpenGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityOpenGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityOpenGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityOpenGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/openCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap openCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID);
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
					params.put("ObjectID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
					params.put("ObjectID", paramValue[num]);
				}
				
				params.put("RegStatus", "R");
				params.put("AppStatus", "RV");
				
				if(!communitySvc.openCommunity(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
				params.put("Code","CreateApproval");
				params.put("SubCode","CCAC");
				
				//TODO-COMMUNITY
				if(sendMessaging(params)){
					// 실패 처리 없음
				}
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	
	@RequestMapping(value = "layout/community/rejectOpenCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap rejectOpenCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID);
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
					params.put("ObjectID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
					params.put("ObjectID", paramValue[num]);
				}
				
				params.put("RegStatus", "P");
				params.put("AppStatus", "RD");
				
				if(!communitySvc.updateCommunityStatus(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				
				params.put("Code","CreateRejectl");
				params.put("SubCode","CCAR");
				
				//TODO-COMMUNITY
				if(sendMessaging(params)){
					// 실패 처리 없음
				}
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityCloseGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityCloseGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityCloseGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityCloseGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/StaticCommunityUpdate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap staticCommunityUpdate(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		String userID = SessionHelper.getSession("USERID");
		
		if(paramValue.length > 0){
			for(int num = 0; num < paramValue.length; num++){
				params.clear();
				params.put("userID", userID);
				
				if(func.f_NullCheck(paramValue[num]).equals("")){
					params.put("CU_ID", paramArr);
					params.put("ObjectID", paramArr);
				}else{
					params.put("CU_ID", paramValue[num]);
					params.put("ObjectID", paramValue[num]);
				}
				
				if(func.f_NullCheck(request.getParameter("AppStatus")).equals("UV")){
					params.put("RegStatus", "U");
				}else{
					params.put("RegStatus", "");
				}
				
				params.put("AppStatus", request.getParameter("AppStatus"));
				
				if(!communitySvc.staticCommunityUpdate(params)){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
			}
		}
		
		if(func.f_NullCheck(request.getParameter("AppStatus")).equals("UV")){
			params.put("Code", "CloseApproval");
			
			//TODO-COMMUNITY
			if(!sendMessaging(params)){
				
			}
		}else if(func.f_NullCheck(request.getParameter("AppStatus")).equals("UD")){
			params.put("Code", "CloseReject");
			
			//TODO-COMMUNITY
			if(!sendMessaging(params)){
				
			}
		}else{
			
			//RF 활동정지 코드 없음 
			/*params.put("Code", "");
			if(!sendMessaging(params)){
				
			}*/
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityStaticGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityStaticGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityStaticGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityStaticGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/selectCommunityStaticSubGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityStaticSubGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			int cnt = communitySvc.selectCommunityStaticSubGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityStaticSubGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/selectCommunityBoardSettingGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityBoardSettingGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			String assignedDomain = SessionHelper.getSession("AssignedDomain");
			String assignedDomainArr[] = assignedDomain.split("¶");
			
			params.put("domainCode", assignedDomainArr[1]);
			
			int cnt = communitySvc.selectCommunityBoardSettingGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityBoardSettingGridList(params);
			
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
	
	@RequestMapping(value = "layout/community/boardSettingUseChange.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap boardSettingUseChange(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("MenuID", request.getParameter("MenuID"));
		params.put("IsUse", request.getParameter("IsUse"));
		
		try {
			if(!communitySvc.updateBoardSettingUseChange(params)){
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
	
	@RequestMapping(value = "community/communityBoardSettingProperty.do", method = RequestMethod.GET)
	public ModelAndView communityBoardSettingProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "admin/community/CommunityBoardSettingPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("MenuID", request.getParameter("MenuID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/community/updateBoardSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateBoardSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
		
		BoardUtils.setRequestParam(request, params);
		
		try {
			if(mode.equals("E")){
				if(!communitySvc.updateBoardSetting(params)){
					returnData.put("status", Return.FAIL);
				}else{
					returnData.put("status", Return.SUCCESS);
				}
			}else if(mode.equals("C")){
				if(!communitySvc.createBoardSetting(params)){
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
	
	@RequestMapping(value = "layout/community/selectCommunityFolderType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityFolderType(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityFolderType(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/communityBoardSettingInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityBoardSettingInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.communityBoardSettingInfo(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "layout/community/selectCommunityAlias.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityAlias(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			returnData.put("alias", communitySvc.selectCommunityAlias(params));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
		CoviMap notiParam = new CoviMap();
		notiParam.put("ObjectType", "CU");
		notiParam.put("ServiceType", "Community");
		notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
		notiParam.put("PopupURL", pNotifyParam.getString("URL"));
		notiParam.put("GotoURL", pNotifyParam.getString("URL"));
		notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
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
	
	public boolean sendMessaging(CoviMap params){
		List list = new ArrayList();
		
		try {
			params.put("lang",SessionHelper.getSession("lang"));
			
			if(params.get("Code").equals("CloseApproval") || params.get("Code").equals("CreateRejectl") || params.get("Code").equals("CreateApproval") || params.get("Code").equals("ForcedApproval") || params.get("Code").equals("CloseRestoration") || params.get("Code").equals("CloseReject") || params.get("Code").equals("CloseApproval")){
				list = communitySvc.sendMessagingCommunityOperator(params);
			}else{
				list = communitySvc.sendMessagingList(params);
			}
			
			if(list.size() > 0){
				CoviMap FolderParams = new CoviMap();
				
				for(int j = 0; j < list.size(); j ++){
					FolderParams = (CoviMap) list.get(j);
					FolderParams.put("Code", params.get("Code"));
					FolderParams.put("Category", "Community");
					
					if(FolderParams.get("Code").equals("CloseApproval")){
						FolderParams.put("Title", "커뮤니티 : "+ FolderParams.get("CommunityName") + " 폐쇄신청이 승인되었습니다.");
						FolderParams.put("Message", FolderParams.get("CommunityName") +" 폐쇄신청이 승인되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CloseReject")){
						FolderParams.put("Title", "커뮤니티 : "+ FolderParams.get("CommunityName") + " 폐쇄 거부 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName") +"가 폐쇄거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CloseRequest")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 폐쇄 신청 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티 폐쇄가 신청되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CloseRestoration")){
						FolderParams.put("Title", "커뮤니티 : 폐쇄된 "+ FolderParams.get("CommunityName") + " 커뮤니티가 관리자에 의해 복원되었습니다.");
						FolderParams.put("Message", "폐쇄된 "+ FolderParams.get("CommunityName") +" 커뮤니티가 관리자에 의해 복원되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CreateApproval")){
						if(params.get("SubCode").equals("CCAR")){
							FolderParams.put("Title", "커뮤니티 : "+ FolderParams.get("CommunityName") + " 개설신청이  거부되었습니다.");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" 개설신청이 거부되었습니다.");
						}else{
							FolderParams.put("Title", "커뮤니티 : "+ FolderParams.get("CommunityName") + " 개설신청이 승인되었습니다.");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" 개설신청이 승인되었습니다.");
						}
						
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CreateRequest")){
						if(params.get("SubCode").equals("SCCA")){
							FolderParams.put("Title", FolderParams.get("CommunityName") + " 커뮤니티 생성 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") +" 커뮤니티 생성 알림");
						}else{
							FolderParams.put("Title", FolderParams.get("CommunityName") + " 커뮤니티 신청 알림");
							FolderParams.put("Message", FolderParams.get("CommunityName") + " 커뮤니티 신청 알림");
						}
						
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("ForcedApproval")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티가 관리자에 의해 강제로 폐쇄되었습니다.");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티가 관리자에 의해 강제로 폐쇄되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CuMemberContact")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티 알림");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("Invited")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티 초대");
						FolderParams.put("Message", FolderParams.get("CommunityName")+ "커뮤니티 초대 알림");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("JoiningApproval")){
						FolderParams.put("Title", "커뮤니티 : 커뮤니티 만들기 "+FolderParams.get("CommunityName")+" 가입 승인 알림");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티 가입 승인 알림");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("PartiNotice")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티  제휴요청");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티  제휴 요청  알림");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}else if(FolderParams.get("Code").equals("CreateRejectl")){
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티  개설거부 알림.");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" 커뮤니티 개설 거부되었습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
					}
					
					notifyCommunityAlarm(FolderParams);
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
	
	public String callOperatorSendMessageHtmlText(String community, String text){
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
										bodyText += community +" 운영자 연락 메일";
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
}
