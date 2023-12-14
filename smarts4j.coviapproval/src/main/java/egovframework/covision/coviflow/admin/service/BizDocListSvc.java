package egovframework.covision.coviflow.admin.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface BizDocListSvc {
	public CoviMap selectBizDocList(CoviMap params) throws Exception;
	public int insertBizDoc(CoviMap params) throws Exception;
	public CoviMap selectBizDocData(CoviMap params) throws Exception;
	public int updateBizDoc(CoviMap params) throws Exception ;
	public int deleteBizDoc(CoviMap params) throws Exception ;
	public CoviMap selectBizDocFormList(CoviMap params) throws Exception;
	public CoviMap selectBizDocSelOrginFormList(CoviMap params) throws Exception;
	public int insertBizDocForm(CoviMap params) throws Exception ;
	public CoviMap selectBizDocFormData(CoviMap params) throws Exception;
	public int updateBizDocForm(CoviMap params) throws Exception ;
	public int deleteBizDocForm(CoviMap params) throws Exception ;
	public CoviMap selectBizDocMemberList(CoviMap params) throws Exception;
	public int deleteBizDocMember(CoviMap params) throws Exception ;
	public int updateBizDocMember(CoviMap params) throws Exception ;
	public int insertBizDocMember(CoviMap params) throws Exception ;
	public CoviMap selectBizDocMemberData(CoviMap params) throws Exception;
	public CoviList selectBizDocFormAllList(CoviMap params) throws Exception;
	
	
	
}
