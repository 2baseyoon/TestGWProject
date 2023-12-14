package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface EumSvc {

	public boolean messengerAuthHis(CoviMap params) throws Exception;
	public CoviMap selectTokenInfo(CoviMap params) throws Exception;
	public CoviMap selectUserInfo(CoviMap params)throws Exception;
	public boolean updateAccessToken(CoviMap params)throws Exception;
}
