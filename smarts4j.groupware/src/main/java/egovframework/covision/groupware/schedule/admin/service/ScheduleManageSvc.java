package egovframework.covision.groupware.schedule.admin.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ScheduleManageSvc {
	
	public CoviList selectFolderTreeList(CoviMap params) throws Exception;
	
	public CoviMap selectFolderDisplayName(CoviMap param) throws Exception;

	public CoviMap selectFolderList(CoviMap params) throws Exception;

	public int selectFolderListCount(CoviMap params) throws Exception;

	public CoviMap selectShareScheduleData(CoviMap params) throws Exception;

	public int selectShareScheduleDataCount(CoviMap params) throws Exception;

	public int insertShareData(CoviList paramsList) throws Exception;

	public CoviMap selectOneShareScheduleData(CoviMap params) throws Exception;

	public int deleteShareData(CoviMap param) throws Exception;

	public CoviList selectLinkFolderListData(CoviMap param) throws Exception;

	public CoviList selectFolderTypeData() throws Exception;
	
	public CoviList selectFolderTypeData(CoviMap param) throws Exception;

	public int insertFolderData(CoviMap params) throws Exception;

	public int deleteFolderData(CoviList params) throws Exception;

	public CoviMap selectFolderData(CoviMap params) throws Exception;

	public int updateFolderData(CoviMap params) throws Exception;
	
	public CoviMap selectDomainMenuID(CoviMap params) throws Exception;
	
	int updateFlag(CoviMap params)throws Exception;				//Use, Display 변경
}
