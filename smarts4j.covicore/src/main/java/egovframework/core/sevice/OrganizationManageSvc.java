package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface OrganizationManageSvc {

	CoviMap selectDomainList(CoviMap params) throws Exception; // 도메인/회사 조회

	CoviMap selectDeptList(CoviMap params) throws Exception;

	CoviMap selectUserList(CoviMap params) throws Exception;

	CoviMap selectSubDeptList(CoviMap params) throws Exception;

	CoviMap selectParentName(CoviMap params) throws Exception;

	CoviMap selectGroupType() throws Exception;

	int updateIsUseDept(CoviMap params) throws Exception;

	int updateIsHRDept(CoviMap params) throws Exception;

	int updateIsDisplayDept(CoviMap params) throws Exception;

	int updateIsMailDept(CoviMap params) throws Exception;

	int updateIsUseUser(CoviMap params) throws Exception;

	int updateIsHRUser(CoviMap params) throws Exception;

	int updateIsADUser(CoviMap params) throws Exception;

	CoviMap selectDeptInfo(CoviMap params) throws Exception;

	CoviMap selectUserInfo(CoviMap params) throws Exception;

	int deleteUser(CoviMap params) throws Exception;

	int deleteDept(CoviMap params) throws Exception;

	CoviMap selectHasChildDept(CoviMap params) throws Exception;

	CoviMap selectHasUserDept(CoviMap params) throws Exception;

	CoviMap selectIsDuplicateDeptCode(CoviMap params) throws Exception;

	CoviMap selectIsDuplicateUserCode(CoviMap params) throws Exception;
	
	CoviMap selectIsDuplicateDeptPriorityOrder(CoviMap params) throws Exception;
	
	CoviMap selectIsduplicatesortkey(CoviMap params) throws Exception;
	
	CoviMap usePWPolicyCheck(CoviMap params) throws Exception;
	
	CoviMap selectDefaultSetInfo(CoviMap params) throws Exception;

	// 그룹 리스트 조회
	CoviMap selectGroupList(CoviMap params) throws Exception;

	// 임의그룹 조회
	CoviMap selectArbitraryGroupInfo(CoviMap params) throws Exception;

	// 임의그룹 리스트 조회
	CoviMap selectArbitraryGroupList(CoviMap params) throws Exception;

	// 임의그룹 설정 변경
	CoviMap updateArbitraryGroup(CoviMap params) throws Exception;

	// 임의그룹 리스트 삭제
	int deleteArbitraryGroupList(CoviMap params) throws Exception;

	// 임의그룹 목록 우선순위 update
	CoviMap updateArbitraryGroupListSortKey(CoviMap params) throws Exception;

	// 임의그룹 중복 여부 조회
	CoviMap selectIsDuplicateGroupCode(CoviMap params) throws Exception;

	// 임의그룹 생성
	int createGroup(CoviMap params) throws Exception;

	// 임의 그룹 삽입 정보 select(path 등)
	CoviMap selectGroupInsertData(CoviMap params) throws Exception;

	int insertDeptInfo(CoviMap params) throws Exception;

	int updateDeptInfo(CoviMap params) throws Exception;

	CoviMap selectDeptEtcInfo(CoviMap params) throws Exception;
	
	CoviMap selectDeptPathInfo(CoviMap params) throws Exception;

	CoviMap updateDeptUserListSortKey(CoviMap params) throws Exception;

	CoviMap selectJobInfoList(CoviMap params) throws Exception;

	CoviMap selectServiceTypeList() throws Exception;

	int updateOrgUserPhotoPath(CoviMap params) throws Exception;

	int insertUserInfo(CoviMap params) throws Exception;

	int updateUserInfo(CoviMap params) throws Exception;
	
	int updateDeptPathInfo(CoviMap params) throws Exception;

	// 지역 목록 조회
	CoviMap selectRegionList(CoviMap params) throws Exception;

	// 지역 정보 조회
	CoviMap selectRegionInfo(CoviMap params) throws Exception;

	// 겸직 목록 조회
	CoviMap selectAddJobList(CoviMap params) throws Exception;

	// 겸직 목록 조회
	CoviMap selectAddJobInfoList(CoviMap params) throws Exception;

	// 임의 그룹 드롭다운 목록 조회
	CoviMap selectArbitraryGroupDropDownList(CoviMap params)
			throws Exception;

	// 겸직 추가
	int createAddJob(CoviMap params) throws Exception;

	// 겸직 정보 조회
	CoviMap selectAddJobInfo(CoviMap params) throws Exception;

	// 겸직 정보(사용자 기본 정보) select
	CoviMap selectAddJobUserInfo(CoviMap params) throws Exception;

	// 겸직 설정 수정(인사연동여부)
	CoviMap updateAddJobSetting(CoviMap params) throws Exception;

	// 겸직 목록 delete
	int deleteAddJob(CoviMap params) throws Exception;

	// 메일 주소 중복 여부 select
	CoviMap selectIsDuplicateMail(CoviMap params) throws Exception;

	// 회사 드롭다운 목록 select
	CoviMap selectAvailableCompanyList(CoviMap params) throws Exception;

	CoviMap selectDeptListForCategory(CoviMap params) throws Exception;

	// 하위 그룹 목록 select
	CoviMap selectSubGroupList(CoviMap params) throws Exception;

	// 그룹 사용자 목록 select
	CoviMap selectGroupUserList(CoviMap params) throws Exception;

	// 그룹 목록 select for select box
	CoviMap selectGroupListForCategory(CoviMap params) throws Exception;

	CoviMap selectOrgExcelList(CoviMap params) throws Exception;

	// 그룹 사용 여부 update
	int updateIsUseGroup(CoviMap params) throws Exception;

	// 그룹 메일 사용 여부 update
	int updateIsMailGroup(CoviMap params) throws Exception;

	// 사용자 메일 사용 여부 update
	int updateIsMailUser(CoviMap params) throws Exception;

	// 그룹 삭제 update
	int deleteGroup(CoviMap params) throws Exception;

	// 하위 그룹 존재 여부 select
	int selectHasChildGroup(CoviMap params) throws Exception;

	// 하위 사용자 존재 여부 select
	int selectHasUserGroup(CoviMap params) throws Exception;

	// 그룹/사용자 목록 우선순위 update
	CoviMap updateGroupUserListSortKey(CoviMap params) throws Exception;

	// 그룹 정보 가져오기 select
	CoviMap selectGroupInfo(CoviMap params) throws Exception;

	// 그룹 정보 가져오기 select
	CoviMap selectDeptInfoList(CoviMap params) throws Exception;

	// 그룹 정보 insert
	int insertGroupInfo(CoviMap params) throws Exception;

	// 그룹 정보 update
	int updateGroupInfo(CoviMap params) throws Exception;

	// 그룹 기타 정보 select
	CoviMap selectGroupEtcInfo(CoviMap params) throws Exception;

	// 코드 값으로 정보 가져오기(그룹, 회사) select
	CoviMap selectDefaultSetInfoGroup(CoviMap params) throws Exception;

	// 그룹 멤버 추가
	int addGroupMember(CoviMap params) throws Exception;

	// 그룹 멤버 목록 select
	CoviMap selectGroupMemberList(CoviMap params) throws Exception;

	// 그룹 멤버 삭제
	int deleteGroupMember(CoviMap params) throws Exception;

	CoviMap getJson(String encodedUrl, String method) throws Exception;

	CoviMap selectUserSyncData(CoviMap params) throws Exception;

	String resetuserpassword(CoviMap params) throws Exception;

	// 인디메일 API
	boolean getIndiSyncTF() throws Exception;

	CoviMap getUserStatus(CoviMap params) throws Exception;

	CoviMap addUser(CoviMap params) throws Exception;

	CoviMap modifyUser(CoviMap params) throws Exception;

	int modifyPass(CoviMap params) throws Exception;

	boolean addGroup(CoviMap params) throws Exception;

	boolean modifyGroup(CoviMap params) throws Exception;

	// 타임스퀘어 API
	String getTSVer() throws Exception;

	boolean getTSSyncTF() throws Exception;

	boolean getUsersyncexistuser(CoviMap params) throws Exception;

	boolean getUserStatusSyncstatususer(CoviMap params) throws Exception;

	int addUserSync(CoviMap params) throws Exception;
	
	int addGroupSync(CoviMap params) throws Exception;

	int addUsersyncusermap(CoviMap params) throws Exception;

	String resetuserpasswordTS(CoviMap params) throws Exception;

	int deleteUserSyncdelete(CoviMap params) throws Exception;
	
	int deleteGroupSync(CoviMap params) throws Exception;

	int updateUserSyncupdate(CoviMap params) throws Exception;
	
	int updateGroupSync(CoviMap params) throws Exception;

	int setUserPhoto(CoviMap params) throws Exception;

	int setUserTypeSyncentcoder(CoviMap params) throws Exception;

	// AD
	int insertUserADInfo(CoviMap params) throws Exception;

	int updateUserADInfo(CoviMap params) throws Exception;
	
	public CoviMap adDeleteUser(String pUserCode, String pCompanyCode, String pDeptCode,String pJobPositionCode,String pJobTItleCode, String pJobLevelCode, String retireGRCode, String pRetireOupath,String pCN, String pSamAccountName) throws Exception ;
	
	public CoviMap adDeleteDept(String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath) throws Exception ;
	
	public CoviMap adAddDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception ;

	public CoviMap adModifyDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception ;
	
	public CoviMap adAddGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception ;
	
	public CoviMap adModifyGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception ;
	
	public CoviMap adDeleteGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath) throws Exception ;
	
	public CoviMap adAddAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName) throws Exception;
	
	public CoviMap adDeleteAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName) throws Exception ;
	
	public CoviMap adModifyUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pCN, String pSamAccountName,String pUserPrincipalName) throws Exception ; 
	
	public CoviMap adAddUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pCN, String pSamAccountName,String pUserPrincipalName) throws Exception ;
	
	public CoviMap adChangePassword(String pUserCode, String pOldPwd, String pNewPwd) throws Exception ;
	
	public CoviMap adDisableUser(String pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode, String pSamAccountName) throws Exception ;
	
	public CoviMap adInitPassword(String pUserCode, String pNewPwd) throws Exception ;
	
	// Exchange
	int insertUserExchInfo(CoviMap params) throws Exception;

	int updateUserExchInfo(CoviMap params) throws Exception;

	public CoviMap exchDisableUser(String pSamAccountName) throws Exception ;
	
	public CoviMap exchEnableGroup(String pGroupCode, String pPrimaryMail,String pSecondaryMails) throws Exception ;
		
	public CoviMap exchDisableGroup(String pGroupCode) throws Exception ;
		
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName) throws Exception ;
	
	public CoviMap exchEnableUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName) throws Exception ;
	
	public CoviMap adAddCompany(String pCompanyCode, String pCompanyName) throws Exception ;
	
	public CoviMap adModifyCompany(String pCompanyCode, String pCompanyName) throws Exception ;
	
	public CoviMap exchSelectExchangeMailBoxList() throws Exception ;
	
	// MSN
	int insertUserMSNInfo(CoviMap params) throws Exception;

	int updateUserMSNInfo(CoviMap params) throws Exception;
	
	public CoviMap msnEnableUser(String pSamAccountName,String pSipAddress) throws Exception;

	public CoviMap msnDisableUser(String pSamAccountName,String pSipAddress) throws Exception ;
	
	CoviMap selectUserInfoByAdmin(CoviMap params) throws Exception;
	
	CoviMap selectUserInfoList(CoviMap params) throws Exception;
}