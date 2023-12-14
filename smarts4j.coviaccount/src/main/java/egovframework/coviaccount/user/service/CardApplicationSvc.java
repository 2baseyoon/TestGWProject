package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface CardApplicationSvc {
	public CoviMap getCardApplicationList(CoviMap params) throws Exception;
	public CoviMap getCardApplicationDetail(CoviMap params) throws Exception;
	public CoviMap saveCardApplicationInfo(CoviMap params) throws Exception;
	CoviMap cardApplicationExcelDownload(CoviMap params) throws Exception;
}