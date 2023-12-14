package egovframework.core.sevice;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface LicenseSvc {
	public CoviMap getConnectionLogList(CoviMap params) throws Exception;
	public CoviMap getLicenseInfo() throws Exception;
	public CoviMap getLicenseInfo(String domainID) throws Exception;
	public CoviMap getLicenseInfo(String domainID, String domainCode, String domainUrl) throws Exception;
	
	public CoviMap getLicenseManageList(CoviMap params) throws Exception;
	public CoviMap getLicenseManageInfo(CoviMap params) throws Exception;
	public CoviMap getLicensePortal(CoviMap params) throws Exception;
	public int getDupLicenseName(CoviMap params) throws Exception;
	public int addLicenseInfo(CoviMap params) throws Exception;
	public int editLicenseInfo(CoviMap params) throws Exception;
	public int deleteLicense(CoviMap params) throws Exception;

	public CoviMap getUserInfo(CoviMap params) throws Exception;
	public CoviMap getLicenseInfoCnt(CoviMap params) throws Exception;
	public CoviMap getLicenseAddUser(CoviMap params) throws Exception;
	public int insertUserLicense(CoviMap params) throws Exception;
	public int deleteUserLicense(CoviMap params) throws Exception;

}
