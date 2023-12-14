package egovframework.covision.coviflow.admin.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;
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
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.admin.service.AdminFormSvc;
import egovframework.covision.coviflow.form.service.FormSvc;


import egovframework.baseframework.util.json.JSONSerializer;

@Controller
public class AdminFormCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(AdminFormCon.class);
	
	@Autowired
	private AdminFormSvc adminFormSvc;
	
	@Autowired
	private FormSvc formSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	final String templateBasePath = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("isSaaStemplateForm.Path"),"");
	
	/**
	 * getAdminFormListData : 양식 관리 - 양식 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getAdminFormListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("EntCode");
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
			String isUse = request.getParameter("IsUse");
			String isCstf = Objects.toString(paramMap.get("IsCstf"),"N");
			
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			params.put("IsUse", isUse);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("isSaaS",isSaaS);
			params.put("IsCstf", isCstf);
			
			resultList = adminFormSvc.getAdminFormListData(params);
			
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();
			
			CoviList arrList = (CoviList)resultList.get("list");
			for(Object obj : arrList) {
				CoviMap list = (CoviMap)obj;
				if(assignedDomainList.size() == 0 || assignedDomainList.contains("ORGROOT") || assignedDomainList.contains(list.optString("CompanyCode"))) {
					list.put("ModifyAcl", "Y");
				} else {
					list.put("ModifyAcl", "N");
				}
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
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
	 * goAdminFormPopup : 양식 관리 -  특정양식 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goAdminFormPopup.do", method = RequestMethod.GET)
	public ModelAndView goAdminFormPopup(Locale locale, Model model) {		
		String returnURL = "admin/approval/AdminFormPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("isSaaS", isSaaS);
		return mav;
	}
	
	/**
	 * goAdminFormPopup : 양식 관리 - 웹에디터팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goAdminFormDocEditor.do", method = RequestMethod.GET)
	public ModelAndView goAdminFormDocEditor(Locale locale, Model model) {		
		String returnURL = "admin/approval/AdminFormDocEditor";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getAdminFormData : 양식 관리 - 특정 양식관리 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getAdminFormData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAdminFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String formID = request.getParameter("FormID");
			
			CoviMap params = new CoviMap();		
			params.put("FormID", formID);		
			params.put("isSaaS", isSaaS);
			CoviMap resultList = adminFormSvc.getAdminFormData(params);
			
			CoviList baseconfigList = (CoviList)resultList.get("map");			
			for(int i=0; i<baseconfigList.size();i++){
				String formDescDecode = new String(Base64.decodeBase64(baseconfigList.getJSONObject(i).getString("FormDesc")),StandardCharsets.UTF_8);
				String bodyDefaultDecode = new String(Base64.decodeBase64(baseconfigList.getJSONObject(i).getString("BodyDefault")),StandardCharsets.UTF_8);
				String formHelperContextDecode = new String(Base64.decodeBase64(baseconfigList.getJSONObject(i).getString("FormHelperContext")),StandardCharsets.UTF_8);		
				String formNoticeContextDecode = new String(Base64.decodeBase64(baseconfigList.getJSONObject(i).getString("FormNoticeContext")),StandardCharsets.UTF_8);
				baseconfigList.getJSONObject(i).put("FormDesc", formDescDecode);
				baseconfigList.getJSONObject(i).put("BodyDefault", bodyDefaultDecode);
				baseconfigList.getJSONObject(i).put("FormHelperContext", formHelperContextDecode);
				baseconfigList.getJSONObject(i).put("FormNoticeContext", formNoticeContextDecode);
			}
						
			returnList.put("list",baseconfigList);
			returnList.put("item", resultList.get("item"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
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
	 * insertAdminFormData : 양식 관리 - 양식 데이터 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/insertAdminFormData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertAdminFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap sqlParams = new CoviMap();
			
			String formClassID = request.getParameter("FormClassID");
			String schemaID = request.getParameter("SchemaID");
			String isUse = request.getParameter("IsUse");
			String revision = request.getParameter("Revision");
			String sortKey = request.getParameter("SortKey");
			String formName = request.getParameter("FormName");
			String formPrefix = request.getParameter("FormPrefix");
			String formDesc = replaceBodyContext(Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormDesc")),""));
			String sourcefile = request.getParameter("sourcefile");
			String fileName = request.getParameter("FileName");
			String bodyDefault = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("BodyDefault")),"");
			String bodyDefaultInlineImage = request.getParameter("BodyDefaultInlineImage");
			String bodyBackgroundImage = request.getParameter("BodyBackgroundImage");
			String extInfo = StringEscapeUtils.unescapeHtml(request.getParameter("ExtInfo"));
			String autoApprovalLine = StringEscapeUtils.unescapeHtml(request.getParameter("AutoApprovalLine"));
			String bodyType = request.getParameter("BodyType");
			String subTableInfo = StringEscapeUtils.unescapeHtml(request.getParameter("SubTableInfo"));
			String registerID = Objects.toString(SessionHelper.getSession("USERID"),"");
			String isEditFormHelper = request.getParameter("IsEditFormHelper");
			String formHelperContext = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormHelperContext")),"");
			String formHelperImages = request.getParameter("FormHelperImages");
			String isEditFormNotice = request.getParameter("IsEditFormNotice");
			String formNoticeContext = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormNoticeContext")),"");
			String formNoticeImages = request.getParameter("FormNoticeImages");
			String authDept = StringEscapeUtils.unescapeHtml(request.getParameter("AuthDept")); //Reserved1
			String mode = StringUtil.replaceNull(request.getParameter("Mode"));
			String companyCode = request.getParameter("CompanyCode");				
			String orgFileEntCode = request.getParameter("OrgFileEntCode");
			String aclAllYN = request.getParameter("AclAllYN");
			
			if(StringUtils.isBlank(formPrefix)) {
				String autoFromSeq = adminFormSvc.getAutoFormSeq();
				formPrefix = String.format("WF_AF_%s_%s", companyCode, autoFromSeq); 
				fileName = String.format("%s_V%s.html", formPrefix, revision);
			}
			CoviMap params = new CoviMap();
		
			params.put("FormClassID", formClassID);
			params.put("SchemaID", schemaID);
			params.put("IsUse", isUse);
			params.put("Revision", revision);
			params.put("SortKey", sortKey);
			params.put("FormName", ComUtils.RemoveScriptAndStyle(formName));
			params.put("FormPrefix", ComUtils.RemoveScriptAndStyle(formPrefix));
			params.put("FormDesc", formDesc);
			params.put("FileName", ComUtils.RemoveScriptAndStyle(fileName));
			params.putOrigin("BodyDefault", bodyDefault);
			params.putOrigin("BodyDefaultInlineImage", bodyDefaultInlineImage);
			params.putOrigin("BodyBackgroundImage", bodyBackgroundImage);
			params.put("ExtInfo", extInfo);
			params.put("AutoApprovalLine", autoApprovalLine);
			params.put("BodyType", bodyType);
			params.put("SubTableInfo", subTableInfo);
			params.put("RegID", registerID);
			params.put("IsEditFormHelper", isEditFormHelper);
			params.put("FormHelperContext", formHelperContext);
			params.put("FormHelperImages", formHelperImages);
			params.put("IsEditFormNotice", isEditFormNotice);
			params.put("FormNoticeContext", formNoticeContext);
			params.put("FormNoticeImages", formNoticeImages);
			params.put("AuthDept", authDept); //Reserved1
			params.put("CompanyCode", companyCode); //CompanyCode
			params.put("AclAllYN", aclAllYN);
			
			returnList.put("data", adminFormSvc.insertForms(params));

			CoviMap extInfoObj = CoviMap.fromObject(Objects.toString(extInfo,"{}"));
        	
            //JSON데이터를 넣어 JSON Object 로 만들어 준다.           
			CoviMap subTableInfoJsonObject = (CoviMap) JSONSerializer.toJSON(subTableInfo);
			
			if (!mode.equals("SaveAs")) {
				if(subTableInfoJsonObject.get("MainTable")!=null){
		            CoviList subMasterTableArray  = (CoviList) subTableInfoJsonObject.get("MainTable");            
		            sqlParams.put("MainTableName", extInfoObj.optString("MainTable"));
		            sqlParams.put("SubMasterTableArray", subMasterTableArray);
				}				
	                    
	            if(subTableInfoJsonObject.get("SubTable1")!=null){
		            CoviList subTable1Array = (CoviList) subTableInfoJsonObject.get("SubTable1");    
		            sqlParams.put("SubTable1Name", extInfoObj.optString("SubTable1"));
		            sqlParams.put("SubTable1Array", subTable1Array);
	            }				
	            
	            if(subTableInfoJsonObject.get("SubTable2")!=null){
		            CoviList subTable2Array = (CoviList) subTableInfoJsonObject.get("SubTable2"); 
		            sqlParams.put("SubTable2Name", extInfoObj.optString("SubTable2"));
		            sqlParams.put("SubTable2Array", subTable2Array);
	            }
	            
	            if(subTableInfoJsonObject.get("SubTable3")!=null){
		            CoviList subTable3Array = (CoviList) subTableInfoJsonObject.get("SubTable3");       
		            sqlParams.put("SubTable3Name", extInfoObj.optString("SubTable3"));
		            sqlParams.put("SubTable3Array", subTable3Array);
	            }
	            	            
	            if(subTableInfoJsonObject.get("SubTable4")!=null){
		            CoviList subTable4Array = (CoviList) subTableInfoJsonObject.get("SubTable4");       
		            sqlParams.put("SubTable4Name", extInfoObj.optString("SubTable4"));
		            sqlParams.put("SubTable4Array", subTable4Array);
	            }
			}
		        		
            returnList.put("createTable", adminFormSvc.createSubTableInfo(sqlParams));
            
            // 2022-12-06 다안기안 + 문서유통을 위해 문서유통 사용여부를 가져온다.
            String strUseScDistributionYN = "N";
            CoviMap paramsSchema = new CoviMap();
            paramsSchema.put("schemaID", schemaID);
            CoviMap formSchema = ((CoviList)(formSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0);
            if(!formSchema.get("SchemaContext").equals("")) {
				CoviMap schemaContext = formSchema.getJSONObject("SchemaContext");
				if(schemaContext.has("scDistribution") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scDistribution").getString("isUse"))) {
					strUseScDistributionYN = schemaContext.getJSONObject("scDistribution").getString("isUse");
				}
			}
            
            //신규파일만들기
            if(StringUtil.isNotNull(sourcefile)){            	
            	fileCopy(sourcefile,fileName, companyCode, orgFileEntCode);            	
            }else{
            	if(extInfoObj.has("FormCreateKind") && extInfoObj.optString("FormCreateKind").equals("1")) { // 신규만들기 일 때만 타도록 수정
	            	if(extInfoObj.has("UseEditYN") && extInfoObj.optString("UseEditYN").equalsIgnoreCase("Y")){ //웹에디터 사용
	            		fileCopy("default/JWF_Form_Editor_Default.html",fileName, companyCode, orgFileEntCode);            	
	            	}else if(extInfoObj.has("UseWebHWPEditYN") && extInfoObj.optString("UseWebHWPEditYN").equalsIgnoreCase("Y") && extInfoObj.has("UseMultiEditYN") && extInfoObj.optString("UseMultiEditYN").equalsIgnoreCase("Y") && strUseScDistributionYN.equalsIgnoreCase("Y")){ // 다안기안 + 문서유통
	            		fileCopy("default/JWF_Form_WebHWP_MultiEditor_Default.html",fileName, companyCode, orgFileEntCode);
	            	}else if(extInfoObj.has("UseHWPEditYN") && extInfoObj.optString("UseHWPEditYN").equalsIgnoreCase("Y")){ //hwp에디터 사용
	            		fileCopy("default/JWF_Form_hwpEditor_Default.html",fileName, companyCode, orgFileEntCode);
	            	}else{
	            		fileCopy("default/JWF_Form_Default.html",fileName, companyCode, orgFileEntCode);            	
	            	}
            	}
            }
            
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");			
		} catch (NullPointerException npE) {
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
	 * updateAdminFormData : 양식 관리 - 양식 데이터 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/updateAdminFormData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateAdminFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String formID = request.getParameter("FormID");
			String formClassID = request.getParameter("FormClassID");
			String schemaID = request.getParameter("SchemaID");
			String isUse = request.getParameter("IsUse");
			String revision = request.getParameter("Revision");
			String sortKey = request.getParameter("SortKey");
			String formName = request.getParameter("FormName");
			String formPrefix = request.getParameter("FormPrefix");
			String formDesc = replaceBodyContext(Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormDesc")),""));			
			String fileName = request.getParameter("FileName");
			String bodyDefault = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("BodyDefault")),"");
			String bodyDefaultInlineImage = request.getParameter("BodyDefaultInlineImage");
			String bodyBackgroundImage = request.getParameter("BodyBackgroundImage");
			String extInfo = StringEscapeUtils.unescapeHtml(request.getParameter("ExtInfo"));
			String autoApprovalLine = StringEscapeUtils.unescapeHtml(request.getParameter("AutoApprovalLine"));
			String bodyType = request.getParameter("BodyType");
			String subTableInfo = StringEscapeUtils.unescapeHtml(request.getParameter("SubTableInfo"));
			String modifierID = Objects.toString(SessionHelper.getSession("USERID"),"");
			String isEditFormHelper = request.getParameter("IsEditFormHelper");
			String formHelperContext = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormHelperContext")),"");
			String formHelperImages = request.getParameter("FormHelperImages");
			String isEditFormNotice = request.getParameter("IsEditFormNotice");
			String formNoticeContext = Objects.toString(StringEscapeUtils.unescapeHtml(request.getParameter("FormNoticeContext")),"");
			String formNoticeImages = request.getParameter("FormNoticeImages");
			String authDept = StringEscapeUtils.unescapeHtml(request.getParameter("AuthDept")); //Reserved1
			String aclAllYN = StringUtil.replaceNull(request.getParameter("AclAllYN"));
			String companyCode = StringUtil.replaceNull(request.getParameter("CompanyCode"));
			
			CoviMap params = new CoviMap();
			
			params.put("FormID", formID);
			params.put("FormClassID", formClassID);
			params.put("SchemaID", schemaID);
			params.put("IsUse", isUse);
			params.put("Revision", revision);
			params.put("SortKey", sortKey);
			params.put("FormName", ComUtils.RemoveScriptAndStyle(formName));
			params.put("FormPrefix", formPrefix);
			params.put("FormDesc", formDesc);
			params.put("FileName", ComUtils.RemoveScriptAndStyle(fileName));
			params.putOrigin("BodyDefault", bodyDefault);
			params.putOrigin("BodyDefaultInlineImage", bodyDefaultInlineImage);
			params.putOrigin("BodyBackgroundImage", bodyBackgroundImage);
			params.put("ExtInfo", extInfo);
			params.put("AutoApprovalLine", autoApprovalLine);
			params.put("BodyType", bodyType);
			params.put("SubTableInfo", subTableInfo);
			params.put("ModID", modifierID);
			params.put("IsEditFormHelper", isEditFormHelper);
			params.put("FormHelperContext", formHelperContext);
			params.put("FormHelperImages", formHelperImages);
			params.put("IsEditFormNotice", isEditFormNotice);
			params.put("FormNoticeContext", formNoticeContext);
			params.put("FormNoticeImages", formNoticeImages);
			params.put("AuthDept", authDept);
			params.put("AclAllYN", aclAllYN);
			params.put("CompanyCode", companyCode);
			params.put("isSaaS",isSaaS);
			
			returnList.put("data", adminFormSvc.updateAdminFormData(params));
            
			CoviMap map = new CoviMap();
			if(aclAllYN.equals("N")) {
				
				CoviMap obj = CoviMap.fromObject(authDept);
				CoviList result = (CoviList) obj.get("item");
				
				CoviList resultList = new CoviList();
				for(int i=0; i<result.size(); i++){
					CoviMap tmp = new CoviMap();
					CoviMap aclObj = CoviMap.fromObject(result.getJSONObject(i));

					tmp.put("ObjectType", "FORM");
					tmp.put("TargetID", formID);
					tmp.put("CompanyCode", aclObj.getString("CompanyCode"));
					tmp.put("GroupCode", aclObj.getString("GroupCode"));
					tmp.put("GroupType", aclObj.getString("GroupType"));
					tmp.put("RegisterCode", modifierID);
					
					resultList.add(tmp);
				}
				
				map.put("FormID", formID);
				map.put("list", resultList);
				map.put("size", result.size()-1);
				adminFormSvc.updateAclListFormData(map);
			}else {
				map.put("ObjectType", "FORM");
				map.put("FormID", formID);
				adminFormSvc.deleteAclListFormData(map);
			}
			JSONParser parser = new JSONParser();
			CoviMap jsonObj = (CoviMap)parser.parse(extInfo);
			
			// 가로양식 설정값 Redis 갱신.
			formSvc.cacheFormExtInfo(formID, companyCode, formPrefix, jsonObj);
			
			// 연동양식(외부연동)인 경우 jwf_formslegacy 에 insert
			params.clear();
			params.put("FormPrefix", formPrefix);
			params.put("FormID", formID);
			params.put("Revision", revision);
			params.put("CompanyCode", companyCode);
			
			if(jsonObj.containsKey("UseOtherLegacyForm") && jsonObj.optString("UseOtherLegacyForm").equals("Y")) {
				params.put("UseOtherLegacyForm", "Y");
			}
			else {
				params.put("UseOtherLegacyForm", "N");
			}
			adminFormSvc.insertFormsLegacy(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
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
	 * deleteAdminFormData : 양식 관리 - 양식 데이터 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/deleteAdminFormData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteAdminFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String formID = request.getParameter("FormID");
			
			CoviMap params = new CoviMap();
			
			params.put("FormID", formID);
			params.put("ObjectType", "FORM");
			returnList.put("data", adminFormSvc.deleteAdminFormData(params));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
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
	 * getFormClassListSelectData : 양식분류 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getFormClassListSelectData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormClassListSelectData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String entCode = request.getParameter("entCode");

			CoviMap params = new CoviMap();
			params.put("isSaaS", isSaaS);
			params.put("entCode", entCode);

			CoviMap resultList = adminFormSvc.getFormClassListSelectData(params);
			CoviList formCLassListData = (CoviList)resultList.get("list");
			
			for(int i=0; i<formCLassListData.size(); i++) { // 다국어 처리
				CoviMap jsonObj = (CoviMap) formCLassListData.get(i);
				jsonObj.put("optionText", DicHelper.getDicInfo(jsonObj.optString("optionText"), SessionHelper.getSession("lang")));
			}
				
			returnList.put("list", formCLassListData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
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
	 * getSchemaListSelectData : 양식프로세스  리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getSchemaListSelectData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSchemaListSelectData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String entCode = request.getParameter("entCode");

			CoviMap params = new CoviMap();
			params.put("isSaaS", isSaaS);
			params.put("entCode", entCode);
			
			CoviMap resultList = adminFormSvc.getSchemaListSelectData(params);
			CoviList schemaListData = (CoviList)resultList.get("list");
				
			returnList.put("list", schemaListData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
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
	 * goAdminFormPopup : 양식 관리 -  원본양식파일 선택  레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goFormFileList.do", method = RequestMethod.GET)
	public ModelAndView goFormFileList(Locale locale, Model model) {		
		String returnURL = "admin/approval/FormFileList";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getFormFileList : 양식 관리 -  원본양식파일 선택 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getFormFileList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormFileList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap)
	{
		
		CoviMap returnList = new CoviMap();

		try {
			String domainCode = request.getParameter("domainCode");						
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			String filePath;
			
			if(osType.equals("WINDOWS"))
				filePath = PropertiesUtil.getGlobalProperties().getProperty("templateWINDOW.path");
			else
				filePath = PropertiesUtil.getGlobalProperties().getProperty("templateUNIX.path");
			
			if(isSaaS.equals("Y") && templateBasePath.contains("{0}")) {
				filePath = templateBasePath.replace("{0}", domainCode);
			}
			
			// 지정된 경로에 해당하는 파일 객체 file을 생성한다. 
			File file = new File(FileUtil.checkTraversalCharacter(filePath));
		
		
			// 파일 리스트를 String타입 배열로 반환받아서 fileList로 저장한다.
			String[] fileList = file.list((dir, name) -> FilenameUtils.getExtension(name).equalsIgnoreCase("html"));
			Arrays.sort(fileList, String.CASE_INSENSITIVE_ORDER);
			
			CoviList formFileListData = new CoviList();
			
			// 파일 리스트인 fileList의 모든 요소(파일 명)를 출력해준다.
			if(file.length() >= 1){
				for (String fileName : fileList) {				
					formFileListData.add(fileName);
				}
			}
				
			returnList.put("list", formFileListData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
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
	 * getAutoApprovalLineDeptlist : 자동결재선 - 트리용 부서 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getAutoApprovalLineDeptlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAutoApprovalLineDeptlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			CoviList resultList = new CoviList();
			
			CoviMap params = new CoviMap();
			CoviList domainList = ComUtils.getAssignedDomainID();
			params.put("assignedDomain", domainList);
			
			CoviList result = (CoviList) adminFormSvc.getAutoApprovalLineDeptlist(params).get("list");
						
			for(Object jsonobject : result){
				CoviMap tmp = new CoviMap();
				CoviMap tmp1 = (CoviMap) jsonobject;
				tmp.put("no", getSortNo(tmp1.optString("SortPath")));
				tmp.put("nodeName", tmp1.get("DisplayName"));
				tmp.put("nodeValue", tmp1.get("DN_Code"));
				tmp.put("dn_id", tmp1.get("DN_ID"));
				tmp.put("type", "0");
				tmp.put("pno", getParentSortNo(tmp1.optString("SortPath")));
				tmp.put("chk", "Y");
				tmp.put("rdo", "N");
				tmp.put("url", "#");
				
				resultList.add(tmp);
			}
			
			returnList.put("list", resultList);
			returnList.put("list2", resultList);
			returnList.put("list3", resultList);
			returnList.put("list4", resultList);
			returnList.put("list5", resultList);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
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
	 * getAutoApprovalLineRegionlist : 자동결재선 - 트리용 사업장 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getAutoApprovalLineRegionlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAutoApprovalLineRegionlist(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
			
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		try{
			CoviMap params = new CoviMap();
			params.put("assignedDomain", ComUtils.getAssignedDomainCode());
			CoviList result = (CoviList) adminFormSvc.getAutoApprovalLineRegionlist(params).get("list");
			
			for(Object jsonobject : result){
				CoviMap tmp = new CoviMap();
				CoviMap tmp1 = (CoviMap) jsonobject;
				tmp.put("no", getSortNo(tmp1.optString("SortPath")));
				tmp.put("nodeName", tmp1.get("DisplayName"));
				tmp.put("nodeValue", tmp1.get("GR_Code"));
				tmp.put("gr_id", tmp1.get("GR_ID"));
				tmp.put("type", "0");
				// 여러 회사의 사업장을 가져올경우, 트리구조 root가 맞지 않아 오류 발생 --> 사업장은 트리구조가 아니므로 pno고정하고 1depth로 모두 나오도록
				//tmp.put("pno", getParentSortNo(tmp1.optString("SortPath")));
				tmp.put("pno", "000000000000000");
				tmp.put("chk", "Y");
				tmp.put("rdo", "N");
				tmp.put("url", "#");
				
				resultList.add(tmp);
			}
			
			returnList.put("list", resultList);
			returnList.put("list2", resultList);
			returnList.put("list3", resultList);
			returnList.put("list4", resultList);
			returnList.put("list5", resultList);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
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
	 * 하위테이블 명 중복 체크
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/checkDuplidationTableName.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDuplidationTableName(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap){
		CoviMap returnList = new CoviMap();
		Boolean result = false;
		
		String tableName = request.getParameter("tableName");
		
		try{
			CoviMap params = new CoviMap();
			
			params.put("tableName", ComUtils.RemoveScriptAndStyle(tableName));
			
			result = adminFormSvc.checkDuplidationTableName(params);
			
			returnList.put("result", result);

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
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
	 * 회사별 formprefix 및 버전 중복 체크
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/addFormDuplicateCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addFormDuplicateCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap){
		CoviMap returnList = new CoviMap();
		Boolean result = false;
		
		try{
			CoviMap params = new CoviMap();
			
			params.put("Formprefix", request.getParameter("Formprefix"));
			params.put("Revision", request.getParameter("Revision"));
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			params.put("isSaaS", request.getParameter("isSaaS"));			
			
			result = adminFormSvc.addFormDuplicateCheck(params);
			returnList.put("result", result);

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
	
	//SortPath를 통해  간략화된 SortNo 생성
	public String getSortNo(String pStr){
		if(pStr == null || pStr.equals("")) {
			return "";
		} else {
			String[] strArr = pStr.split(";");
			StringBuilder strReturn = new StringBuilder();
			
			for(String str : strArr){
				strReturn.append(str);
			}
			
			return strReturn.toString();	
		}
	}
	
	//SortPath를 통해 부모의 SortNo 생성
	public String getParentSortNo(String pStr){
		String[] strArr = pStr.split(";");
		StringBuilder resultStr = new StringBuilder();
		
		for(int i=0;i<strArr.length - 1;i++){
			resultStr.append(strArr[i] + ";");
		}
		
		return getSortNo(resultStr.toString());
	}
	
		
	public void fileCopy(String originalfile, String newfile, String getCompanyCode, String getOrgFileEntCode){
		String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		String filePath;
		String companyPath;
		String rootPath = "";			
		
		if(osType.equals("WINDOWS"))
			filePath = PropertiesUtil.getGlobalProperties().getProperty("templateWINDOW.path");
		else
			filePath = PropertiesUtil.getGlobalProperties().getProperty("templateUNIX.path");
		
		companyPath = filePath;		
		if(isSaaS.equals("Y") && templateBasePath.contains("{0}")) {
			rootPath = templateBasePath.replace("{0}", getOrgFileEntCode);
			companyPath = templateBasePath.replace("{0}", getCompanyCode);
			filePath = rootPath;
			
			File folder = new File(FileUtil.checkTraversalCharacter(companyPath));
			
			//폴더생성
			boolean isExistfolder = folder.exists();
			if(!isExistfolder && !folder.mkdirs()) {
				LOGGER.warn("Failed to make directories.");
			}
		}
			
		try(
			FileInputStream fis = new FileInputStream(FileUtil.checkTraversalCharacter(filePath+originalfile));
			FileOutputStream fos = new FileOutputStream(FileUtil.checkTraversalCharacter(companyPath+newfile));
		) {
			int data = 0;
		    while((data=fis.read())!=-1) {
		     fos.write(data);
		    }
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	    
	    //js파일
		try(
		    FileInputStream fisJS = new FileInputStream(filePath+FilenameUtils.getPath(originalfile)+FilenameUtils.getBaseName(originalfile)+".js");
			FileOutputStream fosJS = new FileOutputStream(companyPath+FilenameUtils.getBaseName(newfile)+".js");
		) {
			int data = 0;
		    while((data=fisJS.read())!=-1) {
		     fosJS.write(data);
		    }
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	public String replaceBodyContext(String oBodyContext){
		if(oBodyContext == null)
			return null;
		return new String(Base64.encodeBase64(oBodyContext.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
	}
}
