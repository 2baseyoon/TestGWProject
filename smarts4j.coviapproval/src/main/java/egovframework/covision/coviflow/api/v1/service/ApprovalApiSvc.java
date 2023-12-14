package egovframework.covision.coviflow.api.v1.service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.coviflow.form.dto.UserInfo;

public interface ApprovalApiSvc {
	public CoviMap getFormData(CoviMap params) throws Exception;
	public CoviMap getFormObjForProcess(CoviMap param) throws Exception;
	public CoviMap getProcessData(CoviMap baseInfo) throws Exception;
	public CoviMap getFormInstanceData(CoviMap baseInfo) throws Exception;
	public CoviMap getFormTempInstID(CoviMap baseInfo) throws Exception;
	public CoviMap getFormsData(CoviMap baseInfo) throws Exception;
	public CoviMap getSchemaData(CoviMap baseInfo) throws Exception;
	public CoviMap getDomainData(CoviMap baseInfo) throws Exception;
	public CoviMap getDomainDataTempBox(CoviMap baseInfo, UserInfo userInfo) throws Exception;
	public CoviList getCommentData(CoviMap baseInfo) throws Exception;
	public CoviList getFileInfosData(CoviMap baseInfo) throws Exception;
	public CoviList getButtonList(String strReadMode, String strSessionUserID, String strSessionApvDeptID, String strSessionDnCode, CoviMap processObj, CoviMap approvalLine, CoviMap formInstance, CoviMap schemaContext) throws Exception;
	public String getApiFormUrl(CoviMap processObj, CoviMap formInstance, CoviMap requestData) throws Exception;
	public CoviMap getFormPdf(HttpServletRequest request, HttpServletResponse response, CoviMap formInfo) throws Exception;
	public int setDeputyData(CoviMap baseInfo) throws Exception;
	public CoviMap getUserFormList() throws Exception;
	public int setSignData(CoviMap baseInfo);
	public CoviList getReceiptList(CoviMap param) throws Exception;
}
