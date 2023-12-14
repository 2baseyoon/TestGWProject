package egovframework.covision.coviflow.common.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.common.service.del_ComStorageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("comStorageService")
public class del_ComStorageSvcImpl  extends EgovAbstractServiceImpl implements del_ComStorageSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap select(CoviMap params) throws Exception {	
		CoviList list = coviMapperOne.list("common.ComStorage.select", params);	
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "StorageID,DN_ID,ServiceType,SeverName,LastSeq,FileURL,FilePath,ImageURL,ImagePath,InlineURL,InlinePath,VideoURL,VideoPath,IsUse,Description,RegistDate"));		
		return resultList;
	}
	
	@Override
	public CoviMap selectList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("common.ComStorage.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("common.ComStorage.selectList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "StorageID,DN_ID,ServiceType,SeverName,LastSeq,FileURL,FilePath,ImageURL,ImagePath,InlineURL,InlinePath,VideoURL,VideoPath,IsUse,Description,RegistDate"));
		return resultList;
	}
	
	@Override
	public int insert(CoviMap params)throws Exception{
		return coviMapperOne.insert("common.ComStorage.insert", params);		
	}
	
	@Override
	public int update(CoviMap params)throws Exception{
		return coviMapperOne.update("common.ComStorage.update", params);
	}
	
	@Override
	public int delete(CoviMap params)throws Exception{
		return coviMapperOne.delete("common.ComStorage.delete", params);
	}
}
