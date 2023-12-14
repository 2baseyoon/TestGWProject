package egovframework.covision.coviflow.user.service;

import egovframework.baseframework.data.CoviMap;

public interface SeriesFunctionSvc {
	public int getDupFunctionCodeCnt(CoviMap params) throws Exception;
	public String getFunctionLevel(CoviMap params) throws Exception;
	public String getFunctionLastSort(CoviMap params) throws Exception;
	public int updateFunctionSort(CoviMap params) throws Exception;
	public int insertSeriesFunction(CoviMap params) throws Exception;
	public int updateSeriesFunction(CoviMap params) throws Exception;
	public int getIsSubFunctionCodeCnt(CoviMap params) throws Exception;
	public int deleteSeriesFunction(CoviMap params) throws Exception;
}
