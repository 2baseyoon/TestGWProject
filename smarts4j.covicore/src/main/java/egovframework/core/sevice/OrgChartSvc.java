package egovframework.core.sevice;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;


public interface OrgChartSvc {
	public CoviList getDeptList(CoviMap params) throws Exception;
	public CoviList getGroupList(CoviMap params) throws Exception;
	public CoviMap getUserList(CoviMap params) throws Exception;
	public CoviMap getGroupUserList(CoviMap params) throws Exception;
	public CoviMap getCompanyList(CoviMap params) throws Exception;
	public CoviList getAllUserAutoTagList(CoviMap params) throws Exception;
	public CoviList getAllUserGroupAutoTagList(CoviMap params) throws Exception;
	
	public CoviList getInitOrgTreeList(CoviMap params) throws Exception;
	public CoviList getChildrenData(CoviMap params) throws Exception;
	public CoviMap getOrgPathInfo(CoviMap params) throws Exception;
	public CoviList getGovOrgTreeList(CoviMap params) throws Exception;	
	public CoviList getGov24OrgTreeList(CoviMap params) throws Exception;
	public CoviMap getSelectedUserList(CoviMap params) throws Exception;
	public CoviMap getSelectedDeptList(CoviMap params) throws Exception;
}
