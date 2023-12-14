package egovframework.core.sevice.impl;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;
import javax.imageio.ImageIO;

import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;



import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.OrganizationManageSvc;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MultipartUtility;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("organizationManageService")
public class OrganizationManageSvcImpl extends EgovAbstractServiceImpl implements OrganizationManageSvc {

	private Logger LOGGER = LogManager.getLogger(OrganizationManageSvcImpl.class);

	// Thread-safe patch
	//	private HttpURLConnection conn = null;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	AwsS3 awsS3 = AwsS3.getInstance();

	@Autowired
	FileUtilService fileUtilSvc;

	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	
	/**
	 * @param params DomainID
	 * @description 도메인/회사 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDomainList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("organization.admin.selectDomainList", params);
		CoviList companyList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",companyList);
		
		return resultList;
	}
	
	/**
	 * 부서 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptList(CoviMap params) throws Exception {
		params.put("isSaaS", (isSaaS) ? "Y" : "N");
		CoviList list = coviMapperOne.list("organization.admin.selectDeptList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,CompanyCode,GroupCode,GroupType,GroupDisplayName,GroupName,CompanyName,PrimaryMail,MemberOf,SortKey,SortPath,GroupID,hasChild,GroupFullPath"));
		return resultList;
	}
	
	/**
	 * 하위 부서 Path 정보 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptPathInfo(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectDeptPathInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,GroupPath,OUPath,SortPath"));
		return resultList;
	}

	/**
	 * 사용자 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectUserList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectUserListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,UserID,UserCode,MultiDisplayName,JobTitle,JobPosition,JobLevel,Mobile,MailAddress,PhoneNumber,EmpNo,DeptCode,MultiDeptName,CompanyCode,MultiCompanyName,JobType,PhoneNumberInter,IsUse,IsDisplay,IsHR,SortKey"));
			resultList.put("cnt", cnt);
			
		} catch (SQLException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return resultList;
	}
	
	/**
	 * 하위 부서 목록 selectOrgGroup_Add
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSubDeptList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectSubDeptList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectSubDeptListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,DisplayName,MultiDisplayName,ShortName,MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,DomainName,MultiDomainName,HasChild,Depth"));
			resultList.put("cnt", cnt);
			
		} catch (SQLException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return resultList;
	}

	/**
	 * 상위 분류 가져오기 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectParentName(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectParentName", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DisplayName,GroupPath"));
		return resultList;
	}
	
	/**
	 * 그룹 유형 가져오기 select
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectGroupType() throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectGroupType", null);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupType,SortKey,Priority,DisplayName,MultiDisplayName"));
		return resultList;
	}
	
	/**
	 * 부서 정보 가져오기 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectDeptInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectDeptInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,ShortName,ParentName,GroupPath,MultiDisplayName,MultiShortName,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitcode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode,OUPath,OUName"));
		return resultList;
	}
	
	/**
	 * 그룹 정보 가져오기 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectDeptInfoList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectDeptInfoList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,ShortName,ParentName,GroupPath,MultiDisplayName,MultiShortName,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitcode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode,OUPath,OUName"));
		return resultList;
	}
	
	/**
	 * 사용자 정보 가져오기 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectUserInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectUserInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserID,UserCode,LogonID,EmpNo,MultiDisplayName,NickName,MultiAddress,HomePage,PhoneNumber,Mobile,FAX,IPPhone,UseMessengerConnect,SortKey,SecurityLevel,Description,IsUse,IsHR,IsDisplay,EnterDate,RetireDate,PhotoPath,BirthDiv,BirthDate,UseMailConnect,MailAddress,ExternalMailAddress,PhoneNumberInter,Reserved2,Reserved3,Reserved4,ManagerName,Reserved5,CompanyCode,MultiCompanyName,DeptCode,MultiDeptName,RegionCode,MultiRegionName,JobPositionCode,JobTitleCode,JobLevelCode,JobPositionName,JobTitleName,JobLevelName,UseDeputy,DeputyCode,DeputyName,DeputyFromDate,DeputyToDate,AlertConfig,ApprovalUnitCode,ApprovalUnitName,ReceiptUnitCode,ReceiptUnitName,UseApprovalMessageBoxView,UseMobile,AD_DISPLAYNAME,AD_FIRSTNAME,AD_LASTNAME,AD_INITIALS,AD_OFFICE,AD_HOMEPAGE,AD_COUNTRY,AD_COUNTRYID,AD_COUNTRYCODE,AD_STATE,AD_CITY,AD_STREETADDRESS,AD_POSTOFFICEBOX,AD_POSTALCODE,AD_USERACCOUNTCONTROL,AD_ACCOUNTEXPIRES,AD_PHONENUMBER,AD_HOMEPHONE,AD_PAGER,AD_MOBILE,AD_FAX,AD_IPPHONE,AD_INFO,AD_TITLE,AD_DEPARTMENT,AD_COMPANY,AD_MANAGERCODE,EX_PRIMARYMAIL,EX_SECONDARYMAIL,EX_STORAGESERVER,EX_STORAGEGROUP,EX_STORAGESTORE,EX_CUSTOMATTRIBUTE01,EX_CUSTOMATTRIBUTE02,EX_CUSTOMATTRIBUTE03,EX_CUSTOMATTRIBUTE04,EX_CUSTOMATTRIBUTE05,EX_CUSTOMATTRIBUTE06,EX_CUSTOMATTRIBUTE07,EX_CUSTOMATTRIBUTE08,EX_CUSTOMATTRIBUTE09,EX_CUSTOMATTRIBUTE10,EX_CUSTOMATTRIBUTE11,EX_CUSTOMATTRIBUTE12,EX_CUSTOMATTRIBUTE13,EX_CUSTOMATTRIBUTE14,EX_CUSTOMATTRIBUTE15,MSN_POOLSERVERNAME,MSN_POOLSERVERDN,MSN_SIPADDRESS,MSN_ANONMY,MSN_MEETINGPOLICYNAME,MSN_MEETINGPOLICYDN,MSN_PHONECOMMUNICATION,MSN_PBX,MSN_LINEPOLICYNAME,MSN_LINEPOLICYDN,MSN_LINEURI,MSN_LINESERVERURI,MSN_FEDERATION,MSN_REMOTEACCESS,MSN_PUBLICIMCONNECTIVITY,MSN_INTERNALIMCONVERSATION,MSN_FEDERATEDIMCONVERSATION,AD_ISUSE,EX_ISUSE,MSN_ISUSE,AD_CN,AD_SamAccountName,AD_UserPrincipalName"));
		return resultList;
	}
	
	/**
	 * 사용자 정보 Group Code select
	 * @param params - CoviMap
	 * @return string
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserSyncData(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectUserInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptCode,JobPositionName,JobTitleName,JobLevelName"));
		return resultList;
	}
	
	/**
	 * 코드 값으로 정보 가져오기(부서, 회사) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectDefaultSetInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectDefaultSetInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyName,DeptName,CompanyID"));
		return resultList;
	}

	/**
	 * 부서 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseDept(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsUseDept", params);
	};
	

	/**
	 * 부서 인사 연동 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsHRDept(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsHRDept", params);
	};
	
	/**
	 * 부서 표시 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsDisplayDept(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsDisplayDept", params);
	};
	
	/**
	 * 부서 메일 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsMailDept(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsMailDept", params);
	}
	
	/**
	 * 사용자 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseUser(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsUseUser", params);
	};
	
	/**
	 * 사용자 인사 연동 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsHRUser(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsHRUser", params);
	};
	
	/**
	 * 사용자 AD 연동 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsADUser(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsADUser", params);
	};
	
	@Override
	public int deleteUser(CoviMap params) throws Exception {
		int count = 0;
		count += coviMapperOne.update("organization.admin.deleteUser", params);
		count += coviMapperOne.update("organization.admin.deleteUserBaseGroup", params);
		count += coviMapperOne.delete("organization.admin.deleteUserGroupMember", params);
		count += coviMapperOne.insert("organization.admin.insertRetiredGroupMember", params);

		return count;
	}

	@Override
	public int deleteDept(CoviMap params) throws Exception {
		return coviMapperOne.delete("organization.admin.deleteDept", params);
	}

	@Override
	public CoviMap selectHasChildDept(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectHasChildDept", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "HasChild"));
		return resultList;
	}
	
	@Override
	public CoviMap selectHasUserDept(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectHasUserDept", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "HasUser"));
		return resultList;
	}

	@Override
	public CoviMap selectIsDuplicateDeptCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateDeptCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	};

	@Override
	public CoviMap selectIsDuplicateDeptPriorityOrder(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateDeptPriorityOrder", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	};
	
	@Override
	public CoviMap selectIsDuplicateUserCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateUserCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	};

	@Override
	public CoviMap selectIsduplicatesortkey(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateSortKey", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate,MaxSortKey"));
		return resultList;
	};
	
	
	/**
	 * 그룹 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupList(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectGroupList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,DomainCode,SortKey,GroupCode,GroupType,GroupName,DomainName,PrimaryMail,MemberOf,SortPath,GroupID,hasChild"));
		return resultList;
	}

	/**
	 * 지역 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectRegionInfo(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectRegionInfo", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,IsUse,IsHR,IsMail,CompanyCode,CompanyID,SortKey,GroupCode,GroupType,GroupName,MultiGroupName,CompanyName,PrimaryMail,SecondaryMail,MemberOf,SortPath,GroupID,Description,hasChild"));
			resultList.put("cnt", 1);
			
		} catch (SQLException e){
			LOGGER.error("selectRegionInfo Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectRegionInfo Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 임의 그룹 드롭다운 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectArbitraryGroupDropDownList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectArbitraryGroupDropDownList", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupType,GroupCode,GroupName"));
			
		} catch (SQLException e){
			LOGGER.error("selectArbitraryGroupDropDownList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectArbitraryGroupDropDownList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;

	}
	
	/**
	 * 임의 그룹 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectArbitraryGroupInfo(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectArbitraryGroupInfo", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,IsUse,IsHR,IsMail,CompanyCode,CompanyID,SortKey,GroupCode,GroupType,GroupName,MultiGroupName,CompanyName,MultiCompanyName,PrimaryMail,SecondaryMail,MemberOf,SortPath,GroupID,Description,hasChild"));
			resultList.put("cnt", 1);
			
		} catch (SQLException e){
			LOGGER.error("selectArbitraryGroupInfo Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectArbitraryGroupInfo Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 임의 그룹 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectArbitraryGroupList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectArbitraryGroupList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectArbitraryGroupListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,IsUse,IsHR,IsMail,DomainCode,SortKey,GroupCode,GroupType,GroupName,DomainName,PrimaryMail,MemberOf,SortPath,GroupID,hasChild,Description"));
			resultList.put("cnt", cnt);
			
		} catch (SQLException e){
			LOGGER.error("selectArbitraryGroupList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectArbitraryGroupList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;

	}
	
	/**
	 * 임의 그룹 설정 update
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateArbitraryGroup(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.update("organization.admin.updateArbitraryGroup", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 임의 그룹 목록 delete
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int deleteArbitraryGroupList(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("organization.admin.deleteArbitraryGroupList", params);
		return cnt;
	}
	
	/**
	 * 임의 그룹 목록 우선순위 update
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateArbitraryGroupListSortKey(CoviMap params) throws Exception {
		
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		String strSortKey_A = null;
		String strSortPath_A = null;
		String strSortKey_B = null;
		String strSortPath_B = null;
		String strTemp = null;
		
		try{
			//get SortKey,SortPath
			params.put("TargetCode", params.get("GR_Code_A"));
			strSortKey_A = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortKey").toString();
			strSortPath_A = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortPath").toString();
			params.put("TargetCode", params.get("GR_Code_B"));
			strSortKey_B = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortKey").toString();
			strSortPath_B = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortPath").toString();
			
			//update SortKey
			params.put("TargetCode", params.get("GR_Code_A"));
			params.put("TargetSortKey", strSortKey_B);
			params.put("TargetSortPath", strSortPath_B);
			returnCnt += coviMapperOne.update("organization.admin.updateArbitraryGroupSortKey", params);
			params.put("TargetCode", params.get("GR_Code_B"));
			params.put("TargetSortKey", strSortKey_A);
			params.put("TargetSortPath", strSortPath_A);
			returnCnt += coviMapperOne.update("organization.admin.updateArbitraryGroupSortKey", params);
			
		} catch (NullPointerException e){
			LOGGER.error("updateArbitraryGroupListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("updateArbitraryGroupListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 부서 기타 정보 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptEtcInfo(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectDeptEtcInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyID,GroupPath,SortPath,OUPath"));
		return resultList;
	}

	/**
	 * 부서 정보 insert
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertDeptInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.insertDeptInfo", params);
	}
	
	/**
	 * 부서 정보 update
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateDeptInfo(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("organization.admin.updateDeptInfo", params);
		coviMapperOne.update("organization.admin.updateBaseGroupDeptInfo", params);
		
		return retCnt;
	}
	
	/**
	 * 하위 부서 Path 정보 update
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateDeptPathInfo(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("organization.admin.updateDeptPathInfo", params);
		return retCnt;
	}
	
	/**
	 * 임의그룹 중복 여부 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateGroupCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateGroupCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	};

	/**
	 * 임의그룹 삽입
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int createGroup(CoviMap params) throws Exception {
		int iReturn = 0;
		
//		직급 직위 직책 동기화 
		if(this.addGroupSync(params) == 1) {
			if( params.getString("Mode")!= null && params.getString("Mode").toUpperCase().equals("ADD") )
			{
				iReturn = coviMapperOne.insert("organization.admin.insertObject", params);
				iReturn = coviMapperOne.insert("organization.admin.insertGroup", params);
			}
			else
			{	
				iReturn = coviMapperOne.insert("organization.admin.updateObject", params);
				iReturn = coviMapperOne.update("organization.admin.updateGroup", params);			
				switch(params.getString("GroupType").toUpperCase())
				{
				case "JOBPOSITION":
					coviMapperOne.update("organization.admin.updateBaseGroupJobPositionInfo", params);
					break;
				case "JOBTITLE":
					coviMapperOne.update("organization.admin.updateBaseGroupJobTitleInfo", params);
					break;
				case "JOBLEVEL":
					coviMapperOne.update("organization.admin.updateBaseGroupJobLevelInfo", params);
					break;
				default :
					break;
				}				
			}
		}else if(this.addGroupSync(params) == 0) {
			iReturn = 0;
		}
		return iReturn;
	}
	
	/**
	 * 임의 그룹 삽입 정보 select(path 등)
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupInsertData(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("organization.admin.selectGroupInsertData", params);
		CoviList groupInfo = CoviSelectSet.coviSelectJSON(list, "GroupPath,OUPath,SortPath");
		
		resultList.put("list",groupInfo);
		
		return resultList;
	};
	
	/**
	 * 지역 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectRegionList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectRegionList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectRegionListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,IsUse,IsHR,IsMail,DomainCode,SortKey,GroupCode,GroupType,GroupName,MultiGroupName,DomainName,PrimaryMail,MemberOf,SortPath,GroupID,hasChild,Description"));
			resultList.put("cnt", cnt);
			
		} catch (SQLException e){
			LOGGER.error("selectRegionList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectRegionList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 겸직 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectAddJobList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectAddJobListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "NO,UserCode,UserName,CompanyCode,DeptCode,JobTitleCode,JobPositionCode,JobLevelCode,JobType,CompanyName,DeptName,JobTitleName,JobPositionName,JobLevelName,IsHR"));
			resultList.put("cnt", cnt);
			
		} catch (SQLException e){
			LOGGER.error("selectAddJobList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectAddJobList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 겸직 삽입
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int createAddJob(CoviMap params) throws Exception {
		if( params.getString("Mode")!= null && params.getString("Mode").toUpperCase().equals("ADD") )
			return coviMapperOne.insert("organization.admin.insertAddJob", params);
		else
			return coviMapperOne.update("organization.admin.updateAddJob", params);
	}
	
	/**
	 * 겸직 정보 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobInfo(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectAddJobInfo", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "NO,UserCode,UserName,CompanyCode,DeptCode,JobTitleCode,JobPositionCode,JobLevelCode,JobType,CompanyName,DeptName,JobTitleName,JobPositionName,JobLevelName,IsHR"));
			
		} catch (SQLException e){
			LOGGER.error("selectAddJobInfo Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectAddJobInfo Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 겸직 정보 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobInfoList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectAddJobInfoList", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "NO,UserCode,UserName,CompanyCode,DeptCode,JobTitleCode,JobPositionCode,JobLevelCode,JobType,CompanyName,DeptName,JobTitleName,JobPositionName,JobLevelName,IsHR"));
			
		} catch (SQLException e){
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}	
	
	/**
	 * 겸직 정보(사용자 기본 정보) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobUserInfo(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectUserInfo", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "JobPositionCode,JobPositionName,JobTitleCode,JobTitleName,JobLevelCode,JobLevelName,UserID,UserID,MultiDisplayName,DeptCode,MultiDeptName,CompanyCode,MultiCompanyName"));
			
		} catch (SQLException e){
			LOGGER.error("selectAddJobUserInfo Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectAddJobUserInfo Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;
	}
	
	/**
	 * 겸직 설정 update
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateAddJobSetting(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
			
		returnCnt = coviMapperOne.update("organization.admin.updateAddJobSetting", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 겸직 목록 delete
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int deleteAddJob(CoviMap params) throws Exception {
		int cnt = coviMapperOne.delete("organization.admin.deleteAddJob", params);
		return cnt;
	}
	
	/**
	 * 부서/사용자 목록 우선순위 update
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateDeptUserListSortKey(CoviMap params) throws Exception {
		
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		String strSortKey_A = null;
		String strSortKey_B = null;
		String strSortPath_A = "";
		String strSortPath_B = "";
		String strTemp = null;
		String strType = null;
		try{
			strType = params.get("Type").toString();
			if(strType.equals("dept")) {
				//get SortKey
				params.put("TargetCode", params.get("Code_A"));
				strSortKey_A = coviMapperOne.select("organization.admin.selectDeptSortKey", params).get("SortKey").toString();
				strSortPath_A = coviMapperOne.select("organization.admin.selectDeptSortKey", params).get("SortPath").toString();				
				params.put("TargetCode", params.get("Code_B"));
				strSortKey_B = coviMapperOne.select("organization.admin.selectDeptSortKey", params).get("SortKey").toString();
				strSortPath_B = coviMapperOne.select("organization.admin.selectDeptSortKey", params).get("SortPath").toString();
				
				//update SortKey
				params.put("TargetCode", params.get("Code_A"));
				params.put("TargetSortKey", strSortKey_B);
				params.put("TargetSortPath", strSortPath_B);
				returnCnt += coviMapperOne.update("organization.admin.updateDeptSortKey", params);
				params.put("TargetCode", params.get("Code_B"));
				params.put("TargetSortKey", strSortKey_A);
				params.put("TargetSortPath", strSortPath_A);
				returnCnt += coviMapperOne.update("organization.admin.updateDeptSortKey", params);
			} else if(strType.equals("user")) {
				//get SortKey
				params.put("TargetCode", params.get("Code_A"));
				strSortKey_A = coviMapperOne.select("organization.admin.selectUserSortKey", params).get("SortKey").toString();
				params.put("TargetCode", params.get("Code_B"));
				strSortKey_B = coviMapperOne.select("organization.admin.selectUserSortKey", params).get("SortKey").toString();
				
				//update SortKey
				params.put("TargetCode", params.get("Code_A"));
				params.put("TargetSortKey", strSortKey_B);
				returnCnt += coviMapperOne.update("organization.admin.updateUserSortKey", params);
				params.put("TargetCode", params.get("Code_B"));
				params.put("TargetSortKey", strSortKey_A);
				returnCnt += coviMapperOne.update("organization.admin.updateUserSortKey", params);
			}
			
		} catch (NullPointerException e){
			LOGGER.error("updateDeptUserListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("updateDeptUserListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 메일 주소 중복 여부 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateMail(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateMail", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	
	/**
	 * 임의그룹 리스트 가져오기 select
	 * @param params CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectJobInfoList(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("organization.admin.selectJobInfoCount", params);
		CoviList list = null;
		
		if(cnt > 0) {
			list = coviMapperOne.list("organization.admin.selectJobInfoList", params);
		} else {
			CoviMap temp = new CoviMap();
			temp.put("domainCode", "ORGROOT");
			temp.put("groupType", params.get("groupType").toString());
			
			list = coviMapperOne.list("organization.admin.selectJobInfoList", temp);
		}

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,DisplayName,GroupType,MemberOf,MultiDisplayName"));
		return resultList;
	}
	
	/**
	 * 회사 드롭다운 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAvailableCompanyList(CoviMap params) throws Exception {
		
		CoviMap resultList = null;
		CoviList list = null;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectAvailableCompanyList", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyCode,CompanyName,CompanyID"));
			
		} catch (SQLException e){
			LOGGER.error("selectAvailableCompanyList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectAvailableCompanyList Error  " + "[Message : " +  e.getMessage() + "]");
		}
	
		return resultList;

	}
	
	/**
	 * 서비스 유형 select
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectServiceTypeList() throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectServiceTypeList", null);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText"));
		return resultList;
	}
	
	/**
	 * 사용자 정보 insert
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserInfo(CoviMap params) throws Exception {
		int returnCnt = 0;
		params.put("aeskey", aeskey);
		returnCnt = coviMapperOne.insert("organization.admin.insertUserDefaultInfo", params);
		returnCnt = coviMapperOne.insert("organization.admin.insertUserDefaultInfo2", params);
		returnCnt += coviMapperOne.insert("organization.admin.insertUserBaseGroupInfo", params);
		returnCnt += coviMapperOne.insert("organization.admin.insertUserApprovalInfo", params);
		returnCnt += coviMapperOne.insert("organization.admin.insertUserGroupMember", params);
		
		returnCnt += updateOrgUserPhotoPath(params);
		
		return returnCnt;
	}
	
	/**
	 * 사용자 정보 update
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserInfo(CoviMap params) throws Exception {
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("organization.admin.updateUserDefaultInfo", params);
		returnCnt += coviMapperOne.update("organization.admin.updateUserBaseGroupInfo", params);
	
		if(returnCnt < 2) {
			returnCnt += coviMapperOne.insert("organization.admin.insertUserBaseGroupInfo", params);
		}
		
		returnCnt += coviMapperOne.update("organization.admin.updateUserApprovalInfo", params);
		if(returnCnt < 3) {
			returnCnt += coviMapperOne.insert("organization.admin.insertUserApprovalInfo", params);
		}
		
		returnCnt += coviMapperOne.delete("organization.admin.deleteUserGroupDefaultMember",params);
		returnCnt += coviMapperOne.insert("organization.admin.insertUserGroupMember", params);
		
		returnCnt +=  updateOrgUserPhotoPath(params);
		
		return returnCnt;
	}
	
	@Override
	public int updateOrgUserPhotoPath(CoviMap params) throws Exception {
		int retCnt = 0;
		if(!params.getString("PhotoPath").equals("")) {
			final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath"); 
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			if(awsS3.getS3Active(companyCode)) {
				String dir = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path;
				String key = dir+"/"+params.getString("UserCode") + "_org";
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				String orgkey = dir+"/"+params.getString("UserCode") + "_org.jpg";
				MultipartFile mFile = (MultipartFile) params.get("FileInfo");
				awsS3.upload(mFile.getInputStream(), orgkey, mFile.getContentType(), mFile.getSize());
				String thumKey = FileUtil.getBackPath() + path + params.getString("UserCode") + ".jpg";
				fileUtilSvc.makeThumb(thumKey, mFile.getInputStream(), FilenameUtils.getExtension(mFile.getName()));
			}else{
				// 0. 디렉토리, 파일 체크
				File dir = new File(FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path);
				if (!dir.exists()) {
					if (dir.mkdirs()) {
						LOGGER.info("path : " + path + " mkdirs()");
					}
				}

				File existFile = new File(dir, params.getString("UserCode"));
				if (existFile.exists()) {
					boolean dReturn =false;
					try{
						dReturn = existFile.delete();	
					} catch (NullPointerException e){
						throw new IOException("updateUserPhotoPath : Fail to delete file." + existFile.getName());
					}
					catch(Exception ex){
						throw new IOException("updateUserPhotoPath : Fail to delete file." + existFile.getName());
					}
					dReturn = new File(dir, params.getString("UserCode") + "_org").delete();

					if (!dReturn)
						throw new IOException("updateOrgUserPhotoPath : Fail to delete file." + existFile.getName());
				}

				// 1. 파일 생성(리사이즈, 원본)
				MultipartFile mFile = (MultipartFile) params.get("FileInfo");
				File file = new File(dir, params.getString("UserCode") + "_org.jpg");
				mFile.transferTo(file);

				Image src = ImageIO.read(file);
				BufferedImage resizeImage = new BufferedImage(200, 200, BufferedImage.TYPE_INT_RGB);
				resizeImage.getGraphics().drawImage(src.getScaledInstance(200, 200, Image.SCALE_SMOOTH), 0, 0, null);

				try (FileOutputStream out = new FileOutputStream(FileUtil.getBackPath() + path + params.getString("UserCode") + ".jpg");) {
					ImageIO.write(resizeImage, "jpg", out);
				}
			}
		    
			// 2. photoPath 업데이트
			params.put("PhotoPath", RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + path +  params.getString("UserCode") + ".jpg");
			params.put("UserCode",  params.getString("UserCode"));
			
			retCnt = coviMapperOne.update("organization.admin.updateOrgUserPhotoPath", params);
		}
		
		return  retCnt;
	}
	
	/**
	 * 부서 목록 select for select box
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptListForCategory(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectDeptListForCategory", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,GroupName"));
		return resultList;
	}
	
	/**
	 * 하위 그룹 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSubGroupList(CoviMap params) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectSubGroupList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectSubGroupListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,MultiDisplayName,IsUse,GroupType,CompanyCode,GroupPath,SortPath,MultiShortName,OUName,ShortName,SortKey,MemberOf,IsMail,PrimaryMail"));
			resultList.put("cnt", cnt);		
		} catch (SQLException e){
			LOGGER.error("selectSubGroupList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectSubGroupList Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		return resultList;
	}
	
	/**
	 * 그룹 사용자 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupUserList(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectGroupUserList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectGroupUserListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,UserID,UserCode,MultiDisplayName,JobLevel,JobTitle,JobPosition,Mobile,MailAddress,PhoneNumber,EmpNo,DeptCode,MultiDeptName,CompanyCode,MultiCompanyName,JobType,PhoneNumberInter,IsUse,IsDisplay,IsHR,SortKey"));
			resultList.put("cnt", cnt);		
		} catch (SQLException e){
			LOGGER.error("selectGroupUserList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectGroupUserList Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		return resultList;
	}
	
	/**
	 * 그룹 멤버 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupMemberList(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		try{
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.admin.selectGroupMemberList", params);
			cnt = (int)coviMapperOne.getNumber("organization.admin.selectGroupMemberListCnt", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ROWNUM,Type,Code,CodeName,MailAddress,MemberID"));
			resultList.put("cnt", cnt);		
		} catch (SQLException e){
			LOGGER.error("selectGroupMemberList Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("selectGroupMemberList Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		return resultList;
	}
	
	/**
	 * 그룹 목록 select for select box
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupListForCategory(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectGroupListForCategory", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,GroupName"));
		return resultList;
	}

	@Override
	public CoviMap selectOrgExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		String sField = ""; // 항목 설정
		CoviList list = null;
		int cnt = 0;
		
		if(params.get("type").toString().equalsIgnoreCase("dept")){
			sField = "GroupCode,SortKey,DisplayName,ShortName,IsUse,IsHR,IsDisplay,IsMail,PrimaryMail";
			list = coviMapperOne.list("organization.admin.selectSubDeptList",params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectSubDeptListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("user")){
			sField = "UserCode,SortKey,DisplayName,JobTitleName,JobPositionName,JobLevelName,IsUse,IsHR,MailAddress";
			list = coviMapperOne.list("organization.admin.selectUserList",params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectUserListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("group")){ //group
			sField = "GroupCode,SortKey,DisplayName,ShortName,IsUse,IsMail,PrimaryMail";
			list = coviMapperOne.list("organization.admin.selectSubGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectSubGroupListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("title") || params.get("type").toString().equalsIgnoreCase("position") || params.get("type").toString().equalsIgnoreCase("level")){
			sField = "GroupCode,GroupName,SortKey,IsUse,IsHR,IsMail";
			list = coviMapperOne.list("organization.admin.selectArbitraryGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectArbitraryGroupListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("region")){
			sField = "DomainName,GroupCode,GroupName,SortKey,IsUse,IsHR,IsMail,PrimaryMail";
			list = coviMapperOne.list("organization.admin.selectRegionList", params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectRegionListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("addjob")){
			sField = "UserName,CompanyName,GroupName,JobTitleName,JobPositionName,JobLevelName,IsHR";
			list = coviMapperOne.list("organization.admin.selectAddJobList", params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectAddJobListCnt", params);
		} else if(params.get("type").toString().equalsIgnoreCase("groupmember")){
			sField = "Type,Code,CodeName,MailAddress";
			list = coviMapperOne.list("organization.admin.selectGroupMemberList", params);
			cnt = (int) coviMapperOne.getNumber("organization.admin.selectGroupMemberListCnt", params);
		}
		
		resultList.put("list", coviSelectJSONForExcel(list, sField));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @param clist
	 * @param str
	 * @return JSONArray
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForExcel(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}
	
	/**
	 * 그룹 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseGroup(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsUseGroup", params);
	};
	
	/**
	 * 그룹 메일 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsMailGroup(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsMailGroup", params);
	}
	
	/**
	 * 사용자 메일 사용 여부 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsMailUser(CoviMap params)throws Exception{
		return coviMapperOne.update("organization.admin.updateIsMailUser", params);
	}
	
	/**
	 * 그룹 삭제 update
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public int deleteGroup(CoviMap params) throws Exception {
		return coviMapperOne.delete("organization.admin.deleteGroup", params);
	}
	
	/**
	 * 하위 그룹 존재 여부 select
	 * @param params - CoviMap
	 * @return resultList - JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectHasChildGroup(CoviMap params) throws Exception {
		int hasChildCnt =(int) coviMapperOne.getNumber("organization.admin.selectHasChildGroup", params);

		return hasChildCnt;
	}
	
	/**
	 * 하위 사용자 존재 여부 select
	 * @param params - CoviMap
	 * @return resultList - JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectHasUserGroup(CoviMap params) throws Exception {
		int hasChildCnt =(int) coviMapperOne.getNumber("organization.admin.selectHasUserGroup", params);

		return hasChildCnt;
	}
	
	/**
	 * 그룹/사용자 목록 우선순위 update
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateGroupUserListSortKey(CoviMap params) throws Exception {
		
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		String strSortKey_A = null;
		String strSortKey_B = null;
		String strSortPath_A = "";
		String strSortPath_B = "";
		String strTemp = null;
		String strType = null;
		try{
			strType = params.get("Type").toString();
			if(strType.equals("group")) {
				//get SortKey
				params.put("TargetCode", params.get("Code_A"));
				strSortKey_A = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortKey").toString();
				strSortPath_A = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortPath").toString();				
				params.put("TargetCode", params.get("Code_B"));
				strSortKey_B = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortKey").toString();
				strSortPath_B = coviMapperOne.select("organization.admin.selectArbitraryGroupSortKey", params).get("SortPath").toString();
				
				//update SortKey
				params.put("TargetCode", params.get("Code_A"));
				params.put("TargetSortKey", strSortKey_B);
				params.put("TargetSortPath", strSortPath_B);
				returnCnt += coviMapperOne.update("organization.admin.updateArbitraryGroupSortKey", params);
				params.put("TargetCode", params.get("Code_B"));
				params.put("TargetSortKey", strSortKey_A);
				params.put("TargetSortPath", strSortPath_A);
				returnCnt += coviMapperOne.update("organization.admin.updateArbitraryGroupSortKey", params);
			} else if(strType.equals("user")) {
				//get SortKey
				params.put("TargetCode", params.get("Code_A"));
				strSortKey_A = coviMapperOne.select("organization.admin.selectUserSortKey", params).get("SortKey").toString();
				params.put("TargetCode", params.get("Code_B"));
				strSortKey_B = coviMapperOne.select("organization.admin.selectUserSortKey", params).get("SortKey").toString();
				
				//update SortKey
				params.put("TargetCode", params.get("Code_A"));
				params.put("TargetSortKey", strSortKey_B);
				returnCnt += coviMapperOne.update("organization.admin.updateUserSortKey", params);
				params.put("TargetCode", params.get("Code_B"));
				params.put("TargetSortKey", strSortKey_A);
				returnCnt += coviMapperOne.update("organization.admin.updateUserSortKey", params);
			}
			
		} catch (NullPointerException e){
			LOGGER.error("updateGroupUserListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e){
			LOGGER.error("updateGroupUserListSortKey Error  " + "[Message : " +  e.getMessage() + "]");
		}
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 그룹 정보 가져오기 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectGroupInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectGroupInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,ParentName,GroupPath,MultiDisplayName,MultiShortName,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitcode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode"));
		return resultList;
	}
	
	/**
	 * 그룹 기타 정보 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupEtcInfo(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("organization.admin.selectGroupEtcInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyID,GroupPath,SortPath,OUPath"));
		return resultList;
	}
	
	/**
	 * 그룹 정보 insert
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertGroupInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.insertGroupInfo", params);
	}
	
	/**
	 * 그룹 정보 update
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateGroupInfo(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.admin.updateGroupInfo", params);
	}
	
	/**
	 * 코드 값으로 정보 가져오기(그룹, 회사) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDefaultSetInfoGroup(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectDefaultSetInfoGroup", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyName,GroupName,CompanyID"));
		return resultList;
	}
	
	/**
	 * 그룹 멤버 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addGroupMember(CoviMap params) throws Exception {
		int iCnt = 0;
		String URList1 = "";
		String GRList1 = "";
		if(params.get("URList") != null && !params.get("URList").equals("")) {
			URList1 = params.get("URList").toString();
		}
		if(params.get("GRList") != null && !params.get("GRList").equals("")) {
			GRList1 = params.get("GRList").toString();
		}
		
		if(URList1 != null && !URList1.equals("")){
			String URList[] = URList1.split(";");
			for(int i=0; i < URList.length; i++) {
				params.put("URList", URList[i]);
				iCnt += coviMapperOne.insert("organization.admin.insertGroupMemberUser", params);
			}
		}
		if(GRList1 != null && !GRList1.equals("")){
			String GRList[] = GRList1.split(";");
			for(int i=0; i < GRList.length; i++) {
				params.put("URList", GRList[i]);
				iCnt += coviMapperOne.insert("organization.admin.insertGroupMemberGroup", params);
			}
		}
		return iCnt;
	}
	
	/**
	 * 그룹 멤버 삭제
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteGroupMember(CoviMap params) throws Exception {
		int iCnt = 0;
		if(params.get("deleteDataUser") != null){
			iCnt += coviMapperOne.delete("organization.admin.deleteGroupMemberUser", params);
		}
		if(params.get("deleteDataGroup") != null){
			iCnt += coviMapperOne.delete("organization.admin.deleteGroupMemberGroup", params);
		}
		return iCnt;
	}
	
	@Override
	public CoviMap getJson(String encodedUrl, String method) throws Exception {
		CoviMap resultList = new CoviMap();
		HttpURLConnectUtil url= new HttpURLConnectUtil();
		String sMethod = method;
		
		try
		{
			if(sMethod.equals("POST")) {resultList = url.httpConnect(encodedUrl,sMethod,10000,10000,"xform","Y");}
			else if(sMethod.equals("GET")) {resultList = url.httpConnect(encodedUrl,sMethod,10000,10000,"xform","Y");}
			LOGGER.debug("URL : " + encodedUrl);
		} catch (NullPointerException ex){
			throw ex;
		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			url.httpDisConnect();
		}
		
		return resultList;
	}
	
	// NameValuePair Array Add Item
	public static NameValuePair[] addArray(NameValuePair[] arrOrigin, NameValuePair newData) {		
		NameValuePair[] arrTemp = null;
		
	    int iCnt = arrOrigin.length;
	    
	    if(iCnt < Integer.MAX_VALUE) {
	    	int iNewCnt = iCnt + 1;
		    
		    arrTemp = new NameValuePair[ iNewCnt ];
		    for (int i=0; i < iCnt; i++) {
		    	arrTemp[i] = arrOrigin [i];
		    }
		    
		    arrTemp[iNewCnt- 1] = newData;		       
	    }
	    
	    return arrTemp;
	}
	
	@Override
	public boolean getIndiSyncTF() throws Exception {
		boolean bReturn;
		bReturn = RedisDataUtil.getBaseConfig("IsSyncIndi").equals("Y") ? true : false;
		return bReturn;
	}

	
	/**
	 * IndiMail 사용자 계정상태 확인
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserStatus(CoviMap params) throws Exception {
		String apiURL = null;
		String sMode = "?job=userStatus";
		String sDomain = null;
		String method = "POST";
		CoviMap jObj = new CoviMap();
		
		try
		{
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");

			String sLogonID = params.get("LogonID").toString();
			
			sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = apiURL + String.format("&id=%s&domain=%s", sLogonID, sDomain);
			jObj = getJson(apiURL, method);
		} catch (NullPointerException ex){
			LOGGER.error("IndiMail getUserStatus Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		}
		catch(Exception ex)
		{
			LOGGER.error("IndiMail getUserStatus Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		}
		return jObj;
	}

	/**
	 * IndiMail 사용자 계정 추가
	 * @param params - CoviMap
	 * @return 
	 * @throws Exception
	 */
	@Override
	public CoviMap addUser(CoviMap params) throws Exception {
		String apiURL = null;
		String sMode = "?job=addUser";
		String sDomain = null;
		String method = "GET";
		CoviMap jObj = new CoviMap();
		
		try {
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") +sMode;
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");

			String sLogonID = params.get("LogonID").toString();
			//String sPassword = params.get("DecLogonPassword").toString();
			AES aes = new AES(aeskey, "N");
			String sPassword = aes.encrypt(params.get("DecLogonPassword").toString());
			String sName = params.get("DisplayName").toString();
			String sEnc = "";
			String sCompany = params.getString("CompanyCode");
			String sDeptId = params.get("DeptCode").toString();
			String sDeptName = params.get("DeptName").toString();
			String sStatus = "A";
			String slang = params.get("LanguageCode").toString();
			String sTimeZone = params.get("TimeZoneCode").toString();
			String sMailSize = "1024";
			String sFileSize = "10";
			String sContacts = "1";
			
			sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
			sName = java.net.URLEncoder.encode(sName, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = apiURL + String.format("&id=%s&pw=%s&name=%s&domain=%s&company=%s&enc=%s&deptId=%s&deptName=%s&status=%s&lang=%s&timezone=%s&mailsize=%s&filesize=%s&contacts=%s",
					sLogonID, sPassword, sName, sDomain, sCompany, sEnc, sDeptId, sDeptName, sStatus, slang, sTimeZone, sMailSize, sFileSize, sContacts);
			jObj = getJson(apiURL, method);
			
			if(!jObj.get("returnCode").toString().equals("1")) {
				LOGGER.error(jObj.toString());
				throw new Exception(" [메일] " + jObj.get("returnMsg"));
			}
		} catch (NullPointerException e){
			LOGGER.error("IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}
		return jObj;
	}

	/**
	 * IndiMail 사용자 계정 수정/삭제
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public CoviMap modifyUser(CoviMap params) throws Exception {
		StringBuffer apiURL = new StringBuffer();
		String sMode = "?job=modifyUser";
		String sDomain = null;
		String sLogonID = null;
		String method = "GET";
		CoviMap jObj = new CoviMap();
		
		try {
			apiURL.append(RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode);
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");
			String sMailStatus = params.get("mailStatus").toString();
			
			//S 인디메일 계정 비활성화
			if(sMailStatus.equals("S")) {
				 int i = Integer.parseInt(params.get("intI").toString());
				for(int j=0; j<i; j++) {
					sLogonID = params.get("sLoginID"+j).toString(); 
					params.put("LogonID", sLogonID);
					
					CoviMap reObject = getUserStatus(params);
					String rReturnCode = reObject.get("returnCode").toString();
					String rResult = reObject.get("result").toString();
					if(rReturnCode.equals("0") && rResult.equals("0")){    //계정이 존재하면
						sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
						String sCompany = params.getString("CompanyCode");
						sMailStatus = java.net.URLEncoder.encode(sMailStatus, java.nio.charset.StandardCharsets.UTF_8.toString());
						
						apiURL.append(String.format("&id=%s&status=%s&domain=%s&company=%s", sLogonID, sMailStatus, sDomain, sCompany));
						jObj = getJson(apiURL.toString(), method);
						if(!jObj.get("returnCode").toString().equals("0")||!"SUCCESS".equals(jObj.get("returnMsg")))
						{
							LOGGER.error(jObj.toString()); //print error context
						}
					}
				}
			}else {
				sLogonID = params.get("LogonID").toString();
				sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
				AES aes = new AES(aeskey, "N");
				String sPassword = aes.encrypt(params.get("DecLogonPassword").toString());
				String sName = params.get("DisplayName").toString();
				sName = java.net.URLEncoder.encode(sName, java.nio.charset.StandardCharsets.UTF_8.toString());
				String sCompany = params.getString("CompanyCode");
				String sDeptId = params.get("DeptCode").toString();
				sMailStatus = java.net.URLEncoder.encode(sMailStatus, java.nio.charset.StandardCharsets.UTF_8.toString());
				
				apiURL.append(String.format("&id=%s&pw=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s", sLogonID, sPassword, sName, sMailStatus, sDomain, sCompany, sDeptId));
				jObj = getJson(apiURL.toString(), method);
				if(!jObj.get("returnCode").toString().equals("0")||!"SUCCESS".equals(jObj.get("returnMsg")))
				{
					LOGGER.error(jObj.toString()); //print error context
				}
				
			}
		} catch (NullPointerException e){
			LOGGER.error("IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}
		return jObj;
	}
	
	/**
	 * IndiMail 비밀번호 수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int modifyPass(CoviMap params) throws Exception {
		int iReturn = 1;
		String apiURL = null;
		String sMode = "?job=modifyPass";
		String sDomain = null;
		String method = "POST";
		String sPassword = null;
		
		try {
			sPassword = params.get("Returnpass").toString();
			
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");

			String sLogonID = params.get("UserID").toString();
			sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
			AES aes = new AES(aeskey, "N");
			sPassword = aes.encrypt(sPassword);
			
			apiURL = apiURL + String.format("&id=%s&pw=%s&domain=%s", sLogonID, sPassword, sDomain);
			CoviMap jObj = getJson(apiURL, method);
			
			if(jObj.get("returnCode").toString().equals("0")&&"SUCCESS".equals(jObj.get("returnMsg")))
			{
				iReturn = 0;
				LOGGER.debug(jObj.get("returnMsg").toString());
			}
			else
			{
				iReturn = 3;
				LOGGER.error(jObj.toString()); //print error context
			}
		} catch (NullPointerException e){
			LOGGER.error("IndiMail modifyPass Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("IndiMail modifyPass Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}
		return iReturn;
	}
	
	/**
	 * IndiMail 그룹 추가
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean addGroup(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "?job=addGroup";
		String sDomain = null;
		String method = "POST";
		
		try
		{
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");
			String sDeptCode = params.get("GroupCode").toString();
			String sDisplayName = params.get("DisplayName").toString();
			String sMemberOf = params.get("MemberOf").toString();				
			
			sDeptCode = java.net.URLEncoder.encode(sDeptCode, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDisplayName = java.net.URLEncoder.encode(sDisplayName, java.nio.charset.StandardCharsets.UTF_8.toString());
			sMemberOf = java.net.URLEncoder.encode(sMemberOf, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = apiURL + String.format("&id=%s&name=%s&enc=%s&deptId=%s&status=%s&domain=%s", sDeptCode, sDisplayName, "0", sMemberOf, "A", sDomain);
			LOGGER.debug(apiURL);
			
			CoviMap jObj = getJson(apiURL, method);
			if(jObj.get("returnCode").toString().equals("0")&&"SUCCESS".equals(jObj.get("returnMsg")))
			{					
				bReturn = true;					
			}else
			{
				LOGGER.error(jObj.toString()); //print error context
			}								
		} catch (NullPointerException ex){
			LOGGER.error("addGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		}
		catch(Exception ex)
		{
			LOGGER.error("addGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]", ex);
		}
		return bReturn;
	}
	
	/**
	 * IndiMail 그룹 수정
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean modifyGroup(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "?job=modifyGroup";		
		String sDomain = null;
		String method = "POST";
		
		try
		{
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);
			
			sDomain = RedisDataUtil.getBaseConfig("IndiMailDomain");
			String sDeptCode = params.get("GroupCode").toString();
			String sDisplayName = params.get("DisplayName").toString();
			String sMemberOf = params.get("MemberOf").toString();
			
			sDeptCode = java.net.URLEncoder.encode(sDeptCode, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDisplayName = java.net.URLEncoder.encode(sDisplayName, java.nio.charset.StandardCharsets.UTF_8.toString());
			sMemberOf = java.net.URLEncoder.encode(sMemberOf, java.nio.charset.StandardCharsets.UTF_8.toString());
							
			apiURL = apiURL + String.format("&id=%s&name=%s&enc=%s&deptId=%s&status=%s&domain=%s", sDeptCode, sDisplayName, "0", sMemberOf, "A", sDomain);				
			
			CoviMap jObj = getJson(apiURL, method);
			if(jObj.get("returnCode").toString().equals("0")&&"SUCCESS".equals(jObj.get("returnMsg")))
			{					
				bReturn = true;					
			}else
			{
				LOGGER.error(jObj.toString()); //print error context
			}				
		} catch (NullPointerException ex){
			LOGGER.error("modifyGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]");
		}
		catch(Exception ex)
		{
			LOGGER.error("modifyGroup Error [" + params.get("UserCode") + "]" + "[Message : " +  ex.getMessage() + "]");
		}
		
		return bReturn;
	}
	
	@Override
	public String getTSVer() throws Exception {
		String sReturn;
		sReturn = RedisDataUtil.getBaseConfig("TimeSquareAPIVer");
		return sReturn;
	}

	@Override
	public boolean getTSSyncTF() throws Exception {
		boolean bReturn;
		bReturn = RedisDataUtil.getBaseConfig("IsSyncTimeSquare").equals("Y") ? true : false;
		return bReturn;
	}

	/**
	 * 타임스퀘어 계정존재 여부 조회
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getUsersyncexistuser(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "syncexistuser?d=";
		String method = "GET";
		
		try {
			String sUsername = params.get("LogonID").toString();
			
			sUsername = java.net.URLEncoder.encode(sUsername, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			apiURL = apiURL + "{" + "\"username\":\"" +sUsername + "\"" + "}";
			CoviMap jObj = getJson(apiURL, method);
			
			if(jObj.get("returnCode").toString().equals("0"))
			{
				if(jObj.get("userstatus").toString().equals("true"))
					bReturn = true;
				else
					bReturn = false;
			}else
			{
				bReturn = false;
				LOGGER.error(jObj.toString()); //print error context
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}
		return bReturn;
	}
	
	/**
	 * 타임스퀘어 계정활성화 여부 조회
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getUserStatusSyncstatususer(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "syncstatususer?d=";
		String method = "GET";
		
		try {
			String sUsername = params.get("LogonID").toString();
			
			sUsername = java.net.URLEncoder.encode(sUsername, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			apiURL = apiURL + "{" + "\"username\":\"" +sUsername + "\"" + "}";
			CoviMap jObj = getJson(apiURL, method);
			
			if(jObj.get("returnCode").toString().equals("0"))
			{
				bReturn = true;
			}else
			{
				bReturn = false;
				LOGGER.error(jObj.toString()); //print error context
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}
		return bReturn;
	}
	
	/**
	 * 타임스퀘어 사용자 계정 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addUserSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;	
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());	
			
			wrTS = httpClient.streamAdd(wrTS, "job","addUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId",params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "email",params.get("MailAddress").toString());
			wrTS = httpClient.streamAdd(wrTS, "password",params.get("DecLogonPassword").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName",params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order",params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumberInter",params.get("PhoneNumberInter").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumber",params.get("PhoneNumber").toString());
			wrTS = httpClient.streamAdd(wrTS, "memberOf",params.get("DeptCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobTitleCode",params.get("JobTitleCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobTitleName",params.get("JobTitleName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobPositionCode",params.get("JobPositionCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobPositionName",params.get("JobPositionName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobLevelCode",params.get("JobLevelCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobLevelName",params.get("JobLevelName").toString());			
			
			if(!params.getString("PhotoPath").equals("")){			
				wrTS = httpClient.streamFileAdd(wrTS,"profileImage",params);
			}
			
			if(params.get("BySaml").toString().equals("1")) {
				wrTS = httpClient.streamAdd(wrTS, "authType","saml");			
			}		
			
			wrTS = httpClient.streamAdd(wrTS, "","");
		
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);			
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}catch(Exception e){
			LOGGER.error("TimeSquare addUser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		return bReturn;
	}
	
	/**
	 * 타임스퀘어 그룹 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addGroupSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
	
			switch(params.get("GroupType").toString().toUpperCase()){
				case "DEPT" :
					wrTS = httpClient.streamAdd(wrTS, "job", "addGroup");
					wrTS = httpClient.streamAdd(wrTS, "createType", "channel");
					wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());
					wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("MemberOf").toString());
					wrTS = httpClient.streamAdd(wrTS, "level", "1");				
					break;
				case "JOBTITLE" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "T");
					wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());				
					break;
				case "JOBLEVEL" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "L");
					wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());				
					break;
				case "JOBPOSITION" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "P");
					wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());				
					break;
				default :
					break;
			}
			
			wrTS = httpClient.streamAdd(wrTS, "","");
		
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);			
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}catch(Exception e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		return bReturn;
	}
	
	/**
	 * 타임스퀘어 그룹 수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateGroupSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
			
			switch(params.get("GroupType").toString().toUpperCase()){
				case "DEPT" :
					wrTS = httpClient.streamAdd(wrTS, "job", "modifyGroup");
					wrTS = httpClient.streamAdd(wrTS, "createType", "channel");
					wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());
					wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("MemberOf").toString());
					wrTS = httpClient.streamAdd(wrTS, "level", "1");				
					break;
				case "JOBTITLE" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "T");		
					break;
				case "JOBLEVEL" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "L");						
					break;
				case "JOBPOSITION" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "P");							
					break;
				default :
					break;
			}
			
			wrTS = httpClient.streamAdd(wrTS, "","");
			
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}catch(Exception e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]", e);
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		return bReturn;
	}

	/**
	 * 타임스퀘어 그룹 삭제
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteGroupSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());		
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
			
			switch(params.get("GroupType").toString().toUpperCase()){
				case "DEPT" :
					wrTS = httpClient.streamAdd(wrTS, "job", "modifyGroup");								
					break;
				case "JOBTITLE" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "T");		
					break;
				case "JOBLEVEL" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "L");						
					break;
				case "JOBPOSITION" :
					wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
					wrTS = httpClient.streamAdd(wrTS, "groupType", "P");							
					break;
				default : 
					break;
			}		
			
			wrTS = httpClient.streamAdd(wrTS, "","");
		
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);			
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}catch(Exception e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		return bReturn;
	}	
	
	/**
	 * 타임스퀘어 사용자/부서 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addUsersyncusermap(CoviMap params) throws Exception {
		int bReturn = 0;
		String apiURL = null;
		String sMode = "syncusermap";
		String method = "POST";
		
		try {
			String syncMode = params.get("SyncMode").toString(); // 조직도 동기화 부서/사용자 구분코드
			String sUc = null;
			String sGC = null;
			String sLv = null;
			String sDn = null;
			String sUt = null;
			String sOd = null;
			
			String sGroup_type = null;
			String sCompany_code = null;
			String job_title_code = null;
			String ex_job_title_name = null;
			String job_position_code = null;
			String ex_job_position_name = null;
			String job_level_code = null;
			String ex_job_level_name = null;
			String phone_number_inter = null;
			String phone_number = null;
			
			if(syncMode.equals("U")) {
				sUc = params.get("LogonID").toString(); 	//UserCode
				sGC = params.get("DeptCode").toString(); 	//GroupCode
				sLv = "0"; 									//조직도상 노드의 레벨 0
				sDn = params.get("DisplayName").toString(); //Displayname
				sUt = "U"; 									//UserType U
				sOd = params.get("SortKey").toString(); 	//부서내 정렬순서
				//sGroup_type = "company";
				//sCompany_code = params.get("CompanyCode").toString();	//계열사 경우 회사코드
				job_title_code = !params.get("JobTitleCode").toString().equals("") ? params.get("JobTitleCode").toString() : "";
				ex_job_title_name = !params.get("JobTitleName").toString().equals("") ? params.get("JobTitleName").toString() : "";
				job_position_code = !params.get("JobPositionCode").toString().equals("") ? params.get("JobPositionCode").toString() : "";
				ex_job_position_name = !params.get("JobPositionName").toString().equals("") ? params.get("JobPositionName").toString() : "";
				job_level_code = !params.get("JobLevelCode").toString().equals("") ? params.get("JobLevelCode").toString() : "";
				ex_job_level_name = !params.get("JobLevelName").toString().equals("") ? params.get("JobLevelName").toString() : "";
				phone_number_inter = !params.get("PhoneNumberInter").toString().equals("") ? params.get("PhoneNumberInter").toString() : "";
				phone_number = !params.get("PhoneNumber").toString().equals("") ? params.get("PhoneNumber").toString() : "";
			}else if(syncMode.equals("G")) {
				sUc = params.get("GroupCode").toString();
				if(sUc.equals("ORGROOT"))  sGC = "";
				else sGC = params.get("MemberOf").toString();
				sLv = "0";
				sDn = params.get("DisplayName").toString();
				sUt = "G"; 
				sOd = params.get("SortKey").toString();
			}
			
			if(sUc != null && sGC != null) {
				sUc = java.net.URLEncoder.encode(sUc, java.nio.charset.StandardCharsets.UTF_8.toString());
				sGC = java.net.URLEncoder.encode(sGC, java.nio.charset.StandardCharsets.UTF_8.toString());
				//sDn = java.net.URLEncoder.encode(sDn, java.nio.charset.StandardCharsets.UTF_8.toString());
			}
			
			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			
			String apiData = "{\"uc\":\"" +sUc + "\",\"gc\":\"" + sGC + "\",\"lv\":\"" + sLv + "\",\"dn\":\"" + sDn + "\",\"ut\":\"" + sUt + "\",\"od\":\"" + sOd
					//+ "\",\"group_type\":\"" + sGroup_type + "\",\"company_code\":\"" + sCompany_code
					+ "\",\"job_title_code\":\"" + job_title_code + "\",\"ex_job_title_name\":\"" + ex_job_title_name + "\",\"job_position_code\":\"" + job_position_code
					+ "\",\"ex_job_position_name\":\"" + ex_job_position_name + "\",\"job_level_code\":\"" + job_level_code + "\",\"ex_job_level_name\":\"" + ex_job_level_name
					+ "\",\"phone_number_inter\":\"" + phone_number_inter + "\",\"phone_number\":\"" + phone_number + "\"}";
			byte[] postData = apiData.getBytes("UTF-8");
			
			try {
				URL strurl;
				StringUtil func = new StringUtil();
				String responseMsg = "";
				String RequestDate = func.getCurrentTimeStr();
				int statusCode = 404;
				StringBuffer response = new StringBuffer();
				String jsonText = "";
				
				HttpURLConnection conn = null;
				try {
					strurl = new URL(apiURL);
					conn = (HttpURLConnection) strurl.openConnection();
					conn.setReadTimeout(15000);
					conn.setConnectTimeout(15000);
					conn.setRequestMethod(method);
					conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
					conn.setDoInput(true);
					conn.setDoOutput(true);
					
					if(true){
						try (DataOutputStream wr = new DataOutputStream(conn.getOutputStream());) {
							wr.write(postData);
							int responseCode = conn.getResponseCode();
							
							if (responseCode == 200) { // 정상 호출
								bReturn =1;
								try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));) {
									try (InputStream in = conn.getInputStream(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
							            
							            byte[] buf = new byte[1024 * 8];
							            int length = 0;
							            while ((length = in.read(buf)) != -1) {
							                out.write(buf, 0, length);
							            } 
							
							            jsonText = new String(out.toByteArray(), "UTF-8");
							            CoviMap resultList = CoviMap.fromObject(jsonText);
							            LOGGER.debug("[HttpURLConnect] ["+strurl+"] Return Msg : "+resultList);
							        }
								}
							} else { 
								// 에러 발생
								// 오류 처리 추가 할 것	
								bReturn =0;
								try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));) {
									throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
								}
							}
						}
					}
					
					statusCode = conn.getResponseCode();
				} catch (RuntimeException e) {
					throw new RuntimeException("Failed : HTTP error code (RuntimeException) : " + e.getMessage());
				} catch (Exception e) {
					statusCode = 500;
					responseMsg = e.toString();
					bReturn =0;
					LOGGER.debug("[HttpURLConnect] ["+apiURL+"] Connect Exception : " + e.toString());
				}finally{
					if(conn != null){
						try {
							conn.disconnect();
							conn = null;
						} catch (NullPointerException e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						} catch (Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
					}
					
					if(apiURL.indexOf("sendmessaging") <= 0 || statusCode >= 299){					
						params.put("LogType","URL");
						params.put("Method",method);
						params.put("ConnetURL",apiURL);
						
						params.put("RequestDate", RequestDate);
						params.put("ResultState", Integer.toString(statusCode));
						params.put("RequestBody", "");
						
						if(func.f_NullCheck(responseMsg).equals("")){
							if(statusCode < 299){
								bReturn =1;
								params.put("ResultType", "SUCCESS");
							}else{
								bReturn =0;
								params.put("ResultType", "FAIL");
							}
							params.put("ResponseMsg", response.toString());
						}else{
							bReturn =0;
							params.put("ResultType", "FAIL");
							params.put("ResponseMsg", responseMsg);
						}
						
						params.put("ResponseDate", func.getCurrentTimeStr());
						LoggerHelper.httpLog(params);
					}
					LoggerHelper.httpLog(params);
				}
			} catch (NullPointerException e) {
				bReturn =0;
				LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
			} catch (IOException e) {
				bReturn =0;
				LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
			}
		} catch (NullPointerException e) {
			bReturn =0;
			LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		} catch (Exception e) {
			bReturn =0;
			LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 수정(비밀번호)
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public String resetuserpasswordTS(CoviMap params) throws Exception {
		String sReturn = "";	
		int iReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "password", params.get("Returnpass").toString());
			wrTS = httpClient.streamAdd(wrTS, "","");
			
			iReturn = httpClient.httpClientTSConnect(conTS,wrTS);
			sReturn = Integer.toString(iReturn);
			
		} catch (NullPointerException e){
			sReturn = "0";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}catch(Exception e){
			sReturn = "0";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
	
		return sReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 삭제(계정비활성화)
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteUserSyncdelete(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", "N");
			wrTS = httpClient.streamAdd(wrTS, "","");
		
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);								
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare deleteUserSyncdelete Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}catch(Exception e){
			LOGGER.error("TimeSquare deleteUserSyncdelete Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		} finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 업데이트(비밀번호 제외)
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserSyncupdate(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try{
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId",params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "email",params.get("MailAddress").toString());
			wrTS = httpClient.streamAdd(wrTS, "password",params.get("DecLogonPassword").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName",params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order",params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumberInter",params.get("PhoneNumberInter").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumber",params.get("PhoneNumber").toString());
			wrTS = httpClient.streamAdd(wrTS, "memberOf",params.get("DeptCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobTitleCode",params.get("JobTitleCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobTitleName",params.get("JobTitleName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobPositionCode",params.get("JobPositionCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobPositionName",params.get("JobPositionName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobLevelCode",params.get("JobLevelCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobLevelName",params.get("JobLevelName").toString());
					
	        if (params.get("oldCompanyCode") != null &&!params.getString("CompanyCode").equals(params.getString("oldCompanyCode")))
	        {
	        	wrTS = httpClient.streamAdd(wrTS, "oldTeamName",params.get("oldCompanyCode").toString());
	    		wrTS = httpClient.streamAdd(wrTS, "teamName",params.get("CompanyCode").toString());        	
	        }
	        
	        if (params.get("oldDeptCode") != null && !params.getString("DeptCode").equals(params.getString("oldDeptCode")))
	        {
	        	wrTS = httpClient.streamAdd(wrTS, "oldChannelName",params.get("oldDeptCode").toString());
	    		wrTS = httpClient.streamAdd(wrTS, "channelName",params.get("DeptCode").toString());        	
	        }
			
			if(!params.getString("PhotoPath").equals("")){			
				wrTS = httpClient.streamFileAdd(wrTS,"profileImage",params);			
			}
			
			if(params.get("BySaml").toString().equals("1")) {
				wrTS = httpClient.streamAdd(wrTS, "authType","saml");			
			}		
			
			wrTS = httpClient.streamAdd(wrTS, "","");
		
			bReturn = httpClient.httpClientTSConnect(conTS,wrTS);	
			
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare updateUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}catch(Exception e){
			LOGGER.error("TimeSquare updateUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}finally{
			if(conTS != null){
				conTS.disconnect();
				conTS = null;
			}
			if(wrTS != null) { wrTS.close(); }
		}
		
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 사진 변경
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int setUserPhoto(CoviMap params) throws Exception {
		int bReturn = 0;
		String sMode = "syncimage";
		if(!params.getString("PhotoPath").equals("")) {
			final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);

			if(awsS3.getS3Active(companyCode)){
				String dir = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path;
				String key = dir+"/"+params.getString("UserCode");
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				key = dir+"/"+params.getString("UserCode")+ "_org";
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					String key2 = dir+"/"+params.getString("UserCode") + "_org.jpg";
					awsS3.upload(mFile.getInputStream(), key2, mFile.getContentType(), mFile.getSize());
				}
			}else {
				File dir = new File(FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path);
				if (!dir.exists()) {
					if (dir.mkdirs()) {
						LOGGER.info("path : " + path + " mkdirs()");
					}
				}

				File existFile = new File(dir, params.getString("UserCode"));
				if (existFile.exists()) {
					boolean dReturn =false;
					try{
						dReturn = existFile.delete();
					} catch (NullPointerException e){
						throw new IOException("updateUserPhotoPath : Fail to delete file." + existFile.getName());
					}
					catch(Exception ex){
						throw new IOException("updateUserPhotoPath : Fail to delete file." + existFile.getName());
					}
					dReturn = new File(dir, params.getString("UserCode") + "_org").delete();

					if (!dReturn)
						throw new IOException("updateOrgUserPhotoPath : Fail to delete file." + existFile.getName());
				}

				MultipartFile mFile = (MultipartFile) params.get("FileInfo");
				File file = new File(dir, params.getString("UserCode") + "_org.jpg");
				mFile.transferTo(file);
			}
			
			String username = params.get("LogonID").toString();
			String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path + params.getString("UserCode")  + ".jpg";
			String requestURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			String charset = "UTF-8";
			
			try
			{
				MultipartUtility multipart = new MultipartUtility(requestURL, charset);
				
				multipart.addFormField("username", username);
				if(awsS3.getS3Active(companyCode)){
					AwsS3Data awsS3Data = awsS3.downData(filePath);
					try (InputStream is = awsS3Data.getContentStream();){
						multipart.addFilePart("image", is, awsS3Data.getName());
					}
				}else {
					multipart.addFilePart("image", new File(filePath));
				}
				List<String> response = multipart.finish();	        
				
				for (String line : response) {	            
					//System.out.println(line);
				}
				bReturn = 0;
			} catch (NullPointerException e){
				bReturn = 2;
			}catch(Exception ex)
			{
				bReturn = 2;
			}
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 직급,직위,직책 동기화
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int setUserTypeSyncentcoder(CoviMap params) throws Exception {
		int bReturn = 0;
		String apiURL = null;
		String sMode = "syncentcode?d=";
		String method = "GET";
		
		try {
			String sId = params.get("GroupCode").toString();
			String sType = params.get("GroupType").toString().toUpperCase();
			String sDisplayname = params.get("GroupName").toString();
			String sSortkey = params.get("SortKey").toString();
			String sIsuse = params.get("IsUse").toString();
			
			if(sType.equals("JOBPOSITION")) sType = "P";
			else if(sType.equals("JOBTITLE")) sType = "T";
			else if(sType.equals("JOBLEVEL")) sType = "L";
			
			sId = java.net.URLEncoder.encode(sId, java.nio.charset.StandardCharsets.UTF_8.toString());
			sType = java.net.URLEncoder.encode(sType, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDisplayname = java.net.URLEncoder.encode(sDisplayname, java.nio.charset.StandardCharsets.UTF_8.toString());
			sIsuse = java.net.URLEncoder.encode(sIsuse, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			
			apiURL = apiURL + "{\"id\":\"" + sId + "\",\"type\":\"" + sType + "\",\"display_name\":\"" + sDisplayname + "\",\"sort_key\":\"" + sSortkey + "\",\"is_use\":\"" + sIsuse + "\"}";
			CoviMap jObj = getJson(apiURL, method);
			
			if(!jObj.get("returnCode").toString().equals("0")) { //추가오류
				bReturn = 0;
				LOGGER.error(jObj.toString()); //print error context
			}else {
				bReturn = 1;
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare setUserTypeSyncentcoder Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare setUserTypeSyncentcoder Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}
		return bReturn;
	}

	/**
	 * 사용자 비밀번호 초기화
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public String resetuserpassword(CoviMap params) throws Exception {
		String sNewPassword = null;
		params.put("aeskey", aeskey);
		StringBuffer sTemp = new StringBuffer();
		int mCount = 0;
		
		try {
			if(!RedisDataUtil.getBaseConfig("InitPassword").equals("")) {
				sNewPassword = RedisDataUtil.getBaseConfig("InitPassword");
				
			}else {
				SecureRandom rnd = new SecureRandom();
				for(int i=0; i<10; i++) {
					int iIndex = rnd.nextInt(3);
					switch(iIndex) {
					case 0:
						sTemp.append((char)((int)(rnd.nextInt(26)) + 97));
						break;
					case 1:
						sTemp.append((char)((int)(rnd.nextInt(26)) + 65));
						break;
					case 2:
						sTemp.append(rnd.nextInt(10));
						break;
					default :
						break;
					}
				}
				sNewPassword = sTemp.toString();
				LOGGER.debug("비밀번호 랜덤 생성 : " + sNewPassword);
			}
			
			params.put("sNewPassword", sNewPassword);
			coviMapperOne.update("organization.admin.resetuserpassword", params);			
			
			mCount = coviMapperOne.update("organization.admin.resetuserpassword", params);
			if (mCount == 1) {
				coviMapperOne.update("organization.admin.resetuserpasswordLock", params);
			}
		} catch (NullPointerException e){
			sNewPassword = "FAIL";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		} catch (Exception e) {
			sNewPassword = "FAIL";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}
		return sNewPassword;
	}
	
	/**
	 * 사용자 AD 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserADInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.insertUserADInfo", params);
	}
	/**
	 * 사용자 Exchange 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserExchInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.insertUserExchInfo", params);
	}
	/**
	 * 사용자 MSN 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUserMSNInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.insertUserMSNInfo", params);
	}
	
	/**
	 * 사용자 AD 정보 수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserADInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.updateUserADInfo", params);
	}
	/**
	 * 사용자 Exchange 정보 추가
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserExchInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.updateUserExchInfo", params);
	}
	/**
	 * 사용자 MSN 정보 추가/수정
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserMSNInfo(CoviMap params) throws Exception {
		return coviMapperOne.insert("organization.admin.updateUserMSNInfo", params);
	}
	
	/**
	 * 사용자 정보 가져오기 select (패스워드 포함)
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectUserInfoByAdmin(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectUserInfoByAdmin", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserID,UserCode,LogonID,EmpNo,MultiDisplayName,NickName,MultiAddress,HomePage,PhoneNumber,Mobile,FAX,IPPhone,UseMessengerConnect,SortKey,SecurityLevel,Description,IsUse,IsHR,IsDisplay,EnterDate,RetireDate,PhotoPath,BirthDiv,BirthDate,UseMailConnect,MailAddress,ExternalMailAddress,PhoneNumberInter,Reserved2,Reserved3,Reserved4,ManagerName,Reserved5,CompanyCode,MultiCompanyName,DeptCode,MultiDeptName,RegionCode,MultiRegionName,JobPositionCode,JobTitleCode,JobLevelCode,JobPositionName,JobTitleName,JobLevelName,UseDeputy,DeputyCode,DeputyName,DeputyFromDate,DeputyToDate,AlertConfig,ApprovalUnitCode,ApprovalUnitName,ReceiptUnitCode,ReceiptUnitName,UseApprovalMessageBoxView,UseMobile,AD_DISPLAYNAME,AD_FIRSTNAME,AD_LASTNAME,AD_INITIALS,AD_OFFICE,AD_HOMEPAGE,AD_COUNTRY,AD_COUNTRYID,AD_COUNTRYCODE,AD_STATE,AD_CITY,AD_STREETADDRESS,AD_POSTOFFICEBOX,AD_POSTALCODE,AD_USERACCOUNTCONTROL,AD_ACCOUNTEXPIRES,AD_PHONENUMBER,AD_HOMEPHONE,AD_PAGER,AD_MOBILE,AD_FAX,AD_IPPHONE,AD_INFO,AD_TITLE,AD_DEPARTMENT,AD_COMPANY,AD_MANAGERCODE,EX_PRIMARYMAIL,EX_SECONDARYMAIL,EX_STORAGESERVER,EX_STORAGEGROUP,EX_STORAGESTORE,EX_CUSTOMATTRIBUTE01,EX_CUSTOMATTRIBUTE02,EX_CUSTOMATTRIBUTE03,EX_CUSTOMATTRIBUTE04,EX_CUSTOMATTRIBUTE05,EX_CUSTOMATTRIBUTE06,EX_CUSTOMATTRIBUTE07,EX_CUSTOMATTRIBUTE08,EX_CUSTOMATTRIBUTE09,EX_CUSTOMATTRIBUTE10,EX_CUSTOMATTRIBUTE11,EX_CUSTOMATTRIBUTE12,EX_CUSTOMATTRIBUTE13,EX_CUSTOMATTRIBUTE14,EX_CUSTOMATTRIBUTE15,MSN_POOLSERVERNAME,MSN_POOLSERVERDN,MSN_SIPADDRESS,MSN_ANONMY,MSN_MEETINGPOLICYNAME,MSN_MEETINGPOLICYDN,MSN_PHONECOMMUNICATION,MSN_PBX,MSN_LINEPOLICYNAME,MSN_LINEPOLICYDN,MSN_LINEURI,MSN_LINESERVERURI,MSN_FEDERATION,MSN_REMOTEACCESS,MSN_PUBLICIMCONNECTIVITY,MSN_INTERNALIMCONVERSATION,MSN_FEDERATEDIMCONVERSATION,AD_ISUSE,EX_ISUSE,MSN_ISUSE,LOGONPASSWORD,AD_USERID,EX_USERID,MSN_USERID,AD_CN,AD_SamAccountName,AD_UserPrincipalName"));
		return resultList;
	}
	/**
	 * 사용자 정보 가져오기
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */

	@Override
	public CoviMap selectUserInfoList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectUserInfoList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserID,UserCode,LogonID,EmpNo,MultiDisplayName,NickName,MultiAddress,HomePage,PhoneNumber,Mobile,FAX,IPPhone,UseMessengerConnect,SortKey,SecurityLevel,Description,IsUse,IsHR,IsDisplay,EnterDate,RetireDate,PhotoPath,BirthDiv,BirthDate,UseMailConnect,MailAddress,ExternalMailAddress,PhoneNumberInter,Reserved2,Reserved3,Reserved4,ManagerName,Reserved5,CompanyCode,MultiCompanyName,DeptCode,MultiDeptName,RegionCode,MultiRegionName,JobPositionCode,JobTitleCode,JobLevelCode,JobPositionName,JobTitleName,JobLevelName,UseDeputy,DeputyCode,DeputyName,DeputyFromDate,DeputyToDate,AlertConfig,ApprovalUnitCode,ApprovalUnitName,ReceiptUnitCode,ReceiptUnitName,UseApprovalMessageBoxView,UseMobile,AD_DISPLAYNAME,AD_FIRSTNAME,AD_LASTNAME,AD_INITIALS,AD_OFFICE,AD_HOMEPAGE,AD_COUNTRY,AD_COUNTRYID,AD_COUNTRYCODE,AD_STATE,AD_CITY,AD_STREETADDRESS,AD_POSTOFFICEBOX,AD_POSTALCODE,AD_USERACCOUNTCONTROL,AD_ACCOUNTEXPIRES,AD_PHONENUMBER,AD_HOMEPHONE,AD_PAGER,AD_MOBILE,AD_FAX,AD_IPPHONE,AD_INFO,AD_TITLE,AD_DEPARTMENT,AD_COMPANY,AD_MANAGERCODE,EX_PRIMARYMAIL,EX_SECONDARYMAIL,EX_STORAGESERVER,EX_STORAGEGROUP,EX_STORAGESTORE,EX_CUSTOMATTRIBUTE01,EX_CUSTOMATTRIBUTE02,EX_CUSTOMATTRIBUTE03,EX_CUSTOMATTRIBUTE04,EX_CUSTOMATTRIBUTE05,EX_CUSTOMATTRIBUTE06,EX_CUSTOMATTRIBUTE07,EX_CUSTOMATTRIBUTE08,EX_CUSTOMATTRIBUTE09,EX_CUSTOMATTRIBUTE10,EX_CUSTOMATTRIBUTE11,EX_CUSTOMATTRIBUTE12,EX_CUSTOMATTRIBUTE13,EX_CUSTOMATTRIBUTE14,EX_CUSTOMATTRIBUTE15,MSN_POOLSERVERNAME,MSN_POOLSERVERDN,MSN_SIPADDRESS,MSN_ANONMY,MSN_MEETINGPOLICYNAME,MSN_MEETINGPOLICYDN,MSN_PHONECOMMUNICATION,MSN_PBX,MSN_LINEPOLICYNAME,MSN_LINEPOLICYDN,MSN_LINEURI,MSN_LINESERVERURI,MSN_FEDERATION,MSN_REMOTEACCESS,MSN_PUBLICIMCONNECTIVITY,MSN_INTERNALIMCONVERSATION,MSN_FEDERATEDIMCONVERSATION,AD_ISUSE,EX_ISUSE,MSN_ISUSE,LOGONPASSWORD,AD_USERID,EX_USERID,MSN_USERID,OUPath,OUName,DomainID,AD_CN,AD_SamAccountName,AD_UserPrincipalName"));
		return resultList;
	}
	
	/**
	 * AD 사용자 삭제
	 * @param pUserCode String pUserCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteUser(String pUserCode, String pCompanyCode, String pDeptCode,String pJobPositionCode,String pJobTItleCode, String pJobLevelCode, String retireGRCode, String pRetireOupath, String pCN, String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("retireGRCode",retireGRCode),
				new NameValuePair("pRetireOupath",pRetireOupath),
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteUser", pParam);
		} catch (NullPointerException e){
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
	 * AD 사용자 추가
	 * @param pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pUserPrincipalName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pCN, String pSamAccountName ,String pUserPrincipalName) throws Exception {
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
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pUserPrincipalName",pUserPrincipalName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddUser", pParam);
		} catch (NullPointerException e){
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
	 * AD 사용자 수정
	 * @param String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pUserPrincipalName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyUser(String pUserCode, String pCompanyCode, String pDeptCode,String pOldDeptCode,String pOUPath, String pLogonID, String pEncLogonPW, String pEmpNo,String pDisplayName,String pJobPositionCode, String pJobTItleCode,String pJobLevelCode, String pFirstName, String pLastName, String pUserAccountControl, String pAccountExpires, String pPhoneNumber ,String pMobile, String pFax,String pInfo,String pTitle,String pDepartment,String pCompany,String pMailAddress,String pCN, String pSamAccountName,String pUserPrincipalName) throws Exception {
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
				new NameValuePair("pCN",pCN),
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pUserPrincipalName",pUserPrincipalName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyUser", pParam);
		} catch (NullPointerException e){
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
	 * AD 사용자 비활성화
	 * @param  pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDisableUser(String pUserCode, String pCompanyCode, String pDeptCode, String pJobPositionCode, String pJobTItleCode, String pJobLevelCode,String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DisableUser", pParam);
		} catch (NullPointerException e){
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
	 * AD 사용자 패스워드 변경
	 * @param pUserCode, String pOldPwd, String pNewPwd
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adChangePassword(String pUserCode, String pOldPwd, String pNewPwd) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pOldPwd",pOldPwd),
				new NameValuePair("pNewPwd",pNewPwd)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ChangePassword", pParam);
		} catch (NullPointerException e){
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
	public CoviMap adInitPassword(String pUserCode, String pNewPwd) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","InitPassword", pParam);
		} catch (NullPointerException e){
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
	 * AD 부서 삭제
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteDept(String pDeptCode, String pDeptName, String pCompanyName,String pOUName,String pOUPath) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteDept", pParam);
		} catch (NullPointerException e){
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
	 * AD 부서 추가
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddDept", pParam);
		} catch (NullPointerException e){
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
	 * AD 부서 수정
	 * @param String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyDept(String pDeptCode, String pDeptName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pDeptName",pDeptName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pMemberOf",pMemberOf),
				new NameValuePair("pOUName",pOUName),
				new NameValuePair("pOUPath",pOUPath),
				new NameValuePair("pMailAddress",pMailAddress)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyDept", pParam);
		} catch (NullPointerException e){
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
	 * AD 그룹 추가
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception {
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
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddGroup", pParam);
		} catch (NullPointerException e){
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
	 * AD 그룹 수정
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pMemberOf,String pOUName,String pOUPath,String pMailAddress) throws Exception {
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
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyGroup", pParam);
		} catch (NullPointerException e){
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
	 * AD 그룹 삭제
	 * @param String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteGroup(String pGroupType,String pGroupCode, String pGroupName, String pCompanyName,String pOUPath) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pGroupType",pGroupType),
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pGroupName",pGroupName),
				new NameValuePair("pCompanyName",pCompanyName),
				new NameValuePair("pOUPath",pOUPath)
	        };	
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteGroup", pParam);
		} catch (NullPointerException e){
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
	 * AD 겸직 추가
	 * @param String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddAddJob", pParam);
		} catch (NullPointerException e){
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
	 * AD 겸직 삭제
	 * @param String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adDeleteAddJob(String pUserCode,String pCompanyCode, String pDeptCode, String pJobPositionCode,String pJobTItleCode,String pJobLevelCode,String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode),
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pDeptCode",pDeptCode),
				new NameValuePair("pJobPositionCode",pJobPositionCode),
				new NameValuePair("pJobTItleCode",pJobTItleCode),
				new NameValuePair("pJobLevelCode",pJobLevelCode),
				new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","DeleteAddJob", pParam);
		} catch (NullPointerException e){
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
	 * AD 회사 추가
	 * @param String pCompanyCode, String pCompanyName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adAddCompany(String pCompanyCode, String pCompanyName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pCompanyName",pCompanyName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","AddCompany", pParam);
		} catch (NullPointerException e){
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
	 * AD 회사 수정
	 * @param String pCompanyCode, String pCompanyName
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap adModifyCompany(String pCompanyCode, String pCompanyName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pCompanyCode",pCompanyCode),
				new NameValuePair("pCompanyName",pCompanyName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("AD","ModifyCompany", pParam);
		} catch (NullPointerException e){
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
	 * Exchange 사용자 비활성화
	 * @param String pUserCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchDisableUser(String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","DisableUser", pParam);
		} catch (NullPointerException e){
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
	 * Exchange 사용자 활성화
	 * @param String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchEnableUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode)
				,new NameValuePair("pStorageServer",pStorageServer)
				,new NameValuePair("pStorageGroup",pStorageGroup)
				,new NameValuePair("pStorageStore",pStorageStore)
				,new NameValuePair("pPrimaryMail",pPrimaryMail)
				,new NameValuePair("pSecondaryMails",pSecondaryMails)
				,new NameValuePair("pSipAddress",pSipAddress)
				,new NameValuePair("pCN",pCN)
				,new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","EnableUser", pParam);
		} catch (NullPointerException e){
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
	 * Exchange 사용자 수정
	 * @param String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchModifyUser(String pUserCode, String pStorageServer,String pStorageGroup, String pStorageStore,String pPrimaryMail,String pSecondaryMails,String pSipAddress,String pCN,String pSamAccountName) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pUserCode",pUserCode)
				,new NameValuePair("pStorageServer",pStorageServer)
				,new NameValuePair("pStorageGroup",pStorageGroup)
				,new NameValuePair("pStorageStore",pStorageStore)
				,new NameValuePair("pPrimaryMail",pPrimaryMail)
				,new NameValuePair("pSecondaryMails",pSecondaryMails)
				,new NameValuePair("pSipAddress",pSipAddress)
				,new NameValuePair("pCN",pCN)
				,new NameValuePair("pSamAccountName",pSamAccountName)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","ModifyUser", pParam);
		} catch (NullPointerException e){
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
	 * Exchange 그룹 활성화
	 * @param String pGroupCode, String pPrimaryMail,String pSecondaryMails
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchEnableGroup(String pGroupCode, String pPrimaryMail,String pSecondaryMails) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pGroupCode",pGroupCode),
				new NameValuePair("pPrimaryMail",pPrimaryMail),
				new NameValuePair("pSecondaryMails",pSecondaryMails)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","EnableGroup", pParam);
		} catch (NullPointerException e){
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
	 * Exchange 그룹 비활성화
	 * @param String pGroupCode
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchDisableGroup(String pGroupCode) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pGroupCode",pGroupCode)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","DisableGroup", pParam);
		} catch (NullPointerException e){
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
	 * Exchange Exchange MailBox List
	 * @param 
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap exchSelectExchangeMailBoxList() throws Exception {
		NameValuePair[] pParam = {};
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("EXCH","SelectExchangeMailBoxList", pParam);
		} catch (NullPointerException e){
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
	 * SFB 사용자 활성화
	 * @param String pUserCode, String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap msnEnableUser(String pSamAccountName,String pSipAddress) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pSipAddress",pSipAddress)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("SFB","EnableUser", pParam);
		} catch (NullPointerException e){
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
	 * SFB 사용자 비활성화
	 * @param String pUserCode, String pSipAddress
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap msnDisableUser(String pSamAccountName,String pSipAddress) throws Exception {
		NameValuePair[] pParam = {
				new NameValuePair("pSamAccountName",pSamAccountName),
				new NameValuePair("pSipAddress",pSipAddress)
	        };
		HttpClientUtil httpClient = new HttpClientUtil();
		CoviMap resultList = new CoviMap();
		
		try{
			resultList = httpClient.httpClientOrgConnect("SFB","DisableUser", pParam);
		} catch (NullPointerException e){
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
	 * 비밀번호 정책 확인
	 * @param params - CoviMap
	 * @return json
	 * @throws Exception
	 */
	@Override
	public CoviMap usePWPolicyCheck(CoviMap params) throws Exception {
		CoviList list = null;
		
		int cnt = (int) coviMapperOne.getNumber("organization.admin.updatePasswordPolicyCount", params);
		
		if(cnt > 0 ){
			list = coviMapperOne.list("organization.admin.getPolicy", params);
		}else{
			params.clear();
			params.put("DomainCode", "GENERAL");
			
			list = coviMapperOne.list("organization.admin.getPolicy", params);
		}
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainID,IsUseComplexity,MaxChangeDate,MinimumLength,ChangeNoticeDate"));
		
		return resultList;
	}
	
}
