package egovframework.covision.groupware.auth;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.task.user.service.TaskSvc;


import egovframework.baseframework.util.json.JSONSerializer;

public class TaskAuth {
	
	/**
	 * 폴더 관리자 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getFolderAdminAuth(CoviMap params){
		boolean bFolderAdminAuth = false;
		
		try {
			TaskSvc taskSvc = StaticContextAccessor.getBean(TaskSvc.class);
			
			setParameter(params); // 파라미터 세팅
			
			String userCode = params.getString("userCode");
			CoviMap folderData = taskSvc.getFolderData(params);
			
			if ("Y".equals(SessionHelper.getSession("isAdmin"))) {
				bFolderAdminAuth = true;
			} else if (folderData.getString("RegisterCode").equals(userCode) || folderData.getString("OwnerCode").equals(userCode)) {
				bFolderAdminAuth = true;
			}
			
			return bFolderAdminAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 업무 관리자 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getTaskAdminAuth(CoviMap params){
		boolean bTaskAdminAuth = false;
		
		try {
			TaskSvc taskSvc = StaticContextAccessor.getBean(TaskSvc.class);
			
			setParameter(params); // 파라미터 세팅
			
			String userCode = params.getString("userCode");
			CoviMap taskData = taskSvc.getTaskData(params);
			
			if ("Y".equals(SessionHelper.getSession("isAdmin"))) {
				bTaskAdminAuth = true;
			} else if (taskData.getString("RegisterCode").equals(userCode) || taskData.getString("OwnerCode").equals(userCode)) {
				bTaskAdminAuth = true;
			}
			
			return bTaskAdminAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 폴더 멤버 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getFolderMemberAuth(CoviMap params){
		boolean bFolderMemberAuth = false;
		
		try {
			TaskSvc taskSvc = StaticContextAccessor.getBean(TaskSvc.class);
			
			setParameter(params); // 파라미터 세팅
			
			if (getFolderAdminAuth(params)) { // 폴더 관리자 권한
				bFolderMemberAuth = true;
			} else if (params.getString("mode").indexOf("I") > -1) { // 생성 시 권한체크 X
				bFolderMemberAuth = true;
			} else if (StringUtil.isNotNull(params.getString("FolderID"))) {
				if (params.getString("FolderID").equals("0")) { // 내가 하는 일/같이 하는 일
					bFolderMemberAuth = true;
				} else {
					CoviList folderMemberList = taskSvc.getFolderShareMember(params);
					String groupPath = SessionHelper.getSession("GR_GroupPath");
					
					for(Object fObj : folderMemberList) {
						CoviMap member = (CoviMap) fObj;
						
						if((member.getString("Type").equals("UR") && member.getString("Code").equals(params.getString("userCode")))
							|| ((member.getString("Type").equals("GR") || (member.getString("Type").equals("CM"))) && groupPath.indexOf(member.getString("Code")) > -1)){
							return true;
						}
					}
				}
			}
			
			return bFolderMemberAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 업무 멤버 권한 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getTaskMemberAuth(CoviMap params){
		boolean bTaskMemberAuth = false;
		
		try {
			TaskSvc taskSvc = StaticContextAccessor.getBean(TaskSvc.class);
			
			setParameter(params); // 파라미터 세팅
			
			if (getTaskAdminAuth(params)) { // 업무 관리자 권한
				bTaskMemberAuth = true;
			} else if (params.getString("mode").indexOf("I") > -1) { // 생성 시 권한체크 X
				bTaskMemberAuth = true;
			} else if (StringUtil.isNotNull(params.getString("TaskID"))) {
				CoviList taskMemberList = taskSvc.getTaskPerformer(params);
				String groupPath = SessionHelper.getSession("GR_GroupPath");
				
				for (Object tObj : taskMemberList) {
					CoviMap member = (CoviMap) tObj;
					
					if((member.getString("Type").equals("UR") && member.getString("Code").equals(params.getString("userCode")))
						|| ((member.getString("Type").equals("GR") || (member.getString("Type").equals("CM"))) && groupPath.indexOf(member.getString("Code")) > -1)){
						return true;
					}
				}
				
				if (StringUtil.isNotNull(params.getString("FolderID"))) { // 공유 업무일 때 폴더 권한 체크
					bTaskMemberAuth = getFolderMemberAuth(params);
				}
			}
			
			return bTaskMemberAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	private static void setParameter(CoviMap params) {
		if (StringUtil.isNotNull(params.getString("taskStr"))) {
			CoviMap taskObj = CoviMap.fromObject(JSONSerializer.toJSON(params.getString("taskStr")));
			
			if (taskObj.get("TaskID") != null && StringUtil.isNotNull(taskObj.getString("TaskID"))) {
				params.put("TaskID", taskObj.getString("TaskID"));
			}
			
			if (taskObj.get("FolderID") != null && StringUtil.isNotNull(taskObj.getString("FolderID"))) {
				params.put("FolderID", taskObj.getString("FolderID"));
			}
		} else if (StringUtil.isNotNull(params.getString("taskID"))) {
			params.put("TaskID", params.getString("taskID"));
		} else if (StringUtil.isNotNull(params.getString("folderID"))) {
			params.put("FolderID", params.getString("folderID"));
		}
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
	}
}
