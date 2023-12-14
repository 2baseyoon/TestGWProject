package egovframework.coviframework.service;

import java.sql.Connection;
import javax.annotation.PostConstruct;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ExtDatabasePoolSvc {
	@PostConstruct
	public void init();
	public Connection getConnection(String poolName);
	public String getEncryptedPasswd(String plain);
	public String getDecryptedPasswd(String enc);
	public void close(AutoCloseable... resource) throws Exception;
	public boolean release(String... datasourceSeqs) throws Exception;
	public void reload(String poolName);
	public java.util.Map<String, String> getPoolNameMap();
	
	public CoviList getDatasourceSelectData(CoviMap params) throws Exception;
	public CoviMap selectDatasourceList(CoviMap params) throws Exception;
	public CoviMap selectDatasource(CoviMap params) throws Exception;
	public int insertDatasource(CoviMap params) throws Exception;
	public int updateDatasource(CoviMap params) throws Exception;
	public int deleteDatasource(CoviMap params) throws Exception;
}
