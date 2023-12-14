package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface MonitorErrorListSvc {
	public CoviMap getMonitorErrorList(CoviMap params) throws Exception;
	public int setMonitorChangeState(CoviMap params) throws Exception;
}
