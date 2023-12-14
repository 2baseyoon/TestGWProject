package egovframework.covision.legacy.base.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.legacy.base.service.WebpartSvc;
import egovframework.covision.legacy.data.CoviMapperLegacyOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WebpartSvc")
public class WebpartSvcImpl extends EgovAbstractServiceImpl implements WebpartSvc{

	@Resource(name="CoviMapperLegacyOne")
	private CoviMapperLegacyOne legacyDB;

	/**
	 * selectSampleData - sample data 조회
	 * @param params
	 * @return JSONArray
	 * @throws Exception
	 */
	@Override
	public CoviList selectSampleData(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(legacyDB.list("user.sample.selectSampleItem", params), "itemId,itemVal");
	}
}
