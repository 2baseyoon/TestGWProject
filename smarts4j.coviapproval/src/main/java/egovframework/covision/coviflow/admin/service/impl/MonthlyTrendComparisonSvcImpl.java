package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.MonthlyTrendComparisonSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("monthlyTrendComparisonService")
public class MonthlyTrendComparisonSvcImpl extends EgovAbstractServiceImpl implements MonthlyTrendComparisonSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getMonthlyDeptList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;	
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.monthlyTrendComparison.selectMonthlyDeptListcnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.monthlyTrendComparison.selectMonthlyDeptList", params);		
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GR_Name,Month1,Month2,Month3,Month4,Month5,Month6,Month7,Month8,Month9,Month10,Month11,Month12"));
		resultList.put("page", pagingData);
		return resultList; 
	}

	@Override
	public CoviMap getMonthlyFormList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.monthlyTrendComparison.selectMonthlyFormListcnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.monthlyTrendComparison.selectMonthlyFormList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormName,Month1,Month2,Month3,Month4,Month5,Month6,Month7,Month8,Month9,Month10,Month11,Month12"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap getMonthlyPersonList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.monthlyTrendComparison.selectMonthlyPersonListcnt", params);

		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.monthlyTrendComparison.selectMonthlyPersonList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Name,Month1,Month2,Month3,Month4,Month5,Month6,Month7,Month8,Month9,Month10,Month11,Month12"));
		resultList.put("page", pagingData);
		
		return resultList;
	}	
}
