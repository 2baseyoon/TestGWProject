package egovframework.covision.coviflow.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface CommonApprovalListSvc {
	public CoviMap selectDomainListData(CoviMap params) throws Exception;
	public CoviMap selectCommFileListData(CoviMap params) throws Exception;
	public CoviMap selectDocreadHistoryListData(CoviMap params) throws Exception;
	public CoviMap selectAdminMnLIstData(CoviMap params) throws Exception;
	public int selectSingleDocreadData(CoviMap params) throws Exception;
	public CoviMap getPersonDirectorOfPerson(CoviMap params) throws Exception;
	public CoviList getPersonDirectorOfUnitData(CoviMap params) throws Exception;
}
