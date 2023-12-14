package egovframework.coviframework.util;

import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import javax.imageio.ImageIO;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import egovframework.baseframework.util.RedisShardsUtil;
import io.lettuce.core.pubsub.RedisPubSubListener;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.tika.Tika;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Component;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.FrameworkServlet;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.vo.DRMIF;
import egovframework.coviframework.vo.FileVO;




/**
 * @Class Name : FileUtil.java
 * @Description : 파일 다운로드 및 업로드 메소드 제공
 * @Modification Information 
 * @ 2017.01.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.01.03
 * @version 1.0
 */
@Component
public class FileUtil {
	private static final Logger LOGGER = LogManager.getLogger(FileUtil.class);
	private static final String OS_TYPE;
	private static final String AES_KEY;
	private static CoviMap STORAGE_INFO_BY_TYPE = new CoviMap();
	private static CoviMap STORAGE_INFO_BY_ID = new CoviMap();
	private static final String CURRENT_DAY_FORMAT = "yyyy/MM/dd";
	private static final String CURRENT_TIME_FORMAT = "yyyyMMddhhmmssSSS";
	private static final String CHARSET = "UTF-8";
	private static final String FRONT_PATH;
	private static final String BACK_PATH;
	private static final String S3_FRONT_PATH;
	private static final String S3_BACK_PATH;
	private static String FILE_MAX_SIZE = "";
	static AwsS3 awsS3 = AwsS3.getInstance();
	
	public static final String CHANNELID = "storageInfoEvent";
	public static final String PUBSUB_TYPE_RESETALL = "RESET";
	private static RedisLettuceSentinelUtil lettuceUtil;
	private static StorageInfoRedisPubSubListener listener;
	
	@Autowired
	static ServletContext sc;

	static {
		OS_TYPE = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		AES_KEY = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		
		S3_BACK_PATH  = PropertiesUtil.getGlobalProperties().getProperty("attachAwsS3.path");
		S3_FRONT_PATH = PropertiesUtil.getGlobalProperties().getProperty("frontAwsS3.path");
		
		if (OS_TYPE.equals("UNIX")) {
			BACK_PATH = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			FRONT_PATH = PropertiesUtil.getGlobalProperties().getProperty("frontUNIX.path");
		} else {
			BACK_PATH = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			FRONT_PATH = PropertiesUtil.getGlobalProperties().getProperty("frontWINDOW.path");
		}
		
		// register Redis pub/sub event listener
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		if(instance instanceof RedisLettuceSentinelUtil && listener == null) {
			lettuceUtil = (RedisLettuceSentinelUtil)instance;
			listener = new StorageInfoRedisPubSubListener();
			lettuceUtil.subscribe(FileUtil.CHANNELID, listener);
			
			LOGGER.info("FileUtil storageInfo cache change listen started.");
		}
	}
	
//	@Autowired 
//	public FileUtil() { 
//		RedisShardsUtil instance = RedisShardsUtil.getInstance();
//		if(instance instanceof RedisLettuceSentinelUtil && listener == null) {
//			lettuceUtil = (RedisLettuceSentinelUtil)instance;
//			listener = new StorageInfoRedisPubSubListener();
//			lettuceUtil.subscribe(FileUtil.CHANNELID, listener);
//			
//			LOGGER.info("FileUtil storageInfo cache change listen started.");
//		}
//	}
	
	public static void setMaxUploadSize(String fileMaxSize){
		FILE_MAX_SIZE = fileMaxSize;
	}
	
	public static String getMaxUploadSize(){
		return FILE_MAX_SIZE;
	}
	
	
	public static String getBackPath(){
		String backPath = awsS3.getS3Active() ? S3_BACK_PATH : BACK_PATH;
		if(!backPath.endsWith("/")){
			backPath = backPath+"/";
		}
		return backPath;
	}

	public static String getFrontPath(){
		String frontPath = awsS3.getS3Active() ? S3_FRONT_PATH : FRONT_PATH;
		if(!frontPath.endsWith("/")){
			frontPath = frontPath+"/";
		}
		return frontPath;
	}
	
	public static String getBackPath(String dnCode){
		String backPath = awsS3.getS3Active(dnCode) ? S3_BACK_PATH : BACK_PATH; 
		if(!backPath.endsWith("/")){
			backPath = backPath+"/";
		}
		return backPath;
	}

	public static String getFrontPath(String dnCode){
		String frontPath = awsS3.getS3Active(dnCode) ? S3_FRONT_PATH : FRONT_PATH;
		if(!frontPath.endsWith("/")){
			frontPath = frontPath+"/";
		}
		return frontPath;
	}
	
	public static String getBackPath(boolean isS3){
		String backPath = isS3 ? S3_BACK_PATH : BACK_PATH;
		if(!backPath.endsWith("/")){
			backPath = backPath+"/";
		}
		return backPath;
	}
	
	public static String getFrontPath(boolean isS3){
		String frontPath = isS3 ? S3_FRONT_PATH : FRONT_PATH;
		if(!frontPath.endsWith("/")){
			frontPath = frontPath+"/";
		}
		return frontPath;
	}
	
	public static String returnSaveType(String fileName){
		String saveType = ""; //확장자가 jpg, jpeg, png, gif, bmp 면 'IMAGE' 그 외에는 'FILE'
    	final String[] IMAGE_EXTENSION = { "jpg", "jpeg", "png", "gif", "bmp" };

    	if(Arrays.asList(IMAGE_EXTENSION).contains(FilenameUtils.getExtension(fileName.toLowerCase()))){
    		saveType = "IMAGE";
    	} else {
    		saveType = "FILE";
    	}
    	
    	return saveType;
	}
	
