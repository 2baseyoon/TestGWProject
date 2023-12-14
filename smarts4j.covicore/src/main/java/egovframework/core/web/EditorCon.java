package egovframework.core.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.OpenOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.zip.InflaterInputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.amazonaws.services.s3.model.ObjectMetadata;
import egovframework.coviframework.util.s3.AwsS3;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.tika.Tika;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.FileUtil;


@Controller
public class EditorCon {
	
	private static final Logger LOGGER = LogManager.getLogger(EditorCon.class);

	static AwsS3 awsS3 = AwsS3.getInstance();
	
	@RequestMapping(value = { "/SynapEditor/uploadFile.do" }, method = { RequestMethod.POST })
	public @ResponseBody Map<String, Object> synapEditorUploadFile(@RequestParam("file") MultipartFile file) throws IOException {
		String companyCode = SessionHelper.getSession("DN_Code");
		String ROOT_PATH = FileUtil.getFrontPath()
				+ File.separator + companyCode
				+ PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
		String fileName = file.getOriginalFilename();
		String contentType = file.getContentType();
		String ext = "";

		if (contentType != null) {
			ext = "." + contentType.substring(contentType.lastIndexOf('/') + 1);
		} else if (fileName.lastIndexOf('.') > 0) {
			ext = fileName.substring(fileName.lastIndexOf('.'));
		}

		if (ext.indexOf(".jpeg") > -1) { // jpg가 더많이쓰여서 jpeg는 jpg로 변환
			ext = ".jpg";
		}
		
		String saveFileName = UUID.randomUUID().toString() + ext;

		File uploadDir = new File(ROOT_PATH);
		if (!uploadDir.exists()) {
			if(uploadDir.mkdirs()){
				LOGGER.info("path : " + uploadDir + " mkdirs();");
			}
		}
		
		byte[] bytes = file.getBytes();
		Path path = Paths.get(ROOT_PATH + saveFileName, new String[0]);
		Files.write(path, bytes, new OpenOption[0]);

		String pathStr = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")
				+ RedisDataUtil.getBaseConfig("FrontStorage").replace("{0}", companyCode)
				+ PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path")
				+ saveFileName;

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("uploadPath", pathStr);

		return map;
	}

