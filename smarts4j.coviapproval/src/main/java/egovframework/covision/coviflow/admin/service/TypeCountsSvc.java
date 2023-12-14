package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface TypeCountsSvc {
	public CoviMap getStatDeptList(CoviMap params) throws Exception;
	public CoviMap getStatFormList(CoviMap params) throws Exception;
	public CoviMap getStatPersonList(CoviMap params) throws Exception;
}
