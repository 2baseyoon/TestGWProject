package egovframework.coviframework.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class MultipartUtility {
	private static final Logger LOGGER = LogManager.getLogger(MultipartUtility.class);

	private final String boundary;
    private static final String LINE_FEED = "\r\n";
    private HttpURLConnection httpConn;
    private String charset;
    private OutputStream outputStream;
    private PrintWriter writer;
    
    /**
     * This constructor initializes a new HTTP POST request with content type
     * is set to multipart/form-data
     *
     * @param requestURL
     * @param charset
     * @throws IOException
     */
    public MultipartUtility(String requestURL, String charset)
            throws IOException {
        this.charset = charset;
        // creates a unique boundary based on time stamp
        //boundary = "===" + System.currentTimeMillis() + "==="; // added
        boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"; // add
        URL url = new URL(requestURL);
        httpConn = (HttpURLConnection) url.openConnection();
        httpConn.setUseCaches(false);
        httpConn.setDoOutput(true);    // indicates POST method
        httpConn.setDoInput(true);
        httpConn.setRequestProperty("Content-Type","multipart/form-data; boundary=" + boundary);
        outputStream = httpConn.getOutputStream();
        writer = new PrintWriter(new OutputStreamWriter(outputStream, this.charset),true);
    }

    /**
     * Adds a form field to the request
     *
     * @param name  field name
     * @param value field value
     */
    public void addFormField(String name, String value) {
    	writer.append(LINE_FEED); // add
    	writer.append("--" + boundary).append(LINE_FEED); // add
        //writer.append("--" + boundary).append(LINE_FEED); // added
        writer.append("Content-Disposition: form-data; name=\"" + name + "\"").append(LINE_FEED);
        //writer.append("Content-Type: text/plain; charset=" + charset).append(LINE_FEED); // added
        writer.append(LINE_FEED);
        //writer.append(value).append(LINE_FEED); // added
        writer.append(value);
        writer.flush();
    }

    /**
     * Adds a upload file section to the request
     *
     * @param fieldName  name attribute in <input type="file" name="..." />
     * @param uploadFile a File to be uploaded
     * @throws IOException
     */
    public void addFilePart(String fieldName, File uploadFile)
            throws IOException {
    	
    	FileInputStream inputStream = null;
    	try {
	        String fileName = uploadFile.getName();
	        writer.append(LINE_FEED); // add
	        writer.append("--" + boundary).append(LINE_FEED); // added
	        writer.append(
	                "Content-Disposition: form-data; name=\"" + fieldName
	                        + "\"; filename=\"" + fileName + "\"")
	                .append(LINE_FEED);
	        writer.append(
	                "Content-Type: "
	                        + URLConnection.guessContentTypeFromName(fileName))
	                .append(LINE_FEED);
	        //writer.append("Content-Transfer-Encoding: binary").append(LINE_FEED); // added
	        writer.append(LINE_FEED);
	        writer.flush();
	
	        inputStream = new FileInputStream(uploadFile);
	        //byte[] buffer = new byte[4096]; // added
	        //int bytesRead = -1; // added
	        byte[] buffer = new byte[1024]; // add
	        int bytesRead = 0; // add
	        //JSYun:Memory분산처리 시작 
	        //while ((bytesRead = inputStream.read(buffer)) != -1) {
	        //    outputStream.write(buffer, 0, bytesRead);
	        //}
	        int bytesBuffered=0;
	        while ((bytesRead = inputStream.read(buffer)) != -1) {
	            outputStream.write(buffer, 0, bytesRead);
	            bytesBuffered += bytesRead;
	        	if(bytesBuffered > 1024 * 1024){ //flush after 1M
	        		bytesBuffered=0;
	        		outputStream.flush();
	        	}
	        }
	        //JSYun:Memory분산처리 종료
	        outputStream.flush();
	        
	        // writer.append(LINE_FEED); // added
	        writer.flush();
    	}finally {
    		if(inputStream != null) {
    			try{ inputStream.close(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.addFilePart", ex); }
    		}
    	}
    }

    /**
     * inputStream will must close after call this method.
     * @param fieldName
     * @param inputStream of File
     * @throws IOException
     */
    public void addFilePart(String fieldName, InputStream inputStream, String fileName) throws IOException {
		writer.append(LINE_FEED); // add
		writer.append("--" + boundary).append(LINE_FEED); // added
		writer.append(
		                "Content-Disposition: form-data; name=\"" + fieldName
		                        + "\"; filename=\"" + fileName + "\"")
		        .append(LINE_FEED);
		writer.append(
		                "Content-Type: "
		                        + URLConnection.guessContentTypeFromName(fileName))
		        .append(LINE_FEED);
		//writer.append("Content-Transfer-Encoding: binary").append(LINE_FEED); // added
		writer.append(LINE_FEED);
		writer.flush();

		byte[] buffer = new byte[1024]; // add
		int bytesRead = 0; // add
		//JSYun:Memory분산처리 시작
		//while ((bytesRead = inputStream.read(buffer)) != -1) {
		//    outputStream.write(buffer, 0, bytesRead);
		//}
		int bytesBuffered=0;
		while ((bytesRead = inputStream.read(buffer)) != -1) {
		    outputStream.write(buffer, 0, bytesRead);
		    bytesBuffered += bytesRead;
		    if(bytesBuffered > 1024 * 1024){ //flush after 1M
		        bytesBuffered=0;
		        outputStream.flush();
		    }
		}
		//JSYun:Memory분산처리 종료
		outputStream.flush();
		
		// writer.append(LINE_FEED); // added
		writer.flush();
    }
    
    public void addFilePart(String fieldName, byte[] bytes, String fileName)
            throws IOException {
    	InputStream inputStream = null;
    	try {
	        inputStream = new ByteArrayInputStream(bytes);
	        writer.append(LINE_FEED); // add
	        writer.append("--" + boundary).append(LINE_FEED); // added
	        writer.append(
	                        "Content-Disposition: form-data; name=\"" + fieldName
	                                + "\"; filename=\"" + fileName + "\"")
	                .append(LINE_FEED);
	        writer.append(
	                        "Content-Type: "
	                                + URLConnection.guessContentTypeFromName(fileName))
	                .append(LINE_FEED);
	        //writer.append("Content-Transfer-Encoding: binary").append(LINE_FEED); // added
	        writer.append(LINE_FEED);
	        writer.flush();
	
	        byte[] buffer = new byte[1024]; // add
	        int bytesRead = 0; // add
	        //JSYun:Memory분산처리 시작
	        //while ((bytesRead = inputStream.read(buffer)) != -1) {
	        //    outputStream.write(buffer, 0, bytesRead);
	        //}
	        int bytesBuffered=0;
	        while ((bytesRead = inputStream.read(buffer)) != -1) {
	            outputStream.write(buffer, 0, bytesRead);
	            bytesBuffered += bytesRead;
	            if(bytesBuffered > 1024 * 1024){ //flush after 1M
	                bytesBuffered=0;
	                outputStream.flush();
	            }
	        }
	        //JSYun:Memory분산처리 종료
	        outputStream.flush();
	        
	        // writer.append(LINE_FEED); // added
	        writer.flush();
    	}finally {
    		if(inputStream != null) {
    			try{ inputStream.close(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.addFilePart", ex); }
    		}
    	}
    }


    /**
     * Adds a header field to the request.
     *
     * @param name  - name of the header field
     * @param value - value of the header field
     */
    public void addHeaderField(String name, String value) {
        writer.append(name + ": " + value).append(LINE_FEED);
        writer.flush();
    }

    /**
     * Completes the request and receives response from the server.
     *
     * @return a list of Strings as response in case the server returned
     * status OK, otherwise an exception is thrown.
     * @throws IOException
     */
    public List<String> finish() throws IOException {
        List<String> response = new ArrayList<String>();
        BufferedReader reader = null;
        try {
	        writer.append(LINE_FEED).flush();        
	        writer.append("--" + boundary + "--").append(LINE_FEED); //added
	        //writer.close();
	
	        // checks server's status code first
	        int status = httpConn.getResponseCode();
	        if (status == HttpURLConnection.HTTP_OK) {
	            reader = new BufferedReader(new InputStreamReader(httpConn.getInputStream(), StandardCharsets.UTF_8));
	            //System.out.println("server status " + status);
	            String line = null;
	            while ((line = reader.readLine()) != null) {
	                response.add(line);
	            }
	            if (reader != null) reader.close();
	            //httpConn.disconnect();
	        } else {
	            throw new IOException("Server returned non-OK status: " + status);
	        }
        }finally {
        	if(reader != null) {
    			try{ reader.close(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.finish", ex); }
    		}
        	if(writer != null) {
    			try{ writer.close(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.finish", ex); }
    		}
        	if(outputStream != null) {
    			try{ outputStream.close(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.finish", ex); }
    		}
        	if(httpConn != null) {
    			try{ httpConn.disconnect(); } catch(NullPointerException e){	LOGGER.error("MultipartUtility.addFilePart", e); }catch(Exception ex){ LOGGER.error("MultipartUtility.finish", ex); }
    		}
        }
        return response;
    }
}
