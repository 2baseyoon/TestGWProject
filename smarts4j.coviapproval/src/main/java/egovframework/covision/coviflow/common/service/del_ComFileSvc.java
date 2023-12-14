package egovframework.covision.coviflow.common.service;


import egovframework.baseframework.data.CoviMap;

public interface del_ComFileSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectList(CoviMap params) throws Exception;
	public int insert(CoviMap params)throws Exception;
	public int update(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
}
