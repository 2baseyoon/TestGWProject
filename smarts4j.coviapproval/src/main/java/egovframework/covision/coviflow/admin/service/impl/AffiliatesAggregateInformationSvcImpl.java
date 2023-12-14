package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AffiliatesAggregateInformationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("affiliatesAggregateInformationService")
public class AffiliatesAggregateInformationSvcImpl extends EgovAbstractServiceImpl implements AffiliatesAggregateInformationSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getEntCountList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("admin.affiliatesAggregateInformation.selectEntCountListCnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.affiliatesAggregateInformation.selectEntCountList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DN_Name,A_Count,REQCMP_count,document_leadtime"));
		resultList.put("page",page);
		
		return resultList; 
	}
	
	
	@Override
	public CoviMap getEntMonthlyCountList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("admin.affiliatesAggregateInformation.selectEntMonthlyCountListCnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.affiliatesAggregateInformation.selectEntMonthlyCountList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DN_Name,Month1,Month2,Month3,Month4,Month5,Month6,Month7,Month8,Month9,Month10,Month11,Month12"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	
}
