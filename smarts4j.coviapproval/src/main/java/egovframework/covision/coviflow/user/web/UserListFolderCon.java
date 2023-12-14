package egovframework.covision.coviflow.user.web;


import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.UserListFolderSvc;



@Controller
public class UserListFolderCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(UserListFolderCon.class);

	@Autowired
	private UserListFolderSvc userListFolderSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getApprovalListData - 개인폴더 - 새로운폴더
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/UserNewFolderAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getUserNewFolderListData(Locale locale, Model model)
	{
		String returnURL = "user/approval/UserNewFolderListAddPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalListData - 개인폴더 - 폴더명수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/UserUpdtFolderAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getUserUpdtFolderListData(Locale locale, Model model)
	{
		String returnURL = "user/approval/UserUpdtFolderListAddPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalListData - 개인폴더함-사용자별 폴더 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserListFolder.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserListFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList 			= new CoviMap();
		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String mode   = request.getParameter("mode");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("mode", mode);
			CoviMap resultList = userListFolderSvc.selectUserFolderList(params);

			CoviList result = (CoviList)resultList.get("list");
			for(Object jsonobject : result){
				CoviMap tmp1 = (CoviMap) jsonobject;
				String folderName = tmp1.optString("FolDerName");
				folderName = ComUtils.ConvertInputValue(folderName);
				folderName = StringUtil.replace(folderName, "^", "&#94;");
				folderName = StringUtil.replace(folderName, "\"", "&#34;");
				tmp1.put("FolDerName", folderName);
			}
			
			returnList.put("list", result);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getApprovalListData - 개인폴더함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserFolderListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserFolderListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userID = request.getParameter("userID");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortKey = request.getParameter("sortBy")==null?"RegDate":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"desc":request.getParameter("sortBy").split(" ")[1];
			String folderId 	= StringUtil.replaceNull(request.getParameter("folderId"));
			String folderMode 	= request.getParameter("folderMode");

			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}

			CoviMap params = new CoviMap();
			
			if(folderId.equals("")){ //folderId 값이 없는경우 조회
				CoviList  result 	= new CoviList();
				userID = SessionHelper.getSession("USERID");
				params.put("userID", userID);
				params.put("checkYn", "Y");
				result = (CoviList) userListFolderSvc.selectUserFolderList(params).get("list");
				CoviMap jsonobj = result.getJSONObject(0);
				folderId = (String)jsonobj.get("FolderID");
				folderMode = (String)jsonobj.get("FolDerMode");
				params.put("folderId", folderId);
				params.put("folderMode", folderMode);
			}else{
				params.put("folderId", folderId);
				params.put("folderMode", folderMode);
				params.put("userID", userID);
			}
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			CoviMap resultList = userListFolderSvc.selectUserFolderDataList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getApprovalGroupListData - 개인폴더-폴더명수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateUserFolder.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateUserFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			//현재 사용자 ID
			String   userID 			= SessionHelper.getSession("USERID");
			String   folDerName 		= request.getParameter("FolDerName");
			String   folderId 			= request.getParameter("FolderId");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("FolDerName", ComUtils.RemoveScriptAndStyle(folDerName));
			params.put("folderId", folderId);

			int result = userListFolderSvc.update(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getApprovalGroupListData - 개인폴더-폴더이동
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateUserFolderMove.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateUserFolderMove(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {
			//현재 사용자 ID
			String   userID 			= SessionHelper.getSession("USERID");
			String   folderId 			= request.getParameter("FolderID");
			String   folederListIDTemp	= StringUtil.replaceNull(request.getParameter("FolederListID"));
			String[] folederListIDs		= folederListIDTemp.split(",");
			String	 message;
			
			CoviMap params = new CoviMap();
			
			int result;

			params.put("userID", userID);
			params.put("FolederListID", folederListIDs);
			params.put("folderId", folderId);

			result = userListFolderSvc.updateUserFolderMove(params);
			
			if(result == 0) {
				message = DicHelper.getDic("msg_apv_moveNotExist");
			} else if(result < folederListIDs.length) {
				message = DicHelper.getDic("msg_apv_moveExceptDuplicate");
			} else {
				message = DicHelper.getDic("msg_apv_move");
			}
			
			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", message);
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getApprovalGroupListData - 개인폴더-폴더 및 함 삭제처리
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/deleteUserFolderList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteUserFolderList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			String   folderMode 		= request.getParameter("folderMode");
			String   folderId 			= request.getParameter("folderId");
			String   parentId 			= request.getParameter("parentId");
			String   folderListIDTemp	= StringUtil.replaceNull(request.getParameter("FolderListID"));
			String[] folderListIDs		= folderListIDTemp.split(",");
			
			CoviMap params = new CoviMap();

			params.put("FolderListID", folderListIDs);
			params.put("folderId", folderId);
			params.put("folderMode", folderMode);
			params.put("parentId", parentId);

			int result;

			result = userListFolderSvc.deleteUserFolderList(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
}
