package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils; 
import egovframework.covision.coviflow.admin.service.PersonDirectorSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("personDirectorService")
public class PersonDirectorSvcImpl extends EgovAbstractServiceImpl implements PersonDirectorSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getPersonDirectorList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.personDirector.selectgridcnt", params);	
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.personDirector.selectgrid", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,EntCode,UserName,Description,SortKey,AuthStartDate,AuthEndDate,TargetCode,TargetName"));
		resultList.put("page", pagingData);
		return resultList;
	}
	
	//저장jwf_persondirectormember
	@Override
	public Object insertjwf_persondirectormember(CoviMap params) throws Exception {				
		return coviMapperOne.insertWithPK("admin.personDirector.insertjwf_persondirectormember", params);
	}
	
	//저장jwf_persondirector
	@Override
	public Object insertjwf_persondirector(CoviMap params) throws Exception {		
		return coviMapperOne.insertWithPK("admin.personDirector.insertjwf_persondirector", params);
	}
	
	//삭제
	@Override
	public int deletejwf_persondirectormember(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.personDirector.deletejwf_persondirectormember", params);
	}
	//삭제
	@Override
	public int deletejwf_persondirector(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.personDirector.deletejwf_persondirector", params);
	}
		
	@Override
	public CoviMap getPersonDirectorData(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.personDirector.select", params);
		int cnt = (int) coviMapperOne.getNumber("admin.personDirector.selectgridcnt", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,EntCode,UserName,Description,SortKey,AuthStartDate,AuthEndDate,TargetCode,TargetName,ViewStartDate,ViewEndDate"));
		resultList.put("cnt", cnt);		
		return resultList;
	}

	@Override
	public int chkDuplicateTarget(CoviMap params) throws Exception {
		return (int) coviMapperOne.selectOne("admin.personDirector.selectDuplicateTargetCnt", params);
	}
}
