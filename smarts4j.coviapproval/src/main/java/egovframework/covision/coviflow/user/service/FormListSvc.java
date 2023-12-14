package egovframework.covision.coviflow.user.service;

import egovframework.baseframework.data.CoviMap;


public interface FormListSvc {
	public CoviMap getFormListData(CoviMap params) throws Exception;
	public CoviMap getClassificationListData(CoviMap params) throws Exception;
	public CoviMap getLastestUsedFormListData(CoviMap params) throws Exception;
	public CoviMap getFavoriteUsedFormListData(CoviMap params) throws Exception;
	public CoviMap getHomeFavoriteFormListData(CoviMap params) throws Exception;
	public int addFavoriteUsedFormListData(CoviMap params) throws Exception;
	public int removeFavoriteUsedFormListData(CoviMap params) throws Exception;
	public CoviMap getCompleteAndRejectListData(CoviMap params) throws Exception;
	public int getNotDocReadCnt(CoviMap params) throws Exception;
	public int selectFavoriteAuth(CoviMap params);
	
	public int updateFavoriteUsedFormSort(CoviMap params) throws Exception;
}
