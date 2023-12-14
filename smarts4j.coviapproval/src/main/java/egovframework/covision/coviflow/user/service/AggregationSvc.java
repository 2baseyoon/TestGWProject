package egovframework.covision.coviflow.user.service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

public interface AggregationSvc {

	int getAggregationFormsCnt(CoviMap map);

	CoviList getAggregationFormsSimple(CoviMap map) throws Exception;

	CoviMap getAggregationFormListByAggFormId(CoviMap map) throws Exception;

	CoviList getAggregationFormHeaderByAggFormId(CoviMap map) throws Exception;

	CoviMap selectExcelData(CoviMap params, String headerKey) throws Exception;

}
