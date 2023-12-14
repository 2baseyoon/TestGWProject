package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface BizTripSvc {
	public CoviMap saveBizTripRequest(CoviMap params) throws Exception;
	public CoviMap searchBizTripList(CoviMap params) throws Exception;	
	public CoviMap bizTripExcelDownload(CoviMap paras) throws Exception;
	public CoviMap getBizTripRequestInfo(CoviMap params) throws Exception;
	public CoviMap exceptBizTripApplication(CoviMap params) throws Exception;
}