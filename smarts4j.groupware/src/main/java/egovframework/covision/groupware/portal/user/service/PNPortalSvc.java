package egovframework.covision.groupware.portal.user.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface PNPortalSvc {
	public int saveUserPortalOption(CoviMap params) throws Exception;
	
	public String selectUserPortalOption(CoviMap params) throws Exception;
	
	public CoviList selectProfileImagePath(CoviMap params) throws Exception;
	
	public CoviMap selectRollingBannerBoardList(CoviMap params) throws Exception;		//포탈 개선용 롤링 배너 게시글 조회
	
	public CoviMap getApprovalList(CoviMap params) throws Exception;
	
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception;
	
	public CoviMap selectBoardMessageList(CoviMap params) throws Exception;
	
	public CoviList selectLastestUsedFormList(CoviMap params) throws Exception;
	
	public CoviMap selectSystemLinkBoardList(CoviMap params) throws Exception;
	
	public CoviMap setWebpartThumbnailList(CoviMap params) throws Exception;
	
	public int selectUserRewardVacDay(CoviMap params) throws Exception;
	
	public int selectSiteLinkListCnt(CoviMap params) throws Exception;
	
	public CoviMap selectSiteLinkList(CoviMap params) throws Exception;
	
	public CoviMap selectSiteLinkData(CoviMap params) throws Exception;
	
	public int insertSiteLink(CoviMap params) throws Exception;
	
	public int updateSiteLink(CoviMap params) throws Exception;
	
	public int deleteSiteLink(CoviMap params) throws Exception;
	
	public CoviMap selectCommentList(CoviMap params) throws Exception;

	public CoviMap selectPasswordPolicy(CoviMap params) throws Exception;

	public String selectPwChangeDate(CoviMap params) throws Exception;
}
