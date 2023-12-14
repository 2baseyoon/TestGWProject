package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SysPasswordPolicySvc {

	public CoviMap getSelectPolicyComplexity(CoviMap params) throws Exception;
	public CoviMap getPolicy(CoviMap params) throws Exception;
	
	public boolean updatePasswordPolicy(CoviMap params, CoviMap parInitPass, CoviMap parFailCount) throws Exception;
}
