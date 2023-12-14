package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface AdminFormClassSvc {
	public CoviMap getFormClassList(CoviMap params) throws Exception;
	public CoviMap getFormClassData(CoviMap params) throws Exception;
	public int insertFormClassData(CoviMap params) throws Exception ;
	public int updateFormClassData(CoviMap params) throws Exception ;
	public int selectEachFormClassData(CoviMap params) throws Exception ;
	public int deleteFormClassData(CoviMap params) throws Exception ;
	public void updateAclListClassData(CoviMap params)throws Exception;
	public void deleteAclListClassData(CoviMap params)throws Exception;
}
