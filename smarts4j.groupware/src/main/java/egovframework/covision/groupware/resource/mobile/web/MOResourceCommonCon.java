package egovframework.covision.groupware.resource.mobile.web;

import javax.servlet.http.HttpServletRequest;




import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.vo.ACLMapper;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;


/**
 * @Class Name : MOResourceCommonCon.java
 * @Description : 자원예약 사용자 요청 처리 - 모바일
 * @Modification Information 
 * @ 2017.12.19 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.12.19
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
@RequestMapping("/mobile/resource/")
public class MOResourceCommonCon {
	
	@Autowired
	private EventSvc eventSvc;
	
	@Autowired
	private ResourceSvc resourceSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 권한있는 일정 폴더 조회
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getACLFolder.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getACLFolder(HttpServletRequest request) throws Exception
	{

		CoviMap returnObj = new CoviMap();
		
		CoviList createObj = new CoviList();
		CoviList deleteObj = new CoviList();
		CoviList modifyObj = new CoviList();
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
			returnObj.put("read", readObj);
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
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
	@RequestMapping(value = "getBookingList.do",  method = {RequestMethod.GET, RequestMethod.POST})
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
			 @RequestParam(value = "SearchText", required = false, defaultValue="") String searchText,
			 @RequestParam(value = "RegisterName", required = false, defaultValue="") String registerName
			) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String[] arrApprovalState  = approvalState.split(";");
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			int pageOffset = (pageNo - 1) * pageSize;
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("pageOffset", pageOffset);
			params.put("sortColumn",  ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",  ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("userID", userID);
			params.put("arrApprovalState", arrApprovalState);
			params.put("searchDateType", searchDateType);
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("SearchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("rowStart", pageOffset);		//rowStart	: Oracle 페이징처리용
			params.put("rowEnd", pageOffset+pageSize);			//rowEnd	: Oracle 페이징처리용
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			//params.put("FolderID", folderID);
			//폴더값은 배열로 넘기기
			String[] folderList =  StringUtil.split(folderID, ";");
			params.put("FolderIDs", folderList);
			//등록일 기준 검색일 떄 timezone 적용 날짜변환
			if(params.get("searchDateType") != null && params.getString("searchDateType").equals("RegistDate")) {
				if(params.get("StartDate") != null && !params.get("StartDate").equals("")){
					params.put("StartDate",ComUtils.TransServerTime(params.get("StartDate").toString() + " 00:00:00"));
				}
				if(params.get("EndDate") != null && !params.get("EndDate").equals("")){
					params.put("EndDate",ComUtils.TransServerTime(params.get("EndDate").toString() + " 23:59:59"));
				}
			}
			
			if(mode.equalsIgnoreCase("List")){				
				CoviMap pageParam  = new CoviMap();
				
				if (folderID == null || folderList.length > 0){
					resultList = resourceSvc.getBookingList(params);
					
					pageParam.addAll(ComUtils.setPagingData(params, resultList.getInt("cnt")));			//페이징 parameter set
					
					returnList.put("page", pageParam);
					returnList.put("list", resultList.getJSONArray("bookingList"));
				} else{
					pageParam.addAll(ComUtils.setPagingData(params, 0));			//페이징 parameter set
					
					returnList.put("page", pageParam);
					returnList.put("list", new CoviList());
				}
			}else if((mode.equalsIgnoreCase("D") || mode.equalsIgnoreCase("W") || mode.equalsIgnoreCase("M")) && folderList.length > 0){
				resultList = resourceSvc.getBookingPeriodList(params);
			}
			
			if(!mode.equalsIgnoreCase("List")){
				returnList.put("data", resultList);
			}
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getResourceData - 자원 정보 조회
	 * @param folderID
	 * @throws Exception
	 */
	@RequestMapping(value = "getResourceData.do", method=RequestMethod.POST)
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
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getBookingData - 자원예약 정보 조회
	 * @param mode
	 * @param evnetID
	 * @param dateID
	 * @param repeatID
	 * @param folderID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getBookingData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBookingData(
			@RequestParam(value = "mode", required = true) String mode,
			 @RequestParam(value = "EventID", required = true) int EventID,
			 @RequestParam(value = "DateID", required = true) int DateID,
			 @RequestParam(value = "RepeatID", required = false) String RepeatID,
			 @RequestParam(value = "FolderID", required = false) String FolderID
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			params.put("mode", mode);
			params.put("EventID", EventID);
			params.put("DateID", DateID);
			params.put("RepeatID", RepeatID);
			params.put("FolderID", FolderID);
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = resourceSvc.getBookingData(params);
			
			returnList.put("data", resultList);
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
	
	/**
	 *  modifyBookingState - 자원예약 상태 변경
	 * @param dateID
	 * @param state 변경할 상태코드
	 * @return
	 */
	@RequestMapping(value = "modifyBookingState.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyBookingState(
			 @RequestParam(value = "DateID", required = true) String DateID,
			 @RequestParam(value = "ApprovalState", required = true) String ApprovalState
			) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviList resultArr = new CoviList();
		
		try {
			String[] dataIDArr = DateID.split(";");			
			
			CoviMap params = new CoviMap();
			params.put("ApprovalState", ApprovalState);
			params.put("lang", SessionHelper.getSession("lang"));
			
			for(int i = 0 ;i < dataIDArr.length; i++){
				params.put("DateID", dataIDArr[i]);
				
				resultObj = resourceSvc.modifyBookingState(params);
				resultObj.put("DateID", dataIDArr[i]);
				
				resultArr.add(resultObj);
			}
			
			returnList.put("result", resultArr);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
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
	@RequestMapping(value = "saveBookingData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveBookingData(
			@RequestParam(value = "mode", required = false, defaultValue="I") String mode,
			@RequestParam(value = "eventStr", required = true) String eventStr,
			@RequestParam(value = "isChangeDate", required = true, defaultValue="false") String isChangeDate,
			@RequestParam(value = "isChangeRes", required = true, defaultValue="false") String isChangeRes
			) throws Exception
	{
		CoviMap resultObj = new CoviMap();
		CoviMap returnList = new CoviMap();
		CoviMap eventObj = new CoviMap();
		
		try {
			String eventObjStr = StringEscapeUtils.unescapeHtml(eventStr);
			eventObj = CoviMap.fromObject(eventObjStr);
			
			if(mode.equals("I")){
				resultObj = resourceSvc.saveBookingData(eventObj, null, null);
			}else if(mode.equals("U")){
				resultObj = resourceSvc.modifyBookingData(eventObj, null, null);
			}else if(mode.equals("RU")){
				resultObj = resourceSvc.setEachSchedule(eventObj, null, null, isChangeDate, isChangeRes);
			}
			
			returnList.put("result", resultObj.getString("retType")); //OK or DUPLICATION
			returnList.put("status", Return.SUCCESS);
			returnList.put("message",resultObj.getString("retMsg"));
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			// Redis에 임시로 저장한 본인의 자원예약 정보를 모두 삭제한다
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			instance.removeAll("ResourceBooking_" + eventObj.getString("ResourceID") + "_" + SessionHelper.getSession("USERID"));
		}
		
		return returnList;
		
	}
		
	/**
	 * getManageInfo - 담당자 정보 조회
	 * @param userID
	 * @param groupPath
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getManageInfo.do", method=RequestMethod.POST)
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
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getResourceTreeList - 자원 선택 시 트리
	 * @param placeOfBusiness
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getResourceTreeList.do", method=RequestMethod.POST)
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
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	@RequestMapping(value = "getChkFolderListRedis.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getChkFolderListRedis() throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			String checkStr = instance.get("ResourceCheckBox_" + SessionHelper.getSession("USERID"));
			
			returnList.put("redisData", checkStr);
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
	/*
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
			
			// 예약 가능여부, 첫 추천 시간
			CoviMap firstTimeResultObj = resourceSvc.check(params);
			if(firstTimeResultObj.getString("IsDuplication").equals("1")){
				if(!firstTimeResultObj.getString("StartDateTime").equals("")){
					firstTime.put("StartDateTime", firstTimeResultObj.getString("StartDateTime"));
					firstTime.put("EndDateTime", firstTimeResultObj.getString("EndDateTime"));
				}
				
				// 자원 추천
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
			
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}*/
	
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
	/*@RequestMapping(value = "resource/checkDuplicateTime.do", method=RequestMethod.POST)
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
			
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}*/
}
