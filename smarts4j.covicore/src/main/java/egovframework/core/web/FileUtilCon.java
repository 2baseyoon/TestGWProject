package egovframework.core.web;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.core.util.AsyncTaskTempDelete;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.s3.AwsS3;

/**
 * @Class Name : FileUtilCon.java
 * @Description : 파일관리 컨트롤러 정리
 * @Modification Information 
 * @ 2017.07.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.20
 * @version 1.0
 * Copyright (C) by Covision All right reserved.
 */
@Controller
public class FileUtilCon {
	
	private Logger LOGGER = LogManager.getLogger(FileUtilCon.class);
	
	@Autowired
	private FileUtilService fileUtilSvc;

	@Resource(name = "asyncTaskTempDelete")
	private AsyncTaskTempDelete asyncTaskTempDelete;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	AwsS3 awsS3 = AwsS3.getInstance();
	// 파일다운로드 
	@RequestMapping(value = "common/fileDown.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public void commonFileDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
	    String fileID = "";
		String fileUUID = "";
		String serviceType = "";
		String orgFileName = "";
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."
		CoviMap fileParam = new CoviMap();
		CoviMap fileResult = new CoviMap();
	    
	    try{
			fileID = StringUtil.replaceNull(request.getParameter("fileID"),"");
			String fileToken = StringUtil.replaceNull(request.getParameter("fileToken"),"");
			String userCode = SessionHelper.getSession("UR_Code");
			String companyCode = SessionHelper.getSession("DN_Code");
			
			fileParam.put("fileID",fileID);
			fileParam.put("fileUUID","");
			fileParam.put("fileToken",fileToken);
			fileParam.put("tokenCheckTime","N");
			fileParam.put("userCode",userCode);
			fileParam.put("companyCode",companyCode);
			
			fileResult = fileUtilSvc.fileDownloadByID(request, response, fileParam, false, true);
			
			serviceType = fileResult.optString("serviceType");
			orgFileName = fileResult.optString("orgFileName");
			downloadResult = fileResult.optString("downloadResult");
			failReason = fileResult.optString("failReason");
			errMsg = fileResult.optString("errMsg");
			
	    }
	    catch(NullPointerException e){
			downloadResult = "N";
			failReason =  e.getMessage();
			LOGGER.error("FileUtilCon", e);
	    }
	    catch(Exception e){
			downloadResult = "N";
			failReason =  e.getMessage();
			if (!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				// 해당 에러 외의 에러 처리
				LOGGER.error("FileUtilCon", e);
			}
	    }
	    finally {
	    	if(downloadResult.equalsIgnoreCase("N") && !errMsg.equals("")) {
	    		response.reset();
				response.setContentType("text/html;charset=UTF-8");
				try(PrintWriter out = response.getWriter();){
					out.println("<script language='javascript'>alert('" + errMsg + "');</script>");
				}
			}
	    }
	}
	
	@RequestMapping(value = "common/zipFileDownload.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public void commonZipFileDownload(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap fileResult = new CoviMap();
		
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."
		
		CoviMap params = new CoviMap();
		
		try {
			params.put("ServiceType", request.getParameter("bizSection"));
			params.put("ObjectID", request.getParameter("folderID"));
			params.put("ObjectType", "FD");
			params.put("MessageID", request.getParameter("messageID"));
			params.put("Version", request.getParameter("version"));
			params.put("tokenCheckTime","N");
			params.put("userCode",SessionHelper.getSession("UR_Code"));
			
			fileResult = fileUtilSvc.zipFileDownload(request, response, params, false, true);
			
			downloadResult = fileResult.optString("downloadResult");
			failReason = fileResult.optString("failReason");
			errMsg = fileResult.optString("errMsg");
		} catch(NullPointerException e){
			downloadResult = "N";
			failReason =  e.getMessage();
			LOGGER.error("FileUtilCon.commonZipFileDownload", e);
	    } catch(Exception e){
			downloadResult = "N";
			failReason =  e.getMessage();
			if (!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				// 해당 에러 외의 에러 처리
				LOGGER.error("FileUtilCon.commonZipFileDownload", e);
			}
	    }
	}
	
