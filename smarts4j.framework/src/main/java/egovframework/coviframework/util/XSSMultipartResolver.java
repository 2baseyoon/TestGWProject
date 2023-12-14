package egovframework.coviframework.util;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.springframework.util.Assert;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.tika.Tika;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;

public class XSSMultipartResolver extends CommonsMultipartResolver {
	private static final Logger LOGGER = LogManager.getLogger(XSSMultipartResolver.class);
			
	// xss, sql injection 체크 하지 않을 파라미터 keyList(comma로 구분)
	private static String[] excludeFieldsArr = PropertiesUtil.getGlobalProperties().getProperty("filter.notCheckList").split(",");
	
	private boolean resolveLazily = false;
	
	public XSSMultipartResolver() {
		super();
	}
	public void setMaxUploadSize(String maxUploadSize) {
		boolean isNumeric =  maxUploadSize.matches("[+-]?\\d*(\\.\\d+)?");
		
		if (!isNumeric)
			maxUploadSize = "100000000";
		
		FileUtil.setMaxUploadSize(maxUploadSize);
		this.setMaxUploadSize(Long.parseLong(maxUploadSize));
	}
	
	public void setResolveLazily(boolean resolveLazily) {
		this.resolveLazily = resolveLazily;
	}
	
	public MultipartHttpServletRequest resolveMultipart(final HttpServletRequest request) throws MultipartException {
		Assert.notNull(request, "Request must not be null");
		if (this.resolveLazily) {
			return new XSSMultipartHttpServletRequest(request) {
				@Override
				protected void initializeMultipart() {
					MultipartParsingResult parsingResult = parseRequest(request);
					setMultipartFiles(parsingResult.getMultipartFiles());
					setMultipartParameters(parsingResult.getMultipartParameters());
					setMultipartParameterContentTypes(parsingResult.getMultipartParameterContentTypes());
				}
			};
		}
		else {
			MultipartParsingResult parsingResult = parseRequest(request);
			return new XSSMultipartHttpServletRequest(request, parsingResult.getMultipartFiles(),
						parsingResult.getMultipartParameters(), parsingResult.getMultipartParameterContentTypes());
		}
	}
	
	static class XSSMultipartHttpServletRequest extends DefaultMultipartHttpServletRequest {

		public XSSMultipartHttpServletRequest(HttpServletRequest request) {
			super(request);
		}
		
		public XSSMultipartHttpServletRequest(HttpServletRequest request, MultiValueMap<String, MultipartFile> mpFiles,
				Map<String, String[]> mpParams, Map<String, String> mpParamContentTypes) {
			super(request);
//			try{
				MultiValueMap<String, MultipartFile> files =
						new org.springframework.util.LinkedMultiValueMap<String, MultipartFile>(java.util.Collections.unmodifiableMap(mpFiles));
				List<String> extCheckList = Arrays.asList(RedisDataUtil.getBaseConfig("EnableFileExtention").split(","));
				List<String> validMimeTypes = Arrays.asList(RedisDataUtil.getBaseConfig("EnableFileMime").split(","));

			    if (!files.isEmpty()) {
			    	java.util.Iterator<java.util.Map.Entry<String, java.util.List<MultipartFile>>> itr = files.entrySet().iterator();
			    	while (itr.hasNext()) {
			    		java.util.Map.Entry<String, java.util.List<MultipartFile>> entry = itr.next();
			    		java.util.List<MultipartFile> mFiles = entry.getValue();
			    		for (int i=0; i < mFiles.size(); i++){
				    		MultipartFile mFile = mFiles.get(i);
							String orginFileName = mFile.getOriginalFilename();
							String extName = FilenameUtils.getExtension(orginFileName).toLowerCase();
							if (!extName.equals("")){
								//String mimeType = new Tika().detect(f);
								if(!extCheckList.contains(extName)){
									throw new MultipartException("Upload files in a limited extension.["+extName+"]");
								}
								if(!validMimeTypes.contains(mFile.getContentType())){
									throw new MultipartException("Upload is not possible. ["+mFile.getContentType()+"]");
								}
							}	
			    		}
			    	}
			    }
//
				setMultipartFiles(mpFiles);
				setMultipartParameters(mpParams);
				setMultipartParameterContentTypes(mpParamContentTypes);

//			}catch(Exception e){
//				throw new MultipartException("fileUpload exception");
//				LOGGER.error(e.getLocalizedMessage(), e);
//			}
		}
		
		/* 단일파라미터 조회시 반복적으로 불필요한 Loop 로 성능저하. 
		 * Super( DefaultMultipartHttpServletRequest ) 의 getParameter(String) 참고.
		protected Map<String, String[]> getMultipartParameters() {
			Map<String, String[]> result = super.getMultipartParameters();
			Set<String> keySet = result.keySet();
			
			for(String key: keySet){
				String[] values = result.get(key);
				String[] resultValues = new String[values.length];
				for(int i=0; i<values.length; i++) {
					String value = values[i];
					//filter xss below here
					if (Arrays.asList(excludeFieldsArr).contains(key)) {
						resultValues[i] = value;
					}else {
						resultValues[i] = stripXSS(value);
					}
				}
				result.put(key, resultValues);
			}
			
			return result;
		}
		*/
		
		@Override
		public String getParameter(String name) {
			if (Arrays.asList(excludeFieldsArr).contains(name)) {
				return super.getParameter(name);
			}
			return stripXSS(super.getParameter(name));
		}
		
		
		private String stripXSS(String value) {
	        if (value != null) {
				return XSSUtils.XSSFilter(value);
	        }
	        return value;
	    }

	}
}

