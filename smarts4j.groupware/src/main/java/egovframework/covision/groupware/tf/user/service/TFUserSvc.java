package egovframework.covision.groupware.tf.user.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface TFUserSvc {
	public CoviMap selectUserJoinTF(CoviMap params) throws Exception;
	
	public CoviMap selectUserTempTFGridList(CoviMap params) throws Exception;
	public int selectUserTempTFGridListCount(CoviMap params) throws Exception;
	public boolean deleteTempTFTeamRoom(CoviMap params) throws Exception;
	
	public CoviMap selectUserTFGridList(CoviMap params) throws Exception;
	public int selectUserTFGridListCount(CoviMap params) throws Exception;
	
	public CoviMap selectUserMyTFGridList(CoviMap params) throws Exception;
	public int selectUserMyTFGridListCount(CoviMap params) throws Exception;	
	public String selectMemberGrade(CoviMap params) throws Exception;
	
	public CoviMap selectUserAdminTFGridList(CoviMap params) throws Exception;
	public int selectUserAdminTFGridListCount(CoviMap params) throws Exception;
	
	public String deleteTFTeamRoom(CoviMap params) throws Exception;
	public boolean updateTFTeamRoomStatus(CoviMap params) throws Exception;
	public boolean updateTFTeamRoom(CoviMap params, CoviMap filesParams, List<MultipartFile> mf);
	
	public int checkTFNameCount(CoviMap params) throws Exception; 
	public int checkTFCodeCount(CoviMap params) throws Exception;
	
	public CoviMap createTFTeamRoom(CoviMap params, CoviMap filesParams, List<MultipartFile> mf);
	public boolean tempSaveTFTeamRoom(CoviMap params, CoviMap filesParams, List<MultipartFile> mf) throws Exception;
	
	public CoviMap selectTFTempSaveData(CoviMap params) throws Exception;
	
	public CoviMap selectTFDetailInfo(CoviMap params) throws Exception;
	public CoviMap selectCommunityBoardLeft(CoviMap params) throws Exception;
	
	public CoviMap getTaskData(CoviMap params) throws Exception;
	public CoviList getTaskPerformer(CoviMap params) throws Exception;
	
	public CoviMap isDuplicationSaveName(String type, String originName, String originID, String targetCUID, String isModify) throws Exception;
	
	public void saveTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;
	
	public void modifyTaskData(CoviMap taskObj, CoviMap fileInfos, List<MultipartFile> mf) throws Exception;
	
	public void deleteTaskData(CoviMap params) throws Exception;
	
	public int updateTaskSortPath(CoviMap params) throws Exception; //activity SortPath update	
	
	public CoviMap getLevelTaskList(CoviMap params) throws Exception;
	
	public int selectTaskGridListCount(CoviMap params) throws Exception;
	public CoviMap selectTaskGridList(CoviMap params) throws Exception;
	
	public int selectMyTaskGridListCount(CoviMap params) throws Exception;
	public CoviMap selectMyTaskGridList(CoviMap params) throws Exception;
	
	public CoviMap selectActivityProgress(CoviMap params) throws Exception;
	
	public CoviMap selectActivityMinMaxDate(CoviMap params) throws Exception;
	
	public CoviMap selectTFPrintData(CoviMap params) throws Exception;
	
	public CoviMap TFLeftUserInfo(CoviMap params) throws Exception;
	
	public CoviMap getTFMemberInfo(CoviMap params) throws Exception;
	
	public int insertProjectTaskByExcel(CoviMap params) throws Exception;
	
	public CoviList selectTFProgressInfo(CoviMap params) throws Exception;
	
	public int selectSumTaskWeight(CoviMap params) throws Exception; //가중치 합계 구하기
	
	public String eumChannelCreate(CoviMap params) throws Exception; //이음 채널 생성
	
	public String pb_encrypt(String ciphertext) throws Exception; // 이음 채널 패스워드 암호화
	
	public String pb_decrypt(String ciphertext) throws Exception; // 이음 채널 패스워드 복호화
	
	public CoviList selectUserMailList(CoviMap params) throws Exception; //메일대상정보 조회
	
	public CoviList selectUserTFGridListGroupCount(CoviMap params) throws Exception; //메일대상정보 조회
	
	public CoviList getUserEmailInfo(CoviMap params) throws Exception;
}