	public static void setStorageInfo() throws Exception{
		setStorageInfo(true);
	}
	
	/**
	 * 
	 * @param bPublish : 타 모듈 적용 호출여부
	 * true : RedisPubSubListener 를 통해 타 모듈까지 적용
	 * false : 현재 모듈에만 적용
	 * @throws Exception
	 */
	public static void setStorageInfo(boolean bPublish) throws Exception{
		// params.put("osType", PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType"));
		STORAGE_INFO_BY_TYPE.clear();
		STORAGE_INFO_BY_ID.clear();
		CoviList storageJArr = new CoviList();
		storageJArr = StaticContextAccessor.getBean(FileUtilService.class).selectStorageInfo();
		
		for (int i = 0; i < storageJArr.size(); i++) {
			CoviMap storageJson = storageJArr.getJSONObject(i);
			String storageInfoKey = storageJson.optString("ServiceType").toUpperCase();
			String isActive = storageJson.optString("IsActive");
			
			STORAGE_INFO_BY_ID.put(storageJson.optString("StorageID"),storageJson);
			
			if(isActive.equalsIgnoreCase("Y")) {
				storageInfoKey += (storageJson.optString("DomainID").equals("0")) ? "" : ("_" + storageJson.optString("DomainCode")); // 계열사일때만 회사코드추가
				STORAGE_INFO_BY_TYPE.put(storageInfoKey,storageJson);
			}
		}
		
		if(bPublish && lettuceUtil != null) {
			lettuceUtil.publish(FileUtil.CHANNELID, FileUtil.PUBSUB_TYPE_RESETALL);
		}
	}
	
	private static class StorageInfoRedisPubSubListener implements RedisPubSubListener<String, String> {

