package egovframework.api.admin.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ConfigSvc {

	public CoviMap getTokenList(CoviMap params) throws Exception;
	public int insertToken(String domainID, String token) throws Exception;
	public int updateToken(CoviMap params) throws Exception;
	public int deleteToken(CoviMap params) throws Exception;
	
	public CoviList getConfigListAll(CoviMap params) throws Exception;
	public CoviMap getConfigList(CoviMap params) throws Exception;
	public CoviMap getConfig(CoviMap params) throws Exception;
	public int insertConfig(CoviMap params) throws Exception;
	public int updateConfig(CoviMap params) throws Exception;
	public int updateConfigIsUse(CoviMap params) throws Exception;
	public int deleteConfig(CoviMap params) throws Exception;
	
	public void synchronizeConfig(CoviMap params) throws Exception;
	
	public CoviMap getIPSecureList(CoviMap params) throws Exception;
	public CoviMap getIPSecure(CoviMap params) throws Exception;
	public int insertIPSecure(CoviMap params) throws Exception;
	public int updateIPSecure(CoviMap params) throws Exception;
	public int updateIPSecureIsUse(CoviMap params) throws Exception;
	public int deleteIPSecure(CoviMap params) throws Exception;
	
	public CoviMap getRequestLogList(CoviMap params) throws Exception;
	public CoviMap getRequestLog(CoviMap params) throws Exception;
	
	public CoviList getRequestStatList(CoviMap params) throws Exception;
}
