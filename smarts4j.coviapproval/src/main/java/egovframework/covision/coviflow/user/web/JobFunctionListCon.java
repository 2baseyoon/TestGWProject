package egovframework.covision.coviflow.user.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;



/**
 * @Class Name : JobFunctionListCon.java
 * @Description : 사용자 메뉴 > 담당업무함 요청 처리
 * @ 2016.11.03 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class JobFunctionListCon {

	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(JobFunctionListCon.class);

	@Autowired
	private JobFunctionListSvc jobFunctionListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");

	/**
	 * getJobFunctionCount : 사용자 메뉴 -담당업무함 : 해당 사용자에게 권한이 부여된 담당업무 개수 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionCount.do")
	public @ResponseBody CoviMap getJobFunctionCount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("JobFunctionType", request.getParameter("JobFunctionType"));
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);

			int cnt = jobFunctionListSvc.selectJobFunctionCount(params);

			returnList.put("cnt",cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}


	/**
	 * getJobFunctionListData : 사용자 메뉴 -담당업무함 : 해당 사용자에게 권한이 부여된 담당업무 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionListData.do")
	public @ResponseBody CoviMap getJobFunctionListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("JobFunctionType", request.getParameter("JobFunctionType"));
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);

			resultList = jobFunctionListSvc.selectJobFunctionListData(params);

			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}


	/**
	 * getJobFunctionApprovalListData : 사용자 메뉴 -담당업무함 : 담당업무의 미결함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionApprovalListData.do")
	public @ResponseBody CoviMap getJobFunctionApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String jobFunctionCode = StringUtil.replaceNull(request.getParameter("jobFunctionCode"));
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String userCode = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			
			if(jobFunctionCode.equals("")){ //jobFunctionCode 값이 없는경우 조회
				CoviList  result 	= new CoviList();
				result = (CoviList) jobFunctionListSvc.selectJobFunctionListData(params).get("list");
				CoviMap jsonobj = result.getJSONObject(0);
				jobFunctionCode = (String)jsonobj.get("JobFunctionCode");
				params.put("jobFunctionCode", jobFunctionCode);
			}else{
				params.put("jobFunctionCode", jobFunctionCode);
			}

			/*if(sortKey.equals("FormSubject")){
				sortKey = "Created";
			}*/

			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			resultList = jobFunctionListSvc.selectJobFunctionApprovalListData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}


	/**
	 * getJobFunctionProcessListData : 사용자 메뉴 -담당업무함 : 담당업무의 진행함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionProcessListData.do")
	public @ResponseBody CoviMap getJobFunctionProcessListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String jobFunctionCode = request.getParameter("jobFunctionCode");
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			// pageOffset : 가져올 페이지의 시작 번호--> 따로 계산
			/*int pageSize = 10;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}
			int pageOffset = (pageNo - 1) * pageSize;*/

			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}			
			
			/*if(sortKey.equals("FormSubject")){
				sortKey = "Created";
			}*/

			CoviMap params = new CoviMap();
			params.put("jobFunctionCode", jobFunctionCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			//params.put("pageOffset", pageOffset);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			resultList = jobFunctionListSvc.selectJobFunctionProcessListData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getJobFunctionCompleteListData : 사용자 메뉴 -담당업무함 : 담당업무의 완료함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionCompleteListData.do")
	public @ResponseBody CoviMap getJobFunctionCompleteListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			
			String jobFunctionCode = request.getParameter("jobFunctionCode");
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("jobFunctionCode", jobFunctionCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			resultList = jobFunctionListSvc.selectJobFunctionCompleteListData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getJobFunctionRejectListData : 사용자 메뉴 -담당업무함 : 담당업무의 반려함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getJobFunctionRejectListData.do")
	public @ResponseBody CoviMap getJobFunctionRejectListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String jobFunctionCode = request.getParameter("jobFunctionCode");
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			CoviMap params = new CoviMap();
			params.put("jobFunctionCode", jobFunctionCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtils.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			} else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtils.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			resultList = jobFunctionListSvc.selectJobFunctionRejectListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	@RequestMapping(value = "user/getJobFunctionGroupList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalGroupListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String jobFunctionCode = request.getParameter("jobFunctionCode");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String clickTab	= request.getParameter("clickTab");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String userCode = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();

			params.put("userCode", userCode);
			
			params.put("jobFunctionCode", jobFunctionCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtils.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("clickTab", clickTab);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtils.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			resultList = jobFunctionListSvc.selectJobFunctionGroupList(params);

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
	
}
