package egovframework.covision.coviflow.legacy.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface DistributionSvc {
	public String startDistribution(String params) throws Exception;
	public void deleteDistribution(String params) throws Exception;
	public CoviList selectReceiptPersonInfo(CoviMap params) throws Exception;
}
