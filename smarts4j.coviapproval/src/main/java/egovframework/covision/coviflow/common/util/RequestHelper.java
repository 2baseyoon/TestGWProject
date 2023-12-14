/**
 * @Class Name : RequestHelper.java
 * @Description : 
 * @Modification Information 
 * @ 2017.02.10 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 02.10
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
package egovframework.covision.coviflow.common.util;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import egovframework.baseframework.util.json.JSONParser;
import org.springframework.util.StreamUtils;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.HttpsUtil;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.idgnr.impl.Base64;

public class RequestHelper {	
	
	private static final Logger LOGGER = LogManager.getLogger(ChromeRenderManager.class);
	
	public static CoviMap sendPOST(String pURL, CoviMap pJsonObj) throws Exception{
		URL url = new URL(pURL);

		TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
			public java.security.cert.X509Certificate[] getAcceptedIssuers() {
				return null;
			}

			public void checkClientTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}

			public void checkServerTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}
		} };

		SSLContext context = SSLContext.getInstance("SSL");
		context.init(null, trustAllCerts, new java.security.SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(context.getSocketFactory());
		HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
			@Override
			public boolean verify(String paramString, SSLSession paramSSLSession) {
				if("Y".equalsIgnoreCase(egovframework.baseframework.util.PropertiesUtil.getGlobalProperties().getProperty("https.url.hostname.verify"))) {
					return false;
				}else {
					return true;
				}
			}
		});

		// make connection
		HttpURLConnection urlc = (HttpURLConnection) url.openConnection();

		String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
		String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");

		urlc.setDoOutput(true);
		urlc.setRequestMethod("POST");
		urlc.setRequestProperty("Content-Type", "application/json");
		urlc.setRequestProperty(
				"Authorization",
				"Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8))
				);

		OutputStream os = null;
		OutputStreamWriter writer = null;
		try {
			os = urlc.getOutputStream();
			writer = new OutputStreamWriter(os, StandardCharsets.UTF_8);
			writer.write(pJsonObj.toString());
			if(writer != null) {
				try {
					writer.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			os.flush();
			if(os != null) {
				try {
					os.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			
			// get result
			BufferedReader br = null;
			StringBuffer response = new StringBuffer();

			try {
				br = new BufferedReader(new InputStreamReader(urlc.getInputStream(),StandardCharsets.UTF_8));
				String inputLine = "";
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine);
				}
			} catch (FileNotFoundException e) {
				throw new FileNotFoundException("FileNotFound");
			} catch (Exception ex) {
				throw ex;
			} finally {
				if(br != null) {
					try {
						br.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			}


			CoviMap result = new CoviMap();
			if(response.length() != 0){
				JSONParser parser = new JSONParser();
				Object returnedObj = parser.parse(response.toString());
				result.put("result", returnedObj);
			}
			return result;
		}finally {
			if(os != null) {
				try {
					os.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}if(writer != null) {
				try {
					writer.close();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
	} 
	
	public static CoviMap sendGET(String pURL) throws Exception{
		URL url = new URL(pURL);

		TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
			public java.security.cert.X509Certificate[] getAcceptedIssuers() {
				return null;
			}

			public void checkClientTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}

			public void checkServerTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}
		} };

		SSLContext context = SSLContext.getInstance("SSL");
		context.init(null, trustAllCerts, new java.security.SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(context.getSocketFactory());
		HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
			@Override
			public boolean verify(String paramString, SSLSession paramSSLSession) {
				if("Y".equalsIgnoreCase(egovframework.baseframework.util.PropertiesUtil.getGlobalProperties().getProperty("https.url.hostname.verify"))) {
					return false;
				}else {
					return true;
				}
			}
		});

		// make connection
		HttpURLConnection urlc = (HttpURLConnection) url.openConnection();

		String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
		String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");

		urlc.setDoOutput(true);
		urlc.setRequestMethod("GET");
		urlc.setRequestProperty("Content-Type", "application/json");
		urlc.setRequestProperty(
				"Authorization",
				"Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8))
				);

		// get result
		StringBuffer response = new StringBuffer();

		try (BufferedReader br = new BufferedReader(new InputStreamReader(urlc.getInputStream(),StandardCharsets.UTF_8))){
			String inputLine = "";
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine);
			}
		} catch (FileNotFoundException e) {
			throw new FileNotFoundException("FileNotFound");
		} catch (Exception ex) {
			throw ex;
		}


		CoviMap result = new CoviMap();
		if(response.length() != 0){
			JSONParser parser = new JSONParser();
			Object returnedObj = parser.parse(response.toString());
			result.put("result", returnedObj);
		}
		return result;
	}
	
	// 일반적인 HTTP(S) 호출결과 받을 경우, 200 응답외의 경우 Exception 처리되는 메소드 호출.
	public static Map<String, Object> sendUrl(String url, String contentType, String method, CoviMap pJsonObj) throws Exception{
		return new HttpsUtil().httpsClientConnectResponse(url, method, pJsonObj, "UTF-8", "");
	}
	
	// 요청 페이지 response를 그대로 받음
	public static String sendGETForStream(String pURL, HttpServletRequest request, HttpServletResponse response) throws Exception{
		String result = "OK";
		
		URL url = new URL(pURL);

		TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
			public java.security.cert.X509Certificate[] getAcceptedIssuers() {
				return null;
			}

			public void checkClientTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}

			public void checkServerTrusted(
					java.security.cert.X509Certificate[] certs, String authType) {
			}
		} };

		SSLContext context = SSLContext.getInstance("SSL");
		context.init(null, trustAllCerts, new java.security.SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(context.getSocketFactory());
		HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
			@Override
			public boolean verify(String paramString, SSLSession paramSSLSession) {
				if("Y".equalsIgnoreCase(egovframework.baseframework.util.PropertiesUtil.getGlobalProperties().getProperty("https.url.hostname.verify"))) {
					return false;
				}else {
					return true;
				}
			}
		});

		// make connection
		HttpURLConnection urlc = (HttpURLConnection) url.openConnection();

		String activitiID = PropertiesUtil.getGlobalProperties().getProperty("activiti.id");
		String activitiPW = PropertiesUtil.getGlobalProperties().getProperty("activiti.pw");

		urlc.setDoOutput(true);
		urlc.setRequestMethod("GET");
		urlc.setRequestProperty("Content-Type", "application/json");
		urlc.setRequestProperty(
				"Authorization",
				"Basic " + Base64.encode((activitiID + ":" + activitiPW).getBytes(StandardCharsets.UTF_8))
				);

		try {
			
			if (urlc.getResponseCode() != HttpURLConnection.HTTP_OK) {
    			StringBuffer sbResponse = new StringBuffer();
    			
    			BufferedReader br = null;
    			InputStreamReader isr = null;
    			try {
    				isr = new InputStreamReader(urlc.getErrorStream(),StandardCharsets.UTF_8);
    				br = new BufferedReader(isr);
    				
    				String inputLine = "";
    				while ((inputLine = br.readLine()) != null) {
    					sbResponse.append(inputLine);
    				}
    				result = sbResponse.toString();
    			} finally {
    				if(isr != null) {
    					try {
    						isr.close();
    					}catch(NullPointerException npE) {
    						LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
    					}
    				}
    				if(br != null) {
    					try {
    						br.close();
    					}catch(NullPointerException npE) {
    						LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
    					}
    				}
    			}
    		}else {
    			StreamUtils.copy(urlc.getInputStream(), response.getOutputStream());
				response.flushBuffer();
    		}
			
		} catch (FileNotFoundException e) {
			throw new FileNotFoundException("FileNotFound");
		} catch (Exception ex) {
			throw ex;
		} finally {
			if(urlc != null) {
				try {
					urlc.disconnect();
				}catch(NullPointerException npE) {
					LOGGER.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return result;
	}
	
}
