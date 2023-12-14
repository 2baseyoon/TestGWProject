package egovframework.covision.coviflow.user.web;

import java.net.URLDecoder;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;
import egovframework.covision.coviflow.user.service.AuditDeptCompleteListSvc;
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;
import egovframework.covision.coviflow.user.service.UserBizDocListSvc;
import egovframework.covision.coviflow.user.service.AggregationSvc;

/**
 * @Class Name : CommonApprovalListCon.java
 * @Description : 결재함 공통 요청 처리 (Ex. 엑셀 저장, 검색 조건 Select Box 바인딩)
 * @ 2016.11.10 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class CommonApprovalListCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(CommonApprovalListCon.class);

	@Autowired
	private CommonApprovalListSvc commonApprovalListSvc;

	@Autowired
	private ApprovalListSvc approvalListSvc;

	@Autowired
	private DeptApprovalListSvc deptApprovalListSvc;

	@Autowired
	private JobFunctionListSvc jobFunctionListSvc;

	@Autowired
	private AuditDeptCompleteListSvc auditDeptCompleteListSvc;
	
	@Autowired
	private UserBizDocListSvc bizDocListSvc;
	
	@Autowired
	private AggregationSvc aggregationSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	/**
	 * getApprovalListSelectData : 결재함 공통 Select Box Data
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalListSelectData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalListSelectData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		//검색조건, 제목, 기안부서, 기안자
		//완료함일 경우 문서번호 추가
		//임시함일 경우 제목만

		//전체, 날짜별, 기안자별, 기안부서별, 양식별
		//임시함일 경우 날짜별, 양식별

		String filter = StringUtil.replaceNull(request.getParameter("filter"));
		String mode = StringUtil.replaceNull(request.getParameter("mode"));

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		String listData = "";

		try {
			if(filter.equals("selectSearchTypeAdmin")){ //관리자 - 사용자문서확인 - selectBox List 구하기
				CoviMap params = new CoviMap();
				params.put("DomainID", SessionHelper.getSession("DN_ID"));
				if(mode.equalsIgnoreCase("USER"))// 사용자문서보기일경우
					params.put("MemberOf", "ApprovalUser");
				else // 부서문서보기일경우
					params.put("MemberOf", "ApprovalDept");
					
				resultList = commonApprovalListSvc.selectAdminMnLIstData(params);
				returnList.put("list", resultList.get("list"));
			}

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
	 * approvalListExcelDownload - 결재함 공통 Excel 다운로드
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "user/approvalListExcelDownload.do" )
	public ModelAndView approvalListExcelDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();

		try {
			String queryID = StringUtil.replaceNull(request.getParameter("queryID"));
			String selectParams = StringUtil.replaceNull(request.getParameter("selectParams")).replace("&amp;", "&").replace("&quot;", "\"");
			CoviMap selectParamsObj = CoviMap.fromObject(selectParams);
			String title = StringUtil.replaceNull(request.getParameter("title"));
			String approvalListType = StringUtil.replaceNull(request.getParameter("approvalListType"));
			String headerKey = StringUtil.replaceNull(request.getParameter("headerkey"));
			String headerName = request.getParameter("headername");
			headerName = URLDecoder.decode(headerName, "utf-8");
			String bstored = StringUtil.replaceNull(request.getParameter("bstored"));
			String dbName = "COVI_APPROVAL4J_ARCHIVE";
			if(queryID.equalsIgnoreCase("selectTCInfoListExcel") || queryID.equalsIgnoreCase("selectDeptTCInfoListExcel"))
				dbName = "COVI_APPROVAL4J";
			if(bstored.equals("true"))
				dbName = "COVI_APPROVAL4J_STORE";
			
			CoviMap params = new CoviMap();
			String[] headerNames = headerName.split(";");

			for(Iterator<String> keys=selectParamsObj.keys();keys.hasNext();){
				String key = keys.next();
				params.put(key, selectParamsObj.getString(key));
			}
			String businessData1 = params.getString("businessData1");
			
			String sortKey = params.get("sortBy")==null?"":params.getString("sortBy").split(" ")[0];
			String sortDirec =  params.get("sortBy")==null?"": params.getString("sortBy").split(" ")[1];
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			//권한 부여여부 확인 필요
			String userID = params.getString("userID");
			String sessionUserID = SessionHelper.getSession("USERID").toLowerCase();
			String deptID 	= params.getString("deptID");
			String sessiondeptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String viewStartDate = "";
			String viewEndDate = "";
			boolean bhasAuth = false;
			
			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(approvalListType.equals("user") && (userID == null || !userID.toLowerCase().equals(sessionUserID))){
				if(title.equalsIgnoreCase("CompleteBoxList") || title.equalsIgnoreCase("TCInfoBoxList")){
					CoviMap paramsAuth = new CoviMap();

					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
		
					CoviMap resultListAuth = new CoviMap();
					resultListAuth = commonApprovalListSvc.getPersonDirectorOfPerson(paramsAuth);
					
					CoviList directPersonList = (CoviList)resultListAuth.get("list");
                    for(Object obj : directPersonList){
                        CoviMap directPerson = (CoviMap)obj;
                        if( directPerson.optString("UserCode").equalsIgnoreCase(userID)){
            				bhasAuth = true;
            				viewStartDate = directPerson.getString("ViewStartDate");
            				viewEndDate = directPerson.getString("ViewEndDate");
            				break;
                        }
                    }
				}
			} else if (approvalListType.equals("dept") && !deptID.equalsIgnoreCase(sessiondeptID)) {
				//인증처리
				//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_admindeptlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if((title.equalsIgnoreCase("DeptDraftCompleteBoxList")|| title.equalsIgnoreCase("DeptSenderCompleteBoxList")|| title.equalsIgnoreCase("DeptReceiveCompleteBoxList"))){
					CoviMap paramsAuth = new CoviMap();

					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("UnitCode", SessionHelper.getSession("GR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
		
					CoviList directPersonUnitList = deptApprovalListSvc.getPersonDirectorOfUnitData(paramsAuth);
				
                    for(Object obj : directPersonUnitList){
                        CoviMap directPersonUnit = (CoviMap)obj;
                        if(directPersonUnit.optString("UnitCode").equalsIgnoreCase(deptID)){
            				viewStartDate = directPersonUnit.getString("ViewStartDate");
            				viewEndDate = directPersonUnit.getString("ViewEndDate");
            				bhasAuth = true;
            				break;
                        }
                    }
				}
			}else{
				bhasAuth = true;
			}

			if(bhasAuth){
				//날짜, 그룹핑 날짜인 경우
				String startDate = params.get("startDate")==null?"":params.getString("startDate");
				String endDate = params.get("endDate")==null?"":params.getString("endDate");
				if(StringUtil.isNotEmpty(startDate)) {
					params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
					params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
				}
				else {
					params.put("startDate", ComUtils.ConvertDateToDash(startDate));
					params.put("endDate", ComUtils.ConvertDateToDash(endDate));
				}
				
				String searchGroupType = params.get("searchGroupType")==null?"":params.getString("searchGroupType");
				String searchGroupWord = params.get("searchGroupWord")==null?"":params.getString("searchGroupWord");
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				
				if(title.equalsIgnoreCase("CompleteBoxList") || title.equalsIgnoreCase("TCInfoBoxList") 
					|| title.equalsIgnoreCase("DeptDraftCompleteBoxList")|| title.equalsIgnoreCase("DeptSenderCompleteBoxList")|| title.equalsIgnoreCase("DeptReceiveCompleteBoxList")) {
					if(StringUtil.isNotEmpty(viewStartDate)) {
						params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
					}
					if(StringUtil.isNotEmpty(viewEndDate)) {
						params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
					}
				}
				
				params.put("entCode", SessionHelper.getSession("DN_Code"));
				params.put("isSaaS", isSaaS);
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = approvalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				//결재함에 따라 service를 다르게 호출
				if(approvalListType.equals("user")){
					String titleNm = (String) params.get("titleNm");
					String userNm = (String) params.get("userNm");
					params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
					params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
					params.put("DBName", dbName);
		
					viewParams = approvalListSvc.selectExcelData(params, queryID, headerKey);
				}else if(approvalListType.equals("dept")){
					if(queryID.equals("selectDeptReceiveListExcel") || queryID.equals("selectDeptReceiveProcessListExcel")){
						//부서함 - 수신함에서 제목 검색 후 엑셀 출력의 경우 Subject컬럼으로 조회조건이 들어가는 문제 수정
						if(params.get("searchType").equals("Subject")){
							params.put("searchType", "FormSubject");
						}
					}
					String titleNm = (String) params.get("titleNm");
					String userNm = (String) params.get("userNm");
					params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
					params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));				//viewParams = 부서 결재함 svc의 selectExcelData 호출. 매개변수는 위와 동일.
					params.put("DBName", dbName);
					// 20210126 이관함 > 부서 참조/회람함에서 엑셀 저장 시 구분이 합의로 나오는 부분 수정
					if(bstored.equals("true") && queryID.equals("selectDeptTCInfoListExcel")) {
						params.put("bstored", bstored);
						params.put("queryID", queryID);
					}
					
					viewParams = deptApprovalListSvc.selectExcelData(params, queryID, headerKey);
				}else if(approvalListType.equals("jobFunction")){
					viewParams = jobFunctionListSvc.selectExcelData(params, queryID, headerKey);
				}else if(approvalListType.equals("auditDept")){
					//viewParams = 감사문서함 svc의 selectExcelData 호출. 매개변수는 위와 동일.
					params.put("DBName", dbName);
					viewParams = auditDeptCompleteListSvc.selectExcelData(params, queryID, headerKey);
				}else if(approvalListType.equals("bizDoc")){
					viewParams = bizDocListSvc.selectExcelData(params, queryID, headerKey);
				}else if(approvalListType.equals("docType")){
					String titleNm = (String) params.get("titleNm");
					String userNm = (String) params.get("userNm");
					params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
					params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
					params.put("userID", SessionHelper.getSession("USERID"));
					params.put("deptID", SessionHelper.getSession("GR_Code"));
	
					viewParams = approvalListSvc.selectExcelData(params, queryID, headerKey);
				}else if (approvalListType.equals("simpleAggregation")) {
					params.put("userCode", SessionHelper.getSession("UR_Code"));
					params.put("groupCode", SessionHelper.getSession("GR_Code"));
					params.put("companyCode", SessionHelper.getSession("DN_Code"));
					viewParams = aggregationSvc.selectExcelData(params, headerKey);
				}

			}
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", title);

			mav = new ModelAndView(returnURL, viewParams);

		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}

	/**
	 * getApprovalSubMenuData - 결재함  리스트/그래픽 목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getDomainListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDomainListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			String processID = request.getParameter("ProcessID");

			CoviMap params = new CoviMap();

			params.put("ProcessID", processID);

			CoviMap resultList = commonApprovalListSvc.selectDomainListData(params);

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
	 * getApprovalSubMenuData - 결재함  첨부목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getCommFileListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCommFileListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			String formInstID = request.getParameter("FormInstID");
			String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String bstored = request.getParameter("bstored");

			CoviMap params = new CoviMap();

			params.put("FormInstID", formInstID);
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("lang", SessionHelper.getSession("lang"));
			
			if(bstored != null && bstored.equalsIgnoreCase("true")) // 이관문서
				params.put("ServiceType", "ApprovalMig");
			else
				params.put("ServiceType", "Approval");

			CoviMap resultList = commonApprovalListSvc.selectCommFileListData(params);

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
	 * getApprovalSubMenuData - 결재함 읽음확인 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getDocreadHistoryListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDocreadHistoryListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			String formInstID = request.getParameter("FormInstID");
			String processID = request.getParameter("ProcessID");
			String sortColumn = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];

			CoviMap params = new CoviMap();

			params.put("FormInstID", formInstID);
			params.put("ProcessID", processID);
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			
			CoviMap resultList = commonApprovalListSvc.selectDocreadHistoryListData(params);

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
	
	
	@RequestMapping(value = "user/selectSingleDocreadData.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectSingleDocreadData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");

			String processID = request.getParameter("ProcessID");
			String formInstID = request.getParameter("FormInstID");
			
			CoviMap params = new CoviMap();
			
			params.put("userID", userID);
			params.put("ProcessID", processID);
			params.put("FormInstID", formInstID);

			returnList.put("cnt", commonApprovalListSvc.selectSingleDocreadData(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");

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
