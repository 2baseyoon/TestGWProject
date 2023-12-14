package egovframework.covision.groupware.board.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface MessageACLSvc {
	CoviMap selectMessageReadAuthList(CoviMap params) throws Exception;	//열람권한
	int selectMessageReadAuthListCnt(CoviMap params) throws Exception;		//열람권한 개수
	int selectMessageReadAuthCount(CoviMap params) throws Exception;		//열람권한 확인
	
	CoviMap selectMessageAuthList(CoviMap params) throws Exception;		//상세권한
	CoviMap selectMessageAclList(CoviMap params) throws Exception;		//사용자 상세권한 확인
	CoviMap selectCommunityAclList(CoviMap params) throws Exception;		//커뮤니티 권한 확인
	
	CoviMap selectMessageInfo(CoviMap params) throws Exception;
	CoviMap selectRequestAclDetail(CoviMap params) throws Exception;
	int selectUserSecurityLevel(CoviMap params) throws Exception;
	String selectFolderOwnerCode(CoviMap params) throws Exception;
	int selectDocAuthCnt(CoviMap params) throws Exception;
	int selectApprovalCnt(CoviMap params) throws Exception;
	
	int createRequestAuth(CoviMap params) throws Exception;
	int updateRequestAuth(CoviMap params) throws Exception;
	int checkDuplicateRequest(CoviMap params) throws Exception;
	
	boolean checkAclShard(String pType, String pShard, CoviList pArray) throws Exception;	//ACL 정보 파싱하여 권한 여부 확인
}
