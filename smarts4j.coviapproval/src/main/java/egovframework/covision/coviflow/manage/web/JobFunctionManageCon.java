package egovframework.covision.coviflow.manage.web;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
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
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.JobFunctionSvc;



@Controller
public class JobFunctionManageCon {
	
	private Logger LOGGER = LogManager.getLogger(JobFunctionManageCon.class);
	
	@Autowired
	private JobFunctionSvc jobFunctionSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getJobFunctionList : 결재업무담당자지정 - 담당 업무 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getJobFunctionList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobFunctionList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo=  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String jobFunctionType = request.getParameter("JobFunctionType");
			String searchType = request.getParameter("SearchType");
			String searchText = request.getParameter("SearchText");
			String entCode = request.getParameter("EntCode");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("JobFunctionType",ComUtils.RemoveSQLInjection(jobFunctionType, 100));
			params.put("EntCode",ComUtils.RemoveSQLInjection(entCode, 100));
			params.put("assignedDomain", ComUtils.getAssignedDomainID());
			params.put("SearchType",ComUtils.RemoveSQLInjection(searchType, 100));
			params.put("SearchText",ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = jobFunctionSvc.selectJobFunctionGrid(params);
			
			returnList.put("page",resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getJobFunctionMemberList : 결재업무담당자지정 - 업무별 담당자 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getJobFunctionMemberList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobFunctionMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String jobFunctionID =request.getParameter("JobFunctionID");
			String searchType =request.getParameter("sel_Search");
			String search =request.getParameter("search");		
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo); // pageNo : 현재 페이지 번호
			params.put("pageSize", pageSize); // pageSize : 페이지당 출력데이타 수
			params.put("JobFunctionID", jobFunctionID);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = jobFunctionSvc.selectJobFunctionMemberGrid(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	/**
	 * goJobFunctionSetPopup : 결재업무담당자지정 - 담당 업무 설정 팝업창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goJobFunctionSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goPersonDirectorOfUnitSetPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/JobFunctionSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goJobFunctionMember : 담당업무함관리 - 담당자 목록 팝업 표시 
	 */
	@RequestMapping(value = "manage/goJobFunctionMember.do", method = RequestMethod.GET)
	public ModelAndView goBizDocMember() {
		String returnURL = "manage/approval/JobFunctionMember";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goJobFunctionMemberSetPopup : 결재업무담당자지정 - 담당자 설정 팝업창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goJobFunctionMemberSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goJobFunctionMemberSetPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/JobFunctionMemberSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goJobFunctionMemberDetailPopup : 결재업무담당자지정 - 담당자 설정 수정 팝업창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goJobFunctionMemberDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goJobFunctionMemberDetailPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/JobFunctionMemberDetailPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getJobFunctionData : 결재업무담당자지정 - 특정 담당 업무 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getJobFunctionData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobFunctionData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String jobFunctionID = request.getParameter("JobFunctionID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("JobFunctionID", jobFunctionID);
			
			resultList = jobFunctionSvc.selectJobFunctionData(params);
			
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getJobFunctionMemberData : 결재업무담당자지정 - 특정 담당자 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getJobFunctionMemberData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobFunctionMemberData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String jobFunctionMemberID = request.getParameter("JobFunctionMemberID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("JobFunctionMemberID", jobFunctionMemberID);			
			resultList = jobFunctionSvc.selectJobFunctionMemberData(params);						
	
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * insertJobFunction : 결재업무담당자지정 - 담당 업무 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertJobFunction.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertJobFunction(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode		  = request.getParameter("EntCode");
			String jobFunctionID  = request.getParameter("JobFunctionID");
			String jobFunctionName= request.getParameter("JobFunctionName");
			String jobFunctionCode= request.getParameter("JobFunctionCode");
			String jobFunctionType= request.getParameter("JobFunctionType");
			String description    = request.getParameter("Description");
			String sortKey        = request.getParameter("SortKey");
			String isUse          = request.getParameter("IsUse");
			String insertDate	  = request.getParameter("InsertDate");

			List selectCode = jobFunctionSvc.selectJobFunctionCode(entCode); //업무함 코드 조회
			
			ArrayList<String> jobFunctionCodeAll = new ArrayList<String> ();
			for(int i=0; i<selectCode.size(); i++) {
				jobFunctionCodeAll.add((String) ((CoviMap) selectCode.get(i)).get("JobFunctionCode"));
			}
			
			if(jobFunctionCodeAll.contains(jobFunctionCode)) {
				returnList.put("object", 0);
				
			}else {
				CoviMap params = new CoviMap();			
				params.put("EntCode"		, entCode);
				params.put("JobFunctionID"  , jobFunctionID);
				params.put("JobFunctionName", ComUtils.RemoveScriptAndStyle(jobFunctionName));
				params.put("JobFunctionCode", ComUtils.RemoveScriptAndStyle(jobFunctionCode));
				params.put("JobFunctionType", jobFunctionType);
				params.put("Description"    , ComUtils.RemoveScriptAndStyle(description));
				params.put("SortKey"        , sortKey);
				params.put("IsUse"          , isUse);
				params.put("InsertDate"     , ComUtils.RemoveScriptAndStyle(insertDate));
				
				returnList.put("object", jobFunctionSvc.insertJobFunction(params));
			}
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateJobFunction : 결재업무담당자지정 - 담당 업무 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateJobFunction.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateJobFunction(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode		  = request.getParameter("EntCode");
			String jobFunctionID  = request.getParameter("JobFunctionID");
			String jobFunctionName= request.getParameter("JobFunctionName");
			String jobFunctionCode= request.getParameter("JobFunctionCode");
			String jobFunctionType= request.getParameter("JobFunctionType");
			String description    = request.getParameter("Description");
			String sortKey        = request.getParameter("SortKey");
			String isUse          = request.getParameter("IsUse");
			String insertDate	  = request.getParameter("InsertDate");
			
			CoviMap params = new CoviMap();
			params.put("EntCode"		, entCode);			
			params.put("JobFunctionID"  , jobFunctionID);
			params.put("JobFunctionName", ComUtils.RemoveScriptAndStyle(jobFunctionName));
			params.put("JobFunctionCode", ComUtils.RemoveScriptAndStyle(jobFunctionCode));
			params.put("JobFunctionType", ComUtils.RemoveScriptAndStyle(jobFunctionType));
			params.put("Description"    , description);
			params.put("SortKey"        , sortKey);
			params.put("IsUse"          , isUse);
			params.put("InsertDate"     , ComUtils.RemoveScriptAndStyle(insertDate));
			
			returnList.put("object", jobFunctionSvc.updateJobFunction(params));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	/**
	 * deleteJobFunction : 결재업무담당자지정 - 담당 업무 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteJobFunction.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteJobFunction(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String jobFunctionID   = request.getParameter("JobFunctionID");
			
			CoviMap params = new CoviMap();			
			params.put("JobFunctionID",jobFunctionID);
			
			returnList.put("object", jobFunctionSvc.deleteJobFunction(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * insertJobFunctionMember : 결재업무담당자지정 - 특정 담당자 정보 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertJobFunctionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertJobFunctionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			String jsonString = request.getParameter("jobFunctionMember");
			
			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);
			CoviList jarr = CoviList.fromObject(escapedJson);			
			
			for(int i=0; i<jarr.size(); i++){			
				CoviMap order = jarr.getJSONObject(i);				
				CoviMap params = new CoviMap();
				params.put("JobFunctionID"  , order.getString("JobFunctionID"));
				params.put("Weight", order.getString("Weight"));
				params.put("UserCode", order.getString("UserCode"));
				params.put("SortKey", order.getString("SortKey"));				
				jobFunctionSvc.insertJobFunctionMember(params);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (ArrayIndexOutOfBoundsException aibooE) {
			LOGGER.error(aibooE.getLocalizedMessage(), aibooE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aibooE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateJobFunctionMember : 결재업무담당자지정 - 특정 담당자 정보 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateJobFunctionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateJobFunctionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String jobFunctionMemberID  = request.getParameter("JobFunctionMemberID");			
			String sortKey     = request.getParameter("SortKey");
			
			CoviMap params = new CoviMap();
			params.put("JobFunctionMemberID", jobFunctionMemberID);
			params.put("SortKey", sortKey);
			
			returnList.put("object", jobFunctionSvc.updateJobFunctionMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * deleteJobFunctionMember : 결재업무담당자지정 - 특정 담당자 정보 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteJobFunctionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteJobFunctionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String jobFunctionMemberID  = request.getParameter("JobFunctionMemberID");
			
			CoviMap params = new CoviMap();
			params.put("JobFunctionMemberID", jobFunctionMemberID);
			
			returnList.put("object", jobFunctionSvc.deleteJobFunctionMember(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
}
