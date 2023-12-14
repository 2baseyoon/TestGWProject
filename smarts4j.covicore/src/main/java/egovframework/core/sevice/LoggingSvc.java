package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface LoggingSvc {

	public CoviMap selectConnectFalse(CoviMap params) throws Exception;
	public CoviMap selectConnect(CoviMap params) throws Exception;
	public CoviMap selectConnectExcel(CoviMap params) throws Exception;
	public CoviMap selectError(CoviMap params) throws Exception;
	public CoviMap selectErrorExcel(CoviMap params) throws Exception;
	public CoviMap selectPageMove(CoviMap params) throws Exception;
	public CoviMap selectPageMoveExcel(CoviMap params) throws Exception;
	public CoviMap selectPerformance(CoviMap params) throws Exception;
	public CoviMap selectPerformanceExcel(CoviMap params) throws Exception;
	public CoviMap selectUserInfoChange(CoviMap params) throws Exception;
	public CoviMap selectHttpConnect(CoviMap params) throws Exception;
	public String selectDetailErrorLogMessage(CoviMap params) throws Exception;
	public CoviMap selectErrorPage(CoviMap params) throws Exception;
	public CoviMap selectUserCheck(CoviMap params)  throws Exception;
	public CoviMap selectExtDbSync(CoviMap params)  throws Exception;
	public String selectExtDbSyncDetail(CoviMap params)  throws Exception;
	public CoviMap selectFileDownload(CoviMap params) throws Exception;
	public CoviMap selectFileDownloadExcel(CoviMap params) throws Exception;
	public CoviMap selectAuthError(CoviMap params) throws Exception;
	public CoviMap selectAuthErrorExcel(CoviMap params) throws Exception;
	public CoviMap selectACLChange(CoviMap params) throws Exception;
	public CoviMap selectAuthChangeHistoryExcel(CoviMap params) throws Exception;
	
}
