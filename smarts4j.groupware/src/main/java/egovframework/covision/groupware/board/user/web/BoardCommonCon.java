package egovframework.covision.groupware.board.user.web;

import java.util.Locale;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.util.BoardUtils;

/**
 * @Class Name : BoardCommonCon.java
 * @Description : 게시판 공통 Controller
 * @Modification Information 
 * @ 2017.07.26 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.26
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class BoardCommonCon {
	
	//NOSONAR private Logger LOGGER = LogManager.getLogger(BoardCommonCon.class);
	
	@Autowired
	BoardCommonSvc boardCommonSvc;
	
	@Autowired
	BoardManageSvc boardManageSvc;
	
	@Autowired
	MessageSvc messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	/**
	 * 작성하기 버튼 선택시 이동
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goWrite.do", method = RequestMethod.GET) 
	public ModelAndView goWrite(HttpServletRequest request, Locale locale, Model model) throws Exception {
		String returnURL = "board/BoardWrite.board";
		String mode = request.getParameter("mode");
		String bizSection = request.getParameter("bizSection");
		String version = request.getParameter("version");
		String folderID = request.getParameter("folderID");
		String messageID = request.getParameter("messageID");
		String domainID = SessionHelper.getSession("DN_ID");
		CoviMap params = new CoviMap();
		
		params.put("domainID", domainID);
		
		//권한 체크 필요
		CoviList securityLevelList = (CoviList) boardManageSvc.selectSecurityLevelList(params).get("list");
		ModelAndView mav = new ModelAndView(returnURL);

		//문서에서 수정 페이지 이동시 체크아웃 자동 설정
		if("update".equals(mode) && "Doc".equals(bizSection)){
			params.put("messageID", messageID);
			params.put("version", version);
			params.put("userCode", SessionHelper.getSession("USERID"));
			boardCommonSvc.updateMessageCheckOut(params);
		}
		
		mav.addObject("mode", mode);
		mav.addObject("bizSection", bizSection);
		mav.addObject("version", version);
		mav.addObject("folderID", folderID);
		mav.addObject("messageID", messageID);	//update, reply
		mav.addObject("securityLevelList", securityLevelList);
		return mav;
	}
	
	/**
	 * 게시글 목록 페이지 이동처리
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goBoardList.do", method = RequestMethod.GET)
	public ModelAndView goBoardList(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "board/BoardList.board";
		ModelAndView mav = new ModelAndView(returnURL);
		
		String boardType = request.getParameter("boardType")==null?"Normal":request.getParameter("boardType");
		String menuID = request.getParameter("menuID")==null?"":request.getParameter("menuID");
		String folderID = request.getParameter("folderID")==null?"":request.getParameter("folderID");
		
		mav.addObject("boardType", boardType);
		mav.addObject("menuID", menuID);
		mav.addObject("folderID", folderID);
		return mav;
	}
	
	/**
	 * 게시글 상세보기 페이지 이동처리
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goView.do", method = RequestMethod.GET) 
	public ModelAndView goView(HttpServletRequest request, Locale locale, Model model) throws Exception {
		String returnURL = "board/BoardView.board";
		String version = request.getParameter("version");
		String folderID = request.getParameter("folderID");
		String messageID = request.getParameter("messageID");
		String boardType = request.getParameter("boardType")==null?"Normal":request.getParameter("boardType");
		
		//권한 체크 필요
		ModelAndView mav = new ModelAndView(returnURL);
		
		//조회수 및 조회자 추가
		mav.addObject("boardType", boardType);
		mav.addObject("messageID", messageID);
		mav.addObject("folderID", folderID);
		mav.addObject("version", version);
		return mav;
	}
	
	/**
	 * 즐겨찾기(관심 게시판) 설정 팝업 - 사용안함
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goFavoriteConfigPopup.do", method = RequestMethod.GET)
	public ModelAndView goFavoriteConfigPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/FavoriteConfigPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * 복사/이동/이관 설정 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goMoveBoardTreePopup.do", method = RequestMethod.GET)
	public ModelAndView goMoveBoardTreePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/MoveBoardTreePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 조회용 폴더 트리 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goSearchBoardTreePopup.do", method = RequestMethod.GET)
	public ModelAndView goSearchBoardTreePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/SearchBoardTreePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 게시글 연결/바인더용 게시글 조회 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goSearchMessagePopup.do", method = RequestMethod.GET)
	public ModelAndView goSearchMessagePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/SearchMessagePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 수정요청/삭제/잠금 등의 코멘트 설정용 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goCommentPopup.do", method = RequestMethod.GET)
	public ModelAndView goCommentPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/commentPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 상세보기 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goBoardViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardViewPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/BoardViewPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 미리보기 상세보기 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goBoardPreViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardPreViewPopup(HttpServletRequest request) throws Exception{
		String returnURL = "user/board/BoardPreViewPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 열람권한 설정 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goReadAuthPopup.do", method = RequestMethod.GET)
	public ModelAndView goReadAuthPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/BoardReadAuthPopup";
		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 상세권한 설정 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goMessageAuthPopup.do", method = RequestMethod.GET)
	public ModelAndView goMessageAuthPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/BoardACLPopup";
		
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "board/goViewerPopup.do", method = RequestMethod.GET)
	public ModelAndView goViewerPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/ViewerListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 게시글 처리 이력 목록 팝업 호출
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "board/goHistoryPopup.do", method = RequestMethod.GET)
	public ModelAndView goMessageHistoryListPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/HistoryListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * 권한요청 조회 팝업 페이지 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goRequestAuthPopup.do", method = RequestMethod.GET)
	public ModelAndView goRequestAuthPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/DocRequestAuthPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goApproveAuthPopup.do", method = RequestMethod.GET)
	public ModelAndView goApproveAuthPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/DocApproveAuthPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 문서 배포 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goDistributeDocPopup.do", method = RequestMethod.GET)
	public ModelAndView goDistributeDocPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/DocDistributePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 댓글 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/goReplyPopup.do", method = RequestMethod.GET)
	public ModelAndView goReplyPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/ReplyPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 에디터 팝업 호출
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goEditorPopup.do", method = RequestMethod.GET)
	public ModelAndView goEditorPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/EditorPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	@RequestMapping(value = "board/goEditorPopupRegError.do", method = RequestMethod.GET)
	public ModelAndView goEditorPopupRegError(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/EditorPopupRegError";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	@RequestMapping(value = "board/goBoardWritePopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardWritePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/board/BoardWrite";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 게시판 폴더 트리메뉴 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectFolderTreeData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderTreeList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String bizSection = request.getParameter("bizSection");
		String menuCode = request.getParameter("menuCode");
		String menuID = getMenuID(request.getParameter("menuID"),bizSection);

		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		
		try{
			CoviMap params = new CoviMap();

			String domainID = SessionHelper.getSession("DN_ID");
			String userCode = SessionHelper.getSession("USERID");
			String isAdmin = SessionHelper.getSession("isAdmin");
			String useDocMultiCategory = RedisDataUtil.getBaseConfig("useDocMultiCategory");
			
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("domainID", domainID);
			params.put("userCode", userCode);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("menuID", menuID);
			params.put("bizSection", bizSection);
			params.put("groupPath", groupPath);
			params.put("isContents", request.getParameter("isContents"));
			params.put("useDocMultiCategory", useDocMultiCategory);
			
			// 유저는  폴더 권한 처리 skip
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();	//할당된 도메인 코드
			params.put("assignedDomain", assignedDomainList);
//			int chkSysAuth = boardCommonSvc.checkSysAuthority(params);
			
			if(!"Y".equalsIgnoreCase(isAdmin) || ("Y".equalsIgnoreCase(isAdmin) && !"0".equalsIgnoreCase(domainID) )) {
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", bizSection, "V");
				String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
				
				params.put("aclDataArr", objectArray);
				params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
				params.put("objectType", "FD");
			}
			
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
			result = (CoviList) boardCommonSvc.selectTreeFolderMenu(params).get("list");
			int index = 0;	//AXTree index array 체크용
		    for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				folderData.put("ownerFlag", folderData.get("OwnerFlag"));
				folderData.put("index", index);
				folderData.put("bizSection", bizSection);
				
				if(folderData.get("FolderType").equals("Folder") || folderData.get("FolderType").equals("Root")){
					//폴더 선택시 하위메뉴 표시하는 메소드 호출
					folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
				} else {
					folderData.put("type", "board_default");	//사용자 게시판은 아이콘 구별 하지 않음
					folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
				}
				resultList.add(folderData);
				index++;
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
	 * 게시판 폴더 트리메뉴 조회 - 팝업/라디오 버튼 선택 항목 표시 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectRadioFolderTree.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectRadioFolderTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		
		try{
			String bizSection = request.getParameter("bizSection");
			String folderID = request.getParameter("folderID");
			String menuID = request.getParameter("menuID");
			String menuCode = request.getParameter("menuCode");
			String communityID = request.getParameter("communityID");
			String multiFolderIDs = ";" + request.getParameter("multiFolderIDs") + ";";
			String userCode = SessionHelper.getSession("USERID");
			String domainID = SessionHelper.getSession("DN_ID");
			String isAdmin = SessionHelper.getSession("isAdmin");
			String isEDMS = request.getParameter("isEDMS");
			String docMultiFolder = request.getParameter("docMultiFolder");
			CoviMap params = new CoviMap();

			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("domainID", domainID);
			params.put("userCode", userCode);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("bizSection", bizSection);
			params.put("menuID", menuID);
			params.put("communityID", communityID);
			params.put("groupPath", groupPath);
			params.put("mode", "Copy");
			params.put("isEDMS", isEDMS);
			params.put("docMultiFolder", docMultiFolder);
			
			// 유저는  폴더 권한 처리 skip
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();	//할당된 도메인 코드
			params.put("assignedDomain", assignedDomainList);
			
			Set<String> createSet = null;
			Set<String> viewSet = null;
			
			
			if(!"Y".equalsIgnoreCase(isAdmin)) {
				String serviceType = bizSection;
				
				if(communityID != null && !communityID.isEmpty()){	// CommunityID가 있는경우 Community 권한 조회
					serviceType = "Community";
				}
				
				ACLMapper aclMapCommunity = ACLHelper.getACLMapper(SessionHelper.getSession(), "FD", serviceType);
				createSet = aclMapCommunity.getACLInfo("C");
				viewSet = aclMapCommunity.getACLInfo("V");
				
				String[] objectArray = viewSet.toArray(new String[viewSet.size()]);
				
				params.put("aclDataArr", objectArray);
				params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
				params.put("objectType", "FD");
				params.put("bizSection", serviceType);
			}
			
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
			result = (CoviList) boardCommonSvc.selectTreeFolderMenu(params).get("list");
			for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				folderData.put("chk", "N");
				
				if(folderData.get("FolderType").equals("Folder") || folderData.get("FolderType").equals("Root") || folderData.get("FolderType").equals("DocRoot") || folderData.get("FolderID").equals(folderID)
					|| (!multiFolderIDs.equals(";;")) && multiFolderIDs.indexOf(";" + folderData.getString("FolderID") + ";") > -1){
					folderData.put("rdo", "N");
				} else {
					if("Y".equalsIgnoreCase(isAdmin) || createSet.contains(folderData.getString("FolderID"))) {
						folderData.put("rdo", "Y");
					}else {
						folderData.put("rdo", "N");
					}					
				}
				
				if(folderData.get("FolderType").equals("Folder")){
					//폴더 선택시 하위메뉴 표시하는 메소드 호출
//					folderData.put("url", "javascript:myFolderTree.click("+ index +", \"expand\");");
				} else {
					folderData.put("type", "board_default");	//사용자 게시판은 아이콘 구별 하지 않음
				}
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
	 * 게시판 네비게이터 정보 조회
	 * @param request FolderID
	 * @param response
	 * @param paramMap
	 * @description 현재 선택한 게시판의 상위 폴더를 표시
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectFolderPath.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFolderPath(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String[] folderIDs  = StringUtil.replaceNull(request.getParameter("folderPath"), "").split(";");    //변경할 폴더ID
			CoviMap params = new CoviMap();
			params.put("folderIDs", folderIDs);

			//Folder Path 조회
			result = (CoviList) boardCommonSvc.selectFolderPath(params).get("list");
		    
			StringBuffer folderPath = new StringBuffer();
		    for(Object jsonobject : result){
		    	//해당 폴더 이름 부분 조회
		    	folderPath.append(((CoviMap) jsonobject).getString("DisplayName") + ">");
			}
			
		    returnData.put("folderPath",folderPath.toString());
		    returnData.put("list", result);
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
	 * 검색 조건용 팝업에 표시되는 게시판 트리메뉴 조회 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectSearchFolderTree.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectSearchFolderTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String menuID = request.getParameter("menuID");
		String treeType = request.getParameter("treeType");
		String menuCode = request.getParameter("menuCode");
		CoviMap params = new CoviMap();
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		try{
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("menuID", menuID);	
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Board", "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Board");
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
			result = (CoviList) boardCommonSvc.selectTreeFolderMenu(params).get("list");
		    
		    for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				//treeType 으로 트리메뉴에 라디오버튼,체크박스 사용여부 확인
				if(treeType != null && (!"Folder".equals(folderData.getString("FolderType")) || !"Root".equals(folderData.getString("FolderType"))) ){
					folderData.put(treeType.equals("checkbox")?"chk":"rdo", "Y");
				}
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
	 * 사용자 정의 필드 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectUserDefFieldList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			String isList = request.getParameter("isList")==null?"":request.getParameter("isList");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("IsList", isList);

			//Folder Path 조회
			returnList = (CoviList) boardCommonSvc.selectUserDefFieldList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * 사용정의 필드 옵션 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectUserDefFieldOptionList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldOptionList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String userFormID = request.getParameter("userFormID");
			CoviMap params = new CoviMap();
			params.put("userFormID", userFormID);

			//Folder Path 조회
			returnList = (CoviList) boardCommonSvc.selectUserDefFieldOptionList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * 작성화면에서의 게시판 목록조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			String bizSection = request.getParameter("bizSection");
			String folderID = request.getParameter("folderID");
			String communityID = request.getParameter("communityID");
			String menuID = getMenuID(request.getParameter("menuID"),bizSection);
			String domainID = SessionHelper.getSession("DN_ID");

			CoviMap params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("domainID", domainID);
			params.put("communityID", communityID);
			params.put("menuID", menuID);
			params.put("folderID", folderID);
			
			returnList = (CoviList) boardCommonSvc.selectBoardList(params).get("list");
			
			String isAdmin = SessionHelper.getSession("isAdmin");
			
			// 관리자가 아닌경우 작성권한 체크
			if(!isAdmin.equalsIgnoreCase("Y")) {
				// CommunityID가 있는경우 Community 권한 조회
				String serviceType = bizSection;
				if(communityID != null && !communityID.isEmpty() && !communityID.equals("")){
					serviceType = "Community";
				}
				
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, "C");
				CoviList filterList = new CoviList();
				
				for(int i=0; i < returnList.size(); i++) {
					CoviMap folderObj = (CoviMap) returnList.get(i);
					if(authorizedObjectCodeSet.contains(folderObj.getString("optionValue"))) {
						filterList.add(folderObj);
					}
				}
				
				returnData.put("list", filterList);
			} else {				
				returnData.put("list", returnList);
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
	 * 간편등록 게시판 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectSimpleBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSimpleBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			String domainID = SessionHelper.getSession("DN_ID");
			
			CoviMap params = new CoviMap();
			params.put("bizSection", "Board");
			params.put("domainID", domainID);
			params.put("boardMenu", RedisDataUtil.getBaseConfig("BoardMenu", domainID).split(";"));
			//Folder Path 조회
			returnList = (CoviList) boardCommonSvc.selectSimpleBoardList(params).get("list");
			
			String isAdmin = SessionHelper.getSession("isAdmin");
			
			// 관리자가 아닌경우 작성권한 체크
			if(!isAdmin.equalsIgnoreCase("Y")) {
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Board", "C");
				
				CoviList filterList = new CoviList();
				
				for(int i=0; i < returnList.size(); i++) {
					CoviMap folderObj = (CoviMap) returnList.get(i);
					if(authorizedObjectCodeSet.contains(folderObj.getString("optionValue").split("_")[1])) {
						filterList.add(folderObj);
					}
				}
				
				returnData.put("list", filterList);
			} else {				
				returnData.put("list", returnList);
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
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 * @description 보안등급 목록 조회
	 */
	@RequestMapping(value = "board/selectSecurityLevelList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSecurityLevelList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			//Folder Path 조회
			returnList = (CoviList) boardManageSvc.selectSecurityLevelList(params).get("list");
			
			returnData.put("list", returnList);
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
	
	@RequestMapping(value = "board/selectCategoryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCategoryList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
			//Folder Path 조회
			returnList = (CoviList) boardCommonSvc.selectCategoryList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 * @description 본문양식 목록 보기
	 */
	@RequestMapping(value = "board/selectBodyFormList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBodyFormList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
			//Folder Path 조회
			returnList = (CoviList) boardCommonSvc.selectBodyFormList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * 작성부서 검색
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectRegistDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRegistDeptList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnList = (CoviList) boardCommonSvc.selectRegistDeptList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * 승인선 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectProcessActivityList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectProcessActivityList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectProcessActivityList(params);
			
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
	
	/**
	 * 승인목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectProgressStateList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectProgressStateList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnList = (CoviList) boardCommonSvc.selectProgressStateList(params).get("list");
			
			returnData.put("list", returnList);
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
	 * 사용자 프로필 최근게시 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectMyInfoProfileBoardData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMyInfoProfileBoardData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		String userCode = request.getParameter("userCode");
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("sessionUserCode", SessionHelper.getSession("USERID"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Board", "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Board");
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnList = (CoviList) boardCommonSvc.selectMyInfoProfileBoardData(params).get("list");
			
			returnData.put("list", returnList);
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
	
	//메뉴 id return
	private String getMenuID(String menuID, String bizSection){
		
		if (menuID == null  || menuID.equals("")) {
			if (bizSection.equals("Doc"))
				menuID = RedisDataUtil.getBaseConfig("DocMain");
			else 
				menuID = RedisDataUtil.getBaseConfig("BoardMain");
		}
		return menuID;
	}
	
	/**
	 * 게시등록 팝업 호출(전자결재 완료문서에서 사용)
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goBoardTransferPopup.do", method = RequestMethod.GET)
	public ModelAndView goBoardTransferPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "user/board/BoardTransferPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
     * selectUserBoardTreeData - 이관 게시판 목록 조회(전자결재 완료문서에서 사용)
     * @param paramMap
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "board/selectUserBoardTreeData.do", method=RequestMethod.POST)
    public @ResponseBody CoviMap selectUserBoardTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap returnList = new CoviMap();
        CoviList resultList = new CoviList();

        String bizSection = request.getParameter("bizSection");
        String menuID = request.getParameter("menuID");
		String menuCode = request.getParameter("menuCode");
        CoviMap params = new CoviMap();
        
        try{
        	boolean isMobile = ClientInfoHelper.isMobile(request);
        	CoviMap userDataObj = SessionHelper.getSession(isMobile);
        	
            //Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
            String[] groupPath = userDataObj.getString("GR_GroupPath").split(";");
            params.put("domainID", userDataObj.getString("DN_ID"));
            params.put("userCode", userDataObj.getString("USERID"));
            params.put("lang", userDataObj.getString("lang"));
            params.put("menuID", menuID);
            params.put("bizSection", bizSection);
            params.put("groupPath", groupPath);
            
            Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Board", "V");
            String[] objectArray = authorizedObjectCodeSet.toArray(new String[0]);

            params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Board");
            
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
            //CoviList result = boardCommonSvc.selectUserBoardTreeData(params);
			CoviList result = (CoviList) boardCommonSvc.selectTreeFolderMenu(params).get("list"); //(=게시글 이동)
            
            Set<String> authorizedObjectCodeSetForCreate = ACLHelper.getACL(userDataObj, "FD", "Board", "C");
            
            int index = 0;	//AXTree index array 체크용
            for(Object jsonobject : result){
                CoviMap folderData = (CoviMap) jsonobject;
                
                Object objFolderID = folderData.get("FolderID");
                boolean hasCreateAuth = authorizedObjectCodeSetForCreate.contains(objFolderID);
                folderData.put("createAuth", (hasCreateAuth) ? "C" : "_");

                // 트리를 그리기 위한 데이터
                folderData.put("no", folderData.get("FolderID"));
                folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
                folderData.put("nodeValue", folderData.get("FolderID"));
                folderData.put("pno", folderData.get("MemberOf"));
                folderData.put("chk", "N");
                if("0".equals(folderData.get("hasChild"))){
                    folderData.put("rdo", "Y");
                }else{
                    folderData.put("rdo", "N");
                }
                folderData.put("ownerFlag", folderData.get("OwnerFlag"));
                folderData.put("index", index);
                folderData.put("bizSection", bizSection);

                if(folderData.get("FolderType").equals("Folder") || folderData.get("FolderType").equals("Root")){
                    //폴더 선택시 하위메뉴 표시하는 메소드 호출
                    folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
                } else {
                    folderData.put("type", "board_default");	//사용자 게시판은 아이콘 구별 하지 않음
                    folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
                }
                resultList.add(folderData);
                index++;
            }

            returnList.put("list", resultList);
            returnList.put("result", "ok");

            returnList.put("status", Enums.Return.SUCCESS);
            returnList.put("message", "조회되었습니다");
        } catch(NullPointerException e){
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
        } catch(Exception e){
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
        }

        return returnList;
    }
}