	//사이냅 연결
	@RequestMapping(value = "common/convertPreview.do")
	public void  convertPreview(HttpServletRequest request, HttpServletResponse response) throws Exception {
		try{
			
			// Local proxy 를 사용하는 경우 /covicore 로 요청이 가면 sendRedirect 할 수 없으므로 안되기 때문에 /SynapDocViewServer 로 요청을 보낸다.
			if("Y".equals(PropertiesUtil.getGlobalProperties().getProperty("synap.local.proxy.use", "N"))) {
				String queryString =  request.getQueryString();
				String url = "/SynapDocViewServer/common/convertPreview.do";
				if(queryString != null) {
					// CVE - HTTP Response Splitting Vulnerability
					url = url + "?" + queryString.replaceAll("\r", "").replaceAll("\n", "");
				}
				response.sendRedirect(url);
				return;
			}

			// synapproxy (ProxyController.java) 에서도 사용하므로 Util 로 분리.
			CoviMap result = FileUtil.makeSynapDownParamenter(request);
			CoviMap resultList = new CoviMap();
			String returnURL = result.getString("returnURL");
			
			/*
			String returnURL = RedisDataUtil.getBaseConfig("MobileDocConverterServer");
			CoviMap resultList = new CoviMap();
	
			String fileID = request.getParameter("fileID");
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
				filePath += "&" + "inputAttName=" + request.getParameter("inputAttName");
				filePath += "&" + "inputUserMail=" + URLEncoder.encode(request.getParameter("inputUserMail"),"UTF-8");
				filePath += "&" + "inputReadMessageId=" + URLEncoder.encode(request.getParameter("inputReadMessageId"),"UTF-8");
				filePath += "&" + "inputMailBox=" + URLEncoder.encode(request.getParameter("inputMailBox"),"UTF-8");		
			}
			
			String WaterMarkText = "";
			if (!RedisDataUtil.getBaseConfig("IsSetMobileWatermark").equals("Y")){
				WaterMarkText = "";   // 기초설정 MobileWatermarkText 값을 읽어온다.
			    if (WaterMarkText.indexOf("@@") > -1) {
			        WaterMarkText = WaterMarkText.split("@@")[1];
			        WaterMarkText = SessionHelper.getSession(WaterMarkText);   
			    }
			}
			*/

			HttpClientUtil httpClient = new HttpClientUtil();
			NameValuePair[] data = {
				    new NameValuePair("fid", "filePreview"+result.getString("fileID")),
				    new NameValuePair("fileType", "URL"),
				    new NameValuePair("convertType", "1"),
				    new NameValuePair("filePath",result.getString("filePath")),
				    new NameValuePair("watermarkText",result.getString("WaterMarkText")),
				    new NameValuePair("sync", "false"),
				    new NameValuePair("force", "false")
		    };
			
			resultList = httpClient.httpClientConnect(returnURL+"/job", "", "POST", data, 7);
			if (resultList.get("status").equals(200)){
				response.sendRedirect(returnURL+"/view/"+((CoviMap)resultList.get("body")).get("key"));
			}else{
				LOGGER.error("convertPreview error:" + returnURL+"/job"+ ": "+ result.getString("filePath") + ": "+ resultList);
			}			
		}
		catch(IOException e){
	    	  LOGGER.error("convertPreview", e);
	    	  throw e;
		}
		catch(Exception e){
	    	  LOGGER.error("convertPreview", e);
	    	  throw e;
		}
	}
	
