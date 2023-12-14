package egovframework.covision.groupware.auth;

import org.apache.commons.lang.StringEscapeUtils;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.resource.user.service.ResourceSvc;



public class ResourceAuth {
	/**
	 * 자원 폴더 권한읽기권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getReadAuth(CoviMap params) throws Exception{
		String folderId = params.getString("FolderID");
		if (folderId == null || folderId.equals("")) return true;
		else{
			return CommonAuth.getFolderAuth("Resource", folderId);
		}	
		

	}	
	
	/***
	 * 자원 멀티 폭더 읽기권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getMultiFolderReadAuth(CoviMap params) throws Exception{
		String[] folderList =  StringUtil.split(params.getString("FolderIDs"), ";");
		return CommonAuth.getMultiFolderAuth("Resource", folderList, "V");
	}	
	
	/***
	 * 자원 멀티 폭더 읽기권한 
	 * @param userId
	 * @param domainID
	 * @param aclArray
	 * @return
	 * @throws Exception
	 */
	public static boolean getMultiFolderReadAuth2(CoviMap params) throws Exception{
		String[] folderList =  StringUtil.split(params.getString("FolderIDs").replace("(", "").replace(")", ""), ",");
		return CommonAuth.getMultiFolderAuth("Resource", folderList, "V");
	}	
	

	/***
	 * 자원 리소스 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getResourceAuth(CoviMap params) throws Exception{
		String userCode = SessionHelper.getSession("USERID");
		String eventStr = params.getString("eventStr");
		String eventObjStr = StringEscapeUtils.unescapeHtml(eventStr);
		CoviMap eventObj = CoviMap.fromObject(eventObjStr);
		params.put("ResourceID", eventObj.getString("ResourceID"));
		
		if (params.getString("mode").equals("I")){//등록인 경우
			return CommonAuth.getFolderAuth("Resource", params.getString("ResourceID"));
		}
		else{
			ResourceSvc resourceSvc = StaticContextAccessor.getBean(ResourceSvc.class);
			params.put("EventID", eventObj.getString("EventID"));
			params.put("RepeatID", eventObj.getString("RepeatID"));
			
			CoviMap returnObj = resourceSvc.getBookingData(params);
			CoviMap bookingData = (CoviMap)returnObj.get("bookingData");
			
			if((bookingData.getString("RegisterCode").equals(userCode) || bookingData.getString("OwnerCode").equals(userCode) || CommonAuth.getFolderAuth("Resource", params.getString("ResourceID")))
					&& (bookingData.getString("ApprovalStateCode").equals("ApprovalRequest") 
							|| (bookingData.getString("ApprovalStateCode").equals("Approval") && bookingData.getString("BookingTypeCode").equals("DirectApproval")))){		// 수정 권한 체크
				return true;	
			}
	
			return false;
		}	
	}	
	
	/***
	 * 자원 리소스 상태 변경 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getResourceStatusAuth(CoviMap params){
		boolean bResourceStatusAuth = false;
		
		try {
			ResourceSvc resourceSvc = StaticContextAccessor.getBean(ResourceSvc.class);
			String userCode = SessionHelper.getSession("USERID");
			
			CoviMap returnObj = resourceSvc.getBookingData(params);
			CoviMap bookingData = returnObj.getJSONObject("bookingData");
			CoviList arrayBookingData = (CoviList)returnObj.get("arrayBookingData");
			
			if (bookingData.isEmpty() && arrayBookingData != null && arrayBookingData.size()>0){
				bookingData = arrayBookingData.getJSONObject(0); 
			}
			// 예약 승인/거부 권한(담당자)
			if(StringUtil.isNotNull(params.getString("ApprovalState"))) {
				params.put("lang", SessionHelper.getSession("lang"));
				params.put("ObjectType", "FD");
				params.put("FolderID", bookingData.getString("ResourceID"));
				
				CoviMap resourceData = resourceSvc.getResourceData(params);
				CoviList managerList = resourceData.getJSONArray("managerList");
				
				for(int i = 0; i < managerList.size(); i++) {
					CoviMap manager = managerList.getJSONObject(i);
					
					if ((manager.getString("UserType").equals("User") && manager.getString("SubjectCode").equals(userCode))
						|| (manager.getString("UserType").equals("Group") && SessionHelper.getSession("GR_GroupPath").indexOf(manager.getString("SubjectCode")) > -1)) {
						return true;
					}
				}
			}
			
			if (bookingData.getString("RegisterCode").equals(userCode) || bookingData.getString("OwnerCode").equals(userCode)){
				bResourceStatusAuth = true;
			}
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return bResourceStatusAuth;
	}
}
