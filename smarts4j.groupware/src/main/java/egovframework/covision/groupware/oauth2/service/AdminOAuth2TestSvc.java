package egovframework.covision.groupware.oauth2.service;


public interface AdminOAuth2TestSvc {
	public String getValue(String code) throws Exception;
	public String getClient(String key, String userId) throws Exception;
	
	
}
