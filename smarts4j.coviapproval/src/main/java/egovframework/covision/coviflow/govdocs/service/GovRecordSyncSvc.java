package egovframework.covision.coviflow.govdocs.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface GovRecordSyncSvc {
	
	public CoviList selectRecordGFileData(CoviMap params) throws Exception;
	
	public CoviList selectRecordDocList(CoviMap params) throws Exception;
	
	public CoviList selectRecordDocPageList(CoviMap params) throws Exception;
	
	public CoviList selectRecordHistoryList(CoviMap params) throws Exception;
	
	public CoviMap selectStorageInfo(CoviMap params) throws Exception;
	
	public int updateSyncSeries(CoviList params)throws Exception;
	
	//문서이관 반려 처리
	public int updateRecordGfileStatus(CoviMap params)throws Exception;
	
	public CoviMap selectJwfForminstance(CoviMap params) throws Exception;
	
	public CoviList selectSendMailList() throws Exception;

	public CoviMap selectGovRecordDocInfo(CoviMap params) throws Exception;
	
}


