package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;


public interface OrgSyncExcelSvc {
	//엑셀동기화
	public CoviMap checkSyncCompany(CoviMap params) throws Exception;
	public CoviMap insertFileDataDept(CoviMap params) throws Exception;
	public CoviMap insertFileDataUser(CoviMap params) throws Exception;
	public CoviMap syncCompareObjectForExcel(String pType) throws Exception;
	public CoviMap getExcelTempDeptDataList(CoviMap params) throws Exception;
	public CoviMap getExcelTempUserDataList(CoviMap params) throws Exception;
	public int deleteSelectDept(CoviMap params) throws Exception;
	public int deleteSelectUser(CoviMap params) throws Exception;
	public int deleteTemp() throws Exception;
	public int deleteAll(CoviMap params) throws Exception;
	public CoviMap deleteExcelorgdept(CoviMap params) throws Exception;
	public CoviMap deleteExcelorguser(CoviMap params) throws Exception;
	public int deleteOtherCompany(CoviMap params) throws Exception;
	CoviMap selectIsDupDeptCode(CoviMap params) throws Exception;
	CoviMap selectIsDupUserCode(CoviMap params) throws Exception;
	CoviMap selectIsDupEmpNo(CoviMap params) throws Exception;
}
