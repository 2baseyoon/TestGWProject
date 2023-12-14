package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface SeriesListSvc {
	public CoviMap selectBaseYearList(CoviMap params) throws Exception;
	public CoviMap getSubDeptList(CoviMap params) throws Exception;
	public CoviMap selectSeriesListData(CoviMap params, String headerCode) throws Exception;
	public CoviMap selectSeriesFunctionListData(CoviMap params) throws Exception;
	public CoviMap selectSeriesSearchList(CoviMap params) throws Exception;
	public CoviMap selectSeriesSearchTreeData(CoviMap params) throws Exception;
	public CoviMap seriesExcelUpload(CoviMap params) throws Exception;
	public int insertSeriesData(CoviMap params) throws Exception;
	public int insertSeriesByYear(CoviMap params) throws Exception;
	public int updateSeriesData(CoviMap params) throws Exception;
	public int updateRevokeSeries(CoviMap params) throws Exception;
	public int updateRestoreSeries(CoviMap params) throws Exception;
	public int updateSyncSeries(CoviMap params) throws Exception;
	public String getSeriesPath(CoviMap params) throws Exception;
	public CoviMap getFunctionLevel(CoviMap params) throws Exception;
}
