package egovframework.batch.service;

import egovframework.baseframework.data.CoviMap;

public interface CoviJobSvc {

	//프로시져 호출 테스트
	public int callProc(String procName, CoviMap params) throws Exception;
	public int createJobHistory(CoviMap params) throws Exception;
	
}