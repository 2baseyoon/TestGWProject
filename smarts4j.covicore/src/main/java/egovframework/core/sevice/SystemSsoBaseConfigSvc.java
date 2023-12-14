package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SystemSsoBaseConfigSvc {

	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectList(CoviMap params) throws Exception;
	public CoviMap selectClientList(String urCode) throws Exception;
	
	public int updateIsUse(CoviMap params)throws Exception;
	public int selectClient(CoviMap params) throws Exception;
	public int selectToken(CoviMap params) throws Exception;
	
	public String getDomainURL(CoviMap params) throws Exception;
	
	public boolean update(CoviMap params) throws Exception;
	public boolean updateClient(CoviMap params) throws Exception;
	public boolean createClient(CoviMap params) throws Exception;
	public boolean deleteClient(CoviMap params) throws Exception;
	public boolean deleteToken(CoviMap params) throws Exception;
	
}
