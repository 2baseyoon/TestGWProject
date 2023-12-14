package egovframework.covision.coviflow.user.web;

import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.user.service.UserFolderSvc;



@Controller
public class UserFolderCon {
	
	@Autowired
	private UserFolderSvc userFolderSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");


	/**
	 * getApprovalListData - 부서결재함 하위메뉴별 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/UserFolderListAddPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getUserFolderListData(Locale locale, Model model)
	{
		String returnURL = "user/approval/UserFolderListAddPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * getApprovalListData - 부서결재함-사용자별 폴더 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getUserFolderList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList 			= new CoviMap();
		CoviMap seleteresultList 	= new CoviMap();
		CoviList  treeresultList 		= new CoviList();
		CoviList  result 				= new CoviList();

		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String mode   = request.getParameter("mode");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("mode", mode);
			params.put("userdefinedfolder", DicHelper.getDic("lbl_apv_userdefinedfolder"));

			if(params.get("mode").equals("all")){
				result = (CoviList) userFolderSvc.selectUserFolderList(params).get("list");

				for(Object jsonobject : result){
					CoviMap tmp = new CoviMap();
					CoviMap tmp1 = new CoviMap();
					tmp1 = (CoviMap) jsonobject;
					tmp.put("no", tmp1.get("FolderID"));
					tmp.put("nodeName", tmp1.get("FolDerName"));
					//tmp.put("nodeValue", tmp1.get("GR_Code"));
					tmp.put("type", "0");
					//tmp.put("type", "6");
					tmp.put("pno", tmp1.get("ParentsID"));
					tmp.put("chk", "Y");
					tmp.put("rdo", "N");
					tmp.put("url", "#");

					treeresultList.add(tmp);
				}
				returnList.put("list", treeresultList);

			}else{
				seleteresultList = userFolderSvc.selectUserFolderList(params);
				returnList.put("list", seleteresultList.get("list"));
			}
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
	 * getApprovalGroupListData - 부서결재함 선택된 리스트 해당폴더에 복사
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertUserFolderCopy.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap insertUserFolderCopy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();
		try {

			//현재 사용자 ID
			String   userID 				= SessionHelper.getSession("USERID");
			String 	 processtmp 			= StringUtil.replaceNull(request.getParameter("ProcessID"));
			String 	 workitemtmp 			= StringUtil.replaceNull(request.getParameter("WorkitemID"));
			String 	 circulationBoxtmp 		= StringUtil.replaceNull(request.getParameter("CirculationBoxID"));
			String 	 folderID 				= request.getParameter("FolderID");
			String 	 mode 					= StringUtil.replaceNull(request.getParameter("mode"));
			String 	 deptID 				= SessionHelper.getSession("DEPTID");
			String[] processIDs				= processtmp.split(",");
			String[] workItemIDs				= workitemtmp.split(",");
			String[] circulationBoxIDs 		= circulationBoxtmp.split(",");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("deptID", deptID);
			params.put("FolderID", folderID);
			params.put("mode", mode);
			//
			int result;
			for(int i = 0; i < processIDs.length; i++){
				params.put("ProcessID", processIDs[i]==null?"":processIDs[i]);
				params.put("WorkitemID",  workItemIDs.length<=i?"":workItemIDs[i]);
				if(mode.equalsIgnoreCase("TCInfo") || mode.equalsIgnoreCase("DeptTCInfo")) 
					params.put("CirculationBoxID",  circulationBoxIDs.length<=i?"":circulationBoxIDs[i]);
				result = userFolderSvc.insertFolderCopy(params);

				returnData.put("data", result);
				returnData.put("result", "ok");
			}

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
	 * getApprovalGroupListData - 부서결재함 새폴더새성
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/insertUserFolder.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap insertUserFolder(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String parentsID = request.getParameter("ParentsID");
			String folderName = request.getParameter("FolDerName");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("ParentsID", parentsID == null || parentsID.equals("") ? "0" : parentsID);
			params.put("FolDerName", ComUtils.RemoveScriptAndStyle(folderName));
			params.put("FolDerMode", "M");

			// 기존의 폴더명과 중복됨
			if(userFolderSvc.selectDuplicateFolderCnt(params) > 0) {
				returnData.put("data", 0); // 1이면 성공
				returnData.put("result", "fail");

				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_apv_165"));
			}
			else {
				int result = userFolderSvc.insert(params);
	
				returnData.put("data", result);
				returnData.put("result", "ok");
	
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "조회되었습니다");
			}
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
