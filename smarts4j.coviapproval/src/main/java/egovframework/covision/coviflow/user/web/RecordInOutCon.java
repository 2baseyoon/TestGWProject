package egovframework.covision.coviflow.user.web;

import java.io.IOException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.RecordInOutSvc;

@Controller
public class RecordInOutCon {
	
	private static final Logger LOGGER = LogManager.getLogger(RecordInOutCon.class);
	
	@Autowired
	private RecordInOutSvc recordInOutSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getGovDocInOutManager - 기록물철 문서 담당자 관리 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getGovRecordDocInOutManager.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGovRecordDocInOutManager(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultList = new CoviMap();
			CoviMap params = new CoviMap();
			String CompanyCode = SessionHelper.getSession("DN_Code");
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
				
			if(request.getParameter("pageSize") != null && request.getParameter("pageNo") != null){
				int pageSize = Integer.parseInt(request.getParameter("pageSize"));
				int pageNo = Integer.parseInt(request.getParameter("pageNo"));
				if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
					pageSize = Integer.parseInt(request.getParameter("pageSize"));
				}
				int start =  (pageNo - 1) * pageSize + 1;
				int end = start + pageSize - 1;
				int pageOffset	= (pageNo - 1) * pageSize;
				
				params.put("pageNo", pageNo);
				params.put("pageSize", pageSize);
				params.put("pageOffset", pageOffset);
				params.put("rowStart", start);
				params.put("rowEnd", end);
				
			}
			
			params.put("CompanyCode", CompanyCode);
			params.put("deptCode", request.getParameter("deptCode"));
			params.put("searchType", request.getParameter("searchType") == null ? "" : request.getParameter("searchType"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			resultList = recordInOutSvc.selectGovRecordDocInOutManager(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}	
	
	/**
	 * govDocInOutUserAdd : 기록물철 문서 담당자 관리 - 추가
	 * @return mav
	 */
	@RequestMapping(value = "user/govRecordDocInOutUserAdd.do", method = RequestMethod.GET)
	public ModelAndView govRecordDocInOutUserAdd(@RequestParam Map<String, String> paramMap) {
		String returnURL = "user/approval/RecordDocManagerAddPopup";
		CoviMap params = new CoviMap();		
		ModelAndView mav = new ModelAndView(returnURL);
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			params.put("CompanyCode", companyCode);
			params.put("mode", paramMap.get("mode") == null ? "" : paramMap.get("mode"));
			
			if( paramMap.get("deptCode") != null && paramMap.get("deptCode").length() > 0 ) {
				params.put("deptCode", paramMap.get("deptCode")); 
				mav.addObject("list", recordInOutSvc.selectGovRecordDocInOutManager(params).get("list"));
				mav.addObject("deptCode", paramMap.get("deptCode"));
			}
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
	
	/**
	 * insertGovDocInOutUser - 기록물철 문서 담당자 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertGovRecordDocInOutUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap insertGovRecordDocInOutUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();
		JSONParser 	parser 		= new JSONParser();
		CoviMap jsonObj = (CoviMap) parser.parse( paramMap.get("data"));		
		
		try {
			CoviMap 	dept 	= (CoviMap) jsonObj.get("dept");
			CoviList	user 	= (CoviList) jsonObj.get("user");
			String 	deptcode 	= paramMap.get("deptcode");
			
			params.put("mgrUnitCode", dept.get("code"));
			params.put("userList", user);			
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("deptcode", deptcode);
			
			recordInOutSvc.deleteGovRecordDocInOutUser(params);
			recordInOutSvc.insertGovRecordDocInOutUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다."); 
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * deleteGovDocInOutUser - 기록물철 문서 담당자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteGovRecordDocInOutUser.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap deleteGovRecordDocInOutUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();		
		CoviMap 	params 		= new CoviMap();
		JSONParser 	parser 		= new JSONParser();
		CoviMap jsonObj = (CoviMap) parser.parse( paramMap.get("data"));
				
		try {		
			CoviMap 	dept 	= (CoviMap) jsonObj.get("dept");
			CoviList	user 	= (CoviList) jsonObj.get("user");
			String 	deptcode 	= paramMap.get("deptcode");
			
			params.put("mgrUnitCode", dept.get("code"));
			params.put("userList", user);			
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("deptcode", deptcode);
			
			recordInOutSvc.deleteGovRecordDocInOutUser(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다."); 
		
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

}
