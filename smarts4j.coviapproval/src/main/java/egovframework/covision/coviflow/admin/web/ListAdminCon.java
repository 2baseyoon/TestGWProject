package egovframework.covision.coviflow.admin.web;

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
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.ListAdminSvc;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;



@Controller
public class ListAdminCon {

	private Logger LOGGER = LogManager.getLogger(ListAdminCon.class);

	@Autowired
	private ListAdminSvc listAdminSvc;
	
	@Autowired
	private ApprovalListSvc approvalListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getApprovalListData - 관리자 메뉴 - 결재문서관리툴 - 문서속성팝업
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/OpenDocumentInfoPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getUserFolderListData(Locale locale, Model model)
	{
		String returnURL = "admin/approval/OpenDocumentInfoPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getJobFunctionListData : 관리자 메뉴 - 결재문서관리툴 : 계열사목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getEntinfototalListData.do")
	public @ResponseBody CoviMap getBizDocListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");
			String filter = StringUtil.replaceNull(request.getParameter("filter"));
			String listData = "";

			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			
			if(filter.equals("selectEntinfoListData")){ // 계알사 select 조회
				CoviMap resultList = listAdminSvc.getEntinfototalListData(params);
				returnList.put("list",resultList.get("list"));
			}else if(filter.equals("selectSearchType")){ // 검색조건 select 조회
				listData = "[{\"optionValue\":\"\",\"optionText\":\"검색조건\"},{\"optionValue\":\"FormSubject\",\"optionText\":\"제목\"},{\"optionValue\":\"InitiatorUnitName\",\"optionText\":\"기안부서\"},{\"optionValue\":\"InitiatorName\",\"optionText\":\"기안자\"},{\"optionValue\":\"FormName\",\"optionText\":\"양식명\"},{\"optionValue\":\"DocNo\",\"optionText\":\"문서번호\"},{\"optionValue\":\"FormInstID\",\"optionText\":\"FORM_INST_ID\"}]";
				returnList.put("list", listData);
			}else if(filter.equals("selectSearchTypeDate")){ // 날짜검색 select 조회
				listData = "[{\"optionValue\":\"\",\"optionText\":\"날짜검색\"},{\"optionValue\":\"InitiatedDate\",\"optionText\":\"기안일자\"},{\"optionValue\":\"CompletedDate\",\"optionText\":\"완료일자\"}]";
				returnList.put("list", listData);
			}else{ // 문서 select 조회
				listData = "[{\"optionValue\":\"\",\"optionText\":\"전체\"},{\"optionValue\":\"288\",\"optionText\":\"진행문서\"},{\"optionValue\":\"546\",\"optionText\":\"취소문서\"},{\"optionValue\":\"REJECT\",\"optionText\":\"반려문서\"},{\"optionValue\":\"528\",\"optionText\":\"완료문서\"}]";
				returnList.put("list", listData);
			}
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getApprovalListData - 관리자 메뉴 - 결재문서관리툴 - 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getListAdminData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getListAdminData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String selectSearchTypeDate = request.getParameter("selectSearchTypeDate");
			String selectEntinfoListData = request.getParameter("selectEntinfoListData");
			String selectSearchTypeDoc = request.getParameter("selectSearchTypeDoc");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortKey = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirec = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String bstored = StringUtil.replaceNull(request.getParameter("bstored"));

			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}

			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("selectSearchTypeDate", selectSearchTypeDate);
			params.put("selectEntinfoListData", selectEntinfoListData);
			params.put("selectSearchTypeDoc", selectSearchTypeDoc);
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			if(bstored.equals("true")) // 이관문서
				resultList = listAdminSvc.selectListAdminData_Store(params);
			else
				resultList = listAdminSvc.selectListAdminData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
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
	 * getApprovalListData - 관리자 메뉴 - 결재문서관리툴 - 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/setDocumentInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectDocumentInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String formInstID = request.getParameter("FormInstID");

			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			params.put("FormInstID", formInstID);

			resultList = listAdminSvc.selectDocumentInfo(params);

			returnList.put("list", resultList.get("map"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
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
}
