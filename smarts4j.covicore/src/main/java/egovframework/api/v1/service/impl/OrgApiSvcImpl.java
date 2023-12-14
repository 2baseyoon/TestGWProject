package egovframework.api.v1.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.api.v1.service.OrgApiSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.json.JSONArray;
import egovframework.baseframework.util.json.JSONObject;
import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.coviframework.util.RedisDataUtil;

@Service("orgApiService")
public class OrgApiSvcImpl extends EgovAbstractServiceImpl implements OrgApiSvc {
	
	private Logger LOGGER = LogManager.getLogger(OrgApiSvcImpl.class);
	
	@Autowired
	private OrganizationManageSvc organizationManageSvc;
	
	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int insertGroup(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int result = 0;
		boolean bMail = false;
		
		String strGroupCode = params.getString("GroupCode"); 
		String[] resultString = getGroupEtcInfo(params.getString("CompanyCode"), params.getString("MemberOf")).split("&");
		String strCompanyID = "";
		String strGroupPath = "";
		String strSortPath = "";
		String strOUPath = "";
		if(resultString.length > 0) {
			strCompanyID = resultString[0];
			strGroupPath = resultString[1] + strGroupCode + ";";
			strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(params.getString("SortKey"))) + ";";
			strOUPath = resultString[3] +  params.getString("DisplayName");
		}
		if(RedisDataUtil.getBaseConfig("IsSyncIndi", params.getString("DomainId") ).equals("Y") && params.getString("IsMail").equals("Y")){			
			bMail = true;
		}
		
		

		params.put("ObjectCode", strGroupCode);

		params.put("ObjectType", "GR");

		params.put("ShortName",  params.getString("DisplayName"));
		params.put("MultiShortName",  params.getString("MultiDisplayName"));

		params.put("IsUse", "Y");
		params.put("IsDisplay", "Y");
		
		params.put("IsSync",  params.getString("IsHR"));
		params.put("Description", "");
		
		params.put("CompanyID", strCompanyID);
		params.put("GroupPath", strGroupPath);;
		params.put("OUPath", strOUPath);
		params.put("SortPath", strSortPath);
		params.put("OUName", params.getString("DisplayName"));
		
		/*
		params.put("PrimaryMail", strPrimaryMail)
		params.put("Description", strDescription);
		*/
		
		result =  organizationManageSvc.insertGroup(params) ; 
		
