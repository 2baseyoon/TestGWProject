package egovframework.covision.proxy.synap;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class RequestSynapDocView {
	private static final Logger LOGGER = LogManager.getLogger(RequestSynapDocView.class);
	
	/**
	 * 뷰어서버를 호출 하고 responseEntity를 반환 합니다.
	 * @param targetUrl 뷰어서버 URL ex) http://{서버URL}
	 * @param timeoutParam 뷰어서버 요청 timeout (default : 360000)
	 * @param request request HttpServletRequest Request 요청은 http://{proxyServerURL}/SynapDocViewServer/job 로 해야함
	 * @param response
	 * @throws Exception
	 */
	public static void requestSynapDocViewServer(String targetUrl, String timeoutParam, HttpServletRequest request, HttpServletResponse response) throws Exception {
		if (targetUrl.isEmpty()) {
			new NullPointerException("targetUrl is NULL");
		}
//		System.setProperty("sun.net.http.allowRestrictedHeaders", "true");
		
		int timeout = 360000;
		if (!timeoutParam.isEmpty()) {
			timeout = Integer.parseInt(timeoutParam);
		}

		String originReqUrl = request.getRequestURI();
		String originReqQuery = request.getQueryString();

		StringBuilder requestUrl = new StringBuilder();
		requestUrl.append(targetUrl).append(originReqUrl);
		if (originReqQuery != null) {
			requestUrl.append("?" + originReqQuery);
		}

		URL url = new URL(requestUrl.toString());

		String boundary = "^-----^";
		String LINE_FEED = "\r\n";
		final String hyphens = "--";

		try {
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setConnectTimeout(timeout);
			con.setReadTimeout(timeout);
			con.setInstanceFollowRedirects(false);

			//request header
			Enumeration<String> headerNames = request.getHeaderNames();
			while (headerNames.hasMoreElements()) {
				String headerName = headerNames.nextElement();
				String headerValue = request.getHeader(headerName);
				con.setRequestProperty(headerName, headerValue);
			}

			con.setRequestProperty("X-Forwarded-Proto", request.getScheme());
			con.setRequestProperty("X-Forwarded-Port", String.valueOf(request.getServerPort()));
			con.setRequestProperty("X-Forwarded-Host", request.getServerName());
			
			//request cookies
			if (request.getCookies() != null) {
				StringBuilder cookieData = new StringBuilder();
				for (Cookie cookie : request.getCookies()) {
					String cookieStr = String.format("%s=%s; ", cookie.getName(), cookie.getValue());
					cookieData.append(cookieStr);
				}
				con.setRequestProperty("Cookie", cookieData.toString());
			}

			String method = request.getMethod();
			con.setRequestMethod(method);
			if ("POST".equals(method)) {
				con.setDoInput(true);
				con.setDoOutput(true);
				con.setUseCaches(false);

				DataOutputStream wr = null;
				try {
					wr = new DataOutputStream(con.getOutputStream());
					if (request.getContentType().contains("multipart/form-data") && request.getParts() != null && request.getParts().size() > 0) {
						boundary = request.getHeader("Content-Type").split("=")[1];
						boolean isFile = false;
						for (Part part : request.getParts()) {
							wr.writeBytes(hyphens + boundary + LINE_FEED);
							for (String name : part.getHeaderNames()) {
								String isEmptyContentType = part.getHeader("Content-Type");
								if (isEmptyContentType != null && isEmptyContentType.startsWith("application/")) {
									wr.writeBytes(name + ": " + part.getHeader(name) + LINE_FEED);
									isFile = true;
								} else {
									isFile = false;
									wr.writeBytes(name + ": " + part.getHeader(name) + LINE_FEED);
									wr.writeBytes(LINE_FEED);
									wr.writeBytes(RequestSynapDocView.getFormValue(part));
									wr.writeBytes(LINE_FEED);
								}
							}
							if (isFile) {
								wr.writeBytes(LINE_FEED);
								RequestSynapDocView.getBytesFromInputStream(part, wr);
								wr.writeBytes(LINE_FEED);
								isFile = false;
							}
						}
						wr.writeBytes(LINE_FEED);
						wr.writeBytes(hyphens + boundary + hyphens + LINE_FEED);
					} else {
						//String body = RequestSynapDocView.getBody(request);
						//wr.writeBytes(body);
						IOUtils.copy(request.getInputStream(), wr);
					}
					wr.flush();
				}finally {
					if(wr != null) {
						wr.close();
					}
				}
			}

			// send
			int responseCode = con.getResponseCode();
			response.setStatus(responseCode);

			// response header, cookie
			// con.getHeaderFields().entrySet() 을 사용할 경우 header 순서가 보장되지 않아 Set-Cookie 헤더가 2개 이상일 경우 오동작.
			int headerSize = con.getHeaderFields().size();
			for(int i = 0; i < headerSize; i++) {
				String headerName = con.getHeaderFieldKey(i);
				String headerValue = con.getHeaderField(i);
				if("Transfer-Encoding".equals(headerName)) {
					continue;
				}
				response.addHeader(headerName, headerValue);
			}
//			for (Map.Entry<String, List<String>> entries : con.getHeaderFields().entrySet()) {
//				if (entries.getKey() == null) {
//					continue;
//				} 
//				// 302 응답은 Client 에게 맡긴다.
//				if("Transfer-Encoding".equals(entries.getKey())) {
//					continue;
//				}
//				for(String value : entries.getValue()){
//					response.addHeader(entries.getKey(), value);
//				}
//			}

			//set response body 
			if (con.getInputStream() != null) {
				byte[] buffer = new byte[10240];
				try (InputStream input = con.getInputStream();
				     OutputStream output = response.getOutputStream()) {
					for (int length = 0; (length = input.read(buffer)) > 0; ) {
						output.write(buffer, 0, length);
					}
					output.flush();
				}
			}

		} catch (FileNotFoundException e) {
			LOGGER.error(e.getCause() == null ? "404 Exception. " + e.getLocalizedMessage() : e.getCause());
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ServletException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}


	public static String getBody(HttpServletRequest request) throws IOException {
		String body = IOUtils.toString(request.getInputStream(), StandardCharsets.UTF_8);
		Map<String, String[]> paramMap = request.getParameterMap();
		
		if((body == null || StringUtils.isEmpty(body)) && paramMap != null && paramMap.size() > 0) {
			List<String> parameters = new ArrayList<String>();
			for(String paramName:paramMap.keySet()) {
			    String[] paramValues = paramMap.get(paramName);
			    for(String valueOfParam:paramValues) {
			    	// System.out.println("Value of Param with Name "+paramName+": "+valueOfParam);
			    	parameters.add(URLEncoder.encode(paramName, StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode(valueOfParam,StandardCharsets.UTF_8.name()));
			    }
			}
			
			body = StringUtils.join(parameters, "&");
		}
		return body;
	}

	public static String getFormValue(Part part) throws IOException {
		StringBuilder lines = new StringBuilder();
		try (InputStream inputStream = part.getInputStream()) {
			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
			String line;
			while ((line = bufferedReader.readLine()) != null) {
				lines.append(line);
			}
		}
		return lines.toString();
	}

	public static void getBytesFromInputStream(Part part, DataOutputStream wr) {

		try (InputStream is = part.getInputStream()) {
			int nRead;
			byte[] data = new byte[16384];

			while ((nRead = is.read(data, 0, data.length)) != -1) {
				wr.write(data, 0, nRead);
			}
		} catch (IOException ie) {
			new IOException(ie.getMessage());
		}
	}

}

