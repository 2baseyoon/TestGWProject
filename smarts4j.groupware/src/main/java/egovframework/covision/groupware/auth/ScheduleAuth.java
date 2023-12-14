package egovframework.covision.groupware.auth;


import java.util.Objects;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.event.user.service.EventSvc;
import egovframework.covision.groupware.schedule.user.service.ScheduleSvc;



public class ScheduleAuth {
	/**
	 * 일정 읽기권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getReadAuth(CoviMap params) throws Exception{
		boolean bReadAuth = false;
		
		try {
			ScheduleSvc scheduleSvc = StaticContextAccessor.getBean(ScheduleSvc.class);
			
			setParameter(params);
			
			CoviMap resultList = scheduleSvc.getOneDetail(params);
			if(resultList == null) return true; 
			
			CoviMap resultEvent = (CoviMap) resultList.get("Event");
			CoviList listAttd = (CoviList) resultList.get("Attendee");
			
			if(resultEvent.getString("RegisterCode").equals(params.getString("UserCode")) || 
				resultEvent.getString("OwnerCode").equals(params.getString("UserCode")) ||
				CommonAuth.getFolderAuth("Schedule", resultEvent.getString("FolderID"), "R") ||
				CommonAuth.getFolderAuth("Community", resultEvent.getString("FolderID"), "R")) {
				bReadAuth = true;
			}

			for(int i = 0; i < listAttd.size(); i++){ // 참석자
				CoviMap resultAttd = (CoviMap) listAttd.get(i);
				
				if(resultAttd.getString("UserCode").equals(params.getString("UserCode"))) {
					return true;
				}
			}
			
			// 일정 공개 여부 체크
			if(resultEvent.getString("IsPublic").equals("N")
				&& !resultEvent.getString("RegisterCode").equals(params.getString("UserCode"))){
				return false;
			}
			
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return bReadAuth;
	}
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getMultiFolderAuth(CoviMap  pMap) throws Exception{
		//관리자
		if("Y".equals(SessionHelper.getSession("isAdmin")) ) return true;
		
		String[] folderIds = {""};
		
		if (pMap.getString("FolderIDs").indexOf(",") > -1) {
			folderIds = pMap.getString("FolderIDs").replace("(","").replace(")","").split(",");
		} else if (pMap.getString("FolderIDs").indexOf(";") > -1) {
			folderIds = pMap.getString("FolderIDs").replace("(","").replace(")","").split(";");
		}
		
		for(int i = 0; i < folderIds.length; i++){
			if (!folderIds[i].equals("")){
				if (CommonAuth.getFolderAuth("Schedule", folderIds[i]) == false && CommonAuth.getFolderAuth("Community", folderIds[i]) == false){
					//System.out.println(folderIds[i]);
					return false;
				}
			}	
		}
		return true;
	}
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getViewFolderAuth(CoviMap  pMap) throws Exception{
		//관리자
		if("Y".equals(SessionHelper.getSession("isAdmin")) ) return true;		
		
		String[] folderIds = pMap.getString("FolderIDs").split(";");
		for (int i=0; i< folderIds.length; i++){
			if (!folderIds[i].equals("")){
				if (CommonAuth.getFolderAuth("Schedule", folderIds[i]) == false && CommonAuth.getFolderAuth("Community", folderIds[i]) == false){
					return false;
				}
			}	
		}
		return true;
	}
	
	/**
	 * 일정 등록/수정 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getModifyAuth(CoviMap  pMap){
		boolean bModify = false;
		
		try {
			EventSvc eventSvc = StaticContextAccessor.getBean(EventSvc.class);
			
			setParameter(pMap);
			
			String eventStr = Objects.toString(pMap.get("eventObj"), "");
			String folderId = "";
			
			if (StringUtil.isNotNull(eventStr)) {
				CoviMap eventObj = CoviMap.fromObject(eventStr);
				
				if (pMap.getString("mode").equals("U")){
					pMap.put("EventID", eventObj.getString("EventID"));
					folderId = eventObj.getString("FolderID");
					
					CoviMap resultMap = eventSvc.selectEvent(pMap);
					if(resultMap.getString("RegisterCode").equals(pMap.getString("UserCode")) || 
						resultMap.getString("OwnerCode").equals(pMap.getString("UserCode")) ||
						CommonAuth.getFolderAuth("Schedule", folderId, "M") ||
						CommonAuth.getFolderAuth("Community", folderId, "M")) {
						bModify = true;
					}
				} else { // 등록 권한 체크
					CoviMap event = eventObj.getJSONObject("Event"); // 이벤트 마스터 정보
					folderId = event.getString("FolderID");
					
					if (CommonAuth.getFolderAuth("Schedule", folderId, "C") ||
						CommonAuth.getFolderAuth("Community", folderId, "C")) {
						bModify = true;
					}	
				}
			} else if(StringUtil.isNotNull(pMap.getString("EventID"))) {
				CoviMap resultMap = eventSvc.selectEvent(pMap);
				
				if(resultMap.getString("RegisterCode").equals(pMap.getString("UserCode")) || 
					resultMap.getString("OwnerCode").equals(pMap.getString("UserCode")) ||
					CommonAuth.getFolderAuth("Schedule", folderId, "M") ||
					CommonAuth.getFolderAuth("Community", folderId, "M")) {
					bModify = true;
				}
			}
			
			return bModify;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 일정 삭제 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getDeleteAuth(CoviMap pMap){
		boolean bDelete = false;
		
		try {
			EventSvc eventSvc = StaticContextAccessor.getBean(EventSvc.class);
			
			setParameter(pMap);
			
			CoviMap resultMap = eventSvc.selectEvent(pMap);
			
			if(resultMap.getString("RegisterCode").equals(pMap.getString("UserCode")) || 
					resultMap.getString("OwnerCode").equals(pMap.getString("UserCode")) ||
					CommonAuth.getFolderAuth("Schedule", resultMap.getString("FolderID"), "D") ||
					CommonAuth.getFolderAuth("Community", resultMap.getString("FolderID"), "D")) {
				bDelete = true;
			}
			
			return bDelete;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 일정 참석자 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getAttendAuth(CoviMap params) {
		boolean bAttendAuth = false;
		
		try {
			ScheduleSvc scheduleSvc = StaticContextAccessor.getBean(ScheduleSvc.class);
			
			setParameter(params);
			
			CoviList attendeeList = scheduleSvc.selectAttendee(params);
			
			for(Object aObj : attendeeList){
				CoviMap attendee = (CoviMap) aObj;
				
				if (attendee.getString("UserCode").equals(params.getString("UserCode"))) {
					return true;
				}
			}
			
			return bAttendAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	private static void setParameter(CoviMap params) {
		String eventID = params.getString("EventID");
		String dateID = params.getString("DateID");
		String folderID = params.getString("FolderID");
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		
		if(StringUtil.isNull(eventID)) {
			if(StringUtil.isNotNull(params.getString("eventID"))) {
				eventID = params.getString("eventID");
			}
		}
		
		if(StringUtil.isNull(dateID)) {
			if(StringUtil.isNotNull(params.getString("dateID"))) {
				dateID = params.getString("dateID");
			}
		}
		
		if(StringUtil.isNull(folderID)) {
			if(StringUtil.isNotNull(params.getString("folderID"))) {
				folderID = params.getString("folderID");
			}
		}
		
		params.put("EventID", eventID);
		params.put("DateID", dateID);
		params.put("FolderID", folderID);
	}
}
