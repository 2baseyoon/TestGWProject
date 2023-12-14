package egovframework.covision.coviflow.manage.web;


import java.util.Locale;
import java.util.Map;

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
import egovframework.covision.coviflow.admin.service.DistributionListSvc;



@Controller
public class DistributionListManageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(DistributionListManageCon.class);
	
	@Autowired
	private DistributionListSvc distributionListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getDistributionList : 배포목록관리 - 배포 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getDistributionList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDistributionList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo=  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String entCode = request.getParameter("EntCode");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);			
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn,100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection,100));
			
			resultList = distributionListSvc.selectDistributionList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goDistributionListSetPopup : 배포목록관리 - 배포 목록 설정 팝업 표시 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goDistributionListSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goDistributionListSetPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/DistributionSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * insertDistributionList : 배포목록관리 - 배포 목록 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertDistributionList.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertDistributionList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String groupCode  = request.getParameter("GroupCode");
			String groupName  = request.getParameter("GroupName");
			String description  = request.getParameter("Description");			
			String sortKey  = request.getParameter("SortKey");			
			String isUse  = request.getParameter("IsUse");			
			String entCode  = request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();			
			params.put("GroupCode"  , ComUtils.RemoveScriptAndStyle(groupCode));
			params.put("GroupName"  , ComUtils.RemoveScriptAndStyle(groupName));
			params.put("Description"  , ComUtils.RemoveScriptAndStyle(description));		
			params.put("SortKey"  , sortKey);			
			params.put("IsUse"  , isUse);
			params.put("EntCode"  , entCode);
			
			returnList.put("object", distributionListSvc.insertDistributionList(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateDistribution : 배포목록관리 - 배포 목록 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateDistribution.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateDistribution(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String groupID  = request.getParameter("GroupID");
			String groupCode  = request.getParameter("GroupCode");
			String groupName  = request.getParameter("GroupName");
			String description  = request.getParameter("Description");			
			String sortKey  = request.getParameter("SortKey");			
			String isUse  = request.getParameter("IsUse");
			
			CoviMap params = new CoviMap();		
			params.put("GroupID"  , groupID);
			params.put("GroupCode"  , ComUtils.RemoveScriptAndStyle(groupCode));
			params.put("GroupName"  , ComUtils.RemoveScriptAndStyle(groupName));
			params.put("Description"  , ComUtils.RemoveScriptAndStyle(description));		
			params.put("SortKey"  , sortKey);			
			params.put("IsUse"  , isUse);
				
			returnList.put("object", distributionListSvc.updateDistribution(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;	
	}
	
	/**
	 * deleteDistribution : 배포목록관리 - 배포 목록 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteDistribution.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteDistribution(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {
			String groupID  = request.getParameter("GroupID");			
			CoviMap params = new CoviMap();		
			params.put("GroupID"  , groupID);							
			returnList.put("object", distributionListSvc.deleteDistribution(params));					
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * getDistirbutionData : 배포목록관리 - 특정 배포목록 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getDistirbutionData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDistirbutionData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String groupID = request.getParameter("GroupID");
			String groupCode = request.getParameter("GroupCode");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("GroupID", groupID);		
			params.put("GroupCode", groupCode);
			
			resultList = distributionListSvc.selectDistirbutionData(params);				
	
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getDistributionMemberList : 배포목록관리 - 대상자 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getDistributionMemberList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDistributionMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String groupID = request.getParameter("GroupID");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("GroupID", groupID);			
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = distributionListSvc.selectDistributionMemberList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goDistributionMemberSetPopup : 배포목록관리 - 배포 대상자 설정 팝업 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goDistributionMemberSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goDistributionMemberSetPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/DistributionMemberSetPopup";		
		return new ModelAndView(returnURL);
	}
	/**
	 * insertDistributionMember : 배포목록관리 - 대상자  추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertDistributionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertDistributionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {			
			String jsonString = request.getParameter("DistributionMember");			
			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);			
			CoviList jarr = CoviList.fromObject(escapedJson);			
			
			for(int i=0; i<jarr.size(); i++){			
				CoviMap order = jarr.getJSONObject(i);				
				CoviMap params = new CoviMap();
				params.put("GroupID"  , order.getString("GroupID"));				
				params.put("SortKey", order.getString("SortKey"));				
				params.put("UserCode", order.getString("UserCode"));				
				distributionListSvc.insertDistributionMember(params);				
			}					
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * updateDistributionMember : 배포목록관리 - 대상자 정보 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/updateDistributionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateDistributionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String groupMemberID  = request.getParameter("GroupMemberID");			
			String sortKey  = request.getParameter("SortKey");			
			
			CoviMap params = new CoviMap();		
			params.put("GroupMemberID"  , groupMemberID);				
			params.put("SortKey"  , sortKey);			
			
			returnList.put("object", distributionListSvc.updateDistributionMember(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * deleteDistributionMember : 배포목록관리 - 대상자 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteDistributionMember.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteDistributionMember(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
		
		try {
			String groupMemberID  = request.getParameter("GroupMemberID");			
			CoviMap params = new CoviMap();		
			params.put("GroupMemberID"  , groupMemberID);							
			returnList.put("object", distributionListSvc.deleteDistributionMember(params));					
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * getDistributionMemberData : 배포목록관리 - 특정 대상자의 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getDistributionMemberData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDistributionMemberData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String groupMemberID = request.getParameter("GroupMemberID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("GroupMemberID", groupMemberID);
			
			resultList = distributionListSvc.selectDistributionMemberData(params);
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goDistributionMemberDetailPopup : 배포목록관리 - 배포 목록 수정 팝업 표시 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goDistributionMemberDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goDistributionMemberDetailPopup(Locale locale, Model model) {		
		String returnURL = "manage/approval/DistributionMemberDetailPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goDistributionMemberList : 배포대상 리스트
	 * @return
	 */
	@RequestMapping(value = "manage/goDistributionMemberList.do", method = RequestMethod.GET)
	public ModelAndView goBizDocMember() {
		String returnURL = "manage/approval/DistributionMemberList";		
		return new ModelAndView(returnURL);
	}
	
	
}
