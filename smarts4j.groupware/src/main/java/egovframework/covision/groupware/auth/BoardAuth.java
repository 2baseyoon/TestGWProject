package egovframework.covision.groupware.auth;

import java.util.List;
import java.util.Set;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ACLHelper;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;


public class BoardAuth {

	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static void getViewAclData(CoviMap pMap) throws Exception{
		getViewAclData(pMap, "V");
	}
		
	public static void getViewAclData(CoviMap pMap, String authType) throws Exception{
		String serviceType = pMap.getString("bizSection");
		String communityId = pMap.getString("communityID");
		if(communityId != null && !communityId.isEmpty()){
			serviceType = "Community";
		}
		
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", serviceType, authType);
		String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		
		pMap.put("aclDataArr", objectArray);
		pMap.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
		pMap.put("objectType", "FD");
	}

	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getFolderAuth(String bizSection, String folderID) throws Exception{
		return getFolderAuth(bizSection, folderID, "V");
	}
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getFolderAuth(String bizSection, String folderID, String authType) throws Exception{
		//관리자
		if("Y".equals(SessionHelper.getSession("isAdmin"))) return true;		
		if (bizSection.equals("")) bizSection ="Board";
		
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", bizSection, authType);
		String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		for(int i=0; i <objectArray.length; i++){
			if (objectArray[i].equals(folderID)){
				return true;
			}
		}
		
		if (bizSection.equals("Board")){//board로 들어오면 commutiy 도 재확인
			authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", authType);
			objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			for(int i=0; i <objectArray.length; i++){
				if (objectArray[i].equals(folderID)){
					return true;
				}
			}
		}
		
		return false;
	}	
	
	/**
	 * 게시글 읽기권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getReadAuth(CoviMap params) throws Exception{
		boolean bReadFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			int userSecurityLevel = messageACLSvc.selectUserSecurityLevel(params);
			int msgSecurityLevel = Integer.parseInt(StringUtil.isNull(msgMap.getString("SecurityLevel")) ? "256" : msgMap.getString("SecurityLevel"));
			
			//접속자가 작성자,소유자,등록부서에 해당하는 부서는 무조건 읽기가능			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			boolean bOwner = isOwner(params, msgMap);
			
			/* 폴더 아이디 체크
			 * 1. parameter로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을때
			 * 2. parameter로 들어온 FolderID와 MessageID로 조회된 MultiFolderIDs(다차원 분류 폴더 아이디)에 속하지 않을때 */
			if(!serviceType.equalsIgnoreCase("Doc") && !params.get("folderID").equals(msgMap.getString("FolderID")) && msgMap.getString("MultiFolderIDs").indexOf(params.getString("folderID")) == -1){
				params.put("folderID", msgMap.getString("folderID"));
			}
			
