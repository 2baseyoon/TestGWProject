package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SysThemeSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectCode(CoviMap params) throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int insert(CoviMap params) throws Exception;
	public int update(CoviMap params)throws Exception;
	public int delete(CoviMap params) throws Exception;
	public int updateIsUse(CoviMap params)throws Exception;
	public int changeSortKey(CoviMap params)throws Exception;
}
