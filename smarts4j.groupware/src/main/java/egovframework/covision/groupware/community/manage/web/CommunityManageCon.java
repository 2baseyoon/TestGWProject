package egovframework.covision.groupware.community.manage.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;
import egovframework.covision.groupware.util.BoardUtils;
import net.sf.jxls.transformer.XLSTransformer;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : MenuCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2017.06.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("manage")
public class CommunityManageCon {

	private static final Logger LOGGER = LogManager.getLogger(CommunityManageCon.class);
	
	@Autowired
	CommunitySvc communitySvc;
	
	@Autowired
	private MessageService messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	/*커뮤니티 목록*/
	@RequestMapping(value = "community/selectCommunityTreeDataAll.do" )
	public @ResponseBody CoviMap selectCommunityTreeDataAll(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		params.put("DN_ID", request.getParameter("domain"));
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("searchValue", request.getParameter("searchValue"));
		params.put("searchOption", request.getParameter("searchOption"));
		params.put("communityJoin", request.getParameter("communityJoin"));
		params.put("communityType", request.getParameter("communityType"));
		params.put("communityDetail", request.getParameter("communityDetail"));
		params.put("isAll", request.getParameter("isAll"));
		
		CoviList result = new CoviList();
		CoviList result2 = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
//		"DN_ID" : dnID,

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
	
		
	@RequestMapping(value = "community/communityProperty.do", method = RequestMethod.GET)
	public ModelAndView communityProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/CommunityPropertyPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("CategoryID", request.getParameter("CategoryID"));
		mav.addObject("MemberOf", request.getParameter("MemberOf"));
		mav.addObject("pType", request.getParameter("pType"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "community/modifyCommunity.do", method = RequestMethod.GET)
	public ModelAndView modifyCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/CommunityModifyPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	@RequestMapping(value = "community/createCommunity.do", method = RequestMethod.GET)
	public ModelAndView createCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/CommunityCreatePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	
	/*커뮤니티 분루 상세 조회*/
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
	
	/*커뮤니티 분루  트릭*/
	@RequestMapping(value = "community/selectParentSearch.do", method = RequestMethod.GET)
	public ModelAndView selectParentSearch(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/CommunityCategoryTreePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("CategoryID", request.getParameter("CategoryID"));
		mav.addObject("target", request.getParameter("target"));
		
		return mav;
	}
	
	/*커뮤니티 목록*/
	@RequestMapping(value = "community/selectCommunityTreeData.do" )
	public @ResponseBody CoviMap selectCommunityTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		String DN_ID = StringUtil.replaceNull(request.getParameter("DN_ID"), userDataObj.getString("DN_ID"));
		
		params.put("DN_ID", DN_ID);
		params.put("lang", userDataObj.getString("lang"));
		
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
	
	/*커뮤티니 분류 수정*/
	@RequestMapping(value = "community/updateCommunityProperty.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCommunityProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			BoardUtils.setRequestParam(request, params);
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("isSaaS", isSaaS);
			
			// 다국어 정보.
			String strMultiDisplayName = params.get("txtMultiDisplayName").toString();
			String[] multiName = strMultiDisplayName.split(";");
			if (multiName.length >= 4) {
				params.put("DIC_Code_ko", multiName[0]);
				params.put("DIC_Code_en", multiName[1]);
				params.put("DIC_Code_ja", multiName[2]);
				params.put("DIC_Code_zh", multiName[3]);
			}
			
			if(func.f_NullCheck(request.getParameter("MemberOf")).equals("") || func.f_NullCheck(request.getParameter("MemberOf")).equals("0")){
				params.put("FolderType", "Root");
				params.put("MemberOf", "0");
			}
			params.put("mode", request.getParameter("mode"));
			
			communitySvc.updateProperty(params);
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			String[] cause = e.getCause().toString().split(":");
			String errorType = (cause.length > 1) ? cause[1].trim() : e.getMessage();
			returnData.put("status", Return.FAIL);
			returnData.put("errorType", errorType);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/*커뮤니티  분류 삭제*/
	@RequestMapping(value = "community/deleteCategory.do", method = RequestMethod.POST)
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
		String returnURL = "manage/community/CommunityCategoryMoveTreePopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("paramArr", request.getParameter("paramArr"));
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		
		return mav;
	}
	
	//커뮤니티 분류 이동
	@RequestMapping(value = "community/moveCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
			String paramValue[] = paramArr.split(",");
			String userID = SessionHelper.getSession("USERID");
			String _selTreeId = StringUtil.replaceNull(request.getParameter("_selTreeId"), "");
			
			if(paramValue.length > 0){
				for(int num = 0; num < paramValue.length; num++){
					params.clear();
					params.put("userID", userID );
					if(func.f_NullCheck(paramValue[num]).equals("")){
						params.put("paramArr", paramArr);
					}else{
						params.put("paramArr", paramValue[num]);
					}
					params.put("MemberOf", _selTreeId);
					params.put("CategoryID", paramArr);
					
					if(func.f_NullCheck(params.getString("MemberOf")).equals("") || func.f_NullCheck(params.getString("MemberOf")).equals("0")){
						params.put("FolderType", "Root");
						params.put("MemberOf", "0");
					}else {
						params.put("FolderType", "Folder");
					}
					
					if(!_selTreeId.equals(paramArr)){
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

	/*커뮤니티 페쇄*/
	@RequestMapping(value = "community/closeCommunity.do", method = RequestMethod.POST)
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
				
//				params.put("Community",'Y');
//				/*communitySvc.updateCommunityCacheSync(params);*/
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	/*커큐니티 복원*/
	@RequestMapping(value = "community/restoreCommunity.do", method = RequestMethod.POST)
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
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	/*커뮤티니 정보*/
	@RequestMapping(value = "community/selectCommunityInfomation.do", method = RequestMethod.POST)
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
	/*커뮤니티 이름 중복 체크*/
	@RequestMapping(value = "community/checkCommunityName.do", method = RequestMethod.POST)
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
	/*커뮤니티 알리아스 중복 체크*/
	@RequestMapping(value = "community/checkCommunityAlias.do", method = RequestMethod.POST)
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
	/*커뮤니티 수정*/
	@RequestMapping(value = "community/editCommunityInfomation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap editCommunityInfomation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		CoviMap params = new CoviMap();
		CoviMap subParams = new CoviMap();
		
		BoardUtils.setRequestParam(request, params);
		
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("userID", SessionHelper.getSession("USERID") );
		
		String strMultiDisplayName = params.get("txtMultiDisplayName").toString();
		String[] multiName = strMultiDisplayName.split(";");
		
		if (multiName.length >= 4) {
			params.put("DIC_Code_ko", multiName[0]);
			params.put("DIC_Code_en", multiName[1]);
			params.put("DIC_Code_ja", multiName[2]);
			params.put("DIC_Code_zh", multiName[3]);
		}
		
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
	
	/*커뮤니티 알리아스 조회*/
	@RequestMapping(value = "community/selectCommunityAlias.do", method = RequestMethod.POST)
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
	/*개설신청 리스트*/
	@RequestMapping(value = "community/selectCommunityOpenGridList.do", method = RequestMethod.POST)
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
	/*개설승인*/
	@RequestMapping(value = "community/openCommunity.do", method = RequestMethod.POST)
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
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	/*개설 거부*/
	@RequestMapping(value = "community/rejectOpenCommunity.do", method = RequestMethod.POST)
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
			}
		}
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	/*페쇠 신청 리스트*/
	@RequestMapping(value = "community/selectCommunityCloseGridList.do", method = RequestMethod.POST)
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
	/*페쇠 상태 변경*/
	@RequestMapping(value = "community/StaticCommunityUpdate.do", method = RequestMethod.POST)
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
		
		returnData.put("status", Return.SUCCESS);
		
		return returnData;
	}
	
	/*커뮤티니 기본게시판*/
	@RequestMapping(value = "community/selectCommunityBoardSettingGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityBoardSettingGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			/*String assignedDomain = SessionHelper.getSession("AssignedDomain");
			String assignedDomainArr[] = assignedDomain.split("¶");
			
			params.put("domainCode", assignedDomainArr[1]);
			*/
			
			params.put("domainID", request.getParameter("domainID"));
			
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
	
	/*커뮤티니 기본게시판 사용유뮤 저장*/
	@RequestMapping(value = "community/boardSettingUseChange.do", method = RequestMethod.POST)
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
	
	/*커뮤티니 기본게시판 팝업*/
	@RequestMapping(value = "community/communityBoardSettingProperty.do", method = RequestMethod.GET)
	public ModelAndView communityBoardSettingProperty(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/CommunityBoardSettingPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("MenuID", request.getParameter("MenuID"));
		mav.addObject("mode", request.getParameter("mode"));
		
		return mav;
	}
	/*커뮤티니 기본게시판 저장*/
	@RequestMapping(value = "community/updateBoardSetting.do", method = RequestMethod.POST)
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
	
	
	//////////////////////////////////////////////////////////////////////////////

	
	
	
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
	

	
	@RequestMapping(value = "community/todoOperator.do", method = RequestMethod.GET)
	public ModelAndView todoOperator(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "manage/community/TodoOperatorPopup";
		ModelAndView  mav = new ModelAndView(returnURL);
		
		mav.addObject("DN_ID", request.getParameter("DN_ID"));
		mav.addObject("paramArr", request.getParameter("paramArr"));
		mav.addObject("notiMail", request.getParameter("notiMail"));
		mav.addObject("todoList", request.getParameter("todoList"));
		
		return mav;
	}
	
	@RequestMapping(value = "community/todoSendMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap todoSendMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		CoviMap params = new CoviMap();
		String paramArr = StringUtil.replaceNull(request.getParameter("paramArr"), "");
		String paramValue[] = paramArr.split(",");
		
		String userID = SessionHelper.getSession("USERID");
		String isMail = StringUtil.replaceNull(request.getParameter("notiMail"), "");
		String isTodo = StringUtil.replaceNull(request.getParameter("todoList"), "");
		
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
				params.put("sendMessage", cuName + " : " + request.getParameter("popup_prompt"));
				params.put("url", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
				
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
	

	
	
	@RequestMapping(value = "community/selectCommunityStaticGridList.do", method = RequestMethod.POST)
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
	
	@RequestMapping(value = "community/selectCommunityStaticSubGridList.do", method = RequestMethod.POST)
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
	

	@RequestMapping(value = "community/selectCommunityFolderType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityFolderType(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
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
	
	@RequestMapping(value = "community/communityBoardSettingInfo.do", method = RequestMethod.POST)
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
	
	// 간편관리자 커뮤니티 활동현황집계 엑셀다운로드
	@RequestMapping(value = "community/CommunityStaticCompileExcelFormatDownload.do")
	public void communityStaticExcelFormatDownload(HttpServletRequest request, HttpServletResponse response) {
		try {
			StringUtil func = new StringUtil();
            String FileName = "Community_"+func.getOutputId()+".xlsx";
            String sortKey = request.getParameter("sortKey");
            String sortDirec = request.getParameter("sortWay");
            String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Community_templete.xlsx");
            
            response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");
            response.setHeader("Content-Description", "JSP Generated Data");  
            response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
            response.getOutputStream().write(excelDownload(ExcelPath,request.getParameter("communityId"),sortKey,sortDirec));
            response.getOutputStream().flush();
            
		} catch (NullPointerException e) {
            LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
            LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
            LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	// 간편관리자 커뮤니티 활동현황집계 엑셀다운로드(전체)
	@RequestMapping(value = "community/CommunityStaticStatusExcelFormatDownload.do")
	public ModelAndView messageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			
			String DN_ID = request.getParameter("DN_ID");
			String CommunityType = request.getParameter("CommunityType");
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			String RegStatus = request.getParameter("RegStatus");
			String SearchOption = request.getParameter("SearchOption");
			String searchValue = request.getParameter("searchValue");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			
			String[] headerNames = headerName.split("\\|");
			
			CoviMap params = new CoviMap();
			
			params.put("DN_ID", DN_ID);
			params.put("CommunityType", CommunityType);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("RegStatus", RegStatus);
			params.put("SearchOption", SearchOption);
			params.put("searchValue", ComUtils.RemoveSQLInjection(searchValue, 100));
			
			CoviMap resultList = communitySvc.selectCommunityStaticGridExcelList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Community" );

			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}

	// 엑셀다운로드
	private byte[] excelDownload(String ExcelPath, String CU_ID, String sortKey, String sortDirec) throws Exception {
		ByteArrayOutputStream outputStream = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		CoviMap excelMap= new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();

		try {
			params.put("CU_ID", CU_ID);

			if (communitySvc.selectCommunityExcelInfoCount(params) > 0) {
				excelMap = communitySvc.selectCommunityExcelInfo(params);
				excelMap.put("OutputYear", func.getOutputYear());
			}

			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));

			List list = communitySvc.selectCommunityExcelLogDaily(params);
			excelMap.put("CommunityList",list);
			excelMap.put("Title","["+excelMap.get("CommunityName")+"] 커뮤니티 활동 현황");

			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, excelMap);

			outputStream = new ByteArrayOutputStream();
			resultWorkbook.write(outputStream);

			return outputStream.toByteArray();
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		} finally {
			if(outputStream != null) { try { outputStream.flush(); outputStream.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(fis != null) { try { fis.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
		}
	}
	
	/**
	 * 기본게시판 순서변경처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "community/moveFolder.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveFolder(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String domainID = request.getParameter("domainID");
			String menuID = request.getParameter("menuID");
			String sortKey = request.getParameter("sortKey");
			String communityType = request.getParameter("communityType");
			String mode = request.getParameter("mode");
			
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("menuID", menuID);
			params.put("orgSortKey", sortKey);
			params.put("communityType", communityType);
			params.put("mode", mode);
			
			if(params.get("sortBy") != null){
				params.put("sortColumn", params.get("sortBy").toString().split(" ")[0]);
				params.put("sortDirection", params.get("sortBy").toString().split(" ")[1]);
			}
			
			result = (CoviMap) communitySvc.selectBoardSettingSortKey(params).get("target");	//순서 변경할 sortkey 조회
			if(!result.isEmpty()){	//최상위 혹은 최하위에 해당하거나 순서 변경을 할 대상을 찾지 못할경우의 처리 
				//현재 sortkey를 검색된 sortkey로 update
				params.put("sortKey", result.get("SortKey"));
				
				int cnt = communitySvc.updateBoardSettingSortKey(params);
				if(cnt > 0 ){
					CoviMap targetParams = new CoviMap();
					targetParams.put("menuID", result.get("MenuID"));	//Target FolderID
					targetParams.put("domainID", domainID);
					targetParams.put("communityType", communityType);
					targetParams.put("sortKey", sortKey);
					communitySvc.updateBoardSettingSortKey(targetParams);
				}
			} else {
				returnData.put("message", DicHelper.getDic("msg_gw_UnableChangeSortKey"));
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
	
	@RequestMapping(value = "community/categoryUseChange.do", method = RequestMethod.POST)
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
}
