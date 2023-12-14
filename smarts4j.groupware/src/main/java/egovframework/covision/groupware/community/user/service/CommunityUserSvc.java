package egovframework.covision.groupware.community.user.service;

import java.util.List;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface CommunityUserSvc {
	
	public CoviMap communityFavoritesSetting(CoviMap params)throws Exception;
	public CoviMap selectUserJoinCommunity(CoviMap params)throws Exception;
	public CoviMap selectCommunityHotStory(CoviMap params)throws Exception;
	public CoviMap selectCommunityFavorite(CoviMap params)throws Exception;
	public CoviMap selectCommunitySearchWord(CoviMap params)throws Exception;
	public CoviMap selectCommunityNotice(CoviMap params)throws Exception;
	public CoviMap selectCommunityFrequent(CoviMap params)throws Exception;
	public CoviMap selectNewCommunity(CoviMap params)throws Exception;
	public CoviMap selectUserCommunityGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityTreeData(CoviMap params)throws Exception;
	public CoviMap selectCommunityBaseCode(CoviMap params)throws Exception;
	public CoviMap selectcommunityHeaderSetting(CoviMap params)throws Exception;
	public CoviMap communitySubHeaderSetting(CoviMap params)throws Exception;
	public CoviMap communityLeftUserInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityTopMenu(CoviMap params)throws Exception;
	public CoviMap selectCommunityHeaderSettingList(CoviMap params)throws Exception;
	public CoviMap selectCommunityBoardLeft(CoviMap params)throws Exception;
	public CoviMap selectCommunityTagCloud(CoviMap params)throws Exception;
	public CoviMap selectCommunitySelectNoticeList(CoviMap params)throws Exception;
	public CoviMap selectCommunityActivity(CoviMap params)throws Exception;
	public CoviMap selectCommunityDetailInfo(CoviMap params)throws Exception;
	public CoviMap selectCurrentLocation(CoviMap params)throws Exception;
	public CoviMap selectCommunityVisitList(CoviMap params)throws Exception;
	public CoviMap selectCommunityJoinUserInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityMemberManageGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityDeleteMemberGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityMemberGridList(CoviMap params)throws Exception;
	public CoviMap communityMemberMenageListExcelList(CoviMap params)throws Exception;
	public CoviMap communityDeleteMemberListExcelList(CoviMap params)throws Exception;
	public CoviMap communityMemberListExcelList(CoviMap params)throws Exception;
	public CoviMap selectMemberLevelBox(CoviMap params)throws Exception;
	public CoviMap selectCommunityLeaveInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityBoardRankInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityVisitRankInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityCallMember(CoviMap params)throws Exception;
	public CoviMap selectCommunityAllianceGridList(CoviMap params)throws Exception;
	public CoviMap selectAlianceType(CoviMap params)throws Exception;
	public CoviMap communityAllianceList(CoviMap params)throws Exception;
	public CoviMap selectCommunityDoorList(CoviMap params)throws Exception;
	public CoviMap selectCommunityImageList(CoviMap params)throws Exception;
	
	public String communitySelectCreateId(CoviMap params)throws Exception;
	public String selectCommunityUserLevelCheck(CoviMap params)throws Exception;
	public String selectCommunityTypeCheck(CoviMap params)throws Exception;
	public String selectCommunityScheduleMenu(CoviMap params)throws Exception;
	public String selectCommunityName(CoviMap params)throws Exception;
	public String selectCommunityDoorText(CoviMap params)throws Exception;
	public String communitySelectDoor(CoviMap params)throws Exception;
	public String getCommunityName(CoviMap params)throws Exception;
	public String sendMessagingSettingUserCode(CoviMap params)throws Exception;
	public String selectTargetCallMemberSendMessage(CoviMap params)throws Exception;
	
	public int selectUserCommunityGridListCount(CoviMap params)throws Exception;
	public int checkCommunityNameCount(CoviMap params)throws Exception;
	public int selectCommunityHomeCount(CoviMap params)throws Exception;
	public int selectCommunityACLCount(CoviMap params)throws Exception;
	public int selectCommunityFolderCnt(CoviMap params)throws Exception;
	public int selectCommunityMemberCount(CoviMap params)throws Exception;
	public int selectCommunityMenuTopCount(CoviMap params)throws Exception;
	public int selectCommunityBoardCount(CoviMap params)throws Exception;
	public int communityCnt(CoviMap params)throws Exception;
	public int selectCommunityVisitCnt(CoviMap params)throws Exception;
	public int selectCommunitySelectNoticeCount(CoviMap params)throws Exception;
	public int selectCommunityMemberDuplyCnt(CoviMap params)throws Exception;
	public int selectCommunityMemberManageGridListCount(CoviMap params)throws Exception;
	public int selectCommunityDeleteMemberGridListCount(CoviMap params)throws Exception;
	public int selectCommunityMemberGridListCount(CoviMap params)throws Exception;
	public int selectCommunityAllianceGridListCount(CoviMap params)throws Exception;
	public int selectCommunityNoticeCnt(CoviMap params)throws Exception;
	public int selectCommunityApprovCheck(CoviMap params)throws Exception;
	public int selectCommunityHomepageCheck(CoviMap params)throws Exception;
	public int selectCommunityDomainCheck(CoviMap params)throws Exception;
    public int communitySendSimpleMail(CoviMap params) throws Exception;
    public int sendMessagingSettingCnt(CoviMap params) throws Exception;
    public int selectCurrentFileSizeByCommunity(CoviMap params) throws Exception;
	
	public boolean communityFavoritesDelete(CoviMap params)throws Exception;
	public boolean createCommunityInfomation(CoviMap params)throws Exception;
	public boolean createCommunityDetailInfomation(CoviMap params)throws Exception;
	public boolean updateCommunityStatus(CoviMap params)throws Exception;	
	public boolean createObjectGroup(CoviMap params)throws Exception;
	public boolean updateObjectGroup(CoviMap params)throws Exception;
	public boolean updateCommunityGroupCode(CoviMap params)throws Exception;
	public boolean createCommunityHome(CoviMap params)throws Exception;
	public boolean updateCommunityACL(CoviMap params)throws Exception;
	public boolean createCommunityACL(CoviMap params)throws Exception;
	public boolean createCommunityFolder(CoviMap params)throws Exception;
	public boolean createCommunityMember(CoviMap params)throws Exception;
	public boolean updateCommunityMemberCount(CoviMap params)throws Exception;
	public boolean createCommunityMenuTop(CoviMap params)throws Exception;
	public boolean createBoardConfig(CoviMap params)throws Exception;
	public boolean updateBoardConfig(CoviMap params)throws Exception;
	public boolean updateCommunityNameDictionary(CoviMap params)throws Exception;
	public boolean createCommunityNameDictionary(CoviMap params)throws Exception;
	public boolean communityFavoritesInsert(CoviMap params)throws Exception;
	public boolean insertCommunityVisit(CoviMap params)throws Exception;
	public boolean updateCommunityTopMenuUse(CoviMap params)throws Exception;
	public boolean updateCommunityTopMenuSort(CoviMap params)throws Exception;
	public boolean communityUserJoin(CoviMap params,String op)throws Exception;
	public boolean communityJoinProcess(CoviMap params,String op)throws Exception;
	public boolean communityMemberLevelChange(CoviMap params)throws Exception;
	public boolean communityMemberLeave(CoviMap params)throws Exception;
	public boolean updateCommunityMemberOperatorCode(CoviMap params)throws Exception;
	public boolean communityCallMemberSendMessage(CoviMap params)throws Exception;
	public boolean communityUpdateInfo(CoviMap params)throws Exception;
	public boolean updateCommunityMember(CoviMap params)throws Exception;
	public boolean updateAllianceApprove(CoviMap params, String checkNum)throws Exception;
	public boolean communityClosingUpdate(CoviMap params)throws Exception;
	public boolean communityLayoutHeaderSet(CoviMap params)throws Exception;
	public boolean communityLayoutDoorSet(CoviMap params)throws Exception;
	public boolean communityLayoutDoorUpdate(CoviMap params)throws Exception;
	public boolean communityLayoutDoorChange(CoviMap params)throws Exception;
	public boolean communityLayoutDoorDelete(CoviMap params)throws Exception;
	public boolean communityImgSet(CoviMap params)throws Exception;
	public boolean communityImgDel(CoviMap params)throws Exception;
	public boolean communityImgChoice(CoviMap params)throws Exception;
	public boolean communitySearchWordPoint(CoviMap params)throws Exception;
	public boolean communityParentCreate(CoviMap params)throws Exception;
	public boolean clearRedisCache(CoviMap params)throws Exception;
	public boolean communityGroupMember(CoviMap params)throws Exception;
	
	public boolean communityNewCreateSite(CoviMap params)throws Exception;  //커뮤니티 생성 
	public boolean ACL(String ObjectID,String ObjectType,String SubjectCode,String SubjectType, String AclList, String Security, String Create, String Delete, String Modify, String Execute, String View, String Read, String Type, String userID, String dnID, String CommunityType);
	public boolean sendMessaging(CoviMap params)throws Exception;
	
	public CoviMap selectCommunityInfo(CoviMap params)throws Exception;
	
	public List sendMessagingList(CoviMap params)throws Exception;
	public List sendMessagingListAdmin(CoviMap params)throws Exception;
	public List sendMessagingCommunityOperator(CoviMap params)throws Exception;
	
	CoviList getWebpartList(CoviMap params) throws Exception;
	String getJavascriptString(CoviList webPartList) throws Exception;
	String getLayoutTemplate(CoviList webPart, CoviMap params) throws Exception;
	
	Object getWebpartData(CoviList webPart) throws Exception;
	public CoviMap selectCommunityDataWebpart(CoviMap params) throws Exception;	// 웹파트 커뮤니티 데이터 조회
}