	// 첨부파일 미리보기 다운로드
	@RequestMapping(value = "common/filePreviewDown.do")
	public void commonFilePreviewDownload(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		String fileID = "";
		String fileUUID = "";
		String serviceType = "";
		String orgFileName = "";
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."
		CoviMap fileParam = new CoviMap();
		CoviMap fileResult = new CoviMap();
	    
	    try{
	    	fileID = StringUtil.replaceNull(request.getParameter("fileID"),"");
			String fileToken = StringUtil.replaceNull(request.getParameter("fileToken"),"");
			String userCode = StringUtil.replaceNull(request.getParameter("userCode"),SessionHelper.getSession("UR_Code"));
			String companyCode = SessionHelper.getSession("DN_Code");
			
			fileParam.put("fileID",fileID);
			fileParam.put("fileUUID","");
			fileParam.put("fileToken",fileToken);
			fileParam.put("tokenCheckTime","Y");
			fileParam.put("userCode",userCode);
			fileParam.put("companyCode",companyCode);
			
			fileResult = fileUtilSvc.fileDownloadByID(request, response, fileParam, true, true);
			
			serviceType = fileResult.optString("serviceType");
			orgFileName = fileResult.optString("orgFileName");
			downloadResult = fileResult.optString("downloadResult");
			failReason = fileResult.optString("failReason");
			errMsg = fileResult.optString("errMsg");
			
	    }
	    catch(NullPointerException e){
			downloadResult = "N";
			failReason =  e.getMessage();
			LOGGER.error("FileUtilCon", e);
	    }
	    catch(Exception e){
			downloadResult = "N";
			failReason =  e.getMessage();
			if (!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
				// 해당 에러 외의 에러 처리
				LOGGER.error("FileUtilCon", e);
			}
	    }
	    finally {
	    	if(downloadResult.equalsIgnoreCase("N") && !errMsg.equals("")) {
				response.reset();
				response.setContentType("text/html;charset=UTF-8");
				try(PrintWriter out = response.getWriter();){
					out.println("<script language='javascript'>alert('" + errMsg + "');history.back();</script>");
				}
			}
	    	LoggerHelper.filedownloadLogger(fileID, fileUUID, StringUtil.isEmpty(serviceType) ? "Unknown" : serviceType, orgFileName, downloadResult, failReason);
	    }
	}
	
