package egovframework.core.web;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
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
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.PBE;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.DevHelperSvc;
import egovframework.core.sevice.LoginSvc;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.SeedUtil;
import egovframework.coviframework.util.SessionCommonHelper;
import  egovframework.baseframework.util.LicenseHelper;
/**
 * @Class Name : DevHelperCon.java
 * @Description : 개발자 지원
 * @Modification Information 
 * @ 2016.04.05 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.06
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class DevHelperCon {

	private Logger LOGGER = LogManager.getLogger(DevHelperCon.class);
	
	@Autowired
	private LoginSvc loginsvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private EditorService editorService; 
	
	@Autowired
	private DevHelperSvc devHelperSvc; 
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//devhelper - grid
	@RequestMapping(value = "devhelper/grid.do", method = RequestMethod.GET)
	public ModelAndView devhelper_gridpage(Locale locale, Model model) {
		String returnURL = "admin/devhelper/grid";
		
		String headerData = "[{key:'seq', label:'seq',width:'100',align:'center'},{key:'subject',label:'제목', width:'200', align:'left'},{key:'registDate',  label:'작성일', width:'100', align:'center'},{key:'register', label:'작성자', width:'100', align:'center'}]";
		String listData = "[{seq:'1', subject:'2월 산악회 등산 사진', registDate:'2016-02-29', register:'김사랑',img:'test/1.jpg'},{seq:'2', subject:'5월 산악회 등산 사진', registDate:'2016-02-29', register:'김사랑2',img:'test/2.jpg'},{seq:'3', subject:'3월 산악회 등산 사진', registDate:'2016-03-01', register:'김사랑3',img:'test/3.PNG'},{seq:'4', subject:'Grid Test 내용입니다.', registDate:'2016-05-01', register:'김사랑3',img:'test/1.PNG'},{seq:'5', subject:'제목이 길면 어떻게 되나 테스트 내용입니다.아아아아아아아아아', registDate:'2016-05-01', register:'김사랑3',img:'test/3.PNG'},{seq:'6', subject:'merge cell', registDate:'2016-06-01', register:'김사랑3',img:'test/3.PNG'},{seq:'7', subject:'merge cell', registDate:'2016-07-01', register:'김사랑3',img:'test/3.PNG'},{seq:'8', subject:'8월 산악회 등산 사진', registDate:'2016-08-01', register:'김사랑3',img:'test/3.PNG'},{seq:'9', subject:'9월 산악회 등산 사진', registDate:'2016-09-01', register:'김사랑3',img:'test/3.PNG'},{seq:'10', subject:'10월 산악회 등산 사진', registDate:'2016-10-01', register:'김사랑3',img:'test/3.PNG'},{seq:'11', subject:'11월 산악회 등산 사진', registDate:'2016-11-01', register:'김사랑3',img:'test/3.PNG'},{seq:'12', subject:'12월 산악회 등산 사진', registDate:'2016-12-01', register:'김사랑3',img:'test/3.PNG'}]";
		 
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("headerdata", headerData);
		mav.addObject("listdata", listData);
				
		return mav;
	}
	
	//devhelper - layer popup
	@RequestMapping(value = "devhelper/layerpopup.do", method = RequestMethod.GET)
	public ModelAndView devhelper_layerpopuppage(Locale locale, Model model) {
		String returnURL = "admin/devhelper/layerpopup";

		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	//devhelper - Grid test data
	@RequestMapping(value = "/gridtestdata.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap gridtestdata(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnList = new CoviMap();
		String strList = "{\"page\":{\"pageNo\":1,\"pageSize\":6,\"pageCount\":\"2\",\"listCount\":9},\"list\":[{\"id\":\"U5ADMGROUP\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U500SALES4\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U500SALES3\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U500SALES1\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U5000DELAY\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U50000MAIL\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U50000LAB1\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U500000LAB\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0},{\"id\":\"U4ADMGROUP\",\"name\":\"\",\"status\":\"A\",\"quota\":0,\"messagesize\":0,\"messagecount\":0}]}";
		
		returnList = CoviMap.fromObject(strList);
				
		return returnList;
	}
	
	//devhelper - 팝업테스트
	@RequestMapping(value = "/layerpopuptest.do", method = RequestMethod.GET)
	public ModelAndView layerpopuptest(Locale locale, Model model) {
		String returnURL = "admin/devhelper/layerpopupcontents";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	//devhelper - 팝업테스트2
	@RequestMapping(value = "/layerpopuptest2.do", method = RequestMethod.GET)
	public ModelAndView layerpopuptest2(Locale locale, Model model) {
		String returnURL = "admin/devhelper/layerpopupcontents2";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	//devhelper 공통
	@RequestMapping(value = "devhelper/{path}.do", method = RequestMethod.GET)
	public ModelAndView devhelper_page(@PathVariable String path, Locale locale, Model model) {
		String returnURL = "core/devhelper/" + path;

		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	//tutorial
	@RequestMapping(value = "devhelper/tutorial_{path}.do", method = RequestMethod.GET)
	public ModelAndView devhelper_tutorialpage(@PathVariable String path, Locale locale, Model model) {
		String returnURL = "admin/devhelper/tutorial_axisj";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("mode",path);
				
		return mav;
	}
	
	//관리자 메뉴 Redis Cache Delete
	@RequestMapping(value = "devhelper/rediscachedelete.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap devhelper_redisCacheDelete(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String redisKey = request.getParameter("redisID");
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		if(redisKey != null && !redisKey.isEmpty()){
			instance.remove(redisKey);
		}
		
		returnList.put("status", Return.SUCCESS);
	
		return returnList;
	}
	
	@RequestMapping(value = "devhelper/encrypt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap encryptAPI(HttpServletRequest request, HttpServletResponse response) {

		CoviMap returnList = new CoviMap();
		
		try{
			String encrypted = "";
			String key = "";
			if(request.getParameter("algorithm") != null && request.getParameter("text") != null){
				String paramAlg = request.getParameter("algorithm");
				String paramTxt = request.getParameter("text");
				
				switch(paramAlg){
				
				case "PBE" :
					key = PropertiesUtil.getSecurityProperties().getProperty("sec.pbe.key");
					encrypted = PBE.encode(paramTxt, key);
					break;
					
				case "AES" :
					key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
					AES aes = new AES(key, "N");
					encrypted = aes.encrypt(paramTxt);
					break;
					
				case "SEED" :
					encrypted = SeedUtil.getSeedEncryptString(paramTxt);
					break;
					
				case "BASE" :
					encrypted = new String(Base64.encodeBase64(paramTxt.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					break;
					
				default :
					break;
				
				}
				
			}
			
			returnList.put("result", encrypted);
			returnList.put("status", Return.SUCCESS);
			
		}
		catch (NullPointerException e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "devhelper/decrypt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap decryptAPI(HttpServletRequest request, HttpServletResponse response) {

		CoviMap returnList = new CoviMap();
		
		try{
			String decrypted = "";
			String key = "";
			if(request.getParameter("algorithm") != null && request.getParameter("text") != null){
				String paramAlg = request.getParameter("algorithm");
				String paramTxt = request.getParameter("text");
				
				switch(paramAlg){
				
				case "PBE" :
					key = PropertiesUtil.getSecurityProperties().getProperty("sec.pbe.key");
					decrypted = PBE.decode(paramTxt, key);
					break;
					
				case "AES" :
					key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
					AES aes = new AES(key, "N");
					decrypted = aes.decrypt(paramTxt);
					break;
					
				case "SEED" :
					decrypted = SeedUtil.getSeedDecryptString(paramTxt);
					break;
					
				case "BASE" :
					decrypted = new String(Base64.decodeBase64(paramTxt.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					break;
					
				default :
					break;
				
				}
				
			}
			
			returnList.put("result", decrypted);
			returnList.put("status", Return.SUCCESS);
			
		}
		catch (NullPointerException e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//개발지원 sample code: get Back FileList
	@RequestMapping(value = "devhelper/fileupload/getBackFileList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBackFileList(HttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			// 각 모듈에서 조회 시 메시지들을 구분 가능하도록 지정 (covi_smart4j.sys_file 테이블 참고)
			params.put("ServiceType", "Devhelper");							// 서비스 유형 (ex. 게시판- Board, 일정 - Schedule, 전자결재 - Approval 등)
			params.put("ObjectID", "0");								// 메시지를 소유한 객체 아이디
			params.put("ObjectType", "NONE");							// 메시지를 소유한 객체 유형 (ex. FD:폴더)
			params.put("MessageID", "0");								// 메시지 아이디
			params.put("Version", request.getParameter("version"));		// Version 없을 경우 생략 가능
			
			returnList.put("fileList", fileSvc.selectAttachAll(params));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//개발지원 sample code: move to Back from Front  
	@RequestMapping(value = "devhelper/fileupload/moveToBack.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap moveToBack(HttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList frontFileInfos = CoviList.fromObject(request.getParameter("frontFileInfos"));
			
			returnList.put("list", fileSvc.moveToBack(frontFileInfos, "Devhelper/", "Devhelper", "0", "NONE", "0")); 
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//개발지원 sample code: upload to Back  
	@RequestMapping(value = "devhelper/fileupload/uploadToBack.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap uploadToBack(MultipartHttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList fileInfos = CoviList.fromObject(request.getParameter("fileInfos"));
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			/*
			 * 게시판과 같이 버전이 있을 경우 아래와 같이 변경
			 * fileSvc.uploadToBack(fileInfos, mf, "Devhelper/", "Devhelper", "0", "NONE", "0", "0")
			 */
			
			returnList.put("list", fileSvc.uploadToBack(fileInfos, mf, "Devhelper/", "Devhelper", "0", "NONE", "0"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	//개발지원 sample code: upload to Back Editor Inline Images
	@RequestMapping(value = "devhelper/editor/uploadToBackInlineImage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap uploadToBackInlineImage(HttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap editorParam = new CoviMap();
			
			// 각 모듈에서 조회 시 메시지들을 구분 가능하도록 지정 (covi_smart4j.sys_file 테이블 참고)
			editorParam.put("serviceType", "Devhelper");  							// 서비스 유형 (ex. 게시판- Board, 일정 - Schedule, 전자결재 - Approval 등)
			editorParam.put("objectID", "0");     								// 메시지를 소유한 객체 아이디
			editorParam.put("objectType", "NONE");     							// 메시지를 소유한 객체 유형 (ex. FD:폴더)
			editorParam.put("messageID", "0");  								// 메시지 아이디

			editorParam.put("imgInfo", request.getParameter("inlineImages"));    // Inline Images 정보
			editorParam.put("bodyHtml",  request.getParameter("bodyHtml"));   	// Editor 본문 HTML

			/*
			 * CoviMap editorInfo = editorService.getEscapeContent(editorParam); 
			 * 게시판의 경우 스크립트 단에서 bodyHtml을 escape() 처리하기 때문에 기능은 동일한 별도의 메소드 구현
			 * 게시판 외의 모듈에서는 getContent 메소드 사용
			 * 
			 * return 값
			 * BodyHtml - 본문 내 인라인 이미지 경로가 FrontStorage에서 BackStorage로 변경된 HTML 
			 * FileID - 인라인 이미지 별로 추가된 File의 ID로 구분자는 , (covi_smart4j.sys_file 의 FileID)
			 * result- 결과( SUCCESS or FAIL)
			 */
			
			//예제이기 때문에 기존 인라인 이미지 삭제
			editorService.deleteInlineFile(editorParam);
			
			CoviMap editorInfo = editorService.getContent(editorParam); 
			
			//TODO editorInfo의 bodyHtml로 본문 저장
			
			/*
			 * TODO covi_smart4j.sys_file 에 MessageID 값 수정
			 * 대부분 모듈이 게시물 추가 후  messageID를 받을 수 있기 때문에 게시물 추가 후 sys_file의 MessageID 업데이트(수정일 경우 생략)
			 * 
			 *  editorParam.put("messageID", "추가된 MessageID");    
			 *  editorParam.put("FileID", editorInfo.getString("FileID"));   
			 *  
			 *  editorService.updateFileMessageID(editorParam);
			 */
			
			returnList.put("bodyHtml", editorInfo.getString("BodyHtml"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭) isUse 버튼의 클릭 이벤트.
	@RequestMapping(value = "devhelper/updateModuleIsUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateModuleIsUse(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("ModuleID", (String)request.getParameter("ModuleID"));
			params.put("IsUse", (String)request.getParameter("IsUse"));
			params.put("regCode", SessionHelper.getSession("UR_Code"));
			
			if ( (params.get("ModuleID") != null) && !params.get("ModuleID").equals("") ) {
				returnObj.put("result", devHelperSvc.updateModuleIsUse(params));
			}
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭) isAdmin 버튼의 클릭 이벤트.
	@RequestMapping(value = "devhelper/updateModuleIsAdmin.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateModuleIsAdmin(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("ModuleID", (String)request.getParameter("ModuleID"));
			params.put("IsAdmin", (String)request.getParameter("IsAdmin"));
			params.put("regCode", SessionHelper.getSession("UR_Code"));
			
			if ( (params.get("ModuleID") != null) && !params.get("ModuleID").equals("") ) {
				returnObj.put("result", devHelperSvc.updateModuleIsAdmin(params));
			}
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭) isAudit 버튼의 클릭 이벤트.
	@RequestMapping(value = "devhelper/updateModuleIsAudit.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateModuleIsAudit(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("ModuleID", (String)request.getParameter("ModuleID"));
			params.put("IsAudit", (String)request.getParameter("IsAudit"));
			params.put("regCode", SessionHelper.getSession("UR_Code"));
			
			if ( (params.get("ModuleID") != null) && !params.get("ModuleID").equals("") ) {
				returnObj.put("result", devHelperSvc.updateModuleIsAudit(params));
			}
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}

	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 체크한 항목 모두 상태 변경하기.
	@RequestMapping(value = "devhelper/updateAllStatus.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateIsUseAll(@RequestBody Map<String, Object> params
			, HttpServletRequest request, HttpServletResponse response
			) {
		CoviMap returnObj = new CoviMap();
		List<Map> listJson = (List)params.get("dataList");
		String pType = (String)params.get("pType");
		CoviMap coviMap = new CoviMap();
		coviMap.put("regCode", SessionHelper.getSession("UR_Code"));
		
		try {
			int resultCnt = 0;
			for (int i=0; listJson.size()>i;i++ ) {
				coviMap.put("ModuleID", (String)listJson.get(i).get("ModuleID"));
				
				if (pType.equals("IsUse")) {
					coviMap.put("IsUse", (String)listJson.get(i).get("IsUse"));
					resultCnt += devHelperSvc.updateModuleIsUse(coviMap);
				} else if (pType.equals("IsAdmin")) {
					coviMap.put("IsAdmin", (String)listJson.get(i).get("IsAdmin"));
					resultCnt += devHelperSvc.updateModuleIsAdmin(coviMap);
				} else if (pType.equals("IsAudit")) {
					coviMap.put("IsAudit", (String)listJson.get(i).get("IsAudit"));
					resultCnt += devHelperSvc.updateModuleIsAudit(coviMap);
				} else {
					break;
				}
			}
			
			returnObj.put("result", resultCnt);
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), module tab 조회.
	@RequestMapping(value = "devhelper/getModuleDataList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getModuleDataList(
			HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("searchText", request.getParameter("searchText"));
			params.put("searchType", request.getParameter("searchType"));
			
			if (params.get("searchType").equals("detail")) {
				params.put("moduleId", request.getParameter("moduleId"));
				// 상세화면에서 moduleId에 매칭되는 program_map 테이블의 prmgId 정보를 조회.
				returnObj.put("listPrgm", devHelperSvc.selectModulePrgmMapList(params));
			} else {
				params.addAll(ComUtils.setPagingData(params, devHelperSvc.selectModuleDataCnt(params)));
			}
			
			returnObj.put("page", params);										// paging 데이터.
			returnObj.put("list", devHelperSvc.selectModuleDataList(params));	// data list 데이터.
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}

	// 관리자페이지 > 개발지원 > 모듈관리(가칭).
	@RequestMapping(value = "devhelper/getPrgmDataList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPrgmDataList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));

			if (params.get("searchType").equals("detail")) {
				params.put("prgmId", request.getParameter("prgmId"));
			} else {
				params.addAll(ComUtils.setPagingData(params, devHelperSvc.selectPrgmDataCnt(params)));
			}
			returnObj.put("page", params);										// paging 데이터.
			returnObj.put("list", devHelperSvc.selectPrgmDataList(params));		// data list 데이터.
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), program_map tab 조회.
	@RequestMapping(value = "devhelper/getPrgmMapDataList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPrgmMapDataList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));

			params.addAll(ComUtils.setPagingData(params, devHelperSvc.selectPrgmMapDataCnt(params)));
			
			returnObj.put("page", params);
			returnObj.put("list", devHelperSvc.selectPrgmMapDataList(params));		// data list 데이터.
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭).
	@RequestMapping(value = "devhelper/getPrgmMenuDataList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPrgmMenuDataList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));
			
			if (params.get("searchType").equals("detail")) {
				params.put("menuId", request.getParameter("menuId"));
			} else {
				// 데이터 조회.
				params.addAll(ComUtils.setPagingData(params, devHelperSvc.selectPrgmMenuDataCnt(params)));
			}
			
			returnObj.put("page", params);										// paging 데이터.
			returnObj.put("list", devHelperSvc.selectPrgmMenuDataList(params));		// data list 데이터.
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 추가 팝업.
	@RequestMapping(value="devhelper/modulemanagepop.do", method=RequestMethod.GET)
	public ModelAndView showModuleManagePop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "core/devhelper/ModuleManagePop";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 팝업, 메뉴정보 조회.
	@RequestMapping(value = "devhelper/getMenuDataList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMenuDataList(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchText", request.getParameter("searchText"));

			params.addAll(ComUtils.setPagingData(params, devHelperSvc.selectMenuDataCnt(params)));
			
			returnObj.put("page", params);										// paging 데이터.
			returnObj.put("list", devHelperSvc.selectMenuDataList(params));		// data list 데이터.
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 추가 팝업 저장.
	@RequestMapping(value = "devhelper/saveModuleManage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveModuleManage(@RequestBody Map<String, Object> params
			, HttpServletRequest request, HttpServletResponse response
			) {
		CoviMap returnObj = new CoviMap();
		CoviMap coviMap = new CoviMap();
		
		// 필수값 type이 없으면 에러 리턴.
		if ( params.get("type") == null || ((String)params.get("type")).equals("") ) {
			returnObj.put("status", Return.FAIL);
			return returnObj;
		}
		
		coviMap.put("type", (String)params.get("type"));
		coviMap.put("regCode", SessionHelper.getSession("UR_Code"));
		
		try {
			int resultCnt = 0;
			
			if ( coviMap.get("type").equals("module")) { 	// module 탭일 때.
				// 필수값 없을 시 에러 전송.
				if ( params.get("moduleId") == null || ((String)params.get("moduleId")).trim().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				
				// isUse, isAdmin, isAudit, isBlock 값이 null이면 'N'으로 변경.
				if (params.get("isUse") == null) {coviMap.put("isUse", 'N');} else {coviMap.put("isUse", (String)params.get("isUse"));}
				if (params.get("isAdmin") == null) {coviMap.put("isAdmin", 'N');} else {coviMap.put("isAdmin", (String)params.get("isAdmin"));}
				if (params.get("isAudit") == null) {coviMap.put("isAudit", 'N');} else {coviMap.put("isAudit", (String)params.get("isAudit"));}
				if (params.get("isBlock") == null) {coviMap.put("isBlock", 'N');} else {coviMap.put("isBlock", (String)params.get("isBlock"));}
				
				coviMap.put("url", (String)params.get("url"));
				coviMap.put("moduleId", (String)params.get("moduleId"));
				coviMap.put("moduleName", (String)params.get("moduleName"));
				coviMap.put("auditClass", (String)params.get("auditClass"));
				coviMap.put("bizSection", (String)params.get("bizSection"));
				coviMap.put("auditMethod", (String)params.get("auditMethod"));
				coviMap.put("description", (String)params.get("description"));
				
				coviMap.put("searchType", "pkChk"); 	// 등록 이전에 sys_object_module의 pk를 미리 조회.
				resultCnt = devHelperSvc.selectModuleDataCnt(coviMap);
				if (resultCnt == 0) {
					resultCnt = devHelperSvc.insertModuleData(coviMap);
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.SUCCESS);
				} else {
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.FAIL);
				}
			} else if (coviMap.get("type").equals("modulePrgmMap")) { 	// module tab에서 program_map 까지 입력.
				// 필수값 없을 시 에러 전송.
				if ( params.get("moduleId") == null || ((String)params.get("moduleId")).trim().length() == 0
						|| params.get("prgmId") == null || ((String)params.get("prgmId")).trim().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				// isUse, isAdmin, isAudit, isBlock 값이 null이면 'N'으로 변경.
				if (params.get("isUse") == null) {coviMap.put("isUse", 'N');} else {coviMap.put("isUse", (String)params.get("isUse"));}
				if (params.get("isAdmin") == null) {coviMap.put("isAdmin", 'N');} else {coviMap.put("isAdmin", (String)params.get("isAdmin"));}
				if (params.get("isAudit") == null) {coviMap.put("isAudit", 'N');} else {coviMap.put("isAudit", (String)params.get("isAudit"));}
				if (params.get("isBlock") == null) {coviMap.put("isBlock", 'N');} else {coviMap.put("isBlock", (String)params.get("isBlock"));}
				
				coviMap.put("url", (String)params.get("url"));
				coviMap.put("moduleId", (String)params.get("moduleId"));
				coviMap.put("moduleName", (String)params.get("moduleName"));
				coviMap.put("auditClass", (String)params.get("auditClass"));
				coviMap.put("bizSection", (String)params.get("bizSection"));
				coviMap.put("auditMethod", (String)params.get("auditMethod"));
				coviMap.put("description", (String)params.get("description"));
				coviMap.put("prgmId", (String)params.get("prgmId"));
				coviMap.put("moduleId", (String)params.get("moduleId"));
				coviMap.put("searchType", "pkChk");
				
				// 중복체크
				resultCnt = devHelperSvc.selectModuleDataCnt(coviMap);
				resultCnt += devHelperSvc.selectPrgmMapDataCnt(coviMap);
				if (resultCnt == 0) {
					resultCnt = devHelperSvc.insertModuleData(coviMap);
					resultCnt += devHelperSvc.insertPrgmMapData(coviMap);
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.SUCCESS);
				} else {
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.FAIL);
				}
				
			} else if (coviMap.get("type").equals("prgm")) {
				// 필수값 체크.
				if ( params.get("prgmId") == null || ((String)params.get("prgmId")).trim().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				
				coviMap.put("prgmId", (String)params.get("prgmId"));
				coviMap.put("searchType", "pkChk");
				// PrgmID 중복 체크.
				resultCnt = devHelperSvc.selectPrgmDataCnt(coviMap);
				
				if (resultCnt > 0) {
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.FAIL);
				} else {
					coviMap.put("prgmName", (String)params.get("prgmName"));
					resultCnt = devHelperSvc.insertPrgmData(coviMap);
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.SUCCESS);
				}
			} else if (coviMap.get("type").equals("prgmMap")) {
				// 필수값 체크.
				if (params.get("prgmId") == null || ((String)params.get("prgmId")).trim().length() == 0
						|| params.get("moduleId") == null || ((String)params.get("moduleId")).trim().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				coviMap.put("prgmId", (String)params.get("prgmId"));
				coviMap.put("moduleId", (String)params.get("moduleId"));
				coviMap.put("searchType", "pkChk");
				// 중복체크
				resultCnt = devHelperSvc.selectPrgmMapDataCnt(coviMap);
				if (resultCnt > 0) {
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.FAIL);
				} else {
					resultCnt = devHelperSvc.insertPrgmMapData(coviMap);
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.SUCCESS);
				}
			} else if (coviMap.get("type").equals("prgmMenu")) {
				// 필수값 체크.
				if (params.get("menuId") == null || ((String)params.get("menuId")).trim().length() == 0
						|| params.get("prgmId") == null || ((String)params.get("prgmId")).trim().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				coviMap.put("menuId", (String)params.get("menuId"));
				coviMap.put("prgmId", (String)params.get("prgmId"));
				coviMap.put("searchType", "pkChk");
				// 중복체크
				resultCnt = devHelperSvc.selectPrgmMenuDataCnt(coviMap);
				if (resultCnt > 0) {
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.FAIL);
				} else {			
					resultCnt = devHelperSvc.insertPrgmMenuData(coviMap);
					returnObj.put("result", resultCnt);
					returnObj.put("status", Return.SUCCESS);
				}
			}
		}
		catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 체크한 항목 모두 삭제하기.
	@RequestMapping(value = "devhelper/delModuleData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteModuleData(@RequestBody Map<String, Object> params
			, HttpServletRequest request, HttpServletResponse response
			) {
		CoviMap returnObj = new CoviMap();
		List<Map> listJson = (List)params.get("dataList");
		String pType = (String)params.get("pType");
		CoviMap coviMap = new CoviMap();
	
		try {
			int resultCnt = 0;
			
			for (int i=0; listJson.size()>i;i++ ) {
				if (pType.equals("tabMenu02")) { 	// module tab.
					coviMap.put("ModuleID", (String)listJson.get(i).get("ModuleID"));
					coviMap.put("delType", "Module");
					resultCnt += devHelperSvc.deleteModuleData(coviMap);
					resultCnt += devHelperSvc.deletePrgmMapData(coviMap); 	// program_map 테이블 데이터도 삭제.
				} else if (pType.equals("tabMenu03")) {
					coviMap.put("PrgmID", (String)listJson.get(i).get("PrgmID"));
					coviMap.put("delType", "Prgm");
					resultCnt += devHelperSvc.deletePrgmData(coviMap);
					resultCnt += devHelperSvc.deletePrgmMapData(coviMap); 	// program_map 테이블 데이터도 삭제.
				} else if (pType.equals("tabMenu04")) { 	// program_map
					coviMap.put("PrgmID", (String)listJson.get(i).get("PrgmID"));
					coviMap.put("ModuleID", (String)listJson.get(i).get("ModuleID"));
					coviMap.put("delType", "Map");
					resultCnt += devHelperSvc.deletePrgmMapData(coviMap);
				} else if (pType.equals("tabMenu05")) { 	// program_menu
					coviMap.put("MenuID", (String)listJson.get(i).get("MenuID"));
					coviMap.put("PrgmID", (String)listJson.get(i).get("PrgmID"));
					resultCnt += devHelperSvc.deletePrgmMenuData(coviMap);
				} else {
					break;
				}
			}
			
			returnObj.put("result", resultCnt);
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 관리자페이지 > 개발지원 > 모듈관리(가칭), 체크한 항목 모두 삭제하기.
	@RequestMapping(value = "devhelper/modifyModuleData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyModuleData(@RequestBody Map<String, Object> params
			, HttpServletRequest request, HttpServletResponse response
			) {
		CoviMap returnObj = new CoviMap();
		CoviMap coviMap = new CoviMap();
		
		coviMap.put("type", (String)params.get("type"));
		coviMap.put("modifiercode", SessionHelper.getSession("UR_Code"));
		
		try {
			int resultCnt = 0;
			
			if (coviMap.get("type").equals("modModule")) { 	// 모듈 수정.
				
				coviMap.put("bizSection", (String)params.get("bizSection"));
				coviMap.put("url", (String)params.get("url"));
				coviMap.put("moduleId", (String)params.get("moduleId"));
				coviMap.put("moduleName", (String)params.get("moduleName"));
				coviMap.put("auditMethod", (String)params.get("auditMethod"));
				coviMap.put("auditClass", (String)params.get("auditClass"));
				coviMap.put("isUse", (String)params.get("isUse"));
				coviMap.put("isAdmin", (String)params.get("isAdmin"));
				coviMap.put("isAudit", (String)params.get("isAudit"));
				coviMap.put("description", (String)params.get("description"));
				
				// 필수값 확인.(URL, BizSection, ModuleID)
				if ( coviMap.get("url").toString().length() == 0 || coviMap.get("bizSection").toString().length() == 0 
						|| coviMap.get("moduleId").toString().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				resultCnt = devHelperSvc.updateModuleData(coviMap);
				
			} else if (coviMap.get("type").equals("modPrgm")) {
				coviMap.put("prgmId", (String)params.get("prgmId"));
				coviMap.put("prgmName", (String)params.get("prgmName"));
				// 필수값 확인(prgmId)
				if ( coviMap.get("prgmId").toString().length() == 0 ) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				resultCnt = devHelperSvc.updatePrgmData(coviMap);
			} else if ( coviMap.get("type").equals("modPrgmMenu") ) {
				coviMap.put("menuId", (String)params.get("menuId"));
				coviMap.put("prgmId", (String)params.get("prgmId"));
				// 필수값 확인(menuId, prgmId)
				if ( coviMap.get("menuId").toString().length() == 0 || coviMap.get("prgmId").toString().length() == 0) {
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				resultCnt = devHelperSvc.updatePrgmMenuData(coviMap);
			}
			returnObj.put("result", resultCnt);
			returnObj.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	//개발지원 게시판 예시
	@RequestMapping(value = "devhelper/boardGridSample.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap boardGridSample(HttpServletRequest request, HttpServletResponse response) {
		
		CoviMap returnObj = new CoviMap();
		CoviMap coviMap = new CoviMap();
		
		try {
			//Grid 정렬 시 사용하는 파라미터 세팅
			//BoardUtils.setRequestParam(request, coviMap);
			coviMap.put("sortColumn", ComUtils.RemoveSQLInjection(request.getParameter("sortBy").split(" ")[0], 100)); //sorting 할 컬럼
			coviMap.put("sortDirection", ComUtils.RemoveSQLInjection(request.getParameter("sortBy").split(" ")[1], 100)); // 오름차순/내림차순
			
			// 페이징 관련 파라미터 세팅
			coviMap.put("pageSize", request.getParameter("pageSize")); //Grid 리스트 갯수
			coviMap.put("pageNo", request.getParameter("pageNo")); //현재 페이지 위치 
			int cnt = devHelperSvc.selectBoardlistCountExample(coviMap);
			coviMap.addAll(ComUtils.setPagingData(coviMap,cnt)); //페이징 계산
			
			returnObj.put("page", coviMap); //페이징 세팅
			returnObj.put("list", devHelperSvc.selectBoardSampleList(coviMap)); //게시글 리스트 호출 
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnObj;
	}
	
	@RequestMapping(value = "devhelper/encryptLicense.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap encryptLicense(HttpServletRequest request, HttpServletResponse response) {

		CoviMap returnList = new CoviMap();
		CoviMap coviMap = new CoviMap();
		try{
			String key = request.getParameter("domainUrl");
			
			coviMap.put("LIUD", LicenseHelper.getEncrypt(request.getParameter("domain"), key, "LIUD"));
			coviMap.put("LIUC", LicenseHelper.getEncrypt(request.getParameter("userCount"), key, "LIUC"));
			coviMap.put("LIUP",  LicenseHelper.getEncrypt(request.getParameter("expireDate"), key, "LIUP"));
			coviMap.put("LIExUC",  LicenseHelper.getEncrypt(request.getParameter("exUserCount"), key, "LIExUC"));
			coviMap.put("LIEx1UP",  LicenseHelper.getEncrypt(request.getParameter("ex1Date"), key, "LIEx1UP"));
 
			returnList.put("result", coviMap);
			returnList.put("status", Return.SUCCESS);
			
		}
		catch (NullPointerException e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	

	@RequestMapping(value = "devhelper/decryptLicense.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap decryptLicense(HttpServletRequest request, HttpServletResponse response) {

		CoviMap returnList = new CoviMap();
		CoviMap coviMap = new CoviMap();
		try{
			String encrypted = "";
			String key = request.getParameter("domainUrl");
			
			coviMap.put("domain", LicenseHelper.getDecrypt(request.getParameter("LIUD"), key, "LIUD")); 
			coviMap.put("userCount", LicenseHelper.getDecrypt(request.getParameter("LIUC"), key, "LIUC")); 
			coviMap.put("expireDate", LicenseHelper.getDecrypt(request.getParameter("LIUP"), key, "LIUP")); 
			coviMap.put("exUserCount", LicenseHelper.getDecrypt(request.getParameter("LIExUC"), key, "LIExUC")); 
			coviMap.put("exUserCount", LicenseHelper.getDecrypt(request.getParameter("LIEx1UP"), key, "LIEx1UP")); 
			
			returnList.put("result", coviMap);
			returnList.put("status", Return.SUCCESS);
			
		}
		catch (NullPointerException e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e){
			LOGGER.error("encryptAPI", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
}
