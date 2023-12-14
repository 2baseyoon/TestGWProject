package egovframework.covision.groupware.bizcard.user.service;

import egovframework.baseframework.data.CoviMap;


public interface BizCardGroupManageService {
	//그룹 등록
	
	public int insertGroupMail(CoviMap params) throws Exception;
	
	public int deleteGroupMail(CoviMap params) throws Exception;
	
	public int insertBizcard_GroupPerson(CoviMap params) throws Exception;
	
	public int insertBizcard_Person(CoviMap params) throws Exception;	
	
	public int insertGroupId(CoviMap params) throws Exception;
	
	public int updateGroupId(CoviMap params) throws Exception;
	
	public int deleteGroupId(CoviMap params) throws Exception;
	
	public int deleteBizCard_GroupPerson(CoviMap params) throws Exception;

	public int updateBizCard_Person(CoviMap params) throws Exception;
	
	public int deleteBizCard_Person(CoviMap params) throws Exception;
	
	public CoviMap insertGroup(CoviMap params) throws Exception;
	//그룹 수정
	public CoviMap updateGroup(CoviMap params) throws Exception;
	//그룹 조회
	public CoviMap selectGroupList(CoviMap params) throws Exception;
	//그룹 연락처 조회
	public CoviMap selectGroupPersonList(CoviMap params) throws Exception;
	//그룹 조회(groupID)
	public CoviMap selectGroup(CoviMap params) throws Exception;
	//그룹 조회
	public CoviMap selectBizcardGroup(CoviMap params) throws Exception;
	
}