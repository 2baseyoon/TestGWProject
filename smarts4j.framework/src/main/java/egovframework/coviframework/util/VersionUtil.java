/*
 * Copyright yysvip.tistory.com.,LTD.
 * All rights reserved.
 * 
 * This software is the confidential and proprietary information
 * of yysvip.tistory.com.,LTD. ("Confidential Information").
 */
package egovframework.coviframework.util; 

import java.io.IOException;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.util.PropertiesUtil;

public class VersionUtil {
	
	private static Logger LOGGER = LogManager.getLogger(VersionUtil.class);
	
	public static String getGroupwareVersion() {
		String version = "";
		
		Properties properties = new Properties();
		try {
			properties.load(VersionUtil.class.getResourceAsStream("/META-INF/maven/com.covision/smarts4j.framework/pom.properties"));
			version = properties.getProperty("version");
		} catch (IOException e) {
			LOGGER.error("Groupware Version Loading Error : {}", e.getMessage());
		} catch (Exception e) {
			LOGGER.error("Groupware Version Loading Error : {}", e.getMessage());
		}
		
		return version;
	}
	
	public static String getBaseframeworkVersion() {
		String version = "";
		
		Properties properties = new Properties();
		try {
			properties.load(PropertiesUtil.class.getResourceAsStream("/META-INF/maven/framework.saas/baseframework/pom.properties"));
			version = properties.getProperty("version");
		} catch (IOException e) {
			LOGGER.error("Baseframework Version Loading Error : {}", e.getMessage());
		} catch (Exception e) {
			LOGGER.error("Baseframework Version Loading Error : {}", e.getMessage());
		}
		
		return version;
	}	
}