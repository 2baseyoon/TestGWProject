package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.FileUtilService;

public interface StampManagerSvc {
	public CoviMap getStampList(CoviMap params) throws Exception;
	public CoviMap getStampData(CoviMap params) throws Exception;
	public int insertStampData(CoviMap params)throws Exception;
	public int deleteStampData(CoviMap params)throws Exception;
	public int updateStampData(CoviMap params)throws Exception;
	public int setUseStampUse(CoviMap params)throws Exception;
	
}