		if(result!=0 && bMail) {	// 그룹메일 추가.		
			setSubSystemGroup("ADD",strGroupCode,params);
		}
		
		
		return result;
	}

	@Override
	public int updateGroup(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int result = 0;

		String strGroupCode = params.getString("GroupCode"); 
		String[] resultString = getGroupEtcInfo(params.getString("CompanyCode"), params.getString("MemberOf")).split("&");
		String strCompanyID = "";
		String strGroupPath = "";
		String strSortPath = "";
		String strOUPath = "";
		if(resultString.length > 0) {
			strCompanyID = resultString[0];
			strGroupPath = resultString[1] + strGroupCode + ";";
			strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(params.getString("SortKey"))) + ";";
			strOUPath = resultString[3] +  params.getString("DisplayName");
		}
		

		params.put("ObjectCode", strGroupCode);

		params.put("ObjectType", "GR");

		params.put("ShortName",  params.getString("DisplayName"));
		params.put("MultiShortName",  params.getString("MultiDisplayName"));

		params.put("IsUse", "Y");
		params.put("IsDisplay", "Y");
		
		params.put("IsSync",  params.getString("IsHR"));
		params.put("Description", "");
		
		params.put("CompanyID", strCompanyID);
		params.put("GroupPath", strGroupPath);;
		params.put("OUPath", strOUPath);
		params.put("SortPath", strSortPath);
		params.put("OUName", params.getString("DisplayName"));
		
		result =  organizationManageSvc.updateGroup(params);
		
		if(result!=0 && RedisDataUtil.getBaseConfig("IsSyncIndi", params.getString("DomainId") ).equals("Y")  ) {
			if(  params.getString("IsMail").equals("Y") && params.getString("oldIsMail").equals("N")) {
				setSubSystemGroup("ADD",strGroupCode,params);
			}else if (  params.getString("IsMail").equals("N")  && params.getString("oldIsMail").equals("Y") ) {
				setSubSystemGroup("DEL",strGroupCode,params);
			}else if (  params.getString("IsMail").equals("Y") ) {
				setSubSystemGroup("MODIFY",strGroupCode,params);
			}
		}
		
		return result;
	}


	@Override
	public int deleteGroup(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int result = 0;
		

		// 부서 메일 사용정보 가져오기
		params.put("gr_code", params.getString("GroupCode"));		
		JSONObject paramInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
		
		String isMail = paramInfo.getString("IsMail") ;
		
		result =  organizationManageSvc.deleteGroup(params);
				
		
		if(result!=0 && isMail.equals("Y") && RedisDataUtil.getBaseConfig("IsSyncIndi", params.getString("DomainId") ).equals("Y") ) {
				
			setSubSystemGroup("DEL",params.getString("GroupCode"), params);
		}
		
		return result;
	}
		 
	
	
	/**
	 * getGroupEtcInfo : 그룹 기타 정보 select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	protected String getGroupEtcInfo(String CompanyCode, String MemberOf) {
		String CompanyID = "";
		String GroupPath = "";
		String SortPath = "";
		String OUPath = "";
		
		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", CompanyCode);
			params.put("MemberOf", MemberOf);
			
			CoviMap returnList = organizationManageSvc.selectGroupEtcInfo(params);
			
			CompanyID = returnList.getJSONArray("list").getJSONObject(0).getString("CompanyID");
			GroupPath = returnList.getJSONArray("list").getJSONObject(0).getString("GroupPath");
			SortPath = returnList.getJSONArray("list").getJSONObject(0).getString("SortPath");
			OUPath = returnList.getJSONArray("list").getJSONObject(0).getString("OUPath");
			
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return CompanyID + "&" + GroupPath + "&" + SortPath + "&" + OUPath;
	}
	
	
	//strModType : ADD / MODIFY / DELETE(indi는 delete 미사용)
	protected CoviMap setSubSystemGroup(String strModType, String strGroupCode, CoviMap param){
		CoviMap returnList = new CoviMap();
		boolean bResultSyncIndiMail =  true;
		
		String strGroupStatus = ""; // 삭제 
		try{
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			

			param.put("MODE", "?job=modifyGroup");
			
			if("ADD".equals(strModType))
			{ 
				param.put("MODE",  "?job=addGroup");
				strGroupStatus = "A";
			}else if("DEL".equals(strModType)) {
				
				 strGroupStatus = "S"; // 삭제 
			} 
			
			param.put("GroupStatus", strGroupStatus);
		
			bResultSyncIndiMail = organizationManageSvc.setIndiMailGroup(param);
			if(!bResultSyncIndiMail)
			{
				returnList.put("result", "fail");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "[MAIL] Raise Error");
				return returnList;
			}
			
		} catch (NullPointerException ex){
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", ex.getMessage());
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex){
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", ex.getMessage());
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		return returnList;
	}

	@Override
	public int insertUser(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int result = 0 ;
		String domainId =  params.getString("DomainID");
		
		params.put("LogonPassword", RedisDataUtil.getBaseConfig("InitPassword", domainId)); // 기초설정값으로 패스워드 설정
		params.put("SecurityLevel", RedisDataUtil.getBaseConfig("DefaultSecurityLevel", domainId));
		
		params.put("UseDeputy","N");
		params.put("AlertConfig", "");
		params.put("UseApprovalPassword","N");
		params.put("ApprovalCode", params.getString("UserCode"));
		params.put("ApprovalFullCode", params.getString("UserCode"));
		params.put("ApprovalFullName", params.getString("DisplayName"));
		
		params.put("LanguageCode","ko");
		params.put("MobileThemeCode", "MobileTheme_Base");
		params.put("TimeZoneCode", "TIMEZO0048");
		params.put("AD_IsUse","N");
		params.put("EX_IsUse","N");
		params.put("MSN_IsUse","N");

		
		result = organizationManageSvc.insertUser(params);
		if(result > 0 &&  params.getString("IsMail").equals("Y") && RedisDataUtil.getBaseConfig("IsSyncIndi", domainId ).equals("Y")  ) {
			params.put("DecLogonPassword",  RedisDataUtil.getBaseConfig("InitPassword", domainId));
			
			setSubSystemUser("ADD", params);
		}
		
		return result;
	}

	@Override
	public int updateUser(CoviMap params, JSONObject oldparams) throws Exception {
		// TODO Auto-generated method stub		
		int result = 0 ;
		String domainId =  params.getString("DomainID");
		
		
		// 기존 사용자정보 삽입
		params.put("Description", oldparams.getString("Description"));
		params.put("NickName", oldparams.getString("NickName"));
		params.put("Address", oldparams.getString("MultiAddress").split(";")[0] );
		params.put("MultiAddress", oldparams.getString("MultiAddress"));
		params.put("HomePage", oldparams.getString("HomePage"));
		params.put("IPPhone", oldparams.getString("IPPhone"));
		

		params.put("SecurityLevel", oldparams.getString("SecurityLevel"));
		
		params.put("CheckUserIP", oldparams.getString("CheckUserIP"));
		params.put("StartIP", oldparams.getString("StartIP"));
		params.put("EndIP", oldparams.getString("EndIP"));
		

		params.put("RegionCode", oldparams.getString("RegionCode"));		
		params.put("ApprovalUnitCode", oldparams.getString("ApprovalUnitCode"));
		params.put("ReceiptUnitCode", oldparams.getString("ReceiptUnitCode"));
		
		
		params.put("LanguageCode",  oldparams.getString("LanguageCode"));
		params.put("MobileThemeCode",  "MobileTheme_Base");
		params.put("TimeZoneCode", "TIMEZO0048");
		
		params.put("Reserved1", oldparams.getString("Reserved1"));
		params.put("Reserved2", oldparams.getString("Reserved2"));
		params.put("Reserved3", oldparams.getString("Reserved3"));
		params.put("Reserved4", oldparams.getString("Reserved4"));
		params.put("Reserved5", oldparams.getString("Reserved5"));
		

		params.put("ApprovalCode", params.getString("UserCode"));
		params.put("ApprovalFullCode", params.getString("UserCode"));
		params.put("ApprovalFullName", params.getString("DisplayName"));
				
		
		
		result = organizationManageSvc.updateUser(params);
		
		if(result > 0  && RedisDataUtil.getBaseConfig("IsSyncIndi", domainId ).equals("Y")  ) {
			String isMailAdd = params.getString("IsMailAdd");
			
			if(isMailAdd.equals("ADD")) {
				JSONObject reObject = organizationManageSvc.getIndiMailUserStatus(params);
				if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) {
					isMailAdd ="MOD";
				}
			}
			
			switch(isMailAdd) {
				case "ADD" :
					params.put("DecLogonPassword",  RedisDataUtil.getBaseConfig("InitPassword", domainId));			
					setSubSystemUser("ADD", params);
					break;
				case "MOD" :
					setSubSystemUser("MOD",params);
					break;
				case "DEL" : 
					params.put("MailAddress", oldparams.getString("MailAddress"));
					setSubSystemUser("DEL",params);
					break;					
				default :
					break;
			}
					
		}
		
		return result;
	}

	@Override
	public int deleteUser(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int result = 0 ;
		
		String isMail = params.getString("IsMail") ;
		
		result = organizationManageSvc.deleteUser(params);
		
		if(result!=0 && isMail.equals("Y") && RedisDataUtil.getBaseConfig("IsSyncIndi", params.getString("DomainId") ).equals("Y") ) {
			
			setSubSystemUser("DEL",params);
		}
		
		return result;
	}
	
	//param : DecLogonPassword, UserCode
	//UserCode
	//oldUserInfo : DeptCode,JobPositionCode,JobTitleCode,JobLevelCode,DeptMailAddress,JobPositionMailAddress,JobTitleMailAddress,JobLevelMailAddress, 
	protected CoviMap setSubSystemUser(String mode, CoviMap param){
		//params
		
		StringBuffer returnMsg = new StringBuffer();
		CoviMap returnList = new CoviMap();
		CoviMap reObject = new CoviMap();
		CoviMap mapTemp = new CoviMap();
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////
		try{
			returnList.put("result", "OK");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			String  strDecLogonPassword = param.getString("DecLogonPassword");	
			//조직도 연동 API에서 비밀번호 변경은 불가!!

			mapTemp.put("MailAddress", param.getString("MailAddress"));
			mapTemp.put("CompanyCode", param.getString("CompanyCode"));
			
			
			if(mode.equals("ADD")) {  // 신규
				mapTemp.put("MODE", "ADD");
				mapTemp.put("DisplayName", param.getString("DisplayName"));
				mapTemp.put("GroupName", "");
				mapTemp.put("LanguageCode", param.getString("LanguageCode"));
				mapTemp.put("TimeZoneCode", param.getString("TimeZoneCode"));
				mapTemp.put("GroupMailAddress", param.getString("DeptMail"));// 부서메일
				mapTemp.put("oldGroupMailAddress", "");
				mapTemp.put("mailStatus", "A");
				mapTemp.put("DecLogonPassword",strDecLogonPassword);
				
				reObject = organizationManageSvc.setIndiMailUser(mapTemp);
				if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
				
				
				mapTemp.put("MODE", "MODIFY");
				if( !param.get("JobPositionMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobPositionMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				
				if( !param.get("JobTitleMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobTitleMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				
				if( !param.get("JobLevelMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobLevelMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				
				
			} else if(mode.equals("DEL")) { 
				mapTemp.put("MODE", "DEL");
				mapTemp.put("DisplayName", "");
				mapTemp.put("GroupName", "");
				mapTemp.put("LanguageCode", "");
				mapTemp.put("TimeZoneCode", "");
				mapTemp.put("GroupMailAddress", "");
				mapTemp.put("oldGroupMailAddress", "");
				mapTemp.put("mailStatus", "S");
				
				
				reObject = organizationManageSvc.setIndiMailUser(mapTemp);
				if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
				
			} else {				
				mapTemp.put("MODE", "MODIFY");
				mapTemp.put("DisplayName", param.getString("DisplayName"));
				mapTemp.put("GroupName", "");
				mapTemp.put("LanguageCode", param.getString("LanguageCode"));
				mapTemp.put("TimeZoneCode", param.getString("TimeZoneCode"));
				mapTemp.put("GroupMailAddress", param.getString("DeptMail"));// 부서메일
				mapTemp.put("oldGroupMailAddress", param.getString("oldDeptMail"));
				mapTemp.put("mailStatus", "A");
				
				reObject = organizationManageSvc.setIndiMailUser(mapTemp);
				if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
				
				if( !param.get("JobPositionMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobPositionMail"));
					mapTemp.put("oldGroupMailAddress", param.getString("oldJobPositionMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				if( !param.get("JobTitleMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobTitleMail"));
					mapTemp.put("oldGroupMailAddress", param.getString("oldJobTitleMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				
				if( !param.get("JobLevelMail").equals("") ) {
					mapTemp.put("GroupMailAddress", param.getString("JobLevelMail"));
					mapTemp.put("oldGroupMailAddress", param.getString("oldJobLevelMail"));
					reObject = organizationManageSvc.setIndiMailUser(mapTemp);
					if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
					
				}
				
				
			}
			
						
		
					
		} catch (NullPointerException ex){
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", ex.getMessage());
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		catch(Exception ex)
		{
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", ex.getMessage());
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		finally{
			returnList.put("returnMsg", returnMsg);
		}
		return returnList;
	}
	
	@Override
	public CoviMap selectJobList(CoviMap params) throws Exception {
		// 직함 리스트 조회
		CoviMap resultList = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectGroupListByGroupTypeCnt", params);
			if(cnt > 0) {
				list = coviMapperOne.list("organization.conf.manage.selectGroupListByGroupType", params);
				resultList.put("list", CoviSelectSet.coviSelectJSON(list));
				resultList.put("status", Return.SUCCESS);
			}else {
				resultList.put("status", Return.FAIL);
				resultList.put("message", "NOT_FOUND_DATA");
			}			
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}


	@Override
	public CoviMap selectUserList(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			int cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectUserListCnt", params);
			if(cnt > 0) {
				list = coviMapperOne.list("organization.syncmanage.selectUserList", params);
				//coviSelectJSON(list, "USERCODE")
				JSONArray  listArray =  CoviSelectSet.coviSelectJSONObject(list, "UserCode") ;
				String[] strUserCode = new String[cnt]; 
				 
				for (int i=0 ; i < cnt ; i++ ) {
					JSONObject jObj = listArray.getJSONObject(i);
					strUserCode[i] = jObj.getString("UserCode");
				}
				
				params.put("TargetID", strUserCode );
				
				list = coviMapperOne.list("organization.syncmanage.selectUserInfoListOrderby", params);
				
				resultList.put("status", Return.SUCCESS);
				resultList.put("list", CoviSelectSet.coviSelectJSON(list));
			}else {
				resultList.put("status", Return.FAIL);
				resultList.put("message", "NOT_FOUND_DATA");
			}			
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	
	
	@Override
	public CoviMap selectUserView(CoviMap params) throws Exception {
		CoviMap  resultList= new CoviMap();
		try {
			resultList= coviMapperOne.select("organization.syncmanage.selectUserInfo", params);
			resultList.put("status", Return.SUCCESS);
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}			
		return resultList;
	}

	@Override
	public CoviMap selectDeptList(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap  resultList= new CoviMap();
		CoviList list = new CoviList();
		try {
			resultList = new CoviMap();
			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllDeptListCnt", params);
			if(cnt> 0) {
				list = coviMapperOne.list("organization.conf.manage.selectAllDeptList", params);
				
				resultList.put("status", Return.SUCCESS);
				resultList.put("list", list);
				resultList.put("count", cnt);
								
			} else {
				resultList.put("status", Return.FAIL);
				resultList.put("message", "NOT_FOUND_DATA");
			}
			
			
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}			
		return resultList;
	}

		
}
