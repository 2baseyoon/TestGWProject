package egovframework.coviframework.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import egovframework.coviframework.util.s3.AwsS3;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;



import org.apache.commons.codec.binary.Base64;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;

import java.util.Iterator;
public class HttpClientUtil{
	private static String  boundaryString = "----WebKitFormBoundary7MA4YWxkTrZu0gW";
	
	private static Logger LOGGER = LogManager.getLogger(HttpClientUtil.class);
	
	//httpClient Request
	public CoviMap httpClientConnect(String url, String conType, String method, NameValuePair[] data, int count) throws Exception{
		CoviMap params = new CoviMap();
		
		CoviMap resultList = new CoviMap();
		CoviMap value = new CoviMap();
		
		StringUtil func = new StringUtil();
		
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int status = 404;
		String body = "";
		String responseMsg = "";
		String RequestDate = func.getCurrentTimeStr();
		
		try {
			if(func.f_NullCheck(method).equals("POST")){
				PostMethod conn = new PostMethod(url);
				
				if(func.f_NullCheck(conType).equals("furl")){
					conn.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				}
				
				if(func.f_NullCheck(conType).equals("json")){
					conn.setRequestHeader("Content-Type", "application/json");
				}
				
				conn.setRequestBody(data);
				
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
				
			}
		
		} catch(NullPointerException e){	
			status = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			status = 500;
			responseMsg = e.toString();
		}finally{
			for(int i=0;count > i;i++ ){
				value.put( data[i].getName(), data[i].getValue());
			}
			
			params.put("LogType","CLIENT");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(status));
        	params.put("RequestBody", value.toString());
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(status < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", body);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
			
		}
		
		resultList.put("status", status);
		resultList.put("body", body);
		
		return resultList;
	}

	
	//Restful API Request
	private CoviMap httpRestAPIConnect(String url, String conType, String method, Object paramsObj, CoviMap authHeader) throws Exception{
		CoviMap params = new CoviMap();
		
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int status = 404;
		String body = "";
		String responseMsg = "";
		String RequestDate = func.getCurrentTimeStr();
		String contentType = func.f_NullCheck(conType).equals("json")?"application/json":"";
		Iterator<String> iter = authHeader.keySet().iterator();
		try {
			if(func.f_NullCheck(method).equals("POST")){
				PostMethod conn = new PostMethod(url);
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				
				while(iter.hasNext()){   
					String key = (String)iter.next();
					conn.setRequestHeader(key, authHeader.getString(key));
				}
				
				if(paramsObj instanceof CoviMap) {
					CoviMap paramMap = (CoviMap)paramsObj;
					Iterator<String> paramIt = paramMap.keySet().iterator();
					while(paramIt.hasNext()){   
						String key = (String)paramIt.next();
						conn.addParameter(key, paramMap.getString(key));
					}
				}else{
					conn.setRequestBody(paramsObj.toString());
				}
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}else if(func.f_NullCheck(method).equals("GET")){
				GetMethod conn = new GetMethod(url);
				
				while(iter.hasNext()){   
					String key = (String)iter.next();
					conn.setRequestHeader(key, authHeader.getString(key));
					
				}
				 
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}else if(func.f_NullCheck(method).equals("DELETE")){
				DeleteMethod conn = new DeleteMethod(url);
				
				while(iter.hasNext()){   
					String key = (String)iter.next();
					conn.setRequestHeader(key, authHeader.getString(key));
					
				}
				status = client.executeMethod(conn);
			}else if(func.f_NullCheck(method).equals("PUT")){
				PutMethod conn = new PutMethod(url);
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				while(iter.hasNext()){   
					String key = (String)iter.next();
					conn.setRequestHeader(key, authHeader.getString(key));
					
				}
				
				conn.setRequestBody(paramsObj.toString());
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}else if(func.f_NullCheck(method).equals("PATCH")){
				PostMethod conn = new PostMethod(url + "?_HttpMethod=PATCH");
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				while(iter.hasNext()){   
					String key = (String)iter.next();
					conn.setRequestHeader(key, authHeader.getString(key));
					
				}
				
				conn.setRequestBody(paramsObj.toString());
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}
		} catch(NullPointerException e){	
			status = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			status = 500;
			responseMsg = e.toString();
		}finally{
			params.put("LogType","CLIENT");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(status));
        	params.put("RequestBody", paramsObj.toString());
        	params.put("RequestHeader", authHeader.toString());
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(status < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", body);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
		}
		
		resultList.put("status", status);
		resultList.put("body", body);
		
		return resultList;
	}
		
