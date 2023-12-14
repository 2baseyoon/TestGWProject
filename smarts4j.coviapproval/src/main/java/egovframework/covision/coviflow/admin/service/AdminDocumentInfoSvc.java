package egovframework.covision.coviflow.admin.service;

import egovframework.baseframework.data.CoviMap;

public interface AdminDocumentInfoSvc {
	public void updateDocData(CoviMap params) throws Exception;
	public int deleteMarkingDel(CoviMap params) throws Exception;
	public int markingRollBack(CoviMap params) throws Exception;
	public int deleteClearDel(CoviMap params) throws Exception;
	
}
