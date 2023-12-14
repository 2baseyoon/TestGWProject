package egovframework.covision.groupware.board.mobile.web;

import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import egovframework.baseframework.util.json.JSONSerializer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.util.BoardUtils;

@Controller
@RequestMapping("/mobile/board")
public class MOBoardCommonCon {

	@Autowired
	private BoardCommonSvc boardCommonSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private BoardManageSvc boardManageSvc;
	
	@Autowired
	private MessageACLSvc messageACLSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	//게시판 목록  - 트리 조회
	@RequestMapping(value = "/getTreeData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTreeData(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap params = null;
		try {
			// 폴더 트리 조회
			String domainID = SessionHelper.getSession("DN_ID");
			String userCode = SessionHelper.getSession("USERID");
			String lang = SessionHelper.getSession("lang");
			//String menuID = ConfigHelper.getBaseConfig("BoardMain", SessionHelper.getSession("DN_ID"));	//TODO: BoardMain 메뉴셋팅에서 가져온 하드코딩임
			String menuID = request.getParameter("menuID");
			String bizSection = request.getParameter("bizSection"); //"Board";
			String communityID = StringUtil.replaceNull(request.getParameter("communityID"), "");
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			String menuCode = request.getParameter("menuCode");
			
			params = new CoviMap();
			params.put("domainID", domainID);
			params.put("userCode", userCode);
			params.put("lang", lang);
			params.put("menuID", menuID);
			params.put("bizSection", bizSection);
			params.put("groupPath", groupPath);
			params.put("communityID", communityID);
			params.put("IsMobileSupport", "Y");
			
			String serviceType = bizSection;
			if(communityID != null && !communityID.isEmpty()){
				serviceType = "Community";
			}
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr",objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			params.put("bizSection", serviceType);
			params.put("objectType", "FD");
			
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
			result = (CoviList) boardCommonSvc.selectTreeFolderMenu(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap tempobj = new CoviMap();					
				String strFolderName = "";
				tempobj = (CoviMap) jsonobject;		
				strFolderName = tempobj.get("FolderName").toString();
				tempobj.put("DisplayName", strFolderName);				
				resultList.add(tempobj);
			}
			
			//조회결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("treedata", resultList);
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			result = null;
			params = null;
		}
		
		return returnList;
	}
		
