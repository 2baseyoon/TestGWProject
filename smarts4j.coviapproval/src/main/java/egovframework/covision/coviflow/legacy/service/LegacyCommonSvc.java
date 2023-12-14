package egovframework.covision.coviflow.legacy.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface LegacyCommonSvc {
	public void insertLegacy(String mode, String state, String parameters, Exception ex) throws Exception;
	public CoviMap selectGrid(CoviMap params) throws Exception;
	public CoviMap getVacInfoForUser(CoviMap params) throws Exception;	// 연차 조회(신청서)
	void deleteLegacyErrorLog(CoviMap params) throws Exception;
	void updateLegacyRetryFlag(String legacyID) throws Exception;
	public void docInfoselectInsert(CoviMap params) throws Exception;
	
	CoviMap getBodyData(CoviMap params) throws Exception;
	public CoviList getLegacyInterfaceInfo(CoviMap params) throws Exception;
	public CoviMap insertInterfaceHistory(CoviMap logParam, Exception ex, String callType) throws Exception;
	public CoviMap insertInterfaceHistory(CoviMap legacyInfo, CoviMap spParams, Exception ex, String callType) throws Exception;
	public CoviMap getInterfaceHistory(CoviMap params) throws Exception;
	
	CoviMap makeLogParamDefault(CoviMap legacyInfo, CoviMap spParams) throws Exception;
	CoviMap makeLegacyParams(CoviMap legacyInfo, CoviMap spParams) throws Exception;
	
	public CoviMap selectEachGrid(CoviMap params) throws Exception;
	void deleteEachLegacyErrorLog(CoviMap params) throws Exception;
	
}
