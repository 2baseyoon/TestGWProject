package egovframework.covision.groupware.board.user.web;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.auth.BoardAuth;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.util.BoardUtils;

/**
 * @Class Name : MessageACLCon.java
 * @Description : [사용자] 통합게시 - 게시글 권한 관리
 * @Modification Information 
 * @ 2017.08.07 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 08.03
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageACLCon {
	
	private Logger LOGGER = LogManager.getLogger(MessageACLCon.class);
	
	@Autowired
	MessageACLSvc messageACLSvc;
	
	@Autowired
	AuthorityService authSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 작성권한 체크
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/checkWriteAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkWriteAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		int cnt = 0;
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			String userCode = SessionHelper.getSession("USERID");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", userCode);
			params.put("groupPath", groupPath);
			params.put("folderID", params.getString("objectID"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			//접속자가 작성자,소유자,등록부서에 해당하는 부서는 무조건 읽기가능
			
			boolean bWriteFlag = false;
			if("Y".equals(SessionHelper.getSession("isAdmin"))){	//관리자
				bWriteFlag = true;
			} else if (msgMap.getString("FolderOwnerCode").indexOf(userCode+";") != -1){	//게시판 담당자
				bWriteFlag = true;
			} else if (userCode.equals(msgMap.getString("CreatorCode"))){					//작성자
				bWriteFlag = true;
			} else {
				bWriteFlag = BoardAuth.getWriteAuth(params);
			}
			
			returnData.put("flag", bWriteFlag);
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
	 * 조회 권한 체크
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/checkReadAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkReadAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		boolean bReadFlag = false;
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			bReadFlag = BoardUtils.getReadAuth(params);
			
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
	
	/**
	 * 수정 권한 체크
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/checkModifyAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkModifyAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		boolean bModifyFlag = false;
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			bModifyFlag = BoardUtils.getModifyAuth(params);
			
			returnData.put("flag", bModifyFlag);
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
	
	//AclList 정보 조회
//	@RequestMapping(value = "board/selectBoardAclData.do", method = RequestMethod.POST)
//	public @ResponseBody CoviMap selectBoardAclData(HttpServletRequest request, HttpServletResponse response) throws Exception{
//		CoviMap returnData = new CoviMap();
//		int cnt = 0;
//		try {
//			CoviMap params = new CoviMap();
//			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
//			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
//			String userCode = SessionHelper.getSession("USERID");
//			params.put("lang", SessionHelper.getSession("lang"));
//			params.put("userCode", userCode);
//			params.put("groupPath", groupPath);
//			
//			String aclData = "_____";
//			if("Board".equals(params.getString("bizSection")) && "Y".equals(SessionHelper.getSession("isAdmin"))){		//관리자
//				aclData = "SCDMR";
//			} else {
//				CoviList aclArray = authSvc.selectACL(params);
//				aclData = getAclList("SubjectType", aclArray);
//			}
//			
//			returnData.put("aclData", aclData);
//			returnData.put("status", Return.SUCCESS);
//		} catch (Exception e) {
//			returnData.put("status", Return.FAIL);
//			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
//		}
//
//		return returnData;
//	}
	
	/**
	 * 열람권한 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectMessageReadAuthList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageReadAuthList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = messageACLSvc.selectMessageReadAuthList(params);
			
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
	
	/**
	 * checkReadAuth.do에서 체크하도록 주석처리
	 * 
	 * 열람권한 확인 - item list 형식이 아니라 조회데이터 개수로 열람 가능 여부 판단 (0 .. *)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	/* 
	@RequestMapping(value = "board/selectMessageReadAuthCount.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageReadAuthCount(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		int cnt = 0, allCnt = 0;
			
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("groupPath", groupPath);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			allCnt = messageACLSvc.selectMessageReadAuthListCnt(params);
			cnt = messageACLSvc.selectMessageReadAuthCount(params);
			
			returnData.put("page", params);
			returnData.put("allCount", allCnt);
			returnData.put("count", cnt);
			returnData.put("status", Return.SUCCESS);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	*/
	
	/**
	 * 게시글 권한목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectMessageAuthList.do", method = RequestMethod.POST)
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
	
	
	/**
	 * 상세보기화면 내부 권한별 버튼 표시/숨김 및 문서관리 Grid 권한아이콘 표시용
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectMessageAclList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageAclList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("groupPath", groupPath);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("deptCode", SessionHelper.getSession("DEPTID"));
			
			if(StringUtil.isNotEmpty(params.get("requestorCode").toString())) {
				params.put("userCode", params.get("requestorCode").toString());
			}
			
			CoviMap aclObj = new CoviMap();
			
			//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
			//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
			if(!params.getString("messageID").isEmpty()){
				CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (params.getString("bizSection").equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = new CoviList();
					
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
			}
			
			returnData.put("page", params);
			returnData.put("aclObj", aclObj);
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
	
	/**
	 * 권한 요청 세부 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectRequestAclDetail.do", method = RequestMethod.POST)
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
	
	/**
	 * 권한 요청 정보 생성
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/createRequestAuth.do", method = RequestMethod.POST)
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
	
	/**
	 * 권한 요청 게시물: 승인
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/allowMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap acceptMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
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
	
	/**
	 * 승인 요청 게시물: 거부
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/denieMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap rejectMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
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
	
	@RequestMapping(value = "board/checkExecuteAuth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkFileDownloadAuth(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		boolean bExecuteFlag = false;
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			bExecuteFlag = BoardUtils.getExecuteAuth(params);
			
			returnData.put("flag", bExecuteFlag);
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
