package egovframework.core.sevice;



import egovframework.baseframework.data.CoviMap;

public interface SysAclSvc {
	public CoviMap getAclList(CoviMap params) throws Exception;
	public CoviMap getAclTarget(CoviMap params) throws Exception;
	public CoviMap getAclDetail(CoviMap params) throws Exception;
	public CoviMap deleteAcl(CoviMap params) throws Exception;
	public CoviMap getFolderType(CoviMap params) throws Exception;
	public CoviMap getACLInfo(CoviMap params) throws Exception;
	public CoviMap addAclInfo(CoviMap params) throws Exception;
	public CoviMap setACLInfo(CoviMap params) throws Exception;
	public CoviMap getAddList(CoviMap params) throws Exception;
	public CoviMap getAddTargetList(CoviMap params) throws Exception;
	public void syncAclData(String objectType, String domainID) throws Exception;
	public String getDomainID(String domainCode) throws Exception;
}
