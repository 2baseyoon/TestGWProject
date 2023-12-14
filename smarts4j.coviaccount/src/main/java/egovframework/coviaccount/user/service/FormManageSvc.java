package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface FormManageSvc {
	public CoviMap getFormManagelist(CoviMap params) throws Exception;
	
	public CoviMap getFormManageDetail(CoviMap params) throws Exception;
	public CoviMap getInfoListData(CoviMap params) throws Exception;
	
	public CoviMap saveFormManageInfo(CoviMap params) throws Exception;
	public CoviMap deleteFormManage(CoviMap params) throws Exception;
	
	CoviMap formManageExcelDownload(CoviMap params) throws Exception;
	public CoviMap formManageExcelUpload(CoviMap params) throws Exception;
	
	public CoviMap getFormMenuList(CoviMap params) throws Exception;
	public CoviMap getFormManageInfo(CoviMap params) throws Exception;
	public CoviMap getFormLegacyManageInfo(CoviMap params) throws Exception;
	
	public CoviMap getNoteIsUse(CoviMap params) throws Exception;
	public CoviMap getExchangeIsUse(CoviMap params) throws Exception;
}