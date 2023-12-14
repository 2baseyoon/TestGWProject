package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;


public interface ManagerSvc {
	public CoviMap getManagerList(CoviMap params) throws Exception;
	public CoviMap saveManagerInfo(CoviMap params) throws Exception;
	public CoviMap deleteManagerInfo(CoviMap params) throws Exception;
	public CoviMap managerExcelDownload(CoviMap params) throws Exception;
	public CoviMap searchManagerInfo(CoviMap params) throws Exception;
}