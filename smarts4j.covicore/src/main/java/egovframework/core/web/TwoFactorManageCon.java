package egovframework.core.web;

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

import egovframework.core.sevice.TwoFactorManageSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;


@Controller
public class TwoFactorManageCon {

	private Logger LOGGER = LogManager.getLogger(TwoFactorManageCon.class);
	
	@Autowired
	private TwoFactorManageSvc twoFactorManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "layout/TwoFactorManageList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "selectsearch", required = false, defaultValue = "") String selectsearch,
			@RequestParam(value = "searchtext", required = false, defaultValue = "") String searchtext,
			@RequestParam(value = "companyCode", required = false, defaultValue = "") String companyCode,
			@RequestParam(value = "startdate", required = false, defaultValue = "") String startdate,
			@RequestParam(value = "enddate", required = false, defaultValue = "") String enddate,
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "10") String pageSize) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortColumn = ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirection = ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			int iPageNo =  Integer.parseInt(pageNo);
			int iPageSize = Integer.parseInt(pageSize);	
			int start =  (iPageNo - 1) * iPageSize +1; 
			int end = start + iPageSize -1;
			
			CoviMap params = new CoviMap();
			CoviMap page = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageOffset = (iPageNo - 1) * iPageSize;
			
			params.put("pageOffset", pageOffset);
			params.put("pageSize", iPageSize);
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}
			
			if(companyCode.isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("rowStart",start);
			params.put("rowEnd",end);
			
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("selectsearch", selectsearch);
			params.put("companyCode", companyCode);
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = twoFactorManageSvc.select(params);

			page.put("pageNo", iPageNo);
			page.put("pageSize", iPageSize);
			
			int cnt = resultList.getInt("cnt")	;

			page.addAll(ComUtils.setPagingData(page,cnt));	

			returnList.put("page", page);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	

	@RequestMapping(value = "layout/TwoFactorManageIsCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap TwoFactorManageIsCheck(HttpServletRequest request) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		StringUtil func = new StringUtil();
		String isTarget = request.getParameter("isTarget");
		
		try {
			
			params.put("seq", request.getParameter("seq"));
			params.put("userID", SessionHelper.getSession("USERID") );
			params.put("value", request.getParameter("value"));
			
			if(func.f_NullCheck(isTarget).equals("U")){
				
				if(!twoFactorManageSvc.twoFactorUserIsCheck(params)){
					returnList.put("status", Return.FAIL);
				}else{
					returnList.put("status", Return.SUCCESS);
				}
				
			}else if(func.f_NullCheck(isTarget).equals("A")){
				
				if(!twoFactorManageSvc.twoFactorAdminIsCheck(params)){
					returnList.put("status", Return.FAIL);
				}else{
					returnList.put("status", Return.SUCCESS);
				}
				
			}else{
				returnList.put("status", Return.FAIL);
			}
		} 
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "layout/TwoFactorDeleteList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap TwoFactorDeleteList(HttpServletRequest request) throws Exception
	{
		String DeleteData = request.getParameter("DeleteData");
		String[] saData = StringUtil.replaceNull(DeleteData).split(",");
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("seq", saData);
			
			for (String codeID: saData) {
				CoviMap selectParam = new CoviMap();
				selectParam.put("seq", codeID);
				selectParam.put("userID", SessionHelper.getSession("USERID"));
				if(twoFactorManageSvc.deleteTwoFactorList(selectParam)){
					
				}else{
					returnList.put("status", Return.FAIL);
					return returnList;
				}
			}
			
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "layout/TwoFactorInfoPopup.do", method = RequestMethod.GET)
	public ModelAndView goBaseCodePopup(HttpServletRequest request) {
		String returnURL = "core/system/TwoFactorManagePopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("mode",request.getParameter("mode"));
		mav.addObject("seq",request.getParameter("seq"));
		
		return mav;
	}
	
	@RequestMapping(value = "layout/TwoFactorInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap TwoFactorInfo(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap objList = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("seq", request.getParameter("seq"));
		
		objList = twoFactorManageSvc.selectTwoFactorInfo(params);
		
		returnList.put("list", objList.get("list"));
		
		return returnList;
	}
	
	
	@RequestMapping(value = "layout/TwoFactorEdit.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap TwoFactorEdit(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("seq", request.getParameter("seq"));
		params.put("startIP", request.getParameter("STARTIP"));
		params.put("endIP", request.getParameter("ENDIP"));
		params.put("companyCode", request.getParameter("COMPANYCODE"));
		params.put("Description", request.getParameter("DESCRIPTION"));
		params.put("isLogin", request.getParameter("ISLOGIN"));
		params.put("isAdmin", request.getParameter("ISADMIN"));
		params.put("userID", SessionHelper.getSession("USERID"));

		if(twoFactorManageSvc.twoFactorEdit(params)){
			returnList.put("status", Return.SUCCESS);
		}else{
			returnList.put("status", Return.FAIL);
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "layout/TwoFactorAdd.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap TwoFactorAdd(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("startIP", request.getParameter("STARTIP"));
		params.put("endIP", request.getParameter("ENDIP"));
		params.put("companyCode", request.getParameter("COMPANYCODE"));
		params.put("Description", request.getParameter("DESCRIPTION"));
		params.put("isLogin", request.getParameter("ISLOGIN"));
		params.put("isAdmin", request.getParameter("ISADMIN"));
		params.put("userID", SessionHelper.getSession("USERID"));

		if(twoFactorManageSvc.twoFactorAdd(params)){
			returnList.put("status", Return.SUCCESS);
		}else{
			returnList.put("status", Return.FAIL);
		}
		
		
		return returnList;
	}
}
