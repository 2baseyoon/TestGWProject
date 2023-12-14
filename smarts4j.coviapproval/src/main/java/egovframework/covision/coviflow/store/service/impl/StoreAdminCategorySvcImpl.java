package egovframework.covision.coviflow.store.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.store.service.StoreAdminCategorySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("storeAdminCategoryService")
public class StoreAdminCategorySvcImpl extends EgovAbstractServiceImpl implements StoreAdminCategorySvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectCategoryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("store.adminCategory.selectCount", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("store.adminCategory.select", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page",page);
		
		return resultList;
	}
	
	@Override
	public void insertCategoryData(CoviMap params) throws Exception {
		coviMapperOne.insert("store.adminCategory.insertCategoryData", params);		
	}
	
	@Override
	public void updateIsUseCategory(CoviMap params) throws Exception {
		coviMapperOne.update("store.adminCategory.updateIsUseCategory", params);
	}
	
	@Override
	public void deleteCategory(CoviMap params) throws Exception {
		coviMapperOne.update("store.adminCategory.deleteCategory", params);
	}
	
	@Override
	public CoviMap getCategoryData(CoviMap params) throws Exception {		
		CoviMap resultList = new CoviMap();
		CoviMap map = coviMapperOne.select("store.adminCategory.selectCategoryData", params);		

		resultList.put("map", CoviSelectSet.coviSelectJSON(map));
		
		return resultList;
	}
	
	@Override
	public void updateCategoryData(CoviMap params) throws Exception {
		coviMapperOne.update("store.adminCategory.updateCategoryData", params);
	}
		
}
