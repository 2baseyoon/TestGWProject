package egovframework.core.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Locale;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.CoviCsSvc;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;

/**
 * @Class Name : LoginCon.java
 * @Description : 로그인 처리
 * @Modification Information
 * @ 2015.11.06 최초생성
 *
 * @author 코비젼 연구소
 * @since 2015. 11.13
 * @version 1.0
 * @see Copyright(C) by Covision All right reserved.
 */

@Controller
public class CoviCsCon extends HttpServlet {
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired 
	CoviCsSvc coviCsSvc;
	@Autowired
	private FileUtilService fileUtilSvc;
	
	private static final Logger LOGGER = LogManager.getLogger(CoviCsCon.class);
	
	@RequestMapping(value = "/covics/list.do") 
	public ModelAndView list(Locale locale, Model model,HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "core/covics/list";
		ModelAndView mav = new ModelAndView(returnURL);
		/*mav.addObject("samlRequest", request.getParameter("SAMLRequest"));
		mav.addObject("relayState", request.getParameter("RelayState"));
		mav.addObject("acr", acr);
		
		mav.addObject("loginState", "success");
		mav.addObject("samlLogin", PropertiesUtil.getSecurityProperties().getProperty("sso.sp.yn"));
		mav.addObject("ssoType", PropertiesUtil.getSecurityProperties().getProperty("sso.type"));
		mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));*/
		return mav;
	}

	
	@RequestMapping(value = "covics/getCsList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCsList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String listType = request.getParameter("listType");
			String folderID = getFolderID(StringUtil.replaceNull(listType));
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("listType", listType);
			params.put("searchText", request.getParameter("searchText"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", StringUtil.replaceNull(listType).equals("notice") ? 8 : StringUtil.replaceNull(listType).equals("news") ? 4 : 5);
			
			resultList = coviCsSvc.getCsList(params);

			if (resultList.get("page") != null){
				returnList.put("page", resultList.get("page"));
			}	

			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "covics/getCsContents.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCsContents(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String listType = request.getParameter("listType");
			String folderID = getFolderID(StringUtil.replaceNull(listType));

			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("listType", listType);
			params.put("messageID", request.getParameter("messageID"));
			CoviMap resultMap = coviCsSvc.getCsContents(params);
			if (StringUtil.replaceNull(listType).equals("news")){
				String bizSection = resultMap.getString("ServiceType");
				String fileName = resultMap.getString("SavedName");
				String companyCode = resultMap.getString("CompanyCode");
				String filePath = resultMap.getString("FilePath");
				
//				params.Body
				// 미사용.. 추후 사용시 fileID,StorageID 로 경로 조회하도록 변경 필요
				//filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + bizSection + File.separator + filePath + fileName;
				resultMap.put("FilePath", filePath);		
			}
			returnList.put("data", resultMap);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "covics/photo.do", method = RequestMethod.GET)
	public void loadImage(HttpServletResponse response, HttpServletRequest request ) throws Exception {
		CoviMap params = new CoviMap();
		String listType = request.getParameter("listType")==null?"news":request.getParameter("listType");
		String folderID = getFolderID(listType);
	    try{
	    	params.put("folderID", folderID);
			params.put("listType", listType);
			params.put("messageID", request.getParameter("messageID"));
			CoviMap resultMap = coviCsSvc.getCsContentsFile(params);
			String bizSection   = "Board";
			String fileExtension = resultMap.getString("Extention");
			String fileName = resultMap.getString("SavedName");
			String companyCode = resultMap.getString("CompanyCode");
			String filePath = resultMap.getString("FilePath");
//			filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + bizSection + File.separator + filePath + fileName;
//			loadImage(response, companyCode, filePath, fileExtension, "");
			
			String fileURL = resultMap.getString("StorageFilePath").replace("{0}", companyCode) + filePath + fileName; 
			
			//filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + bizSection + File.separator + filePath + fileName;
			filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileURL;

			fileUtilSvc.loadImageByPath(response, companyCode, filePath, fileURL, fileExtension, "");
	    }
	    catch(NullPointerException e) {
	    	LOGGER.error("FileUtilCon", e);
	    }
	    catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    }
	}
	/*
	private void loadImage(HttpServletResponse response, String companyCode, String imgpath, String fileExtension, String errorImg) throws Exception {
		InputStream in = null;
	    OutputStream os = null;
	    try{
			String filePath = imgpath;
			//System.out.println("#######filePath:"+filePath);
	        // 파일을 읽어 스트림에 담기
		    File file = null;
		    if (!filePath.equals("")){
		    	file = new File(filePath);
		    }
			//System.out.println("[photo.do]file.exists():"+file.exists());
			//System.out.println("[photo.do]file.isDirectory():"+file.isDirectory());
		    if(file == null || !file.exists() || file.isDirectory()){
				filePath = FileUtil.getBackPath(companyCode)+errorImg;
				file = new File(filePath);
		    }
		    in = new FileInputStream(filePath);
		    
	        // 파일 다운로드 헤더 지정
            response.setHeader("Content-Length", file.length()+"" );
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
            //JSYun:Memory분산처리 종료
            
            os.flush();
            os.close();
	    }catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    } finally {
	    	if(in != null){ 
	    		try{in.close();} catch(Exception e1){}
	    	}
	    	if(os != null){
	    		try{os.close();} catch(Exception e1){}
	    	}
	    }
	}*/
	
	@RequestMapping(value = "covics/loginImg.do", method = RequestMethod.GET)
	public void loginImg(HttpServletResponse response, HttpServletRequest request) throws Exception {
		String companyCode =  request.getParameter("domainCode");
		String fileID = "PC_Login";
		String fileExtension = fileID.substring(fileID.lastIndexOf(".") + 1,				fileID.length());
		
		String fileURL = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("LogoImage_SavePath")  +  fileID;
		String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileURL;
//		String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("LogoImage_SavePath")  +  fileID;
//		loadImage(response, companyCode, filePath, fileExtension, "banner.jpg");

		fileUtilSvc.loadImageByPath(response, companyCode, filePath, fileURL, fileExtension, "banner.jpg");		
	}
	
	@RequestMapping(value = "covics/loadPdfPhoto.do", method = RequestMethod.GET)
	public void loadPdfImage(HttpServletResponse response, HttpServletRequest request ) throws Exception {
		String img = StringUtil.replaceNull(request.getParameter("img"));
	    try{
	    	InputStream in = null;
	    	OutputStream os = null;

		    try{
				String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + img  ;
				filePath = FileUtil.checkTraversalCharacter(filePath);
		        // 파일을 읽어 스트림에 담기
			    File file = null;
			    if (!filePath.equals("")){
			    	file = new File(FileUtil.checkTraversalCharacter(filePath));
			    }
			    if(file == null || !file.exists()){
			    	return;
			    }
			    in = new FileInputStream(FileUtil.checkTraversalCharacter(filePath));
			    String fileExtension = StringUtil.replaceNull(img).substring(StringUtil.replaceNull(img).lastIndexOf(".") + 1, StringUtil.replaceNull(img).length());
		        // 파일 다운로드 헤더 지정
		        response.reset();
	            response.setHeader("Content-Length", file.length()+"" );
				//썸네일 jpg 고정
	            if(fileExtension.equals("png")){
					response.setContentType("image/png");
				} else if(fileExtension.equals("gif")){
					response.setContentType("image/gif");
				} else if(fileExtension.equals("bmp")){
					response.setContentType("image/bmp");
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
	            //JSYun:Memory분산처리 종료
	            
	            os.flush();
		    }
		    catch(NullPointerException e) {
		    	LOGGER.error("NullPointerException", e);
		    }
		    catch(Exception e){
		      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
		    		// 해당 에러 외의 에러 처리
		    	  //LOGGER.error("", e);
		      }
		    } 
		    finally {
		    	if(in != null){ 
		    		try{in.close();} 
					catch(IOException e){ LOGGER.error(e.getLocalizedMessage(), e); } 
					catch(Exception e1){ LOGGER.error(e1.getLocalizedMessage(), e1); }
		    	}
		    	if(os != null){
		    		try{os.close();} 
					catch(IOException e){ LOGGER.error(e.getLocalizedMessage(), e); } 
					catch(Exception e1){ LOGGER.error(e1.getLocalizedMessage(), e1); }
		    	}
		    }
	    }
	    catch(NullPointerException e) {
	    	LOGGER.error("NullPointerException", e);
	    }
	    catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    }
	}
	private static String getFolderID(String listType){
		/*			folderID = "6493";
		folderID = "6510";
		folderID = "6495";*/
		return RedisDataUtil.getBaseConfig("Cs"+listType.substring(0,1).toUpperCase()+listType.substring(1));
	}
}
