package egovframework.api.v1.web;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.api.v1.service.OrgApiSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.json.JSONObject;
import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.core.sevice.LicenseSvc;
import egovframework.core.sevice.SysAclSvc;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;

@Controller
@RequestMapping(value = "api/v1")
public class OrgApiCon {
	@Autowired
	private OrgApiSvc orgApiSvc;
	
	@Autowired
	private OrganizationManageSvc organizationManageSvc;

	@Autowired
	private LicenseSvc licenseSvc;
	
	@Autowired
	private SysAclSvc sysAclSvc;
	
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	String syncManage = "API";

	
	/**
	 * 직함 (직위, 직급, 직책) 추가 API
	 */
	@RequestMapping(value = "/org/job/add.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap addJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			//중복체크  #{GroupCode}						
			
			
			if(checkDuplicationGroupCode(params.getString("GroupCode"))) {
				throw new Exception("사용중인 jobcode입니다.");
			}
			

			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			String memberOf =  domainID + "_"+ params.getString("GroupType") ;
			
			//중복체크  #{MailAddress}
			if(paramMap.get("IsMail").equals("Y")) {
				params.put("Code",  params.get("GroupCode"));
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("사용중인 메일주소입니다.");
				}
				
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
			}
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "INSERT");
			params.put("MemberOf",  memberOf);	
			params.put("DomainId", domainID);
			
					
			result = orgApiSvc.insertGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 직함 (직위, 직급, 직책) 수정 API
	 */
	@RequestMapping(value = "/org/job/modify.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap modifyJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			
			//코드 여부 체크  #{GroupCode}		
			if(!checkDuplicationGroupCode(params.getString("GroupCode"))) {
				throw new Exception("해당 jobcode가 없습니다.");
			}
			

			// 부서  사용정보 가져오기
			params.put("gr_code", params.getString("GroupCode"));		
			JSONObject paramInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
			if( !params.getString("GroupType").equals( paramInfo.getString("GroupType"))||  !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("jobtype에 해당 jobcode가 없습니다.");
			}
			
			String oldIsMail = paramInfo.getString("IsMail");
			//중복체크  #{MailAddress} // 고민 필요  ( 미사용에서 사용으로 바꿀시) 
			if(paramMap.get("IsMail").equals("Y") && oldIsMail.equals("N")) {
				params.put("Code",  paramMap.get("GroupCode"));
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("메일주소가 중복됩니다.");
				}
				
			}
			params.put("oldIsMail",  oldIsMail);
			

			String domainID = sysAclSvc.getDomainID(paramMap.get("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			String memberOf =  domainID + "_"+ paramMap.get("GroupType") ;
			
			if(!params.has("MailAddress")) {
				params.put("MailAddress",   paramInfo.getString("PrimaryMail"));
				params.put("PrimaryMail",   paramInfo.getString("PrimaryMail"));
				
			}else {
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
			}
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "UPDATE");
			params.put("MemberOf",  memberOf);	
			params.put("DomainId", domainID);
			
					
			result = orgApiSvc.updateGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 직함 (직위, 직급, 직책) 삭제 API
	 */
	@RequestMapping(value = "/org/job/delete.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			
			//코드 여부 체크  #{GroupCode}		
			if(!checkDuplicationGroupCode(params.getString("GroupCode"))) {
				throw new Exception("해당 jobcode가 없습니다.");
			}
			
			// 부서  사용정보 가져오기
			params.put("gr_code", params.getString("GroupCode"));		
			JSONObject paramInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
			if( !params.getString("GroupType").equals( paramInfo.getString("GroupType")) ||  !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("jobtype에 해당 jobcode가 없습니다.");
			}
			
			
			//직무 사용 멤버 체크
			if( organizationManageSvc.selectHasGroupMember(params) > 0 ) {
				throw new Exception("해당 코드에 소속된 사용자가 존재합니다.");
			}
			
			
			String isMail = paramInfo.getString("IsMail") ;
			params.put("IsMail", paramInfo.getString("IsMail"));	
			
			if(isMail.equals("Y")) {		
				params.put("PrimaryMail", paramInfo.getString("PrimaryMail"));
				params.put("DisplayName", paramInfo.getString("DisplayName"));
				params.put("MemberOf", paramInfo.getString("MemberOf"));			
			}		
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "DELETE");
			params.put("ObjectCode",  params.getString("GroupCode"));	
			
					
			result = orgApiSvc.deleteGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	
	/**
	 * 부서 추가 API
	 */
	@RequestMapping(value = "/org/dept/add.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap addDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			//중복체크  #{GroupCode}						
			String strGroupCode = params.getString("GroupCode");
			
			if(checkDuplicationGroupCode(strGroupCode)) {
				throw new Exception("사용중인 부서코드입니다.");
			}
			
			if(!checkDuplicationGroupCode(params.getString("MemberOf"))) {
				throw new Exception("존재하지 않는 상위부서코드입니다.");
			}
			

			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			//중복체크  #{MailAddress}
			if(paramMap.get("IsMail").equals("Y")) {
				params.put("Code", strGroupCode);
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("사용중인 메일주소입니다.");
				}
				
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
			}
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "INSERT");
			params.put("DomainId", domainID);
			
			params.put("ReceiptUnitCode", strGroupCode);
			params.put("ApprovalUnitCode", strGroupCode);
			params.put("Receivable", "1");
			params.put("Approvable", "1");
					
			result = orgApiSvc.insertGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 부서 수정 API
	 */
	@RequestMapping(value = "/org/dept/modify.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap modifyDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			String strGroupCode = params.getString("GroupCode");
			
			//코드 여부 체크  #{GroupCode}		
			if(!checkDuplicationGroupCode(strGroupCode)) {
				throw new Exception("해당 부서코드 가 없습니다.");
			}
			
			// 부서  사용정보 가져오기
			params.put("gr_code",strGroupCode);		
			JSONObject paramInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
			if( !params.getString("GroupType").equals( paramInfo.getString("GroupType")) || !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("해당 부서코드가 없습니다.");
			}			

			if(!checkDuplicationGroupCode(params.getString("MemberOf"))) {
				throw new Exception("존재하지 않는 상위부서코드입니다.");
			}

			
			String oldIsMail = paramInfo.getString("IsMail");
			//중복체크  #{MailAddress} // 고민 필요  ( 미사용에서 사용으로 바꿀시) 
			if(paramMap.get("IsMail").equals("Y") && oldIsMail.equals("N")) {
				params.put("Code", strGroupCode);
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("메일주소가 중복됩니다.");
				}
				
			}
			params.put("oldIsMail",  oldIsMail);
			

			String domainID = sysAclSvc.getDomainID(paramMap.get("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			if(!params.has("MailAddress")) {
				params.put("MailAddress",   paramInfo.getString("PrimaryMail"));
				params.put("PrimaryMail",   paramInfo.getString("PrimaryMail"));
				
			}else {
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
			}
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "UPDATE");
			params.put("DomainId", domainID);

			params.put("ReceiptUnitCode", strGroupCode);
			params.put("ApprovalUnitCode", strGroupCode);
			params.put("Receivable", "1");
			params.put("Approvable", "1");
			
					
			result = orgApiSvc.updateGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 부서 삭제 API
	 */
	@RequestMapping(value = "/org/dept/delete.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			
			//코드 여부 체크  #{GroupCode}		
			if(!checkDuplicationGroupCode(params.getString("GroupCode"))) {
				throw new Exception("해당 부서코드 가 없습니다.");
			}
						
			// 부서  사용정보 가져오기
			params.put("gr_code", params.getString("GroupCode"));		
			JSONObject paramInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
			if( !params.getString("GroupType").equals( paramInfo.getString("GroupType")) || !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("해당 부서코드 가 없습니다.");
			}
			
			
			
			//직무 사용 멤버 체크
			if( organizationManageSvc.selectHasGroupMember(params) > 0 ) {
				throw new Exception("해당 부서에 소속된 사용자가 존재합니다.");
			}
			
			
			String isMail = paramInfo.getString("IsMail") ;
			params.put("IsMail", paramInfo.getString("IsMail"));	
			
			if(isMail.equals("Y")) {		
				params.put("PrimaryMail", paramInfo.getString("PrimaryMail"));
				params.put("DisplayName", paramInfo.getString("DisplayName"));
				params.put("MemberOf", paramInfo.getString("MemberOf"));			
			}		
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "DELETE");
			params.put("ObjectCode",  params.getString("GroupCode"));	
			
					
			result = orgApiSvc.deleteGroup(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	
	/**
	 * 사용자 추가 API
	 */
	@RequestMapping(value = "/org/user/add.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap addUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			
			//중복 여부 체크  usercode, empno, sabun
			if(checkDuplicationUser(params.getString("UserCode"), "UserCode")) {
				throw new Exception("사용중인 usercode 입니다.");
			}
			if(checkDuplicationUser(params.getString("EmpNo"), "UserEmpNo")) {
				throw new Exception("사용중인 empno 입니다.");
			}
			if(checkDuplicationUser(params.getString("LogonID"), "LogonID")) {
				throw new Exception("사용중인 logonid 입니다.");
			}
			
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			params.put("DomainID", domainID);
			
			//중복체크  #{MailAddress}
			if(paramMap.get("IsMail").equals("Y")) {
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
				
				params.put("Code",  params.get("UserCode"));
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("사용중인 메일주소입니다.");
				}
				
			}
			

			// 부서  사용정보 가져오기
			if( checkDuplicationGroupCode(params.getString("DeptCode")) ) {
				params.put("gr_code", params.getString("DeptCode"));	
				JSONObject deptInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
				if( !"Dept".equals( deptInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( deptInfo.getString("CompanyCode").toLowerCase())) {
					throw new Exception("deptcode가 없습니다.");
				} else if ("Y".equals( deptInfo.getString("IsMail")) && !"".equals(deptInfo.getString("PrimaryMail"))) {
					params.put("DeptMail", deptInfo.getString("PrimaryMail"));	
				}
			}else {
				throw new Exception("deptcode가 없습니다.");
			}
			
			//직위, 직책 , 직급
			if(!"".equals(params.getString("JobPositionCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobPositionCode")) ) {
					params.put("gr_code", params.getString("JobPositionCode"));	
					JSONObject jpInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
					if( !"JobPosition".equals( jpInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jpInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobpositioncode가 없습니다.");
					} else if ("Y".equals( jpInfo.getString("IsMail")) && !"".equals(jpInfo.getString("PrimaryMail"))) {
						params.put("JobPositionMail", jpInfo.getString("PrimaryMail"));	
					}
				} else {
					throw new Exception("jobpositioncode가 없습니다.");
				}
			}
			
			if(!"".equals(params.getString("JobTitleCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobTitleCode")) ) {
					params.put("gr_code", params.getString("JobTitleCode"));
					
					JSONObject jtInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
					if( !"JobTitle".equals( jtInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jtInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobtitlecode가 없습니다.");
					} else if ("Y".equals( jtInfo.getString("IsMail")) && !"".equals(jtInfo.getString("PrimaryMail"))) {
						params.put("JobTitleMail", jtInfo.getString("PrimaryMail"));	
					}
					
				} else {
					throw new Exception("jobtitlecode가 없습니다.");
				}
			}
			
			if(!"".equals(params.getString("JobLevelCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobLevelCode")) ) {
					params.put("gr_code", params.getString("JobLevelCode"));		
					JSONObject jlInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
					if( !"JobLevel".equals( jlInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jlInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobpositioncode가 없습니다.");
					} else if ("Y".equals( jlInfo.getString("IsMail")) && !"".equals(jlInfo.getString("PrimaryMail"))) {
						params.put("JobLevelMail", jlInfo.getString("PrimaryMail"));	
					}
				} else {
					throw new Exception("jobpositioncode가 없습니다.");
				}
			}
			
			params.put("licSeq", params.getString("LicSeq"));	
			CoviMap licMap =  licenseSvc.getLicenseManageInfo(params);
			String sModule = "" ;
			if(licMap == null ) {
				throw new Exception("라이선스가 잘못되었습니다.");
			}
			
			if( licMap.getString("IsOpt").equals("Y") || licMap.getString("IsUse").equals("N")) {
				throw new Exception("라이선스가 잘못되었습니다.");
			}
			
			if (licMap.get("LicModule") != null){
				sModule = PropertiesUtil.getDecryptedProperty(licMap.getString("LicModule"));
			}
			if(sModule.indexOf("Mail") < 0  && paramMap.get("IsMail").equals("Y") ) {
				throw new Exception("메일을 사용할 수 없는 라이선스입니다.");
			}
						
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "INSERT");
			params.put("JobType", "Origin");
			params.put("ObjectCode",  params.getString("UserCode"));	
			
					
			result = orgApiSvc.insertUser(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 사용자 수정 API
	 */
	@RequestMapping(value = "/org/user/modify.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap modifyUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		CoviMap grParam = new CoviMap();
		
		int result = 0 ;
		
		try	{
			
			//중복 여부 체크  usercode, empno, sabun
			if(!checkDuplicationUser(params.getString("UserCode"), "UserCode")) {
				throw new Exception("해당 usercode가 없습니다.");
			}
			
			// 사용자 정보 가져오기
			JSONObject paramInfo =  orgApiSvc.selectUserView(params);
			if(  !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("회사에 해당 usercode가 없습니다.");
			}
			
			if(!paramInfo.getString("EmpNo").equals(params.getString("EmpNo"))) {
				if(checkDuplicationUser(params.getString("EmpNo"), "UserEmpNo")) {
					throw new Exception("사용중인 empno 입니다.");
				}
			}
			
			if(!paramInfo.getString("LogonID").equals(params.getString("LogonID"))) {
				if(checkDuplicationUser(params.getString("LogonID"), "LogonID")) {
					throw new Exception("사용중인 logonid 입니다.");
				}
			}
			
			String domainID = paramInfo.getString("DomainID");
			params.put("DomainID", domainID);
			
			//중복체크  #{MailAddress}
			String IsMailAdd = "N";
			
			if( (paramMap.get("IsMail").equals("Y") && paramInfo.get("UseMailConnect").equals("N")) ||
					(paramMap.get("IsMail").equals("Y") && !paramMap.get("MailAddress").equals(paramInfo.get("MailAddress")) )) {
				IsMailAdd = "ADD";
				if( !isMailUse(domainID, params.getString("MailAddress") )) {
					throw new Exception("사용할수 없는 메일주소입니다.");
				}
				
				params.put("Code",  params.get("UserCode"));
				CoviList mailListDuplication =  organizationManageSvc.selectIsDuplicateMail(params).getJSONArray("list") ;
				if(Integer.parseInt(mailListDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
					throw new Exception("사용중인 메일주소입니다.");
				}
				
			} else if( paramMap.get("IsMail").equals("N") && paramInfo.get("UseMailConnect").equals("Y")) {
				IsMailAdd = "DEL";
			} else if(paramMap.get("IsMail").equals("Y")) {
				IsMailAdd = "MOD";
			}
			
			params.put("IsMailAdd", IsMailAdd);
			

			// 부서 메일  사용정보 가져오기
			if( checkDuplicationGroupCode(params.getString("DeptCode")) ) {
				grParam.put("gr_code", params.getString("DeptCode"));	
				JSONObject deptInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
				if( !"Dept".equals( deptInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( deptInfo.getString("CompanyCode").toLowerCase())) {
					throw new Exception("deptcode가 없습니다.");
				} else if ("Y".equals( deptInfo.getString("IsMail")) && !"".equals(deptInfo.getString("PrimaryMail"))) {
					params.put("DeptMail", deptInfo.getString("PrimaryMail"));	
				}
			}else {
				throw new Exception("deptcode가 없습니다.");
			}
			
			if(!paramInfo.getString("DeptCode").equals(params.getString("DeptCode")) && IsMailAdd.equals("MOD") ) {
				grParam.put("gr_code", paramInfo.getString("DeptCode"));	
				JSONObject oldDeptInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
				if ("Y".equals( oldDeptInfo.getString("IsMail")) && !"".equals(oldDeptInfo.getString("PrimaryMail"))) {
					params.put("oldDeptMail", oldDeptInfo.getString("PrimaryMail"));	
				}
			}
			
			
			
			//직위 메일 사용정보 
			if(!"".equals(params.getString("JobPositionCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobPositionCode")) ) {
					grParam.put("gr_code", params.getString("JobPositionCode"));	
					JSONObject jpInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if( !"JobPosition".equals( jpInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jpInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobpositioncode가 없습니다.");
					} else if ("Y".equals( jpInfo.getString("IsMail")) && !"".equals(jpInfo.getString("PrimaryMail"))) {
						params.put("JobPositionMail", jpInfo.getString("PrimaryMail"));	
					}
				} else {
					throw new Exception("jobpositioncode가 없습니다.");
				}
				
				
			} 
			
			if (!"".equals(paramInfo.getString("JobPositionCode")) && IsMailAdd.equals("MOD")) {
				if(!paramInfo.getString("JobPositionCode").equals(params.getString("JobPositionCode"))) {
					grParam.put("gr_code", paramInfo.getString("JobPositionCode"));	
					JSONObject oldJpInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if ("Y".equals( oldJpInfo.getString("IsMail")) && !"".equals(oldJpInfo.getString("PrimaryMail"))) {
						params.put("oldJobPositionMail", oldJpInfo.getString("PrimaryMail"));	
					}
				}
			}
			
			//직책 메일 사용정보
			if(!"".equals(params.getString("JobTitleCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobTitleCode")) ) {
					grParam.put("gr_code", params.getString("JobTitleCode"));
					
					JSONObject jtInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if( !"JobTitle".equals( jtInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jtInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobtitlecode가 없습니다.");
					} else if ("Y".equals( jtInfo.getString("IsMail")) && !"".equals(jtInfo.getString("PrimaryMail"))) {
						params.put("JobTitleMail", jtInfo.getString("PrimaryMail"));	
					}
					
				} else {
					throw new Exception("jobtitlecode가 없습니다.");
				}
			} 
			
			if (!"".equals(paramInfo.getString("JobTitleCode")) && IsMailAdd.equals("MOD")) {
				if(!paramInfo.getString("JobTitleCode").equals(params.getString("JobTitleCode"))) {
					grParam.put("gr_code", paramInfo.getString("JobTitleCode"));	
					JSONObject oldJtInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if ("Y".equals( oldJtInfo.getString("IsMail")) && !"".equals(oldJtInfo.getString("PrimaryMail"))) {
						params.put("oldJobTitleMail", oldJtInfo.getString("PrimaryMail"));	
					}
				} 
			}
			
			//직급 메일 사용정보
			if(!"".equals(params.getString("JobLevelCode"))) {
				if( checkDuplicationGroupCode(params.getString("JobLevelCode")) ) {
					grParam.put("gr_code", params.getString("JobLevelCode"));		
					JSONObject jlInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if( !"JobLevel".equals( jlInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( jlInfo.getString("CompanyCode").toLowerCase())) {
						throw new Exception("jobpositioncode가 없습니다.");
					} else if ("Y".equals( jlInfo.getString("IsMail")) && !"".equals(jlInfo.getString("PrimaryMail"))) {
						params.put("JobLevelMail", jlInfo.getString("PrimaryMail"));	
					}
				} else {
					throw new Exception("jobpositioncode가 없습니다.");
				}
			} 
			
			if (!"".equals(paramInfo.getString("JobLevelCode")) && IsMailAdd.equals("MOD")) {
				if(!paramInfo.getString("JobLevelCode").equals(params.getString("JobLevelCode"))) {
					grParam.put("gr_code", paramInfo.getString("JobLevelCode"));	
					JSONObject oldJlInfo =  organizationManageSvc.selectDeptInfo(grParam).getJSONArray("list").getJSONObject(0);
					if ("Y".equals( oldJlInfo.getString("IsMail")) && !"".equals(oldJlInfo.getString("PrimaryMail"))) {
						params.put("oldJobLevelMail", oldJlInfo.getString("PrimaryMail"));	
					}
				}
			}
			
			params.put("licSeq", params.getString("LicSeq"));	
			
			
			CoviMap licMap =  licenseSvc.getLicenseManageInfo(params);
			String sModule = "" ;
			if(licMap == null ) {
				throw new Exception("라이선스가 잘못되었습니다.");
			}
			
			if( licMap.getString("IsOpt").equals("Y") || licMap.getString("IsUse").equals("N")) {
				throw new Exception("라이선스가 잘못되었습니다.");
			}
			
			if (licMap.get("LicModule") != null){
				sModule = PropertiesUtil.getDecryptedProperty(licMap.getString("LicModule"));
			}
			if(sModule.indexOf("Mail") < 0  && paramMap.get("IsMail").equals("Y") ) {
				throw new Exception("메일을 사용할 수 없는 라이선스입니다.");
			}
					
			
			
			
			params.put("SyncManage", syncManage);
			params.put("SyncType", "UPDATE");
			params.put("JobType", "Origin");
			params.put("ObjectCode",  params.getString("UserCode"));	
			
					
			result = orgApiSvc.updateUser(params, paramInfo);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 사용자 삭제 API
	 */
	@RequestMapping(value = "/org/user/delete.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		int result = 0 ;
		
		try	{
			
			//중복 여부 체크  usercode, empno, sabun
			if(!checkDuplicationUser(params.getString("UserCode"), "UserCode")) {
				throw new Exception("해당 usercode가 없습니다.");
			}
			
			// 사용자 정보 가져오기
			JSONObject paramInfo =  orgApiSvc.selectUserView(params);
			if(  !params.getString("CompanyCode").toLowerCase().equals( paramInfo.getString("CompanyCode").toLowerCase())) {
				throw new Exception("회사에 해당 usercode가 없습니다.");
			}
			
			
			String isMail = paramInfo.getString("UseMailConnect") ;
			params.put("IsMail", isMail);	
			
			if(isMail.equals("Y")) {		
				params.put("MailAddress", paramInfo.getString("MailAddress"));
			}		
			
			
			params.put("DeptCode", paramInfo.getString("DeptCode"));
			params.put("SyncManage", syncManage);
			params.put("SyncType", "DELETE");
			params.put("ObjectCode",  params.getString("UserCode"));
					
			result = orgApiSvc.deleteUser(params);
			
			if (result > 0) {
				returnMap.put("status", Return.SUCCESS);
				returnMap.put("message", Return.SUCCESS);
			} else {
				// 500 응답
				throw new Exception(params.optString("ErrorMessage"));
			}
		} catch (NullPointerException npE) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 직함 (직위, 직급, 직책) 리스트 API
	 */
	
	@RequestMapping(value = "/org/user/list.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap listUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			// 부서  사용정보 가져오기
			//if( checkDuplicationGroupCode(params.getString("DeptCode")) ) {
			//	params.put("gr_code", params.getString("DeptCode"));	
			//	JSONObject deptInfo =  organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0);
			//	if( !"Dept".equals( deptInfo.getString("GroupType")) &&  !params.getString("CompanyCode").toLowerCase().equals( deptInfo.getString("CompanyCode").toLowerCase())) {
			//		throw new Exception("deptcode가 없습니다.");
			//	}
			//}else {
			//	throw new Exception("deptcode가 없습니다.");
			//}
			
			params.put("lang", "ko");
			//params.put("deptCode", params.getString("DeptCode"));
			params.put("companyCode", params.getString("CompanyCode"));
			
			returnMap = orgApiSvc.selectUserList(params);
			
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 사용자 상세보기 API
	 */
	
	@RequestMapping(value = "/org/user/view.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap viewUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			//상세보기로 변경
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			returnMap = orgApiSvc.selectUserView(params);
			
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}

	protected boolean isMailUse(String domainId, String mailAddress ) throws Exception {
		boolean bReturn = false;
		
		String regex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
	    Pattern pattern = Pattern.compile(regex);
	    Matcher matcher = pattern.matcher(mailAddress);
	    
	    if(!matcher.matches() )
	      return false;
				
		String mailDomain = mailAddress.split("@")[1] ;
	    
		CoviList mailDomainAry = RedisDataUtil.getBaseCode("MailDomain", domainId);
		
		for (int i=0; i<mailDomainAry.size(); i++) {
			if(mailDomainAry.getJSONObject(i).getString("CodeName").equals(mailDomain) ) {
				bReturn = true;
				break;
			}
		}			
		
		return bReturn;
	}
	
	//사용자 중복여부 체크
	protected boolean checkDuplicationUser(String code, String type) throws Exception  {
		CoviMap params = new CoviMap();
		
		params.put("Type", type);
  		params.put("Code", code);
				
		//코드 여부 체크  #{GroupCode}		
		CoviList listDuplication = organizationManageSvc.selectIsDuplicateUserInfo(params).getJSONArray("list");
		if(Integer.parseInt(listDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
			return true;
		}
		
		
		return false;
	}
	
	//group 중복여부 체크
	protected boolean checkDuplicationGroupCode(String code) throws Exception  {
		CoviMap params = new CoviMap();
		
  		params.put("GroupCode", code);
				
		//코드 여부 체크  #{GroupCode}		
		CoviList listDuplication = organizationManageSvc.selectIsDuplicateGroupCode(params).getJSONArray("list");
		if(Integer.parseInt(listDuplication.getJSONObject(0).getString("isDuplicate")) > 0) {
			return true;
		}
		
		
		return false;
	}
	
	/**
	 * 직함 (직위, 직급, 직책) 리스트 API
	 */
	
	@RequestMapping(value = "/org/job/list.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap listJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			params.put("domainId", domainID);
			returnMap = orgApiSvc.selectJobList(params);
			
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 직함 (직위, 직급, 직책) 상세보기 API
	 */
	
	@RequestMapping(value = "/org/job/view.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap viewJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));			
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			params.put("gr_code", params.getString("GroupCode"));		
			returnMap = (CoviMap) organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0); 
			
			if( !params.getString("GroupType").equals( returnMap.getString("GroupType")) || !params.getString("CompanyCode").toLowerCase().equals( returnMap.getString("CompanyCode").toLowerCase())) {
				throw new Exception("jobtype에 해당 jobcode가 없습니다.");
			}
			
			returnMap.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 부서 상세보기 API
	 */
	@RequestMapping(value = "/org/dept/view.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap viewDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));			
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			
			params.put("gr_code", params.getString("GroupCode"));	
			returnMap = (CoviMap) organizationManageSvc.selectDeptInfo(params).getJSONArray("list").getJSONObject(0); 
			//JSONObject paramInfo = returnMap.getJSONArray("list").getJSONObject(0);
			if( !params.getString("GroupType").equals( returnMap.getString("GroupType")) || !params.getString("CompanyCode").toLowerCase().equals( returnMap.getString("CompanyCode").toLowerCase())) {
				throw new Exception("해당하는 부서코드가 없습니다.");
			}
			String ManagerCode = returnMap.getString("ManagerCode");
			//매니지코드가 있다면
			if(ManagerCode != null && !"".equals(ManagerCode)) {
				// 사용자 정보 가져오기
				CoviMap userParam = new CoviMap();
				userParam.put("UserCode", ManagerCode);
				JSONObject userInfo = orgApiSvc.selectUserView(userParam);
				returnMap.put("DeptManagerName",userInfo.getString("DisplayName"));
			}
			returnMap.put("status", Return.SUCCESS);
			
			
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
	
	/**
	 * 부서 리스트 API
	 */
	
	@RequestMapping(value = "/org/dept/list.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap listDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		try	{
			String domainID = sysAclSvc.getDomainID(params.getString("CompanyCode"));
			
			if(domainID == null || domainID.isEmpty()) {
				throw new Exception("해당 CompanyCode 가 없습니다.");
			}
			params.put("domainId", domainID);
			returnMap = orgApiSvc.selectDeptList(params);
	
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnMap;
	}
		
}
