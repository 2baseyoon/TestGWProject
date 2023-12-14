package egovframework.api.v1.service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.json.JSONObject;

public interface OrgApiSvc {
	
	public int insertGroup(CoviMap params) throws Exception;
	public int updateGroup(CoviMap params) throws Exception;
	public int deleteGroup(CoviMap params) throws Exception;
	
	public int insertUser(CoviMap params) throws Exception;
	public int updateUser(CoviMap params, JSONObject oldparams) throws Exception;
	public int deleteUser(CoviMap params) throws Exception;
	
	public CoviMap selectJobList(CoviMap params) throws Exception;		
	public CoviMap selectDeptList(CoviMap params) throws Exception;	
	
	public CoviMap selectUserList(CoviMap params) throws Exception;
	public CoviMap selectUserView(CoviMap params) throws Exception;
}
