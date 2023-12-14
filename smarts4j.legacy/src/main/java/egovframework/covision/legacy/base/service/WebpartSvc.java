package egovframework.covision.legacy.base.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface WebpartSvc {
	public CoviList selectSampleData(CoviMap params) throws Exception;		// sample data 조회
}