	public CoviMap httpRestAPIConnect(String url, String conType, String method, String paramsObj , String authHeader) throws Exception{
		CoviMap authHeaderObject = new CoviMap();
		authHeaderObject.put("Authorization",authHeader);
		
		return httpRestAPIConnect(url, conType, method, paramsObj , authHeaderObject);
	}
	
	public CoviMap httpRestAPIConnect(String url, String conType, String method, String paramsObj, CoviMap authHeader) throws Exception{
		return httpRestAPIConnect(url, conType, method, (Object)paramsObj, authHeader);
	}
	
	/**
	 * Use Parameters instead of Request Body.
	 * @param url
	 * @param conType
	 * @param method
	 * @param paramsObj
	 * @param authHeader
	 * @return
	 * @throws Exception
	 */
	public CoviMap httpRestAPIConnect(String url, String conType, String method, CoviMap paramsObj, CoviMap authHeader) throws Exception{
		return httpRestAPIConnect(url, "", method, (Object)paramsObj, authHeader);
	}
	
	//Mail Api 호출 메서드
	@SuppressWarnings("deprecation")
	public CoviMap httpMailRestAPIConnect(String url, String conType, String method, String paramsObj , String authHeader) throws Exception{
		CoviMap params = new CoviMap();
		
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int status = 404;
		String body = "";
		String responseMsg = "";
		String RequestDate = func.getCurrentTimeStr();
		String contentType = "";
		try {
		
			if(func.f_NullCheck(conType).equals("json")){
				contentType = "application/json";
			}
			
			if(func.f_NullCheck(method).equals("POST")){
				PostMethod conn = new PostMethod(url);
				
				conn.setRequestHeader("Authorization", authHeader);
				conn.setRequestBody(paramsObj);
				
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
	
				status = client.executeMethod(conn);
				
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
				
			}else if(func.f_NullCheck(method).equals("GET")){
				GetMethod conn = new GetMethod(url);
				
				if(!func.f_NullCheck(authHeader).equals("")){
					conn.addRequestHeader("Authorization", authHeader);
				}
				 
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				
				status = client.executeMethod(conn);
				
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}else if(func.f_NullCheck(method).equals("DELETE")){
				DeleteMethod conn = new DeleteMethod(url);
				
				conn.addRequestHeader("Authorization", authHeader);
				 
				status = client.executeMethod(conn);
			}else if(func.f_NullCheck(method).equals("PUT")){
				PutMethod conn = new PutMethod(url);
				
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				conn.setRequestHeader("Authorization", authHeader);
				
				conn.setRequestBody(paramsObj);
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}else if(func.f_NullCheck(method).equals("PATCH")){
				PostMethod conn = new PostMethod(url + "?_HttpMethod=PATCH");
				
				if(!func.f_NullCheck(contentType).equals("")){
					conn.setRequestHeader("Content-Type", contentType);
				}
				conn.setRequestHeader("Authorization", authHeader);
				
				conn.setRequestBody(paramsObj);
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			}
		} catch(NullPointerException e){	
			status = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			status = 500;
			responseMsg = e.toString();
		}
		/*
		finally{
			params.put("LogType","CLIENT");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(status));
        	params.put("RequestBody", paramsObj.toString());
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(status < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", body);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
		}
		*/
		resultList.put("status", status);
		resultList.put("body", body);
		
		return resultList;
	}
	
	//httpclient Request (for .Net)
	public CoviMap httpClientNetConnect(String url, String bodyData, String method) throws Exception{
		  CoviMap params = new CoviMap();
			
			CoviMap resultList = new CoviMap();
			CoviMap value = new CoviMap();
			
			StringUtil func = new StringUtil();
			
			HttpClient client = new HttpClient();
			client.getParams().setContentCharset("utf-8");
			
			int status = 404;
			String body = "";
			String responseMsg = "";
			String RequestDate = func.getCurrentTimeStr();
			
		try {
				PostMethod conn = new PostMethod(url);
					
				conn.setRequestHeader("Content-Type", "text/xml");
					
				conn.setRequestBody(bodyData);
					
				status = client.executeMethod(conn);
				try(InputStream is = conn.getResponseBodyAsStream()){
					body = IOUtils.toString(is, StandardCharsets.UTF_8);
				}
			
		} catch(NullPointerException e){	
			status = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			status = 500;
			responseMsg = e.toString();
		}finally{
			params.put("LogType","CLIENT");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(status));
        	params.put("RequestBody", value.toString());
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(status < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", body);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
			
		}
		
		resultList.put("status", status);
		resultList.put("body", body);
		
		return resultList;
	}
	
