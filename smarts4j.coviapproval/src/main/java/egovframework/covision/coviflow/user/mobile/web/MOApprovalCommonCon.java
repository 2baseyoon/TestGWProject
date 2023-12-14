package egovframework.covision.coviflow.user.mobile.web;


import java.io.FileNotFoundException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.admin.service.DocFolderManagerSvc;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.user.mobile.service.MobileApprovalListSvc;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;
import egovframework.covision.coviflow.user.service.FormListSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;
//import egovframework.covision.coviflow.xform.service.XFormEditorDatabaseSvc;
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;
import egovframework.covision.coviflow.user.service.UserBizDocListSvc;




@Controller
@RequestMapping("/mobile/approval")
public class MOApprovalCommonCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(MOApprovalCommonCon.class);

	@Autowired
	private ApprovalListSvc approvalListSvc;
	
	@Autowired
	private DeptApprovalListSvc deptApprovalListSvc;
	
	@Autowired
	private MobileApprovalListSvc mobileApprovalListSvc;

	@Autowired
	private CommonApprovalListSvc commonApprovalListSvc;
	
	@Autowired
	private FormListSvc formListSvc;
	
	@Autowired
	private ApvProcessSvc apvProcessSvc;
	
	@Autowired
	private DocFolderManagerSvc docFolderManagerSvc;
	
	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	@Autowired
	private JobFunctionListSvc jobFunctionListSvc;
	
	@Autowired
	private UserBizDocListSvc userBizDocListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	/**
	 * getMobileMenuList - 모바일 결재함 , 권한있는 담당업무함/업무문서함 카운트 조회 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getNotDocReadCnt.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMobileMenuList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		int user_apvNDRCnt = 0;
		int user_prcNDRCnt = 0;
		int user_tcNDRCnt = 0;
		int dept_rcvNDRCnt = 0;
		int dept_prcNDRCnt = 0;
		int dept_tcNDRCnt = 0;
		int jobFunction_Cnt = 0;
		int bizDoc_tcNDRCnt = 0;
		
		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			//현재 부서 ID
			String deptID = SessionHelper.getSession("GR_Code");
			// 통합결재 조건 추가 
			String businessData1 = request.getParameter("businessData1"); 

			if( !SessionHelper.getSession("GR_Code").equals(SessionHelper.getSession("ApprovalParentGR_Code")) && SessionHelper.getSession("ApprovalParentGR_Code").length() > 0 ){
				deptID = SessionHelper.getSession("ApprovalParentGR_Code");
			}
			
			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("deptID", deptID);
			
			if(businessData1 != null && !businessData1.equals("ACCOUNT")) {
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = mobileApprovalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				user_apvNDRCnt = approvalListSvc.selectApprovalCnt(params);			//개인함 - 미결함
				user_prcNDRCnt = approvalListSvc.selectProcessCnt(params);			//개인함 - 진행함
				user_tcNDRCnt = approvalListSvc.selectTCInfoNotDocReadCnt(params);				//개인함 - 참조/회람함
				dept_rcvNDRCnt = deptApprovalListSvc.selectDeptReceptionCnt(params);			//부서함 - 수신함
				dept_prcNDRCnt = deptApprovalListSvc.selectDeptProcessCnt(params);	//부서함 - 진행함
				dept_tcNDRCnt = deptApprovalListSvc.selectDeptTCInfoNotDocReadCnt(params);		//부서함 - 참조/회람함
			}

			CoviMap paramJobBiz = new CoviMap();
			paramJobBiz.put("userCode", userID);
			paramJobBiz.put("JobFunctionType", businessData1);
			paramJobBiz.put("bizDocType", businessData1);
			paramJobBiz.put("entCode", SessionHelper.getSession("DN_Code"));
			paramJobBiz.put("isSaaS", isSaaS);

			jobFunction_Cnt = jobFunctionListSvc.selectJobFunctionCount(paramJobBiz);
			bizDoc_tcNDRCnt = userBizDocListSvc.selectBizDocCount(paramJobBiz);
			
			returnList.put("user_apvNDRCnt", user_apvNDRCnt);
			returnList.put("user_prcNDRCnt", user_prcNDRCnt);
			returnList.put("user_tcNDRCnt", user_tcNDRCnt);
			returnList.put("dept_rcvNDRCnt", dept_rcvNDRCnt);
			returnList.put("dept_prcNDRCnt", dept_prcNDRCnt);
			returnList.put("dept_tcNDRCnt", dept_tcNDRCnt);
			returnList.put("jobFunction_Cnt", jobFunction_Cnt);
			returnList.put("bizDoc_tcNDRCnt", bizDoc_tcNDRCnt);
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
	 * getApprovalListData - 모바일 결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getMobileApprovalListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMobileApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		boolean bhasAuth = false;

		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String sessionUserID = SessionHelper.getSession("USERID");
			String deptID 	= request.getParameter("deptID");
			String sessiondeptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String viewStartDate = "";
			String viewEndDate = "";
			String mode = StringUtil.replaceNull(request.getParameter("mode")).toUpperCase();

			//관리자
			String requestURI = request.getHeader("referer").toLowerCase();

			CoviMap paramsAuth = new CoviMap();

			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_adminuserlist.do") > -1){
				bhasAuth = true;				
			} else if(userID == null || !userID.equalsIgnoreCase(sessionUserID)){
				if(mode.equals("COMPLETE") || mode.equals("TCINFO")){
					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
	
					CoviMap resultListAuth = new CoviMap();
					resultListAuth = commonApprovalListSvc.getPersonDirectorOfPerson(paramsAuth);
					
					CoviList directPersonList = (CoviList)resultListAuth.get("list");
	                for(Object obj : directPersonList){
	                    CoviMap directPerson = (CoviMap)obj;
	                    if(directPerson.optString("UserCode").equalsIgnoreCase(userID)){
	        				bhasAuth = true;
	        				viewStartDate = directPerson.getString("ViewStartDate");
	        				viewEndDate = directPerson.getString("ViewEndDate");
	        				break;
	                    }
	                }
				}
			} else if(deptID == null || !deptID.equalsIgnoreCase(sessiondeptID)){
				if(mode.equals("DEPTCOMPLETE") || mode.equals("SENDERCOMPLETE") || mode.equals("RECEIVECOMPLETE") || mode.equals("DEPTTCINFO")) {
					paramsAuth.put("UserCode", SessionHelper.getSession("UR_Code"));
					paramsAuth.put("UnitCode", SessionHelper.getSession("GR_Code"));
					paramsAuth.put("EntCode", SessionHelper.getSession("DN_Code"));
	
					CoviList directPersonUnitList = commonApprovalListSvc.getPersonDirectorOfUnitData(paramsAuth);
					
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
			} else{
				bhasAuth = true;
			}
			
			if(bhasAuth){
				String searchType = request.getParameter("searchType");
	  			String searchWord = request.getParameter("searchWord");
	 			String searchGroupType = request.getParameter("searchGroupType")==null?"":request.getParameter("searchGroupType");
	 			String searchGroupWord = request.getParameter("searchGroupWord");
				String startDate = request.getParameter("startDate")==null?"":request.getParameter("startDate");
				String endDate = request.getParameter("endDate")==null?"":request.getParameter("endDate");
				String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
				String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-사용자문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
				
				String bstored 	= "false"; //request.getParameter("bstored");
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO"))
					dbName = "COVI_APPROVAL4J";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
				
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
	
				// pageNo : 현재 페이지 번호
				// pageSize : 페이지당 출력데이타 수
				int pageSize = 1;
				int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
				if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
					pageSize = Integer.parseInt(request.getParameter("pageSize"));
				}
				
				String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
				
				CoviMap params = new CoviMap();
				CoviMap page = new CoviMap();
	
				params.put("userID", userID);
				params.put("deptID", deptID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				
				params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("mode", mode);
				params.put("adminYn", adminYn);
				params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
				params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
				params.put("pageSize", pageSize);
				params.put("pageNo", pageNo);
				params.put("DBName", dbName);
				params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
				
				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
				}
	
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = mobileApprovalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				// [211021 add]문서연결 창 조건 추가
				params.put("requestType",requestType);
				
				switch(mode){
				case "PREAPPROVAL":
				case "APPROVAL":
				case "PROCESS":
				case "COMPLETE":
				case "REJECT":
				case "TEMPSAVE":
				case "TCINFO":
					if(mode.equals("TEMPSAVE")) {
						params.put("isMobile", "Y");
					}
					
					resultList = mobileApprovalListSvc.selectMobileApprovalList(params);
					break;
				case "DEPTCOMPLETE":
				case "SENDERCOMPLETE":
				case "RECEIVE":
				case "RECEIVECOMPLETE":
				case "DEPTTCINFO":
				case "DEPTPROCESS":
					resultList = mobileApprovalListSvc.selectMobileDeptApprovalList(params);
					break;
				default:
					break;
				}
	
				//draftkey 추가
				AES aes = new AES("", "N");
				CoviList resultListArr = (CoviList)resultList.get("list");
	            for(Object obj : resultListArr){
	                CoviMap resultListobj = (CoviMap)obj;
	                if(resultListobj.has("FormInstID") && resultListobj.has("ProcessID") && resultListobj.has("TaskID") && (resultListobj.has("WorkItemID") || resultListobj.has("WorkitemID")) ){
	                	String workItemID = "";
	                	if (resultListobj.has("WorkItemID")) workItemID = resultListobj.getString("WorkItemID");
	                	else workItemID = resultListobj.getString("WorkitemID");
	                	
	                	String draftkey = resultListobj.getString("FormInstID") +  "@" + workItemID +  "@" + resultListobj.getString("ProcessID") +  "@" + resultListobj.getString("TaskID");
	                	resultListobj.put("formDraftkey", aes.encrypt(draftkey));
	                }
	            }
				
				page = resultList.getJSONObject("page");
				
				returnList.put("page", page);
				returnList.put("list", resultList.get("list"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_DoNotPermissionViewList"));
			}
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
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
	 * getApprovalListData - 모바일 결재함 하위메뉴별 리스트 조회(담당업무함, 업무문서함)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getMobileJobBizApprovalListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMobileJobBizApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		boolean bhasAuth = false;

		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String sessionUserID = SessionHelper.getSession("USERID");
			String deptID 	= request.getParameter("deptID");
			String sessiondeptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String viewStartDate = "";
			String viewEndDate = "";
			String mode = StringUtil.replaceNull(request.getParameter("mode")).toUpperCase();

			//관리자
			String requestURI = request.getHeader("referer").toLowerCase();

			CoviMap paramsAuth = new CoviMap();

			//인증처리
			//허용케이스 : 관리자 전체, 사용자인 경우 완료함에서 권한부여 받은 사용자만
			if(SessionHelper.getSession("isAdmin").equals("Y") && requestURI.indexOf("/approval/layout/approval_adminuserlist.do") > -1){
				bhasAuth = true;				
			} else if(userID == null || !userID.equalsIgnoreCase(sessionUserID)){
			} else if(deptID == null || !deptID.equalsIgnoreCase(sessiondeptID)){
			} else{
				bhasAuth = true;
			}
			
			if(bhasAuth){
				String searchType = request.getParameter("searchType");
	  			String searchWord = request.getParameter("searchWord");
	 			String searchGroupType = request.getParameter("searchGroupType")==null?"":request.getParameter("searchGroupType");
	 			String searchGroupWord = request.getParameter("searchGroupWord");
				String startDate = request.getParameter("startDate")==null?"":request.getParameter("startDate");
				String endDate = request.getParameter("endDate")==null?"":request.getParameter("endDate");
				String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
				String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
				String titleNm 	= request.getParameter("titleNm");
				String userNm 	= request.getParameter("userNm");
				String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-사용자문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
				String jobBizKey 	= request.getParameter("jobBizKey")==null?"":request.getParameter("jobBizKey"); // 담당업무,업무문서 함 키값
				
				String bstored 	= "false"; //request.getParameter("bstored");
				String dbName = "COVI_APPROVAL4J_ARCHIVE";
				if(bstored.equals("true"))
					dbName = "COVI_APPROVAL4J_STORE";
				
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
	
				// pageNo : 현재 페이지 번호
				// pageSize : 페이지당 출력데이타 수
				int pageSize = 1;
				int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
				if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
					pageSize = Integer.parseInt(request.getParameter("pageSize"));
				}
				
				String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
				
				CoviMap params = new CoviMap();
				CoviMap page = new CoviMap();
	
				params.put("userCode", userID);
				params.put("entCode", SessionHelper.getSession("DN_Code"));
				params.put("isSaaS", isSaaS);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				
				params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
				params.put("mode", mode);
				params.put("adminYn", adminYn);
				params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
				params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
				params.put("pageSize", pageSize);
				params.put("pageNo", pageNo);
				params.put("DBName", dbName);
				
				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
				}
	
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = mobileApprovalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				params.put("businessData1", businessData1);
				
				// [211021 add]문서연결 창 조건 추가
				params.put("requestType",requestType);
				
				// 담당업무함,업무문서함 키
				params.put("jobFunctionCode", jobBizKey);
				params.put("bizDocCode", jobBizKey);
				switch(mode){
					case "JOBFUNCTIONAPPROVAL": resultList = jobFunctionListSvc.selectJobFunctionApprovalListData(params); break;
					case "JOBFUNCTIONPROCESS": resultList = jobFunctionListSvc.selectJobFunctionProcessListData(params); break;
					case "JOBFUNCTIONCOMPLETE": resultList = jobFunctionListSvc.selectJobFunctionCompleteListData(params); break;
					case "JOBFUNCTIONREJECT": resultList = jobFunctionListSvc.selectJobFunctionRejectListData(params); break;
					case "BIZDOCPROCESS": resultList = userBizDocListSvc.selectBizDocProcessListData(params); break;
					case "BIZDOCCOMPLETE": resultList = userBizDocListSvc.selectBizDocCompleteLisData(params); break;
					default:
						break;
				}
				
				page = resultList.getJSONObject("page");
				
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
	 * getMobileApprovalView - 모바일 결재 상세 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getMobileApprovalView.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMobileApprovalView(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try	{

			String processDescID = request.getParameter("processDescID");
			String formInstID = request.getParameter("formInstID");

			CoviMap params = new CoviMap();

			params.put("processDescID", processDescID);
			params.put("formInstID", formInstID);

			resultList = mobileApprovalListSvc.selectMobileApprovalView(params);

			returnList.put("processdes", resultList.get("processdes"));
			returnList.put("forminstance", resultList.get("forminstance"));
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
	 * getDataSelect - 모바일 결재 xForm 조회 연동
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getDataSelect.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDataSelect(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try	{
			
			@SuppressWarnings({ "rawtypes" })
			Enumeration Eparams = request.getParameterNames();
			
			//connect, tableName, columnName
			//param1,paramValue1 ~ param4,paramValue4
			while(Eparams.hasMoreElements())
			{
				String strParamName = (String) Eparams.nextElement();
				params.put(strParamName,request.getParameter(strParamName));			
			}
			
			String columnList = "";//xformEditorDatabaseSvc.selectData(params);
			
			returnList.put("Table", columnList);
			
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
	 * 프로세스 시작 [기안, 승인, 반려, 합의, 재기안 등]
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 * @deprecated : 모바일 일괄결재시 호출되었음. >> pc버전 draft.do 공통로직으로 변경
	 */
	@RequestMapping(value = "draft.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doProcess(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
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
			
			// 본문 저장관련해서 호출 분리함.
			CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
			
			// 기안 및 승인
			String formInstID = apvProcessSvc.doProcess(formObj, processFormDataReturn);
			
			//문서발번 처리
			if(!formInstID.equals(""))
				apvProcessSvc.updateFormInstDocNumber(formInstID);
			
			// 알림 처리
			try {
				String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/setTimeLineData.do";
				HttpsUtil httpsUtil = new HttpsUtil();
				httpsUtil.httpsClientWithRequest(url, "POST", formObj, "UTF-8", null);
			} catch(NullPointerException npE) {
				LOGGER.error("ApvProcessCon", npE);
			} catch(Exception e) {
				LOGGER.error("ApvProcessCon", e);
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
			
		}catch(FileNotFoundException e) {
			result.put("status", Return.FAIL);
			result.put("message", e.toString());
		}catch(NullPointerException npE){
			LOGGER.error("ApvProcessCon", npE);
			result.put("status", Return.FAIL);
			result.put("message", npE.toString());
		}catch(Exception e){
			LOGGER.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", e.toString());
		}
		return result;
	}
	
	/**
	 * 일괄결재를 위한 결재선 조회 (담당업무함)
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getBatchApvLine.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviList getBatchApvLine(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviList resultArr = new CoviList();	
		
		String processIDArr = StringUtil.replaceNull(request.getParameter("processIDArr"));
		String[] processIDs = null;
		
		if(processIDArr.indexOf(',')>=0){
			processIDs = processIDArr.split(",");
		}else{
			processIDs = new String[]{ processIDArr };
		}
		
		CoviMap params = new CoviMap();
		params.put("processIDs", processIDs);
		resultArr = apvProcessSvc.getBatchApvLine(params).getJSONArray("list");
		
		return resultArr;
	}
	
	/**
	 * chkCommentWrite - 모바일 결재 비밀번호 확인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "chkCommentWrite.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody Boolean chkCommentWrite(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		Boolean result = false;
		String userCode = request.getParameter("ur_code");
		String password = request.getParameter("password");

		AES aes = new AES("", "P");
		password = aes.pb_decrypt(password);
		
		result = apvProcessSvc.chkCommentWrite(userCode,password);
		
		return result;
	}
	
	@RequestMapping(value = "chkUsePasswordYN.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody Boolean chkUsePasswordYN(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		Boolean result = false;
		String userCode = request.getParameter("ur_code");
		
		CoviMap params = new CoviMap();
		params.put("UR_CODE", userCode);
		
		CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
		if(resultList != null){
			CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
			if(map.optString("UseApprovalPassWord").equals("Y")) {
				result = true;
			}
		}
		return result;
	}	
	
	// 미결함, 참조/회람함 읽음 처리
	@RequestMapping(value = "docRead.do")
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
	
	//부서 참조/회람함 읽음 처리
	@RequestMapping(value = "deptDocRead.do")
	public @ResponseBody CoviMap deptDocReadProcess(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=true) String[] paramArr) throws Exception {
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
			String mode = StringUtil.replaceNull(request.getParameter("mode"));		// DeptTCInfo 부서 참조/회람함
			if (mode.equalsIgnoreCase("RECEIVE")) {
				cnt = deptApprovalListSvc.insertDocReadHistory(params);
			} else if (mode.equalsIgnoreCase("DEPTTCINFO")) {
				cnt = deptApprovalListSvc.insertTCInfoDocReadHistory(params);
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
	 * deleteTempSaveList - 개인결재함 임시함/반려함 삭제처리
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "deleteTempSaveList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteTempSaveList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			//현재 사용자 ID
			String   userID 			= SessionHelper.getSession("USERID");
			String   type 				= StringUtil.replaceNull(request.getParameter("type"));
			String   formInstIdTemp		= null;
			String   formInstBoxIdTemp	= null;
			String   workItemIdTemp		= null;
			String[] formInstIds		= null;
			String[] formInstBoxIds		= null;
			String[] workItemIds		= null;

			if(type.equals("TempSave")){ //임시함삭제세팅
				formInstIdTemp 		= request.getParameter("FormInstId");
				formInstBoxIdTemp 	= request.getParameter("FormInstBoxId");
				formInstIds 		= StringUtil.replaceNull(formInstIdTemp).split(",");
				formInstBoxIds 		= StringUtil.replaceNull(formInstBoxIdTemp).split(",");
			}else{ //반려함삭제세팅
				workItemIdTemp		= request.getParameter("WorkItemId");
				workItemIds			= StringUtil.replaceNull(workItemIdTemp).split(",");
			}
			
			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("FormInstId",formInstIds);
			params.put("FormInstBoxId",formInstBoxIds);
			params.put("WorkItemId",workItemIds);

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
	 * getFormListData : 결재문서작성 : 양식조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return CoviMap
	 * @throws Exception
	 */
	
	@RequestMapping(value = "getFormListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//String viewAll = request.getParameter("viewAll");
			String formClassID =  request.getParameter("FormClassID");
			String formName =  request.getParameter("FormName");
			
			CoviMap params = new CoviMap();

			//params.put("viewAll", viewAll);
			params.put("FormClassID", formClassID);
			params.put("FormName", ComUtils.RemoveSQLInjection(formName, 100));
			params.put("entCode",  SessionHelper.getSession("DN_Code"));
			params.put("deptCode",  SessionHelper.getSession("GR_Code"));
			params.put("userCode",  SessionHelper.getSession("USERID"));
			params.put("isSaaS", isSaaS);
			
			CoviMap resultList = formListSvc.getFormListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * 임시저장 메소드
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "tempSave.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doTempSave(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();	
		String tempSaveReturnData = "";
		try{
			CoviMap formObj = CoviMap.fromObject(new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			List<MultipartFile> mf = request.getFiles("fileData[]");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return result;
			}
		
			apvProcessSvc.doCreateInstance("TEMPSAVE", formObj, mf);
			tempSaveReturnData = formObj.optString("FormInstID");			
			
			result.put("status", Return.SUCCESS);
			result.put("TempSaveReturnData", tempSaveReturnData);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		} catch (NullPointerException npE) {
			result.put("status", Return.FAIL);
			result.put("message", npE.toString());
		} catch(Exception e){
			LOGGER.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", e.toString());
		}
		return result;
	}
	
	/**
	 * getDocFolderManagerCount : 문서분류관리 - 해당 계열사의 최상위 폴더 정보를 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getTopFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDocFolderManagerCount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("EntCode");
			
			CoviMap params = new CoviMap();
			params.put("EntCode", entCode);
			
			CoviMap resultList = docFolderManagerSvc.selectDocClass(params);
			
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
