package egovframework.coviaccount.common.util;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.baseframework.util.SessionHelper;

import java.util.Map;
import java.util.Objects;
import java.io.File;
import java.lang.invoke.MethodHandles;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;




import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component("AccountFileUtil")
public class AccountFileUtil  {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Resource(name="coviMapperOne")
	private  CoviMapperOne coviMapperOne;

	/**
	* @Method Name : moveToBack
	* @Description : front에서 back로 이동
					covicore/coviframework에서 copy
	*/
	// 미사용, FileUtilService 함수로 대체
//	public  CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
//		CoviList returnList = new CoviList();
//		String companyCode = Objects.toString(SessionHelper.getSession("DN_Code"),"");
//		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
//		//String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + servicePath;
//		String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
//		String currentDay = DateHelper.getCurrentDay("yyyy/MM/dd");
//		String fullPath = backServicePath + currentDay;
//		
//		String FILE_SEPARATOR = "/";
//		
//		File dir = new File(fullPath);
//
//		if (!dir.exists()) {
//		    if(dir.mkdirs()) {
//		        logger.info("moveToBack : dir mkdirs();");
//		    }			
//		}
//		
//		/*
//		 * 1. DB 처리
//		 * 2. File 처리
//		 * 
//		 * */
//		if (!frontFileInfos.isEmpty()) {
//			//기존 파일 처리
//
//			for (int i = 0; i < frontFileInfos.size(); i++) {
//				//0. 변수 처리
//				CoviMap frontFile = (CoviMap)frontFileInfos.get(i);
//				String fileName = frontFile.getString("FileName");
//				String frontSavedName = frontFile.getString("SavedName");
//				String savedName = "";
//				String fileSize = frontFile.getString("Size");
//				String ext = FilenameUtils.getExtension(fileName);
//				
//				//JSONObject fileObj = new CoviMap();
//				// 파일 중복명 처리
//				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
//				// 본래 파일명
//				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
//				// 저장되는 파일 이름
//				savedName = genId + "." + ext;
//				
//				//1. DB 처리
//				String storageID = storageInfo.optString("StorageID");
//				String version = "0";
//				String saveType = FileUtil.returnSaveType(fileName);
//				String lastSeq = "0";
//				String seq = String.valueOf(i);
//				String filePath = currentDay + FILE_SEPARATOR;
//				String thumbWidth = "0";
//				String thumbHeight = "0";
//				String desc = "";
//				String register = Objects.toString(SessionHelper.getSession("USERID"),"");
//				//String companyCode = Objects.toString(SessionHelper.getSession("DN_Code"),"");
//				
//				CoviMap fileParam = new CoviMap();
//				fileParam.put("StorageID" , storageID);
//				fileParam.put("ServiceType" , serviceType);
//				fileParam.put("ObjectID" , objectID);
//				fileParam.put("ObjectType" , objectType);
//				fileParam.put("MessageID" , messageID);
//				fileParam.put("Version" , version);
//				fileParam.put("SaveType" , saveType);
//				fileParam.put("LastSeq" , lastSeq);
//				fileParam.put("Seq" , seq);
//				fileParam.put("FilePath" , filePath);
//				fileParam.put("FileName" , fileName);
//				fileParam.put("SavedName" , savedName);
//				fileParam.put("Extention" , ext);
//				fileParam.put("Size" , fileSize);
//				fileParam.put("ThumWidth" , thumbWidth);
//				fileParam.put("ThumHeight" , thumbHeight);
//				fileParam.put("Description" , desc);
//				fileParam.put("RegisterCode" , register);
//				fileParam.put("CompanyCode" , companyCode);
//				
//				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
//				String fileID = fileParam.get("FileID").toString();
//				
//				//2. File 처리
//				String fullFrontFilePath = FileUtil.getFrontPath() + FILE_SEPARATOR + SessionHelper.getSession("DN_Code") + FILE_SEPARATOR + frontSavedName;
//				String fullBackPath = fullPath + FILE_SEPARATOR;
//				Path file = Paths.get(fullFrontFilePath);
//				Path movePath = Paths.get(fullBackPath);
//				Files.move(file , movePath.resolve(savedName));
//				if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
//					Path fileThumb = Paths.get(FileUtil.getFrontPath() + FILE_SEPARATOR + SessionHelper.getSession("DN_Code") + FILE_SEPARATOR + FilenameUtils.getBaseName(frontSavedName) + "_thumb.jpg");
//					Files.move(fileThumb , movePath.resolve(genId + "_thumb.jpg"));
//		        }
//				
//				returnList.add(CoviMap.fromObject(fileParam));
//			}
//			
//		}
//		
//		return returnList;
//	}

	/**
	* @Method Name : deleteFileByID
	* @Description : 파일 ID로 파일 삭제
	*/
	// 미사용, FileUtilService 함수로 대체
//	public void deleteFileByID(String fileID)throws Exception{
//		CoviMap param = new CoviMap();
//		if(fileID == null){
//			return;
//		}
//		if("".equals(fileID)){
//			return;
//		}
//		param.put("FileID", fileID);
//		Map fileInfo = coviMapperOne.selectOne("framework.FileUtil.selectOne", param);
//
//		if(fileInfo != null && fileInfo.size() > 0) {
//			String companyCode = (String)fileInfo.getOrDefault("CompanyCode",SessionHelper.getSession("DN_Code"));
//			//String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
//			String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + ((String)fileInfo.get("StorageFilePath")).replace("{0}", companyCode);
//			String fileFolder = (String)fileInfo.get("FilePath");
//			String fullPath = backServicePath + fileFolder;
//			String fileSavedNm = (String)fileInfo.get("SavedName");
//			
//			File backFile = new File(fullPath+fileSavedNm);
//			
//			if(backFile.isFile()){
//				if(Files.deleteIfExists(backFile.toPath())){
//					coviMapperOne.delete("account.common.deleteFileDbByID", param);
//					//삭제 성공
//				} else {
//					//삭제 실패시 Logging
//					logger.error("Fail on deleteFile() : {}", backFile);
//					throw new Exception("deleteFile error.");
//				}
//			}
//		}
//	}
	
	public String getDisposition(HttpServletRequest request, String filename) throws Exception {
		String browser = FileUtil.getBrowser(request);
		
		String encodedFilename = null;
		if (browser.equals("MSIE")) {
			encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8.name()).replaceAll("\\+", "%20");
		} else if (browser.equals("Firefox")) {
			encodedFilename ="\"" + new String(filename.getBytes(StandardCharsets.UTF_8), StandardCharsets.ISO_8859_1) + "\"";
		} else if (browser.equals("Opera")) {
			encodedFilename ="\"" + new String(filename.getBytes(StandardCharsets.UTF_8), StandardCharsets.ISO_8859_1) + "\"";
		} else if (browser.equals("iPhone")){
			encodedFilename ="\"" + new String(filename.getBytes(StandardCharsets.UTF_8), StandardCharsets.ISO_8859_1) + "\"";
		} else if (browser.equals("Chrome")) {
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < filename.length(); i++) {
				char c = filename.charAt(i);
				if (c > '~') {
					sb.append(URLEncoder.encode("" + c, "UTF-8"));
				} else {
					sb.append(c);
				}
			}
			encodedFilename = "\"" + sb.toString()+ "\"";
		} else {
			throw new RuntimeException("Not supported browser");
		}
		
		return encodedFilename;
	}
}
