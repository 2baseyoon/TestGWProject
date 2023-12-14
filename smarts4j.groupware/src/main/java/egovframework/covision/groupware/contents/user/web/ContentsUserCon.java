package egovframework.covision.groupware.contents.user.web;

import java.io.File;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
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
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.admin.service.UserDefFieldManageSvc;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;
import egovframework.covision.groupware.contents.user.service.ContentsUserSvc;


@Controller
public class ContentsUserCon {
	
	private Logger LOGGER = LogManager.getLogger(ContentsUserCon.class);
	
	LogHelper logHelper = new LogHelper();
	
	@Autowired
	BoardManageSvc boardManageSvc;
	
	@Autowired
	BoardCommonSvc boardCommonSvc;
	
	@Autowired
	ContentsUserSvc contentsUserSvc;
	
	@Autowired
	private FileUtilService fileUtilService;
	
	@Autowired
	UserDefFieldManageSvc userDefFieldManageSvc;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Autowired
	AuthorityService authSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 컨텐츠 앱 홈
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "contents/ContentsMain.do", method = RequestMethod.GET)
	public ModelAndView contentsMain(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsMain";
		String domainID = SessionHelper.getSession("DN_ID"); 
		if (request.getParameter("domainID") != null) domainID =request.getParameter("domainID");
		String bizSection = "Board";
		ModelAndView mav		= new ModelAndView(returnURL);
		try{
			CoviMap params = new CoviMap();
				
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			params.put("lang", SessionHelper.getSession("lang"));

			if (request.getParameter("memberOf") == null)
				params.put("folderType", "Root");
			else
				params.put("memberOf", request.getParameter("memberOf"));
			String menuID =  StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			
			params.put("menuID", menuID.split(";"));
			//CoviMap result = (CoviMap) boardManageSvc.selectTreeFolderMenu(params);
			CoviMap configMap = new CoviMap();
			if (request.getParameter("memberOf") != null){
				params.put("folderID", request.getParameter("memberOf"));
				configMap = boardManageSvc.selectBoardConfig(params);
				mav.addObject("folderPathName", configMap.get("FolderPathName")+";"+configMap.get("DisplayName"));
			}
			
			if(request.getParameter("isFav") != null && "Y".equals(request.getParameter("isFav")))
				mav.addObject("folderPathName", "즐겨찾는 앱");
			
			//mav.addObject("appList", result.get("list"));
			mav.addObject("folderData", configMap);
			mav.addObject("memberOf", request.getParameter("memberOf"));
			mav.addObject("isFav", request.getParameter("isFav"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		//	returnList.put("status", Return.FAIL);
		//	returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return mav;
	}
	
	/**
	 * 컨텐츠 앱 목록 조회
	 * @param request 
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "contents/selectContentsList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectContentsList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String domainID = SessionHelper.getSession("DN_ID"); 
		if (request.getParameter("domainID") != null) domainID =request.getParameter("domainID");
		String bizSection = "Board";
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		try{
			CoviMap params = new CoviMap();
				
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("USERID", SessionHelper.getSession("USERID"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));
			params.put("isFolderMenu", (request.getParameter("isFolderMenu") != null)?request.getParameter("isFolderMenu"):"");
			params.put("isFav", request.getParameter("isFav"));
			
			if (request.getParameter("memberOf") == null || request.getParameter("memberOf").equals("")) {
				params.put("folderType", "Root");
			} else {
				params.put("memberOf", request.getParameter("memberOf"));
			}
			
			String menuID =  StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			
			params.put("menuID", menuID.split(";"));
			
			result = (CoviList) contentsUserSvc.selectContentsList(params).get("list");
		    
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
	
	//컨텐츠 앱 즐겨찾기
	@RequestMapping(value = "contents/saveContentsFavorite.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveContentsFavorite(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("fid", request.getParameter("fid"));
			reqMap.put("ftype", request.getParameter("ftype"));
			
			if ("false".equals(request.getParameter("isFlag")))
				contentsUserSvc.addContentsFavorite(reqMap);
			else
				contentsUserSvc.deleteContentsFavorite(reqMap);
			
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
	
	//폴더 추가 팝업 화면
	@RequestMapping(value = "contents/ContentsFolderAddPopup.do")
	public ModelAndView contentsFolderAddPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsFolderAddPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		CoviMap params = new CoviMap();
		params.put("folderID", request.getParameter("fId"));
		
		CoviMap result = (CoviMap) contentsUserSvc.selectContentsName(params).get("desc");
		
		mav.addObject("folderID", result.get("FolderID"));
		mav.addObject("displayName", result.get("DisplayName"));
		mav.addObject("multiDisplayName", result.get("MultiDisplayName"));
		
		return mav;
	}
	
	//폴더 생성
	@RequestMapping(value = "contents/saveFolderAdd.do")
	public  @ResponseBody CoviMap saveFolderAdd(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();	
			CoviMap trgMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			
			if (request.getParameter("folderID") == null || "".equals(request.getParameter("folderID"))){	//params 생성
				CoviMap boardMap = new CoviMap();
				boardMap.put("memberOf", request.getParameter("memberOf"));
				
				int sortKey = (boardManageSvc.selectNextSortKey(boardMap) + 1);
				boardMap.put("sortKey", sortKey);
				CoviMap pathData = boardManageSvc.selectPathInfo(boardMap);	//상위폴더의 SortPath, FolderPath 검색
				boardMap.put("sortPath", pathData.get("SortPath") + String.format("%015d", sortKey)+";");
				boardMap.put("folderPath", pathData.getString("FolderPath")+request.getParameter("memberOf")+";");		//FolderPath의 경우에는 생성되는 FolderID가 필요하므로 다시 설정
				
				boardMap.put("domainID", SessionHelper.getSession("DN_ID"));
				boardMap.put("menuID",RedisDataUtil.getBaseConfig("BoardMain"));
				boardMap.put("displayName",  request.getParameter("displayName"));
				boardMap.put("multiDisplayName", request.getParameter("multiDisplayName"));
				boardMap.put("ownerCode",SessionHelper.getSession("USERID"));
				boardMap.put("userCode",SessionHelper.getSession("USERID"));
				
				//default값 세팅
				boardMap.put("bizSection","Board");
				boardMap.put("folderType", request.getParameter("folderType"));
				boardMap.put("isContens","Y");
				boardMap.put("isShared","N");
				boardMap.put("isUse","Y");
				boardMap.put("isDisplay","Y");
				boardMap.put("isURL","N");
				boardMap.put("isMobileSupport","N");
				boardMap.put("isAdminNotice","N");
				boardMap.put("isMsgSecurity","N");
				boardMap.put("securityLevel","256");
				
				boardManageSvc.createBoard(boardMap);
				
				boardMap.put("useUserForm","Y");
				boardManageSvc.createBoardConfig(boardMap);
				
				CoviMap aclParams = new CoviMap();
				String menuID = RedisDataUtil.getBaseConfig("BoardMain");
				
				aclParams.put("objectType", "MN");		//메뉴권한 상속
				aclParams.put("objectID", menuID);		//현재 Folder가 참조하는 Menu ID
				
				CoviList aclArray = authSvc.selectACL(aclParams);	//Menu ACL 정보 조회
				insertACLData(aclArray, boardMap);		//sys_object_acl
				
				/* 권한 상속 처리
				if (RedisDataUtil.getBaseConfig("useBoardInherited", boardMap.getString("domainID")).equals("Y")
					&& StringUtil.isNotNull(boardMap.getString("isInherited")) && boardMap.getString("isInherited").equals("Y")) {
					insertInheritedACLData(aclArray, boardMap);
				}*/
				authSvc.syncDomainACL(boardMap.getString("domainID"), "FD_Board");
				
				reqMap.put("folderID",boardMap.get("folderID"));
			}else{
				reqMap.put("folderID",request.getParameter("folderID"));
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

	//컨텐츠 앱 이름변경 팝업 화면
	@RequestMapping(value = "contents/ContentsNameChangePopup.do")
	public ModelAndView contentsNameChangePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsNameChangePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		CoviMap params = new CoviMap();
		params.put("folderID", request.getParameter("fId"));
		
		CoviMap result = (CoviMap) contentsUserSvc.selectContentsName(params).get("desc");
		
		mav.addObject("folderID", result.get("FolderID"));
		mav.addObject("displayName", result.get("DisplayName"));
		mav.addObject("multiDisplayName", result.get("MultiDisplayName"));
		
		return mav;
	}
	
	//컨텐츠 앱 이름변경 처리
	@RequestMapping(value = "contents/updateContentsNameChange.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap updateContentsNameChange(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("folderID", request.getParameter("folderID"));
			reqMap.put("displayName", request.getParameter("displayName"));
			reqMap.put("multiDisplayName", request.getParameter("multiDisplayName"));
			
			contentsUserSvc.updateContentsNameChange(reqMap);
			
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
	
	//등록, 수정 화면
	@RequestMapping(value = "contents/ContentsUserForm.do", method = RequestMethod.GET)
	public ModelAndView contentsUserForm(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsUserForm";
		ModelAndView mav		= new ModelAndView(returnURL);
	
		try {
			String folderID = request.getParameter("folderID");
			String memberOf = request.getParameter("memberOf");
		
			CoviMap params = new CoviMap();
			if (folderID != null){
				params.put("folderID", folderID);
				params.put("userCode", SessionHelper.getSession("USERID"));
				
				CoviMap configMap = boardManageSvc.selectBoardConfig(params);
				CoviMap result = contentsUserSvc.selectUserDefFieldGridList(params);
				mav.addObject("folderData", configMap);
				mav.addObject("folderID", folderID);
				mav.addObject("menuID", configMap.get("MenuID"));
				mav.addObject("formList", result.get("list"));
				mav.addObject("folderPathName", configMap.get("FolderPathName"));
				mav.addObject("useBody", configMap.get("UseBody"));
			}else{	//신규
				params.put("folderID", memberOf);
				if (memberOf != null && !memberOf.equals("")) {
					CoviMap configMap = boardManageSvc.selectBoardConfig(params);
					mav.addObject("folderPathName", configMap.get("FolderPathName")+";"+configMap.get("DisplayName"));
					mav.addObject("menuID", configMap.get("MenuID"));
				}	
				mav.addObject("memberOf", memberOf);
			}
			mav.addObject("lang", SessionHelper.getSession("lang"));
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return mav;

	}
	
	@RequestMapping(value = "contents/ContentsList.do", method = RequestMethod.GET)
	public ModelAndView contentsList(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsList";
		ModelAndView mav		= new ModelAndView(returnURL);
	
		try {
			String folderID = request.getParameter("folderID");
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("OnlyData", "Y");
			
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			CoviList chartList= contentsUserSvc.getFolderChartList(params);
			CoviMap result = boardCommonSvc.selectUserDefFieldList(params);
			mav.addObject("folderData", configMap);
			mav.addObject("folderID", folderID);
			mav.addObject("memberOf", configMap.get("MemberOf"));
			mav.addObject("chartList", chartList);
			mav.addObject("formList", result.get("list"));
			mav.addObject("sortCols", configMap.get("SortCols"));
//			mav.addObject("formList", result.get("list"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return mav;

	}
	
	//컨텐츠앱 만들기 저장
	@RequestMapping(value = "contents/saveUserFrom.do")
	public  @ResponseBody CoviMap saveUserFrom(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			
			List jsonData = (List)params.get("jsonData");

			CoviMap boardMap = new CoviMap();
			
			boardMap.put("menuID", params.get("menuID")== null  || "".equals(params.get("menuID").toString())? RedisDataUtil.getBaseConfig("BoardMain"):params.get("menuID"));
			
			if (params.get("folderID") == null || "".equals(params.get("folderID").toString())){	//params 생성
				boardMap.put("memberOf", params.get("memberOf"));
				
				int sortKey = (boardManageSvc.selectNextSortKey(boardMap) + 1);
				boardMap.put("sortKey", sortKey);
				CoviMap pathData = boardManageSvc.selectPathInfo(boardMap);	//상위폴더의 SortPath, FolderPath 검색
				boardMap.put("sortPath", pathData.get("SortPath") + String.format("%015d", sortKey)+";");
				boardMap.put("folderPath", pathData.getString("FolderPath")+params.get("memberOf")+";");		//FolderPath의 경우에는 생성되는 FolderID가 필요하므로 다시 설정
				
				boardMap.put("domainID", SessionHelper.getSession("DN_ID"));
				boardMap.put("displayName",  params.get("displayName"));
				boardMap.put("multiDisplayName", params.get("multiDisplayName"));
				boardMap.put("ownerCode",SessionHelper.getSession("USERID"));
				boardMap.put("userCode",SessionHelper.getSession("USERID"));
				
				//default값 세팅
				boardMap.put("bizSection","Board");
				boardMap.put("folderType", "Board");
				boardMap.put("isContens","Y");
				boardMap.put("isShared","N");
				boardMap.put("isUse","Y");
				boardMap.put("isDisplay","Y");
				boardMap.put("isURL","N");
				boardMap.put("isMobileSupport","N");
				boardMap.put("isAdminNotice","N");
				boardMap.put("isMsgSecurity","N");
				boardMap.put("securityLevel","256");
				
				//게시판 기본정보 등록
				int cnt = boardManageSvc.createBoard(boardMap);
				
				boardMap.put("useUserForm","Y");
				boardMap.put("useIcon",params.get("useIcon"));
				
				boardManageSvc.createBoardConfig(boardMap);
				
				reqMap.put("folderID",boardMap.get("folderID"));
			}else{
				boardMap.put("folderType", "Board");
				boardMap.put("isUse","Y");
				boardMap.put("isDisplay","Y");
				boardMap.put("folderID",params.get("folderID"));
				boardMap.put("displayName",  params.get("displayName"));
				boardMap.put("multiDisplayName", params.get("multiDisplayName"));
				boardMap.put("useBody",params.get("useBody"));
				
				//게시판 기본정보 수정
				boardMap.put("useEasyAdmin", "Y");
				boardManageSvc.updateBoard(boardMap);
				
				contentsUserSvc.updateBoardConfigBody(boardMap);
				reqMap.put("folderID",params.get("folderID"));
			}
			
			//사용자 정의 필드 삭제
			String[] userFormIDs = params.get("userFormIDs").toString().split(";");
			
			for (int i = 0; i < userFormIDs.length; i++) {
				CoviMap delImgMap = new CoviMap();
				delImgMap.put("userFormID", userFormIDs[i]);
				
				//사용자 정의 폼 삭제전 image 유무 조회
				CoviMap userFormData = (CoviMap) contentsUserSvc.selectUserFormImageData(delImgMap).get("desc");
				
				String userFormID = userFormData.getString("UserFormID");
				String gotoLink = userFormData.getString("GotoLink");
				
				if(gotoLink != null && !"".equals(gotoLink)) {
					gotoLink = gotoLink.replace("/covicore/common/view/", "");
					gotoLink = gotoLink.replace(".do", "");
					
					//이미지 삭제
					fileUtilService.deleteFileByID(gotoLink, true);
				}
			}
			
			CoviMap delMap = new CoviMap();
			delMap.put("userFormIDs", userFormIDs);
			delMap.put("folderID", reqMap.get("folderID"));
			
			userDefFieldManageSvc.deleteUserDefField(delMap);			//board_userform
			userDefFieldManageSvc.deleteUserDefFieldOption(delMap);		//board_userform_option
			
			if (jsonData.size()>0){
				//사용자 정의 필드 추가 및 수정
				int result = contentsUserSvc.updateUserDefField(reqMap, jsonData);	//board_userform
				
				CoviList userFormList = CoviList.fromObject(params.get("jsonData"));
				for (int i = 0; i < userFormList.size(); i++) {
					CoviMap userFormObj = userFormList.getJSONObject(i);
					
					//사용자 정의 필드 옵션 추가
					if(userFormObj.getString("OptionList") != null && !userFormObj.getString("OptionList").equals("")) {
						//사용자 정의 폼 UserFormID 조회
						CoviMap userFormKeyMap = new CoviMap();
						userFormKeyMap.put("folderID", reqMap.get("folderID"));
						userFormKeyMap.put("sortKey", i);
						int userFormKey = contentsUserSvc.selectUserFormKey(userFormKeyMap);	//board_userform
						
						//이전 옵션 삭제
						CoviMap delOptMap = new CoviMap();
						delOptMap.put("userFormID", userFormKey);
						delOptMap.put("folderID", reqMap.get("folderID"));
						userDefFieldManageSvc.deleteUserDefFieldOption(delOptMap);		//board_userform_option
						
						String[] optionList = userFormObj.getString("OptionList").split("\\|");
						for (int j = 0; j < optionList.length; j++) {
							String[] optionArr = optionList[j].split("\\^");
							
							CoviMap optionMap = new CoviMap();
							optionMap.put("userFormID", String.valueOf(userFormKey));
							optionMap.put("folderID", reqMap.get("folderID"));
							optionMap.put("sortKey", j);
							optionMap.put("optionName", optionArr[1]);
							optionMap.put("optionValue", optionArr[2]);
							optionMap.put("optionCheck", optionArr[3]);
							
							userDefFieldManageSvc.createUserDefOption(optionMap);	//board_userform_option
						}
					}
				}
			}
			
			returnObj.put("folderID", reqMap.get("folderID"));
			returnObj.put("status", Return.SUCCESS);			

		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
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
	
	//컨텐츠앱 만들기 다른이름으로 저장
	@RequestMapping(value = "contents/addSaveUserFrom.do")
	public  @ResponseBody CoviMap addSaveUserFrom(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			
			List jsonData = (List)params.get("jsonData");
			
			CoviMap boardMap = new CoviMap();
			boardMap.put("pFolderID", params.get("pFolderID"));
			boardMap.put("displayName",  params.get("displayName"));
			boardMap.put("multiDisplayName", params.get("multiDisplayName"));
			boardMap.put("ownerCode",SessionHelper.getSession("USERID"));
			boardMap.put("userCode",SessionHelper.getSession("USERID"));
			boardMap.put("useIcon",params.get("useIcon"));
			
			//게시판 기본정보 등록
			contentsUserSvc.insertSaveFolder(boardMap);
			
			contentsUserSvc.insertBoardConfig(boardMap);
			
			reqMap.put("folderID",boardMap.get("folderID"));
			
			if (jsonData.size()>0){
				//사용자 정의 필드 추가 및 수정
				int result = contentsUserSvc.updateUserDefField(reqMap, jsonData);	//board_userform
				
				CoviList userFormList = CoviList.fromObject(params.get("jsonData"));
				for (int i = 0; i < userFormList.size(); i++) {
					CoviMap userFormObj = userFormList.getJSONObject(i);
					
					//사용자 정의 필드 옵션 추가
					if(userFormObj.getString("OptionList") != null && !userFormObj.getString("OptionList").equals("")) {
						//사용자 정의 폼 UserFormID 조회
						CoviMap userFormKeyMap = new CoviMap();
						userFormKeyMap.put("folderID", reqMap.get("folderID"));
						userFormKeyMap.put("sortKey", i);
						int userFormKey = contentsUserSvc.selectUserFormKey(userFormKeyMap);	//board_userform
						
						String[] optionList = userFormObj.getString("OptionList").split("\\|");
						for (int j = 0; j < optionList.length; j++) {
							String[] optionArr = optionList[j].split("\\^");
							
							CoviMap optionMap = new CoviMap();
							optionMap.put("userFormID", String.valueOf(userFormKey));
							optionMap.put("folderID", reqMap.get("folderID"));
							optionMap.put("sortKey", j);
							optionMap.put("optionName", optionArr[1]);
							optionMap.put("optionValue", optionArr[2]);
							optionMap.put("optionCheck", optionArr[3]);
							
							userDefFieldManageSvc.createUserDefOption(optionMap);	//board_userform_option
						}
					}
				}
			}
			
			returnObj.put("folderID", reqMap.get("folderID"));
			returnObj.put("status", Return.SUCCESS);			

		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
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
	
	@RequestMapping(value = "contents/ContentsChartView.do", method = RequestMethod.GET)
	public ModelAndView contentsChartView(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsChartView";
		ModelAndView mav		= new ModelAndView(returnURL);
	
		try {
			String folderID = request.getParameter("folderID");
			String chartID = request.getParameter("chartID");
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("chartID", chartID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("IsSearchItem", "Y");
			CoviList chartList= contentsUserSvc.getChartData(params);
			CoviMap result = boardCommonSvc.selectUserDefFieldList(params);
			//CoviMap result = userDefFieldManageSvc.selectUserDefFieldGridList(params);
			mav.addObject("searchItem", result.get("list"));
			mav.addObject("chartList", chartList);
			mav.addObject("folderID", folderID);
			mav.addObject("chartID", chartID);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return mav;

		
	}
	// 컨텐츠 앱  조건별 차트 데이타 
	@RequestMapping(value = "contents/getFolderChartData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderChartData(HttpServletRequest request) throws Exception {
			
		CoviMap returnList = new CoviMap();
	
		try {
			String folderID = request.getParameter("folderID");
			String chartID = request.getParameter("chartID");
			

			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("chartID", chartID);
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));
			params.put("userFormID", request.getParameter("ufColumn"));
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			CoviList chartList= contentsUserSvc.getChartData(params);
			
			returnList.put("chartData", ((CoviMap)chartList.get(0)).get("ChartData"));
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
	
	//컨텐츠 앱 폴더이동 팝업 화면
	@RequestMapping(value = "contents/ContentsFolderMovePopup.do")
	public ModelAndView contentsFolderMovePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsFolderMovePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}

	// 컨텐츠 앱  폴더이동 메뉴 조회
	@RequestMapping(value = "contents/getFolderMenu.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectContentsFolderMenu(HttpServletRequest request) throws Exception {
			
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
	
		try {
			String domainID = SessionHelper.getSession("DN_ID");
			String bizSection = "Board";
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			
			resultList = contentsUserSvc.selectContentsFolderMenu(params);
			
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
	
	// 컨텐츠 앱 폴더 이동 처리
	@RequestMapping(value = "contents/moveFolder.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveFolder(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String domainID = SessionHelper.getSession("DN_ID"); 
			if (request.getParameter("domainID") != null) domainID =request.getParameter("domainID");
			String menuID = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("BoardMenu", domainID));
			
			String folderID = request.getParameter("folderID");
			String memberOf = request.getParameter("memberOf");
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domainID", domainID);
			params.put("menuID", menuID.split(";"));
			params.put("folderID", memberOf);
			
			CoviMap targetResult = (CoviMap) contentsUserSvc.selectTargetFolder(params).get("desc");	//이동할 폴더 조회
			
			CoviMap pathData = new CoviMap();
			pathData.put("folderID", folderID);
			pathData.put("memberOf", memberOf);
			pathData.put("folderPath", targetResult.get("FolderPath") + memberOf+";");
			pathData.put("sortKey", targetResult.get("TargetSortKey"));
			pathData.put("sortPath", ((targetResult.get("SortPath") != null)?targetResult.get("SortPath"):"") + String.format("%015d", targetResult.getInt("TargetSortKey"))+";");
			
			contentsUserSvc.updateTargetFolder(pathData);
			
			CoviMap configParams = new CoviMap();
			configParams.put("folderID", folderID);
			configParams.put("userCode", SessionHelper.getSession("USERID"));
			
			CoviMap configMap = boardManageSvc.selectBoardConfig(configParams);
			
			returnData.put("folderPathName", configMap.get("FolderPathName"));
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
	
	//컨텐츠 앱 아이콘설정 팝업 화면
	@RequestMapping(value = "contents/ContentsIconPopup.do")
	public ModelAndView contentsIconPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsIconPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		CoviMap params = new CoviMap();
		params.put("folderID", request.getParameter("fId"));
		
		CoviMap result = (CoviMap) contentsUserSvc.selectContentsName(params).get("desc");
		
		mav.addObject("folderID", result.get("FolderID"));
		mav.addObject("displayName", result.get("DisplayName"));
		mav.addObject("multiDisplayName", result.get("MultiDisplayName"));
		
		return mav;
	}
	
	//컨텐츠 앱 아이콘설정 처리
	@RequestMapping(value = "contents/insertContentsIcon.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertContentsIcon(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
	
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			String userId = Objects.toString(SessionHelper.getSession("USERID"),"");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			String filePath = RedisDataUtil.getBaseConfig("ContentsAppIcon_SavePath");
			String rootPath;
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			String savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("ContentsAppIcon_SavePath");
			String folderID = paramMap.get("folderID");
			
			// 아이콘 처리시작
			if(paramMap.get("useIconSave").equals("true")) {
				if(paramMap.get("iconType").equals("FILE")) {
					MultipartFile fileInfo = req.getFile("iconFile");
					
					if(fileInfo != null){
						long fileSize = fileInfo.getSize();
					
						if(fileSize > 0){
							File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
							//폴더가없을 시 생성
							if(!realUploadDir.exists()){
								if(realUploadDir.mkdirs()) {
									LOGGER.info("path : " + realUploadDir + " mkdirs();");
								}
							}
							
			                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");						// 파일 중복명 처리
			                String originalfileName = fileInfo.getOriginalFilename();										// 본래 파일명
			                String saveFileName = yyyyMMddhhmmssSSS + "." + FilenameUtils.getExtension(originalfileName);	// 저장되는 파일 이름
			                
			                filePath += saveFileName;
			                savePath += saveFileName; // 저장 될 파일 경로
			                
			                //한글명저장
			                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
			                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
			                
			                params.put("iconFile", filePath);
						}else{
							params.put("iconFile","");
						}
					}else{
						params.put("iconFile","");
					}
				} else {
					params.put("iconFile", paramMap.get("iconFile"));
				}
				
				params.put("folderID", folderID);
				
				CoviMap boardMap = new CoviMap();
				boardMap.put("folderID", folderID);
				boardMap.put("userCode", userId);
				boardMap.put("useIcon",params.get("iconFile"));
				
				CoviMap configMap = boardManageSvc.selectBoardConfig(params);
				
				if(configMap.get("UseIcon") != null && !"".equals(configMap.get("UseIcon"))) {
					//기존 파일이 있으면 삭제
					String delUseIcon = (String) configMap.get("UseIcon");
					
					//파일 삭제
					if(StringUtils.isNoneBlank(delUseIcon)){
						String fullPath = rootPath + backStorage + delUseIcon;
						fileUtilService.deleteFile(fullPath);
					}	
				}
				
				//아이콘 수정
				contentsUserSvc.updateBoardConfigIcon(boardMap);
			}else {
				
				//다른이름으로 저장시 직접입력 아이콘 이미지 복사
				if(paramMap.get("pFolderID") != null && !"".equals(paramMap.get("pFolderID"))) {
					
					CoviMap orgIconParam = new CoviMap();
					orgIconParam.put("folderID", paramMap.get("pFolderID"));
					
					CoviMap orgIconData = (CoviMap) contentsUserSvc.selectBoardConfigIcon(orgIconParam).get("desc");
					
					if(!"".equals(orgIconData.get("UseIcon"))) {
						String orgFile = (String) orgIconData.get("UseIcon");
						String[] orgPathArr = orgFile.split("/");
						
						if(orgPathArr.length > 0) {
							File sourceFile = new File(savePath + orgPathArr[orgPathArr.length -1]);	//원본 파일
							
							if(sourceFile.exists()){
				                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");						// 파일 중복명 처리
				                String originalfileName = orgPathArr[orgPathArr.length -1];										// 본래 파일명
				                String saveFileName = yyyyMMddhhmmssSSS + "." + FilenameUtils.getExtension(originalfileName);	// 저장되는 파일 이름
				                
				                filePath += saveFileName;
				                savePath += saveFileName; // 저장 될 파일 경로
				                
				                File targetFile = new File(FileUtil.checkTraversalCharacter(savePath));
				                
				                if(contentsUserSvc.copy(sourceFile, targetFile)) {
				                	CoviMap boardMap = new CoviMap();
				    				boardMap.put("folderID", folderID);
				    				boardMap.put("userCode", userId);
				    				boardMap.put("useIcon", filePath);
				                	
				    				//아이콘 수정
				    				contentsUserSvc.updateBoardConfigIcon(boardMap);
				                }
							}
						}
					}
				}
			}
			
			// 컴포넌트 이미지 처리시작
			String fileSvcType = "ContentsApp";
			String fileSvcPath = fileSvcType + "/";
			
			// 컴포넌트 이미지 삭제
			String delFileIDs = paramMap.get("delFileIDs");
			if(!"".equals(delFileIDs)) {
				delFileIDs = delFileIDs.substring(0, delFileIDs.length()-1);
				
				String[] delFileID = delFileIDs.split(";");
				
				for (int i = 0; i < delFileID.length; i++) {
					
					String[] delData = delFileID[i].split("-");
							
					fileUtilService.deleteFileByID(delData[1], true);
					
					CoviMap userformMap = new CoviMap();
					userformMap.put("folderID", folderID);
					userformMap.put("sortKey", delData[0]);					
					CoviMap userFormData = (CoviMap) contentsUserSvc.selectUserFormData(userformMap).get("desc");
					
					if(!"".equals(userFormData.get("UserFormID"))) {
						CoviMap delfileMap = new CoviMap();
						delfileMap.put("userFormID", userFormData.get("UserFormID"));
						delfileMap.put("gotoLink", "");
						contentsUserSvc.updateUserformGotoLink(delfileMap);
					}
				}
			}
			
			// 컴포넌트 이미지 추가
			int imgFileCnt = Integer.parseInt(paramMap.get("imgFileCnt"));
			
			if(imgFileCnt > 0) {
				
				String[] imgCid = paramMap.get("imgCid").split("-");
				
				for (int i = 0; i < imgCid.length; i++) {
					String cid = imgCid[i];
					
					MultipartFile fileInfo = req.getFile("imgFile" + cid);
					
					if(fileInfo != null && fileInfo.getSize()>0) {
						CoviMap userformMap = new CoviMap();
						userformMap.put("folderID", folderID);
						userformMap.put("sortKey", cid);
						
						CoviMap userFormData = (CoviMap) contentsUserSvc.selectUserFormData(userformMap).get("desc");
						
						String userFormID = userFormData.getString("UserFormID");
						String gotoLink = userFormData.getString("GotoLink");
						
						if(gotoLink != null && !"".equals(gotoLink)) {
							gotoLink = gotoLink.replace("/covicore/common/view/", "");
							gotoLink = gotoLink.replace(".do", "");
							
							fileUtilService.deleteFileByID(gotoLink, true);
						}
						
						List<MultipartFile> mockedFileList = new ArrayList<>();
						mockedFileList.add(fileInfo);
						
						CoviList fileObj = fileUtilService.uploadToBack(null, mockedFileList, fileSvcPath, fileSvcType, userFormID, "NONE", "0", false);
						
						CoviMap fileRs = (CoviMap) fileObj.get(0);
						userformMap.put("userFormID", userFormID);
						userformMap.put("gotoLink", "/covicore/common/view/" + fileRs.get("FileID") + ".do");
						contentsUserSvc.updateUserformGotoLink(userformMap);
					}
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (ArrayIndexOutOfBoundsException e) {
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
	
	// 컨텐츠 앱  차트 추가
	@RequestMapping(value = "contents/addFolderChart.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addFolderChart(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");
			CoviMap reqMap = new CoviMap();
			reqMap.put("folderID", folderID);
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("chartName", request.getParameter("chartName"));
			reqMap.put("chartType", request.getParameter("chartType"));
			reqMap.put("chartCol", request.getParameter("chartCol"));
			reqMap.put("chartMethod", request.getParameter("chartMethod"));
			reqMap.put("chartSubCol", request.getParameter("chartSubCol"));
			int returnCnt= contentsUserSvc.insertFolderChart(reqMap);
			
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
	
	// 컨텐츠 앱  차트 수정
	@RequestMapping(value = "contents/saveFolderChart.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveFolderChart(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String chartID = request.getParameter("chartID");
			CoviMap reqMap = new CoviMap();
			reqMap.put("chartID", chartID);
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("chartName", request.getParameter("chartName"));
			reqMap.put("chartType", request.getParameter("chartType"));
			reqMap.put("chartCol", request.getParameter("chartCol"));
			reqMap.put("chartMethod", request.getParameter("chartMethod"));
			reqMap.put("chartSubCol", request.getParameter("chartSubCol"));
			int returnCnt= contentsUserSvc.updateFolderChart(reqMap);
			
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
	
	// 컨텐츠 앱  차트삭제
	@RequestMapping(value = "contents/deleteFolderChart.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteFolderChart(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String chartID = request.getParameter("chartID");
			CoviMap reqMap = new CoviMap();
			reqMap.put("chartID", chartID);
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			int returnCnt= contentsUserSvc.deleteFolderChart(reqMap);
			
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
	
	// 컨텐츠 앱 리스트 순서 변경
	@RequestMapping(value = "contents/saveUserFormList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveUserFormList(@RequestParam Map<String, Object> params, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		JSONParser parser = new JSONParser();
		try {
			String domainID = SessionHelper.getSession("DN_ID"); 
			
			String folderID = (String)params.get("folderID");
			List colInfo = (List)parser.parse((String)params.get("colsInfo"));
			StringBuffer displayCol = new StringBuffer();
			CoviList userFormList = new CoviList();
			for (int i=0; i < colInfo.size(); i++){
				if (i>0) displayCol.append(",");
				displayCol.append(((CoviMap)colInfo.get(i)).get("key"));
				if (((CoviMap)colInfo.get(i)).get("isUserForm").equals("Y")){
					userFormList.add(((CoviMap)colInfo.get(i)).get("key"));
				}
			}
			
			CoviMap reqMap = new CoviMap();
			reqMap.put("folderID", folderID);
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("sortCols", displayCol.toString());
			reqMap.put("userFormList", userFormList);
			//returnData.put("folderPathName", configMap.get("FolderPathName"));
			int returnCnt= contentsUserSvc.updateBoardConfigSort(reqMap);
			
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
	
	//폴더 권한 팝업 화면
	@RequestMapping(value = "contents/ContentsFolderACLPopup.do")
	public ModelAndView contentsFolderACLPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsFolderACLPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		mav.addObject("folderID", request.getParameter("folderID"));
		
		return mav;
	}
	
	//폴더 권한 처리
	@RequestMapping(value = "contents/updateFolderACL.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateFolderACL(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			//권한 설정 정보 
			params.put("folderID", request.getParameter("folderID"));
			params.put("objectID", request.getParameter("folderID"));
			params.put("objectType", "FD");
			params.put("userCode", SessionHelper.getSession("USERID"));
	
			//ACL정보 삭제
			authSvc.deleteACL(params);
			
			//ACL정보 재등록
			String aclList = request.getParameter("aclList");
			CoviList aclArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(aclList, "utf-8"));
			insertACLData(aclArray, params);
			
			// 권한 상속 처리
			if (RedisDataUtil.getBaseConfig("useBoardInherited", params.getString("domainID")).equals("Y")
				&& StringUtil.isNotNull(params.getString("isInherited")) && params.getString("isInherited").equals("Y")) {
				insertInheritedACLData(aclArray, params);
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
	 * 권한 정보 추가
	 * @param aclArray
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public int insertACLData(CoviList aclArray, CoviMap params) throws Exception{
		int cnt = 0;
		
		for(int i=0;i<aclArray.size();i++){
			CoviMap aclObj = aclArray.getJSONObject(i);
			String[] aclShard = aclObj.get("AclList").toString().split("(?!^)");		//ACL List 한글자씩 파싱
			params.put("objectID", params.get("folderID"));			//ObjectID: FolderID
			params.put("objectType", "FD");							//ObjectType: FD
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
		
		// 상속 권한 처리
		authSvc.setInheritedACL(params.getString("folderID"), "FD", false);
		
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
	
	//등록, 수정 화면
	@RequestMapping(value = "contents/ContentsFolderUpload.do", method = RequestMethod.GET)
	public ModelAndView contentsFolderUpload(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsFolderUpload";
		ModelAndView mav		= new ModelAndView(returnURL);
	
		try {
			String folderID = request.getParameter("folderID");
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			CoviMap result = userDefFieldManageSvc.selectUserDefFieldGridList(params);
			mav.addObject("folderData", configMap);
			mav.addObject("folderID", folderID);
			mav.addObject("formList", result.get("list"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return mav;

	}
	
	//미리보기
	@RequestMapping(value = "contents/ContentsPreview.do", method = RequestMethod.GET)
	public ModelAndView contentsPreview(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/contents/ContentsPreview";
		ModelAndView mav		= new ModelAndView(returnURL);
	
/*		try {
			String folderID = request.getParameter("folderID");
			String chartID = request.getParameter("chartID");
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("chartID", chartID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("IsSearchItem", "Y");
			CoviList chartList= contentsUserSvc.getChartData(params);
			CoviMap result = boardCommonSvc.selectUserDefFieldList(params);
			//CoviMap result = userDefFieldManageSvc.selectUserDefFieldGridList(params);
			mav.addObject("searchItem", result.get("list"));
			mav.addObject("chartList", chartList);
			mav.addObject("folderID", folderID);
			mav.addObject("chartID", chartID);
		} catch (Exception e) {
		}*/
		return mav;
	}

	//폴더 추가 팝업 화면
	@RequestMapping(value = "contents/ContentsUserFormAddSavePopup.do")
	public ModelAndView contentsUserFormAddSavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/contents/ContentsUserFormAddSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		mav.addObject("folderID", request.getParameter("folderID"));
		
		return mav;
	}
			
}
