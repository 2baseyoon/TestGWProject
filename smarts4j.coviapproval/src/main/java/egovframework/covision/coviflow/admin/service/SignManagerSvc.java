package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface SignManagerSvc {
	public CoviMap getSignList(CoviMap params) throws Exception;
	public CoviMap getSignData(CoviMap params) throws Exception;
	public int insertSignData(CoviMap params)throws Exception;
	public int deleteSignImage(CoviMap params)throws Exception;
	public int changeUseSign(CoviMap params)throws Exception;
	public int releaseUseSign(CoviMap params)throws Exception;
}
