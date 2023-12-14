package egovframework.core.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.OrgChartSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.coviframework.util.ComUtils;

@Controller
@RequestMapping("/mobile/org")
public class MobileOrgCon {

	private Logger LOGGER = LogManager.getLogger(MobileOrgCon.class);
	
	@Autowired
	private OrgChartSvc orgChartSvc;
	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getdeptlist : 조직도 - 부서 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getSubList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSubList(
			HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

		String domainName = "";
		  
		if(ClientInfoHelper.isMobile(request)){
			domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
		}else{
			domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
		}
		String companyCode = request.getParameter("companyCode");
		String groupType = request.getParameter("groupType");
		String deptCode = request.getParameter("deptCode");
		String searchType = request.getParameter("searchType");
		String searchText = request.getParameter("searchText");
		String type = request.getParameter("type");
		
		searchText = StringUtil.replaceNull(searchText).isEmpty() ? null : searchText;
		deptCode = StringUtil.replaceNull(deptCode).isEmpty() ? null : deptCode; 
		companyCode = StringUtil.replaceNull(companyCode).isEmpty() ? null : companyCode; 
		
		CoviMap returnList = new CoviMap();
		CoviList resultDeptList = new CoviList();
		CoviList resultUserList = new CoviList();
		
		try{
			
			//파라미터 검증
			//search : 검색어가 있어야 함
			//sub : 회사코드/부서코드가 있어야 함
			if((StringUtil.replaceNull(type).equalsIgnoreCase("search") && searchText != null)
				|| (StringUtil.replaceNull(type).equalsIgnoreCase("sub") && deptCode != null)) {

				//0. 타계열사 표시 안하는 경우 회사코드 지정
				if(!RedisDataUtil.getBaseConfig("ORGDisplayOtherCompany").equals("Y")) {
					companyCode = SessionHelper.getSession("DN_Code");
				}
				
				// 1. 부서 조회
				CoviMap params = new CoviMap();
				params.put("companyCode", companyCode);
				params.put("groupType", groupType);
				if(StringUtil.replaceNull(type).equals("sub")) {
					params.put("searchType","MemberOf");
					params.put("searchText", deptCode);
				}else {
					params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
				}
				
				resultDeptList = (CoviList) orgChartSvc.getDeptList(params);
				
				// 2. 부서원 조회
				params = new CoviMap();
				String domainID = SessionHelper.getSession("DN_ID");
				
				String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
				if(!orgMapOrderSet.equals("")) {
	                String[] orgOrders = orgMapOrderSet.split("\\|");
	                params.put("orgOrders", orgOrders);
				}
				
				params.put("companyCode", companyCode);
				params.put("deptCode", deptCode);
				params.put("searchType", searchType);
				params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
				if("usercodes".equals(searchType)) {
					String[] arrSearchUsers = "".equals(searchText) ? null : searchText.split(";");
					params.put("usercodes", arrSearchUsers);
				}
				
				resultUserList = (CoviList) orgChartSvc.getUserList(params).get("list");
			}
			
			//조회결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("deptlist", resultDeptList);
			returnList.put("userlist", resultUserList);
			returnList.put("domainName", domainName);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "getOrgInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOrgInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();	

	    String domainName = "";
	    
		if(ClientInfoHelper.isMobile(request)){
			domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
		}else{
			domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"); 
		}
		String UserCode = request.getParameter("UserCode");
		String gr_code = request.getParameter("gr_code");
		UserCode = StringUtil.replaceNull(UserCode).isEmpty() ? null : UserCode;
		gr_code = StringUtil.replaceNull(gr_code).isEmpty() ? null : gr_code;
		
		CoviList resultDeptList = new CoviList();
		CoviList resultUserList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("gr_code", gr_code);
			resultDeptList = (CoviList) orgSyncManageSvc.selectDeptInfo(params).get("list");

			params = new CoviMap();
			params.put("UserCode", UserCode);
			resultUserList = (CoviList) orgSyncManageSvc.selectUserInfoOrg(params).get("list");
			
			returnList.put("deptlist", resultDeptList);
			returnList.put("userlist", resultUserList);
			returnList.put("domainName", domainName);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
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
	 * getOrgPathInfo : 조직도 Path 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getOrgPathInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOrgPathInfo(
			HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

		String domainName = "";
		String strGroupPath = request.getParameter("GroupPath");
		String strGroupCode = request.getParameter("GroupCode");
		String arrGroupPath[] = StringUtil.replaceNull(strGroupPath).split(";");				
		
		if(ClientInfoHelper.isMobile(request)){
			domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
		}else{
			domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
		}
				
		CoviMap returnList = new CoviMap();
		CoviList resultDeptList = new CoviList();		
				
		try{ 
			CoviMap params = new CoviMap();
			params.put("arrGroupPath", arrGroupPath);
			params.put("GroupCode", strGroupCode);						
					
			//조회결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("data", orgChartSvc.getOrgPathInfo(params));			
			returnList.put("domainName", domainName);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
}
