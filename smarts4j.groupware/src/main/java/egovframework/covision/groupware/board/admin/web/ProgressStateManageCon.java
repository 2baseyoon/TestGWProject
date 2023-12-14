package egovframework.covision.groupware.board.admin.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.groupware.board.admin.service.ProgressStateManageSvc;

/**
 * @Class Name : ProgressStateManageCon.java
 * @Description : [관리자] 업무시스템 - 게시 관리 - 폴더/게시판 환경설정 - 확장옵션설정 탭
 * @Modification Information 
 * @ 2017.06.13 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.13
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ProgressStateManageCon {
	
	private Logger LOGGER = LogManager.getLogger(ProgressStateManageCon.class);
	
	@Autowired
	private AuthHelper authHelper;
	
	@Autowired
	ProgressStateManageSvc progressStateManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 진행상태 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectProgressStateList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectProgressStateList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("lang", SessionHelper.getSession("lang"));
			//이전의 폴더 ID 경로 조회
			result = (CoviList) progressStateManageSvc.selectProgressStateList(params).get("list");
			
		    returnData.put("stateList",result);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	
	/**
	 * 진행상태 생성
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/createProgressState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createProgressState(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");		//FolderID
			String displayName = request.getParameter("displayName");//표시 이름
			String sortKey = request.getParameter("sortKey");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("displayName", displayName);
			params.put("sortKey", sortKey);
			
			int cnt = progressStateManageSvc.createProgressState(params);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	/**
	 * 진행상태 수정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateProgressState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateProgressState(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String stateID = request.getParameter("stateID");		//categoryID
			String displayName = request.getParameter("displayName");	//표시 이름
			
			CoviMap params = new CoviMap();
			params.put("stateID", stateID);
			params.put("displayName", displayName);
			
			progressStateManageSvc.updateProgressState(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	/**
	 * 진행상태 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteProgressState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteProgressState(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String stateID = request.getParameter("stateID");		//stateID
			
			CoviMap params = new CoviMap();
			params.put("stateID", stateID);
			
			progressStateManageSvc.deleteProgressState(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
}
