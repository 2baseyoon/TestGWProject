package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface MonitorErrorLogSvc {
	public CoviMap getMonitorErrorLog(CoviMap params) throws Exception;

	void deleteErrorLog(CoviMap params) throws Exception;
}
