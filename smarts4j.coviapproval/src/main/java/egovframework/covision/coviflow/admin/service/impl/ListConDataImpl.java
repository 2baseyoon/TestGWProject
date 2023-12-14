package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.ListConDataSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("listConDataService")
public class ListConDataImpl extends EgovAbstractServiceImpl implements ListConDataSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getConDataLogLegacy(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.listConData.selectConDataLogLegacyListCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.listConData.selectConDataLogLegacyList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "IDX,DocID,InterfaceID,InitiatorID,exsistErr,RegDate"));
		resultList.put("page", pagingData);
		
		return resultList;
	}	
}
