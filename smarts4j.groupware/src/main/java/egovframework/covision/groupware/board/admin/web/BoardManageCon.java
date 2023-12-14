package egovframework.covision.groupware.board.admin.web;

import java.io.File;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.util.BoardUtils;


import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.util.XSSMultipartResolver;

/**
 * @Class Name : BoardManageCon.java
 * @Description : [관리자] 업무시스템 - 게시 관리
 * @Modification Information 
 * @ 2017.04.27 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 04.27
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BoardManageCon {
	
	private Logger LOGGER = LogManager.getLogger(BoardManageCon.class);
	
	@Autowired
	BoardManageSvc boardManageSvc;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	CommunityUserSvc communitySvc;
	
	@Autowired
	AuthorityService authSvc;
	
	@Autowired
	private FileUtilService fileUtilService;
	
	@Autowired
	XSSMultipartResolver multipartResolver;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 관리 도메인 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectDomainList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectDomainList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			CoviList domainList = (CoviList) boardManageSvc.selectDomainList(params).get("list");
			
			returnList.put("list", domainList);
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
	 * 통합게시 메뉴 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectMenuList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectMenuList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList domainList = new CoviList();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try{
			String isAdmin = SessionHelper.getSession("isAdmin");
			String domainID = request.getParameter("domainID");
			String bizSection = request.getParameter("bizSection");
			String menuID = "";
			
			if(!func.f_NullCheck(request.getParameter("communityID")).equals("")){
				params.put("communityID", request.getParameter("communityID"));
				domainList = (CoviList) boardManageSvc.selectCommunityList(params).get("list");
			}else{
				if("Board".equals(bizSection)){
					menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
				} else {
					menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("DocMenu", domainID));
				}
				
				params.put("menuID", menuID.split(";"));
				params.put("lang", SessionHelper.getSession("lang"));
				
				
				if(!"Y".equalsIgnoreCase(isAdmin)) {
					Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "MN", "", "V");
					String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
					
					params.put("menuAclDataArr", objectArray);
				}
				
				domainList = (CoviList) boardManageSvc.selectMenuList(params).get("list");
			}
			
			
			returnList.put("list", domainList);
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
	 * 게시판 트리메뉴 조회
	 * @param request domainID, menuID
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectFolderTreeData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderTreeList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String domainID = request.getParameter("domainID");
		String bizSection = request.getParameter("bizSection");
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		try{
			CoviMap params = new CoviMap();
				
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			params.put("lang", SessionHelper.getSession("lang"));
			String menuID = "";
			if("Board".equals(bizSection)){
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			} else {
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("DocMenu", domainID));
			}
			params.put("menuID", menuID.split(";"));
			result = (CoviList) boardManageSvc.selectTreeFolderMenu(params).get("list");
		    
		    for(Object jsonobject : result){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				//folderData.put("url", "javascript:selectFolderGridListByTree(\"" + folderData.get("MenuID") + "\", \"" + folderData.get("FolderID") + "\", \"" + folderData.get("FolderType") + "\", \"" + folderData.get("FolderPath") + "\" );");
				
				resultList.add(folderData);
			}
			returnList.put("list", resultList);
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
	 * 검색조건용 게시판 트리메뉴 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectSearchFolderTree.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectSearchFolderTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String domainID = request.getParameter("domainID");
		String bizSection = request.getParameter("bizSection");
		CoviMap params = new CoviMap();
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		try{
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			String menuID = "";
			if("Board".equals(bizSection)){
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			} else {
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("DocMenu", domainID));
			}
			params.put("menuID", menuID.split(";"));
			
			result = (CoviList) boardManageSvc.selectTreeFolderMenu(params).get("list");
		    
		    for(Object jsonobject : result){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				folderData.put("url", "#");
				folderData.put("rdo", "Y");
				resultList.add(folderData);
			}
			returnList.put("list", resultList);
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
	
	
	// Left Menu 관련 Controller 종료 //
	
	// Contents -  Folder Grid 조회 //
	
	/**
	 * 게시 관리 - 폴더/게시판 목록 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectFolderGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFolderGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {			
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			resultList = boardManageSvc.selectFolderGridList(params);
			
			returnData.put("page", resultList.get("page"));
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
	// Contents - FolderGrid 종료 //
	
	/**
	 * 게시 - 추가/수정 설정 팝업 호출
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goBoardConfigPopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardConfigPopup(HttpServletRequest request, Locale locale, Model model, @RequestParam Map<String, String> paramMap) throws Exception{
		String returnURL = "admin/board/boardManageConfigPopup";
		String bizSection = request.getParameter("bizSection");
		String domainID = request.getParameter("domainID");
		String communityID = request.getParameter("CommunityID");
		String folderID = request.getParameter("folderID");
		
		CoviMap params = new CoviMap();
		params.put("bizSection", bizSection);
		params.put("domainID", domainID);
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("lang", SessionHelper.getSession("lang"));
		
		StringUtil func = new StringUtil();
		String folderPathName = "";
		CoviList folderTypeList = new CoviList();
		
		if(!func.f_NullCheck(communityID).equals("")){
			params.put("communityID", communityID);
			String type = "";
			
			if(func.f_NullCheck(request.getParameter("mode")).equals("create")){
				type = "C";
			}else{
				type = "M";
			}
			
			folderTypeList = (CoviList) boardManageSvc.selectCommunityFolderTypeList(params, type).get("list");
		}else{
			folderTypeList = (CoviList) boardManageSvc.selectFolderTypeList(params).get("list");
			if(!func.f_NullCheck(folderID).equals("") && func.f_NullCheck(request.getParameter("mode")).equals("create")){
				params.put("folderID", folderID);
				CoviMap configMap = boardManageSvc.selectBoardConfig(params);
				folderPathName = configMap.getString("FolderPathName")+configMap.getString("DisplayName")+";";
			}
		}
		
		CoviList securityLevelList = (CoviList) boardManageSvc.selectSecurityLevelList(params).get("list");
		
		CoviMap item = new CoviMap();
		//지정 안함 옵션 항목 추가
		item.put("optionValue", "");
		item.put("optionText", DicHelper.getDic("lbl_NotSpecified"));
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);
		mav.addObject("bizSection", bizSection);
		mav.addObject("folderTypeList",folderTypeList);
		mav.addObject("securityLevelList", securityLevelList);
		mav.addObject("CommunityID", communityID);
		mav.addObject("domainID", domainID);
		mav.addObject("folderPathName", folderPathName);
		mav.addObject("useBoardInherited", RedisDataUtil.getBaseConfig("useBoardInherited", domainID));
		return mav;
	}
	
	/**
	 * 게시 - 추가/수정 설정 팝업 호출
	 * @param request
	 * @param paramMap
	 * @return mav
	 */
	@RequestMapping(value = "admin/goFolderManagePopup.do", method = RequestMethod.GET)
	public ModelAndView goFolderManagePopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception{
		String returnURL = "manage/board/FolderManagePopup";
		String bizSection = request.getParameter("bizSection");
		String domainID = request.getParameter("domainID");
		String communityID = request.getParameter("CommunityID");
		
		CoviMap params = new CoviMap();
		params.put("bizSection", bizSection);
		params.put("domainID", domainID);
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("lang", SessionHelper.getSession("lang"));
		
		StringUtil func = new StringUtil();
		CoviList folderTypeList = new CoviList();
		
		if(!func.f_NullCheck(communityID).equals("")){
			params.put("communityID", communityID);
			String type = "";
			
			if(func.f_NullCheck(request.getParameter("mode")).equals("create")){
				type = "C";
			}else{
				type = "M";
			}
			
			folderTypeList = (CoviList) boardManageSvc.selectCommunityFolderTypeList(params, type).get("list");
		}else{
			folderTypeList = (CoviList) boardManageSvc.selectFolderTypeList(params).get("list");
		}
		
		CoviList domainList = (CoviList) boardManageSvc.selectDomainList(params).get("list");
		
		//CHECK : Base Code 조회항목
		CoviList securityLevelList = (CoviList) boardManageSvc.selectSecurityLevelList(params).get("list");
		
		CoviMap item = new CoviMap();
		//지정 안함 옵션 항목 추가
		item.put("optionValue", "");
		item.put("optionText", DicHelper.getDic("lbl_NotSpecified"));
		domainList.add(0, item);
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);
		mav.addObject("folderTypeList",folderTypeList);
		mav.addObject("domainList", domainList);
		mav.addObject("securityLevelList", securityLevelList);
		mav.addObject("CommunityID", communityID);
		mav.addObject("domainID", domainID);
		mav.addObject("useBoardInherited", RedisDataUtil.getBaseConfig("useBoardInherited", domainID));
		return mav;
	}
	
	/**
	 * 게시글 처리 이력관리용 코멘트(처리 사유) 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/goCommentPopup.do", method = RequestMethod.GET)
	public ModelAndView goCommentPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "admin/board/commentPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 수정요청 팝업 호출 
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/goRequestStatusPopup.do", method = RequestMethod.GET)
	public ModelAndView goRequestModifyPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "admin/board/requestStatusPopup";
		String domainID = request.getParameter("domainID");
		CoviMap params = new CoviMap();
		params.put("domainID", domainID);
		
		CoviList statusList = (CoviList) boardManageSvc.selectRequestStatusList(params).get("list");
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("statusList", statusList);
		return mav;
	}
	
	@RequestMapping(value = "admin/goBoardTreePopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardTreePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "admin/board/boardTreePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 폴더 타입별 Default Config 조회
	 * @param request FolderType
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectDefaultConfig.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectDefaultConfig(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String folderType = request.getParameter("folderType");    //폴더 타입
			
			CoviMap params = new CoviMap();
			params.put("folderType", folderType);

			//이전의 폴더 ID 경로 조회
			CoviMap configData = boardManageSvc.selectDefaultConfig(params);
			
			configData.put("TotalFileSize", multipartResolver.getFileUpload().getSizeMax());
			configData.put("LimitFileSize", multipartResolver.getFileUpload().getSizeMax());
			
		    returnData.put("config",configData);
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
	 * 폴더의 속성 및 옵션 조회
	 * @param request FolderID
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBoardConfig.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardConfig(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");			//폴더 ID
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			params.put("ContentsID", boardManageSvc.selectContentsID(params));
			
			//board_config_default의 설정컬럼들의 이름과 동일하게 설정 
			//JSP에서의 설정 항목별 맵핑 규칙 - 컬럼명과 ElementID를 prefix text하나를 두고 구분
			//체크 박스 - [UsePopNotice/'chk'UsePopNotice]
			//텍스트 박스 - [LimitFileSize/'txt'LimitFileSize]
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			configMap.put("FileSize", multipartResolver.getFileUpload().getSizeMax());
			returnData.put("config", configMap);
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
	 * 게시판 권한 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBoardACLData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardACLData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String objectID = request.getParameter("objectID");
			String objectType = request.getParameter("objectType");			
			
			CoviMap params = new CoviMap();
			params.put("objectID", objectID);
			params.put("objectType", objectType);
			result = authSvc.selectACL(params);
			
		    returnData.put("data",result);
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
	 * 게시 추가/설정 팝업 - 새로만들기/추가 (기본설정 정보 저장)
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/createBoard.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createBoard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			String menuID = request.getParameter("menuID");
			String memberOf = request.getParameter("memberOf");
			String folderType = StringUtil.replaceNull(request.getParameter("folderType") ,"");
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID"));		//RegisterCode에 사용
			
			//기존에는 정렬순서를 입력받았지만 현재 트리메뉴의 경우 정렬순서를 입력받을 경우 sortpath에 중복된 데이터가 생성되므로 추가할때만 새로 생성
			if(folderType.equals("Root")){	//최상위 폴더의 sortPath, folderPath 
				params.put("memberOf", null);
				int sortKey = (boardManageSvc.selectNextSortKey(params) + 1);
				params.put("sortKey", sortKey);
				params.put("sortPath", String.format("%015d", sortKey)+";");
				params.put("folderPath", "");				
			} else {
				//상위 데이터에 따라 memberOf, sortPath, folderPath 설정
				params.put("memberOf", memberOf);
				int sortKey = (boardManageSvc.selectNextSortKey(params) + 1);
				params.put("sortKey", sortKey);
				CoviMap pathData = boardManageSvc.selectPathInfo(params);	//상위폴더의 SortPath, FolderPath 검색
				params.put("sortPath", pathData.get("SortPath") + String.format("%015d", sortKey)+";");
				params.put("folderPath", pathData.get("FolderPath")+memberOf+";");		//FolderPath의 경우에는 생성되는 FolderID가 필요하므로 다시 설정
			}
			
			int cnt = 0;
			if(func.f_NullCheck(request.getParameter("communityID")).equals("")){
				cnt = boardManageSvc.createBoard(params);
			}else{
				params.put("bizSection", "Community");
				cnt = boardManageSvc.createBoard(params);
				
				params.put("CU_ID", params.get("communityID").toString());
				if(!"Root".equals(folderType) && !"Folder".equals(folderType)){
					boardManageSvc.createCommunityTopMenu(params);
				}
				
				CoviMap communityInfo = communitySvc.selectCommunityInfo(params);
				
				if(!communitySvc.ACL(params.get("folderID").toString(), "FD", communityInfo.get("CU_Code").toString(), "GR" ,"_C__EVR", "_", "C", "_", "_", "E", "V", "R", "C", params.get("userCode").toString(), communityInfo.getString("DN_ID"), communityInfo.getString("CommunityType"))){
					returnData.put("status", Return.FAIL);
					return returnData;
				}				
			}
			
			if(cnt>0){
				//FolderType이 Root, Folder가 아닐경우 board_config 테이블에 default 테이블 정보 insert
				if(!"Root".equals(folderType) && !"Folder".equals(folderType)){
					boardManageSvc.createBoardConfig(params);
				}
				
				if("QuickComment".equals(folderType)){	//한줄게시의 경우 폴더 생성시 게시글데이터도 자동으로 생성
					List mf = new ArrayList();
					params.put("subject", params.get("displayName"));	//CHECK:제목은 폴더명과 동일하게...표시할 필요가 있나 싶다
					params.put("body", " ");
					params.put("bodyText", " ");
					params.put("bodySize",1);
					params.put("bizSection", "Board");
					params.put("isInherited", "N");
					params.put("msgType", "O");
					params.put("msgState", "C");
					params.put("step", 0);
					params.put("depth", 0);
					params.put("isApproval", "N");
					params.put("useSecurity", "N");
					params.put("isPopup", "N");
					params.put("isTop", "N");
					params.put("isUserForm", "N");
					params.put("useScrap", "N");
					params.put("useRSS", "N");
					params.put("useReplyNotice", "N");
					params.put("useCommNotice", "Y");
					params.put("fileCnt",0);
					params.put("fileInfos","[]");
					boardMessageSvc.createMessage(params, mf);
				}
			}
			
			// Menu(메뉴) ACL을 상속 또는 Folder의 상위 권한을 상속
			if(func.f_NullCheck(request.getParameter("communityID")).equals("")){
				CoviMap aclParams = new CoviMap();
				CoviList aclArray = new CoviList();
				
				// FolderType 이 최상위 폴더일 경우 Menu(메뉴) ACL을 상속 받는다.
				if("Root".equals(folderType)) {					
					aclParams.put("objectType", "MN");				//Menu 권한 상속
					aclParams.put("objectID", menuID);				//현재 Folder가 참조하는 Menu ID
					aclParams.put("inheritedObjectID", menuID);		//상속 받는 ObjectID					
					aclArray = authSvc.selectACL(aclParams);		//Menu ACL 정보 조회
				} else {
					aclParams.put("objectType", "FD");				//Folder 권한 상속
					aclParams.put("objectID", memberOf);			//현재 Folder 및 Board 가 참조하는 FolderID
					aclParams.put("inheritedObjectID", memberOf);	//상속 받는 ObjectID
					aclArray = authSvc.selectACL(aclParams);		//Folder ACL 정보 조회
				}
				
				insertACLData(aclArray, params);					//SYS_OBJECT_ACL
				
				// 권한상속 - 기초설정 useBoardInherited 값이 Y 이고, 폴더/게시판 환경설정의 권상상속여부를 사용으로 저장하면 모든 하위의 권한이 같이 변경
				if (RedisDataUtil.getBaseConfig("useBoardInherited", params.getString("domainID")).equals("Y")
					&& StringUtil.isNotNull(params.getString("isSubfolderInherited")) && params.getString("isSubfolderInherited").equals("Y")) {
					insertInheritedACLData(aclArray, params);
				}
			}
			
			/* 폴더 관련 등록 이후 캐쉬정보 업데이트 추후 적용
			 * 1. 폴더 정보 캐시 업데이트
			 * 2. 도메인정보 캐시 업데이트
			 * 3. 개인 메뉴 캐시 업데이트
			*/
			authSvc.syncDomainACL(params.getString("domainID"), "FD_"+params.getString("bizSection"));
			
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
	 * 게시 추가/설정 팝업 - 속성 (옵션 정보 저장)
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/updateBoard.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateBoard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			
			//권한 설정 정보 
			params.put("objectID", params.get("folderID"));
			params.put("objectType", "FD");
			params.put("userCode", SessionHelper.getSession("USERID"));
			String useEasyAdmin = "";
			
			if (RedisDataUtil.getBaseConfig("BoardEasyAdmin").equals("Y") && SessionHelper.getSession("isEasyAdmin").equals("Y"))
				useEasyAdmin = "Y"; 
			
			params.put("useEasyAdmin", useEasyAdmin);
			int cnt = boardManageSvc.updateBoard(params);
			
			if(!func.f_NullCheck(request.getParameter("communityID")).equals("")){
				if(!params.get("folderType").equals("Root") && !params.get("folderType").equals("Folder")){
					boardManageSvc.createCommunityTopMenu(params);
				}
				
				/*
				if(!ACL(params.get("folderID").toString(), "FD", params.get("communityID").toString(), "GR" ,"_C__EVR", "_", "C", "_", "_", "E", "V", "R", "U", params.get("userCode").toString())){
					returnData.put("status", Return.FAIL);
					return returnData;
				}
				*/				
			}
			
			if(cnt>0){
				//FolderType이 Root, Folder가 아닐경우 board_config 테이블에 default 테이블 정보 insert
				if(!params.get("folderType").equals("Root") && !params.get("folderType").equals("Folder")){
					boardManageSvc.updateBoardConfig(params);
				} 
				
				//확장옵션탭: 게시판설명 추가/삭제
				if(params.get("useBoardDescription") != null && params.get("userBoardDescription").equals("Y")){
					if(!"".equals(params.getString("boardDescription"))){
						params.put("bodySize", params.getString("boardDescription").length());
					}
					
					if("".equals(params.get("contentsID"))){//boardDescription 공백체크
						boardManageSvc.createBoardDescription(params);
					} else {
						boardManageSvc.updateBoardDescription(params);
					}
				} else {
					//게시판 설명 삭제
					boardManageSvc.deleteBoardDescription(params);
				}
				
				//확장옵션탭: 본문양식중 초기양식 사용 여부 확인
				if(StringUtil.isNotNull(params.get("useBodyForm")) && params.get("useBodyForm").equals("Y") && StringUtil.isNotNull(params.get("bodyFormID"))){
					boardManageSvc.updateBodyFormInit(params);
				}
				
				//ACL정보 삭제
				authSvc.deleteACL(params);
				
				//ACL정보 재등록
				String aclList = request.getParameter("aclList");
				CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(aclList, "utf-8"));
				
				//권한 등록
				insertACLData(aclArray, params);
				
				// 권한상속 - 기초설정 useBoardInherited 값이 Y 이고, 폴더/게시판 환경설정의 권상상속여부를 사용으로 저장하면 모든 하위의 권한이 같이 변경
				if (RedisDataUtil.getBaseConfig("useBoardInherited", params.getString("domainID")).equals("Y")
					&& StringUtil.isNotNull(params.getString("isSubfolderInherited")) && params.getString("isSubfolderInherited").equals("Y")) {
					insertInheritedACLData(aclArray, params);
				} else {
					// 하위 폴더/게시판 상속 권한 처리
					authSvc.setInheritedACL(params.getString("folderID"), "FD", false);
				}
				
				//ACL정보 재등록
				String aclActionList = request.getParameter("aclActionList");
				CoviList aclActionArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(aclActionList, "utf-8"));
				
				if(aclActionArray.size() > 0) {
					String serviceType = request.getParameter("bizSection");
					if(!func.f_NullCheck(request.getParameter("communityID")).equals("")){
						serviceType = "COMMUNITY";
					}
					authSvc.syncActionACL(aclActionArray, "FD_" + serviceType);
				}
			}
			/* 폴더 관련 등록 이후 캐쉬정보 업데이트 추후 적용
			 * 1. 폴더 정보 캐시 업데이트
			 * 2. 도메인정보 캐시 업데이트
			 * 3. 개인 메뉴 캐시 업데이트
			*/
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
	 * 만료일 일괄 수정
	 * @param request expiredDay folderID
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateExpiredDay.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateExpiredDay(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");
			String expireDay = request.getParameter("expireDay");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("expireDay", expireDay);

			int cnt = boardManageSvc.updateExpiredDay(params);
			
		    returnData.put("cnt",cnt);
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
	 * 게시판 복사
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/pasteBoard.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap pasteBoard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			String orgMenuID = request.getParameter("orgMenuID"); 				//잘라낸 메뉴ID
			String orgFolderID  = request.getParameter("orgFolderID");			//잘라낸 FolderID 
			String targetMenuID  = request.getParameter("targetMenuID");		//붙여넣을 메뉴ID
			String targetFolderID  = request.getParameter("targetFolderID");	//붙여넣을 폴더ID
			String targetFolderPath = request.getParameter("targetFolderPath");	//붙여넣을 폴더Path
			String targetSortPath = request.getParameter("targetSortPath");		//붙여넣을 폴더의 sortpath
			
			CoviMap params = new CoviMap();
			params.put("orgMenuID", orgMenuID);
			params.put("orgFolderID", orgFolderID);
			params.put("targetMenuID", targetMenuID);
			params.put("targetFolderID", targetFolderID);
			
			CoviMap targetParams = new CoviMap();
			//타겟 폴더 하위의 sortkey중 최고값 조회
			targetParams = (CoviMap) boardManageSvc.selectTargetFolderSortKey(params).get("desc");
			params.put("sortKey", targetParams.get("SortKey"));
			params.put("sortPath", targetSortPath + String.format("%015d", targetParams.getInt("SortKey"))+";");
			params.put("folderPath", targetFolderPath + targetFolderID + ";");
			
			//원본 게시판의 MenuID, MemberOf, SortKey 업데이트
			//원본 게시판의 FolderPath 수정
			//원본 게시판의 SortPath 수정
			boardManageSvc.updateOrginalFolder(params);
			
			//하위 폴더의 MenuID수정
			//하위폴더의 FolderPath 수정
			//하위 게시판의 SortPath 수정
			boardManageSvc.updateLowerFolder(params);
			//캐쉬 적용
			
			// 상속 권한 처리
			CoviMap delParams = new CoviMap();
			delParams.put("objectID", orgFolderID);
			delParams.put("objectType", "FD");
			
			authSvc.deleteInheritedACL(delParams);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 게시판 삭제 처리
	 * @param request FolderID ("1,2,3,4,5"), MenuID
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteBoard.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteBoard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID[]  = StringUtil.replaceNull(request.getParameter("folderID"), "").split(";"); //삭제할 포탈 ID
			
			for(int i = 0; i < folderID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("folderID",folderID[i]);
				//하위의 폴더 ID 경로 조회
				boardManageSvc.deleteLowerBoard(params);
				boardManageSvc.deleteBoard(params);
				//1. ACL 삭제 
				//2. Authority 삭제
				//3. 다국어 비사용처리
				//ACL정보 삭제
				params.put("objectID", folderID[i]);
				params.put("objectType", "FD");
				authSvc.deleteACL(params);
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
	
	
	
	/**
	 * 게시판 사용/표시 여부 설정
	 * @param request FolderID, FlagKey: IsUse/IsDisplay, FlagValue: Y/N
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateBoardFlag.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateFlag(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID  = request.getParameter("folderID");    //변경할 폴더ID
			String flagKey = request.getParameter("flagKey");		//변경될 컬럼 : IsUse/IsDisplay
			String flagValue = request.getParameter("flagValue");		//변경될 값: Y/N
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("flagKey", flagKey);
			params.put("flagValue", flagValue);
			params.put("userCode", SessionHelper.getSession("USERID"));

			//사용, 표시여부 변경
			int cnt = boardManageSvc.updateFlag(params);
			
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
	 * 문서번호 발번 설정 변경
	 * @param request ManagerID, FlagValue: Y/N
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateDocNumberFlag.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateDocNumberFlag(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String managerID  = request.getParameter("managerID");    //변경할 폴더ID
			String flagValue = request.getParameter("flagValue");		//변경될 값: Y/N
			
			CoviMap params = new CoviMap();
			params.put("managerID", managerID);
			params.put("flagValue", flagValue);
			params.put("userCode", SessionHelper.getSession("USERID"));

			//사용, 표시여부 변경
			int cnt = boardManageSvc.updateDocNumberFlag(params);
			
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
	 * 삭제된 게시판 복원
	 * @param request FolderID
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/restoreFolder.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap restoreFolder(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID  = request.getParameter("folderID");    //변경할 폴더ID
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userCode", SessionHelper.getSession("USERID"));

			//폴더 복원
			int cnt = boardManageSvc.restoreFolder(params);
			if(cnt > 0){
				params.put("objectID", params.get("folderID"));			//ObjectID: FolderID
				params.put("objectType", "FD");							//ObjectType: FD
				params.put("subjectCode", "ORGROOT");
				params.put("subjectType", "FD");
				params.put("aclList", "_C__EVR");
				params.put("security", "_");
				params.put("create", "C");
				params.put("delete", "_");
				params.put("modify", "_");
				params.put("execute", "E");
				params.put("view", "V");
				params.put("read", "R");
				params.put("description", "");
				params.put("registerCode", params.get("userCode"));
				authSvc.insertACL(params);
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
	
	/**
	 * 게시판 description정보 조회 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBoardDescription.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardDescription(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String folderID  = request.getParameter("folderID");    //폴더ID
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);

			//게시판 설명 조회
			result = (CoviMap) boardManageSvc.selectBoardDescription(params).get("desc");
			
		    returnData.put("boardDescription",result);
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
	 * 본문양식 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBodyForm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBodyForm(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);

			//본문양식 조회
			result = (CoviList) boardManageSvc.selectBodyForm(params).get("list");
			
		    returnData.put("formList",result);
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
	 * 본문양식 정보 생성 및 양식 파일 업로드
	 * @param req		multipart file upload 이므로 다른 param을 사용
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/createBodyForm.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap createBodyForm(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile FileInfo = req.getFile("uploadFile");
			String folderID = req.getParameter("folderID");
			String formName = req.getParameter("formName");  
			String isInit = req.getParameter("isInit");  
			String serviceType = "BodyForm";

			CoviMap params = new CoviMap();
			if(FileInfo!=null){
				long FileSize = FileInfo.getSize();
			
				if(FileSize>0 ){
					List<MultipartFile> list = new ArrayList<>();
					list.add(FileInfo);
					CoviList savedArray = fileUtilService.uploadToBack(null, list, null, serviceType, "0", "NONE", "0", false);
					CoviMap savedFile = savedArray.getJSONObject(0);
					int fileId = savedFile.getInt("FileID");
					String savedName = savedFile.optString("SavedName");
					params.put("fileId", fileId);
		            params.put("formPath", savedName);
				}else{
					params.put("fileId", "0");
					params.put("formPath","");
				}
				
			}else{
				params.put("fileId", "0");
				params.put("formPath","");
			}
			
			params.put("folderID", folderID);
			params.put("formName", formName);
			params.put("isInit", isInit);
						
			boardManageSvc.createBodyForm(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
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
	 * 본문 양식 정보 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteBodyForm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteBodyForm(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String bodyFormID = request.getParameter("bodyFormID");			//본문양식ID
			
			CoviMap params = new CoviMap();
			params.put("bodyFormID", bodyFormID);
		
			int cnt = boardManageSvc.deleteBodyForm(params);
			
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
	 * 게시판 소유자 이름 확인
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBoardOwnerName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardOwnerName(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String ownerCode = StringUtil.replaceNull(request.getParameter("ownerCode"), "");    //폴더 타입
			String[] ownerCodes = ownerCode.split(";");
			
			CoviMap params = new CoviMap();
			params.put("ownerCodes", ownerCodes);

			//이전의 폴더 ID 경로 조회
			result = (CoviList) boardManageSvc.selectBoardOwnerName(params).get("list");
			
		    returnData.put("list",result);
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
	 * 게시판 이동처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/moveFolder.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveFolder(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String bizSection = request.getParameter("bizSection");
			String domainID = request.getParameter("domainID");
			String folderID = request.getParameter("folderID");
			String sortKey = request.getParameter("sortKey");
			String folderPath = request.getParameter("folderPath");
			String folderType = request.getParameter("folderType");
			String mode = request.getParameter("mode");
			
			String menuID = null;
			if("Board".equals(bizSection)){
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			} else {
				menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("DocMenu", domainID));
			}
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("menuID", menuID.split(";"));
			params.put("folderID", folderID);
			params.put("orgSortKey", sortKey);
			params.put("folderPath", folderPath);
			params.put("folderType", folderType);
			params.put("mode", mode);
			
			result = (CoviMap) boardManageSvc.selectTargetBoardSortKey(params).get("target");	//순서 변경할 sortkey 조회
			if(!result.isEmpty()){	//최상위 혹은 최하위에 해당하거나 순서 변경을 할 대상을 찾지 못할경우의 처리 
				//현재 sortkey를 검색된 sortkey로 update
				params.put("sortKey", result.get("SortKey"));
				params.put("memberOf", result.get("MemberOf"));
//				CoviMap pathData = (CoviMap) boardManageSvc.selectPathInfo(params).get("path");	//상위폴더의 SortPath, FolderPath 검색
//				params.put("sortPath", pathData.get("SortPath") + String.format("%015d", result.getInt("SortKey"))+";");
				
				int cnt = boardManageSvc.updateBoardSortKey(params);
				if(cnt > 0 ){
					CoviMap targetParams = new CoviMap();
					targetParams.put("folderID", result.get("FolderID"));	//Target FolderID
					targetParams.put("sortKey", sortKey);
//					targetParams.put("sortPath", pathData.get("SortPath") + String.format("%015d", Integer.parseInt(sortKey))+";");
					boardManageSvc.updateBoardSortKey(targetParams);
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
	
	/**
	 * 권한 정보 추가
	 * @param aclArray
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int insertACLData(CoviList aclArray, CoviMap params) throws Exception{
		int cnt = 0;
		
		// 본인 권한 데이터 추가
		for(int i=0;i<aclArray.size();i++){
			CoviMap aclObj = aclArray.getJSONObject(i);
			String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
			params.put("objectID", params.get("folderID"));								//ObjectID: FolderID
			params.put("objectType", "FD");												//ObjectType: FD
			params.put("subjectCode", aclObj.get("SubjectCode"));
			params.put("subjectType", aclObj.get("SubjectType"));
			params.put("aclList", aclObj.get("AclList"));
			params.put("security", aclShard[0]);
			params.put("create", aclShard[1]);
			params.put("delete", aclShard[2]);
			params.put("modify", aclShard[3]);
			params.put("execute", aclShard[4]);
			params.put("view", aclShard[5]);
			params.put("read", aclShard[6]);
			params.put("description", "");
			params.put("registerCode", SessionHelper.getSession("USERID"));
			params.put("inheritedObjectID", aclObj.get("InheritedObjectID"));
			params.put("isSubInclude", aclObj.get("IsSubInclude"));
			cnt += (int) authSvc.insertACL(params);
		}
		
		return cnt;
	}
	
	/**
	 * 권한 상속 정보 추가
	 * @param aclArray
	 * @param params
	 * @return void
	 * @throws Exception
	 */
	public void insertInheritedACLData(CoviList aclArray, CoviMap params) throws Exception {
		CoviList authList = boardManageSvc.selectInheritedACLList(params);
		
		if (authList.size() > 0 && aclArray.size() > 0) {
			for (int i = 0; i < authList.size(); i++) {
				CoviMap auth = authList.getMap(i);
				auth.put("objectType", params.getString("objectType"));
				
				authSvc.deleteACL(auth);
				
				insertACLData(aclArray, auth);
			}
			
			// 권한 변경 사항 Redis 적용
			String serviceType = params.getString("bizSection");
			if(StringUtil.isNotNull(params.getString("communityID"))){
				serviceType = "COMMUNITY";
			}
			
			authSvc.syncActionACL(aclArray, "FD_" + serviceType);
		}
	}
	
	/**
	 * 승인선 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectProcessActivityList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectProcessActivityList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);

			//승인 프로세스 정의 조회 
			CoviMap processDef = (CoviMap) boardManageSvc.selectProcessTarget(params).get("processDef");
			params.put("processID", processDef.get("ProcessID"));
			
			result = (CoviList) boardManageSvc.selectProcessPerformerList(params).get("list");
			
			returnData.put("processID", processDef.get("ProcessID"));
		    returnData.put("list",result);
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
	 * 소유자, 담당부서 변경
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/changeDocInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap changeDocInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] messageID = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";");
			String ownerCode = request.getParameter("ownerCode");
			String registDept = request.getParameter("registDept");
			
			CoviMap params = new CoviMap();
			params.put("ownerCode", ownerCode);
			params.put("registDept", registDept);
			params.put("messageID", messageID);
			int cnt = boardManageSvc.changeDocInfo(params);
			
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
	 * 문서번호 관리 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/goDocNumberManagePopup.do", method = RequestMethod.GET)
	public ModelAndView goDocNumberManagePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "admin/board/DocNumberManagePopup";
		
		CoviMap params = new CoviMap();
		CoviList domainList = (CoviList) boardManageSvc.selectDomainList(params).get("list");
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("domainList", domainList);
		return mav;
	}
	
	/**
	 * 기초코드 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectBaseCodeList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBaseCodeList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			resultList = boardManageSvc.selectBaseCodeList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	/**
	 * 문서번호 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectDocNumberInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectDocNumberInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			resultList = boardManageSvc.selectDocNumberInfo(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	/**
	 * 문서번호 관리 발번 정보 설정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/setDocNumber.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setDocNumber(HttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			int cnt = 0;
			
			if("create".equals(params.get("mode"))){
				cnt = boardManageSvc.createDocNumber(params);
			} else {
				cnt = boardManageSvc.updateDocNumber(params);
			}
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", "저장되었습니다.");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
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
	 * 문서번호 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteDocNumber.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteDocNumber(HttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] managerID = params.getString("managerIDs").split(";");
			params.put("managerID", managerID);
			
			int cnt =  boardManageSvc.deleteDocNumber(params);
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", "저장되었습니다.");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
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
	 * 문서번호를 위한 다국어 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectFieldLangInfos.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFieldLangInfos(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			resultList = boardManageSvc.selectFieldLangInfos(params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		return returnData;
	}
	
	/**
	 * 문서번호 우선순위 UP
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateFieldSeq.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateFieldSeq(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			
			if (params.get("ManagerID").equals("") || params.get("Seq").equals("") 
				 || params.get("DomainID").equals("") || params.get("FieldType").equals("") ) {
				
				returnData.put("status", Return.FAIL);
				returnData.put("message", "저장에 실패했습니다.");
				return returnData;
			}
			
			CoviMap prevNextMap = boardManageSvc.selectPrevNextField(params);
			
			if (prevNextMap.size() == 0) {
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_gw_UnableChangeSortKey"));
				return returnData;
			}
			
			int prevNextSeq = prevNextMap.getInt("Seq");
			
			prevNextMap.put("Seq", params.get("Seq"));
			params.put("Seq", prevNextSeq);
			
			int resultCnt = boardManageSvc.updateFieldSeq(prevNextMap);
			resultCnt += boardManageSvc.updateFieldSeq(params);

			if(resultCnt > 0){
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "저장되었습니다.");
			} else {
				returnData.put("status", Return.FAIL);
				returnData.put("message", "저장에 실패했습니다.");
			}
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		return returnData;
	}
	
	/**
	 * 카테고리 담당자 수정
	 * 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateCategoryManager.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCategoryManager(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);
			
			int cnt = boardManageSvc.updateCategoryManager(params);
			
			if(cnt > 0) {
				returnData.put("status", Return.SUCCESS);
			} else {
				returnData.put("status", Return.FAIL);
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
	
}