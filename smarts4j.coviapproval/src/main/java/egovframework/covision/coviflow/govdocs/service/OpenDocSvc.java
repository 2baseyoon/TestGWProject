package egovframework.covision.coviflow.govdocs.service;

import egovframework.baseframework.data.CoviMap;


public interface OpenDocSvc {
	// 원문공개 정보
	public void insertOpenDocInfo(CoviMap spParams) throws Exception;
	public CoviMap selectOpenDocList(CoviMap params) throws Exception;
	
	public CoviMap updateOpenDocInfo(CoviMap params) throws Exception;
	public int updateOpenDocStatus(CoviMap params) throws Exception;
	public CoviMap selectGovHistory(CoviMap params) throws Exception;
	public CoviMap selectGovStatistics(CoviMap params) throws Exception;
	public int deleteHistory(CoviMap params) throws Exception;
	public int updateOpenDocStatStatus(CoviMap params) throws Exception;
	public CoviMap selectOpenDocFileList(CoviMap params) throws Exception;
}
