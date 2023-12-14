package egovframework.covision.coviflow.user.web;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.AuditDeptCompleteListSvc;


@Controller
public class AuditDeptCompleteListCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(AuditDeptCompleteListCon.class);

	@Autowired
	private AuditDeptCompleteListSvc auditDeptCompleteListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getApprovalGroupListData - 개인결재함 하위메뉴별 그룹별 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getAuditDeptCompleteGroupListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAuditDeptCompleteGroupListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate 	= StringUtil.replaceNull(request.getParameter("endDate"));
			String mnid 	= request.getParameter("mn_id");
			String deptID 	= request.getParameter("deptID");
			String isCheckSubDept = request.getParameter("isCheckSubDept");
			String clickTab	= StringUtil.replaceNull(request.getParameter("clickTab"), "Complete");
			
			String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
			String dbName = "COVI_APPROVAL4J_ARCHIVE";
			if(bstored.equals("true"))
				dbName = "COVI_APPROVAL4J_STORE";
			
			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			
			if(StringUtil.isNotEmpty(startDate)) {
				params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			}
			else {
				params.put("startDate", ComUtils.ConvertDateToDash(startDate));
				params.put("endDate", ComUtils.ConvertDateToDash(endDate));
			}
			params.put("mnid", mnid);
			params.put("deptID", deptID);
			params.put("DBName", dbName);
			params.put("isCheckSubDept", isCheckSubDept);
			params.put("clickTab", clickTab);
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			CoviMap resultList = auditDeptCompleteListSvc.getAuditDeptCompleteGroupListData(params);

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
	 * getAuditDeptCompleteListData : 감사문서함 진행 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getAuditDeptProcessListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAuditDeptProcessListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {

			String userID = SessionHelper.getSession("USERID");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = StringUtil.replaceNull(request.getParameter("searchGroupWord"));
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");
			String isCheckSubDept = request.getParameter("isCheckSubDept");
			String deptID 	= request.getParameter("deptID");
			String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
			String dbame = "COVI_APPROVAL4J_ARCHIVE";
			if(bstored.equals("true"))
				dbame = "COVI_APPROVAL4J_STORE";
			
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap params = new CoviMap();

			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}

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
			params.put("isCheckSubDept", isCheckSubDept);
			params.put("UserCode", userCode);
			params.put("EntCode", entCode);
			params.put("deptID", deptID);
			params.put("userID", userID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("DBName", dbame);

			CoviMap resultList = auditDeptCompleteListSvc.getAuditDeptProcessListData(params);
			
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
	 * getAuditDeptCompleteListData : 감사문서함 완료 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getAuditDeptCompleteListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAuditDeptCompleteListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {

			String userID = SessionHelper.getSession("USERID");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = request.getParameter("searchGroupType");
			String searchGroupWord = request.getParameter("searchGroupWord");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");
			String isCheckSubDept = request.getParameter("isCheckSubDept");
			String deptID 	= request.getParameter("deptID");
			String bstored 	= request.getParameter("bstored");
			String dbame = "COVI_APPROVAL4J_ARCHIVE";
			if(StringUtil.replaceNull(bstored, "").equals("true"))
				dbame = "COVI_APPROVAL4J_STORE";
			
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap params = new CoviMap();

			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(StringUtil.replaceNull(searchGroupType, "").equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}

			if(StringUtil.isNotEmpty(startDate)) {
				params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(StringUtil.replaceNull(endDate, "").equals("") ? "" : endDate + " 00:00:00")));
			}
			else {
				params.put("startDate", ComUtils.ConvertDateToDash(startDate));
				params.put("endDate", ComUtils.ConvertDateToDash(endDate));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("isCheckSubDept", isCheckSubDept);
			params.put("UserCode", userCode);
			params.put("EntCode", entCode);
			params.put("deptID", deptID);
			params.put("userID", userID);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("DBName", dbame);

			CoviMap resultList = auditDeptCompleteListSvc.getAuditDeptCompleteListData(params);
			
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

}