		@Override
		public void message(String channel, String message) {
			if(!FileUtil.CHANNELID.equals(channel)) {
				return;
			}
			LOGGER.info("FileUtil storageInfo cache Message arrived. " + message);
			if(FileUtil.PUBSUB_TYPE_RESETALL.equals(message)) {
				try {
					setStorageInfo(false);
				} catch(NullPointerException e){	
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}

		@Override
		public void message(String pattern, String channel, String message) {
		}

		@Override
		public void subscribed(String channel, long count) {
		}

		@Override
		public void psubscribed(String pattern, long count) {
		}

		@Override
		public void unsubscribed(String channel, long count) {
		}

		@Override
		public void punsubscribed(String pattern, long count) {
		}
		
	}
	
	/**
	 * Get StorageInfo By ServiceType
	 * @param serviceType
	 * @param domainCode
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getStorageInfo(String serviceType, String domainCode) throws Exception{
		if(STORAGE_INFO_BY_TYPE.isEmpty()) {
			setStorageInfo();
		}
		
		CoviMap rtnJson = new CoviMap();
		String serviceTypeKey = serviceType.toUpperCase();
		
		if(STORAGE_INFO_BY_TYPE.has(serviceTypeKey + "_" + domainCode)) { // 계열사일때만 회사코드추가
			rtnJson = (CoviMap)(STORAGE_INFO_BY_TYPE.get(serviceTypeKey + "_" + domainCode));
		}else if(STORAGE_INFO_BY_TYPE.has(serviceTypeKey)) {
			rtnJson = (CoviMap)STORAGE_INFO_BY_TYPE.get(serviceTypeKey);
		}else {
			rtnJson.put("StorageID","0");
			rtnJson.put("DomainID","0");
			rtnJson.put("ServiceType",serviceType);
			rtnJson.put("LastSeq","0");
			rtnJson.put("FilePath",RedisDataUtil.getBaseConfig("BackStorage") + serviceType + "/");
			rtnJson.put("InlinePath",RedisDataUtil.getBaseConfig("BackStorage") + serviceType + "/Inline/");
			rtnJson.put("IsActive","X");
			rtnJson.put("Description","");
			rtnJson.put("RegistDate","");
			rtnJson.put("Reserved1","");
			rtnJson.put("Reserved2","");
			rtnJson.put("Reserved3","");
			rtnJson.put("Reserved4","");
			rtnJson.put("Reserved5","");
			Exception ex = new Exception("Storage info not found. ( ServiceType : " + serviceType + " , " + domainCode + " )");
			//LOGGER.error("FileUtil", ex);
			LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.FileUtil.getStorageInfo", "Error");
			//throw ex;
		}
		
		return rtnJson;
	}
	
	/**
	 * Get StorageInfo By StorageID
	 * @param storageID
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getStorageInfo(String storageID) throws Exception{
		if(STORAGE_INFO_BY_ID.isEmpty()) {
			setStorageInfo();
		}
		
		CoviMap rtnJson = new CoviMap();
		
		if(STORAGE_INFO_BY_ID.has(storageID)) {
			rtnJson = (CoviMap)(STORAGE_INFO_BY_ID.get(storageID));
		}else {
			rtnJson.put("StorageID","0");
			rtnJson.put("DomainID","0");
			rtnJson.put("ServiceType","");
			rtnJson.put("LastSeq","0");
			rtnJson.put("FilePath",RedisDataUtil.getBaseConfig("BackStorage") + "NONE" + "/");
			rtnJson.put("InlinePath",RedisDataUtil.getBaseConfig("BackStorage") + "NONE" + "/Inline/");
			rtnJson.put("IsActive","X");
			rtnJson.put("Description","");
			rtnJson.put("RegistDate","");
			rtnJson.put("Reserved1","");
			rtnJson.put("Reserved2","");
			rtnJson.put("Reserved3","");
			rtnJson.put("Reserved4","");
			rtnJson.put("Reserved5","");
			Exception ex = new Exception("Storage info not found. ( StorageID : " + storageID + " )");
			//LOGGER.error("FileUtil", ex);
			LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.FileUtil.getStorageInfo", "Error");
			//throw ex;
		}
		
		return rtnJson;
	}
		
	/**
	 * fileinfo(CoviList) 의 FileID 기준 storage,company 정보 조회
	 * @param fileInfos
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getFileStorageInfo(CoviList fileInfos) throws Exception {
		CoviMap rtnJSON = new CoviMap();
		CoviList addInfo = new CoviList();
		String strFileIDs = "";
		
		if(fileInfos != null && fileInfos.size() > 0) {
			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileinfo = fileInfos.getJSONObject(i);
				if(!fileinfo.optString("FileID").equals("")) strFileIDs += fileinfo.optString("FileID") + ",";
			}
			if(strFileIDs != null && !strFileIDs.equals("")) {
				CoviMap params = new CoviMap();
				strFileIDs = strFileIDs.substring(0,strFileIDs.length()-1);
				params.put("fileIDs", strFileIDs.split(","));
				
				addInfo = StaticContextAccessor.getBean(FileUtilService.class).selectFileStorageInfo(params);
				
				for (int i = 0; i < addInfo.size(); i++) {
					CoviMap addInfoJson = addInfo.getJSONObject(i);
					rtnJSON.put(addInfoJson.optString("FileID"),addInfoJson);
				}
			}
		}
		
		return rtnJSON;
	}
	
	/**
	 * fileID(String) 의 FileID 기준 storage,company 정보 조회
	 * 구분자(,) 로 여러개 조회 가능
	 * return.get("fileid") = storageinfo
	 * @param fileInfos
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getFileStorageInfo(String fileID) throws Exception {
		CoviMap rtnJSON = new CoviMap();
		CoviList addInfo = new CoviList();
		
		if(StringUtils.isNotBlank(fileID)) {
			if(fileID.split(",").length > 0) {
				CoviMap params = new CoviMap();
				params.put("fileIDs", fileID.split(","));
				
				addInfo = StaticContextAccessor.getBean(FileUtilService.class).selectFileStorageInfo(params);
				
				for (int i = 0; i < addInfo.size(); i++) {
					CoviMap addInfoJson = addInfo.getJSONObject(i);
					rtnJSON.put(addInfoJson.optString("FileID"),addInfoJson);
				}
			}
		}
		
		return rtnJSON;
	}
	
	public static boolean isFileInMultipartFile(String fileName, String fileSize, List<MultipartFile> mf){
		boolean isFile = false;
		for (int i = 0; i < mf.size(); i++) {
			if(fileName.equalsIgnoreCase(mf.get(i).getOriginalFilename())&&
					fileSize.equalsIgnoreCase(String.valueOf(mf.get(i).getSize()))){
				isFile = true;
			}
		}
		
		return isFile;
	}
	
	public static boolean isFileInFileVO(String fileName, String fileSize, List<FileVO> fileList){
		boolean isFile = false;
		
		for (int i = 0; i < fileList.size(); i++) {
			if(fileName.equalsIgnoreCase(fileList.get(i).getFileName())&&
					fileSize.equalsIgnoreCase(fileList.get(i).getSize())){
				isFile = true;
			}
		}
		
		return isFile;
	}
	
	/**
	 * @param mf MultipartFile
	 * @description EnableFileExtention(기초설정)에 설정된 확장자의 파일인지 확인
	 * @return
	 * @throws Exception 
	 */
	public static boolean isEnableExtention(List<MultipartFile> mf) throws Exception{
		//File f = null;
		//FileOutputStream fos = null;
		boolean enableFlag = true;
		
		try {
			String mimeType = "";
			String contentType = "";
			String ENABLE_FILE_EXTENTION = RedisDataUtil.getBaseConfig("EnableFileExtention");

			for (int i = 0; i < mf.size(); i++) {
				MultipartFile file = mf.get(i);
				List<String> extCheckList = Arrays.asList(ENABLE_FILE_EXTENTION.split(","));
				String extName = FilenameUtils.getExtension(file.getOriginalFilename()).toLowerCase();
				
				/*f = new File(FRONT_PATH, file.getOriginalFilename());
				if(f.createNewFile()) {
					LOGGER.info("file : " + f.toString() + " createNewFile();");
				}
				
				fos = new FileOutputStream(f);     
				fos.write(file.getBytes()); */
				if(awsS3.getS3Active()){
					mimeType = file.getContentType();
				}else {
					mimeType = new Tika().detect(file.getInputStream());
					if(mimeType.indexOf(";") > -1){
						mimeType = mimeType.substring(0,mimeType.indexOf(";") );
					}
				}
				contentType = file.getContentType();
				if(extCheckList.contains(extName) && isPermittedMimeType(mimeType)){
					continue;
				} else {
					LOGGER.warn("[isEnableExtention false] fileName=" + file.getOriginalFilename() + ", mimeType=" + mimeType + ", contentType=" + contentType);
					
					enableFlag = false;
					break;
				}
			}
		} catch(NullPointerException e){	
			LoggerHelper.errorLogger(e, "egovframework.coviframework.util.isValidToken", "Error");
			throw e; 
		}catch(Exception ex) {
			LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.isValidToken", "Error");
			throw ex; 
		}/*finally {
			if( fos != null )	fos.close();
			if( f != null && f.exists() )	{
				if(f.delete()) {
					LOGGER.info("file : " + f.toString() + " delete();");
				}
			}
		}*/
		
		return enableFlag;
	}
	
	private static boolean isPermittedMimeType(String mimeType) {
		String[] validMimeTypes = RedisDataUtil.getBaseConfig("EnableFileMime").split(",");
		boolean returnValue = false;

		for (String validMimeType : validMimeTypes) {
			if (validMimeType.equalsIgnoreCase(mimeType)) {
				return true;
			}
		}
		return returnValue;
	}

	// banner 등 storageinfo 안쓰는 곳에서 사용
	@SuppressWarnings("resource")
	public static MultipartFile makeMockMultipartFile(String servicePath, String filePath, String fileName, String savedName) throws Exception{
		MultipartFile result = null;
		String companyCode = SessionHelper.getSession("DN_Code");
		String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		InputStream is = null;
		try {
			String contentType = "text/plain";
//			byte[] content;
			if(awsS3.getS3Active()){
				String s3key = backServicePath + filePath + savedName;
				AwsS3Data data = awsS3.downData(s3key);
				is = data.getContentStream();
			}else{
				Path path = Paths.get(backServicePath + filePath + savedName);
				//content = Files.readAllBytes(path);
				is = new BufferedInputStream(new FileInputStream(path.toFile()));
			}
			result = new MockMultipartFile(fileName, fileName, contentType, is);
		} catch(NullPointerException e){	
			throw e;
		} catch (Exception e) {
			throw e;
		}
		return result;
	}

	@SuppressWarnings("resource")
	public static MultipartFile makeMockMultipartFile(CoviMap fileStorageInfo, String fileName) throws Exception{
		MultipartFile result = null;
		//String companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileStorageInfo.optString("CompanyCode");
		String companyCode = fileStorageInfo.optString("CompanyCode"); // companycode 없는경우 있음(기존데이터 오류방지)
		//String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");

		InputStream is = null;
		try {
			String contentType = "text/plain";
//			byte[] content;
			if(awsS3.getS3Active()){
				String s3key = backServicePath;
				AwsS3Data awsS3Data = awsS3.downData(s3key);
				is = awsS3Data.getContentStream();
			}else{
				Path path = Paths.get(backServicePath);
				//content = Files.readAllBytes(path);
				is = new BufferedInputStream(new FileInputStream(path.toFile()));
			}
			//result = new MockMultipartFile(fileName, fileName, contentType, content);
			result = new MockMultipartFile(fileName, fileName, contentType, is);
		} catch(NullPointerException e){	
			throw e;
		} catch (Exception e) {
			throw e;
		}
		
		return result;
	}
	
	//FRONT_PATH에 있는 파일 (ex. Webhard)
	@SuppressWarnings("resource")
	public static MultipartFile makeMockMultipartFrontFile(String fileName, String savedName) throws Exception{
		MultipartFile result = null;
		InputStream is = null;
		try {
			String contentType = "text/plain";
//			byte[] content;
			if(awsS3.getS3Active()){
				String FrontPath = getFrontPath();
				if(FrontPath.endsWith("/")){
					FrontPath = FrontPath.substring(0,FrontPath.length()-1);
				}
				String key = FrontPath  + File.separator  + SessionHelper.getSession("DN_Code") + File.separator + savedName;
				AwsS3Data data = awsS3.downData(key);
				is = data.getContentStream();
			}else{
				Path path = Paths.get(getFrontPath()  + File.separator  + SessionHelper.getSession("DN_Code") + File.separator + savedName);
				//content = Files.readAllBytes(path);
				is = new BufferedInputStream(new FileInputStream(path.toFile()));
			}
			result = new MockMultipartFile(fileName, fileName, contentType, is);

		} catch(NullPointerException e){	
			throw e;
		} catch (Exception e) {
			throw e;
		}
		return result;
	}

	@SuppressWarnings("resource")
	public static MultipartFile makeMockMultipartFile(String fullPath, String fileName) throws Exception{
		MultipartFile result = null;
		InputStream is = null;
		try {
			String contentType = "text/plain";
//			byte[] content;
			if(awsS3.getS3Active()){
				AwsS3Data awsS3Data = awsS3.downData(fullPath);
				is = awsS3Data.getContentStream();
			}else {
				Path path = Paths.get(fullPath);
				is = new BufferedInputStream(new FileInputStream(path.toFile()));
			}
			
			result = new MockMultipartFile(fileName, fileName, contentType, is);
			
		} catch(NullPointerException e){	
			throw e;
		} catch (Exception e) {
			throw e;
		}
		
		return result;
	}
	
	
	/********************************************************************************************************************************
	 * 기존 소스 그룹웨어 개발 후 새로운 함수로 대체한 후 폐기 할 것
	 * => 전자결재에서 사용하고 있으므로 폐기하면 안됨
	 * => 전자결재 파일컨트롤 FileUtilServiceImpl 사용하도록 변경하고, 미사용함수 삭제완료 아래는 모두 사용하는 함수들
	 * ******************************************************************************************************************************/
    /**
     * 첨부파일 배열 내 Token 추가
     * @param fileArray 첨부파일 배열
     * @return fileArray Token 추가된 첨부파일 배열
     * @throws Exception
     */
    public static CoviList getFileTokenArray(CoviList fileArray) throws Exception{
    	AES aes = new AES(AES_KEY, "N");

    	String userCode = SessionHelper.getSession("UR_Code");
    	
    	for(Object obj : fileArray) {
			CoviMap fileObj = (CoviMap)obj;
			
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss"); //GMT+0 기준
			String decFileToken = String.format("%s|%s|%s", fileObj.getString("FileID"), userCode, nowTime);
			
			fileObj.put("FileToken", aes.encrypt(decFileToken));
		}
    	
    	return fileArray;
    }
    
    /**
     * 첨부파일 List 내 Token 추가
     * @param fileList 첨부파일 배열
     * @return fileArray Token 추가된 첨부파일 배열
     * @throws Exception
     */
    public static List<Map<String, String>> getFileTokenList(List<Map<String, String>> fileList) throws Exception{
    	AES aes = new AES(AES_KEY, "N");

    	String userCode = SessionHelper.getSession("UR_Code");
    	
    	for(Object obj : fileList) {
    		Map<String, String> fileObj = (Map<String, String>)obj;
			
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss"); //GMT+0 기준
			String decFileToken = String.format("%s|%s|%s", fileObj.get("FileID"), userCode, nowTime);
			
			fileObj.put("FileToken", aes.encrypt(decFileToken));
		}
    	
    	return fileList;
    }
    
    
    /**
     * FileID|UserCode|Token 생성시간 형식의 Token 유효성 검사
     * @param fileID
     * @param fileToken
     * @param userCode
     * @param checkTime 토근 생성시간 체크 여부 <br>
     * <ul>
     * 	<li>true: 생성 시간으로 부터 2시간이 지나면 유효하지 않은 것으로 판단</li>
     *	<li>false: 생성 시간 체크하지 않음</li>
     * </ul>
     * @return isValid<br>
     * <ul>
     * 	<li>true: 유효한 Token</li>
     *	<li>false: 유효하지 않은 Token</li>
     * </ul>
     * @throws Exception
     */
    public static boolean isValidToken(String fileID, String fileToken, String userCode, boolean checkTime) throws Exception {
    	boolean isValid = false;
    	
    	try {
    		
    		if(!fileID.isEmpty() && !fileToken.isEmpty() ) {
        		AES aes = new AES(AES_KEY, "N");
        		
        		String decFileMToken = aes.decrypt(fileToken);
        		String[] splitFileMToken = decFileMToken.split("[|]");
        		
        		if(splitFileMToken.length == 3) {
        			if(splitFileMToken[0].equals(fileID) && splitFileMToken[1].equals(userCode)) {
        				if(checkTime) {
        					String nowTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss", 0, "00:00:00"); //GMT+0 기준
            				
            				Date nowDate =  DateHelper.strToDate(nowTime, "yyyy-MM-dd HH:mm:ss");
            				Date createDate =  DateHelper.strToDate(splitFileMToken[2], "yyyy-MM-dd HH:mm:ss");
            				
            				int diffMinute = DateHelper.diffMinute(nowDate, createDate);
            				
            				if(diffMinute <= 120) {
            					isValid = true;
            				}
        				}else {
        					isValid = true;
        				}
        			}
        		}
        	}
    		
		} catch(NullPointerException e){	
    		LoggerHelper.errorLogger(e, "egovframework.coviframework.util.isValidToken", "Error");
    		isValid = false;
    	}catch(Exception ex) {
    		LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.isValidToken", "Error");
    		isValid = false;
    	}
    	
    	return isValid;
    	
    }
    
    //file 읽어서 리터하기
    public static String getFileContents(String filePath)  {
		String lineSeparator = System.getProperty("line.separator");
		BufferedReader br = null;
		StringBuffer result = new StringBuffer("");
		
		try {
			File file = new File(filePath);
			
			if(filePath.isEmpty() || !file.exists() ){
				return "";
			}
			
			br = new BufferedReader(new InputStreamReader(new FileInputStream(filePath), "UTF8"));
			
			StringBuilder builder = new StringBuilder();
			String sCurrentLine;
			
			while ((sCurrentLine = br.readLine()) != null) {
				builder.append(sCurrentLine + lineSeparator);
			}
			String text = builder.toString();
			Pattern p = Pattern.compile("<spring:message[^>]*code=[\"']?([^>\"']+)[\"']?[^>]*(/>|></spring>|></spring:message>)");
			Matcher m = p.matcher(text);
			
			result = new StringBuffer(text.length());
			while(m.find()){
				String key = m.group(1).replace("Cache.", "");
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, DicHelper.getDic(key));
			}
			m.appendTail(result);
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}finally {
			if(br != null)
				try {
					br.close();
				} catch (IOException e) {
					LOGGER.error(e);
				}
		}
		return result.toString();
		
		
    }
    
