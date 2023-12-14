package egovframework.covision.coviflow.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface RightApprovalConfigSvc {
	public CoviMap selectUserSetting(CoviMap params) throws Exception;
	public int updateUserSetting(CoviMap params)throws Exception;
	public CoviList selectJFMemberID(CoviMap params)throws Exception;
	public CoviList selectGRMemberID(CoviMap params)throws Exception;
	public CoviMap selectApprovalPasswordPolicy(CoviMap params) throws Exception;
}
