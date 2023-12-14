package egovframework.covision.coviflow.govdocs.web;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.form.service.impl.ApvProcessSvcImpl;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;



@Controller
public class ApprovalGovDocCon {
	private Logger LOGGER = LogManager.getLogger(ApprovalGovDocCon.class);

	@Autowired
	private ApprovalGovDocSvc approvalGovDocSvc;
	
	@Autowired
	private ApvProcessSvc apvProcessSvc;
	
	@Autowired
	private FileUtilService fileUtilService;

	@Autowired
	public FormSvc formSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	* @Method Name : CheckGovReceiveDoc
	* @Description : KIC - 대외공문 수신 접수여부 체크
	*/
	@RequestMapping(value = "/user/CheckGovReceiveDoc.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkGovReceiveDoc(HttpServletRequest request) throws Exception{
		int result = 0;
		
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String formInstID = request.getParameter("FormInstID");
			
			params.put("FormInstID", formInstID);
			
			result = approvalGovDocSvc.checkGovReceiveDoc(params);
			
			if(result > 0){
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", "Y");
        	}
			else {
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", "N");
        	}
			
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "N");
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "N");
		}
		return returnObj;
	}
	
	/**
	 * getGovApvList - 문서유통 발송 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getGovApvList.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovApvListCmpl(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		
		try {
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			/* user */
			params.put("userId"			,paramMap.get("userId"));
			
			/* 검색조건 */
			params.put("pageNo"			,paramMap.get("pageNo"));
			params.put("pageSize"		,paramMap.get("pageSize"));
			params.put("sortBy"			,ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection"	,ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("searchInput"	,paramMap.get("searchInput"));
			params.put("keyword"		,paramMap.get("keyword"));
			params.put("fieldName"		,paramMap.get("fieldName"));
			params.put("fromDate"		,paramMap.get("fromDate"));
			params.put("toDate"			,paramMap.get("toDate"));
			params.put("govDocStatus"	,paramMap.get("govDocStatus"));
			params.put("receiveStatus"	,paramMap.get("receiveStatus"));		
			params.put("govDocSecurity"	,paramMap.get("govDocSecurity"));		
			/* 문서타입 */
			params.put("govDocs"		,null == paramMap.get("govDocs") ? "sendWait" : paramMap.get("govDocs"));
			/* Admin */
			params.put("adminYN"		, approvalGovDocSvc.selectGovAuthManage(params) );
			params.put("lang"			, SessionHelper.getSession("lang"));
			
			if( "history".equals(paramMap.get("govDocs")) ) {
				resultList = approvalGovDocSvc.selectGovApvHistory(params);
			}else if( "senderMaster".equals(paramMap.get("govDocs")) ) {				
				resultList = approvalGovDocSvc.selectGovSenderMasterList(params);
			}else if( "sendWait,sendComplete,sendError".contains( paramMap.get("govDocs") ) ) {				
				resultList = approvalGovDocSvc.selectGovApvSend(params);
			} else {
				resultList = approvalGovDocSvc.selectGovApvReceive(params);
			}			

			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	 * selectGovDocMng - 문서유통 대외공문 담당관리( 검색조건 )
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/selectGovDocMng.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap selectGovDocMng(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();	
		
		try {
			/* user */
			params.put("userId", SessionHelper.getSession("USERID"));
			
			String strAdminYN = approvalGovDocSvc.selectGovAuthManage(params);
			params.put("adminYN", strAdminYN);
			
			returnList.put("adminYN", strAdminYN);
			returnList.put("mngList", approvalGovDocSvc.selectGovAuthManageList(params).get("list"));
			
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
	 * getGovManager - 대외공문 담당관리 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getGovManager.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovManager(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		
		try {
			resultList = approvalGovDocSvc.selectGovManager(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	 * govDocUserAdd : 대외공문 담당관리(팝업) - 추가
	 * @return mav
	 */
	@RequestMapping(value = "user/govDocUserAdd.do", method = RequestMethod.GET)
	public ModelAndView goOrgChart(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/GovDocAddPopup";
		CoviMap params = new CoviMap();		
		ModelAndView mav = new ModelAndView(returnURL);
		
		try {			
			if( null != paramMap.get("authorityId") && paramMap.get("authorityId").length() > 0 ) {
				params.put("authorityId", paramMap.get("authorityId")); 
				mav.addObject("list", approvalGovDocSvc.selectGovManager(params).get("list"));
				mav.addObject("authorityId", paramMap.get("authorityId"));
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * insertGovDocUser - 대외공문 담당관리 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertGovDocUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovDocUserSave(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		JSONParser 	parser 		= new JSONParser();
		CoviMap jsonObj = (CoviMap) parser.parse( paramMap.get("data"));		
		
		try {
			CoviMap 	user 	= (CoviMap) jsonObj.get("user");
			CoviList	dept 	= (CoviList) jsonObj.get("dept");
			
			params.put("adminYN", paramMap.get("adminYN"));
			params.put("authorityID", user.get("userId"));
			params.put("deptList", dept);			
			params.put("userId"			,SessionHelper.getSession("USERID"));
			
			approvalGovDocSvc.deleteGovDocUser(params);
			approvalGovDocSvc.insertGovDocUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다."); 
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * deleteGovDocUser - 대외공문 담당관리 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteGovDocUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap deleteGovDocUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {		
			params.put("authorityID" ,paramMap.get("userId"));
			
			approvalGovDocSvc.deleteGovDocUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * getGovDocInOutManager - 문서수발신 담당자 관리 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getGovDocInOutManager.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovDocInOutManager(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultList = new CoviMap();
			CoviMap params = new CoviMap();
			String CompanyCode = SessionHelper.getSession("DN_Code");
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("CompanyCode", CompanyCode);
			params.put("deptCode", request.getParameter("deptCode"));
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = approvalGovDocSvc.selectGovDocInOutManager(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}	
	
	/**
	 * getGovDocInOutManager - 문서수발신 담당자 관리 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getGovDocManager.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovDocManager(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			CoviMap resultList = new CoviMap();
			
			params.put("UserId", request.getParameter("UserId"));
			int cnt = approvalGovDocSvc.selectGovDocManager(params);
			
			returnList.put("Cnt", cnt);
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * govDocInOutUserAdd : 문서수발산 담당자 관리 - 추가
	 * @return mav
	 */
	@RequestMapping(value = "user/govDocInOutUserAdd.do", method = RequestMethod.GET)
	public ModelAndView goDocInOutUserAdd(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/DocManagerAddPopup";
		CoviMap params = new CoviMap();		
		ModelAndView mav = new ModelAndView(returnURL);
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			params.put("CompanyCode", companyCode);
			params.put("mode", paramMap.get("mode") == null ? "" : paramMap.get("mode"));
			
			if( paramMap.get("deptCode") != null && paramMap.get("deptCode").length() > 0 ) {
				params.put("deptCode", paramMap.get("deptCode")); 
				mav.addObject("list", approvalGovDocSvc.selectGovDocInOutManager(params).get("list"));
				mav.addObject("deptCode", paramMap.get("deptCode"));
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * insertGovDocInOutUser - 문서수발신 담당자 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertGovDocInOutUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap insertGovDocInOutUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		JSONParser 	parser 		= new JSONParser();
		CoviMap jsonObj = (CoviMap) parser.parse( paramMap.get("data"));		
		
		try {
			CoviMap 	dept 	= (CoviMap) jsonObj.get("dept");
			CoviList	user 	= (CoviList) jsonObj.get("user");
			
			params.put("mgrUnitCode", dept.get("code"));
			params.put("userList", user);			
			params.put("userId", user);
			
			approvalGovDocSvc.deleteGovDocInOutUser(params);
			approvalGovDocSvc.insertGovDocInOutUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다."); 
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * deleteGovDocInOutUser - 문서수발신 담당자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteGovDocInOutUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap deleteGovDocInOutUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {		
			params.put("mgrUnitCode", paramMap.get("code"));
			
			approvalGovDocSvc.deleteGovDocInOutUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "user/GovDocExceptionPopup.do", method = RequestMethod.GET)
	public ModelAndView govDocExceptionPopup(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/GovDocExceptionPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		try {
			mav.addObject("content", approvalGovDocSvc.selectLog(paramMap));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	
	/**
	 * GovDocHistoryPopup : 이력팝업
	 * @return mav
	 */
	@RequestMapping(value = "user/GovDocHistoryPopup.do", method = RequestMethod.GET)
	public ModelAndView selectHistory(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/GovDocHistoryPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		try {
			mav.addObject("docId", paramMap.get("docId"));
			mav.addObject("govDocs", paramMap.get("govDocs"));
			mav.addObject("uniqueId", paramMap.get("uniqueId"));
			mav.addObject("sendID", paramMap.get("sendID"));
			mav.addObject("callType", paramMap.get("callType"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * GovDocHistoryPopup : 이력팝업
	 * @return mav
	 */
	@RequestMapping(value = "user/GovDocSendHistoryPopup.do", method = RequestMethod.GET)
	public ModelAndView selectSendHistory(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/GovDocSendHistoryPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		try {
			mav.addObject("docId", paramMap.get("docId"));
			mav.addObject("govDocs", paramMap.get("govDocs"));
			mav.addObject("uniqueId", paramMap.get("uniqueId"));
			
			if( paramMap.get("govDocs").equals("sendWait") ) {
				mav.addObject("receiveList", approvalGovDocSvc.selectReceiveList( paramMap.get("uniqueId") ) );
			}
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * selectHistoryData : 이력 데이터
	 * @return mav
	 */
	@RequestMapping(value = "user/selectHistoryData.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap selectHistoryData(@RequestParam Map<String, String> paramMap) {
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();				
		try {		
			params.put("govDocs" 	,paramMap.get("govDocs"));
			params.put("docId" 		,paramMap.get("docId"));
			params.put("uniqueId" 	,paramMap.get("uniqueId"));
			params.put("sendID" 	,paramMap.get("sendID"));
			params.put("pageNo"		,paramMap.get("pageNo"));		
			params.put("pageSize"	,paramMap.get("pageSize"));
			
			resultList = approvalGovDocSvc.selectGovHistory(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok"); 
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다"); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * 발송정보 데이터
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "user/selectHistorySendData.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap selectHistorySendData(@RequestParam Map<String, String> paramMap) {
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();				
		try {		
			params.put("uniqueId" 	,paramMap.get("uniqueId"));
			
			resultList = approvalGovDocSvc.selectGovSendInfoHistory(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok"); 
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다"); 
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * 문서유통 - Offline 문서 저장 메소드
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "offlineSave.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doOfflineSave(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();	
		try{
			CoviMap formObj = CoviMap.fromObject(new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			List<MultipartFile> mf = request.getFiles("fileData[]");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return result;
			}
			
			// FormInstance 생성 & 발송대장 등록 
			CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
			
			// 문서유통 수기문서 등록
			approvalGovDocSvc.doSaveDocList(processFormDataReturn);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		}catch(NullPointerException npE){
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		}catch(Exception e){
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}
	
	/**
	 * 문서유통 발신
	 * @return mav
	 */
	@RequestMapping(value = "govDocs/callPacker.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap callPacker(@RequestParam MultiValueMap<String, String> paramMap,HttpServletResponse response) {
		CoviMap 	returnObj 	= new CoviMap();
	    RestTemplate restTemplate = new RestTemplate();	    
	    try {
	    	returnObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/callPacker.do", paramMap, CoviMap.class);	    	
	    	if( returnObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
	    }catch (NullPointerException npE) {
	    	LOGGER.error(npE.getLocalizedMessage(), npE);
	    	response.setStatus(500);
		}catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	response.setStatus(500);
		}	    
	    return returnObj;
	}

	/**
	 * 문서유통 수신응답
	 * @return mav
	 */
	@RequestMapping(value = "govDocs/callAcker.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap callAcker(@RequestParam MultiValueMap<String, String> paramMap,HttpServletResponse response) {
		CoviMap 	returnObj 	= new CoviMap();
	    RestTemplate restTemplate = new RestTemplate();
	    try {
	    	returnObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/callAcker.do", paramMap, CoviMap.class);	    	
	    	if( returnObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
	    }catch (NullPointerException npE) {
	    	LOGGER.error(npE.getLocalizedMessage(), npE);
	    	response.setStatus(500);
		}catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	response.setStatus(500);
		}	    
	    return returnObj;
	}
	
	/**
	 * 문서유통 미리보기
	 * @return mav
	 */
	@RequestMapping(value = "govDocs/preview.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap preview(@RequestParam HashMap<String, String> paramMap,HttpServletResponse response) {
		CoviMap 	returnObj 	= new CoviMap();
	    RestTemplate restTemplate = new RestTemplate();
	    try {
	    	//returnObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/govDocsPreview.do", paramMap, CoviMap.class);	    	
	    	//if( returnObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
	    	CoviMap map = new CoviMap(paramMap);
	    	CoviMap formJson = map.getJSONObject("formJson");

	    	String strBodyTemplGov = formSvc.docsTransform(formJson);
	    	returnObj.putOrigin("content", strBodyTemplGov);
	    	
//	    	if( returnObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
	    	
	    }catch (NullPointerException npE) {
	    	LOGGER.error(npE.getLocalizedMessage(), npE);
	    	response.setStatus(500);
		}catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	response.setStatus(500);
		}	    
	    return returnObj;
	}
	
	/**
	 * 문서유통 미리보기 (일반에디터)
	 * @return mav
	 * 미사용.
	 */
	@RequestMapping(value = "govDocs/Govpreview.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody String govPreview(@RequestParam MultiValueMap<String, String> paramMap,HttpServletResponse response) {
		CoviMap govObj	= new CoviMap();
		String returnObj = "";
	    RestTemplate restTemplate = new RestTemplate();
	    try {
	    	govObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/govDocsPreview.do", paramMap, CoviMap.class);	    	
	    	if( govObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
	    	returnObj = ApvProcessSvcImpl.GetGovDocumentHTML(govObj.getString("content"));
	    }catch (NullPointerException npE) {
	    	LOGGER.error(npE.getLocalizedMessage(), npE);
	    	response.setStatus(500);
		}catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	response.setStatus(500);
		}	    
	    return returnObj;
	}
	
	/**
	 * 문서유통 수신 테스트
	 * @return mav
	 */
	@RequestMapping(value = "govDocs/testReceive.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap testReceive(@RequestParam MultiValueMap<String, String> paramMap,HttpServletResponse response) {
		CoviMap 	returnObj 	= new CoviMap();
	    RestTemplate restTemplate = new RestTemplate();
	    try {
	    	returnObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/testReceive.do", paramMap, CoviMap.class);
	    }catch (NullPointerException npE) {
	    	LOGGER.error(npE.getLocalizedMessage(), npE);
	    	response.setStatus(500);
		}catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    	response.setStatus(500);
		}	    
	    return returnObj;
	}

	/*
	 * 문서유통 수신문서 상태변경
	 * 
	 */	
	@RequestMapping(value = "user/updateGovReceiveStatus.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap updateReceiveStatus(@RequestParam Map<String, String> paramMap)  throws Exception {
		CoviMap 	returnObj 	= new CoviMap();
	    CoviMap		coviMap = new CoviMap();
	    String formInstID = paramMap.get("formInstId");
	    //대상 문서 formInstId
	    coviMap.put("formInstId",  formInstID );		
	    //문서 status
	    coviMap.put("status"	,  paramMap.get("status") );
	    
	    if (paramMap.get("status") .equals("distribute")) {
		    coviMap.put("distribDeptId"	,  paramMap.get("distribDeptId") );
		    coviMap.put("distribDeptName"	,  paramMap.get("distribDeptName") );
	    } 
	    returnObj.put("cnt", approvalGovDocSvc.insertDocumentNumber(coviMap));
	    //returnObj.put("cnt", approvalGovDocSvc.updateGovRecvStatus(coviMap));
	    return returnObj;
	}
	
	/**
	 * selectRecordDocComboData - 기록물대장 검색조건
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/selectRecordDocComboData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap selectRecordDocComboData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();	
		if(paramMap.get("BaseYear")!= null) {
			params.put("BaseYear", paramMap.get("BaseYear"));
		}
		if(paramMap.get("DeptId")!= null) {
			params.put("DeptId", paramMap.get("DeptId"));
		}
		if(paramMap.get("RecordAdmin")!= null) {
			params.put("RecordAdmin", paramMap.get("RecordAdmin"));
		}
		if(paramMap.get("SeriesCode")!=null) {
			params.put("SeriesCode", paramMap.get("SeriesCode"));
		}
		
		try {			
			returnList.put("searchTypeList", approvalGovDocSvc.selectRecordDocComboData(params).get("SearchTypeList"));
			returnList.put("productYearList", approvalGovDocSvc.selectRecordDocComboData(params).get("ProductYearList"));
			returnList.put("recordDeptList", approvalGovDocSvc.selectRecordDocComboData(params).get("RecordDeptList"));
			returnList.put("recordSeriesList", approvalGovDocSvc.selectRecordDocComboData(params).get("RecordSeriesList")); // 단위업무
			returnList.put("recordList", approvalGovDocSvc.selectRecordDocComboData(params).get("RecordList")); // 기록물철
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * getRecordDocList - 기록물등록대장 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordDocList.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getRecordDocList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		
		try {
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String functionLevel = request.getParameter("functionLevel");
			String functionCode = request.getParameter("functionCode");
			String recordSeries = request.getParameter("recordSeries");
			
			params.put("productYear", request.getParameter("productYear"));
			if (!"".equals(request.getParameter("recordDept")) && request.getParameter("recordDept") !=null ) {
				params.put("recordDeptCode", request.getParameter("recordDept"));
			}else if(request.getParameter("recordAdmin").equals("N")) {
				params.put("recordDeptCode", SessionHelper.getSession("GR_Code"));
			}
			
			if(functionLevel.equals("0")) {
				functionLevel = "";
				functionCode = "";
			}else if(functionLevel.equals("1")) {
				recordSeries = functionCode;
				functionCode = "";
			}else if(functionLevel.equals("2")){
				
			}
			
			params.put("registCheck", request.getParameter("registCheck"));
			params.put("releaseCheck", request.getParameter("releaseCheck"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", ComUtils.RemoveSQLInjection(request.getParameter("searchText"), 100));
			params.put("functionCode", functionCode);
			params.put("functionLevel", functionLevel);
			// 단위업무
			params.put("recordSeries", recordSeries);
			// 기록물철
			params.put("recordList", request.getParameter("recordList"));
			
			params.put("sortColumn", sortKey);
			params.put("sortDirection", sortDirec);

			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = approvalGovDocSvc.selectRecordDocList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}	
	
	
	/**
	 * getRecordAdmin - 기록물철 권한
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordAdmin.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getRecordAdmin(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap resultList = new CoviMap();
			
			params.put("UserId", request.getParameter("UserId"));
			int cnt = approvalGovDocSvc.selectRecordAdmin(params);
			
			returnList.put("Cnt", cnt);
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getRecordAdmin - 기록물철 부서 관리자 권한
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordDeptAdmin.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getRecordDeptAdmin(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			CoviMap resultList = new CoviMap();
			
			params.put("UserId", request.getParameter("UserId"));
			int cnt = approvalGovDocSvc.selectRecordDeptAdmin(params);
			
			returnList.put("Cnt", cnt);
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * recordDocListExcelDownload - Excel 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "user/recordDocListExcelDownload.do" )
	public ModelAndView recordDocListExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();

		try {
			String selectParams = StringUtil.replaceNull(request.getParameter("selectParams")).replace("&amp;", "&").replace("&quot;", "\"");
			CoviMap selectParamsObj = CoviMap.fromObject(selectParams);
			
			String title = request.getParameter("title");
			String headerKey = request.getParameter("headerkey");
			String headerName = URLDecoder.decode(request.getParameter("headername"), "utf-8");
			String[] headerNames = headerName.split(";");
			
			CoviMap params = new CoviMap();
			for(Iterator<String> keys = selectParamsObj.keys(); keys.hasNext(); ){
				String key = keys.next();
				params.put(key, selectParamsObj.getString(key));
			}
			
			String sortKey = params.get("sortBy")==null?"":params.getString("sortBy").split(" ")[0];
			String sortDirec =  params.get("sortBy")==null?"": params.getString("sortBy").split(" ")[1];
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			
			viewParams = approvalGovDocSvc.selectRecordDocListExcel(params, headerKey);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);

		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
	
	/**
	 * deleteRecordDoc - 기록물 삭제마킹
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteRecordDoc.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap deleteRecordDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {		
			params.put("RecordDocumentIDs" ,paramMap.get("RecordDocumentIDs").split(","));
			
			approvalGovDocSvc.deleteRecordDoc(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * changeFileOfRecordDoc - 기록물 편철변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/changeFileOfRecordDoc.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap changeFileOfRecordDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {		
			params.put("RecordDocumentIDs" ,paramMap.get("RecordDocumentIDs").split(","));
			params.put("RecordClassNum" ,paramMap.get("RecordClassNum"));
			params.put("KeepPeriod" ,paramMap.get("KeepPeriod"));
			
			approvalGovDocSvc.changeFileOfRecordDoc(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "변경되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * saveDocTempInfo - 접수(수신)부서의 문서정보 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/saveDocTempInfo.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap saveDocTempInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {
			//CoviMap docInfoParam = CoviMap.fromObject(paramMap.get("DocInfoParam"));
			CoviMap docInfoParam = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("DocInfoParam")));
			params.addAll(docInfoParam);
			params.put("formInstID" ,paramMap.get("FormInstID"));
			params.put("processID" ,paramMap.get("ProcessID"));
			params.put("deptCode" ,paramMap.get("DeptCode"));
			
			approvalGovDocSvc.saveDocTempInfo(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * getDocTempInfo - 접수(수신)부서의 문서정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDocTempInfo.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getDocTempInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList 	= new CoviMap();		
		CoviMap resultData	= new CoviMap();
		CoviMap params			= new CoviMap();
				
		try {
			params.put("formInstID" ,paramMap.get("FormInstID"));
			params.put("processID" ,paramMap.get("ProcessID"));
			params.put("deptCode" ,paramMap.get("DeptCode"));
			
			resultData = approvalGovDocSvc.selectDocTempInfo(params);
			
			returnList.put("data", resultData);			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * getRecordDocInfo - 기록물 상세조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getRecordDocInfo.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getRecordDocInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList 	= new CoviMap();		
		CoviMap resultData	= new CoviMap();
		CoviMap params			= new CoviMap();
				
		try {
			params.put("RecordDocumentID" ,paramMap.get("RecordDocumentID"));
			
			resultData = approvalGovDocSvc.selectRecordDocInfo(params);
			
			CoviList mapObj = (CoviList)resultData.get("map");
			for(Object obj : mapObj) {
				CoviMap recordObj = (CoviMap) obj;
				
				if(recordObj.get("RECORDFILEPATH") instanceof CoviList){
					CoviList fileArr = (CoviList)recordObj.get("RECORDFILEPATH");
					for(Object tObj : fileArr) {
						CoviMap tokenObj = (CoviMap)tObj;
						tokenObj.put("FileID", tokenObj.getString("id"));
					}
					recordObj.put("RECORDFILEPATH", FileUtil.getFileTokenArray(fileArr));
				}else {
					break;
				}
			}
			
			returnList.put("data", resultData);			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * saveRecordDocInfo - 기록물 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/saveRecordDocInfo.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap saveRecordDocInfo(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
				
		try {
			CoviMap docInfoParam = CoviMap.fromObject(request.getParameter("DocInfoParam"));
			params.addAll(docInfoParam);
			String strOrgFileInfo = (String) params.get("RECORDFILEPATH");
			String strDelFileInfo = (String) params.get("hidDeletFiles");
			
			List<MultipartFile> recordMultiFiles = request.getFiles("fileData_record[]");
			String doAttachFileSaveReturnforRecord = approvalGovDocSvc.doRecordAttachFileSave(recordMultiFiles, strOrgFileInfo, strDelFileInfo);

			params.put("RecordDocumentID", request.getParameter("RecordDocumentID"));
			params.put("DIVISIONTYPE","DISTCOMPLETE");
			params.put("RECORDFILEPATH", doAttachFileSaveReturnforRecord);
			approvalGovDocSvc.saveRecordDocInfo(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다."); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * govDocListExcelDownload - 문서유통 Excel 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "user/govDocListExcelDownload.do" )
	public ModelAndView govDocListExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();

		try {
			String selectParams = StringUtil.replaceNull(URLDecoder.decode(request.getParameter("selectParams"), "utf-8")).replace("&amp;", "&").replace("&quot;", "\"");
			CoviMap selectParamsObj = CoviMap.fromObject(selectParams);
			
			String title = request.getParameter("title");
			String headerKey = request.getParameter("headerkey");
			String headerName = URLDecoder.decode(request.getParameter("headername"), "utf-8");
			String[] headerNames = headerName.split(";");
			
			CoviMap params = new CoviMap();
			for(Iterator<String> keys = selectParamsObj.keys(); keys.hasNext(); ){
				String key = keys.next();
				params.put(key, ComUtils.RemoveSQLInjection(selectParamsObj.getString(key), 100));
			}
			
			params.put("pageNo", 1);		
			params.put("pageSize", 99999999);
			params.put("sortDirection", params.optString("sortBy").split(" ")[1]);
			params.put("sortBy", params.optString("sortBy").split(" ")[0]);
			params.put("lang", SessionHelper.getSession("lang"));
			
			viewParams = approvalGovDocSvc.selectGovDocListExcel(params, headerKey, params.optString("govDocs"));
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);

		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
	
	/** 2022-10-24 => jhsong : 발송함, 수신함엑셀은 새로 만들어서 사용함(govDocListExcelDownload). 추후에 나머지 메뉴들도 발송함처럼 화면에 보이는 값만 출력하게 되면 아래 소스는 필요없으므로 삭제처리해야 함.
	 * approvalListExcelDownload - 문서유통 공통 Excel 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "user/downloadGovDocExcel.do" )
	public ModelAndView downloadGovDocExcel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			String queryID = StringUtil.replaceNull(request.getParameter("queryID"));
			String selectParams = StringUtil.replaceNull(URLDecoder.decode(request.getParameter("selectParams"), "utf-8")).replace("&amp;", "&").replace("&quot;", "\"");
			CoviMap selectParamsObj = CoviMap.fromObject(selectParams);
			String title = request.getParameter("title");
			String headerKey = "";
			CoviList cList = null;
			
			if (queryID.equals("")) {
				String[] headerNames;
				String govDocs = selectParamsObj.optString("govDocs");
				if(govDocs.equals("sendWait")) {
					String[] headerWaitNames =  {"Subject","Institution","Institution Code","Reciver","Send Name","Approval Names","Approval Dates","Approval Signpositions","Approval Types","Approval Signs","Regnumber","Enforce Date","Zipcode","Address","Homepage","Telephone","Fax","E-mail","Publication","Reason","FileName","Author","Dept","AuthorDate","Approver","ApproverDate"};
					queryID="user.govDoc.selectGovApvSendCmplExcel";
					headerNames=headerWaitNames;
				} else {
					String[] headeReceiverNames =  {"Subject","Institution","Institution Code","Reciver","Send Name","Approval Names","Approval Dates","Approval Signpositions","Approval Types","Approval Signs"
							,"Assist Names","Assist Dates","Assist Signpositions","Assist Types","Assist Signs"
							,"Regnumber","Enforce Date","Zipcode","Address","Homepage","Telephone","Fax","E-mail","Publication","Reason","File Name"
							,"ArrivedDate",	"AcceptedDate","DistributedDate"};
					queryID="user.govDoc.selectGovApvReceiveExcel";
					headerNames=headeReceiverNames;
				}
				
				params.put("govDocs", selectParamsObj.optString("govDocs"));
				params.put("sendStatus", selectParamsObj.optString("sendStatus"));
				params.put("receiveStatus", selectParamsObj.optString("receiveStatus"));
				cList = approvalGovDocSvc.selectExcelData(params, queryID);
				
				CoviList excelArray = new CoviList();
				for (int i=0; i < cList.size(); i++) {
					CoviMap excelMap = cList.getMap(i);
					CoviMap newObject = new CoviMap();
					if (govDocs.equals("sendWait")) {
						newObject.put("PROCESS_SUBJECT", excelMap.getString("PROCESS_SUBJECT"));
						newObject.put("Institution", RedisDataUtil.getBaseConfig("APV_EXTERNAL_NAME"));
						newObject.put("Institution_Code", RedisDataUtil.getBaseConfig("GOV_INSTT_CODE"));
						newObject.put("Reciver", excelMap.getString("RECEIVER_NAME"));
						newObject.put("SendName", RedisDataUtil.getBaseConfig("GOV_SEND_NAME"));
						//approval
						String approvalContext = excelMap.getString("APPROVAL_CONTEXT");
	
						CoviMap approvalObject =  CoviMap.fromObject(approvalContext);
						StringBuilder appNames = new StringBuilder();
						StringBuilder appDates = new StringBuilder();
						StringBuilder appType = new StringBuilder();
						StringBuilder appPos = new StringBuilder();

						CoviList approvalSteps = new CoviList();
						CoviList personArr = new CoviList();
						String strAuthor = "";
						String strDept = "";
						String strAuthorDate = "";
						String strApprover = "";
						String strApproverDate = "";
						if (approvalObject.get("steps") != null) {
							if( approvalObject.getJSONObject("steps").getJSONObject("division").get("step") instanceof CoviList ){ 
								approvalSteps =  approvalObject.getJSONObject("steps").getJSONObject("division").getJSONArray("step");
								for (int j=0; j< approvalSteps.size(); j++) {
									CoviMap ouObject = (CoviMap) approvalSteps.get(j);
									Object personObj = ouObject.getJSONObject("ou").get("person");
									if (personObj instanceof CoviMap) {
										CoviMap jsonObj = (CoviMap) personObj;
										personArr.add(jsonObj);
									} else {
										personArr = (CoviList) personObj;
									}
									CoviMap person = (CoviMap) personArr.get(j);
									if (j == 0) {
										strAuthor = person.getString("name");
										strDept = ouObject.getJSONObject("ou").getString("name");
										strAuthorDate = person.getJSONObject("taskinfo").getString("datecompleted");
									}
									strApprover = person.getString("name");
									strApproverDate = person.getJSONObject("taskinfo").getString("datecompleted");
									
									if (j>0) {
										appNames.append(",");
										appDates.append(",");
										appType.append(",");
										appPos.append(",");
									}
									appNames.append(getMultiDic(person.getString("name"),0));
									appDates.append(person.getJSONObject("taskinfo").getString("datecompleted"));
									appType.append(getMultiDic(person.getString("position"),1));
									appPos.append(getMultiDic(person.getString("position"),1));
								}
							}
							else {
								CoviMap person =approvalObject.getJSONObject("steps").getJSONObject("division").getJSONObject("step");
								appNames.append(getMultiDic(person.getJSONObject("ou").getJSONObject("person").getString("name"),0));
								appDates.append(person.getJSONObject("ou").getJSONObject("person").getJSONObject("taskinfo").getString("datecompleted"));
								appType.append(getMultiDic(person.getJSONObject("ou").getJSONObject("person").getString("position"),1));
								appPos.append(getMultiDic(person.getJSONObject("ou").getJSONObject("person").getString("position"),1));
								approvalSteps.add(person);
							}
						}	

						newObject.put("Approval Names", appNames.toString());
						newObject.put("Approval Dates", appDates.toString());
						newObject.put("Approval Signpositions", appPos.toString());
						newObject.put("Approval Type", appType.toString());
						newObject.put("Approval Signs", appNames.toString());
						
						newObject.put("Regnumber", excelMap.getString("DOC_NUMBER"));
						newObject.put("Enforce Date", excelMap.getString("SEND_DATE"));
						
						//kicc 정보
						newObject.put("ZipCode", RedisDataUtil.getBaseConfig("GOV_Zipcode"));
						newObject.put("Address", RedisDataUtil.getBaseConfig("GOV_Addr"));
						newObject.put("HomePage", RedisDataUtil.getBaseConfig("GOV_HomeUrl"));
						newObject.put("TelePhone", RedisDataUtil.getBaseConfig("GOV_Tel"));
						newObject.put("Fax", RedisDataUtil.getBaseConfig("GOV_Fax"));
						newObject.put("Email", RedisDataUtil.getBaseConfig("GOV_Email"));
	
						//bodya
						String bodyContext = new String(Base64.decodeBase64(excelMap.getString("BODY_CONTEXT").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
						CoviMap bodyObject =  CoviMap.fromObject(bodyContext);
								 
						newObject.put("Publication", bodyObject.get("publicationValue"));
						newObject.put("Reason", bodyObject.optString("SecurityOption1", ""));
						//
						newObject.put("FileName", excelMap.getString("FILE_NAME"));
	
						newObject.put("Author", getMultiDic(strAuthor,0));
						newObject.put("Dept", getMultiDic(strDept,0));
						newObject.put("AuthorDate", strAuthorDate);
						newObject.put("Approver", getMultiDic(strApprover,0));
						newObject.put("ApproverDate", strApproverDate);
					}
					else {
						newObject.put("PROCESS_SUBJECT", excelMap.getString("PROCESS_SUBJECT"));
						newObject.put("Institution", excelMap.getString("PUBDOC_HEAD_ORGAN"));
						newObject.put("Institution_Code", excelMap.getString("SEND_ID"));
						newObject.put("Reciver", excelMap.getString("PUBDOC_HEAD_RECEIPT"));
						newObject.put("SendName", excelMap.getString("SEND_NAME"));
						//approval
						String approvalContext = excelMap.getString("APPROVAL_CONTEXT");
	
						CoviMap approvalObject =  CoviMap.fromObject(approvalContext);
						StringBuilder appNames = new StringBuilder();
						StringBuilder appDates = new StringBuilder();
						StringBuilder appType = new StringBuilder();
						StringBuilder appPos = new StringBuilder();

						if (approvalObject.get("approvalinfo") != null) {
							if( approvalObject.getJSONObject("approvalinfo").get("approval") instanceof CoviList ){
								CoviList approvalSteps=  approvalObject.getJSONObject("approvalinfo").getJSONArray("approval");
								CoviList personArr = new CoviList();
								for (int j=0; j< approvalSteps.size(); j++) {
									Object personObj = approvalSteps.getJSONObject(j);
									if (personObj instanceof CoviMap) {
										CoviMap jsonObj = (CoviMap) personObj;
										personArr.add(jsonObj);
									} else {
										personArr = (CoviList) personObj;
									}
									CoviMap person = (CoviMap) personArr.get(0);
									if (j>0) {
										appNames.append(",");
										appDates.append(",");
										appType.append(",");
										appPos.append(",");
									}
									appNames.append(person.getString("name"));
									appDates.append(person.getString("date"));
									appType.append(person.getString("type"));
									appPos.append(person.getString("signposition"));
								}
							}else {
								CoviMap person =approvalObject.getJSONObject("approvalinfo").getJSONObject("approval");
								appNames.append(person.getString("name"));
								appDates.append(person.getString("date"));
								appType.append(person.getString("type"));
								appPos.append(person.getString("signposition"));
							}
						}	
						newObject.put("Approval Names", appNames.toString());
						newObject.put("Approval Dates", appDates.toString());
						newObject.put("Approval Signpositions", appPos.toString());
						newObject.put("Approval Type", appType.toString());
						newObject.put("Approval Signs", appNames.toString());
						
						//접수대기함은 협조자 정보 출력
						String assNames = "";
						String assDates = "";
						String assType = "";
						String assPos = "";
						
						if (approvalObject.getJSONObject("approvalinfo").get("assist") != null) {
							CoviMap assist =  approvalObject.getJSONObject("approvalinfo").getJSONObject("assist");
							assNames= assist.getString("name");
							assDates= assist.getString("date");
							assPos = assist.getString("signposition");
							assType = assist.getString("type");
							assPos = assist.getString("signposition");
						}	

						newObject.put("Assist Names", assNames);
						newObject.put("Assist Dates", assDates);
						newObject.put("Assist Signpositions", assPos);
						newObject.put("Assist Type", assType);
						newObject.put("Assist Signs", assPos);

						newObject.put("Regnumber", excelMap.getString("DOC_NUMBER"));
						newObject.put("Enforce Date", convertDateFormat(excelMap.getString("ACCEPT_DATE")));
						
						//접수처 정보
						newObject.put("ZipCode", excelMap.getString("PUBDOC_FOOT_ZIPCODE"));
						newObject.put("Address", excelMap.getString("PUBDOC_FOOT_ADDR"));
						newObject.put("HomePage", excelMap.getString("PUBDOC_FOOT_HOMEURL"));
						newObject.put("TelePhone", excelMap.getString("PUBDOC_FOOT_TELEPHONE"));
						newObject.put("Fax", excelMap.getString("PUBDOC_FOOT_FAX"));
						newObject.put("Email", excelMap.getString("PUBDOC_FOOT_EMAIL"));
	
						//bodya
						String bodyContext = new String(Base64.decodeBase64(excelMap.getString("BODY_CONTEXT").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
						CoviMap bodyObject =  CoviMap.fromObject(bodyContext);
						newObject.put("Publication", bodyObject.get("publicationValue"));
						newObject.put("Reason", bodyObject.optString("SecurityOption1",""));
						//
						newObject.put("FileName", excelMap.getString("FILE_NAME"));
	
						
						newObject.put("ArrivedDate", convertDateFormat(excelMap.getString("ARRIVED_DATE")));
						newObject.put("AcceptDate", convertDateFormat(excelMap.getString("ACCEPT_DATE")));
						newObject.put("DistribDate", convertDateFormat(excelMap.getString("DISTRIB_DATE")));
					}
					excelArray.add(newObject);
				}
				viewParams.put("list", excelArray);
				viewParams.put("headerName", headerNames);
			}
			else {
				String headerName = request.getParameter("headername");
				headerName = URLDecoder.decode(headerName, "utf-8");
				String[] headerNames = headerName.split(";");

				for(Iterator<String> keys=selectParamsObj.keys();keys.hasNext();){
					String key = keys.next();
					params.put(key, selectParamsObj.getString(key));
				}
				headerKey = request.getParameter("headerkey");
				
				cList = approvalGovDocSvc.selectExcelData(params, queryID);
				viewParams.put("list", CoviSelectSet.coviSelectJSON(cList, headerKey));
				viewParams.put("headerName", headerNames);
			}	
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);

		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
	
	private String getMultiDic(String sVal, int idx) {
		String[] aMultiDic = sVal.split(";");

		int findIdx=0+idx;
		switch (SessionHelper.getSession("lang").toUpperCase())
		{
			case "KO": findIdx = 0; break;
			case "EN": findIdx = 1; break;
			case "JA": findIdx = 2; break;
			case "ZH": findIdx = 3; break;
			case "KO-KR": findIdx = 0; break;
			case "EN-US": findIdx = 1; break;
			case "JA-JP": findIdx = 2; break;
			case "ZH-CN": findIdx = 3; break;
			default: findIdx = 0; break;
		}
		findIdx+=idx;
		if (findIdx< aMultiDic.length) return aMultiDic[findIdx];
		else return sVal;
	}
	
	/**
	 * selectSendHistoryData : 발송이력 데이터
	 * @return mav
	 */
	@RequestMapping(value = "user/selectSendHistoryData.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap selectSendHistoryData(@RequestParam Map<String, String> paramMap) {
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();				
		try {		
			params.put("govDocs" 	,paramMap.get("govDocs"));
			params.put("docId" 		,paramMap.get("docId"));
			params.put("uniqueId" 	,paramMap.get("uniqueId"));
			params.put("sendID" 	,paramMap.get("sendID"));
			params.put("pageNo"		,paramMap.get("pageNo"));		
			params.put("pageSize"	,paramMap.get("pageSize"));
			
			resultList = approvalGovDocSvc.selectGovSendHistory(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok"); 
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다"); 
		
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * updateSeriesFunctionData - 기록물 분리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateRecordDocSeparation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateRecordDocSeparation(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("RecordClassNum", request.getParameter("recordclassnum"));
			params.put("RecordDocumentID", StringUtil.replaceNull(request.getParameter("selectedRecordDoc")).split(","));
			
			int result = approvalGovDocSvc.updateRecordDocSeparation(params);
			if (result > 0) {
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_37")); // 저장되었습니다.
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030")); // 오류가 발생했습니다.
				return returnList;
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	private String convertDateFormat(String s) 	{
		String s1 = null;
        if(s.trim().length() == 14) 
        {
            String s2 = s.substring(0, 8);
            s2 = s2.substring(0, 4) + "-" + s2.substring(4, 6) + "-" + s2.substring(6);
            String s3 = s.substring(8);
            s3 = s3.substring(0, 2) + ":" + s3.substring(2, 4) + ":" + s3.substring(4);
            s1 = s2 + " " + s3;
        } 
        else 
        {
            s1 = s;
        }
        return s1;
	}

	/**
	 * SenderMasterAddPopup - 발신처 관리 (팝업)
	 * @param locale
	 * @param model
	 * @return mav
	 * @throws Exception
	 */
	@RequestMapping(value = "user/SenderMasterAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getSenderMasterAddPopup(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/approval/SenderMasterAddPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}

	/**
	 * getSenderMasterListData - 발신처 관리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getSenderMasterListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSenderMasterListData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		String senderID = request.getParameter("senderID");
		String pageNo = request.getParameter("pageNo");
		String pageSize = request.getParameter("pageSize");
		
		try	{
			CoviMap params = new CoviMap();
			params.put("senderID", senderID == null ? "" : senderID);
			params.put("pageNo", pageNo == null ? 1 : Integer.parseInt(pageNo));
			params.put("pageSize", pageSize == null ? 1 : Integer.parseInt(pageSize));
			//params.put("pageNo", "1");
			//params.put("pageSize", "10");
			
			CoviMap resultList = approvalGovDocSvc.selectGovSenderMasterList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	@RequestMapping(value = "user/getSenderMasterData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSenderMasterData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("senderID", request.getParameter("senderID"));
			
			CoviList resultList = approvalGovDocSvc.selectGovSenderMaster(params);
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	@RequestMapping(value = "user/selectGovSenderMasterUpper.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectGovSenderMasterUpper(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("deptCode", request.getParameter("deptCode"));
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			
			CoviList resultList = approvalGovDocSvc.selectGovSenderMasterUpper(params);
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	@RequestMapping(value = "user/insertSenderMasterData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertSenderMasterData(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			
			CoviMap params = new CoviMap();
			params.put("COMPANYCODE", SessionHelper.getSession("DN_Code"));
			params.put("SENDER_TYPE", req.getParameter("SENDER_TYPE"));
			params.put("DEPT_NAME", req.getParameter("DEPT_NAME"));
			params.put("DEPT_CODE", req.getParameter("DEPT_CODE"));
			params.put("DISPLAY_NAME", req.getParameter("DISPLAY_NAME"));
			params.put("USAGE_STATE", req.getParameter("USAGE_STATE"));
			params.put("OUNAME", req.getParameter("OUNAME"));
			params.put("NAME", req.getParameter("NAME"));
			params.put("TEL", req.getParameter("TEL"));
			params.put("FAX", req.getParameter("FAX"));
			params.put("HOMEPAGE", req.getParameter("HOMEPAGE"));
			params.put("EMAIL", req.getParameter("EMAIL"));
			params.put("ZIP_CODE", req.getParameter("ZIP_CODE"));
			params.put("ADDRESS", req.getParameter("ADDRESS"));
			params.put("CAMPAIGN_T", req.getParameter("CAMPAIGN_T"));
			params.put("CAMPAIGN_F", req.getParameter("CAMPAIGN_F"));
			/*
			params.put("LOGO", req.getParameter("LOGO")); params.put("SYMBOL",
			req.getParameter("SYMBOL")); params.put("STAMP", req.getParameter("STAMP"));
			*/
			
			params.put("LOGO", Integer.parseInt(StringUtil.replaceNull(req.getParameter("LOGO"),"0")));
			params.put("SYMBOL", Integer.parseInt(StringUtil.replaceNull(req.getParameter("SYMBOL"),"0")));
			params.put("STAMP", Integer.parseInt(StringUtil.replaceNull(req.getParameter("STAMP"),"0")));
			
			int result = approvalGovDocSvc.insertSenderMasterData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "추가되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "user/modifySenderMasterData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap modifySenderMasterData(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("SENDER_TYPE", req.getParameter("SENDER_TYPE"));
			params.put("DEPT_NAME", req.getParameter("DEPT_NAME"));
			params.put("DEPT_CODE", req.getParameter("DEPT_CODE"));
			params.put("DISPLAY_NAME", req.getParameter("DISPLAY_NAME"));
			params.put("USAGE_STATE", req.getParameter("USAGE_STATE"));
			params.put("OUNAME", req.getParameter("OUNAME"));
			params.put("NAME", req.getParameter("NAME"));
			params.put("TEL", req.getParameter("TEL"));
			params.put("FAX", req.getParameter("FAX"));
			params.put("HOMEPAGE", req.getParameter("HOMEPAGE"));
			params.put("EMAIL", req.getParameter("EMAIL"));
			params.put("ZIP_CODE", req.getParameter("ZIP_CODE"));
			params.put("ADDRESS", req.getParameter("ADDRESS"));
			params.put("CAMPAIGN_T", req.getParameter("CAMPAIGN_T"));
			params.put("CAMPAIGN_F", req.getParameter("CAMPAIGN_F"));
			params.put("LOGO", Integer.parseInt(StringUtil.replaceNull(req.getParameter("LOGO"),"0")));
			params.put("SYMBOL", Integer.parseInt(StringUtil.replaceNull(req.getParameter("SYMBOL"),"0")));
			params.put("STAMP", Integer.parseInt(StringUtil.replaceNull(req.getParameter("STAMP"),"0")));
			params.put("senderID", req.getParameter("senderID"));
			
			int result = approvalGovDocSvc.updateSenderMasterData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "수정되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "user/deleteSenderMasterData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteSenderMasterData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			CoviMap params = new CoviMap();
			params.put("senderID", request.getParameter("senderID"));
			
			int result = approvalGovDocSvc.deleteSenderMasterData(params);
			
			if(result > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제되었습니다.");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_apv_030"));
				return returnList;
			}
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "user/insertImgUploadData.do", method = RequestMethod.POST)	
	public @ResponseBody CoviMap insertImgUploadData(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			MultipartFile file = request.getFile("MyFile");
			String serviceType = request.getParameter("serviceType");
			
			List<MultipartFile> list = new ArrayList<>();
			list.add(file);
			
			CoviList savedArray = fileUtilService.uploadToBack(null, list, null, serviceType, "0", "NONE", "0", false, false);
			if(savedArray.size() > 0) {
				CoviMap savedFile = savedArray.getJSONObject(0);
				int fileID = savedFile.getInt("FileID");
				
				returnList.put("fileID", fileID);
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "등록되었습니다");
			}
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/*
	@RequestMapping(value = "user/deleteImgUploadData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteImgUploadData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try	{
			String fileID = request.getParameter("fileID");
			fileUtilService.deleteFileByID(fileID, true);
			
			
			CoviMap params = new CoviMap();
			params.put("senderID", request.getParameter("senderID"));
			params.put("type", request.getParameter("type"));
			params.put("FileInfo", "");
			
			int result = approvalGovDocSvc.deleteImgUploadData(params);
			
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	*/
}
