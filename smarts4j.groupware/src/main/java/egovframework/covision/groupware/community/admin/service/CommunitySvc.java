package egovframework.covision.groupware.community.admin.service;

import java.util.List;


import egovframework.baseframework.data.CoviMap;

public interface CommunitySvc {
	public CoviMap selectCommunityDomain(CoviMap params)throws Exception;
	public CoviMap selectCommunityTreeData(CoviMap params)throws Exception;
	public CoviMap selectCommunityGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunitySubGridList(CoviMap params)throws Exception;
	public CoviMap setCurrentLocation(CoviMap params)throws Exception;
	public CoviMap selectCommunityBaseCode(CoviMap params)throws Exception;
	public CoviMap selectProperty(CoviMap params)throws Exception;
	public CoviMap selectCommunityInfomation(CoviMap params)throws Exception;
	public CoviMap selectCommunityOpenGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityCloseGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityStaticGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityStaticSubGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityStaticGridExcelList(CoviMap params)throws Exception;
	public CoviMap selectCommunityBoardSettingGridList(CoviMap params)throws Exception;
	public CoviMap selectCommunityFolderType(CoviMap params)throws Exception;
	public CoviMap communityBoardSettingInfo(CoviMap params)throws Exception;

	
	public int selectCommunityGridListCount(CoviMap params)throws Exception;
	public int selectCommunitySubGridListCount(CoviMap params)throws Exception;
	public int communityDictionaryCnt(CoviMap params)throws Exception;
	public CoviMap selectCommunitySubProperty(CoviMap params)throws Exception;
	public int selectCommunityStaticGridListCount(CoviMap params)throws Exception;
	public int checkCommunityNameCount(CoviMap params)throws Exception;
	public int checkCommunityAliasCount(CoviMap params)throws Exception;
	public int communityCnt(CoviMap params)throws Exception;
	public int selectCommunityHomeCount(CoviMap params)throws Exception;
	public int selectCommunityACLCount(CoviMap params)throws Exception;
	public int selectCommunityMemberCount(CoviMap params)throws Exception;
	public int selectCommunityGroupCount(CoviMap params)throws Exception;
	public int selectCommunityMenuTopCount(CoviMap params)throws Exception;
	public int selectCommunityBoardCount(CoviMap params)throws Exception;
	public int selectCommunityDetailInfomationCount(CoviMap params)throws Exception;
	public int selectCommunityOpenGridListCount(CoviMap params)throws Exception;
	public int selectCommunityCloseGridListCount(CoviMap params)throws Exception;
	public int selectCommunityStaticSubGridListCount(CoviMap params)throws Exception;
	public int selectCommunityExcelInfoCount(CoviMap params)throws Exception;
	public int selectCommunityBoardSettingGridListCount(CoviMap params)throws Exception;
	public int selectCommunityFolderCnt(CoviMap params)throws Exception;
	public int selectCommunitySortDuplyCount(CoviMap params)throws Exception;
	
	public String selectCategoryID(CoviMap params) throws Exception;
	public String selectDICCode(CoviMap params) throws Exception;
	public CoviMap selectCommunityOperatorInfo(CoviMap params) throws Exception;
	public String selectCommunityScheduleMenu(CoviMap params)throws Exception;
	public String selectCommunityAlias(CoviMap params)throws Exception;
	public String getCommunityName(CoviMap params)throws Exception;
	