			if(isAuth(params, msgMap)) { //관리자
				bReadFlag = true;
			} else if (serviceType.equalsIgnoreCase("Board") && msgMap.getString("UseSecurity").equals("Y") && !bOwner){ // 비밀글
				bReadFlag = false;
			} else if (msgMap.getString("MsgState").equals("T") && !bOwner){ // 작성중인 게시
				bReadFlag = false;
			} else if ("QuickComment".equals(msgMap.getString("FolderType"))){ // 한줄게시
				bReadFlag = true;
			} else if (serviceType.equalsIgnoreCase("Doc") && !msgMap.getString("UseSecurity").equals("Y") && msgMap.getString("RegistDept").equals(SessionHelper.getSession("GR_Code"))){ // UseSecurity가 Y인 경우, 담당부서 체크를 하지 않음
				bReadFlag = true;
			} else if (isProcessActor(params, msgMap)) { // 승인프로세스 - 승인자
				bReadFlag = true;
			} else if (msgSecurityLevel == 256 || (msgSecurityLevel != 256 && userSecurityLevel <= msgSecurityLevel)){ // 보안등급
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
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
					
					bReadFlag = getFolderAuth(serviceType, params.getString("folderID"), "R");
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
			
			return bReadFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 게시글 수정권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getModifyAuth(CoviMap params) throws Exception{
		boolean bModifyFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			boolean bOwner = isOwner(params, msgMap);
			
			/* 폴더 아이디 체크
			 * 1. parameter로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을때
			 * 2. parameter로 들어온 FolderID와 MessageID로 조회된 MultiFolderIDs(다차원 분류 폴더 아이디)에 속하지 않을때 */
			if(!serviceType.equalsIgnoreCase("Doc") && !params.get("folderID").equals(msgMap.getString("FolderID"))
				&& msgMap.getString("MultiFolderIDs").indexOf(params.getString("folderID")) == -1){
				return bModifyFlag;
			}
			
			if (serviceType.equalsIgnoreCase("Board") && msgMap.getString("UseSecurity").equals("Y") && !bOwner){ // 비밀글
				bModifyFlag = false;
			} else if (msgMap.getString("MsgState").equals("T") && !bOwner){ // 작성중인 게시
				bModifyFlag = false;
			} else if (isAuth(params, msgMap)) { // 관리자
				bModifyFlag = true;
			} else {
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = null;
					//board_message_acl 테이블에서 데이터 조회
					if(!communityID.isEmpty()){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					bModifyFlag = messageACLSvc.checkAclShard("TargetType", "M", aclArray);
				} else {
					if(!communityID.isEmpty()){
						serviceType = "Community";
					}
					
					bModifyFlag = getFolderAuth(serviceType, params.getString("folderID"), "M");
				}
			}
			
			return bModifyFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * 게시글 삭제권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getDeleteAuth(CoviMap params) throws Exception{
		boolean bDeleteFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			String[] messageIDs = params.getString("messageID").split(";");
			String[] versions = params.getString("version").split(";");
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			for(int i = 0; i < messageIDs.length; i++) {
				params.put("messageID", messageIDs[i]);
				params.put("version", versions[i]);
				
				CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
				
				boolean bOwner = isOwner(params, msgMap);
				
				if (serviceType.equalsIgnoreCase("Board") && msgMap.getString("UseSecurity").equals("Y") && !bOwner){ // 비밀글
					return false;
				} else if (msgMap.getString("MsgState").equals("T") && !bOwner){ // 작성중인 게시
					bDeleteFlag = false;
				} else if (isAuth(params, msgMap)) { //관리자
					bDeleteFlag = true;
				} else {
					//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
					//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
					//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						CoviList aclArray = null;
						//board_message_acl 테이블에서 데이터 조회
						if(!communityID.isEmpty()){
							aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
						} else {
							aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
						}
						bDeleteFlag = messageACLSvc.checkAclShard("TargetType", "D", aclArray);
					} else {
						if(!communityID.isEmpty()){
							serviceType = "Community";
						}
						
						bDeleteFlag = getFolderAuth(serviceType, params.getString("folderID"), "D");
					}
					
					if(!bDeleteFlag) return false;
				}
			}
			
			return bDeleteFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 게시글 작성권한
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	public static boolean getWriteAuth(CoviMap params) throws Exception{
		boolean bWriteFlag = false;
		
		try {
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			
			if (isAuth(params, null)) {		//관리자
				bWriteFlag = true;
			} else {
				String serviceType = params.getString("serviceType");
				
				if(!communityID.isEmpty()){
					serviceType = "Community";
				}
				
				//게시글 작성권한은 전적으로 폴더권한에서 체크
				bWriteFlag = getFolderAuth(serviceType, params.getString("folderID"), "C");
			}
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		} 

		return bWriteFlag;
	}
	
	/**
	 * 게시글 조회권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getViewAuth(CoviMap params) throws Exception{
		boolean bViewFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			int userSecurityLevel = messageACLSvc.selectUserSecurityLevel(params);
			int msgSecurityLevel = Integer.parseInt(StringUtil.isNull(msgMap.getString("SecurityLevel")) ? "256" : msgMap.getString("SecurityLevel"));
			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			boolean bOwner = isOwner(params, msgMap);
			
			if(serviceType.equalsIgnoreCase("Board") && msgMap.getString("UseSecurity").equals("Y") && !bOwner){	//비밀글
				bViewFlag = false;
			} else if (msgMap.getString("MsgState").equals("T") && !bOwner){ // 작성중인 게시
				bViewFlag = false;
			} else if (isAuth(params, msgMap)) {		//관리자
				bViewFlag = true;
			} else if (serviceType.equalsIgnoreCase("Doc") && !msgMap.getString("UseSecurity").equals("Y") && msgMap.getString("RegistDept").equals(SessionHelper.getSession("GR_Code"))){ // UseSecurity가 Y인 경우, 담당부서 체크를 하지 않음
				bViewFlag = true;
			} else if (msgSecurityLevel == 256 || (msgSecurityLevel != 256 && userSecurityLevel <= msgSecurityLevel)){ // 보안등급
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = null;
					//board_message_acl 테이블에서 데이터 조회
					if(!communityID.isEmpty()){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					bViewFlag = messageACLSvc.checkAclShard("TargetType", "R", aclArray); // 상세 권한에서는 읽기 권한과 조회 권한이 동일함
				} else {
					if(!communityID.isEmpty()){
						serviceType = "Community";
					}
					
					bViewFlag = getFolderAuth(serviceType, params.getString("folderID"), "V");
				}
			}
			
			return bViewFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}	

	/**
	 * 게시글 보안권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getSecurityAuth(CoviMap params) throws Exception{
		boolean bSecurityFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			if (isAuth(params, msgMap)) {		//관리자
				bSecurityFlag = true;
			} else {
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = null;
					//board_message_acl 테이블에서 데이터 조회
					if(!communityID.isEmpty()){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					bSecurityFlag = messageACLSvc.checkAclShard("TargetType", "S", aclArray);
				} else {
					if(!communityID.isEmpty()){
						serviceType = "Community";
					}
					
					bSecurityFlag = getFolderAuth(serviceType, params.getString("folderID"), "S");
				}
			}
			
			return bSecurityFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 게시글 복사 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getCopyAuth(CoviMap params) {
		boolean bCopyAuth = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			BoardManageSvc boardManageSvc = StaticContextAccessor.getBean(BoardManageSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			String[] messageIDs = params.getString("messageID").split(";");
			String[] versions = params.getString("version").split(";");
			String[] orgFolderIDs = params.getString("orgFolderID").split(";");
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			for(int i = 0; i < messageIDs.length; i++) {
				params.put("messageID", messageIDs[i]);
				params.put("version", versions[i]);
				params.put("orgFolderID", orgFolderIDs[i]);
				params.put("userCode", SessionHelper.getSession("USERID"));
			
				CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
				
				if ("Doc".equals(serviceType)) { // 문서
					bCopyAuth = false;
				} else if("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) {	// 관리자
					bCopyAuth = true;
				} else {
					CoviMap configMap = boardManageSvc.selectBoardConfig(params);
					
					if (!configMap.getString("UseCopy").equals("Y")) { // 복사 기능이 없는 경우
						bCopyAuth = false;
					} else {
						boolean bOwner = isOwner(params, msgMap);
						
						//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
						//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
						if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
							CoviList aclArray = null;
							
							//board_message_acl 테이블에서 데이터 조회
							if(!communityID.isEmpty()){
								aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
							} else {
								aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
							}
							
							// 복사 하려는 게시판(폴더)에 생성 권한이 있고, 게시글 작성자나 읽기 권한이 있는 경우
							if(getFolderAuth(serviceType, params.getString("folderID"), "C") && (messageACLSvc.checkAclShard("TargetType", "R", aclArray) || bOwner)) {
								bCopyAuth = true;
							} 
						} else {
							if(!communityID.isEmpty()){
								serviceType = "Community";
							}
							
							// 복사 하려는 게시판(폴더)에 생성 권한이 있고, 게시글 작성자나 원본 게시판(폴더)에 읽기 권한이 있는 경우
							if(getFolderAuth(serviceType, params.getString("folderID"), "C") && (getFolderAuth(serviceType, params.getString("orgFolderID"), "R") || bOwner)) {
								bCopyAuth = true;
							}
						}	
					}
				}
				
				if(!bCopyAuth) return false;
			}
			
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return bCopyAuth;
	}
	
	/**
	 * 게시글 스크랩 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getScrapAuth(CoviMap params) {
		boolean bScrapAuth = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			params.put("messageID", params.getString("orgMessageID"));
			
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			if (!msgMap.getString("UseScrap").equals("Y")) {
				return false;
			} else if (getReadAuth(params)) {
				bScrapAuth = true;
			}
			
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return bScrapAuth;
	}
	
	/**
	 * 게시판 관리자 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getAdminAuth(CoviMap params) throws Exception{
		boolean bAdminFlag = false;
		
		try {
			// 파라미터 세팅
			setParameter(params);
			
			if (isAuth(params, null)) {
				bAdminFlag = true;
			} else if (!params.getString("communityID").isEmpty()) {
				return CommunityAuth.getAdminAuth(params);
			}
			
			return bAdminFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 문서 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getDocRequestAuth(CoviMap params) throws Exception{
		boolean bDocReqFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			
			String messageIDArr[] = params.getString("messageID").split(";");
			String requestIDArr[] = params.getString("requestID").split(";");
			String versionArr[] = params.getString("version").split(";");
			String serviceType = params.getString("serviceType");
			
			if (!serviceType.equals("Doc")) {
				bDocReqFlag = false;
			} else {
				for(int i = 0; i < messageIDArr.length; i++) {
					params.put("messageID", messageIDArr[i]);
					params.put("requestID", requestIDArr[i]);
					params.put("version", versionArr[i]);
					
					int docAuthCnt = messageACLSvc.selectDocAuthCnt(params);
					
					if(docAuthCnt == 0) return false;
				}
				
				bDocReqFlag = true;
			}
			
			return bDocReqFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * 게시/문서 승인 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getApprovalAuth(CoviMap params) throws Exception{
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			
			String processIDArr[] = params.getString("processID").split(";");
			
			for(int i = 0; i < processIDArr.length; i++) {
				params.put("processID", processIDArr[i]);
				
				int apvCnt = messageACLSvc.selectApprovalCnt(params);
				
				if(apvCnt == 0) return false;
			}
				
			return true;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 게시/문서 실행 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getExecuteAuth(CoviMap params) throws Exception{
		boolean bExecuteFlag = false;
		
		try {
			// 파라미터 세팅
			setParameter(params);
			
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
			
			int userSecurityLevel = messageACLSvc.selectUserSecurityLevel(params);
			int msgSecurityLevel = Integer.parseInt(StringUtil.isNull(msgMap.getString("SecurityLevel")) ? "256" : msgMap.getString("SecurityLevel"));
			
			if(isAuth(params, msgMap)) { // 관리자, 작성자, 문서 소유자, 커뮤니티 작성자
				bExecuteFlag = true;
			} else if (msgSecurityLevel == 256 || (msgSecurityLevel != 256 && userSecurityLevel <= msgSecurityLevel)){
				String serviceType = params.getString("bizSection");
				String communityID = params.getString("communityID");
				
				//상세권한(메시지권한) 옵션을 사용중일 때는 BOARD_MESSAGE_ACL 테이블에서 권한 체크
				//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
				//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
				if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
					CoviList aclArray = null;
					
					if(StringUtil.isNotEmpty(communityID)){
						aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
					} else {
						aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
					}
					
					bExecuteFlag = messageACLSvc.checkAclShard("TargetType", "E", aclArray);
				} else {
					if(StringUtil.isNotEmpty(communityID)){
						serviceType = "Community";
					}
					
					bExecuteFlag = getFolderAuth(serviceType, params.getString("folderID"), "E");
				}
				
				//열람권한 사용 시
				if( "Y".equals(msgMap.getString("UseMessageReadAuth")) ) {
					int cnt = messageACLSvc.selectMessageReadAuthCount(params); 
					int allCount = messageACLSvc.selectMessageReadAuthListCnt(params);
					
					if(allCount > 0 && cnt < 1) {  //지정된 열람권한이 있으나 현 사용자에게 권한이 없을 경우 다운로드 권한을 주지 않는다.
						bExecuteFlag = false;
					}
				}
			}
			
		} catch (NullPointerException e) {
			return bExecuteFlag;
		} catch (Exception e) {
			return bExecuteFlag;
		}
		
		return bExecuteFlag;
	}
	
	/**
	 * 게시글 이동 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getMoveAuth(CoviMap params) {
		boolean bMoveFlag = false;
		
		try {
			MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
			
			// 파라미터 세팅
			setParameter(params);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			String[] messageIDs = params.getString("messageID").split(";");
			String[] versions = params.getString("version").split(";");
			String[] orgFolderIDs = params.getString("orgFolderID").split(";");
			String communityID = params.getString("communityID").replaceAll("[^0-9]", "");
			String serviceType = params.getString("serviceType");
			
			for(int i = 0; i < messageIDs.length; i++) {
				params.put("messageID", messageIDs[i]);
				params.put("version", versions[i]);
				params.put("orgFolderID", orgFolderIDs[i]);
				
				CoviMap msgMap = messageACLSvc.selectMessageInfo(params);
				
				boolean bOwner = isOwner(params, msgMap);
				
				if (serviceType.equalsIgnoreCase("Board") && msgMap.getString("UseSecurity").equals("Y") && !bOwner){ // 비밀글
					bMoveFlag = false;
				} else if (msgMap.getString("MsgState").equals("T") && !bOwner){ // 작성중인 게시
					bMoveFlag = false;
				} else if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { // 관리자 
					bMoveFlag = true;
				} else {
					//메시지 권한을 사용하고 있지만 권한이 설정되어 있지 않는 경우 폴더 권한을 체크
					//문서인 경우 항상 메세지 권한을 사용하는 것으로 판단하고 메세지 권한을 체크
					if(("Y".equals(msgMap.getString("UseMessageAuth")) && "Y".equals(msgMap.getString("MessageAuth"))) || (serviceType.equalsIgnoreCase("Doc") && "Y".equals(msgMap.getString("MessageAuth")))) {
						CoviList aclArray = null;
						
						//board_message_acl 테이블에서 데이터 조회
						if(!communityID.isEmpty()){
							aclArray = (CoviList) messageACLSvc.selectCommunityAclList(params).get("list");
						} else {
							aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
						}
						
						// 이동 하려는 게시판(폴더)에 생성 권한이 있고, 게시글에 작성자 이거나 삭제 권한이 있는 경우
						if(getFolderAuth(serviceType, params.getString("folderID"), "C") && (messageACLSvc.checkAclShard("TargetType", "D", aclArray) || bOwner)) {
							bMoveFlag = true;
						} 
					} else {
						if(!communityID.isEmpty()){
							serviceType = "Community";
						}
						
						// 이동 하려는 게시판(폴더)에 생성 권한이 있고, 게시글에 작성자 이거나 원본 게시판(폴더) 에 삭제 권한이 있는 경우
						if(getFolderAuth(serviceType, params.getString("folderID"), "C") && (getFolderAuth(serviceType, params.getString("orgFolderID"), "D") || bOwner)) {
							bMoveFlag = true;
						}
					}
				}
				
				if(!bMoveFlag) return false;
			}
			
			return bMoveFlag;
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	private static boolean isOwner(CoviMap params, CoviMap msgMap) {
		String serviceType = params.getString("serviceType");
		String userCode = params.getString("userCode");
		
		if(msgMap != null && msgMap.size() != 0) {
			if ("Board".equalsIgnoreCase(serviceType) && userCode.equals(msgMap.getString("CreatorCode"))){		//작성자
				return true;
			} else if ("Doc".equalsIgnoreCase(serviceType) && userCode.equals(msgMap.getString("OwnerCode"))){	//문서 소유자
				return true;
			} else if ("Community".equalsIgnoreCase(serviceType) && userCode.equals(msgMap.getString("CreatorCode"))) {	//커뮤니티 작성자
				return true;
			}
		}
		
		return false;
	}
	
	private static boolean isAuth(CoviMap params, CoviMap msgMap) {
		String userCode = params.getString("userCode");
		
		if ("Y".equals(SessionHelper.getSession("isAdmin")) || "Y".equals(SessionHelper.getSession("isEasyAdmin"))) { //관리자
			return true;
		} else if(isOwner(params, msgMap)) {
			return true;
		} else {
			try {
				MessageACLSvc messageACLSvc = StaticContextAccessor.getBean(MessageACLSvc.class);
				String folderOwnerCode = messageACLSvc.selectFolderOwnerCode(params);
				
				if (folderOwnerCode.indexOf(userCode + ";") != -1) { //게시판 담당자
					return true;
				}
			} catch(NullPointerException e) {
				return false;
			} catch(Exception e) {
				return false;
			}
		}
		
		return false;
	}
	
	private static boolean isProcessActor(CoviMap params, CoviMap msgMap) {
		String userCode = params.getString("userCode");
		
		if (msgMap != null && StringUtil.isNotNull(msgMap.getString("MsgState")) && msgMap.getString("MsgState").equals("R")) { // 승인요청 상태일 때만 승인자 체크
			try {
				MessageSvc messageSvc = StaticContextAccessor.getBean(MessageSvc.class);
				List<CoviMap> actorList = messageSvc.selectProcessActorList(params);
				
				for (CoviMap actor : actorList) {
					if (StringUtil.isNotNull(actor.getString("ActorCode")) && actor.getString("ActorCode").equals(userCode)) {
						return true;
					}
				}
			} catch(NullPointerException e) {
				return false;
			}  catch(Exception e) {
				return false;
			}
		}
		
		return false;
	}
	
	private static void setParameter(CoviMap params) {
		String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
		String version = params.getString("version");
		String serviceType = params.getString("bizSection");
		String communityID = params.getString("communityID");
		
		if(StringUtil.isNull(serviceType)) {
			if(StringUtil.isNotNull(params.getString("serviceType"))){
				serviceType = params.getString("serviceType");
			} else if(StringUtil.isNotNull(params.getString("CLBIZ"))){
				serviceType = params.getString("CLBIZ");
			}
		}
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("deptCode", SessionHelper.getSession("DEPTID"));
		params.put("groupPath", groupPath);
		params.put("serviceType", serviceType);
		
		if(StringUtil.isNull(version)) {
			if(StringUtil.isNotNull(params.getString("Version"))) {
				params.put("version", params.getString("Version"));
			} else if(StringUtil.isNotNull(params.getString("messageVer"))) {
				params.put("version", params.getString("messageVer"));
			}
		}
		
		if(StringUtil.isNull(communityID)) {
			if (StringUtil.isNotNull(params.getString("CU_ID"))) {
				communityID = params.getString("CU_ID");
			} else if(StringUtil.isNotNull(params.getString("C"))) {
				communityID = params.getString("C");
			} else if(StringUtil.isNotNull(params.getString("CommunityID"))) {
				communityID = params.getString("CommunityID");
			} else if(StringUtil.isNotNull(params.getString("communityId"))) {
				communityID = params.getString("communityId");
			} else if(StringUtil.isNotNull(params.getString("cid"))) {
				communityID = params.getString("cid");
			} else if(StringUtil.isNotNull(params.getString("cId"))) {
				communityID = params.getString("cId");
			}
		}
		
		params.put("communityID", communityID);
	}
}
