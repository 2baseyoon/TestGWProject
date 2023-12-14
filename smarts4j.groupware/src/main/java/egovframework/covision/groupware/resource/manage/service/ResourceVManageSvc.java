package egovframework.covision.groupware.resource.manage.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ResourceVManageSvc {

	CoviMap getEquipmentList(CoviMap params) throws Exception;

	int chnageEquipmentIsUse(CoviMap params) throws Exception;

	int deleteEquipmentData(CoviMap delParam) throws Exception;

	int insertEquipmentData(CoviMap params) throws Exception;

	CoviMap getEquipmentData(CoviMap params) throws Exception;

	int updateEquipmentData(CoviMap params) throws Exception;

	CoviMap getMainResourceList(CoviMap params) throws Exception;

	CoviList getMainResourceTreeList(CoviMap params) throws Exception;
	
	CoviList getFolderResourceTreeList(CoviMap params) throws Exception;

	int insertMainResourceList(CoviMap params) throws Exception;

	int changeResourceSortKey(CoviMap params) throws Exception;
	
	CoviMap selectTargetSortKey(CoviMap params)throws Exception;	//순서 변경용: 정보 조회

	// String getFolderIconCss() throws Exception; 디자인상 ICON 빠짐

	CoviMap getFolderInfo(CoviMap params) throws Exception;

	CoviMap getBookingOfResourceList(CoviMap params) throws Exception;

	CoviMap getResourceOfFolderList(CoviMap params) throws Exception;

	int changeIsSwitch(CoviMap params) throws Exception;

	int deleteFolderData(CoviMap params) throws Exception;

	int changeFolderSortKey(CoviMap params) throws Exception;
	
	CoviMap getUserDefFieldGridList(CoviMap param) throws Exception;	//사용자 정의 필드 Grid  조회
	
	int getUserDefFieldGridCount(CoviMap params)throws Exception;
	
	CoviMap getUserDefFieldOptionList(CoviMap param) throws Exception;
	
	CoviMap getTargetUserDefFieldSortKey(CoviMap param) throws Exception;			//변경해야하는 sortkey값 조회
	
	int createUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 추가
	
	int updateUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 수정
	
	int deleteUserDefField(CoviMap params)throws Exception;					//사용자 정의 필드 삭제
	
	int createUserDefOption(CoviMap params)throws Exception;					//필드 옵션 추가
	
	int deleteUserDefFieldOption(CoviMap params)throws Exception;			//필드 옵션 삭제
	
	int updateUserDefFieldSortKey(CoviMap params)throws Exception;						//순서 변경

	CoviList getOnlyFolderTreeList(CoviMap params)throws Exception;

	CoviMap getShareResourceList(CoviMap params) throws Exception;

	int getMenuByDomainID(CoviMap params) throws Exception;

	int getTopFolderByMenuID(CoviMap params) throws Exception;

	int insertFolderData(CoviMap params) throws Exception;

	int updateFolderData(CoviMap params) throws Exception;

	CoviMap getFolderData(CoviMap params) throws Exception;

	int deleteBookingData(CoviMap params) throws Exception;

	String getEquipmentDomainData(CoviMap params) throws Exception;
}
