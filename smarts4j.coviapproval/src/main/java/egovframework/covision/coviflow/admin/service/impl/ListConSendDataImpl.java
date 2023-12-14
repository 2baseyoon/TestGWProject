package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.admin.service.ListConSendDataSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("listConSendDataService")
public class ListConSendDataImpl extends EgovAbstractServiceImpl implements ListConSendDataSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getConSendDataLogLegacy(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.listConSendData.selectConSendDataLogLegacyList", params);
		
		int cnt = (int) coviMapperOne.getNumber("admin.listConSendData.selectConSendDataLogLegacyListCnt", params);
	
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "IDX,DocID,SystemID,Section,AprMemberSN,ApvMode,FMPF,FormName,Subject,ApvResult,DocNumber,ApproverId,ExDisplayName,Flag,SendDate"));
		resultList.put("cnt", cnt);
		return resultList;
	}
}
