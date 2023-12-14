package egovframework.covision.coviflow.common.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.common.service.EntInfoSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("entInfoService")
public class EntInfoSvcImpl extends EgovAbstractServiceImpl implements EntInfoSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getEntinfoListData(CoviMap params) throws Exception {		
		params.put("lang", SessionHelper.getSession("lang"));
		
		String queryId = "common.entInfo.selectEntInfoList";
		if("ID".equals(params.get("domainCodeType"))) {
			queryId = "common.entInfo.selectEntInfoListId";
		}
		CoviList list = coviMapperOne.list(queryId, params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText,defaultVal"));	
		return resultList;
	}
	

	
	
}
