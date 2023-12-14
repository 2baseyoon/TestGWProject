package egovframework.covision.coviflow.govdocs.record.handler;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.commons.codec.binary.Base64;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.vo.xml.ServerConfigVO;
//import gr.classes.client.MultiClient;

public class AuthHandler {
	
	private Logger LOGGER = LogManager.getLogger(AuthHandler.class);
	
	//Gr모듈 연동을 위한 Client 객체
	//private MultiClient mc;
	
	private String conIp;
	private String conPort;
	private String className;
	
	private String conId;
	private String conPwd;
	
	private String key;
	
	private String workDir;
	private String rcCode;
	
	public AuthHandler(){
		init();
	}
	
	private void init(){
        Properties prop = new Properties();
        try {
        	
        	String grConfigDir = PropertiesUtil.getGlobalProperties().getProperty("gr.config.dir");
        	System.setProperty("user.home", grConfigDir);
        	
        	File config = new File(FileUtil.checkTraversalCharacter(System.getProperty("user.home")), "config.properties");
        	
			try(InputStream fis = new FileInputStream(config);){
				prop.load(fis);
			}
			
			this.conIp = prop.getProperty("setting.ip");
			this.conPort = prop.getProperty("setting.port");
			
			this.className = prop.getProperty("setting.className");
			
			this.workDir = prop.getProperty("setting.rootPath");
			this.rcCode = prop.getProperty("setting.rcCode");
			
			this.conId = new String(Base64.decodeBase64("YWRtaW4="), StandardCharsets.UTF_8);
            this.conPwd = new String(Base64.decodeBase64("YWRtaW4="), StandardCharsets.UTF_8);

			//this.mc = new MultiClient();
			
			LOGGER.info("GR Module Auth Infomation ==========");
			LOGGER.info("gr config dir : {}", grConfigDir);
			LOGGER.info("gr con ip : {}", conIp);
			LOGGER.info("gr con conPort : {}", conPort);
			LOGGER.info("gr className : {}", className);
			LOGGER.info("gr workDir : {}", workDir);
			LOGGER.info("gr rcCode : {}", rcCode);
			
		} catch (IOException e) {
			LOGGER.error(e.getMessage());
		}
		
	}
	
	public void conStatusLog(){
		LOGGER.info("Connect RMS System information");
		LOGGER.info("Connect IP : {}, PORT : {}, ID : {}, PWD : {}", this.conIp, this.conPort, this.conId, this.conPwd);
	}
	
	public String getConIp() {
		return conIp;
	}

	public void setConIp(String conIp) {
		this.conIp = conIp;
	}

	public String getConPort() {
		return conPort;
	}

	public void setConPort(String conPort) {
		this.conPort = conPort;
	}

	public String getClassName() {
		return className;
	}

	public void setClassName(String className) {
		this.className = className;
	}

	public String getKey(){
		return this.key;
	}
	
	public String getWorkDir() {
		return workDir;
	}

	public String getRcCode() {
		return rcCode;
	}

	public void setRcCode(String rcCode) {
		this.rcCode = rcCode;
	}

	public ServerConfigVO getServerConfig(String type){
		
		ServerConfigVO configVo = new ServerConfigVO();
		
		if("SEND".equals(type)){
			String sendServerIp = PropertiesUtil.getGlobalProperties().getProperty("gr.server.ip");
			String sendClassName = PropertiesUtil.getGlobalProperties().getProperty("gr.className");
			
			configVo.setIp(sendServerIp);
			configVo.setClassName(sendClassName);
		} else {
			configVo.setIp(this.conIp);
			configVo.setClassName(this.className);
		}
		configVo.setPort(this.conPort);
		configVo.setGrLanguage("JAVA");
		
		return configVo;
	}
	
	
	public String loginApi(){
		return login();
	}
	
	public String callSendFile(String filePath){
		//return this.mc.sendFile(filePath);
		return "";
	}
	
	public void logoutApi(){
		String result = ""; //mc.logout(this.conIp, this.conPort, this.conId, this.key);
		if("00000".equals(result)){
			LOGGER.info("API Logout success");
		} else {
			LOGGER.info("API Logout failed");
		}
	}
	
	private String login(){
		String result = "";
		String loginStatus = "";
		
		result = lineCheck();
		LOGGER.info("Connect Line checked result : {}", result);
		
		if("00000".equals(result)){
			//loginStatus = mc.login(this.conIp, this.conPort, this.conId, this.conPwd);
			LOGGER.info("RMS Gr-Api login status : {}", loginStatus);
			
			if("20704".equals(loginStatus)){
				//loginStatus = mc.certInit(this.conIp, this.conPort, this.conId, this.conPwd);
				//loginStatus = mc.login(this.conIp, this.conPort, this.conId, this.conPwd);
				LOGGER.info("RMS Gr-Api  relogin status : {}", loginStatus);
			}
			
			if(loginStatus.startsWith("00000") && loginStatus.length() > 5){
				this.key = loginStatus.substring(5);
				LOGGER.info("RMS Gr-Api login key : {}", this.key);
			} 
		}
		
		return result;
	}
	
	public String lineCheck(){
		return ""; //this.mc.lineCheck(this.conIp, this.conPort, this.className, "JAVA");
	}
	
	public String getErrorContent(String errorCode){
		return ""; //this.mc.getErrorContent(errorCode);
	}
	
}
