package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface PersonDirectorSvc {
	public CoviMap getPersonDirectorList(CoviMap params) throws Exception;
	public Object insertjwf_persondirectormember(CoviMap params)throws Exception;
	public Object insertjwf_persondirector(CoviMap params)throws Exception;
	public CoviMap getPersonDirectorData(CoviMap params) throws Exception;
	public int deletejwf_persondirectormember(CoviMap params)throws Exception;
	public int deletejwf_persondirector(CoviMap params)throws Exception;
	public int chkDuplicateTarget(CoviMap params) throws Exception;
}
