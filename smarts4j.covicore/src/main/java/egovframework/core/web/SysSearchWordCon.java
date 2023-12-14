package egovframework.core.web;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;




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

import egovframework.core.sevice.SysSearchWordSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : SysBaseConfigCon.java
 * @Description : 시스템 - 검색어 관리
 * @Modification Information 
 * @ 2018.09.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysSearchWordCon {

	private Logger LOGGER = LogManager.getLogger(SysSearchWordCon.class);
	
	@Autowired
	private SysSearchWordSvc sysSerachWordSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 검색어 관리 그리드 데이터
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "searchWord/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "domainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "searchType", required = true, defaultValue = "") String searchType,
			@RequestParam(value = "searchWord", required = true, defaultValue = "") String searchWord,
			@RequestParam(value = "pageNo", required = true, defaultValue = "") String pageNo,
			@RequestParam(value = "pageSize", required = true, defaultValue = "") String pageSize,
			@RequestParam(value = "sortBy", required = true, defaultValue = "") String sortBy) throws Exception
	{
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			CoviMap params = new CoviMap();
			params.put("DomainID", domainID);
			params.put("SearchType", searchType);
			params.put("SearchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortBy.split(" ")[0], 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortBy.split(" ")[1], 100));
			
			int cnt = sysSerachWordSvc.selectListCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = sysSerachWordSvc.selectList(params);
			
			returnList.put("page", params);
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
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
	 * 검색어 추가 및 수정 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "searchWord/goAddLayerPopup.do", method = RequestMethod.GET)
	public ModelAndView goAddLayerPopup(Locale locale, Model model) {
		String returnURL = "core/system/SearchWordLayerPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 검색어 데이터 추가 및 수정
	 * @param request
	 * @param mode
	 * @param searchWordID
	 * @param domainID
	 * @param system
	 * @param searchWord
	 * @param searchCount
	 * @param recentlyPoint
	 * @param createDate
	 * @param searchDate
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "searchWord/setData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setData(HttpServletRequest request,
			@RequestParam(value = "mode", required = true, defaultValue = "") String mode,
			@RequestParam(value = "searchWordID", required = true, defaultValue = "") String searchWordID,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "system", required = true, defaultValue = "") String system,
			@RequestParam(value = "searchWord", required = true, defaultValue = "") String searchWord,
			@RequestParam(value = "searchCount", required = true, defaultValue = "") String searchCount,
			@RequestParam(value = "recentlyPoint", required = false) String recentlyPoint,
			@RequestParam(value = "createDate", required = false) String createDate,
			@RequestParam(value = "searchDate", required = false) String searchDate) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("SearchWordID", searchWordID);
			params.put("DomainID", domainID);
			params.put("System", system);
			params.put("SearchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("SearchCnt", searchCount);
			params.put("RecentlyPoint", recentlyPoint);
			params.put("CreateDate", createDate);
			params.put("SearchDate", searchDate);
			
			if(mode.equalsIgnoreCase("add"))
				sysSerachWordSvc.insertData(params);
			else if(mode.equalsIgnoreCase("modify"))
				sysSerachWordSvc.updateData(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
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
	 * 검색어 데이터 삭제 
	 * @param request
	 * @param deleteData
	 * @return returnList
	 */
	@RequestMapping(value = "searchWord/deleteData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertSearchData(HttpServletRequest request, 
		@RequestParam(value = "DeleteData", required = true, defaultValue = "") String deleteData	)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String [] arrDeleteData = deleteData.split("[|]");
			
			if(!deleteData.isEmpty() && arrDeleteData.length > 0){
				params.put("arrDeleteData", arrDeleteData);
				
				sysSerachWordSvc.deleteData(params);
			}
			
			returnList.put("status", Return.SUCCESS);
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
	 * 검색어 데이터 조회
	 * @param request
	 * @param searchWordID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "searchWord/getData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getData(HttpServletRequest request, 
			@RequestParam(value = "searchWordID", required = true, defaultValue = "") String searchWordID) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("SearchWordID", searchWordID);
			
			resultList = sysSerachWordSvc.selectData(params);
			
			returnList.put("data", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
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
	 * 
	 * @param request
	 * @param searchWord
	 * @param domainID
	 * @param system
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "searchWord/insertSearchData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertSearchData(HttpServletRequest request, 
			@RequestParam(value = "searchWord", required = true, defaultValue = "") String searchWord,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "system", required = true, defaultValue = "") String system) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
		
			List searchWordList = Arrays.asList(searchWord.split("¶"));
			
			for(int i=0; i<searchWordList.size(); i++){
				if(!searchWordList.get(i).toString().equals("")){
					params.put("SearchWord", ComUtils.RemoveSQLInjection(searchWordList.get(i).toString(), 100));
					params.put("DomainID", domainID);
					params.put("System", system);
					
					sysSerachWordSvc.insertSearchData(params);
				}
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
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
	 * 
	 * @param request
	 * @param searchWord
	 * @param domainID
	 * @param system
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "searchWord/checkDouble.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDouble(HttpServletRequest request, 
			@RequestParam(value = "searchWord", required = true, defaultValue = "") String searchWord,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "system", required = true, defaultValue = "") String system) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("SearchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("DomainID", domainID);
			params.put("System", system);
			
			returnList = sysSerachWordSvc.checkDouble(params);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
