package egovframework.covision.groupware.issueboard.user.web;

import java.awt.Color;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import egovframework.baseframework.util.json.JSONSerializer;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.bizcard.user.util.BizCardUtils;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.issueboard.user.service.IssueMessageSvc;
import egovframework.covision.groupware.util.BoardUtils;

/**
 * @Class Name : IssueMessageCon.java
 * @Description : [사용자] 프로젝트 이슈 해결사례
 * @Modification Information 
 * @ 2019.07.05 최초생성
 *
 * @author 코비젼 협업팀
 * @since 2019.07.05
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class IssueMessageCon {
	
	private Logger LOGGER = LogManager.getLogger(IssueMessageCon.class);
	
	@Autowired
	private IssueMessageSvc issueMessageSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 이슈 일괄 업로드 팝업
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "board/goIssueUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView goCommentPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "user/issue/IssueUploadPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	/**
	 * 이슈 일괄 업로드
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "issue/uploadIssueMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap uploadIssueMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			int cnt = issueMessageSvc.uploadIssueMessage(params, mf);

			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", "저장되었습니다.");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		}
		return returnList;	
	}
	
	/**
	 * 게시글 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "issue/selectMessageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String boardType = request.getParameter("boardType");		//게시판 타입: Normal, 신고, 잠금, 삭제/만료, 수정요청 게시 통계
			String bizSection = request.getParameter("bizSection");
			
			String communityId = request.getParameter("communityID");
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			params.put("bizSection", bizSection);
			
			BoardUtils.setRequestParam(request, params);

			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			int cnt = issueMessageSvc.selectNormalMessageGridCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = issueMessageSvc.selectNormalMessageGridList(params);
			
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
	 * 게시글 엑셀 다운로드
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping(value = "issue/messageListExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView messageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			String bizSection = request.getParameter("bizSection");
			String boardType = request.getParameter("boardType");
			String folderType = request.getParameter("folderType");
			String boxType = request.getParameter("boxType");
			String domainID = request.getParameter("domainID");
			String menuID = request.getParameter("menuID");
			String folderID = request.getParameter("folderID");
			String useUserForm = request.getParameter("useUserForm");
			String searchType = request.getParameter("searchType");
			String searchText = request.getParameter("searchText");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");
			String approvalStatus = request.getParameter("approvalStatus");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			String headerKey = request.getParameter("headerKey");
			
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			
			String communityID = request.getParameter("communityID");
			
			String[] headerNames = headerName.split("\\|");
			
			CoviMap params = new CoviMap();
			
			params.put("bizSection", bizSection);
			params.put("boardType", boardType);
			params.put("folderType", folderType);
			params.put("boxType", boxType);
			params.put("domainID", domainID);
			params.put("menuID", menuID);
			params.put("folderID", folderID);
			params.put("useUserForm", useUserForm);
			params.put("searchType", searchType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("approvalStatus", approvalStatus);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("headerKey", headerKey);
			params.put("communityID", communityID);

			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			resultList = issueMessageSvc.selectNormalMessageExcelList(params);
			
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
	 * 게시 작성/임시저장
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "board/createIssueMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			
			if(params.get("reservationDate") != null && !params.get("reservationDate").equals("")){
				params.put("reservationLocalDate",ComUtils.TransServerTime(params.get("reservationDate").toString())); //timezone이 적용된 예약일시 
			}
			
			int cnt;
			if(params.getString("isUserForm").equals("Y")){
				cnt = issueMessageSvc.createIssueMessage(params, mf);
			}else{
				cnt = messageSvc.createMessage(params, mf);
			}
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", "저장되었습니다.");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		}
		return returnList;	
	}
	
	
	/**
	 * 게시글 상세보기 및 파일 목록 조회, 수정시 데이터 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectIssueMessageDetail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageDetail(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			CoviMap configData = issueMessageSvc.selectIssueMessageDetail(params);
			
			//업로드 파일 조회용 parameter 설정
			params.put("ServiceType", request.getParameter("bizSection"));
			params.put("ObjectID", request.getParameter("folderID"));
			params.put("ObjectType", "FD");
			params.put("MessageID", request.getParameter("messageID"));
			params.put("Version", request.getParameter("version"));
			
			if(!params.get("folderID").equals(configData.getString("FolderID"))){		//parameter로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을때 실패처리 
				returnData.put("message", "PARAMETER_MANIPULATION");					//실패 처리 관련 message parameter 추가
				returnData.put("list", configData);
				returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
				returnData.put("status", Return.FAIL);
			} else {
				returnData.put("list", configData);
				returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
				returnData.put("status", Return.SUCCESS);
			}
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
	 * 게시 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "board/updateIssueMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt;
			if(params.getString("isUserForm").equals("Y")){
				cnt = issueMessageSvc.updateIssueMessage(params, mf);
			}else{
				cnt = messageSvc.updateMessage(params, mf);
			}
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", DicHelper.getDic("msg_37"));			//저장 되었습니다.
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_sns_03"));		//저장 중 오류가 발생했습니다.
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 템플릿 다운로드
	@RequestMapping(value = "issue/excelTemplateDownload.do")
	public ModelAndView excelTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		CoviList list = new CoviList();

		String sField = "No,IssueType,Module,Source,IssueSubject,IssueContext,IssueDate,IssueSolution,Progress,Result,ComplateCheck,ComplateDate,Etc";
		
		try {
			String returnURL = "UtilIssueView";
			CoviMap viewParams = new CoviMap();
			String[] headerNames = null;
			
			headerNames = new String [] {
					"NO","이슈종류","대상모듈","출처","이슈제목"
					,"이슈내용","발생일자","해결방안","진행상태","해결결과"
					,"완료여부","완료일","비고"};
			
			viewParams.put("list", BizCardUtils.coviSelectJSONForExcel(list, sField));
			viewParams.put("cnt", 0);
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "이슈공유 업로드 템플릿");
			mav = new ModelAndView(returnURL, viewParams);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
}
