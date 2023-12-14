package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;


public interface CollabProjectSvc {
	CoviMap getProject(int prjSeq) throws Exception;
	CoviMap addProject(CoviMap params, List objMember, List objManager, List objViewer, List objUserForm, MultipartFile[] mf) throws Exception;
	CoviMap addProjectByTmpl(CoviMap params, List objMember, List objManager) throws Exception;
	CoviMap saveProject(CoviMap params, List objMember, List objManager, List objViewer, List objUserForm, MultipartFile[] mf, List objDelFile) throws Exception;
	CoviMap getProjectUserForm(int prjSeq) throws Exception; 
	CoviMap getProjectStat(CoviMap params) throws Exception;
	CoviMap getProjectMain(CoviMap params) throws Exception;
	CoviMap getProjectTask(CoviMap params) throws Exception;
	CoviMap getProjectTask(CoviMap params, List filterList) throws Exception;
	CoviMap addProjectInvite(CoviMap params) throws Exception;
	public int projectSectionCnt (CoviMap params) throws Exception;
	public String getProjectSectionSeq (CoviMap params) throws Exception;
	CoviMap addProjectSection(CoviMap params) throws Exception;
	CoviMap saveProjectSection(CoviMap params) throws Exception;
	int deleteProjectSection(CoviMap params) throws Exception;
	int deleteProject(CoviMap params) throws Exception;
	int copyProject(CoviMap params) throws Exception;
	CoviMap getMemberList(CoviMap params) throws Exception;
	CoviMap getProjectMemberList(CoviMap params) throws Exception;
	CoviMap getProjectMemberTagList(CoviMap params) throws Exception;
	CoviMap getFileList(CoviMap params) throws Exception;
	CoviMap getCollabSurveyList(CoviMap params) throws Exception;
	List<CoviMap> getCollabApprovalList(CoviMap params) throws Exception;
	CoviMap addProjectTmpl(CoviMap params) throws Exception;	
	int closeTeamExec(CoviMap params) throws Exception;
	int closeProject(CoviMap params) throws Exception;
	int saveProjectChannel(CoviMap params) throws Exception;
	public List<CoviMap> getSectionList(CoviMap params) throws Exception;
	public int updateSectionChange(CoviMap params) throws Exception;
	public int updateSectionOrder(CoviMap params) throws Exception;
	public int addProjectFavorite(CoviMap params) throws Exception;
	public int deleteProjectFavorite(CoviMap params) throws Exception;
	public CoviMap getGoingProject(CoviMap params) throws Exception;
	public int saveProjectAlarm(CoviMap params) throws Exception;
	public int cencelProjectAlarm(CoviMap params) throws Exception;
	public CoviMap getClosingAlarm(CoviMap params) throws Exception;
	public int saveClosingAlarm(CoviMap params) throws Exception;
	public CoviMap getSurveyInfo(CoviMap params) throws Exception;
	public CoviMap addPrjPersonalName(CoviMap params) throws Exception;
}
