package egovframework.covision.groupware.oauth2.web;

import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map.Entry;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Settings {
	private static final Logger LOGGER = LogManager.getLogger(Settings.class);
	
	public static final String RESPONSE_TYPE = "code";
	public static final String SCOPE = "personalinfo";

	public static String getParamString(HashMap<String,String> map, boolean useAuthHeader) throws Exception {
		int i=0;
		String strout = ""; 
		StringBuffer buf = new StringBuffer();
		for(Entry<String, String> entry : map.entrySet()) {
			if (useAuthHeader == true && 
					(entry.getKey().equals("client_id") || entry.getKey().equals("client_secret") )) {
				continue;
			}
			if (i !=0 )	buf.append("&");
			buf.append(entry.getKey()).append("=").append(URLEncoder.encode(entry.getValue(), "utf-8"));
			i++;			
		}
		/*
		for (String key : map.keySet()) {
			if (useAuthHeader == true && 
					(key.equals("client_id") || key.equals("client_secret") )) {
				continue;
			}
			if (i !=0 )	strout += "&";
			strout += key + "=" + URLEncoder.encode(map.get(key), "utf-8");
			i++;
		}*/ 
		strout = buf.toString();		
		return strout;
	}
}
