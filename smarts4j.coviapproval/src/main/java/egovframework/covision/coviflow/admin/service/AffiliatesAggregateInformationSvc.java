package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;


public interface AffiliatesAggregateInformationSvc {
	public CoviMap getEntCountList(CoviMap params) throws Exception;
	public CoviMap getEntMonthlyCountList(CoviMap params) throws Exception;	
}
