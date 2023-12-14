package egovframework.covision.coviflow.admin.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.Objects;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AdminFormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("adminFormService")
public class AdminFormSvcImpl extends EgovAbstractServiceImpl implements AdminFormSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private EditorService editorService;
	
	@Override
	public CoviMap getAdminFormListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.adminForm.selectAdminFormListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.adminForm.selectAdminFormList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormID,FormName,IsUse,FormDesc,RegDate,FileName,Revision,SchemaID,SortKey,BodyType,FormPrefix,EntCode,SchemaName,FORM_KEY,FormClassID,FormClassName,EntName,CompanyCode,IsFree,Price"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap getFormClassListSelectData(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.adminForm.selectFormClassListSelectData", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText"));	
		return resultList;
	}
	
	@Override
	public CoviMap getSchemaListSelectData(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.adminForm.selectSchemaListSelectData", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText,SchemaDesc"));	
		return resultList;
	}
	
	@Override
	public int insertForms(CoviMap params)throws Exception{
		//Editor 처리 - BodyDefault
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Approval");  //BizSection
		editorParam.put("imgInfo", params.getString("BodyDefaultInlineImage"));
		editorParam.put("backgroundImage", params.getString("BodyBackgroundImage"));
		editorParam.put("objectID", "0");     
		editorParam.put("objectType", "Form"); 
		editorParam.put("messageID", "0");  
		editorParam.putOrigin("bodyHtml",params.getString("BodyDefault"));   

		CoviMap bodyEditorInfo = editorService.getContent(editorParam); 
		
		if(bodyEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
			 throw new Exception("InlineImage move BackStorage Error");
		}
		
		params.put("BodyDefault",  replaceBodyContext(bodyEditorInfo.getString("BodyHtml")));
		
		//Editor 처리 - FormHelperContext
		editorParam.put("imgInfo", params.getString("FormHelperImages")); 
		editorParam.put("objectType", "FormHelper"); 
		editorParam.putOrigin("bodyHtml",params.getString("FormHelperContext"));   
		
		CoviMap helperEditorInfo = editorService.getContent(editorParam); 
		
		if(helperEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
			 throw new Exception("InlineImage move BackStorage Error");
		}
		
		params.put("FormHelperContext",  replaceBodyContext(helperEditorInfo.getString("BodyHtml")));
		
		//Editor 처리 - FormNoticeContext
		editorParam.put("imgInfo", params.getString("FormNoticeImages")); 
		editorParam.put("objectType", "FormNotice"); 
		editorParam.putOrigin("bodyHtml",params.getString("FormNoticeContext"));   
		 
		CoviMap noticeEditorInfo = editorService.getContent(editorParam); 
		
		if(noticeEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
			 throw new Exception("InlineImage move BackStorage Error");
		}
		
		params.put("FormNoticeContext",  replaceBodyContext(noticeEditorInfo.getString("BodyHtml")));
		
		int cnt = coviMapperOne.insert("admin.adminForm.insertForms", params);
		if(params.getString("FormID") != null) { // mssql 인 경우 대비하여 추가함.
			cnt = 1;
		}
		
		editorParam.put("objectID", params.getString("FormID"));
		editorParam.addAll(bodyEditorInfo);
		editorService.updateFileObjectID(editorParam);
		
		editorParam.addAll(helperEditorInfo);
		editorService.updateFileObjectID(editorParam);
		
		editorParam.addAll(noticeEditorInfo);
		editorService.updateFileObjectID(editorParam);
		
		if(params.optString("AclAllYN").equals("N")) {
			CoviMap map = new CoviMap();
			
			CoviMap obj = CoviMap.fromObject(params.getString("AuthDept"));
			CoviList result = (CoviList) obj.get("item");
			
			CoviList resultList = new CoviList();
			for(Object jsonobject : result){
				CoviMap tmp = new CoviMap();
				CoviMap aclObj = CoviMap.fromObject(jsonobject);
				
				tmp.put("ObjectType", "FORM");
				tmp.put("TargetID", params.getString("FormID"));
				tmp.put("CompanyCode", aclObj.get("CompanyCode"));
				tmp.put("GroupCode", aclObj.get("GroupCode"));
				tmp.put("GroupType", aclObj.get("GroupType"));
				tmp.put("RegisterCode", params.getString("RegID"));
				
				resultList.add(tmp);
			}
			map.put("FormID", params.getString("FormID"));
			map.put("list", resultList);
			map.put("size", result.size()-1);
			updateAclListFormData(map);
		}
		
		
		// 연동양식(외부연동)인 경우 jwf_formslegacy 에 insert
		params.put("FormPrefix", params.getString("FormPrefix"));
		params.put("FormID", params.getString("FormID"));
		CoviMap extInfoObj = CoviMap.fromObject(Objects.toString(params.getString("ExtInfo"),"{}"));
		if(extInfoObj.containsKey("UseOtherLegacyForm") && extInfoObj.optString("UseOtherLegacyForm").equals("Y")) {
			params.put("UseOtherLegacyForm", "Y");
		}
		else {
			params.put("UseOtherLegacyForm", "N");
		}
		insertFormsLegacy(params);
		
		return cnt;
	}
	
	
	/**
	 * 부서 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAutoApprovalLineDeptlist(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("admin.adminForm.selectDeptList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DN_ID,DN_Code,DisplayName,SortKey,SortPath,IsUse"));
		return resultList;
	}
	
	/**
	 * 사업장 목록 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAutoApprovalLineRegionlist(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("admin.adminForm.selectRegionList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GR_ID,GR_Code,DN_Code,GroupType,GroupPath,DisplayName,SortKey,SortPath,IsUse,IsDisplay,DataStatus"));
		return resultList;
	}
	
	
	/**
	 * 특정 양식관리 정보 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAdminFormData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.adminForm.selectAdminFormData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "FormID,FormClassID,SchemaID,IsUse,Revision,SortKey,FormName,FormPrefix,FormDesc,FileName,BodyDefault,EntCode,ExtInfo,AutoApprovalLine,BodyType,SubTableInfo,RegID,RegDate,ModID,ModDate,FormHelperContext,FormNoticeContext,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,CompanyCode,FormIcon"));
		
		CoviList aclList = coviMapperOne.list("admin.adminForm.selectFormsAclSelect", params);		
		resultList.put("item", CoviSelectSet.coviSelectJSON(aclList));
		
		return resultList;
	}
	
	/**
	 * 특정 양식관리 정보 수정
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int updateAdminFormData(CoviMap params) throws Exception {
		//Editor 처리  - BodyDefault
		CoviMap editorParam = new CoviMap();
		editorParam.put("serviceType", "Approval");  //BizSection
		editorParam.put("imgInfo", params.getString("BodyDefaultInlineImage"));
		editorParam.put("backgroundImage", params.getString("BodyBackgroundImage"));
		editorParam.put("objectID", params.getString("FormID"));     
		editorParam.put("objectType", "Form");   
		editorParam.put("messageID", "0");  
		editorParam.putOrigin("bodyHtml",params.getString("BodyDefault"));   

		CoviMap editorInfo = editorService.getContent(editorParam); 
		
		if(editorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
			 throw new Exception("InlineImage move BackStorage Error");
		}
		
		params.put("BodyDefault",  replaceBodyContext(editorInfo.getString("BodyHtml")));
		
		if (params.containsKey("IsEditFormHelper") && params.optString("IsEditFormHelper").equals("Y")) {
			//Editor 처리 - FormHelperContext
			editorParam.put("imgInfo", params.getString("FormHelperImages")); 
			editorParam.put("objectType", "FormHelper"); 
			editorParam.putOrigin("bodyHtml",params.getString("FormHelperContext"));   
			
			CoviMap helperEditorInfo = editorService.getContent(editorParam); 
			
			if(helperEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
				 throw new Exception("InlineImage move BackStorage Error");
			}
			
			params.put("FormHelperContext",  replaceBodyContext(helperEditorInfo.getString("BodyHtml")));
		}
		
		if (params.containsKey("IsEditFormNotice") && params.optString("IsEditFormNotice").equals("Y")) {
			//Editor 처리 - FormNoticeContext
			editorParam.put("imgInfo", params.getString("FormNoticeImages")); 
			editorParam.put("objectType", "FormNotice"); 
			editorParam.putOrigin("bodyHtml",params.getString("FormNoticeContext"));   
			
			CoviMap noticeEditorInfo = editorService.getContent(editorParam); 
			
			if(noticeEditorInfo.getString("BodyHtml").indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) > -1) {
				 throw new Exception("InlineImage move BackStorage Error");
			}
			
			params.put("FormNoticeContext",  replaceBodyContext(noticeEditorInfo.getString("BodyHtml")));
		}
		
		return coviMapperOne.update("admin.adminForm.updateAdminFormData", params);
	}
	
	//양식별 권한등록
	@Override
	public void updateAclListFormData(CoviMap params) throws Exception {
		coviMapperOne.delete("admin.adminForm.deleteFormsAcl", params);
		coviMapperOne.insert("admin.adminForm.insertFormsAcl", params);
	}
	
	//양식별 권한삭제
	@Override
	public void deleteAclListFormData(CoviMap params) throws Exception {
		coviMapperOne.delete("admin.adminForm.deleteAllFormsAcl", params);
	}

	// 특정 양식관리 정보 삭제
	@Override
	public int deleteAdminFormData(CoviMap params) throws Exception {
		int cnt;
		cnt = coviMapperOne.update("admin.adminForm.deleteAdminFormData_jwf_processUP", params);
		cnt = coviMapperOne.update("admin.adminForm.deleteAdminFormData_jwf_processArchiveUP", params);
		cnt = coviMapperOne.update("admin.adminForm.deleteAdminFormData_jwf_workitemarchiveUP", params);
		cnt = coviMapperOne.delete("admin.adminForm.deleteAdminFormData_jwf_formhistory", params);
		cnt = coviMapperOne.delete("admin.adminForm.deleteAdminFormData_jwf_forminstance", params);
		cnt = coviMapperOne.delete("admin.adminForm.deleteAdminFormData_jwf_formstempinstbox", params);
		cnt = coviMapperOne.delete("admin.adminForm.deleteAdminFormData_jwf_forms", params);
		coviMapperOne.delete("admin.adminForm.deleteAllFormsAcl", params);
		return cnt;
	}
	
	/**
	 * SubTableInfo 테이블 생성
	 */
	@Override
	public int createSubTableInfo(CoviMap params) throws Exception {
		int cnt = 0;		
		if(params.containsKey("SubMasterTableArray")){
			cnt = coviMapperOne.update("admin.adminForm.CreateSubTableInfoSql", params);
		}
		if(params.containsKey("SubTable1Array")){
			cnt = coviMapperOne.update("admin.adminForm.CreateSubTable1Sql", params);
		}
		if(params.containsKey("SubTable2Array")){
			cnt = coviMapperOne.update("admin.adminForm.CreateSubTable2Sql", params);
		}
		if(params.containsKey("SubTable3Array")){
			cnt = coviMapperOne.update("admin.adminForm.CreateSubTable3Sql", params);
		}
		if(params.containsKey("SubTable4Array")){
			cnt = coviMapperOne.update("admin.adminForm.CreateSubTable4Sql", params);
		}
		return cnt;
	}

	@Override
	public Boolean checkDuplidationTableName(CoviMap params) {
		int cnt = 0;
		
		cnt = coviMapperOne.selectOne("admin.adminForm.checkDuplidationTableName", params);
		
		return (cnt == 0);
	}
	
	@Override
	public Boolean addFormDuplicateCheck(CoviMap params) {
		int cnt = 0;
		
		cnt = coviMapperOne.selectOne("admin.adminForm.addFormDuplicateCheck", params);
		
		return (cnt == 0);
	}
	
	public String replaceBodyContext(String oBodyContext){
		if(oBodyContext == null)
			return null;
		
		return new String(Base64.encodeBase64(oBodyContext.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
	}
	
	@Override
	public void insertFormsLegacy(CoviMap params) throws Exception{
		if(params.optString("UseOtherLegacyForm").equals("Y")) {
			int cnt = coviMapperOne.selectOne("admin.adminForm.selectFormsLegacyCnt", params);
			
			if(cnt == 0){
				coviMapperOne.insert("admin.adminForm.insertFormsLegacy", params);
			}else{
				//coviMapperOne.update("admin.adminForm.updateFormsLegacy", params);
			}
		}else {
			// delete
			coviMapperOne.delete("admin.adminForm.deleteFormsLegacy", params);
		}
	}
	
	@Override
	public String getAutoFormSeq() throws Exception{
		return coviMapperOne.selectOne("admin.adminForm.getAutoFormSeq");
	}
}
