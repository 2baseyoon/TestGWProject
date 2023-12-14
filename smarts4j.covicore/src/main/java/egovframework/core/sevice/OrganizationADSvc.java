package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface OrganizationADSvc {
	//AD
	public CoviMap adAddCompany(String pCompanyCode, String pCompanyName, String pMemberOf) throws Exception ;
	public CoviMap adModifyCompany(String pCompanyCode, String pCompanyName, String pMemberOf) throws Exception ;
	
	public CoviMap adAddDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap adModifyDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pOldOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap adDeleteDept(String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath,String pSyncManage,String pSyncMasterID) throws Exception ;
	
	public CoviMap adAddGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap adModifyGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap adDeleteGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath,String pSyncManage,String pSyncMasterID) throws Exception ;
	
	CoviMap selectUserInfoByAdmin(CoviMap params) throws Exception;
	int insertUserADInfo(CoviMap params) throws Exception;
	int updateUserADInfo(CoviMap params) throws Exception;
	public CoviMap adAddUser(String pUserCode, String pCompanyCode, String pDeptCode, String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo, String pDisplayName, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode, String pRegionCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber, String pMobile, String pFax, String pInfo, String pTitle, String pDepartment, String pCompany, String pMailAddress, String pSecondaryMail, String pCN, String pSamAccountName, String pUserPrincipalName, String pPhotoPath, String pManagerCode, String pO365_IsUse, String pSyncManage, String pSyncMasterID) throws Exception ;
	public CoviMap adModifyUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo, String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pRegionCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber , String pMobile, String pFax, String pInfo, String pTitle, String pDepartment, String pCompany, String pMailAddress, String pSecondaryMail, String pCN, String pSamAccountName, String pUserPrincipalName, String pNewPhotoPath, String pManagerCode, String pSyncManage, String pSyncMasterID) throws Exception ; 
	public CoviMap adDeleteUser(String pUserCode, String pCompanyCode, String pDeptCode,String pJobPositionCode,String pJobTItleCode, String pJobLevelCode, String pRegionCode, String retireGRCode, String pRetireOupath, String pCN, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception ;
	public CoviMap adDisableUser(String pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode, String pRegionCode, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception ;
	public CoviMap adChangePassword(String pUserCode, String pOldPwd, String pNewPwd) throws Exception ;
	public CoviMap adInitPassword(String pUserCode, String pNewPwd, String pSyncManage, String pSyncMasterID) throws Exception ;
	public CoviMap adAddAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception;
	public CoviMap adDeleteAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception ;
	
	public CoviMap adGroupMemberGR_Control(String pMemberOf, String pGR_Code, String pMode) throws Exception ;
	public CoviMap adGroupMember_Control(String pGR_Code, String pSamAccountNames, String pMode) throws Exception ;
	
	//Exchange
	public CoviMap exchEnableGroup(String pGroupCode, String pPrimaryMail,String pSecondaryMails,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap exchDisableGroup(String pGroupCode,String pSyncManage,String pSyncMasterID) throws Exception ;
	
	int insertUserExchInfo(CoviMap params) throws Exception;
	int updateUserExchInfo(CoviMap params) throws Exception;
	public CoviMap exchEnableUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName,String pOldMailaddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap exchDisableUser(String pUserCode,String pSyncManage,String pSyncMasterID) throws Exception ;
	public CoviMap exchSelectExchangeMailBoxList() throws Exception ;
	
	//SFB 연동
	int insertUserMSNInfo(CoviMap params) throws Exception;
	int updateUserMSNInfo(CoviMap params) throws Exception;
	public CoviMap msnEnableUser(String pUserCode,String pSipAddress,String pSyncManage,String pSyncMasterID) throws Exception;
	public CoviMap msnDisableUser(String pUserCode,String pSipAddress,String pSyncManage,String pSyncMasterID) throws Exception ;
	
	// Exchange 연동 비밀번호 초기화
	public boolean exchResetPassword(String pToken) throws Exception;
}