	//OrgWebAPI 호출 메서드 (AD,Exchange,SFB 연동)
	public CoviMap httpClientOrgConnect(String pType,String method, NameValuePair[] data,String conType) throws Exception{
		CoviMap params = new CoviMap();
		
		CoviMap value = new CoviMap();
		
		StringUtil func = new StringUtil();
		
		HttpClient client = new HttpClient();
		String url = "";
		
		client.getParams().setContentCharset("utf-8");
		
		int status = 404;
		String body = "";
		String responseMsg = "";
		String RequestDate = func.getCurrentTimeStr();
		
		try {
			
			switch(pType.toUpperCase()){
			case "AD": 
				url = PropertiesUtil.getGlobalProperties().getProperty("ADSyncservice.url");
				break;
			case "EXCH":
				url = PropertiesUtil.getGlobalProperties().getProperty("ExchSyncService.url");
				break;
			case "SFB": 
				url = PropertiesUtil.getGlobalProperties().getProperty("SFBSyncService.url");
				break;
			default : 
				url = PropertiesUtil.getGlobalProperties().getProperty("ADSyncservice.url");
				break;
			}
			
			url += "/"+method;
			
			PostMethod conn = new PostMethod(url);
			
			if(func.f_NullCheck(conType).equals("")){
				conn.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			}
			else{
				conn.setRequestHeader("Content-Type", conType);
			}
			String auth = PropertiesUtil.getGlobalProperties().getProperty("OrgWebAPI.auth.id") + ":" +PropertiesUtil.getGlobalProperties().getProperty("OrgWebAPI.auth.password");
			
			byte[] encodedAuth = Base64.encodeBase64(
			auth.getBytes(StandardCharsets.ISO_8859_1));
			String authHeader = "Basic " + new String(encodedAuth, StandardCharsets.UTF_8);
			conn.setRequestHeader("Authorization", authHeader);
			conn.setRequestBody(data);
			
			status = client.executeMethod(conn);
			try(InputStream is = conn.getResponseBodyAsStream()){
				body = IOUtils.toString(is, StandardCharsets.UTF_8);
			}
		
		} catch(NullPointerException e){	
			status = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			status = 500;
			responseMsg = e.toString();
		}finally{
			for(int i=0;data.length > i;i++ ){
				value.put( data[i].getName(), data[i].getValue());
			}
			
			params.put("LogType","CLIENT");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(status));
        	params.put("RequestBody", value.toString());
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(status < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", body);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
			
		}
		
		return parseOrgSyncResult(body);
	}
	
	//OrgWebAPI 호출 메서드 (AD,Exchange,SFB 연동)
	public CoviMap httpClientOrgConnect(String pType,String method, NameValuePair[] data) throws Exception{
		return httpClientOrgConnect(pType,method, data,"");
	}
	
	//OrgWebAPI 리턴 XML Parser (AD,Exchange,SFB 연동)
	public CoviMap parseOrgSyncResult(String pXML)
	{
		CoviMap resultList = new CoviMap();

        DocumentBuilderFactory dbf = null;
        DocumentBuilder db = null;
        Document doc = null;
        NodeList nodes = null;
        Node node = null;
        Element element = null;
        InputSource is = new InputSource();
        String strResult = "";
        String strReason = "";
		
        try
        {
        	dbf = DocumentBuilderFactory.newInstance();
        	db = dbf.newDocumentBuilder();
        	is = new InputSource();
        	is.setCharacterStream(new StringReader(pXML));
            doc = db.parse(is);
            nodes = doc.getElementsByTagName("ResultContext");

            strResult = doc.getElementsByTagName("Result").item(0).getTextContent();
            strReason = doc.getElementsByTagName("Reason").item(0).getTextContent();
            
            if(strResult.toUpperCase().equals("SUCCESS"))
            {
            	resultList.put("result", true);
            }
            else
            {
            	resultList.put("result", false);	
            }
    		
    		
    		resultList.put("message", strReason);

		} catch(NullPointerException e){	
    		resultList.put("result", false);
    		resultList.put("message", e.toString());
        } catch (Exception e){
    		resultList.put("result", false);
    		resultList.put("message", e.toString());
        }
        finally
        {
        	
        }

		return resultList;
	}

