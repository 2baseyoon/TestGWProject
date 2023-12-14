package egovframework.covision.groupware.task.user.service;

import java.util.List;




import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface TaskSvc {

	public CoviList getPersonalFolderList(CoviMap params) throws Exception;
	
	public CoviList getShareFolderList(CoviMap params) throws Exception;

	public CoviMap getSearchAll(CoviMap params) throws Exception;

	public CoviMap getFolderItemList(CoviMap params) throws Exception;

	public void saveFolderData(CoviMap folderObj) throws Exception;

	public void modifyFolderData(CoviMap folderObj) throws Exception;

	public void deleteFolderData(CoviMap params) throws Exception;

	public void saveTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;
	
	public void modifyTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;
	
	public void saveTaskDataMobile(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;
	
	public void modifyTaskDataMobile(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;

	public CoviMap isDuplicationName(String Type, String originID, String targetFolderID, String isCopy) throws Exception;

	public CoviMap isDuplicationSaveName(String type, String originName, String originID, String targetFolderID, String isModify) throws Exception;
	
	public void copyTask(CoviMap params) throws Exception;

	public void deleteTaskData(CoviMap params) throws Exception;

	public void moveTask(CoviMap params) throws Exception;

	public String isHaveShareChild(String folderID) throws Exception;

	public String isHaveChild(String folderID) throws Exception;

	public void moveFolder(CoviMap params) throws Exception;

	public boolean checkAuthority(CoviMap params) throws Exception;

	public CoviList getFolderShareMember(CoviMap params) throws Exception;

	public CoviList getParentFolderShareMember(CoviMap params) throws Exception;

	public CoviMap getFolderData(CoviMap params) throws Exception;

	public CoviMap getTaskData(CoviMap params) throws Exception;

	public CoviList getTaskPerformer(CoviMap params) throws Exception;

	public CoviMap getShareUseList(CoviMap params) throws Exception;

	public void checkTaskReadData(CoviMap params)  throws Exception;
	
	public int selectTaskSearchListCnt(CoviMap params) throws Exception;
	
	public CoviMap selectTaskSearchList(CoviMap params) throws Exception;

}
