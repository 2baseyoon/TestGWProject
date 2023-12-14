package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;


public interface CollabTaskSvc {
	CoviMap getTask(CoviMap params) throws Exception;
	CoviMap getTask(CoviMap params, boolean bMapAuth) throws Exception;
	List<CoviMap> getSubTask(CoviMap params) throws Exception;
	CoviMap addTask(CoviMap params, List objMember) throws Exception;
	CoviMap addTask(CoviMap params, List objMember, List trgUserForm, List<MultipartFile> mf, List tags) throws Exception;
	int addTaskInvite(CoviMap params) throws Exception;
	int deleteTaskMember(CoviMap params) throws Exception;
	int saveTaskMile(CoviMap params) throws Exception;
	int addTaskFavorite(CoviMap params) throws Exception;
	int deleteTaskFavorite(CoviMap params) throws Exception;
	
	int changeProjectTaskOrder(CoviMap params, List ordTask) throws Exception;
	int changeProjectTaskTodoOrder(CoviMap params, List ordTask) throws Exception;
	int changeProjectTaskStatus(CoviMap params) throws Exception;
	int changeProjectTaskDate(CoviMap params) throws Exception;
	CoviMap saveTask(CoviMap params, List objMember, List trgUserForm, MultipartFile[] mf, List delFile, List tags) throws Exception;
	int updateTaskStatus(CoviMap params) throws Exception;
	int deleteTask(CoviMap params) throws Exception;
	CoviList getNoAllocProject(CoviMap params) throws Exception;
	int addAllocProject(CoviMap params) throws Exception;
	int deleteAllocProject(CoviMap params) throws Exception;
	
	int addTaskTag(CoviMap params) throws Exception ;
	int deleteTaskTag(CoviMap params) throws Exception ;
	
	int copyTask(CoviMap params) throws Exception ;
	
	int addTaskLink(CoviMap params) throws Exception ;
	int deleteTaskLink(CoviMap params) throws Exception ;
	
	CoviMap getTaskMapBySchedule(CoviMap params) throws Exception;
	int updateTaskDateBySchedule(CoviMap params) throws Exception;
	int updateTaskDate(CoviMap params) throws Exception;
	List<CoviMap> getTaskSeqList(CoviMap params) throws Exception;
	int deleteTaskList(CoviMap params) throws Exception;
	List<CoviMap> getTaskSeqListByProjectObj(CoviMap params) throws Exception;
	
	List<CoviMap> selectTaskMemberList(CoviMap params) throws Exception;
	
	int getTaskMapCnt(CoviMap params) throws Exception;
	
	List<CoviMap> getPrjTask(CoviMap params) throws Exception;
	
	CoviMap getTaskLink(CoviMap params) throws Exception;

}
