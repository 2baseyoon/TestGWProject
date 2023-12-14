package egovframework.coviframework.service;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.InputStream;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.vo.FileVO;

public interface FileUtilService {
	/*
	 * sys_file
	 * */

	public CoviList uploadToFront(CoviList fileInfos, List<MultipartFile> mf, String servicePath) throws Exception;
	public CoviList uploadToBackFull(List<FileVO> fileList, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception;
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception;
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel) throws Exception;
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel, boolean bSubPath) throws Exception;
	public CoviList uploadToBack(CoviList fileInfos, List<MultipartFile> mf, String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception;
	public CoviList moveToBackFull(List<FileVO> fileList, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception;
	public CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception;
	public CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID, boolean bDel) throws Exception;
	
	public CoviList moveToService(CoviList fileInfos, List<MultipartFile> mf, String orgPath, String servicePath, String serviceType, String objectID, String objectType, String messageID, String version) throws Exception;
	public void clearFile(String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception;
	public void deleteFileByID(String fileID, boolean bDel)throws Exception;
	public void deleteFileByID(List<String> fileIDs, boolean bDel)throws Exception;
	public void makeThumb(String savedName, File originalFile) throws Exception;
	public void makeThumb(String savedName, InputStream isImg) throws Exception;
	public void makeThumb(String savedName, InputStream isImg, String ext) throws Exception;
	public void makeThumb(String savedName, InputStream isImg, String ext, File originalFile) throws Exception;
	public int insert(CoviMap params) throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int deleteAll(CoviMap params) throws Exception;
	public CoviList selectAttachAll(CoviMap params) throws Exception;
	public boolean fileIsExistsBoolean(String filePath) throws Exception;
	
	public File callDRMDecoding(File file, String fileFullNamePath) throws Exception;
	public File callDRMEncoding(File file, String fileFullNamePath) throws Exception;
	public CoviList selectStorageInfo() throws Exception;
	public CoviList selectFileStorageInfo(CoviMap params) throws Exception;
	
	public CoviMap fileDownloadByID(HttpServletRequest request, HttpServletResponse response, CoviMap fileParam, boolean chkToken, boolean insertLog) throws Exception;
	public CoviMap zipFileDownload(HttpServletRequest request, HttpServletResponse response, CoviMap fileParam, boolean chkToken, boolean insertLog) throws Exception;
	public void loadImageByID(HttpServletResponse response, String fileID, String companyCode, String errorImg, boolean thumbnail) throws Exception;
	public void loadImageByPath(HttpServletResponse response, String companyCode, String fullPath, String fullURL, String fileExtension, String errorImg) throws Exception;
	public void loadImageAwsS3ByPath(HttpServletResponse response, String companyCode, String fullPath, String fullURL, String fileExtension, String errorImg) throws Exception;
	public String getErrorImgPath(String errorImg, String companyCode) throws Exception;
	public String getErrorImgURL(String errorImg, String companyCode) throws Exception;
	public void  loadFileByPath(HttpServletResponse response, String companyCode, String fullPath, String fileExtension) throws Exception;
	
	public void deleteFile(String filePath) throws Exception;
	
	/*
	 * com_file
	 * DB 스키마 전환 작업 완료 후 아래 부분은 삭제 처리 할 것.
	 * 전자결재에서 사용하고 있는 쿼리이므로 삭제하면 안됨
	 * */
	public int deleteFileDb(CoviMap params) throws Exception;
	//public int selectFileDbSeq(CoviMap params) throws Exception;
	public int deleteFileDbAll(CoviMap fileCoviMap) throws Exception;
	public CoviMap selectAttachFileAll(CoviMap params) throws Exception;
	public int updateFileSeq(CoviMap jsonObj) throws Exception;

	public void transferTo(MultipartFile mf, File file, String ext) throws Exception;
	public BufferedImage rotateImageForExif(BufferedImage bi, int orientation) throws Exception;
	public BufferedImage rotateImageForExif(MultipartFile file, int orientation) throws Exception;
	
	
	public String getCURRENT_TIME_FORMAT() throws Exception;
	public String getFILE_SEPARATOR() throws Exception;
	public String getCHARSET() throws Exception;
	public String getIS_USE_DECODE_DRM() throws Exception;
	public String getIS_USE_ENCODE_DRM() throws Exception;
	public void deleteAllFiles(File delFolder);

    public CoviList getFileListByID(List<String> fileIDs) throws Exception;
    
}
