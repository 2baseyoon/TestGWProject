package egovframework.covision.coviflow.store.service;

import egovframework.baseframework.data.CoviMap;

public interface StoreAdminCategorySvc {
	public CoviMap selectCategoryList(CoviMap params) throws Exception;
	public void insertCategoryData(CoviMap params) throws Exception;
	public void updateIsUseCategory(CoviMap params) throws Exception;
	public void deleteCategory(CoviMap params) throws Exception;
	public CoviMap getCategoryData(CoviMap params) throws Exception;
	public void updateCategoryData(CoviMap params) throws Exception;
}
