package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface AccountManageSvc {
	public CoviMap getAccountmanagelist(CoviMap params) throws Exception;
	public CoviMap saveAccountManageInfo(CoviMap params) throws Exception;
	public CoviMap getAccountManageDetail(CoviMap params) throws Exception;
	public CoviMap deleteAccountManage(CoviMap params) throws Exception;
	CoviMap accountManageExcelDownload(CoviMap params) throws Exception;
	public CoviMap accountManageExcelUpload(CoviMap params) throws Exception;
	public CoviMap accountManageSync();
}