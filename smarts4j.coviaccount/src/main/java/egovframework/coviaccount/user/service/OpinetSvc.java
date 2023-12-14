package egovframework.coviaccount.user.service;

import egovframework.baseframework.data.CoviMap;


public interface OpinetSvc {
	
	public CoviMap getList(CoviMap params) throws Exception;
	
	public void getSync() throws Exception;
	
	public CoviMap getOpinet(CoviMap params) throws Exception;
}
