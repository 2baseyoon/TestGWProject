package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.BizTripSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : AuditCon.java
 * @Description : AuditCon 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BizTripCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BizTripSvc bizTripSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	* @Method Name : saveBizTripRequestData
	* @Description : 출장신청 내역 저장
	*/
	@RequestMapping(value = "bizTrip/saveBizTripRequestData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveBizTripRequestData(@RequestBody CoviMap paramObj) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap bizTripRequestDataObj = new CoviMap(paramObj.get("bizTripRequestDataObj"));

			CoviMap returnObj = new CoviMap();

			returnObj = bizTripSvc.saveBizTripRequest(bizTripRequestDataObj);
						
			if("S".equals(returnObj.getString("status"))){
				returnList.put("returnObj", returnObj);
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장되었습니다.");
			}
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "알수없는 에러");
			}
			 
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : searchBizTripList
	* @Description : 출장 신청/정산 현황
	*/
	@RequestMapping(value = "bizTrip/searchBizTripList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchBizTripList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",	required = false, defaultValue="") String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();

			int pageSize = 10;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null || request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}			
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			String requestTitle = request.getParameter("RequestTitle");
			String requesterDeptName = request.getParameter("RequesterDeptName");
			String requesterName = request.getParameter("RequesterName");
			String bizTripType = request.getParameter("BizTripType");
			String projectCode = request.getParameter("ProjectCode");
			String businessAreaType = request.getParameter("BusinessAreaType");
			String requestStatus = request.getParameter("RequestStatus");
			String applicationStatus = request.getParameter("ApplicationStatus");
			String startDate = request.getParameter("StartDate");
			String endDate = request.getParameter("EndDate");
			String companyCode = request.getParameter("companyCode");
			
			params.put("RequestTitle", ComUtils.RemoveSQLInjection(requestTitle, 100));
			params.put("RequesterDeptName", ComUtils.RemoveSQLInjection(requesterDeptName, 100));
			params.put("RequesterName", ComUtils.RemoveSQLInjection(requesterName, 100));
			params.put("BizTripType", bizTripType);
			params.put("ProjectCode", projectCode);
			params.put("BusinessAreaType", businessAreaType);
			params.put("RequestStatus", requestStatus);
			params.put("ApplicationStatus", applicationStatus);
			params.put("StartDate", ComUtils.RemoveSQLInjection(startDate, 100));
			params.put("EndDate", ComUtils.RemoveSQLInjection(endDate, 100));
			params.put("companyCode", companyCode);
			
			if(request.getParameter("IsUser") != null && request.getParameter("IsUser").length() > 0 && request.getParameter("IsUser").equals("Y")) {
				params.put("SessionUser", SessionHelper.getSession("USERID"));
			}
			
			resultList = bizTripSvc.searchBizTripList(params);
		
			returnList.put("page", resultList.get("page"));		
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : bizTripExcelDownload
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "bizTrip/bizTripExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadVenderList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();

			String requestTitle = request.getParameter("RequestTitle");
			String requesterDeptName =request.getParameter("RequesterDeptName");
			String requesterName =request.getParameter("RequesterName");
			String bizTripType =request.getParameter("BizTripType");
			String projectCode =request.getParameter("ProjectCode");
			String businessAreaType =request.getParameter("BusinessAreaType");
			String applicationStatus =request.getParameter("ApplicationStatus");
			String startDate =request.getParameter("StartDate");
			String endDate =request.getParameter("EndDate");
			String companyCode = request.getParameter("companyCode");
			
			if(request.getParameter("IsUser") != null && request.getParameter("IsUser").length() > 0 && request.getParameter("IsUser").equals("Y")) {
				params.put("SessionUser", SessionHelper.getSession("USERID"));
			}
			
			params.put("RequestTitle", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(requestTitle, 100)));
			params.put("RequesterDeptName", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(requesterDeptName, 100)));
			params.put("RequesterName", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(requesterName, 100)));
			params.put("BizTripType", commonCon.convertUTF8(bizTripType));
			params.put("ProjectCode", commonCon.convertUTF8(projectCode));
			params.put("BusinessAreaType", commonCon.convertUTF8(businessAreaType));	
			params.put("ApplicationStatus", commonCon.convertUTF8(applicationStatus));
			params.put("StartDate", commonCon.convertUTF8(startDate));
			params.put("EndDate", commonCon.convertUTF8(endDate));
			params.put("companyCode", commonCon.convertUTF8(companyCode));
			
			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			
			//String[] headerNames = headerName.split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = bizTripSvc.bizTripExcelDownload(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
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
	

	/**
	* @Method Name : getBizTripRequestInfo
	* @Description : 출장신청서 정보 조회
	*/
	@RequestMapping(value = "bizTrip/getBizTripRequestInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizTripRequestInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String bizTripRequestID = request.getParameter("bizTripRequestID");
			params.put("bizTripRequestID", bizTripRequestID);
			
			resultList = bizTripSvc.getBizTripRequestInfo(params);
			
			returnList.put("data", resultList.get("data"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : exceptBizTripApplication
	* @Description : 출장 정산 제외 처리
	*/
	@RequestMapping(value = "bizTrip/exceptBizTripApplication.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap exceptBizTripApplication(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue = new CoviMap();
		CoviMap params = new CoviMap(paramMap);
		
		try {
			bizTripSvc.exceptBizTripApplication(params);
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return rtValue;
	}
}
