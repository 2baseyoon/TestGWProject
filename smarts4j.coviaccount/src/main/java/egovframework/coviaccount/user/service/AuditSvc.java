package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface AuditSvc {
	public CoviMap getAuditList(CoviMap params) throws Exception;
	public CoviMap getAuditDetail(CoviMap params) throws Exception;
	public CoviMap saveAuditInfo(CoviMap params) throws Exception;
	public CoviMap getAuditRuleInfo(CoviMap params) throws Exception;
}