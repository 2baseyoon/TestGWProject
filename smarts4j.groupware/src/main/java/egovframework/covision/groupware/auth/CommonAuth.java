package egovframework.covision.groupware.auth;

import java.util.Set;



import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ACLHelper;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;

public class CommonAuth {

	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getUserAuth(CoviMap pMap) throws Exception{
		try {
			if (pMap.getString("UserCode").equals("") || pMap.getString("UserCode").equals(SessionHelper.getSession("USERID"))){
				return true;
			}
			else return false;
		} catch(NullPointerException e){
			return false;
		} catch(Exception e){
			return false;
		}
	}

	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getFolderAuth(String bizSection, String folderID) throws Exception{
		return getFolderAuth(bizSection, folderID, "V");
	}
		
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getFolderAuth(String bizSection, String folderID, String authType) throws Exception{
		//관리자
		if("Y".equals(SessionHelper.getSession("isAdmin")) ) return true;		
			
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", bizSection, authType);
		
		String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		for(int i=0; i <objectArray.length; i++){
			if (objectArray[i].equals(folderID)){
				return true;
			}
		}
		return false;
	}
	
	
	//sys_object_acl에서 sys_object_folder에 대한 View 권한 조회
	public static boolean getMultiFolderAuth(String bizSection, String[] folderList, String authType) throws Exception{
		//관리자
		if("Y".equals(SessionHelper.getSession("isAdmin")) ) return true;		
		for (int i=0; i< folderList.length; i++){
			if (getFolderAuth(bizSection, folderList[i], authType) == false){
				return false;
			}
		}
		return true;
	}
		
}
