package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface UnitDirectorSvc {
	public CoviMap getUnitDirectorList(CoviMap params) throws Exception;		
	public Object insertjwf_unitdirectormember(CoviMap params)throws Exception;
	public Object insertjwf_unitdirector(CoviMap params)throws Exception;
	public CoviMap getUnitDirectorData(CoviMap params) throws Exception;
	public int deletejwf_unitdirectormember(CoviMap params)throws Exception;
	public int deletejwf_unitdirector(CoviMap params)throws Exception;
	
}
