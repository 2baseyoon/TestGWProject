package egovframework.covision.coviflow.manage.web;


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
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.coviflow.admin.service.DeptDocTransferSvc;


@Controller
public class DeptDocTransferManageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(DeptDocTransferManageCon.class);
	
	@Autowired
	private DeptDocTransferSvc deptDocTransferSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	

	/**
	 * getDeptDocTransferCount : 부서 문서 이관 - 이관문서 개수 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getDeptDocTransferCount.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptDocTransferCount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			String sourceDeptCode = request.getParameter("SOURCE_DEPT_CODE");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("SOURCE_DEPT_CODE", sourceDeptCode);
			resultList = deptDocTransferSvc.select(params);
			
			returnList.put("cnt", resultList.get("cnt"));	
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
	 * transferDeptDoc : 부서 문서 이관 - 이관실행
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "manage/transferDeptDoc.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertPersonDirector(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String sourceDeptCode  = request.getParameter("SOURCE_DEPT_CODE");
			String destDeptCode    = request.getParameter("DEST_DEPT_CODE");
			String destDeptName    = request.getParameter("DEST_DEPT_NAME");
			String userID  = SessionHelper.getSession("USERID");
			
			CoviMap params = new CoviMap();			
			params.put("SOURCE_DEPT_CODE"  , sourceDeptCode  );
			params.put("DEST_DEPT_CODE"    , destDeptCode    );
			params.put("DEST_DEPT_NAME"    , destDeptName    );
			params.put("USERID"  , userID  );
			
			deptDocTransferSvc.transferDeptDoc(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "이관되었습니다.");			
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
