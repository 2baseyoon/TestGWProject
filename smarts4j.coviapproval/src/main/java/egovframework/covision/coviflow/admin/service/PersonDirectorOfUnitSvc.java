package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface PersonDirectorOfUnitSvc {
	public CoviMap getPersonDirectorOfUnitList(CoviMap params) throws Exception;		
	public Object insertJWF_DIRECTORMEMBER(CoviMap params)throws Exception;
	public Object insertJWF_DIRECTOR(CoviMap params)throws Exception;
	public CoviMap getPersonDirectorOfUnitData(CoviMap params) throws Exception;
	public int deleteJWF_DIRECTORMEMBER(CoviMap params)throws Exception;
	public int deleteJWF_DIRECTOR(CoviMap params)throws Exception;
	public int chkDuplicateTarget(CoviMap params) throws Exception;
}
