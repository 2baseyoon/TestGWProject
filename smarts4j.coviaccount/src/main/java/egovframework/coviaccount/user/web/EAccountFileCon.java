package egovframework.coviaccount.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.Map;
import java.util.Objects;

import javax.annotation.Resource;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;



/**
 * @Class Name : DownloadLargeFilesCon.java
 * @Description : 대용량 파일 다운로드 컨트롤러
 * @Modification Information 
 * @ 2018.04.16 최초생성
 * 
 * Class Name : EAccountFileCon.java
 * EAccount용 파일 컨트롤러
 * 
 * @author 코비젼 연구소
 * @since 2018. 03.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class EAccountFileCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private FileUtilService fileSvc;

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	* @Method Name : uploadFiles
	* @Description : //Front -> Back sample code 
	파일 업로드
	covicore/coviframework에서 copy
	*/
	@RequestMapping(value = "EAccountFileCon/uploadFiles.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap uploadFiles(HttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviList frontFileInfos = CoviList.fromObject(request.getParameter("frontFileInfos"));
			//returnList.put("list", moveToBack(frontFileInfos, "EAccount/", "EAccount", "0", "NONE", "0"));
			returnList.put("list", fileSvc.moveToBack(frontFileInfos, "EAccount/", "EAccount", "0", "NONE", "0", false));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : doDownloadLargeFiles
	* @Description : 파일 다운로드
	covicore/coviframework에서 copy
	*/
	@RequestMapping(value = "EAccountFileCon/doDownloadFiles.do")
	public void doDownloadLargeFiles(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {//, @PathVariable String bizSection, @PathVariable long fileID
		String fileID = "";
		String fileUUID = "";
		String serviceType = "";
		String orgFileName = "";
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."
		CoviMap fileParam = new CoviMap();
		CoviMap fileResult = new CoviMap();
	    
		try {
			fileID = paramMap.get("fileId");
			String userCode = SessionHelper.getSession("UR_Code");
			String companyCode = SessionHelper.getSession("DN_Code");
			
			fileParam.put("fileID",fileID);
			fileParam.put("fileUUID","");
			fileParam.put("fileToken","");
			fileParam.put("tokenCheckTime","N");
			fileParam.put("userCode",userCode);
			fileParam.put("companyCode",companyCode);
			
			fileResult = fileSvc.fileDownloadByID(request, response, fileParam, false, true);
			
			serviceType = fileResult.optString("serviceType");
			orgFileName = fileResult.optString("orgFileName");
			downloadResult = fileResult.optString("downloadResult");
			failReason = fileResult.optString("failReason");
			errMsg = fileResult.optString("errMsg");
			
		} catch (SQLException e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			logger.error(e.getLocalizedMessage(), e);
			//throw new IOException();
			response.reset();
			response.setContentType("text/html;charset=UTF-8");
        	try (PrintWriter out = response.getWriter();){
        		out.println("<script language='javascript'>parent.accountFileCtrl.makeError();</script>");
        		errMsg = "";
        	}
		} catch (Exception e) {
			downloadResult = "N";
			failReason =  e.getMessage();
			logger.error(e.getLocalizedMessage(), e);
			//throw new IOException();
			response.reset();
			response.setContentType("text/html;charset=UTF-8");
        	try (PrintWriter out = response.getWriter();){
        		out.println("<script language='javascript'>parent.accountFileCtrl.makeError();</script>");
        		errMsg = "";
        	}
		} finally {
			if(downloadResult.equalsIgnoreCase("N") && !errMsg.equals("")) {
				response.reset();
				response.setContentType("text/html;charset=UTF-8");
	        	try (PrintWriter out = response.getWriter();){
	        		//out.println("<script language='javascript'>alert('Can not find file');</script>");
	        		out.println("<script language='javascript'>parent.Common.Error('" + errMsg + "');</script>");
	        	}
			}
		}
	}
	
	/**
	* @Method Name : getBrowser
	* @Description : FileUtilCon.java 참조
	*/
	private String getBrowser(HttpServletRequest request) {
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
	
	/**
	* @Method Name : getDisposition
	* @Description : FileUtilCon.java 참조
	*/
	private String getDisposition(String filename, String browser) throws Exception {
		String dispositionPrefix = "attachment; filename=";
		String encodedFilename = null;
		if (browser.equals("MSIE")) {
			encodedFilename = URLEncoder.encode(filename, "UTF-8").replaceAll("\\+", "%20");
		} else if (browser.equals("Firefox")) {
			encodedFilename ="\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
		} else if (browser.equals("Opera")) {
			encodedFilename ="\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
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
			encodedFilename = "\"" + sb.toString()+ "\"";
		} else {
			throw new RuntimeException("Not supported browser");
		}

		return dispositionPrefix + encodedFilename;
	}
	

	/**
	* @Method Name : getFileURLInfo
	* @Description : 파일 썸네일용 url인포 정보
	covicore/coviframework에서 copy
	*/
	@RequestMapping(value = "EAccountFileCon/getFileURLInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFileURLInfo(
			@RequestParam(value = "FileID",	required = false, defaultValue="")	String FileID) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("FileID",		FileID);
			
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
			//params.put("fileSavePath", filePath);

			resultList.put("info",	coviMapperOne.selectOne("account.common.getFileURLInfo", params));
			resultList.put("status",	Return.SUCCESS);
			resultList.put("result",	"");
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	//=====================

	/**
	* @Method Name : moveToBack
	* @Description : front에서 back로 이동
	미사용
	covicore/coviframework에서 copy
	*/
	// 미사용, FileUtilService 함수로 대체
//	public CoviList moveToBack(CoviList frontFileInfos, String servicePath, String serviceType, String objectID, String objectType, String messageID) throws Exception{
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
	* @Method Name : deleteFile
	* @Description : 파일 삭제
	*  미사용
	*/
//	public void deleteFile(String filePath)throws Exception{
//		File backFile = new File(filePath);
//		
//		if(backFile.isFile()){
//			if(backFile.delete()){
//				//삭제 성공
//			} else {
//				//삭제 실패시 Logging
//				logger.error("Fail on deleteFile() : " + filePath);
//				throw new Exception("deleteFile error.");
//			}
//		}
//	}
}