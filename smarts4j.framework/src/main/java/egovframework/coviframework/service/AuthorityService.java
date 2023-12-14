package egovframework.coviframework.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.vo.ACLMapper;

/**
 * @Class Name : AuthorityService.java
 * @Description : 권한 처리
 * @Modification Information 
 * @ 2017.06.14 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.06.14
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

public interface AuthorityService {

	public HashMap<String, String> selectAllowedURL() throws Exception;
	public HashMap<String, String> selectAllowedURL(boolean isAdmin) throws Exception;
	public String[] getAssignedSubject(CoviMap userInfoObj) throws Exception;
	public Map<String, String> getAuthorizedACL(CoviMap userInfoObj) throws Exception;
	public ACLMapper getAuthorizedACL_Menu(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception;
	public ACLMapper getAuthorizedACL_Folder(String serviceType, String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception;
	public HashMap<String, ACLMapper> getAuthorizedACL_FolderList(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception;
	public ACLMapper getAuthorizedACL_Portal(String userCode, String domainID, String deptPath, String[] subjectCodeArr) throws Exception;
	//public String[] getAuthorizedACL(String userId, String objectType, String aclColName, String aclValue) throws Exception;
	public CoviList getAuthorizedMenu(CoviMap params) throws Exception;
	public Object insertACL(CoviMap params)throws Exception;
	public Object deleteACL(CoviMap params)throws Exception;
	public CoviList selectACL(CoviMap params) throws Exception;
	public ACLMapper rebuildACL(CoviMap userDataObj, String fieldName) throws Exception;
	public void syncActionACL(CoviList aclActionData, String changeField) throws Exception;
	public void syncDomainACL(String domainID, String changeField) throws Exception;
	public void syncUserACL(String key, String domainID, String changeField) throws Exception;
	public int selectTwoFactorIpCheck(CoviMap params, String isTarget)throws Exception;
	public Object insertInheritedACL(CoviMap params)throws Exception;
	public Object deleteInheritedACL(CoviMap params)throws Exception;
	public List<CoviMap> selectInheritedACL(CoviMap params) throws Exception;
	public void setInheritedACL(String pObjectID, String pObjectType, boolean pIsUpdateChildren) throws Exception;	
	public HashMap<String, String> selectMenuAuthURL() throws Exception;
	public CoviList selectCompanyACL(CoviMap params) throws Exception;
}
