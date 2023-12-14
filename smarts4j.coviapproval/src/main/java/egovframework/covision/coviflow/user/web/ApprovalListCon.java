package egovframework.covision.coviflow.user.web;


import java.util.ArrayList;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;



@Controller
public class ApprovalListCon {
	@Autowired
	private ApprovalListSvc approvalListSvc;

	@Autowired
	private DeptApprovalListSvc deptApprovalListSvc;
	
	@Autowired
	private CommonApprovalListSvc commonApprovalListSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getApprovalDetailList - 개인결재함 하위메뉴별 리스트 상세  조회
	 */
	@RequestMapping(value = "user/ApprovalDetailList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getApprovalDetailList(Locale locale, Model model)
	{
		String returnURL = "user/approval/ApprovalDetailList";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalIframeList - 개인결재함 하위메뉴별 양식 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/ApprovalIframeList.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody ModelAndView getApprovalIframeList(Locale locale, Model model, HttpServletRequest request)
	{
		String returnURL = "user/approval/ApprovalIframeList";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getHandoverPopup - 임시함 인계 팝업 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/HandoverPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getHandoverPopup(Locale locale, Model model, HttpServletRequest request)
	{
		String returnURL = "user/approval/HandoverPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalSubMenuData - 개인결재함 하위메뉴 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalSubMenuData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalSubMenuData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("MemberOf", "ApprovalUser");

			CoviMap resultList = commonApprovalListSvc.selectAdminMnLIstData(params);

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
	 * getApprovalListData - 개인결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalListData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		boolean bhasAuth = false;
		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String sessionUserID = SessionHelper.getSession("USERID").toLowerCase();
			String viewStartDate = "";
			String viewEndDate = "";
			
			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(userID == null || !userID.toLowerCase().equals(sessionUserID)){
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_adminuserlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if(StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("complete") || StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("tcinfo")){
					CoviMap paramsAuth = new CoviMap();

					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));

					CoviMap resultListAuth = commonApprovalListSvc.getPersonDirectorOfPerson(paramsAuth);
					
					CoviList directPersonList = (CoviList)resultListAuth.get("list");
                    for(Object obj : directPersonList){
                        CoviMap directPerson = (CoviMap)obj;
                        if( directPerson.optString("UserCode").equalsIgnoreCase(userID.toLowerCase())){
            				bhasAuth = true;
                            viewStartDate = directPerson.getString("ViewStartDate");
                            viewEndDate = directPerson.getString("ViewEndDate");
            				break;
                        }
                    }
				}
			}else{
				bhasAuth = true;
			}
			
			if(bhasAuth){
				String searchType = request.getParameter("searchType");
				String searchWord = request.getParameter("searchWord");
				String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
				String searchGroupWord = request.getParameter("searchGroupWord");
				String formSubject = request.getParameter("formSubject");
				String initiatorName = request.getParameter("initiatorName");
				String initiatorUnitName = request.getParameter("initiatorUnitName");
				String formName = request.getParameter("formName");
				String docNo = request.getParameter("docNo");
				String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
				String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
				String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
				String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
				String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-사용자문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
				String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				String submode = (bstored.equals("true") && request.getParameter("submode") != null && StringUtil.replaceNull(request.getParameter("submode")).equals("Admin") ? "ADMIN" : ""); // 20210126 이관함 > 관리자문서함
				if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO"))
					dbName = "COVI_APPROVAL4J";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
				
				String pageSizeStr = request.getParameter("pageSize");
				int pageSize = 1;
				int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
				if (pageSizeStr != null && pageSizeStr.length() > 0){
					pageSize = Integer.parseInt(pageSizeStr);	
				}
				
				String companyCode = request.getParameter("companyCode");
				String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
				
				CoviMap resultList = null;
				CoviMap page = null;
				if(userID != null && !userID.equals("")){
					CoviMap params = new CoviMap();
		
					params.put("userID", userID);
					params.put("searchType", searchType);
					params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
					params.put("searchGroupType", searchGroupType);
					
					if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
						params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
					}
					else {
						params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
					}
					
					params.put("formSubject", ComUtils.RemoveSQLInjection(formSubject, 100));
					params.put("initiatorName", ComUtils.RemoveSQLInjection(initiatorName, 100));
					params.put("initiatorUnitName", ComUtils.RemoveSQLInjection(initiatorUnitName, 100));
					params.put("formName", ComUtils.RemoveSQLInjection(formName, 100));
					params.put("docNo", ComUtils.RemoveSQLInjection(docNo, 100));
					
					if(StringUtil.isNotEmpty(startDate)) {
						params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
						params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
					}
					else {
						params.put("startDate", ComUtils.ConvertDateToDash(startDate));
						params.put("endDate", ComUtils.ConvertDateToDash(endDate));
					}
					params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
					params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
					params.put("mode", mode);
					params.put("adminYn", adminYn);
					params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
					params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
					params.put("pageSize", pageSize);
					params.put("pageNo", pageNo);
					params.put("DBName", dbName);
					
					// 20210126 이관함 관리자 추가
					params.put("submode", submode);
					
					// 통합결재 조건 추가
					String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
					if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
						params = approvalListSvc.getApprovalListCode(params, businessData1);	
					} else {
						params.put("isApprovalList", "X");
					}
					
					// 겸직자 개인함 법인별 보기 옵션 추가 사용 시 파라미터 추가
					String useIsUseAddJobApprovalList = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList")) ? RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList") : "N"; // 개인함겸직자법이별보기 사용여부(기본값: N)
					if(useIsUseAddJobApprovalList.equalsIgnoreCase("Y")) {
						params.put("companyCode",companyCode);
					}else {
						params.put("companyCode","");
					}

					if(StringUtil.isNotEmpty(viewStartDate)) {
						params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
					}
					if(StringUtil.isNotEmpty(viewEndDate)) {
						params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
					}
					
					// [211021 add]문서연결 창 조건 추가
					params.put("requestType",requestType);
					
					resultList = approvalListSvc.selectApprovalList(params);
					page = resultList.getJSONObject("page");
				}else{
					resultList = new CoviMap();
					page = new CoviMap();
					
					resultList.put("list", new CoviList());
					resultList.put("cnt", 0);
					
					page.put("pageCount", 1);
					page.put("listCount", 0);
				}

