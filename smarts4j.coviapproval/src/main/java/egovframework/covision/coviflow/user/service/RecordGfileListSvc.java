package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface RecordGfileListSvc {
	public CoviMap selectRecordGFileListData(CoviMap params, String headerCode) throws Exception;
	public CoviMap selectRecordHistoryList(CoviMap params) throws Exception;
	public CoviMap selectBaseYearList(CoviMap params) throws Exception;
	public int insertRecordGFileData(CoviMap params) throws Exception;
	public int insertRecordGFileByYear(CoviMap params) throws Exception;
	public int insertRecordGFileByYearSchedule(CoviMap params) throws Exception;
	public int updateRecordGFileData(CoviMap params) throws Exception;
	public int updateRecordStatus(CoviMap params) throws Exception;
	public int updateExtendWork(CoviMap params) throws Exception;
	public int updateRecordTakeover(CoviMap params) throws Exception;
	public int recordGFileExcelUpload(CoviMap params) throws Exception;
	public String selectRecordSeq(CoviMap params) throws Exception;
	public CoviMap selectRecordGFileTreeData(CoviMap params) throws Exception;
	public int insertRecordGFileIntergrationHistory(CoviMap params) throws Exception;
	public int updateDocIntergration(CoviMap params) throws Exception;
}
