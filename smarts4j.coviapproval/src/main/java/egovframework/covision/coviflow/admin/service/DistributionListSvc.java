package egovframework.covision.coviflow.admin.service;


import egovframework.baseframework.data.CoviMap;

public interface DistributionListSvc {
	public CoviMap selectDistributionList(CoviMap params) throws Exception;
	public int insertDistributionList(CoviMap params)throws Exception;
	public int updateDistribution(CoviMap params)throws Exception;
	public int deleteDistribution(CoviMap params)throws Exception;
	public CoviMap selectDistirbutionData(CoviMap params) throws Exception;
	public CoviMap selectDistributionMemberList(CoviMap params) throws Exception;
	public int insertDistributionMember(CoviMap params)throws Exception;
	public int updateDistributionMember(CoviMap params)throws Exception;
	public int deleteDistributionMember(CoviMap params)throws Exception;
	public CoviMap selectDistributionMemberData(CoviMap params) throws Exception;
}
