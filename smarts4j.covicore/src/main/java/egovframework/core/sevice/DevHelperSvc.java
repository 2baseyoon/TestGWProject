package egovframework.core.sevice;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface DevHelperSvc {
	
	public int updateModuleIsUse(CoviMap params) throws Exception;
	public int updateModuleIsAdmin(CoviMap params) throws Exception;
	public int updateModuleIsAudit(CoviMap params) throws Exception;
	public int selectModuleDataCnt(CoviMap params) throws Exception;
	public CoviList selectModuleDataList(CoviMap params) throws Exception;
	public int insertModuleData(CoviMap params) throws Exception;
	public int insertPrgmData(CoviMap params) throws Exception;
	public int selectPrgmDataCnt(CoviMap params) throws Exception;
	public CoviList selectPrgmDataList(CoviMap params) throws Exception;
	public int selectPrgmMapDataCnt(CoviMap params) throws Exception;
	public CoviList selectPrgmMapDataList(CoviMap params) throws Exception;
	public int selectPrgmMenuDataCnt(CoviMap params) throws Exception;
	public CoviList selectPrgmMenuDataList(CoviMap params) throws Exception;
	public int insertPrgmMapData(CoviMap params) throws Exception;
	public int selectMenuDataCnt(CoviMap params) throws Exception;
	public CoviList selectMenuDataList(CoviMap params) throws Exception;
	public int insertPrgmMenuData(CoviMap params) throws Exception;
	public int deleteModuleData(CoviMap params) throws Exception;
	public int deletePrgmData(CoviMap params) throws Exception;
	public int deletePrgmMapData(CoviMap params) throws Exception;
	public int deletePrgmMenuData(CoviMap params) throws Exception;
	public int updateModuleData(CoviMap params) throws Exception;
	public int updatePrgmData(CoviMap params) throws Exception;
	public int updatePrgmMenuData(CoviMap params) throws Exception;
	public CoviList selectModulePrgmMapList(CoviMap params) throws Exception;
	public CoviList selectBoardSampleList(CoviMap params) throws Exception ;
	public int selectBoardlistCountExample(CoviMap params) throws Exception;
}
