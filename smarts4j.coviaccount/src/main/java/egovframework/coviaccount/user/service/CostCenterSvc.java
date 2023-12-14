package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface CostCenterSvc {
	public CoviMap getCostCenterlist(CoviMap params) throws Exception;
	public CoviMap getCostCenterDetail(CoviMap params) throws Exception;
	public CoviMap saveCostCenterInfo(CoviMap params) throws Exception;
	public CoviMap deleteCostCenter(CoviMap params) throws Exception;
	CoviMap getCostCenterExcelList(CoviMap params) throws Exception;
	public CoviMap costCenterExcelUpload(CoviMap params) throws Exception;
	public CoviList getCostCenterUserMappingDeptList(CoviMap params) throws Exception;
	public CoviMap getCostCenterUserMappingUserList(CoviMap params) throws Exception;
	public CoviMap updateCostCenterUserMappingInfo(CoviMap params) throws Exception;
	public CoviMap getCostCenterUserMappingExcelList(CoviMap params) throws Exception;
	public CoviMap costCenterUserMappingExcelUpload(CoviMap params) throws Exception;
	public CoviMap costCenterSync();
	public CoviMap getCostCenterCodeCnt(CoviMap params) throws Exception;
	public CoviMap costCenterUserMappingSync();
}