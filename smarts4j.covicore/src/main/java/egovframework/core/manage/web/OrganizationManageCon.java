package egovframework.core.manage.web;

import java.io.StringReader;
import java.net.URLDecoder;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;










import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.core.sevice.OrganizationADSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : OrganizationManageCon.java
 * @Description : 조직관리
 * @Modification Information 
 * @ 2016.05.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class OrganizationManageCon {

	private Logger LOGGER = LogManager.getLogger(OrganizationManageCon.class);
	private HttpClientUtil httpClient = new HttpClientUtil();	
	@Autowired
	private OrganizationManageSvc OrganizationManageSvc;
	@Autowired
	private OrganizationADSvc orgADSvc;
	@Autowired
	private FileUtilService fileUtilSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	private String licSection = "Y";

	//페이지 이동
	@RequestMapping(value="GroupManageInfoPop.do", method=RequestMethod.GET)
	public ModelAndView groupManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainId = request.getParameter("domainId");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "manage/organization/GroupManageInfoPop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}
	

	//페이지 이동
	@RequestMapping(value="GroupMemberManagePop.do", method=RequestMethod.GET)
	public ModelAndView groupMemberManagePop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainId = request.getParameter("domainId");
		String strDomainCode = request.getParameter("domainCode");
		String strGroupType = request.getParameter("groupType");

		String returnURL = "manage/organization/GroupMemberManagePop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("GroupType", strGroupType);


		return mav;
	}

	//페이지 이동
	@RequestMapping(value="DeptManageInfoPop.do", method=RequestMethod.GET)
	public ModelAndView deptManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainId = request.getParameter("domainId");
		String strDomainCode = request.getParameter("domainCode");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "manage/organization/DeptManageInfoPop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("Mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}


	//페이지 이동
	@RequestMapping(value="ArbitraryGroupManageInfoPop.do", method=RequestMethod.GET)
	public ModelAndView arbitraryGroupManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainId = request.getParameter("domainId");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "manage/organization/ArbitraryGroupManageInfoPop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}
	//페이지 이동
	@RequestMapping(value="AddJobManageInfoPop.do", method=RequestMethod.GET)
	public ModelAndView addJobManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strNO = request.getParameter("NO");
		String strMode = request.getParameter("mode");
		String strDomainId = request.getParameter("domainId");
		String strDomainCode = request.getParameter("domainCode");
		String returnURL = "manage/organization/AddJobManageInfoPop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("NO", strNO);
		mav.addObject("mode", strMode);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("DomainCode", strDomainCode);

		return mav;
	}
	

	//페이지 이동
	@RequestMapping(value="UserManageInfoPop.do", method=RequestMethod.GET)
	public ModelAndView showUserManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("groupCode");
		String strMode = request.getParameter("mode");
		String strDomainId = request.getParameter("domainId");
		String strUserCode = request.getParameter("userCode");
		String strdomainCode = request.getParameter("domainCode");
		String strReferer =request.getHeader("REFERER");
		String returnURL = "manage/organization/UserManageInfoPop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("Editable", "N");
		if (strReferer != null &&strReferer.indexOf("CLMD=manage") > -1 ){
			mav.addObject("Editable", "Y");
		}
		mav.addObject("GroupCode", strGR_Code);
		mav.addObject("DomainId", strDomainId);
		mav.addObject("DomainCode", strdomainCode);
		mav.addObject("Mode", strMode);
		mav.addObject("UserCode", strUserCode);
		
		return mav;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//부서관리
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	@RequestMapping(value = "manage/conf/selectGroupType.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectGroupType(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		
		CoviMap returnList = new CoviMap();
		
		try{
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectGroupType().get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * selectAllDeptList : 부서 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectAllDeptList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectAllDeptList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");		
		//String gr_code = request.getParameter("gr_code");
		//String grouptype = request.getParameter("grouptype");
		//String IsUse = request.getParameter("IsUse");
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		//String type = request.getParameter("type");
		
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();

			params.put("domainId", domainId);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectAllDeptList(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	/**
	 * deleteDept : 부서 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteDept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String GroupCodes = StringUtil.replaceNull(request.getParameter("GroupCodes"), "");
		int result = 0;
		try {
			for(int i = 0; i < GroupCodes.split(",").length; i++) {
				if(getHasChildDept(GroupCodes.split(",")[i])) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "부서코드 [" + GroupCodes.split(",")[i] + "] : 하위그룹이 존재합니다.");
					return returnList;
				} 
				else if(getHasUserDept(GroupCodes.split(",")[i])) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "부서코드 [" + GroupCodes.split(",")[i] + "] : 사용자가 존재합니다.");
					return returnList;
				}
			}
			
			CoviMap params = new CoviMap();
			
			String GroupCodeArr[] = GroupCodes.split(",");
			
			params.put("deleteData", GroupCodeArr);
			params.put("TargetID",GroupCodeArr);
			
			CoviList arrresultList = (CoviList) OrganizationManageSvc.selectGroupInfoList(params).get("list");			
						
			int max = arrresultList.size();
			for (int i = 0; i < max; i++) {
				String strGroupCode =arrresultList.getJSONObject(i).getString("GroupCode");
				String strDisplayName =arrresultList.getJSONObject(i).getString("DisplayName");
				String strMultiDisplayName =arrresultList.getJSONObject(i).getString("MultiDisplayName");
				String sCompanyName =arrresultList.getJSONObject(i).getString("CompanyName").split(";")[0];
				String sOUPath =arrresultList.getJSONObject(i).getString("OUPath");
				String sOUName =arrresultList.getJSONObject(i).getString("OUName");
				String sGroupType =arrresultList.getJSONObject(i).getString("GroupType");
				String sMemberOf =arrresultList.getJSONObject(i).getString("MemberOf");
				String sSortKey =arrresultList.getJSONObject(i).getString("SortKey");
				String sIsMail =arrresultList.getJSONObject(i).getString("IsMail");
				String sPrimaryMail =arrresultList.getJSONObject(i).getString("PrimaryMail");
				String sSecondaryMail =arrresultList.getJSONObject(i).getString("SecondaryMail");
				String sManagerCode =arrresultList.getJSONObject(i).getString("ManagerCode");
				CoviMap params2 = new CoviMap();
				params2.put("ObjectCode",strGroupCode);
				params2.put("GroupCode",strGroupCode);
				params2.put("GroupType",sGroupType);
				params2.put("DisplayName",strDisplayName);
				params2.put("MultiDisplayName", strMultiDisplayName);
				params2.put("SyncType", "DELETE");
				params2.put("SyncManage", "Manage");
				params2.put("MemberOf", sMemberOf);
				params2.put("SortKey", sSortKey);
				params2.put("ManagerCode", sManagerCode);
				params2.put("PrimaryMail", sPrimaryMail);
				
				result = OrganizationManageSvc.deleteGroup(params2);
				if(result != 0) { 
					returnList.put("object", result);
					returnList.put("result", "ok");

					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "삭제되었습니다");
					returnList.put("etcs", "");
				}
				
				if(result!=0)returnList = setSubSystemGroup("MODIFY",strGroupCode,params2);
				
			}
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	 
	//strModType : ADD / MODIFY / DELETE(indi는 delete 미사용)
	protected CoviMap setSubSystemGroup(String strModType, String strGroupCode, CoviMap param){
		CoviMap returnList = new CoviMap();
		
		boolean bDoSyncIndiMail = false;
		boolean bDoSyncAD = false;
		boolean bDoSyncExch = false;
		boolean bResultSyncIndiMail = true;
		boolean bResultSyncAD = true;
		boolean bResultSyncExch = true;
		String strGroupType = "";
		String strIsMail = "";
		String strPrimaryMail = "";
		String strIsUse = "";
		String strGroupStatus = "";
		////////////////////////////////////////////////////////////////////////////////////////////////
		String strDisplayName="";
		String strCompanyName="";
		String strOUName="";
		String strOUPath="";
		String strMemberOf="";
		////////////////////////////////////////////////////////////////////////////////////////////////
		String strSecondaryMail="";
		try{
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			
			
			param.put("gr_code", strGroupCode);
			
			CoviList arrGroupList =  OrganizationManageSvc.selectSubSystemGroupInfo(param);
			CoviMap mTargetInfo = (CoviMap) arrGroupList.get(0);
			strGroupType        =mTargetInfo.getString("GroupType");	
			strIsMail           =mTargetInfo.getString("IsMail");	
			strPrimaryMail      =mTargetInfo.getString("PrimaryMail");	
			strIsUse            =mTargetInfo.getString("IsUse");	
			strDisplayName      =mTargetInfo.getString("DisplayName");	
			strCompanyName      =mTargetInfo.getString("CompanyName");	
			strOUName           =mTargetInfo.getString("OUName");	
			strOUPath           =mTargetInfo.getString("OUPath");	
			strMemberOf         =mTargetInfo.getString("MemberOf");	
			strSecondaryMail    =mTargetInfo.getString("SecondaryMail");	
			////////////////////////////////////////////////////////////////////////////////////////////////
			//인디메일
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(OrganizationManageSvc.getIndiSyncTF() && !strPrimaryMail.equals(""))
			{
				bDoSyncIndiMail = true;
				if(strGroupType.equalsIgnoreCase("DEPT")&&!"Y".equals(RedisDataUtil.getBaseConfig("IsDBDeptSync")))
					bDoSyncIndiMail = false;
			}
			if(bDoSyncIndiMail){
				mTargetInfo.put("MODE", "?job=modifyGroup");
				
				if("ADD".equals(strModType))
				{ 
					mTargetInfo.put("MODE",  "?job=addGroup");
				}
				if(strIsMail.equals("Y")&&strIsUse.equals("Y"))
					strGroupStatus = "A";
				else
					strGroupStatus = "S";
				mTargetInfo.put("GroupStatus", strGroupStatus);
			
				bResultSyncIndiMail = OrganizationManageSvc.setIndiMailGroup(mTargetInfo);
				if(!bResultSyncIndiMail)
				{
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "[MAIL] Raise Error");
					return returnList;
				}
			} 
			////////////////////////////////////////////////////////////////////////////////////////////////
			//AD
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") ){
				bDoSyncAD = true;
				if(strGroupType.equalsIgnoreCase("DEPT")&&!"Y".equals(RedisDataUtil.getBaseConfig("IsDBDeptSync")))
					bDoSyncAD = false;
			}
			if(bDoSyncAD){
				CoviMap resultList = new CoviMap();
				try{
					switch(strGroupType.toUpperCase()){
					case "COMPANY":
						resultList = orgADSvc.adModifyCompany(strGroupCode,strDisplayName,strMemberOf);
						break;
					case "DEPT":
						if(strIsUse.equals("Y")){
							resultList = orgADSvc.adModifyDept(strGroupCode,strDisplayName,strCompanyName,strMemberOf,strOUName,strOUPath,strOUPath,strPrimaryMail,"Manage","");
						}else if(strIsUse.equals("N") ){
							resultList = orgADSvc.adDeleteDept(strGroupCode,strDisplayName,strCompanyName,strOUName,strOUPath,"Manage","");
						}
						
						break;
					case "DIVISION":
						if(!strOUName.equals("")){ 
							if(strIsUse.equals("Y")){
								resultList = orgADSvc.adModifyGroup(strGroupType,strGroupCode,strDisplayName,strCompanyName,strMemberOf,strOUName,strOUPath,strPrimaryMail,"Manage","");
							}else if(strIsUse.equals("N")){
								resultList = orgADSvc.adDeleteGroup(strGroupType,strGroupCode,strDisplayName,strCompanyName,strOUPath,"Manage","");
							}
						}
						break;
					default :
						if(strIsUse.equals("Y")){
							resultList = orgADSvc.adModifyGroup(strGroupType,strGroupCode,strDisplayName,strCompanyName,strMemberOf,strOUName,strOUPath,strPrimaryMail,"Manage","");
						}else if(strIsUse.equals("N")){
							resultList = orgADSvc.adDeleteGroup(strGroupType,strGroupCode,strDisplayName,strCompanyName,strOUPath,"Manage","");
						}
						break;
					}
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						bResultSyncAD = false;
						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + resultList.getString("Reason"));
						throw new Exception(" [AD] " + resultList.getString("Reason"));
					}
				} catch (NullPointerException e){
					bResultSyncAD = false;
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [AD] " + resultList.getString("Reason"));
					throw new Exception(" [AD] " + resultList.getString("Reason"));
				}
				catch(Exception ex){
					bResultSyncAD = false;
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [AD] " + resultList.getString("Reason"));
					throw new Exception(" [AD] " + resultList.getString("Reason"));
				}
				
			}
			
						
			////////////////////////////////////////////////////////////////////////////////////////////////
			//Exchange
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
				bDoSyncExch = true;
				if(strGroupType.equalsIgnoreCase("DEPT")&&!"Y".equals(RedisDataUtil.getBaseConfig("IsDeptSync")))
					bDoSyncExch = false;
			}
			if(!bResultSyncAD)
				bDoSyncExch = false;
			if(bDoSyncExch)
			{
				CoviMap resultList = new CoviMap();
				try{
					if(strIsMail.equals("Y"))
						resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
					else
						resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						bResultSyncExch = false;
						returnList.put("result", "fail");
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [Exch] " + resultList.getString("Reason"));
						throw new Exception(" [Exch] " + resultList.getString("Reason"));
					}
				} catch (NullPointerException e){
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [Exch] " + resultList.getString("Reason"));
					throw new Exception(" [Exch] " + resultList.getString("Reason"));
				}
				catch(Exception ex){
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [Exch] " + resultList.getString("Reason"));
					throw new Exception(" [Exch] " + resultList.getString("Reason"));
				}
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
	 
	//param : DecLogonPassword, UserCode
	//UserCode
	//oldUserInfo : DeptCode,JobPositionCode,JobTitleCode,JobLevelCode,DeptMailAddress,JobPositionMailAddress,JobTitleMailAddress,JobLevelMailAddress, 
	protected CoviMap setSubSystemUser(CoviMap oldUserInfo ,CoviMap oldGroupInfos, CoviMap param){
		StringBuffer returnMsg = new StringBuffer();
		CoviMap returnList = new CoviMap();
		CoviMap reObject = new CoviMap();
		CoviMap mapResult = new CoviMap();
		CoviMap mapTemp = new CoviMap();
		
		boolean bDoSyncIndiMail = false;
		boolean bDoSyncAD = false;
		boolean bDoSyncExch = false;
		boolean bDoSyncSFB = false;
		boolean bResultSyncAD = true;
		CoviList curUserList =null;
		CoviMap mTargetInfo  =null;
		CoviMap curGroupInfos = null;
		
		String strUserCode = "";
		String strUserMailAddress   = "";
		String strDeptCode      	 = "";
		String strJobPositionCode	 = "";
		String strJobTitleCode      = "";
		String strJobLevelCode      = "";
		String strRegionCode      = "";
		String strOldDeptCode = "";
		String stroldJobPositionCode = "";
		String stroldJobTitleCode 	= "";
		String stroldJobLevelCode = "";
		String stroldRegionCode = "";

		String strIsUse = "Y";
		String strUseMailConnect = "";
		String strOldUseMailConnect = "";
		String strOldIsUse = "";
		
		String strDecLogonPassword;	

		String strAD_IsUse = "";
		String strCurEX_IsUse = "";
		

		boolean bActive = false;
		////////////////////////////////////////////////////////////////////////////////////////////////
		try{
			returnList.put("result", "OK");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			strDecLogonPassword = param.getString("DecLogonPassword");	
			//간편관리자>사용자수정에서 비밀번호 변경은 불가!!
			curUserList = (CoviList) OrganizationManageSvc.selectUserInfo(param).get("list");
			mTargetInfo = (CoviMap) curUserList.get(0);
			//mTargetInfo.addAll(param);
			//mTargetInfo.addAll(mTemp);
			strIsUse     =mTargetInfo.getString("IsUse");	
			strUserCode  =mTargetInfo.getString("UserCode");	
			strUserMailAddress  =mTargetInfo.getString("MailAddress");	
			strDeptCode      	=mTargetInfo.getString("DeptCode");	
			strJobPositionCode	=mTargetInfo.getString("JobPositionCode");	
			strJobTitleCode     =mTargetInfo.getString("JobTitleCode");	
			strJobLevelCode     =mTargetInfo.getString("JobLevelCode");	
			strRegionCode     =mTargetInfo.getString("RegionCode");	
			strUseMailConnect     =mTargetInfo.getString("UseMailConnect");	
			strAD_IsUse = mTargetInfo.getString("AD_ISUSE");	
			strCurEX_IsUse = mTargetInfo.getString("EX_IsUse");	
			
			mTargetInfo.put("DecLogonPassword",strDecLogonPassword);
			mapTemp.addAll(mTargetInfo);
			
			strOldDeptCode      =oldUserInfo.getString("DeptCode");	
			stroldJobPositionCode=oldUserInfo.getString("JobPositionCode");	
			stroldJobTitleCode  =oldUserInfo.getString("JobTitleCode");	
			stroldJobLevelCode  =oldUserInfo.getString("JobLevelCode");	
			stroldRegionCode  =oldUserInfo.getString("RegionCode");	
			strOldUseMailConnect  =oldUserInfo.getString("UseMailConnect");	
			strOldIsUse  =oldUserInfo.getString("IsUse");	
			

			if("N".equalsIgnoreCase(strIsUse)){
				strUseMailConnect="N";
				strAD_IsUse  ="N";
				strCurEX_IsUse  ="N";
			}
			//사용여부가 변경된 경우 강제
			if(!strIsUse.equalsIgnoreCase(strOldIsUse))
				bActive =true;
			//메일사용여부가 변경된 경우 강제
			if("Y".equalsIgnoreCase(strIsUse)&&!strOldUseMailConnect.equalsIgnoreCase(strUseMailConnect))
				bActive =true;
	
			
			curGroupInfos = (CoviMap)((CoviList) OrganizationManageSvc.selectUserGroupMailInfo(param).get("list")).get(0);//UserCode
			////////////////////////////////////////////////////////////////////////////////////////////////
			//인디메일
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(OrganizationManageSvc.getIndiSyncTF() && !strUserMailAddress.equals(""))
			{
				bDoSyncIndiMail = true;
				if(strUseMailConnect.equals("N")&&strOldUseMailConnect.equals("N"))
					bDoSyncIndiMail = false;	
			}
			if(bDoSyncIndiMail){
				mapTemp.put("mailStatus", "S");
				if(strUseMailConnect.equalsIgnoreCase("Y"))
					mapTemp.put("mailStatus", "A");
				try 
				{
					reObject = OrganizationManageSvc.getIndiMailUserStatus(mapTemp);
					String strGroupMail = curGroupInfos.getString("DeptMailAddress");
					String strOldGroupMail = oldGroupInfos.getString("DeptMailAddress");
					mapTemp.put("GroupName", mapTemp.getString("DeptName"));//setIndiMailUser용
					mapTemp.put("DecLogonPassword", mapTemp.getString("DecLogonPassword"));
					mapTemp.put("LanguageCode", mapTemp.getString("LanguageCode"));
					mapTemp.put("TimeZoneCode", mapTemp.getString("TimeZoneCode"));
					mapTemp.put("GroupMailAddress", strGroupMail);
					mapTemp.put("oldGroupMailAddress", strOldGroupMail);
					mapTemp.put("MODE", "ADD");
					
					if(reObject.getString("returnCode").equals("0") && reObject.getString("result").equals("0"))//계정 있을경우
						mapTemp.put("MODE", "MODIFY");
					else if(strUseMailConnect.equals("N"))//계정 없는데 비활성화일경우 
						bDoSyncIndiMail = false;
					if(bDoSyncIndiMail){
						reObject = OrganizationManageSvc.setIndiMailUser(mapTemp);
						if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
						mapTemp.put("MODE", "MODIFY");
						if(!strJobPositionCode.equalsIgnoreCase(stroldJobPositionCode)||bActive) 
						{
							strGroupMail = "";
							strOldGroupMail = "";
							if(!strJobPositionCode.isEmpty())
								strGroupMail = curGroupInfos.getString("JobPositionMailAddress");
						
							if(!stroldJobPositionCode.isEmpty())
								strOldGroupMail = oldGroupInfos.getString("JobPositionMailAddress");
							
							mapTemp.put("GroupMailAddress", strGroupMail.isEmpty() ? "" : strGroupMail);
							mapTemp.put("oldGroupMailAddress", strOldGroupMail.isEmpty() ? "" : strOldGroupMail);
							
							reObject = OrganizationManageSvc.setIndiMailUser(mapTemp);
							if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
						}
						if(!strJobTitleCode.equalsIgnoreCase(stroldJobTitleCode)||bActive) {
							strGroupMail = "";
							strOldGroupMail = "";
							if(!strJobTitleCode.isEmpty())
								strGroupMail = curGroupInfos.getString("JobTitleMailAddress");
						
							if(!stroldJobTitleCode.isEmpty())
								strOldGroupMail = oldGroupInfos.getString("JobTitleMailAddress");
							
							mapTemp.put("GroupMailAddress", strGroupMail.isEmpty() ? "" : strGroupMail);
							mapTemp.put("oldGroupMailAddress", strOldGroupMail.isEmpty() ? "" : strOldGroupMail);
							
							reObject = OrganizationManageSvc.setIndiMailUser(mapTemp);
							if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
						}
						if(!strJobLevelCode.equalsIgnoreCase(stroldJobLevelCode)||bActive) {
							strGroupMail = "";
							strOldGroupMail = "";
							if(!strJobLevelCode.isEmpty())
								strGroupMail = curGroupInfos.getString("JobLevelMailAddress");
						
							if(!stroldJobLevelCode.isEmpty())
								strOldGroupMail = oldGroupInfos.getString("JobLevelMailAddress");
							
							mapTemp.put("GroupMailAddress", strGroupMail.isEmpty() ? "" : strGroupMail);
							mapTemp.put("oldGroupMailAddress", strOldGroupMail.isEmpty() ? "" : strOldGroupMail);
							
							reObject = OrganizationManageSvc.setIndiMailUser(mapTemp);
							if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
						}
						if(!strRegionCode.equalsIgnoreCase(stroldRegionCode)||bActive) {
							strGroupMail = "";
							strOldGroupMail = "";
							if(!strRegionCode.isEmpty())
								strGroupMail = curGroupInfos.getString("RegionMailAddress");
						
							if(!stroldRegionCode.isEmpty())
								strOldGroupMail = oldGroupInfos.getString("RegionMailAddress");
							
							mapTemp.put("GroupMailAddress", strGroupMail.isEmpty() ? "" : strGroupMail);
							mapTemp.put("oldGroupMailAddress", strOldGroupMail.isEmpty() ? "" : strOldGroupMail);
							
							reObject = OrganizationManageSvc.setIndiMailUser(mapTemp);
							if(!reObject.getString("returnCode").equals("0")||!"SUCCESS".equals(reObject.getString("returnMsg"))) throw new Exception(" [CP메일] " + reObject.getString("returnMsg"));
						}
						
						
					}
					returnMsg.append("|<b>CP메일</b> : SUCCESS<br/>");
				} catch (NullPointerException e){
					returnMsg.append("|<b>CP메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				catch (Exception e) {
					returnMsg.append("|<b>CP메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////
			//AD
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")&&RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
				bDoSyncAD = true;
			}
			CoviMap oldUserADInfo = null;
			String strAD_SamAccountName  = null;
			if(bDoSyncAD){
				try{
					oldUserADInfo = (CoviMap)((CoviList) orgADSvc.selectUserInfoByAdmin(mTargetInfo).get("list")).get(0);
					int icheckad = 0;
					if(oldUserADInfo.getString("AD_USERID").equals("")){
						icheckad = orgADSvc.insertUserADInfo(param);
					}else{
						icheckad = orgADSvc.updateUserADInfo(param);
					}
					curUserList = (CoviList) OrganizationManageSvc.selectUserInfo(param).get("list");
					mTargetInfo = (CoviMap) curUserList.get(0);
					strAD_SamAccountName = mTargetInfo.getString("AD_SamAccountName");	
					
					if(icheckad != 0){	//sys_object_user_ad 정보 수정 성공
						if(strAD_IsUse.equals("Y")){
							mapTemp.put("gr_code", strDeptCode);
							String strOUPath_Temp = "";
							String strAD_ServerURL = RedisDataUtil.getBaseConfig("AD_ServerURL");
							String strUserPrincipalName = strUserCode + "@"+strAD_ServerURL;
							strOUPath_Temp = curGroupInfos.getString("OUPath");
							
							if(oldUserADInfo.getString("AD_USERID").equals(""))
							{
								mapResult = orgADSvc.adAddUser(strUserCode, mTargetInfo.getString("CompanyCode")
									, strDeptCode 
									//, strOldDeptCode
									, strOUPath_Temp, mTargetInfo.getString("LogonID")
									, strDecLogonPassword//AD 사용안함이다가 사용으로 변경시 문제생길수 있겠는데..
									, mTargetInfo.getString("EmpNo")
									, mTargetInfo.getString("AD_DisplayName")
									, mTargetInfo.getString("JobPositionCode"), mTargetInfo.getString("JobTitleCode"), mTargetInfo.getString("JobLevelCode"), mTargetInfo.getString("RegionCode"), mTargetInfo.getString("AD_FIRSTNAME"), mTargetInfo.getString("AD_LASTNAME"), mTargetInfo.getString("AD_USERACCOUNTCONTROL"), mTargetInfo.getString("AD_ACCOUNTEXPIRES")
									, mTargetInfo.getString("AD_PhoneNumber"), mTargetInfo.getString("AD_MOBILE"), mTargetInfo.getString("AD_FAX"), mTargetInfo.getString("AD_INFO"), mTargetInfo.getString("AD_TITLE"), mTargetInfo.getString("AD_DEPARTMENT"), mTargetInfo.getString("AD_COMPANY"), mTargetInfo.getString("EX_PRIMARYMAIL"), mTargetInfo.getString("EX_SECONDARYMAIL")
									, mTargetInfo.getString("AD_CN"), mTargetInfo.getString("AD_SamAccountName"), strUserPrincipalName, mTargetInfo.getString("PhotoPath"), mTargetInfo.getString("AD_MANAGERCODE"), mTargetInfo.getString("O365_IsUse"),"Manage","");

								if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
									returnList.put("status", Return.FAIL);
									throw new Exception(" [AD] adAddUser " +mapResult.getString("Reason"));
								}
							}

							mapResult = orgADSvc.adModifyUser(strUserCode, mTargetInfo.getString("CompanyCode"), strDeptCode, strOldDeptCode
									, strOUPath_Temp, mTargetInfo.getString("LogonID"), mTargetInfo.getString("DecLogonPassword"), mTargetInfo.getString("EmpNo"), mTargetInfo.getString("AD_DisplayName")
									, mTargetInfo.getString("JobPositionCode"), mTargetInfo.getString("JobTitleCode"), mTargetInfo.getString("JobLevelCode"), mTargetInfo.getString("RegionCode"), mTargetInfo.getString("AD_FIRSTNAME"), mTargetInfo.getString("AD_LASTNAME"), mTargetInfo.getString("AD_USERACCOUNTCONTROL"), mTargetInfo.getString("AD_ACCOUNTEXPIRES")
									, mTargetInfo.getString("AD_PhoneNumber"), mTargetInfo.getString("AD_MOBILE"), mTargetInfo.getString("AD_FAX"), mTargetInfo.getString("AD_INFO"), mTargetInfo.getString("AD_TITLE"), mTargetInfo.getString("AD_DEPARTMENT"), mTargetInfo.getString("AD_COMPANY"), mTargetInfo.getString("EX_PRIMARYMAIL"), mTargetInfo.getString("EX_SECONDARYMAIL")
									, mTargetInfo.getString("AD_CN"), mTargetInfo.getString("AD_SamAccountName"), strUserPrincipalName, mTargetInfo.getString("PhotoPath"), mTargetInfo.getString("AD_MANAGERCODE"),"Manage","");
							
							if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								throw new Exception(" [AD] adModifyUser " +mapResult.getString("Reason"));
							}

							/*if(!oldUserADInfo.getString("AD_USERID").equals("")&&RedisDataUtil.getBaseConfig("PERMISSION_AD_PWD_CHG").equals("Y")//AD 수정이면서, 비밀번호 변경 가능일때
								&&!"".equals(strDecLogonPassword))
							{	
								String sOldLogonPW = oldUserADInfo.getString("LOGONPASSWORD");//오류발생할텐데..
								AES aes = new AES(aeskey, "N");
								sOldLogonPW = aes.decrypt(sOldLogonPW);
								if (sOldLogonPW != strDecLogonPassword)
								{
									mapResult = orgADSvc.adChangePassword(strAD_SamAccountName,sOldLogonPW,strDecLogonPassword);
									if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
										returnList.put("status", Return.FAIL);
										throw new Exception(" [AD] adChangePassword " +mapResult.getString("Reason"));
									}
								}
							}*/
							
						}else{
							//사용자 비활성화
							mapResult = orgADSvc.adDisableUser(strUserCode,mTargetInfo.getString("CompanyCode"),strDeptCode
									,mTargetInfo.getString("JobPositionCode"),mTargetInfo.getString("JobTitleCode"),mTargetInfo.getString("JobLevelCode")
									,mTargetInfo.getString("RegionCode"),mTargetInfo.getString("AD_SamAccountName"),"Manage","");
							
							if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								throw new Exception(mapResult.getString("Reason"));
							}
						}
					}
					returnMsg.append("|<b>AD</b> : SUCCESS<br/>");
				} catch (NullPointerException e){
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(e.getLocalizedMessage(), e);
					bResultSyncAD = false;
				}
				catch(Exception e){
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(e.getLocalizedMessage(), e);
					bResultSyncAD = false;
				}
				
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////
			//Exchange
			////////////////////////////////////////////////////////////////////////////////////////////////
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")  && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
				bDoSyncExch = true;
			}
			if(!bResultSyncAD||oldUserADInfo==null)
				bDoSyncExch = false;
			if(bDoSyncExch)
			{
				try{
					String strOldEX_IsUse = oldUserInfo.getString("EX_IsUse");
					String strOldSECONDARYMAIL = oldUserInfo.getString("SECONDARYMAIL");
					if(strCurEX_IsUse.equals("Y")) {
						int icheckexch = 0;
						if(oldUserADInfo.getString("EX_USERID").equals("")){
							icheckexch = orgADSvc.insertUserExchInfo(param);
						}else{
							icheckexch = orgADSvc.updateUserExchInfo(param);
						} 

						curUserList = (CoviList) OrganizationManageSvc.selectUserInfo(param).get("list");
						mTargetInfo = (CoviMap) curUserList.get(0);
						if(icheckexch != 0){	//sys_object_user_exchange 정보 입력 성공
							mapResult = orgADSvc.exchModifyUser(strUserCode,mTargetInfo.getString("EX_STORAGESERVER"),mTargetInfo.getString("EX_STORAGEGROUP"),mTargetInfo.getString("EX_STORAGESTORE")
																,mTargetInfo.getString("EX_PRIMARYMAIL"),mTargetInfo.getString("EX_SECONDARYMAIL"),mTargetInfo.getString("MSN_SIPADDRESS")
																,mTargetInfo.getString("AD_CN"),mTargetInfo.getString("AD_SamAccountName"),strOldSECONDARYMAIL,"Manage","");
							
							if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								throw new Exception(" [EXCH] exchModifyUser " +mapResult.getString("Reason"));
							}
							if(!strOldEX_IsUse.equals(strCurEX_IsUse)){//활성화
								mapResult = orgADSvc.exchEnableUser(strUserCode,mTargetInfo.getString("EX_STORAGESERVER"),mTargetInfo.getString("EX_STORAGEGROUP"),mTargetInfo.getString("EX_STORAGESTORE")
																,mTargetInfo.getString("EX_PRIMARYMAIL"),mTargetInfo.getString("EX_SECONDARYMAIL"),mTargetInfo.getString("MSN_SIPADDRESS")
																,mTargetInfo.getString("AD_CN"),mTargetInfo.getString("AD_SamAccountName"),"Manage","");
								
								if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
									returnList.put("status", Return.FAIL);
									throw new Exception(" [EXCH] exchEnableUser " +mapResult.getString("Reason"));
								}
							}
						}
					}
					else if(strOldEX_IsUse.equals("Y")) //비활성화
					{
						mapResult = orgADSvc.exchDisableUser(strAD_SamAccountName,"Manage","");
						
						if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							throw new Exception(" [EXCH] exchDisableUser " +mapResult.getString("Reason"));
						}
					}
					returnMsg.append("|<b>Exch</b> : SUCCESS<br/>");
				} catch (NullPointerException ex){
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
				catch(Exception ex){
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
			}
					
			////////////////////////////////////////////////////////////////////////////////////////////////
			//SFB
			////////////////////////////////////////////////////////////////////////////////////////////////
			//if(RedisDataUtil.getBaseConfig("IsSyncMessenger").equals("Y")  && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
			//	bDoSyncSFB = true;
			//}
			//if(!bResultSyncAD||oldUserADInfo==null)
			//	bDoSyncSFB = false;
			//if(bDoSyncSFB)
			//{
			//	try{
			//		int icheckmsn = 0;
			//		if(oldUserADInfo.getString("MSN_USERID").equals(""))
			//		{
			//			icheckmsn = orgADSvc.insertUserMSNInfo(param);
			//		}else{
			//			icheckmsn = orgADSvc.updateUserMSNInfo(param);
			//		}
			//		
			//		if(icheckmsn != 0) {
			//			if(mTargetInfo.getString("MSN_IsUse").equals("Y")) {
			//				mapResult = orgADSvc.msnEnableUser(strAD_SamAccountName,mTargetInfo.getString("MSN_SIPADDRESS"),"Manage","");
			//				
			//				if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패	
			//					returnList.put("status", Return.FAIL);
			//					throw new Exception(" [SFB] msnEnableUser " +mapResult.getString("Reason"));
			//				}
			//			} else {
			//				mapResult = orgADSvc.msnDisableUser(strAD_SamAccountName,mTargetInfo.getString("MSN_SIPADDRESS"),"Manage","");
			//				
			//				if(!Boolean.valueOf((String) mapResult.getString("result"))){ //실패	
			//					returnList.put("status", Return.FAIL);
			//					throw new Exception(" [SFB] msnDisableUser " +mapResult.getString("Reason"));
			//				}
			//			}
			//		}
			//		returnMsg.append("|<b>SFB</b> : SUCCESS<br/>");
			//	}
			//	catch(Exception ex){
			//		returnMsg.append("|<b>SFB</b> : FAIL<br/>");
			//		returnList.put("status", Return.FAIL);
			//		LOGGER.error(ex.getLocalizedMessage(), ex);
			//	}
			//}
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
	
	/**
	 * updateIsUseDept : 부서 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateIsUseDept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		int result = 0;
		int modifyStatus = 0;
		
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsUse");
			String strModDate = request.getParameter("ModDate");
			
			if("N".equalsIgnoreCase(strIsUse)){
				if(getHasChildDept(strCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "코드 [" + strCode + "] : 하위그룹이 존재합니다.");
					return returnList;
				} 
				else if(getHasUserDept(strCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "코드 [" + strCode + "] : 사용자가 존재합니다.");
					return returnList;
				}
			}
			
			CoviMap params2 = new CoviMap();
			params2.put("gr_code", strCode);
			
			CoviList arrGroupList = (CoviList) OrganizationManageSvc.selectDeptInfo(params2).get("list");
			String sCompanyName =arrGroupList.getJSONObject(0).getString("CompanyName");
			String sDisplayName = arrGroupList.getJSONObject(0).getString("DisplayName");
			String sMemberOf = arrGroupList.getJSONObject(0).getString("MemberOf");
			String sOUName = arrGroupList.getJSONObject(0).getString("OUName");
			String sOUPath = arrGroupList.getJSONObject(0).getString("OUPath");
			String sIsMail = arrGroupList.getJSONObject(0).getString("IsMail");
			String sPrimaryMail = arrGroupList.getJSONObject(0).getString("PrimaryMail");
			String sSecondaryMail = arrGroupList.getJSONObject(0).getString("SecondaryMail");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsUse", strIsUse);
			params.put("ModifyDate", strModDate);
			params.put("GroupType", "Dept");
			params.put("DisplayName", sDisplayName);
			params.put("MemberOf", sMemberOf);
			params.put("PrimaryMail", sPrimaryMail);
			
			result = OrganizationManageSvc.updateIsUseDept(params);
			if(result > 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
			}
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다.");
			}
			
			
			if(result!=0)returnList = setSubSystemGroup("MODIFY",strCode,params);
			
			returnList.put("object", result);
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsHRDept : 부서 인사 연동 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateishrdept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsHRDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsHR = request.getParameter("IsHR");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsHR", strIsHR);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", OrganizationManageSvc.updateIsHRDept(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsDisplayDept : 부서 표시 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateisdisplaydept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsDisplayDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsDisplay = request.getParameter("IsDisplay");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsDisplay", strIsDisplay);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", OrganizationManageSvc.updateIsDisplayDept(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}


	/**
	 * insertDeptInfo : 부서 정보 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/insertdeptinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertDeptInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			
			int addStatus = 0;
			String strGroupCode = request.getParameter("GroupCode");
			String strDisplayName = request.getParameter("DisplayName");
			String strMultiDisplayName = request.getParameter("MultiDisplayName");
			String strShortName = request.getParameter("ShortName");
			String strMultiShortName = request.getParameter("MultiShortName");
			String strPrimaryMail = request.getParameter("PrimaryMail");
			String strCompanyCode = request.getParameter("CompanyCode");
			String strMemberOf = request.getParameter("MemberOf");
			String strIsUse = request.getParameter("IsUse");
			String strIsHR = request.getParameter("IsHR");
			String strIsDisplay = request.getParameter("IsDisplay");
			String strIsMail = StringUtil.replaceNull(request.getParameter("IsMail"), "");
			String strApprovable = request.getParameter("Approvable");
			String strReceivable = request.getParameter("Receivable");
			String strSortKey = request.getParameter("SortKey");
			String strManagerCode = request.getParameter("ManagerCode");
			String strDescription = request.getParameter("Description");
			//String strRegID = request.getParameter("RegID");
			String strRegistDate = request.getParameter("RegistDate");			
			String strSecondaryMail = request.getParameter("SecondaryMail");
			String strRegionCode = request.getParameter("RegionCode");
			String strOUName = request.getParameter("OUName");
			String strCompanyName = request.getParameter("CompanyName");
			String strEX_PrimaryMail = request.getParameter("EX_PrimaryMail");
			String strChkDeptSchedule = StringUtil.replaceNull(request.getParameter("ChkDeptSchedule"), "");

			String[] resultString = getGroupEtcInfo(strCompanyCode, strMemberOf).split("&");
			String strCompanyID = "";
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";
			if(resultString.length > 0) {
				strCompanyID = resultString[0];
				strGroupPath = resultString[1] + strGroupCode + ";";
				strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(strSortKey)) + ";";
				strOUPath = resultString[3] + strDisplayName + ";";
			}
			String[] arrOUPath = strOUPath.split(";");
			int nDepth = arrOUPath.length;
			
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			String strIsCRM = request.getParameter("IsCRM");
			
			CoviMap params = new CoviMap();
			//sys_object
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");
			params.put("IsSync", "Y");
			
			params.put("GroupType", "Dept");
			params.put("CompanyID", strCompanyID);
			params.put("GroupCode", strGroupCode);
			params.put("DisplayName", strDisplayName);
			params.put("MultiDisplayName", strMultiDisplayName);
			params.put("ShortName", strShortName);
			params.put("MultiShortName", strMultiShortName);
			params.put("PrimaryMail", strPrimaryMail);
			params.put("CompanyCode", strCompanyCode);
			params.put("MemberOf", strMemberOf);
			params.put("GroupPath", strGroupPath);
			params.put("OUPath", strOUPath);
			params.put("IsUse", strIsUse);
			params.put("IsHR", strIsHR);
			params.put("IsDisplay", strIsDisplay);
			params.put("IsMail", strIsMail);
			params.put("Approvable", strApprovable);
			params.put("Receivable", strReceivable);
			params.put("SortKey", strSortKey);
			params.put("SortPath", strSortPath);
			params.put("ManagerCode", strManagerCode);
			params.put("Description", strDescription);
			//params.put("RegID", strRegID);
			params.put("RegistDate", strRegistDate);
			params.put("SecondaryMail", strSecondaryMail);
			params.put("RegionCode", strRegionCode);
			params.put("OUName", strOUName);
			params.put("CompanyName", strCompanyName);
			params.put("EX_PrimaryMail", strEX_PrimaryMail);
			params.put("SyncMode","G");
			params.put("nDepth", nDepth);
			params.put("SyncType", "INSERT");
			params.put("SyncManage", "Manage");
			params.put("IsCRM", strIsCRM);
			int result = OrganizationManageSvc.insertGroup(params);
			returnList.put("object", result);
			
			if(result == 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
				return returnList;
			}
			//부서일정 추가
			if(strChkDeptSchedule.equalsIgnoreCase("Y")) {
				params.put("FolderType", "Schedule");
				params.put("OwnerCode", params.get("ManagerCode") != null && !params.get("ManagerCode").equals("") ? params.get("ManagerCode") : "superadmin");
				params.put("CreateYN", "N");
				
				int cnt = OrganizationManageSvc.insertDeptScheduleCreation(params);
				if(cnt > 0) {
					OrganizationManageSvc.insertDeptScheduleInfo();
				}
			}
			returnList = setSubSystemGroup("ADD",strGroupCode,params);
			
			//path 전체 수정
			if(RedisDataUtil.getBaseConfig("IsRebuildDeptPath").equals("Y")){
				OrganizationManageSvc.updateDeptPathInfoAll();
			}			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateDeptInfo : 부서 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updatedeptinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateDeptInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			
			int modifyStatus = 0;
			String strGroupCode = request.getParameter("GroupCode");
			String strDisplayName = request.getParameter("DisplayName");
			String strMultiDisplayName = request.getParameter("MultiDisplayName");
			String strShortName = request.getParameter("ShortName");
			String strMultiShortName = request.getParameter("MultiShortName");
			String strPrimaryMail = request.getParameter("PrimaryMail");
			String strCompanyCode = request.getParameter("CompanyCode");
			String strMemberOf = request.getParameter("MemberOf");
			String strGroupType = request.getParameter("GroupType");
			String strIsUse = request.getParameter("IsUse");
			String strIsHR = request.getParameter("IsHR");
			String strIsDisplay = request.getParameter("IsDisplay");
			String strIsMail = StringUtil.replaceNull(request.getParameter("IsMail"), "");
			String strhidtxtUseMailConnect = request.getParameter("hidtxtUseMailConnect");
			String strApprovable = request.getParameter("Approvable");
			String strReceivable = request.getParameter("Receivable");
			String strSortKey = request.getParameter("SortKey");
			String strManagerCode = request.getParameter("ManagerCode");
			String strDescription = request.getParameter("Description");
			//String strModID = request.getParameter("RegID"); //수정 시, 해당 세션과 날짜의 값을 Reg로 받아와도 Mod로 저장될 수 있도록
			String strModifyDate = request.getParameter("RegistDate");
			String strOUName = request.getParameter("OUName");
			String strSecondaryMail = request.getParameter("SecondaryMail");
			String strEX_PrimaryMail = request.getParameter("EX_PrimaryMail");
			
			String[] resultString = getGroupEtcInfo(strCompanyCode, strMemberOf).split("&");
			String strCompanyID = "";
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";
			if(resultString.length > 0) {
				strCompanyID = resultString[0];
				strGroupPath = resultString[1] + strGroupCode + ";";
				strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(strSortKey)) + ";";
				strOUPath = resultString[3] + strDisplayName + ";";

				if(resultString[1].indexOf(";"+strGroupCode+";")>-1)
				{
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_ValidDeptMemberOf"));
					return returnList;
				}
			}

			if("N".equalsIgnoreCase(strIsUse)){
				if(getHasChildGroup(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupName|" + strDisplayName);
					return returnList;
				} else if(getHasUserGroup(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + strDisplayName);
					return returnList;
				}
				else if(getHasGroupMember(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + strDisplayName);
					return returnList;
				}
			}
			
			
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			String strIsCRM = request.getParameter("IsCRM");
			
			CoviMap params = new CoviMap();
			
			params.put("CompanyID", strCompanyID);
			params.put("GroupCode", strGroupCode);
			params.put("gr_code", strGroupCode);
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");			
			params.put("DisplayName", strDisplayName);
			params.put("MultiDisplayName", strMultiDisplayName);
			params.put("ShortName", strShortName);
			params.put("MultiShortName", strMultiShortName);
			params.put("PrimaryMail", strPrimaryMail);
			params.put("CompanyCode", strCompanyCode);
			params.put("MemberOf", strMemberOf);
			params.put("GroupPath", strGroupPath);
			params.put("OUPath", strOUPath);
			params.put("GroupType", strGroupType);
			params.put("IsUse", strIsUse);
			params.put("IsHR", strIsHR);
			params.put("IsDisplay", strIsDisplay);
			params.put("IsMail", strIsMail);
			params.put("Approvable", strApprovable);
			params.put("Receivable", strReceivable);
			params.put("SortKey", strSortKey);
			params.put("SortPath", strSortPath);
			params.put("ManagerCode", strManagerCode);
			params.put("Description", strDescription);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModifyDate); 
			params.put("OUName", strOUName);
			params.put("SyncType", "UPDATE");
			params.put("SyncManage", "Manage");
			params.put("gr_code", strGroupCode);
			params.put("SecondaryMail", strSecondaryMail);
			params.put("IsCRM", strIsCRM);
			
			
			
			
			modifyStatus = OrganizationManageSvc.updateGroup(params);
			returnList.put("object", modifyStatus);
			
			if(modifyStatus == 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
				return returnList;
			}
			OrganizationManageSvc.updateDeptScheduleInfo(params);
			
			//하위부서 Path 정보 업데이트
			int iSize = 0;
			CoviList arrChildGroupList = OrganizationManageSvc.selectDeptPathInfo(params).getJSONArray("list");
			iSize = arrChildGroupList.size();
			for(int j=0; j<iSize; j++){
				CoviMap params2 = new CoviMap();
				params2.put("GroupCode", arrChildGroupList.getJSONObject(j).getString("GroupCode")) ;
				params2.put("OUPath", arrChildGroupList.getJSONObject(j).getString("OUPath")) ;
				params2.put("SortPath", arrChildGroupList.getJSONObject(j).getString("SortPath")) ;
				params2.put("GroupPath", arrChildGroupList.getJSONObject(j).getString("GroupPath")) ;
				OrganizationManageSvc.updateDeptPathInfo(params2);
			}
			
			returnList = setSubSystemGroup("MODIFY",strGroupCode,params);
			
			
			//path 전체 수정
			if(RedisDataUtil.getBaseConfig("IsRebuildDeptPath").equals("Y")){
				OrganizationManageSvc.updateDeptPathInfoAll();
			}
			
			if(RedisDataUtil.getBaseConfig("DeptScheuleAutoCreation").equals("Y")) {
				OrganizationManageSvc.updateDeptScheduleInfo(params);
			}
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//그룹관리
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	/**
	 * getGroupTreeList : 그룹 목록 select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getAllGroupList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getAllGroupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");		
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();
				
		try{
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();
			params.put("domainId", domainId);
			
			returnObj = OrganizationManageSvc.getAllGroupList(params);
			
			returnObj.put("list", returnObj.get("list"));
			returnObj.put("result", "ok");
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	
	/**
	 * getGroupTreeList : 그룹 목록 select(직위/직책..)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectGroupListByGroupType.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getGroupListByGroupType(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");	
		String groupType = request.getParameter("groupType");
		
		
		String searchType = request.getParameter("searchType");		
		String searchText = request.getParameter("searchText");		
		String searchIsUse = request.getParameter("searchIsUse");		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
				 
		try{
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("domainId", domainId);
			params.put("groupType", groupType);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : searchText);
			params.put("searchIsUse", searchIsUse == null || searchIsUse.isEmpty() ? null : searchIsUse);
			returnObj = OrganizationManageSvc.selectGroupListByGroupType(params);
			
			returnObj.put("result", "ok");
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	@RequestMapping(value = "manage/conf/selectGroupListByGroupTypeByCode.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectGroupListByGroupTypeByCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainCode = request.getParameter("domainCode");	
		String groupType = request.getParameter("groupType");
		
		
		String searchType = request.getParameter("searchType");		
		String searchText = request.getParameter("searchText");		
		String searchIsUse = request.getParameter("searchIsUse");		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
				 
		try{
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("domainCode", domainCode);
			params.put("groupType", groupType);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : searchText);
			params.put("searchIsUse", searchIsUse == null || searchIsUse.isEmpty() ? null : searchIsUse);
			returnObj = OrganizationManageSvc.selectGroupListByGroupType(params);
			
			returnObj.put("result", "ok");
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	

	/**
	 * deleteGroup : 그룹 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String GroupCodes = StringUtil.replaceNull(request.getParameter("GroupCodes"), "");
		int result= 0;
		
		try {

			String GroupCodeArr[] = GroupCodes.split(",");

			CoviMap params = new CoviMap();
			params.put("deleteData", GroupCodeArr);
			params.put("TargetID",GroupCodeArr);
			
			CoviList arrresultList = (CoviList) OrganizationManageSvc.selectGroupInfoWithSubList(params).get("list");	
			for(int i = 0; i < arrresultList.size(); i++) {
				CoviMap jObjTemp  =arrresultList.getJSONObject(i);
				if(getHasChildGroup(GroupCodes.split(",")[i])) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupName|" + jObjTemp.getString("DisplayName"));
					return returnList;
				} else if(getHasUserGroup(GroupCodes.split(",")[i])) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + jObjTemp.getString("DisplayName"));
					return returnList;
				}
				else if(getHasGroupMember(GroupCodes.split(",")[i])) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + jObjTemp.getString("DisplayName"));
					return returnList;
				}
			}
			
					
					
			int max = arrresultList.size();
			for (int i = 0; i < max; i++) {
				String strGroupCode =arrresultList.getJSONObject(i).getString("GroupCode");
				String strDisplayName =arrresultList.getJSONObject(i).getString("DisplayName");
				String strMultiDisplayName =arrresultList.getJSONObject(i).getString("MultiDisplayName");
				String sCompanyName =arrresultList.getJSONObject(i).getString("CompanyName").split(";")[0];
				String sOUPath =arrresultList.getJSONObject(i).getString("OUPath");
				String sOUName =arrresultList.getJSONObject(i).getString("OUName");
				String sGroupType =arrresultList.getJSONObject(i).getString("GroupType");
				String sMemberOf =arrresultList.getJSONObject(i).getString("MemberOf");
				String sSortKey =arrresultList.getJSONObject(i).getString("SortKey");
				String sIsMail =arrresultList.getJSONObject(i).getString("IsMail");
				String sPrimaryMail =arrresultList.getJSONObject(i).getString("PrimaryMail");
				String sSecondaryMail =arrresultList.getJSONObject(i).getString("SecondaryMail");
				String sManagerCode =arrresultList.getJSONObject(i).getString("ManagerCode");
				CoviMap params2 = new CoviMap();
				params2.put("ObjectCode",strGroupCode);
				params2.put("GroupCode",strGroupCode);
				params2.put("GroupType",sGroupType);
				params2.put("DisplayName",strDisplayName);
				params2.put("MultiDisplayName", strMultiDisplayName);
				params2.put("SyncType", "DELETE");
				params2.put("SyncManage", "Manage");
				params2.put("MemberOf", sMemberOf);
				params2.put("SortKey", sSortKey);
				params2.put("ManagerCode", sManagerCode);
				params2.put("PrimaryMail", sPrimaryMail);		
				result = OrganizationManageSvc.deleteGroup(params2);
				
				if(result > 0) {
					returnList.put("object", result);
					returnList.put("result", "ok");

					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "삭제되었습니다");
					returnList.put("etcs", "");
				} else {
					returnList.put("status", Return.FAIL);
					returnList.put("message", strDisplayName);
				}
				
				if(result!=0)returnList = setSubSystemGroup("MODIFY",strGroupCode,params2);
				
			}
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/**
	 * updateIsUseDept : 그룹 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateIsUseGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		int result = 0;
		int modifyStatus = 0;
		
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsUse");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params2 = new CoviMap();
			params2.put("GroupCode", strCode);
			
			
			
			CoviList arrGroupList = (CoviList) OrganizationManageSvc.selectGroupInfo(params2).get("list");
			String sCompanyName =arrGroupList.getJSONObject(0).getString("CompanyName");
			String sDisplayName = arrGroupList.getJSONObject(0).getString("DisplayName");
			String sMemberOf = arrGroupList.getJSONObject(0).getString("MemberOf");
			String sOUName = arrGroupList.getJSONObject(0).getString("OUName");
			String sOUPath = arrGroupList.getJSONObject(0).getString("OUPath");
			String sIsMail = arrGroupList.getJSONObject(0).getString("IsMail");
			String sPrimaryMail = arrGroupList.getJSONObject(0).getString("PrimaryMail");
			String sSecondaryMail = arrGroupList.getJSONObject(0).getString("SecondaryMail");
			
			if("N".equalsIgnoreCase(strIsUse)){
				if(getHasChildGroup(strCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupName|" + sDisplayName);
					return returnList;
				} else if(getHasUserGroup(strCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + sDisplayName);
					return returnList;
				}
				else if(getHasGroupMember(strCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + sDisplayName);
					return returnList;
				}
			}
			
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsUse", strIsUse);
			params.put("ModifyDate", strModDate);
			params.put("GroupType", "Dept");
			params.put("DisplayName", sDisplayName);
			params.put("MemberOf", sMemberOf);
			params.put("PrimaryMail", sPrimaryMail);
			
			result = OrganizationManageSvc.updateIsUseGroup(params);
			if(result > 0) modifyStatus = 0;
			else modifyStatus = -1;
			

			if(result!=0)returnList = setSubSystemGroup("MODIFY",strCode,params2);
			
			
			returnList.put("object", result);
			
			if(modifyStatus < 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "그룹 수정 오류가 발생하였습니다.");
			}else if(modifyStatus == 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}else if(modifyStatus == 1) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메일)");
			}else if(modifyStatus == 2) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
			}
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/**
	 * moveSortKey_GroupUser : 그룹 우선순위 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/moveSortKey_GroupUser.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap moveSortKey_GroupUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int result;
		String pStrCode_A		= null;
		String pStrCode_B		= null;
		String pStrType			= null;
		CoviMap params = null;
		CoviMap returnData = null;
		
		try {
			returnData = new CoviMap();
			params = new CoviMap();
			
			pStrCode_A = request.getParameter("pStrCode_A");		
			pStrCode_B = request.getParameter("pStrCode_B");
			pStrType = request.getParameter("pStrType");

			params.put("Code_A",pStrCode_A);
			params.put("Code_B",pStrCode_B);
			params.put("Type", pStrType);
			
			returnData = OrganizationManageSvc.updateGroupUserListSortKey(params);
			
			
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}	
	

	/**
	 * moveDeptOrgUser : 다수 사용자 부서이동
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/moveDeptOrgUser.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap moveDeptOrgUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int iResult;
		StringBuffer returnMsg = new StringBuffer();
		String strGroupCode		= request.getParameter("GroupCode");		
		String strUserCodeList = StringUtil.replaceNull(request.getParameter("UserCodeList"), "");
		String moveDataArrUser[] = strUserCodeList.isEmpty() ? null : strUserCodeList.split(",");
		CoviMap params = new CoviMap();
		CoviMap returnData = new CoviMap();
		CoviMap oldUserInfo=null;
		CoviMap oldGroupInfo=null;
		try {
			returnData.put("status", Return.SUCCESS);

			params.put("GroupCode", strGroupCode);
			for(String strUserCode : moveDataArrUser){
				params.put("UserCode", strUserCode);
				oldUserInfo = (CoviMap)((CoviList) OrganizationManageSvc.selectUserInfo(params).get("list")).get(0);
				oldGroupInfo = (CoviMap)((CoviList) OrganizationManageSvc.selectUserGroupMailInfo(params).get("list")).get(0);
				
				iResult= OrganizationManageSvc.moveDeptOrgUser(params);

				if(iResult==0){
					if(returnMsg.length()>0) returnMsg.append(", ");
					returnMsg.append(oldUserInfo.getString("DisplayName"));
					continue;
				}
				setSubSystemUser(oldUserInfo ,oldGroupInfo, params);
			} 
			if(returnMsg.length()>0){
				returnData.put("status", Return.FAIL);
				returnData.put("message","오류 대상자 : "+returnMsg);
			}	
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getGroupinfo : 그룹 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */	
	@RequestMapping(value = "manage/conf/getGroupInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGroupinfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();

			params.put("GroupCode", gr_code);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectGroupInfo(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	/**
	 * getisduplicategroupcode : 임의그룹 중복 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getIsduplicateGroupcode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getisduplicategroupcode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGroupCode = request.getParameter("GroupCode");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("GroupCode", strGroupCode);
			
			returnList.put("list", OrganizationManageSvc.selectIsDuplicateGroupCode(params).get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	

	/**
	 * getisduplicatemail : 메일 주소 중복 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getIsduplicateMail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getisduplicatemail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strMailAddress = request.getParameter("MailAddress");
		String strCode = StringUtil.replaceNull(request.getParameter("Code"), "");
		
		// 값이 비어있을경우 NULL 값으로 전달	
		strCode = strCode.isEmpty() ? null : strCode;
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("MailAddress", strMailAddress);
			params.put("Code", strCode);
			
			returnList.put("list", OrganizationManageSvc.selectIsDuplicateMail(params).get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	/**
	 * insertGroupInfo : 그룹 정보 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/insertgroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertGroupInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{ 
		CoviMap returnList = new CoviMap();
		int result;
		int addStatus = 0;
		
		try {
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			String strGroupType = request.getParameter("GroupType");
			String strGroupCode = request.getParameter("GroupCode");
			String strDisplayName = request.getParameter("DisplayName");
			String strMultiDisplayName = request.getParameter("MultiDisplayName");
			String strShortName = request.getParameter("ShortName");
			String strMultiShortName = request.getParameter("MultiShortName");
			String strPrimaryMail = request.getParameter("PrimaryMail");
			String strCompanyCode = request.getParameter("CompanyCode");
			String strMemberOf = request.getParameter("MemberOf");
			String strIsUse = request.getParameter("IsUse");
			String strIsHR = request.getParameter("IsHR");
			String strIsMail = StringUtil.replaceNull(request.getParameter("IsMail"), "");
			String strSortKey = request.getParameter("SortKey");
			String strDescription = request.getParameter("Description");
			//String strRegID = request.getParameter("RegID");
			String strRegistDate = request.getParameter("RegistDate");
			String strEX_PrimaryMail = request.getParameter("EX_PrimaryMail");
			String strSecondaryMail = request.getParameter("SecondaryMail");
			String strCompanyName = request.getParameter("CompanyName");
			String strOUName = request.getParameter("OUName");
			
			String[] resultString = getGroupEtcInfo(strCompanyCode, strMemberOf).split("&");
			String strCompanyID = "";
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";
			if(resultString.length > 0) {
				strCompanyID = resultString[0];
				strGroupPath = resultString[1] + strGroupCode + ";";
				strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(strSortKey)) + ";";
				strOUPath = resultString[3] + strDisplayName;
			}
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			
			CoviMap params = new CoviMap();
			
			params.put("GroupType", strGroupType);
			params.put("CompanyID", strCompanyID);
			params.put("GroupCode", strGroupCode);
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");
			params.put("DisplayName", strDisplayName);
			params.put("MultiDisplayName", strMultiDisplayName);
			params.put("ShortName", strShortName);
			params.put("MultiShortName", strMultiShortName);
			params.put("PrimaryMail", strPrimaryMail);
			params.put("CompanyCode", strCompanyCode);
			params.put("MemberOf", strMemberOf);
			params.put("GroupPath", strGroupPath);
			params.put("OUPath", strOUPath);
			params.put("IsUse", strIsUse);
			params.put("IsDisplay", strIsUse);
			params.put("IsHR", strIsHR);
			params.put("IsMail", strIsMail);
			params.put("SortKey", strSortKey);
			params.put("SortPath", strSortPath);
			params.put("Description", strDescription);
			//params.put("RegID", strRegID);
			params.put("RegistDate", strRegistDate);
			params.put("EX_PrimaryMail", strEX_PrimaryMail);
			params.put("SecondaryMail", strSecondaryMail);
			params.put("CompanyName", strCompanyName);
			params.put("OUName", strOUName);
			result = OrganizationManageSvc.insertGroup(params);
			
			if(result ==0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
				return returnList;
			} 

			if(result!=0)returnList = setSubSystemGroup("ADD",strGroupCode,params);
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateGroupInfo : 그룹 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updategroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateGroupInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result;
		
		try {
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			
			String strGroupType = request.getParameter("GroupType");
			String strGroupCode = request.getParameter("GroupCode");
			String strDisplayName = request.getParameter("DisplayName");
			String strMultiDisplayName = request.getParameter("MultiDisplayName");
			String strShortName = request.getParameter("ShortName");
			String strMultiShortName = request.getParameter("MultiShortName");
			String strPrimaryMail = request.getParameter("PrimaryMail");
			String strCompanyCode = request.getParameter("CompanyCode");
			String strMemberOf = request.getParameter("MemberOf");
			String strIsUse = StringUtil.replaceNull(request.getParameter("IsUse"), "");
			String strIsHR = request.getParameter("IsHR");
			String strIsMail = StringUtil.replaceNull(request.getParameter("IsMail"), "");
			String strhidtxtUseMailConnect = request.getParameter("hidtxtUseMailConnect");
			String strSortKey = request.getParameter("SortKey");
			String strDescription = request.getParameter("Description");
			//String strModID = request.getParameter("RegID"); //수정 시, 해당 세션과 날짜의 값을 Reg로 받아와도 Mod로 저장될 수 있도록
			String strModifyDate = request.getParameter("RegistDate");
			String strEX_PrimaryMail = request.getParameter("EX_PrimaryMail");
			String strSecondaryMail = request.getParameter("SecondaryMail");
			String strCompanyName = request.getParameter("CompanyName");
			String strOUName = request.getParameter("OUName");
			
			String[] resultString = getGroupEtcInfo(strCompanyCode, strMemberOf).split("&");
			String strCompanyID = "";
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";

			if(resultString.length > 0) {
				strCompanyID = resultString[0];
				strGroupPath = resultString[1] + strGroupCode + ";";
				strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(strSortKey)) + ";";
				strOUPath = resultString[3] + strDisplayName;
			}
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			
			CoviMap params = new CoviMap();
			
			params.put("GroupType", strGroupType);
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");
			params.put("CompanyID", strCompanyID);
			params.put("GroupCode", strGroupCode);
			params.put("DisplayName", strDisplayName);
			params.put("MultiDisplayName", strMultiDisplayName);
			params.put("ShortName", strShortName);
			params.put("MultiShortName", strMultiShortName);
			params.put("PrimaryMail", strPrimaryMail);
			params.put("CompanyCode", strCompanyCode);
			params.put("MemberOf", strMemberOf);
			params.put("GroupPath", strGroupPath);
			params.put("OUPath", strOUPath);
			params.put("IsUse", strIsUse);
			params.put("IsDisplay", strIsUse);
			params.put("IsHR", strIsHR);
			params.put("IsMail", strIsMail);
			params.put("SortKey", strSortKey);
			params.put("SortPath", strSortPath);
			params.put("Description", strDescription);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModifyDate);
			params.put("EX_PrimaryMail", strEX_PrimaryMail);
			params.put("SecondaryMail", strSecondaryMail);
			params.put("CompanyName", strCompanyName);
			params.put("OUName", strOUName);
			params.put("gr_code", strGroupCode);
			String sOldIsUse = "";
			CoviList arrGroupList = (CoviList) OrganizationManageSvc.selectDeptInfo(params).get("list");
			sOldIsUse = StringUtil.replaceNull(arrGroupList.getJSONObject(0).getString("IsUse"), "");
			if("N".equals(strIsUse) && "Y".equals(sOldIsUse)){
				if(getHasChildGroup(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupName|" + strDisplayName);
					return returnList;
				} else if(getHasUserGroup(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + strDisplayName);
					return returnList;
				}
				else if(getHasGroupMember(strGroupCode)) {
					returnList.put("reason", "EXIST_INFO");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupMember|" + strDisplayName);
					return returnList;
				}
			}
				
			result = OrganizationManageSvc.updateGroup(params);
			if(result==0){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
				return returnList;
			}
			
			
			setSubSystemGroup("MODIFY",strGroupCode,params);
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/**
	 * addGroupMember : 그룹 구성원 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/addGroupMember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addGroupMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		String strGroupCode = StringUtil.replaceNull(request.getParameter("GroupCode"), "");
		String strURList = StringUtil.replaceNull(request.getParameter("URList"), "");
		String strGRList = StringUtil.replaceNull(request.getParameter("GRList"), "");
		
		try {
			CoviMap params = new CoviMap();
			
			strGroupCode = strGroupCode.isEmpty() ? null : strGroupCode;
			
			String URList = strURList.isEmpty() ? null : strURList;
			String GRList = strGRList.isEmpty() ? null : strGRList;
			
			params.put("GroupCode", strGroupCode);
			params.put("URList", URList);
			params.put("GRList", GRList);
									
			returnList.put("object", OrganizationManageSvc.addGroupMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteGroupMember : 그룹 멤버 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteGroupMember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteGroupMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteUser = StringUtil.replaceNull(request.getParameter("TargetUser"), "");
		String strDeleteGroup = StringUtil.replaceNull(request.getParameter("TargetGroup"), "");
		
		try {
			CoviMap params = new CoviMap();
			
			String DeleteDataArrUser[] = strDeleteUser.isEmpty() ? null : strDeleteUser.split(",");
			String DeleteDataArrGroup[] = strDeleteGroup.isEmpty() ? null : strDeleteGroup.split(",");
			
			params.put("deleteDataUser", DeleteDataArrUser);
			params.put("deleteDataGroup", DeleteDataArrGroup);
						
			returnList.put("object", OrganizationManageSvc.deleteGroupMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//겸직
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * getGroupTreeList : 겸직 목록 select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectAddJobList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectAddJobList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");		
		
		String searchType = request.getParameter("searchType");		
		String searchText = request.getParameter("searchText");		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();
				 
		try{
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("domainId", domainId);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : searchText);
			returnObj = OrganizationManageSvc.selectAddJobList(params);
			returnObj.put("result", "ok");
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	

	//겸직 정보 select
	@RequestMapping(value = "manage/conf/selectAddJobInfoData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectAddJobInfoData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strID = request.getParameter("id");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("id", strID);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectAddJobInfoData(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * selectArbitraryGroupDropdownlist : 조직관리 - 임의그룹 드롭다운 목록(직위,직책,직급)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectArbitraryGroupDropdownlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectArbitraryGroupDropdownlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strcompanyCode = request.getParameter("companyCode");
		

		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("CompanyCode", strcompanyCode);
		params.put("lang", SessionHelper.getSession("lang"));
		CoviMap listData = OrganizationManageSvc.selectArbitraryGroupDropdownlist(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
	
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	

	/**
	 * registaddjob : 겸직 추가
	 * @param req
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */		
	@RequestMapping(value="manage/conf/insertAddJob.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap insertAddJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		int cnt = 0;
		CoviMap params = null;
		CoviMap returnObj = null;
		Boolean bDept = true;
		Boolean bJTitle = true;
		Boolean bJPosition = true;
		Boolean bJLevel = true;
		try {			
			
			returnObj = new CoviMap();
			params = new CoviMap();
			String strMode = request.getParameter("Mode");  //add
			String strType = request.getParameter("Type");  //AddJob
			String strUserCode = request.getParameter("UserCode");  //sunnyhwang			
			String strAddJob_Company = request.getParameter("AddJob_Company");  //null
			String strAddJob_Group = request.getParameter("AddJob_Group");  //RD02
			String strAddJob_Title = request.getParameter("AddJob_Title");  //1_T000
			String strAddJob_Position = request.getParameter("AddJob_Position");  //1_P000
			String strAddJob_Level = request.getParameter("AddJob_Level");  //1_L000
			
			String strAddJob_TitleName = request.getParameter("AddJob_TitleName");  //대리
			String strAddJob_PositionName = request.getParameter("AddJob_PositionName");  //팀원
			String strAddJob_LevelName = request.getParameter("AddJob_LevelName");  //대리
			
			String stroldAddJob_Company = request.getParameter("oldAddJob_Company");  //null
			String stroldAddJob_Group = request.getParameter("oldAddJob_Group");  //RD02
			String stroldAddJob_Title = request.getParameter("oldAddJob_Title");  //1_T000
			String stroldAddJob_Position = request.getParameter("oldAddJob_Position");  //1_P000
			String stroldAddJob_Level = request.getParameter("oldAddJob_Level");  //1_L000
			String strIsHR = request.getParameter("IsHR");  //Y
			String strID = request.getParameter("id");  //null
								
			//params.put("UserCode", strRegistUR_Code);
			params.put("SyncManage", "Manage");
			params.put("SyncType", "ADD".equals(strMode) ? "INSERT" : "UPDATE");
			params.put("JobType", "AddJob");
			params.put("Mode", strMode);
			params.put("Type", strType);
			params.put("UserCode", strUserCode);
			params.put("LogonID", strUserCode);
			params.put("AddJob_Company", strAddJob_Company);
			params.put("AddJob_Group", strAddJob_Group);
			params.put("AddJob_Title", strAddJob_Title);
			params.put("AddJob_Position",  strAddJob_Position);
			params.put("AddJob_Level", strAddJob_Level);
			params.put("CompanyCode", strAddJob_Company);
			params.put("DeptCode", strAddJob_Group);
			params.put("JobTitleCode", strAddJob_Title);
			params.put("JobPositionCode",  strAddJob_Position);
			params.put("JobLevelCode", strAddJob_Level);			
			params.put("oldAddJob_Company", stroldAddJob_Company);
			params.put("oldAddJob_Group", stroldAddJob_Group);
			params.put("oldAddJob_Title", stroldAddJob_Title);
			params.put("oldAddJob_Position",  stroldAddJob_Position);
			params.put("oldAddJob_Level", stroldAddJob_Level);
			params.put("IsHR", strIsHR);
			params.put("SortKey", 0);
			params.put("id", strID);
			params.put("Seq", strID);
			params.put("mailStatus", "A");
			params.put("DecLogonPassword", "");
			
			//본직 정보
			CoviList arrresultList = (CoviList) OrganizationManageSvc.selectUserInfo(params).get("list");
			String strOriginLogonID =arrresultList.getJSONObject(0).getString("LogonID");
			String strOriginDisplayName =arrresultList.getJSONObject(0).getString("DisplayName");
			String strOriginDeptCode =arrresultList.getJSONObject(0).getString("DeptCode");
			String strOriginPhoneNumber =arrresultList.getJSONObject(0).getString("PhoneNumber");
			String strOriginPhoneNumberInter =arrresultList.getJSONObject(0).getString("PhoneNumberInter");
			String strOriginSortKey =arrresultList.getJSONObject(0).getString("SortKey");
			String strOriginMailAddress = arrresultList.getJSONObject(0).getString("MailAddress");
			String strOriginAD_SamAccountName = arrresultList.getJSONObject(0).getString("AD_SamAccountName");
			
			CoviMap params2 = new CoviMap();
			
			params2.put("GroupCode", strAddJob_Group);
			params2.put("LogonID", strOriginLogonID);
			params2.put("DisplayName", strOriginDisplayName);
			params2.put("OriginGroupCode", strOriginDeptCode);
			params2.put("IsUse", "Y");
			params2.put("SortKey", strOriginSortKey);
			params2.put("JobTitleCode", strAddJob_Title);
			params2.put("JobTitleName", strAddJob_TitleName);
			params2.put("JobPositionCode", strAddJob_Position);
			params2.put("JobPositionName", strAddJob_PositionName);
			params2.put("JobLevelCode", strAddJob_Level);
			params2.put("JobLevelName", strAddJob_LevelName);
			params2.put("PhoneNumberInter", strOriginPhoneNumberInter);
			params2.put("PhoneNumber", strOriginPhoneNumber);
			 
			if( strMode!= null && strMode.toUpperCase().equals("ADD") ){
				cnt  = OrganizationManageSvc.insertAddjob(params);
				
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");
				}
				
				if(cnt != 0){
					//인디메일 겸직 연동
					try {
						CoviMap reObject = null;
						if(OrganizationManageSvc.getIndiSyncTF()) {
							params.put("DisplayName", strOriginDisplayName);
							params.put("MailAddress", strOriginMailAddress);
							reObject = OrganizationManageSvc.getIndiMailUserStatus(params);
							if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
								
								String sGroupMail = "";
								
								if(!(strAddJob_Group == null || strAddJob_Group.equals("") || strAddJob_Group.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Group == null || stroldAddJob_Group.equals("") || stroldAddJob_Group.equalsIgnoreCase("undefined"))) {
									params.put("GroupCode",strAddJob_Group);
									sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", "");
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Position == null || stroldAddJob_Position.equals("") || stroldAddJob_Position.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Position.isEmpty()) {
										params.put("GroupCode",strAddJob_Position);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", "");
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Title == null || stroldAddJob_Title.equals("") || stroldAddJob_Title.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Title.isEmpty()) {
										params.put("GroupCode",strAddJob_Title);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", "");
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Level == null || stroldAddJob_Level.equals("") || stroldAddJob_Level.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Level.isEmpty()) {
										params.put("GroupCode",strAddJob_Level);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", "");
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
						}
					} catch (NullPointerException e){
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(OrganizationManageSvc.getTSSyncTF()) {
						cnt = OrganizationManageSvc.insertUpdateAddJobSync(params2);							
					}
					
					//AD 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
							//사용자 비활성화
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.adAddAddJob(strUserCode,strAddJob_Company,strAddJob_Group,strAddJob_Position,strAddJob_Title,strAddJob_Level,strOriginAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnObj.put("result", "FAIL");
								returnObj.put("message", " [AD] " + resultList.getString("Reason"));
								return returnObj;
							}
						}
					} catch (NullPointerException e){
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					}catch(Exception e){
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					}
				}
			}else{				
				//겸직 수정
				cnt  = OrganizationManageSvc.updateAddjob(params);
				
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");
				}
				
				if(cnt != 0){
					//인디메일 겸직 연동
					try {
						CoviMap reObject = null;
						if(OrganizationManageSvc.getIndiSyncTF()) {
							params.put("DisplayName", strOriginDisplayName);
							params.put("MailAddress", strOriginMailAddress);
							reObject = OrganizationManageSvc.getIndiMailUserStatus(params);
							if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
								CoviList listUserGroupInfo = (CoviList) OrganizationManageSvc.selectUserGroupList(params).get("list");
								for (int j = 0; j < listUserGroupInfo.size(); j++) {
									String strGroupCode = listUserGroupInfo.getMap(j).getString("groupCode");
									if(bDept&&strGroupCode.equals(stroldAddJob_Group))bDept = false;
									if(bJPosition&&strGroupCode.equals(stroldAddJob_Position))bJPosition = false;
									if(bJTitle&&strGroupCode.equals(stroldAddJob_Title))bJTitle = false;
									if(bJLevel&&strGroupCode.equals(stroldAddJob_Level))bJLevel = false;
									if(!bDept&&!bJPosition&&!bJTitle&&!bJLevel)
										break;
								}
								
								String sGroupMail, sOldGroupMail = "";
								
								if(!(strAddJob_Group == null || strAddJob_Group.equals("") || strAddJob_Group.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Group == null || stroldAddJob_Group.equals("") || stroldAddJob_Group.equalsIgnoreCase("undefined"))) {
									params.put("GroupCode",strAddJob_Group);
									sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									params.put("GroupCode",stroldAddJob_Group);
									sOldGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									sOldGroupMail = bDept?sOldGroupMail:"";
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Position == null || stroldAddJob_Position.equals("") || stroldAddJob_Position.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Position.isEmpty()) {
										params.put("GroupCode",strAddJob_Position);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									if(!stroldAddJob_Position.isEmpty()) {
										params.put("GroupCode",stroldAddJob_Position);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJPosition?sOldGroupMail:"";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Title == null || stroldAddJob_Title.equals("") || stroldAddJob_Title.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Title.isEmpty()) {
										params.put("GroupCode",strAddJob_Title);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									if(!stroldAddJob_Title.isEmpty()) {
										params.put("GroupCode",stroldAddJob_Title);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJTitle?sOldGroupMail:"";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined")) 
										|| !(stroldAddJob_Level == null || stroldAddJob_Level.equals("") || stroldAddJob_Level.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Level.isEmpty()) {
										params.put("GroupCode",strAddJob_Level);
										sGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sGroupMail = "";
									if(!stroldAddJob_Level.isEmpty()) {
										params.put("GroupCode",stroldAddJob_Level);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJLevel?sOldGroupMail:"";
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
						}
					} catch (NullPointerException e){
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(OrganizationManageSvc.getTSSyncTF()) {						
						params2.put("GroupCode", strAddJob_Group);
						params2.put("LogonID", strOriginLogonID);		
						params2.put("DisplayName", strOriginDisplayName);		
						params2.put("OriginGroupCode", strOriginDeptCode);							
						params2.put("IsUse", "Y");
						params2.put("SortKey", strOriginSortKey);		
						params2.put("JobTitleCode", strAddJob_Title);
						params2.put("JobTitleName", strAddJob_TitleName);	
						params2.put("JobPositionCode", strAddJob_Position);
						params2.put("JobPositionName", strAddJob_PositionName);
						params2.put("JobLevelCode", strAddJob_Level);
						params2.put("JobLevelName", strAddJob_LevelName);			
						params2.put("PhoneNumberInter", strOriginPhoneNumberInter);
						params2.put("PhoneNumber", strOriginPhoneNumber);																		
						cnt = OrganizationManageSvc.insertUpdateAddJobSync(params2);							
					}
					
					//AD 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
							//사용자 비활성화
							CoviMap resultList = new CoviMap();
							CoviMap resultList2 = orgADSvc.adDeleteAddJob(strUserCode,strAddJob_Company,strAddJob_Group,strAddJob_Position,strAddJob_Title,strAddJob_Level,strOriginAD_SamAccountName,"Manage","");
							
							if(Boolean.valueOf((String) resultList2.getString("result"))){ //성공
								resultList = orgADSvc.adAddAddJob(strUserCode,strAddJob_Company,strAddJob_Group,strAddJob_Position,strAddJob_Title,strAddJob_Level,strOriginAD_SamAccountName,"Manage","");
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
									returnObj.put("result", "FAIL");
									returnObj.put("message", " [AD] " + resultList.getString("Reason"));
									return returnObj;
								}
							} else {//실패
								returnObj.put("result", "FAIL");
								returnObj.put("message", " [AD] " + resultList.getString("Reason"));
								return returnObj;
							}
						}
					} catch (NullPointerException e){
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					} catch(Exception e) {
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					}
				}
			}
			return returnObj;
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	
	/**
	 * deleteaddjob : 겸직 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/conf/deleteAddJob.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteAddJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int result=0;
		String   NOTemp	= null; 
		String[] NO		= null;
		CoviMap params = null;
		CoviMap returnData = new CoviMap();
		Boolean bDept = true;
		Boolean bJTitle = true;
		Boolean bJPosition = true;
		Boolean bJLevel = true;
		try {
			params = new CoviMap();
			
			NOTemp		= StringUtil.replaceNull(request.getParameter("NO"), "");
			NO			= NOTemp.split(",");
			
			params.put("TargetID",NO);
			
			int max = NO.length;
			for (int i = 0; i < max; i++) {				
				bDept = true;
				bJTitle = true;
				bJPosition = true;
				bJLevel = true;
				
				CoviMap params2 = new CoviMap();				
				params2.put("Seq",NO[i]);
				CoviList arrresultList = (CoviList) OrganizationManageSvc.selectAddJobInfoList(params2).get("list");
				params2.put("UserCode", arrresultList.getJSONObject(0).getString("UserCode"));
				params2.put("SyncManage", "Manage");
				params2.put("SyncType","DELETE");
				params2.put("CompanyCode", arrresultList.getJSONObject(0).getString("CompanyCode"));
				
				CoviList arrresultList2 = (CoviList) OrganizationManageSvc.selectUserInfo(params2).get("list");
				String strUR_Code =arrresultList.getJSONObject(0).getString("UserCode"); 
				String strAddJob_Company =arrresultList.getJSONObject(0).getString("CompanyCode");
				String strAddJob_Group =arrresultList.getJSONObject(0).getString("DeptCode");
				String strAddJob_Position =arrresultList.getJSONObject(0).getString("JobPositionCode");
				String strAddJob_Title =arrresultList.getJSONObject(0).getString("JobTitleCode");
				String strAddJob_Level =arrresultList.getJSONObject(0).getString("JobLevelCode");				
				String strAddJob_PositionName =arrresultList.getJSONObject(0).getString("JobPositionName");
				String strAddJob_TitleName =arrresultList.getJSONObject(0).getString("JobTitleName");
				String strAddJob_LevelName =arrresultList.getJSONObject(0).getString("JobLevelName");							
				String strOriginLogonID =arrresultList2.getJSONObject(0).getString("LogonID");
				String strOriginDisplayName =arrresultList2.getJSONObject(0).getString("DisplayName");
				String strOriginDeptCode =arrresultList2.getJSONObject(0).getString("DeptCode");
				String strOriginPhoneNumber =arrresultList2.getJSONObject(0).getString("PhoneNumber");
				String strOriginPhoneNumberInter =arrresultList2.getJSONObject(0).getString("PhoneNumberInter");
				String strOriginSortKey =arrresultList2.getJSONObject(0).getString("SortKey");
				String strOriginAD_SamAccountName = arrresultList2.getJSONObject(0).getString("AD_SamAccountName");
				String strOriginMailAddress = arrresultList2.getJSONObject(0).getString("MailAddress");
				
				result = OrganizationManageSvc.deleteAddjob(params2);
				
				CoviMap params3 = new CoviMap();						
				params3.put("GroupCode", strAddJob_Group);
				params3.put("LogonID", strOriginLogonID);		
				params3.put("DisplayName", strOriginDisplayName);		
				params3.put("OriginGroupCode", strOriginDeptCode);
				
				if(result > 0) {
					returnData.put("data", result);
					returnData.put("result", "ok");
					returnData.put("status", Return.SUCCESS);
					returnData.put("message", "조회되었습니다");
				} else {
					returnData.put("result", "ok");
					returnData.put("status", Return.FAIL);
				}
				
				if(result != 0){
					//인디메일 겸직 연동
					try {
						CoviMap reObject = null;
						if(OrganizationManageSvc.getIndiSyncTF()) {
							params2.put("DisplayName", strOriginDisplayName); 
							params2.put("MailAddress", strOriginMailAddress);
							params2.put("mailStatus", "A");
							params2.put("DecLogonPassword", "");
							reObject = OrganizationManageSvc.getIndiMailUserStatus(params2);
							if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
								CoviList listUserGroupInfo = (CoviList) OrganizationManageSvc.selectUserGroupList(params2).get("list");
								for (int j = 0; j < listUserGroupInfo.size(); j++) {
									String strGroupCode = listUserGroupInfo.getMap(j).getString("groupCode");
									if(bDept&&strGroupCode.equals(strAddJob_Group))bDept = false;
									if(bJPosition&&strGroupCode.equals(strAddJob_Position))bJPosition = false;
									if(bJTitle&&strGroupCode.equals(strAddJob_Title))bJTitle = false;
									if(bJLevel&&strGroupCode.equals(strAddJob_Level))bJLevel = false;
									if(!bDept&&!bJPosition&&!bJTitle&&!bJLevel)
										break;
								}
								
								String sOldGroupMail = "";
								
								if(!(strAddJob_Group == null || strAddJob_Group.equals("") || strAddJob_Group.equalsIgnoreCase("undefined"))) {
									params2.put("GroupCode",strAddJob_Group);
									sOldGroupMail = OrganizationManageSvc.selectGroupMail(params2); // 그룹의 메일주소
									sOldGroupMail = bDept?sOldGroupMail:"";
									
									params2.put("GroupMailAddress", "");
									params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params2);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Position.isEmpty()) {
										params2.put("GroupCode",strAddJob_Position);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params2); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJPosition?sOldGroupMail:"";
									
									params2.put("GroupMailAddress", "");
									params2.put("oldGroupMailAddress", sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params2);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Title.isEmpty()) {
										params2.put("GroupCode",strAddJob_Title);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params2); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJTitle?sOldGroupMail:"";
									
									params2.put("GroupMailAddress", "");
									params2.put("oldGroupMailAddress", sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params2);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
								if(!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined"))) {
									if(!strAddJob_Level.isEmpty()) {
										params2.put("GroupCode",strAddJob_Level);
										sOldGroupMail = OrganizationManageSvc.selectGroupMail(params2); // 그룹의 메일주소
									} else sOldGroupMail = "";
									sOldGroupMail = bJLevel?sOldGroupMail:"";
									
									params2.put("GroupMailAddress", "");
									params2.put("oldGroupMailAddress", sOldGroupMail);
									
									reObject = OrganizationManageSvc.modifyUser(params2);
									if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
						}
					} catch (NullPointerException e){
						returnData.put("status", Return.FAIL);
						returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnData.put("status", Return.FAIL);
						returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(OrganizationManageSvc.getTSSyncTF()) {
						params3.put("IsUse", "N");
						params3.put("SortKey", strOriginSortKey);		
						params3.put("JobTitleCode", strAddJob_Title);
						params3.put("JobTitleName", strAddJob_TitleName);	
						params3.put("JobPositionCode", strAddJob_Position);
						params3.put("JobPositionName", strAddJob_PositionName);
						params3.put("JobLevelCode", strAddJob_Level);
						params3.put("JobLevelName", strAddJob_LevelName);			
						params3.put("PhoneNumberInter", strOriginPhoneNumberInter);
						params3.put("PhoneNumber", strOriginPhoneNumber);																		
						result = OrganizationManageSvc.insertUpdateAddJobSync(params3);							
					}
										
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){	
						CoviMap resultList2 = new CoviMap();
						resultList2 = orgADSvc.adDeleteAddJob(strUR_Code,strAddJob_Company,strAddJob_Group,strAddJob_Position,strAddJob_Title,strAddJob_Level,strOriginAD_SamAccountName,"Manage","");
						
						if(!Boolean.valueOf((String) resultList2.getString("result"))){ //실패
							returnData.put("result", "FAIL");
							returnData.put("message", " [AD] " + resultList2.getString("Reason"));
							return returnData;
						}
						
					}
				}				
			}
		} catch (NullPointerException e){
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//사용자관리
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * getUserList : 조직도 - 사용자 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectUserList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectUserList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");		
		String groupCode = request.getParameter("groupCode");	
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		
		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		 
		
		try{
		
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));

			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));	
			params.put("domainId", domainId);
			params.put("groupCode", groupCode);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : ComUtils.RemoveSQLInjection(searchText, 100));
			//params.put("rownumOrderby", strSortColumn +" "+ strSortDirection + ", (JobTitleSortKey +0) ASC, (JobLevelSortKey+0) ASC, EnterDate ASC, MultiDisplayName ASC"); // mssql 페이징처리용
			
			returnList = (CoviMap)OrganizationManageSvc.selectUserList(params);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "manage/conf/selectUserInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectUserInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String UserCode = request.getParameter("UserCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("UserCode", UserCode);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectUserInfo(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * insertUpdateUserInfo : 사용자 정보 추가/수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/insertUpdateUserInfo.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap insertUpdateUserInfo(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap returnSubSystem = new CoviMap();
		StringBuffer returnMsg = new StringBuffer();
		try {
			//String strDomainId = req.getParameter("domainId");
			String strInitPW = req.getParameter("InitPW");
			String strMode = req.getParameter("mode");
			MultipartFile fileInfo = req.getFile("FileInfo");
			String strNickName = req.getParameter("Initials");
			String strCountry = req.getParameter("Country");
			String strCityState_01 = req.getParameter("CityState_01");
			String strCityState_02 = req.getParameter("CityState_02");
			String strAddress = req.getParameter("Address");
			String strZipCode = req.getParameter("ZipCode");
			String strRealAddress = "(우. " + strZipCode + ") " + strAddress; //+ strCountry + " " + strCityState_01 + " " + strCityState_02 + " " 
			String strMultiAddress = "(우. " + strZipCode + ") " + strAddress + ";;;;;;;;;"; //+ strCountry + " " + strCityState_01 + " " + strCityState_02 + " " 
			String strHomePage = req.getParameter("WebPage");
			String strPhoneNumber = req.getParameter("PhoneNumber");
			String strMobile = req.getParameter("Mobile");
			String strFax = req.getParameter("Fax");
			String strIPPhone = req.getParameter("HomePhone");
			String strUseMessengerConnect = req.getParameter("UseMessengerConnect");
			String strSecurityLevel = req.getParameter("SecurityLevel");
			String strUseMailConnect = req.getParameter("UseMailConnect");
			String strLicSeq = req.getParameter("LicSeq");
			String strMailAddress = req.getParameter("MailAddress");
			String strChargeBusiness = req.getParameter("ChargeBusiness");
			String strLanguageCode = SessionHelper.getSession("lang"); //ko
			String strRegistDate = req.getParameter("RegistDate");
			String strJobType = "Origin";
			String strBaseGroupSortKey = "0";
			String strCompanyName = req.getParameter("CompanyName");
			String strDeptName = req.getParameter("DeptName");
			String strRegionName = req.getParameter("RegionName");
			/*********추가 DB 기본 정보**********/
			String strUserCode = req.getParameter("UserCode");
			//DN_ID
			String strCompanyCode = req.getParameter("CompanyCode");
			String strDeptCode = req.getParameter("DeptCode");
			String stroldDeptCode = req.getParameter("oldDeptCode");
			String stroldCompanyCode = req.getParameter("oldCompanyCode");
			String strLogonID = req.getParameter("LogonID");
			String strDecLogonPassword = req.getParameter("Password");
			String strEmpNo = req.getParameter("EmpNo");
			String strDisplayName = req.getParameter("DisplayName");
			String strMultiDisplayName = req.getParameter("MultiDisplayName");
			//ExGroupName
			String strRegionCode = req.getParameter("RegionCode");
			//ExRegionName
			String strJobPositionCode = req.getParameter("JobPositionCode");
			String strJobPositionName = req.getParameter("JobPositionName");
			String strJobTitleCode = req.getParameter("JobTitleCode");
			String strJobTitleName = req.getParameter("JobTitleName");
			String strJobLevelCode = req.getParameter("JobLevelCode");
			String strJobLevelName = req.getParameter("JobLevelName");
			String strSortKey = req.getParameter("SortKey");
			//Description
			String strIsUse = req.getParameter("IsUse");
			String strIsHR = req.getParameter("IsHR");
			String strEnterDate = req.getParameter("EnterDate");
			String strRetireDate = req.getParameter("RetireDate");
			String strPhotoPath = req.getParameter("PhotoPath");
			String strIsDisplay = req.getParameter("IsDisplay");
			String strBirthDiv = req.getParameter("BirthDiv");
			String strBirthDate = req.getParameter("BirthDate");
			String strExternalMailAddress = req.getParameter("ExtMail");
			String strDescription = req.getParameter("Role"); // ??
			String strPhoneNumberInter = req.getParameter("PhoneNumberInter");
			String strCheckUserIP = req.getParameter("CheckUserIP");
			String strStartIP = req.getParameter("StartIP");
			String strEndIP= req.getParameter("EndIP");
			String strIsCRM = req.getParameter("IsCRM");
			String strMobileThemeCode = "MobileTheme_Base";
			String strTimeZoneCode = "TIMEZO0048";
			String strReserved1 = req.getParameter("Reserved1");
			String strReserved2 = req.getParameter("Reserved2");
			String strReserved3 = req.getParameter("Reserved3");
			String strReserved4 = req.getParameter("Reserved4");
			String strReserved5 = req.getParameter("Reserved5");

			/*********추가 AD **********/
			String strAD_IsUse = req.getParameter("IsAD");
			String strAD_CN = req.getParameter("AD_CN");
			String strAD_UserPrincipalName = req.getParameter("AD_UserPrincipalName");
			String strAD_SamAccountName = req.getParameter("AD_SamAccountName");
			String strAD_DisplayName = req.getParameter("AD_DisplayName");
			String strAD_FirstName = req.getParameter("FirstName");
			String strAD_LastName = req.getParameter("LastName");
			String strAD_Initials = req.getParameter("Initials");
			String strAD_Office = req.getParameter("OfficeAddress");
			String strAD_HomePage = req.getParameter("WebPage");
			String strAD_Country = req.getParameter("Country");
			String strAD_CountryID = req.getParameter("AD_CountryID");
			String strAD_CountryCode = req.getParameter("AD_CountryCode");
			String strAD_State = req.getParameter("CityState_01");
			String strAD_City = req.getParameter("CityState_02");
			String strAD_StreetAddress = req.getParameter("Address");
			String strAD_PostOfficeBox = req.getParameter("MailBox");
			String strAD_PostalCode = req.getParameter("ZipCode");
			String strAD_UserAccountControl = req.getParameter("AD_UserAccountControl");
			String strAD_AccountExpires = req.getParameter("AD_AccountExpires");
			String strAD_PhoneNumber = req.getParameter("PhoneNumber");
			String strAD_HomePhone = req.getParameter("HomePhone");
			String strAD_Pager = req.getParameter("AD_Pager");
			String strAD_Mobile = req.getParameter("Mobile");
			String strAD_Fax = req.getParameter("Fax");
			String strAD_Info = req.getParameter("AD_Info");
			String strAD_Title = req.getParameter("AD_Title");
			String strAD_Department = req.getParameter("DeptName");
			String strAD_Company = req.getParameter("CompanyName");
			String strAD_ManagerCode = req.getParameter("ManagerCode");
			/*********추가 Exchange **********/
			String strEX_IsUse = req.getParameter("EX_IsUse");
			String strO365_IsUse = req.getParameter("O365_IsUse");
			String strEX_PrimaryMail = req.getParameter("EX_PrimaryMail");
			String strEX_SecondaryMail = req.getParameter("EX_SecondaryMail");
			String strEX_StorageServer = req.getParameter("EX_StorageServer");
			String strEX_StorageGroup = req.getParameter("EX_StorageGroup");
			String strEX_StorageStore = req.getParameter("hidEX_StorageStore");
			String strEX_CustomAttribute01 = req.getParameter("EX_CustomAttribute01");
			String strEX_CustomAttribute02 = req.getParameter("EX_CustomAttribute02");
			String strEX_CustomAttribute03 = req.getParameter("EX_CustomAttribute03");
			String strEX_CustomAttribute04 = req.getParameter("EX_CustomAttribute04");
			String strEX_CustomAttribute05 = req.getParameter("EX_CustomAttribute05");
			String strEX_CustomAttribute06 = req.getParameter("EX_CustomAttribute06");
			String strEX_CustomAttribute07 = req.getParameter("EX_CustomAttribute07");
			String strEX_CustomAttribute08 = req.getParameter("EX_CustomAttribute08");
			String strEX_CustomAttribute09 = req.getParameter("EX_CustomAttribute09");
			String strEX_CustomAttribute10 = req.getParameter("EX_CustomAttribute10");
			String strEX_CustomAttribute11 = req.getParameter("EX_CustomAttribute11");
			String strEX_CustomAttribute12 = req.getParameter("EX_CustomAttribute12");
			String strEX_CustomAttribute13 = req.getParameter("EX_CustomAttribute13");
			String strEX_CustomAttribute14 = req.getParameter("EX_CustomAttribute14");
			String strEX_CustomAttribute15 = req.getParameter("EX_CustomAttribute15");
			/*********추가 Messenger **********/
			String strMSN_IsUse = req.getParameter("IsMSG");
			String strMSN_PoolServerName = req.getParameter("MSN_PoolServerName");
			String strMSN_PoolServerDN = req.getParameter("MSN_PoolServerDN");
			String strMSN_SIPAddress = req.getParameter("MSN_SIPAddress");
			String strMSN_Anonmy = req.getParameter("MSN_Anonmy");
			String strMSN_MeetingPolicyName = req.getParameter("ServiceType");
			String strMSN_MeetingPolicyDN = req.getParameter("MSN_MeetingPolicyDN");
			String strMSN_PhoneCommunication = req.getParameter("TelephonyOptions");
			String strMSN_PBX = req.getParameter("MSN_PBX");
			String strMSN_LinePolicyName = req.getParameter("MSN_LinePolicyName");
			String strMSN_LinePolicyDN = req.getParameter("MSN_LinePolicyDN");
			String strMSN_LineURI = req.getParameter("MSN_LineURI");
			String strMSN_LineServerURI = req.getParameter("MSN_LineServerURI");
			String strMSN_Federation = req.getParameter("MSN_Federation");
			String strMSN_RemoteAccess = req.getParameter("MSN_RemoteAccess");
			String strMSN_PublicIMConnectivity = req.getParameter("MSN_PublicIMConnectivity");
			String strMSN_InternalIMConversation = req.getParameter("MSN_InternalIMConversation");
			String strMSN_FederatedIMConversation = req.getParameter("MSN_FederatedIMConversation");
			/*********추가 Approval **********/
			String strUseDeputy = req.getParameter("IsDeputy");
			String strDeputyOption = req.getParameter("DeputyOption");
			String strDeputyCode = req.getParameter("DeputyApprovalCode");
			String strDeputyName = req.getParameter("DeputyApprovalName");
			String strDeputyFromDate = req.getParameter("DeputyDateStart");
			String strDeputyToDate = req.getParameter("DeputyDateEnd");
			String strApprovalArrival_YN = req.getParameter("ApprovalArrival_YN");
			String strAlertConfig = req.getParameter("CompleteApprovalType");
			String strUseApprovalPassword = "N";	
			String strApprovalCode = req.getParameter("UserCode");
			String strApprovalFullCode = req.getParameter("UserCode");
			String strApprovalFullName = req.getParameter("DisplayName");
			String strUseApprovalMessageBoxView = req.getParameter("CompleteYN");
			String strApprovalUnitCode = req.getParameter("ApprovalDeptCode");
			String strReceiptUnitCode = req.getParameter("ReceiptDeptCode");
			String strUseMobile = req.getParameter("IsPhoneApproval");			
			
			if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && strAD_IsUse.equals("Y"))
				strMailAddress = strEX_PrimaryMail;
			
			CoviMap params = new CoviMap();
			params.put("InitPW", strInitPW);
			params.put("ObjectCode", strUserCode);
			params.put("ObjectType", "UR");
			params.put("IsSync", strIsHR);
			params.put("SyncManage", "Manage");
			
			params.put("UserCode", strUserCode);
			params.put("LogonID", strLogonID);
			//params.put("LogonPassword", strLogonPassword);
			params.put("LogonPassword", strDecLogonPassword);
			params.put("DecLogonPassword", strDecLogonPassword);
			params.put("EmpNo", strEmpNo);
			params.put("NickName", strNickName);
			params.put("DisplayName", strDisplayName);
			params.put("MultiDisplayName", strMultiDisplayName);
			params.put("Address", strRealAddress);
			params.put("MultiAddress", strMultiAddress);
			params.put("HomePage", strHomePage);
			params.put("PhoneNumber", strPhoneNumber);
			params.put("Mobile", strMobile);
			params.put("Fax", strFax);
			params.put("IPPhone", strIPPhone);
			params.put("UseMessengerConnect", strUseMessengerConnect);
			params.put("SortKey", strSortKey);
			params.put("SecurityLevel", strSecurityLevel);
			params.put("Description", strDescription);
			params.put("IsUse", strIsUse);
			params.put("IsHR", strIsHR);
			params.put("IsDisplay", strIsDisplay);
			params.put("EnterDate", strEnterDate);
			params.put("PhotoPath", strPhotoPath);
			params.put("FileInfo", fileInfo);
			params.put("RetireDate", strRetireDate);
			params.put("BirthDiv", strBirthDiv);
			params.put("BirthDate", strBirthDate);
			params.put("UseMailConnect", strUseMailConnect);
			params.put("LicSeq", strLicSeq);
			params.put("MailAddress", strMailAddress);
			params.put("ExternalMailAddress", strExternalMailAddress);
			params.put("ChargeBusiness", strChargeBusiness);
			params.put("PhoneNumberInter", strPhoneNumberInter);
			params.put("LanguageCode", strLanguageCode);
			params.put("CheckUserIP", strCheckUserIP);
			params.put("StartIP", strStartIP);
			params.put("EndIP", strEndIP);
			params.put("IsCRM", strIsCRM);
			params.put("MobileThemeCode", strMobileThemeCode);
			params.put("TimeZoneCode", strTimeZoneCode);
			params.put("RegistDate", strRegistDate);
			params.put("Reserved1", strReserved1);
			params.put("Reserved2", strReserved2);
			params.put("Reserved3", strReserved3);
			params.put("Reserved4", strReserved4);
			params.put("Reserved5", strReserved5);
			
			params.put("JobType", strJobType);
			params.put("BaseGroupSortKey", strBaseGroupSortKey);
			params.put("CompanyCode", strCompanyCode);
			params.put("CompanyName", strCompanyName);
			params.put("DeptCode", strDeptCode);
			params.put("oldDeptCode", stroldDeptCode);
			params.put("oldCompanyCode", stroldCompanyCode);
			params.put("DeptName", strDeptName);
			params.put("RegionCode", strRegionCode);
			params.put("RegionName", strRegionName);
			params.put("JobPositionCode", strJobPositionCode);
			params.put("JobPositionName", strJobPositionName);
			params.put("JobTitleCode", strJobTitleCode);
			params.put("JobTitleName", strJobTitleName);
			params.put("JobLevelCode", strJobLevelCode);
			params.put("JobLevelName", strJobLevelName);
			
			params.put("UseDeputy", strUseDeputy);
			params.put("DeputyOption", strDeputyOption);
			params.put("DeputyCode", strDeputyCode);
			params.put("DeputyName", strDeputyName);
			params.put("DeputyFromDate", strDeputyFromDate);
			params.put("DeputyToDate", strDeputyToDate);
			params.put("AlertConfig", strAlertConfig);
			params.put("ApprovalUnitCode", strApprovalUnitCode);
			params.put("ReceiptUnitCode", strReceiptUnitCode);
			params.put("ApprovalCode", strApprovalCode);
			params.put("ApprovalFullCode", strApprovalFullCode);
			params.put("ApprovalFullName", strApprovalFullName);
			params.put("UseApprovalMessageBoxView", strUseApprovalMessageBoxView);
			params.put("UseMobile", strUseMobile);
			params.put("UseApprovalPassword", strUseApprovalPassword);
			
			/*********추가 AD **********/
			params.put("AD_IsUse",strAD_IsUse);
			params.put("AD_CN",strAD_CN);
			params.put("AD_SamAccountName",strAD_SamAccountName);
			params.put("AD_UserPrincipalName",strAD_UserPrincipalName);
			params.put("AD_DisplayName",strAD_DisplayName);
			params.put("AD_FirstName",strAD_FirstName);
			params.put("AD_LastName",strAD_LastName);
			params.put("AD_Initials",strAD_Initials);
			params.put("AD_Office",strAD_Office);
			params.put("AD_HomePage",strAD_HomePage);
			params.put("AD_Country",strAD_Country);
			params.put("AD_CountryID",strAD_CountryID);
			params.put("AD_CountryCode",strAD_CountryCode);
			params.put("AD_State",strAD_State);
			params.put("AD_City",strAD_City);
			params.put("AD_StreetAddress",strAD_StreetAddress);
			params.put("AD_PostOfficeBox",strAD_PostOfficeBox);
			params.put("AD_PostalCode",strAD_PostalCode);
			params.put("AD_UserAccountControl",strAD_UserAccountControl);
			params.put("AD_AccountExpires",strAD_AccountExpires);
			params.put("AD_PhoneNumber",strAD_PhoneNumber);
			params.put("AD_HomePhone",strAD_HomePhone);
			params.put("AD_Pager",strAD_Pager);
			params.put("AD_Mobile",strAD_Mobile);
			params.put("AD_Fax",strAD_Fax);
			params.put("AD_Info",strAD_Info);
			params.put("AD_Title",strAD_Title);
			params.put("AD_Department",strAD_Department);
			params.put("AD_Company",strAD_Company);
			params.put("AD_ManagerCode",strAD_ManagerCode);
			/*********추가 Exchange **********/
			params.put("EX_IsUse",strEX_IsUse);
			params.put("EX_PrimaryMail",strEX_PrimaryMail);
			params.put("EX_SecondaryMail",strEX_SecondaryMail);
			params.put("EX_StorageServer",strEX_StorageServer);
			params.put("EX_StorageGroup",strEX_StorageGroup);
			params.put("EX_StorageStore",strEX_StorageStore);
			params.put("EX_CustomAttribute01",strEX_CustomAttribute01);
			params.put("EX_CustomAttribute02",strEX_CustomAttribute02);
			params.put("EX_CustomAttribute03",strEX_CustomAttribute03);
			params.put("EX_CustomAttribute04",strEX_CustomAttribute04);
			params.put("EX_CustomAttribute05",strEX_CustomAttribute05);
			params.put("EX_CustomAttribute06",strEX_CustomAttribute06);
			params.put("EX_CustomAttribute07",strEX_CustomAttribute07);
			params.put("EX_CustomAttribute08",strEX_CustomAttribute08);
			params.put("EX_CustomAttribute09",strEX_CustomAttribute09);
			params.put("EX_CustomAttribute10",strEX_CustomAttribute10);
			params.put("EX_CustomAttribute11",strEX_CustomAttribute11);
			params.put("EX_CustomAttribute12",strEX_CustomAttribute12);
			params.put("EX_CustomAttribute13",strEX_CustomAttribute13);
			params.put("EX_CustomAttribute14",strEX_CustomAttribute14);
			params.put("EX_CustomAttribute15",strEX_CustomAttribute15);
			/*********추가 Messenger **********/
			params.put("MSN_IsUse",strMSN_IsUse);
			params.put("MSN_PoolServerName",strMSN_PoolServerName);
			params.put("MSN_PoolServerDN",strMSN_PoolServerDN);
			params.put("MSN_SIPAddress",strMSN_SIPAddress);
			params.put("MSN_Anonmy",strMSN_Anonmy);
			params.put("MSN_MeetingPolicyName",strMSN_MeetingPolicyName);
			params.put("MSN_MeetingPolicyDN",strMSN_MeetingPolicyDN);
			params.put("MSN_PhoneCommunication",strMSN_PhoneCommunication);
			params.put("MSN_PBX",strMSN_PBX);
			params.put("MSN_LinePolicyName",strMSN_LinePolicyName);
			params.put("MSN_LinePolicyDN",strMSN_LinePolicyDN);
			params.put("MSN_LineURI",strMSN_LineURI);
			params.put("MSN_LineServerURI",strMSN_LineServerURI);
			params.put("MSN_Federation",strMSN_Federation);
			params.put("MSN_RemoteAccess",strMSN_RemoteAccess);
			params.put("MSN_PublicIMConnectivity",strMSN_PublicIMConnectivity);
			params.put("MSN_InternalIMConversation",strMSN_InternalIMConversation);
			params.put("MSN_FederatedIMConversation",strMSN_FederatedIMConversation);
			
			//Saml 사용시 1로 변경
			params.put("BySaml", RedisDataUtil.getBaseConfig("UseSaml"));
			
			
			String reMsg = null;
			int ireturn = 0;
			CoviMap oldGroupInfos = new CoviMap();
			CoviMap oldUserInfo = new CoviMap();
			
			
			//라이선스 체크
			params.put("searchGUBUN", "DOMAINCODE");
			params.put("domainCode", strCompanyCode);
			CoviList listData = (CoviList)OrganizationManageSvc.selectLicenseInfo(params).get("list");
			boolean bContainLicense = false;
			for(int i = 0 ; i < listData.size(); i++){
				if(strLicSeq.equals(listData.getJSONObject(i).getString("LicSeq"))){
					if("N".equals(listData.getJSONObject(i).getString("LicMail"))&&"Y".equals(strUseMailConnect)){
						break;
					}
					bContainLicense = true;
					break;
				}
			}
			if(!bContainLicense){
				throw new Exception("License 오류");
			}
			
			if(strMode.equals("modify")) 
			{
				oldGroupInfos = (CoviMap)((CoviList) OrganizationManageSvc.selectUserGroupMailInfo(params).get("list")).get(0);
				oldUserInfo = (CoviMap)((CoviList) OrganizationManageSvc.selectUserInfo(params).get("list")).get(0); 
				params.put("SyncType", "UPDATE");
				ireturn = OrganizationManageSvc.updateUser(params);
			}
			else
			{
				params.put("SyncType", "INSERT");
				ireturn = OrganizationManageSvc.insertUser(params);
			}
				
			
			if(ireturn < 1) {
				returnMsg.append("|<b>DB</b> : FAIL<br/>");
				throw new Exception("Object Error!");
			} 
			returnMsg.append("|<b>DB</b> : SUCCESS<br/>");
			////////////////////////////////////////////////////////////////////////////////
			returnSubSystem = setSubSystemUser(oldUserInfo ,oldGroupInfos, params);
			////////////////////////////////////////////////////////////////////////////////
			returnMsg.append(returnSubSystem.get("returnMsg"));
			returnSubSystem.put("ReturnMsg", returnMsg.toString());
			returnList = returnSubSystem;
		
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("ReturnMsg", returnMsg.toString());
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	/**
	 * deleteUser : 사용자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteUser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		StringBuffer returnMsg = new StringBuffer();
		CoviMap returnSubSystem = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap oldUserInfo= null;
		CoviMap reObject = null;
		CoviMap oldGroupInfo = null;
		CoviList tempList= null;
		String strDeleteData = StringUtil.replaceNull(request.getParameter("deleteData"), "");
		int result;
		String stretireGRCode="";
		String strRetireOupath="";
		try {
			CoviMap params = new CoviMap();
			
			String DeleteDataArr[] = strDeleteData.split(",");
			
			for(int i=0; i<DeleteDataArr.length; i++) {
				params.put("UserCode",DeleteDataArr[i]);
				
				// 겸직 갯수
				CoviMap listData = OrganizationManageSvc.selectUserAddJobListCnt(params);
				int listCount = listData.getInt("cnt");
				
				if(listCount > 0) {
					// 겸직 카운트 0 이상이면 
					returnList.put("status", Return.FAIL);
					returnList.put("returnMsg", DicHelper.getDic("msg_existAddJob").replace("{0}",DeleteDataArr[i])); // 사용자[] 의 겸직이 존재합니다.
					return returnList;
				} else {
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "삭제되었습니다");
					
					params.put("ObjectCode",DeleteDataArr[i]);
					params.put("SyncManage","Manage");
					params.put("SyncType","DELETE");
					
					tempList = (CoviList) OrganizationManageSvc.selectUserInfo(params).get("list");
					oldUserInfo = tempList.getJSONObject(0);
					tempList = (CoviList) OrganizationManageSvc.selectUserGroupMailInfo(params).get("list");
					oldGroupInfo = tempList.getJSONObject(0);
					
					
					stretireGRCode =oldUserInfo.getString("DomainID")+"_RetireDept";
					
					CoviMap params2 = new CoviMap();
					params2.put("gr_code", stretireGRCode);
					
					tempList = (CoviList) OrganizationManageSvc.selectDeptInfo(params2).get("list");
					strRetireOupath = tempList.getJSONObject(0).getString("OUPath");
					
					params.put("SyncType", "DELETE");
					params.put("IsUse", "N");
					params.put("IsDisplay","N");
					
					result = OrganizationManageSvc.deleteUser(params);
					
					if(result < 2) {
						returnMsg.append("|<b>DB</b> : FAIL<br/>");
						throw new Exception("Object Error!");
					}
					returnMsg.append("|<b>DB</b> : SUCCESS<br/>");	
					
					returnSubSystem = setSubSystemUser(oldUserInfo ,oldGroupInfo,params);
					returnMsg.append(returnSubSystem.get("returnMsg"));
					returnList.put("returnMsg", returnMsg.toString());
				}
			}
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("returnMsg", returnMsg);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	

	@RequestMapping(value = "manage/conf/resetUserPassword.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap resetUserPassword(HttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strUserCode = request.getParameter("UserCode");
		String strModDate = request.getParameter("ModDate");
		String strMailAddress = null;
		String strIsAD = null;
		String strAD_SamAccountName = null;
		String strResult = "";
		
		try {
			returnList.put("status", Return.SUCCESS);
			CoviMap params = new CoviMap();
			params.put("UserCode", strUserCode);
			
			CoviMap mTargetInfo = (CoviMap) ((CoviList) OrganizationManageSvc.selectUserInfo(params).get("list")).get(0);
			strMailAddress=mTargetInfo.getString("MailAddress");
			strIsAD=mTargetInfo.getString("IsAD");
			strAD_SamAccountName=mTargetInfo.getString("AD_SamAccountName");
			params.put("MailAddress", strMailAddress);
			params.put("ModDate", strModDate);
			
			String strLogonPW = OrganizationManageSvc.resetUserPassword(params);
			returnList.put("message", strLogonPW);
			
			if("FAIL".equalsIgnoreCase(strLogonPW)) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "초기화에 실패하였습니다.");
				throw new Exception();
			} else {
				params.put("LogonPW", strLogonPW);
				if(OrganizationManageSvc.getIndiSyncTF() && !strMailAddress.equals("") && mTargetInfo.getString("UseMailConnect").equals("Y")) {
					if(!"0".equals(OrganizationManageSvc.indiModifyPass(params))){
						throw new Exception("[CP메일]초기화에 실패하였습니다.");
					}
				}
			}
			
			if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") &&RedisDataUtil.getBaseConfig("IsUserSync").equals("Y") && strIsAD.equals("Y")){	//비밀번호 변경
                CoviMap mapTemp = orgADSvc.adInitPassword(strAD_SamAccountName,strLogonPW,"Manage","");
                
				if(!Boolean.valueOf((String) mapTemp.getString("result"))){ //실패
					throw new Exception("[AD]초기화에 실패하였습니다.");
				} 
			}
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}


	@RequestMapping(value = "manage/conf/selectMailboxList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getmailboxlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap resultList = orgADSvc.exchSelectExchangeMailBoxList();
			
			if(Boolean.valueOf((String) resultList.getString("result"))){
				CoviList arrtemplist = new CoviList();
				
		        DocumentBuilderFactory dbf = null;
		        DocumentBuilder db = null;
		        Document doc = null;
		        NodeList nodes = null;
		        Element element = null;
		        InputSource is = new InputSource();
		        
		        dbf = DocumentBuilderFactory.newInstance();
		        dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
		        
	        	db = dbf.newDocumentBuilder();
	        	is.setCharacterStream(new StringReader((String) resultList.getString("message")));
	            doc = db.parse(is);
	            nodes = doc.getElementsByTagName("storageGroup");
				
			    for(int i=0; i<nodes.getLength(); i++) {
			    	CoviMap templist = new CoviMap();
			    	element = (Element) nodes.item(i);
			    	templist.put("name", ((String) element.getAttributes().getNamedItem("name").getNodeValue()));
			    	templist.put("code", element.getAttributes().getNamedItem("value").getNodeValue().replace("\\","/").split("/")[0] + "/" + element.getAttributes().getNamedItem("value").getNodeValue().replace("\\","/").split("/")[1]);
			    	arrtemplist.add(templist);
			    }

				returnList.put("list", arrtemplist);
				returnList.put("result", "ok");
			}
			else{
				returnList.put("list", null);
				returnList.put("result", "fail");
			}
		} catch (NullPointerException e){
			returnList.put("list", null);
			returnList.put("result", "fail");
		} catch (Exception e) {
			returnList.put("list", null);
			returnList.put("result", "fail");
		}
		
		return returnList;
	}

	@RequestMapping(value = "manage/conf/selectServiceTypeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectServiceTypeList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try{
			CoviList resultList = (CoviList) OrganizationManageSvc.selectServiceTypeList().get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	

	
	@RequestMapping(value = "manage/conf/selectIsDuplicateUserInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectIsDuplicateUserInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strCode = request.getParameter("Code");
		String strType = request.getParameter("Type");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("Code", strCode);
			params.put("Type", strType);
			
			returnList.put("list", OrganizationManageSvc.selectIsDuplicateUserInfo(params).get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}


	
	@RequestMapping(value = "manage/conf/selectIsDuplicateEmpno.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectIsDuplicateEmpno(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strCode = request.getParameter("Code");
		String strCompanyCode = request.getParameter("CompanyCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("Code", strCode);
			params.put("CompanyCode", strCompanyCode);

			returnList.put("list", OrganizationManageSvc.selectIsDuplicateEmpno(params).get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	

	/**
	 * getisduplicatemail : 메일 주소 중복 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectIsDuplicateMail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectIsDuplicateMail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strMailAddress = StringUtil.replaceNull(request.getParameter("MailAddress"), "");
		String strCode = StringUtil.replaceNull(request.getParameter("Code"), "");
		
		// 값이 비어있을경우 NULL 값으로 전달	
		strCode = strCode.isEmpty() ? null : strCode;
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("MailAddress", strMailAddress);
			params.put("Code", strCode);
			
			returnList.put("list", OrganizationManageSvc.selectIsDuplicateMail(params).get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}


	/**
	 * usePWPolicyCheck : 계열사 비밀번호 정책 체크
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/usePWPolicyCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap usePWPolicyCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String DomainCode = request.getParameter("DomainCode");
		String NewPW = request.getParameter("NewPW");
		CoviMap returnList = new CoviMap();
		String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("DomainCode", DomainCode);
			params.put("NewPW", NewPW);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.usePWPolicyCheck(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("cryptoType", cryptoType);
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;
	}
	

	/**
	 * updateIsUseUser : 사용자 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateIsUseUser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		StringBuffer returnMsg = new StringBuffer();
		CoviMap returnSubSystem = new CoviMap();
		CoviList userlist = new CoviList();
		CoviMap returnList = new CoviMap();
		CoviMap oldGroupInfo  = new CoviMap();
		int result = 0;
		try {
			returnList.put("result", "ok");			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			
			String strUserCode = request.getParameter("UserCode");
			String strIsUse = request.getParameter("IsUse");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strUserCode);
			params.put("IsUse", strIsUse);
			params.put("ModifyDate", strModDate);

			userlist = (CoviList) OrganizationManageSvc.selectUserInfo(params).get("list");
			oldGroupInfo = (CoviMap)((CoviList) OrganizationManageSvc.selectUserGroupMailInfo(params).get("list")).get(0);
			result = OrganizationManageSvc.updateIsUseUser(params);
			if(result == 0 ){
				returnMsg.append("|<b>DB</b> : FAIL<br/>");
				throw new Exception("Object Error!");
			}	
			returnMsg.append("|<b>DB</b> : SUCCESS<br/>");	
			
			returnSubSystem = setSubSystemUser(userlist.getJSONObject(0) ,oldGroupInfo,params);
			returnMsg.append(returnSubSystem.get("returnMsg"));
			returnList.put("returnMsg", returnMsg.toString());
		} catch (NullPointerException e){
			returnList.put("returnMsg", returnMsg);
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("returnMsg", returnMsg);
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsHRUser : 사용자 인사 연동 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateIsHRUser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsHRUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strUserCode = request.getParameter("UserCode");
			String strIsHR = request.getParameter("IsHR");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strUserCode);
			params.put("IsHR", strIsHR);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", OrganizationManageSvc.updateIsHRUser(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	

	/**
	 * updateIsDisplayUser : 사용자 표시 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/updateIsDisplayUser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsDisplayUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strUserCode = request.getParameter("UserCode");
			String strIsDisplay = request.getParameter("IsDisplay");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strUserCode);
			params.put("IsDisplay", strIsDisplay);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", OrganizationManageSvc.updateIsDisplayUser(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	/**
	 * selectLicenseInfo : 라이선스정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectLicenseInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectLicenseInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		try {
			// Parameters
			String strDomainId = request.getParameter("domainId");
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();

			params.put("searchGUBUN", "DOMAINID");
			params.put("domainId", strDomainId);
			CoviMap listData = OrganizationManageSvc.selectLicenseInfo(params);
			
		
			returnObj.put("list", listData.get("list"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회 성공");
			
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} 
		return returnObj;
	}
	@RequestMapping(value = "manage/conf/selectLicenseInfoByCode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectLicenseInfoByCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		try {
			// Parameters
			String strdomainCode = request.getParameter("domainCode");
			
			// DB Parameter Setting
			CoviMap params = new CoviMap();

			params.put("searchGUBUN", "DOMAINCODE");
			params.put("domainCode", strdomainCode);
			CoviMap listData = OrganizationManageSvc.selectLicenseInfo(params);
			
		
			returnObj.put("list", listData.get("list"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회 성공");
			
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} 
		return returnObj;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//공통
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	protected boolean getHasChildDept(String GroupCode) {
		int hasChild = 0;

		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			CoviMap returnList = OrganizationManageSvc.selectHasChildDept(params);
			
			hasChild = returnList.getJSONArray("list").getJSONObject(0).getInt("HasChild");
			if(hasChild > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}
	
	protected boolean getHasUserDept(String GroupCode) {
		int hasUser = 0;

		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			CoviMap returnList = OrganizationManageSvc.selectHasUserDept(params);
			
			hasUser = returnList.getJSONArray("list").getJSONObject(0).getInt("HasUser");
			if(hasUser > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}

	/**
	 * getHasChildGroup : 하위 그룹 존재 여부
	 * @param GroupCode
	 * @return boolean값
	 * @throws Exception
	 */
	protected boolean getHasChildGroup(String GroupCode) {
		int hasChild = 0;
		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			hasChild = OrganizationManageSvc.selectHasChildGroup(params);
			
			if(hasChild > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}
	
	/**
	 * getHasUserGroup : 하위 사용자 존재 여부
	 * @param GroupCode
	 * @return boolean값
	 * @throws Exception
	 */
	
	protected boolean getHasUserGroup(String GroupCode) {
		int hasUser = 0;
		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			hasUser = OrganizationManageSvc.selectHasUserGroup(params);
			if(hasUser > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}

	protected boolean getHasGroupMember(String GroupCode) {
		int hasGroupMember = 0;
		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			hasGroupMember = OrganizationManageSvc.selectHasGroupMember(params);
			if(hasGroupMember > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
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
			
			CoviMap returnList = OrganizationManageSvc.selectGroupEtcInfo(params);
			
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
	
	
	/**
	 * getGroupTreeList : 그룹멤버 목록(By GroupCode,DomainId)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getGroupMemberList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getGroupMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();
		
		String DomainId = request.getParameter("DomainId");		
		String GroupCode = request.getParameter("GroupCode");	
		try{

			// DB Parameter Setting
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("DomainId", DomainId);
			params.put("GroupCode", GroupCode);
			returnObj = OrganizationManageSvc.getGroupMemberList(params);
			
			returnObj.put("result", "ok");
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	/*
	 * 그룹코드로 그룹정보 가져오기
	 * */
	@RequestMapping(value = "manage/conf/getDefaultsetInfoGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDefaultSetInfoGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGR_Code = request.getParameter("memberOf");
		String strDomainId = request.getParameter("domainId");
		String strGroupType = request.getParameter("groupType");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", strGR_Code);
			params.put("domainId", strDomainId);
			params.put("groupType", strGroupType);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectDefaultSetInfoGroup(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "manage/conf/groupExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView groupExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String groupType = request.getParameter("groupType");//dept group
			String groupCode = request.getParameter("groupCode");//사용자관리일때만 사용
			String hasChildGroup = request.getParameter("hasChildGroup");//하위부서포함여부
			String searchText = request.getParameter("searchText");
			String searchType = request.getParameter("searchType");
			String searchIsUse = request.getParameter("searchIsUse");
			
			//String groupType = request.getParameter("groupType");
			String domainId = request.getParameter("domainId");
			String headerName = URLDecoder.decode(request.getParameter("headerName"),"UTF-8");//타이틀
			String fileName = "Organization_Management";
			String[] headerNames = headerName.split(";");
			 
			CoviMap params = new CoviMap();
			
			params.put("groupType", groupType);;
			params.put("domainId", domainId);
			params.put("searchType", searchType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("searchIsUse", searchIsUse);
			if("user".equalsIgnoreCase(groupType)){
				params.put("hasChildGroup", hasChildGroup);
				params.put("groupCode", groupCode);
			}
			if("exUser".equalsIgnoreCase(groupType)||"exDept".equalsIgnoreCase(groupType)){
				fileName="exDept".equalsIgnoreCase(groupType)?"Dept":"User";
				
				params.put("headerKey", URLDecoder.decode(request.getParameter("headerKey"),"UTF-8"));;
			}
			
			CoviMap resultList = OrganizationManageSvc.selectGroupExcelList(params);

			viewParams.put("headerKey", resultList.getString("headerKey").split(","));
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", fileName);
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}

	/*
	 * domainId로 회사정보 가져오기
	 * */
	@RequestMapping(value = "manage/conf/selectCompanyInfoGroupByDomainId.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectCompanyInfoGroupByDomainId(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strDomainId = request.getParameter("domainId");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("domainId", strDomainId);
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectCompanyInfoGroupByDomainId(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// 파라미터로 넘어온 문자열을 영문 대소문자, 숫자, _ 이외의 값 전부 치환하여 리턴
	private String setRegexString(String paramStr) throws Exception {
		String result = "";
		Pattern regPattern = Pattern.compile("[^a-zA-Z0-9\\_]");
		
		result = regPattern.matcher(paramStr).replaceAll("");
		
		return result;
	}


	/**
	 * selectAllDeptList : 부서 리스트 (CRM 테스트용)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectCrmDeptList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectCrmDeptList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainId = request.getParameter("domainId");		
		//String gr_code = request.getParameter("gr_code");
		//String grouptype = request.getParameter("grouptype");
		//String IsUse = request.getParameter("IsUse");
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		//String type = request.getParameter("type");
		
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();

			params.put("domainId", domainId);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviList resultList = (CoviList) OrganizationManageSvc.selectCrmDeptList(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}

	// //////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 사용자관리 (CRM 테스트용)
	// //////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * getUserList : 조직도 - 사용자 목록 (CRM 테스트용)
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/selectCrmUserList.do", method = {RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap selectCrmUserList(HttpServletRequest request,	HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		//String domainId = request.getParameter("domainId");
		String groupCode = request.getParameter("groupCode");
		//String searchType = request.getParameter("searchType");
		//String searchText = request.getParameter("searchText");

		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();

		// 정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}

		try {

			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));

			params.put("sortColumn",
					ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection",
					ComUtils.RemoveSQLInjection(strSortDirection, 100));
			//params.put("domainId", domainId);
			params.put("groupCode", groupCode);
			//params.put("searchType",
			//		searchType == null || searchType.isEmpty() ? null	: searchType);
			//params.put("searchText",
			//		searchText == null || searchText.isEmpty() ? null	: ComUtils.RemoveSQLInjection(searchText, 100));
			// params.put("rownumOrderby", strSortColumn +" "+ strSortDirection
			// +
			// ", (JobTitleSortKey +0) ASC, (JobLevelSortKey+0) ASC, EnterDate ASC, MultiDisplayName ASC");
			// // mssql 페이징처리용

			returnList = (CoviMap) OrganizationManageSvc.selectCrmUserList(params);

			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",
					isDevMode.equalsIgnoreCase("Y") ? e.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",
					isDevMode.equalsIgnoreCase("Y") ? e.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",
					isDevMode.equalsIgnoreCase("Y") ? e.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
}
