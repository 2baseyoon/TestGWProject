package egovframework.covision.coviflow.user.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.coviflow.user.service.SignRegistrationSvc;



/**
 * @Class Name : SignRegistrationCon.java
 * @Description : 사용자 메뉴 > 서명등록 요청 처리 @ 2016.10.27 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class SignRegistrationCon {

	@Autowired
	private AuthHelper authHelper;

	private static final Logger LOGGER = LogManager.getLogger(SignRegistrationCon.class);

	@Autowired
	private SignRegistrationSvc signRegistrationSvc;

	@Autowired
	private FileUtilService fileUtilService;

	private static final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static final String SERVICE_TYPE = "ApprovalSign";

	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명등록: 사용자 서명 목록 조회
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserSignList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserSignList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			// 현재 사용자 ID
			String userCode = SessionHelper.getSession("USERID");
			CoviMap params = new CoviMap();

			params.put("UserCode", userCode);

			CoviMap resultList = signRegistrationSvc.selectUserSignList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	/**
	 * getUserSignImage : 사용자 메뉴 - 개인환경설정 - 서명수정: 사용자 서명 이미지 조회
	 * 
	 * @param request
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserSignImage.do", method = RequestMethod.GET)
	public ResponseEntity<CoviMap> selectUserSignImage(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
			// 현재 사용자 ID
			String signID = request.getParameter("signID");
			CoviMap params = new CoviMap();
			params.put("signID", signID);

			CoviMap result = signRegistrationSvc.selectUserSignImage(params);
			
			String userCode = SessionHelper.getSession("USERID"); 
			if(!userCode.equals(result.getString("UserCode"))){
				throw new IllegalStateException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
			}
			
			returnObj.put("result", result);
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnObj);
		}

		return ResponseEntity.ok(returnObj);
	}

	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명삭제: 사용자 서명 삭제
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteUserSign.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserSign(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String signID = request.getParameter("SignID");
			String isUse = request.getParameter("isUse");
			String userCode = request.getParameter("UserCode");

			CoviMap params = new CoviMap();
			params.put("SignID", signID);
			params.put("IsUse", isUse);
			params.put("UserCode", userCode);

			returnList.put("object", signRegistrationSvc.deleteUserSign(params));

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");

		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명사용여부 변경: 사용자 서명 사용여부 변경
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/changeUserSignUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap changeUserSignUse(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnList = new CoviMap();

		try {
			String userCode = SessionHelper.getSession("USERID");
			String signID = request.getParameter("SignID");

			CoviMap params = new CoviMap();

			params.put("UserCode", userCode);
			params.put("SignID", signID);

			int result = signRegistrationSvc.updateUserSignUse(params);

			returnList.put("data", result);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명등록: 사용자 서명 등록
	 * 
	 * @param request
	 * @param response
ㄴ	 * @return returnList
	 * @throws Exception 파일을 첨부 파일 저장 위치에 저장해야 하지만 현재 저장소의 위치가 정해지지 않았기 때문에 후에 파일
	 *                   저장과 DB에 저장하는 과정을 끊기지 않도록 트랜잭션 처리
	 */
	@RequestMapping(value = "user/insertUserSign.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> insertUserSign(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnList = new CoviMap();

		try {

			MultipartFile file = request.getFile("MyFile");
			String userCode = SessionHelper.getSession("USERID");
			String isUse = request.getParameter("IsUse");
			
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
			params.put("IsUse", isUse);
			params.put("UserCode", userCode);
			params.put("FileName", fileName);
			params.put("FilePath", "");
			params.put("FileID", fileId);
			signRegistrationSvc.insertUserSign(params);
			
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			//return ResponseEntity.badRequest().body(returnList);
			return ResponseEntity.ok(returnList);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			//return ResponseEntity.badRequest().body(returnList);
			return ResponseEntity.ok(returnList);
		}

		return ResponseEntity.ok(returnList);
	}

	/**
	 * updateUserSign : 사용자 메뉴 - 개인환경설정 - 서명수정: 사용자 서명 수정
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception 파일을 첨부 파일 저장 위치에 저장해야 하지만 현재 저장소의 위치가 정해지지 않았기 때문에 후에 파일
	 *                   저장과 DB에 저장하는 과정을 끊기지 않도록 트랜잭션 처리
	 */
	@RequestMapping(value = "user/updateUserSign.do", method = RequestMethod.POST)
	public ResponseEntity<CoviMap> updateUserSign(MultipartHttpServletRequest req, HttpServletRequest request,
			HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {

		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		try {
			String userCode = SessionHelper.getSession("USERID");
			String isUse = request.getParameter("IsUse");
			String signID = request.getParameter("SignID");

			MultipartFile file = req.getFile("MyFile");
			
			if(file != null) {
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
				params.put("FileName", fileName);
				params.put("FileID", fileId);
			}
			
			params.put("UserCode", userCode);
			params.put("IsUse", isUse);
			params.put("SignID", signID);
			int result = signRegistrationSvc.updateUserSign(params);

			returnList.put("data", result);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		}

		return ResponseEntity.ok(returnList);
	}

	/**
	 * getUserSignList : 사용자 메뉴 - 개인환경설정 - 서명등록: 서명등록 팝업
	 * 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "user/goSignRegistrationPopup.do", method = RequestMethod.GET)
	public ModelAndView goRightApprovalJobFunctionSetPopup(Locale locale, Model model) {
		String returnURL = "user/approval/SignRegistrationPopup";
		return new ModelAndView(returnURL);
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
