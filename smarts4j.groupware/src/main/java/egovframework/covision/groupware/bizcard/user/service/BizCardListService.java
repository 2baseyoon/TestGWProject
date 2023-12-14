package egovframework.covision.groupware.bizcard.user.service;

import egovframework.baseframework.data.CoviMap;


public interface BizCardListService {
	public CoviMap selectBizCardFavoriteList(CoviMap params) throws Exception;
	public CoviMap selectBizCardPersonList(CoviMap params) throws Exception;
	public CoviMap selectBizCardCompanyList(CoviMap params) throws Exception;
	public CoviMap getCallFuncDivList(CoviMap params) throws Exception;
	public int relocateBizCardList(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
	public int deleteOne(CoviMap params)throws Exception;
	public int deleteGroupOne(CoviMap params)throws Exception;
	public int deleteGroup(CoviMap params)throws Exception;
	public int insertIntoFavoriteList(CoviMap params)throws Exception;
	public int deleteFromFavoriteList(CoviMap params)throws Exception;
	public CoviMap selectBizCardAllList(CoviMap params) throws Exception;
	public CoviMap selectBizCardGroupList(CoviMap params) throws Exception;
	public CoviMap selectBizCardExcelList(CoviMap params) throws Exception;	
	public CoviMap selectBizCardGroupMemberList(CoviMap params) throws Exception;
	public CoviMap selectBizCardOrgMapList(CoviMap params) throws Exception;
}