    public static String getDisposition(String filename, HttpServletRequest request) throws Exception {
		return getDisposition(filename, getBrowser(request));
	}
	
	public static String getDisposition(String filename, String browser) throws Exception {
		String dispositionPrefix = "attachment; filename=";
		String encodedFilename = null;
		if (browser.equals("MSIE")) {
			encodedFilename = URLEncoder.encode(filename, CHARSET).replaceAll("\\+", "%20");
		} else if (browser.equals("Firefox")) {
			encodedFilename ="\"" + new String(filename.getBytes(CHARSET), "8859_1") + "\"";
		} else if (browser.equals("Opera")) {
			encodedFilename ="\"" + new String(filename.getBytes(CHARSET), "8859_1") + "\"";
		} else if (browser.equals("iPhone")){
			encodedFilename ="\"" + new String(filename.getBytes(CHARSET), "8859_1") + "\"";
		} else if (browser.equals("Chrome")) {
			StringBuffer sb = new StringBuffer();
			for (int i = 0; i < filename.length(); i++) {
				char c = filename.charAt(i);
				if (c > '~') {
					sb.append(URLEncoder.encode("" + c, CHARSET));
				} else {
					sb.append(c);
				}
			}
			encodedFilename = "\"" + sb.toString()+ "\"";
		} else {
			throw new RuntimeException("Not supported browser");
		}

		return dispositionPrefix + encodedFilename;
	}