	public boolean updateCategoryUseChange(CoviMap params)throws Exception;
	public boolean updateCommunityProperty(CoviMap params)throws Exception;
	public boolean updateCommunitySubProperty(CoviMap params)throws Exception;	
	public boolean updateCommunityDictionary(CoviMap params)throws Exception;	
	public boolean createCommunityDictionary(CoviMap params)throws Exception;	
	public boolean deleteCategory(CoviMap params)throws Exception;	
	public boolean moveCommunityCategory(CoviMap params)throws Exception;	
	public boolean updateCommunitySortProperty(CoviMap params)throws Exception;	
	public boolean updateCommunityStatus(CoviMap params)throws Exception;	
	public boolean updateCommunityNameDictionary(CoviMap params)throws Exception;	
	public boolean createCommunityNameDictionary(CoviMap params)throws Exception;
	public boolean createCommunityInfomation(CoviMap params)throws Exception;
	public boolean createCommunityDetailInfomation(CoviMap params)throws Exception;
	public boolean createCommunityProperty(CoviMap params)throws Exception;	
	
	public boolean updateCommunityGroupCode(CoviMap params)throws Exception;
	public boolean updateCommunityGroupFD(CoviMap params)throws Exception;
	public boolean updateCommunityCacheSync(CoviMap params)throws Exception;
	public boolean createCommunityHome(CoviMap params)throws Exception;
	public boolean updateCommunityACL(CoviMap params)throws Exception;
	public boolean createCommunityACL(CoviMap params)throws Exception;
	public boolean createCommunityMember(CoviMap params)throws Exception;
	public boolean createCommunityGroup(CoviMap params)throws Exception;
	public boolean updateCommunityMemberCount(CoviMap params)throws Exception;
	public boolean createCommunityFolder(CoviMap params)throws Exception;
	public boolean createCommunityMenuTop(CoviMap params)throws Exception;
	public boolean createBoardConfig(CoviMap params)throws Exception;
	public boolean updateBoardConfig(CoviMap params)throws Exception;
	public boolean createObjectGroup(CoviMap params)throws Exception;
	public boolean updateObjectGroup(CoviMap params)throws Exception;
	public boolean editCommunityInfomation(CoviMap params)throws Exception;
	public boolean updateCommunityDetailInfomation(CoviMap params)throws Exception;
	public boolean insertTodoSendMessage(CoviMap params)throws Exception;
	public boolean staticCommunityUpdate(CoviMap params)throws Exception;
	public boolean updateBoardSettingUseChange(CoviMap params)throws Exception;
	public boolean updateBoardSetting(CoviMap params)throws Exception;
	public boolean createBoardSetting(CoviMap params)throws Exception;
	public boolean updateCommunityMemberOperatorCode(CoviMap params)throws Exception;
	public boolean communityMemberActivityPoint(CoviMap params)throws Exception;
	public boolean communityActivityPoint(CoviMap params)throws Exception;
	public boolean communityActivityPointHistory(CoviMap params)throws Exception;
	public boolean updateCommunityMember(CoviMap params)throws Exception;
	
	public boolean restoreCommunity(CoviMap params)throws Exception;
	public boolean communityNewCreateSite(CoviMap params)throws Exception;
	public boolean openCommunity(CoviMap params)throws Exception;
	public boolean communityMemberActivityPointHistory(CoviMap params)throws Exception;
	public boolean clearRedisCache(CoviMap params)throws Exception;
	
	public boolean updatePwChange(CoviMap params)throws Exception;
	
	
	
	public CoviMap selectCommunityInfo(CoviMap params)throws Exception;
	public CoviMap selectCommunityExcelInfo(CoviMap params)throws Exception;
	
	public List selectCommunityExcelLogDaily(CoviMap params)throws Exception;
	public List communityMemberActivity(CoviMap params)throws Exception;
	public List communityActivity(CoviMap params)throws Exception;
	public List sendMessagingList(CoviMap params)throws Exception;
	public List sendMessagingCommunityOperator(CoviMap params)throws Exception;
	public List selectUserAllPwChange(CoviMap params)throws Exception;
	
	CoviMap selectBoardSettingSortKey(CoviMap params)throws Exception;	//순서 변경용: 기본게시판정보 조회
	int updateBoardSettingSortKey(CoviMap params)throws Exception;		//기본게시판정보 SortKey 변경
	
	public void updateProperty(CoviMap params) throws Exception;	
}
