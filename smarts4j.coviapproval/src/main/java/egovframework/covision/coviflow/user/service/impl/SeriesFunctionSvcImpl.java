package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.user.service.SeriesFunctionSvc;

@Service("SeriesFunctionSvc")
public class SeriesFunctionSvcImpl extends EgovAbstractServiceImpl implements SeriesFunctionSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	Logger LOGGER = LogManager.getLogger(SeriesFunctionSvcImpl.class);

	@Override
	public int getDupFunctionCodeCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.seriesFunction.selectDupFunctionCodeCnt", params);
	}

	@Override
	public String getFunctionLevel(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.seriesFunction.selectFunctionLevel", params);
	}
	
	@Override
	public String getFunctionLastSort(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.seriesFunction.selectFunctionLastSort", params);
	}
	
	@Override
	public int updateFunctionSort(CoviMap params) throws Exception {
		return coviMapperOne.update("user.seriesFunction.updateFunctionSort", params);
	}

	@Override
	public int insertSeriesFunction(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.seriesFunction.insertSeriesFunction", params);
	}

	@Override
	public int updateSeriesFunction(CoviMap params) throws Exception {
		int retValue = coviMapperOne.update("user.seriesFunction.updateSeriesFunction", params);
		return retValue;
	}

	@Override
	public int getIsSubFunctionCodeCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.seriesFunction.selectIsSubFunctionCodeCnt", params);
	}
	
	@Override
	public int deleteSeriesFunction(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.seriesFunction.deleteSeriesFunction", params);
	}
}