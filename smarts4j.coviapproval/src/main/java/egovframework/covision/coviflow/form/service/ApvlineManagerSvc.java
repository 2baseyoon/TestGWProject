package egovframework.covision.coviflow.form.service;


import java.util.ArrayList;

import egovframework.baseframework.data.CoviMap;

public interface ApvlineManagerSvc {
	public CoviMap selectPrivateDomainList(CoviMap params)throws Exception;

	public int deletePrivateDomain(CoviMap params);

	public CoviMap selectDistributionList(CoviMap params)throws Exception;

	public int updatePrivateDomain(CoviMap params)throws Exception;

	public CoviMap selectDistributionMember(CoviMap params)throws Exception;

	public int updatePrivateDomainDefaultY(CoviMap params)throws Exception;

	public int updatePrivateDomainDefaultN(CoviMap params)throws Exception;

	public CoviMap selectPrivateDistribution(CoviMap params)throws Exception;

	public CoviMap selectPrivateDistributionMember(CoviMap params)throws Exception;

	public int deletePrivateDistribution(CoviMap params)throws Exception;

	public int deletePrivateDistributionMemberData(CoviMap params)throws Exception;

	public CoviMap selectAbsentMember(CoviMap params)throws Exception;

	public CoviMap selectAbsentGroup(CoviMap params)throws Exception;

	public int insertPrivateDomainData(CoviMap params)throws Exception;

	public int insertPrivateDistribution(CoviMap params)throws Exception;

	public int insertPrivateDistributionMember(CoviMap params2)throws Exception;
	
	public int selectApvlineAuth(CoviMap params)throws Exception;

	public CoviMap selectPrivateGovDistributionMember(CoviMap params)throws Exception;

	public CoviMap selectDistributionMemberList(CoviMap params)throws Exception;
	
	// 문서 내 결재선 임직원/부서 자동완성 목록 조회
	public CoviMap selectAddInLineAutoSearchList(CoviMap params)throws Exception;

	public int addDocComment(CoviMap params)throws Exception;

	public CoviMap selectDocCommentList(CoviMap params)throws Exception;

	public int addDocCommentReply(CoviMap params)throws Exception;

	public int updateCommentRelpyCnt(String CommentID)throws Exception;

	public int modifyDocComment(CoviMap params)throws Exception;

	public int delDocComment(String CommentID)throws Exception;

	public int delRelayCount(CoviMap params)throws Exception;

	public void setCommentMessage(CoviMap formObj)throws Exception;

	public int updateDocCommentSort(CoviMap params)throws Exception;

}
