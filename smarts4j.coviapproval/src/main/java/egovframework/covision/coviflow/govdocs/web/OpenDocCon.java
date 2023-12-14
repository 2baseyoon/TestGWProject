package egovframework.covision.coviflow.govdocs.web;

import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;
import egovframework.covision.coviflow.govdocs.service.OpenDocSvc;
import egovframework.covision.coviflow.govdocs.util.AsyncTaskOpenDocConverter;
import egovframework.covision.coviflow.govdocs.util.AsyncTaskOpenDocSender;


@Controller
public class OpenDocCon {
	private Logger LOGGER = LogManager.getLogger(OpenDocCon.class);
	
	@Resource(name = "asyncTaskOpenDocConverter")
	private AsyncTaskOpenDocConverter asyncTaskOpenDocConverter;
	
	@Resource(name = "asyncTaskOpenDocSender")
	private AsyncTaskOpenDocSender asyncTaskOpenDocSender;

	@Autowired
	private OpenDocSvc openDocSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 파일변환중 오류발생시 재처리
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/reConvertDoc.do", method= {RequestMethod.POST})
	public @ResponseBody CoviMap reConvertDoc (HttpServletRequest request) throws Exception {
		CoviMap result = new CoviMap();
		try {
			String formInstID = request.getParameter("FormInstID");
			
			CoviMap spParams = new CoviMap();
			spParams.put("DOC_MNGE_CARD_ID", formInstID);
			spParams.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_CONVPROGRESS);
			//상태값 진행중으로 변경.
			openDocSvc.updateOpenDocStatus(spParams);
			
			//변환작업시작(백그라운드)
			spParams.put("formInstID", formInstID);
			asyncTaskOpenDocConverter.executeOpenDocConvert(spParams);
			result.put("status", Return.SUCCESS);
			return result;
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			result.put("status", Return.FAIL);
			result.put("message", npE.getLocalizedMessage());
			return result;
		} catch (Exception e) {
			LOGGER.error(e);
			result.put("status", Return.FAIL);
			result.put("message", e.getLocalizedMessage());
			return result;
		}
	}
	
	/**
	 * 일자별 수동연계
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/resend.do", method= {RequestMethod.POST})
	public @ResponseBody CoviMap reSend(HttpServletRequest request, @RequestParam Map<String, Object> params) throws Exception {
		CoviMap result = new CoviMap();
		try {
			String targetDate = (String)params.get("targetDate");
			CoviMap spParams = new CoviMap();
			spParams.put("targetDate", targetDate);
			 
			spParams.put("RST","PROGRESS");
			openDocSvc.updateOpenDocStatStatus(spParams);
			
			asyncTaskOpenDocSender.executeOpenDocSend(spParams);
			
			
			result.put("status", Return.SUCCESS);
			return result;
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			result.put("status", Return.FAIL);
			result.put("message", npE.getLocalizedMessage());
			return result;
		} catch (Exception e) {
			LOGGER.error(e);
			result.put("status", Return.FAIL);
			result.put("message", e.getLocalizedMessage());
			return result;
		}
	}
	
	/**
	 * 원문공개 마스터 데이터 조회.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/getOpenDocApvList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getOpenDocApvList (HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap 	returnList 	= new CoviMap();
		CoviMap params = new CoviMap();

		try {
			String sortKey = ComUtils.RemoveSQLInjection(paramMap.get("sortBy"),100);
			params.put("pageNo"			,paramMap.get("pageNo"));		
			params.put("pageSize"		,paramMap.get("pageSize"));
			params.put("sortBy"			,(sortKey != null) ? sortKey.split(" ")[0] : "");
			params.put("sortDirection"	,(sortKey != null) ? sortKey.split(" ")[1] : "");			
			params.put("searchType"		,paramMap.get("searchType"));			
			params.put("searchWord"		,paramMap.get("searchWord"));	
			params.put("startDate"		,paramMap.get("startDate"));
			params.put("endDate"		,paramMap.get("endDate"));
			resultList = openDocSvc.selectOpenDocList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");  
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		
		return returnList;
	}
	
	/**
	 * 원문공개 히스토리(문서별) 조회
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/getHistoryList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap selectOpenDocHistory(@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();				
		try {		
			String sortKey = ComUtils.RemoveSQLInjection(paramMap.get("sortBy"),100);
			params.put("pageNo"			,paramMap.get("pageNo"));		
			params.put("pageSize"		,paramMap.get("pageSize"));
			params.put("sortBy"			,(sortKey != null) ? sortKey.split(" ")[0] : "");
			params.put("sortDirection"	,(sortKey != null) ? sortKey.split(" ")[1] : "");			
			params.put("searchType"		,paramMap.get("searchType"));			
			params.put("searchWord"		,paramMap.get("searchWord"));	
			params.put("startDate"		,paramMap.get("startDate"));
			params.put("endDate"		,paramMap.get("endDate"));
			
			resultList = openDocSvc.selectGovHistory(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok"); 
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다"); 
		
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * History 삭제. 
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/delHistory.do", method= {RequestMethod.POST})
	public @ResponseBody CoviMap delHistory(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try {
			String chkHistoryIds = (String)paramMap.get("chkHistoryId");
			
			CoviMap params = new CoviMap();
			params.put("chkHistoryIds", StringUtils.split(chkHistoryIds, ","));
			openDocSvc.deleteHistory(params);
			
			result.put("status", Return.SUCCESS);
			return result;
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			result.put("status", Return.FAIL);
			result.put("message", npE.getLocalizedMessage());
			return result;
		} catch (Exception e) {
			LOGGER.error(e);
			result.put("status", Return.FAIL);
			result.put("message", e.getLocalizedMessage());
			return result;
		}
	}


	/**
	 * 원문공개 통계현황(일별) 조회
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/getStatisticsList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap selectOpenDocStatistics(@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap 	returnList 	= new CoviMap();
		CoviMap 	resultList 	= new CoviMap();
		CoviMap 	params 		= new CoviMap();				
		try {		
			String sortKey = ComUtils.RemoveSQLInjection(paramMap.get("sortBy"),100);
			params.put("pageNo"			,paramMap.get("pageNo"));		
			params.put("pageSize"		,paramMap.get("pageSize"));
			params.put("sortBy"			,(sortKey != null) ? sortKey.split(" ")[0] : "");
			params.put("sortDirection"	,(sortKey != null) ? sortKey.split(" ")[1] : "");			
			params.put("searchType"		,paramMap.get("searchType"));			
			params.put("searchWord"		,paramMap.get("searchWord"));	
			params.put("startDate"		,paramMap.get("startDate"));
			params.put("endDate"		,paramMap.get("endDate"));
			
			resultList = openDocSvc.selectGovStatistics(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok"); 
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다"); 
		
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	
	/**
	 * 원문공개 파일 목록 조회.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/opendoc/getOpenDocApvList.do", method = {RequestMethod.GET})
	public @ResponseBody CoviMap getOpenDocFileList (HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap 	returnList 	= new CoviMap();
		CoviMap params = new CoviMap();

		try {
			params.put("docID"		,paramMap.get("docID"));
			resultList = openDocSvc.selectOpenDocFileList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");  
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		
		return returnList;
	}
}
