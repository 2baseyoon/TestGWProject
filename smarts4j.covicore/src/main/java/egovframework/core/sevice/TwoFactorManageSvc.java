package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface TwoFactorManageSvc {

	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectTwoFactorInfo(CoviMap params) throws Exception;
	public boolean twoFactorUserIsCheck(CoviMap params) throws Exception;
	public boolean twoFactorAdminIsCheck(CoviMap params) throws Exception;
	public boolean deleteTwoFactorList(CoviMap params) throws Exception;
	public boolean twoFactorEdit(CoviMap params) throws Exception;
	public boolean twoFactorAdd(CoviMap params) throws Exception;
	
}