	@RequestMapping(value = { "/SynapEditor/importDoc.do" }, method = { RequestMethod.POST })
	public @ResponseBody Map<String, Object> synapEditorImportDoc(@RequestParam("file") MultipartFile importFile) throws IOException {
		String companyCode = SessionHelper.getSession("DN_Code");
		String ROOT_PATH = FileUtil.getFrontPath() + File.separator + companyCode + File.separator + "uploads";
		String DOC_UPLOAD_DIR = File.separator + "docs";
		String WORKS_DIR = File.separator + "tmp";

		String fileName = importFile.getOriginalFilename();

		File uploadDir = new File(ROOT_PATH + DOC_UPLOAD_DIR);
		if (!uploadDir.exists()) {
			if(uploadDir.mkdirs()){
				LOGGER.info("path : " + uploadDir + " mkdirs();");
			}
		}
		
		byte[] bytes = new byte[0];
		try {
			bytes = importFile.getBytes();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		Path path = Paths.get(ROOT_PATH + DOC_UPLOAD_DIR + File.separator + fileName, new String[0]);
		
		try {
			Files.write(path, bytes, new OpenOption[0]);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		File worksDir = new File(ROOT_PATH + WORKS_DIR);
		if (!worksDir.exists()) {
			if(worksDir.mkdirs()){
				LOGGER.info("path : " + worksDir + " mkdirs();");
			}
		}
		
		executeConverter(ROOT_PATH + DOC_UPLOAD_DIR + File.separator + fileName, ROOT_PATH + WORKS_DIR);

		deleteFile(ROOT_PATH + DOC_UPLOAD_DIR + File.separator + fileName);

		String PbPath = ROOT_PATH + WORKS_DIR + "/document.pb";
		Integer[] serializedData = serializePbData(PbPath);

		deleteFile(PbPath);

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("serializedData", serializedData);
		map.put("importPath", WORKS_DIR);

		return map;
	}
	
	@RequestMapping(value = { "/ckeditor/uploadFile.do" }, method = { RequestMethod.POST })
	public @ResponseBody CoviMap ckEditorUploadFile(HttpServletRequest request, HttpServletResponse response, @RequestParam MultipartFile upload){
		CoviMap returnObj = new CoviMap();
		
		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			String ROOT_PATH = FileUtil.getFrontPath()
					+ File.separator + companyCode
					+ PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");

			byte[] bytes = upload.getBytes();
			String fileName = upload.getOriginalFilename();
			String contentType = upload.getContentType();
			String ext = "";

			if (contentType != null) {
				ext = "." + contentType.substring(contentType.lastIndexOf('/') + 1);
			} else if (fileName.lastIndexOf('.') > 0) {
				ext = fileName.substring(fileName.lastIndexOf('.'));
			}

			String saveFileName = UUID.randomUUID().toString() + ext;
			String frontPath = RedisDataUtil.getBaseConfig("FrontStorage").replace("{0}", companyCode);
			String gwAttachPath = PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
			String pathStr = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")
					+ frontPath
					+ gwAttachPath
					+ saveFileName;
			if(awsS3.getS3Active()){
				if(frontPath.endsWith("/")){
					frontPath = frontPath.substring(1);
				}
				String key = frontPath
						+ gwAttachPath
						+ saveFileName;
				ObjectMetadata objectMetadata = new ObjectMetadata();
				String mimeType = URLConnection.guessContentTypeFromName(pathStr);
				objectMetadata.setContentType(mimeType);
				objectMetadata.setContentLength(bytes.length);
				InputStream is = new ByteArrayInputStream(bytes);
				awsS3.upload(is, key, objectMetadata.getContentType(), objectMetadata.getContentLength());

				returnObj.put("uploaded", 1);
				returnObj.put("fileName", saveFileName);
				returnObj.put("url", "/covicore/common/photo/photo.do?img="+key);
				is.close();
			}else {
				File uploadDir = new File(ROOT_PATH);
				if (!uploadDir.exists()) {
					if (uploadDir.mkdirs()) {
						LOGGER.info("path : " + uploadDir + " mkdirs();");
					}
				}

				Path path = Paths.get(ROOT_PATH + saveFileName, new String[0]);
				Files.write(path, bytes, new OpenOption[0]);

				returnObj.put("uploaded", 1);
				returnObj.put("fileName", saveFileName);
				returnObj.put("url", pathStr);
			}
		}
		catch (IOException e) {
			CoviMap errorObj  = new CoviMap();
			errorObj.put("message",e.getMessage());

			returnObj.put("uploaded", 0);
			returnObj.put("error", errorObj);
		}
		catch (Exception e) {
			CoviMap errorObj  = new CoviMap();
			errorObj.put("message",e.getMessage());

			returnObj.put("uploaded", 0);
			returnObj.put("error", errorObj);
		}
		
		return returnObj;
	}

	@RequestMapping(value = { "/covieditor/uploadFile.do", "/mobileeditor/uploadFile.do" }, method = { RequestMethod.POST })
	public @ResponseBody CoviMap covieditorUploadFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("file") MultipartFile upload){
		CoviMap returnObj = new CoviMap();

		try {
			String companyCode = SessionHelper.getSession("DN_Code");
			String ROOT_PATH = FileUtil.getFrontPath(companyCode)
					+ companyCode
					+ PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
			ROOT_PATH = ROOT_PATH.replaceAll("//","/");
			
			byte[] bytes = upload.getBytes();
			String fileName = upload.getOriginalFilename();
			String contentType = upload.getContentType();
			String ext = "";

			/*if (contentType != null) {
				ext = "." + contentType.substring(contentType.lastIndexOf('/') + 1);
			} else if (fileName.lastIndexOf('.') > 0) {
				ext = fileName.substring(fileName.lastIndexOf('.'));
			}*/

			ext = fileName.substring(fileName.lastIndexOf('.')); //일단 파일 확장자 그대로 사용하도록

			String saveFileName = UUID.randomUUID().toString() + ext;
			String frontPath = RedisDataUtil.getBaseConfig("FrontStorage").replace("{0}", companyCode);
			String gwAttachPath = PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
			String gwDomain = "";
			String strImageLoadUrl = RedisDataUtil.getBaseConfig("ImageLoadURL");
			if(request.getServletPath().equals("/covieditor/uploadFile.do")) {
				gwDomain = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
			} else if(request.getServletPath().equals("/mobileeditor/uploadFile.do")) {
				gwDomain = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
			}
			String pathStr = gwDomain + frontPath + gwAttachPath + saveFileName;

			if(awsS3.getS3Active()){
				if(ROOT_PATH.startsWith("/")){
					ROOT_PATH = ROOT_PATH.substring(1);
				}
				String key = ROOT_PATH
						+ saveFileName;
				String mimeType = URLConnection.guessContentTypeFromName(saveFileName);
				awsS3.upload(new ByteArrayInputStream(bytes), key, upload.getContentType(), bytes.length);
				if(!contentType.equals(mimeType)) {
					awsS3.delete(key); //file delete
					returnObj.put("error", "Invalid file.");
				} else {
					returnObj.put("location", strImageLoadUrl+key); // "/covicore/common/photo/photo.do?img="
				}
			}else{
				File uploadDir = new File(ROOT_PATH);
				if (!uploadDir.exists()) {
					if(uploadDir.mkdirs()){
						LOGGER.info("path : " + uploadDir + " mkdirs();");
					}
				}

				Path path = Paths.get(ROOT_PATH + saveFileName, new String[0]);
				Files.write(path, bytes, new OpenOption[0]);

				String mimeType = new Tika().detect(path); //mime type 체크로직 추가(보안)
				//System.err.println("contentType : " + contentType + ", mimeType : " + mimeType + ", ext : " + ext);

				if(!contentType.equals(mimeType)) {
					Files.delete(path); //file delete
					returnObj.put("error", "Invalid file.");
				} else {
					returnObj.put("location", pathStr);
				}
			}
		}
		catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("message", e.getMessage());
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("message", e.getMessage());
		}

