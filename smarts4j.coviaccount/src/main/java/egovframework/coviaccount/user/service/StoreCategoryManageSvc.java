package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface StoreCategoryManageSvc {
	public CoviMap getStoreCategoryManagelist(CoviMap params) throws Exception;
	public CoviMap getStoreCategoryManageDetail(CoviMap params) throws Exception;
	public CoviMap saveStoreCategoryManageInfo(CoviMap params) throws Exception;
	public CoviMap deleteStoreCategoryManageInfo(CoviMap params) throws Exception;
	CoviMap storeCategoryManageExcelDownload(CoviMap params) throws Exception;
	public CoviMap storeCategoryManageExcelUpload(CoviMap params) throws Exception;
}