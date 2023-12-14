package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.PersonDirectorOfUnitSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("personDirectorOfUnitService")
public class PersonDirectorOfUnitSvcImpl extends EgovAbstractServiceImpl implements PersonDirectorOfUnitSvc {

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getPersonDirectorOfUnitList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.personDirectorOfUnit.selectgridcnt", params);

		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.personDirectorOfUnit.selectgrid", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SortKey,UserName,UnitName,Description,UserCode,UnitCode,AuthStartDate,AuthEndDate"));
		resultList.put("page", pagingData);
		return resultList;
	}

	// 저장JWF_DIRECTORMEMBER
	@Override
	public Object insertJWF_DIRECTORMEMBER(CoviMap params) throws Exception {
		return coviMapperOne.insertWithPK("admin.personDirectorOfUnit.insertJWF_DIRECTORMEMBER", params);
	}

	// 저장JJWF_DIRECTOR
	@Override
	public Object insertJWF_DIRECTOR(CoviMap params) throws Exception {
		return coviMapperOne.insertWithPK("admin.personDirectorOfUnit.insertJWF_DIRECTOR", params);
	}

	// 삭제
	@Override
	public int deleteJWF_DIRECTORMEMBER(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.personDirectorOfUnit.deleteJWF_DIRECTORMEMBER", params);
	}

	// 삭제
	@Override
	public int deleteJWF_DIRECTOR(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.personDirectorOfUnit.deleteJWF_DIRECTOR", params);
	}

	@Override
	public CoviMap getPersonDirectorOfUnitData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("admin.personDirectorOfUnit.select", params);
		int cnt = (int) coviMapperOne.getNumber("admin.personDirectorOfUnit.selectgridcnt", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SortKey,UserName,UnitName,Description,UserCode,UnitCode,AuthStartDate,AuthEndDate,ViewStartDate,ViewEndDate"));
		resultList.put("cnt", cnt);
		return resultList;
	}

	@Override
	public int chkDuplicateTarget(CoviMap params) throws Exception {
		return (int) coviMapperOne.selectOne("admin.personDirectorOfUnit.selectDuplicateTargetCnt", params);
	}
}