	public static String getBrowser(HttpServletRequest request) {
        String header = request.getHeader("User-Agent");
        if (header.indexOf("Trident") > -1) {
        	return "MSIE";
        } else if (header.indexOf("Chrome") > -1) {
        	return "Chrome";
        } else if (header.indexOf("Opera") > -1) {
        	return "Opera";
        } else if (header.indexOf("iPhone") > -1 && header.indexOf("Mobile") > -1) {
        	return "iPhone";
        } else if (header.indexOf("Android") > -1 && header.indexOf("Mobile") > -1) {
        	return "Android";
        }

        return "Firefox";
    }
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(tmp.delete()) {
	        		LOGGER.info("file : " + tmp.toString() + " delete();");
	        	}
	        }
	        
	        throw ioE;
	    }
	}
	
	//CSV 데이터 추출
	public List<List<String>> cvsReaderArray(CoviMap params, int headerCnt) throws Exception {
		
		//반환용 리스트
	    List<List<String>> ret = new ArrayList<List<String>>();
	    BufferedReader br = null;
	    
	    MultipartFile mFile = (MultipartFile) params.get("uploadfile");
	    File file = prepareAttachment(mFile);	// 임시파일 생성
	    
	    try{			
			ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
			
	    	br = Files.newBufferedReader(Paths.get(file.getPath()));
	        //Charset.forName("UTF-8");
	        String line = "";
	        
	        int lineNum = 0;
	        while((line = br.readLine()) != null){	  
	        	// 스타트 라인까지 스킵!
	        	if (headerCnt <= lineNum) {	        	
		            //CSV 1행을 저장하는 리스트
		            List<String> tmpList = new ArrayList<String>();
		            String array[] = line.split(",");
		            //배열에서 리스트 반환
		            tmpList = Arrays.asList(array);
		            //System.out.println(tmpList);
		            ret.add(tmpList);
		        }
	            lineNum++;
	        }
	    }catch(FileNotFoundException e){
	        LOGGER.error(e.getLocalizedMessage(), e);
	    }catch(IOException e){
	        LOGGER.error(e.getLocalizedMessage(), e);
	    }finally{
	    	if (file != null) {
				if(file.delete()) {
					LOGGER.info("file : " + file.toString() + " delete();");
				}
			}
	    	
	        try{
	            if(br != null){
	                br.close();
	            }
	        }catch(IOException e){
	            LOGGER.error(e.getLocalizedMessage(), e);
	        }
	    }
	    
	    return ret;
	}
	/**
     * eml 첨부파일 배열 내 Token 추가
     * @param fileArray 첨부파일 배열
     * @return fileArray Token 추가된 첨부파일 배열
     * @throws Exception
     */
    public static CoviList getEmlFileTokenArray(CoviList fileArray) throws Exception{
    	AES aes = new AES(AES_KEY, "N");

    	String userCode = SessionHelper.getSession("UR_Code");
    	
    	for(Object obj : fileArray) {
			CoviMap fileObj = (CoviMap)obj;
			
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss"); //GMT+0 기준
			String decFileToken = String.format("%s|%s|%s|%s", fileObj.getString("att_uid"), fileObj.getString("att_index"), userCode, nowTime);
			
			fileObj.put("FileToken", aes.encrypt(decFileToken));
		}
    	
    	return fileArray;
    }
    
    /**
     * eml 첨부파일 List 내 Token 추가
     * @param fileList 첨부파일 배열
     * @return fileArray Token 추가된 첨부파일 배열
     * @throws Exception
     */
    public static List<Map<String, String>> getEmlFileTokenList(List<Map<String, String>> fileList) throws Exception{
    	AES aes = new AES(AES_KEY, "N");

    	String userCode = SessionHelper.getSession("UR_Code");
    	
    	for(Object obj : fileList) {
    		Map<String, String> fileObj = (Map<String, String>)obj;
			
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss"); //GMT+0 기준
			String decFileToken = String.format("%s|%s|%s|%s", fileObj.get("att_uid"), fileObj.get("att_index"), userCode, nowTime);
			
			fileObj.put("FileToken", aes.encrypt(decFileToken));
		}
    	
    	return fileList;
    }	
    /**
     * fileID|fileIndex|UserCode|Token 생성시간 형식의 Token 유효성 검사
     * @param fileID
     * @param fileIndex
     * @param fileToken
     * @param userCode
     * @param checkTime 토근 생성시간 체크 여부 <br>
     * <ul>
     * 	<li>true: 생성 시간으로 부터 2시간이 지나면 유효하지 않은 것으로 판단</li>
     *	<li>false: 생성 시간 체크하지 않음</li>
     * </ul>
     * @return isValid<br>
     * <ul>
     * 	<li>true: 유효한 Token</li>
     *	<li>false: 유효하지 않은 Token</li>
     * </ul>
     * @throws Exception
     */
    public static boolean isValidEmlToken(String fileID,String fileIndex, String fileToken, String userCode, boolean checkTime) throws Exception {
    	boolean isValid = false;
    	
    	try {
    		
    		if(!fileID.isEmpty() && !fileToken.isEmpty() ) {
        		AES aes = new AES(AES_KEY, "N");
        		
        		String decFileMToken = aes.decrypt(fileToken);
        		String[] splitFileMToken = decFileMToken.split("[|]");
        		
        		if(splitFileMToken.length == 4) {
        			if(splitFileMToken[0].equals(fileID) && splitFileMToken[1].equals(fileIndex) && splitFileMToken[2].equals(userCode)) {
        				if(checkTime) {
        					String nowTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss", 0, "00:00:00"); //GMT+0 기준
            				
            				Date nowDate =  DateHelper.strToDate(nowTime, "yyyy-MM-dd HH:mm:ss");
            				Date createDate =  DateHelper.strToDate(splitFileMToken[3], "yyyy-MM-dd HH:mm:ss");
            				
            				int diffMinute = DateHelper.diffMinute(nowDate, createDate);
            				
            				if(diffMinute <= 120) {
            					isValid = true;
            				}
        				}else {
        					isValid = true;
        				}
        			}
        		}
        	}
    		
		} catch(NullPointerException e){	
    		LoggerHelper.errorLogger(e, "egovframework.coviframework.util.isValidEmlToken", "Error");
    		isValid = false;
    	}catch(Exception ex) {
    		LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.isValidEmlToken", "Error");
    		isValid = false;
    	}
    	
    	return isValid;
    }

	public static File multipartToFile(MultipartFile mfile) throws  IOException{
		File file = new File(mfile.getOriginalFilename());
		if(!file.createNewFile()) {
			LOGGER.debug("Failed to make file.");
		}
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(file);
			fos.write(mfile.getBytes());
		} finally {
			if(fos != null) {
				fos.close();
			}
		}
		return file;
	}

	public static File multipartToFile(MultipartFile mfile, String fname) throws  IOException{
		File file = new File(fname);
		if(!file.createNewFile()) {
			LOGGER.debug("Failed to make file.");
		}
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(file);
			fos.write(mfile.getBytes());
		} finally {
			if(fos != null) {
				fos.close();
			}
		}

		return file;
	}

	public static File multipartToFileV2(MultipartFile mfile) throws IllegalStateException, IOException {
		File file = new File(mfile.getOriginalFilename());
		mfile.transferTo(file);
		return file;
	}

	public static File multipartToFileV2(MultipartFile mfile, String fname) throws IllegalStateException, IOException {
		File file = new File(fname);
		mfile.transferTo(file);
		return file;
	}

	public static byte[] fileToByteArray(File file) throws IOException {
		byte[] buffer = new byte[(int) file.length()];
		InputStream ios = null;
		try {
			ios = new FileInputStream(file);
			if (ios.read(buffer) == -1) {
				throw new IOException(
						"EOF reached while trying to read the whole file");
			}
		} finally {
			try {
				if (ios != null)
					ios.close();
			} catch (IOException e) {
				LOGGER.error(e);
			}
		}
		return buffer;
	}

	public static InputStream bufferdImage_to_InputStream(BufferedImage bfdImg, String ext) throws IOException{
		ByteArrayOutputStream os = new ByteArrayOutputStream();
	 	ImageIO.write(bfdImg, ext, os);                          // Passing: ​(RenderedImage im, String formatName, OutputStream output)
		return new ByteArrayInputStream(os.toByteArray());
	}
	
	public static String checkTraversalCharacter(String filePath) {
		if(filePath != null) {
			// .. -> Error
			String[] checkChar = {
					"../"
					, "..\\"};
			
			for(String chk : checkChar) {
				if(filePath.indexOf(chk) > -1) {
					throw new Error("RELATIVE_PATH_TRAVERSAL ERROR");
				}
			}
		}
		return filePath;
	}
	
	// 폴더 용량 확인
    public static long getFolderSizeNio(String folderPath) throws Exception {
    	//long time1 = System.currentTimeMillis ();
    	//File directory = new File(folderPath);
    	//long size = FileUtils.sizeOfDirectory(directory); //성능안좋음
        final AtomicLong size = new AtomicLong(0);
        Path path = Paths.get(folderPath);
        try {
            Files.walkFileTree(path, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {

                    size.addAndGet(attrs.size());
                    return FileVisitResult.CONTINUE;
                }
            });
		} catch(NullPointerException e){	
        	LoggerHelper.errorLogger(e, "egovframework.coviframework.util.FileUtil.getFolderSizeNio", "Error");
            throw e;
        } catch (IOException e) {
        	LoggerHelper.errorLogger(e, "egovframework.coviframework.util.FileUtil.getFolderSizeNio", "Error");
            throw e;
        }
        //long time2 = System.currentTimeMillis ();
        //System.out.println(( time2 - time1 ) / 1000.0);
        return size.get();
    }
    
    // 해당 폴더의 root 디스크 용량 확인
    public static CoviMap getDiskSize(String folderPath) throws Exception {
    	CoviMap rtnJson = new CoviMap();
    	File directory = new File(folderPath);
    	Path path = Paths.get(folderPath);
        
    	String diskName = "";
    	String dirPath = "";
    	long totalSize = 0;
    	long usableSize = 0;
    	long freeSize = 0;
        try {
        	if(directory.exists() && directory.isDirectory()) {
	        	diskName = path.getRoot().toString();
	        	dirPath = directory.getAbsolutePath();
	        	totalSize = directory.getTotalSpace();
	        	usableSize = directory.getUsableSpace();
	        	freeSize = directory.getFreeSpace(); // getUsableSpace 과 같음
        	}
		} catch(NullPointerException e){	
        	LoggerHelper.errorLogger(e, "egovframework.coviframework.util.FileUtil.getStorageInfo", "Error");
        } catch (Exception e) {
        	LoggerHelper.errorLogger(e, "egovframework.coviframework.util.FileUtil.getStorageInfo", "Error");
        	//throw e;
        }finally {
        	rtnJson.put("diskName",diskName);
        	rtnJson.put("dirPath",dirPath);
        	rtnJson.put("totalSize",totalSize);
        	rtnJson.put("usableSize",usableSize);
        	rtnJson.put("freeSize",freeSize); 
        }
        return rtnJson;
    }

    public static CoviMap makeSynapDownParamenter(HttpServletRequest request) throws Exception {
    	
		String returnURL = RedisDataUtil.getBaseConfig("MobileDocConverterServer");

		String fileID = StringUtil.replaceNull(request.getParameter("fileID"),"");
		String fileToken = request.getParameter("fileToken");
		String filePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() +RedisDataUtil.getBaseConfig("FilePreviewDownURL")
				+"?fileID=" + fileID + "&fileToken=" + URLEncoder.encode(fileToken,"UTF-8") + "&userCode=" + SessionHelper.getSession("USERID") ;

		//메일 첨부파일 다운로드 예외처리
		String sysType = request.getParameter("sysType");
		if("Mail".equalsIgnoreCase(sysType)) {
			filePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() +"/mail/userMail/mailAttDown.do"
			+"?fileID=" + fileID + "&fileToken=" + URLEncoder.encode(fileToken,"UTF-8") + "&userCode=" + SessionHelper.getSession("USERID") ;
			filePath += "&" + "inputReadIndex=" + fileID.split("@@")[1];
			filePath += "&" + "inputReadUid=" + fileID.split("@@")[0];
			filePath += "&" + "inputReadType=" + "SINGLE";
			filePath += "&" + "inputAttName=" + URLEncoder.encode(StringUtil.replaceNull(request.getParameter("inputAttName"), ""),"UTF-8");
			filePath += "&" + "inputUserMail=" + URLEncoder.encode(request.getParameter("inputUserMail"),"UTF-8");
			filePath += "&" + "inputReadMessageId=" + URLEncoder.encode(request.getParameter("inputReadMessageId"),"UTF-8");
			filePath += "&" + "inputMailBox=" + URLEncoder.encode(request.getParameter("inputMailBox"),"UTF-8");		
		}
		else if("MailAnnotation".equalsIgnoreCase(sysType)) {
			filePath += "&" + "inputReadIndex=" + StringUtil.replaceNull(request.getParameter("inputReadIndex"), "");
			filePath += "&" + "inputReadUid=" + URLEncoder.encode(request.getParameter("inputReadUid"),"UTF-8");
			filePath += "&" + "inputAttName=" + URLEncoder.encode(StringUtil.replaceNull(request.getParameter("inputAttName"), ""),"UTF-8");			
		}
		
		if(request.getParameter("is_annotation") != null) {
			filePath += "&" + "is_annotation=" + request.getParameter("is_annotation");	
		}
		
		String WaterMarkText = "";
		if ("Y".equals(RedisDataUtil.getBaseConfig("IsSetMobileWatermark"))){
			WaterMarkText = RedisDataUtil.getBaseConfig("MobileWatermarkText");   // 기초설정 MobileWatermarkText 값을 읽어온다.
		    if (WaterMarkText.indexOf("@@") > -1) {
		        WaterMarkText = WaterMarkText.split("@@")[1];
		        WaterMarkText = SessionHelper.getSession(WaterMarkText);   
		    }
		}
		
		CoviMap result = new CoviMap();
		result.put("fileID", fileID);
		result.put("filePath", filePath);
		result.put("WaterMarkText", WaterMarkText);
		result.put("returnURL", returnURL);
		return result;
    }
    
    
    
    
    
    
    /**
     * 첨부파일 등록(신규업로드) 후 서버 과정에서 오류발생하여 DB Rollback 되는 경우, 물리파일만 삭제한다.
     * @param fileInfos
     * @return
     * @throws Exception
     */
    public static boolean fileUploadRollBack(CoviList fileInfos) throws Exception{
    	Boolean returnBool = true;
    	try{
    		// Exception 발생한 경우 Rollback 이후라면 데이터 조회되지 않을수 있음.
    		String companyCode = SessionHelper.getSession("DN_Code");
    		FileUtilService fileUtilService = StaticContextAccessor.getBean(FileUtilService.class);
	    	for(Object Obj : fileInfos){
	    		CoviMap fileInfoObj = (CoviMap)Obj;
		    	
		    	CoviMap storageInfo = FileUtil.getStorageInfo(fileInfoObj.getString("StorageID"));
		    	
		    	String storagePath = storageInfo.optString("FilePath");
		    	String savedName = fileInfoObj.optString("SavedName");
		    	String filePath = fileInfoObj.optString("FilePath");
		    	String basePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storagePath.replace("{0}", companyCode);
		    	String savePath = basePath + filePath + savedName;
		    	
				fileUtilService.deleteFile(savePath);
				String ext = FilenameUtils.getExtension(savedName);
				if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
					fileUtilService.deleteFile(basePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
		        }
				
	    	}
		} catch(NullPointerException e){	
        	LoggerHelper.errorLogger(e, "egovframework.coviframework.util.FileUtil.getStorageInfo", "Error");
    	}catch(Exception e){
    		returnBool = false;
    		LOGGER.error("FileUtil", e);
    	}
    	
    	return returnBool;
    }
}
