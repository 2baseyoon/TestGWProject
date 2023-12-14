package egovframework.covision.coviflow.govdocs.record.handler;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class PdfHandler {

	private static final Logger LOGGER = LogManager.getLogger(PdfHandler.class);
	
	private static String phantomsDIR = "phantomjs/bin/";
	
	public static long makeHtmlToPdf(String osType, String appPath, String pdfUrl, String workDir, String recordClassNum, String pdfFileName){
		long fileSize = 0;
		
		String prefixDir = "";
		StringBuffer sb = new StringBuffer();
		
		if("WINDOWS".equals(osType)){
			sb.append("cmd /c ");
			prefixDir = "C:";
		}
		
		sb.append(prefixDir + appPath + phantomsDIR + "phantomjs ");
		sb.append(prefixDir + appPath + phantomsDIR + "htmltopdf.js ");
		sb.append(" " + pdfUrl);
		sb.append(" " + workDir + recordClassNum + "/" + pdfFileName);
		sb.append(" 860*1200 ");
		
		File workPdfDir = new File(workDir + recordClassNum);
		if(!workPdfDir.isDirectory() && !workPdfDir.mkdirs()) {
			LOGGER.debug("Failed to make directories.");
		}
		LOGGER.debug("== HTML URL convert to pdf file");
		LOGGER.debug(sb.toString());
		
		if(shellCmd(sb.toString())){
			LOGGER.debug("PDF dir : {}", workDir + recordClassNum + "/" + pdfFileName);
			File pdfFile = new File(workDir + recordClassNum + "/" + pdfFileName);
			
			if(pdfFile.isFile()){
				fileSize = pdfFile.length();
			}
		}
		
		return fileSize;
		
	}
	//	String command = "/devp/app/phantomjs/bin/phantomjs /devp/app/phantomjs/bin/htmltopdf.js http://devportal.kic.go.kr/approval/approval_Form.do?mode=COMPLETE&processID=645000&workitemID=340697&performerID=2651&processdescriptionID=2412&forminstanceID=&userCode=131060&gloct=DEPART&admintype=&archived=true&usisdocmanager=true&listpreview=N&subkind=A&ExpAppID=&taskID=&CFN_OpenWindowName=69568 ssotest2.pdf";
	//	String command = "C:/devp/app/phantomjs/bin/phantomjs C:/devp/app/phantomjs/bin/htmltopdf.js http://sso.kic.go.kr/login.jsp ssotest5_test.pdf";
	
	private static boolean shellCmd(String command){
		Boolean result = true;
		Runtime runtime = Runtime.getRuntime();
		try{
			Process process = runtime.exec(command);
			try(
					InputStream stderr = process.getErrorStream();
					OutputStream stdin = process.getOutputStream();
					InputStream sdtout = process.getInputStream();
					BufferedReader reader = new BufferedReader(new InputStreamReader(sdtout, StandardCharsets.UTF_8));
			){
				String line;
				while((line = reader.readLine()) != null){
					
				}
			} catch(IOException ioE){
				result = false;
				LOGGER.error("============= shellCmd error1 ====================");
				LOGGER.error(ioE.getMessage(), ioE);
			} catch(Exception e){
				result = false;
				LOGGER.error("============= shellCmd error1 ====================");
				LOGGER.error(e.getMessage(), e);
			}
		} catch(NullPointerException npE){
			result = false;
			LOGGER.error("============= shellCmd error2 ====================");
			LOGGER.error(npE.getMessage(), npE);
		} catch(Exception e){
			result = false;
			LOGGER.error("============= shellCmd error2 ====================");
			LOGGER.error(e.getMessage(), e);
		}
		return result;
	}

}
