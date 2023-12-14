package egovframework.covision.coviflow.manage.web;


import java.util.Map;
import java.util.Objects;

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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.TempSaveDocSvc;

@Controller
public class TempSaveDocManageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(TempSaveDocManageCon.class);
	
	@Autowired
	private TempSaveDocSvc tempSaveDocSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	/**
	 * getTempSaveDocList : 임시저장문서보기 - 임시 문서 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getTempSaveDocList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap gettempSaveDocList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String state = request.getParameter("sel_State");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String dateType = request.getParameter("sel_Date");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}		

			CoviMap resultList = null;
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sel_State", state);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sel_Date", dateType);
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("selectEntinfoListData",ComUtils.RemoveSQLInjection(request.getParameter("selectEntinfoListData"), 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = tempSaveDocSvc.selectGrid(params);

			returnList.put("page",  resultList.get("page"));
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
