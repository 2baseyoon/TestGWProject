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
import egovframework.covision.coviflow.admin.service.AdminSchemaSvc;


@Controller
public class ApprovalAdminSchemaCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(ApprovalAdminSchemaCon.class);
	
	@Autowired
	private AdminSchemaSvc adminSchemaSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	/**
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "admin/getschemalist.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getschemalist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String[] EntCode = paramMap.get("EntCode").split(",");
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DomainID", paramMap.get("DomainID"));
			params.put("EntCode", EntCode);
			params.put("isSaaS", isSaaS);
			
			resultList = adminSchemaSvc.select(params);

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
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "admin/getschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getschemainfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		
		try {
			String schemaId = request.getParameter("SCHEMA_ID");
			
			CoviMap resultData = null;
			CoviMap params = new CoviMap();
			params.put("SCHEMA_ID",schemaId);
			
			resultData = adminSchemaSvc.selectOne(params);

			returnData.put("data", resultData);
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
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "admin/setschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap setschemainfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		
		try {
			String mode = StringUtil.replaceNull(request.getParameter("mode"));
			String schemaID = request.getParameter("SCHEMA_ID");
			String schemaName = request.getParameter("SCHEMA_NAME");
			String schemaDesc = request.getParameter("SCHEMA_DESC");
			String schemaContext = StringUtil.replaceNull(request.getParameter("SCHEMA_CONTEXT"));
			
			CoviMap params = new CoviMap();

			params.put("SCHEMA_ID",schemaID);
			params.put("SCHEMA_NAME",ComUtils.RemoveScriptAndStyle(schemaName));
			params.put("SCHEMA_DESC",ComUtils.RemoveScriptAndStyle(schemaDesc));
			params.put("SCHEMA_CONTEXT",schemaContext.replace("&quot;", "\""));
			params.put("DOMAIN_ID", paramMap.get("DOMAIN_ID"));
			
			int result;
			
			if(mode.equals("add")){
				result = (int) adminSchemaSvc.insert(params);
			} else {
				result = adminSchemaSvc.update(params);
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
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "admin/deleteschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteschemainfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		
		try {
			String schemaID = request.getParameter("SchemaID");
			
			CoviMap params = new CoviMap();
			params.put("SchemaID",schemaID);
			
			int formCnt = adminSchemaSvc.selectForm(params);
			
			if(formCnt == 0){
				adminSchemaSvc.delete(params);
				
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "성공적으로 삭제하였습니다.");
			}else{
				returnData.put("status", "NODATA");
				returnData.put("message", "해당 스키마로 등록된 양식이 존재하여, 삭제할 수 없습니다.");
			}			
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
	 * 
	 */
	@RequestMapping(value = "admin/addschemalayerpopup.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView addschemalayerpopup(Locale locale, Model model) {
		String returnURL = "admin/approval/addschemalayerpopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 
	 */
	@RequestMapping(value = "admin/processdefinitionsearch_popup.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView processDefinitionSearch(Locale locale, Model model) {
		String returnURL = "admin/approval/addschema_processdefinitionselect";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goFormAutoApvSet : 담당부서/담당업무 유형별 팝업 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goFormAutoApvSet.do", method = RequestMethod.GET)
	public ModelAndView goFormAutoApvSet(Locale locale, Model model) {
		String returnURL = "admin/approval/FormAutoApvSet";		
		return new ModelAndView(returnURL);
	}
	
	
	
	/**
	 * goFormAutoRecApvSet : 수신자 멀티선택
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goFormAutoRecApvSet.do", method = RequestMethod.GET)
	public ModelAndView goFormAutoRecApvSet(Locale locale, Model model) {
		String returnURL = "admin/approval/FormAutoRecApvSet";		
		return new ModelAndView(returnURL);
	}
	
	
	/**
	 * goJFListSelect : 담당업무 선택
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goJFListSelect.do", method = RequestMethod.GET)
	public ModelAndView goJFListSelect(Locale locale, Model model) {
		String returnURL = "admin/approval/JFListSelect";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * gosetwfschema : 미사용
	 * @param locale
	 * @param model
	 * @return mav
	 */
	/*
	@RequestMapping(value = "admin/gosetwfschema.do", method = RequestMethod.GET)
	public ModelAndView gosetwfschema(Locale locale, Model model) {
		String returnURL = "admin/approval/setwfschema";		
		return new ModelAndView(returnURL);
	}
	*/
}