		return returnObj;
	}

	public static int executeConverter(String inputFilePath, String outputFilePath) {
		String companyCode = SessionHelper.getSession("DN_Code");
		String SEDOC_CONVERT_DIR = RedisDataUtil.getBaseConfig("synapConverterPath")
				+ "sedocConverter/sedocConverter_exe";
		String FONT_DIR = RedisDataUtil.getBaseConfig("synapConverterPath") + "fonts";
		String TEMP_DIR = FileUtil.getFrontPath() + File.separator + companyCode + File.separator + "tmpconverter";

		File tempDir = new File(TEMP_DIR);
		if (!tempDir.exists()) {
			if(tempDir.mkdirs()){
				LOGGER.info("path : " + tempDir + " mkdirs();");
			}
		}
		File fontDir = new File(FONT_DIR);
		if (!fontDir.exists()) {
			if(fontDir.mkdirs()){
				LOGGER.info("path : " + fontDir + " mkdirs();");
			}
		}
		String[] cmd = { SEDOC_CONVERT_DIR, "-f", FONT_DIR, inputFilePath, outputFilePath, TEMP_DIR };

		try {
			Timer t = new Timer();
			Process proc = Runtime.getRuntime().exec(cmd);
			TimerTask killer = new TimeoutProcessKiller(proc);
			t.schedule(killer, 20000); // 20초 (변환이 20초 안에 완료되지 않으면 프로세스 종료)

			int exitValue = proc.waitFor();
			killer.cancel();

			return exitValue;

		}
		catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return -1;
		}
		catch (InterruptedException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return -1;
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return -1;
		}
	}

	public Integer[] serializePbData(String pbFilePath) throws IOException {
		List<Integer> serializedData = new ArrayList<Integer>();
		FileInputStream fis = null;
		InflaterInputStream ifis = null;
		Integer[] data = null;

		try {
			fis = new FileInputStream(pbFilePath);
			long skipped = fis.skip(16);

			ifis = new InflaterInputStream(fis);
			byte[] buffer = new byte[1024];

			int len;
			while ((len = ifis.read(buffer)) != -1) {
				for (int i = 0; i < len; i++) {
					serializedData.add(buffer[i] & 0xFF);
				}
			}

			data = serializedData.toArray(new Integer[serializedData.size()]);
		} finally {
			if (ifis != null) {
				try {
					ifis.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
			if (fis != null) {
				try {
					fis.close();
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				}
			}
		}

		return data;
	}

	private static void deleteFile(String path) {
		File file = new File(path);
		if (file.exists()) {
			if(file.delete()) {
				LOGGER.info("file : " + file.toString() + " delete();");
			}
		}
	}

	private static class TimeoutProcessKiller extends TimerTask {
		private Process p;

		public TimeoutProcessKiller(Process p) {
			this.p = p;
		}

		@Override
		public void run() {
			p.destroy();
		}
	}

 }

