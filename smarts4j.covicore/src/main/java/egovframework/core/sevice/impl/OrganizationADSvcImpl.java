package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.sevice.OrganizationADSvc;
import egovframework.coviframework.util.HttpClientUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("organizationADService")
public class OrganizationADSvcImpl extends EgovAbstractServiceImpl implements OrganizationADSvc {
	
	private Logger LOGGER = LogManager.getLogger(OrganizationSyncManageSvcImpl.class);
	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;


	//AD Company
	/**
	 * AD 회사 추가
	 * @param String pCompanyCode, String pCompanyName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddCompany(String pCompanyCode, String pCompanyName, String pMemberOf) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddCompany", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adAddCompany ERROR [CompanyCode : " + pCompanyCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			LOGGER.error("[AD] adAddCompany ERROR [CompanyCode : " + pCompanyCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		finally{
			LOGGER.info("[AD] adAddCompany [CompanyCode : " + pCompanyCode + "] " + resultList.get("result").toString());
		}
		return resultList;
	}
	
	/**
	 * AD 회사 수정
	 * @param String pCompanyCode, String pCompanyName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyCompany(String pCompanyCode, String pCompanyName, String pMemberOf) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyCompany", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adModifyCompany ERROR [CompanyCode : " + pCompanyCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			LOGGER.error("[AD] adModifyCompany ERROR [CompanyCode : " + pCompanyCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		finally{
			LOGGER.info("[AD] adModifyCompany [CompanyCode : " + pCompanyCode + "] " + resultList.get("result").toString());
		}
		return resultList;
	}
	
	//AD Dept
	/**
	 * AD 부서 추가
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddDept", pParam);
		}catch (NullPointerException e){
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adAddDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adAddDept ERROR [GroupCode : " + pDeptCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adAddDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adAddDept [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Dept","AD","adAddDept End [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 부서 수정
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pOldOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pOldOUPath",pOldOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyDept", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adModifyDept ERROR [GroupCode : " + pDeptCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adModifyDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adModifyDept ERROR [GroupCode : " + pDeptCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adModifyDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adModifyDept [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Dept","AD","adModifyDept End [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 부서 삭제
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteDept(String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteDept", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adDeleteDept ERROR [GroupCode : " + pDeptCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adDeleteDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adDeleteDept ERROR [GroupCode : " + pDeptCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Dept","AD","adDeleteDept Error [GroupCode : " + pDeptCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adDeleteDept [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Dept","AD","adDeleteDept End [GroupCode : " + pDeptCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	//AD Group
	/**
	 * AD 그룹 추가
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGroupType",pGroupType),
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pGroupName",pGroupName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddGroup", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adAddGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","GroupCode Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adAddGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","GroupCode Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adAddGroup [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Group","AD","GroupCode End [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 그룹 수정
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGroupType",pGroupType),
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pGroupName",pGroupName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyGroup", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adModifyGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","adModifyGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adModifyGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","adModifyGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adModifyGroup [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Group","AD","adModifyGroup End [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 그룹 삭제
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGroupType",pGroupType),
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pGroupName",pGroupName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pOUPath",pOUPath)
	        };	
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteGroup", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adDeleteGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","adDeleteGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adDeleteGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","Group","AD","adDeleteGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adDeleteGroup [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","Group","AD","adDeleteGroup End [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	//AD User
	/**
	 * 사용자 정보 가져오기 select (패스워드 포함)
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserInfoByAdmin(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectUserInfoByAdmin", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserID,UserCode,LogonID,EmpNo,MultiDisplayName,NickName,MultiAddress,HomePage,PhoneNumber,Mobile,FAX,IPPhone,UseMessengerConnect,SortKey,SecurityLevel,Description,IsUse,IsHR,IsDisplay,EnterDate,RetireDate,PhotoPath,BirthDiv,BirthDate,UseMailConnect,MailAddress,ExternalMailAddress,PhoneNumberInter,Reserved2,Reserved3,Reserved4,Reserved5,CompanyCode,MultiCompanyName,DeptCode,MultiDeptName,RegionCode,MultiRegionName,JobPositionCode,JobTitleCode,JobLevelCode,JobPositionName,JobTitleName,JobLevelName,UseDeputy,DeputyCode,DeputyName,DeputyFromDate,DeputyToDate,AlertConfig,ApprovalUnitCode,ApprovalUnitName,ReceiptUnitCode,ReceiptUnitName,UseApprovalMessageBoxView,UseMobile,AD_DISPLAYNAME,AD_FIRSTNAME,AD_LASTNAME,AD_INITIALS,AD_OFFICE,AD_HOMEPAGE,AD_COUNTRY,AD_COUNTRYID,AD_COUNTRYCODE,AD_STATE,AD_CITY,AD_STREETADDRESS,AD_POSTOFFICEBOX,AD_POSTALCODE,AD_USERACCOUNTCONTROL,AD_ACCOUNTEXPIRES,AD_PHONENUMBER,AD_HOMEPHONE,AD_PAGER,AD_MOBILE,AD_FAX,AD_IPPHONE,AD_INFO,AD_TITLE,AD_DEPARTMENT,AD_COMPANY,AD_MANAGERCODE,EX_PRIMARYMAIL,EX_SECONDARYMAIL,EX_STORAGESERVER,EX_STORAGEGROUP,EX_STORAGESTORE,EX_CUSTOMATTRIBUTE01,EX_CUSTOMATTRIBUTE02,EX_CUSTOMATTRIBUTE03,EX_CUSTOMATTRIBUTE04,EX_CUSTOMATTRIBUTE05,EX_CUSTOMATTRIBUTE06,EX_CUSTOMATTRIBUTE07,EX_CUSTOMATTRIBUTE08,EX_CUSTOMATTRIBUTE09,EX_CUSTOMATTRIBUTE10,EX_CUSTOMATTRIBUTE11,EX_CUSTOMATTRIBUTE12,EX_CUSTOMATTRIBUTE13,EX_CUSTOMATTRIBUTE14,EX_CUSTOMATTRIBUTE15,MSN_POOLSERVERNAME,MSN_POOLSERVERDN,MSN_SIPADDRESS,MSN_ANONMY,MSN_MEETINGPOLICYNAME,MSN_MEETINGPOLICYDN,MSN_PHONECOMMUNICATION,MSN_PBX,MSN_LINEPOLICYNAME,MSN_LINEPOLICYDN,MSN_LINEURI,MSN_LINESERVERURI,MSN_FEDERATION,MSN_REMOTEACCESS,MSN_PUBLICIMCONNECTIVITY,MSN_INTERNALIMCONVERSATION,MSN_FEDERATEDIMCONVERSATION,AD_ISUSE,EX_ISUSE,MSN_ISUSE,LOGONPASSWORD,AD_USERID,EX_USERID,MSN_USERID,AD_CN,AD_SamAccountName,AD_UserPrincipalName"));
		return resultList;
	}
	
	/**
	 * 사용자 AD 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserADInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.insertUserADInfo", params);
	}
	
	/**
	 * 사용자 AD 정보 수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserADInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.updateUserADInfo", params);
	}
	
	/**
	 * AD 사용자 추가
	 * @param String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pUserPrincipalName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddUser(String pUserCode, String pCompanyCode, String pDeptCode, String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo, String pDisplayName, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode, String pRegionCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber, String pMobile, String pFax, String pInfo, String pTitle, String pDepartment, String pCompany, String pMailAddress, String pSecondaryMail, String pCN, String pSamAccountName, String pUserPrincipalName, String pPhotoPath, String pManagerCode, String pO365_IsUse, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pLogonID",pLogonID),
				new NameValuePair("pEncLogonPW",pEncLogonPW), //암호화 필요
				new NameValuePair("pEmpNo",pEmpNo),
				new NameValuePair("pDisplayName",pDisplayName),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pRegionCode",pRegionCode),
				new NameValuePair("pFirstName",pFirstName),
				new NameValuePair("pLastName",pLastName),
				new NameValuePair("pUserAccountControl",pUserAccountControl),
				new NameValuePair("pAccountExpires",pAccountExpires),
				new NameValuePair("pPhoneNumber",pPhoneNumber),
				new NameValuePair("pMobile",pMobile),
				new NameValuePair("pFax",pFax),
				new NameValuePair("pInfo",pInfo),
				new NameValuePair("pTitle",pTitle),
				new NameValuePair("pDepartment",pDepartment),
				new NameValuePair("pCompany",pCompany),
				new NameValuePair("pMailAddress",pMailAddress),
				new NameValuePair("pSecondaryMail",pSecondaryMail),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pUserPrincipalName",pUserPrincipalName),
				new NameValuePair("pPhotoPath",pPhotoPath),
				new NameValuePair("pManagerCode",pManagerCode),
				new NameValuePair("pO365_IsUse",pO365_IsUse)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddUser", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adAddUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adAddUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adAddUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adAddUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adAddUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","AD","adAddUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 사용자 수정
	 * @param String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pUserPrincipalName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo, String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pRegionCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber , String pMobile, String pFax, String pInfo, String pTitle, String pDepartment, String pCompany, String pMailAddress, String pSecondaryMail, String pCN, String pSamAccountName, String pUserPrincipalName, String pNewPhotoPath, String pManagerCode, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pOldDeptCode",pOldDeptCode),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pLogonID",pLogonID),
				new NameValuePair("pEncLogonPW",pEncLogonPW), //암호화 필요
				new NameValuePair("pEmpNo",pEmpNo),
				new NameValuePair("pDisplayName",pDisplayName),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pRegionCode",pRegionCode),
				new NameValuePair("pFirstName",pFirstName),
				new NameValuePair("pLastName",pLastName),
				new NameValuePair("pUserAccountControl",pUserAccountControl),
				new NameValuePair("pAccountExpires",pAccountExpires),
				new NameValuePair("pPhoneNumber",pPhoneNumber),
				new NameValuePair("pMobile",pMobile),
				new NameValuePair("pFax",pFax),
				new NameValuePair("pInfo",pInfo),
				new NameValuePair("pTitle",pTitle),
				new NameValuePair("pDepartment",pDepartment),
				new NameValuePair("pCompany",pCompany),
				new NameValuePair("pMailAddress",pMailAddress),
				new NameValuePair("pSecondaryMail",pSecondaryMail),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pUserPrincipalName",pUserPrincipalName),
				new NameValuePair("pNewPhotoPath",pNewPhotoPath),
				new NameValuePair("pManagerCode",pManagerCode),
				new NameValuePair("sNewPhotoPath",pNewPhotoPath),
				new NameValuePair("pManagerCode",pManagerCode),
				new NameValuePair("pO365_IsUse","N")
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyUser", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adModifyUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","AD","adModifyUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 사용자 삭제
	 * @param String pUserCode, String pCompanyCode, String pDeptCode,String pJobPositionCode,String pJobTItleCode, String pJobLevelCode, String retireGRCode, String pRetireOupath
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteUser(String pUserCode, String pCompanyCode, String pDeptCode,String pJobPositionCode,String pJobTItleCode, String pJobLevelCode, String pRegionCode, String retireGRCode, String pRetireOupath, String pCN, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pRegionCode",pRegionCode),
				new NameValuePair("retireGRCode",retireGRCode),
				new NameValuePair("pRetireOupath",pRetireOupath),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteUser", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adDeleteUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adDeleteUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adDeleteUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adDeleteUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adDeleteUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","AD","adDeleteUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 사용자 비활성화
	 * @param String pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDisableUser(String pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode, String pRegionCode, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pRegionCode",pRegionCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DisableUser", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adDisableUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adDisableUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adDisableUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adDisableUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adDisableUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","AD","adDisableUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * AD 사용자 패스워드 변경
	 * @param String pUserCode, String pOldPwd, String pNewPwd
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adChangePassword(String pSamAccountName, String pOldPwd, String pNewPwd) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pOldPwd",pOldPwd),
				new NameValuePair("pNewPwd",pNewPwd)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ChangePassword", pParam);
		}catch (NullPointerException e){
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		finally{
		}
		return resultList;
	}
	
	/**
	 * AD 비밀번호 초기화
	 * @param String pUserCode, String pNewPwd
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adInitPassword(String pSamAccountName, String pNewPwd, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","InitPassword", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adInitPassword ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adInitPassword Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adInitPassword ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","AD","adInitPassword Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adInitPassword [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","AD","adInitPassword End [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	//AD AddJob
	/**
	 * AD 겸직 추가
	 * @param String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddAddJob", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adAddAddJob ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","AddJob","AD","adAddAddJob Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adAddAddJob ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","AddJob","AD","adAddAddJob Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adAddAddJob [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","AddJob","AD","adAddAddJob End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
		
	/**
	 * AD 겸직 삭제
	 * @param String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteAddJob", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adDeleteAddJob ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","AddJob","AD","adDeleteAddJob Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[AD] adDeleteAddJob ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","AddJob","AD","adDeleteAddJob Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[AD] adDeleteAddJob [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","AddJob","AD","adDeleteAddJob End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * 구성원 추가/삭제(그룹-그룹)  Mode(I:추가 / D:삭제)
	 * @param String pMemberOf, String pGRCodes, String pMode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adGroupMemberGR_Control(String pMemberOf, String pGRCodes, String pMode) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pGRCodes",pGRCodes),
				new NameValuePair("pMode",pMode)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","GroupMemberGR_Control", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adGroupMemberGR_Control ERROR [MemberOf/GRCode : " + pMemberOf + "/" + pGRCodes + "] [Mode : " + pMode + "]");
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			LOGGER.error("[AD] adGroupMemberGR_Control ERROR [MemberOf/GRCode : " + pMemberOf + "/" + pGRCodes + "] [Mode : " + pMode + "]");
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		finally{
			LOGGER.info("[AD] adGroupMemberGR_Control [MemberOf/GRCode : " + pMemberOf + "/" + pGRCodes + "] [Mode : " + pMode + "]" + resultList.get("result").toString());
		}
		return resultList;
	}
	
	/**
	 * 구성원 추가/삭제(그룹-사용자)  Mode(I:추가 / D:삭제)
	 * @param String pGR_Code, String pSamAccountNames, String pMode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adGroupMember_Control(String pGR_Code, String pSamAccountNames, String pMode) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGR_Code",pGR_Code),
				new NameValuePair("pSamAccountNames",pSamAccountNames),
				new NameValuePair("pMode",pMode)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("AD","GroupMember_Control", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[AD] adGroupMember_Control ERROR [GRCode/URCode : " + pGR_Code + "/" + pSamAccountNames + "] [Mode : " + pMode + "]");
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			LOGGER.error("[AD] adGroupMember_Control ERROR [GRCode/URCode : " + pGR_Code + "/" + pSamAccountNames + "] [Mode : " + pMode + "]");
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		finally{
			LOGGER.info("[AD] adGroupMember_Control [GRCode/URCode : " + pGR_Code + "/" + pSamAccountNames + "] [Mode : " + pMode + "]" + resultList.get("result").toString());
		}
		return resultList;
	}
	
	
	
	//Exch Group
	/**
	 * Exchange 그룹 활성화
	 * @param String pGroupCode, String pPrimaryMail,String pSecondaryMails
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchEnableGroup(String pGroupCode, String pPrimaryMail,String pSecondaryMails,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pPrimaryMail",pPrimaryMail),
				new NameValuePair("pSecondaryMails",pSecondaryMails)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","EnableGroup", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[Exch] exchEnableGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","GR","Exch","exchEnableGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchEnableGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","GR","Exch","exchEnableGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchEnableGroup [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","GR","Exch","exchEnableGroup End [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * Exchange 그룹 비활성화
	 * @param String pGroupCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchDisableGroup(String pGroupCode, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pGroupCode",pGroupCode)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","DisableGroup", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[Exch] exchDisableGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","GR","Exch","exchDisableGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchDisableGroup ERROR [GroupCode : " + pGroupCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","GR","Exch","exchDisableGroup Error [GroupCode : " + pGroupCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchDisableGroup [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","GR","Exch","exchDisableGroup End [GroupCode : " + pGroupCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	//Exch User
	/**
	 * 사용자 Exchange 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserExchInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.insertUserExchInfo", params);
	}
	
	/**
	 * 사용자 Exchange 정보 수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserExchInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.updateUserExchInfo", params);
	}
	
	/**
	 * Exchange 사용자 활성화
	 * @param String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchEnableUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail, String pSecondaryMails, String pSipAddress, String pCN, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pStorageServer",pStorageServer),
				new NameValuePair("pStorageGroup",pStorageGroup),
				new NameValuePair("pStorageStore",pStorageStore),
				new NameValuePair("pPrimaryMail",pPrimaryMail),
				new NameValuePair("pSecondaryMails",pSecondaryMails),
				new NameValuePair("pSipAddress",pSipAddress),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","EnableUser", pParam);
		}catch (NullPointerException e){
			LOGGER.error("[Exch] exchEnableUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchEnableUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchEnableUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchEnableUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchEnableUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","Exch","exchEnableUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * Exchange 사용자 수정
	 * @param String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer, String pStorageGroup, String pStorageStore, String pPrimaryMail, String pSecondaryMails, String pSipAddress, String pCN, String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pStorageServer",pStorageServer),
				new NameValuePair("pStorageGroup",pStorageGroup),
				new NameValuePair("pStorageStore",pStorageStore),
				new NameValuePair("pPrimaryMail",pPrimaryMail),
				new NameValuePair("pSecondaryMails",pSecondaryMails),
				new NameValuePair("pSipAddress",pSipAddress),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","ModifyUser", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[Exch] exchModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchModifyUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","Exch","exchModifyUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}

	@Override
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer, String pStorageGroup, String pStorageStore, String pPrimaryMail, String pSecondaryMails, String pSipAddress, String pCN, String pSamAccountName,String pOldMailaddress, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pStorageServer",pStorageServer),
				new NameValuePair("pStorageGroup",pStorageGroup),
				new NameValuePair("pStorageStore",pStorageStore),
				new NameValuePair("pPrimaryMail",pPrimaryMail),
				new NameValuePair("pSecondaryMails",pSecondaryMails),
				new NameValuePair("pSipAddress",pSipAddress),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pOldSecondarymails",pOldMailaddress)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","ModifyUser", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[Exch] exchModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchModifyUser ERROR [UserCode : " + pUserCode + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchModifyUser Error [UserCode : " + pUserCode + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchModifyUser [UserCode : " + pUserCode + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","Exch","exchModifyUser End [UserCode : " + pUserCode + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * Exchange 사용자 비활성화
	 * @param String pUserCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchDisableUser(String pSamAccountName, String pSyncManage, String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","DisableUser", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[Exch] exchDisableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchDisableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[Exch] exchDisableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","Exch","exchDisableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[Exch] exchDisableUser [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","Exch","exchDisableUser End [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * Exchange Exchange MailBox List
	 * @param 
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchSelectExchangeMailBoxList() throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {};
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","SelectExchangeMailBoxList", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[Exch] exchSelectExchangeMailBoxList ERROR " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}catch(Exception e){
			LOGGER.error("[Exch] exchSelectExchangeMailBoxList ERROR " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
		}
		
		return resultList;
	}

	
	//SFB
	/**
	 * 사용자 MSN 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserMSNInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.insertUserMSNInfo", params);
	}
	
	/**
	 * 사용자 MSN 정보 추가/수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserMSNInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.syncmanage.updateUserMSNInfo", params);
	}
	
	/**
	 * SFB 사용자 활성화
	 * @param String pUserCode, String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap msnEnableUser(String pSamAccountName,String pSipAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pSipAddress",pSipAddress)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("SFB","EnableUser", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[SFB] msnEnableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","SFB","msnEnableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[SFB] msnEnableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","SFB","msnEnableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[SFB] msnEnableUser [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","SFB","msnEnableUser End [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * SFB 사용자 비활성화
	 * @param String pUserCode, String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap msnDisableUser(String pSamAccountName,String pSipAddress,String pSyncManage,String pSyncMasterID) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pSipAddress",pSipAddress)
	        };
		try{
			resultList = httpClient.httpClientOrgConnect("SFB","DisableUser", pParam);
		}catch(NullPointerException e){
			LOGGER.error("[SFB] msnDisableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","SFB","msnDisableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}catch(Exception e){
			LOGGER.error("[SFB] msnDisableUser ERROR [UserCode : " + pSamAccountName + "] " + e.toString());
			resultList = new CoviMap();
			resultList.put("result", "false");
			resultList.put("Reason", e.toString());
			
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Error","UR","SFB","msnDisableUser Error [UserCode : " + pSamAccountName + "] " + "[Message : " +  e.toString() + "]","");
			}
		}
		finally{
			LOGGER.info("[SFB] msnDisableUser [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString());
			if(pSyncManage.equalsIgnoreCase("Sync")) {
				orgSyncManageSvc.insertLogListLog(Integer.parseInt(pSyncMasterID),"Info","UR","SFB","msnDisableUser End [UserCode : " + pSamAccountName + "] " + resultList.get("result").toString(),"");
			}
		}
		return resultList;
	}
	
	/**
	 * Exchange 연동 패스워드 초기화
	 * @param pToken // 패스워드 초기화용 JWT 토큰
	 * @return true/false
	 * */
	@Override
	public boolean exchResetPassword(String pToken) throws Exception {
		boolean body;
		CoviMap resultList = new CoviMap();
		String reMsg = "";
		
		String mailSvcUrl = RedisDataUtil.getBaseConfig("mailSvcUrl","0");
		
		String url = mailSvcUrl + "/WebSite/base/controls/externalwebservice.asmx";
		String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
		bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
		bodydata += "<soap:Body>";
		bodydata += "<SetADPassword xmlns='http://tempuri.org/'>";
		bodydata += "<pToken>"+pToken+"</pToken>";
		bodydata += "</SetADPassword>";
		bodydata += "</soap:Body>";
		bodydata += "</soap:Envelope>";
		
		HttpClientUtil httpClient = new HttpClientUtil();
		
		resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
		
		int status = (int) resultList.get("status");
		
		reMsg = resultList.get("body").toString().toLowerCase();
		
		if (status == 200 && (reMsg.indexOf("true") > -1 || reMsg.indexOf("success") > -1)) {
			body = true;
		}else{
			body = false;
		}
		
		return body;		
	}

}
