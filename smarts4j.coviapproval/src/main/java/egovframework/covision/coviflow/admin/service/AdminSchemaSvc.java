package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface AdminSchemaSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public Object insert(CoviMap params) throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int update(CoviMap params) throws Exception;
	public int delete(CoviMap params) throws Exception;
	public int selectForm(CoviMap params) throws Exception;
}
