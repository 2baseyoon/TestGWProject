package egovframework.core.web;

import java.io.StringReader;
import java.net.URLDecoder;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;




import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

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

import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
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

/**
 * @Class Name : OrgManageCon.java
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
public class OrgManageCon {

	private Logger LOGGER = LogManager.getLogger(OrgManageCon.class);
	private HttpClientUtil httpClient = new HttpClientUtil();	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;
	@Autowired
	private OrganizationManageSvc OrganizationManageSvc;
	
	@Autowired
	private OrganizationADSvc orgADSvc;
	@Autowired
	private FileUtilService fileUtilSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	
	//페이지 이동
	@RequestMapping(value="regioninfopop.do", method=RequestMethod.GET)
	public ModelAndView showRegionInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strCompany = request.getParameter("company");
		String strCode = request.getParameter("code");
		String strMode = request.getParameter("mode");
		
		String returnURL = "core/organization/regioninfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("company",strCompany);
		mav.addObject("code", strCode);
		mav.addObject("mode", strMode);

		return mav;
	}
		
	//페이지 이동
	@RequestMapping(value="arbitarygroupinfopop.do", method=RequestMethod.GET)
	public ModelAndView showArbitaryGroupInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strType = request.getParameter("type");
		String strCode = request.getParameter("code");
		String strMode = request.getParameter("mode");
		String strDNCode = request.getParameter("dncode");
		String mail = request.getParameter("mail");
		
		String returnURL = "core/organization/arbitrarygroupinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("type", strType);
		mav.addObject("code", strCode);
		mav.addObject("mode", strMode);
		mav.addObject("dncode", strDNCode);
		mav.addObject("mail", mail);
		
		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="groupmanageinfopop.do", method=RequestMethod.GET)
	public ModelAndView showGroupManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainCode = request.getParameter("domainCode");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "core/organization/groupmanageinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="authoritymanageinfopop.do", method=RequestMethod.GET)
	public ModelAndView authoritymanageinfopop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainCode = request.getParameter("domainCode");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "core/organization/authoritymanageinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="deptmanageinfopop.do", method=RequestMethod.GET)
	public ModelAndView showDeptManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainCode = request.getParameter("domainCode");
		String strMemberOf = request.getParameter("memberOf");
		String strGroupType = request.getParameter("GroupType");
		String strMode = request.getParameter("mode");
		
		String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "core/organization/deptmanageinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GR_Code", strGR_Code);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("MemberOf", strMemberOf);
		mav.addObject("GroupType", strGroupType);
		mav.addObject("mode", strMode);
		mav.addObject("UR_Code", strUR_Code);

		return mav;
	}

	//페이지 이동
	@RequestMapping(value="mailaddress_attribute.do", method=RequestMethod.GET)
	public ModelAndView showMailAddress_Attribute(HttpServletRequest request, HttpServletResponse response) throws Exception{
				
		String strType = request.getParameter("type");
		String strMail = request.getParameter("mail");
		String strMode = request.getParameter("mode");
		String strCallBackMethod = request.getParameter("CallBackMethod");
		
		//String strUR_Code = SessionHelper.getSession("UR_Code");

		String returnURL = "core/organization/mailaddress_attribute";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("type", strType);
		mav.addObject("mail", strMail);
		mav.addObject("mode", strMode);
		mav.addObject("CallBackMethod", strCallBackMethod);

		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="addjobinfopop.do", method=RequestMethod.GET)
	public ModelAndView showAddJobInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strMode = request.getParameter("mode");
		String strID = request.getParameter("id");
		
		String returnURL = "core/organization/addjobinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("mode", strMode);
		mav.addObject("id", strID);

		return mav;
	}

	//페이지 이동
	@RequestMapping(value="usermanageinfopop.do", method=RequestMethod.GET)
	public ModelAndView showUserManageInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strGR_Code = request.getParameter("gr_code");
		String strDomainCode = request.getParameter("domainCode");
		String strMode = request.getParameter("mode");
		String strUR_Code = request.getParameter("ur_code");

		String returnURL = "core/organization/usermanageinfopop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("GroupCode", strGR_Code);
		mav.addObject("DomainCode", strDomainCode);
		mav.addObject("mode", strMode);
		mav.addObject("UserCode", strUR_Code);

		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="regionlistpop.do", method=RequestMethod.GET)
	public ModelAndView regionListPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strfunctionName = request.getParameter("functionName");
		String strdomainCode = request.getParameter("domainCode");
		
		String returnURL = "core/organization/regionlistpop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("functionName", strfunctionName);
		mav.addObject("domainCode", strdomainCode);

		return mav;
	}
	
	@RequestMapping(value = "admin/orgmanage/getdomainlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomainList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		String domainCode = request.getParameter("domainCode");
		
		CoviMap returnList = new CoviMap();
		CoviList domainList = new CoviList();
		try{
			CoviMap params = new CoviMap();
		    
		    if(domainCode == null || domainCode.equals("")) {
		    	domainCode = SessionHelper.getSession("DN_Code");
		    }
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();
			params.put("assignedDomain", assignedDomainList);
		    params.put("domainCode", domainCode);
		    
		    //관리자 domain 정보
		    domainList = (CoviList) orgSyncManageSvc.selectDomainList(params).get("list");
			
			returnList.put("list", domainList);
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
	 * getDeptList : 조직도 - 부서 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getdeptlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domain = request.getParameter("domain");
		String grouptype = request.getParameter("grouptype");
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		try{
			CoviMap params = new CoviMap();

			params.put("companyCode", domain);
			params.put("groupType", grouptype);
			
			CoviList result = (CoviList) orgSyncManageSvc.selectDeptList(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap dbOrgDeptData = (CoviMap) jsonobject;

				// 트리를 그리기 위한 데이터
				//dbOrgDeptData.put("no", getSortNo(dbOrgDeptData.get("SortPath").toString()));
				dbOrgDeptData.put("no", dbOrgDeptData.get("GroupCode").toString());
				dbOrgDeptData.put("nodeName", dbOrgDeptData.get("GroupDisplayName").toString());
				dbOrgDeptData.put("nodeValue", dbOrgDeptData.get("GroupCode").toString());
				dbOrgDeptData.put("gr_id", dbOrgDeptData.get("GroupID").toString());
				//tmp.put("type", "0") 폴더 아이콘 사용 안함;
				//dbOrgDeptData.put("pno", getParentSortNo(dbOrgDeptData.get("SortPath").toString()));
				dbOrgDeptData.put("pno", dbOrgDeptData.get("MemberOf").toString());
				dbOrgDeptData.put("chk", "Y");
				dbOrgDeptData.put("rdo", "N");
				dbOrgDeptData.put("url", "javascript:getOrgListData(\"" + dbOrgDeptData.get("CompanyCode").toString() + "\", \"" + dbOrgDeptData.get("GroupCode").toString() + "\", \"" + dbOrgDeptData.get("GroupType").toString() + "\", \"deptuser\");");
				
				resultList.add(dbOrgDeptData);
			}
			
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

	/**
	 * 조직도 개선 : 조직도 초기 트리 데이터 조회 ( 하위 depth 와 현재 사용자가 속한 depth까지 조회
	 * @param companyCode - 회사 코드
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getInitOrgTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInitOrgTreeList(
		@RequestParam(value = "companyCode", required = true) String companyCode,
		@RequestParam(value = "groupType", required = true, defaultValue = "dept") String groupType) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try{
			CoviMap params = new CoviMap();

			params.put("companyCode", companyCode);
			params.put("groupType", groupType);
			
			CoviList result = orgSyncManageSvc.getInitOrgTreeList(params);

			for(Object jsonobject : result){
				CoviMap dbOrgDeptData = (CoviMap) jsonobject;
				dbOrgDeptData.put("url", "javascript:getOrgListData(\"" + dbOrgDeptData.get("CompanyCode").toString() + "\", \"" + dbOrgDeptData.get("GroupCode").toString() + "\", \"" + dbOrgDeptData.get("GroupType").toString() + "\", \"deptuser\");");
				resultList.add(dbOrgDeptData);
			}
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
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
	 * 조직도 개선 : 조직도 초기 트리 데이터 조회 ( 하위 depth 와 현재 사용자가 속한 depth까지 조회
	 * @param companyCode - 회사 코드
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getChildrenData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getChildrenData(
			@RequestParam(value = "memberOf", required = false) String memberOf,
			@RequestParam(value = "companyCode", required = true) String companyCode,
			@RequestParam(value = "groupType", required = true, defaultValue = "dept") String groupType) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try{
			CoviMap params = new CoviMap();
			
			params.put("memberOf", memberOf);
			params.put("companyCode", companyCode);
			params.put("groupType", groupType);
			
			CoviList result = orgSyncManageSvc.getChildrenData(params);
			 
			for(Object jsonobject : result){
				CoviMap dbOrgDeptData = (CoviMap) jsonobject;
				dbOrgDeptData.put("url", "javascript:getOrgListData(\"" + dbOrgDeptData.get("CompanyCode").toString() + "\", \"" + dbOrgDeptData.get("GroupCode").toString() + "\", \"" + dbOrgDeptData.get("GroupType").toString() + "\", \"deptuser\");");
				resultList.add(dbOrgDeptData);
			}
			
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
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
	
	//SortPath를 통해  간략화된 SortNo 생성
	public String getSortNo(String pStr){
		if(pStr == null || pStr.equals("")) {
			return "";
		} else {
			String[] strArr = pStr.split(";");
			StringBuffer strReturn = new StringBuffer();
			
			for(String str : strArr){
				strReturn.append(Integer.parseInt(str));
			}
			
			return strReturn.toString();	
		}
	}
	
	//SortPath를 통해 부모의 SortNo 생성
	public String getParentSortNo(String pStr){
		String[] strArr = pStr.split(";");
		StringBuffer resultStr = new StringBuffer();
		
		for(int i=0;i<strArr.length - 1;i++){
			resultStr.append(strArr[i] + ";");
		}
		
		return getSortNo(resultStr.toString());
	}
	
	/**
	 * getUserList : 조직도 - 사용자 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getuserlist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getUserList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainCode = request.getParameter("domainCode");		//회사 이름(코드)
		String gr_code = request.getParameter("gr_code");		//부서 이름(코드)
		String IsUse = request.getParameter("IsUse");
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		String type = request.getParameter("type");
		
		CoviMap returnList = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		if(type != null && type.equals("search")) {
			domainCode = domainCode.isEmpty() ? null : domainCode;
			gr_code = gr_code.isEmpty() ? null : gr_code;
		}
		
		try{
		
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));					
			 
			
			params.put("companyCode", domainCode);
			params.put("deptCode", gr_code);
			params.put("IsUse", IsUse == null || IsUse.isEmpty() ? null : IsUse);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("rownumOrderby", strSortColumn +" "+ strSortDirection + ", (JobTitleSortKey +0) ASC, (JobLevelSortKey+0) ASC, EnterDate ASC, MultiDisplayName ASC"); // mssql 페이징처리용
			
			CoviMap jobjResult = orgSyncManageSvc.selectUserList(params);
			
			returnList.put("page", jobjResult.get("page"));
			returnList.put("list", jobjResult.get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/getsubdeptlist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getSubDeptList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainCode = request.getParameter("domainCode");		//회사 이름(코드)		
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		String IsUse = request.getParameter("IsUse");
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		String type = request.getParameter("type");
		
		CoviMap returnList = new CoviMap();
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		
		
		if(type != null && type.equals("search")) {
			gr_code = gr_code.isEmpty() ? null : gr_code;
			grouptype = grouptype.isEmpty() ? null : grouptype;
		}
		
		try{
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", strSortColumn == null || strSortColumn.isEmpty() ? null : ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", strSortDirection == null || strSortDirection.isEmpty() ? null : ComUtils.RemoveSQLInjection(strSortDirection, 100));
			
			params.put("companyCode", domainCode);
			params.put("gr_code", gr_code);
			params.put("grouptype", grouptype);
			params.put("IsUse", IsUse == null || IsUse.isEmpty() ? null : IsUse);
			params.put("searchType", searchType == null || searchType.isEmpty() ? null : searchType);
			params.put("searchText", searchText == null || searchText.isEmpty() ? null : ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap jobjResult = orgSyncManageSvc.selectSubDeptList(params);
			
			returnList.put("page", jobjResult.get("page"));
			returnList.put("list", jobjResult.get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/getdeptname.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptName(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		String displayName = "";
		String parentName = "";
		String rootName = "";
		String groupPath = "";
		StringBuffer parentPath = new StringBuffer();
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			params.put("grouptype", grouptype);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectParentName(params).get("list");
			displayName = resultList.getJSONObject(0).getString("DisplayName");
			groupPath = resultList.getJSONObject(0).getString("GroupPath");
			
			if(groupPath.split(";").length > 2) {
				for(int i = 1; i < groupPath.split(";").length-1; i++) {
					params.put("gr_code", groupPath.split(";")[i]);
					params.put("grouptype", "Dept");
					resultList = (CoviList) orgSyncManageSvc.selectParentName(params).get("list");
					
					parentName += resultList.getJSONObject(0).getString("DisplayName") + " > ";
					if(i == 1) {
						rootName = resultList.getJSONObject(0).getString("DisplayName") + " > ";
					} else {
						parentPath.append(groupPath.split(";")[i] + ";");
					}
					//groupPath = resultList.getJSONObject(0).getString("GroupPath");		
				}
			}
			
			returnList.put("displayName", displayName);
			returnList.put("parentName", parentName);
			returnList.put("rootName", rootName);
			returnList.put("parentPath", parentPath.toString());
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
	
	@RequestMapping(value = "admin/orgmanage/getgrouptype.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGroupType(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		
		CoviMap returnList = new CoviMap();
		
		try{
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectGroupType().get("list");
			
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
	
	@RequestMapping(value = "admin/orgmanage/getdeptinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
			
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
	
	@RequestMapping(value = "admin/orgmanage/getuserinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String UserCode = request.getParameter("UserCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("UserCode", UserCode);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
			
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
	
	//지역 정보 select
	@RequestMapping(value = "admin/orgmanage/getregioninfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getregioninfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectRegionInfo(params).get("list");
			
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
	
	//직급,직위,직책 정보 select
	@RequestMapping(value = "admin/orgmanage/getarbitrarygroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getarbitrarygroupinfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectArbitraryGroupInfo(params).get("list");
			
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

	//겸직 정보 select
	@RequestMapping(value = "admin/orgmanage/getaddjobInfodata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getaddjobInfodata(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strID = request.getParameter("id");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("id", strID);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectAddJobInfo(params).get("list");
			
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
	
	//겸직 정보(사용자 기본 정보) select
	@RequestMapping(value = "admin/orgmanage/getaddjobuserInfodata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getaddjobuserInfodata(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strUR_Code = request.getParameter("ur_code");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("UserCode", strUR_Code);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectAddJobUserInfo(params).get("list");
			
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
	
	@RequestMapping(value = "admin/orgmanage/getisduplicatedeptcode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIsDuplicateDeptCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGroupCode = request.getParameter("groupCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("GroupCode", strGroupCode);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateDeptCode(params).get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/checkDuplicatePriorityOrder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDuplicatePriorityOrder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGroupCode = request.getParameter("groupCode");
		String strsortkey = request.getParameter("sortkey");
		String strMemberOf = request.getParameter("MemberOf");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("GroupCode", strGroupCode);
			params.put("sortkey", strsortkey);
			params.put("MemberOf", strMemberOf);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateDeptPriorityOrder(params).get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/getisduplicateusercode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIsDuplicateUserCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strCode = request.getParameter("Code");
		String strType = request.getParameter("Type");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("Code", strCode);
			params.put("Type", strType);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateUserCode(params).get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/getisduplicateempno.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getIsDuplicateEmpno(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strCode = request.getParameter("Code");
		String strCompanyCode = request.getParameter("CompanyCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("Code", strCode);
			params.put("CompanyCode", strCompanyCode);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateEmpno(params).get("list"));
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
	
	@RequestMapping(value = "admin/orgmanage/getdefaultsetinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDefaultSetInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGR_Code = request.getParameter("memberOf");
		String strDomainCode = request.getParameter("domainCode");
		String strGroupType = request.getParameter("groupType");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", strGR_Code);
			params.put("domainCode", strDomainCode);
			params.put("groupType", strGroupType);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectDefaultSetInfo(params).get("list");
			
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
	
	/**
	 * deleteUser : 사용자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/deleteuser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap reObject = null;
		String strDeleteData = request.getParameter("deleteData");
		int result;
		
		try {
			CoviMap params = new CoviMap();
			
			String DeleteDataArr[] = strDeleteData.split(",");
			
			for(int i=0; i<DeleteDataArr.length; i++) {
				params.put("UserCode",DeleteDataArr[i]);
				
				// 겸직 갯수
				CoviMap listData = orgSyncManageSvc.selectUserAddJobListCnt(params);
				int listCount = listData.getInt("cnt");
				
				if(listCount > 0) {
					// 겸직 카운트 0 이상이면 
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_existAddJob").replace("{0}",DeleteDataArr[i])); // 사용자[] 의 겸직이 존재합니다.
					return returnList;
				} else {
					params.put("LoginID",DeleteDataArr[i]);
					params.put("ObjectCode",DeleteDataArr[i]);
					params.put("SyncManage","Manage");
					params.put("SyncType","DELETE");
					
					//arrresultList = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
					CoviList arrresultList = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
					
					String strUserCode =arrresultList.getJSONObject(0).getString("UserCode");
					String strMultiDisplayName =arrresultList.getJSONObject(0).getString("MultiDisplayName");
					String strCompanyCode =arrresultList.getJSONObject(0).getString("CompanyCode");
					String strDeptCode =arrresultList.getJSONObject(0).getString("DeptCode");
					String strJobPositionCode =arrresultList.getJSONObject(0).getString("JobPositionCode");
					String strJobTitleCode =arrresultList.getJSONObject(0).getString("JobTitleCode");
					String strJobLevelCode =arrresultList.getJSONObject(0).getString("JobLevelCode");
					String strRegionCode =arrresultList.getJSONObject(0).getString("RegionCode");
					String stretireGRCode =arrresultList.getJSONObject(0).getString("DomainID")+"_RetireDept";
					String strAD_ISUSE =arrresultList.getJSONObject(0).getString("AD_ISUSE");
					String strEX_ISUSE =arrresultList.getJSONObject(0).getString("EX_ISUSE");
					String strMSN_ISUSE =arrresultList.getJSONObject(0).getString("MSN_ISUSE");
					String strAD_CN =arrresultList.getJSONObject(0).getString("AD_CN");
					String strAD_SamAccountName =arrresultList.getJSONObject(0).getString("AD_SamAccountName");
					String strAD_AD_UserPrincipalName =arrresultList.getJSONObject(0).getString("AD_UserPrincipalName");
					String strEX_PRIMARYMAIL =arrresultList.getJSONObject(0).getString("EX_PRIMARYMAIL");
					String strMSN_SIPADDRESS =arrresultList.getJSONObject(0).getString("MSN_SIPADDRESS");
					String strRetireOupath = "";
					
					CoviMap params2 = new CoviMap();
					params2.put("gr_code", stretireGRCode);
					
					CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params2).get("list");
					strRetireOupath = arrGroupList.getJSONObject(0).getString("OUPath");
					params.put("SyncType", "DELETE");
					params.put("CompanyCode", strCompanyCode);
					params.put("DeptCode",strDeptCode);
					params.put("LogonID", arrresultList.getJSONObject(0).getString("LogonID"));
					params.put("EmpNo", arrresultList.getJSONObject(0).getString("EmpNo"));
					params.put("DisplayName", arrresultList.getJSONObject(0).getString("DisplayName"));
					params.put("MultiDisplayName",strMultiDisplayName);
					params.put("JobPositionCode",strJobPositionCode);
					params.put("JobTitleCode",strJobTitleCode);
					params.put("JobLevelCode", strJobLevelCode);
					params.put("SortKey", arrresultList.getJSONObject(0).getString("SortKey"));
					params.put("IsUse", "N");
					params.put("IsDisplay","N");
					params.put("RetireDate", arrresultList.getJSONObject(0).getString("RetireDate"));
					params.put("BirthDiv", arrresultList.getJSONObject(0).getString("BirthDiv"));
					params.put("BirthDate", arrresultList.getJSONObject(0).getString("BirthDate"));
					params.put("UseMailConnect", arrresultList.getJSONObject(0).getString("UseMailConnect"));
					params.put("UseMessengerConnect", arrresultList.getJSONObject(0).getString("UseMessengerConnect"));
					params.put("MailAddress", arrresultList.getJSONObject(0).getString("MailAddress"));
					params.put("ExternalMailAddress", arrresultList.getJSONObject(0).getString("ExternalMailAddress"));
					params.put("PhoneNumberInter", arrresultList.getJSONObject(0).getString("PhoneNumberInter"));
					params.put("oldDeptCode", strDeptCode);
					params.put("RetireDept",stretireGRCode);
					
					result = orgSyncManageSvc.deleteUser(params);
					
					if(result >= 2) {
						returnList.put("result", "ok");
						returnList.put("status", Return.SUCCESS);
						returnList.put("message", "삭제되었습니다");
						returnList.put("etcs", "");
					}
					
					params.put("mailStatus","S");
					params.put("TargetID",DeleteDataArr);				
					
					//인디메일 연동
					if(orgSyncManageSvc.getIndiSyncTF() && arrresultList.getJSONObject(0).getString("UseMailConnect").equals("Y") && !arrresultList.getJSONObject(0).getString("MailAddress").equals("")) {
						params.put("GroupCode",strDeptCode);
						String sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
						
						params.put("GroupMailAddress", "");
						params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
						
						reObject = orgSyncManageSvc.modifyUser(params);
						
						if(!reObject.get("returnCode").toString().equals("0")) {
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [메일] " + reObject.get("returnMsg"));
							throw new Exception(" [메일] " + reObject.get("returnMsg"));
						} else {
							if(strJobPositionCode != null && !strJobPositionCode.isEmpty()) {
								params.put("GroupCode",strJobPositionCode);
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
								
								params.put("GroupMailAddress", "");
								params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(params);
								
								if(!reObject.get("returnCode").toString().equals("0")) {
									returnList.put("status", Return.FAIL);
									returnList.put("message", " [메일] " + reObject.get("returnMsg"));
									throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
							if(strJobTitleCode != null && !strJobTitleCode.isEmpty()) {
								params.put("GroupCode",strJobTitleCode);
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
								
								params.put("GroupMailAddress", "");
								params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(params);
								if(!reObject.get("returnCode").toString().equals("0")) {
									returnList.put("status", Return.FAIL);
									returnList.put("message", " [메일] " + reObject.get("returnMsg"));
									throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
							if(strJobLevelCode != null && !strJobLevelCode.isEmpty()) {
								params.put("GroupCode",strJobLevelCode);
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
								
								params.put("GroupMailAddress", "");
								params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(params);
								if(!reObject.get("returnCode").toString().equals("0")) {
									returnList.put("status", Return.FAIL);
									returnList.put("message", " [메일] " + reObject.get("returnMsg"));
									throw new Exception(" [메일] " + reObject.get("returnMsg"));
								}
							}
						}
					}
					
					//타임스퀘어 연동
					if(orgSyncManageSvc.getTSSyncTF() && arrresultList.getJSONObject(0).getString("UseMessengerConnect").equals("Y") && !arrresultList.getJSONObject(0).getString("MailAddress").equals("")) {
						orgSyncManageSvc.deleteUserSyncdelete(params);
					}
					
					//AD 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && strAD_ISUSE.equals("Y")){
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.adDeleteUser(strUserCode,strCompanyCode,strDeptCode,strJobPositionCode,strJobTitleCode,strJobLevelCode,strRegionCode,stretireGRCode,strRetireOupath,strAD_CN,strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [AD] " + resultList.getString("Reason"));
								throw new Exception(" [AD] " + resultList.getString("Reason"));
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					}
					
					//Exchange 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strEX_ISUSE.equals("")){
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.exchDisableUser(strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [Exch] " + resultList.getString("Reason"));
								throw new Exception(" [Exch] " + resultList.getString("Reason"));
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					}
					
					//Messenger 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncMessenger").equals("Y") && strMSN_ISUSE.equals("Y")){
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.msnEnableUser(strAD_SamAccountName,strMSN_SIPADDRESS,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [SFB] " + resultList.getString("Reason"));
								throw new Exception(" [SFB] " + resultList.getString("Reason"));
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnList.put("status", Return.FAIL);
						returnList.put("message", ex.getMessage());
					}
				}
			}
			
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
	 * deleteDept : 부서 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/deletedept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteData = request.getParameter("deleteData");
		int result = 0;
		try {
			
			for(int i = 0; i < strDeleteData.split(",").length; i++) {
				if(getHasChildDept(strDeleteData.split(",")[i])) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "부서코드 [" + strDeleteData.split(",")[i] + "] : 하위그룹이 존재합니다.");
					return returnList;
				} else if(getHasUserDept(strDeleteData.split(",")[i])) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "부서코드 [" + strDeleteData.split(",")[i] + "] : 사용자가 존재합니다.");
					return returnList;
				}
			}
			
			CoviMap params = new CoviMap();
			
			String DeleteDataArr[] = strDeleteData.split(",");
			
			params.put("deleteData", DeleteDataArr);
			params.put("TargetID",DeleteDataArr);
			
			CoviList arrresultList = (CoviList) orgSyncManageSvc.selectDeptInfoList(params).get("list");			
						
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
				
				result = orgSyncManageSvc.deleteGroup(params2);
				if(result != 0) { 
					returnList.put("object", result);
					returnList.put("result", "ok");

					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "삭제되었습니다");
					returnList.put("etcs", "");
				}
				
				//인디메일 부서 비활성화
				if(result != 0 && orgSyncManageSvc.getIndiSyncTF() && !sPrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
					params2.put("GroupStatus", "S");
					orgSyncManageSvc.modifyGroup(params2);
				}
				
				//타임스퀘어 부서 비활성화
				if(result != 0 && orgSyncManageSvc.getTSSyncTF() && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
					orgSyncManageSvc.deleteGroupSync(params2);
				}

				//AD 연동
				try{
					if(result != 0 && RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")){
						CoviMap resultList = orgADSvc.adDeleteDept(strGroupCode, strDisplayName, sCompanyName, sOUName, sOUPath, "Manage", "");
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [AD] " + resultList.getString("Reason"));
							throw new Exception(" [AD] " + resultList.getString("Reason"));
						}
					}
				} catch (NullPointerException e) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", e.getMessage());
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", e.getMessage());
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				//Exchange 연동
				try {
					if(result != 0 && RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y") && sIsMail.equals("Y")){
						CoviMap resultList = orgADSvc.exchEnableGroup(strGroupCode,sPrimaryMail,sSecondaryMail,"Manage","");
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [Exch] " + resultList.getString("Reason"));
							throw new Exception(" [Exch] " + resultList.getString("Reason"));
						}
					}
				} catch (NullPointerException e) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", e.getMessage());
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", e.getMessage());
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	protected boolean getHasChildDept(String GroupCode) {
		int hasChild = 0;

		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			CoviMap returnList = orgSyncManageSvc.selectHasChildDept(params);
			
			hasChild = returnList.getJSONArray("list").getJSONObject(0).getInt("HasChild");
			if(hasChild > 0) {
				return true;
			} else {
				return false;
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}
	
	protected boolean getHasUserDept(String GroupCode) {
		int hasUser = 0;

		try {
			CoviMap params = new CoviMap();
			params.put("GroupCode", GroupCode);
			
			CoviMap returnList = orgSyncManageSvc.selectHasUserDept(params);
			
			hasUser = returnList.getJSONArray("list").getJSONObject(0).getInt("HasUser");
			if(hasUser > 0) {
				return true;
			} else {
				return false;
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}
	
	/**
	 * updateIsUseDept : 부서 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisusedept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		int result = 0;
		int modifyStatus = 0;
		
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsUse");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params2 = new CoviMap();
			params2.put("gr_code", strCode);
			
			CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params2).get("list");
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
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			params.put("GroupType", "Dept");
			params.put("DisplayName", sDisplayName);
			params.put("MemberOf", sMemberOf);
			params.put("PrimaryMail", sPrimaryMail);
			
			result = orgSyncManageSvc.updateIsUseDept(params);
			if(result > 0) modifyStatus = 0;
			else modifyStatus = -1;
			
			//인디메일 Group 활성/비활성화
			if(result != 0 && orgSyncManageSvc.getIndiSyncTF() && !sPrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				if(strIsUse.equals("N")) params.put("GroupStatus", "S");
				else params.put("GroupStatus", "A");
				
				if(!orgSyncManageSvc.modifyGroup(params)) modifyStatus = 1;
				else modifyStatus = 0;
			}

			//타임스퀘어 Group 활성/비활성화
			if(result != 0 && orgSyncManageSvc.getTSSyncTF() && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {						
				result = orgSyncManageSvc.isUseGroupSyncUpdate(params,strIsUse);
				
				if(result == 0) modifyStatus = 2;
				else modifyStatus = 0;
			}
			
			//AD 연동
			try{
				if(result != 0 && RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")){
					CoviMap resultList = new CoviMap();
					if(strIsUse.equals("N")) {
						resultList = orgADSvc.adDeleteDept(strCode, sDisplayName, sCompanyName, sOUName, sOUPath, "Manage", "");
					} else {
						resultList = orgADSvc.adModifyDept(strCode,sDisplayName,sCompanyName,sMemberOf,sOUName,sOUPath,sOUPath,sPrimaryMail,"Manage","");
					}
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + resultList.getString("Reason"));
						throw new Exception(" [AD] " + resultList.getString("Reason"));
					}
				}
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			//Exchange 연동
			try {
				if(result != 0 && RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y") && sIsMail.equals("Y")){
					CoviMap resultList = new CoviMap();
					
					if(strIsUse.equals("N")) {
						resultList = orgADSvc.exchDisableGroup(strCode,"Manage","");
					} else {
						resultList = orgADSvc.exchEnableGroup(strCode,sPrimaryMail,sSecondaryMail,"Manage","");
					}
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [Exch] " + resultList.getString("Reason"));
						throw new Exception(" [Exch] " + resultList.getString("Reason"));
					}
				}
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			returnList.put("object", result);
			
			if(modifyStatus < 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다.");
			}else if(modifyStatus == 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}else if(modifyStatus == 1) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메일)");
			}else if(modifyStatus == 2) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
			}
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
	 * updateIsHRDept : 부서 인사 연동 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateishrdept.do", method=RequestMethod.POST)
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
			
			returnList.put("object", orgSyncManageSvc.updateIsHRDept(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsDisplayDept : 부서 표시 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisdisplaydept.do", method=RequestMethod.POST)
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
			
			returnList.put("object", orgSyncManageSvc.updateIsDisplayDept(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsMailDept : 부서 메일 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateismaildept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsMailDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsMail = request.getParameter("IsMail");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsMail", strIsMail);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsMailDept(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsUseUser : 사용자 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisuseuser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviList userlist = new CoviList();
		CoviMap returnList = new CoviMap();
		int result = 0;
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsUse");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strCode);
			params.put("LogonID", strCode);
			params.put("IsUse", strIsUse);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			result = orgSyncManageSvc.updateIsUseUser(params);
			
			userlist = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
			params.put("DisplayName", userlist.getJSONObject(0).getString("DisplayName"));
			params.put("oldDeptCode", userlist.getJSONObject(0).getString("DeptCode"));
			params.put("RetireDept", userlist.getJSONObject(0).getString("DomainID")+"_RetireDept");
			params.put("MailAddress", userlist.getJSONObject(0).getString("MailAddress"));
			
			String strCompanyCode = userlist.getJSONObject(0).getString("CompanyCode");
			String strDeptCode = userlist.getJSONObject(0).getString("DeptCode");
			String stroldDeptCode = userlist.getJSONObject(0).getString("DeptCode");
			String strLogonID = userlist.getJSONObject(0).getString("LogonID");
			String strDecLogonPassword = RedisDataUtil.getBaseConfig("InitPassword");
			String strEmpNo = userlist.getJSONObject(0).getString("EmpNo");
			String strAD_DisplayName = userlist.getJSONObject(0).getString("AD_DISPLAYNAME");
			String strJobPositionCode = userlist.getJSONObject(0).getString("JobPositionCode");
			String strJobTitleCode = userlist.getJSONObject(0).getString("JobTitleCode");
			String strJobLevelCode = userlist.getJSONObject(0).getString("JobLevelCode");
			String strRegionCode = userlist.getJSONObject(0).getString("RegionCode");
			String strAD_ISUSE = userlist.getJSONObject(0).getString("AD_ISUSE");
			String strAD_FirstName = userlist.getJSONObject(0).getString("AD_FIRSTNAME");
			String strAD_LastName = userlist.getJSONObject(0).getString("AD_LASTNAME");
			String strAD_UserAccountControl = userlist.getJSONObject(0).getString("AD_USERACCOUNTCONTROL");
			String strAD_AccountExpires = userlist.getJSONObject(0).getString("AD_ACCOUNTEXPIRES");
			String strAD_PhoneNumber = userlist.getJSONObject(0).getString("AD_PHONENUMBER");
			String strAD_Mobile = userlist.getJSONObject(0).getString("AD_MOBILE");
			String strAD_Fax = userlist.getJSONObject(0).getString("AD_FAX");
			String strAD_Info = userlist.getJSONObject(0).getString("AD_INFO");
			String strAD_Title = userlist.getJSONObject(0).getString("AD_TITLE");
			String strAD_Department = userlist.getJSONObject(0).getString("AD_DEPARTMENT");
			String strAD_Company = userlist.getJSONObject(0).getString("AD_COMPANY");
			String strEX_PrimaryMail = userlist.getJSONObject(0).getString("EX_PRIMARYMAIL");
			String strEX_SecondaryMail = userlist.getJSONObject(0).getString("EX_SECONDARYMAIL");
			String strAD_CN = userlist.getJSONObject(0).getString("AD_CN");
			String strAD_SamAccountName = userlist.getJSONObject(0).getString("AD_SamAccountName");
			String sUserPrincipalName = userlist.getJSONObject(0).getString("AD_UserPrincipalName");
			String strPhotoPath = userlist.getJSONObject(0).getString("PhotoPath");
			String strAD_ManagerCode = userlist.getJSONObject(0).getString("AD_MANAGERCODE");
			String strAD_INITIALS = userlist.getJSONObject(0).getString("AD_INITIAL");
			String strAD_OFFICE = userlist.getJSONObject(0).getString("AD_OFFICE");
			String strAD_HOMEPAGE = userlist.getJSONObject(0).getString("AD_HOMEPAGE");
			String strAD_COUNTRY = userlist.getJSONObject(0).getString("AD_COUNTRY");
			String strAD_COUNTRYID = userlist.getJSONObject(0).getString("AD_COUNTRYID");
			String strAD_COUNTRYCODE = userlist.getJSONObject(0).getString("AD_COUNTRYCODE");
			String strAD_STATE = userlist.getJSONObject(0).getString("AD_STATE");
			String strAD_CITY = userlist.getJSONObject(0).getString("AD_CITY");
			String strAD_STREETADDRESS = userlist.getJSONObject(0).getString("AD_STREETADDRESS");
			String strAD_POSTOFFICEBOX = userlist.getJSONObject(0).getString("AD_POSTOFFICEBOX");
			String strAD_POSTALCODE = userlist.getJSONObject(0).getString("AD_POSTALCODE");
			String strAD_HOMEPHONE = userlist.getJSONObject(0).getString("AD_HOMEPHONE");
			String strAD_PAGER = userlist.getJSONObject(0).getString("AD_PAGER");
			
			String strEX_IsUse = userlist.getJSONObject(0).getString("EX_ISUSE");
			String strEX_StorageServer = userlist.getJSONObject(0).getString("EX_STORAGESERVER");
			String strEX_StorageGroup = userlist.getJSONObject(0).getString("EX_STORAGEGROUP");
			String strEX_StorageStore = userlist.getJSONObject(0).getString("EX_STORAGESTORE");
			String strMSN_ISUSE = userlist.getJSONObject(0).getString("MSN_ISUSE");
			String strMSN_SIPAddress = userlist.getJSONObject(0).getString("MSN_SIPADDRESS");
			
			//Old Data
			CoviMap params_old = new CoviMap();
			CoviMap  resultList_old = new CoviMap();
			CoviList  arrresultList_old = new CoviList();
			params_old.put("UserCode", strCode);
			arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
			
			//인디메일 사용자 활성/비활성화
			if(result != 0 && orgSyncManageSvc.getIndiSyncTF()) {
				CoviMap reObject = null;
				reObject = orgSyncManageSvc.getUserStatus(params);
				if(reObject.has("returnCode") && reObject.has("result")){
				
					if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
						
						String sOldGroupMail = "";
						
						if("N".equals(strIsUse)) {
							params.put("GroupCode",stroldDeptCode);
							sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
							
							params.put("GroupMailAddress", "");
							params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
							params.put("mailStatus","S");
						}
						else {
							params.put("GroupCode",strDeptCode);
							String sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
							
							params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
							params.put("oldGroupMailAddress", "");
							params.put("mailStatus","A");
						}
						
						try {	
							reObject = orgSyncManageSvc.modifyUser(params);
							if(!reObject.get("returnCode").toString().equals("0")) {
								throw new Exception(" [메일] " + reObject.get("returnMsg"));
							} else {
								if(!strJobPositionCode.equals("")) {
									params.put("GroupCode",strJobPositionCode);
									sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", "");
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = orgSyncManageSvc.modifyUser(params);
								}
								if(!strJobTitleCode.equals("")) {
									params.put("GroupCode",strJobTitleCode);
									sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", "");
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = orgSyncManageSvc.modifyUser(params);
								}
								if(!strJobLevelCode.equals("")) {
									params.put("GroupCode",strJobLevelCode);
									sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", "");
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = orgSyncManageSvc.modifyUser(params);
								}
							}
						} catch (NullPointerException e) {
							returnList.put("status", Return.FAIL);
						} catch (Exception e) {
							returnList.put("status", Return.FAIL);
						}						
					}	
				
				}
			}

			//타임스퀘어  사용자  활성/비활성화
			if(result != 0 && orgSyncManageSvc.getTSSyncTF()) {						
				result = orgSyncManageSvc.isUseUserSyncupdate(params,strIsUse);
			}
			
			//AD 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y") && strAD_ISUSE.equals("Y")){
					params.put("UserCode",strCode);
					params.put("AD_DisplayName", !strAD_DisplayName.equals("") ? strAD_DisplayName : userlist.getJSONObject(0).getString("DisplayName"));
					params.put("AD_FirstName", !strAD_FirstName.equals("") ? strAD_FirstName : userlist.getJSONObject(0).getString("DisplayName").substring(1));
					params.put("AD_LastName", !strAD_LastName.equals("") ? strAD_LastName : userlist.getJSONObject(0).getString("DisplayName").substring(0,1));
					params.put("AD_Initials",strAD_INITIALS);
					params.put("AD_Office",strAD_OFFICE);
					params.put("AD_HomePage",strAD_HOMEPAGE);
					params.put("AD_Country",strAD_COUNTRY);
					params.put("AD_CountryID",strAD_COUNTRYID);
					params.put("AD_CountryCode",strAD_COUNTRYCODE);
					params.put("AD_State",strAD_STATE);
					params.put("AD_City",strAD_CITY);
					params.put("AD_StreetAddress",strAD_STREETADDRESS);
					params.put("AD_PostOfficeBox",strAD_POSTOFFICEBOX);
					params.put("AD_PostalCode",strAD_POSTALCODE);
					if(strIsUse.equals("Y")) params.put("AD_UserAccountControl","66048");
					else params.put("AD_UserAccountControl","66050");
					params.put("AD_AccountExpires","0");
					params.put("AD_PhoneNumber",strAD_PhoneNumber);
					params.put("AD_HomePhone",strAD_HOMEPHONE);
					params.put("AD_Pager",strAD_PAGER);
					params.put("AD_Fax",strAD_Fax);
					params.put("AD_Info",strAD_Info);
					params.put("AD_Title",strAD_Title);
					params.put("AD_Department",strAD_Department);
					params.put("AD_Company",strAD_Company);
					params.put("AD_ManagerCode",strAD_ManagerCode);
					params.put("AD_CN",strAD_CN);
					params.put("AD_SamAccountName",strAD_SamAccountName);
					params.put("AD_UserPrincipalName",sUserPrincipalName);
					
					int icheckad = 0;
					if(arrresultList_old.getJSONObject(0).getString("AD_USERID").equals("")){
						icheckad = orgADSvc.insertUserADInfo(params);
					}else{
						icheckad = orgADSvc.updateUserADInfo(params);
					}
					
					if(icheckad != 0){	//sys_object_user_ad 정보 수정 성공
						if(strIsUse.equals("Y")){
							params.put("gr_code", userlist.getJSONObject(0).getString("DeptCode"));
							String sOUPath_Temp = "";
							String sAD_ServerURL = RedisDataUtil.getBaseConfig("AD_ServerURL");
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							
							resultList = orgADSvc.adModifyUser(strCode, strCompanyCode, strDeptCode, stroldDeptCode, sOUPath_Temp, strLogonID, strDecLogonPassword, strEmpNo, strAD_DisplayName,
									strJobPositionCode, strJobTitleCode, strJobLevelCode, strRegionCode, strAD_FirstName, strAD_LastName, strAD_UserAccountControl, strAD_AccountExpires, 
									strAD_PhoneNumber, strAD_Mobile, strAD_Fax, strAD_Info, strAD_Title, strAD_Department, strAD_Company, strEX_PrimaryMail, strEX_SecondaryMail, 
									strAD_CN, strAD_SamAccountName, sUserPrincipalName, strPhotoPath, strAD_ManagerCode,"Manage","");
							
							if(Boolean.valueOf((String) resultList.getString("result"))){ //성공
								if(RedisDataUtil.getBaseConfig("PERMISSION_AD_PWD_CHG").equals("Y")){	//비밀번호 변경
		                            String sOldLogonPW = arrresultList_old.getJSONObject(0).getString("LOGONPASSWORD");
		                            AES aes = new AES(aeskey, "N");
		                            sOldLogonPW = aes.decrypt(sOldLogonPW);
		                            if (!strDecLogonPassword.equals(sOldLogonPW))
		                            {
		                            	CoviMap resultList2 = new CoviMap();
		    							resultList2 = resultList = orgADSvc.adChangePassword(strAD_SamAccountName,sOldLogonPW,strDecLogonPassword);
		    							if(!Boolean.valueOf((String) resultList2.getString("result"))){ //실패
		    								returnList.put("status", Return.FAIL);
		    								returnList.put("message", " [AD] " + resultList.getString("Reason"));
		    								throw new Exception(" [AD] " + resultList.getString("Reason"));
		    							}
		                            }
								}
							}
							else {
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [AD] " + resultList.getString("Reason"));
								throw new Exception(" [AD] " + resultList.getString("Reason"));
							}
						}else{
							//사용자 비활성화
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.adDisableUser(strCode,strCompanyCode,strDeptCode,strJobPositionCode,strJobTitleCode,strJobLevelCode,strRegionCode,strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [AD] " + resultList.getString("Reason"));
								throw new Exception(" [AD] " + resultList.getString("Reason"));
							}
						}
					}
				}
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + e.getMessage());
				throw new Exception(" [AD] " + e.getMessage());
			} catch(Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + e.getMessage());
				throw new Exception(" [AD] " + e.getMessage());
			}
			
			//Exchange 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && !strEX_PrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y") && strEX_IsUse.equals("Y")){
					int icheckexch = 0;
					if(arrresultList_old.getJSONObject(0).getString("EX_USERID").equals("")){
						icheckexch = orgADSvc.insertUserExchInfo(params);
					}else{
						icheckexch = orgADSvc.updateUserExchInfo(params);
					}
					
					if(icheckexch != 0){	//sys_object_user_exchange 정보 입력 성공
						if(strIsUse.equals("Y")) {
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.exchModifyUser(strCode,strEX_StorageServer,strEX_StorageGroup,strEX_StorageStore,strEX_PrimaryMail,strEX_SecondaryMail,strMSN_SIPAddress,strAD_CN,strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [Exch] " + resultList.getString("Reason"));
								throw new Exception(" [Exch] " + resultList.getString("Reason"));
							}
						} else { //비활성화
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.exchDisableUser(strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [Exch] " + resultList.getString("Reason"));
								throw new Exception(" [Exch] " + resultList.getString("Reason"));
							}
						}
					} 
				}
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch(Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		
			//SFB 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncMessenger").equals("Y") && !strMSN_SIPAddress.equals("") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y") && strMSN_ISUSE.equals("Y")){
					int icheckmsn = 0;
					if(arrresultList_old.getJSONObject(0).getString("MSN_USERID").equals("")){
						icheckmsn = orgADSvc.insertUserMSNInfo(params);
					}else{
						icheckmsn = orgADSvc.updateUserMSNInfo(params);
					}
					
					if(icheckmsn != 0) {
						if(strIsUse.equals("Y")) {
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.msnEnableUser(strAD_SamAccountName,strMSN_SIPAddress,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [SFB] " + resultList.getString("Reason"));
								throw new Exception(" [SFB] " + resultList.getString("Reason"));
							}
						} else {
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.msnDisableUser(strAD_SamAccountName,strMSN_SIPAddress,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
								returnList.put("status", Return.FAIL);
								returnList.put("message", " [SFB] " + resultList.getString("Reason"));
								throw new Exception(" [SFB] " + resultList.getString("Reason"));
							}
						}
					}
				}
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [SFB] " + e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [SFB] " + e.getMessage());
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			returnList.put("object", result);
			
			if(result != 0 ){
				returnList.put("result", "ok");			
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			} else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "실패하였습니다");
			}			
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
	 * updateIsHRUser : 사용자 인사 연동 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateishruser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsHRUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsHR = request.getParameter("IsHR");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strCode);
			params.put("IsHR", strIsHR);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsHRUser(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsADUser : 사용자 AD 연동 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisaduser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsADUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsAD = request.getParameter("IsAD");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strCode);
			params.put("IsAD", strIsAD);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsADUser(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * getdeptlist : 조직도 - 그룹 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getgrouplist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getgrouplist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String lang = SessionHelper.getSession("lang");
		String domain = request.getParameter("domain");
		String grouptype = request.getParameter("grouptype");
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try{
			CoviMap params = new CoviMap();

			params.put("domaincode", domain);
			params.put("grouptype", grouptype);
			
			CoviList result = (CoviList) orgSyncManageSvc.selectGroupList(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap dbOrgGroupData = (CoviMap) jsonobject;
				
				// 트리를 그리기 위한 데이터
				//dbOrgGroupData.put("no", getSortNo(dbOrgGroupData.get("SortPath").toString()));
				dbOrgGroupData.put("no", dbOrgGroupData.get("GroupCode").toString());
				dbOrgGroupData.put("nodeName", DicHelper.getDicInfo(dbOrgGroupData.get("GroupName").toString(),lang));
				dbOrgGroupData.put("nodeValue", dbOrgGroupData.get("GroupCode").toString());
				dbOrgGroupData.put("gr_id", dbOrgGroupData.get("GroupID").toString());
				//tmp.put("type", "0") 폴더 아이콘 사용 안함;
				//dbOrgGroupData.put("pno", getParentSortNo(dbOrgGroupData.get("SortPath").toString()));
				dbOrgGroupData.put("pno", dbOrgGroupData.get("MemberOf").toString());
				dbOrgGroupData.put("chk", "Y");
				dbOrgGroupData.put("rdo", "N");
				dbOrgGroupData.put("url", "javascript:getOrgListData(\"" + dbOrgGroupData.get("DomainCode").toString() + "\", \"" + dbOrgGroupData.get("GroupCode").toString() + "\", \"" + dbOrgGroupData.get("GroupType").toString() + "\", \"group\");");
				
				resultList.add(dbOrgGroupData);
			}
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * getarbitrarygrouplist : 조직관리 - 임의그룹 목록(직위/직책/직급)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getarbitrarygrouplist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getarbitrarygrouplist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strDomain = request.getParameter("domain");
		String strGrouptype = request.getParameter("grouptype");
		String strIsUse = request.getParameter("IsUse");
		String strIsHR = request.getParameter("IsHR");
		String strIsMail = request.getParameter("IsMail");
		String strSearchText = request.getParameter("searchText");
		String strSearchType = request.getParameter("searchType");
		
		// 값이 비어있을경우 NULL 값으로 전달
		strDomain = strDomain.isEmpty() ? null : strDomain; 
		strGrouptype = strGrouptype.isEmpty() ? null : strGrouptype;
		strIsUse = strIsUse.isEmpty() ? null : strIsUse;
		strIsHR = strIsHR.isEmpty() ? null : strIsHR;
		strIsMail = strIsMail.isEmpty() ? null : strIsMail;
		strSearchText = strSearchText.isEmpty() ? null : strSearchText;
		strSearchType = strSearchType.isEmpty() ? null : strSearchType;

		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "gr.SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		params.put("domaincode", strDomain);
		params.put("grouptype", strGrouptype);
		params.put("IsUse", strIsUse);
		params.put("IsHR", strIsHR);
		params.put("IsMail", strIsMail);
		params.put("searchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
		params.put("searchType", strSearchType);
		if("gr.SortKey".equals(strSortColumn)) {
			params.put("rownumOrderby", "SortKey "+strSortDirection);
		}else {
			params.put("rownumOrderby", strSortColumn +" "+ strSortDirection);
		}
		
		CoviMap jobjResult = orgSyncManageSvc.selectArbitraryGroupList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 

		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * getarbitrarygroupdropdownlist : 조직관리 - 임의그룹 드롭다운 목록(직위,직책,직급)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getarbitrarygroupdropdownlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getarbitrarygroupdropdownlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strDomain = request.getParameter("domain");
		
		// 값이 비어있을경우 NULL 값으로 전달
		strDomain = strDomain.isEmpty() ? null : strDomain; 

		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("domaincode", strDomain);
		CoviMap listData = orgSyncManageSvc.selectArbitraryGroupDropDownList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
	
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value = "admin/orgmanage/changearbitrarygroupsetting.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changearbitrarygroupsetting(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		String[] TargetID = new String[1];
		int result = 0; 
		try {
			String strtType = request.getParameter("type");
			String strGroupType = request.getParameter("GroupType");
			String strTargetCode = request.getParameter("targetCode");
			String strToBeValue = request.getParameter("tobeValue");
			TargetID[0] = strTargetCode;
			
			CoviMap params = new CoviMap();
			CoviMap params2 = new CoviMap();
			CoviMap params3 = new CoviMap();
			
			params.put("Type", strtType);
			params.put("GroupType", strGroupType);
			params.put("TargetCode", strTargetCode);
			params.put("GroupCode", strTargetCode);
			params.put("ToBeValue", strToBeValue);
			
			params2.put("TargetID", TargetID);
			
			CoviList arrresultList = (CoviList)orgSyncManageSvc.selectDeptInfoList(params2).get("list");
			
			String strType =arrresultList.getJSONObject(0).getString("GroupType"); 
			String strGroupCode =arrresultList.getJSONObject(0).getString("GroupCode");
			String strIsUse =arrresultList.getJSONObject(0).getString("IsUse");
		
			params3.put("ObjectCode",strGroupCode);
			params3.put("GroupCode",strGroupCode);
			params3.put("GroupType",strType);
			params3.put("groupCode",strGroupCode);
			
			CoviMap listData = orgSyncManageSvc.selectGroupUserList(params3);
			int listCount = listData.getInt("cnt");

			if(listCount > 0 && strtType.equals("IsUse") && strIsUse.equals("Y")) { 
				returnList.put("status", Return.FAIL);
				returnList.put("message", strGroupCode);
				return returnList;
			} else {					
				returnObj = orgSyncManageSvc.updateArbitraryGroup(params);
				if(returnObj.getString("result").equals("OK")){
					result = 1;
					//타임스퀘어 Group 활성/비활성화
					if(strtType.equals("IsUse") && orgSyncManageSvc.getTSSyncTF()) {
						if(strGroupType.toUpperCase().equals("JOBTITLE") || strGroupType.toUpperCase().equals("JOBLEVEL") || strGroupType.toUpperCase().equals("JOBPOSITION")){
							params.put("IsUse", strToBeValue);
							result = orgSyncManageSvc.isUseGroupSyncUpdate(params,strToBeValue);						
						}					
					}
				} else {
					result = 0;
				}
			}
			if(result != 0){
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "실패하였습니다");
			}
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "admin/orgmanage/deletearbitrarygrouplist.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deletearbitrarygrouplist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int result = 0;
		String   TargetIDTemp = null;
		String[] TargetID = null;
		String TypeCode = null;
		CoviMap returnData = new CoviMap();
		CoviMap params = null;
		
		try {
			params = new CoviMap();
			
			TargetIDTemp		= request.getParameter("TargetID");
			TargetID			= TargetIDTemp.split(",");
			
			params.put("TargetID",TargetID);
			
			CoviList arrresultList = (CoviList) orgSyncManageSvc.selectDeptInfoList(params).get("list");
			
			int max = arrresultList.size();
			for (int i = 0; i < max; i++) {
				String strType =arrresultList.getJSONObject(i).getString("GroupType"); 
				String strGroupCode =arrresultList.getJSONObject(i).getString("GroupCode");
				String strGroupName =arrresultList.getJSONObject(i).getString("DisplayName");
				String sCompanyName =arrresultList.getJSONObject(i).getString("CompanyName").split(";")[0];
				String sOUPath =arrresultList.getJSONObject(i).getString("OUPath");

				CoviMap params2 = new CoviMap();
				params2.put("ObjectCode",strGroupCode);
				params2.put("GroupCode",strGroupCode);
				params2.put("GroupType",strType);
				params2.put("groupCode",strGroupCode);
				
				CoviMap listData = orgSyncManageSvc.selectGroupUserList(params2);
				int listCount = listData.getInt("cnt");
				
				if(listCount > 0) {
					returnData.put("status", Return.FAIL);
					returnData.put("message", strGroupCode);
					return returnData;
				} else {
					result = orgSyncManageSvc.deleteGroup(params2);					
				}
				
				if(result != 0){
					returnData.put("data", result);
					returnData.put("result", "ok");
					returnData.put("status", Return.SUCCESS);
					returnData.put("message", "조회되었습니다");
				
					//타임스퀘어 Group 비활성화
					if(result != 0 && orgSyncManageSvc.getTSSyncTF()) {
						if(strType.toUpperCase().equals("JOBTITLE") || strType.toUpperCase().equals("JOBLEVEL") || strType.toUpperCase().equals("JOBPOSITION"))					
							orgSyncManageSvc.deleteGroupSync(params2);
					}
					
					//AD 연동
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
						CoviMap resultList = orgADSvc.adDeleteGroup(strType,strGroupCode,strGroupName,sCompanyName,sOUPath,"Manage","");
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnData.put("result", "ok");
							returnData.put("status", Return.FAIL);
							returnData.put("message", " [AD] " + resultList.getString("Reason"));
							throw new Exception(" [AD] " + resultList.getString("Reason"));
						}
					}
				} else {
					returnData.put("result", "ok");
					returnData.put("status", Return.FAIL);
				}
			}
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "admin/orgmanage/movesortkey.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap movesortkey(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int result;
		String pStrGR_Code_A		= null;
		String pStrGR_Code_B		= null;
		CoviMap params = null;
		CoviMap returnData = null;
		
		try {
			returnData = new CoviMap();
			params = new CoviMap();
			
			pStrGR_Code_A = request.getParameter("pStrGR_Code_A");		
			pStrGR_Code_B = request.getParameter("pStrGR_Code_B");

			params.put("GR_Code_A",pStrGR_Code_A);
			params.put("GR_Code_B",pStrGR_Code_B);
			
			returnData = orgSyncManageSvc.updateArbitraryGroupListSortKey(params);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}
	
	/**
	 * getAuthorityinfo : 沅뚰븳 �젙蹂� List 議고쉶
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getAuthoritylist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAuthoritylist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strDomain = request.getParameter("domain");
		String strIsUse = request.getParameter("IsUse");
		String strIsMail = request.getParameter("IsMail");
				
		// 媛믪씠 鍮꾩뼱�엳�쓣寃쎌슦 NULL 媛믪쑝濡� �쟾�떖
		strDomain = strDomain.isEmpty() ? null : strDomain; 
		strIsUse = strIsUse.isEmpty() ? null : strIsUse;
		strIsMail = strIsMail.isEmpty() ? null : strIsMail;
		
		//�젙�젹 諛� �럹�씠吏�
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("domaincode", strDomain);
		params.put("IsUse", strIsUse);
		params.put("IsMail", strIsMail);
		if("gr.SortKey".equals(strSortColumn)) {
			params.put("rownumOrderby", "SortKey "+strSortDirection);
		}else {
			params.put("rownumOrderby", strSortColumn +" "+ strSortDirection);
		}
		
		CoviMap jobjResult = orgSyncManageSvc.selectAuthorityList(params);
		
		CoviMap returnObj = new CoviMap(); 

		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "議고쉶 �꽦怨�");
		
		return returnObj;
	}
	
	/**
	 * 沅뚰븳 議고쉶 �뙘�뾽 湲곕낯
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getdefaultsetauthority.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDefaultSetAuthority(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strDomainCode = request.getParameter("domainCode");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("domainCode", strDomainCode);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectDefaultSetAuthority(params).get("list");
			
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
	
	/**
	 * 沅뚰븳 �젙蹂� 議고쉶
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/selectauthorityinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectAuthorityInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGroupCode = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", strGroupCode);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectAuthorityinfo(params).get("list");
			
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
	
	/**
	 * insertDeptInfo : 부서 정보 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/insertdeptinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertDeptInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
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
			String strIsMail = request.getParameter("IsMail");
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
			String strChkDeptSchedule = request.getParameter("ChkDeptSchedule");

			String[] resultString = getDeptEtcInfo(strCompanyCode, strMemberOf).split("&");
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
			
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			
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
			
			returnList.put("object", orgSyncManageSvc.insertGroup(params));
			
			//부서일정 추가
			if(strChkDeptSchedule.equalsIgnoreCase("Y")) {
				params.put("FolderType", "Schedule");
				params.put("OwnerCode", params.get("ManagerCode") != null && !params.get("ManagerCode").equals("") ? params.get("ManagerCode") : "superadmin");
				params.put("CreateYN", "N");
				
				int cnt = orgSyncManageSvc.insertDeptScheduleCreation(params);
				if(cnt > 0) {
					orgSyncManageSvc.insertDeptScheduleInfo();
				}
			}
			
			//인디메일 부서 추가
			if(orgSyncManageSvc.getIndiSyncTF() && strIsMail.equals("Y") && !strPrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				if(!orgSyncManageSvc.addGroup(params)) {
					addStatus = 1;
				}
			}
			//타임스퀘어 부서 추가
			if(orgSyncManageSvc.getTSSyncTF() && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				if(orgSyncManageSvc.addGroupSync(params) != 1) {
					addStatus = 2;
				}
			}
			
			//AD 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y")){
					params.put("gr_code", strGroupCode);
					String sOUPath_Temp = "";
					String sManagerCode_Temp = "";
					String sCompanyName_Temp = "";
					
					CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
					sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
					sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
					sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];
					
					CoviMap resultList = orgADSvc.adAddDept(strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,sOUPath_Temp,strPrimaryMail,"Manage","");
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + resultList.getString("Reason"));
						throw new Exception(" [AD] " + resultList.getString("Reason"));
					}
				}
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			}
			
			//Exchange 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y") && RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y") ){
					if(!strPrimaryMail.equals("")){
						CoviMap resultList = new CoviMap();
						resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [Exch] " + resultList.getString("Reason"));
							throw new Exception(" [Exch] " + resultList.getString("Reason"));
						}
					}
				}
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			}
			
			//path 전체 수정
			if(RedisDataUtil.getBaseConfig("IsRebuildDeptPath").equals("Y")){
				orgSyncManageSvc.updateDeptPathInfoAll();
			}			
			
			if(addStatus == 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}else if(addStatus == 1) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 추가 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메일)");
			}else if(addStatus == 2) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 추가 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
			}
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
	 * updateDeptInfo : 부서 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updatedeptinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateDeptInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
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
			String strIsMail = request.getParameter("IsMail");
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
			
			String[] currentString = getDeptEtcInfo(strCompanyCode, strGroupCode).split("&");
			String crntGroupPath = "";
			if(currentString.length > 0) {
				crntGroupPath = currentString[1];
			}//현재부서그룹패스
			
			String[] resultString = getDeptEtcInfo(strCompanyCode, strMemberOf).split("&");
			String strCompanyID = "";
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";
			
			if(resultString.length > 0) {
				strCompanyID = resultString[0];
				strGroupPath = resultString[1] + strGroupCode + ";";
				
				if(resultString[1].contains(crntGroupPath)) {
					returnList.put("message", DicHelper.getDic("msg_parentDeptError"));
					returnList.put("status", Return.FAIL);
					returnList.put("result", "parentDeptError");
					return returnList;
				}
				
				strSortPath = resultString[2] + String.format("%015d", Integer.parseInt(strSortKey)) + ";";
				strOUPath = resultString[3] + strDisplayName + ";";
			}
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
				strPrimaryMail = strEX_PrimaryMail;
			}
			
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
			
			//Old Data
			CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
			String sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
			String sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
			String sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];
			String sOldIsMail = arrGroupList.getJSONObject(0).getString("IsMail");
			
			returnList.put("object", orgSyncManageSvc.updateGroup(params));
			orgSyncManageSvc.updateDeptScheduleInfo(params);
			
			//하위부서 Path 정보 업데이트
			int iSize = 0;
			CoviList arrChildGroupList = orgSyncManageSvc.selectDeptPathInfo(params).getJSONArray("list");
			iSize = arrChildGroupList.size();
			for(int j=0; j<iSize; j++){
				CoviMap params2 = new CoviMap();
				params2.put("GroupCode", arrChildGroupList.getJSONObject(j).getString("GroupCode")) ;
				params2.put("OUPath", arrChildGroupList.getJSONObject(j).getString("OUPath")) ;
				params2.put("SortPath", arrChildGroupList.getJSONObject(j).getString("SortPath")) ;
				params2.put("GroupPath", arrChildGroupList.getJSONObject(j).getString("GroupPath")) ;
				orgSyncManageSvc.updateDeptPathInfo(params2);
			}
			
			//인디메일 부서 업데이트
			if(orgSyncManageSvc.getIndiSyncTF() && !strPrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				if(strhidtxtUseMailConnect.equalsIgnoreCase("N") && strIsMail.equals("Y")) {
					params.put("GroupStatus", "A");
					if(!orgSyncManageSvc.addGroup(params)) { 
						modifyStatus = 1;
					}
				} else if(strhidtxtUseMailConnect.equalsIgnoreCase("Y") && strIsMail.equals("Y")) {
					params.put("GroupStatus", "A");
					if(!orgSyncManageSvc.modifyGroup(params)) {
						modifyStatus = 1;
					}
				} else if(strhidtxtUseMailConnect.equalsIgnoreCase("Y") && strIsMail.equals("N")) {
					params.put("GroupStatus", "S");
					if(!orgSyncManageSvc.modifyGroup(params)) {
						modifyStatus = 1;
					}
				}
			}
			
			//타임스퀘어 부서 업데이트
			if(orgSyncManageSvc.getTSSyncTF() && RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				params.put("SyncMode", "G");
				if(orgSyncManageSvc.updateGroupSync(params) == 0) {
					modifyStatus = 2;
				}
			}
			
			//AD 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")&& RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y")){
					params.put("gr_code", strGroupCode);
					CoviMap resultList = new CoviMap();
					
					if(strIsMail.equals("Y")) {
						resultList = orgADSvc.adModifyDept(strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,strOUPath,sOUPath_Temp,strPrimaryMail,"Manage","");
					} else {
						resultList = orgADSvc.adDeleteDept(strGroupCode, strDisplayName, sCompanyName_Temp, strOUName, sOUPath_Temp,"Manage","");
					}
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + resultList.getString("Reason"));
						throw new Exception(" [AD] " + resultList.getString("Reason"));
					}
				}
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [AD] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			}
			
			//Exchange 연동
			try{
				if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y") && !strPrimaryMail.equals("")){
					CoviMap resultList = new CoviMap();
					if(strIsMail.equals("Y")){
						resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
					}else if(strIsMail.equals("N") && !strIsMail.equals(sOldIsMail)){
						resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
					}
					
					if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [Exch] " + resultList.getString("Reason"));
						throw new Exception(" [Exch] " + resultList.getString("Reason"));
					}
				}
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", " [Exch] " + ex.getMessage());
				throw new Exception(ex.getMessage());
			}
			
			//path 전체 수정
			if(RedisDataUtil.getBaseConfig("IsRebuildDeptPath").equals("Y")){
				orgSyncManageSvc.updateDeptPathInfoAll();
			}
			
			if(RedisDataUtil.getBaseConfig("DeptScheuleAutoCreation").equals("Y")) {
				orgSyncManageSvc.updateDeptScheduleInfo(params);
			}
			
			if(modifyStatus == 0) {
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}else if(modifyStatus == 1) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메일)");
			}else if(modifyStatus == 2) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
			}
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	protected String getDeptEtcInfo(String CompanyCode, String MemberOf) {
		String CompanyID = "";
		String GroupPath = "";
		String SortPath = "";
		String OUPath = "";

		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", CompanyCode);
			params.put("MemberOf", MemberOf);
			
			CoviMap returnList = orgSyncManageSvc.selectDeptEtcInfo(params);
			
			CompanyID = returnList.getJSONArray("list").getJSONObject(0).getString("CompanyID");
			GroupPath = returnList.getJSONArray("list").getJSONObject(0).getString("GroupPath");
			SortPath = returnList.getJSONArray("list").getJSONObject(0).getString("SortPath");
			OUPath = returnList.getJSONArray("list").getJSONObject(0).getString("OUPath");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return CompanyID + "&" + GroupPath + "&" + SortPath + "&" + OUPath;
	}
	
	@RequestMapping(value = "admin/orgmanage/movesortkey_deptuser.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap movesortkey_deptuser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
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
			
			returnData = orgSyncManageSvc.updateDeptUserListSortKey(params);
			
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnData;
	}

	/**
	 * getisduplicategroupcode : 임의그룹 중복 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getisduplicategroupcode.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getisduplicategroupcode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGroupCode = request.getParameter("GroupCode");
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("GroupCode", strGroupCode);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateGroupCode(params).get("list"));
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
	 * registarbitarygroup : 임의그룹 추가
	 * @param req
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */		
	@RequestMapping(value="admin/orgmanage/registarbitarygroup.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap registarbitarygroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		int cnt = 0;
		CoviMap params = null;
		CoviMap returnObj = null;
		CoviMap groupMap = null;
		
		try {			
			
			returnObj = new CoviMap();
			params = new CoviMap();
			
			String strUR_Code = SessionHelper.getSession("UR_Code");
			
			String strMode = request.getParameter("Mode");
			String strType = request.getParameter("Type");
			String strTypeCode = request.getParameter("TypeCode");
			String strGroupCode = request.getParameter("GroupCode");
			String strGroupName = request.getParameter("GroupName");			
			String strMultiGroupName =request.getParameter("MultiGroupName"); //현재 넘겨주지 않고 있음
			//String strMultiGroupName = request.getParameter("GroupName") + ";;;;;;;;;"; //js전역변수 dicObj 값 ';' 구분자로 전달받을 수 있도록 수정할 것
			String strCompanyCode = request.getParameter("CompanyCode");
			String strIsUse = request.getParameter("IsUse");
			String strIsHR = request.getParameter("IsHR");
			String strIsMail = request.getParameter("IsMail");
			String strPriorityOrder = request.getParameter("PriorityOrder");
			String strDescription = request.getParameter("Description");
			String strMailAddress = request.getParameter("MailAddress");
			String strOUName = request.getParameter("OUName");
			String strEX_PrimaryMail = request.getParameter("EX_PrimaryMail");
			String strSecondaryMail = request.getParameter("SecondaryMail");
			String strGroupPath = "";
			String strOUPath = "";
			String strSortPath = "";	
			
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
				strMailAddress = strEX_PrimaryMail;
			}
			
			// 값이 비어있을경우 NULL 값으로 전달	
			strMailAddress = strMailAddress.isEmpty() ? null : strMailAddress; 
			
			if(strTypeCode != null){
				groupMap = new CoviMap();
				
				groupMap.put("GroupCode", strTypeCode);
				CoviMap groupObj = orgSyncManageSvc.selectGroupInsertData(groupMap);
				
				strGroupPath = groupObj.getJSONArray("list").getJSONObject(0).getString("GroupPath");
				strOUPath = groupObj.getJSONArray("list").getJSONObject(0).getString("OUPath");
				strSortPath = groupObj.getJSONArray("list").getJSONObject(0).getString("SortPath");	
			}
			
			//sys_object
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");
			params.put("IsSync", "Y");
			
			params.put("Mode", strMode);
			params.put("UR_Code", strUR_Code);
			params.put("GroupCode", strGroupCode);
			params.put("CompanyCode", strCompanyCode);
			params.put("GroupType", strType);
			params.put("MemberOf",  strTypeCode);
			params.put("GroupPath", strGroupPath + strGroupCode + ";");
			params.put("GroupName", strGroupName);
			params.put("DisplayName", strGroupName);
			params.put("MultiDisplayName", strMultiGroupName);			
			params.put("MultiGroupName", strMultiGroupName);
			params.put("OUPath", strOUPath + strGroupName + ";");
			params.put("SortKey", strPriorityOrder);
			params.put("SortPath", strSortPath + String.format("%015d", Integer.parseInt(strPriorityOrder)) + ";");
			params.put("IsUse", strIsUse);
			params.put("IsDisplay", strIsUse);
			params.put("IsMail", strIsMail);
			params.put("IsHR", strIsHR);
			params.put("Description", strDescription);
			params.put("MailAddress", strMailAddress);
			params.put("SecondaryMail", strSecondaryMail);
			params.put("PrimaryMail", strMailAddress);
			params.put("GroupStatus", strIsUse.equals("Y") ? "A" : "S");
			
			if( strMode!= null && strMode.toUpperCase().equals("ADD") ){
				cnt  = orgSyncManageSvc.insertGroup(params);
				
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");

				}
				if(cnt != 0){
					//인디메일 Group 추가
					if(orgSyncManageSvc.getIndiSyncTF() && strIsMail.equals("Y") && !strMailAddress.equals("")) {
						if(strType.toUpperCase().equals("JOBTITLE") && RedisDataUtil.getBaseConfig("IsDBJobTitleSync").equals("Y")) {
							if(!orgSyncManageSvc.addGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 등록 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						} else if(strType.toUpperCase().equals("JOBLEVEL") && RedisDataUtil.getBaseConfig("IsDBJobLevelSync").equals("Y")) {
							if(!orgSyncManageSvc.addGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 등록 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						} else if(strType.toUpperCase().equals("JOBPOSITION") && RedisDataUtil.getBaseConfig("IsDBJobPositionSync").equals("Y")) {
							if(!orgSyncManageSvc.addGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 등록 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						}
					}
					
					//타임스퀘어 Group 추가
					if(orgSyncManageSvc.getTSSyncTF()) {
						if(strType.toUpperCase().equals("JOBTITLE") || strType.toUpperCase().equals("JOBLEVEL") || strType.toUpperCase().equals("JOBPOSITION"))
							orgSyncManageSvc.addGroupSync(params);
					}
					
					//AD 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && !strOUName.equals("")){
							params.put("gr_code", strGroupCode);
							String sOUPath_Temp = "";
							String sManagerCode_Temp = "";
							String sCompanyName_Temp = "";
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
							sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];

							resultList = orgADSvc.adAddGroup(strType,strGroupCode,strGroupName,sCompanyName_Temp,strTypeCode,strOUName,sOUPath_Temp,strMailAddress,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnObj.put("result", "FAIL");
								returnObj.put("message", " [AD] " + resultList.getString("Reason"));
								return returnObj;
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					}
					
					//Exchange 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
							if(!strMailAddress.equals("")){
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.exchEnableGroup(strGroupCode,strMailAddress,strSecondaryMail,"Manage","");
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
									returnObj.put("result", "FAIL");
									returnObj.put("message", " [Exch] " + resultList.getString("Reason"));
									return returnObj;
								}
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					}
				}
			}else{
				cnt  = orgSyncManageSvc.updateGroup(params);
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");
				}
				
				if(cnt != 0){
					//인디메일 Group 수정
					if(orgSyncManageSvc.getIndiSyncTF() && strIsMail.equals("Y") && !strMailAddress.equals("")) {
						if(strType.toUpperCase().equals("JOBTITLE") && RedisDataUtil.getBaseConfig("IsDBJobTitleSync").equals("Y")) {
							if(!orgSyncManageSvc.modifyGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						} else if(strType.toUpperCase().equals("JOBLEVEL") && RedisDataUtil.getBaseConfig("IsDBJobLevelSync").equals("Y")) {
							if(!orgSyncManageSvc.modifyGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						} else if(strType.toUpperCase().equals("JOBPOSITION") && RedisDataUtil.getBaseConfig("IsDBJobPositionSync").equals("Y")) {
							if(!orgSyncManageSvc.modifyGroup(params)) {
								returnObj.put("result", "FAIL");
								returnObj.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
								return returnObj;
							}
						}
					}
					
					//타임스퀘어 Group 수정
					if(orgSyncManageSvc.getTSSyncTF()) {
						if(strType.toUpperCase().equals("JOBTITLE") || strType.toUpperCase().equals("JOBLEVEL") || strType.toUpperCase().equals("JOBPOSITION"))
							orgSyncManageSvc.updateGroupSync(params);
					}
					
					//AD 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && !strOUName.equals("")){
							params.put("gr_code", strGroupCode);
							String sOUPath_Temp = "";
							String sManagerCode_Temp = "";
							String sCompanyName_Temp = "";
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
							sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];

							if(strIsUse.equals("Y")){
								resultList = orgADSvc.adAddGroup(strType,strGroupCode,strGroupName,sCompanyName_Temp,strTypeCode,strOUName,sOUPath_Temp,strMailAddress,"Manage","");
							}else if(strIsUse.equals("N") && !strIsUse.equals(arrGroupList.getJSONObject(0).getString("IsUse"))){
								resultList = orgADSvc.adDeleteGroup(strType,strGroupCode,strGroupName,sCompanyName_Temp,sOUPath_Temp,"Manage","");
							}
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnObj.put("result", "FAIL");
								returnObj.put("message", " [AD] " + resultList.getString("Reason"));
								return returnObj;
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					}
					
					//Exchange 연동
					try{
						if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
							CoviMap resultList = new CoviMap();
							if(strIsMail.equals("Y")){
								resultList = orgADSvc.exchEnableGroup(strGroupCode,strMailAddress,strSecondaryMail,"Manage","");
							}else if(!strIsMail.equals("Y")){
								resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
							}
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnObj.put("result", "FAIL");
								returnObj.put("message", " [Exch] " + resultList.getString("Reason"));
								return returnObj;
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
						returnObj.put("result", "FAIL");
					}
				}
			}
			
			return returnObj;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	/**
	 * getregionlist : 조직관리 - 지역
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getregionlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getregionlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strdomain = request.getParameter("domain");
		String strIsUse = request.getParameter("IsUse");
		String strIsHR = request.getParameter("IsHR");
		String strIsMail = request.getParameter("IsMail");
		String strSearchText = request.getParameter("searchText");
		String strSearchType = request.getParameter("searchType");
		
		// 값이 비어있을경우 NULL 값으로 전달
		strdomain = strdomain.isEmpty() ? null : strdomain;
		strIsUse = strIsUse.isEmpty() ? null : strIsUse;
		strIsHR = strIsHR.isEmpty() ? null : strIsHR;
		strIsMail = strIsMail.isEmpty() ? null : strIsMail;
		strSearchText = strSearchText.isEmpty() ? null : strSearchText;
		strSearchType = strSearchType.isEmpty() ? null : strSearchType;

		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "gr.SortKey";
		String strSortDirection = "ASC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100)); 
		params.put("domain", strdomain);
		params.put("IsUse", strIsUse);
		params.put("IsHR", strIsHR);
		params.put("IsMail", strIsMail);
		params.put("searchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
		params.put("searchType", strSearchType);
		if("gr.SortKey".equals(strSortColumn)) {
			params.put("rownumOrderby", "SortKey "+strSortDirection);
		}else {
			params.put("rownumOrderby", strSortColumn +" "+ strSortDirection);
		}
		
		CoviMap jobjResult = orgSyncManageSvc.selectRegionList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * registregion : 지역 추가
	 * @param req
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */		
	@RequestMapping(value="admin/orgmanage/registregion.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap registregion(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		
		int cnt = 0;

		CoviMap params = null;
		CoviMap returnObj = null;

		CoviMap groupMap = null;
		
		try {			
			
			returnObj = new CoviMap();
			params = new CoviMap();
			
			String strUR_Code = SessionHelper.getSession("UR_Code");
			
			String strMode = request.getParameter("Mode");
			String strType = request.getParameter("Type");
			String strTypeCode = request.getParameter("TypeCode");
			String strGroupCode = request.getParameter("GroupCode");
			String strGroupName =request.getParameter("GroupName");
			String strMultiGroupName =request.getParameter("MultiGroupName");
			String strCompanyCode = request.getParameter("CompanyCode");
			String strIsUse = request.getParameter("IsUse");
			String strIsHR = request.getParameter("IsHR");
			String strIsMail = request.getParameter("IsMail");
			String strPriorityOrder = request.getParameter("PriorityOrder");
			String strDescription = request.getParameter("Description");
			String strMailAddress = request.getParameter("MailAddress");
			String strGroupPath = "";
			String strOUPath = "";
			String strSortPath = "";			
			
			// 값이 비어있을경우 NULL 값으로 전달	
			//strMemberOf = strMemberOf.isEmpty() ? null : strMemberOf; 
			
			//GroupPath, OUPath, SortPath 가져오기
			groupMap = new CoviMap();
			groupMap.put("GroupCode", strTypeCode);

			CoviMap groupObj = orgSyncManageSvc.selectGroupInsertData(groupMap);
			
			if(!groupObj.isEmpty() && !groupObj.getJSONArray("list").isEmpty()){
				strGroupPath = groupObj.getJSONArray("list").getJSONObject(0).getString("GroupPath");
				strOUPath = groupObj.getJSONArray("list").getJSONObject(0).getString("OUPath");
				strSortPath = groupObj.getJSONArray("list").getJSONObject(0).getString("SortPath");	
			}
			
			//sys_object
			params.put("ObjectCode", strGroupCode);
			params.put("ObjectType", "GR");
			params.put("IsSync", "Y");
			
			params.put("Mode", strMode);
			params.put("UR_Code", strUR_Code);
			params.put("GroupCode", strGroupCode);
			params.put("CompanyCode", strCompanyCode);
			params.put("GroupType", strType);
			params.put("MemberOf",  strTypeCode);
			params.put("GroupPath", strGroupPath + strGroupCode + ";");
			params.put("GroupName", strGroupName);
			params.put("MultiGroupName", strMultiGroupName);
			params.put("DisplayName", strGroupName);
			params.put("MultiDisplayName", strMultiGroupName);
			params.put("ShortName", strGroupName);
			params.put("MultiShortName", strMultiGroupName);
			params.put("OUPath", strOUPath + strGroupName + ";");
			params.put("SortKey", strPriorityOrder);
			params.put("SortPath", strSortPath + String.format("%015d", Integer.parseInt(strPriorityOrder)) + ";");
			params.put("IsUse", strIsUse);
			params.put("IsDisplay", strIsUse);
			params.put("IsMail", strIsMail);
			params.put("IsHR", strIsHR);
			params.put("Description", strDescription);
			params.put("MailAddress", strMailAddress);
			params.put("PrimaryMail", strMailAddress);
			
			if( strMode!= null && strMode.toUpperCase().equals("ADD") ){
				cnt  = orgSyncManageSvc.insertGroup(params);
			}else{
				cnt  = orgSyncManageSvc.updateGroup(params);
			}
			
			if(cnt > 0 ){
				returnObj.put("result", "OK");
			} else {
				returnObj.put("result", "FAIL");
			}
			return returnObj;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 * getaddjoblist : 조직관리 - 겸직
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getaddjoblist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getaddjoblist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		// Parameters
		String strIsHR = request.getParameter("IsHR");
		String strSearchText = request.getParameter("searchText");
		String strSearchType = request.getParameter("searchType");
		String strCompanyCode = request.getParameter("CompanyCode");
		
		// 값이 비어있을경우 NULL 값으로 전달
		strIsHR = strIsHR.isEmpty() ? null : strIsHR;
		strSearchText = strSearchText.isEmpty() ? null : strSearchText;
		strSearchType = strSearchType.isEmpty() ? null : strSearchType;
		strCompanyCode = strCompanyCode.isEmpty() ? null : strCompanyCode;

		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "BG.Seq";
		String strSortDirection = "DESC";
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		 
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		params.put("IsHR", strIsHR);
		params.put("searchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
		params.put("searchType", strSearchType);
		if("BG.Seq".equals(strSortColumn)) {
			params.put("rownumOrderby", "Seq "+strSortDirection);
		}else {
			params.put("rownumOrderby", strSortColumn +" "+ strSortDirection);
		}
		
		params.put("CompanyCode", strCompanyCode);
		
		CoviMap jobjResult = orgSyncManageSvc.selectAddJobList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		

		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
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
	@RequestMapping(value="admin/orgmanage/registaddjob.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap registaddjob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		
		int cnt = 0;

		CoviMap params = null;
		CoviMap returnObj = null;

		CoviMap groupMap = null;
		CoviMap groupObj = null;

		Boolean bDept = true;
		Boolean bJTitle = true;
		Boolean bJPosition = true;
		Boolean bJLevel = true;
		try {			
			
			returnObj = new CoviMap();
			params = new CoviMap();
			
			String strRegistUR_Code = SessionHelper.getSession("UR_Code");  //SuperAdmin
			
			String strMode = request.getParameter("Mode");  //add
			String strType = request.getParameter("Type");  //AddJob
			String strUserCode = request.getParameter("UserCode");  //sunnyhwang			
			String strAddJob_Company = request.getParameter("AddJob_Company");  //null
			String strAddJob_Group = request.getParameter("AddJob_Group");  //RD02
			String strAddJob_Title = request.getParameter("AddJob_Title");  //1_T000
			String strAddJob_Position = request.getParameter("AddJob_Position");  //1_P000
			String strAddJob_Level = request.getParameter("AddJob_Level");  //1_L000
			
			String strAddJob_CompanyName = request.getParameter("AddJob_CompanyName");  // 코비젼
			String strAddJob_GroupName = request.getParameter("AddJob_GroupName");  //연구2팀
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
			CoviList arrresultList = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
			String strOriginLogonID =arrresultList.getJSONObject(0).getString("LogonID");
			String strOriginDisplayName =arrresultList.getJSONObject(0).getString("DisplayName");
			String strOriginCompanyCode =arrresultList.getJSONObject(0).getString("CompanyCode");
			String strOriginDeptCode =arrresultList.getJSONObject(0).getString("DeptCode");
			String strOriginJobPositionCode =arrresultList.getJSONObject(0).getString("JobPositionCode");
			String strOriginJobTitleCode =arrresultList.getJSONObject(0).getString("JobTitleCode");
			String strOriginJobLevelCode =arrresultList.getJSONObject(0).getString("JobLevelCode");
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
				cnt  = orgSyncManageSvc.insertAddjob(params);
				
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");
				}
				
				if(cnt != 0){
					//인디메일 겸직 연동
					try {
						CoviMap reObject = null;
						if(orgSyncManageSvc.getIndiSyncTF()) {
							params.put("DisplayName", strOriginDisplayName);
							params.put("MailAddress", strOriginMailAddress);
							reObject = orgSyncManageSvc.getUserStatus(params);
							if(reObject.has("returnCode") && reObject.has("result")){
								
								if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
									
									String sGroupMail = "";
									
									if(!(strAddJob_Group == null || strAddJob_Group.equals("") || strAddJob_Group.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Group == null || stroldAddJob_Group.equals("") || stroldAddJob_Group.equalsIgnoreCase("undefined"))) {
										params.put("GroupCode",strAddJob_Group);
										sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", "");
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Position == null || stroldAddJob_Position.equals("") || stroldAddJob_Position.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Position.isEmpty()) {
											params.put("GroupCode",strAddJob_Position);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", "");
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Title == null || stroldAddJob_Title.equals("") || stroldAddJob_Title.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Title.isEmpty()) {
											params.put("GroupCode",strAddJob_Title);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", "");
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Level == null || stroldAddJob_Level.equals("") || stroldAddJob_Level.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Level.isEmpty()) {
											params.put("GroupCode",strAddJob_Level);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", "");
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
								}
							
							}
						}
					} catch (NullPointerException e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(orgSyncManageSvc.getTSSyncTF()) {
						cnt = orgSyncManageSvc.insertUpdateAddJobSync(params2);							
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
					} catch (NullPointerException e) {
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					} catch (Exception e) {
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					}
				}
			}else{				
				//겸직 수정
				cnt  = orgSyncManageSvc.updateAddjob(params);
				
				if(cnt > 0 ){
					returnObj.put("result", "OK");
				} else {
					returnObj.put("result", "FAIL");
				}
				
				if(cnt != 0){
					//인디메일 겸직 연동
					try {
						CoviMap reObject = null;
						if(orgSyncManageSvc.getIndiSyncTF()) {
							params.put("DisplayName", strOriginDisplayName);
							params.put("MailAddress", strOriginMailAddress);
							reObject = orgSyncManageSvc.getUserStatus(params);
							if(reObject.has("returnCode") && reObject.has("result")){
								
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
									
									if((!(strAddJob_Group == null || strAddJob_Group.equals("") || strAddJob_Group.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Group == null || stroldAddJob_Group.equals("") || stroldAddJob_Group.equalsIgnoreCase("undefined")))) {
										params.put("GroupCode",strAddJob_Group);
										sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										params.put("GroupCode",stroldAddJob_Group);
										sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										sOldGroupMail=bDept?sOldGroupMail:"";
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if((!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Position == null || stroldAddJob_Position.equals("") || stroldAddJob_Position.equalsIgnoreCase("undefined")))) {
										if(!strAddJob_Position.isEmpty()) {
											params.put("GroupCode",strAddJob_Position);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										if(!stroldAddJob_Position.isEmpty()) {
											params.put("GroupCode",stroldAddJob_Position);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJPosition?sOldGroupMail:"";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if((!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Title == null || stroldAddJob_Title.equals("") || stroldAddJob_Title.equalsIgnoreCase("undefined")))) {
										if(!strAddJob_Title.isEmpty()) {
											params.put("GroupCode",strAddJob_Title);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										if(!stroldAddJob_Title.isEmpty()) {
											params.put("GroupCode",stroldAddJob_Title);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJTitle?sOldGroupMail:"";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if((!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined")) 
											|| !(stroldAddJob_Level == null || stroldAddJob_Level.equals("") || stroldAddJob_Level.equalsIgnoreCase("undefined")))) {
										if(!strAddJob_Level.isEmpty()) {
											params.put("GroupCode",strAddJob_Level);
											sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sGroupMail = "";
										if(!stroldAddJob_Level.isEmpty()) {
											params.put("GroupCode",stroldAddJob_Level);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJLevel?sOldGroupMail:"";
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
								}
							
							}
						}
					} catch (NullPointerException e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(orgSyncManageSvc.getTSSyncTF()) {						
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
						cnt = orgSyncManageSvc.insertUpdateAddJobSync(params2);							
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
					} catch (NullPointerException e) {
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					} catch (Exception e) {
						returnObj.put("result", "FAIL");
						returnObj.put("message", " [AD] " + e.getMessage());
						return returnObj;
					}
				}
			}
			return returnObj;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	// 겸직 정보 변경 => 테이블 구조 변경으로 인하여 보류
	@RequestMapping(value = "admin/orgmanage/changeaddjobsetting.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changeaddjobsetting(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnObj = new CoviMap();
		
		try {
			String strtID = request.getParameter("id");
			String strToBeValue = request.getParameter("tobeValue");
			
			CoviMap params = new CoviMap();
			
			params.put("id", strtID);
			params.put("ToBeValue", strToBeValue);
			
			returnObj = orgSyncManageSvc.updateAddJobSetting(params);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
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
	@RequestMapping(value = "admin/orgmanage/deleteaddjob.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteaddjob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		
		int result=0;
		String   TargetIDTemp		= null;
		String[] TargetID		= null;
		String TypeCode			= null;
		CoviMap params = null;
		CoviMap returnData = new CoviMap();
		Boolean bDept = true;
		Boolean bJTitle = true;
		Boolean bJPosition = true;
		Boolean bJLevel = true;
		
		try {
			params = new CoviMap();
			
			TargetIDTemp		= request.getParameter("TargetID");
			TargetID			= TargetIDTemp.split(",");
			
			params.put("TargetID",TargetID);
			
			int max = TargetID.length;
			for (int i = 0; i < max; i++) {				
				CoviMap params2 = new CoviMap();				
				params2.put("Seq",TargetID[i]);
				CoviList arrresultList = (CoviList) orgSyncManageSvc.selectAddJobInfoList(params2).get("list");
				params2.put("UserCode", arrresultList.getJSONObject(0).getString("UserCode"));
				params2.put("SyncManage", "Manage");
				params2.put("SyncType","DELETE");
				params2.put("CompanyCode", arrresultList.getJSONObject(0).getString("CompanyCode"));
				
				CoviList arrresultList2 = (CoviList) orgSyncManageSvc.selectUserInfo(params2).get("list");
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
				String strOriginCompanyCode =arrresultList2.getJSONObject(0).getString("CompanyCode");
				String strOriginDeptCode =arrresultList2.getJSONObject(0).getString("DeptCode");
				String strOriginJobPositionCode =arrresultList2.getJSONObject(0).getString("JobPositionCode");
				String strOriginJobTitleCode =arrresultList2.getJSONObject(0).getString("JobTitleCode");
				String strOriginJobLevelCode =arrresultList2.getJSONObject(0).getString("JobLevelCode");
				String strOriginPhoneNumber =arrresultList2.getJSONObject(0).getString("PhoneNumber");
				String strOriginPhoneNumberInter =arrresultList2.getJSONObject(0).getString("PhoneNumberInter");
				String strOriginSortKey =arrresultList2.getJSONObject(0).getString("SortKey");
				String strOriginAD_SamAccountName = arrresultList2.getJSONObject(0).getString("AD_SamAccountName");
				String strOriginMailAddress = arrresultList2.getJSONObject(0).getString("MailAddress");
				
				result = orgSyncManageSvc.deleteAddjob(params2);
				
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
						if(orgSyncManageSvc.getIndiSyncTF()) {
							params2.put("DisplayName", strOriginDisplayName);
							params2.put("MailAddress", strOriginMailAddress);
							params2.put("mailStatus", "A");
							params2.put("DecLogonPassword", "");
							reObject = orgSyncManageSvc.getUserStatus(params2);
							if(reObject.has("returnCode") && reObject.has("result")){
								
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
										sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										sOldGroupMail=bDept?sOldGroupMail:"";
										
										params2.put("GroupMailAddress", "");
										params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Position == null || strAddJob_Position.equals("") || strAddJob_Position.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Position.isEmpty()) {
											params2.put("GroupCode",strAddJob_Position);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJPosition?sOldGroupMail:"";
										
										params2.put("GroupMailAddress", "");
										params2.put("oldGroupMailAddress", sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Title == null || strAddJob_Title.equals("") || strAddJob_Title.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Title.isEmpty()) {
											params2.put("GroupCode",strAddJob_Title);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJTitle?sOldGroupMail:"";
										
										params2.put("GroupMailAddress", "");
										params2.put("oldGroupMailAddress", sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
									if(!(strAddJob_Level == null || strAddJob_Level.equals("") || strAddJob_Level.equalsIgnoreCase("undefined"))) {
										if(!strAddJob_Level.isEmpty()) {
											params2.put("GroupCode",strAddJob_Level);
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										} else sOldGroupMail = "";
										sOldGroupMail=bJLevel?sOldGroupMail:"";
										
										params2.put("GroupMailAddress", "");
										params2.put("oldGroupMailAddress", sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));
									}
								}
							
							}
						}
					} catch (NullPointerException e) {
						returnData.put("status", Return.FAIL);
						returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					} catch (Exception e) {
						returnData.put("status", Return.FAIL);
						returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
					}
					
					//타임스퀘어 겸직 연동
					if(orgSyncManageSvc.getTSSyncTF()) {
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
						result = orgSyncManageSvc.insertUpdateAddJobSync(params3);							
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
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * getisduplicatemail : 메일 주소 중복 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getisduplicatemail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getisduplicatemail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strMailAddress = request.getParameter("MailAddress");
		String strCode = request.getParameter("Code");
		
		// 값이 비어있을경우 NULL 값으로 전달	
		strCode = strCode.isEmpty() ? null : strCode;
		
		CoviMap returnList = new CoviMap();

		try{
			CoviMap params = new CoviMap();

			params.put("MailAddress", strMailAddress);
			params.put("Code", strCode);
			
			returnList.put("list", orgSyncManageSvc.selectIsDuplicateMail(params).get("list"));
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
	 * getavailablecompanylist : 조직관리 - 회사 리스트 가져오기(DropDown 바인딩용)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getavailablecompanylist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getavailablecompanylist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap params = new CoviMap();
		
		CoviList assignedDomainList = ComUtils.getAssignedDomainCode();
		params.put("assignedDomain", assignedDomainList);
		
		CoviMap listData = orgSyncManageSvc.selectAvailableCompanyList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
	
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}

	@RequestMapping(value = "admin/orgmanage/getjobinfolist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getJobInfoList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainCode = request.getParameter("domainCode");
		String groupType = request.getParameter("groupType");
		
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();

			params.put("domainCode", domainCode);
			params.put("groupType", groupType);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectJobInfoList(params).get("list");
			
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
	
	@RequestMapping(value = "admin/orgmanage/getservicetypelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getServiceTypeList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try{
			CoviList resultList = (CoviList) orgSyncManageSvc.selectServiceTypeList().get("list");
			
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
	
	/**
	 * insertUpdateUserInfo : 사용자 정보 추가/수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/insertupdateuserinfo.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap insertUpdateUserInfo(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		StringBuffer returnMsg = new StringBuffer();
		try {
			String strInitPW = req.getParameter("InitPW");
			String strMode = req.getParameter("mode");
			MultipartFile fileInfo = req.getFile("FileInfo");
			String strNickName = req.getParameter("Initials");
			//String strLogonPassword = MD5.encrypt(strDecLogonPassword);
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
			String strMailAddress = req.getParameter("MailAddress");
			String strChargeBusiness = req.getParameter("ChargeBusiness");
			String strLanguageCode = req.getParameter("LanguageCode");
			String strRegistDate = req.getParameter("RegistDate");
			String strJobType = "Origin";
			String strBaseGroupSortKey = "0";
			String strCompanyName = req.getParameter("CompanyName");
			String strDeptName = req.getParameter("DeptName");
			String strRegionName = req.getParameter("RegionName");
			/*********추가 DB 기본 정보**********/
			String strLicSeq = req.getParameter("LicSeq");
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
			String strMobileThemeCode = "MobileTheme_Base";
			String strTimeZoneCode = "TIMEZO0048";
			String strReserved1 = req.getParameter("Reserved1");
			String strReserved2 = req.getParameter("Reserved2");
			String strReserved3 = req.getParameter("Reserved3");
			String strReserved4 = req.getParameter("Reserved4");
			String strReserved5 = req.getParameter("Reserved5");
			
			// 추가 사용자 부가설정 정보 (AD 사용이 아닐 때) 
			String strCountryID = req.getParameter("AD_CountryID");
			String strCountryCode = req.getParameter("AD_CountryCode");
			String strPostOfficeBox = req.getParameter("MailBox");
			String strOfficeAddress = req.getParameter("OfficeAddress");

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
			
			params.put("LicSeq", strLicSeq);
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
			params.put("MailAddress", strMailAddress);
			params.put("ExternalMailAddress", strExternalMailAddress);
			params.put("ChargeBusiness", strChargeBusiness);
			params.put("PhoneNumberInter", strPhoneNumberInter);
			params.put("LanguageCode", strLanguageCode);
			params.put("CheckUserIP", strCheckUserIP);
			params.put("StartIP", strStartIP);
			params.put("EndIP", strEndIP);
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
			
			// 추가 사용자 부가설정 정보 (AD 사용이 아닐 때)
			params.put("CountryID", strCountryID);
			params.put("CountryCode", strCountryCode);
			params.put("CityState_01", strCityState_01);
			params.put("CityState_02", strCityState_02);
			params.put("PostOfficeBox", strPostOfficeBox);
			params.put("OfficeAddress", strOfficeAddress);			
			
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
			
			//Old User
			String stroldJobPositionCode = "";
			String stroldJobTitleCode = "";
			String stroldJobLevelCode = "";
			
			String reMsg = null;
			if(strMode.equals("modify")) {
				int modifyStatus = 0;
				
				//Old User
				CoviList arrOldUserList = new CoviList();
				arrOldUserList = (CoviList) orgSyncManageSvc.selectUserInfo(params).get("list");
				stroldJobPositionCode = arrOldUserList.getJSONObject(0).get("JobPositionCode") != null && !"".equals(arrOldUserList.getJSONObject(0).get("JobPositionCode")) ?
						arrOldUserList.getJSONObject(0).getString("JobPositionCode") : "";
				stroldJobTitleCode = arrOldUserList.getJSONObject(0).get("JobTitleCode") != null && !"".equals(arrOldUserList.getJSONObject(0).get("JobTitleCode")) ?
						arrOldUserList.getJSONObject(0).getString("JobTitleCode") : "";
				stroldJobLevelCode = arrOldUserList.getJSONObject(0).get("JobLevelCode") != null && !"".equals(arrOldUserList.getJSONObject(0).get("JobLevelCode")) ?
						arrOldUserList.getJSONObject(0).getString("JobLevelCode") : "";

				params.put("SyncType", "UPDATE");
				if(strUseMailConnect.equalsIgnoreCase("Y"))
					params.put("mailStatus", "A");
				else
					params.put("mailStatus", "S");
				//orgSyncManageSvc.updateUserInfo(params);
				orgSyncManageSvc.updateUser(params);
				returnMsg.append("|<b>DB</b> : SUCCESS<br/>");
				
				//인디메일 사용자 수정
				try {
					CoviMap reObject = null;
					if(orgSyncManageSvc.getIndiSyncTF() && !strMailAddress.equals("")) {
						reObject = orgSyncManageSvc.getUserStatus(params);
						if(reObject.has("returnCode") && reObject.has("result")){
							
							if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
								
								try {
									params.put("GroupCode",strDeptCode);
									String sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									params.put("GroupCode",stroldDeptCode);
									String sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = orgSyncManageSvc.modifyUser(params);
									
									if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) {
										throw new Exception(" [메일] " + reObject.get("returnMsg"));
									} else {
										if(!strJobPositionCode.equalsIgnoreCase(stroldJobPositionCode)) {
											if(!strJobPositionCode.isEmpty()) {
												params.put("GroupCode",strJobPositionCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobPositionCode.isEmpty()) {
												params.put("GroupCode",stroldJobPositionCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
										if(!strJobTitleCode.equalsIgnoreCase(stroldJobTitleCode)) {
											if(!strJobTitleCode.isEmpty()) {
												params.put("GroupCode",strJobTitleCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobTitleCode.isEmpty()) {
												params.put("GroupCode",stroldJobTitleCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
										if(!strJobLevelCode.equalsIgnoreCase(stroldJobLevelCode)) {
											if(!strJobLevelCode.isEmpty()) {
												params.put("GroupCode",strJobLevelCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobLevelCode.isEmpty()) {
												params.put("GroupCode",stroldJobLevelCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
									}
									returnMsg.append("|<b>메일</b> : SUCCESS<br/>");
								} catch (NullPointerException e) {
									returnMsg.append("|<b>메일</b> : FAIL<br/>");
									returnList.put("status", Return.FAIL);
									reMsg += " [메일] " + reObject.get("returnMsg");
									LOGGER.error(e.getLocalizedMessage(), e);
								} catch (Exception e) {
									returnMsg.append("|<b>메일</b> : FAIL<br/>");
									returnList.put("status", Return.FAIL);
									reMsg += " [메일] " + reObject.get("returnMsg");
									LOGGER.error(e.getLocalizedMessage(), e);
								}
								
							}else if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("-1")) { //응답코드0:성공  result-1:계정없음
								if(strUseMailConnect.equalsIgnoreCase("Y")) { //메일사용여부 Y 이면
									try {
										params.put("GroupCode",strDeptCode);
										String sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										
										reObject = orgSyncManageSvc.addUser(params);
										if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) {
											throw new Exception(" [메일] " + reObject.get("returnMsg"));
										} else {
											if(!strJobPositionCode.isEmpty()) {
												params.put("GroupCode",strJobPositionCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));										
											}
											if(!strJobTitleCode.isEmpty()) {
												params.put("GroupCode",strJobTitleCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
											}
											if(!strJobLevelCode.isEmpty()) {
												params.put("GroupCode",strJobLevelCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
											}
										}
										returnMsg.append("|<b>메일</b> : SUCCESS<br/>");
									} catch (NullPointerException e) {
										returnMsg.append("|<b>메일</b> : FAIL<br/>");
										returnList.put("status", Return.FAIL);
										reMsg += " [메일] " + reObject.get("returnMsg");
										LOGGER.error(e.getLocalizedMessage(), e);
									} catch (Exception e) {
										returnMsg.append("|<b>메일</b> : FAIL<br/>");
										returnList.put("status", Return.FAIL);
										reMsg += " [메일] " + reObject.get("returnMsg");
										LOGGER.error(e.getLocalizedMessage(), e);
									}
								}
							}
						
						}
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [메일] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [메일] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				//타임스퀘어 사용자 수정
				try {
					if(orgSyncManageSvc.getTSSyncTF() && !strMailAddress.equals("")) {
						params.put("DeptCode", strDeptCode);
						params.put("oldDeptCode", stroldDeptCode);
						
						modifyStatus = 2; //TS 싱크 오류
						if(orgSyncManageSvc.updateUserSyncupdate(params) == 1) {							
							modifyStatus = 0;
							returnMsg.append("|<b>TS</b> : SUCCESS<br/>");
						}
						else
							throw new Exception(" [TS] updateUserSyncupdate");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>TS</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [TS] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>TS</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [TS] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				CoviMap params_old = new CoviMap();
				CoviMap  resultList_old = new CoviMap();
				CoviList  arrresultList_old = new CoviList();
				params_old.put("UserCode", strUserCode);
				arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
				
				//AD 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
						int icheckad = 0;
						if(arrresultList_old.getJSONObject(0).getString("AD_USERID").equals("")){
							icheckad = orgADSvc.insertUserADInfo(params);
						}else{
							icheckad = orgADSvc.updateUserADInfo(params);
						}
						
						if(icheckad != 0){	//sys_object_user_ad 정보 수정 성공
							if(strAD_IsUse.equals("Y")){
								params.put("gr_code", strDeptCode);
								String sOUPath_Temp = "";
								String sAD_ServerURL = RedisDataUtil.getBaseConfig("AD_ServerURL");
								String sUserPrincipalName = strUserCode + "@"+sAD_ServerURL;
								CoviList arrGroupList = new CoviList();
								CoviMap resultList = new CoviMap();
								arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
								sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
								
								resultList = orgADSvc.adModifyUser(strUserCode, strCompanyCode, strDeptCode, stroldDeptCode, sOUPath_Temp, strLogonID, strDecLogonPassword, strEmpNo, strAD_DisplayName,
										strJobPositionCode, strJobTitleCode, strJobLevelCode, strRegionCode, strAD_FirstName, strAD_LastName, strAD_UserAccountControl, strAD_AccountExpires, 
										strAD_PhoneNumber, strAD_Mobile, strAD_Fax, strAD_Info, strAD_Title, strAD_Department, strAD_Company, strEX_PrimaryMail, strEX_SecondaryMail, 
										strAD_CN, strAD_SamAccountName, sUserPrincipalName, strPhotoPath, strAD_ManagerCode,"Manage","");
								
								if(Boolean.valueOf((String) resultList.getString("result"))){ //성공
									if(RedisDataUtil.getBaseConfig("PERMISSION_AD_PWD_CHG").equals("Y")){	//비밀번호 변경
			                            String sOldLogonPW = arrresultList_old.getJSONObject(0).getString("LOGONPASSWORD");
			                            AES aes = new AES(aeskey, "N");
			                            sOldLogonPW = aes.decrypt(sOldLogonPW);
			                            if (!sOldLogonPW.equals(strDecLogonPassword))
			                            {
			                            	CoviMap resultList2 = new CoviMap();
			    							resultList2 = resultList = orgADSvc.adChangePassword(strAD_SamAccountName,sOldLogonPW,strDecLogonPassword);
			    							if(!Boolean.valueOf((String) resultList2.getString("result"))){ //실패
			    								returnList.put("status", Return.FAIL);
			    								reMsg += " [AD] " + resultList.getString("Reason");
			    								throw new Exception(reMsg);
			    							}
			                            }
									}
								}
								else {
									returnList.put("status", Return.FAIL);
									reMsg += " [AD] " + resultList.getString("Reason");
									throw new Exception(reMsg);
								}
							}else{
								//사용자 비활성화
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.adDisableUser(strUserCode,strCompanyCode,strDeptCode,strJobPositionCode,strJobTitleCode,strJobLevelCode,strRegionCode,strAD_SamAccountName,"Manage","");
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
									returnList.put("status", Return.FAIL);
									reMsg += " [AD] " + resultList.getString("Reason");
									throw new Exception(reMsg);
    							}
							}
						}
						returnMsg.append("|<b>AD</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [AD] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch(Exception e) {
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [AD] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				//Exchange 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && !strEX_PrimaryMail.equals("") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
						if(arrresultList_old.getJSONObject(0).getString("EX_ISUSE").equals("Y")) {
							if(strEX_IsUse.equals("Y")) { //수정
								int icheckexch = 0;
								if(arrresultList_old.getJSONObject(0).getString("EX_USERID").equals("")){
									icheckexch = orgADSvc.insertUserExchInfo(params);
								}else{
									icheckexch = orgADSvc.updateUserExchInfo(params);
								}
								
								if(icheckexch != 0){	//sys_object_user_exchange 정보 입력 성공
									CoviMap resultList = new CoviMap();
									resultList = orgADSvc.exchModifyUser(strUserCode,strEX_StorageServer,strEX_StorageGroup,strEX_StorageStore,strEX_PrimaryMail,strEX_SecondaryMail,strMSN_SIPAddress,strAD_CN,strAD_SamAccountName,"Manage","");
									
									if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
										returnList.put("status", Return.FAIL);
										reMsg += " [Exch] " + resultList.getString("Reason");
										throw new Exception(reMsg);
									}
								}
							} else { //비활성화
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.exchDisableUser(strAD_SamAccountName,"Manage","");
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
									returnList.put("status", Return.FAIL);
									reMsg += " [Exch] " + resultList.getString("Reason");
									throw new Exception(reMsg);
								}
							}
						}else{
							if(strEX_IsUse.equals("Y")){
								int icheckexch = 0;
								if(arrresultList_old.getJSONObject(0).getString("EX_USERID").equals("")){
									icheckexch = orgADSvc.insertUserExchInfo(params);
								}else{
									icheckexch = orgADSvc.updateUserExchInfo(params);
								}
								
								if(icheckexch != 0){	//sys_object_user_exchange 정보 입력 성공
									CoviMap resultList = new CoviMap();
									resultList = orgADSvc.exchEnableUser(strUserCode,strEX_StorageServer,strEX_StorageGroup,strEX_StorageStore,strEX_PrimaryMail,strEX_SecondaryMail,strMSN_SIPAddress,strAD_CN,strAD_SamAccountName,"Manage","");
									
									if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
										returnList.put("status", Return.FAIL);
										reMsg += " [Exch] " + resultList.getString("Reason");
										throw new Exception(reMsg);
									}
								}
							}
						}
						returnMsg.append("|<b>Exch</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [Exch] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch(Exception e) {
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [Exch] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			
				//SFB 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMessenger").equals("Y") && !strMSN_SIPAddress.equals("") && RedisDataUtil.getBaseConfig("IsUserSync").equals("Y")){
						int icheckmsn = 0;
						if(arrresultList_old.getJSONObject(0).getString("MSN_USERID").equals("")){
							icheckmsn = orgADSvc.insertUserMSNInfo(params);
						}else{
							icheckmsn = orgADSvc.updateUserMSNInfo(params);
						}
						
						if(icheckmsn != 0) {
							if(strMSN_IsUse.equals("Y")) {
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.msnEnableUser(strAD_SamAccountName,strMSN_SIPAddress,"Manage","");
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
									returnList.put("status", Return.FAIL);
									reMsg += " [SFB] " + resultList.getString("Reason");
									throw new Exception(reMsg);
								}
							} else {
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.msnDisableUser(strAD_SamAccountName,strMSN_SIPAddress,"Manage","");
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
									returnList.put("status", Return.FAIL);
									reMsg += " [SFB] " + resultList.getString("Reason");
									throw new Exception(reMsg);
								}
							}
						}
						returnMsg.append("|<b>SFB</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>SFB</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [SFB] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch(Exception e) {
					returnMsg.append("|<b>SFB</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [SFB] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				if(modifyStatus == 0) {
					returnList.put("result", "OK");
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "갱신되었습니다");
					returnList.put("etcs", "");
				}else if(modifyStatus == 2) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
				}
				
			} else {
				int addStatus = 0;
				//orgSyncManageSvc.insertUserInfo(params);
				params.put("SyncType", "INSERT");
				params.put("mailStatus", "A");
				int ireturn = orgSyncManageSvc.insertUser(params);
				if(ireturn < 1) {
					returnMsg.append("|<b>DB</b> : FAIL<br/>");
					throw new Exception("Object Error!");
				}
				returnMsg.append("|<b>DB</b> : SUCCESS<br/>");
				
				//인디메일 사용자 추가
				try {
					CoviMap reObject = null;
					if(orgSyncManageSvc.getIndiSyncTF() && !strMailAddress.equals("")) {
						reObject = orgSyncManageSvc.getUserStatus(params);
						if(reObject.has("returnCode") && reObject.has("result")){
						
							if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
								
								try {
									params.put("GroupCode",strDeptCode);
									String sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									params.put("GroupCode",stroldDeptCode);
									String sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
									
									params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
									params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
									
									reObject = orgSyncManageSvc.modifyUser(params);
									
									if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) {
										throw new Exception(" [메일] " + reObject.get("returnMsg"));
									} else {
										if(!stroldJobPositionCode.equalsIgnoreCase(strJobPositionCode)) {
											if(!strJobPositionCode.isEmpty()) {
												params.put("GroupCode",strJobPositionCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobPositionCode.isEmpty()) {
												params.put("GroupCode",stroldJobPositionCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
										if(!stroldJobTitleCode.equalsIgnoreCase(strJobTitleCode)) {
											if(!strJobTitleCode.isEmpty()) {
												params.put("GroupCode",strJobTitleCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobTitleCode.isEmpty()) {
												params.put("GroupCode",stroldJobTitleCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
										if(!stroldJobLevelCode.equalsIgnoreCase(strJobLevelCode)) {
											if(!strJobLevelCode.isEmpty()) {
												params.put("GroupCode",strJobLevelCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sGroupMail = "";
											if(!stroldJobLevelCode.isEmpty()) {
												params.put("GroupCode",stroldJobLevelCode);
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
											} else sOldGroupMail = "";
											
											params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(params);
											if(!reObject.get("returnCode").toString().equals("0")||!"SUCCESS".equals(reObject.get("returnMsg"))) throw new Exception(" [메일] " + reObject.get("returnMsg"));
										}
									}
									returnMsg.append("|<b>메일</b> : SUCCESS<br/>");
								} catch (NullPointerException e) {
									returnMsg.append("|<b>메일</b> : FAIL<br/>");
									returnList.put("status", Return.FAIL);
									reMsg += " [메일] " + reObject.get("returnMsg");
									LOGGER.error(e.getLocalizedMessage(), e);
								} catch (Exception e) {
									returnMsg.append("|<b>메일</b> : FAIL<br/>");
									returnList.put("status", Return.FAIL);
									reMsg += " [메일] " + reObject.get("returnMsg");
									LOGGER.error(e.getLocalizedMessage(), e);
								}
								
							}else if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("-1")) { //응답코드0:성공  result-1:계정없음
								if(strUseMailConnect.equalsIgnoreCase("Y")) { //메일사용여부 Y 이면
									try {
										params.put("GroupCode",strDeptCode);
										String sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
										
										params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										
										reObject = orgSyncManageSvc.addUser(params);
										
										if(!reObject.get("returnCode").toString().equals("0")) {
											throw new Exception(" [메일] " + reObject.get("returnMsg"));
										} else {
											if(!strJobPositionCode.isEmpty()) {
												params.put("GroupCode",strJobPositionCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));										
											}
											if(!strJobTitleCode.isEmpty()) {
												params.put("GroupCode",strJobTitleCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
											}
											if(!strJobLevelCode.isEmpty()) {
												params.put("GroupCode",strJobLevelCode);
												sGroupMail = orgSyncManageSvc.selectGroupMail(params); // 그룹의 메일주소
												
												params.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
												params.put("oldGroupMailAddress", "");
												
												reObject = orgSyncManageSvc.modifyUser(params);
												if(!reObject.get("returnCode").toString().equals("0")) throw new Exception(" [메일] " + reObject.get("returnMsg"));	
											}
										}
										returnMsg.append("|<b>메일</b> : SUCCESS<br/>");
									} catch (NullPointerException e) {
										returnMsg.append("|<b>메일</b> : FAIL<br/>");
										returnList.put("status", Return.FAIL);
										reMsg += " [메일] " + reObject.get("returnMsg");
										LOGGER.error(e.getLocalizedMessage(), e);
									} catch (Exception e) {
										returnMsg.append("|<b>메일</b> : FAIL<br/>");
										returnList.put("status", Return.FAIL);
										reMsg += " [메일] " + reObject.get("returnMsg");
										LOGGER.error(e.getLocalizedMessage(), e);
									}
								}
							}
						
						}
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [메일] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>메일</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [메일] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				//타임스퀘어 사용자 추가
				try {
					if(orgSyncManageSvc.getTSSyncTF()) {
						params.put("DeptCode", strDeptCode);
						params.put("oldDeptCode", stroldDeptCode);
						
						addStatus = 2;
						if(orgSyncManageSvc.addUserSync(params) == 1) {
							addStatus = 0;
							returnMsg.append("|<b>TS</b> : SUCCESS<br/>");
						}
						else
							throw new Exception(" [TS] updateUserSyncupdate");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>TS</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [TS] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>TS</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [TS] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				boolean bResult = false;
				
				//AD 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && strAD_IsUse.equals("Y")){
						if(orgADSvc.insertUserADInfo(params) != 0){	//sys_object_user_ad 정보 입력 성공
							params.put("gr_code", strDeptCode);
							bResult = false;
							String sOUPath_Temp = "";
							String sAD_ServerURL = RedisDataUtil.getBaseConfig("AD_ServerURL");
							String sUserPrincipalName = strUserCode + "@"+sAD_ServerURL;
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							
							resultList = orgADSvc.adAddUser(strUserCode, strCompanyCode, strDeptCode, sOUPath_Temp, strLogonID, strDecLogonPassword, strEmpNo, strAD_DisplayName
									,strJobPositionCode, strJobTitleCode,strJobLevelCode, strRegionCode, strAD_FirstName, strAD_LastName, strAD_UserAccountControl, strAD_AccountExpires
									,strAD_PhoneNumber, strAD_Mobile, strAD_Fax, strAD_Info, strAD_Title, strAD_Department, strAD_Company
									,strEX_PrimaryMail, strEX_SecondaryMail, strAD_CN, strAD_SamAccountName, strAD_UserPrincipalName, strPhotoPath, strAD_ManagerCode, strO365_IsUse,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								reMsg += " [AD] " + resultList.getString("Reason");
								throw new Exception(reMsg);
							}
						}
						returnMsg.append("|<b>AD</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [AD] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>AD</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [AD] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
				
				//Exchange 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strEX_IsUse.equals("Y") && !strEX_PrimaryMail.equals("")){
						if(orgADSvc.insertUserExchInfo(params) != 0){	//sys_object_user_exchange 정보 입력 성공
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.exchEnableUser(strUserCode,strEX_StorageServer,strEX_StorageGroup,strEX_StorageStore,strEX_PrimaryMail,strEX_SecondaryMail,strMSN_SIPAddress,strAD_CN,strAD_SamAccountName,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								reMsg += " [Exch] " + resultList.getString("Reason");
								throw new Exception(reMsg);
							}
						}
						returnMsg.append("|<b>Exch</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [Exch] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>Exch</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [Exch] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			
				//SFB 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMessenger").equals("Y") && strMSN_IsUse.equals("Y") && !strMSN_SIPAddress.equals("")){
						if(orgADSvc.insertUserMSNInfo(params) != 0){	//sys_object_user_messenger 정보 입력 성공
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.msnEnableUser(strAD_SamAccountName, strMSN_SIPAddress,"Manage","");
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								returnList.put("status", Return.FAIL);
								reMsg += " [SFB] " + resultList.getString("Reason");
								throw new Exception(reMsg);
							}
						}
						returnMsg.append("|<b>SFB</b> : SUCCESS<br/>");
					}
				} catch (NullPointerException e) {
					returnMsg.append("|<b>SFB</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [SFB] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					returnMsg.append("|<b>SFB</b> : FAIL<br/>");
					returnList.put("status", Return.FAIL);
					reMsg += " [SFB] " + e.getMessage();
					LOGGER.error(e.getLocalizedMessage(), e);
				}

				if(addStatus == 0) {
					returnList.put("result", "OK");
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "갱신되었습니다");
					returnList.put("etcs", "");
				}else if(addStatus == 2) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "추가 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.(메신저)");
				}
			}
			returnList.put("ReturnMsg", returnMsg.toString());
		} catch (NullPointerException e) {
			returnList.put("ReturnMsg", returnMsg.toString());
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
	 * getDeptListForSelect : 조직도 - 부서 목록(select box binding)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getdeptlistforselect.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptListForSelect(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String lang = SessionHelper.getSession("lang");
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("lang", lang);
			params.put("groupCode", gr_code);
			params.put("groupType", grouptype);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectDeptListForCategory(params).get("list");
			
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

	/**
	 * getSubGroupList : 하위 그룹 목록 select
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getsubgrouplist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getSubGroupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "SortKey";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");
				
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();
				
		try{
			
			if(strSort != null && !strSort.isEmpty()) {
				strSortColumn = setRegexString(strSort.split(" ")[0]);
				strSortDirection = setRegexString(strSort.split(" ")[1]);
			}
		 
			// DB Parameter Setting
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			params.put("gr_code", gr_code);
			params.put("grouptype", grouptype);
			params.put("rownumOrderby", "SortPath ASC");		
			
			CoviMap jobjResult = orgSyncManageSvc.selectSubGroupList(params);
			

			returnObj.put("page", jobjResult.get("page"));
			returnObj.put("list", jobjResult.get("list"));
			returnObj.put("result", "ok");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "admin/orgmanage/getgroupname.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGroupName(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		String displayName = "";
		String parentName = "";
		String rootName = "";
		String groupPath = "";
		StringBuffer parentPath = new StringBuffer();
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			params.put("grouptype", grouptype);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectParentName(params).get("list");
			displayName = resultList.getJSONObject(0).getString("DisplayName");
			groupPath = resultList.getJSONObject(0).getString("GroupPath");
			
			if(groupPath.split(";").length > 2) {
				for(int i = 1; i < groupPath.split(";").length-1; i++) {
					params.put("gr_code", groupPath.split(";")[i]);
					params.put("grouptype", "group");
					resultList = (CoviList) orgSyncManageSvc.selectParentName(params).get("list");
					
					parentName += resultList.getJSONObject(0).getString("DisplayName") + " > ";
					if(i == 1) {
						rootName = resultList.getJSONObject(0).getString("DisplayName") + " > ";
					} else {
						parentPath.append(groupPath.split(";")[i] + ";");
					}
					//groupPath = resultList.getJSONObject(0).getString("GroupPath");		
				}
			}
			
			returnList.put("displayName", displayName);
			returnList.put("parentName", parentName);
			returnList.put("rootName", rootName);
			returnList.put("parentPath", parentPath.toString());
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
	 * getGroupUserList : 조직도 - 그룹 사용자 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getgroupuserlist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getGroupUserList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String domainCode = request.getParameter("domainCode");		//회사 이름(코드)
		String gr_code = request.getParameter("gr_code");		//부서 이름(코드)
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "gr.SortKey";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();

		try{
			
			if(strSort != null && !strSort.isEmpty()) {
				strSortColumn = setRegexString(strSort.split(" ")[0]);
				strSortDirection = setRegexString(strSort.split(" ")[1]);
			} 
			// DB Parameter Setting
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			

			params.put("companyCode", domainCode);
			params.put("groupCode", gr_code);
			params.put("rownumOrderby", "(JobTitleSortKey+0) ASC, (JobLevelSortKey+0) ASC, (SortKey+0) ASC, EnterDate ASC, MultiDisplayName ASC"); // mssql 페이징처리용
			
			CoviMap jobjResult = orgSyncManageSvc.selectGroupUserList(params);

			returnObj.put("page", jobjResult.get("page"));
			returnObj.put("list", jobjResult.get("list"));
			returnObj.put("result", "ok");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getGroupMemberList : 조직도 - 그룹 멤버 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getgroupmemberlist.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getGroupMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");		//그룹 이름(코드)
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "gr.SortKey";
		String strSortDirection = "ASC";
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		CoviMap page = new CoviMap();

		try{
			
			if(strSort != null && !strSort.isEmpty()) {
				strSortColumn = setRegexString(strSort.split(" ")[0]);
				strSortDirection = setRegexString(strSort.split(" ")[1]);
			}
			 
			// DB Parameter Setting
			CoviMap params = new CoviMap();

			//params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			//params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("groupCode", gr_code);
			
			CoviMap jobjResult = orgSyncManageSvc.selectGroupMemberList(params);
			
			returnObj.put("page", jobjResult.get("page"));
			returnObj.put("list", jobjResult.get("list"));
			returnObj.put("result", "ok");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getGroupListForSelect : 조직도 - 그룹 목록(select box binding)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getgrouplistforselect.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGroupListForSelect(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String lang = SessionHelper.getSession("lang");
		String gr_code = request.getParameter("gr_code");
		String grouptype = request.getParameter("grouptype");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("lang", lang);
			params.put("groupCode", gr_code);
			params.put("groupType", grouptype);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectGroupListForCategory(params).get("list");
			
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
	
	// 엑셀 다운로드
	@RequestMapping(value = "admin/orgmanage/orglistexceldownload.do" , method = RequestMethod.GET)
	public ModelAndView orgListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String type = request.getParameter("type");
			String groupCode = request.getParameter("groupCode");
			String groupType = request.getParameter("groupType");
			String companyCode = request.getParameter("companyCode");
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			String headerName = URLDecoder.decode(request.getParameter("headerName"),"UTF-8");
			String hasChildGroup = request.getParameter("hasChildGroup");
			
			String[] headerNames = headerName.split(";");
			
			CoviMap params = new CoviMap();
			
			params.put("type", type);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("companyCode", companyCode);
			if(type.equals("user")) {
				params.put("deptCode", groupCode);
				params.put("hasChildGroup", hasChildGroup == null || hasChildGroup.isEmpty() ? "" : hasChildGroup);
			} else if(type.equals("dept")) {
				params.put("gr_code", groupCode);
				params.put("hasChildGroup", hasChildGroup == null || hasChildGroup.isEmpty() ? "" : hasChildGroup);
			} else if(type.equals("group")){//group
				params.put("gr_code", groupCode);
				params.put("grouptype", groupType);
			} else if(type.equalsIgnoreCase("title") || type.equalsIgnoreCase("position") || type.equalsIgnoreCase("level")){//title,position,title
				params.put("domaincode", companyCode);
				params.put("grouptype", groupType);
			} else if(type.equals("region")){
				params.put("domain", companyCode);
				//no param
			} else if(type.equals("addjob")){
				//no param
			} else if(type.equals("groupmember")){
				params.put("groupCodeList", groupCode.split(";"));
			} else if(type.equals("exdept")) {
				params.put("domaincode", companyCode);
			} else if(type.equals("exuser")) {
				params.put("domaincode", companyCode);
			}
			
			CoviMap resultList = orgSyncManageSvc.selectOrgExcelList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Organization_Management");
			mav = new ModelAndView(returnURL, viewParams);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}

	/**
	 * updateIsUseGroup : 그룹 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisusegroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result = 0;		
		
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsUse");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			String strGroupType = request.getParameter("Type");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsUse", strIsUse);
			params.put("GroupType", strGroupType);			
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			result = orgSyncManageSvc.updateIsUseGroup(params);
						
			//타임스퀘어 Group 활성/비활성화
			if(result != 0 && orgSyncManageSvc.getTSSyncTF()) {
				if(strGroupType.toUpperCase().equals("JOBTITLE") || strGroupType.toUpperCase().equals("JOBLEVEL") || strGroupType.toUpperCase().equals("JOBPOSITION"))					
					result = orgSyncManageSvc.isUseGroupSyncUpdate(params,strIsUse);
			}

			returnList.put("object", result);
			if(result != 0){
				returnList.put("result", "ok");			
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "실패하였습니다");
			}					
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
	 * updateIsMailGroup : 그룹 표시여부 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateisdisplaygroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateisdisplaygroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsMail = request.getParameter("IsMail");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsMail", strIsMail);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsDisplayGroup(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsMailGroup : 그룹 메일 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateismailgroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsMailGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsMail = request.getParameter("IsMail");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupCode", strCode);
			params.put("IsMail", strIsMail);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsMailGroup(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * updateIsMailUser : 사용자 사용 여부 update
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updateismailuser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsMailUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String strCode = request.getParameter("Code");
			String strIsUse = request.getParameter("IsMail");
			//String strModID = request.getParameter("ModID");
			String strModDate = request.getParameter("ModDate");
			
			CoviMap params = new CoviMap();
			
			params.put("UserCode", strCode);
			params.put("IsMail", strIsUse);
			//params.put("ModID", strModID);
			params.put("ModifyDate", strModDate);
			
			returnList.put("object", orgSyncManageSvc.updateIsMailUser(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "갱신되었습니다");
			returnList.put("etcs", "");
			
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
	 * deleteGroup : 그룹 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/deletegroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteData = request.getParameter("deleteData");
		int result= 0;
		
		try {
			
			for(int i = 0; i < strDeleteData.split(",").length; i++) {
				if(getHasChildGroup(strDeleteData.split(",")[i])) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroup|" + strDeleteData.split(",")[i]);
					return returnList;
				} else if(getHasUserGroup(strDeleteData.split(",")[i])) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupmember|" + strDeleteData.split(",")[i]);
					return returnList;
				}
			}
			
			CoviMap params = new CoviMap();
			
			String DeleteDataArr[] = strDeleteData.split(",");
			
			params.put("deleteData", DeleteDataArr);
			params.put("TargetID",DeleteDataArr);
			CoviList arrresultList = (CoviList) orgSyncManageSvc.selectDeptInfoList(params).get("list");
									
			int max = arrresultList.size();
			for (int i = 0; i < max; i++) {
				String strType =arrresultList.getJSONObject(i).getString("GroupType"); 
				String strGroupCode =arrresultList.getJSONObject(i).getString("GroupCode");
				String strGroupName =arrresultList.getJSONObject(i).getString("DisplayName");
				String sCompanyName =arrresultList.getJSONObject(i).getString("CompanyName").split(";")[0];
				String sOUPath =arrresultList.getJSONObject(i).getString("OUPath");
				String sOUName =arrresultList.getJSONObject(i).getString("OUName");
				String sGroupType =arrresultList.getJSONObject(i).getString("GroupType");
				CoviMap params2 = new CoviMap();
				
				params2.put("GroupCode", strGroupCode);
				params2.put("ObjectCode", strGroupCode);
				params2.put("GroupType", sGroupType);				
				result = orgSyncManageSvc.deleteGroup(params2);
				
				if(result > 0) {
					returnList.put("object", result);
					returnList.put("result", "ok");

					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "삭제되었습니다");
					returnList.put("etcs", "");
				} else {
					returnList.put("result", "ok");
					returnList.put("status", Return.FAIL);
				}
				
				//타임스퀘어 비활성화
				if(result != 0 && orgSyncManageSvc.getTSSyncTF()) {
					if(sGroupType.toUpperCase().equals("JOBTITLE") || sGroupType.toUpperCase().equals("JOBLEVEL") || sGroupType.toUpperCase().equals("JOBPOSITION"))					
						orgSyncManageSvc.deleteGroupSync(params2);
				}
				
				if(result != 0 && RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
					//AD 연동
					try{
						CoviMap resultList = new CoviMap();
						if(strType.toUpperCase().equals("DEPT")){
							resultList = orgADSvc.adDeleteDept(strGroupCode, strGroupName, sCompanyName, sOUName, sOUPath, "Manage","");
						}else{
							resultList = orgADSvc.adDeleteGroup(strType,strGroupCode, strGroupName, sCompanyName, sOUPath, "Manage","");
						}
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [AD] " + resultList.getString("Reason"));
							return returnList;
						}
					} catch (NullPointerException e) {
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + e.getMessage());
					} catch(Exception e) {
						returnList.put("status", Return.FAIL);
						returnList.put("message", " [AD] " + e.getMessage());
					}
				}
			}
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
			
			hasChild = orgSyncManageSvc.selectHasChildGroup(params);
			
			if(hasChild > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
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
			
			hasUser = orgSyncManageSvc.selectHasUserGroup(params);
			if(hasUser > 0) {
				return true;
			} else {
				return false;
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return false;
	}
	
	/**
	 * moveSortKey_GroupUser : 그룹 우선순위 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/movesortkey_groupuser.do", method = {RequestMethod.GET,RequestMethod.POST})
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
			
			returnData = orgSyncManageSvc.updateGroupUserListSortKey(params);
			
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "admin/orgmanage/getgroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGroupinfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String gr_code = request.getParameter("gr_code");
		
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", gr_code);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectGroupInfo(params).get("list");
			
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
	
	/**
	 * insertGroupInfo : 그룹 정보 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/insertgroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertGroupInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result;
		int addStatus = 0;
		
		try {
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
			String strIsMail = request.getParameter("IsMail");
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
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
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
			result = orgSyncManageSvc.insertGroup(params);
			
			if(result > 0) {
				returnList.put("object", result);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			} else {
				returnList.put("result", "ok");
				returnList.put("status", Return.FAIL);
			}

			if(result != 0){
				//인디메일 그룹 추가
				if(orgSyncManageSvc.getIndiSyncTF() && strIsMail.equals("Y") && !strPrimaryMail.equals("")) {
					if(!orgSyncManageSvc.addGroup(params)) {
						returnList.put("status", Return.FAIL);
						returnList.put("message", "[메일] 부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
						return returnList;
					}
				}
				
				//타임스퀘어 그룹 추가
				if(orgSyncManageSvc.getTSSyncTF()) {
					if(strGroupType.toUpperCase().equals("JOBTITLE") || strGroupType.toUpperCase().equals("JOBLEVEL") || strGroupType.toUpperCase().equals("JOBPOSITION")) {
						if(orgSyncManageSvc.addGroupSync(params) != 1) {
							returnList.put("status", Return.FAIL);
							returnList.put("message", "[메신저] 부서 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
							return returnList;
						}
					}
				}
				
				//AD 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
						params.put("gr_code", strGroupCode);
						String sOUPath_Temp = "";
						String sManagerCode_Temp = "";
						String sCompanyName_Temp = "";
						CoviMap resultList = new CoviMap();
						CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
						sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
						sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
						sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];
						
						switch(strGroupType.toUpperCase()){
							case "COMPANY":
								resultList = orgADSvc.adAddCompany(strGroupCode,strDisplayName,strMemberOf);
								break;
							case "DEPT":
								if(RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y")){
									resultList = orgADSvc.adAddDept(strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,sOUPath_Temp,strPrimaryMail,"Manage","");
								}
								break;
							case "DIVISION":
								if(!strOUName.equals("")){
									resultList = orgADSvc.adAddGroup(strGroupType, strGroupCode, strDisplayName, sCompanyName_Temp, strMemberOf, strOUName, sOUPath_Temp, strPrimaryMail,"Manage","");
								}
								break;
							default :
								if(!strOUName.equals("")){
									resultList = orgADSvc.adAddGroup(strGroupType, strGroupCode, strDisplayName, sCompanyName_Temp, strMemberOf, strOUName, sOUPath_Temp, strPrimaryMail,"Manage","");
								}
								break;
						}
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [AD] " + resultList.getString("Reason"));
							return returnList;
						}
					}
				} catch (NullPointerException ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [AD] " + ex.getMessage());
					LOGGER.error(ex.getLocalizedMessage(), ex);
				} catch (Exception ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [AD] " + ex.getMessage());
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
				
				//Exchange 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strIsMail.equals("Y")){
						CoviMap resultList = new CoviMap();

						switch(strGroupType.toUpperCase()){
							case "COMPANY":
								resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
								break;
							case "DEPT":
								if(RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y") && !strPrimaryMail.equals("")){
									resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
								}
								break;
							default :
								if(RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y") && !strPrimaryMail.equals("")){
									resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
								}
								break;
							}
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [Exch] " + resultList.getString("Reason"));
							return returnList;
						}
					}
				} catch (NullPointerException ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [Exch] " + ex.getMessage());
					LOGGER.error(ex.getLocalizedMessage(), ex);
				} catch (Exception ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", " [Exch] " + ex.getMessage());
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
			}
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
	 * updateGroupInfo : 그룹 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/updategroupinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateGroupInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result;
		
		try {
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
			String strIsDisplay = request.getParameter("IsDisplay");
			String strIsMail = request.getParameter("IsMail");
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
			if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y")&& strIsMail.equals("Y")){
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
			params.put("IsDisplay", strIsDisplay);
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
			String sOUPath_Temp = "";
			String sManagerCode_Temp = "";
			String sCompanyName_Temp = "";
			String sOldIsUse = "";
			String sOldIsMail = "";
			CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
			sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
			sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
			sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];
			sOldIsUse = arrGroupList.getJSONObject(0).getString("IsUse");
			sOldIsMail = arrGroupList.getJSONObject(0).getString("IsMail");
			if(strIsUse.equals("N") && sOldIsUse.equals("Y")){
				if(getHasChildGroup(strGroupCode)) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroup|" + strGroupCode);
					return returnList;
				} else if(getHasUserGroup(strGroupCode)) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "msg_existGroupmember|" + strGroupCode);
					return returnList;
				}
			}
				
			result = orgSyncManageSvc.updateGroup(params);
			if(result > 0) {
				returnList.put("object", result);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "갱신되었습니다");
				returnList.put("etcs", "");
			}
			
			if(result != 0){
				//인디메일 그룹 수정
				if(orgSyncManageSvc.getIndiSyncTF() && !strPrimaryMail.equals("")) {
					if(strhidtxtUseMailConnect.equalsIgnoreCase("N") && strIsMail.equals("Y")) {
						params.put("GroupStatus", "A");
						if(!orgSyncManageSvc.addGroup(params)) { 
							returnList.put("status", Return.FAIL);
							returnList.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
							return returnList;
						}
					} else if(strhidtxtUseMailConnect.equalsIgnoreCase("Y") && strIsMail.equals("Y")) {
						params.put("GroupStatus", "A");
						if(!orgSyncManageSvc.modifyGroup(params)) {
							returnList.put("status", Return.FAIL);
							returnList.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
							return returnList;
						}
					} else if(strhidtxtUseMailConnect.equalsIgnoreCase("Y") && strIsMail.equals("N")) {
						params.put("GroupStatus", "S");
						if(!orgSyncManageSvc.modifyGroup(params)) {
							returnList.put("status", Return.FAIL);
							returnList.put("message", "[메일] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
							return returnList;
						}
					}
				}
				
				//타임스퀘어 그룹 수정
				if(orgSyncManageSvc.getTSSyncTF()) {
					params.put("SyncMode", "G");
					if(strGroupType.toUpperCase().equals("JOBTITLE") || strGroupType.toUpperCase().equals("JOBLEVEL") || strGroupType.toUpperCase().equals("JOBPOSITION")) {
						if(orgSyncManageSvc.addGroupSync(params) != 1) {
							returnList.put("status", Return.FAIL);
							returnList.put("message", "[메신저] 그룹 수정 오류가 발생하였습니다. 관리자에게 문의해주시기 바랍니다.");
							return returnList;
						}
					}
				}
				
				//AD 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y")){
						CoviMap resultList = new CoviMap();
						arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");
						sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
						sManagerCode_Temp = arrGroupList.getJSONObject(0).getString("ManagerCode");
						sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];
						
						switch(strGroupType.toUpperCase()){
							case "COMPANY":
								resultList = orgADSvc.adModifyCompany(strGroupCode,strDisplayName,strMemberOf);
								break;
							case "DEPT":
								if(RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y")){
									if(strIsUse.equals("Y")){
										resultList = orgADSvc.adModifyDept(strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,strOUPath,sOUPath_Temp,strPrimaryMail,"Manage","");
									}else if(strIsUse.equals("N") && !strIsUse.equals(sOldIsUse)){
										resultList = orgADSvc.adDeleteDept(strGroupCode,strDisplayName,sCompanyName_Temp,strOUName,sOUPath_Temp,"Manage","");
									}
								}
								break;
							case "DIVISION":
								if(!strOUName.equals("")){
									if(strIsUse.equals("Y")){
										resultList = orgADSvc.adModifyGroup(strGroupType,strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,sOUPath_Temp,strPrimaryMail,"Manage","");
									}else if(strIsUse.equals("N") && !strIsUse.equals(sOldIsUse)){
										resultList = orgADSvc.adDeleteGroup(strGroupType,strGroupCode,strDisplayName,sCompanyName_Temp,sOUPath_Temp,"Manage","");
									}
								}
								break;
							default :
								if(strIsUse.equals("Y")){
									resultList = orgADSvc.adModifyGroup(strGroupType,strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,sOUPath_Temp,strPrimaryMail,"Manage","");
								}else if(strIsUse.equals("N") && !strIsUse.equals(sOldIsUse)){
									resultList = orgADSvc.adDeleteGroup(strGroupType,strGroupCode,strDisplayName,sCompanyName_Temp,sOUPath_Temp,"Manage","");
								}
								break;
						}
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [AD] " + resultList.getString("Reason"));
							throw new Exception(" [AD] " + resultList.getString("Reason"));
						}
					}
				} catch (NullPointerException ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", ex.getMessage());
					throw new Exception(ex.getMessage());
				} catch (Exception ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", ex.getMessage());
					throw new Exception(ex.getMessage());
				}
				
				//Exchange 연동
				try{
					if(RedisDataUtil.getBaseConfig("IsSyncMail").equals("Y") && strIsMail.equals("Y")){
						CoviMap resultList = new CoviMap();

						switch(strGroupType.toUpperCase()){
							case "COMPANY":
								if(strIsMail.equals("Y")){
									resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
								}else if(!strIsMail.equals("Y")){
									resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
								}
								break;
							case "DEPT":
								if(RedisDataUtil.getBaseConfig("IsDeptSync").equals("Y")){
									if(strIsMail.equals("Y")){
										resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
									}else if(!strIsMail.equals("Y")){
										resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
									}
								}
								break;
							default :
								if(strIsMail.equals("Y")){
									resultList = orgADSvc.exchEnableGroup(strGroupCode,strPrimaryMail,strSecondaryMail,"Manage","");
								}else if(!strIsMail.equals("Y")){
									resultList = orgADSvc.exchDisableGroup(strGroupCode,"Manage","");
								}
								break;
							}
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							returnList.put("status", Return.FAIL);
							returnList.put("message", " [Exch] " + resultList.getString("Reason"));
							throw new Exception(" [Exch] " + resultList.getString("Reason"));
						}
					}
				} catch (NullPointerException ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", ex.getMessage());
					throw new Exception(ex.getMessage());
				} catch (Exception ex) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", ex.getMessage());
					throw new Exception(ex.getMessage());
				}
			}
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
			
			CoviMap returnList = orgSyncManageSvc.selectGroupEtcInfo(params);
			
			CompanyID = returnList.getJSONArray("list").getJSONObject(0).getString("CompanyID");
			GroupPath = returnList.getJSONArray("list").getJSONObject(0).getString("GroupPath");
			SortPath = returnList.getJSONArray("list").getJSONObject(0).getString("SortPath");
			OUPath = returnList.getJSONArray("list").getJSONObject(0).getString("OUPath");
			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return CompanyID + "&" + GroupPath + "&" + SortPath + "&" + OUPath;
	}
	
	@RequestMapping(value = "admin/orgmanage/getdefaultsetinfogroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDefaultSetInfoGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strGR_Code = request.getParameter("memberOf");
		String strDomainCode = request.getParameter("domainCode");
		String strGroupType = request.getParameter("groupType");
		
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("gr_code", strGR_Code);
			params.put("domainCode", strDomainCode);
			params.put("groupType", strGroupType);
			
			CoviList resultList = (CoviList) orgSyncManageSvc.selectDefaultSetInfoGroup(params).get("list");
			
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
	
	/**
	 * addGroupMember : 그룹 구성원 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/organization/addgroupmember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addGroupMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		String strGroupCode = request.getParameter("GroupCode");
		String strURList = request.getParameter("URList");
		String strGRList = request.getParameter("GRList");
		
		try {
			CoviMap params = new CoviMap();
			
			strGroupCode = strGroupCode.isEmpty() ? null : strGroupCode;
			
			String URList = strURList.isEmpty() ? null : strURList;
			String GRList = strGRList.isEmpty() ? null : strGRList;
			
			params.put("GroupCode", strGroupCode);
			params.put("URList", URList);
			params.put("GRList", GRList);
									
			returnList.put("object", orgSyncManageSvc.addGroupMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가되었습니다");
			returnList.put("etcs", "");
			
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
	 * deleteGroupMember : 그룹 멤버 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/deletegroupmember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteGroupMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteUser = request.getParameter("TargetUser");
		String strDeleteGroup = request.getParameter("TargetGroup");
		
		try {
			CoviMap params = new CoviMap();
			
			String DeleteDataArrUser[] = strDeleteUser.isEmpty() ? null : strDeleteUser.split(",");
			String DeleteDataArrGroup[] = strDeleteGroup.isEmpty() ? null : strDeleteGroup.split(",");
			
			params.put("deleteDataUser", DeleteDataArrUser);
			params.put("deleteDataGroup", DeleteDataArrGroup);
						
			returnList.put("object", orgSyncManageSvc.deleteGroupMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "admin/organization/resetuserpassword.do", method={RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap resetuserpassword(HttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strUserID = request.getParameter("UserID");
		String strLogonID = request.getParameter("LogonID");
		String strMailAddress = request.getParameter("MailAddress");
		String strAD_SamAccountName = request.getParameter("AD_SamAccountName");
		String strModDate = request.getParameter("ModDate");
		String strIsAD = request.getParameter("IsAD");		
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UserID", strUserID);
			params.put("LogonID", strLogonID);
			params.put("MailAddress", strMailAddress);
			params.put("AD_SamAccountName", strAD_SamAccountName);
			params.put("ModDate", strModDate);
			params.put("BySaml", RedisDataUtil.getBaseConfig("UseSaml"));

			returnList.put("object", orgSyncManageSvc.resetuserpassword(params));
			String returnpass = returnList.get("object").toString();
			
			if("FAIL".equals(returnpass)) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "초기화에 실패하였습니다.");
				throw new Exception();
			} else {
				params.put("Returnpass", returnpass);
				if(orgSyncManageSvc.getTSSyncTF()) {
					returnList.put("object", orgSyncManageSvc.resetuserpasswordTS(params));
				}
				if(orgSyncManageSvc.getIndiSyncTF() && !strMailAddress.equals("")) {
					returnList.put("object", orgSyncManageSvc.modifyPass(params));
				}
			}
			
			if(RedisDataUtil.getBaseConfig("IsSyncAD").equals("Y") && strIsAD.equals("Y")){	//비밀번호 변경
                //AES aes = new AES(aeskey, "N");
                //String strDecLogonPassword = aes.decrypt(returnpass); 

                CoviMap resultList2 = orgADSvc.adInitPassword(strAD_SamAccountName,returnpass,"Manage","");
                
				if(!Boolean.valueOf((String) resultList2.getString("result"))){ //실패
					returnList.put("status", Return.FAIL);
					returnList.put("message", "초기화에 실패하였습니다.");
					throw new Exception();
				}
			}
			
			if(RedisDataUtil.getBaseConfig("isUseExchMail").equals("Y") && RedisDataUtil.getBaseConfig("isUseMail").equals("Y")) {
				if(RedisDataUtil.getBaseConfig("PassADIsUse").equals("Y")){	// Exchange 연동 비밀번호 변경

					// 토큰 발급 서비스 사용을 위한 param
					CoviMap jwtTokenParam = new CoviMap();
					
					// param 세팅
					jwtTokenParam.put("userID", strLogonID);
					jwtTokenParam.put("LogonID", strLogonID);
					jwtTokenParam.put("UserCode", strUserID);
					jwtTokenParam.put("isAdmin", "Y");
					jwtTokenParam.put("newPass", returnpass);
					jwtTokenParam.put("SamAccountName", strMailAddress.split("@")[0]);
					
					String pToken = ComUtils.jwtToken(jwtTokenParam);
	                
					if(!orgADSvc.exchResetPassword(pToken)){ //실패
						returnList.put("status", Return.FAIL);
						returnList.put("message", "초기화에 실패하였습니다.");
						throw new Exception();
					}
				}
			}

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", returnpass);
			returnList.put("etcs", "");

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
	
	@RequestMapping(value = "admin/orgmanage/getmailboxlist.do", method=RequestMethod.POST)
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
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("list", null);
			returnList.put("result", "fail");
		} catch (NullPointerException e) {
			returnList.put("list", null);
			returnList.put("result", "fail");
		} catch (Exception e) {
			returnList.put("list", null);
			returnList.put("result", "fail");
		}
		
		return returnList;
	}
	
	//페이지 이동
	@RequestMapping(value="mailaddressattributepop.do", method=RequestMethod.GET)
	public ModelAndView showMailAddressAttributePop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strIframeName = request.getParameter("iframename");
		String strOpenName = request.getParameter("openname");
		String strMailAddress = request.getParameter("mailaddress");
		String strMail = request.getParameter("mail");
		String strIndex = request.getParameter("index");
		String strMode = request.getParameter("mode");
		String strCallBackMethod = request.getParameter("callbackmethod");
		String strGroupType = request.getParameter("grouptype");
		
		String returnURL = "core/organization/mailaddressattributepop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("iframename", strIframeName);
		mav.addObject("openname", strOpenName);
		mav.addObject("mailaddress", strMailAddress);
		mav.addObject("mail", strMail);
		mav.addObject("index", strIndex);
		mav.addObject("mode", strMode);
		mav.addObject("callbackmethod", strCallBackMethod);
		mav.addObject("grouptype", strGroupType);
		
		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="mailattributepop.do", method=RequestMethod.GET)
	public ModelAndView showMailAttributePop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strIframeName = request.getParameter("iframename");
		String strOpenName = request.getParameter("openname");
		String strAttributes = request.getParameter("attributes");
		String strCallBackMethod = request.getParameter("callbackmethod");
		
		String returnURL = "core/organization/mailattributepop";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("iframename", strIframeName);
		mav.addObject("openname", strOpenName);
		mav.addObject("attributes", strAttributes);
		mav.addObject("callbackmethod", strCallBackMethod);
		
		return mav;
	}
	
	/**
	 * getisduplicatesortkey : SortKey중복 체크
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getisduplicatesortkey.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getisduplicatesortkey(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String strMemberOf = request.getParameter("MemberOf");
		String strGroupCode = request.getParameter("GroupCode");
		String strSortKey = request.getParameter("SortKey");
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();

			params.put("MemberOf", strMemberOf);
			params.put("GroupCode", strGroupCode);
			params.put("SortKey", strSortKey);
			returnList.put("object", orgSyncManageSvc.selectIsduplicatesortkey(params));
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
	 * usePWPolicyCheck : 계열사 비밀번호 정책 체크
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/usePWPolicyCheck.do", method=RequestMethod.POST)
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
			
			CoviList resultList = (CoviList) orgSyncManageSvc.usePWPolicyCheck(params).get("list");
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("cryptoType", cryptoType);
			
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
	
	// 파라미터로 넘어온 문자열을 영문 대소문자, 숫자, _ 이외의 값 전부 치환하여 리턴
	private String setRegexString(String paramStr) throws Exception {
		String result = "";
		Pattern regPattern = Pattern.compile("[^a-zA-Z0-9\\_]");
		
		result = regPattern.matcher(paramStr).replaceAll("");
		
		return result;
	}
}
