package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.admin.service.DocFolderManagerSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("docFolderManagerService")
public class DocFolderManagerSvcImpl extends EgovAbstractServiceImpl implements DocFolderManagerSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectDocClass(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.docFolderManager.selectdocclass", params);	
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "no,nodeName,type,pno,url,chk,rdo,KeepYear,SortKey"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectDocClassPopup(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.docFolderManager.selectDocClassPopup", params);	
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "no,nodeName,type,pno,url,chk,rdo,KeepYear,SortKey"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectdocclassOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.docFolderManager.selectdocclassOne", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "no,nodeName,type,pno,url,chk,rdo,KeepYear,SortKey"));
		
		return resultList;
	}	

	@Override
	public CoviMap selectDdlCompany(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("admin.docFolderManager.selectDdlCompany", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText"));	
		return resultList;
	}
	
	//저장
	@Override
	public Object insert(CoviMap params) throws Exception {			
		return coviMapperOne.insertWithPK("admin.docFolderManager.insert", params);
	}
	
	//수정
	@Override
	public int update(CoviMap params) throws Exception {		
		return coviMapperOne.update("admin.docFolderManager.update", params);
	}
	//수정
	@Override
	public int delete(CoviMap params) throws Exception {		
		return coviMapperOne.delete("admin.docFolderManager.delete", params);
	}
	
	//수정
	@Override
	public CoviMap selectdocclassRetrieveFolder(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();		
		int cnt = (int) coviMapperOne.getNumber("admin.docFolderManager.selectdocclassRetrieveFolder", params);
		resultList.put("cnt", cnt);
		return resultList;
	}

	@Override
	public CoviMap selectDocClassSearchList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.docFolderManager.selectDocClassSearchList", params);	
		CoviMap resultList = new CoviMap();
		resultList.put("list", list);
		return resultList;
	}
	
	@Override
	public CoviMap selectDocFavoritesList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.docFolderManager.selectDocFavoritesList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", list);
		return resultList;
	}
	
	@Override
	public CoviMap insertDocFavorites(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();		
		int cnt = coviMapperOne.insert("admin.docFolderManager.insertDocFavorites", params);
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	@Override
	public CoviMap deleteDocFavorites(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();		
		int cnt = coviMapperOne.delete("admin.docFolderManager.deleteDocFavorites", params);
		resultList.put("cnt", cnt);
		return resultList;
	}
}
