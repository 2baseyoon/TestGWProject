package egovframework.covision.groupware.board.manage.web;
import java.util.Locale;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.manage.service.OrgNoticeManageSvc;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;

/**
 * @Class Name : MenuCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2017.06.15 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.15
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("board/manage")
public class OrgNoticeManageCon {

	private Logger LOGGER = LogManager.getLogger(this);
	
	@Autowired
	private OrgNoticeManageSvc orgNoticeManageSvc;

	@Autowired
	BoardManageSvc boardManageSvc;

	@Autowired
	BoardCommonSvc boardCommonSvc;
	
	@Autowired
	private FileUtilService fileSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	String orgFolderID= RedisDataUtil.getBaseConfig("CsNotice");
	
	@RequestMapping(value = "getOrgFolderPath.do")
	public @ResponseBody CoviMap getOrgFolderPath(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("folderID", orgFolderID);
			
			returnList.put("data",orgNoticeManageSvc.getOrgFolderPath(params));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	@RequestMapping(value = "getOrgNoticeList.do")
	public @ResponseBody CoviMap getOrgNoticeList(HttpServletRequest request) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			String domainID = request.getParameter("domainID");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");

			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			CoviMap params = new CoviMap();
			
			params.put("folderID", orgFolderID);
			params.put("domainID", domainID);
			params.put("searchType","Total");
			params.put("searchText", request.getParameter("searchText"));
			params.put("startDate", StringUtil.replaceNull(startDate));
			params.put("endDate", StringUtil.replaceNull(endDate));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}

			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			CoviMap returnMap = orgNoticeManageSvc.getOrgNoticeList(params);
			returnList.put("page", returnMap.get("page"));
			returnList.put("folderID", orgFolderID);
			returnList.put("folder", returnMap.get("folder"));
			returnList.put("list", returnMap.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
	
	/**
	 * 복사/이동/이관 설정 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "ExportNoticeFolderPopup.do", method = RequestMethod.GET)
	public ModelAndView exportNoticeFolderPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "manage/board/ExportNoticeFolderPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * 통합게시 메뉴 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "selectMenuList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectMenuList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try{
			String domainID = request.getParameter("domainID");
			params.put("domainID", domainID);
			params.put("lang", SessionHelper.getSession("lang"));
				
			returnList.put("list", orgNoticeManageSvc.selectMenuList(params).get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "selectRadioFolderTree.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectRadioFolderTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		CoviList resultList = new CoviList();
		
		try{
			String menuID = request.getParameter("menuID");
			String domainID = request.getParameter("domainID");
			String isAdmin = SessionHelper.getSession("isAdmin");

			CoviMap params = new CoviMap();

			params.put("domainID", domainID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("menuID", menuID);
			params.put("mode", "Copy");
			params.put("bizSection","Board"	);

			Set<String> createSet = null;
			Set<String> viewSet = null;
			
			CoviList result = (CoviList)boardCommonSvc.selectTreeFolderMenu(params).get("list");
			for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				
				if (!"Folder".equals(folderData.getString("FolderType")) && !"Root".equals(folderData.getString("FolderType"))){
					folderData.put("rdo", "Y");
				}
				
				if(folderData.get("FolderType").equals("Folder")){
					//폴더 선택시 하위메뉴 표시하는 메소드 호출
//					folderData.put("url", "javascript:myFolderTree.click("+ index +", \"expand\");");
				} else {
					folderData.put("type", "board_default");	//사용자 게시판은 아이콘 구별 하지 않음
				}
				resultList.add(folderData);
			}
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 게시글 복사
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "exportMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap exportMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID  = request.getParameter("messageID"); //Message ID
			String folderID = request.getParameter("folderID");
			String bizSection = "Board";
			String registIP = request.getRemoteHost();
			String domainID = request.getParameter("domainID");
			boolean bCopyFlag = false;
			
			CoviMap params = new CoviMap();
			params.put("bizSection", bizSection);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("orgMessageID",messageID);
			params.put("folderID", folderID);
			params.put("historyType", "Export");
			params.put("registIP", registIP);
			params.put("domainID", domainID);
			params.put("orgFolderID", orgFolderID);
			//업로드 파일 조회용 parameter 설정
			params.put("ServiceType", bizSection);
			params.put("ObjectType", "FD");
			params.put("MessageID", messageID);
			params.put("version", request.getParameter("version"));
			
			params.put("fileInfos", JSONSerializer.toJSON(fileSvc.selectAttachAll(params)));	//upload파일은 같이 조회
			
			orgNoticeManageSvc.exportMessage(params);			//게시글 복사
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
	 * 복사/이동/이관 설정 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "ExportNoticeListPopup.do", method = RequestMethod.GET)
	public ModelAndView exportNoticeListPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "manage/board/ExportNoticeListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "getNoticeHistoryList.do")
	public @ResponseBody CoviMap getNoticeHistoryList(HttpServletRequest request) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			String messageID = request.getParameter("messageID");
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];

			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("messageID", messageID);
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			CoviMap returnMap = orgNoticeManageSvc.getNoticeHistoryList(params);
			returnList.put("page", returnMap.get("page"));
			returnList.put("list", returnMap.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;

	}
	
	@RequestMapping(value="/goSystemNoticePopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView weharangPopup() {
		String returnURL = "user/webpart/manage/SystemNoticePopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	@RequestMapping(value="/checkSystemNotice.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap checkSystemNotice() {
		CoviMap result = new CoviMap();
		CoviMap params = new CoviMap();
		
		String isSasS  = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
		String isEasyAdmin = SessionHelper.getSession("isEasyAdmin");
		String isAdmin = SessionHelper.getSession("isAdmin");
		String userCode = SessionHelper.getSession("USERID");
		String noticeFolderID = RedisDataUtil.getBaseConfig("CsNotice");
		
		try {
			int count = 0;
			
			if("Y".equals(isSasS) && ("Y".equals(isEasyAdmin) || "Y".equals(isAdmin))) {
				params.put("userCode", userCode);
				params.put("noticeFolderID", noticeFolderID);
				
				count = orgNoticeManageSvc.checkSystemNotice(params);
				if(count > 0) {
					result.put("status", Return.SUCCESS);
				}
			}
			
			if(count == 0) result.put("status", Return.FAIL);
		} catch(DataAccessException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
		}
		
		return result;
	}
}