	//미리보기화면에서 표시할 내용 파일 조회시 사용
	@RequestMapping(value = "common/preview/{fileID}.do", method = RequestMethod.GET)
	public void previewImage(HttpServletResponse response,@PathVariable long fileID) throws Exception {
		previewImage(response, "", fileID);
	}
	//ex) [GET] /covicore/preview/Board/282.do
	@RequestMapping(value = "common/preview/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public void previewImage(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
	    try{
	    	String companyCode = SessionHelper.getSession("DN_Code");
	    	String strFileID = Long.toString(fileID);
	    	fileUtilSvc.loadImageByID(response, strFileID, companyCode, "no_image.jpg", true);
	    }
	    catch(NullPointerException e){
	    	LOGGER.error("FileUtilCon", e);
	    }
	    catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    } 
	}
	
	@RequestMapping(value = "common/previewsrc/{fileID}.do", method = RequestMethod.GET)
	public @ResponseBody String previewImageSrc(HttpServletResponse response, @PathVariable long fileID) throws Exception {
		return previewImageSrc(response, "", fileID);
	}
	@RequestMapping(value = "common/previewsrc/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public @ResponseBody String previewImageSrc(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
		CoviMap params = new CoviMap();
		//String backStorageURL = RedisDataUtil.getBaseConfig("BackStorage");
		String fileSrc = "";
		String companyCode = SessionHelper.getSession("DN_Code");
		try {
			params.put("FileID", fileID);
			CoviMap fileMap = fileUtilSvc.selectOne(params);

			companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");
			String fileName = fileMap.getString("SavedName");
			fileName = fileName.replace("."+fileMap.getString("Extention"),"_thumb.jpg");
			//backStorageURL = backStorageURL.replace("{0}", companyCode);
			//String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorageURL + bizSection + File.separator + fileMap.getString("FilePath") + fileName;
			//fileSrc = backStorageURL + bizSection + "/" + fileMap.getString("FilePath") + fileName;
			fileSrc = fileMap.getString("StorageFilePath").replace("{0}", companyCode) + fileMap.getString("FilePath") + fileName;
			String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileSrc;
			

	        // 파일을 읽어 스트림에 담기
		    File file = new File(FileUtil.checkTraversalCharacter(filePath));
		    
		    if(!file.exists()){
		    	//filePath = FileUtil.BACK_PATH + File.separator + "GWStorage" + File.separator + "no_image.jpg";
		    	//fileSrc = backStorageURL.replace("{0}", companyCode) + "no_image.jpg";
		    	//fileSrc = fileUtilSvc.getErrorImgURL("no_image.jpg", companyCode);
		    	response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		    }
		}
		catch (NullPointerException e) {
			fileSrc = fileUtilSvc.getErrorImgURL("no_image.jpg", companyCode);
		}
		catch (Exception e) {
			//return backStorageURL.replace("{0}", companyCode) + "no_image.jpg";
			fileSrc = fileUtilSvc.getErrorImgURL("no_image.jpg", companyCode);
		}
		
		return fileSrc;
	}
	
	@RequestMapping(value = "common/logo/{fileID}.do", method = RequestMethod.GET)
	public void viewLogo(HttpServletRequest request, HttpServletResponse response, @PathVariable String fileID) throws Exception {
		String domainCode = StringUtil.replaceNull(request.getParameter("DomainCode"));
		String companyCode =  (StringUtil.isNotBlank(domainCode)) ? domainCode : SessionHelper.getSession("DN_Code");
		//String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("LogoImage_SavePath")  +  fileID;
		String fileURL = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("LogoImage_SavePath")  +  fileID;
		String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileURL;
		String fileExtension ="png";
		//loadImage(response, companyCode, filePath, fileExtension, "logo.png");
		fileUtilSvc.loadImageByPath(response, companyCode, filePath, fileURL, fileExtension, "logo.png");
	}
	
	@RequestMapping(value = "common/banner/{fileID}.do", method = RequestMethod.GET)
	public void viewBanner(HttpServletRequest request, HttpServletResponse response, @PathVariable String fileID) throws Exception {
		String domainCode = StringUtil.replaceNull(request.getParameter("DomainCode"));
		String companyCode =  (StringUtil.isNotBlank(domainCode)) ? domainCode : SessionHelper.getSession("DN_Code");
		//String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("PortalBanner_SavePath")  +  fileID;
		String fileURL = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("PortalBanner_SavePath")  +  fileID;
		String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileURL;
		String fileExtension = fileID.substring(fileID.lastIndexOf(".") + 1, fileID.length());
		//loadImage(response, companyCode, filePath, fileExtension, "banner.jpg");
		fileUtilSvc.loadImageByPath(response, companyCode, filePath, fileURL, fileExtension, "banner.jpg");		
	}
	
	@RequestMapping(value = "common/photo/photo.do", method = {RequestMethod.GET, RequestMethod.POST})
	public void viewPhoto(HttpServletResponse response, HttpServletRequest request) throws Exception {
		final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		String companyCode =  SessionHelper.getSession("DN_Code");
		String img = StringUtil.replaceNull(request.getParameter("img"));
		String fileURL = "";
		String filePath = "";
		
		if(StringUtil.isNotBlank(img)) {
			img = ComUtils.ConvertOutputValue(StringUtil.replaceNull(img));
			String[] imgArray= img.split("/");
			//권한 체크
			if (imgArray.length>0)
			{
				if (isSaaS.equalsIgnoreCase("Y")){
					if(imgArray[0].equals("Groupware")) {
						img = "/"+companyCode+"/covistorage/"+img;
					}
				}
			}
		}
		
		String fileExtension = StringUtil.replaceNull(img).substring(StringUtil.replaceNull(img).lastIndexOf(".") + 1);

		fileURL = img;
		filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) +  img;
		if(filePath.indexOf("GWStorage/FrontStorage/")>-1){
			filePath = filePath.replace("GWStorage/FrontStorage/","FrontStorage/");
		}
		fileUtilSvc.loadImageByPath(response, companyCode, filePath, fileURL, fileExtension, "no_image.jpg");
	}

	/**
	 * 문자의 영문,숫자, 한글 타입을 리턴한다
	 *
	 * @param word
	 * @return
	 */
	public boolean checkIncludeKo(String word) {
		String[] strArr = null;

		if(word!=null && word.indexOf("/")>-1){
			strArr = word.split("/");
		}
		for(int i=0; strArr != null && i < strArr.length; i++) {
			if(strArr[i].matches("^[ㄱ-ㅎ가-힣]*$")){
				return true;
			}
		}
		return false;
	}

	@RequestMapping(value = "common/view/{fileID}.do", method = RequestMethod.GET)
	public void viewImage(HttpServletResponse response, @PathVariable long fileID) throws Exception {
		viewImage(response, "", fileID);
	}
	@RequestMapping(value = "common/view/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public void viewImage(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
	    try{
	    	String companyCode = SessionHelper.getSession("DN_Code");
	    	String strFileID = Long.toString(fileID);
	    	fileUtilSvc.loadImageByID(response, strFileID, companyCode, "no_image.jpg", false);
	    	//loadImage(response, companyCode, filePath, fileExtension, "");
	    }
	    catch(NullPointerException e){
	    	LOGGER.error("FileUtilCon", e);
	    }
	    catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    }
	}
	
	@RequestMapping(value = "common/viewsrc/{fileID}.do", method = RequestMethod.GET)
	public @ResponseBody String viewImageSrc(HttpServletResponse response, @PathVariable long fileID) throws Exception {
		return viewImageSrc(response, "", fileID);
	}
	@RequestMapping(value = "common/viewsrc/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public @ResponseBody String viewImageSrc(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
		CoviMap params = new CoviMap();
		String filePath = "";
		String companyCode = SessionHelper.getSession("DN_Code");
		try {
			params.put("FileID", fileID);
			CoviMap fileMap = fileUtilSvc.selectOne(params);
			String fileName = fileMap.getString("SavedName");
			companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");
			//filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + bizSection + File.separator + fileMap.getString("FilePath") + fileName;
			filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + fileMap.getString("StorageFilePath").replace("{0}", companyCode) + fileMap.getString("FilePath") + fileName;
			//String fileSrc = RedisDataUtil.getBaseConfig("BackStorage") + bizSection + "/" + fileMap.getString("FilePath") + fileName;
	        // 파일을 읽어 스트림에 담기
		    File file = new File(FileUtil.checkTraversalCharacter(filePath));
		    
		    if(!file.exists()){
		    	//filePath = FileUtil.BACK_PATH + File.separator + "GWStorage" + File.separator + "no_image.jpg";
		    	//fileSrc = "/GWStorage/no_image.jpg";
		    	//filePath = fileUtilSvc.getErrorImgPath("no_image.jpg", companyCode);
		    	response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		    }
		}
		catch (NullPointerException e) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		}
		catch (Exception e) {
			//filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage") + "no_image.jpg";
			//filePath = fileUtilSvc.getErrorImgPath("no_image.jpg", companyCode);
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		}
		return filePath;
	}
	
	/**
	 * [스케쥴러]Frontstorage 파일 삭제
	 * @param response
	 * @param paramMap
	 * @throws Exception
	 */
	@RequestMapping(value = "common/deleteTemporaryFiles.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteTemporaryFiles(HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		asyncTaskTempDelete.execute();
		
		result.put("status", Return.SUCCESS);
		result.put("message", DicHelper.getDic("msg_com_processSuccess"));
	
		return result;
	}
	
	/**
	 * Diff File Preview
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "common/diffFilePreview.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView diffPreview(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
	    ModelAndView mav = new ModelAndView("core/devhelper/DiffFilePreview");
	    
		String fileID = StringUtil.replaceNull(request.getParameter("fileID"), "");
		String fileName = "";
		String fileExists = "N";
		String diffString = "";
		
		if(!fileID.equals("")){
			CoviMap params = new CoviMap();
			params.put("FileID", fileID);
			
			CoviMap fileMap = fileUtilSvc.selectOne(params);

			String companyCode = fileMap.getString("CompanyCode");
			String savedName = fileMap.getString("SavedName");
			String filePath = fileMap.getString("FilePath");

			String attachRootPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1);
			String savePath = attachRootPath + fileMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath;
			
			FileUtil.checkTraversalCharacter(savePath + savedName);
			File file = new File(savePath, savedName);			
			if(file.exists()) {
				diffString = FileUtils.readFileToString(file, StandardCharsets.UTF_8);
				fileExists = "Y";
				fileName = fileMap.getString("FileName");
			}
		}
		
		mav.addObject("fileName", fileName);
		mav.addObject("fileExists", fileExists);
		mav.addObject("diffString", diffString);
		return mav;
	}
}
