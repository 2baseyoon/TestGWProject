package egovframework.covision.groupware.portal.user.web;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;








import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.portal.user.service.PNPortalSvc;
import egovframework.covision.groupware.util.BoardUtils;

@Controller
public class PNPortalCon {
	private Logger LOGGER = LogManager.getLogger(PNPortalCon.class);
	
	@Autowired
	PNPortalSvc pnPortalSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * saveUserPortalOption - 사용자 포탈 옵션 저장
	 * @param request
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/saveUserPortalOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveUserPortalMode(HttpServletRequest request) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("UR_Code", isMobile));
			params.put("portalOption", request.getParameter("portalOption"));
			
			int result = pnPortalSvc.saveUserPortalOption(params);
			
			if(result > 0){
				returnData.put("status", Return.SUCCESS);
			}else{
				returnData.put("status", Return.FAIL);
			}
			
			String isDark = request.getParameter("DarkMode") == null ? "N" : request.getParameter("DarkMode");
		
			SessionHelper.setSession("portalOption", request.getParameter("portalOption"));
			SessionHelper.setSession("DarkMode", isDark);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * getUserPortalOption - 사용자 포탈 옵션 가져오기
	 * @param request
	 * @return returnData
	 * @throws Exception
	 */
	public static String getUserPortalOption() throws Exception{
		String result = "";
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("UR_Code"));
			params.put("lang",  SessionHelper.getSession("lang"));

			PNPortalSvc pnPortalModeSvc = StaticContextAccessor.getBean(PNPortalSvc.class);
			result = pnPortalModeSvc.selectUserPortalOption(params);
		} catch (NullPointerException e) {
			return "";
		} catch (Exception e) {
			return "";
		}
		
		return result;
	}
	
	/**
	 * 롤링 배너 게시글 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectRollingBannerBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRollingBannerBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			params.put("folderID", RedisDataUtil.getBaseConfig("RollingBannerBoardID", isMobile));
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			CoviMap rollingBannerBoardList = pnPortalSvc.selectRollingBannerBoardList(params);
			
			returnData.put("list", rollingBannerBoardList.getJSONArray("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "pnPortal/getApprovalList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptVacationList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String lang = SessionHelper.getSession("lang");
			
			if(userID != null && !userID.equals("")){
				CoviMap params = new CoviMap();
				
				params.put("userID", userID);
				params.put("lang", lang);
				
				String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"), "");
				
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = pnPortalSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				resultList = pnPortalSvc.getApprovalList(params);
			}else{
				returnList.put("list", new CoviList());
			}
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "pnPortal/getProfileImagePath.do")
	public @ResponseBody CoviMap getProfileImagePath(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String userCodes = request.getParameter("userCodes");
			String userMails = request.getParameter("userMails");
			String searchMode = StringUtil.replaceNull(request.getParameter("searchMode"), "");
			
			params.put("searchMode", searchMode);
			
			if(userCodes != null && !userCodes.equals("")){
				params.put("userCodes", userCodes.split(";"));
			}else if(searchMode.equals("Code")){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "사용자 코드가 없습니다.");
				
				return returnList;
			}
			
			if(userMails != null && !userMails.equals("")){
				params.put("userMails", userMails.split(";"));
			}else if(searchMode.equals("Mail")){
				returnList.put("status", Return.FAIL);
				returnList.put("message", "사용자 메일주소가 없습니다.");
				
				return returnList;
			}
			
			returnList.put("list", pnPortalSvc.selectProfileImagePath(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "pnPortal/selectBoardMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectLatestMessageList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", userDataObj.getString("USERID"));
			params.put("lang", userDataObj.getString("lang"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", params.getString("bizSection"), "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			
			resultList = pnPortalSvc.selectBoardMessageList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "pnPortal/selectLastestUsedFormList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectLastestUsedFormList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList resultList = new CoviList();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", userDataObj.getString("USERID"));
			
			resultList = pnPortalSvc.selectLastestUsedFormList(params);
			
			returnData.put("list", resultList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 동영상 게시판 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectMovieBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMovieBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			int cnt = messageSvc.selectNormalMessageGridCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = messageSvc.selectNormalMessageGridList(params);
			CoviList resultArr = resultList.getJSONArray("list");
			CoviList returnArr = new CoviList();
			
			for(int i = 0; i < resultArr.size(); i++){
				CoviMap resultObj = resultArr.getJSONObject(i);
				CoviMap fileParams = new CoviMap();
				
				fileParams.put("ServiceType", "Board");
				fileParams.put("ObjectID", resultObj.getString("FolderID"));
				fileParams.put("ObjectType", "FD");
				fileParams.put("MessageID", resultObj.getString("MessageID"));
				fileParams.put("Version", resultObj.getString("Version"));
				
				resultObj.put("fileList", fileSvc.selectAttachAll(fileParams));
				
				returnArr.add(resultObj);
			}
			
			returnData.put("list", returnArr);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 업무시스템 바로가기 게시판 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectSystemLinkBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSystemLinkBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			resultList = pnPortalSvc.selectSystemLinkBoardList(params);
			/*CoviList returnArr = new CoviList();*/
			
			/*for(int i = 0; i < resultArr.size(); i++){
				CoviMap resultObj = resultArr.getJSONObject(i);
				CoviMap fileParams = new CoviMap();
				
				fileParams.put("ServiceType", "Board");
				fileParams.put("ObjectID", resultObj.getString("FolderID"));
				fileParams.put("ObjectType", "FD");
				fileParams.put("MessageID", resultObj.getString("MessageID"));
				fileParams.put("Version", resultObj.getString("Version"));
				
				resultObj.put("fileList", fileSvc.selectAttachAll(fileParams));
				
				returnArr.add(resultObj);
			}*/
			
			CoviList listObj = new CoviList();
			listObj = (CoviList)resultList.get("list");
			
			if (!params.has("folderID")) {
				returnData.put("infos", "-1"); 	// -1 : 게시판이 지정되어 있지 않음(systemLinkFolderID 미지정).
			} else if (listObj.size() == 0) {
				returnData.put("infos", "0"); 	// 0 : 데이터가 0건.
			} else {
				returnData.put("infos", "1"); 	// 1 : 데이터 건수가 1건 이상일 때.
			}
			
			returnData.put("list", resultList.getJSONArray("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 웹파트 썸네일 리스트 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/setWebpartThumbnailList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setWebpartThumbnailList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			String cMode = request.getParameter("contentsMode");
			
			CoviMap params = new CoviMap();
			CookiesUtil cUtil = new CookiesUtil();
			String key = cUtil.getCooiesValue(request);
			CoviMap userDataObj = SessionCommonHelper.getSession(isMobile, key);
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "WP", "", "V");
			params.put("webpartIDs", authorizedObjectCodeSet);
			params.put("cMode", cMode);
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			resultList = pnPortalSvc.setWebpartThumbnailList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 웹파트 썸네일 리스트 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectUserRewardVacDay.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserRewardVacDay(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("userCode", request.getParameter("userCode"));
			params.put("year", request.getParameter("year"));
			
			int result = pnPortalSvc.selectUserRewardVacDay(params);
			
			returnData.put("rewardVacDay", result);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * goSiteLinkListPopup - 사이트링크 목록 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "pnPortal/goSiteLinkListPopup.do", method = RequestMethod.GET)
	public ModelAndView goSiteLinkListPopup(){
		String returnURL = "user/privacy/SiteLinkListPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * goSiteLinkAddPopup - 사이트링크 추가 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "pnPortal/goSiteLinkAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goSiteLinkAddPopup(){
		String returnURL = "user/privacy/SiteLinkAddPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 사이트링크 리스트 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectSiteLinkList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSiteLinkList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			
			if(params.get("sortBy") != null){
				params.put("sortColumn", params.get("sortBy").toString().split(" ")[0]);
				params.put("sortDirection", params.get("sortBy").toString().split(" ")[1]);
			}
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			if(params.containsKey("pageNo")) {
				int cnt = pnPortalSvc.selectSiteLinkListCnt(params);
				page = ComUtils.setPagingData(params,cnt);
			 	params.addAll(page);
			 	returnData.put("page", page);
			}
			
			resultList = pnPortalSvc.selectSiteLinkList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 사이트링크 데이터 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectSiteLinkData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSiteLinkData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("siteLinkID", request.getParameter("siteLinkID"));
			
			resultList = pnPortalSvc.selectSiteLinkData(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 사이트링크 리스트 웹파트용 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectSiteLinkWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSiteLinkWebpartList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			
			resultList = pnPortalSvc.selectSiteLinkList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 사이트링크 리스트  저장
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/insertSiteLink.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertSiteLink(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			MultipartFile fileInfo = request.getFile("thumbnail");
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("siteLinkName", request.getParameter("siteLinkName"));
			params.put("siteLinkURL", request.getParameter("siteLinkURL"));
			params.put("sortKey", StringUtil.isNotNull(request.getParameter("sortKey")) ? request.getParameter("sortKey") : "999");
			
			String filePath;
			String rootPath;
			if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = rootPath + RedisDataUtil.getBaseConfig("SiteLinkThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename();
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = genId + "." + FilenameUtils.getExtension(originalfileName);
	                String savePath = filePath + saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("thumbnail", savePath.replace(rootPath, ""));
				}else{
					params.put("thumbnail", "");
				}
			}else{
				params.put("thumbnail", "");
			}
			
			int result = pnPortalSvc.insertSiteLink(params);
			
			if(result > 0) returnData.put("status", Return.SUCCESS);
			else returnData.put("status", Return.FAIL);
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 사이트링크 리스트  수정
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/updateSiteLink.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateSiteLink(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			MultipartFile fileInfo = request.getFile("thumbnail");
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("siteLinkID", request.getParameter("siteLinkID"));
			params.put("siteLinkName", request.getParameter("siteLinkName"));
			params.put("siteLinkURL", request.getParameter("siteLinkURL"));
			params.put("sortKey", StringUtil.isNotNull(request.getParameter("sortKey")) ? request.getParameter("sortKey") : "999");
			
			String filePath;
			String rootPath;
			if(osType.equals("WINDOWS")) rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = rootPath + RedisDataUtil.getBaseConfig("SiteLinkThumbnail_SavePath");
			
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
				
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()){
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename();
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = genId + "." + FilenameUtils.getExtension(originalfileName);
	                String savePath = filePath + saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("thumbnail", savePath.replace(rootPath, ""));
				}else{
					params.put("thumbnail", "");
				}
			}else{
				params.put("thumbnail", "");
			}
			
			int result = pnPortalSvc.updateSiteLink(params);
			
			if(result > 0) returnData.put("status", Return.SUCCESS);
			else returnData.put("status", Return.FAIL);
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 사이트링크 리스트 삭제
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/deleteSiteLinkList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteSiteLinkList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("siteLinkIDs", StringUtil.replaceNull(request.getParameter("siteLinkIDs"), "").split(";"));
			
			int result = pnPortalSvc.deleteSiteLink(params);
			
			if(result > 0) returnData.put("status", Return.SUCCESS);
			else returnData.put("status", Return.FAIL);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 댓글 목록 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/selectCommentList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommentList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("targetServiceType", request.getParameter("targetServiceType"));
			params.put("targetID", request.getParameter("targetID"));
			
			resultList = pnPortalSvc.selectCommentList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	
	/**
	 * 비밀번호 만료일
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "pnPortal/getPasswordExpirationDate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPasswordExpirationDate(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap policyData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			policyData = pnPortalSvc.selectPasswordPolicy(params);
			
			String strPwChangeDate = pnPortalSvc.selectPwChangeDate(params);
			
			SimpleDateFormat format = new SimpleDateFormat ("yyyy-MM-dd");
			String strCurrentDate = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"),"yyyy-MM-dd");
			Date currentDate = format.parse(strCurrentDate);

			Calendar calPwChangeDate = new GregorianCalendar();
			calPwChangeDate.setTime(format.parse(strPwChangeDate));
			calPwChangeDate.add(Calendar.DAY_OF_YEAR, Integer.parseInt(policyData.get("MaxChangeDate").toString()));
			
			Date pwChangeDate = new Date(calPwChangeDate.getTimeInMillis());

			long diffPwChange = (pwChangeDate.getTime() - currentDate.getTime()) / (24 * 60 * 60 * 1000);
			returnData.put("result", diffPwChange);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
}