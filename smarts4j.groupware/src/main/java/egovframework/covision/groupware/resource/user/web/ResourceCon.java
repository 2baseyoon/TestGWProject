package egovframework.covision.groupware.resource.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import net.sf.jxls.transformer.XLSTransformer;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;
/**
 * @Class Name : ResourceCon.java
 * @Description : 자원예약 사용자 요청 처리
 * @Modification Information 
 * @ 2017.08.14 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 08.14
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class ResourceCon {
	Logger LOGGER = LogManager.getLogger(ResourceCon.class);
	
	private final String FILE_SERVICE_TYPE = "Resource";
	
	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private ResourceSvc resourceSvc;
	
	@Autowired
	private FileUtilService fileSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 간단 등록 보기 창
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/getSimpleWriteView.do", method = RequestMethod.GET)
	public ModelAndView getSimpleWriteView(Locale locale, Model model) {
		String returnURL = "user/resource/SimpleWrite";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 상세 등록 자원 목록 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/goResourceTree.do", method = RequestMethod.GET)
	public ModelAndView goResourceTree(Locale locale, Model model) {
		String returnURL = "user/resource/ResourceTree";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 자원 정보 팝업
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/goResourceInfoView.do", method = RequestMethod.GET)
	public ModelAndView goResourceInfoView(Locale locale, Model model) {
		String returnURL = "user/resource/ResourceInfoView";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 간단 조회 보기 창
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/getSimpleViewView.do", method = RequestMethod.GET)
	public ModelAndView getSimpleViewView(Locale locale, Model model) {
		String returnURL = "user/resource/SimpleView";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 나의 자원예약 목록 보기 - iframe
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/goGridMyBooking.do", method = RequestMethod.GET)
	public ModelAndView goGridMyBooking(Locale locale, Model model) {
		String returnURL = "user/resource/GridMyBooking";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 나의 자원예약 목록 보기 - iframe
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/goGridRequestBooking.do", method = RequestMethod.GET)
	public ModelAndView goGridRequestBooking(Locale locale, Model model) {
		String returnURL = "user/resource/GridRequestBooking";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * 자원예약 현황 팝업 (일정관리)
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "resource/goViewPopup.do", method = RequestMethod.GET)
	public ModelAndView goViewPopup(Locale locale, Model model) {
		String returnURL = "user/resource/ViewPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 *  웹파트 자원예약 상세 팝업
	 * @param request
	 * @param response
	 * @return ModelAndView
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/goResourceDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView goScheduleDetailPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/resource/ResourceDetailPopup");
	}
	
	// 웹파트 일정 상세
	/**
	 * 웹파트 자원예약 상세
	 * @param request
	 * @param response
	 * @return ModelAndView
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/detailView.do", method = RequestMethod.GET)
	public ModelAndView detailView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/resource/DetailView");
	}
	
	/**
	 * 자원예약 용도 입력 팝업
	 * @param request
	 * @param response
	 * @return ModelAndView
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/goSubjectPopup.do", method = RequestMethod.GET)
	public ModelAndView goSubjectPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/resource/ResourceSubjectPopup");
	}
	
	/**
	 * 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getACLFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLFolder(HttpServletRequest request) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		
		CoviList createObj = new CoviList();
		CoviList deleteObj = new CoviList();
		CoviList modifyObj = new CoviList();
		CoviList viewObj = new CoviList();
		CoviList readObj = new CoviList();
		
		try {
			String createStr = "";
			String deleteStr = "";
			String modifyStr = "";
			String viewStr = "";
			String readStr = "";
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap userInfoObj = SessionHelper.getSession();
			
			ACLMapper aclMap = ACLHelper.getACLMapper(userInfoObj, "FD", "Resource");
			createStr = eventSvc.getACLFolderData(aclMap.getACLInfo("C"), "C");
			deleteStr = eventSvc.getACLFolderData(aclMap.getACLInfo("D"), "D");
			modifyStr = eventSvc.getACLFolderData(aclMap.getACLInfo("M"), "M");
			viewStr = eventSvc.getACLFolderData(aclMap.getACLInfo("V"), "V");
			readStr = eventSvc.getACLFolderData(aclMap.getACLInfo("R"), "R");
			
			params.put("C_FolderIDs", createStr);
			params.put("D_FolderIDs", deleteStr);
			params.put("M_FolderIDs", modifyStr);
			params.put("V_FolderIDs", viewStr);
			params.put("R_FolderIDs", readStr);
			
			params.put("C_FolderIDArr", createStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("D_FolderIDArr", deleteStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("M_FolderIDArr", modifyStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("V_FolderIDArr", viewStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			params.put("R_FolderIDArr", readStr.replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("\'", "").split(","));
			
			CoviList folderData = resourceSvc.selectACLData(params);
			for(Object obj : folderData){
				CoviMap folder = (CoviMap) obj;
				String type = folder.getString("type");
				
				switch (type) {
				case "C":
					createObj.add(folder);
					break;
				case "D":
					deleteObj.add(folder);
					break;
				case "M":
					modifyObj.add(folder);
					break;
				case "V":
					viewObj.add(folder);
					break;
				case "R":
					readObj.add(folder);
					break;
				default :
					break;
				}
			}
			
			returnObj.put("create", createObj);
			returnObj.put("delete", deleteObj);
			returnObj.put("modify", modifyObj);
			returnObj.put("view", viewObj);
			returnObj.put("read", readObj);
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	/**
	 * getResourceList - 자원 목록 조회
	 * 
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getResourceList.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getResourceList(@RequestParam(value = "FolderType", required = false) String pFolderType) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("DomainID",SessionHelper.getSession("DN_ID"));
			params.put("FolderType", pFolderType);
			
			returnList.put("data", resourceSvc.getResourceList(params));
			
			if(RedisDataUtil.getBaseConfig("IsUsePlaceOfBusinessSel").equals("Y")) {
				returnList.put("placeOfBusiness", resourceSvc.getResourceList(params));
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	

	/**
	 * getFolderTreeData - 좌측 트리 정보 조회
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getFolderTreeData.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getFolderTreeData(
			@RequestParam(value = "placeOfBusiness", required = false) String placeOfBusiness,
			@RequestParam(value = "FolderIDs", required = false) String folderIDs) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("domainID",SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("placeOfBusiness",placeOfBusiness);
			params.put("aclFolderIDs", folderIDs);
			params.put("aclFolderIDArr", folderIDs.replaceAll("\\(", "").replaceAll("\\)", "").split(","));
			
			returnList.put("list", resourceSvc.getFolderTreeData(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	
	/**
	 * getBookingList - 자원 예약 조회 (List/Daily/Weekly)
	 * @param mode
	 * @param pageNo
	 * @param pageSize
	 * @param sortBy
	 * @param folderID
	 * @param userID
	 * @param approvalState
	 * @param startDate
	 * @param endDate
	 * @param searchType
	 * @param searchWord
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getBookingList.do",  method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getBookingList(
			 @RequestParam(value = "mode", required = false, defaultValue="List" ) String mode,
			 @RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
			 @RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
			 @RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			 @RequestParam(value = "FolderID", required = false) String folderID,
			 @RequestParam(value = "userID", required = false) String userID,
			 @RequestParam(value = "ApprovalState", required = false, defaultValue="ApprovalRequest;Approval;ReturnRequest;ReturnComplete") String approvalState,
			 @RequestParam(value = "searchDateType", required = false) String searchDateType,
			 @RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
			 @RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
			 @RequestParam(value = "Subject", required = false, defaultValue="") String subject,
			 @RequestParam(value = "RegisterName", required = false, defaultValue="") String registerName,
			 @RequestParam(value = "hasAnniversary", required = false, defaultValue="N") String hasAnniversary,
			 @RequestParam(value = "isGetShared", required = false, defaultValue="N") String isGetShared
			 , HttpServletRequest request
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviList anniversaryList =new CoviList();
		
		try {
			String[] arrApprovalState  = approvalState.split(";");
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			int pageOffset = (pageNo - 1) * pageSize;
			
			//Oracle 페이징처리용
			int start =  (pageNo - 1) * pageSize + 1;
			int end = start + pageSize - 1;
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("pageOffset", pageOffset);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("userID", userID);
			params.put("arrApprovalState", arrApprovalState);
			params.put("searchDateType", searchDateType);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("Subject", subject);
			params.put("RegisterName", registerName);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			//Oracle 페이징처리용
			params.put("rowStart", start);
			params.put("rowEnd", end);
			
			String[] folderList =  StringUtil.split(folderID, ";");
			params.put("FolderIDs", folderList);
			params.put("isGetShared", isGetShared);
			
			// 사업장 세팅
			String placeOfBusiness = StringUtil.replaceNull(request.getParameter("placeOfBusiness"), "");
			params.put("placeOfBusiness", placeOfBusiness);

			if (isGetShared.equalsIgnoreCase("Y")) {  // 공유 자원 ID 추가 검색.
			      if (folderList != null && folderList.length > 0) {
			            CoviList linkList = new CoviList();
			            CoviMap linkMap = new CoviMap();
			            linkList = resourceSvc.selectLinkFolderID(params);

			            String[] linkFolders = new String[linkList.size()];
			            for (int i=0; i<linkList.size(); i++) {
			                  linkMap = (CoviMap) linkList.get(i);
			                  linkFolders[i] = String.valueOf(linkMap.get("FolderID"));
			            }
			            
			            params.put("linkFolderIDs", linkFolders);
			      }
			}
						
			if(mode.equalsIgnoreCase("List")){
				if ( folderID == null || folderList.length > 0){
					resultList = resourceSvc.getBookingList(params);
				}	else{
					returnList.put("list", new CoviList());
					resultList.put("bookingList", new CoviList());
					resultList.put("cnt", 0);
				}
					
			}else if(mode.equalsIgnoreCase("D") || mode.equalsIgnoreCase("W") || mode.equalsIgnoreCase("M")){
				if (folderList.length > 0){
					resultList = resourceSvc.getBookingPeriodList(params);
				}
				else
				{
					resultList.put("folderList", new CoviMap());
					resultList.put("bookingList", new CoviMap());
				}
			}
			
			if(mode.equalsIgnoreCase("List")){
				CoviMap pageParam  = new CoviMap();
				
				pageParam.addAll(ComUtils.setPagingData(params,resultList.getInt("cnt")));			//페이징 parameter set
				returnList.put("page", pageParam);
				returnList.put("list", resultList.getJSONArray("bookingList"));
			}else{
				returnList.put("data", resultList);
			}
			
			if(hasAnniversary.equalsIgnoreCase("Y")){
				params.put("EndDate", DateHelper.getAddDate(endDate, "yyyy-MM-dd", 1, Calendar.DATE));
				
				anniversaryList = eventSvc.selectAnniversaryList(params);
			}
			
			returnList.put("anniversaryList", anniversaryList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	 * getResourceData - 자원 정보 조회
	 * @param folderID
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getResourceData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getResourceData(
			 @RequestParam(value = "FolderID", required = true) String FolderID
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("FolderID", FolderID);
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = resourceSvc.getResourceData(params);
			
			returnList.put("data", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	/**
	 * getBookingData - 자원예약 정보 조회
	 * @param mode
	 * @param EventID
	 * @param DateID
	 * @param RepeatID
	 * @param FolderID
	 * @param EventIDArr
	 * @param DateIDArr
	 * @param RepeatIDArr
	 * @param FolderIDArr
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getBookingData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBookingData(
			@RequestParam(value = "mode", required = true) String mode,
			 @RequestParam(value = "EventID", required = false) String EventID,
			 @RequestParam(value = "DateID", required = false) String DateID,
			 @RequestParam(value = "RepeatID", required = false) String RepeatID,
			 @RequestParam(value = "FolderID", required = false) String FolderID,
			 @RequestParam(value = "IntegratedID", required = false) String IntegratedID,
			 @RequestParam(value = "ResourceID", required = false) String ResourceID,
			 @RequestParam(value = "EventIDArr[]" , required = false) List<String> EventIDArr,
			 @RequestParam(value = "DateIDArr[]", required = false) List<String> DateIDArr,
			 @RequestParam(value = "RepeatIDArr[]", required = false) List<String> RepeatIDArr,
			 @RequestParam(value = "FolderIDArr[]", required = false) List<String> FolderIDArr
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			
			// 1개 예약 정보 조회
			params.put("EventID", EventID);
			params.put("DateID", DateID);
			params.put("RepeatID", RepeatID);
			params.put("FolderID", FolderID);
			params.put("integratedID", IntegratedID);
			
			// N개의 예약정보 조회 (N > 1)
			params.put("EventIDArr", EventIDArr);
			params.put("DateIDArr", DateIDArr);
			params.put("RepeatIDArr", RepeatIDArr);
			params.put("FolderIDArr", FolderIDArr);
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			// 공유자원의 경우, IntegratedID(resourceID or LinkFolderID)를 이용해 가져옴.
			if ( IntegratedID != null && !ResourceID.equalsIgnoreCase(IntegratedID)) {
				CoviList linkList = new CoviList();
				String[] folderList = new String[2];
				folderList[0] = ResourceID;
				folderList[1] = IntegratedID;
				params.put("FolderIDs", folderList);
				linkList = resourceSvc.selectLinkFolderID(params);
				
				CoviList folderIdArr = new CoviList(); 
				CoviMap idMap = new CoviMap();
				for (int i=0;linkList.size()>i;i++) {
					idMap = (CoviMap) linkList.get(i);
					folderIdArr.add(i, idMap.get("FolderID").toString());
				}
				FolderIDArr = folderIdArr;
				params.put("FolderIDArr", FolderIDArr);
			}
			resultList = resourceSvc.getBookingData(params);
			
			if(!params.getString("EventID").isEmpty()) { //1개 이상 데이터 조회 시 파일 목록 조회 X
				CoviMap filesParams = new CoviMap();
				filesParams.put("ServiceType", FILE_SERVICE_TYPE);
				filesParams.put("ObjectID", FolderID);
				filesParams.put("ObjectType", "FD");
				filesParams.put("MessageID", EventID);
				filesParams.put("Version", "0");
				
				resultList.put("fileList", fileSvc.selectAttachAll(filesParams));
			}
			
			returnList.put("data", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	
	/**
	 *  modifyBookingState - 자원예약 상태 변경
	 * @param dateID
	 * @param state 변경할 상태코드
	 * @return
	 */
	@RequestMapping(value = "resource/modifyBookingState.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyBookingState(
			@RequestParam(value = "ApprovalState", required = true) String ApprovalState,
			 @RequestParam(value = "DateID", required = false) String DateID,
			 @RequestParam(value = "EventID", required = false) String EventID,
			 @RequestParam(value = "ResourceID", required = false) String ResourceID, 
			 @RequestParam(value = "IsRepeatAll", required = false, defaultValue = "N") String IsRepeatAll
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviList resultArr = new CoviList();
		int failCnt = 0, successCnt = 0;
		try {
			String[] dataIDArr = DateID.split(";");			

			CoviMap params = new CoviMap();
			params.put("ApprovalState", ApprovalState);
			params.put("ResourceID", ResourceID);
			params.put("IsRepeatAll", IsRepeatAll);
			params.put("lang", SessionHelper.getSession("lang"));
			
			if(IsRepeatAll.equals("Y")) { //반복일정 모두 보기이면 조건에 맞는 대상 모두 변경
				params.put("EventID", EventID);
				
				resultObj = resourceSvc.modifyAllBookingState(params);
				
				failCnt = resultObj.getInt("FailCnt");
				successCnt = resultObj.getInt("SuccessCnt");
				resultArr = resultObj.getJSONArray("bookingArray");
			}else {
				for(int i = 0 ;i < dataIDArr.length; i++){
					params.put("DateID", dataIDArr[i]);
					
					resultObj = resourceSvc.modifyBookingState(params);
					resultObj.put("DateID", dataIDArr[i]);
					
					if(resultObj.getString("retType").equalsIgnoreCase("FAIL")) {
						failCnt++;
					}else {
						successCnt++;
					}
					
					resultArr.add(resultObj);
				}
			}
			
			returnList.put("result", resultArr);
			returnList.put("failCnt", failCnt);
			returnList.put("successCnt", successCnt);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	

	/**
	 *  teamsModifyBookingState - 팀즈 자원예약 상태 변경
	 * @param dateID
	 * @param state 변경할 상태코드
	 * @return
	 */
	@RequestMapping(value = "resource/teamsModifyBookingState.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap teamsModifyBookingState(@RequestBody CoviMap params) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviList resultArr = new CoviList();
		int failCnt = 0, successCnt = 0;
		try {
			String DateID = params.getString("DateID");
			String IsRepeatAll = params.getString("IsRepeatAll");
			String[] dataIDArr = DateID.split(";");			
			
			if(IsRepeatAll.equals("Y")) { //반복일정 모두 보기이면 조건에 맞는 대상 모두 변경
				
				resultObj = resourceSvc.modifyAllBookingState(params);
				
				failCnt = resultObj.getInt("FailCnt");
				successCnt = resultObj.getInt("SuccessCnt");
				resultArr = resultObj.getJSONArray("bookingArray");
			}else {
				for(int i = 0 ;i < dataIDArr.length; i++){
					params.put("DateID", dataIDArr[i]);
					
					resultObj = resourceSvc.modifyBookingState(params);
					resultObj.put("DateID", dataIDArr[i]);
					
					if(resultObj.getString("retType").equalsIgnoreCase("FAIL")) {
						failCnt++;
					}else {
						successCnt++;
					}
					
					resultArr.add(resultObj);
				}
			}
			
			returnList.put("result", resultArr);
			returnList.put("failCnt", failCnt);
			returnList.put("successCnt", successCnt);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	
	/**
	 * saveBookingData - 자원예약 정보 조회
	 * @param mode
	 * @param evnetID
	 * @param dateID
	 * @param repeatID
	 * @param folderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/saveBookingData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveBookingData(MultipartHttpServletRequest request) throws Exception
	{
		
		String mode = Objects.toString(request.getParameter("mode"), "I");
		String eventStr = request.getParameter("eventStr");
		String isChangeDate = Objects.toString(request.getParameter("isChangeDate"), "false");
		String isChangeRes = Objects.toString(request.getParameter("isChangeRes"), "false");
		
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap eventObj = new CoviMap();
		
		try {
			String eventObjStr = StringEscapeUtils.unescapeHtml(eventStr);
			eventObj = CoviMap.fromObject(eventObjStr);
			
			List<MultipartFile> mf = request.getFiles("files");	
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap filesParams = new CoviMap();
			filesParams.put("ServiceType", FILE_SERVICE_TYPE);
			filesParams.put("fileInfos", request.getParameter("fileInfos"));
			filesParams.put("fileCnt", request.getParameter("fileCnt"));
			
			if(mode.equals("I")){
				resultObj = resourceSvc.saveBookingData(eventObj, filesParams, mf);
			}else if(mode.equals("U")){
				resultObj = resourceSvc.modifyBookingData(eventObj, filesParams, mf);
			}else if(mode.equals("RU")){
				resultObj = resourceSvc.setEachSchedule(eventObj, filesParams, mf, isChangeDate, isChangeRes);
			}
			
			returnList.put("result", resultObj.getString("retType")); //OK or DUPLICATION
			returnList.put("status", Return.SUCCESS);
			returnList.put("message",resultObj.getString("retMsg"));			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			// Redis에 임시로 저장한 본인의 자원예약 정보를 모두 삭제한다
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			instance.removeAll("ResourceBooking_" + eventObj.getString("ResourceID") + "_" + SessionHelper.getSession("USERID"));
		}
		
		return returnList;		
	}
	
	/**
	 * 자원 예약 가능 여부 체크
	 * @param folderID
	 * @param startDate
	 * @param startTime
	 * @param endDate
	 * @param endTime
	 * @param resourceType
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/check.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap check(
			@RequestParam(value = "FolderID", required = false, defaultValue="") String folderID,
			@RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
			@RequestParam(value = "StartTime", required = false, defaultValue="") String startTime,
			@RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
			@RequestParam(value = "EndTime", required = false, defaultValue="") String endTime,
			@RequestParam(value = "ResourceType", required = false, defaultValue="") String resourceType
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviList resource = new CoviList();
		String message = "";
		CoviMap firstTime = new CoviMap();
		CoviMap time = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("StartDate", startDate);
			params.put("StartTime", startTime);
			params.put("EndDate", endDate);
			params.put("EndTime", endTime);
			params.put("ResourceType", resourceType);
			
			// 예약 가능여부
			int checkResourceApv = resourceSvc.checkResourceApv(folderID);
			
			if(checkResourceApv > 0){
				returnList.put("result", "ApprovalProhibit");
				returnList.put("message", DicHelper.getDic("msg_cannotpossiblereservationresource")); // 예약이 불가능한 자원입니다.
				returnList.put("status", Return.SUCCESS);
				
				return returnList;
			}
			
			// 예약 가능여부, 첫 추천 시간
			CoviMap firstTimeResultObj = resourceSvc.check(params);
			if(firstTimeResultObj.getString("IsDuplication").equals("1")){
				if(!firstTimeResultObj.getString("StartDateTime").equals("")){
					firstTime.put("StartDateTime", firstTimeResultObj.getString("StartDateTime"));
					firstTime.put("EndDateTime", firstTimeResultObj.getString("EndDateTime"));
				}
				
				// 자원 추천
				///
				CoviMap userInfoObj = SessionHelper.getSession();
				ACLMapper aclMap = ACLHelper.getACLMapper(userInfoObj, "FD", "Resource");
				Set<String> authObjCodeSet = aclMap.getACLInfo("R");
				String[] folderObjArr = authObjCodeSet.toArray(new String[authObjCodeSet.size()]);
				params.put("FolderIDs", folderObjArr);
				
				resource = resourceSvc.checkTime(params);
				
				// 시간 추천
				CoviMap timeResultObj = resourceSvc.checkResource(params);
				if(!timeResultObj.getString("StartDateTime").equals("")){
					time.put("StartDateTime", timeResultObj.getString("StartDateTime"));
					time.put("EndDateTime", timeResultObj.getString("EndDateTime"));
				}
				
				resultObj.put("resource", resource);
				resultObj.put("firstTime", firstTime);
				resultObj.put("time", time);
				
				returnList.put("resultObj", resultObj);
			}
			returnList.put("message", firstTimeResultObj.getString("Message"));
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	
	/**
	 * 담당자 정보 조회
	 * @param userID
	 * @param groupPath
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getManageInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getManageInfo() throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		try {
			
			resultObj = resourceSvc.getManageInfo();
			
			returnList.put("list", resultObj.get("list"));
			returnList.put("cnt", resultObj.getInt("cnt"));
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	
	/**
	 * 시간으로 가능한 다른 자원 체크
	 * @param folderID
	 * @param startDate
	 * @param startTime
	 * @param endDate
	 * @param endTime
	 * @param resourceType
	 * @return
	 * @throws Exception
	 */
	/*@RequestMapping(value = "resource/checkTime.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkTime(
			@RequestParam(value = "FolderID", required = false, defaultValue="") String folderID,
			@RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
			@RequestParam(value = "StartTime", required = false, defaultValue="") String startTime,
			@RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
			@RequestParam(value = "EndTime", required = false, defaultValue="") String endTime,
			@RequestParam(value = "ResourceType", required = false, defaultValue="") String resourceType
			) throws Exception
	{
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("FolderID", folderID);
			params.put("StartDate", startDate);
			params.put("StartTime", startTime);
			params.put("EndDate", endDate);
			params.put("EndTime", endTime);
			params.put("ResourceType", resourceType);
			resultObj = resourceSvc.checkTime(params);
			
			String message = resultObj.getString("Message");
			String url = "";
			
			if(DateHelper.diffHour(startDate+" "+startTime, endDate+" "+endTime) >= 24){
				message += "\n" + DicHelper.getDic("msg_QuestionRecommendRS");		// 더 추천을 받아보시는 것은 어떠세요?
				url = "checkTimeResource.do";
			}else{
				message +=  "\n" + DicHelper.getDic("msg_QuestionCheckTimeMTH");		// 자원 말고, 다른 시간을 추천 받아보시는 것은 어떠세요?
				url = "checkResource.do";
			}
			
			returnList.put("message", message);		
			returnList.put("nextURL", url);
			returnList.put("result", resultObj.getJSONArray("Resources"));
			returnList.put("status", Return.SUCCESS);
			
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}*/
	
	/**
	 * checkResource - 동일한 자원에서 다른 시간대 추천 
	 * @param folderID
	 * @param startDate
	 * @param startTime
	 * @param endDate
	 * @param endTime
	 * @param resourceType
	 * @return returnList
	 * @throws Exception
	 */
	/*@RequestMapping(value = "resource/checkResource.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkResource(
			@RequestParam(value = "FolderID", required = false, defaultValue="") String folderID,
			@RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
			@RequestParam(value = "StartTime", required = false, defaultValue="") String startTime,
			@RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
			@RequestParam(value = "EndTime", required = false, defaultValue="") String endTime,
			@RequestParam(value = "ResourceType", required = false, defaultValue="") String resourceType
			) throws Exception
	{
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("FolderID", folderID);
			params.put("StartDate", startDate);
			params.put("StartTime", startTime);
			params.put("EndDate", endDate);
			params.put("EndTime", endTime);
			params.put("ResourceType", resourceType);
			
			resultObj = resourceSvc.checkResource(params);
			
			returnList.put("result", resultObj);
			returnList.put("status", Return.SUCCESS);
			returnList.put("nextURL", " resource/checkTimeResource.do");
			returnList.put("message",resultObj.getString("Message") + "\n" + DicHelper.getDic("msg_QuestionRecommendRS"));		// 더 추천을 받아보시는 것은 어떠세요? 
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}*/
	
	
	/**
	 * checkTimeResource - 다른 시간 다른 자원 추천
	 * @param folderID
	 * @param startDate
	 * @param startTime
	 * @param endDate
	 * @param endTime
	 * @param resourceType
	 * @return returnList
	 * @throws Exception
	 */
	/*@RequestMapping(value = "resource/checkTimeResource.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkTimeResource(
			@RequestParam(value = "FolderID", required = false, defaultValue="") String folderID,
			@RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
			@RequestParam(value = "StartTime", required = false, defaultValue="") String startTime,
			@RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
			@RequestParam(value = "EndTime", required = false, defaultValue="") String endTime,
			@RequestParam(value = "ResourceType", required = false, defaultValue="") String resourceType
			) throws Exception
	{
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("FolderID", folderID);
			params.put("StartDate", startDate);
			params.put("StartTime", startTime);
			params.put("EndDate", endDate);
			params.put("EndTime", endTime);
			params.put("ResourceType", resourceType);
			
			resultObj = resourceSvc.checkTimeResource(params);
			
			returnList.put("result", resultObj);
			returnList.put("status", Return.SUCCESS);
			returnList.put("nextURL", "");
			returnList.put("message",resultObj.getString("Message"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}*/
	
	/**
	 * 자원예약 체크된 항목이 아무것도 없을 경우 기본 데이터 조회.
	 * @param domainID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getMainResourceMenuList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMainResourceMenuList(@RequestParam(value = "domainID", required = false) String domainID) throws Exception {
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
		
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String checkStr = instance.get("ResourceCheckBox_" + SessionHelper.getSession("USERID"));
			
			if(checkStr == null || checkStr.equals("")|| checkStr.equals(";")){
				CoviMap params = new CoviMap();
				params.put("domainID", domainID);				
				resultList = resourceSvc.getMainResourceMenuList(params);
			}
			
			returnList.put("list", resultList);
			returnList.put("redisData", checkStr);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	/**
	 * 체크한 항목 Redis에 저장
	 * @param checkList
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/saveChkFolderListRedis.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMainResourceMenuList(
			@RequestParam(value = "checkList", required = true) String checkList,
			@RequestParam(value = "userCode", required = true) String userCode
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			instance.save("ResourceCheckBox_" + SessionHelper.getSession("USERID"), checkList);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
		
	}
	
	/**
	 * 자원 선택 시 트리
	 * @param placeOfBusiness
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getResourceTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getResourceTreeList(
			@RequestParam(value = "placeOfBusiness", required = false) String placeOfBusiness) throws Exception
	{
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("DomainID",SessionHelper.getSession("DN_ID"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("placeOfBusiness",placeOfBusiness);
			
			resultList = resourceSvc.getResourceTreeList(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;	
	}
	
	/**
	 * 확장필드 조회
	 * @param folderID
	 * @param lang
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getUserFormOptionData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserFormOptionData(
			@RequestParam(value = "FolderID", required = false) String folderID,
			@RequestParam(value = "lang", required = false) String lang) throws Exception
	{
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("FolderID",folderID);
			params.put("lang",lang);
			
			resultList = resourceSvc.getUserFormOptionData(params);
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;	
	}
	
	/**
	 * 자원등록시 예약 가능 여부 체크
	 * @param folderID
	 * @param startDate
	 * @param startTime
	 * @param endDate
	 * @param endTime
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/checkDuplicateTime.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDuplicateTime(
			@RequestParam(value = "FolderID", required = false) String folderID,
			@RequestParam(value = "StartDate", required = false) String startDate,
			@RequestParam(value = "StartTime", required = false) String startTime,
			@RequestParam(value = "EndDate", required = false) String endDate,
			@RequestParam(value = "EndTime", required = false) String endTime
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap eventDateObj = new CoviMap();
			
			eventDateObj.put("StartDate", startDate);
			eventDateObj.put("StartTime", startTime);
			eventDateObj.put("EndDate", endDate);
			eventDateObj.put("EndTime", endTime);
			
			resultList = resourceSvc.checkDuplicateTime(folderID, eventDateObj);
			
			returnList.put("data", resultList.getString("IsDuplication"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;	
	}
	
	/**
	 * 왼쪽 상단 메뉴 일정 표시
	 * @param request
	 * @param response
	 * @param startDate
	 * @param endDate
	 * @param folderIDs
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "resource/getLeftCalendarEvent.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLeftCalendarEvent(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "StartDate", required = false, defaultValue = "") String startDate,
			@RequestParam(value = "EndDate", required = false, defaultValue = "") String endDate,
			@RequestParam(value = "FolderIDs", required = false, defaultValue = "") String folderIDs) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		try {
			CoviMap params = new CoviMap();
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			String[] folderList =  StringUtil.split(folderIDs, ";");
			params.put("FolderIDs", folderList);
			if (folderList.length>0){
				returnList = resourceSvc.selectLeftCalendarEvent(params);
			}	
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "resource/excelDownload.do")
	public void excelDownload(HttpServletRequest request, HttpServletResponse response,
		@RequestParam(value = "mode", required = false, defaultValue="List" ) String mode,
		@RequestParam(value = "pageNo", required = false, defaultValue="1" ) int pageNo,
		@RequestParam(value = "pageSize", required = false, defaultValue="10"  ) int pageSize,
		@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
		@RequestParam(value = "FolderID", required = false) String folderID,
		@RequestParam(value = "userID", required = false) String userID,
		@RequestParam(value = "ApprovalState", required = false, defaultValue="ApprovalRequest;Approval;ReturnRequest;ReturnComplete") String approvalState,
		@RequestParam(value = "searchDateType", required = false) String searchDateType,
		@RequestParam(value = "StartDate", required = false, defaultValue="") String startDate,
		@RequestParam(value = "EndDate", required = false, defaultValue="") String endDate,
		@RequestParam(value = "Subject", required = false, defaultValue="") String subject,
		@RequestParam(value = "RegisterName", required = false, defaultValue="") String registerName) {
		
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			// 1. 데이터 조회
			String[] arrApprovalState  = approvalState.split(";");
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			int pageOffset = (pageNo - 1) * pageSize;
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			params.put("pageNo", pageNo);
			params.put("pageSize", null);
			params.put("pageOffset", pageOffset);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("userID", userID);
			params.put("arrApprovalState", arrApprovalState);
			params.put("searchDateType", searchDateType);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("Subject", subject);
			params.put("RegisterName", registerName);
			params.put("lang", SessionHelper.getSession("lang"));
			
			//폴더값은 배열로 넘기기
			String[] folderList =  StringUtil.split(folderID, ";");
			params.put("FolderIDs", folderList);

			CoviMap resultList = new CoviMap();
			if(mode.equalsIgnoreCase("List")){
				resultList = resourceSvc.getBookingList(params);
			}else if(mode.equalsIgnoreCase("D") || mode.equalsIgnoreCase("W") || mode.equalsIgnoreCase("M")){
				resultList = resourceSvc.getBookingPeriodList(params);
			}
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("list", resultList.getJSONArray("bookingList"));
	        
			// 2. 엑셀 생성
			String FileName = new SimpleDateFormat("yyyy_MM_dd").format(new Date()) + "_Resource.xlsx";
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Resource_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, paramMap);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	
	// 반복일정 모두보기에서 알림 모두 변경
		@RequestMapping(value = "resource/modifyAllNoti.do", method = RequestMethod.POST) 
		public @ResponseBody CoviMap modifyAllNoti(HttpServletRequest request, HttpServletResponse response,
				@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID,
				@RequestParam(value = "NotiInfo", required = true, defaultValue = "") String notiInfo)
		{
			CoviMap returnObj = new CoviMap();
			try {
				String notiStr = StringEscapeUtils.unescapeHtml(notiInfo);
				CoviMap notiInfoObj = CoviMap.fromObject(notiStr);
				
				CoviMap params = new CoviMap();
				params.put("EventID", eventID);
				params.put("UserCode", SessionHelper.getSession("USERID"));
				params.put("ServiceType", "Resource");
				params.put("IsReminder", notiInfoObj.getString("reminder"));
				params.put("ReminderTime", notiInfoObj.getString("reminderTime"));
				params.put("IsCommentNotification", notiInfoObj.getString("comment"));
				
				eventSvc.modifyAllNotification(params);
				returnObj.put("status", Return.SUCCESS);
			} catch (NullPointerException e) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));	
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch(Exception ex) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));	
				LOGGER.error(ex.getLocalizedMessage(), ex);
			}
			
			return returnObj;
		}
		
		// 반복일정 모두보기에서 알림 모두 끄기
		@RequestMapping(value = "resource/deleteAllNoti.do", method = RequestMethod.POST) 
		public @ResponseBody CoviMap deleteAllNoti(HttpServletRequest request, HttpServletResponse response,
				@RequestParam(value = "EventID", required = true, defaultValue = "") String eventID)
		{
			CoviMap returnObj = new CoviMap();
			try {
				CoviMap params = new CoviMap();
				params.put("EventID", eventID);
				params.put("ServiceType", "Resource");
				params.put("UserCode", SessionHelper.getSession("USERID"));
				eventSvc.deleteAllNotification(params);
				
				returnObj.put("status", Return.SUCCESS);
			} catch(NullPointerException ex) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));	
				LOGGER.error(ex.getLocalizedMessage(), ex);
			}  catch(Exception ex) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?ex.getMessage():DicHelper.getDic("msg_apv_030"));	
				LOGGER.error(ex.getLocalizedMessage(), ex);
			}
			
			return returnObj;
		}
		
	@RequestMapping(value = "resource/webpartSelectMeeting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap webpartSelectResource(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			String folderId = request.getParameter("folderId");
			String viewDate = request.getParameter("viewDate");
			
			param.put("folderId", folderId);
			param.put("viewDate", viewDate);
			
			returnObj.put("list", resourceSvc.webpartSelectMeetingRoom(param));
		}	catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
}
