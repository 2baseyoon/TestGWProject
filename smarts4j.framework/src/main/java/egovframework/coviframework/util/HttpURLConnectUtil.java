package egovframework.coviframework.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.apache.http.client.utils.URIBuilder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import org.egovframe.rte.fdl.idgnr.impl.Base64;

public class HttpURLConnectUtil{
	
	private HttpURLConnection conn = null;
	private String responseCode = "";
	private String responseMessage = "";
	private String responseType = "";

	Logger log = LogManager.getLogger(HttpURLConnectUtil.class);
	
	public CoviMap httpConnect(String encodedUrl, String method, int connetTime, int readTime, String conType, String logUseYn) throws Exception{
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap resultList = new CoviMap();
		String RequestDate = func.getCurrentTimeStr();
		String responseMsg = "";
		String jsonText = "";
		int statusCode = 404;
		URL url;
		
		try {
			url = new URL(encodedUrl);
			conn = (HttpURLConnection) url.openConnection();
	        conn.setRequestMethod(method); 
	        conn.setConnectTimeout(connetTime); 
	        conn.setReadTimeout(readTime); 
	        conn.setDoInput(true);
	        conn.setDoOutput(true);
	        conn.setUseCaches(false);
	        if(func.f_NullCheck(conType).equals("xform")){
		       conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
	        }
	        
	        log.info("[HttpURLConnect] ["+url+"] Connect Start");
	        try (InputStream in = conn.getInputStream();
	                ByteArrayOutputStream out = new ByteArrayOutputStream()) {
	            
	            byte[] buf = new byte[1024 * 8];
	            int length = 0;
	            while ((length = in.read(buf)) != -1) {
	                out.write(buf, 0, length);
	            } 
	
	            jsonText = new String(out.toByteArray(), "UTF-8");
	            resultList = CoviMap.fromObject(jsonText);
	            log.info("[HttpURLConnect] ["+url+"] Return Msg : "+resultList);
	           	
	        }
	        
	        statusCode = conn.getResponseCode();
	        
		} catch(NullPointerException e){	
			responseMsg = e.toString();
			statusCode = 500;
			resultList = new CoviMap();
			resultList.put("returnCode", "0");
			resultList.put("returnMsg", responseMsg);
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		} catch (Exception e) {
			responseMsg = e.toString();
			statusCode = 500;
			resultList = new CoviMap();
			resultList.put("returnCode", "0");
			resultList.put("returnMsg", responseMsg);
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		}finally{
			if(func.f_NullCheck(logUseYn).equals("Y")){
				int cnt = encodedUrl.indexOf("&pw=");
				if(!func.f_NullCheck(encodedUrl).equals("")){
					if(cnt > 0 && encodedUrl.indexOf("mailapi.php") > 0){
						encodedUrl = encodedUrl.substring(0, cnt+4);
					}
				}
				params.put("LogType","URL");
				params.put("Method",method);
				params.put("ConnetURL",encodedUrl);
				
				params.put("RequestDate", RequestDate);
				params.put("ResultState", Integer.toString(statusCode));
				params.put("RequestBody", "");
				
				if(func.f_NullCheck(responseMsg).equals("")){
					if(statusCode < 299){
						params.put("ResultType", "SUCCESS");
					}else{
						params.put("ResultType", "FAIL");
					}
					params.put("ResponseMsg", jsonText);
				}else{
					params.put("ResultType", "FAIL");
					params.put("ResponseMsg", jsonText);
				}
				
				params.put("ResponseDate", func.getCurrentTimeStr());
				LoggerHelper.httpLog(params);
			}
			
		}
        return resultList;
		
	}
	