				//draftkey 추가
				AES aes = new AES("", "N");
				CoviList resultListArr = (CoviList)resultList.get("list");
                for(Object obj : resultListArr){
                    CoviMap resultListobj = (CoviMap)obj;
                    if(resultListobj.has("FormInstID") && resultListobj.has("WorkItemID") && resultListobj.has("ProcessID") && resultListobj.has("TaskID")){
                    	String draftkey = resultListobj.getString("FormInstID") +  "@" + resultListobj.getString("WorkItemID") +  "@" + resultListobj.getString("ProcessID") +  "@" + resultListobj.getString("TaskID");
                    	resultListobj.put("formDraftkey", aes.encrypt(draftkey));
                    }
                }
				
				returnList.put("page", page);
				returnList.put("list", resultList.get("list"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");

			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_DoNotPermissionViewList"));
			}
				
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
	 * 홈 화면 미결함, 진행함, 완료함, 반려함 조회 (프로필 사진 조회로 분리)
	 * - UX/UI 개편으로 미결,회람,참조목록으로 분리.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getHomeApprovalListData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getHomeApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = null;
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			
			if(userID != null && !userID.equals("")){
				CoviMap params = new CoviMap(paramMap);
	
				params.put("userID", userID);
				
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = approvalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
	
				resultList = approvalListSvc.selectHomeApprovalList(params);
				
				// 건수 재조회
				CoviMap cntResult = approvalListSvc.selectHomeApprovalListCnt(params);
				returnList.put("cntinfo", cntResult);
			}else{
				resultList = new CoviMap();
				resultList.put("list", new CoviList());
				resultList.put("cnt", 0);
			}
			
			returnList.put("list", resultList);
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
	 * 홈 화면 지연문서 건수 메시지 표시
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getHomeApprovalDelayCnt.do",  method = {RequestMethod.POST})
	public @ResponseBody CoviMap getHomeApprovalDelayCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = null;
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			
			if(userID != null && !userID.equals("")){
				CoviMap params = new CoviMap(paramMap);
	
				String delayPeriodDay = RedisDataUtil.getBaseConfig("DelayPeriodDay");
				params.put("userID", userID);
				params.put("DelayPeriodDay", delayPeriodDay);
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = approvalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
	
				resultList = approvalListSvc.getHomeApprovalDelayCnt(params);
				
				returnList.put("DelayPeriodDay", delayPeriodDay);
				returnList.put("cnt", resultList.getString("Cnt"));
			}else{
				returnList.put("list", new CoviList());
				returnList.put("DelayPeriodDay", 0);
			}
			
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
	 * getApprovalGroupListData - 개인결재함 하위메뉴별 그룹별 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalGroupListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalGroupListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String sessionUserID = SessionHelper.getSession("USERID").toLowerCase();
			String viewStartDate = "";
			String viewEndDate = "";
			boolean bhasAuth = false;
			
			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(userID == null || !userID.toLowerCase().equals(sessionUserID)){
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_adminuserlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if(StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("complete") || StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("tcinfo")){
					CoviMap paramsAuth = new CoviMap();
	
					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
			
					CoviMap resultListAuth = commonApprovalListSvc.getPersonDirectorOfPerson(paramsAuth);
					
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
			}else{
				bhasAuth = true;
			}
	
			if(bhasAuth){
				String searchType = request.getParameter("searchType");
				String searchWord = request.getParameter("searchWord");
				String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
				String searchGroupWord = request.getParameter("searchGroupWord");
				String formSubject = request.getParameter("formSubject");
				String initiatorName = request.getParameter("initiatorName");
				String initiatorUnitName = request.getParameter("initiatorUnitName");
				String formName = request.getParameter("formName");
				String docNo = request.getParameter("docNo");
				String startDate = request.getParameter("startDate");
				String endDate 	= request.getParameter("endDate");
				String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				String submode = (bstored.equals("true") && request.getParameter("submode") != null && request.getParameter("submode").equals("Admin") ? "ADMIN" : ""); // 20210126 이관함 > 관리자문서함
				if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO"))
					dbName = "COVI_APPROVAL4J";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
				String companyCode =  request.getParameter("companyCode");
				
				CoviMap params = new CoviMap();
	
				params.put("userID", userID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(searchGroupWord));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				
				params.put("formSubject", ComUtils.RemoveSQLInjection(formSubject, 100));
				params.put("initiatorName", ComUtils.RemoveSQLInjection(initiatorName, 100));
				params.put("initiatorUnitName", ComUtils.RemoveSQLInjection(initiatorUnitName, 100));
				params.put("formName", ComUtils.RemoveSQLInjection(formName, 100));
				params.put("docNo", ComUtils.RemoveSQLInjection(docNo, 100));
				
				params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
				params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
				if(StringUtil.isNotEmpty(startDate)) {
					params.put("startDate", ComUtils.TransServerTime(startDate));
					params.put("endDate", ComUtils.TransServerTime(endDate));
				}
				else {
					params.put("startDate", ComUtils.ConvertDateToDash(startDate));
					params.put("endDate", ComUtils.ConvertDateToDash(endDate));
				}
				params.put("mode", mode);
				params.put("DBName", dbName);
				params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
				
				// 20210126 이관함 관리자 추가
				params.put("submode", submode);
				
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = approvalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				// 겸직자 개인함 법인별 보기 옵션 추가 사용 시 파라미터 추가
				String useIsUseAddJobApprovalList = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList")) ? RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList") : "N"; // 개인함겸직자법이별보기 사용여부(기본값: N)
				if(useIsUseAddJobApprovalList.equalsIgnoreCase("Y")) {
					params.put("companyCode",companyCode);
				}else {
					params.put("companyCode","");
				}			
				
				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(viewStartDate));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(viewEndDate));
				}
				
				CoviMap resultList = approvalListSvc.selectApprovalGroupList(params);
	
				returnList.put("list", resultList.get("list"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_DoNotPermissionViewList"));
			}
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
	 * getApprovalGroupListData - 개인결재함 임시함/반려함 삭제처리
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "deleteTempSaveList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteschemainfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			//현재 사용자 ID
			String   userID 			= SessionHelper.getSession("USERID");
			String   type 				= StringUtil.replaceNull(request.getParameter("type"));
			String   formInstIdTemp		= null;
			String   formInstBoxIdTemp	= null;
			String   workItemIdTemp		= null;
			String[] formInstId			= null;
			String[] formInstBoxId		= null;
			String[] workItemId			= null;

			if(type.equals("TempSave")){ //임시함삭제세팅
				formInstIdTemp 		= request.getParameter("FormInstId");
				formInstBoxIdTemp 	= request.getParameter("FormInstBoxId");
				formInstId 			= StringUtil.replaceNull(formInstIdTemp).split(",");
				formInstBoxId 		= StringUtil.replaceNull(formInstBoxIdTemp).split(",");
			}else{ //반려함삭제세팅
				workItemIdTemp		= request.getParameter("WorkItemId");
				workItemId			= StringUtil.replaceNull(workItemIdTemp).split(",");
			}
			
			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("FormInstId",formInstId);
			params.put("FormInstBoxId",formInstBoxId);
			params.put("WorkItemId",workItemId);

			int result;

			if(type.equals("TempSave")){ //임시함은 삭제
				result = approvalListSvc.delete(params);
			}else{ //반려함은 업데이트
				result = approvalListSvc.update(params);
			}

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getApprovalCntAll : 결재함 전체 카운트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalCntAll.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectApprovalCntAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList cntList = new CoviList();
		try{
			CoviMap params = new CoviMap();
			
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String listType = StringUtil.replaceNull(request.getParameter("listType"));
			String boxList = StringUtil.replaceNull(request.getParameter("boxList"));
			
			params.put("userID", userID);
			params.put("UserCode", userID);
			params.put("deptID", deptID);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			String configCnt = RedisDataUtil.getBaseConfig("ApprovalBoxListCnt");
			if(!boxList.equals("")) configCnt = boxList;
			else if(configCnt.equals("")) {
				switch(listType) {
					case "USER": configCnt = "U_Approval;U_Process"; break;
					case "DEPT": configCnt = "D_Receive;D_DeptProcess"; break;
					default: configCnt = "U_Approval;U_Process;D_Receive;D_DeptProcess"; break;
				}
			}
			//String[] configUser = Arrays.stream(configCnt.split(";")).filter(item -> item.startsWith("U_")).toArray(String[]::new);
			for(String item : configCnt.split(";")) {
				if(item.startsWith("U_") && !listType.equalsIgnoreCase("DEPT")) {
					CoviMap tmpCnt = new CoviMap();
					tmpCnt.put("type", item);
					switch(item) {
						case "U_Approval":
							tmpCnt.put("cnt", approvalListSvc.selectApprovalCnt(params));
							break;
						case "U_Process":
							tmpCnt.put("cnt", approvalListSvc.selectProcessCnt(params));
							break;
						case "U_TCInfo":
							tmpCnt.put("cnt", approvalListSvc.selectTCInfoNotDocReadCnt(params));
							break;
						default:
							params.put("listGubun", item);
							tmpCnt.put("cnt", approvalListSvc.selectUserBoxListCnt(params));
							break;
					}
					cntList.add(tmpCnt);
				}else if(item.startsWith("D_") && !listType.equalsIgnoreCase("USER")) {
					CoviMap tmpCnt = new CoviMap();
					tmpCnt.put("type", item);
					switch(item) {
						case "D_Receive":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptReceptionCnt(params));
							break;
						case "D_DeptProcess":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptProcessCnt(params));
							break;
						case "D_DeptTCInfo":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptTCInfoNotDocReadCnt(params));
							break;
						default:
							params.put("listGubun", item);
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptBoxListCnt(params));
							break;
					}
					cntList.add(tmpCnt);
				}
			}
			
			returnList.put("list", cntList);
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
	
	/**
	 * getApprovalCnt : 개인결재함 - 미결함 전체 개수 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectApprovalCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			CoviMap params = new CoviMap();

			params.put("userID", userID);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", approvalListSvc.selectApprovalCnt(params));
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
	
	
	/**
	 * getProcessCnt : 개인결재함 - 진행함 전체 개수 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getProcessCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectProcessCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			CoviMap params = new CoviMap();
			
			params.put("userID", userID);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", approvalListSvc.selectProcessCnt(params));
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
	
	/**
	 * getPreApprovalCnt : 개인결재함 - 함별 전체 개수 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserBoxListCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectUserBoxListCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("listGubun", request.getParameter("listGubun"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", approvalListSvc.selectUserBoxListCnt(params));
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
	
	
	/**
	 * getApprovalNotDocReadCnt : 개인결재함 - 미결함/읽지않는개수조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getApprovalNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectApprovalNotDocReadCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}			

			returnList.put("cnt", approvalListSvc.selectApprovalNotDocReadCnt(params));
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

	/**
	 * getProcessNotDocReadCnt : 개인결재함 - 진행함/읽지않는개수조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getProcessNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectProcessNotDocReadCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", approvalListSvc.selectProcessNotDocReadCnt(params));
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

	/**
	 * getTCInfoNotDocReadCnt : 개인결재함 - 참조회람함/읽지않는개수조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getTCInfoNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectTCInfoNotDocReadCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {

			String userID = SessionHelper.getSession("USERID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			CoviMap params = new CoviMap();

			params.put("userID", userID);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			returnList.put("cnt", approvalListSvc.selectTCInfoNotDocReadCnt(params));
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
	
	@RequestMapping(value = "user/selectApprovalTCInfoSingleDocRead.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectApprovalTCInfoSingleDocRead(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID 			= SessionHelper.getSession("USERID");
			String processID = request.getParameter("ProcessID");
			String formInstID = request.getParameter("FormInstID");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			CoviMap params = new CoviMap();
			
			params.put("userID", userID);
			params.put("ProcessID", processID);
			params.put("FormInstID", formInstID);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			returnList.put("cnt", approvalListSvc.selectApprovalTCInfoSingleDocRead(params));
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
	
	/**
	 * getPersonDirectorOfPerson : 개인결재함- 특정사용자 부서조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getPersonDirectorOfPerson.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorOfPerson(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");

			CoviMap params = new CoviMap();

			params.put("UserCode", userCode);
			params.put("EntCode", entCode);

			CoviMap resultList = commonApprovalListSvc.getPersonDirectorOfPerson(params);

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
	
	// 미결함, 참조/회람함 읽음 처리
	@RequestMapping(value = "user/docRead.do")
	public @ResponseBody CoviMap docReadProcess(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=true) String[] paramArr) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String userId = SessionHelper.getSession("USERID");
			String userName = SessionHelper.getSession("USERNAME");
			String jobTitle = SessionHelper.getSession("UR_JobTitleCode");
			String jobLevel = SessionHelper.getSession("UR_JobLevelCode");
			String adminYn = "N";
			
			ArrayList<CoviMap> paramList = new ArrayList<>();
			CoviMap tempMap = null;
			for (String param : paramArr) {
				String[] tempArr = param.split("\\|");
				tempMap = new CoviMap();
				tempMap.put("UserID", userId);
				tempMap.put("UserName", userName);
				tempMap.put("JobTitle", jobTitle);
				tempMap.put("JobLevel", jobLevel);
				tempMap.put("AdminYN", adminYn);
				tempMap.put("ReceiptID", userId);
				tempMap.put("ProcessID", tempArr[0]);
				tempMap.put("FormInstID", tempArr[1]);
				tempMap.put("Kind", tempArr[2]);
				paramList.add(tempMap);
			}
			
			CoviMap params = new CoviMap();
			params.put("paramList", paramList);
			
			int cnt = 0;
			String mode = StringUtil.replaceNull(request.getParameter("mode"));		// Approval 미결함, TCInfo 참조/회람함
			if (mode.equalsIgnoreCase("APPROVAL")) {
				cnt = approvalListSvc.insertDocReadHistory(params);
			} else if (mode.equalsIgnoreCase("TCINFO")) {
				cnt = approvalListSvc.updateTCInfoDocReadHistory(params);
			}
			
			returnList.put("cnt", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
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
	 * user/getProfileImagePath.do
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getProfileImagePath.do")
	public @ResponseBody CoviMap getProfileImagePath(HttpServletRequest request,
			@RequestParam(value = "UserCodes", required = true, defaultValue = "") String userCodes) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if(userCodes != null && !userCodes.equals("")){
				params.put("UserCodes", userCodes.split(";"));
				
				returnList.put("data", approvalListSvc.selectProfileImagePath(params));
			}
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
	
	/**
	 * updateHandoverUser.do
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateHandoverUser.do")
	public @ResponseBody CoviMap updateHandoverUser(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String[] formInstId 		= StringUtil.replaceNull(request.getParameter("FormInstId")).split(",");
			String[] formInstBoxId 		= StringUtil.replaceNull(request.getParameter("FormInstBoxId")).split(",");
			
			params.put("FormInstId", formInstId);
			params.put("FormInstBoxId", formInstBoxId);
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("SessionUserCode", SessionHelper.getSession("USERID"));
			
			approvalListSvc.updateHandoverUser(params);
			
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "인계되었습니다");
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
	 * 결재완료 문서 >> 협업 타스크로 등록.
	 * @param request
	 * @param response
	 * @return 
	 * @return
	 */
	@RequestMapping(value = "user/transferCollabLink.do", method = RequestMethod.POST)
	public @ResponseBody ModelAndView transferCollabLink(HttpServletRequest request, HttpServletResponse response, 
			@RequestParam Map<String, String> paramMap) {

		String returnURL = "user/approval/CollabLinkProcess";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 결재완료 문서 >> 협업 타스크로 등록.
	 * @param request
	 * @param response
	 * @return 
	 * @return
	 */
	@RequestMapping(value = "user/transferPdfCollab.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap transferPdfCollab(HttpServletRequest request, HttpServletResponse response, 
			@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			returnList = approvalListSvc.transferPdfCollab(paramMap);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "등록되었습니다");
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
	 * getApprovalListData - 개인결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDocTypeListData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getDocTypeListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try	{
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("GR_Code");

			String docClassID = request.getParameter("docClassID");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap resultList = null;
			CoviMap page = null;
			
			if(docClassID != null && !docClassID.equals("")){
				CoviMap params = new CoviMap();
	
				params.put("userID", userID);
				params.put("deptID", deptID);
				params.put("docClassID", docClassID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
				params.put("pageSize", pageSize);
				params.put("pageNo", pageNo);
				
				resultList = approvalListSvc.selectDocTypeList(params);
				page = resultList.getJSONObject("page");
			} else {
				resultList = new CoviMap();
				resultList.put("list", new CoviList());
				resultList.put("cnt", 0);
				
				page = new CoviMap();
				page.put("pageCount", 1);
				page.put("listCount", 0);
			}
			
			returnList.put("page", page);
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
	 * 홈 대시보드의 결재목록 탭순서 저장
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateHomeListTabSort.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateHomeListTabSort(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			approvalListSvc.updateHomeListTabSort(params);
			
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
	
	/**
	 * 홈 대시보드의 섹션 순서 저장
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateHomeSectionSort.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateHomeSectionSort(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			
			approvalListSvc.updateHomeSectionSort(params);
			
			
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