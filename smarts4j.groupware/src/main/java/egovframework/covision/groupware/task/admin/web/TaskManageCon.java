package egovframework.covision.groupware.task.admin.web;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.task.admin.service.TaskManageSvc;

@Controller
public class TaskManageCon {
	private Logger LOGGER = LogManager.getLogger(TaskManageCon.class);
	
	@Autowired
	private TaskManageSvc taskManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value="task/getUserFolderList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getUserFolderList(
			@RequestParam(value = "folderID", required=true) String folderID,
			@RequestParam(value = "userID", required=true) String userID,
			@RequestParam(value = "stateCode", required=false) String stateCode,
			@RequestParam(value = "searchType", required=false) String searchType,
			@RequestParam(value = "searchWord", required=false) String searchWord,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize,
			@RequestParam(value = "sortBy", required=false, defaultValue = "" ) String sortBy) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		CoviMap resultObj = new CoviMap();
		try {
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userID", userID);
			params.put("stateCode", stateCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultObj = taskManageSvc.getUserFolderList(params);
			
			returnObj.put("list", resultObj.get("list"));
			returnObj.put("page", resultObj.get("page")) ;
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="task/getUserTaskList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getUserTaskList(
			@RequestParam(value = "folderID", required=true) String folderID,
			@RequestParam(value = "userID", required=true) String userID,
			@RequestParam(value = "stateCode", required=false) String stateCode,
			@RequestParam(value = "searchType", required=false) String searchType,
			@RequestParam(value = "searchWord", required=false) String searchWord,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize,
			@RequestParam(value = "sortBy", required=false, defaultValue = "" ) String sortBy) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		CoviMap resultObj = new CoviMap();
		try {
			String sortColumn = (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirection = (! sortBy.equals("") )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			params.put("FolderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userID", userID);
			params.put("stateCode", stateCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultObj = taskManageSvc.getUserTaskList(params);
			
			returnObj.put("list", resultObj.get("list"));
			returnObj.put("page", resultObj.get("page")) ;
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}

	/**
	 * transferTask - 업무 이관
	 * @param sourceUserID
	 * @param targetUserID
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/transferTask.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap transferTask(
			@RequestParam(value = "sourceUserID", required=true) String sourceUserID,
			@RequestParam(value = "targetUserID", required=true) String targetUserID) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("sourceUserID", sourceUserID);
			params.put("targetUserID", targetUserID);
			
			taskManageSvc.transferTask(params);
			
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}

	
	/**
	 * getGroupChartData - 부서별 통계
	 * @param groupCode
	 * @return returnObj
	 * @throws Exception
	 */
	@RequestMapping(value = "task/getGroupChartData.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap getGroupChartData(
			@RequestParam(value = "groupCode", required=true) String groupCode) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("groupCode", groupCode);
			
			returnObj.put("list",taskManageSvc.getGroupChartData(params));
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}	
	
	
}
