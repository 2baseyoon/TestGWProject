/*
 * Copyright 2002-2015 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package egovframework.coviframework.base;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.codec.DecoderException;
import org.apache.commons.codec.net.URLCodec;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.util.WebUtils;

import egovframework.coviframework.base.CoviParamFilter.CoviContentCachingRequestWrapper;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.filter.XSSUtils;
import egovframework.baseframework.util.PropertiesUtil;

import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.http.HttpServletResponse;

/**
 * {@link javax.servlet.http.HttpServletRequest} wrapper that caches all content read from
 * the {@linkplain #getInputStream() input stream} and {@linkplain #getReader() reader},
 * and allows this content to be retrieved via a {@link #getContentAsByteArray() byte array}.
 *
 * <p>Used e.g. by {@link org.springframework.web.filter.AbstractRequestLoggingFilter}.
 *
 * @author Juergen Hoeller
 * @author Brian Clozel
 * @since 4.1.3
 * @see ContentCachingResponseWrapper
 */
public class CoviParamFilter  extends OncePerRequestFilter {
	private static final Logger LOGGER = LogManager.getLogger(CoviParamFilter.class);
	private static String[] excludeFieldsArr = PropertiesUtil.getGlobalProperties().getProperty("filter.notCheckList").split(",");
	@Override
//	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)	throws ServletException, IOException { 
		chain.doFilter(new CoviContentCachingRequestWrapper((HttpServletRequest) request), response);
	}
	
	static class CoviContentCachingRequestWrapper extends HttpServletRequestWrapper {
		private final Charset encoding;
		private final ByteArrayOutputStream cachedContent;
		private final Map<String, ArrayList<String>> parameters = new LinkedHashMap<String, ArrayList<String>>();
		private BufferedReader reader;
	    private byte[] rawData;
	    boolean parametersParsed = false;
	    boolean isRawData = false;
		ByteChunk tmpName = new ByteChunk();
		ByteChunk tmpValue = new ByteChunk();
	
	    private class ByteChunk {
	
	    	public byte[] buff;
	    	private int start = 0;
	    	private int end;
	
	        public void setByteChunk(byte[] b, int off, int len) {
	        	this.buff = new byte[b.length];
	            for (int i = 0; i < b.length; ++i){
	            	this.buff[i] = b[i];
	            }
	            start = off;
	            end = start + len;
	        }
	
	        public byte[] getBytes() {
	            return buff;
	        }
	
	        public int getStart() {
	            return start;
	        }
	
	        public int getEnd() {
	            return end;
	        }
	
	        public void recycle() {
	            buff = null;
	            start = 0;
	            end = 0;
	        }
	    }
	
	
		/**
		 * Create a new ContentCachingRequestWrapper for the given servlet request.
		 * @param request the original servlet request
		 */
		public CoviContentCachingRequestWrapper(HttpServletRequest request) {
			super(request);
			
			String characterEncoding = request.getCharacterEncoding();
			if (StringUtils.isBlank(characterEncoding)) {
				characterEncoding = StandardCharsets.UTF_8.name();
			}
			this.encoding = Charset.forName(characterEncoding);
			int contentLength = request.getContentLength();
			try {
				if (!getMethod().equals("POST")) {
					
				}
				else{
					this.rawData = IOUtils.toByteArray(request.getInputStream());
					isRawData = true;
				}
			} catch(NullPointerException e){	
				LOGGER.debug(e);
			} catch(Exception e) {
				LOGGER.debug(e);
			}
			this.cachedContent = new ByteArrayOutputStream(contentLength >= 0 ? contentLength : 1024);
		}
	
	
		@Override
		public ServletInputStream getInputStream() throws IOException {
	        final ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(this.rawData);
	        ServletInputStream servletInputStream = new ServletInputStream() {
	            public int read() throws IOException {
	                return byteArrayInputStream.read();
	            }
	        };
	        return servletInputStream;
		}
	
		@Override
		public String getCharacterEncoding() {
			String enc = super.getCharacterEncoding();
			return (enc != null ? enc : WebUtils.DEFAULT_CHARACTER_ENCODING);
		}
	
		@Override
		public BufferedReader getReader() throws IOException {
			if (this.reader == null) {
				this.reader = new BufferedReader(new InputStreamReader(getInputStream(), getCharacterEncoding()));
			}
			return this.reader;
		}
	
		@Override
		public String getParameter(String name) {
			if (!isRawData) return super.getParameter(name);
			
			if (!parametersParsed) {
				parseParameters();
			}
			ArrayList<String> values = this.parameters.get(name);
			if (values == null || values.size() == 0) return null;
			
			return values.get(0);
		}
	
		public HashMap<String, String[]> getParameters() {
			if (!parametersParsed) {
				parseParameters();
			}
			HashMap<String, String[]> map = new HashMap<String, String[]>(this.parameters.size() * 2);
			
			for (Map.Entry<String, ArrayList<String>> entry : this.parameters.entrySet()) {
				map.put(entry.getKey(), entry.getValue().toArray(new String[entry.getValue().size()]));
			}
			return map;
		}
	
		@SuppressWarnings("rawtypes")
		@Override
		public Map getParameterMap() {
			if (!isRawData) return super.getParameterMap();
			return getParameters();
		}
	
		@SuppressWarnings("rawtypes")
		@Override
		public Enumeration getParameterNames() {
			if (!isRawData) return super.getParameterNames();
			
			return new Enumeration<String>() {
				@SuppressWarnings("unchecked")
				private String[] arr = (String[]) (getParameterMap().keySet().toArray(new String[0]));
				private int index = 0;
	
				@Override
				public boolean hasMoreElements() {
					return index < arr.length;
				}
	
				@Override
				public String nextElement() {
					return arr[index++];
				}
			};
		}
	
		@Override
		public String[] getParameterValues(String name) {
			if (!isRawData) return super.getParameterValues(name);
			
			if (!parametersParsed) {
				parseParameters();
			}
			ArrayList<String> values = this.parameters.get(name);
			if (values == null) return null;
			
			String[] arr = values.toArray(new String[values.size()]);
			if (arr == null) {
				return null;
			}
			return arr;
		}
	
		private void parseParameters() {
			parametersParsed = true;
			try {
				if (!getMethod().equals("POST")||!super.getContentType().toLowerCase().contains("application/x-www-form-urlencoded")) {
					return;
				}
			} catch(NullPointerException e){	
				return;
			} catch(Exception e) {
				return;
			}		
			int pos = 0;
			int end = this.rawData.length;
	
			while (pos < end) {
				int nameStart = pos;
				int nameEnd = -1;
				int valueStart = -1;
				int valueEnd = -1;
	
				boolean parsingName = true;
				boolean decodeName = false;
				boolean decodeValue = false;
				boolean parameterComplete = false;
	
				do {
					switch (this.rawData[pos]) {
					case '=':
						if (parsingName) {
							// Name finished. Value starts from next character
							nameEnd = pos;
							parsingName = false;
							valueStart = ++pos;
						} else {
							// Equals character in value
							pos++;
						}
						break;
					case '&':
						if (parsingName) {
							// Name finished. No value.
							nameEnd = pos;
						} else {
							// Value finished
							valueEnd = pos;
						}
						parameterComplete = true;
						pos++;
						break;
					case '%':
					case '+':
						// Decoding required
						if (parsingName) {
							decodeName = true;
						} else {
							decodeValue = true;
						}
						pos++;
						break;
					default:
						pos++;
						break;
					}
				} while (!parameterComplete && pos < end);
	
				if (pos == end) {
					if (nameEnd == -1) {
						nameEnd = pos;
					} else if (valueStart > -1 && valueEnd == -1) {
						valueEnd = pos;
					}
				}
	
				if (nameEnd <= nameStart) {
					continue;
					// ignore invalid chunk
				}
	
				tmpName.setByteChunk(this.rawData, nameStart, nameEnd - nameStart);
				if (valueStart >= 0) {
					tmpValue.setByteChunk(this.rawData, valueStart, valueEnd - valueStart);
				} else {
					tmpValue.setByteChunk(this.rawData, 0, 0);
				}
	
				try {
					String name;
					String value;
	
					if (decodeName) {
						name = new String(
								URLCodec.decodeUrl(
										Arrays.copyOfRange(tmpName.getBytes(), tmpName.getStart(), tmpName.getEnd())),
								this.encoding);
					} else {
						name = new String(tmpName.getBytes(), tmpName.getStart(), tmpName.getEnd() - tmpName.getStart(),
								this.encoding);
					}
	
					if (valueStart >= 0) {
						if (decodeValue) {
							value = new String(URLCodec.decodeUrl(
									Arrays.copyOfRange(tmpValue.getBytes(), tmpValue.getStart(), tmpValue.getEnd())),
									this.encoding);
						} else {
							value = new String(tmpValue.getBytes(), tmpValue.getStart(),
									tmpValue.getEnd() - tmpValue.getStart(), this.encoding);
						}
					} else {
						value = "";
					}
	
					if (StringUtils.isNotBlank(name)) {
						ArrayList<String> values = this.parameters.get(name);
						if (values == null) {
							values = new ArrayList<String>(1);
							this.parameters.put(name, values);
						}
						//if (StringUtils.isNotBlank(value)) {
							values.add(value);
						//}
					}
				} catch (DecoderException e) {
					LOGGER.debug(e);
					// ignore invalid chunk
				}
	
				tmpName.recycle();
				tmpValue.recycle();
			}
		}
	}
}