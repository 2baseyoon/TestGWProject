package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface StandardBriefSvc {
	public CoviMap getStandardBrieflist(CoviMap params) throws Exception;
	public CoviMap saveStandardBriefInfo(CoviMap params) throws Exception;
	public CoviMap getStandardBriefDetail(CoviMap params) throws Exception;
	public CoviMap deleteStandardBriefInfoByAccountID(CoviMap params) throws Exception;
	CoviMap standardBriefExcelDownload(CoviMap params) throws Exception;
	public CoviMap standardBriefExcelUpload(CoviMap params) throws Exception;
}