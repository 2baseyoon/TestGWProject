package egovframework.covision.coviflow.store.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface StoreAdminFormSvc {
	public CoviList selectFormsCategoryList(CoviMap params) throws Exception;
	public CoviMap selectStoreFormList(CoviMap params, boolean paging) throws Exception;
	public int updateIsUseForm(CoviMap params) throws Exception;
	public int storeInsertFormData(CoviMap pObj, CoviList flist) throws Exception;
	public int storeUpdateFormData(CoviMap pObj, CoviList flist) throws Exception;
	public CoviMap storeAdminPurchaseListData(CoviMap pObj, boolean paging) throws Exception;
	public CoviMap getStoreCategorySelectbox(CoviMap params) throws Exception;
	public int storeFormDuplicateCheck(CoviMap params) throws Exception;
	public CoviMap getStoreFormData(CoviMap params) throws Exception;
	public CoviList getStoreFormRevList(CoviMap params) throws Exception;
	public long getCategoryFormCnt(CoviMap params) throws Exception;
}
