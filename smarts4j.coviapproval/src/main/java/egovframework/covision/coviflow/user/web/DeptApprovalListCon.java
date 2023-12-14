package egovframework.covision.coviflow.user.web;


import java.util.ArrayList;
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
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;



@Controller
public class DeptApprovalListCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(DeptApprovalListCon.class);

	@Autowired
	private DeptApprovalListSvc deptApprovalListSvc;

	@Autowired
	private CommonApprovalListSvc commonApprovalListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getApprovalListData - 부서결재함 하위메뉴별 리스트 상세  조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/DeptApprovalDetailList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getUserFolderListData(Locale locale, Model model)
	{
		String returnURL = "user/DeptApprovalDetailList";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalListData - 부서결재함 하위메뉴별 양식 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/DeptApprovalIframeList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getApprovalIframeList(Locale locale, Model model, HttpServletRequest request)
	{
		String returnURL = "user/DeptApprovalIframeList";
		return new ModelAndView(returnURL);
	}

	/**
	 * getDeptApprovalSubMenuData - 부서결재함 하위메뉴 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptApprovalSubMenuData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptApprovalSubMenuData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("MemberOf", "ApprovalDept");

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
	 * getApprovalListData - 부서결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptApprovalListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		boolean bhasAuth = false;
		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String deptID 	= StringUtil.replaceNull(request.getParameter("deptID"));
			String sessiondeptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String viewStartDate = "";
			String viewEndDate = "";

			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(!deptID.equalsIgnoreCase(sessiondeptID)){
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_admindeptlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if(!StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("receive")){
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
				String searchType = StringUtil.replaceNull(request.getParameter("searchType"),"Subject");
				String searchWord = request.getParameter("searchWord");
				String encodeSearchWord = request.getParameter("encodeSearchWord");
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
				String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-부서문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
				String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				if(mode.equalsIgnoreCase("DEPTTCINFO"))
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
				
				String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
				
				CoviMap params = new CoviMap();
				if(searchType.equals("Subject")){
					searchType = "FormSubject";
				}
	
				params.put("deptID", deptID);
				params.put("userID", userID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
				params.put("searchGroupType", searchGroupType);
				params.put("encodeSearchWord", encodeSearchWord);
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
				
				if(StringUtil.isBlank(startDate)) {
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
				
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}

				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
				}

				// [211021 add]문서연결 창 조건 추가
				params.put("requestType",requestType);
				
				CoviMap resultList = deptApprovalListSvc.selectDeptApprovalList(params);
	
				returnList.put("page", resultList.get("page"));
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
	 * getApprovalGroupListData - 부서결재함 하위메뉴별 그룹별 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptApprovalGroupListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalGroupListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		boolean bhasAuth = false;		
		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String deptID 	= StringUtil.replaceNull(request.getParameter("deptID"));
			String sessiondeptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String viewStartDate = "";
			String viewEndDate = "";

			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(!deptID.equalsIgnoreCase(sessiondeptID)){
				//관리자
				String requestURI = request.getHeader("referer").toLowerCase();
				if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_admindeptlist.do") > -1){
					bhasAuth = true;
				//권한부여 확인
				}else if(!StringUtil.replaceNull(request.getParameter("mode")).equalsIgnoreCase("receive")){
					CoviMap paramsAuth = new CoviMap();
			
					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("UnitCode", SessionHelper.getSession("GR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
			
					CoviList directPersonUnitList = deptApprovalListSvc.getPersonDirectorOfUnitData(paramsAuth);
			
                    for(Object obj : directPersonUnitList){
                        CoviMap directPersonUnit = (CoviMap)obj;
                        if( directPersonUnit.optString("UnitCode").equalsIgnoreCase(deptID)){
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
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
				String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				if(mode.equalsIgnoreCase("DEPTTCINFO"))
					dbName = "COVI_APPROVAL4J";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));				
				CoviMap params = new CoviMap();	
				params.put("deptID", deptID);
				params.put("userID", userID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(searchGroupWord));
				} else {
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
				
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}

				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(viewStartDate));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(viewEndDate));
				}

				CoviMap resultList = deptApprovalListSvc.selectDeptApprovalGroupList(params);
	
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
	 * getProcessNotDocReadCnt : 부서결재함 - 수신함/읽지않는개수조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptProcessNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptProcessNotDocReadCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("ApprovalParentGR_Code");
			
			CoviMap params = new CoviMap();

			params.put("deptID", deptID);
			params.put("userID", userID);

			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptProcessNotDocReadCnt(params));
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
	 * getTCInfoNotDocReadCnt : 부서결재함 - 참조회람함/읽지않는개수조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getDeptTCInfoNotDocReadCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptTCInfoNotDocReadCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("ApprovalParentGR_Code");
			
			CoviMap params = new CoviMap();

			params.put("deptID", deptID);
			params.put("userID", userID);

			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptTCInfoNotDocReadCnt(params));
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
	
	@RequestMapping(value = "user/selectDeptTCInfoSingleDocRead.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptTCInfoSingleDocRead(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("DEPTID");

			String processID = request.getParameter("ProcessID");
			String formInstID = request.getParameter("FormInstID");
			
			CoviMap params = new CoviMap();			
			params.put("deptID", deptID);
			params.put("userID", userID);
			params.put("ProcessID", processID);
			params.put("FormInstID", formInstID);

			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptTCInfoSingleDocRead(params));
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
	 * getPersonDirectorOfUnitData : 부서결재함- 특정부서(사용자) 부서조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getPersonDirectorOfUnitData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorOfUnitData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String userCode = request.getParameter("UserCode");
			String unitCode = request.getParameter("UnitCode");
			String entCode = request.getParameter("EntCode");

			CoviMap params = new CoviMap();

			params.put("UserCode", userCode);
			params.put("UnitCode", unitCode);
			params.put("EntCode", entCode);

			CoviList resultList = deptApprovalListSvc.getPersonDirectorOfUnitData(params);
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
	
	// 부서함 - 수신함 갯수
	@RequestMapping(value = "user/getDeptReceptionCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptReceptionCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("deptID", SessionHelper.getSession("ApprovalParentGR_Code"));
			
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptReceptionCnt(params));
			
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
	
	// 부서함 - 진행함 갯수
	@RequestMapping(value = "user/getDeptProcessCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptProcessCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("deptID", SessionHelper.getSession("ApprovalParentGR_Code"));
			
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptProcessCnt(params));
			
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
	
	// 부서함 - 함별 전체 개수 조회
	@RequestMapping(value = "user/getDeptBoxListCnt.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectDeptBoxListCnt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("deptID", SessionHelper.getSession("ApprovalParentGR_Code"));
			params.put("listGubun", request.getParameter("listGubun"));
			
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			returnList.put("cnt", deptApprovalListSvc.selectDeptBoxListCnt(params));
			
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
		
	// 미결함, 참조/회람함 읽음 처리
	@RequestMapping(value = "user/deptDocRead.do")
	public @ResponseBody CoviMap docReadProcess(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=true) String[] paramArr) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String userId = SessionHelper.getSession("USERID");
			String userName = SessionHelper.getSession("USERNAME");
			String jobTitle = SessionHelper.getSession("UR_JobTitleCode");
			String jobLevel = SessionHelper.getSession("UR_JobLevelCode");
			String adminYn = "N";
			String receiptOuid = SessionHelper.getSession("DEPTID");
			String deptName = SessionHelper.getSession("DEPTNAME");
			
			ArrayList<CoviMap> paramList = new ArrayList<>();
			CoviMap tempMap = null;
			for (String param : paramArr) {
				String[] tempArr = param.split("\\|");
				tempMap = new CoviMap();
				tempMap.put("UserID", userId);
				tempMap.put("UserCode", userId);
				tempMap.put("UserName", userName);
				tempMap.put("JobTitle", jobTitle);
				tempMap.put("JobLevel", jobLevel);
				tempMap.put("AdminYN", adminYn);
				tempMap.put("ReceiptID", receiptOuid);
				tempMap.put("ProcessID", tempArr[0]);
				tempMap.put("FormInstID", tempArr[1]);
				tempMap.put("Kind", tempArr[2]);
				tempMap.put("ReceiptOUID", receiptOuid);
				tempMap.put("ReceiptName", userName);
				tempMap.put("ReceiptOUName", deptName);
				tempMap.put("DeptCode", receiptOuid);
				tempMap.put("DeptName", deptName);
				paramList.add(tempMap);
			}
			
			CoviMap params = new CoviMap();
			params.put("paramList", paramList);
			
			int cnt = 0;
			String mode = StringUtil.replaceNull(request.getParameter("mode"));		// 487 수신함, 489 참조/회람함
			if (mode.equalsIgnoreCase("RECEIVE")) {
				cnt = deptApprovalListSvc.insertDocReadHistory(params);
			} else if (mode.equalsIgnoreCase("DEPTTCINFO")) {
				cnt = deptApprovalListSvc.insertTCInfoDocReadHistory(params);
			}
			
			returnList.put("cnt", cnt);
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
