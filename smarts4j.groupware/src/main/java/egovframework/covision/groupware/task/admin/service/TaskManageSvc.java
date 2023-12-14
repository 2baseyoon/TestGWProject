package egovframework.covision.groupware.task.admin.service;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface TaskManageSvc {

	public void transferTask(CoviMap params) throws Exception;

	public CoviList getGroupChartData(CoviMap params) throws Exception;

	public CoviMap getUserFolderList(CoviMap params) throws Exception;

	public CoviMap getUserTaskList(CoviMap params) throws Exception;

}
