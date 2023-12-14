package egovframework.coviframework.util;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.httpclient.HttpException;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.CookieStore;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.StringUtil;


public class HttpsUtil{
	private CloseableHttpClient httpclient = null;
	private PoolingHttpClientConnectionManager cm = null;
	Logger log = LogManager.getLogger(HttpsUtil.class);
	boolean tcpCommunicationResult = false; 
	String[] oneWayReturnMessage = new String[2];
	
	public String httpsClientWithRequest(String url, String method, CoviMap obj, String encoding, String etc_value) throws Exception {
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String responseMsg = "";
		
		String RequestDate = func.getCurrentTimeStr();
		int urlReturnStatus = 404;
		
		TrustManager easyTrustManager = new X509TrustManager() {
    		
            public X509Certificate[] getAcceptedIssuers() {
                // no-op
                return null;
            }

            public void checkServerTrusted(X509Certificate[] chain,
                    String authType) throws CertificateException {
            }

            public void checkClientTrusted(X509Certificate[] chain,
                    String authType) throws CertificateException {
            }
        };
        
        try {
        	//Default Max Connection : 20
        	cm = new PoolingHttpClientConnectionManager();
        	cm.setMaxTotal(120);
        	cm.setDefaultMaxPerRoute(40);
            /**
             * Connection Time Out > 15초 > 60초 > 120초
             */
        	Integer timout_sec = 120;
            RequestConfig requestConfig = RequestConfig.custom().setConnectionRequestTimeout(timout_sec*1000).setConnectTimeout(timout_sec*1000).setSocketTimeout(timout_sec*1000).build();
//          RequestConfig requestConfig = RequestConfig.copy(RequestConfig.DEFAULT).setConnectionRequestTimeout(timout_sec*1000).setConnectTimeout(timout_sec*1000).setSocketTimeout(timout_sec*1000).build();
            
            SSLContext sslcontext = SSLContext.getInstance("SSL");
            sslcontext.init(null, new TrustManager[] { easyTrustManager }, null);
            
            /**
             *  https 인증방식
             *    - 도메인 방식: STRICT_HOSTNAME_VERIFIER
             *    - No 도메인 방식: ALLOW_ALL_HOSTNAME_VERIFIER
             */
            SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(sslcontext,SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            //만약 본인 인증 방식 (Self-Signed Certificate)일 경우는 “SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER”
            
            httpclient = HttpClients.custom().setConnectionManager(cm).setSSLSocketFactory(sslsf).setDefaultRequestConfig(requestConfig).build();
//            .setSocketTimeout(timeout * 1000)
//            .setConnectTimeout(timeout * 1000)
//            .setConnectionRequestTimeout(timeout * 1000)
            
            /**
             *  or # > URL Setting ( UTF - 8 )
             */
            url = url.replace("#", "%23");
			switch (method) // Start of switch
			{
			case "GET":
				// HttpGet Start
				try{
			        HttpGetWithBody httpGet = new HttpGetWithBody(url);
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else {
			        	httpGet.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
			        StringEntity delEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
			        httpGet.setEntity(delEntity);
			        
			        try(CloseableHttpResponse response = httpclient.execute(httpGet);){
			        	HttpEntity entity = response.getEntity();
			        	
			        	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
			        	
			        	oneWayReturnMessage[0] = response.getStatusLine()+"";
			        	oneWayReturnMessage[1] = responseBody;
			        	
			        	if (entity != null) {
//		                log.info("- Response content length: " + entity.getContentLength(), "");
			        	}
			        	
			        	EntityUtils.consume(entity);
			        	
			        	urlReturnStatus = response.getStatusLine().getStatusCode();
			        }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				// HttpGet End
				break;

			case "POST":
				// HttpPost Start
				try{
			        HttpPost httppost = new HttpPost(url);                
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else{
			        	httppost.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
		            StringEntity postEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
		            httppost.setEntity(postEntity);
		            
		            try(CloseableHttpResponse response = httpclient.execute(httppost);){
	
			            HttpEntity entity = response.getEntity();
			            
			            String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
			        	
			            
			            oneWayReturnMessage[0] = response.getStatusLine()+"";
			            oneWayReturnMessage[1] = responseBody;
			            
			            log.info("##### oneWayReturnMessage[0]    " + response.getStatusLine());
			            log.info("##### oneWayReturnMessage[1]    " + responseBody);
			            log.info("##### entity    " + response.getEntity());
			            
			            if (entity != null) {
	//		                log.info("- Response content length: " + entity.getContentLength(), "");
			            }
			            
			            EntityUtils.consume(entity);
			            
			            urlReturnStatus = response.getStatusLine().getStatusCode();
		            }
		            
		            log.info("##### urlReturnStatus    " + urlReturnStatus);
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	LoggerHelper.errorLogger(new Exception(), url,  String.valueOf(urlReturnStatus));
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				// HttpPost End
				break;
 
			case "PUT":
				try{
			        HttpPut httpput = new HttpPut(url);                
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else{
			        	httpput.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
		            
		            StringEntity putEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
		            httpput.setEntity(putEntity);
		            
		            try(CloseableHttpResponse response = httpclient.execute(httpput);){
		            	
		            	HttpEntity entity = response.getEntity();
		            	
		            	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
		            	
		            	oneWayReturnMessage[0] = response.getStatusLine()+"";
		            	oneWayReturnMessage[1] = responseBody;
		            	
		            	if (entity != null) {
//		                log.info("- Response content length: " + entity.getContentLength(), "");
		            	}
		            	
		            	EntityUtils.consume(entity);
		            	
		            	urlReturnStatus = response.getStatusLine().getStatusCode();
		            }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					oneWayReturnMessage[0] = "Connection Fail"; 
					oneWayReturnMessage[1] = e.toString();
				} catch (Exception e){
					oneWayReturnMessage[0] = "Connection Fail"; 
					oneWayReturnMessage[1] = e.toString();
				} finally {
					httpclient.close();
				}
				break;		
				
			case "DELETE":
				try{
					log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] URL : "+url+"\n", "");
			        HttpDeleteWithBody httpDelete = new HttpDeleteWithBody(url);
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        }else{
			        	httpDelete.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
			        log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Param : "+obj.toString()+"--", "");
			        
			        StringEntity delEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
			        httpDelete.setEntity(delEntity);
			       
			        try(CloseableHttpResponse response = httpclient.execute(httpDelete);){
			        	HttpEntity entity = response.getEntity();
			        	
			        	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
			        	
			        	oneWayReturnMessage[0] = response.getStatusLine()+"";
			        	oneWayReturnMessage[1] = responseBody;
			        	
			        	log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REP] StatusLine : "+oneWayReturnMessage[0], "");
			        	log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REP] Body : "+oneWayReturnMessage[1], "");
			        	EntityUtils.consume(entity);
			        	
			        	urlReturnStatus = response.getStatusLine().getStatusCode();
			        }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				break;				
			default:
	            oneWayReturnMessage[0] = "Fail";
	            oneWayReturnMessage[1] = "(Fail) Body default-fail";
	            
	            log.debug("[HttpsOneWay] ["+url+"][NO METHOD] [REP] StatusLine : "+oneWayReturnMessage[0], "");
	            log.debug("[HttpsOneWay] ["+url+"][NO METHOD] [REP] Body : "+oneWayReturnMessage[1], "");
				break;
			} // End of switch

        } finally {
        	params.put("LogType","HTTPS");
        	params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(urlReturnStatus));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		params.put("ResultType", oneWayReturnMessage[0]);
        		params.put("ResponseMsg", oneWayReturnMessage[1]);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        }
        
        return oneWayReturnMessage[1];
    }
	
	
	public String httpsClientWithRequest(String url, String method, CoviMap obj, String encoding, String etc_value, HttpServletRequest request, HttpServletResponse Sresponse) throws Exception {
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();	
		String RequestDate = func.getCurrentTimeStr();
		int urlReturnStatus = 404;
		String responseMsg = "";
		
		TrustManager easyTrustManager = new X509TrustManager() {
		
    		public X509Certificate[] getAcceptedIssuers() {
                // no-op
                return null;
            }

            public void checkServerTrusted(X509Certificate[] chain,
                    String authType) throws CertificateException {
            }

            public void checkClientTrusted(X509Certificate[] chain,
                    String authType) throws CertificateException {
            }
        };
        try {
        	//Default Max Connection : 20
        	cm = new PoolingHttpClientConnectionManager();
        	cm.setMaxTotal(120);
        	cm.setDefaultMaxPerRoute(40);
            /**
             * Connection Time Out > 15초 > 60초 > 120초
             */
        	Integer timout_sec = 120;
            RequestConfig requestConfig = RequestConfig.custom().setConnectionRequestTimeout(timout_sec*1000).setConnectTimeout(timout_sec*1000).setSocketTimeout(timout_sec*1000).build();
//          RequestConfig requestConfig = RequestConfig.copy(RequestConfig.DEFAULT).setConnectionRequestTimeout(timout_sec*1000).setConnectTimeout(timout_sec*1000).setSocketTimeout(timout_sec*1000).build();
            
            SSLContext sslcontext = SSLContext.getInstance("SSL");
            sslcontext.init(null, new TrustManager[] { easyTrustManager }, null);
            
            /**
             *  https 인증방식
             *    - 도메인 방식: STRICT_HOSTNAME_VERIFIER
             *    - No 도메인 방식: ALLOW_ALL_HOSTNAME_VERIFIER
             */
            SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(sslcontext,SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            //만약 본인 인증 방식 (Self-Signed Certificate)일 경우는 “SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER”
            
            httpclient = HttpClients.custom().setConnectionManager(cm).setSSLSocketFactory(sslsf).setDefaultRequestConfig(requestConfig).build();
//            .setSocketTimeout(timeout * 1000)
//            .setConnectTimeout(timeout * 1000)
//            .setConnectionRequestTimeout(timeout * 1000)
            
            /**
             *  or # > URL Setting ( UTF - 8 )
             */
            url = url.replace("#", "%23");
			switch (method) // Start of switch
			{
			case "GET":
				// HttpGet Start
				try{
			        HttpGetWithBody httpGet = new HttpGetWithBody(url);
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else {
			        	httpGet.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
			        StringEntity delEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
			        httpGet.setEntity(delEntity);
			        
			        try(CloseableHttpResponse response = httpclient.execute(httpGet);){
			        	HttpEntity entity = response.getEntity();
			        	
			        	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
			        	
			        	oneWayReturnMessage[0] = response.getStatusLine()+"";
			        	oneWayReturnMessage[1] = responseBody;
			        	
			        	if (entity != null) {
//		                log.info("- Response content length: " + entity.getContentLength(), "");
			        	}
			        	
			        	EntityUtils.consume(entity);
			        	
			        	urlReturnStatus = response.getStatusLine().getStatusCode();
			        }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				// HttpGet End
				break;

			case "POST":
				// HttpPost Start
				try{
			        HttpPost httppost = new HttpPost(url);                
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else{
			        	httppost.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
		            StringEntity postEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
		            httppost.setEntity(postEntity);
		            
		            // Create a local instance of cookie store
		            CookieStore cookieStore = new BasicCookieStore();

		            // Create local HTTP context
		            HttpContext localContext = new BasicHttpContext();
		            // Bind custom cookie store to the local context
		            localContext.setAttribute(ClientContext.COOKIE_STORE, cookieStore);
		            
		            try(CloseableHttpResponse response = httpclient.execute(httppost,localContext);){
		            	HttpEntity entity = response.getEntity();
		            	
		            	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
		            	
		            	oneWayReturnMessage[0] = response.getStatusLine()+"";
		            	oneWayReturnMessage[1] = responseBody;
		            	
		            	if (entity != null) {
//		                log.info("- Response content length: " + entity.getContentLength(), "");
		            	}
		            	
		            	EntityUtils.consume(entity);
		            	
		            	urlReturnStatus = response.getStatusLine().getStatusCode();
		            }
	
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	LoggerHelper.errorLogger(new Exception(), url,  String.valueOf(urlReturnStatus));
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
		            
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				// HttpPost End
				break;
 
			case "PUT":
				try{
			        HttpPut httpput = new HttpPut(url);                
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        } else{
			        	httpput.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
		            
		            StringEntity putEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
		            httpput.setEntity(putEntity);
		            
		            try(CloseableHttpResponse response = httpclient.execute(httpput);){
		            	HttpEntity entity = response.getEntity();
		            	
		            	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
		            	
		            	oneWayReturnMessage[0] = response.getStatusLine()+"";
		            	oneWayReturnMessage[1] = responseBody;
		            	
		            	if (entity != null) {
//		                log.info("- Response content length: " + entity.getContentLength(), "");
		            	}
		            	
		            	EntityUtils.consume(entity);
		            	
		            	urlReturnStatus = response.getStatusLine().getStatusCode();
		            }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				break;		
				
			case "DELETE":
				try{
					log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] URL : "+url+"\n", "");
			        HttpDeleteWithBody httpDelete = new HttpDeleteWithBody(url);
			        
			        if(etc_value == null || etc_value.equals("")){
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
			        }else{
			        	httpDelete.setHeader("Authorization", etc_value);
			        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
			        }
			        
			        log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Param : "+obj.toString()+"--", "");
			        
			        StringEntity delEntity = new StringEntity(obj.toString(),ContentType.create("application/json", encoding));
			        httpDelete.setEntity(delEntity);
			       
			        try(CloseableHttpResponse response = httpclient.execute(httpDelete);){
			        	
			        	HttpEntity entity = response.getEntity();
			        	
			        	String responseBody = EntityUtils.toString(response.getEntity(),"UTF-8");
			        	
			        	oneWayReturnMessage[0] = response.getStatusLine()+"";
			        	oneWayReturnMessage[1] = responseBody;
			        	
			        	log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REP] StatusLine : "+oneWayReturnMessage[0], "");
			        	log.debug("[HttpsOneWay] ["+url+"] ["+method+"] [REP] Body : "+oneWayReturnMessage[1], "");
			        	EntityUtils.consume(entity);
			        	
			        	urlReturnStatus = response.getStatusLine().getStatusCode();
			        }
		            
		            if(urlReturnStatus == 500){
		            	throw new IOException("Server returned HTTP response code: 500 for URL: "+url);
		            }else if(urlReturnStatus == 404){
		            	throw new FileNotFoundException();
		            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
		            	throw new Exception();
		            }else if(urlReturnStatus == 302){
		            	throw new Exception();
		            }
				} catch(NullPointerException e){	
					responseMsg = e.toString();
				} catch (Exception e){
					responseMsg = e.toString();
				} finally {
					httpclient.close();
				}
				break;				
			default:
	            oneWayReturnMessage[0] = "Fail";
	            oneWayReturnMessage[1] = "(Fail) Body default-fail";
	            
	            log.debug("[HttpsOneWay] ["+url+"][NO METHOD] [REP] StatusLine : "+oneWayReturnMessage[0], "");
	            log.debug("[HttpsOneWay] ["+url+"][NO METHOD] [REP] Body : "+oneWayReturnMessage[1], "");
				break;
			} // End of switch

        } finally {
        	params.put("LogType","HTTPS");
        	params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(urlReturnStatus));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		params.put("ResultType", oneWayReturnMessage[0]);
        		params.put("ResponseMsg", oneWayReturnMessage[1]);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        }
        return oneWayReturnMessage[1];
    }
	
	public Map<String, Object> httpsClientConnectResponse(String url, String method, CoviMap obj, String encoding, String etc_value) throws Exception {
		return httpsClientConnectResponse(url, method, obj.toString(), "application/json", encoding, etc_value, new ArrayList<NameValuePair>());
	}
	/**
	 * 정상호출 외의 경우 Exception 발생
	 * @param url
	 * @param method
	 * @param obj
	 * @param encoding
	 * @param etc_value
	 * @param objParam : requestParam
	 * @return
	 * @throws Exception
	 */
	public Map<String, Object> httpsClientConnectResponse(String url, String method, String strBody, String contentType, String encoding, String etc_value, List<NameValuePair> objParam) throws Exception {
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String responseMsg = "";
		Map<String, Object> rtnObject = new HashMap<String, Object>();
		
		String RequestDate = func.getCurrentTimeStr();
		int urlReturnStatus = 404;
		
		TrustManager easyTrustManager = new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() {
                return null;
            }
            public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
            }
            public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
            }
        };
        
        try {
        	//Default Max Connection : 20
        	cm = new PoolingHttpClientConnectionManager();
        	cm.setMaxTotal(120);
        	cm.setDefaultMaxPerRoute(40);
            /**
             * Connection Time Out > 15초 > 60초 > 120초
             */
        	Integer timout_sec = 120;
            RequestConfig requestConfig = RequestConfig.custom().setConnectionRequestTimeout(timout_sec*1000).setConnectTimeout(timout_sec*1000).setSocketTimeout(timout_sec*1000).build();
            
            SSLContext sslcontext = SSLContext.getInstance("SSL");
            sslcontext.init(null, new TrustManager[] { easyTrustManager }, null);
            
            /**
             *  https 인증방식
             *    - 도메인 방식: STRICT_HOSTNAME_VERIFIER
             *    - No 도메인 방식: ALLOW_ALL_HOSTNAME_VERIFIER
             */
            SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(sslcontext,SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            
            httpclient = HttpClients.custom().setConnectionManager(cm).setSSLSocketFactory(sslsf).setDefaultRequestConfig(requestConfig).build();
            
            /**
             *  or # > URL Setting ( UTF - 8 )
             */
            url = url.replace("#", "%23");
            
            HttpEntityEnclosingRequestBase httpMethod = null;
            // set RequestParam
            URIBuilder uriBuilder = new URIBuilder(url); //builder.setScheme("http"); builder.setHost("~~url~~");
        	uriBuilder.setParameters(objParam); // uriBuilder.setParameter("param1", "value");
            if("GET".equals(method)) {
            	//httpMethod = new HttpGetWithBody(url);
            	httpMethod = new HttpGetWithBody(uriBuilder.build());
            }else if("POST".equals(method)) {
            	//httpMethod = new HttpPost(url);
            	httpMethod = new HttpPost(uriBuilder.build());
            }else {
            	throw new Exception("Invalid request. method : " + method);
            }
            
	        if(etc_value == null || etc_value.equals("")){
	        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : NULL--", "");	
	        } else {
	        	httpMethod.setHeader("Authorization", etc_value);
	        	log.info("[HttpsOneWay] ["+url+"] ["+method+"] [REQ] Auth_value : "+etc_value+"--", "");
	        }
	        
	        // set RequestBody
            StringEntity postEntity = new StringEntity(strBody,ContentType.create(contentType, encoding));
            httpMethod.setEntity(postEntity);
            
            try(CloseableHttpResponse response = httpclient.execute(httpMethod);){

	            HttpEntity entity = response.getEntity();
	            
	            String responseBody = EntityUtils.toString(response.getEntity(),encoding);
	        	
	            rtnObject.put("STATUS", response.getStatusLine()+"");
	            rtnObject.put("MESSAGE", responseBody);
	            
	            EntityUtils.consume(entity);
	            urlReturnStatus = response.getStatusLine().getStatusCode();
	            rtnObject.put("STATUSCODE", urlReturnStatus);
            }
            log.info("##### urlReturnStatus(HTTP State)    " + urlReturnStatus);
            
            if(urlReturnStatus >= 500){
            	// engine api call 일경우 오류메시지 사용자 표시를 위해 return 처리한다.
            	if(url.indexOf("/activiti-rest") > -1) {
            		log.error("", new HttpException("Server returned HTTP response code:" + String.valueOf(urlReturnStatus) + " for URL :" + url));
            	}else {
            		throw new HttpException("Server returned HTTP response code:" + String.valueOf(urlReturnStatus) + " for URL :" + url);
            	}
            }else if(urlReturnStatus == 404){
            	throw new HttpException("Server returned HTTP response code:" + String.valueOf(urlReturnStatus) + " for URL :" + url);
            }else if(urlReturnStatus == 415 || urlReturnStatus == 409 || urlReturnStatus == 403 || urlReturnStatus == 400){				//세분화가 필요할 때 위와 같이 세분화
            	throw new HttpException("Server returned HTTP response code:" + String.valueOf(urlReturnStatus) + " for URL :" + url);
            }else if(urlReturnStatus == 302){
            	throw new Exception();
            }
            
        } finally {
        	params.put("LogType","HTTP(S)");
        	params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(urlReturnStatus));
        	params.put("RequestBody", "");
        	
        	if(func.f_NullCheck(responseMsg).equals("")){
        		params.put("ResultType", oneWayReturnMessage[0]);
        		params.put("ResponseMsg", oneWayReturnMessage[1]);
        	}else{
        		params.put("ResultType", "FAIL");
        		params.put("ResponseMsg", responseMsg);
        	}
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        }
        
        return rtnObject;
    }

	static class HttpDeleteWithBody extends HttpEntityEnclosingRequestBase {
	    public String getMethod() {
	        return "DELETE";
	    }
	 
	    public HttpDeleteWithBody(final String uri) {
	        super();
	        setURI(URI.create(uri));
	    }
	 
	    public HttpDeleteWithBody(final URI uri) {
	        super();
	        setURI(uri);
	    }
	 
	    public HttpDeleteWithBody() {
	        super();
	    }
	}

	static class HttpGetWithBody extends HttpEntityEnclosingRequestBase {
	    public String getMethod() {
	        return "GET";
	    }
	 
	    public HttpGetWithBody(final String uri) {
	        super();
	        setURI(URI.create(uri));
	    }
	 
	    public HttpGetWithBody(final URI uri) {
	        super();
	        setURI(uri);
	    }
	 
	    public HttpGetWithBody() {
	        super();
	    }
	}
	
}