	//TimeSquare API 연동(v2)
	public CoviMap httpClientTSConnect(NameValuePair[] data) throws Exception{
		CoviMap params = new CoviMap();		
		CoviMap value = new CoviMap();	
		
		return value;
	}

	//TimeSquare API 연동(v2)
	public int httpClientTSConnect(HttpURLConnection pCon,DataOutputStream pStream) throws Exception{
		CoviMap resultList = new CoviMap();	
		int responseCode = 500;
		int iReturn = 0;
		String jsonText = "";
		String responseMsg = "";
		BufferedReader br = null;
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try{
			params.put("LogType","CLIENT");
			params.put("Method",pCon.getRequestMethod());
			params.put("ConnetURL",pCon.getURL().toString());			
			params.put("RequestDate", func.getCurrentTimeStr());			
			params.put("RequestBody", "");			
			//pStream.write(("\r\n--" + boundaryString + "--\r\n").getBytes("UTF-8"));			
			pStream.flush();
			pStream.close();		
			responseCode = pCon.getResponseCode();
			
			if (responseCode == 200) { // 정상 호출
				iReturn =1;
				br = new BufferedReader(new InputStreamReader(pCon.getInputStream(), StandardCharsets.UTF_8));
				try (InputStream in = pCon.getInputStream();
		                ByteArrayOutputStream out = new ByteArrayOutputStream()) {
		            
		            byte[] buf = new byte[1024 * 8];
		            int length = 0;
		            while ((length = in.read(buf)) != -1) {
		                out.write(buf, 0, length);
		            } 
		
		            jsonText = new String(out.toByteArray(), "UTF-8");
		            resultList = CoviMap.fromObject(jsonText);
		            
		            if(!resultList.get("returnCode").toString().equals("0")){//추가 오류
						iReturn = 0;						
					}else {
						iReturn = 1;
					}
		        }
			} else { 
				iReturn =0;
				br = new BufferedReader(new InputStreamReader(pCon.getErrorStream(), StandardCharsets.UTF_8));
				//throw new RuntimeException("Failed : HTTP error code : " + pCon.getResponseCode());
			}
			if(br != null) br.close();
		} catch(NullPointerException e){	
			responseCode = 500;
			iReturn =0;
			responseMsg = e.toString();
		} catch (Exception e) {
			responseCode = 500;
			iReturn =0;
			responseMsg = e.toString();
		}
		finally{					
			params.put("ResultState", Integer.toString(responseCode));
			
        	if(func.f_NullCheck(responseMsg).equals("")){
        		if(responseCode < 299){
        			params.put("ResultType", "SUCCESS");
        		}else{
        			iReturn =0;
        			params.put("ResultType", "FAIL");
        		}
        		params.put("ResponseMsg", jsonText);
        	}else{
        		iReturn =0;
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
					
			params.put("ResponseDate", func.getCurrentTimeStr());
			if(br != null) {br.close();}
        	if(pCon != null){
				pCon.disconnect();
				
				pCon = null;
			}
        	
        	LoggerHelper.httpLog(params);
		}		
		
		return iReturn;
	}
	
	//DataOutputStream Add FormData
	public DataOutputStream streamAdd(DataOutputStream pStream, String pStrName, String pStrValue) throws Exception{        
		if (pStrName.toUpperCase().equals(""))
        {
        	pStream.write(("\r\n--" + boundaryString + "--\r\n").getBytes("UTF-8"));
        }
        else
        {
        	pStream.write(("\r\n--" + boundaryString + "\r\n").getBytes("UTF-8"));
        	pStream.write(String.format("Content-Disposition: form-data; name=\"%s\"%n%n%s", pStrName, pStrValue).getBytes("UTF-8"));
        }
		
		return pStream;
	}

	//DataOutputStream Add FileStream
	public DataOutputStream streamFileAdd(DataOutputStream pStream, String pName,CoviMap params) throws Exception{        	
    	final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
		AwsS3 awsS3 = AwsS3.getInstance();
		if(awsS3.getS3Active()){
			String key = FileUtil.getBackPath() + path+params.getString("UserCode");
			if(awsS3.exist(key)){
				awsS3.delete(key);
				LOGGER.info("file : " + key+ " delete();");
			}
			String orikey = FileUtil.getBackPath() + path+params.getString("UserCode") + "_org";
			if(awsS3.exist(orikey)){
				awsS3.delete(orikey);
				LOGGER.info("file : " + orikey+ " delete();");
			}
			if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
				MultipartFile mFile = (MultipartFile) params.get("FileInfo");
				String newkey = FileUtil.getBackPath() + path+"/"+params.getString("UserCode") + "_org.jpg";
				
				InputStream mFileStream = null;
				try {
					mFileStream = mFile.getInputStream();
					
					awsS3.upload(mFileStream, newkey, mFile.getContentType(), mFile.getSize());
					pStream.write(("\r\n--" + boundaryString + "\r\n").getBytes("UTF-8"));
					
					String fileName = mFile.getName();
					pStream.write(String.format("Content-Disposition: form-data; name=\"%s\"; filename=\"%s\" %nContent-Type: %s%n%n", pName, fileName, URLConnection.guessContentTypeFromName(fileName)).getBytes("UTF-8"));
					pStream.flush();
					pStream.write(mFile.getBytes());
					pStream.flush();
				}finally {
					if(mFileStream != null) {
						mFileStream.close();
					}
				}
			}

		}else {
			File dir = new File(FileUtil.getBackPath() + path);
			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}

			File existFile = new File(dir, params.getString("UserCode"));
			if (existFile.exists()) {
				if (existFile.delete()) {
					LOGGER.info("file : " + existFile.toString() + " delete();");
				}

				File orgFile = new File(dir, params.getString("UserCode") + "_org");
				if (orgFile.delete()) {
					LOGGER.info("file : " + orgFile.toString() + " delete();");
				}
			}

			if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
				MultipartFile mFile = (MultipartFile) params.get("FileInfo");
				File file = new File(dir, params.getString("UserCode") + "_org.jpg");
				mFile.transferTo(file);
			}

