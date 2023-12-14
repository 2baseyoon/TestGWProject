package egovframework.covision.coviflow.legacy.service;


import egovframework.baseframework.data.CoviMap;

public interface LegacyInterfaceSvc {
	public void call(CoviMap legacyInfo, CoviMap spParams, String callType) throws Exception;
	public CoviMap getLogParam();
	public void clear();
}
