package egovframework.covision.coviflow.user.service;


import egovframework.baseframework.data.CoviMap;

public interface SignRegistrationSvc {
	public CoviMap selectUserSignList(CoviMap params) throws Exception;
	public CoviMap selectUserSignImage(CoviMap params) throws Exception;
	public int deleteUserSign(CoviMap params) throws Exception;
	public int updateUserSignUse(CoviMap params)throws Exception;
	public int insertUserSign(CoviMap params);
	public int updateUserSign(CoviMap params);
	public int selectUserSignAuth(CoviMap params);
}
