package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface JobFunctionListSvc {
	public int selectJobFunctionCount(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionListData(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionApprovalListData(CoviMap params)throws Exception;
	public CoviMap selectJobFunctionProcessListData(CoviMap params)throws Exception;
	public CoviMap selectJobFunctionCompleteListData(CoviMap params)throws Exception;
	public CoviMap selectJobFunctionRejectListData(CoviMap params)throws Exception;

	public CoviMap selectJobFunctionGroupList(CoviMap params) throws Exception;

	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;

	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception;
	public int selectJobfunctionAuth(CoviMap params) throws Exception;
}