	//게시글 목록 조회
	@RequestMapping(value = "/getBoardMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBoardMessageList(HttpServletRequest request, HttpServletResponse response) {

		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviMap params = new CoviMap();
		
		int nTotal = 0;
		//기본값 및 파라미터 셋팅
		String bizSection = request.getParameter("bizSection");
		String menuID = request.getParameter("menuID");
		String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");
		String viewType = request.getParameter("viewType");
		String folderID = request.getParameter("folderID");
		String folderType = request.getParameter("folderType");
		String searchType = "Mobile";	//전체 검색(제목+내용+등록)
		String searchText = request.getParameter("searchText");
		String startDate = "";
		String endDate = "";
		String sortColumn =  request.getParameter("sortColumn") == null ? "" : request.getParameter("sortColumn");
		String sortDirection = request.getParameter("sortDirection") == null ? "desc" : request.getParameter("sortDirection");
		String page = request.getParameter("page");
		String pageSize = request.getParameter("pageSize");
		String categoryGubun = request.getParameter("categoryGubun");
		String categoryID = request.getParameter("categoryID");
		String boxType = request.getParameter("boxType");
		
		String communityID = request.getParameter("communityID");
		
		//TODO: 아래항목 추가할것
		String requestStatus = "";
		String readSearchType = "";
		String approvalStatus = request.getParameter("approvalStatus");
		String useTopNotice = request.getParameter("UseTopNotice");
		String useUserForm = "";
		
		String menuCode = request.getParameter("menuCode");
		params.put("isSaaS", isSaaS);
		
		if ("N".equals(isSaaS) && menuCode != null) {
			String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
			params.put("orgRootMenuID", orgRootMenuID);
		}
		
		// 보안등급 및 열람권한에 맞는 목록 조회 여부
		String IsUseListRestriction = RedisDataUtil.getBaseConfig("IsUseListRestriction", SessionHelper.getSession("DN_ID"));
		
		try {
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("bizSection", bizSection);
			params.put("menuID", menuID);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("boardType", boardType);
			params.put("viewType", viewType);
			params.put("folderID", folderID);
			params.put("folderType", folderType);
			params.put("searchType", searchType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("pageNo", page);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("categoryGubun", categoryGubun);
			params.put("categoryID", categoryID);
			params.put("requestStatus", requestStatus);
			params.put("readSearchType", readSearchType);
			params.put("boxType", boxType);
			params.put("approvalStatus", approvalStatus);
			params.put("useTopNotice", useTopNotice);
			params.put("useUserForm", useUserForm);
			params.put("communityID", communityID);
			params.put("isMobileSupport",'Y');// 모바일지원 여부
			
			params.put("IsUseListRestriction", "".equals(IsUseListRestriction) ? "N" : IsUseListRestriction); // 보안등급 및 열람권한 조건에 맞는 목록 표시 여부
			params.put("userSecurityLevel", SessionHelper.getSession("SecurityLevel"));
			params.put("groupPath", SessionHelper.getSession("GR_GroupPath").split(";"));
			
			BoardUtils.getViewAclData(params);
			
			if("DistributeDoc".equals(boardType)){	//배포 문서함
				//전체 건수 조회 및 파라미터 처리
				nTotal = messageSvc.selectDistributeGridCount(params);
				params.addAll(ComUtils.setPagingData(params, nTotal));
				
				result = (CoviList) messageSvc.selectDistributeGridList(params).get("list");
			} 
			else if(!boardType.equalsIgnoreCase("Normal")) {//전체 글 보기, 내가 작성한 게시, 작성중인 게시, 수정 요청 게시, 예약 게시, 스크랩
				//전체 건수 조회 및 파라미터 처리
				nTotal = messageSvc.selectMessageGridCount(params);
				params.addAll(ComUtils.setPagingData(params, nTotal));

				// 값이 비어있지 않고, boardType이 Scrap일 경우, 최근 스크랩 등록일 순으로 정렬
				if(!boardType.isEmpty() && boardType.equals("Scrap")){
					params.put("sortColumn", "RegistDate");
				}
				
				// 각 게시판들에서 게시판 관리자를 일일이 가져오기에는 속도 문제가 있어 게시판 관리자는 일반 사용자와 같은 목록을 조회. 
				result = (CoviList) messageSvc.selectMessageGridList(params).get("list");
			} else {//일반 게시판 (Normal 없는거) 및 승인 요청 게시 / 나의 게시
				// 보안등급 및 열람권한에 맞는 목록 조회 여부를 사용할 때, 게시판 관리자는 조건과 상관없이 모든 게시물을 조회할 수 있다.
				if("Y".equalsIgnoreCase(IsUseListRestriction)) {
					// 게시판 운영자는 해당 폴더의 모든 게시글 조회 가능
					String folderOwnerCode = StringUtil.replaceNull(messageACLSvc.selectFolderOwnerCode(params), "");
					if(folderOwnerCode.indexOf(params.getString("userCode") + ";") != -1) {
						params.put("IsUseListRestriction", "N");
					}
				}
				
				//전체 건수 조회 및 파라미터 처리
				nTotal = messageSvc.selectNormalMessageGridCount(params);
				params.addAll(ComUtils.setPagingData(params, nTotal));
				
				result = (CoviList) messageSvc.selectNormalMessageGridList(params).get("list");
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("totalcount", nTotal);
			returnList.put("list", result);
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			result = null;
			params = null;
		}
		
		return returnList;
		
	}

	//게시글 상세정보 조회
	@RequestMapping(value = "/getBoardMessageView.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBoardMessageView(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnList = new CoviMap();
		
		CoviMap resultConfig = new CoviMap();
		CoviMap resultView = new CoviMap();
		CoviList resultFile = new CoviList();
		CoviMap resultPrevNext = new CoviMap();
		CoviList resultTag = new CoviList();
		CoviList resultLink = new CoviList();
		CoviMap resultUserDefField = new CoviMap();
		CoviList resultLinkedMsgList = new CoviList();
		CoviList resultFolderList = new CoviList();
		CoviList resultReadAuthList = new CoviList();
		CoviList resultAuthList = new CoviList();
		
		CoviMap params = new CoviMap();
		
		//기본값 셋팅
		String bizSection = StringUtil.replaceNull(request.getParameter("bizSection"), "");
		String boardType = request.getParameter("boardType");
		String folderID = request.getParameter("folderID");
		String messageID = request.getParameter("messageID");
		String version = request.getParameter("version");		
		String searchType = "Total";
		String searchText = request.getParameter("searchText");
		String startDate = "";
		String endDate = "";
		String sortColumn = "";
		//if(bizSection.equals("Doc")) sortColumn = "RevisionDate";
		String sortDirection = "desc";
		String page = request.getParameter("page");
		String communityID = request.getParameter("communityID");
		String readFlagStr = request.getParameter("readFlagStr");
		
		// 보안등급 및 열람권한에 맞는 목록 조회 여부
		String IsUseListRestriction = RedisDataUtil.getBaseConfig("IsUseListRestriction", SessionHelper.getSession("DN_ID"));
		
		if(communityID != null && !"".equals(communityID)){
			communityID = communityID.isEmpty() ? null : communityID; 
			bizSection = "Community";
		}
		
		try {
			// 1. 게시 환경설정 조회	//TODO: 환경설정별 처리 필요
			params = new CoviMap();
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			resultConfig = boardManageSvc.selectBoardConfig(params);
			
			// 2. 게시 상세정보 조회
			params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("folderID", folderID);
			params.put("messageID", messageID);
			params.put("version", version);
			params.put("readFlagStr", readFlagStr);		//읽음확인 추가
			
			resultView = messageSvc.selectMessageDetail(params);
			
			// 3. 첨부 조회
			params = new CoviMap();
			params.put("ServiceType", bizSection);
			params.put("ObjectID", folderID);
			params.put("ObjectType", "FD");
			params.put("MessageID", messageID);
			params.put("Version", version);
			
			resultFile = fileSvc.selectAttachAll(params);
			
			//TODO: 댓글 조회는 별도로 (+ 좋아요 포함)
			
			// 4. 이전글/다음글
			if(!bizSection.equalsIgnoreCase("Doc")) {
				params = new CoviMap();
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				params.put("menuID", request.getParameter("menuID"));
				
				if ("N".equals(isSaaS) && "Board".equals(bizSection) && ("".equals(communityID) || communityID == null)) {
					String menuCode = (request.getParameter("menuCode") == null) ? "BoardMain" : request.getParameter("menuCode");
					String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
					params.put("orgRootMenuID", orgRootMenuID);
					
					String menuID = RedisDataUtil.getBaseConfig(menuCode, SessionHelper.getSession("DN_ID"));
					params.put("menuID", menuID);
					params.put("isSaaS", isSaaS);
				}
				
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("bizSection", bizSection);
				params.put("boardType", boardType);
				params.put("folderID", folderID);
				params.put("categoryID", "");//TODO: categoryID??
				params.put("messageID", messageID);
				params.put("version", version);
				params.put("searchType", searchType);
				params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
				params.put("startDate", startDate);
				params.put("endDate", endDate);
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
				params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100) );
				params.put("page", page);
				params.put("communityID", communityID);
				params.put("IsUseListRestriction", IsUseListRestriction); // 보안등급 및 열람권한 조건에 맞는 목록 표시 여부
				params.put("userSecurityLevel", SessionHelper.getSession("SecurityLevel"));
				params.put("groupPath", SessionHelper.getSession("GR_GroupPath").split(";"));
				
				BoardUtils.getViewAclData(params);
				
				params.put("mode", "prev");
				resultPrevNext.put("prev", messageSvc.selectPrevNextMessage(params));
				
				params.put("mode", "next");
				resultPrevNext.put("next", messageSvc.selectPrevNextMessage(params));
			}
			
			// 5. 태그
			params = new CoviMap();
			params.put("messageID", messageID);
			params.put("version", version);
			
			resultTag = (CoviList) messageSvc.selectMessageTagList(params).get("list");
			
			// 6. 링크
			params = new CoviMap();
			params.put("messageID", messageID);
			
			resultLink = (CoviList) messageSvc.selectMessageLinkList(params).get("list");
			
			// 7. 사용자 정의필드 
			params = new CoviMap();
			params.put("folderID", folderID);
			resultUserDefField.put("def_list", boardCommonSvc.selectUserDefFieldList(params).get("list"));
			
			params = new CoviMap();
			params.put("messageID", messageID);
			params.put("version", version);
			resultUserDefField.put("def_value", messageSvc.selectUserDefFieldValue(params).get("list"));
			
			// 8. 연결글 조회
			params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("messageID", messageID);
			params.put("version", version);
			
			resultLinkedMsgList = (CoviList) messageSvc.selectLinkedMessageList(params).get("list");
			
			// 9. 게시판 트리 - 이동/복사에 사용
			params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("communityID", communityID);
			params.put("menuID", resultConfig.getString("MenuID"));
			params.put("IsMobileSupport", "Y");
			//Folder Path 조회
			resultFolderList = (CoviList) boardCommonSvc.selectBoardList(params).get("list");
			
			String isAdmin = SessionHelper.getSession("isAdmin");
			
			// 관리자가 아닌경우 작성권한 체크
			if(!isAdmin.equalsIgnoreCase("Y")) {
				String serviceType = bizSection;
				if(communityID != null && !"".equals(communityID)){
					serviceType = "Community";
				}
				
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, "C");
				CoviList filterList = new CoviList();
				
				for(int i=0; i < resultFolderList.size(); i++) {
					CoviMap folderObj = (CoviMap) resultFolderList.get(i);
					if(authorizedObjectCodeSet.contains(folderObj.getString("optionValue"))) {
						filterList.add(folderObj);
					}
				}
				resultFolderList = filterList;
			}
			
			// 10. 열람 권한
			params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("bizSection", bizSection);
			params.put("messageID", messageID);
			params.put("folderID", folderID);
			
			resultReadAuthList = (CoviList) messageACLSvc.selectMessageReadAuthList(params).get("list");
			
			// 11. 상세 권한
			params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("bizSection", bizSection);
			params.put("messageID", messageID);
			params.put("version", version);
			
			resultAuthList = (CoviList) messageACLSvc.selectMessageAuthList(params).get("list");
			
			//리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("config", resultConfig);
			returnList.put("view", resultView);
			returnList.put("file", resultFile);
			returnList.put("prevnext", resultPrevNext);
			returnList.put("tag", resultTag);
			returnList.put("link", resultLink);
			returnList.put("userdef", resultUserDefField);
			returnList.put("linked", resultLinkedMsgList);
			returnList.put("treedata", resultFolderList);
			returnList.put("readauth", resultReadAuthList);
			returnList.put("auth", resultAuthList);
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			resultConfig = null;
			resultView = null;
			resultFile = null;
			resultPrevNext = null;
			resultTag = null;
			resultLink = null;
			resultUserDefField = null;
			resultLinkedMsgList = null;
			params = null;
		}
		
