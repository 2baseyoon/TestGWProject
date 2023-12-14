/*package egovframework.covision.coviflow.admin.web;


import java.util.Enumeration;
import java.util.Locale;
import java.util.Map;




import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;







import org.apache.commons.lang.StringEscapeUtils;
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

import egovframework.coviframework.base.Enums.Return;
import egovframework.coviframework.data.CoviMap;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.coviflow.admin.service.ListConSendDataSvc;

@Controller
public class ListConSendDataCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(ListConSendDataCon.class);
	
	@Autowired
	private ListConSendDataSvc listConSendDataSvc;
	
	
	*//**
	 * getConSendDataLogLegacy : 연동시스템 송신로그  - 타시스템연동오류 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 *//*
	@RequestMapping(value = "admin/getConSendDataLogLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConSendDataLogLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sel_Search = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			
		
			String sortColumn = request.getParameter("sortBy").split(" ")[0].equalsIgnoreCase("DisplayName") ? "B.DisplayName" : "A."+request.getParameter("sortBy").split(" ")[0];
			String sortDirection = request.getParameter("sortBy").split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
		
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageOffset = (pageNo - 1) * pageSize;
			
			params.put("pageOffset", pageOffset);
			params.put("pageSize", pageSize);
		

			params.put("sel_Search", sel_Search);
			params.put("search", search);
			params.put("startdate", startdate);
			params.put("enddate", enddate);
	
			
			params.put("sortColumn",sortColumn);
			params.put("sortDirection",sortDirection);
			
			
			resultList = listConSendDataSvc.getConSendDataLogLegacy(params);
			
			page.put("pageNo", pageNo);
			page.put("pageSize", pageSize);

			int pageCount = 1 + (int) Math.ceil((Integer) resultList.get("cnt")	/ pageSize);
			//pageCount : 페이지 갯수
			page.put("pageCount", pageCount);
			int listCount = (Integer) resultList.get("cnt");
			page.put("listCount", listCount);

			returnList.put("page", page);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
		
	}
	
	
}
*/