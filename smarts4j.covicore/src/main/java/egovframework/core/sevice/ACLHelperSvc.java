package egovframework.core.sevice;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ACLHelperSvc { 
	public CoviList selectDomain(CoviMap params) throws Exception;
	public CoviList selectServiceType(CoviMap params) throws Exception;
	public String getDomainID(CoviMap params) throws Exception;
}
