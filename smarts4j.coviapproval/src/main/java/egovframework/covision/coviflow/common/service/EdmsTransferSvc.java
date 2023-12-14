package egovframework.covision.coviflow.common.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface EdmsTransferSvc {
	public CoviList getEdmsTrasferTarget() throws Exception;
	public int setFlagMulti(CoviMap param) throws Exception;
	public int setFlag(CoviMap param) throws Exception;
}
