package egovframework.core.manage.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface OrganizationManageSvc {

	///////////////////////////////////////////////////////////////////////////////////
	CoviMap selectGroupType() throws Exception;
	CoviMap selectAllDeptList(CoviMap params) throws Exception;
	CoviMap selectDeptInfo(CoviMap params) throws Exception;
	int updateIsUseDept(CoviMap params) throws Exception;
	int updateIsHRDept(CoviMap params) throws Exception;
	int updateIsDisplayDept(CoviMap params) throws Exception;
	CoviMap selectHasChildDept(CoviMap params) throws Exception;
	CoviMap selectHasUserDept(CoviMap params) throws Exception;
	
	int insertDeptScheduleCreation(CoviMap params) throws Exception; 
	CoviMap selectDeptSchedule(CoviMap params) throws Exception;
	public int insertDeptScheduleInfo() throws Exception;
	public int updateDeptScheduleInfo(CoviMap params) throws Exception;
	CoviMap selectSubGroupList(CoviMap params) throws Exception;
	CoviMap selectDeptPathInfo(CoviMap params) throws Exception;
	public void updateDeptPathInfoAll();
	int updateDeptPathInfo(CoviMap params) throws Exception;
	///////////////////////////////////////////////////////////////////////////////////
	CoviMap getAllGroupList(CoviMap params) throws Exception;
	CoviMap selectGroupInfo(CoviMap params) throws Exception;
	int updateIsUseGroup(CoviMap params) throws Exception;
	int updateIsMailGroup(CoviMap params) throws Exception;
	int selectHasChildGroup(CoviMap params) throws Exception;
	int selectHasUserGroup(CoviMap params) throws Exception;
	int selectHasGroupMember(CoviMap params) throws Exception;
	CoviMap selectGroupEtcInfo(CoviMap params) throws Exception;

	CoviMap selectGroupListByGroupType(CoviMap params) throws Exception;
	
	

	///////////////////////////////////////////////////////////////////////////////////
	CoviMap selectAddJobList(CoviMap params) throws Exception;
	CoviMap selectAddJobInfoData(CoviMap params) throws Exception;
	CoviMap selectArbitraryGroupDropdownlist(CoviMap params) throws Exception;
	CoviMap selectAddJobInfoList(CoviMap params) throws Exception;
	public int insertAddjob(CoviMap params) throws Exception;
	public int updateAddjob(CoviMap params) throws Exception;
	public int deleteAddjob(CoviMap params) throws Exception;
	CoviMap selectUserAddJobListCnt(CoviMap params) throws Exception;
	CoviMap selectUserGroupList(CoviMap params) throws Exception;
	///////////////////////////////////////////////////////////////////////////////////
	CoviMap selectGroupInfoList(CoviMap params) throws Exception;
	public int deleteGroup(CoviMap params) throws Exception;
	CoviMap updateGroupUserListSortKey(CoviMap params) throws Exception;
	int moveDeptOrgUser(CoviMap params) throws Exception;
	void setSortPathByMemberOf(String strGroupCode) throws Exception;
	CoviMap selectGroupInfoWithSubList(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateGroupCode(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateMail(CoviMap params) throws Exception;
	int insertGroup(CoviMap params) throws Exception;
	public int updateGroup(CoviMap params) throws Exception; 

	
	
	
	

	///////////////////////////////////////////////////////////////////////////////////
	// 그룹멤버 목록(By GroupCode)
	CoviMap getGroupMemberList(CoviMap params) throws Exception;
	int deleteGroupMember(CoviMap params) throws Exception;
	int addGroupMember(CoviMap params) throws Exception;	
	
	
	// 코드 값으로 정보 가져오기(그룹, 회사) select
	CoviMap selectDefaultSetInfoGroup(CoviMap params) throws Exception;
	String getGroupPath(String CompanyCode, String MemberOf) throws Exception;
	CoviMap selectGroupPath(CoviMap params) throws Exception;
	

	CoviMap selectGroupExcelList(CoviMap params) throws Exception;

	CoviMap selectCompanyInfoGroupByDomainId(CoviMap params) throws Exception;
	///////////////////////////////////////////////////////////////////////////////////
	public void insertLogListLog(int LogMasterID, String LogType, String TargetType, String SyncType, String LogMessage, String SyncServer) throws Exception;
	
	

	///////////////////////////////////////////////////////////////////////////////////
	//사용자
	///////////////////////////////////////////////////////////////////////////////////
	CoviMap selectUserList(CoviMap params) throws Exception;
	int insertUser(CoviMap params) throws Exception;
	int updateUser(CoviMap params) throws Exception;	
	int deleteUser(CoviMap params) throws Exception;
	int convertBase64toImage(CoviMap params) throws Exception;
	int updateOrgUserPhotoPath(CoviMap params) throws Exception;
	int getImagefromUrl(String strUrl, String strUserCode, String strPhotoDate) throws Exception;
	String resetUserPassword(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateUserInfo(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateEmpno(CoviMap params) throws Exception;
	CoviMap usePWPolicyCheck(CoviMap params) throws Exception;
	int updateIsUseUser(CoviMap params) throws Exception;
	int updateIsHRUser(CoviMap params) throws Exception;
	int updateIsDisplayUser(CoviMap params) throws Exception;
	CoviMap selectLicenseInfo(CoviMap params) throws Exception;
	
	
	
	

	///////////////////////////////////////////////////////////////////////////////////
	CoviMap selectUserInfo(CoviMap params) throws Exception;
	CoviMap selectServiceTypeList() throws Exception;
	//인디메일 API
	CoviMap selectUserGroupMailInfo(CoviMap params) throws Exception;
	boolean getIndiSyncTF() throws Exception;
	CoviMap getIndiMailUserStatus(CoviMap params) throws Exception;
	CoviMap addUser(CoviMap params) throws Exception;
	CoviMap modifyUser(CoviMap params) throws Exception;
	public String indiModifyPass(CoviMap params) throws Exception;
	//boolean addGroup(CoviMap params) throws Exception;
	//boolean modifyGroup(CoviMap params) throws Exception;
	String selectGroupMail(CoviMap params) throws Exception;
	boolean setIndiMailGroup(CoviMap params) throws Exception;
	CoviMap setIndiMailUser(CoviMap params) throws Exception;
	
	// 타임스퀘어 API
	String getTSVer() throws Exception;
	boolean getTSSyncTF() throws Exception;
	boolean getUsersyncexistuser(CoviMap params) throws Exception;
	boolean getUserStatusSyncstatususer(CoviMap params) throws Exception;
	int updateUserSyncupdate(CoviMap params) throws Exception;
	int addUsersyncusermap(CoviMap params) throws Exception;
	int setUserPhoto(CoviMap params) throws Exception;
	int addUserSync(CoviMap params) throws Exception;
	int deleteUserSyncdelete(CoviMap params) throws Exception;
	int isUseUserSyncupdate(CoviMap params,String pIsUse) throws Exception;
	int addGroupSync(CoviMap params) throws Exception;
	int updateGroupSync(CoviMap params) throws Exception;
	int deleteGroupSync(CoviMap params) throws Exception;
	int isUseGroupSyncUpdate(CoviMap params,String pIsUse) throws Exception;
	CoviMap getJson(String encodedUrl, String method) throws Exception;
	String resetuserpasswordTS(CoviMap params) throws Exception;
	int setUserTypeSyncentcoder(CoviMap params) throws Exception;
	int insertUpdateAddJobSync(CoviMap params) throws Exception;
	
	
	///////////////////////////////////////////////////////////////////////////////////
	public void insertGroupLogList(CoviMap params) throws Exception;
	CoviList selectSubSystemGroupInfo(CoviMap params) throws Exception;
	CoviMap selectCrmDeptList(CoviMap params) throws Exception; //부서 (CRM 테스트용)
	CoviMap selectCrmUserList(CoviMap params) throws Exception; //사용자 (CRM 테스트용)
}