			String filePath = FileUtil.getBackPath() + path + params.getString("UserCode")  + "_org.jpg";

			File uploadFile = new File(filePath);
			pStream.write(("\r\n--" + boundaryString + "\r\n").getBytes("UTF-8"));
			//pStream.write(String.format("Content-Disposition: form-data; name=\"%s\"; filename=\"%s\" \r\nContent-Type: \r\n\r\n", "image", Path.GetFileName(pStrValue), Path.GetExtension(pStrValue)).getBytes("UTF-8"));

			String fileName = uploadFile.getName();
			pStream.write(String.format("Content-Disposition: form-data; name=\"%s\"; filename=\"%s\" %nContent-Type: %s%n%n", pName, fileName, URLConnection.guessContentTypeFromName(fileName)).getBytes("UTF-8"));
			pStream.flush();

			
			// JSYun:Memory분산처리 종료
			//byte[] buffer = new byte[4096]; // added
			//int bytesRead = -1; // added
//        byte[] buffer = new byte[1024]; // add
//        int bytesRead = 0; // add
//        while ((bytesRead = inputStream.read(buffer)) != -1) {
//        	pStream.write(buffer, 0, bytesRead);
//        }
			FileInputStream inputStream = null;
			try {
				inputStream = new FileInputStream(uploadFile);
				
				byte[] buffer = new byte[8192]; // add
				int bytesRead = 0,bytesBuffered=0; // add
				while ((bytesRead = inputStream.read(buffer)) != -1) {
					pStream.write(buffer, 0, bytesRead);
					bytesBuffered+=bytesRead;
					if(bytesBuffered > 1024 * 1024)	{ //flush after 1MB
						bytesBuffered=0;
						pStream.flush();
					}
				}
				// JSYun:Memory분산처리 종료
				pStream.flush();
			}finally {
				if(inputStream != null) {
					inputStream.close();
				}
			}
		}

    	
		return pStream;
	}

	//Create HttpURLConnection Object
	public HttpURLConnection createHttpURLConnection(String pURL,String pMethod,String pType) throws Exception{
		if(pType.equals(""))
			pType = "application/json";
		URL uURL;
		uURL =  new URL(pURL);
		HttpURLConnection conn = (HttpURLConnection) uURL.openConnection();
		conn.setReadTimeout(15000);
		conn.setConnectTimeout(15000);
		conn.setRequestMethod(pMethod);
		conn.setRequestProperty("Content-Type", pType);
		conn.setDoInput(true);
		conn.setDoOutput(true);
		
		return conn;
	}

	//타임스퀘어 연동용  HttpURLConnection 생성
	public HttpURLConnection getTSConnection() throws Exception{
		return createHttpURLConnection(RedisDataUtil.getBaseConfig("TimeSquareAPIURL"),"POST","multipart/form-data; boundary=" + boundaryString);
	}
}
