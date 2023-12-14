package egovframework.coviframework.service.impl;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.color.CMMException;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.annotation.Resource;
import javax.imageio.IIOException;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.jcodec.api.FrameGrab;
import org.jcodec.api.JCodecException;
import org.jcodec.common.model.Picture;
import org.jcodec.scale.AWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.util.StreamUtils;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.servlet.FrameworkServlet;

import com.amazonaws.services.s3.model.ObjectMetadata;
import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.service.FileEncryptor;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.AsyncTaskFileDelete;
import egovframework.coviframework.util.AsyncTaskFileEncryptor;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.Utilcmyk;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.coviframework.vo.DRMIF;
import egovframework.coviframework.vo.FileVO;
import net.coobird.thumbnailator.Thumbnails;



/**
 * @Class Name : FileUtil.java
 * @Description : 파일 다운로드 및 업로드 메소드 제공
 * @Modification Information 
 * @ 2017.01.03 최초생성
 * @ 2017.08.21 수정
 * 
 * @author 코비젼 연구소
 * @since 2017.01.03
 * @version 1.0
 * Copyright (C) by Covision All right reserved.
 * 
 * 1. path 구조
 * ROOT_PATH + filePath(각 시스템별 고유한 저장경로가 있는 경우)
 * 
 * 2. Front, Back 처리 옵션화
 *    옵션 1. Back 사용
 *    옵션 2. Front, Back 사용
 * 
 * 3. File 이력 관리는 각 업무시스템에서 개별적으로 구현할 것.
 * 
 * 4. FileVO를 사용할 것.
 * 
 */
@Service("fileUtilService")
public class FileUtilServiceImpl extends EgovAbstractServiceImpl implements FileUtilService{

	private static final Logger LOGGER = LogManager.getLogger(FileUtilServiceImpl.class);
	private final String FRONT_DAY_PATH = "yyyyMMdd";
	private final String CURRENT_DAY_FORMAT = "yyyy/MM/dd";
	private final String CURRENT_TIME_FORMAT = "yyyyMMddhhmmssSSS";
	private final String FILE_SEPARATOR = "/";
	private final String CHARSET = "UTF-8";

	// DRM 설정값
	private final String IS_USE_DECODE_DRM = PropertiesUtil.getGlobalProperties().getProperty("drm.decode.mode");
	private final String IS_USE_ENCODE_DRM = PropertiesUtil.getGlobalProperties().getProperty("drm.encode.mode");
	private final String DRM_BEAN_NAME = PropertiesUtil.getGlobalProperties().getProperty("drm.beanName");

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Resource(name = "asyncTaskFileEncryptor")
	private AsyncTaskFileEncryptor asyncTaskFileEncryptor;

	@Resource(name = "asyncTaskFileDelete")
	private AsyncTaskFileDelete asyncTaskFileDelete;

	@Autowired
	ServletContext sc;

	@Override
	public String getCURRENT_TIME_FORMAT() throws Exception{
		return CURRENT_TIME_FORMAT;
	}

	@Override
	public String getFILE_SEPARATOR() throws Exception{
		return FILE_SEPARATOR;
	}

	@Override
	public String getCHARSET() throws Exception{
		return CHARSET;
	}

	@Override
	public String getIS_USE_DECODE_DRM() throws Exception{
		return IS_USE_DECODE_DRM;
	}

	@Override
	public String getIS_USE_ENCODE_DRM() throws Exception{
		return IS_USE_ENCODE_DRM;
	}

	AwsS3 awsS3 = AwsS3.getInstance();

