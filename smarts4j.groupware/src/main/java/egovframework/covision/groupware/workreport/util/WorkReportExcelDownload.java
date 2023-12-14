package egovframework.covision.groupware.workreport.util;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.view.AbstractView;

public class WorkReportExcelDownload extends AbstractView{

	/** The content type for an Excel response */
	private static final String CONTENT_TYPE = "application/vnd.ms-excel; charset=utf-8";

	/** The extension to look for existing templates */
	private static final String EXTENSION = ".xls";

	
	@Override
	protected void renderMergedOutputModel(Map<String, Object> model, 
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		// model에서 넘겨받은 HTML Table Source를 Template과 합침
		
		String strExcelData = model.get("excelData").toString();
		
		// strExcelData = WorkReportUtils.ConvertOutputValue(strExcelData);
		
		strExcelData = URLDecoder.decode(strExcelData, "UTF-8");
		
		StringBuilder sbHTML = new StringBuilder();
		sbHTML.append("<HTML xmlns:x=\"urn:schemas-microsoft-com:office:excel\" ><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" ></head><body>");
		sbHTML.append(strExcelData);
		sbHTML.append("</body></HTML>");

		
		// response Header Setting
		// model에서 넘겨받은 excel File Name 설정
		String strFileName = model.get("fileName").toString();

		// FileName Setting
		convertFileName(strFileName, request, response);
		
		response.setCharacterEncoding("UTF-8");
		response.setContentType(CONTENT_TYPE);
		
		try(ServletOutputStream out = response.getOutputStream();){
			out.write(sbHTML.toString().getBytes("UTF-8"));
			out.flush();
		}
	}
	
	
	public void convertFileName(String filename, HttpServletRequest request, HttpServletResponse response) throws Exception {
		String browser = getBrowser(request);

        String dispositionPrefix = "attachment; filename=";

        String encodedFilename = null;
        
        if (browser.equals("MSIE")) {
               encodedFilename = URLEncoder.encode(filename, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.equals("Trident")) {       // IE11 문자열 깨짐 방지
               encodedFilename = URLEncoder.encode(filename, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.equals("Firefox")) {
               encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
               encodedFilename = URLDecoder.decode(encodedFilename, "UTF-8");
        } else if (browser.equals("Opera")) {
               encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
        } else if (browser.equals("Chrome")) {
               StringBuffer sb = new StringBuffer();

               for (int i = 0; i < filename.length(); i++) {
                      char c = filename.charAt(i);
                      if (c > '~') {
                            sb.append(URLEncoder.encode("" + c, "UTF-8"));
                      } else {
                            sb.append(c);
                      }

               }

               encodedFilename = sb.toString();

        } else if (browser.equals("Safari")){
               encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1")+ "\"";
               encodedFilename = URLDecoder.decode(encodedFilename, "UTF-8");
        }

        else {
               encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1")+ "\"";
        }

       

        response.setHeader("Content-Disposition", dispositionPrefix + encodedFilename + EXTENSION);
	}
	
	
	public String getBrowser(HttpServletRequest request) {
		String header = request.getHeader("User-Agent");
		
		if (header.indexOf("MSIE") > -1) {
			return "MSIE";
		} else if (header.indexOf("Trident") > -1) {   // IE11 문자열 깨짐 방지
			return "Trident";
		} else if (header.indexOf("Chrome") > -1) {
			return "Chrome";
		} else if (header.indexOf("Opera") > -1) {
			return "Opera";
		} else if (header.indexOf("Safari") > -1) {
			return "Safari";
		}
		
		return "Firefox";
	}
	
}
