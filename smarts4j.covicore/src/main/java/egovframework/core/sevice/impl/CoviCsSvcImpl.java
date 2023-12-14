package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.sevice.CoviCsSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



import egovframework.coviframework.util.ComUtils;
@Service("coviCsService")
public class CoviCsSvcImpl extends EgovAbstractServiceImpl implements CoviCsSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public CoviMap getCsList(CoviMap params)throws Exception{
		CoviMap resultList	= new CoviMap();
		CoviMap page			= null;
		CoviList list			= new CoviList();
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("covics.selectCsListCount" , params);
			page= ComUtils.setPagingData( params, cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("covics.selectCsList", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	public CoviMap getCsContents(CoviMap params)throws Exception{
		
		return coviMapperOne.selectOne("covics.selectCsContents", params);
	}

	public CoviMap getCsContentsFile(CoviMap params)throws Exception{
		
		return coviMapperOne.selectOne("covics.selectCsContentsFile", params);
	}
}
