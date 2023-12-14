package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface MonthlyTrendComparisonSvc {
	public CoviMap getMonthlyDeptList(CoviMap params) throws Exception;
	public CoviMap getMonthlyFormList(CoviMap params) throws Exception;
	public CoviMap getMonthlyPersonList(CoviMap params) throws Exception;
}
