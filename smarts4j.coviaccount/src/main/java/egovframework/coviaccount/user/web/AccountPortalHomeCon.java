package egovframework.coviaccount.user.web;


import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.AccountPortalHomeSvc;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;



/**
 * @Class Name : AccountPortalUserCon.java
 * @Description : 포탈
 * @Modification Information 
 * @author Covision
 * @ 2018.07.23 최초생성
 */
@Controller
public class AccountPortalHomeCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountPortalHomeSvc accountPortalHomeSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	@RequestMapping(value = "accountPortal/portalHome.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView portalHome(Locale locale, Model model, HttpServletRequest request) throws Exception {
		
		final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		String returnURL = "account/AccountPortalUser.user.accountcontent";
		String isAdmin = "N"; //SessionHelper.getSession("isAdmin");
		if ("M".equals(request.getParameter("Auth"))) {
			isAdmin= "Y";
		} else {
			isAdmin = "N";
		}		

		CoviMap params = new CoviMap();
		
		params.put("UR_Code",SessionHelper.getSession("UR_Code"));
		params.put("companyCode", "ORGROOT".equals(SessionHelper.getSession("DN_Code")) ? "ALL" : SessionHelper.getSession("DN_Code"));
		params.put("DeptID", SessionHelper.getSession("DEPTID"));
		params.put("isSaaS", isSaaS);
		
		if (isAdmin.equals("Y")) {
			returnURL = "account/AccountPortalManager.user.accountcontent";
		} else{
			returnURL = "account/AccountPortalUser.user.accountcontent";
		}
		
		String payDate  ="";
		if (request.getParameter("payDate") !=  null)		{
			payDate  = request.getParameter("payDate");
		} else{
			CoviMap jsonDeadLine = accountPortalHomeSvc.getDeadline(params);
			payDate = ((String)jsonDeadLine.get("DeadlineFinishDate")).replaceAll("[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", "").substring(0,6);
			
			String strStandardMonth = jsonDeadLine.optString("StandardMonth");
			String prevPayDate = payDate;
			if("01".equals(strStandardMonth)) {//영수증조회시 검색조건 사용일자로 변경하며, 마감기준이 전월(01)이면 이전달 영수증 조회.
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	            Calendar cal = Calendar.getInstance();
	            cal.setTime(sdf.parse(payDate));
	            cal.add(cal.MONTH, -1);
	            prevPayDate = sdf.format(cal.getTime());
			}
			params.put("prevPayDate", prevPayDate);
		}		
		
		params.put("payDate", payDate);
		params.put("payYear", payDate.substring(0,4));
		params.put("isAdmin", isAdmin );
		CoviMap jsonObject =  isAdmin.equals("Y") ? accountPortalHomeSvc.getAccountPortalManager(params)
													 : accountPortalHomeSvc.getAccountPortalUser(params);

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("payDate", payDate);
		if(isAdmin.equals("Y")) {
			mav.addObject("proofCount",		jsonObject.get("proofCount"));
		} else {
			mav.addObject("proofCount",		jsonObject.getJSONArray("proofCount").get(0));
		}
		mav.addObject("accountCount",	jsonObject.get("accountCount"));
		
		mav.addObject("corpCardList",	jsonObject.get("corpCardList"));
		mav.addObject("corpCardListCnt",jsonObject.get("corpCardListCnt"));
		mav.addObject("taxBillList",	jsonObject.get("taxBillList"));
		mav.addObject("taxBillListCnt",	jsonObject.get("taxBillListCnt"));
		mav.addObject("billList",		jsonObject.get("billList"));
		mav.addObject("billListCnt",	jsonObject.get("billListCnt"));

		mav.addObject("monthHeader",	jsonObject.get("monthHeader"));
		mav.addObject("monthList",		jsonObject.get("monthList"));
		
		mav.addObject("deadline",		jsonObject.get("deadline"));
		
		mav.addObject("urName", SessionHelper.getSession("UR_Name"));
		
		CoviList jsonGuide = null;
		jsonGuide = RedisDataUtil.getBaseCode("EXPENSE_CLAIM_GUIDE", SessionHelper.getSession("DN_ID"));
		if(!isSaaS.equalsIgnoreCase("N")){		//saas이면 0도메인값 제거
			if (!jsonGuide.isEmpty() ){
				if (!((CoviMap)jsonGuide.get(0)).getString("DomainID").equals(SessionHelper.getSession("DN_ID"))){
					jsonGuide = null;
				}
			}
		}
		
		mav.addObject("guideList"	,		jsonGuide);
		
		//AccountPortalManager
		if (isAdmin.equals("Y")){
			params.put("proofDate",  params.get("payDate"));
			mav.addObject("deptCateList"		,	jsonObject.get("deptList"));
			mav.addObject("accountCateList"		,	jsonObject.get("accountList"));			
			mav.addObject("totalSummery"		,	accountPortalHomeSvc.getTotalSummery(params));					
			mav.addObject("auditDupStore"		,	accountPortalHomeSvc.getAuditList("DupStore",params));
			mav.addObject("auditEnterTain"		,	accountPortalHomeSvc.getAuditList("EnterTain",params));			
			mav.addObject("auditHolidayUse"		,	accountPortalHomeSvc.getAuditList("HolidayUse",params));
			mav.addObject("auditLimitAmount"	,	accountPortalHomeSvc.getAuditList("LimitAmount",params));
			mav.addObject("auditUserVacation"	,	accountPortalHomeSvc.getAuditList("UserVacation",params));
			mav.addObject("budgetStd"			,	jsonObject.get("budgetStd"));
		}
		
		// storage정보에서 조회하도록 변경
		//mav.addObject("billPath",RedisDataUtil.getBaseConfig("BackStorage").replace("{0}",SessionHelper.getSession("DN_Code"))+"EAccount");
		mav.addObject("CLSYS", "account");
		mav.addObject("CLMD", "user");
		mav.addObject("CLBIZ", "Account");
		
		return mav;
	}
	
	@RequestMapping(value = "accountPortal/portalProof.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap portalProof(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();		
		
		params.put("UR_Code"	,SessionHelper.getSession("UR_Code"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		params.put("payDate"	,req.getParameter("payDate"));
		params.put("deptCode"	,req.getParameter("deptCode"));
		params.put("searchType"	,req.getParameter("searchType"));	
		params.put("stdCode"	,req.getParameter("stdCode"));
		
		returnList.put("proofList", accountPortalHomeSvc.getPortalProof(params).get("list") );
		
		//이전달
		params.put("payDate"	,req.getParameter("prevPayDate") );		
		returnList.put("prevProofList", accountPortalHomeSvc.getPortalProof(params).get("list") );
		
		return returnList;		
	}
	
	@RequestMapping(value = "accountPortal/portalAccount.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap portalAccount(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("UR_Code"	,SessionHelper.getSession("UR_Code"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		params.put("payDate"	,req.getParameter("payDate"));
		params.put("accountCode",req.getParameter("accountCode"));
		params.put("searchType"	,req.getParameter("searchType"));
		params.put("stdCode"	,req.getParameter("stdCode"));
		
		returnList.put("accountList", accountPortalHomeSvc.getPortalAccount(params).get("list") ); 
		
		//이전달
		params.put("payDate"	,req.getParameter("prevPayDate") );
		returnList.put("prevAccountList", accountPortalHomeSvc.getPortalAccount(params).get("list") );
		
		return returnList;		
	}
	
	@RequestMapping(value = "accountPortal/getReportCategoryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getProofDeptCode(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		params.put("payDate"	,req.getParameter("payDate"));
		params.put("stdCode"	,req.getParameter("stdCode"));
		params.put("searchType"	,req.getParameter("searchType"));		
		
		returnList.put("deptCateList", accountPortalHomeSvc.getProofDeptCode(params).get("list"));
		returnList.put("accountCateList", accountPortalHomeSvc.getAccountCode(params).get("list"));
		returnList.put("totalSummery", accountPortalHomeSvc.getTotalSummery(params));		
		
		return returnList;
	}
	
	@RequestMapping(value = "accountPortal/getTopCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTopCategory(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		
		returnList.put("topCateList", accountPortalHomeSvc.getTopCategory(params).get("list"));
		
		return returnList;
	}
	
	@RequestMapping(value = "accountPortal/getAccountMonth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAccountMonth(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();

		String payYear  = "";
		if (req.getParameter("payYear") != null && !"".equals(req.getParameter("payYear")))	{
			payYear  = req.getParameter("payYear");
		} else {
			CoviMap jsonDeadLine = accountPortalHomeSvc.getDeadline(params);
			payYear = ((String)jsonDeadLine.get("DeadlineStartDate")).replaceAll("[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", "").substring(0,4);
		}

		
		params.put("UR_Code"	,SessionHelper.getSession("UR_Code"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		params.put("stdCode"	, req.getParameter("stdCode"));
		params.put("payYear"	, payYear);
		params.put("searchType"	,req.getParameter("searchType"));
		
		returnList.put("chartObj", accountPortalHomeSvc.getAccountMonth(params));
		returnList.put("payYear", payYear);
		
		return returnList;
	}
	
	@RequestMapping(value = "accountPortal/getBudgetMonthSum.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBudgetMonthSum(Locale locale, HttpServletRequest req, ModelMap map) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("UR_Code"		,SessionHelper.getSession("UR_Code"));
		params.put("companyCode"	,SessionHelper.getSession("DN_Code"));
		params.put("stdCode"		,req.getParameter("stdCode"));
		params.put("payYear"		,req.getParameter("payYear"));
		params.put("searchType"		,req.getParameter("searchType"));
		
		String accountCode = StringUtil.replaceNull(req.getParameter("accountCode"));
		String[] aArray = accountCode.split("†");
		
		params.put("accountCode"	,accountCode.substring(0, accountCode.indexOf("†")));
		
		String[] sbCodeList = new String[aArray.length-1];
		if (aArray.length>1){
			for (int i=1; i<aArray.length; i++){
				sbCodeList[i-1] = aArray[i]; 
			}
		}	
		params.put("sbCodeList"		,sbCodeList);
		
		returnList.put("chartObj"	, accountPortalHomeSvc.getBudgetMonthSum(params).get("list"));
		CoviList budgetTotalArr = accountPortalHomeSvc.getBudgetTotal(params).getJSONArray("list");
		returnList.put("budgetTotal", (budgetTotalArr.size() > 0) ? budgetTotalArr.get(0) : "");
		
		return returnList;
	}
	
	@RequestMapping(value = "accountPortal/getAuditCnt.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAuditCnt(HttpServletRequest req, ModelMap map,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();		
		
		params.put("proofDate"	,paramMap.get("proofDate"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		
		returnList.put("auditDupStore"		,	accountPortalHomeSvc.getAuditList("DupStore",params));
		returnList.put("auditEnterTain"		,	accountPortalHomeSvc.getAuditList("EnterTain",params));			
		returnList.put("auditHolidayUse"	,	accountPortalHomeSvc.getAuditList("HolidayUse",params));
		returnList.put("auditLimitAmount"	,	accountPortalHomeSvc.getAuditList("LimitAmount",params));
		returnList.put("auditUserVacation"	,	accountPortalHomeSvc.getAuditList("UserVacation",params));
		
		return returnList;
	}
	
	@RequestMapping(value = "accountPortal/getAccountUserMonth.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAccountUserMonth(HttpServletRequest req, ModelMap map,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();	

		String payDate = "";
		if (req.getParameter("payDate") != null && !"".equals(req.getParameter("payDate")))		{
			payDate = req.getParameter("payDate");
		} else{
			CoviMap jsonDeadLine = accountPortalHomeSvc.getDeadline(params);
			payDate = ((String)jsonDeadLine.get("DeadlineFinishDate")).replaceAll("[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", "").substring(0,6);
		}

		params.put("UR_Code"	,SessionHelper.getSession("UR_Code"));
		params.put("companyCode",SessionHelper.getSession("DN_Code"));
		params.put("payDate"	, payDate);
		params.put("payYear"	, payDate.substring(0,4));
		
		CoviMap jsonObject =   accountPortalHomeSvc.getAccountUserMonth(params);

		returnList.put("result"			, "ok");
		returnList.put("payDate"		, payDate);
		returnList.put("proofCount"		, jsonObject.get("proofCount"));
		returnList.put("accountCount"	, jsonObject.get("accountCount"));
		returnList.put("urName"			, SessionHelper.getSession("UR_Name"));		
		
		return returnList;
	}

	@RequestMapping(value = "accountPortal/getReportDetailList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getReportDetailList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "ProofMonth",			required = false, defaultValue="")	String ProofMonth,
			@RequestParam(value = "DeptCode",			required = false, defaultValue="")	String DeptCode,
			@RequestParam(value = "CostCenterCode",		required = false, defaultValue="")	String CostCenterCode,
			@RequestParam(value = "RegisterName",		required = false, defaultValue="")	String RegisterName,
			@RequestParam(value = "AccountCode",		required = false, defaultValue="")	String AccountCode,
			@RequestParam(value = "AccountName",		required = false, defaultValue="")	String AccountName,
			@RequestParam(value = "StandardBriefID",	required = false, defaultValue="")	String StandardBriefID,
			@RequestParam(value = "StandardBriefName",	required = false, defaultValue="")	String StandardBriefName,
			@RequestParam(value = "UsageComment",		required = false, defaultValue="")	String UsageComment,
			@RequestParam(value = "SearchAmtSt",		required = false, defaultValue="")	String SearchAmtSt,
			@RequestParam(value = "SearchAmtEd",		required = false, defaultValue="")	String SearchAmtEd)	throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
						
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("ProofMonth",		ProofMonth);
			params.put("DeptCode",			DeptCode);
			params.put("CostCenterCode",	CostCenterCode);
			params.put("RegisterName",		ComUtils.RemoveSQLInjection(RegisterName, 100));
			params.put("AccountCode",		AccountCode);
			params.put("AccountName",		AccountName);
			params.put("StandardBriefID",	StandardBriefID);
			params.put("StandardBriefName",	StandardBriefName);
			params.put("UsageComment",		UsageComment);
			params.put("SearchAmtSt",		SearchAmtSt);	
			params.put("SearchAmtEd",		SearchAmtEd);			
			params.put("CompanyCode",		SessionHelper.getSession("DN_Code"));
			
			resultList = accountPortalHomeSvc.getReportDetailList(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
		}
		return resultList;
	}
	
	@RequestMapping(value = "accountPortal/getReportDetailListExcel.do" , method = RequestMethod.GET)
	public ModelAndView getReportDetailListExcel(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",			required = false, defaultValue="")	String headerType,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title,
			@RequestParam(value = "ProofMonth",			required = false, defaultValue="")	String ProofMonth,
			@RequestParam(value = "DeptCode",			required = false, defaultValue="")	String DeptCode,
			@RequestParam(value = "CostCenterCode",		required = false, defaultValue="")	String CostCenterCode,
			@RequestParam(value = "RegisterName",		required = false, defaultValue="")	String RegisterName,
			@RequestParam(value = "AccountCode",		required = false, defaultValue="")	String AccountCode,
			@RequestParam(value = "StandardBriefID",	required = false, defaultValue="")	String StandardBriefID,
			@RequestParam(value = "UsageComment",		required = false, defaultValue="")	String UsageComment,
			@RequestParam(value = "SearchAmtSt",		required = false, defaultValue="")	String SearchAmtSt,
			@RequestParam(value = "SearchAmtEd",		required = false, defaultValue="")	String SearchAmtEd)	throws Exception{
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			
			params.put("ProofMonth",		commonCon.convertUTF8(ProofMonth));
			params.put("DeptCode",			commonCon.convertUTF8(DeptCode));
			params.put("CostCenterCode",	commonCon.convertUTF8(CostCenterCode));
			params.put("RegisterName",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(RegisterName, 100)));
			params.put("AccountCode",		commonCon.convertUTF8(AccountCode));
			params.put("StandardBriefID",	commonCon.convertUTF8(StandardBriefID));
			params.put("UsageComment",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(UsageComment, 100)));
			params.put("SearchAmtSt",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(SearchAmtSt, 100)));
			params.put("SearchAmtEd",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(SearchAmtEd, 100)));
			params.put("CompanyCode",		SessionHelper.getSession("DN_Code"));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			params.put("isExcel",			"Y");
			
			resultList = accountPortalHomeSvc.getReportDetailList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",commonCon.convertUTF8(headerType));

		    // 파일명으로 사용 불가능한 특수문자 제거
		    //title = title.replaceAll("[|\\\\\\\\?*<\\\":>/]+", " ");
			// 한글유니코드, 숫자, 영어, 공백을 제외한 나머지 치환
			String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
			title = URLDecoder.decode(title,"utf-8").replaceAll(match, " ");
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,title));
			viewParams.put("sheetName", title);
			
			mav = new ModelAndView(returnURL, viewParams);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
		}
	
		return mav;
	}	
	
	/**
	 * @Method Name : accountManageExcelDownload
	 * @Description : 자금지출보고서 관련 이체자료 다운로드
	 */
	@RequestMapping(value = "accountPortal/reportTransferExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView reportTransferExcelDownload(HttpServletRequest request, HttpServletResponse response) throws Exception{
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String headerName = request.getParameter("headerName");
			String headerKey = commonCon.convertUTF8(request.getParameter("headerKey"));
			String headerType = commonCon.convertUTF8(request.getParameter("headerType"));
			String title = StringUtil.replaceNull(commonCon.convertUTF8(request.getParameter("title")));
			String[] headerNames = StringUtil.replaceNull(commonCon.convertUTF8(headerName)).split("†");
			
			String expListIDs = request.getParameter("expListIDs");
			String [] expListIDsArr = StringUtils.split(expListIDs, ",");
			
			CoviMap params = new CoviMap();
			params.put("expListIDsArr",	expListIDsArr);
			params.put("headerKey",		headerKey);
			resultList = accountPortalHomeSvc.reportTransferExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",	headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",			accountFileUtil.getDisposition(request, title));
			
			mav = new ModelAndView(returnURL, viewParams);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		} catch (Exception e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : employeeExpenceExcelDownload
	 * @Description : 자금지출결의서 중 직원경비내역 이체자료 다운로드
	 */
	@RequestMapping(value = "accountPortal/employeeExpenceExcelDownload.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView employeeExpenceExcelDownload(HttpServletRequest request, HttpServletResponse response) throws Exception{
		ModelAndView mav = new ModelAndView();
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		String returnURL = "UtilExcelView";
		
		try {
			String headerName = request.getParameter("headerName");
			String headerKey = commonCon.convertUTF8(request.getParameter("headerKey"));
			String headerType = commonCon.convertUTF8(request.getParameter("headerType"));
			String title = StringUtil.replaceNull(commonCon.convertUTF8(request.getParameter("title")));
			String[] headerNames = StringUtil.replaceNull(commonCon.convertUTF8(headerName)).split("†");
			
			String expListIDs = request.getParameter("expListIDs");
			String [] expListIDsArr = StringUtils.split(expListIDs, ",");
			
			CoviMap params = new CoviMap();
			params.put("expListIDsArr",	expListIDsArr);
			params.put("headerKey",		headerKey);
			resultList = accountPortalHomeSvc.employeeExpenceExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",	headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",			accountFileUtil.getDisposition(request, title));
			
			mav = new ModelAndView(returnURL, viewParams);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		} catch (Exception e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : vendorExpenceExcelDownload
	 * @Description : 자금지출결의서 중 거래처지급내역 이체자료 다운로드
	 * @since 2022/12/28 
	 */
	@RequestMapping(value = "accountPortal/vendorExpenceExcelDownload.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView vendorExpenceExcelDownload(HttpServletRequest request, HttpServletResponse response) throws Exception{
		ModelAndView mav = new ModelAndView();
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		String returnURL = "UtilExcelView";
		
		try {
			String headerName = request.getParameter("headerName");
			String headerKey = commonCon.convertUTF8(request.getParameter("headerKey"));
			String headerType = commonCon.convertUTF8(request.getParameter("headerType"));
			String title = StringUtil.replaceNull(commonCon.convertUTF8(request.getParameter("title")));
			String[] headerNames = StringUtil.replaceNull(commonCon.convertUTF8(headerName)).split("†");
			
			String expListIDs = request.getParameter("expListIDs");
			String [] expListIDsArr = StringUtils.split(expListIDs, ",");
			
			CoviMap params = new CoviMap();
			params.put("expListIDsArr",	expListIDsArr);
			params.put("headerKey",		headerKey);
			resultList = accountPortalHomeSvc.vendorExpenceExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",	headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",			accountFileUtil.getDisposition(request, title));
			
			mav = new ModelAndView(returnURL, viewParams);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		} catch (Exception e) {
			logger.error("", e);
			LoggerHelper.errorLogger(e, "", "");
			resultList.put("status",	Return.FAIL);
		}
	
		return mav;
	}
	
	/**
	 * 홈 대시보드의 결재목록 탭순서 저장
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updatePortalSectionSort.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updatePortalSectionSort(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			accountPortalHomeSvc.updatePortalListTabSort(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
