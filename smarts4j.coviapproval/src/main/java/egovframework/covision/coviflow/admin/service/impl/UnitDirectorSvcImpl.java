package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.UnitDirectorSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("unitDirectoConService")
public class UnitDirectorSvcImpl extends EgovAbstractServiceImpl implements UnitDirectorSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getUnitDirectorList(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.unitDirector.selectgridcnt", params);
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.unitDirector.selectgrid", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SortKey,UnitCode,UnitName,EntCode,Description,AuthStartDate,AuthEndDate,TargetUnitCode,TargetUnitName"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	//저장jwf_unitdirectormember
	@Override
	public Object insertjwf_unitdirectormember(CoviMap params) throws Exception {				
		return coviMapperOne.insertWithPK("admin.unitDirector.insertjwf_unitdirectormember", params);
	}
	
	//저장jwf_unitdirector
	@Override
	public Object insertjwf_unitdirector(CoviMap params) throws Exception {		
		return coviMapperOne.insertWithPK("admin.unitDirector.insertjwf_unitdirector", params);
	}
	
	//삭제
	@Override
	public int deletejwf_unitdirectormember(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.unitDirector.deletejwf_unitdirectormember", params);
	}
	
	//삭제
	@Override
	public int deletejwf_unitdirector(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.unitDirector.deletejwf_unitdirector", params);
	}
	
	@Override
	public CoviMap getUnitDirectorData(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.unitDirector.select", params);
		int cnt = (int) coviMapperOne.getNumber("admin.unitDirector.selectgridcnt", params);
		CoviMap resultList = new CoviMap();		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SortKey,UnitCode,UnitName,EntCode,Description,AuthStartDate,AuthEndDate,TargetUnitCode,TargetUnitName,ViewStartDate,ViewEndDate"));
		resultList.put("cnt", cnt);		
		return resultList;
	}	
}
