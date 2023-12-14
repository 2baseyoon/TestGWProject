package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface UserBizDocListSvc {
	public int selectBizDocCount(CoviMap params) throws Exception;
	public CoviMap selectBizDocListData(CoviMap params) throws Exception;
	public CoviMap selectBizDocProcessListData(CoviMap params) throws Exception;
	public CoviMap selectBizDocCompleteLisData(CoviMap params) throws Exception;
	public CoviMap selectBizDocGroupList(CoviMap params) throws Exception;
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;
}
