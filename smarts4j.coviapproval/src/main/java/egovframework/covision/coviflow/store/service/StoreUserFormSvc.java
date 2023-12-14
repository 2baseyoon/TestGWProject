package egovframework.covision.coviflow.store.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface StoreUserFormSvc {
	public CoviList getFormsCategoryList(CoviMap params) throws Exception;
	public CoviMap getStoreUserFormList(CoviMap params, boolean paging) throws Exception;
	public CoviMap getPurchaseFormData(CoviMap params) throws Exception;
	public CoviMap getStoreUserFormData(CoviMap params) throws Exception;
	public CoviMap getStoreFormClassList(CoviMap params) throws Exception;
	public CoviMap storePurchaseForm(CoviMap fObj) throws Exception;
}
