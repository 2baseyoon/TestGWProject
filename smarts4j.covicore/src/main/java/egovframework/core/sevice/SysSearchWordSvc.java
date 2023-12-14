package egovframework.core.sevice;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface SysSearchWordSvc {

	public int selectListCount(CoviMap params) throws Exception;
	public CoviList selectList(CoviMap params) throws Exception;
	public void insertData(CoviMap params) throws Exception;
	public void updateData(CoviMap params) throws Exception;
	public void deleteData(CoviMap params) throws Exception;
	public CoviMap selectData(CoviMap params) throws Exception;
	public void insertSearchData(CoviMap params) throws Exception;
	public CoviMap checkDouble(CoviMap params) throws Exception;
}
