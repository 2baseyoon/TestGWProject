package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface DeptApprovalListSvc {
	public CoviMap selectDeptApprovalList(CoviMap params) throws Exception;
	public CoviMap selectDeptApprovalGroupList(CoviMap params) throws Exception;
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;
	public int selectDeptProcessNotDocReadCnt(CoviMap params)throws Exception;
	public int selectDeptTCInfoNotDocReadCnt(CoviMap params)throws Exception;
	public int selectDeptTCInfoSingleDocRead(CoviMap params)throws Exception;
	public CoviList getPersonDirectorOfUnitData(CoviMap params) throws Exception;
	public int selectDeptReceptionCnt(CoviMap params)throws Exception;
	public int selectDeptProcessCnt(CoviMap params)throws Exception;
	public int insertDocReadHistory(CoviMap params)throws Exception;
	public int insertTCInfoDocReadHistory(CoviMap params)throws Exception;
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception;
	public int selectDeptBoxListCnt(CoviMap params)throws Exception;
}