		return returnList;
	}

	//컨텐츠 본문 조회
	@RequestMapping(value = "/getContentMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getContentMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			returnData.put("data", messageSvc.selectContentMessage(params));
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
	
	//게시판 목록 조회(작성 selectbox)
	@RequestMapping(value = "/selectBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardList(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviMap params = null;
		
		try {
			// 폴더 트리 조회
			String bizSection = request.getParameter("bizSection"); //"Board";
			String domainID = SessionHelper.getSession("DN_ID");
			String communityID = StringUtil.replaceNull(request.getParameter("communityID"), "");
			String menuID = request.getParameter("menuID");
			
			params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("domainID", domainID);
			params.put("communityID", communityID);
			params.put("menuID", menuID);
			params.put("IsMobileSupport", "Y");
			
			String serviceType = bizSection;
			if(communityID != null && !communityID.isEmpty() && !communityID.equals("")){
				serviceType = "Community";
			}
				
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr",objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			params.put("bizSection", serviceType);
			params.put("objectType", "FD");
				
			//Folder Path 조회
			result = (CoviList) boardCommonSvc.selectBoardList(params).get("list");
						
			//조회결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("treedata", result);
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			result = null;
			params = null;
		}
		
		return returnList;
	}
		
		
	//게시글 작성 (신규/임시저장)
	@RequestMapping(value = "/createMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createMessage(MultipartHttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnList = new CoviMap();
		CoviMap resultConfig = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		String userCode = SessionHelper.getSession("USERID");
		String groupCode = SessionHelper.getSession("GR_Code");
		String domainID = SessionHelper.getSession("DN_ID");
		String userName = request.getParameter("userName");
				
		String bizSection = request.getParameter("bizSection");
		String mode = request.getParameter("mode").toLowerCase();	//'create', 'reply', 'update', 'revision', 'migrate'+ 
		String folderID = request.getParameter("folderID");			//게시판 선택
		String folderType = "";										//게시판 종류
		
		String categoryID = request.getParameter("categoryID");		//카테고리
		
		String subject = request.getParameter("subject");			//제목
		String isTop = request.getParameter("isTop");				//상단공지-사용여부
		String topStartDate = request.getParameter("topStartDate");	//상단공지-시작일
		String topEndDate = request.getParameter("topEndDate");		//상단공지-종료일
		
		//첨부
		String fileInfos = request.getParameter("fileInfos");	//첨부파일 정보
		String fileCnt = request.getParameter("fileCnt");		//첨부파일 갯수
		
		//본문
		String body = request.getParameter("body");             //본문
		String bodyText = request.getParameter("bodyText");		//본문text
		String bodySize = request.getParameter("bodySize");		//본문사이즈
		String bodyInlineImage = request.getParameter("bodyInlineImage");			//인라인 이미지
		String bodyBackgroundImage = request.getParameter("bodyBackgroundImage");	//배경  이미지
		String frontStorageURL = request.getParameter("frontStorageURL");			//front storage
		
		String tagList = request.getParameter("tagList");		//태그
		String linkList = request.getParameter("linkList");		//링크
		
		//상세설정
		String useSecurity = request.getParameter("useSecurity");		//비밀글
		String useScrap = request.getParameter("useScrap");				//스크랩
		String useReplyNotice = request.getParameter("useReplyNotice");	//답글알림
		String useCommNotice = request.getParameter("useCommNotice");	//댓글알림
		
		String useAnonym = request.getParameter("useAnonym");			//익명 게시
		String usePubDeptName = request.getParameter("usePubDeptName");	//부서명 게시
		
		String securityLevel = request.getParameter("securityLevel");	//보안등급
		
		String useMessageReadAuth = request.getParameter("useMessageReadAuth");	//열람권한 사용여부
		String messageReadAuth = request.getParameter("messageReadAuth");		//열람권한
		String aclList = request.getParameter("aclList");						//상세권한
		
		String noticeMedia = request.getParameter("noticeMedia");//알림
		
		String expiredDate = request.getParameter("expiredDate");			//만료일
		String keepyear = request.getParameter("keepyear");					//보존년한
		
		String reservationDate = request.getParameter("reservationDate");	//등록예약
		
		String isUserForm = "";
		String fieldList = request.getParameter("fieldList");	//사용자 정의필드
		
		String isApproval = "N";
		
		String ownerCode = request.getParameter("ownerCode") == null ? userCode : request.getParameter("ownerCode");
		
		String isInherited = "";
		
		String msgType = request.getParameter("msgType");	//메시지 유형 (O: 원본, S: 스크랩)
		String version = request.getParameter("version");	//버전
		String msgState = request.getParameter("msgState");	//메세지 상태(C등록,D반려,A승인,P잠금,R승인요청,T임시저장, BC등록예약,BA예약승인,BR예약승인요청)
		String depth = request.getParameter("depth");		//답글 깊이
		String seq = request.getParameter("seq");			//순서
		String step = request.getParameter("step");			//스텝
		
		String number = request.getParameter("number");						//문서번호
		String messageID = request.getParameter("messageID");				//message ID
		String isAutoDocNumber = request.getParameter("isAutoDocNumber");	//자동발번 사용여부
		String registDept = request.getParameter("registDept");				//등록부서
		
		String linkedMessage = request.getParameter("linkedMessage"); //연결문서
		
		String CSMU = request.getParameter("CSMU");
		String communityId = request.getParameter("communityId");
		
		String Receivers = request.getParameter("Receivers");
		String Excepters = request.getParameter("Excepters");
		
		String LinkURL = request.getParameter("LinkURL");
		
		if(communityId != null && !"".equals(communityId)) {
			bizSection = "Community";
		}

		//TODO: 여기부터 하드코딩
		
		String useRSS = "Y";
		String isPopup = request.getParameter("isPopup");				//팝업공지-사용여부
		String popupStartDate = request.getParameter("popupStartDate");	//팝업공지-시작일
		String popupEndDate = request.getParameter("popupEndDate");		//팝업공지-종료일
		
		// 값이 비어있을경우 NULL 값으로 전달
		userName = userName != null && userName.isEmpty() ? SessionHelper.getSession("UR_Name") : userName;
		securityLevel = securityLevel != null && securityLevel.isEmpty() ? null : securityLevel; 
					
		try {
			
			// 1. 게시 환경설정 조회
			params = new CoviMap();
			params.put("folderID", folderID);
			
			resultConfig = boardManageSvc.selectBoardConfig(params);
			
			folderType = resultConfig.get("FolderType").toString();
			isUserForm = resultConfig.get("UseUserForm") != null ? resultConfig.get("UseUserForm").toString(): "N";
			
			if((resultConfig.get("UseOwnerProcess") != null && resultConfig.get("UseOwnerProcess").toString().equals("Y")) || (resultConfig.get("UseUserProcess") != null && resultConfig.get("UseUserProcess").toString().equals("Y"))) {
				isApproval = "Y";
				msgState = "R";
			}
				
			isInherited = resultConfig.get("IsInherited").toString();
			
			// 2. 게시글 등록
			params = new CoviMap();
			
			params.put("userCode", userCode);
			params.put("creatorName", userName);
			params.put("groupCode", groupCode);
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			params.put("mode", mode);
			params.put("folderID", folderID);
			params.put("folderType", folderType);
			params.put("categoryID", categoryID);
			params.put("subject", subject);
			params.put("isTop", isTop);
			params.put("topStartDate", topStartDate);
			params.put("topEndDate", topEndDate);
			params.put("fileInfos", fileInfos);
			params.put("fileCnt", fileCnt);
			params.put("body", body);
			params.put("bodyText", bodyText);
			params.put("bodySize", bodySize);
			params.put("bodyInlineImage", bodyInlineImage);
			params.put("bodyBackgroundImage", bodyBackgroundImage);
			params.put("frontStorageURL", frontStorageURL);
			params.put("tagList", tagList);
			params.put("linkList", linkList);
			params.put("useSecurity", useSecurity);
			params.put("useScrap", useScrap);
			params.put("useReplyNotice", useReplyNotice);
			params.put("useCommNotice", useCommNotice);
			params.put("useAnonym", useAnonym);
			params.put("usePubDeptName", usePubDeptName);
			params.put("securityLevel", securityLevel);
			params.put("useMessageReadAuth", useMessageReadAuth);
			params.put("messageReadAuth", messageReadAuth);
			params.put("aclList", aclList);
			params.put("expiredDate", expiredDate);
			params.put("keepyear", keepyear);
			params.put("keepYear", keepyear);
			params.put("reservationDate", reservationDate);
			params.put("isUserForm", isUserForm);
			params.put("fieldList", fieldList);
			params.put("isApproval", isApproval);
			params.put("ownerCode", ownerCode);
			params.put("isInherited", isInherited);
			params.put("msgType", msgType);
			params.put("version", version);
			params.put("msgState", msgState);
			params.put("depth", depth);
			params.put("seq", seq);
			params.put("step", step);
			params.put("useRSS", useRSS);
			params.put("isPopup", isPopup);
			params.put("docNumber", number);
			params.put("isAutoDocNumber", isAutoDocNumber);
			params.put("registDept", registDept);
			params.put("messageID", messageID);
			params.put("noticeMedia", noticeMedia);
			params.put("linkedMessage", linkedMessage);
			params.put("CSMU", CSMU);
			params.put("communityId", communityId);
			params.put("Receivers", Receivers);
			params.put("Excepters", Excepters);
			params.put("isPopup", isPopup);
			params.put("popupStartDate", popupStartDate );
			params.put("popupEndDate", popupEndDate );
			
			if("LinkSite".equals(folderType)) {
				params.put("linkURL", LinkURL);
			}
			
			if(params.get("reservationDate") != null && !params.get("reservationDate").equals("")){
				params.put("reservationLocalDate",ComUtils.TransServerTime(params.get("reservationDate").toString())); //timezone이 적용된 예약일시 
			}
			
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			int cnt = messageSvc.createMessage(params, mf);
			
			//리턴
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "OK");
				returnList.put("messageID", params.get("messageID"));
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			params = null;
		}
		
		return returnList;
	}

	//게시글 수정
	@RequestMapping(value = "/updateMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultConfig = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		String userCode = SessionHelper.getSession("USERID");
		String userName = request.getParameter("userName");
		
		String bizSection = request.getParameter("bizSection");
		String mode = request.getParameter("mode").toLowerCase();	//'create', 'reply', 'update', 'revision', 'migrate'+ 
		String folderID = request.getParameter("folderID");			//게시판 선택
		String folderType = "";										//게시판 종류
		
		String categoryID = request.getParameter("categoryID");		//카테고리
		
		String subject = request.getParameter("subject");			//제목
		String isTop = request.getParameter("isTop");				//상단공지-사용여부
		String topStartDate = request.getParameter("topStartDate");	//상단공지-시작일
		String topEndDate = request.getParameter("topEndDate");		//상단공지-종료일
		
		//첨부
		String fileInfos = request.getParameter("fileInfos");	//첨부파일 정보
		String fileCnt = request.getParameter("fileCnt");		//첨부파일 갯수
		
		String body = request.getParameter("body");		//본문
		String bodyText = request.getParameter("bodyText");		//본문
		String bodySize = request.getParameter("bodySize");		//본문사이즈
		String bodyInlineImage = request.getParameter("bodyInlineImage");
		String bodyBackgroundImage = request.getParameter("bodyBackgroundImage");
		String frontStorageURL = request.getParameter("frontStorageURL");
		
		String tagList = request.getParameter("tagList");		//태그
		String linkList = request.getParameter("linkList");		//링크
		
		//상세설정
		String useSecurity = request.getParameter("useSecurity");		//비밀글
		String useScrap = request.getParameter("useScrap");				//스크랩
		String useReplyNotice = request.getParameter("useReplyNotice");	//답글알림
		String useCommNotice = request.getParameter("useCommNotice");	//댓글알림
		
		String useAnonym = request.getParameter("useAnonym");			//익명 게시
		String usePubDeptName = request.getParameter("usePubDeptName");	//부서명 게시
		
		String securityLevel = request.getParameter("securityLevel");	//보안등급
		
		String useMessageReadAuth = request.getParameter("useMessageReadAuth");	//열람권한 사용여부
		String messageReadAuth = request.getParameter("messageReadAuth");		//열람권한
		String aclList = request.getParameter("aclList");						//상세권한
		
		String noticeMedia = request.getParameter("noticeMedia");//알림
		
		String expiredDate = request.getParameter("expiredDate");			//만료일
		String keepyear = request.getParameter("keepyear");					//보존년한
		
		String reservationDate = request.getParameter("reservationDate");	//등록예약
		
		String isUserForm = "";
		String fieldList = request.getParameter("fieldList");	//사용자 정의필드
		
		String isApproval = "N";
		
		String ownerCode = request.getParameter("ownerCode") == null ? userCode : request.getParameter("ownerCode");
		
		String isInherited = "";
		
		String msgType = request.getParameter("msgType");	//메시지 유형 (O: 원본, S: 스크랩)
		String version = request.getParameter("version");	//버전
		String msgState = request.getParameter("msgState");	//메세지 상태(C등록,D반려,A승인,P잠금,R승인요청,T임시저장, BC등록예약,BA예약승인,BR예약승인요청)
		String depth = request.getParameter("depth");		//답글 깊이
		String seq = request.getParameter("seq");			//순서
		String step = request.getParameter("step");			//스텝
		
		String number = request.getParameter("number");		//문서번호
		String messageID = request.getParameter("messageID");//message ID
		
		String linkedMessage = request.getParameter("linkedMessage"); //연결문서
		
		String CSMU = request.getParameter("CSMU");
		String communityId = request.getParameter("communityId");
		
		String LinkURL = request.getParameter("LinkURL");
		String boardType = request.getParameter("boardtype");
		
		if(communityId != null && !"".equals(communityId)) {
			bizSection = "Community";
		}
				
		//TODO: 여기부터 하드코딩
		
		String useRSS = "Y";
		String isPopup = request.getParameter("isPopup");				//팝업공지-사용여부
		String popupStartDate = request.getParameter("popupStartDate");	//팝업공지-시작일
		String popupEndDate = request.getParameter("popupEndDate");		//팝업공지-종료일
		
		// 값이 비어있을경우 NULL 값으로 전달
		userName = userName != null && userName.isEmpty() ? SessionHelper.getSession("UR_Name") : userName;
		securityLevel = securityLevel != null && securityLevel.isEmpty() ? null : securityLevel; 
				
		try {
			
			// 1. 게시 환경설정 조회
			params = new CoviMap();
			params.put("folderID", folderID);
			
			resultConfig = boardManageSvc.selectBoardConfig(params);
			
			folderType = resultConfig.get("FolderType").toString();
			isUserForm = resultConfig.get("UseUserForm") != null ? resultConfig.get("UseUserForm").toString(): "N";
			boolean temp = (resultConfig.get("UseOwnerProcess") != null && resultConfig.get("UseOwnerProcess").toString().equals("Y")) || (resultConfig.get("UseUserProcess") != null && resultConfig.get("UseUserProcess").toString().equals("Y"));
			if(temp) isApproval = "Y";
			isInherited = resultConfig.get("IsInherited").toString();
			
			// 2. 게시글 등록
			params = new CoviMap();
			
			params.put("userCode", userCode);
			params.put("bizSection", bizSection);
			params.put("mode", mode);
			params.put("folderID", folderID);
			params.put("folderType", folderType);
			params.put("categoryID", categoryID);
			params.put("subject", subject);
			params.put("isTop", isTop);
			params.put("topStartDate", topStartDate);
			params.put("topEndDate", topEndDate);
			params.put("fileInfos", fileInfos);
			params.put("fileCnt", fileCnt);
			params.put("body", body);
			params.put("bodyText", bodyText);
			params.put("bodySize", bodySize);
			params.put("bodyInlineImage", bodyInlineImage);
			params.put("bodyBackgroundImage", bodyBackgroundImage);
			params.put("frontStorageURL", frontStorageURL);
			params.put("tagList", tagList);
			params.put("linkList", linkList);
			params.put("useSecurity", useSecurity);
			params.put("useScrap", useScrap);
			params.put("useReplyNotice", useReplyNotice);
			params.put("useCommNotice", useCommNotice);
			params.put("useAnonym", useAnonym);
			params.put("usePubDeptName", usePubDeptName);
			params.put("securityLevel", securityLevel);
			params.put("useMessageReadAuth", useMessageReadAuth);
			params.put("messageReadAuth", messageReadAuth);
			params.put("aclList", aclList);
			params.put("expiredDate", expiredDate);
			params.put("keepyear", keepyear);
			params.put("keepYear", keepyear);
			params.put("reservationDate", reservationDate);
			params.put("isUserForm", isUserForm);
			params.put("fieldList", fieldList);
			params.put("isApproval", isApproval);
			params.put("ownerCode", ownerCode);
			params.put("isInherited", isInherited);
			params.put("msgType", msgType);
			params.put("version", version);
			params.put("msgState", msgState);
			params.put("depth", depth);
			params.put("seq", seq);
			params.put("step", step);
			params.put("useRSS", useRSS);
			params.put("isPopup", isPopup);
			params.put("docNumber", number);
			params.put("messageID", messageID);
			params.put("noticeMedia", noticeMedia);
			params.put("linkedMessage", linkedMessage);	
			params.put("creatorName", userName);
			params.put("CSMU", CSMU);
			params.put("communityId", communityId);
			params.put("isPopup", isPopup);
			params.put("popupStartDate", popupStartDate );
			params.put("popupEndDate", popupEndDate );
			
			if("LinkSite".equals(folderType)) {
				params.put("LinkURL", LinkURL);
			}
			
			// 임시저장한 게시물의 경우 boardType(OnWriting) 구분.
			params.put("boardType", boardType);
			
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			//CoviMap params = new CoviMap();
			//BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			//params.put("userCode", SessionHelper.getSession("USERID"));
			int cnt = messageSvc.updateMessage(params, mf);
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
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
		} finally {
			params = null;
		}
		
		return returnList;	
	}
	
	//게시판 설정 조회
	@RequestMapping(value = "/selectBoardConfig.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardConfig(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");			//폴더 ID
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
		    returnData.put("config",boardManageSvc.selectBoardConfig(params));
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
	
	//게시판 카테고리 목록 조회
	@RequestMapping(value = "/selectCategoryList.do", method = RequestMethod.POST)
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
	
	//댓글용
	
	//게시글 상세정보 조회
	@RequestMapping(value = "/getBoardMessageInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBoardMessageInfo(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnList = new CoviMap();
		
		CoviMap resultView = new CoviMap();
		
		CoviMap params = new CoviMap();
		
		//기본값 셋팅
		String bizSection = request.getParameter("bizSection");
		String messageID = request.getParameter("messageID");
		String version = request.getParameter("version");
		
		try {
			//게시 상세정보 조회
			params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("messageID", messageID);
			params.put("version", version);
			
			resultView = (CoviMap) messageSvc.selectMessageDetailSimple(params).get("list");

			//리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("view", resultView);
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			resultView = null;
			params = null;
		}
		
		return returnList;
	}

	//게시글 조회 권한
	@RequestMapping(value = "/checkReadAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkReadAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		boolean bReadFlag = false;
		
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			String userCode = SessionHelper.getSession("USERID");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", userCode);
			params.put("groupPath", groupPath);
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			//접속자가 작성자,소유자,등록부서에 해당하는 부서는 무조건 읽기가능
			//접속자가 작성자,소유자,등록부서에 해당하는 부서는 무조건 읽기가능			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("bizSection");
			
			if(!msgMap.getString("FolderID").equals(params.get("folderID"))){	//parameter로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을때 실패처리 
				returnData.put("flag", bReadFlag);
				returnData.put("status", Return.SUCCESS);
				return returnData;
			}
			
			if("Board".equals(params.getString("bizSection")) && "Y".equals(SessionHelper.getSession("isAdmin"))){		//관리자
				bReadFlag = true;
			} else if (msgMap.getString("FolderOwnerCode").indexOf(userCode+";") != -1){	//게시판 담당자
				bReadFlag = true;
			} else if ("QuickComment".equals(msgMap.getString("FolderType"))){				//한줄게시
				bReadFlag = true;
			} else if (userCode.equals(msgMap.getString("CreatorCode"))){					//작성자
				bReadFlag = true;
			} else if (userCode.equals(msgMap.getString("OwnerCode"))){						//문서 소유자
				bReadFlag = true;
			} else if ("Doc".equals(params.getString("bizSection")) && userCode.equals(SessionHelper.getSession("GR_Code"))){ //소속,담당부서
				bReadFlag = true;
			} else {
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (params.getString("bizSection").equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = null;
					
					//BOARD_MESSAGE_ACL 테이블에서 데이터 조회
					if(!communityID.isEmpty()){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					bReadFlag = messageACLSvc.checkAclShard("TargetType", "R", aclArray);
				} else {
					if(!communityID.isEmpty()){
						serviceType = "Community";
					}
					
					Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, "R");
					bReadFlag = authorizedObjectCodeSet.contains(params.get("folderID"));
				}
				
				//열람권한 사용 시
				if( "Y".equals(msgMap.getString("UseMessageReadAuth")) ) {
					int cnt = messageACLSvc.selectMessageReadAuthCount(params); 
					int allCount = messageACLSvc.selectMessageReadAuthListCnt(params);
					
					if(allCount > 0 && cnt < 1) {  //지정된 열람권한이 있으나 현 사용자에게 권한이 없을 경우 읽기 권한을 주지 않는다.
						bReadFlag = false;
					}
				}
			}
			
			returnData.put("flag", bReadFlag);
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
	
	//pType : TargetType, ObjectType acl테이블의 컬럼명
	//pShard: Security, Create, Delete, Modify, Read ( board_message_acl 기준 으로 5개의 권한 컬럼만 사용 ) 
	private boolean checkAclShard(String pType, String pShard, CoviList pArray){
		boolean bFlag = false;
		for(int i = 0; i < pArray.size(); i++){
			CoviMap aclObj = pArray.getJSONObject(i);
			
			if("UR".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
				break;
			} else if("DN".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			} else if("CM".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			} else {
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			}
		}
		return bFlag;
	}
	
	//열람권한 확인 - item list 형식이 아니라 조회데이터 개수로 열람 가능 여부 판단 (0 .. *)
	@RequestMapping(value = "/selectMessageReadAuthCount.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageReadAuthCount(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		int cnt = 0;
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("groupPath", groupPath);
			params.put("userCode", SessionHelper.getSession("USERID"));
			cnt = messageACLSvc.selectMessageReadAuthCount(params);
			
			returnData.put("page", params);
			returnData.put("count", cnt);
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
	
	//상세보기화면 내부 권한별 버튼 표시/숨김 및 문서관리 Grid 권한아이콘 표시용
	@RequestMapping(value = "/selectMessageAclList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageAclList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("groupPath", groupPath);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			CoviList aclArray = new CoviList();
			CoviMap aclObj = new CoviMap();
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
			//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
			if(!params.getString("messageID").isEmpty()){
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (params.getString("bizSection").equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {		
					//board_message_acl 테이블에서 데이터 조회
					if(!params.getString("communityID").isEmpty()){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					aclObj.put("Security", messageACLSvc.checkAclShard("TargetType", "S", aclArray)? "S":"_");
					aclObj.put("Create", messageACLSvc.checkAclShard("TargetType", "C", aclArray)? "C":"_");
					aclObj.put("Delete",messageACLSvc.checkAclShard("TargetType", "D", aclArray)? "D":"_");
					aclObj.put("Modify", messageACLSvc.checkAclShard("TargetType", "M", aclArray)? "M":"_");
					aclObj.put("Execute", messageACLSvc.checkAclShard("TargetType", "E", aclArray)? "E":"_");
					aclObj.put("View", "_");	// 상세권한에는 View 권한 없음
					aclObj.put("Read", messageACLSvc.checkAclShard("TargetType", "R", aclArray)? "R":"_");
					
					returnData.put("creatorCode", msgMap.get("CreatorCode"));
					returnData.put("ownerCode", msgMap.get("OwnerCode"));
					returnData.put("folderOwnerCode", msgMap.get("FolderOwnerCode"));
					returnData.put("registDept", msgMap.get("RegistDept"));
				} else {
					String serviceType = params.getString("bizSection");
					
					if(!params.getString("communityID").isEmpty()){
						serviceType = "Community";
					}
					
					ACLMapper aclMap = ACLHelper.getACLMapper(SessionHelper.getSession(), "FD", serviceType);
					String aclList = aclMap.getACLListInfo(params.getString("folderID"));

					boolean isAdmin = false;
					isAdmin = BoardUtils.getAdminAuth(params);
					
					aclObj.put("Security", aclList.charAt(0));
					aclObj.put("Create", (isAdmin) ? "C" : aclList.charAt(1));
					aclObj.put("Delete", (isAdmin) ? "D" : aclList.charAt(2));
					aclObj.put("Modify", (isAdmin) ? "M" : aclList.charAt(3));
					aclObj.put("Execute", (isAdmin) ? "E" : aclList.charAt(4));
					aclObj.put("View", (isAdmin) ? "V" : aclList.charAt(5));
					aclObj.put("Read", (isAdmin) ? "R" : aclList.charAt(6));
					
					aclArray.add(aclObj);
				}
			} else {
				String serviceType = params.getString("bizSection");
				
				if(!params.getString("communityID").isEmpty()){
					serviceType = "Community";
				}
				
				ACLMapper aclMap = ACLHelper.getACLMapper(SessionHelper.getSession(), "FD", serviceType);
				String aclList = aclMap.getACLListInfo(params.getString("folderID"));
				aclObj.put("Security", aclList.charAt(0));
				aclObj.put("Create", aclList.charAt(1));
				aclObj.put("Delete", aclList.charAt(2));
				aclObj.put("Modify", aclList.charAt(3));
				aclObj.put("Execute", aclList.charAt(4));
				aclObj.put("View", aclList.charAt(5));
				aclObj.put("Read", aclList.charAt(6));
				
				aclArray.add(aclObj);
			}
			
			returnData.put("page", params);
			returnData.put("list", aclArray);
			returnData.put("creatorCode", msgMap.get("CreatorCode"));
			returnData.put("ownerCode", msgMap.get("OwnerCode"));
			returnData.put("folderOwnerCode", msgMap.get("FolderOwnerCode"));
			returnData.put("registDept", msgMap.get("RegistDept"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	//게시판 권한 가져오기
	@RequestMapping(value = "/selectBoardACLData.do", method = RequestMethod.POST)
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
	
	//게시글 삭제
	@RequestMapping(value = "/deleteMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteMessage(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		try {	
			String messageID = request.getParameter("messageID"); //게시글
			String registIP = request.getRemoteHost();
			
			params.put("messageID", messageID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("historyType", "Delete");
			params.put("comment", "");
			params.put("registIP", registIP);			
			
			int cnt = messageSvc.deleteMessage(params);
			
			//리턴
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "OK");
				returnList.put("messageID", params.get("messageID"));
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "게시글 삭제에 실패했습니다.");
			}
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			params = null;
		}
		return returnList;
	}
		
	//게시글 신고
	@RequestMapping(value = "/reportMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap reportMessage(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnData = new CoviMap();

		CoviMap params = new CoviMap();
		
		try {			
			String messageID = request.getParameter("messageID"); //게시글
			String registIP = request.getRemoteHost();
			
			params.put("messageID", messageID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", registIP);
			params.put("historyType", "Report");
			params.put("comment", "");
			
			int chk = messageSvc.checkExistReport(params);	//중복 신고 체크 
			
			if(chk > 0 ){
				returnData.put("message", DicHelper.getDic("msg_AlreadySingo"));	//이미 신고처리 하셨습니다.
			} else {
				messageSvc.reportMessage(params);			//게시글 신고
				returnData.put("message", DicHelper.getDic("msg_SingoProcessed"));	//신고처리 하였습니다.
			}
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			params = null;
		}
		
		return returnData;
	}
	
	//게시글 복사
	@RequestMapping(value = "/copyMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap copyMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID = request.getParameter("messageID"); //Message ID
			String folderID = request.getParameter("folderID"); //Folder ID
			String orgFolderID = request.getParameter("orgFolderID"); //원본 폴더 ID
			String bizSection = request.getParameter("bizSection");
			String comment = request.getParameter("comment");
			String version = request.getParameter("version");
			String registIP = request.getRemoteHost();
			
			CoviMap params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("orgMessageID",messageID);
			params.put("folderID", folderID);
			params.put("orgFolderID", orgFolderID);
			params.put("comment", comment);
			params.put("historyType", "Copy");
			params.put("registIP", registIP);
			
			//업로드 파일 조회용 parameter 설정
			params.put("ServiceType", bizSection);
			params.put("ObjectID", orgFolderID);
			params.put("ObjectType", "FD");
			params.put("MessageID", messageID);
			params.put("Version", "");
			params.put("version", version);
			
			params.put("fileInfos", JSONSerializer.toJSON(fileSvc.selectAttachAll(params)));	//upload파일은 같이 조회
			
			messageSvc.copyMessage(params);			//게시글 복사
			
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
	
	//게시글 이동
	@RequestMapping(value = "/moveMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID = request.getParameter("messageID"); //Message ID
			String folderID = request.getParameter("folderID"); //Folder ID
			String orgFolderID = request.getParameter("orgFolderID"); //원본 폴더 ID
			String bizSection = request.getParameter("bizSection");
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			CoviMap params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("messageID",messageID);
			params.put("folderID", folderID);
			params.put("orgFolderID", orgFolderID);
			params.put("comment", comment);
			params.put("historyType", "Move");
			params.put("registIP", registIP);
			
			messageSvc.moveMessage(params);			//게시글 이동			
			
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
	
	//게시글 스크랩
	@RequestMapping(value = "/scrapMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap scrapMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			messageSvc.scrapMessage(params);			//게시글 스크랩
			
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
		
	//조회자 목록 
	@RequestMapping(value = "/selectMessageViewerGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageViewer(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String messageID = StringUtil.replaceNull(request.getParameter("messageID"), "");						
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortColumn"), "");
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortDirection"), "");
			
			String pageNo = StringUtil.replaceNull(request.getParameter("page"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("messageID", messageID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
            params.put("lang", SessionHelper.getSession("lang"));
			
			int cnt = messageSvc.selectMessageViewerGridCount(params);	//조회항목 count
			
			params.addAll(ComUtils.setPagingData(params,cnt));			//페이징 parameter set			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = messageSvc.selectMessageViewerGridList(params);
			
			returnData.put("totalcnt", cnt);
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
	
	//현재 사용자의 부서 검색 
	@RequestMapping(value = "/selectRegistDeptList.do", method = RequestMethod.POST)
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
	
	//게시 버전별 이력 조회
	@RequestMapping(value = "/selectRevisionHistory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRevisionHistory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectRevisionHistory(params);
			
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
	 * selectMessageDetail: 게시글 상세보기 및 파일 목록 조회, 수정시 데이터 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/selectMessageDetail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageDetail(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			//업로드 파일 조회용 parameter 설정
			params.put("ServiceType", request.getParameter("bizSection"));
			params.put("ObjectID", request.getParameter("folderID"));
			params.put("ObjectType", "FD");
			params.put("messageID", request.getParameter("messageID"));
			params.put("MessageID", request.getParameter("messageID"));
			params.put("Version", request.getParameter("version"));
			
			returnData.put("list", messageSvc.selectMessageDetail(params));
			returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
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
	 * updateCheckOutState: 문서게시글 체크아웃 상태 변경
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/updateCheckOutState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCheckOutState(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", request.getRemoteHost());
			
			int chk = messageSvc.selectMessageCheckOutStatus(params);	//체크아웃 여부확인
			
			if(chk > 0 ){
				messageSvc.updateCheckOutState(params);			//게시글 체크아웃 상태 변경
				returnData.put("message", DicHelper.getDic("msg_Processed"));	//처리 되었습니다
			} else {
				if(params.get("actType").equals("Out") && params.get("actType").equals("Renew")){
					returnData.put("message", DicHelper.getDic("AlreadyCheckOut"));	//확인후 작성
				} else {
					returnData.put("message", DicHelper.getDic("AlreadyCheckIn"));	//
				}
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
	 * selectFolderPath
	 * @param request FolderID
	 * @param response
	 * @param paramMap
	 * @description 현재 선택한 게시판의 상위 폴더를 표시
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/selectFolderPath.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFolderPath(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String[] folderIDs  = StringUtil.replaceNull(request.getParameter("folderPath"), "").split(";");    //변경할 폴더ID
			CoviMap params = new CoviMap();
			params.put("folderIDs", folderIDs);

			//Folder Path 조회
			result = (CoviList) boardCommonSvc.selectFolderPath(params).get("list");
		    
			StringBuffer sbFolderPath = new StringBuffer();
		    for(Object jsonobject : result){
		    	//해당 폴더 이름 부분 조회
		    	sbFolderPath.append(((CoviMap) jsonobject).getString("DisplayName") + ">");
			}
			
		    returnData.put("folderPath", sbFolderPath.toString());
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
	
	//권한 요청 세부 정보 조회
	@RequestMapping(value = "/selectRequestAclDetail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRequestAclDetail(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("lang", SessionHelper.getSession("lang"));
			CoviMap map = messageACLSvc.selectRequestAclDetail(params);
			
			returnData.put("data", map);
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
	
	@RequestMapping(value = "/createRequestAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createRequestAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt = messageACLSvc.checkDuplicateRequest(params);
			if(cnt >0){
				returnData.put("message", DicHelper.getDic("msg_AlreadyRegisted"));
			} else {
				messageACLSvc.createRequestAuth(params);
				returnData.put("message", DicHelper.getDic("msg_successSave"));
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
	
	//권한 요청 게시물: 승인
	@RequestMapping(value = "/allowMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap allowMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";");
			String requestID[] = StringUtil.replaceNull(request.getParameter("requestID"), "").split(";");
			String version[] = StringUtil.replaceNull(request.getParameter("version"), "").split(";");
			String comment = request.getParameter("comment");
			String customAcl = request.getParameter("customAcl");
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("requestID", requestID[i]);
				params.put("version", version[i]);
				params.put("ActType", "A");
				params.put("ActMessage", comment);
				params.put("CustomAcl", customAcl);
				messageACLSvc.updateRequestAuth(params);			//권한 요청 정보 수정
			}
			returnData.put("message", DicHelper.getDic("msg_Approved"));	//승인 완료
			
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	//권한 요청 게시물: 거부
	@RequestMapping(value = "/denieMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap denieMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";");
			String requestID[] = StringUtil.replaceNull(request.getParameter("requestID"), "").split(";");
			String version[] = StringUtil.replaceNull(request.getParameter("version"), "").split(";");
			String comment = request.getParameter("comment");
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("requestID", requestID[i]);
				params.put("version", version[i]);
				params.put("ActType", "D");
				params.put("ActMessage", comment);
				
				messageACLSvc.updateRequestAuth(params);			//권한 요청 정보 수정
			}
			returnData.put("message", DicHelper.getDic("msg_Processed"));	//처리 완료.
			
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	//문서 배포
	@RequestMapping(value = "/distributeDoc.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap distributeDoc(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt = messageSvc.distributeDoc(params);
			
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
	
	//문서 권한
	@RequestMapping(value = "/selectMessageAuthList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageAuthList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = messageACLSvc.selectMessageAuthList(params);
			
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
	
	//승인 요청 게시물: 승인
	@RequestMapping(value = "/acceptMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap acceptMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //MessageID
			String processID[] = StringUtil.replaceNull(request.getParameter("processID"), "").split(";"); //ProcessID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("processID", processID[i]);
				params.put("comment", comment);
				params.put("historyType", "Approval");
				params.put("registIP", registIP);
				
				messageSvc.acceptMessage(params);			//게시글 삭제
			}
			returnData.put("message", DicHelper.getDic("msg_Approved"));	//승인 완료
			
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	//승인 요청 게시물: 거부
	@RequestMapping(value = "/rejectMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap rejectMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //MessageID
			String processID[] = StringUtil.replaceNull(request.getParameter("processID"), "").split(";"); //ProcessID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("processID", processID[i]);
				params.put("comment", comment);
				params.put("historyType", "Return");
				params.put("registIP", registIP);
				
				messageSvc.rejectMessage(params);			//게시글 삭제
			}
			returnData.put("message", DicHelper.getDic("msg_Processed"));	//처리 완료.
			
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	@RequestMapping(value = "/selectSearchMessageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSearchMessageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		try {
			String bizSection = request.getParameter("bizSection");
			String menuID = request.getParameter("menuID");
			String communityID = request.getParameter("communityID");
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("bizSection", bizSection);
			params.put("menuID", menuID);
			params.put("communityID", func.f_NullCheck(communityID));
			
			BoardUtils.setRequestParam(request, params);
			BoardUtils.getViewAclData(params);
			int cnt = messageSvc.selectSearchMessageGridCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = messageSvc.selectSearchMessageGridList(params);
			
			returnData.put("page", params);
			returnData.put("totalcount", cnt);
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

	@RequestMapping(value = "/selectSecurityLevelList.do", method = RequestMethod.POST)
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
	
	@RequestMapping(value = "/selectUserDefFieldList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
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
	
	@RequestMapping(value = "/selectUserDefFieldValue.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldValue(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			
			String pMessageID = request.getParameter("messageID");
			String pVersion = request.getParameter("version");
			
			params.put("messageID", pMessageID);
			params.put("version", pVersion);
			
			resultList = messageSvc.selectUserDefFieldValue(params);
			
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

	@RequestMapping(value = "/selectUserDefFieldOptionList.do", method = RequestMethod.POST)
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
	
	@RequestMapping(value = "/selectBoardIsMobileSupport.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardIsMobileSupport(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
	
		try {
			CoviMap params = new CoviMap();
			params.put("folderID", request.getParameter("folderID"));

			//모바일 지원여부 조회
			returnData = (CoviMap) boardCommonSvc.selectBoardIsMobileSupport(params);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
}
