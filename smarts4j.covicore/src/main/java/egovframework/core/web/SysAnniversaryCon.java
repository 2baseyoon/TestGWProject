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

import egovframework.core.sevice.SysAnniversarySvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;

/**
 * @Class Name : SysAnniversaryCon.java
 * @Description : 시스템 - 기념일 관리
 * @Modification Information 
 * @ 2018.10.01 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.10.01
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysAnniversaryCon {

	private Logger LOGGER = LogManager.getLogger(SysAnniversaryCon.class);
	
	@Autowired
	private SysAnniversarySvc sysAnniversarySvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getAnniversaryList - 기념일 목록 조회
	 * @param request
	 * @param domainID
	 * @param anniversaryType
	 * @param startYear
	 * @param pageNo
	 * @param pageSize
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "anniversary/getAnniversaryList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAnniversaryList(HttpServletRequest request,
			@RequestParam(value = "domainID", required = false) String domainID,
			@RequestParam(value = "anniversaryType", required = false ) String anniversaryType,
			@RequestParam(value = "startYear", required = false , defaultValue = "0" ) int startYear,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnData = new CoviMap();
		 
		try {
			String sortBy = request.getParameter("sortBy");
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
		
			params.put("domainID", domainID);
			params.put("anniversaryType", anniversaryType);
			params.put("startYear", startYear);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if(domainID.isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			resultList = sysAnniversarySvc.getAnniversaryList(params);
			
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
	
	/**
	 * goAnniversarySetPopup: 기념일 관리 추가/수정 팝업 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "anniversary/goAnniversarySetPopup.do", method = RequestMethod.GET)
	public ModelAndView goAnniversarySetPopup() {
		return (new ModelAndView("core/system/AnniversarySetPopup"));
	}
	
	
	/**
	 * getAnniversaryData : 시스템 관리 - 기초설정 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "anniversary/getAnniversaryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAnniversaryData(
			@RequestParam(value = "calendarID", required = true) String calendarID) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnData = new CoviMap();
		 
		try {
			CoviMap params = new CoviMap();
		
			params.put("calendarID", calendarID);
			
			returnData.put("anniversary",  sysAnniversarySvc.getAnniversaryData(params));
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
	
	
	/**
	 *  modifyAnniversaryData : 기념일 수정
	 * @param calendarID
	 * @param anniversaryType
	 * @param hidAnniversaryNameDic
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "anniversary/modifyAnniversaryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyAnniversaryData(
			@RequestParam(value = "calendarID", required = true) String calendarID,
			@RequestParam(value = "anniversaryType", required = true) String anniversaryType,
			@RequestParam(value = "hidAnniversaryNameDic", required = true) String hidAnniversaryNameDic) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("calendarID", calendarID);
			params.put("anniversaryType", anniversaryType);
			params.put("hidAnniversaryNameDic", hidAnniversaryNameDic);
			
			sysAnniversarySvc.updateAnniversaryData(params);
			
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
	
	/**
	 * addAnniversaryData - 기념일 추가
	 * @param domainID
	 * @param anniversaryType
	 * @param solarDate
	 * @param isRepeat
	 * @param repeatCnt
	 * @param hidAnniversaryNameDic
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "anniversary/addAnniversaryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addAnniversaryData(
			@RequestParam(value = "domainID", required = true) String domainID,
			@RequestParam(value = "anniversaryType", required = true) String anniversaryType,
			@RequestParam(value = "solarDate", required = true) String solarDate,
			@RequestParam(value = "isRepeat", required = true, defaultValue="N") String isRepeat,
			@RequestParam(value = "repeatCnt", required = true, defaultValue="0") int repeatCnt,
			@RequestParam(value = "hidAnniversaryNameDic", required = true) String hidAnniversaryNameDic) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
		
			params.put("domainID", domainID);
			params.put("anniversaryType", anniversaryType);
			params.put("solarDate", solarDate);
			params.put("isRepeat", isRepeat);
			params.put("repeatCnt", repeatCnt);
			params.put("hidAnniversaryNameDic", hidAnniversaryNameDic);
			
			if(sysAnniversarySvc.checkAnniversaryData(params) <= 0){
				sysAnniversarySvc.insertAnniversaryData(params);
				returnData.put("duplication", "N");
			}else{
				returnData.put("duplication", "Y");
			}
			
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
	
	/**
	 * deleteAnniversaryData - 기념일 삭제
	 * @param deleteData
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "anniversary/deleteAnniversaryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteAnniversaryData(
			@RequestParam(value = "deleteData", required = true, defaultValue = "") String deleteData
			) throws Exception
	{
		CoviMap returnData = new CoviMap();
		
		try {
			if(! deleteData.isEmpty()){
				CoviMap params = new CoviMap();
				params.put("deleteData", deleteData);
				
				sysAnniversarySvc.deleteAnniversary(params);
			}
			
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
	
	/**
	 * Google API 국가 공휴일 연동
	 * @param request
	 * @param response
	 * @param parameters
	 * @return
	 */
	@RequestMapping(value = "anniversary/setGoogleHoliday.do")
	public @ResponseBody CoviMap setGoogleHoliday(HttpServletRequest request, HttpServletResponse response ,@RequestParam Map<String, Object> parameters) {
		
		CoviMap result = new CoviMap();
		
		try { 
			CoviMap params = new CoviMap();
			CoviList holiList = CoviList.fromObject(parameters.get("holi").toString().replaceAll("&quot;", "\""));
			
			if(holiList.size() > 0) {
				for(int i = 0; i < holiList.size(); i++){
		    		CoviMap holiMap = holiList.getJSONObject(i);

		    		params.put("domainID", holiMap.get("DomainID").toString().equals("") ? "0" : holiMap.get("DomainID"));
		    		params.put("anniversaryType", holiMap.get("AnniversaryType"));	 
					params.put("anniversary", holiMap.get("Anniversary"));
					params.put("hidAnniversaryNameDic", holiMap.get("Anniversary") + ";;;;;;;;;");
					params.put("solarYear", holiMap.get("SolarYear"));	 
					params.put("solarDate", holiMap.get("SolarDate"));
					params.put("isRepeat", holiMap.get("IsRepeat"));
					
					sysAnniversarySvc.insertGoogleAnniversaryData(params);
		    	}	 
				
				result.put("status", Return.SUCCESS);
			} else {
				result.put("status", Return.FAIL);
			}
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;
	}
	
}
