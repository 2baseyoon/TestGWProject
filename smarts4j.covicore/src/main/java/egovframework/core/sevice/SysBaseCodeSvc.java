package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SysBaseCodeSvc {

	public CoviMap select(CoviMap params) throws Exception;
	public Object insert(CoviMap params)throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public String selectOneString(CoviMap params) throws Exception;
	public CoviMap selectOneObject(CoviMap params) throws Exception;
	public int update(CoviMap params)throws Exception;
	public int updateIsUse(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
	public int selectForCheckingDouble(CoviMap params)throws Exception;
	public CoviMap selectExcel(CoviMap params) throws Exception;
	public CoviMap selectBaseCodeGroupObject(CoviMap params) throws Exception;
	public CoviMap selectCodeGroupList(CoviMap params) throws Exception;
}
