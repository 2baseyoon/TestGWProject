package egovframework.covision.coviflow.user.service;

import egovframework.baseframework.data.CoviMap;

public interface RecordInOutSvc {

	public CoviMap selectGovRecordDocInOutManager(CoviMap params) throws Exception;
	public void insertGovRecordDocInOutUser(CoviMap params) throws Exception;
	public void deleteGovRecordDocInOutUser(CoviMap params) throws Exception;
	public void selectRecordDeptAdminCnt(CoviMap params) throws Exception;

}
