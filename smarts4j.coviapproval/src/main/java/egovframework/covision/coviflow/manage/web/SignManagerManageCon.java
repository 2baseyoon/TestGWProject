package egovframework.covision.coviflow.manage.web;


import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.admin.service.SignManagerSvc;



@Controller
public class SignManagerManageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(SignManagerManageCon.class);
	
	@Autowired
	private SignManagerSvc signManagerSvc;

	@Autowired
	private FileUtilService fileUtilService;
	
	private static final String SERVICE_TYPE = "ApprovalSign";
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getSignList : 서명관리 - 서명 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getSignList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSignList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String entCode = request.getParameter("EntCode");		
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
		
			CoviMap params = new CoviMap();
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);			
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = signManagerSvc.getSignList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goSignManagerSetPopup : 서명관리 - 서명 설정 팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goSignManagerSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goSignManagerSetPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/SignManagerSetPopup";		
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getSignData : 서명관리 - 특정 사용자의 서명 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getSignData.do", method=RequestMethod.POST)
	public ResponseEntity<CoviMap> getSignData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		try {				
			String userCode = request.getParameter("UserCode");
			String isUse = request.getParameter("IsUse");
			
			CoviMap params = new CoviMap();		
			params.put("UserCode", userCode);		
			params.put("IsUse", isUse);
			returnObj.put("result", signManagerSvc.getSignData(params));
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}
		return ResponseEntity.ok(returnObj);
	}
	
	/**
	 * insertSignData : 서명관리 - 서명 추가
	 * @param req MultipartHttpServletRequest
	 * @return mav
	 */	
	@RequestMapping(value = "manage/insertSignData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertSignData(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String userCode =  req.getParameter("UserCode");
			MultipartFile file = req.getFile("MyFile");			

			// 파일 중복명 처리 - 뒤에 index 붙이는 처리 필요
			// 본래 파일명
			String fileName = file.getOriginalFilename();
			String fileExt = FilenameUtils.getExtension(fileName);
			long fileSize = file.getSize();
			
			validateFile(fileName, fileExt, fileSize);

			List<MultipartFile> list = new ArrayList<>();
			list.add(file);
			CoviList savedArray = fileUtilService.uploadToBack(null, list, null, SERVICE_TYPE, "0", "NONE", "0", false, false);
			CoviMap savedFile = savedArray.getJSONObject(0);
			int fileId = savedFile.getInt("FileID");
			
			CoviMap params = new CoviMap();
			params.put("UserCode" , userCode);
			params.put("FileName", fileName);
			params.put("FilePath", "");
			params.put("FileID", fileId);
			
			signManagerSvc.insertSignData(params);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	/**
	 * deleteSignImage : 서명관리 - 서명 삭제
	 * @param request HttpServletRequest
	 * @param paramMap  Map<String, String>
	 * @return mav
	 */	
	@RequestMapping(value = "manage/deleteSignImage.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteSignImage(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			String userCode   = request.getParameter("UserCode");
			String fileID   = request.getParameter("FileID");
			
			CoviMap params = new CoviMap();
			params.put("UserCode",userCode);
			params.put("FileID",fileID);
			
			returnList.put("object", signManagerSvc.deleteSignImage(params));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	@RequestMapping(value = "manage/signUpload.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap signUpload(HttpServletRequest request,
			@RequestParam(value = "strImg", required = true) String strImg) throws Exception {
		
		String logonID = SessionHelper.getSession("USERID");
		
		// 저장 경로 설정
		String rootPath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code"));

		String uploadPath = rootPath + RedisDataUtil.getBaseConfig("SignImage_SavePath");

		String fullPath = "";
		String[] strParts = strImg.split(",");
		String rstStrImg = strParts[1]; // ,로 구분하여 뒷 부분 이미지 데이터를 임시저장
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		String fileName = "sign_" + logonID + "_" + sdf.format(new Date());
		String isUse = "N";
		
		int fileIndex = getFileIndex(uploadPath, fileName);
		
		fileName = fileName + "_" + fileIndex + ".jpg";
		BufferedImage image = null;
		byte[] byteImg;
		
		byteImg = Base64.decodeBase64(rstStrImg); // base64 디코더를 이용하여 byte 코드로 변환
		ByteArrayInputStream bis = new ByteArrayInputStream(byteImg);
		image = ImageIO.read(bis); // BufferedImage형식으로 변환후 저장
		bis.close();
		fullPath = uploadPath + fileName;
		File folderObj = new File(uploadPath);
		
		boolean bmkdir = true;
		if (!folderObj.isDirectory())
			bmkdir= folderObj.mkdir();

		if(bmkdir) {
			BufferedImage convertImage;
			try {
				convertImage = image;
				BufferedImage newImage = new BufferedImage(convertImage.getWidth(), convertImage.getHeight(), BufferedImage.TYPE_INT_RGB);
				newImage.createGraphics().drawImage(image, 0, 0, Color.WHITE, null);
				ImageIO.write(newImage, "jpg", new File(fullPath));
			} catch(IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}
		
		// DB처리
		CoviMap params = new CoviMap();
		params.put("UserCode", logonID);
		params.put("FileName", fileName);
		params.put("FilePath", RedisDataUtil.getBaseConfig("SignImage_SavePath") + fileName);
		params.put("IsUse", isUse);
		
		CoviMap returnList = new CoviMap();
		returnList.put("object", signManagerSvc.insertSignData(params));
		returnList.put("result", "ok");

		returnList.put("status", Return.SUCCESS);
		returnList.put("message", "저장되었습니다.");
		
		return returnList;
	}		
	
	public int getFileIndex(String pPath, final String pFileName) {
		File path = new File(pPath); 	// 검색할 폴더 지정
		String[] fileList = path.list((dir, name) -> name.contains(pFileName));
		int fileIndex = 0;
		if(fileList != null)
			fileIndex = fileList.length;
		return fileIndex;
	}
	
	// 모바일 서명 조회
	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명등록: 사용자 서명 목록 조회
	 * @param request HttpServletRequest
	 * @param logonID String
	 * @param strImg String
	 * @return returnList CoviMap
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getUserSignList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserSignList(HttpServletRequest request,
			@RequestParam(value = "logonID", required = true) String logonID,
			@RequestParam(value = "fileName", required = true) String strImg) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String userCode = SessionHelper.getSession("USERID");
			CoviMap params = new CoviMap();
			params.put("UserCode",userCode);
			
			CoviMap resultList = signManagerSvc.getSignList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
			return returnList;
	}
	
	// 서명 박스를 탭하여, 사용 할 서명 선택 함수
	/**
	 * changeUseSign : 사용 결재 사인 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/changeUseSign.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap changeUseSign(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {

		String userCode = request.getParameter("UserCode");
		String fileName = request.getParameter("FileName");

		// DB처리
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("FileName", fileName);
		params.put("IsUse", "Y");

		// 모든 IsUse 값 "N" 변경
		signManagerSvc.releaseUseSign(params);

		CoviMap returnList = new CoviMap();
		returnList.put("object", signManagerSvc.changeUseSign(params)); // 대표 사인 변경
		returnList.put("result", "ok");
		returnList.put("status", Return.SUCCESS);
		returnList.put("message", "저장되었습니다.");

		return returnList;
	}
	
	private void validateFile(String fileName, String fileExt, long fileSize) {
		if (fileSize <= 0) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_noFile"));
		}
		if (fileName.contains("_")) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_apv_FileName"));
		}
		if (fileName.contains(";")) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_apv_FileName2"));
		}
		if (fileName.length() > 20) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_207"));
		}
		if (!fileExt.equalsIgnoreCase("gif") && !fileExt.equalsIgnoreCase("jpg")
				&& !fileExt.equalsIgnoreCase("bmp") && !fileExt.equalsIgnoreCase("png")) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_apv_Image_Warning"));
		}
		if (fileSize / 1024 > 500) {
			throw new IllegalArgumentException(DicHelper.getDic("msg_apv_Image_size_Warning"));
		}
	}
}
