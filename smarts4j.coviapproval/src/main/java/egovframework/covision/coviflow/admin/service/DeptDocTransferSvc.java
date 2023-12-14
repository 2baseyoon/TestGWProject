package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface DeptDocTransferSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public void transferDeptDoc(CoviMap params)throws Exception;
}
