package egovframework.core.util;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@Controller
public class OrgSyncDBConnect {

	private static final Logger LOGGER = LogManager.getLogger(OrgSyncDBConnect.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	private volatile static OrgSyncDBConnect connector = null;
   
	private	OrgSyncDBConnect(){}
	
	public static OrgSyncDBConnect getInstance(){
		if(connector == null){
			synchronized(OrgSyncDBConnect.class) {
				if(connector == null){
					connector = new OrgSyncDBConnect();
				}
			}
		}
		return connector;
	}
	static {
		try {
			// 1. MS-SQL JDBC 드라이버 로드
			// String driverNm = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
			String driverNm = "org.mariadb.jdbc.Driver";
			Class.forName(driverNm);
		} catch (ClassNotFoundException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} 
    }	
	
	public Connection getHRConnection() {
		Connection con = null;
		
		// 2. DriverManager.getConnection()를 이용하여 Connection 인스턴스 생성
		// DB 연결정보는 기초설정에서 가져옴.
		String url = RedisDataUtil.getBaseConfig("HRConStr");
		String user = RedisDataUtil.getBaseConfig("HRConUser");
		//String pwd =  PropertiesUtil.getDecryptedProperty("ENC("+RedisDataUtil.getBaseConfig("HRConPW").toString()+")");
		String pwd =  RedisDataUtil.getBaseConfig("HRConPW");
		
		LOGGER.debug("url : " + url);
		LOGGER.debug("user : " + user);
		LOGGER.debug("pwd : " + pwd);
		try {
			con = DriverManager.getConnection(url, user, pwd);
			if (con != null) {
				LOGGER.debug("Connection Successful!!!");
			}
		}
		catch(SQLException e) {
			LOGGER.error("Connection Fail!!!", e);
		}
		
		return con;
	}
	
}
