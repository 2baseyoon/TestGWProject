package egovframework.core.web;

import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LoggingSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : LoggingCon.java
 * @Description : 로깅관리
 * @Modification Information 
 * @ 2016.04.05 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.05
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class LoggingCon {
	
	private Logger LOGGER = LogManager.getLogger(LoggingCon.class);
	
	@Autowired
	private LoggingSvc loggingSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/*
	 * 1. 페이지 이동 처리
	 * "layout/{moduleName}_{pageName}.do"
	 * layout/log/connectlogview.do
	 * 
	 * 2. 리스트 처리, 엑셀처리 공통화 할 것
	 * */
	
	/**
	 * getConnectionLogList : 로그 관리 - 접속 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getconnectionloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConnectionLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			
			resultList = loggingSvc.selectConnect(params);

			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "connectionlogexceldownload.do" )
	public ModelAndView connectionLogExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			
			viewParams = loggingSvc.selectConnectExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "ConnectionLogView");
			
			mav = new ModelAndView(returnURL, viewParams);
		} 
		catch (NullPointerException e) {
			LOGGER.error("LogConnectionCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogConnectionCon", e);
		}

		return mav;
	}
	
	/**
	 * getConnectionFalseLogList : 로그 관리 - 접속 실패 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getconnectionfalseloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConnectionFalseLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			resultList = loggingSvc.selectConnectFalse(params);

			returnList.put("page",resultList.get("page")) ;
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getErrorLogList : 로그 관리 - 에러 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/geterrorloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getErrorLogList(
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "companyCodeNull", required = false) String companyCodeNull,
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("companyCode", companyCode);
			params.put("companyCodeNull", companyCodeNull);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			
			resultList = loggingSvc.selectError(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "errorlogexceldownload.do" )
	public ModelAndView errorLogExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			viewParams = loggingSvc.selectErrorExcel(params);
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "ErrorLogView");
			
			CoviList jArray = new CoviList();
			jArray = (CoviList) viewParams.get("list");
			
			CoviList returnJArray = new CoviList();
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				/*jObj.put("ErrorMessage", "[상세내용은 관리자페이지에서 확인해주세요.]");*/
				returnJArray.add(jObj);
			}
			viewParams.put("list", returnJArray);
		
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogErrorCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogErrorCon", e);
		}

		return mav;
	}
	
	/**
	 * getPageMoveLogList : 로그 관리 - 페이지 이동 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getpagemoveloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPageMoveLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "objectType", required = false) String objectType,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("objectType", objectType);
			params.put("companyCode", companyCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			resultList = loggingSvc.selectPageMove(params);
		
			returnList.put("page", resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "pagemovelogexceldownload.do")
	public ModelAndView pageMoveLogExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchText", required = false) String searchText,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "objectType", required = false) String objectType,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
		
			
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("companyCode", companyCode);
			params.put("objectType", objectType);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			viewParams = loggingSvc.selectPageMoveExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "PageMoveLogView");
		
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogPageMoveCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogPageMoveCon", e);
		}

		return mav;
	}
	
	/**
	 * getPerformenceLogList : 로그관리 - 성능 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getperformenceloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPerformenceLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();

			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("urCode", searchText);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			resultList = loggingSvc.selectPerformance(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "performancelogexceldownload.do" )
	public ModelAndView performanceLogExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String[] headerNames =  headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			viewParams = loggingSvc.selectPerformanceExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "PerformanceLogView");
		
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogPerformanceCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogPerformanceCon", e);
		}

		return mav;
	}
	
	/**
	 * getUserInfoProcessingLogList : 로그 관리 - 사용자 정보 처리 로그 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getuserinfoprocessingloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserInfoProcessingLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();

			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			resultList = loggingSvc.selectUserInfoChange(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "log/gethttploglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getHttpLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "logType", required = false) String logType,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("logType", logType);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			
			resultList = loggingSvc.selectHttpConnect(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "log/usercheckloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserCheckList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "authType", required = false) String authType,
			@RequestParam(value = "searchType", required = false) String searchType,
			@RequestParam(value = "searchWord", required = false) String searchWord,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("authType", authType);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			resultList = loggingSvc.selectUserCheck(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "log/detailErrorLogMessage.do", method=RequestMethod.GET)
	public ModelAndView detailErrorLogMessage(HttpServletRequest request, HttpServletResponse response,Locale locale, Model model)
	{
		response.setHeader("Pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");

		CoviMap params = new CoviMap();
	
		String message = "";
		String returnURL = "core/log/detailLogMessage";
		
		params.put("LogID", request.getParameter("Log"));
		
		try {
			message = loggingSvc.selectDetailErrorLogMessage(params);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("message", message);
		
		return mav;
	}
	
	/**
	 * [SaaS] DB동기화 로그조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "log/ExtDbSyncLog.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getExtDbSyncLog(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			CoviMap params = new CoviMap();
			for(Entry<String, String> entry : paramMap.entrySet()) {
				params.put(entry.getKey(), entry.getValue());
			}
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String startDate = StringUtil.replaceNull(request.getParameter("startdate"));
			String endDate = StringUtil.replaceNull(request.getParameter("enddate"));
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(StringUtil.replaceNull(startDate).equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(StringUtil.replaceNull(endDate).equals("") ? "" : endDate + " 23:59:59")));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = loggingSvc.selectExtDbSync(params);
			
			returnList.put("page",resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error("", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "log/detailExtDbSyncLogMessage.do")
	public ModelAndView detailExtDbSyncLogMessage(HttpServletRequest request, Locale locale, Model model) {
		CoviMap params = new CoviMap();
	
		String message = "";
		String returnURL = "core/log/ExtDbSyncLogDetail";
		params.put("LogSeq", request.getParameter("LogSeq"));
		
		try {
			message = loggingSvc.selectExtDbSyncDetail(params);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("message", message);
		
		return mav;
	}
	
	/**
	 * getFiledownloadLogList : 로그 관리 - 파일 다운로드 목록 호출
	 * @param startDate
	 * @param endDate
	 * @param searchText
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getfiledownloadloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFiledownloadLogList(
		HttpServletRequest request,
		@RequestParam(value = "startdate", required = false) String startDate,
		@RequestParam(value = "enddate", required = false) String endDate,
		@RequestParam(value = "searchtext", required = false) String searchText,
		@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
		@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
		
		) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortColumn =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirection =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();

		params.put("lang", SessionHelper.getSession("lang"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
		params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
		params.put("startDate", startDate);
		params.put("endDate", endDate);
		
		params.put("pageNo", pageNo);
		params.put("pageSize", pageSize);
		
		//timezone 적용 날짜변환
		if(params.get("startDate") != null && !params.get("startDate").equals("")){
			params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if(params.get("endDate") != null && !params.get("endDate").equals("")){
			params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
		}			
		
		resultList = loggingSvc.selectFileDownload(params);

		returnList.put("page",resultList.get("page")) ;
		returnList.put("list", resultList.get("list"));

		returnList.put("status", Return.SUCCESS);
		} 
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	// 엑셀 다운로드
	@RequestMapping(value = "filedownloadlogexceldownload.do" )
	public ModelAndView filedownloadLogExcelDownload(
		@RequestParam(value = "startdate", required = false) String startDate,
		@RequestParam(value = "enddate", required = false) String endDate,
		@RequestParam(value = "searchtext", required = false) String searchText,
		@RequestParam(value = "headername", required = false) String headername,
		@RequestParam(value = "headerType", required = false) String headerType,
		@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
		@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
		) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			
			viewParams = loggingSvc.selectFileDownloadExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "FileDownloadLogView");
			
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogConnectionCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogConnectionCon", e);
		}

		return mav;
	}
	
	/**
	 * getPageMoveLogList : 통합관리 - 권한 오류 로그
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getautherrorloglist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAuthErrorLogList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("companyCode", companyCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			resultList = loggingSvc.selectAuthError(params);
		
			returnList.put("page", resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "autherrorlogexceldownload.do")
	public ModelAndView authErrorLogExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "searchText", required = false) String searchText,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("companyCode", companyCode);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			viewParams = loggingSvc.selectAuthErrorExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "AuthErrorLogView");
		
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogAuthErrorCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogAuthErrorCon", e);
		}

		return mav;
	}
	
	/**
	 * getPageMoveLogList : 통합관리 - 권한 변경 이력
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getauthchangehistorylist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAuthChangeHistoryList(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "searchTarget", required = false) String searchTarget,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "objectType", required = false) String objectType,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo, 	// pageNo : 현재 페이지 번호
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize // pageSize : 페이지당 출력데이타 수
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchTarget", searchTarget);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("objectType", objectType);
			params.put("companyCode", companyCode);
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			resultList = loggingSvc.selectACLChange(params);
		
			returnList.put("page", resultList.get("page")) ;
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 권한변경 이력 엑셀 다운로드
	@RequestMapping(value = "authchangehistoryexceldownload.do") 
	public ModelAndView authChangeHistoryExcelDownload(
			@RequestParam(value = "startdate", required = false) String startDate,
			@RequestParam(value = "enddate", required = false) String endDate,
			@RequestParam(value = "companyCode", required = false) String companyCode,
			@RequestParam(value = "searchTarget", required = false) String searchTarget,
			@RequestParam(value = "searchtext", required = false) String searchText,
			@RequestParam(value = "objectType", required = false) String objectType,
			@RequestParam(value = "headername", required = false) String headername,
			@RequestParam(value = "headerType", required = false) String headerType,
			@RequestParam(value = "sortKey", required = false, defaultValue="") String sortKey,
			@RequestParam(value = "sortWay", required = false, defaultValue="") String sortWay
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			
			String[] headerNames = headername.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("searchTarget", searchTarget);
			params.put("objectType", objectType);
			params.put("companyCode", companyCode);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			params.put("lbl_add",DicHelper.getDic("lbl_Add")); //추가
			params.put("lbl_change",DicHelper.getDic("lbl_change")); //변경
			params.put("lbl_delete",DicHelper.getDic("lbl_delete")); //삭제
			params.put("lbl_user",DicHelper.getDic("lbl_User")); //사용자
			params.put("lbl_group",DicHelper.getDic("lbl_group")); //그룹
			params.put("lbl_allow",DicHelper.getDic("lbl_Allow")); //허용
			params.put("lbl_reject",DicHelper.getDic("lbl_Reject")); //거부
			params.put("lbl_inherited",DicHelper.getDic("lbl_Inherited")); //상속
			params.put("lbl_noInherited",DicHelper.getDic("lbl_NoInherited")); //비상속
			params.put("lbl_include",DicHelper.getDic("lbl_Include")); //포함
			params.put("lbl_noInclude",DicHelper.getDic("lbl_Exclude")); //불포함
			params.put("lbl_menu",DicHelper.getDic("lbl_Menu")); //메뉴
			params.put("lbl_folder",DicHelper.getDic("lbl_Folder")); //폴더
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			viewParams = loggingSvc.selectAuthChangeHistoryExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "AuthChangeHistoryLogView");
		
			mav = new ModelAndView(returnURL, viewParams);
		}
		catch (NullPointerException e) {
			LOGGER.error("LogAuthErrorCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LogAuthErrorCon", e);
		}

		return mav;
	}
	
	/**
	 * 권한 변경 이력 팝어 호출
	 * @param paramMap
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "log/goACLHistoryPopup.do", method = RequestMethod.GET)
	public ModelAndView goACLHistoryPopup(@RequestParam Map<String, String> paramMap, Locale locale, Model model) {
		String returnURL = "manage/acl/ACLHistoryPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * 권한 변경 이력 로그 조회
	 * 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "log/getACLChangeLogList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getACLChangeLogList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String ObjectID = StringUtil.replaceNull(request.getParameter("ObjectID"), "");
			String ObjectType = StringUtil.replaceNull(request.getParameter("ObjectType"), "");
			
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("objectID", ObjectID);
			params.put("objectType", ObjectType);
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = loggingSvc.selectACLChange(params);
			
			returnData.put("page",resultList.get("page")) ;
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
}
