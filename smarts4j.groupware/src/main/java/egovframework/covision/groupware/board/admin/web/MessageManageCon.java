package egovframework.covision.groupware.board.admin.web;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.groupware.board.admin.service.MessageManageSvc;
import egovframework.covision.groupware.util.BoardUtils;

/**
 * @Class Name : MessageManageCon.java
 * @Description : [관리자] 업무시스템 - 게시물 관리
 * @Modification Information 
 * @ 2017.06.01 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.01
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageManageCon {
	
	private Logger LOGGER = LogManager.getLogger(MessageManageCon.class);
	
	@Autowired
	private AuthHelper authHelper;
	
	@Autowired
	MessageManageSvc messageManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	// Contents -  Folder Grid 조회 //
	
	/**
	 * 게시관리 - 게시글 조회자 목록 팝업 호출
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goMessageViewerListPopup.do", method = RequestMethod.GET)
	public ModelAndView goMessageViewerListPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "admin/board/messageViewerListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * 게시관리 - 게시글 처리 이력 목록 팝업 호출
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goMessageHistoryListPopup.do", method = RequestMethod.GET)
	public ModelAndView goMessageHistoryListPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "admin/board/messageHistoryListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	
	/**
	 * 본문 엑셀 다운로드
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping(value = "admin/messageListExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView messageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");
			String domainID = request.getParameter("domainID");
			String folderID = request.getParameter("folderID");
			String searchType = request.getParameter("searchType");
			String searchText = request.getParameter("searchText");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			String bizSection = request.getParameter("bizSection");
			
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			
			String[] headerNames = headerName.split("\\|");
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("boardType", boardType);
			params.put("domainID", domainID);
			params.put("folderID", folderID);
			params.put("searchType", searchType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("bizSection", bizSection);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			if(boardType.equals("Stats")){		//게시 통계와 그외의 관리자 게시판을 분기처리...추후 다른 관리자 게시판도 분리
				resultList = messageManageSvc.selectMessageStatsExcelList(params);
			} else {
				resultList = messageManageSvc.selectMessageExcelList(params);
			}
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Board_" + boardType);
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * 게시 관리 - 게시글 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectMessageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");		//게시판 타입: Normal, 신고, 잠금, 삭제/만료, 수정요청 게시 통계
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);

			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			if(boardType.equals("Stats")){
				int cnt = messageManageSvc.selectMessageStatsGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageManageSvc.selectMessageStatsGridList(params);
			} else {
				int cnt = messageManageSvc.selectMessageGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageManageSvc.selectMessageGridList(params);
			}
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	// Contents - 게시글 Grid 조회 종료 //
	
	/**
	 * 게시 관리 - 게시글 조회자 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectMessageViewerGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageViewerGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			boolean bReadFlag = BoardUtils.getReadAuth(params);
			if (bReadFlag == false){
				params.addAll(ComUtils.setPagingData(params,0));	
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_UNotReadAuth"));
				return returnData;
			}
			
			int cnt = messageManageSvc.selectMessageViewerGridCount(params);	//조회항목 count
			params.addAll(ComUtils.setPagingData(params,cnt));					//페이징 parameter set
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = messageManageSvc.selectMessageViewerGridList(params);

			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	 * 게시 관리 - 게시글 조회자 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectMessageHistoryGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageHistoryGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			int cnt = messageManageSvc.selectMessageHistoryGridCount(params);	//조회항목 count
			params.addAll(ComUtils.setPagingData(params,cnt));					//페이징 parameter set
			
			resultList = messageManageSvc.selectMessageHistoryGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
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
	 * 게시글 삭제 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //게시글 ID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("historyType", "Delete");
				params.put("comment", comment);
				params.put("registIP", registIP);
				
				messageManageSvc.deleteLowerMessage(params);	//하위 게시글 정보 삭제 ( 답글, 덧글 )
				messageManageSvc.deleteMessage(params);			//게시글 삭제
				messageManageSvc.createHistory(params);			//삭제 기록 추가
				//삭제하는 게시글의 file size를 board_config에 가감 처리
			}
			
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
	 * 게시글 복원 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/restoreMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap restoreMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		if(!"Y".equals(SessionHelper.getSession("isAdmin"))){
			returnData.put("status", Return.FAIL);
			returnData.put("message", DicHelper.getDic("msg_sns_03")+"["+DicHelper.getDic("msg_UNotEditAuth")+"]");		//저장 중 오류가 발생했습니다.
			return returnData;
		}	
		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //삭제할 포탈 ID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("historyType", "Restore");
				params.put("comment", comment);
				params.put("registIP", registIP);
				//하위의 폴더 ID 경로 조회
				messageManageSvc.restoreLowerMessage(params);	//하위 게시글 일괄 복원
				messageManageSvc.restoreMessage(params);		//원본 게시글 복원
				messageManageSvc.createHistory(params);			//처리이력 추가
			}
			
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
	 * 게시글 잠금 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/lockMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap lockMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //삭제할 포탈 ID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("historyType", "Lock");
				params.put("comment", comment);
				params.put("registIP", registIP);
				//하위의 폴더 ID 경로 조회
				messageManageSvc.lockLowerMessage(params);		//하위 게시글 일괄 잠금처리
				messageManageSvc.lockMessage(params);			//원본 게시글 잠금처리
				messageManageSvc.createHistory(params);			//처리 이력 추가
			}
			
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
	 * 잠금해제 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/unlockMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap unlockMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //삭제할 포탈 ID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("historyType", "Unlock");
				params.put("comment", comment);
				params.put("registIP", registIP);
				//하위의 폴더 ID 경로 조회
				messageManageSvc.unlockLowerMessage(params);
				messageManageSvc.unlockMessage(params);
				messageManageSvc.createHistory(params);
			}
			
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
	 * 수정요청 상태 변경 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateRequestStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateRequestStatus(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String requestID = request.getParameter("requestID"); //MessageID
			String answerContent = request.getParameter("answerContent");
			String requestStatus = request.getParameter("requestStatus");
			String registIP = request.getRemoteHost();
			
				CoviMap params = new CoviMap();
				params.put("answererCode", SessionHelper.getSession("USERID"));
				params.put("answererName", SessionHelper.getSession("USERNAME"));
				params.put("requestID",requestID);
				params.put("answerContent", answerContent);
				params.put("requestStatus", requestStatus);
				//수정 요청 게시물 상태 변경
				messageManageSvc.updateRequestStatus(params);
			
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
	 * 문서번호 발번 현황 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectDocNumberGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectDocNumberGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");		//게시판 타입: Normal, 신고, 잠금, 삭제/만료, 수정요청 게시 통계
			CoviMap params = new CoviMap();
			String sortKey = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy") == null ? "" : request.getParameter("sortBy").split(" ")[1];
			
			BoardUtils.setRequestParam(request, params);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("useCode", SessionHelper.getSession("USERID"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			
			if(boardType.equals("DocNumberStats")){
				int cnt = messageManageSvc.selectDocNumberStatsGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageManageSvc.selectDocNumberStatsGridList(params);
			} else {
				int cnt = messageManageSvc.selectDocNumberGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageManageSvc.selectDocNumberGridList(params);
			}
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
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
