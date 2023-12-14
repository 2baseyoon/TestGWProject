package egovframework.core.sevice;



import java.util.ArrayList;

import egovframework.baseframework.data.CoviMap;

public interface SysBaseConfigSvc {

	public CoviMap select(CoviMap params) throws Exception;
	public Object insert(CoviMap params)throws Exception;
	public int insertMerge(CoviMap params)throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int update(CoviMap params)throws Exception;
	public int updateIsUse(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
	public int selectForCheckingDouble(CoviMap params)throws Exception;
	public int selectForCheckingKey(CoviMap params) throws Exception;
	public CoviMap selectExcel(CoviMap params) throws Exception;
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception;
	public CoviMap checkExcelWorkInfoData(ArrayList<ArrayList<Object>> dataList) throws Exception;
}
