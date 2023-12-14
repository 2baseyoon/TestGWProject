package egovframework.covision.coviflow.admin.service;

import egovframework.baseframework.data.CoviMap;


public interface AdminFormSvc {
	public CoviMap getAdminFormListData(CoviMap params) throws Exception;
	public CoviMap getFormClassListSelectData(CoviMap params) throws Exception;
	public CoviMap getSchemaListSelectData(CoviMap params) throws Exception ;
	public int insertForms(CoviMap params)throws Exception;
	public CoviMap getAutoApprovalLineDeptlist(CoviMap params) throws Exception;
	public CoviMap getAutoApprovalLineRegionlist(CoviMap params) throws Exception;
	public CoviMap getAdminFormData(CoviMap params) throws Exception;
	public int updateAdminFormData(CoviMap params)throws Exception;
	public int deleteAdminFormData(CoviMap params)throws Exception;
	public int createSubTableInfo(CoviMap params)throws Exception;
	public Boolean checkDuplidationTableName(CoviMap params);
	public Boolean addFormDuplicateCheck(CoviMap params);
	void insertFormsLegacy(CoviMap params) throws Exception;
	public void updateAclListFormData(CoviMap params)throws Exception;
	public void deleteAclListFormData(CoviMap params)throws Exception;
	public String getAutoFormSeq()throws Exception;
}
