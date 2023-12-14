package egovframework.core.sevice;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface OrgSyncManageSvc {
	//Sync여부 설정값
	public CoviMap getIsSyncList() throws Exception;
	//인사데이터 불러오기
	public CoviMap syncTempObject() throws Exception;
	public CoviMap syncCompareObject() throws Exception;
	public void deleteCompareObjectOne(CoviMap params) throws Exception;
	int checkRetireCount() throws Exception;
	public CoviMap selectCompareObjectGroupList(CoviMap params) throws Exception;
	public CoviMap selectCompareObjectUserList(CoviMap params) throws Exception;
	public CoviMap selectMoniterCompareCount(CoviMap params) throws Exception;
	public CoviMap selectCompareObjectAddJobList(CoviMap params) throws Exception;
	//전체 동기화
	//public void sync(CoviMap params) throws Exception;
	
	// 회사
	CoviMap selectDomainList(CoviMap params) throws Exception; // 도메인/회사 조회
	CoviMap selectAvailableCompanyList(CoviMap params) throws Exception;
	
	//부서 또는 그룹
	//public void syncGroup(String sObjectType, String sSyncType) throws Exception;
	int insertDeptScheduleCreation(CoviMap params) throws Exception;
	CoviMap selectDeptSchedule(CoviMap params) throws Exception;
	public int insertDeptScheduleInfo() throws Exception;
	public int updateDeptScheduleInfo(CoviMap params) throws Exception;
	CoviMap selectDeptList(CoviMap params) throws Exception;
	CoviList getInitOrgTreeList(CoviMap params) throws Exception;
	CoviList getChildrenData(CoviMap params) throws Exception;
	CoviMap selectDeptPathInfo(CoviMap params) throws Exception;
	CoviMap selectSubDeptList(CoviMap params) throws Exception;
	CoviMap selectParentName(CoviMap params) throws Exception;
	CoviMap selectGroupType() throws Exception;
	CoviMap selectDeptInfo(CoviMap params) throws Exception;
	CoviMap selectDeptInfoList(CoviMap params) throws Exception;
	String selectGroupMail(CoviMap params) throws Exception;
	CoviMap selectDefaultSetInfo(CoviMap params) throws Exception;
	int updateIsUseDept(CoviMap params) throws Exception;
	int updateIsHRDept(CoviMap params) throws Exception;
	int updateIsDisplayDept(CoviMap params) throws Exception;
	int updateIsMailDept(CoviMap params) throws Exception;
	CoviMap selectHasChildDept(CoviMap params) throws Exception;
	CoviMap selectHasUserDept(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateDeptCode(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateDeptPriorityOrder(CoviMap params) throws Exception;
	CoviMap selectIsduplicatesortkey(CoviMap params) throws Exception;
	CoviMap selectGroupList(CoviMap params) throws Exception;
	CoviMap selectRegionInfo(CoviMap params) throws Exception;
	CoviMap selectArbitraryGroupDropDownList(CoviMap params) throws Exception;
	CoviMap selectArbitraryGroupInfo(CoviMap params) throws Exception;
	CoviMap selectArbitraryGroupList(CoviMap params) throws Exception;
	CoviMap selectDeptEtcInfo(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateGroupCode(CoviMap params) throws Exception;
	CoviMap selectGroupInsertData(CoviMap params) throws Exception;
	CoviMap selectRegionList(CoviMap params) throws Exception;
	CoviMap selectJobInfoList(CoviMap params) throws Exception;
	CoviMap selectDeptListForCategory(CoviMap params) throws Exception;
	CoviMap selectSubGroupList(CoviMap params) throws Exception;
	CoviMap selectGroupListForCategory(CoviMap params) throws Exception;
	CoviMap selectGroupInfo(CoviMap params) throws Exception;
	CoviMap selectGroupEtcInfo(CoviMap params) throws Exception;
	CoviMap selectDefaultSetInfoGroup(CoviMap params) throws Exception;
	CoviMap updateArbitraryGroup(CoviMap params) throws Exception;
	int deleteArbitraryGroupList(CoviMap params) throws Exception;
	CoviMap updateArbitraryGroupListSortKey(CoviMap params) throws Exception;
	CoviMap updateDeptUserListSortKey(CoviMap params) throws Exception;
	int updateIsUseGroup(CoviMap params) throws Exception;
	int updateIsDisplayGroup(CoviMap params) throws Exception;
	int updateIsMailGroup(CoviMap params) throws Exception;
	int insertGroup(CoviMap params) throws Exception;
	public int deleteGroup(CoviMap params) throws Exception;
	public int updateGroup(CoviMap params) throws Exception;
	public CoviMap selectAuthorityList(CoviMap params) throws Exception;
	public CoviMap selectDefaultSetAuthority(CoviMap params) throws Exception;
	public CoviMap selectAuthorityinfo(CoviMap params) throws Exception;
	
	//사용자
	//public void syncUser(String sSyncType) throws Exception;
	CoviMap selectUserSyncData(CoviMap params) throws Exception;
	String resetuserpassword(CoviMap params) throws Exception;
	CoviMap selectUserInfoByAdmin(CoviMap params) throws Exception;
	CoviMap selectUserInfoList(CoviMap params) throws Exception;
	CoviMap selectUserList(CoviMap params) throws Exception;
	CoviMap selectUserInfo(CoviMap params) throws Exception;
	CoviMap selectUserInfoOrg(CoviMap params) throws Exception;
	int updateIsUseUser(CoviMap params) throws Exception;
	int updateIsHRUser(CoviMap params) throws Exception;
	int updateIsADUser(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateUserCode(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateEmpno(CoviMap params) throws Exception;
	CoviMap selectGroupUserList(CoviMap params) throws Exception;
	CoviMap selectGroupMemberList(CoviMap params) throws Exception;
	int updateIsMailUser(CoviMap params) throws Exception;
	int insertUser(CoviMap params) throws Exception;
	int updateUser(CoviMap params) throws Exception;	
	int updateOrgUserPhotoPath(CoviMap params) throws Exception;
	int convertBase64toImage(CoviMap params) throws Exception;
	int getImagefromUrl(String strUrl, String strUserCode, String strPhotoDate) throws Exception;
	int deleteUser(CoviMap params) throws Exception;
	
	//겸직
	//public void syncAddjob(String sSyncType) throws Exception;
	CoviMap selectAddJobList(CoviMap params) throws Exception;
	CoviMap selectUserAddJobListCnt(CoviMap params) throws Exception;
	CoviMap selectAddJobInfo(CoviMap params) throws Exception;
	CoviMap selectAddJobInfoList(CoviMap params) throws Exception;
	CoviMap selectAddJobUserInfo(CoviMap params) throws Exception;
	public int insertAddjob(CoviMap params) throws Exception;
	public int updateAddjob(CoviMap params) throws Exception;
	public int updateAddjobManage(CoviMap params) throws Exception;
	public int deleteAddjobSync(CoviMap params) throws Exception;
	public int deleteAddjob(CoviMap params) throws Exception;
	// 겸직 설정 수정(인사연동여부)
	CoviMap updateAddJobSetting(CoviMap params) throws Exception;
	int deleteGroupMember(CoviMap params) throws Exception;
	int addGroupMember(CoviMap params) throws Exception;	
	
	//인디메일 API
	boolean getIndiSyncTF() throws Exception;
	CoviMap getUserStatus(CoviMap params) throws Exception;
	CoviMap addUser(CoviMap params) throws Exception;
	CoviMap modifyUser(CoviMap params) throws Exception;
	int modifyPass(CoviMap params) throws Exception;
	public String indiModifyPass(CoviMap params) throws Exception;
	boolean addGroup(CoviMap params) throws Exception;
	boolean modifyGroup(CoviMap params) throws Exception;
	
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
	
	//유틸리티
	public String getGroupPath(String CompanyCode, String MemberOf);
	public CoviMap selectGroupPath(CoviMap params) throws Exception;
	CoviMap selectIsDuplicateMail(CoviMap params) throws Exception;
	CoviMap selectServiceTypeList() throws Exception;
	CoviMap selectOrgExcelList(CoviMap params) throws Exception;
	int selectHasChildGroup(CoviMap params) throws Exception;
	int selectHasUserGroup(CoviMap params) throws Exception;
	public void updateDeptPathInfoAll();
	int updateDeptPathInfo(CoviMap params) throws Exception;
	CoviMap usePWPolicyCheck(CoviMap params) throws Exception;
	public void insertGroupLogList(CoviMap params) throws Exception;
	public boolean isSyncProgress() throws Exception;
	public int updateSyncProgress(String status) throws Exception;
	
	// 동기화 모니터링 관련 
	public CoviMap selectSyncHitory(CoviMap params) throws Exception;
	public CoviMap selectSyncItemLog(CoviMap params) throws Exception;
	
	//로그 관리
	public int insertLogList() throws Exception;
	public void updateLogList() throws Exception;
	CoviMap selectGroupLogList(CoviMap params) throws Exception;
	CoviMap selectUserLogList(CoviMap params) throws Exception;
	CoviMap selectAddJobLogList(CoviMap params) throws Exception;
	CoviMap selectLogList(CoviMap params) throws Exception;
	CoviMap updateGroupUserListSortKey(CoviMap params) throws Exception;
	public void insertLogListLog(int LogMasterID, String LogType, String TargetType, String SyncType, String LogMessage, String SyncServer) throws Exception;
	public int selectSyncMasterID() throws Exception;
	/**
	 * @param type 
	 * @description 동기화 대상 조회
	 * @return CoviList
	 * @throws Exception
	 */
	CoviList selectCompareList(String type) throws Exception;
	
	void deleteCompareObject(CoviMap params) throws Exception;
}