	// servicePath 불필요(fileid 이용해서 storageinfo 조회함)
	@Override
	public CoviList uploadToFront(CoviList fileInfos, List<MultipartFile> mf, String servicePath) throws Exception{
		CoviList returnList = new CoviList();

		String companyCode = SessionHelper.getSession("DN_Code");
		String FrontPath = FileUtil.getFrontPath(companyCode);
		if(FrontPath.endsWith("/")){
			FrontPath = FrontPath.substring(0,FrontPath.length()-1);
		}
		String fullPath = FrontPath + FILE_SEPARATOR + companyCode;

		String frontAddPath = FILE_SEPARATOR + DateHelper.getCurrentDay(FRONT_DAY_PATH);
		if(!"".equals(servicePath)) {
			frontAddPath += FILE_SEPARATOR + servicePath;
		}
		fullPath += frontAddPath;

		if(!awsS3.getS3Active()) {
			File dir = new File(fullPath);

			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}
		/*
		 * loop 'fileInfos' compare 'mf'
		 * 
		 * 파일명과 파일 사이즈로 비교하여
		 * 파일명은 javascript단에서는 encodeURIComponent java단에서 decode 필요함.
		 * 
		 * 1. both -> transferTo
		 * 2. only fileInfos -> MockMultipartFile
		 * 3. only mf -> transferTo
		 * 
		 * 기존 파일은 ALL 삭제 처리
		 * 항상 신규파일로 재등록 처리
		 * 
		 * */

		List<MultipartFile> mockedFileList = new ArrayList<>();
		for (int i = 0; i < mf.size(); i++) {
			MultipartFile file = mf.get(i);
			mockedFileList.add(file);
		}

		if(fileInfos != null){
			CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfos); // 기존 파일의 storage정보조회 (fileid 필수)

			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileObj = fileInfos.getJSONObject(i);
				String decodedFileName = Normalizer.normalize(URLDecoder.decode(fileObj.getString("FileName"), CHARSET), Normalizer.Form.NFC);
				String fileType = fileObj.has("FileType")? fileObj.getString("FileType"): "normal"; //normal or webhard
				String fileSize = fileObj.getString("Size");
				String savedName = fileObj.getString("SavedName");
				String filePath = fileObj.getString("FilePath");
				String fileID = fileObj.optString("FileID");

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&&StringUtils.isNoneBlank(filePath)
						&&StringUtils.isNoneBlank(savedName)){
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					//mockedFileList.add(FileUtil.makeMockMultipartFile(servicePath, filePath, decodedFileName, savedName));
					mockedFileList.add(FileUtil.makeMockMultipartFile(fileStorageInfo, decodedFileName));
				}
			}
		}

		if (!mockedFileList.isEmpty()) {
			//String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);

			for (int i = 0; i < mockedFileList.size(); i++) {
				CoviMap frontObj = new CoviMap();
				// 파일 중복명 처리
				// 본래 파일명
				String originalfileName =  Normalizer.normalize(mockedFileList.get(i).getOriginalFilename(), Normalizer.Form.NFC);
				//String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);
				String genId = UUID.randomUUID().toString().replace("-", "");
				// 저장되는 파일 이름
				String ext = FilenameUtils.getExtension(originalfileName);
				String saveFileName = genId + "." + ext;
				String size = String.valueOf(mockedFileList.get(i).getSize());

				String fullFileNamePath = fullPath + FILE_SEPARATOR + saveFileName; // 저장 될 파일 경로
				fullFileNamePath = new String(fullFileNamePath.getBytes(StandardCharsets.UTF_8), CHARSET);
				File originFile = null;
				if(awsS3.getS3Active()){
					try(InputStream is = mockedFileList.get(i).getInputStream()){
						awsS3.upload(is, fullFileNamePath, mockedFileList.get(i).getContentType(), mockedFileList.get(i).getSize());
					}
					/*originFile = FileUtil.multipartToFile(mockedFileList.get(i));

					if(IS_USE_DECODE_DRM.equalsIgnoreCase("Y")){
						//TODO - DRM for AWS S3
					}*/
					ServletRequestAttributes requestAttr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();

					if(requestAttr != null) {
						HttpServletRequest request = requestAttr.getRequest();
						String requestURI = request.getRequestURI();
						if(requestURI.indexOf("mail/userMail/uploadToFront.do") < 0 && requestURI.indexOf("/api/mail/sendMail") < 0) {
							if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
								try(InputStream thumbIs = mockedFileList.get(i).getInputStream()){
									makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", thumbIs, ext); //썸네일 저장
								}
							}
						}
					}
				}else {
					//System.out.println("[AWS S3]uploadToFront-fullFileNamePath:"+fullFileNamePath);
					originFile = new File(fullFileNamePath);
					//				mockedFileList.get(i).transferTo(originFile); // 파일 저장
					transferTo(mockedFileList.get(i), originFile, ext);

					if(IS_USE_DECODE_DRM.equalsIgnoreCase("Y")){
						originFile = callDRMDecoding(originFile, fullFileNamePath);
					}

					ServletRequestAttributes requestAttr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();

					if(requestAttr != null) {
						HttpServletRequest request = requestAttr.getRequest();
						String requestURI = request.getRequestURI();
						if(requestURI.indexOf("mail/userMail/uploadToFront.do") < 0 && requestURI.indexOf("/api/mail/sendMail") < 0) {
							if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
								makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", originFile); //썸네일 저장
							}
						}
					}

				}

				frontObj.put("FileName", originalfileName);
				frontObj.put("SavedName", saveFileName);
				frontObj.put("Size", size);
				frontObj.put("FrontAddPath", frontAddPath);//Front 하위폴더 경로

				/*if(awsS3.getS3Active()) {
					originFile.delete();
				}*/
				returnList.add(frontObj);
			}
		}


		if(fileInfos != null){
			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileObj = fileInfos.getJSONObject(i);
				String fileType = fileObj.has("FileType")? fileObj.getString("FileType"): "normal"; //normal or webhard

				if(fileType.equalsIgnoreCase("webhard")) {
					CoviMap frontObj = new CoviMap();

					frontObj.put("FileName",  URLDecoder.decode(fileObj.getString("FileName"), CHARSET));
					frontObj.put("SavedName", fileObj.getString("SavedName"));
					frontObj.put("Size", fileObj.getString("Size"));

					returnList.add(i, frontObj);
				}
			}
		}

		return returnList;
	}

	// 미사용
	@Override
	public CoviList moveToBackFull(List<FileVO> fileList, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);		
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;

		File dir = new File(fullPath);

		if (!dir.exists()) {
			if(dir.mkdirs()) {
				LOGGER.info("path : " + dir + " mkdirs();");
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!fileList.isEmpty()) {
			//기존 파일 처리
			clearFile(servicePath, serviceType, objectID, objectType, messageID);

			for (int i = 0; i < fileList.size(); i++) {
				//0. 변수 처리
				//MultipartFile mf = fileList.get(i).getFile();
				String frontSavedName = fileList.get(i).getSavedName();
				String fileName = fileList.get(i).getFileName();
				String ext = FilenameUtils.getExtension(fileName);
				String savedName = "";

				//JSONObject fileObj = new CoviMap();
				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
				// 저장되는 파일 이름
				savedName = genId + "." + ext;

				//1. DB 처리
				String fileSize = fileList.get(i).getSize();
				String storageID = storageInfo.optString("StorageID");
				String version = fileList.get(i).getVersion();
				String saveType = FileUtil.returnSaveType(fileName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = currentDay + FILE_SEPARATOR;
				String thumbWidth = fileList.get(i).getThumbWidth();
				String thumbHeight = fileList.get(i).getThumbheight();
				String desc = fileList.get(i).getDescription();
				String register = Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); 
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
				String fileID = fileParam.get("FileID").toString();

				//2. File 처리
				String fullFrontFilePath = FileUtil.getFrontPath() + FILE_SEPARATOR + companyCode + FILE_SEPARATOR + frontSavedName;
				String fullBackPath = fullPath + FILE_SEPARATOR;
				// 한글명저장
				// fullFileNamePath = new String(fullFileNamePath.getBytes(), "UTF-8");
				// mf.transferTo(new File(fullFileNamePath)); // 파일 저장
				// transferTo(mf, new File(fullFileNamePath), ext);
				Path file = Paths.get(fullFrontFilePath);
				Path movePath = Paths.get(fullBackPath);
				Files.move(file , movePath.resolve(savedName));
				if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
					Path fileThumb = Paths.get(FileUtil.getFrontPath() + FILE_SEPARATOR + companyCode + FILE_SEPARATOR + FilenameUtils.getBaseName(frontSavedName) + "_thumb.jpg");
					if(fileThumb.toFile().exists()) {
						Files.move(fileThumb , movePath.resolve(genId + "_thumb.jpg"));
					}
				}
				returnList.add(CoviMap.fromObject(fileParam));
			}
		}

		return returnList;
	}

	@Override
	public CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
		return moveToBack(frontFileInfos, servicePath, serviceType, objectID, objectType, messageID, true);
	}

	@Override
	public CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;

		if(!awsS3.getS3Active()) {
			File dir = new File(fullPath);

			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!frontFileInfos.isEmpty()) {
			//기존 파일 처리
			if ( bDel == true){
				clearFile(servicePath, serviceType, objectID, objectType, messageID);
			}

			for (int i = 0; i < frontFileInfos.size(); i++) {
				//0. 변수 처리
				CoviMap frontFile = (CoviMap)frontFileInfos.get(i);
				String fileName = Normalizer.normalize(frontFile.optString("FileName"), Normalizer.Form.NFC);
				String frontSavedName = frontFile.optString("SavedName");
				String savedName = "";
				String fileSize = frontFile.optString("Size");
				String frontAddPath = frontFile.optString("FrontAddPath");
				String ext = FilenameUtils.getExtension(fileName);

				//JSONObject fileObj = new CoviMap();
				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
				// 저장되는 파일 이름
				savedName = genId + "." + ext;

				//1. DB 처리
				String storageID = storageInfo.optString("StorageID");
				String version = "0";
				String saveType = FileUtil.returnSaveType(fileName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = currentDay + FILE_SEPARATOR;
				String thumbWidth = "0";
				String thumbHeight = "0";
				String desc = "";
				String register = Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); // default 0 - 쓰지 않음
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
				String fileID = fileParam.get("FileID").toString();

				//2. File 처리
				String FrontPath = FileUtil.getFrontPath(companyCode);
				if(FrontPath.endsWith("/")){
					FrontPath = FrontPath.substring(0,FrontPath.length()-1);
				}

				String frontFolderPath = FrontPath + FILE_SEPARATOR + companyCode;
				frontFolderPath += frontAddPath;

				String fullFrontFilePath = frontFolderPath + FILE_SEPARATOR + frontSavedName;


				// [파일보안] 스토리지 저장시 AES 암호화
				String isUse = PropertiesUtil.getSecurityProperties().getProperty("file.encryptor.bean.use", "");
				if("Y".equals(isUse)) {
					final String strCompanyCode = companyCode;
					TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
						@Override
						public void afterCommit() {
							final CoviMap param = new CoviMap();
							try {
								param.put("FileID", fileID);
								param.put("FileName", fileParam.getString("FileName"));
								param.put("RegisterCode", fileParam.getString("RegisterCode"));

								asyncTaskFileEncryptor.encrypt(new File(fullFrontFilePath), strCompanyCode, fileParam);
							} catch(NullPointerException e){	
								LOGGER.error(e.getLocalizedMessage(), e);
							}catch(Exception e) {
								LOGGER.error(e.getLocalizedMessage(), e);
							}
						}
					});
				}

				String fullBackPath = fullPath + FILE_SEPARATOR;
				if(awsS3.getS3Active()) {
					awsS3.copy(fullFrontFilePath, fullBackPath+savedName);

					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						String thumkey = frontFolderPath + FILE_SEPARATOR + FilenameUtils.getBaseName(frontSavedName) + "_thumb.jpg";
						AwsS3Data s3data = awsS3.downData(fullFrontFilePath);
						makeThumb(thumkey, s3data.getContentStream(), ext); //썸네일 저장
						awsS3.copy(thumkey, fullBackPath+genId + "_thumb.jpg");
						awsS3.delete(thumkey);
					}
					awsS3.delete(fullFrontFilePath);
				}else{
					Path file = Paths.get(fullFrontFilePath);
					Path movePath = Paths.get(fullBackPath);
					Files.move(file , movePath.resolve(savedName));

					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						String frontImgPath = frontFolderPath+ FILE_SEPARATOR + FilenameUtils.getBaseName(frontSavedName) + "_thumb.jpg";
						Path fileThumb = Paths.get(frontImgPath);
						if(fileThumb.toFile().exists()) {
							Files.move(fileThumb , movePath.resolve(genId + "_thumb.jpg"));
						}
					}
				}

				returnList.add(CoviMap.fromObject(fileParam));
			}

		}

		return returnList;
	}

	// 미사용
	@Override
	public CoviList uploadToBackFull(List<FileVO> fileList, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;

		if(!awsS3.getS3Active(companyCode)) {
			File dir = new File(fullPath);

			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!fileList.isEmpty()) {
			//기존 파일 처리
			clearFile(servicePath, serviceType, objectID, objectType, messageID);

			for (int i = 0; i < fileList.size(); i++) {
				//0. 변수 처리
				MultipartFile mf = fileList.get(i).getFile();
				String fileName = "";
				String savedName = "";

				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				fileName = mf.getOriginalFilename();
				String ext = FilenameUtils.getExtension(fileName);
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
				// 저장되는 파일 이름
				savedName = genId + "." + ext;

				//1. DB 처리
				String fileSize = String.valueOf(mf.getSize());
				String storageID = storageInfo.optString("StorageID");
				String version = fileList.get(i).getVersion();
				String saveType = FileUtil.returnSaveType(fileName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = currentDay + FILE_SEPARATOR;
				String thumbWidth = fileList.get(i).getThumbWidth();
				String thumbHeight = fileList.get(i).getThumbheight();
				String desc = fileList.get(i).getDescription();
				String register = Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); 
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
				String fileID = fileParam.get("FileID").toString();

				//2. File 처리
				String fullFileNamePath = fullPath + FILE_SEPARATOR + savedName; // 저장 될 파일 경로
				// 한글명저장
				fullFileNamePath = new String(fullFileNamePath.getBytes(StandardCharsets.UTF_8), CHARSET);
				if(awsS3.getS3Active(companyCode)){
					try(InputStream is = mf.getInputStream()){
						awsS3.upload(is, fullFileNamePath, mf.getContentType(), mf.getSize());
						if (IS_USE_DECODE_DRM.equalsIgnoreCase("Y")) {
							//TODO - DRM
						}
					}
					if (ext.equalsIgnoreCase("jpg") || ext.equalsIgnoreCase("jpeg") || ext.equalsIgnoreCase("png") || ext.equalsIgnoreCase("gif") || ext.equalsIgnoreCase("bmp")) {
						try (InputStream thumbIs = mf.getInputStream()){
							makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", thumbIs, ext); //썸네일 저장
						}
					}
				}else {
					File originFile = new File(fullFileNamePath);

					//					mf.transferTo(originFile); // 파일 저장
					transferTo(mf, originFile, ext); // 파일 저장

					if (IS_USE_DECODE_DRM.equalsIgnoreCase("Y")) {
						originFile = callDRMDecoding(originFile, fullFileNamePath);
					}

					if (ext.equalsIgnoreCase("jpg") || ext.equalsIgnoreCase("jpeg") || ext.equalsIgnoreCase("png") || ext.equalsIgnoreCase("gif") || ext.equalsIgnoreCase("bmp")) {
						makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", originFile); //썸네일 저장
					}
				}
				returnList.add(CoviMap.fromObject(fileParam));
			}
		}

		return returnList;
	}

	//버전 parameter를 추가로 받는 메소드 통합 게시판 첨부 파일
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		String userId = Objects.toString(SessionHelper.getSession("USERID"),"");

		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		if(StringUtil.isNull(userId) && RequestContextHolder.getRequestAttributes() != null) {
			userId = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("USERID", RequestAttributes.SCOPE_REQUEST),"");
		}

		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;

		List<MultipartFile> mockedFileList = new ArrayList<>();
		if(!awsS3.getS3Active()) {
			File dir = new File(fullPath);

			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}

		for (int i = 0; i < mf.size(); i++) {
			MultipartFile file = mf.get(i);
			mockedFileList.add(file);
		}



		if(fileInfos != null){
			CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfos); // 기존 파일의 storage정보조회 (fileid 필수)

			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileObj = fileInfos.getJSONObject(i);
				String decodedFileName = Normalizer.normalize(URLDecoder.decode(fileObj.optString("FileName"), CHARSET), Normalizer.Form.NFC);
				//String fileType = fileObj.has("FileType")? fileObj.getString("FileType"): "normal";
				String fileType = fileObj.has("FileType")? fileObj.optString("FileType"): (fileObj.has("AttachType") ? fileObj.optString("AttachType") : "normal"); // 결재에서는 AttachType으로 사용
				String fileSize = fileObj.optString("Size");
				String savedName = fileObj.optString("SavedName");
				String filePath = fileObj.optString("FilePath");
				String fileID = fileObj.optString("FileID");

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&&StringUtils.isNoneBlank(filePath)
						&&StringUtils.isNoneBlank(savedName)){
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					//mockedFileList.add(FileUtil.makeMockMultipartFile(servicePath, filePath, decodedFileName, savedName));
					mockedFileList.add(FileUtil.makeMockMultipartFile(fileStorageInfo, decodedFileName));
				}

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&& fileType.equalsIgnoreCase("webhard") 
						&& StringUtils.isNoneBlank(savedName)) {

					mockedFileList.add(FileUtil.makeMockMultipartFrontFile(decodedFileName, savedName));
				}

				// 결재 edms첨부 처리
				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&& fileType.equalsIgnoreCase("edms") 
						&& StringUtils.isNoneBlank(savedName)) {
					CoviMap fileStorageInfo = FileUtil.getFileStorageInfo(fileObj.optString("OriginID"));
					mockedFileList.add(FileUtil.makeMockMultipartFile((CoviMap)fileStorageInfo.get(fileObj.optString("OriginID")), decodedFileName));
				}
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!mockedFileList.isEmpty()) {
			//기존 파일 처리
			clearFile(servicePath, serviceType, objectID, objectType, messageID, version);

			for (int i = 0; i < mockedFileList.size(); i++) {
				//0. 변수 처리
				String fileName = "";
				String savedName = "";

				//JSONObject fileObj = new CoviMap();
				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				fileName = Normalizer.normalize(mockedFileList.get(i).getOriginalFilename(), Normalizer.Form.NFC);
				String ext = FilenameUtils.getExtension(fileName);
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
				// 저장되는 파일 이름
				savedName = genId + "." + ext;

				//1. DB 처리
				String fileSize = String.valueOf(mockedFileList.get(i).getSize());
				String storageID = storageInfo.optString("StorageID");
				String saveType = FileUtil.returnSaveType(fileName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = currentDay + FILE_SEPARATOR;
				String thumbWidth = "0";
				String thumbHeight = "0";
				String desc = "";
				String register = userId; //Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); 
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
				String fileID = fileParam.get("FileID").toString();

				//2. File 처리
				String fullFileNamePath = fullPath + FILE_SEPARATOR + savedName; // 저장 될 파일 경로
				// 한글명저장
				fullFileNamePath = new String(fullFileNamePath.getBytes(StandardCharsets.UTF_8), CHARSET);
				File originFile = null;
				//System.out.println("#######fullFileNamePath:"+fullFileNamePath);
				if(awsS3.getS3Active()) {
					try(InputStream is = mockedFileList.get(i).getInputStream()){
						awsS3.upload(is, fullFileNamePath, mockedFileList.get(i).getContentType(), mockedFileList.get(i).getSize());
						//originFile = FileUtil.multipartToFile(mockedFileList.get(i));
					}

					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						try(InputStream thumbIs = mockedFileList.get(i).getInputStream()){
							makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", thumbIs, ext); //썸네일 저장
						}
					}
				}else{
					originFile = new File(fullFileNamePath);
					transferTo(mockedFileList.get(i), originFile, ext); // 파일 저장
					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", originFile); //썸네일 저장
					}

					// [파일보안] 스토리지 저장시 AES 암호화
					String isUse = PropertiesUtil.getSecurityProperties().getProperty("file.encryptor.bean.use", "");
					if("Y".equals(isUse)) {
						final String fCompanyCode = companyCode;
						final File fSourceFile = new File(fullFileNamePath);
						TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
							@Override
							public void afterCommit() {
								final CoviMap param = new CoviMap();
								try {
									param.put("FileID", fileID);
									param.put("FileName", fileParam.getString("FileName"));
									param.put("RegisterCode", fileParam.getString("RegisterCode"));
									asyncTaskFileEncryptor.encrypt(fSourceFile, fCompanyCode, param);
								} catch(NullPointerException e){	
									LOGGER.error(e.getLocalizedMessage(), e);
								}catch(Exception e) {
									LOGGER.error(e.getLocalizedMessage(), e);
								}
							}
						});
					}
				}
				if(IS_USE_DECODE_DRM.equalsIgnoreCase("Y")){
					if(awsS3.getS3Active()) {
						//TODO - DRM for AWS S3
					}else {
						originFile = callDRMDecoding(originFile, fullFileNamePath);
					}
				}

				/*if(awsS3.getS3Active()) {
					//originFile.delete();
				}*/
				returnList.add(CoviMap.fromObject(fileParam));
			}

		}

		return returnList;
	}

	@Override
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
		return uploadToBack(fileInfos, mf, servicePath, serviceType, objectID, objectType, messageID, true);
	}	

	@Override
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel) throws Exception{
		return uploadToBack(fileInfos, mf, servicePath, serviceType, objectID, objectType, messageID, bDel, true);
	}	

	@Override
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel, boolean bSubPath) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		String userId = Objects.toString(SessionHelper.getSession("USERID"),"");

		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		if (companyCode.equals("")) {
			companyCode = StringUtil.replaceNull(ThreadContext.get("EN_Code"),"");
		}
		if(StringUtil.isNull(userId) && RequestContextHolder.getRequestAttributes() != null) {
			userId = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("USERID", RequestAttributes.SCOPE_REQUEST),"");
		}

		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;
		if(!bSubPath) {
			fullPath = backServicePath;
			if(fullPath.endsWith("/")) fullPath = fullPath.substring(0,fullPath.length()-1);
		}

		if(!awsS3.getS3Active()) {
			File dir = new File(fullPath);

			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}

		List<MultipartFile> mockedFileList = new ArrayList<>();
		for (int i = 0; i < mf.size(); i++) {
			MultipartFile file = mf.get(i);
			mockedFileList.add(file);
		}

		if(fileInfos != null){
			CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfos); // 기존 파일의 storage정보조회 (fileid 필수)

			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileObj = fileInfos.getJSONObject(i);
				String decodedFileName = Normalizer.normalize(URLDecoder.decode(fileObj.optString("FileName"), CHARSET), Normalizer.Form.NFC);
				//String fileType = fileObj.has("FileType")? fileObj.getString("FileType"): "normal";
				String fileType = fileObj.has("FileType")? fileObj.optString("FileType"): (fileObj.has("AttachType") ? fileObj.optString("AttachType") : "normal"); // 결재에서는 AttachType으로 사용
				String fileSize = fileObj.optString("Size");
				String savedName = fileObj.optString("SavedName");
				String filePath = fileObj.optString("FilePath");
				String fileID = fileObj.optString("FileID");

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&&StringUtils.isNoneBlank(filePath)
						&&StringUtils.isNoneBlank(savedName)){
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					//mockedFileList.add(FileUtil.makeMockMultipartFile(servicePath, filePath, decodedFileName, savedName));
					mockedFileList.add(FileUtil.makeMockMultipartFile(fileStorageInfo, decodedFileName));
				}

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&& fileType.equalsIgnoreCase("webhard") 
						&& StringUtils.isNoneBlank(savedName)) {

					mockedFileList.add(FileUtil.makeMockMultipartFrontFile(decodedFileName, savedName));
				}

				// 결재 edms첨부 처리
				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&& fileType.equalsIgnoreCase("edms") 
						&& StringUtils.isNoneBlank(savedName)) {
					CoviMap fileStorageInfo = FileUtil.getFileStorageInfo(fileObj.optString("OriginID"));
					mockedFileList.add(FileUtil.makeMockMultipartFile((CoviMap)fileStorageInfo.get(fileObj.optString("OriginID")), decodedFileName));
				}
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!mockedFileList.isEmpty()) {
			//기존 파일 처리
			if ( bDel == true){
				clearFile(servicePath, serviceType, objectID, objectType, messageID);
			}

			for (int i = 0; i < mockedFileList.size(); i++) {
				//0. 변수 처리
				String fileName = ""; // sys_file 의 파일명 (다운로드시 사용)
				String originalFileName = ""; // Storage 에 저장할 파일명
				String savedName = "";

				//JSONObject fileObj = new CoviMap();
				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				originalFileName = Normalizer.normalize(mockedFileList.get(i).getOriginalFilename(), Normalizer.Form.NFC);
				fileName = mockedFileList.get(i).getName();
				if(mockedFileList.get(i) instanceof CommonsMultipartFile) {
					fileName = ((CommonsMultipartFile)mockedFileList.get(i)).getFileItem().getName();
				}
				if(fileName == null || StringUtil.isBlank(fileName)) {
					fileName = originalFileName;
				}
				String ext = FilenameUtils.getExtension(originalFileName);
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalFileName);
				// 저장되는 파일 이름
				savedName = genId + "." + ext;

				//1. DB 처리
				String fileSize = String.valueOf(mockedFileList.get(i).getSize());
				String storageID = storageInfo.optString("StorageID");
				String version = "0";
				String saveType = FileUtil.returnSaveType(savedName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = (bSubPath) ? (currentDay + FILE_SEPARATOR) : "";
				String thumbWidth = "0";
				String thumbHeight = "0";
				String desc = "";
				String register = userId; //Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); 
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);

				//2. File 처리
				String fullFileNamePath = fullPath + FILE_SEPARATOR + savedName; // 저장 될 파일 경로
				// 한글명저장
				fullFileNamePath = new String(fullFileNamePath.getBytes(StandardCharsets.UTF_8), CHARSET);
				File originFile = null;

				if(awsS3.getS3Active()) {
					try (InputStream is = mockedFileList.get(i).getInputStream();){
						awsS3.upload(is, fullFileNamePath, mockedFileList.get(i).getContentType(), mockedFileList.get(i).getSize());
						//originFile = FileUtil.multipartToFile(mockedFileList.get(i));
						if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
							try(InputStream thumbIs = mockedFileList.get(i).getInputStream()){
								makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", thumbIs, ext); //썸네일 저장
							}
						}
					}
				}else{
					originFile = new File(fullFileNamePath);
					transferTo(mockedFileList.get(i), originFile, ext); // 파일 저장
					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", originFile); //썸네일 저장
					}
					// [파일보안] 스토리지 저장시 AES 암호화
					String isUse = PropertiesUtil.getSecurityProperties().getProperty("file.encryptor.bean.use", "");
					if("Y".equals(isUse)) {
						final String fCompanyCode = companyCode;
						final File fOriginFile = originFile;
						TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
							@Override
							public void afterCommit() {
								final CoviMap param = new CoviMap();
								try {
									param.put("FileID", fileParam.getString("FileID"));
									param.put("FileName", fileParam.getString("FileName"));
									param.put("RegisterCode", fileParam.getString("RegisterCode"));
									asyncTaskFileEncryptor.encrypt(fOriginFile, fCompanyCode, param);
								} catch(NullPointerException e){	
									LOGGER.error(e.getLocalizedMessage(), e);
								}catch(Exception e) {
									LOGGER.error(e.getLocalizedMessage(), e);
								}
							}
						});
					}
				}

				if(IS_USE_DECODE_DRM.equalsIgnoreCase("Y")){
					if(awsS3.getS3Active()) {
						//TODO - DRM for AWS S3
					}else {
						originFile = callDRMDecoding(originFile, fullFileNamePath);
					}
				}


				/*if(awsS3.getS3Active()) {
					originFile.delete();
				}*/
				returnList.add(CoviMap.fromObject(fileParam));
			}

		}

		return returnList;
	}

	//문서이관, 복사, 개정 업로드 - 기존 파일은 새로운 경로로 Copy하고 새로 추가된 파일은 업로드 한다.
	@Override
	public CoviList moveToService(CoviList fileInfos, List<MultipartFile> mf, String orgPath, String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception{
		CoviList returnList = new CoviList();
		String companyCode = SessionHelper.getSession("DN_Code");
		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		String currentDay = DateHelper.getCurrentDay(CURRENT_DAY_FORMAT);
		String fullPath = backServicePath + currentDay;

		if(!awsS3.getS3Active()) {
			File dir = new File(fullPath);
			if (!dir.exists()) {
				if (dir.mkdirs()) {
					LOGGER.info("path : " + dir + " mkdirs();");
				}
			}
		}

		List<MultipartFile> mockedFileList = new ArrayList<>();
		for (int i = 0; i < mf.size(); i++) {
			MultipartFile file = mf.get(i);
			mockedFileList.add(file);
		}

		if(fileInfos != null){
			CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfos); // 기존 파일의 storage정보조회 (fileid 필수)

			for (int i = 0; i < fileInfos.size(); i++) {
				CoviMap fileObj = fileInfos.getJSONObject(i);
				String decodedFileName = Normalizer.normalize(URLDecoder.decode(fileObj.getString("FileName"), CHARSET), Normalizer.Form.NFC);
				String fileType = fileObj.has("FileType")? fileObj.getString("FileType"): "normal";
				String fileSize = fileObj.getString("Size");
				String savedName = fileObj.getString("SavedName");
				String filePath = fileObj.getString("FilePath");
				String fileID = fileObj.getString("FileID");

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&&StringUtils.isNoneBlank(filePath)
						&&StringUtils.isNoneBlank(savedName)){
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					//mockedFileList.add(FileUtil.makeMockMultipartFile(orgPath, filePath, decodedFileName, savedName));
					mockedFileList.add(FileUtil.makeMockMultipartFile(fileStorageInfo, decodedFileName));
				}

				if(!FileUtil.isFileInMultipartFile(decodedFileName, fileSize, mf)
						&& fileType.equalsIgnoreCase("webhard") 
						&& StringUtils.isNoneBlank(savedName)) {

					mockedFileList.add(FileUtil.makeMockMultipartFrontFile(decodedFileName, savedName));
				}
			}
		}

		/*
		 * 1. DB 처리
		 * 2. File 처리
		 * 
		 * */
		if (!mockedFileList.isEmpty()) {
			//기존 파일 처리
			copyFile(orgPath, servicePath, serviceType, objectID, objectType, messageID, version);

			for (int i = 0; i < mockedFileList.size(); i++) {
				//0. 변수 처리
				String fileName = "";
				String savedName = "";

				// 파일 중복명 처리
				String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay(CURRENT_TIME_FORMAT);
				// 본래 파일명
				fileName = Normalizer.normalize(mockedFileList.get(i).getOriginalFilename(), Normalizer.Form.NFC);
				String ext = FilenameUtils.getExtension(fileName);
				String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(fileName);
				// 저장되는 파일 이름
				savedName = genId + "." + FilenameUtils.getExtension(fileName);

				//1. DB 처리
				String fileSize = String.valueOf(mockedFileList.get(i).getSize());
				String storageID = storageInfo.optString("StorageID");
				String saveType = FileUtil.returnSaveType(fileName);
				String lastSeq = "0";
				String seq = String.valueOf(i);
				String filePath = currentDay + FILE_SEPARATOR;
				String thumbWidth = "0";
				String thumbHeight = "0";
				String desc = "";
				String register = Objects.toString(SessionHelper.getSession("USERID"),"");

				CoviMap fileParam = new CoviMap();
				fileParam.put("StorageID" , storageID); 
				fileParam.put("ServiceType" , serviceType);
				fileParam.put("ObjectID" , objectID);
				fileParam.put("ObjectType" , objectType);
				fileParam.put("MessageID" , messageID);
				fileParam.put("Version" , version);
				fileParam.put("SaveType" , saveType);
				fileParam.put("LastSeq" , lastSeq);
				fileParam.put("Seq" , seq);
				fileParam.put("FilePath" , filePath);
				fileParam.put("FileName" , fileName);
				fileParam.put("SavedName" , savedName);
				fileParam.put("Extention" , ext);
				fileParam.put("Size" , fileSize);
				fileParam.put("ThumWidth" , thumbWidth);
				fileParam.put("ThumHeight" , thumbHeight);
				fileParam.put("Description" , desc);
				fileParam.put("RegisterCode" , register);
				fileParam.put("CompanyCode" , companyCode);

				coviMapperOne.insert("framework.FileUtil.insert", fileParam);
				String fileID = fileParam.get("FileID").toString();

				//2. File 처리
				String fullFileNamePath = fullPath + FILE_SEPARATOR + savedName; // 저장 될 파일 경로
				// 한글명저장
				fullFileNamePath = new String(fullFileNamePath.getBytes(StandardCharsets.UTF_8), CHARSET);
				File originFile = null;
				if(awsS3.getS3Active()) {
					try(InputStream is = mockedFileList.get(i).getInputStream()){
						awsS3.upload(is, fullFileNamePath, mockedFileList.get(i).getContentType(), mockedFileList.get(i).getSize());
						//originFile = FileUtil.multipartToFile(mockedFileList.get(i));
					}
					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						try(InputStream thumbIs = mockedFileList.get(i).getInputStream()){
							makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", thumbIs, ext); //썸네일 저장
						}
					}
				}else {
					originFile = new File(fullFileNamePath);
					transferTo(mockedFileList.get(i), originFile, ext); // 파일 저장
					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						makeThumb(fullPath + FILE_SEPARATOR + genId + "_thumb.jpg", originFile); //썸네일 저장
					}
				}

				returnList.add(CoviMap.fromObject(fileParam));
			}

		}

		return returnList;
	}

	@Override
	public void clearFile(String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
		CoviMap param = new CoviMap();
		param.put("ServiceType", serviceType);
		param.put("ObjectID", objectID);
		param.put("ObjectType", objectType);
		param.put("MessageID", messageID);

		//파일 삭제 처리를 위한 select
		//CoviList fileList = selectAttachAll(param);
		//데이터 삭제(DB Flag 처리)
		int delCnt = deleteAll(param);
		//파일 삭제
		//String companyCode = SessionHelper.getSession("DN_Code");
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;

		// 물리파일 삭제는 sys_file 의 Deleted Flag 기준으로 (Commit 된 경우만) 처리한다. Rollback 시 삭제로직 미수행.
		// 처리 : AsyncTaskFileDelete.java
		if(delCnt > 0) {
			final String companyCode = SessionHelper.getSession("DN_Code");
			TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
				@Override
				public void afterCommit() {
					try {
						CoviMap deleteParam = new CoviMap();
						deleteParam.putAll(param);
						asyncTaskFileDelete.delete(deleteParam, companyCode);
					} catch (NullPointerException e) { 
						LOGGER.error(e.getLocalizedMessage(), e);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			});
		}
		/*
		for (int i = 0; i < fileList.size(); i++) {
			CoviMap fileObj = fileList.getJSONObject(i);
			String companyCode = fileObj.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileObj.optString("CompanyCode");
			String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileObj.optString("StorageFilePath").replace("{0}", companyCode);
			String filePath = fileObj.getString("FilePath");
			String savedName = fileObj.getString("SavedName");

			if(StringUtils.isNoneBlank(filePath)
					&&StringUtils.isNoneBlank(savedName)){

				String fullPath = backServicePath + filePath + savedName;
				deleteFile(fullPath);
				String ext = FilenameUtils.getExtension(savedName);
				if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
					deleteFile(backServicePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
		        }
			}
		}
		 */
	}

	//버전 parameter를 추가로 받는 메소드
	public void clearFile(String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception{
		final CoviMap param = new CoviMap();
		param.put("ServiceType", serviceType);
		param.put("ObjectID", objectID);
		param.put("ObjectType", objectType);
		param.put("MessageID", messageID);
		param.put("Version", version);

		//파일 삭제 처리를 위한 select
		//CoviList fileList = selectAttachAll(param);
		//데이터 삭제(DB Flag 처리)
		int delCnt = deleteAll(param);
		//파일 삭제
		//String companyCode = SessionHelper.getSession("DN_Code");
		//String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;


		// 물리파일 삭제는 sys_file 의 Deleted Flag 기준으로 (Commit 된 경우만) 처리한다. Rollback 시 삭제로직 미수행.
		// 처리 : AsyncTaskFileDelete.java
		if(delCnt > 0) {
			final String companyCode = SessionHelper.getSession("DN_Code");
			TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
				@Override
				public void afterCommit() {
					try {
						CoviMap deleteParam = new CoviMap();
						deleteParam.putAll(param);
						asyncTaskFileDelete.delete(deleteParam, companyCode);
					} catch (NullPointerException e) { 
						LOGGER.error(e.getLocalizedMessage(), e);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			});
		}
		/*
		for (int i = 0; i < fileList.size(); i++) {
			CoviMap fileObj = fileList.getJSONObject(i);
			String companyCode = fileObj.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileObj.optString("CompanyCode");
			String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileObj.optString("StorageFilePath").replace("{0}", companyCode);
			String filePath = fileObj.getString("FilePath");
			String savedName = fileObj.getString("SavedName");

			if(StringUtils.isNoneBlank(filePath)
					&&StringUtils.isNoneBlank(savedName)){

				String fullPath = backServicePath + filePath + savedName;
				deleteFile(fullPath);
				String ext = FilenameUtils.getExtension(savedName);
				if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
					deleteFile(backServicePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
		        }
			}
		}
		 */
	}

	@Override
	public void deleteFileByID(String fileID, boolean bDel)throws Exception{
		if(StringUtils.isNotBlank(fileID)) {
			List<String> fileIDs = new ArrayList<String>();
			fileIDs.add(fileID);
			deleteFileByID(fileIDs, bDel);
		}
	}

	@Override
	public void deleteFileByID(List<String> fileIDs, boolean bDel)throws Exception{
		CoviMap param = new CoviMap();
		if(fileIDs.size() > 0) {
			param.put("fileIdArr", fileIDs);

			if(bDel) { // 물리파일 삭제
				CoviList list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("framework.FileUtil.selectByFileId", param)
						, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,ThumWidth,ThumHeight,Description,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive");
				for (int i = 0; i < list.size(); i++) {
					CoviMap fileInfo = list.getJSONObject(i);
					String companyCode = fileInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileInfo.optString("CompanyCode");
					String backServicePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + (fileInfo.optString("StorageFilePath")).replace("{0}", companyCode);
					String fullPath = backServicePath + fileInfo.optString("FilePath");
					String savedName = fileInfo.optString("SavedName");
					deleteFile(fullPath+savedName);
				}
			}
			coviMapperOne.delete("framework.FileUtil.deleteFileDbByFileId", param); // sysfile 삭제
		}
	}

	public void deleteFile(String filePath)throws Exception{
		if(awsS3.getS3Active()){
			awsS3.delete(filePath);
			LOGGER.info("[AWS S3]file : " + filePath + " delete();");
		}else {
			File backFile = new File(filePath);

			if (backFile.isFile()) {
				if (backFile.delete()) {
					LOGGER.info("file : " + backFile.toString() + " delete();");
				} else {
					//삭제 실패시 Logging
					LOGGER.error("Fail on deleteFile() : " + filePath);
					throw new Exception("deleteFile error.");
				}
			}
		}
	}

	//기존 파일중 mockList에 있는 파일들 복사
	public void copyFile(String orgPath, String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception{
		CoviMap param = new CoviMap();
		param.put("ServiceType", serviceType);
		param.put("ObjectID", objectID);
		param.put("ObjectType", objectType);
		param.put("MessageID", messageID);
		param.put("Version", version);

		//파일 복사 처리를 위한 select
		CoviList fileList = selectAttachAll(param);
		//파일 복사
		String companyCode = SessionHelper.getSession("DN_Code");
		if(StringUtil.isNull(companyCode) && RequestContextHolder.getRequestAttributes() != null) {
			companyCode = StringUtil.replaceNull(RequestContextHolder.getRequestAttributes().getAttribute("DN_Code", RequestAttributes.SCOPE_REQUEST),"");
		}
		CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
		//String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + servicePath;
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
		//String orgServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + orgPath;

		for (int i = 0; i < fileList.size(); i++) {
			CoviMap fileObj = fileList.getJSONObject(i);
			String orgCompanyCode = fileObj.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileObj.optString("CompanyCode");
			String orgServicePath = FileUtil.getBackPath(orgCompanyCode).substring(0, FileUtil.getBackPath(orgCompanyCode).length() - 1) + fileObj.optString("StorageFilePath").replace("{0}", orgCompanyCode);
			String filePath = fileObj.getString("FilePath");
			String savedName = fileObj.getString("SavedName");

			if(StringUtils.isNoneBlank(filePath)
					&&StringUtils.isNoneBlank(savedName)){

				String serviceFullPath = backServicePath + filePath + savedName;
				String orgFullPath = orgServicePath + filePath + savedName;

				if(awsS3.getS3Active(companyCode)){
					if (!orgFullPath.equals(serviceFullPath)) {//동일경로에 있는 파일의 경우 copy하지 않음
						awsS3.copy(orgFullPath, serviceFullPath);
						String ext = FilenameUtils.getExtension(savedName);
						if (ext.equalsIgnoreCase("jpg") || ext.equalsIgnoreCase("jpeg") || ext.equalsIgnoreCase("png") || ext.equalsIgnoreCase("gif") || ext.equalsIgnoreCase("bmp")) {
							deleteFile(backServicePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
						}
					}
				}else {
					File backFile = new File(serviceFullPath);
					File orgFile = new File(orgFullPath);
					if (!orgFullPath.equals(serviceFullPath)) {//동일경로에 있는 파일의 경우 copy하지 않음
						if (backFile.isFile()) {
							FileUtils.copyFile(orgFile, backFile);
							String ext = FilenameUtils.getExtension(savedName);
							if (ext.equalsIgnoreCase("jpg") || ext.equalsIgnoreCase("jpeg") || ext.equalsIgnoreCase("png") || ext.equalsIgnoreCase("gif") || ext.equalsIgnoreCase("bmp")) {
								deleteFile(backServicePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
							}
						} else {
							LOGGER.error("Fail on copyFile() : " + orgFullPath);
							throw new Exception("copyFile error.");
						}
					}
				}
			}
		}
	}

	//check if the file exists or not 
	@Override
	public boolean fileIsExistsBoolean(String filePath){
		boolean isExists = false;
		FileUtil.checkTraversalCharacter(filePath);
		if(awsS3.getS3Active()){
			isExists = awsS3.exist(filePath);
		}else {
			File file = new File(filePath);
			isExists = file.exists();
		}
		return isExists;
	}

	@Override
	public void makeThumb(String outputFile, File originalFile) throws Exception{
		FileInputStream fis = null;
		try {
			fis = new FileInputStream(originalFile);
			String orgext = FilenameUtils.getExtension(originalFile.getName());
			makeThumb(outputFile, fis, orgext, originalFile);
		}finally {
			if(fis != null) {
				fis.close();
			}
		}
	}
	@Override
	public void makeThumb(String outputFile, InputStream isImg) throws Exception {
		makeThumb(outputFile, isImg , "jpg");
	}
	@Override
	public void makeThumb(String outputFile, InputStream isImg, String ext) throws Exception {
		makeThumb(outputFile, isImg , ext, null);
	}
	@Override
	public void makeThumb(String outputFile, InputStream isImg, String ext, File originalFile) throws Exception {
		try {
			// 1. Filter
			ServletRequestAttributes requestAttr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
			if(requestAttr != null) {
				HttpServletRequest request = requestAttr.getRequest();
				if(request != null) {
					String excludeUrl[] = {"/mail/userMail/uploadToFront.do"
							, "/api/mail/sendMail"
							, "/approval/draft.do"
							, "/account/control/uploadToFront.do"};
					
					String requestURI = request.getRequestURI();
					if(Arrays.asList(excludeUrl).indexOf(requestURI) > -1) {
						return;
					}
				}
			}
			
			// 2. estemate Large image file. (by stream)
			boolean isLargeSizeImage = false;
			if(originalFile != null && originalFile.exists()) {
				ImageInputStream iis = null;
				try {
					// Stream 은 재활용 안되므로 로컬파일이 존재할 경우 해당 파일로 별도 Stream 생성하여 측정.
					iis = ImageIO.createImageInputStream(originalFile);
					Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
					if(readers.hasNext()) {
						ImageReader reader = readers.next();
						
						reader.setInput(iis);
						int width = reader.getWidth(0);
						int height = reader.getHeight(0);
						long estematedSize = width * height * 4; // 해상도 x 4 
						if(estematedSize > 50 * 1024 * 1024) { // 압축을 해제한 Binary 데이터가 대략 50Mbyte 를 초과할 가능성이 있음.
							isLargeSizeImage = true;
						}
					}
				}finally {
					if(iis != null) {
						iis.close();
					}
				}
			} else {
				// 원본파일이 Stream 으로 만 제공될 경우 대략적인 기준으로 체크한다.
				int originSize = isImg.available();
				if(originSize > 3 * 1024 * 1024) {
					isLargeSizeImage = true;
				}
			}

			// 3. Make Thumbnail
			BufferedImage resizedImg = null;
			String useThumbnailator = RedisDataUtil.getBaseConfig("useThumbnailator"); // 썸네일 생성시 Thumbnailator 무조건 사용.
			if(StringUtil.isEmpty(useThumbnailator)) {
				useThumbnailator = "Y"; // default : Y
			}
			if(isLargeSizeImage || "Y".equals(useThumbnailator)) {
				// >>>>>>>>> 3-1. net.coobird.thumbnailator.Thumbnails 사용.
				FileOutputStream fos = null;
				try {
					System.setProperty("thumbnailator.conserveMemoryWorkaround", "true"); // heap 사용량 최적화
					fos = new FileOutputStream(outputFile);
					// CMYK image 커버됨
					Thumbnails.of(isImg)
				        .size(200, 200)
				        .outputQuality(0.8)
				        .toOutputStream(fos);
				}finally {
					if(fos != null) {
						fos.close();
					}
					System.setProperty("thumbnailator.conserveMemoryWorkaround", "false");
				}
				resizedImg = ImageIO.read(new File(outputFile));
			} else {
				// >>>>>>>>> 3-2. Legacy 방식 : BufferedImage 방식. 해상도 * 4 정도의 Heap 사용될 수 있음.
				Graphics2D g2 = null;
				BufferedImage sourceImage = null;
				try {
					try {
						sourceImage = ImageIO.read(isImg);
					} catch (CMMException | IIOException ex) {
						Utilcmyk ucmyk = new Utilcmyk();
						sourceImage = ucmyk.readImage(originalFile);
					}
					
					int originalWidth = sourceImage.getWidth();
					int originalHeight = sourceImage.getHeight();
					int boundWidth = 200;
					int boundHeight = 200;
					int newWidth = originalWidth;
					int newHeight = originalHeight;

					// first check if we need to scale width
					if (originalWidth > boundWidth) {
						//scale width to fit
						newWidth = boundWidth;
						//scale height to maintain aspect ratio
						newHeight = (newWidth * originalHeight) / originalWidth;
					}

					// then check if we need to scale even with the new height
					if (newHeight > boundHeight) {
						//scale height to fit instead
						newHeight = boundHeight;
						//scale width to maintain aspect ratio
						newWidth = (newHeight * originalWidth) / originalHeight;
					}

					resizedImg = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
					g2 = resizedImg.createGraphics();
					g2.setBackground(Color.WHITE);
					g2.clearRect(0,0,newWidth, newHeight);
					g2.drawImage(sourceImage, 0, 0, newWidth, newHeight, null);
					
				} finally {
					if(g2 != null) {
						g2.dispose();
					}
				}
			}

			int orientation = -1;
			if(originalFile != null) {
				orientation = getOrientation(originalFile);
			}
			// 4. 변환된 썸네일을 파일로 저장. resize 된 이미지 이므로 BufferedImage 를 사용해도 부담은 없음.
			if (orientation != -1) {
				BufferedImage newResizedImg = rotateImageForExif(resizedImg, orientation);

				if (newResizedImg != null) {
					if(awsS3.getS3Active()){

						ObjectMetadata objectMetadata = new ObjectMetadata();
						String mimeType = URLConnection.guessContentTypeFromName(outputFile);
						objectMetadata.setContentType(mimeType);
						InputStream is =  FileUtil.bufferdImage_to_InputStream(newResizedImg, "jpg");
						byte[] byteArray = IOUtils.toByteArray(is);
						is = new ByteArrayInputStream(byteArray);
						objectMetadata.setContentLength(byteArray.length);
						awsS3.upload(is, outputFile, objectMetadata.getContentType(), objectMetadata.getContentLength());
						is.close();
					}else {
						ImageIO.write(newResizedImg, "jpg", new File(outputFile));
					}
				}
			} else {
				if(awsS3.getS3Active()){
					ObjectMetadata objectMetadata = new ObjectMetadata();
					String mimeType = URLConnection.guessContentTypeFromName(outputFile);
					objectMetadata.setContentType(mimeType);
					InputStream is =  FileUtil.bufferdImage_to_InputStream(resizedImg, "jpg");
					byte[] byteArray = IOUtils.toByteArray(is);
					is = new ByteArrayInputStream(byteArray);
					objectMetadata.setContentLength(byteArray.length);
					awsS3.upload(is, outputFile, objectMetadata.getContentType(), objectMetadata.getContentLength());
					is.close();
				}else {
					ImageIO.write(resizedImg, "jpg", new File(outputFile));
				}
			}
		} catch (IllegalStateException | IllegalArgumentException e) {
			// 그외의 오류 발생시 Dummy 파일로 생성한다.
			LOGGER.error(e.getLocalizedMessage(), e);
			
			BufferedImage bi = new BufferedImage(100, 100, BufferedImage.TYPE_BYTE_GRAY);
			ImageIO.write(bi, "jpg", new File(outputFile));
		}
	}

	@Override
	public int insert(CoviMap params) throws Exception{
		return coviMapperOne.insert("framework.FileUtil.insert", params);
	}

	@Override
	public CoviMap selectOne(CoviMap params) throws Exception{
		return coviMapperOne.select("framework.FileUtil.selectOne", params);
	}

	@Override
	public int deleteAll(CoviMap params) throws Exception {
		// return coviMapperOne.delete("framework.FileUtil.deleteAll", params);
		return coviMapperOne.update("framework.FileUtil.deleteFlagAll", params);
	}

	@Override
	public CoviList selectAttachAll(CoviMap params) throws Exception {
		CoviList list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("framework.FileUtil.selectAttachAll", params)
				, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,ThumWidth,ThumHeight,Description,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive");

		return FileUtil.getFileTokenArray(list);
	}

	@Override
	public File callDRMDecoding(File file, String fileFullNamePath) throws Exception {
		ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(sc, FrameworkServlet.SERVLET_CONTEXT_PREFIX + "action");
		DRMIF drmObj = (DRMIF) context.getBean(DRM_BEAN_NAME);

		File returnFile = drmObj.getDRMDecoding(file, fileFullNamePath);

		return returnFile;
	}

	@Override
	public File callDRMEncoding(File file, String fileFullNamePath) throws Exception {
		ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(sc, FrameworkServlet.SERVLET_CONTEXT_PREFIX + "action");
		DRMIF drmObj = (DRMIF) context.getBean(DRM_BEAN_NAME);

		File returnFile = drmObj.getDRMEncoding(file, fileFullNamePath);

		return returnFile;
	}

	@Override
	public CoviList selectStorageInfo() throws Exception {
		CoviList list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("framework.FileUtil.selectStorageInfo", new CoviMap())
				, "StorageID,DomainID,ServiceType,LastSeq,FilePath,InlinePath,IsActive,Description,RegistDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,DomainCode");
		return list;
	}

	/**
	 * 기존 fileinfo에서 FileID 로 나머지 정보(storageid,path,companycode 등) 조회 
	 */
	@Override
	public CoviList selectFileStorageInfo(CoviMap params) throws Exception {
		CoviList list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("framework.FileUtil.selectFileStorageInfo", params)
				, "StorageID,DomainID,StorageServiceType,StorageLastSeq,StorageFilePath,InlinePath,IsActive,Description,FileID,FileServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,FileLastSeq,Seq,FileFilePath,FileName,SavedName,Extention,Size,RegisterCode,CompanyCode");
		return list;
	}

	/** fileid 이용하여 파일 다운(response에 flush)
	 * fileParam : fileID,fileUUID(생략가능),fileToken,tokenCheckTime(Y/N),userCode,companyCode
	 * chkToken : 토큰 체크여부
	 * insertLog : log insert여부
	 * return : fileID,fileUUID,serviceType,orgFileName,fileSize,downloadResult(Y/N),failReason,errMsg
	 */
	@Override
	public CoviMap fileDownloadByID(HttpServletRequest request, HttpServletResponse response, CoviMap fileParam, boolean chkToken, boolean insertLog) throws Exception {
		CoviMap fileResult = new CoviMap();
		InputStream in = null;
		OutputStream os = null;

		String fileID = "";
		String fileUUID = "";
		String serviceType = "";
		String orgFileName = "";
		String fileSize = "";
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."

		try{
			CoviMap params = new CoviMap();
			request.setCharacterEncoding("UTF-8");

			fileID = fileParam.optString("fileID");
			fileUUID = fileParam.optString("fileUUID");
			String fileToken = fileParam.optString("fileToken");
			String userCode = fileParam.optString("userCode");
			String companyCode = fileParam.optString("companyCode");
			boolean tokenCheckTime = fileParam.optString("tokenCheckTime").equals("Y") ? true : false;

			boolean passToken = true;
			if(chkToken) passToken = FileUtil.isValidToken(fileID, fileToken, userCode, tokenCheckTime);

			if(!fileID.equals("") && passToken){
				params.put("FileID", fileID);
				CoviMap fileMap = selectOne(params);

				String savedName = fileMap.getString("SavedName"); 									//서버에 저장된 파일명
				String filePath = fileMap.getString("FilePath");
				//companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");	// 회사 코드			
				companyCode = fileMap.getString("CompanyCode");	// companycode 없는경우 있음(기존데이터 오류방지)
				orgFileName = fileMap.getString("FileName"); 								//다운로드시 변경될 파일명
				serviceType = fileMap.getString("ServiceType");

				String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
				String savePath = attachRootPath + fileMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath;

				File file = null;
				boolean skip = false;
				// 파일을 읽어 스트림에 담기
				response.reset();
				try{
					if(awsS3.getS3Active(companyCode)) {
						String s3key = savePath+savedName;
						AwsS3Data s3Data = awsS3.downData(s3key);
						in = s3Data.getContentStream();
						response.setHeader("Content-Length", String.valueOf(s3Data.getLength()) );
					}else {
						file = new File(savePath, savedName);
						if(IS_USE_ENCODE_DRM.equalsIgnoreCase("Y")){
							file = callDRMEncoding(file, savePath + savedName);
						}
						// [파일보안] 스토리지 저장시 AES 암호화
						File decrypted = file;
						if("Y".equals(fileMap.optString("Encrypted"))) {
							decrypted = FileEncryptor.getInstance().decrypt(file, companyCode);
						}
						in = new FileInputStream(decrypted);

						fileSize = Long.toString(decrypted.length());
						response.setHeader("Content-Length", ""+fileSize );
					}


				} catch(NullPointerException e){	
					skip = true;
				}catch(FileNotFoundException fe){
					skip = true;
				}

				// 파일 다운로드 헤더 지정
				response.setHeader("Content-Description", "JSP Generated Data");
				response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
				String disposition = FileUtil.getDisposition(orgFileName, FileUtil.getBrowser(request));
				response.setHeader("Content-Disposition", disposition);

				if(!skip){
					downloadResult = "Y";
					errMsg = "";

					os = response.getOutputStream();
					byte b[] = new byte[8192];
					int leng = 0;

					int bytesBuffered=0;
					while ( (leng = in.read(b)) > -1){
						os.write(b,0, leng);
						bytesBuffered += leng;
						if(bytesBuffered > 1024 * 1024){ //flush after 1M
							bytesBuffered = 0;
							os.flush();
						}
					}
					os.flush();
				}else{
					downloadResult = "N";
					failReason = "File not found";
					errMsg = DicHelper.getDic("msg_FileNotFound"); // "파일을 찾을 수 없습니다."
				}
			}else{
				downloadResult = "N";
				failReason = "FileID or fileToken is not valid";
				errMsg = DicHelper.getDic("msg_FileNotFound"); // "파일을 찾을 수 없습니다."
			}
		}catch (FileNotFoundException e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			errMsg = DicHelper.getDic("msg_FileNotFound"); // "파일을 찾을 수 없습니다."
			LOGGER.error("FileUtilService.fileDownloadByID", e);
		} catch (IOException e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			LOGGER.error("FileUtilService.fileDownloadByID", e);
		} catch (Exception e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			if (!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.fileDownloadByID", e); // 해당 에러 외의 에러 처리
			}
		} finally {
			if(in != null){ 
				try{in.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }
			}
			if(os != null){ 
				try{os.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }
			}

			fileResult.put("fileID",fileID);
			fileResult.put("fileUUID",fileUUID);
			fileResult.put("serviceType",serviceType);
			fileResult.put("orgFileName",orgFileName);
			fileResult.put("fileSize",fileSize);
			fileResult.put("downloadResult",downloadResult);
			fileResult.put("failReason",failReason);
			fileResult.put("errMsg",errMsg);

			//파일 다운로드 로그
			if(insertLog) LoggerHelper.filedownloadLogger(fileID, fileUUID, StringUtil.isEmpty(serviceType) ? "Unknown" : serviceType, orgFileName, downloadResult, failReason);
		}

		return fileResult;
	}

	@Override
	public CoviMap zipFileDownload(HttpServletRequest request, HttpServletResponse response, CoviMap fileParam, boolean chkToken, boolean insertLog) throws Exception {
		CoviMap fileResult = new CoviMap();

		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		Date currentTime = new Date();
		String outFilename = dateFormat.format(currentTime) + ".zip";

		response.setStatus(HttpServletResponse.SC_OK);
		response.setContentType("application/zip");
		response.addHeader("Content-Disposition", "attachment; filename=\"" + outFilename + "\"");

		try (ZipOutputStream zipOut = new ZipOutputStream(response.getOutputStream());) {
			CoviList fileList = selectAttachAll(fileParam);

			for(int i = 0; i < fileList.size(); i++) {
				CoviMap fileMap = fileList.getJSONObject(i);

				boolean tokenCheckTime = fileParam.optString("tokenCheckTime").equals("Y") ? true : false;
				boolean passToken = true;

				if(chkToken) {
					passToken = FileUtil.isValidToken(fileMap.getString("FileID"), fileMap.getString("FileToken"), fileParam.getString("userCode"), tokenCheckTime);
				}

				if(!"".equals(fileMap.getString("FileID")) && passToken){
					String orgFileName = fileMap.getString("FileName");
					String savedName = fileMap.getString("SavedName");
					String filePath = fileMap.getString("FilePath");			
					String companyCode = fileMap.getString("CompanyCode");
					String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
					String savePath = attachRootPath + fileMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath;

					if(awsS3.getS3Active(companyCode)) {
						String s3key = savePath + savedName;
						AwsS3Data data = awsS3.downData(s3key);

						ZipEntry entry = new ZipEntry(savedName);
						zipOut.putNextEntry(entry);

						// zipOut.write(bytes);
						try (InputStream fis = data.getContentStream();) {
							StreamUtils.copy(fis, zipOut);
						}

					} else {
						File file = new File(savePath, savedName);
						if(IS_USE_ENCODE_DRM.equalsIgnoreCase("Y")){
							file = callDRMEncoding(file, savePath + savedName);
						}

						// [파일보안] 스토리지 저장시 AES 암호화
						if("Y".equals(fileMap.optString("Encrypted"))) {
							file = FileEncryptor.getInstance().decrypt(file, companyCode);
						}

						zipOut.putNextEntry(new ZipEntry(orgFileName));

						try (FileInputStream fis = new FileInputStream(file);) {
							StreamUtils.copy(fis, zipOut);
						}
					}

					downloadResult = "Y";
					errMsg = "";

					//파일 다운로드 로그
					if(insertLog) LoggerHelper.filedownloadLogger(fileMap.getString("FileID"), "", StringUtil.isEmpty(fileMap.getString("ServiceType")) ? "Unknown" : fileMap.getString("ServiceType"), fileMap.getString("FileName"), downloadResult, failReason);
				}
			}
		} catch (FileNotFoundException e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			errMsg = DicHelper.getDic("msg_FileNotFound"); // "파일을 찾을 수 없습니다."
			LOGGER.error("FileUtilService.zipFileDownload", e);
		} catch (IOException e) {
			downloadResult = "N";
			failReason = e.getMessage();
			LOGGER.error("FileUtilService.zipFileDownload", e);
		} catch (Exception e) {
			downloadResult = "N";
			failReason = e.getMessage();
			if (!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.zipFileDownload", e); // 해당 에러 외의 에러 처리
			}
		} finally {
			fileResult.put("downloadResult",downloadResult);
			fileResult.put("failReason",failReason);
			fileResult.put("errMsg",errMsg);
		}

		return fileResult;
	}

	/** fileid 이용하여 이미지파일 로드(response에 flush)
	 * errorImg : 에러발생시 표시할 파일(없으면 표시하지않음)
	 * thumbnail : 썸네일파일 여부
	 */
	@Override
	public void loadImageByID(HttpServletResponse response, String fileID, String companyCode, String errorImg, boolean thumbnail) throws Exception {
		try{
			CoviMap params = new CoviMap();

			if(!fileID.equals("")){
				params.put("FileID", fileID);
				CoviMap fileMap = selectOne(params);

				String savedName = fileMap.getString("SavedName"); 									//서버에 저장된 파일명
				String fileExtension = fileMap.getString("Extention").equals("") ? savedName.substring(savedName.lastIndexOf(".") + 1) : fileMap.getString("Extention");
				String filePath = fileMap.getString("FilePath");
				companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");	// 회사 코드

				String serviceType = fileMap.getString("ServiceType");

				if(thumbnail) {
					// 썸네일 파일이 없으면 원본 이미지
					String thumbnailSavedName = savedName.replace("." + fileExtension, "_thumb.jpg");
					String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
					String fullURL = fileMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath + thumbnailSavedName;
					String fullPath = attachRootPath + fullURL;
					String thumbnailFilePath = FileUtil.checkTraversalCharacter(fullPath);

					File thumbnailFileFile = null;
					if (!thumbnailFilePath.equals("")){
						thumbnailFileFile = new File(thumbnailFilePath);
					}

					if(thumbnailFileFile != null && thumbnailFileFile.exists() && !thumbnailFileFile.isDirectory()){
						savedName = thumbnailSavedName;
					}
					
					
					// 동영상 Thumbnmail 처리
					if("mp4".equalsIgnoreCase(fileExtension) || "ogg".equalsIgnoreCase(fileExtension) || "webm".equalsIgnoreCase(fileExtension)) {
							if(!thumbnailFileFile.exists()) {
							// 동영상 파일이며 썸네일파일이 없으면 만들어 놓는다.
							String originalFilePath = attachRootPath + fileMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath + savedName;
							
							File originFile = new File(FileUtil.checkTraversalCharacter(originalFilePath));
							if(originFile.exists()) {
								makeVideoThumbnail(originFile, thumbnailFilePath);
								//동영상파일 썸네일 요청은 썸네일 생성에 실패하더라도 원본파일을 응답하지 않도록 한다.
								savedName = thumbnailSavedName;
							}
						}
						fileExtension = "jpg";
					}
				}

				String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
				String fullURL = "";
				
				if("INLINE".equals(fileMap.getString("SaveType"))) {
					fullURL = fileMap.getString("InlinePath").replace("{0}", companyCode);
				} else {
					fullURL = fileMap.getString("StorageFilePath").replace("{0}", companyCode);
				}
				
				fullURL = fullURL + filePath + savedName;
				
				String fullPath = attachRootPath + fullURL;

				HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
				if(request != null) {
					boolean decrypt = false;
					if("Y".equals(fileMap.optString("Encrypted", "N"))) {
						decrypt = true;
					}
					request.setAttribute("_decryptFile", decrypt);
				}
				loadImageByPath(response, companyCode, fullPath, fullURL, fileExtension, errorImg);
			}
		}catch (FileNotFoundException e) {
			LOGGER.error("FileUtilService.loadImageByID", e);
		} catch (IOException e) {
			LOGGER.error("FileUtilService.loadImageByID", e);
		} catch(Exception e){
			if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.loadImageByID", e); // 해당 에러 외의 에러 처리
			}
		} 
	}

	/** 이미지파일 경로 이용하여 로드(response에 flush)
	 * fullPath : 파일명포함 시스템 경로
	 * fullURL : 파일명포함 회사코드부터의 파일 URL(config[BackStorage] , AwsS3에서만 사용)
	 * errorImg : 에러발생시 표시할 파일(없으면 표시하지않음)
	 */
	@Override
	public void loadImageByPath(HttpServletResponse response, String companyCode, String fullPath, String fullURL, String fileExtension, String errorImg) throws Exception {
		InputStream in = null;
		OutputStream os = null;
		try{
			if(awsS3.getS3Active(companyCode)) {
				loadImageAwsS3ByPath(response, companyCode, fullPath, fullURL, fileExtension, errorImg);
				return; 
			}

			String filePath = fullPath;
			filePath = FileUtil.checkTraversalCharacter(filePath);
			// 파일을 읽어 스트림에 담기
			File file = null;
			if (!filePath.equals("")){
				file = new File(filePath);
			}

			if(file == null || !file.exists() || file.isDirectory()){
				if(!StringUtil.isNotBlank(errorImg)) return; // 값이 없으면 아무것도 표시하지 않음
				//filePath = FileUtil.getBackPath(companyCode)+errorImg;
				//				filePath = getErrorImgPath(errorImg, companyCode);
				//				fileExtension = filePath.substring(filePath.lastIndexOf(".") + 1);
				//				file = new File(filePath);
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}

			//in = new FileInputStream(filePath);
			// [파일보안] 스토리지 저장시 AES 암호화
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			boolean decrypt = true;
			if(request != null) {
				if(request.getAttribute("_decryptFile") != null) {
					decrypt = (Boolean)request.getAttribute("_decryptFile");
				}
			}
			File decrypted = file;
			/*if (decrypt) {
				decrypted = FileEncryptor.getInstance().decrypt(file, companyCode);
			}*/
			in = new FileInputStream(decrypted);

			// 파일 다운로드 헤더 지정
			response.reset();
			response.setHeader("Content-Length", decrypted.length()+"" );
			//썸네일 jpg 고정
			if(fileExtension.equals("png")){
				response.setContentType("image/png");
			} else if(fileExtension.equals("gif")){
				response.setContentType("image/gif");
			} else if(fileExtension.equals("bmp")){
				response.setContentType("image/bmp");
			} else if(fileExtension.equals("mp4")){
				response.setContentType("video/quicktime");
			} else {
				response.setContentType("image/jpeg");
			}

			os = response.getOutputStream();
			byte b[] = new byte[8192];
			int leng = 0;

			int bytesBuffered=0;
			while ( (leng = in.read(b)) > -1){
				os.write(b,0, leng);
				bytesBuffered += leng;
				if(bytesBuffered > 1024 * 1024){ //flush after 1M
					bytesBuffered = 0;
					os.flush();
				}
			}

			os.flush();
		} catch (FileNotFoundException e) {
			LOGGER.error("FileUtilService.loadImageByPath", e);
		} catch (IOException e) {
			LOGGER.error("FileUtilService.loadImageByPath", e);
		} catch(Exception e){
			if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.loadImageByPath", e); // 해당 에러 외의 에러 처리
			}
		} finally {
			if(in != null){ 
				try{in.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadImageByPath", e1); }
			}
			if(os != null){
				try{os.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadImageByPath", e1); }
			}
		}
	}

	@Override
	public void loadImageAwsS3ByPath(HttpServletResponse response, String companyCode, String fullPath, String fullURL, String fileExtension, String errorImg) throws Exception {
		InputStream in = null;
		OutputStream os = null;
		try{
			// 파일을 redirect
			String dir = "";
			String imgParam = fullURL;

			if(!StringUtil.isNotBlank(imgParam)) {
				if(!StringUtil.isNotBlank(errorImg)) return; // 값이 없으면 아무것도 표시하지 않음
				//filePath = FileUtil.getBackPath(companyCode)+errorImg;
				imgParam = getErrorImgURL(errorImg, companyCode);
				fileExtension = imgParam.substring(imgParam.lastIndexOf(".") + 1);
			}

			String parsImgParam = new String(imgParam.getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8);
			if(parsImgParam.contains("?")){
				parsImgParam = imgParam;
			}

			if(parsImgParam.contains(FileUtil.getFrontPath(companyCode))){//게시글 디자인 이미지 첨부의 임시 url케이스 예외처리, 키에 front_path포함된 경우
				dir = "";
			}else {
				dir = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
			}

			String key = dir+parsImgParam;
			if(key.startsWith("/")){
				key = key.substring(1);
			}
			//key = java.net.URLEncoder.encode(key, java.nio.charset.StandardCharsets.UTF_8.toString());
			//response.sendRedirect("/groupware/aws/s3redirect.do?key="+key);
			if(!awsS3.exist(key)) {
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}
			AwsS3Data s3data = awsS3.downData(key);
			String fileName = s3data.getName();
			in = s3data.getContentStream();

			fileName = fileName.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응;
			response.setHeader("Content-Disposition", "attachment;fileName=\""+fileName+"\";");
			response.setContentType("application/octet-stream;charset=utf-8");

			// 파일 다운로드 헤더 지정
			response.reset();
			response.setHeader("Content-Length", String.valueOf(s3data.getLength()) );
			//썸네일 jpg 고정
			if(fileExtension.equals("png")){
				response.setContentType("image/png");
			} else if(fileExtension.equals("gif")){
				response.setContentType("image/gif");
			} else if(fileExtension.equals("bmp")){
				response.setContentType("image/bmp");
			} else if(fileExtension.equals("mp4")){
				response.setContentType("video/quicktime");
			} else {
				response.setContentType("image/jpeg");
			}

			os = response.getOutputStream();
			byte b[] = new byte[8192];
			int leng = 0;

			int bytesBuffered=0;
			while ( (leng = in.read(b)) > -1){
				os.write(b,0, leng);
				bytesBuffered += leng;
				if(bytesBuffered > 1024 * 1024){ //flush after 1M
					bytesBuffered = 0;
					os.flush();
				}
			}
			os.flush();
		} catch (FileNotFoundException e) {
			LOGGER.error("FileUtilService.loadImageAwsS3ByPath", e);
		} catch (IOException e) {
			LOGGER.error("FileUtilService.loadImageAwsS3ByPath", e);
		} catch(Exception e){
			if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.loadImageAwsS3ByPath", e); // 해당 에러 외의 에러 처리
			}
		} finally {
			if(in != null){ 
				try{in.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadImageByPath", e1); }
			}
			if(os != null){
				try{os.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadImageByPath", e1); }
			}
		}
	}

	@Override
	public String getErrorImgPath(String errorImg, String companyCode) throws Exception {
		String rtnPath = "";
		if(!StringUtil.isNotBlank(errorImg)) errorImg = "no_image.jpg";
		rtnPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + errorImg;
		return rtnPath;
	}

	@Override
	public String getErrorImgURL(String errorImg, String companyCode) throws Exception {
		String rtnURL = "";
		if(!StringUtil.isNotBlank(errorImg)) errorImg = "no_image.jpg";
		rtnURL = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + errorImg;
		return rtnURL;
	}

	/** 파일 경로 이용하여 로드(response에 flush)
	 * 마이그레이션 덤프파일 보기용(png,gif,mp4,jpeg,jpg,pdf,htm,html이 아닌경우 setContentType에 케이스 추가 필요
	 * fullPath : 파일명포함 시스템 경로
	 */
	@Override
	public void loadFileByPath(HttpServletResponse response, String companyCode, String fullPath, String fileExtension) throws Exception {
		InputStream in = null;
		OutputStream os = null;
		try{
			String filePath = fullPath;
			filePath = FileUtil.checkTraversalCharacter(filePath);
			// 파일을 읽어 스트림에 담기
			File file = null;
			if (!filePath.equals("")){
				file = new File(filePath);
			}

			if(file == null || !file.exists() || file.isDirectory()){
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}

			//in = new FileInputStream(filePath);
			// [파일보안] 스토리지 저장시 AES 암호화
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			boolean decrypt = true;
			if(request != null) {
				if(request.getAttribute("_decryptFile") != null) {
					decrypt = (Boolean)request.getAttribute("_decryptFile");
				}
			}
			File decrypted = file;
			/*if (decrypt) {
				decrypted = FileEncryptor.getInstance().decrypt(file, companyCode);
			}*/
			in = new FileInputStream(decrypted);

			// 파일 다운로드 헤더 지정
			response.reset();
			if(fileExtension.equals("png")){
				response.setContentType("image/png");
			} else if(fileExtension.equals("gif")){
				response.setContentType("image/gif");
			} else if(fileExtension.equals("bmp")){
				response.setContentType("image/bmp");
			} else if(fileExtension.equals("mp4")){
				response.setContentType("video/quicktime");
			} else if(fileExtension.equals("jpeg") || fileExtension.equals("jpg")){
				response.setContentType("image/jpeg");
			} else if(fileExtension.equals("pdf")){
				response.setContentType("application/pdf");
			} else if(fileExtension.equals("html") || fileExtension.equals("htm")){
				response.setContentType("text/html");
			} else if(fileExtension.equals("mht")){
				response.setContentType("message/rfc822");				
			} else {
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}
			
			if(fileExtension.equals("mht")){
		    	response.setHeader("Content-Description", "JSP Generated Data");
				response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
				String disposition = FileUtil.getDisposition(filePath.substring(filePath.lastIndexOf("/") + 1), FileUtil.getBrowser(request));
				response.setHeader("Content-Disposition", disposition);
			}else {
	            response.setHeader("Content-Length", decrypted.length()+"" );
			}		

			os = response.getOutputStream();
			byte b[] = new byte[8192];
			int leng = 0;

			int bytesBuffered=0;
			while ( (leng = in.read(b)) > -1){
				os.write(b,0, leng);
				bytesBuffered += leng;
				if(bytesBuffered > 1024 * 1024){ //flush after 1M
					bytesBuffered = 0;
					os.flush();
				}
			}

			os.flush();
		} catch (FileNotFoundException e) {
			LOGGER.error("FileUtilService.loadFileByPath", e);
		} catch (IOException e) {
			LOGGER.error("FileUtilService.loadFileByPath", e);
		} catch(Exception e){
			if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				LOGGER.error("FileUtilService.loadFileByPath", e); // 해당 에러 외의 에러 처리
			}
		} finally {
			if(in != null){ 
				try{in.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadFileByPath", e1); }
			}
			if(os != null){
				try{os.close();} catch(NullPointerException e1){ LOGGER.error("FileUtilServiceImpl.fileDownloadByID", e1); }catch(Exception e1){ LOGGER.error("FileUtilServiceImpl.loadFileByPath", e1); }
			}
		}
	}

	/**************************************************************************************************/
	/**************************************************************************************************/
	/**************************************************************************************************/
	//아래 부분은 개발 완료 후 삭제 할 것.
	//전자결재에서 사용하고 있는 쿼리이므로 삭제하면 안됨
	@Override
	public int deleteFileDb(CoviMap params) throws Exception{
		return coviMapperOne.delete("framework.FileUtil.deleteFileDb", params);
	}

	/*@Override
	public int selectFileDbSeq(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("framework.FileUtil.selectFileDbSeq", params);
	}*/

	@Override
	public int deleteFileDbAll(CoviMap params) throws Exception {
		return coviMapperOne.delete("framework.FileUtil.deleteFileDbAll", params);
	}

	@Override
	public CoviMap selectAttachFileAll(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("framework.FileUtil.selectAttachFileAll", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,ThumWidth,ThumHeight,Description,RegistDate,RegisterCode,CompanyCode,StorageLastSeq,StorageFilePath,InlinePath,IsActive"));		
		return resultList;
	}

	@Override
	public int updateFileSeq(CoviMap jsonObj) throws Exception {
		int returnValue = 0;
		CoviMap params = new CoviMap();
		for(Object obj : jsonObj.getJSONArray("FileInfos")) {
			CoviMap fileInfo = (CoviMap) obj;
			params.clear();
			params.put("FileID", fileInfo.getString("FileID"));
			params.put("Seq", fileInfo.getString("Seq"));
			returnValue = coviMapperOne.update("framework.FileUtil.updateFileSeq", params);
		}

		return returnValue; 
	}

	public BufferedImage rotateImageForExif(BufferedImage bi, int orientation) throws Exception {
		if (orientation == 6) { // 정위치
			return rotateImage(bi, 90);
		} else if (orientation == 1) { // 왼쪽으로 누웠을 때 
			return bi;
		} else if (orientation == 3) { // 오른쪽으로 누웠을 때
			return rotateImage(bi, 180);
		} else if (orientation == 8) { // 180도
			return rotateImage(bi, 270);      
		} else {
			return bi;
		}
	}

	public BufferedImage rotateImageForExif(MultipartFile mf, int orientation) throws Exception {
		try(InputStream is = new BufferedInputStream(mf.getInputStream());){
			BufferedImage bi = ImageIO.read(is);
			return rotateImageForExif(bi, orientation);
		}
	}

	private int getOrientation(InputStream is) throws Exception {
		int orientation = -1;

		try (BufferedInputStream bis = new BufferedInputStream(is);){

			Metadata metadata = ImageMetadataReader.readMetadata(bis, true);
			Directory directory = metadata.getDirectory(ExifIFD0Directory.class);

			if (directory != null) {
				int tagType = ExifIFD0Directory.TAG_ORIENTATION;
				Integer integer = directory.getInteger(tagType);

				if (integer != null) {
					orientation = directory.getInt(tagType);
				}
			}
		}catch(NullPointerException e1){ 
			LOGGER.error(e1); 	
		} catch (Exception e) {
			orientation = -1;
		}

		return orientation;
	}

	private int getOrientation(File file) throws Exception {
		try(InputStream is = new FileInputStream(file);){
			return getOrientation(is);
		}
	}

	private BufferedImage rotateImage(BufferedImage orgImage, int radians) {
		BufferedImage newImage = null;

		if (radians==90 || radians==270) {
			newImage = new BufferedImage(orgImage.getHeight(),orgImage.getWidth(),orgImage.getType());
		} else if (radians==180){
			newImage = new BufferedImage(orgImage.getWidth(),orgImage.getHeight(),orgImage.getType());
		} else{
			return orgImage;
		}

		Graphics2D graphics = (Graphics2D) newImage.getGraphics();
		graphics.rotate(Math.toRadians(radians), newImage.getWidth() / 2, newImage.getHeight() / 2);
		graphics.translate((newImage.getWidth() - orgImage.getWidth()) / 2, (newImage.getHeight() - orgImage.getHeight()) / 2);
		graphics.drawImage(orgImage, 0, 0, orgImage.getWidth(), orgImage.getHeight(), null);

		return newImage;
	}

	public void transferTo(MultipartFile mf, File file, String ext) throws Exception {
		// orientation 처리는 여기서 하지 않는다. 썸네일처리시에 썸네일이미지에 대해서만 처리하고 원본파일은 건드리지 않도록.
		/*
    	int orientation = getOrientation(mf);
		if (orientation != -1) {
			try {
				BufferedImage bfImg = rotateImageForExif(mf, orientation);

				if (bfImg != null) {
					ByteArrayOutputStream os = new ByteArrayOutputStream();
					ImageIO.write(bfImg, ext, os);
					InputStream is = new ByteArrayInputStream(os.toByteArray());

					mf.transferTo(file);
					FileUtils.copyInputStreamToFile(is, file);
				}else {
					mf.transferTo(file);
				}
			} catch (Exception e) {
				mf.transferTo(file);
			}

		} else {
			mf.transferTo(file);
		}
		 */
		InputStream is = null;
		try {
			mf.transferTo(file);
		}finally {
			try {
				is = mf.getInputStream();
				if(is != null) {
					is.close();
				}
			}
			catch(NullPointerException e){	LOGGER.error(e.getLocalizedMessage(), e); } // InputStream 이중조회로 간헐적인 오류발생(java.lang.IllegalStateException: File has been moved - cannot be read again)
			catch(Exception e) { LOGGER.error(e.getLocalizedMessage(), e); }
		}
	}

	//해당 폴더 및 하위파일 삭제
	public void deleteAllFiles(File rootFile) {
		File[] allFiles = rootFile.listFiles();
		if (allFiles != null) {
			for (File file : allFiles) {
				deleteAllFiles(file);
			}
		}
		if(!rootFile.delete()) {
			LOGGER.info("Fail to delete file ["+ rootFile.getAbsolutePath() +"]");
		}
	}

	@Override
	public CoviList getFileListByID(List<String> fileIDs) throws Exception {
		CoviMap param = new CoviMap();
		param.put("fileIdArr", fileIDs);

		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("framework.FileUtil.selectByFileId", param));
	}	
	
	/**
	 * 동영상 미디어 파일의 썸네일(첫번째 프레임) 이미지 추출
	 * https://mvnrepository.com/artifact/org.jcodec/jcodec
	 * @param originalFile
	 * @param thumbnailPath
	 */
	private void makeVideoThumbnail(File originalFile, String thumbnailPath) {
		FileOutputStream fos = null;
		BufferedOutputStream bos = null;
		long startTime = System.currentTimeMillis();
		try {
			fos = new FileOutputStream(thumbnailPath);
			bos = new BufferedOutputStream(fos);
			
			int frameNumber = 0;
			Picture picture = FrameGrab.getFrameFromFile(originalFile, frameNumber);
			BufferedImage bufferedImage = AWTUtil.toBufferedImage(picture);

			ImageIO.write(bufferedImage, "jpg", bos);
			
			LOGGER.debug("Elapsed time for make Video Thumbnail [size : "+originalFile.length()+" byte] is "+(System.currentTimeMillis() - startTime)+" ms.");
		} catch (FileNotFoundException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (JCodecException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			
			// Codec 오류발생시 이후 재시도를 하지 않도록 Dummy 썸네일파일을 생성해 놓는다.
			Graphics2D graphics = null;
			try {
			
				BufferedImage bi = new BufferedImage(450, 250, BufferedImage.TYPE_BYTE_GRAY); 
				graphics = (Graphics2D) bi.getGraphics();
				graphics.setColor(Color.LIGHT_GRAY);
				graphics.fillRect(0, 0, bi.getWidth(), bi.getHeight());
				graphics.drawImage(bi, 0, 0, 450, 250, null);
			
				ImageIO.write(bi, "jpg", bos);
			}catch(IOException ioe) {
				LOGGER.info(ioe.getLocalizedMessage());
				if(new File(thumbnailPath).exists()) {
					if(!new File(thumbnailPath).delete()) {
						LOGGER.warn("File delete error.");
					}
				}
			}finally{
				if(graphics != null) {
					graphics.dispose();
				}
			}
		} finally {
			if(fos != null) {
				try {
					fos.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if(bos != null) {
				try {
					bos.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
	}
}
