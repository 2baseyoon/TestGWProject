package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface AuditDeptCompleteListSvc {
	public CoviMap getAuditDeptCompleteGroupListData(CoviMap params) throws Exception;
	public CoviMap getAuditDeptProcessListData(CoviMap params) throws Exception;
	public CoviMap getAuditDeptCompleteListData(CoviMap params) throws Exception;
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;
}
