package egovframework.covision.coviflow.manage.web;

import java.util.Locale;
import java.util.Map;
import java.util.Objects;

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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AdminFormSvc;
import egovframework.covision.coviflow.admin.service.AdminSchemaSvc;
import egovframework.covision.coviflow.common.util.ApprovalUtil;
import egovframework.covision.coviflow.form.service.FormFileCacheSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceConfigSvc;


@Controller
public class ApprovalSchemaManageCon {
	
	private Logger LOGGER = LogManager.getLogger(ApprovalSchemaManageCon.class);
	
	@Autowired
	private AdminSchemaSvc adminSchemaSvc;
	
	@Autowired
	private LegacyInterfaceConfigSvc legacyInterfaceConfigSvc;
	
	@Autowired
	private FormFileCacheSvc formFileCacheSvc;
	
	@Autowired
	public FormSvc formSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "manage/getschemalist.do", method = {RequestMethod.GET,RequestMethod.POST})
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
			
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
			String sel_Search = Objects.toString(request.getParameter("sel_Search"), "");
			String search = Objects.toString(request.getParameter("search"), "");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("DomainID", paramMap.get("DomainID"));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			params.put("sel_Search", sel_Search);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			
			resultList = adminSchemaSvc.select(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * 
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "manage/getschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
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
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "manage/setschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
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
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
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
	@RequestMapping(value = "manage/deleteschemainfo.do", method = {RequestMethod.GET,RequestMethod.POST})
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
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	
	/**
	 * 
	 */
	@RequestMapping(value = "manage/addschemalayerpopup.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView addschemalayerpopup(Locale locale, Model model) {
		String returnURL = "manage/approval/addschemalayerpopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 
	 */
	@RequestMapping(value = "manage/processdefinitionsearch_popup.do", method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView processDefinitionSearch(Locale locale, Model model) {
		String returnURL = "manage/approval/addschema_processdefinitionselect";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goFormAutoApvSet : 담당부서/담당업무 유형별 팝업 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goFormAutoApvSet.do", method = RequestMethod.GET)
	public ModelAndView goFormAutoApvSet(Locale locale, Model model) {
		String returnURL = "manage/approval/FormAutoApvSet";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goFormAutoRecApvSet : 수신자 멀티선택
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goFormAutoRecApvSet.do", method = RequestMethod.GET)
	public ModelAndView goFormAutoRecApvSet(Locale locale, Model model) {
		String returnURL = "manage/approval/FormAutoRecApvSet";		
		return new ModelAndView(returnURL);
	}
	
	
	/**
	 * goJFListSelect : 담당업무 선택
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goJFListSelect.do", method = RequestMethod.GET)
	public ModelAndView goJFListSelect(Locale locale, Model model) {
		String returnURL = "manage/approval/JFListSelect";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * ApvMode 별 연동처리 세부설정 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "manage/goLegacyInterfaceConfigPopup.do", method = RequestMethod.GET)
	public ModelAndView goLegacyInterfaceConfigPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/LegacyInterfaceConfigPopup";	
		return new ModelAndView(returnURL);
	}
	
	/**
	 * Event 별 연동정보 목록조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/getLegacyConfigList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getLegacyConfigList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			CoviList resultList = null;
			CoviMap params = new CoviMap(paramMap);			
			
			resultList = legacyInterfaceConfigSvc.getLegacyIfConfig(params);

			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * 후처리 연동 세부설정 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/saveLegacyConfig.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap saveLegacyConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);
			
			legacyInterfaceConfigSvc.saveLegacyIfConfig(params.optJSONObject("ConfigData"));
			returnData.put("status", Return.SUCCESS);	
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * WSDL URL 및 Operation Name 기준으로 Envelope XML ( Templates ) 가져오기.
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/getEnvelopeTemplates.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getEnvelopeTemplates(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);			
			
			CoviMap result = legacyInterfaceConfigSvc.extractRequestSoapTemplates(params);
			returnList.put("TemplateXML", result.getString("TemplateXML"));

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	
	@RequestMapping(value = "manage/getRequestObjectFromWSDL.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getRequestObjectFromWSDL(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);			
			
			CoviList result = legacyInterfaceConfigSvc.parseRequestInfoByCxf(params);
			returnList.put("SerializedTemplate", result);

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	 * 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/deleteLegacyConfig.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap deleteLegacyConfig(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap); //LegacyConfigID
			
			int cnt = legacyInterfaceConfigSvc.deleteConfig(params);
			if(cnt <= 0) {
				throw new Exception("No affected row.");
			}
			returnData.put("status", Return.SUCCESS);	
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "manage/updateLegacyConfigUse.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap updateLegacyConfigUse(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap); // IsUse, LegacyConfigID
			
			int cnt = legacyInterfaceConfigSvc.updateLegacyIfConfigUse(params);
			if(cnt <= 0) {
				throw new Exception("No affected row.");
			}
			returnData.put("status", Return.SUCCESS);	
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}	

	@RequestMapping(value = "manage/goLegacyInterfaceConfigFormSelectPopup.do", method = RequestMethod.GET)
	public ModelAndView goLegacyInterfaceConfigFormSelectPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/LegacyInterfaceConfigFormSelectPopup";	
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/goLegacyInterfaceConfigFieldPopup.do", method = RequestMethod.GET)
	public ModelAndView goLegacyInterfaceConfigFieldPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/LegacyInterfaceConfigFieldPopup";	
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 항목정보 조회 (작성시 참고용 화면)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "manage/getFormFieldInfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap GetFormFieldInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap(paramMap);			
			String lang = SessionHelper.getSession("lang"); 
			
			// Base file path
        	String formCompanyCode = null;
        	String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
        	if(isSaaS.equals("Y")) {
        		CoviMap q_params = new CoviMap();
        		q_params.put("FormID", params.getString("formID"));
        		q_params.put("FormPrefix", params.getString("formPrefix"));
        		formCompanyCode = formSvc.selectFormCompanyCode(q_params);
        	}
        	String filePath = ApprovalUtil.getTemplatePath(formCompanyCode);
        	
			// Common
			String strCommonFieldsTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormCommonFields.html", "UTF8");

			// Form
    		// form 정보
			CoviMap forms = (((CoviList)(formSvc.selectForm(params)).get("list")).getJSONObject(0)); // param : formID
			String strFormFileName = forms.getString("FileName").substring(0, forms.getString("FileName").lastIndexOf("."));
			String fileurl = filePath + strFormFileName + ".html";
			
			String strBodyTempl = formFileCacheSvc.readAllText(lang, fileurl, "UTF8");
			
			returnList.put("CommonFieldHtml", strCommonFieldsTempl);
			returnList.put("BodyFieldHtml", strBodyTempl);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
	
	@RequestMapping(value = "manage/goLegacyInterfaceCheckPopup.do", method = RequestMethod.GET)
	public ModelAndView goLegacyInterfaceCheckPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/LegacyInterfaceCheckPopup";	
		return new ModelAndView(returnURL);
	}
	
}
