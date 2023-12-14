package egovframework.covision.coviflow.common.util;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Component;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.s3.AwsS3;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.validator.routines.UrlValidator;

@Component("ApprovalUtil")
public class ApprovalUtil {

	private static final Logger LOGGER = LogManager.getLogger(ApprovalUtil.class);
	private static final String IS_SAAS;
	private static final String OS_TYPE;
	private static final String TEMPLATE_PATH;
	private static final String SAAS_TEMPLATE_PATH;
	private static final String S3_TEMPLATE_PATH;
	private static final String S3_SAAS_TEMPLATE_PATH;
	static AwsS3 awsS3 = AwsS3.getInstance();
	
	static {
		OS_TYPE = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		IS_SAAS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		
		S3_TEMPLATE_PATH = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("templateAwsS3.path"));
		S3_SAAS_TEMPLATE_PATH = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("isSaaStemplateFormAwsS3.Path"));
		
		if (OS_TYPE.equals("UNIX")) {
			TEMPLATE_PATH = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("templateUNIX.path"));
		} else {
			TEMPLATE_PATH = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("templateWINDOW.path"));
		}
		SAAS_TEMPLATE_PATH = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("isSaaStemplateForm.Path"));
	}
	
	public static String getTemplatePath(){
		return getTemplatePath("");
	}
	
	public static String getTemplatePath(String dnCode){
		String rtnPath = "";
		String templatePath = "";
		String saasTemplatePath = "";
		
		if(dnCode==null || dnCode.equals("")){
			dnCode = SessionHelper.getSession("DN_Code");
		}
		
		templatePath = awsS3.getS3Active(dnCode) ? S3_TEMPLATE_PATH : TEMPLATE_PATH;
		saasTemplatePath = awsS3.getS3Active(dnCode) ? S3_SAAS_TEMPLATE_PATH : SAAS_TEMPLATE_PATH;
		
		if(!templatePath.endsWith("/")){
			templatePath = templatePath+"/";
		}
		if(!saasTemplatePath.endsWith("/")){
			saasTemplatePath = saasTemplatePath+"/";
		}
		
		if("Y".equals(IS_SAAS) && saasTemplatePath.contains("{0}") ) {
			rtnPath = saasTemplatePath.replace("{0}", dnCode);
		}else {
			rtnPath = templatePath;
		}
		
		return rtnPath;
	}
	public static String uriEncode(String url) {
		String fileName = url.substring( url.lastIndexOf("/")+1 );		
		return url.substring(0, url.indexOf(fileName))+encodeURIComponent(fileName);
	}
	
	public static String encodeURIComponent(String s)
	  {
	    String result = null;
	    try{
	      result = URLEncoder.encode(s, "UTF-8")
	                         .replaceAll("\\+", "%20")
	                         .replaceAll("\\%21", "!")
	                         .replaceAll("\\%27", "'")
	                         .replaceAll("\\%28", "(")
	                         .replaceAll("\\%29", ")")
	                         .replaceAll("\\%7E", "~");
	    }
	    catch (UnsupportedEncodingException e){
	      result = s;
	    }
	    return result;
	  }

	public static String fileToBase64(String filePath) throws Exception{		
		Base64 base64 = new Base64();
		UrlValidator urlValidator = new UrlValidator();
		URL url = null;
		ByteArrayOutputStream byteOutStream = null;
		byte[] fileArray = null;
		InputStream inputStream = null;		

		try {
			if( urlValidator.isValid(filePath) ) {
				filePath = uriEncode(filePath);
				url = new URL(filePath);
				inputStream = url.openStream();
			}else {
				inputStream = new FileInputStream( new File(filePath) );
			}
			
			byteOutStream = new ByteArrayOutputStream();
			int len = 0;
			byte[] buf = new byte[1024];
			while( ( len = inputStream.read( buf ) ) != -1 ) byteOutStream.write(buf, 0, len);
			fileArray = byteOutStream.toByteArray();
		}finally {
			if(inputStream != null)inputStream.close();
			if(byteOutStream != null)byteOutStream.close();
		}
		
		return new String(Base64.encodeBase64(fileArray, true), "UTF-8");
		
	}
	
	
}