	public CoviMap httpXFormConnect(String encodedUrl, String method) throws Exception{
		CoviMap params = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		String responseMsg = "";
		URL url;
		StringBuffer strResult = new StringBuffer();
		
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		try {
			url = new URL(encodedUrl);
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod(method);
			conn.setRequestProperty("Content-Type", "application/json");
			conn.setRequestProperty("Authorization", "Basic " + Base64.encode(("kermit" + ":" + "kermit").getBytes(StandardCharsets.UTF_8)));
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String line = "";
			
			while((line = br.readLine()) != null)
			{
				strResult.append(line);
			}
			if(br != null) br.close();
			
			resultList = CoviMap.fromObject(strResult.toString());
			
		    statusCode = conn.getResponseCode();
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		}finally{
			if(br != null) br.close();
				
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method",method);
        	params.put("ConnetURL",encodedUrl);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(statusCode));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(statusCode < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", strResult.toString());
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
		}
		
		return resultList;
	}
	
	public CoviMap httpURLConnect(String encodedUrl, String method,  int connetTime, int readTime, String inputParamString, String conType) throws Exception{
		URL url;
		StringUtil func = new StringUtil();
		String responseMsg = "";
		CoviMap params = new CoviMap();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		StringBuffer response = new StringBuffer();
		BufferedReader br = null;
		try {
		
			url = new URL(encodedUrl);
			conn = (HttpURLConnection) url.openConnection();
			conn.setReadTimeout(readTime);
			conn.setConnectTimeout(connetTime);
			conn.setRequestMethod(method);
			conn.setDoInput(true);
			conn.setDoOutput(true);
			
			if(!func.f_NullCheck(inputParamString).equals("") && func.f_NullCheck(conType).equals("")){
				
				try (DataOutputStream wr = new DataOutputStream(conn.getOutputStream());){
					wr.writeBytes(inputParamString);
					wr.flush();
				}
				int responseCode = conn.getResponseCode();
				
				if (responseCode == 200) { // 정상 호출
					br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
				} else { 
					// 에러 발생
					// 오류 처리 추가 할 것				
					br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
				}
				
				String inputLine;
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine);
				}
				if(br != null) br.close();
				
			}else{
				if(func.f_NullCheck(conType).equals("json")){
					conn.setRequestProperty("Accept", "application/json");
				}
				
				if (conn.getResponseCode() != 200) {
					throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
				}

				br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));

				String output;
				while ((output = br.readLine()) != null) {
					response.append(output);
				}
				if(br != null) br.close();
			}
			statusCode = conn.getResponseCode();
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+encodedUrl+"] Connect Exception : " + e.toString());
		}finally{
			if(br != null) br.close();
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			if(encodedUrl.indexOf("sendmessaging") > 0 && statusCode < 299){
				responseType = "SUCCESS";
				responseMessage = responseMsg;
			}else{
				params.put("LogType","URL");
				params.put("Method",method);
				params.put("ConnetURL",encodedUrl);
				
				params.put("RequestDate", RequestDate);
				params.put("ResultState", Integer.toString(statusCode));
				params.put("RequestBody", "");
				
				if(func.f_NullCheck(responseMsg).equals("")){
					if(statusCode < 299){
						params.put("ResultType", "SUCCESS");
					}else{
						params.put("ResultType", "FAIL");
					}
					params.put("ResponseMsg", response.toString());
					responseMessage = response.toString();
				}else{
					params.put("ResultType", "FAIL");
					params.put("ResponseMsg", responseMsg);
					responseMessage = responseMsg;
				}
				responseType = params.getString("ResultType");
				
				params.put("ResponseDate", func.getCurrentTimeStr());
				LoggerHelper.httpLog(params);
				
			}
		}
		return params;
		
	}
	
	public CoviMap translateAPI(String sourceLang, String targetLang, String pText) throws Exception{
		/*
		 * 네이버 기계번역 API 연결 계정 정보
		 * gwcovision@naver.com
		 * 비번 : Covi@2019
		 * */
		String clientId = "8n3k_sBbGLhIedow3tna";	// 애플리케이션 클라이언트 아이디값
		String clientSecret = "taZcHOOlS0";			// 애플리케이션 클라이언트 시크릿값
		StringBuffer response = new StringBuffer();
		String responseMsg = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		
		try {
			String text = URLEncoder.encode(pText, "UTF-8");
			String apiURL = "https://openapi.naver.com/v1/papago/n2mt";
			URL url = new URL(apiURL);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("X-Naver-Client-Id", clientId);
			conn.setRequestProperty("X-Naver-Client-Secret", clientSecret);
			
			// post request
			String postParams = "source=" + sourceLang + "&target=" + targetLang + "&text=" + text;
			conn.setDoOutput(true);
			try(DataOutputStream wr = new DataOutputStream(conn.getOutputStream());){
				wr.writeBytes(postParams);
				wr.flush();
			}
			statusCode = conn.getResponseCode();
			if (statusCode == 200) { // 정상 호출
				br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			} else { 
				// 에러 발생
				// 오류 처리 추가 할 것				
				br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
			}
			String inputLine;
		
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine);
			}
			if(br != null) br.close();
			
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [https://openapi.naver.com/v1/papago/n2mt] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [https://openapi.naver.com/v1/papago/n2mt] Connect Exception : " + e.toString());
		}finally{
			if(br != null) br.close();
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method","POST");
        	params.put("ConnetURL","https://openapi.naver.com/v1/papago/n2mt");
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(statusCode));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(statusCode < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", response.toString());
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
			
		}	
			
		return CoviMap.fromObject(response.toString());
	}
	
	public String jusoAPI(String currentPage, String keyword, String countPerPage) throws Exception{
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";
		String apiUrl = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		
		try {
			apiUrl = "http://www.juso.go.kr/addrlink/addrLinkApi.do?currentPage=" + currentPage
					+ "&countPerPage=" + countPerPage
					+ "&keyword=" + URLEncoder.encode(keyword, "UTF-8")
					+ "&confmKey=U01TX0FVVEgyMDE3MDgyOTEzNTMwODEwNzI5NTI="
					+ "&resultType=json";
			
			URL url = new URL(apiUrl);
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("POST");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			if(br != null) br.close();
			
			statusCode = conn.getResponseCode();
			
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://www.juso.go.kr/addrlink/addrLinkApi.do] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://www.juso.go.kr/addrlink/addrLinkApi.do] Connect Exception : " + e.toString());
		}finally{
			if(br != null)  br.close();
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method","POST");
        	params.put("ConnetURL","http://www.juso.go.kr/addrlink/addrLinkApi.do");
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(statusCode));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(statusCode < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", sb.toString());
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
			
		}
		
		return sb.toString();
		
	}
	
	public String covid19API(String sDate, String eDate) throws Exception{
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		try {
			StringBuilder urlBuilder = new StringBuilder("http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson");
	        urlBuilder.append("?" + URLEncoder.encode("ServiceKey", "UTF-8") + "=ixg4oIUP35vHv%2BSuc%2FkFLsdqq8AHQbGjPD%2BQ5YnE29M1YwnCFTIcKGZrh7qpbvCgQIQnyNLFtDb6AIS55MI%2FNA%3D%3D");
	        urlBuilder.append("&" + URLEncoder.encode("startCreateDt", "UTF-8") + "=" + URLEncoder.encode(sDate, "UTF-8"));
	        urlBuilder.append("&" + URLEncoder.encode("endCreateDt", "UTF-8") + "=" + URLEncoder.encode(eDate, "UTF-8"));
	        
	        URL url = new URL(urlBuilder.toString());
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("GET");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			if(br != null) br.close();
			
			statusCode = conn.getResponseCode();
			
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson] Connect Exception : " + e.toString());
		}finally{
			if(br != null)  br.close();
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method","GET");
			params.put("ConnetURL","http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson");
			
			params.put("RequestDate", RequestDate);
			params.put("ResultState", Integer.toString(statusCode));
			params.put("RequestBody", "");
			
			if(func.f_NullCheck(responseMsg).equals("")){
				if(statusCode < 299){
					params.put("ResultType", "SUCCESS");
				}else{
					params.put("ResultType", "FAIL");
				}
				params.put("ResponseMsg", sb.toString());
			}else{
				params.put("ResultType", "FAIL");
				params.put("ResponseMsg", responseMsg);
			}
			
			params.put("ResponseDate", func.getCurrentTimeStr());
			LoggerHelper.httpLog(params);
			
		}
		
		return sb.toString();
		
	}
	
	public String openWeatherAPI(String cityName) throws Exception{
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		try {
			if(cityName == null || cityName.equals("")){
				cityName = "Korea";
			}
			
			String apiURL = "http://api.openweathermap.org/data/2.5/weather"
						  + "?q=" + cityName
						  + "&appid=e7b42477b494f1aa92b8510382c77957"
						  + "&units=metric";
			
			URL url = new URL(apiURL);
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("GET");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			if(br != null)  br.close();
			
			statusCode = conn.getResponseCode();
			
		} catch(NullPointerException e){	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://api.openweathermap.org/data/2.5/weather] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] [http://api.openweathermap.org/data/2.5/weather] Connect Exception : " + e.toString());
		}finally{
			if(br != null)  br.close();
			if(conn != null){
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method","GET");
			params.put("ConnetURL","http://api.openweathermap.org/data/2.5/weather");
			
			params.put("RequestDate", RequestDate);
			params.put("ResultState", Integer.toString(statusCode));
			params.put("RequestBody", "");
			
			if(func.f_NullCheck(responseMsg).equals("")){
				if(statusCode < 299){
					params.put("ResultType", "SUCCESS");
				}else{
					params.put("ResultType", "FAIL");
				}
				params.put("ResponseMsg", sb.toString());
			}else{
				params.put("ResultType", "FAIL");
				params.put("ResponseMsg", responseMsg);
			}
			
			params.put("ResponseDate", func.getCurrentTimeStr());
			LoggerHelper.httpLog(params);
			
		}
		
		return sb.toString();
		
	}
	
	public String kmaWeatherAPI(CoviMap pWeatherParams) throws Exception{
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		BufferedReader br = null;
		
		String weatherUrl = RedisDataUtil.getBaseConfig("weatherAPIUrl", SessionHelper.getSession("DN_ID"));
		if ("".equals(weatherUrl)) weatherUrl = "http://api.openweathermap.org/data/2.5/weather";
		
		String appID = RedisDataUtil.getBaseConfig("weatherAPIKey", SessionHelper.getSession("DN_ID"));
		if ("".equals(appID)) appID = "appid=e7b42477b494f1aa92b8510382c77957";
		
		weatherUrl += "?" + appID;
		
		try {
			URIBuilder builder = new URIBuilder(weatherUrl);
			
			for(Object obj : pWeatherParams.keySet()){
				String key = obj.toString();
				builder.addParameter(key, pWeatherParams.getString(key));
			}

			URL url = builder.build().toURL();

			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("GET");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			if(br != null) br.close();
			
			statusCode = conn.getResponseCode();
			
		} catch(NullPointerException e) {	
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+weatherUrl+"] Connect Exception : " + e.toString());
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
			log.info("[HttpURLConnect] ["+weatherUrl+"] Connect Exception : " + e.toString());
		} finally {
			if(br != null) br.close();
			if(conn != null) {
				conn.disconnect();
				conn = null;
			}
			
			params.put("LogType","URL");
			params.put("Method","GET");
			params.put("ConnetURL", weatherUrl);
			
			params.put("RequestDate", RequestDate);
			params.put("ResultState", Integer.toString(statusCode));
			params.put("RequestBody", "");
			
			if(func.f_NullCheck(responseMsg).equals("")){
				if(statusCode < 299) {
					params.put("ResultType", "SUCCESS");
				} else {
					params.put("ResultType", "FAIL");
				}
				params.put("ResponseMsg", sb.toString());
			} else {
				params.put("ResultType", "FAIL");
				params.put("ResponseMsg", responseMsg);
			}
			
			params.put("ResponseDate", func.getCurrentTimeStr());
			LoggerHelper.httpLog(params);
		}
		
		return sb.toString();
		
	}
	
	public void httpDisConnect(){
		if(conn != null){
			log.info("[HttpURLConnect] Connect Close");
			conn.disconnect(); 
			conn = null;
		}
	}
	
	public String getResponseCode() {
		return responseCode;
	}

	public String getResponseMessage() {
		return responseMessage;
	}
	
	public String getResponseType() {
		return responseType;
	}
}
