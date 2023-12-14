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
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MailMgrSvc;


@Controller
public class MailMgrCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(MailMgrCon.class);
	
	@Autowired
	private MailMgrSvc mailMgrSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
		
	/**
	 * getMailMgrList : 결재알림관리 - 결재 알림 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getMailMgrList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMailMgrList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String state = request.getParameter("sel_State");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");			
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sel_State", state);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));		
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = mailMgrSvc.getMailMgrList(params);
			
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
	 * goMailDetail : 결재알림관리 - 팝업 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goMailDetail.do", method = RequestMethod.GET)
	public ModelAndView goMailDetail(Locale locale, Model model) {
		String returnURL = "admin/approval/MailDetail";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getMailDetail : 결재알림관리 - 팝업 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getMailDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMailDetail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String mailID = request.getParameter("MailID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("MailID", mailID);
			resultList = mailMgrSvc.getMailDetail(params);						
	
			returnList.put("list", resultList.get("map"));			
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
	 * resendMail : 결재알림관리 - 메일 재발송
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/resendMail.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap resendMail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String mailID  = request.getParameter("MailID");
			String sendYN  = request.getParameter("SendYN");			
			
			CoviMap params = new CoviMap();			
			params.put("MailID"  , mailID);
			params.put("SendYN"  , sendYN);
			
			returnList.put("object", mailMgrSvc.resendMail(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");			
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
