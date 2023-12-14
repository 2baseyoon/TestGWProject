package egovframework.covision.coviflow.common.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.common.service.del_ComFileSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("comFileService")
public class del_ComFileSvcImpl extends EgovAbstractServiceImpl implements del_ComFileSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap select(CoviMap params) throws Exception {	
		CoviList list = coviMapperOne.list("common.ComFile.select", params);	
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FileID, StorageID, ServiceType, ObjectID, ObjectType, MessageID, Version, SaveType, LastSeq, Seq, FilePath, FileName, SavedName, Extention, Size, ThumWidth, ThumHeight, Description, RegistDate"));		
		return resultList;
	}
	
	@Override
	public CoviMap selectList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("common.ComFile.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("common.ComFile.selectList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FileID, StorageID, ServiceType, ObjectID, ObjectType, MessageID, Version, SaveType, LastSeq, Seq, FilePath, FileName, SavedName, Extention, Size, ThumWidth, ThumHeight, Description, RegistDate"));
		return resultList;
	}
	
	@Override
	public int insert(CoviMap params)throws Exception{
		return coviMapperOne.insert("common.ComFile.insert", params);		
	}
	
	@Override
	public int update(CoviMap params)throws Exception{
		return coviMapperOne.update("common.ComFile.update", params);
	}
	
	@Override
	public int delete(CoviMap params)throws Exception{
		return coviMapperOne.delete("common.ComFile.delete", params);
	}	
}
