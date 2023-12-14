package egovframework.core.web;

import java.util.Locale;
import java.util.Map;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.StatisticsSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : StatisticsCon.java
 * @Description : 통계 관리
 * @Modification Information 
 * @ 2017.07.24 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class StatisticsCon {

	private Logger LOGGER = LogManager.getLogger(StatisticsCon.class);
	
	@Autowired
	private StatisticsSvc statSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getStaticChargingExceptionList : 통계 관리 - 현황 예외자 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getchargingexceptionlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStaticChargingExceptionList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String company = request.getParameter("company");
			String searchtype = request.getParameter("searchtype");
			String searchtext = request.getParameter("searchtext");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DN_ID",company);
			params.put("searchType",searchtype);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startDate",startdate);
			params.put("endDate",enddate);
			
			resultList = statSvc.selectChargingException(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
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
	 * getChargingExceptionSelectData : 통계 관리 - 시스템 사용현황 관리 Select Box 데이터 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getchargingexceptionselectdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getChargingExceptionSelectData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String filter = request.getParameter("filter");

		CoviMap returnList = new CoviMap();

		try {
			String listData = "";
			
			/*
			 * filter는 .NET 방식을 가져 올 것
			 * return 형태는 json
			 * 현재 클라이언트는 AXSelect
			 * */
			switch (filter) {
		      case "selectDomain"  : 
		    	  listData = "[ {optionValue: '', optionText:'도메인'},{ optionValue: '1', optionText:'코비그룹(공통)'},{optionValue: '3', optionText: '코비건설'},	{optionValue: '4', optionText: '코비제약'},{optionValue: '5', optionText: '코비시스템'}]";
		    	  break;
		    }
			
			returnList.put("list", listData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * getAddDataChargingException : 통계 관리 - 시스템 사용현황 관리 추가 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "statistics/getadddatachargingexception.do", method = RequestMethod.GET)
	public ModelAndView getAddDataChargingException(Locale locale, Model model) {
		String returnURL = "admin/static/addchargingexceptiondata";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * createChargingException : 통계 관리 - 시스템 사용현황 관리 데이터 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/createchargingexception.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createChargingException(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//단일 insert일 경우
			//prameter validation 처리 할 것
			String startDate = request.getParameter("STARTDATE");
			String endDate = request.getParameter("ENDDATE");
			String comment = request.getParameter("COMMENT");
			int dnID = Integer.parseInt(request.getParameter("DN_ID"));
			String userName = request.getParameter("UR_Code");
			String regID = request.getParameter("RegID");
			String regDate = request.getParameter("RegDate");
			
			CoviMap params = new CoviMap();
			
			//날짜의 경우 timezone 적용 할 것
			params.put("STARTDATE", startDate);
			params.put("ENDDATE", endDate);
			params.put("COMMENT", comment);
			params.put("DN_ID", dnID);
			params.put("UR_Code", userName);
			params.put("RegID", regID);
			params.put("RegDate", regDate);
			
			returnList.put("object", statSvc.insertChargingException(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteChargingException : 통계 관리 - 시스템 사용현황 관리 데이터 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/deletechargingexception.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteChargingException(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String DeleteData = request.getParameter("DeleteData");
		String[] saData = StringUtil.replaceNull(DeleteData).split(",");
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("ceID", saData);
			statSvc.deleteChargingException(params);
			
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
	 * getStaticUsageManageList : 통계 관리 - 시스템 사용 현황 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getusagemanagelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUsageManageList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortColumn = "DN_ID";//request.getParameter("sortBy").split(" ")[0];
			String sortDirection = "ASC";//request.getParameter("sortBy").split(" ")[1];
			String year = request.getParameter("selectYear");
			String month = request.getParameter("selectMonth");
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("year", year);
			params.put("month", month);
			
			resultList = statSvc.selectUsage(params);

			//Percent 구하기
			CoviList jArray = new CoviList();
			jArray = (CoviList) resultList.get("list");
			int itemTotal = 0;
			
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				itemTotal += Integer.parseInt((String) jObj.get("UseDayCount"));
			}
			
			CoviList returnJArray = new CoviList();
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				jObj.put("UseRate", Math.round((Float.parseFloat((String) jObj.get("UseDayCount")) / itemTotal * 100)*100)/100.0 + "%");
				returnJArray.add(jObj);
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", returnJArray);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getStaticUsePageList : 통계 관리 - 시스템 사용량 통계 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getusepagelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUsePageList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortColumn = "UseCount";//request.getParameter("sortBy").split(" ")[0];
			String sortDirection = "DESC";//request.getParameter("sortBy").split(" ")[1];
			String startDate = request.getParameter("startdate");
			String endDate = request.getParameter("enddate");
			String modeValue = request.getParameter("modevalue");
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			switch (modeValue){
				case "Page" :
					resultList = statSvc.selectPage(params);
					break;
				case "System" :
					resultList = statSvc.selectSystem(params);
					break;
				case "Service" :
					resultList = statSvc.selectService(params);
					break;
				default :
					break;
			}

			//Percent 구하기
			CoviList jArray = new CoviList();
			jArray = (CoviList) resultList.get("list");
			int itemTotal = 0;
			
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				itemTotal += Integer.parseInt((String) jObj.get("UseCount"));
			}
			
			CoviList returnJArray = new CoviList();
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				jObj.put("CoCnt", Math.round((Float.parseFloat((String) jObj.get("UseCount")) / itemTotal * 100)*100)/100.0);
				returnJArray.add(jObj);
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", returnJArray);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getStaticUserLogonList : 통계 관리 - 사용자 로그온 통계 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getuserlogonlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserLogonList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//"sortKey=Items&sortWay=desc"
			String sortColumn = "Items"; //request.getParameter("sortBy").split("&")[0].split("=")[1];
			String sortDirection = "ASC"; //request.getParameter("sortBy").split("&")[1].split("=")[1];
			String startDate = request.getParameter("startdate");
			String endDate = request.getParameter("enddate");
			String perValue = request.getParameter("pervalue");
			
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			switch (perValue){
				case "PerTime" :
					resultList = statSvc.selectPerHour(params);
					break;
				case "PerDays" :
					resultList = statSvc.selectPerDays(params);
					break;
				case "PerDay" :
					resultList = statSvc.selectPerDay(params);
					break;
				case "PerMonth" :
					resultList = statSvc.selectPerMonth(params);
					break;
				default :
					break;
			}
			
			//Percent 구하기
			CoviList jArray = new CoviList();
			jArray = (CoviList) resultList.get("list");
			int itemTotal = 0;
			
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				itemTotal += Integer.parseInt((String) jObj.get("Cnt"));
			}
			
			CoviList returnJArray = new CoviList();
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				jObj.put("CoCnt", Math.round((Float.parseFloat((String) jObj.get("Cnt")) / itemTotal * 100)*100)/100.0);
				
				// 요일 구분값 숫자대신 문자열
				if(StringUtil.replaceNull(perValue).equals("PerDay")){
					switch((String)jObj.get("Items")){
						case "1" : jObj.put("Items", "일요일"); break;
						case "2" : jObj.put("Items", "월요일"); break;
						case "3" : jObj.put("Items", "화요일"); break;
						case "4" : jObj.put("Items", "수요일"); break;
						case "5" : jObj.put("Items", "목요일"); break;
						case "6" : jObj.put("Items", "금요일"); break;
						case "7" : jObj.put("Items", "토요일"); break;
						default : break;
					}
				}
				
				returnJArray.add(jObj);
			}

			returnList.put("page", resultList.get("page"));
			returnList.put("list", returnJArray);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getStaticUserSystemList : 통계 관리 - 접속시스템 통계 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "statistics/getusersystemlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserSystemList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortColumn = "Cnt";//request.getParameter("sortBy").split(" ")[0];
			String sortDirection = "DESC";//request.getParameter("sortBy").split(" ")[1];
			String startDate = request.getParameter("startdate");
			String endDate = request.getParameter("enddate");
			String modeValue = request.getParameter("modevalue");
			
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}			
			switch (modeValue){
				case "Browser" :
					resultList = statSvc.selectBrowser(params);
					break;
				case "OS" :
					resultList = statSvc.selectOS(params);
					break;
				case "Resolution" :
					resultList = statSvc.selectResolution(params);
					break;
				case "Region" :
					resultList = statSvc.selectRegion(params);
					break;
				default :
					break;
			}

			//Percent 구하기
			CoviList jArray = new CoviList();
			jArray = (CoviList) resultList.get("list");
			int itemTotal = 0;
			
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				itemTotal += Integer.parseInt((String) jObj.get("Cnt"));
			}
			
			CoviList returnJArray = new CoviList();
			for(Object obj : jArray){
				CoviMap jObj = new CoviMap();
				jObj = (CoviMap) obj;
				
				jObj.put("CoCnt", Math.round((Float.parseFloat((String) jObj.get("Cnt")) / itemTotal * 100)*100)/100.0);
				returnJArray.add(jObj);
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", returnJArray);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
