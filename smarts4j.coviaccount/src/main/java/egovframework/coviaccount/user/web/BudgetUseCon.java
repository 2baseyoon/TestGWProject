package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.BudgetUseSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : accountPreparCon.java
 * @Description : 예산사용현황 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BudgetUseCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BudgetUseSvc budgetUseSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getApprovalIframeList - 예산사용현황
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 
	@RequestMapping(value = "user/account/BudgetUse.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView BudgetUse(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/BudgetUse";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}*/
	/**
	* @Method Name : AddPopup
	* @Description : 추가화면 호출 
	*/
	@RequestMapping(value = "budgetUse/BudgetUseAddPopup.do", method = RequestMethod.GET)
	public ModelAndView budgetUseAddPopup(HttpServletRequest request,
		HttpServletResponse response) throws Exception {
		String returnURL = "user/account/BudgetUseAddPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("costCenterType",	request.getParameter("costCenterType"));
		mav.addObject("companyCode",		request.getParameter("companyCode"));
		return mav;
	}
	
	/**
	 * @Method Name : getBuggetExecuteList
	 * @Description : 예산실행 목록 조회
	 */
	@RequestMapping(value = "budgetUse/getBudgetExecuteList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBudgetExecuteList(HttpServletRequest request) throws Exception{
 
		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= request.getParameter("sortColumn");
			String sortDirection	= request.getParameter("sortDirection");
			String sortBy			= StringUtil.replaceNull(request.getParameter("sortBy"),"");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			StringUtil.replaceNull(request.getParameter("pageNo"),"1"));
			params.put("pageSize",			StringUtil.replaceNull(request.getParameter("pageSize"),"1"));
			
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("costCenterName")).trim(),100));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			params.put("authMode",			request.getParameter("authMode"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(request.getParameter("searchStr"), 100));

			resultList = budgetUseSvc.getBudgetExecuteList(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	* @Method Name : getBudgetType
	* @Description : 예산구분조회 
	*/
	@RequestMapping(value = "budgetUse/getBudgetCtrlInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBudgetCtrlInfo(HttpServletRequest request) throws Exception {
		CoviMap resultList = new CoviMap();
		try {

			CoviMap params = new CoviMap();
			params.put("accountCode", 		request.getParameter("accountCode"));
			params.put("standardBriefID", 	request.getParameter("standardBriefID"));
			params.put("fiscalYear", 		request.getParameter("fiscalYear"));
			params.put("executeDate",	 	request.getParameter("executeDate"));
			params.put("companyCode", 		request.getParameter("companyCode"));
			
			resultList = budgetUseSvc.getBudgetCtrlInfo(params);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	* @Method Name : getBudgetAmount
	* @Description : 예산금액조회 
	*/
	@RequestMapping(value = "budgetUse/getBudgetAmount.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBudgetAmount(
			HttpServletRequest request) throws Exception {
		// ************** new ***************
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("companyCode", 	request.getParameter("companyCode"));
			params.put("chkList", 		request.getParameter("chkList"));
			
			CoviList amountList = (CoviList) budgetUseSvc.getBudgetAmount(params);
			
			resultList.put("list", 		amountList);
			resultList.put("status", 	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	* @Method Name : addExecuteRegist
	* @Description : 예산사용등록
	*/
	@RequestMapping(value = "budgetUse/addExecuteRegist.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addExecuteRegist(
			HttpServletRequest request) throws Exception {

		CoviMap resultList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenter",		request.getParameter("costCenter"));
			params.put("accountCode",		request.getParameter("accountCode"));
			if (request.getParameter("standardBriefID") != null && !request.getParameter("standardBriefID").equals(""))
				params.put("standardBriefID",	request.getParameter("standardBriefID"));
			else
				params.put("standardBriefID",	0);
			params.put("executeDate",	request.getParameter("executeDate"));
			params.put("usedAmount",	request.getParameter("usedAmount"));
			params.put("description",	request.getParameter("description"));
			params.put("initiatorID",	request.getParameter("initiatorID"));
			params.put("initiatorName",	request.getParameter("initiatorName"));
			params.put("initiatorDeptCode",	request.getParameter("initiatorDeptCode"));
			params.put("initiatorDeptName",	request.getParameter("initiatorDeptName"));
			
			params.put("forminstID",	StringUtil.replaceNull(request.getParameter("forminstID"),""));
			params.put("expenceApplicationListID",	StringUtil.replaceNull(request.getParameter("expenceApplicationListID"),""));
			params.put("expenceApplicationDivID",	StringUtil.replaceNull(request.getParameter("expenceApplicationDivID"),""));
 
			params.put("reservedStr1",	StringUtil.replaceNull(request.getParameter("reservedStr1"),""));
			params.put("reservedStr2",	StringUtil.replaceNull(request.getParameter("reservedStr2"),""));
			params.put("reservedStr3",	StringUtil.replaceNull(request.getParameter("reservedStr3"),""));
			params.put("reservedStr4",	StringUtil.replaceNull(request.getParameter("reservedStr4"),""));
			params.put("reservedStr5",	StringUtil.replaceNull(request.getParameter("reservedStr5"),""));
			params.put("reservedInt1",	StringUtil.replaceNull(request.getParameter("reservedInt1"),"0"));
			params.put("reservedInt2",	StringUtil.replaceNull(request.getParameter("reservedInt2"),"0"));

			
			params.put("status",	request.getParameter("status"));
			params.put("budgetCode",request.getParameter("budgetCode"));

			resultList = budgetUseSvc.addExecuteRegist(params);

		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : changeStatus
	 * @Description : flag 변경
	 * 			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy", required = false, defaultValue = "") String sortBy)

	 */
	@RequestMapping(value = "budgetUse/changeStatus.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap changeStatus(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			int resultCnt = 0;
			CoviMap params = new CoviMap();
			params.put("executeID",		request.getParameter("executeID"));
			params.put("status",		request.getParameter("status"));
			resultCnt = budgetUseSvc.changeStatus(params);

			resultList.put("resultCnt", resultCnt);
			resultList.put("result", "ok");

			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : downloadExcel
	 * @Description : 다운로드
	 */
	@RequestMapping(value = "budgetUse/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(request.getParameter("headerName")).split("†");
			String[] headerNames = URLDecoder.decode(request.getParameter("headerName"),"utf-8").split("†");
			String[] headerKeys  = commonCon.convertUTF8(StringUtil.replaceNull(request.getParameter("headerKey"))).split(",");
			
			String costCenterName = URLDecoder.decode(request.getParameter("costCenterName"),"utf-8");
			String searchStr = URLDecoder.decode(request.getParameter("searchStr"),"utf-8");
			
			CoviMap params = new CoviMap();
			
			params.put("authMode",			request.getParameter("authMode"));
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(costCenterName).trim(), 100));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			CoviMap resultList = budgetUseSvc.getBudgetExecuteList(params);
			// Status 변환
			StatusChange(resultList);

			AccountFileUtil accountFileUtil = new AccountFileUtil();
			
			CoviMap convertList = new CoviMap ();
			convertList.put("list", resultList.get("list"));
			
			viewParams.put("list",			convertList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			//viewParams.put("title",			accountFileUtil.getDisposition(request, request.getParameter("title")));
			
			String title = request.getParameter("title");
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	private void StatusChange(CoviMap resultList) {
		for (Object object: (CoviList) resultList.get("list")) {
			CoviMap coviMap = (CoviMap) object;
			
			switch (coviMap.getString("Status")) {
			case "R":
				coviMap.put("Status", "반려");
				break;
			case "P":
				coviMap.put("Status", "가집행");
				break;
			case "C":
				coviMap.put("Status", "집행");
				break;
			default:
				coviMap.put("Status", "취소");
				break;
			}
		}
	}
}
