package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface MailMgrSvc {
	public CoviMap getMailMgrList(CoviMap params) throws Exception;
	public CoviMap getMailDetail(CoviMap params) throws Exception;
	public int resendMail(CoviMap params)throws Exception;
}
