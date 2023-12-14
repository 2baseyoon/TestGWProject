package egovframework.core.web;

import java.net.URLDecoder;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.minidev.json.parser.JSONParser;



import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.MessageManageSvc;
import egovframework.core.util.MessagingQueueManager;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : MessagingCon.java
 * @Description : 통합메세징관리
 * @Modification Information 
 * @ 2017.10.13 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.10.13
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageManageCon {

	private Logger LOGGER = LogManager.getLogger(MessageManageCon.class);
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private MessageManageSvc messageMgrSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final static Object lock = new Object();
	
	@RequestMapping(value = "admin/messaging/sendSMTP.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendSMTP(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			// Parameters
			String senderName = request.getParameter("senderName"); 
            String senderEmail = request.getParameter("senderEmail"); 
            String receiverEmail = request.getParameter("receiverEmail");
            String subject = request.getParameter("subject"); 
            String message = request.getParameter("message");
            
            if(StringUtils.isNoneBlank(senderName)
            		&&StringUtils.isNoneBlank(senderEmail)
            		&&StringUtils.isNoneBlank(receiverEmail)
            		&&StringUtils.isNoneBlank(subject)
            		&&StringUtils.isNoneBlank(message)){
            	MessageHelper.getInstance().sendSMTP(senderName, senderEmail, receiverEmail, subject, message, false);
            }
            returnList.put("status", Return.SUCCESS);
			returnList.put("message", "초기화 되었습니다");
			returnList.put("result", "ok");
			
		} catch (ArrayIndexOutOfBoundsException ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "admin/messaging/sendMDMPush.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendMDMPush(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			// Parameters
			String userID = request.getParameter("userID"); 
            String message = request.getParameter("message");
            
            if(StringUtils.isNoneBlank(userID)
            		&&StringUtils.isNoneBlank(message)){
            	//뱃지 카운트 조회
            	String badgeCount = messageMgrSvc.selectBadgeCount(userID);		
            	MessageHelper.getInstance().sendPushByUserID(userID, message, badgeCount);
            }
            returnList.put("status", Return.SUCCESS);
			returnList.put("message", "초기화 되었습니다");
			returnList.put("result", "ok");
			
		} catch (ArrayIndexOutOfBoundsException ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "admin/messaging/sendMessage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendMessage(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			//LOGGER.debug("setMessagingData execute");
			
			// Parameters
			String strServiceType = request.getParameter("ServiceType");
            String strObjectType = request.getParameter("ObjectType");
            String strObjectID = request.getParameter("ObjectID");
            String strMsgType = request.getParameter("MsgType");
            String strMessageID = request.getParameter("MessageID");
            String strSubMsgID = request.getParameter("SubMsgID");
            String strMediaType = request.getParameter("MediaType");
            String strIsUse = request.getParameter("IsUse");
            String strIsDelay = request.getParameter("IsDelay");
            String strApprovalState = request.getParameter("ApprovalState");
            String strSenderCode = request.getParameter("SenderCode");
            String strReservedDate = request.getParameter("ReservedDate");
            String strXSLPath = request.getParameter("XSLPath");
            String strWidth = request.getParameter("Width");
            String strHeight = request.getParameter("Height");
            String strPopupURL = request.getParameter("PopupURL");
            String strGotoURL = request.getParameter("GotoURL");
            String strMobileURL = request.getParameter("MobileURL");
            String strOpenType = request.getParameter("OpenType");
            String strMessagingSubject = request.getParameter("MessagingSubject");
            String strMessageContext = request.getParameter("MessageContext");
            String strReceiverText = request.getParameter("ReceiverText");
            String strReservedStr1 = request.getParameter("ReservedStr1");
            String strReservedStr2 = request.getParameter("ReservedStr2");
            String strReservedStr3 = request.getParameter("ReservedStr3");
            String strReservedStr4 = request.getParameter("ReservedStr4");
            String strReservedInt1 = request.getParameter("ReservedInt1");
            String strReservedInt2 = request.getParameter("ReservedInt2");
            String strRegistererCode = request.getParameter("RegistererCode");
            String strReceiversCode = request.getParameter("ReceiversCode");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strServiceType = strServiceType == null ? null : (strServiceType.isEmpty() ? null : strServiceType);
            strObjectType = strObjectType == null ? null : (strObjectType.isEmpty() ? null : strObjectType);
            strObjectID = strObjectID == null ? null : (strObjectID.isEmpty() ? null : strObjectID);
            strMsgType = strMsgType == null ? null : (strMsgType.isEmpty() ? null : strMsgType);
            strMessageID = strMessageID == null ? null : (strMessageID.isEmpty() ? null : strMessageID);
            strSubMsgID = strSubMsgID == null ? null : (strSubMsgID.isEmpty() ? null : strSubMsgID);
            strMediaType = strMediaType == null ? null : (strMediaType.isEmpty() ? null : strMediaType);
            strIsUse = strIsUse == null ? "Y" : (strIsUse.isEmpty() ? "Y" : strIsUse);
            strIsDelay = strIsDelay == null ? "N" : (strIsDelay.isEmpty() ? "N" : strIsDelay);
            strApprovalState = strApprovalState == null ? "P" : (strApprovalState.isEmpty() ? "P" : strApprovalState);
            strSenderCode = strSenderCode == null ? null : (strSenderCode.isEmpty() ? null : strSenderCode);
            strReservedDate = strReservedDate == null ? null : (strReservedDate.isEmpty() ? null : strReservedDate);
            strXSLPath = strXSLPath == null ? null : (strXSLPath.isEmpty() ? null : strXSLPath);
            strWidth = strWidth == null ? null : (strWidth.isEmpty() ? null : strWidth);
            strHeight = strHeight == null ? null : (strHeight.isEmpty() ? null : strHeight);
            strPopupURL = strPopupURL == null ? null : (strPopupURL.isEmpty() ? null : strPopupURL);
            strGotoURL = strGotoURL == null ? null : (strGotoURL.isEmpty() ? null : strGotoURL);
            strMobileURL = strMobileURL == null ? null : (strMobileURL.isEmpty() ? null : strMobileURL);
            strOpenType = strOpenType == null ? null : (strOpenType.isEmpty() ? null : strOpenType);
            strMessagingSubject = strMessagingSubject == null ? null : (strMessagingSubject.isEmpty() ? null : strMessagingSubject);
            strMessageContext = strMessageContext == null ? null : (strMessageContext.isEmpty() ? null : strMessageContext);
            strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
            strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
            strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
            strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
            strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
            strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
            strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
            strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
            strReceiversCode = strReceiversCode == null ? null : (strReceiversCode.isEmpty() ? null : strReceiversCode);
  		
			params.put("ServiceType", strServiceType);
            params.put("ObjectType", strObjectType);
            params.put("ObjectID", strObjectID);
            params.put("MsgType", strMsgType);
            params.put("MessageID", strMessageID);
            params.put("SubMsgID", strSubMsgID);
            params.put("MediaType", strMediaType);
            params.put("IsUse", strIsUse);
            params.put("IsDelay", strIsDelay);
            params.put("ApprovalState", strApprovalState);
            params.put("SenderCode", strSenderCode);
            params.put("ReservedDate", strReservedDate);
            params.put("XSLPath", strXSLPath);
            params.put("Width", strWidth);
            params.put("Height", strHeight);
            params.put("PopupURL", strPopupURL);
            params.put("GotoURL", strGotoURL);
            params.put("MobileURL", strMobileURL);
            params.put("OpenType", strOpenType);
            params.put("MessagingSubject", strMessagingSubject);
            params.put("MessageContext", strMessageContext);
            params.put("ReceiverText", strReceiverText);
            params.put("ReservedStr1", strReservedStr1);
            params.put("ReservedStr2", strReservedStr2);
            params.put("ReservedStr3", strReservedStr3);
            params.put("ReservedStr4", strReservedStr4);
            params.put("ReservedInt1", strReservedInt1);
            params.put("ReservedInt2", strReservedInt2);
            params.put("RegistererCode", strRegistererCode);
            params.put("ReceiversCode", strReceiversCode);
			
            messageSvc.insertMessagingData(params);
			
			//LOGGER.debug("setMessagingData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			//LOGGER.debug("setMessagingData Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
			LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "admin/messaging/testjob.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap testJob(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			//LOGGER.debug("initMessagingData execute");
			
			//LOGGER.debug("initMessagingData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "초기화 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error(ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			//LOGGER.debug("initMessagingData Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/*기본기능*/
	/**
	 * getMasterMessageList : 통합 메세징 마스터 메시지 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	
	@RequestMapping(value = "admin/messaging/getmastermessagelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMasterMessageList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("getMasterMessageList execute");
			
			// Parameters
			String strServiceType = request.getParameter("BizSection"); 
            String strMsgType = request.getParameter("MsgType"); 
            String strMessagingState = request.getParameter("MsgState");
            String strSearchColumn = request.getParameter("SearchColumn"); 
            String strSearchText = request.getParameter("SearchText"); 
            String strDomainCode = SessionHelper.getSession("DN_Code");
            String strUserCode = SessionHelper.getSession("UR_Code");
            
            // 값이 비어있을경우 NULL 값으로 전달
			strServiceType = strServiceType.isEmpty() ? null : strServiceType;
			strMsgType =  strMsgType.isEmpty() ? null : strMsgType;
			strMessagingState = strMessagingState.isEmpty() ? null : strMessagingState;
			strSearchColumn = strSearchColumn.isEmpty() ? null : strSearchColumn;
			strSearchText = strSearchText.isEmpty() ? null : strSearchText;

            //정렬 및 페이징
    		String strSort = request.getParameter("sortBy");
    		String strSortColumn = "A.MessagingID";
    		String strSortDirection = "DESC";
    		String strPageNo = request.getParameter("pageNo");
    		String strPageSize = request.getParameter("pageSize");
    		
    		if(strSort != null && !strSort.isEmpty()) {
    			strSortColumn = strSort.split(" ")[0];
    			strSortDirection = strSort.split(" ")[1];
    		}
    		
    		int pageSize = 1;
    		int pageNo =  1;
    		
    		if(strPageNo != null && strPageNo.length() > 0) {
    			pageNo = Integer.parseInt(strPageNo);
    		}
    		if (strPageSize != null && strPageSize.length() > 0){
    			pageSize = Integer.parseInt(strPageSize);	
    		}
			
    		// Number Start
    		int pageOffset = (pageNo - 1) * pageSize;
    		
			params.put("BizSection", strServiceType);
            params.put("MsgType", strMsgType);
            params.put("MsgState", strMessagingState);
            params.put("SearchColumn", strSearchColumn);
            params.put("SearchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
            params.put("DN_Code", strDomainCode);
            params.put("UR_Code", strUserCode);
            params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
    		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
    		params.put("pageOffset", pageOffset);
    		params.put("pageSize", pageSize);
			
            CoviMap listData = messageMgrSvc.selectMasterMessageList(params);
			    		
    		// 총 갯수
    		int listCount = listData.getInt("cnt");
    		// 총 페이지 갯수
    		int pageCount = ((int)Math.floor((listCount - 1) / pageSize)) + 1;
    		
    		page.put("pageNo", pageNo);
    		page.put("pageSize", pageSize);
    		page.put("pageCount", pageCount);
    		page.put("listCount", listCount);
    		
    		returnList.put("page", page);
    		returnList.put("list", listData.get("list"));
    		returnList.put("result", "ok");
    		
			LOGGER.debug("getMasterMessageList execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (Exception ex) {
			LOGGER.error("getMasterMessageList Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	 */
	/**
	 * getMessagingSubData : 통합메세징 관련 서브 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/getmessagingsubdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMessagingSubData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("getMessagingSubData execute");
			
			// Parameters
            String strMessagingID = request.getParameter("MessagingID"); 
            String strMediaType = request.getParameter("MediaType");
            String strDomainCode = SessionHelper.getSession("DN_Code");
            String strUserCode = SessionHelper.getSession("UR_Code");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strMessagingID =  StringUtil.replaceNull(strMessagingID).isEmpty() ? null : strMessagingID;
            strMediaType = StringUtil.replaceNull(strMediaType).isEmpty() ? null : strMediaType;

            //정렬 및 페이징
    		String strPageNo = request.getParameter("pageNo");
    		String strPageSize = request.getParameter("pageSize");
    		    		
			params.put("MessagingID", strMessagingID);
            params.put("MediaType", strMediaType);
            params.put("DN_Code", strDomainCode);
            params.put("UR_Code", strUserCode);
            params.put("pageNo", strPageNo);
            params.put("pageSize", strPageSize);
			
            CoviMap listData = messageMgrSvc.selectMessagingSubData(params);
    		
    		returnList.put("page", listData.get("page"));
    		returnList.put("list", listData.get("list"));
    		returnList.put("result", "ok");
    		
			LOGGER.debug("getMessagingSubData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (ArrayIndexOutOfBoundsException ex) {
			LOGGER.error("getMessagingSubData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException ex) {
			LOGGER.error("getMessagingSubData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("getMessagingSubData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * initMessagingData : 통합메세징 초기화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/initmessagingdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap initMessagingData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("initMessagingData execute");
			
			// Parameters
			String InitDataArr[];
            String strMode = request.getParameter("Mode"); 
            String strMessagingID = request.getParameter("MessagingID");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strMode = StringUtil.replaceNull(strMode).isEmpty() ? null : strMode;
            strMessagingID = StringUtil.replaceNull(strMessagingID).isEmpty() ? null : strMessagingID;
  		
            //각 초기화 데이터별 처리
            if(strMessagingID != null){
            	InitDataArr = strMessagingID.split(";");
            	for(String msgID : InitDataArr){
            		params.put("Mode", strMode);
    				params.put("MessagingID", msgID);
    				messageMgrSvc.initMessagingData(params);         		
            	}
            }
			
			LOGGER.debug("initMessagingData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "초기화 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("initMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("initMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * setMessagingData : 통합 메세징 등록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/setmessagingdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setMessagingData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("setMessagingData execute");
			
			// Parameters
			String strServiceType = request.getParameter("ServiceType");
            String strObjectType = request.getParameter("ObjectType");
            String strObjectID = request.getParameter("ObjectID");
            String strMsgType = request.getParameter("MsgType");
            String strMessageID = request.getParameter("MessageID");
            String strSubMsgID = request.getParameter("SubMsgID");
            String strMediaType = request.getParameter("MediaType");
            String strIsUse = request.getParameter("IsUse");
            String strIsDelay = request.getParameter("IsDelay");
            String strApprovalState = request.getParameter("ApprovalState");
            String strSenderCode = request.getParameter("SenderCode");
            String strReservedDate = request.getParameter("ReservedDate");
            String strXSLPath = request.getParameter("XSLPath");
            String strWidth = request.getParameter("Width");
            String strHeight = request.getParameter("Height");
            String strPopupURL = request.getParameter("PopupURL");
            String strGotoURL = request.getParameter("GotoURL");
            String strMobileURL = request.getParameter("MobileURL");
            String strOpenType = request.getParameter("OpenType");
            String strMessagingSubject = request.getParameter("MessagingSubject");
            String strMessageContext = request.getParameter("MessageContext");
            String strReceiverText = request.getParameter("ReceiverText");
            String strReservedStr1 = request.getParameter("ReservedStr1");
            String strReservedStr2 = request.getParameter("ReservedStr2");
            String strReservedStr3 = request.getParameter("ReservedStr3");
            String strReservedStr4 = request.getParameter("ReservedStr4");
            String strReservedInt1 = request.getParameter("ReservedInt1");
            String strReservedInt2 = request.getParameter("ReservedInt2");
            String strRegistererCode = request.getParameter("RegistererCode");
            String strReceiversCode = request.getParameter("ReceiversCode");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strServiceType = strServiceType == null ? null : (strServiceType.isEmpty() ? null : strServiceType);
            strObjectType = strObjectType == null ? null : (strObjectType.isEmpty() ? null : strObjectType);
            strObjectID = strObjectID == null ? null : (strObjectID.isEmpty() ? null : strObjectID);
            strMsgType = strMsgType == null ? null : (strMsgType.isEmpty() ? null : strMsgType);
            strMessageID = strMessageID == null ? null : (strMessageID.isEmpty() ? null : strMessageID);
            strSubMsgID = strSubMsgID == null ? null : (strSubMsgID.isEmpty() ? null : strSubMsgID);
            strMediaType = strMediaType == null ? null : (strMediaType.isEmpty() ? null : strMediaType);
            strIsUse = strIsUse == null ? "Y" : (strIsUse.isEmpty() ? "Y" : strIsUse);
            strIsDelay = strIsDelay == null ? "N" : (strIsDelay.isEmpty() ? "N" : strIsDelay);
            strApprovalState = strApprovalState == null ? "P" : (strApprovalState.isEmpty() ? "P" : strApprovalState);
            strSenderCode = strSenderCode == null ? null : (strSenderCode.isEmpty() ? null : strSenderCode);
            strReservedDate = strReservedDate == null ? null : (strReservedDate.isEmpty() ? null : strReservedDate);
            strXSLPath = strXSLPath == null ? null : (strXSLPath.isEmpty() ? null : strXSLPath);
            strWidth = strWidth == null ? null : (strWidth.isEmpty() ? null : strWidth);
            strHeight = strHeight == null ? null : (strHeight.isEmpty() ? null : strHeight);
            strPopupURL = strPopupURL == null ? null : (strPopupURL.isEmpty() ? null : strPopupURL);
            strGotoURL = strGotoURL == null ? null : (strGotoURL.isEmpty() ? null : strGotoURL);
            strMobileURL = strMobileURL == null ? null : (strMobileURL.isEmpty() ? null : strMobileURL);
            strOpenType = strOpenType == null ? null : (strOpenType.isEmpty() ? null : strOpenType);
            strMessagingSubject = strMessagingSubject == null ? null : (strMessagingSubject.isEmpty() ? null : strMessagingSubject);
            strMessageContext = strMessageContext == null ? null : (strMessageContext.isEmpty() ? null : strMessageContext);
            strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
            strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
            strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
            strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
            strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
            strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
            strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
            strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
            strReceiversCode = strReceiversCode == null ? null : (strReceiversCode.isEmpty() ? null : strReceiversCode);
  		
			params.put("ServiceType", strServiceType);
            params.put("ObjectType", strObjectType);
            params.put("ObjectID", strObjectID);
            params.put("MsgType", strMsgType);
            params.put("MessageID", strMessageID);
            params.put("SubMsgID", strSubMsgID);
            params.put("MediaType", strMediaType);
            params.put("IsUse", strIsUse);
            params.put("IsDelay", strIsDelay);
            params.put("ApprovalState", strApprovalState);
            params.put("SenderCode", strSenderCode);
            params.put("ReservedDate", strReservedDate);
            params.put("XSLPath", strXSLPath);
            params.put("Width", strWidth);
            params.put("Height", strHeight);
            params.put("PopupURL", strPopupURL);
            params.put("GotoURL", strGotoURL);
            params.put("MobileURL", strMobileURL);
            params.put("OpenType", strOpenType);
            params.put("MessagingSubject", strMessagingSubject);
            params.put("MessageContext", strMessageContext);
            params.put("ReceiverText", strReceiverText);
            params.put("ReservedStr1", strReservedStr1);
            params.put("ReservedStr2", strReservedStr2);
            params.put("ReservedStr3", strReservedStr3);
            params.put("ReservedStr4", strReservedStr4);
            params.put("ReservedInt1", strReservedInt1);
            params.put("ReservedInt2", strReservedInt2);
            params.put("RegistererCode", strRegistererCode);
            params.put("ReceiversCode", strReceiversCode);
			
            messageSvc.insertMessagingData(params);
			
			LOGGER.debug("setMessagingData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("setMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("setMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * editMessagingData : 통합메세징 관련 정보 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 * 기존 활용 함수
	 * - public int EditMessagingData(MessagingEnt pMessagingEnt, string pIsSendYN)
	 * - public int EditMessagingData(MessagingEnt pMessagingEnt)
	 */
	@RequestMapping(value = "admin/messaging/editmessagingdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editMessagingData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("editMessagingData execute");
			
			// Parameters
			String strMessagingID = request.getParameter("MessagingID");
			String strServiceType = request.getParameter("ServiceType");
           String strObjectType = request.getParameter("ObjectType");
           String strObjectID = request.getParameter("ObjectID");
           String strMessageID = request.getParameter("MessageID");
           String strSubMsgID = request.getParameter("SubMsgID");
           String strMediaType = request.getParameter("MediaType");
           String strIsUse = request.getParameter("IsUse");
           String strIsDelay = request.getParameter("IsDelay");
           String strIsPush = request.getParameter("IsPush");
           String strIsMobilePushed = request.getParameter("IsMobilePushed");
           String strMessagingSubject = request.getParameter("MessagingSubject");
           String strMessagingState = request.getParameter("MessagingState");
           String strApprovalState = request.getParameter("ApprovalState");
           String strSenderCode = request.getParameter("SenderCode");
           String strReservedDate = request.getParameter("ReservedDate");
           String strXSLPath = request.getParameter("XSLPath");
           String strWidth = request.getParameter("Width");
           String strHeight = request.getParameter("Height");
           String strPopupURL = request.getParameter("PopupURL");
           String strGotoURL = request.getParameter("GotoURL");
           String strMobileURL = request.getParameter("MobileURL");
           String strOpenType = request.getParameter("OpenType");
           String strMessageContext = request.getParameter("MessageContext");
           String strReservedStr1 = request.getParameter("ReservedStr1");
           String strReservedStr2 = request.getParameter("ReservedStr2");
           String strReservedStr3 = request.getParameter("ReservedStr3");
           String strReservedStr4 = request.getParameter("ReservedStr4");
           String strReservedInt1 = request.getParameter("ReservedInt1");
           String strReservedInt2 = request.getParameter("ReservedInt2");
           String strModifierCode = request.getParameter("ModifierCode");
           String strDeleteDate = request.getParameter("DeleteDate");
           
           // 값이 비어있을경우 NULL 값으로 전달
           strMessagingID = strMessagingID == null || strMessagingID.isEmpty() ? null : strMessagingID;
           strServiceType = strServiceType == null || strServiceType.isEmpty() ? null : strServiceType;
           strObjectType = strObjectType == null || strObjectType.isEmpty() ? null : strObjectType;
           strObjectID = strObjectID == null || strObjectID.isEmpty() ? null : strObjectID;
           strMessageID = strMessageID == null || strMessageID.isEmpty() ? null : strMessageID;
           strSubMsgID = strSubMsgID == null || strSubMsgID.isEmpty() ? null : strSubMsgID;
           strMediaType = strMediaType == null || strMediaType.isEmpty() ? null : strMediaType;
           strIsUse = strIsUse == null || strIsUse.isEmpty() ? null : strIsUse;
           strIsDelay = strIsDelay == null || strIsDelay.isEmpty() ? null : strIsDelay;
           strIsPush = strIsPush == null || strIsPush.isEmpty() ? null : strIsPush;
           strIsMobilePushed = strIsMobilePushed == null || strIsMobilePushed.isEmpty() ? null : strIsMobilePushed;
           strMessagingSubject = strMessagingSubject == null || strMessagingSubject.isEmpty() ? null : strMessagingSubject;
           strMessagingState = strMessagingState == null || strMessagingState.isEmpty() ? null : strMessagingState;
           strApprovalState = strApprovalState == null || strApprovalState.isEmpty() ? null : strApprovalState;
           strSenderCode = strSenderCode == null || strSenderCode.isEmpty() ? null : strSenderCode;
           strReservedDate = strReservedDate == null || strReservedDate.isEmpty() ? null : strReservedDate;
           strXSLPath = strXSLPath == null || strXSLPath.isEmpty() ? null : strXSLPath;
           strWidth = strWidth == null || strWidth.isEmpty() ? null : strWidth;
           strHeight = strHeight == null || strHeight.isEmpty() ? null : strHeight;
           strPopupURL = strPopupURL == null || strPopupURL.isEmpty() ? null : strPopupURL;
           strGotoURL = strGotoURL == null || strGotoURL.isEmpty() ? null : strGotoURL;
           strMobileURL = strMobileURL == null || strMobileURL.isEmpty() ? null : strMobileURL;
           strOpenType = strOpenType == null || strOpenType.isEmpty() ? null : strOpenType;
           strMessageContext = strMessageContext == null || strMessageContext.isEmpty() ? null : strMessageContext;
           strReservedStr1 = strReservedStr1 == null || strReservedStr1.isEmpty() ? null : strReservedStr1;
           strReservedStr2 = strReservedStr2 == null || strReservedStr2.isEmpty() ? null : strReservedStr2;
           strReservedStr3 = strReservedStr3 == null || strReservedStr3.isEmpty() ? null : strReservedStr3;
           strReservedStr4 = strReservedStr4 == null || strReservedStr4.isEmpty() ? null : strReservedStr4;
           strReservedInt1 = strReservedInt1 == null || strReservedInt1.isEmpty() ? null : strReservedInt1;
           strReservedInt2 = strReservedInt2 == null || strReservedInt2.isEmpty() ? null : strReservedInt2;
           strModifierCode = strModifierCode == null || strModifierCode.isEmpty() ? null : strModifierCode;
           strDeleteDate = strDeleteDate == null || strDeleteDate.isEmpty() ? null : strDeleteDate;
 		
           params.put("MessagingIDs", strMessagingID);
		   params.put("ServiceType", strServiceType);
           params.put("ObjectType", strObjectType);
           params.put("ObjectID", strObjectID);
           params.put("MessageID", strMessageID);
           params.put("SubMsgID", strSubMsgID);
           params.put("MediaType", strMediaType);
           params.put("IsUse", strIsUse);
           params.put("IsDelay", strIsDelay);
           params.put("IsPush", strIsPush);
           params.put("IsMobilePushed", strIsMobilePushed);
           params.put("MessagingSubject", strMessagingSubject);
           params.put("MessagingState", strMessagingState);
           params.put("ApprovalState", strApprovalState);
           params.put("SenderCode", strSenderCode);
           params.put("ReservedDate", strReservedDate);
           params.put("XSLPath", strXSLPath);
           params.put("Width", strWidth);
           params.put("Height", strHeight);
           params.put("PopupURL", strPopupURL);
           params.put("GotoURL", strGotoURL);
           params.put("MobileURL", strMobileURL);
           params.put("OpenType", strOpenType);
           params.put("MessageContext", strMessageContext);
           params.put("ReservedStr1", strReservedStr1);
           params.put("ReservedStr2", strReservedStr2);
           params.put("ReservedStr3", strReservedStr3);
           params.put("ReservedStr4", strReservedStr4);
           params.put("ReservedInt1", strReservedInt1);
           params.put("ReservedInt2", strReservedInt2);
           params.put("ModifierCode", strModifierCode);
           params.put("DeleteDate", strDeleteDate);
			
           messageMgrSvc.updateMessagingData(params);
			
			LOGGER.debug("editmessagingdata execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("editMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("editMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteMessagingData : 통합메세징 관련 정보 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/deletemessagingdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteMessagingData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("deleteMessagingData execute");
			
			// Parameters
			String strMessagingID = request.getParameter("MessagingID");
            String strSubID = request.getParameter("SubID"); 
            
            // 값이 비어있을경우 NULL 값으로 전달
            strMessagingID =  StringUtil.replaceNull(strMessagingID).isEmpty() ? null : strMessagingID;
            strSubID = StringUtil.replaceNull(strSubID).isEmpty() ? null : strSubID;
                    
            params.put("MessagingID", strMessagingID);
            params.put("SubID", strSubID);
            
            messageMgrSvc.deleteMessagingData(params);           
  					
			LOGGER.debug("deleteMessagingData execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("deleteMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("deleteMessagingData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * getMessagingApprovalList : 통합메세징 관련 발송 승인 목록
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/getmessagingapprovallist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMessagingApprovalList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("getMessagingApprovalList execute");
			
			// Parameters
            String strMessagingID = request.getParameter("MessagingID");
            String strServiceType = request.getParameter("ServiceType"); 
            String strMsgType = request.getParameter("MsgType"); 
            String strSearchColumn = request.getParameter("SearchColumn"); 
            String strSearchText = request.getParameter("SearchText"); 
            
            // 값이 비어있을경우 NULL 값으로 전달
            strMessagingID = StringUtil.replaceNull(strMessagingID).isEmpty() ? null : strMessagingID;
			strServiceType = StringUtil.replaceNull(strServiceType).isEmpty() ? null : strServiceType;
			strMsgType =  StringUtil.replaceNull(strMsgType).isEmpty() ? null : strMsgType;
			strSearchColumn = StringUtil.replaceNull(strSearchColumn).isEmpty() ? null : strSearchColumn;
			strSearchText = StringUtil.replaceNull(strSearchText).isEmpty() ? null : strSearchText;

            //정렬 및 페이징
    		String strSort = request.getParameter("sortBy");
    		String strSortColumn = "MessagingID";
    		String strSortDirection = "DESC";
    		String strPageNo = request.getParameter("pageNo");
    		String strPageSize = request.getParameter("pageSize");
    		
    		if(strSort != null && !strSort.isEmpty()) {
    			strSortColumn = strSort.split(" ")[0];
    			strSortDirection = strSort.split(" ")[1];
    		}
    		
            params.put("MessagingID", strMessagingID);
            params.put("ServiceType", strServiceType);
            params.put("MsgType", strMsgType);
            params.put("SearchColumn", strSearchColumn);
            params.put("SearchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
            params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
    		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
    		params.put("pageNo", strPageNo);
    		params.put("pageSize", strPageSize);
			
            CoviMap listData = messageMgrSvc.selectMessagingApprovalList(params);
			    		
    		returnList.put("page", listData.get("page"));
    		returnList.put("list", listData.get("list"));
    		returnList.put("result", "ok");
    		
			LOGGER.debug("getMessagingApprovalList execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException ex) {
			LOGGER.error("getMessagingApprovalList Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("getMessagingApprovalList Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * editMessagingPartialApproval : 통합메세징 관련 발송 승인 요청 시 부분 승인
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/editmessagingpartialapproval.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editMessagingPartialApproval(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("editMessagingPartialApproval execute");
			
			// Parameters
			String strMessagingID = request.getParameter("MessagingID");
			String strRejectMediaType = request.getParameter("RejectMediaType");
			String strDelimiter = request.getParameter("Delimiter");
			            
            // 값이 비어있을경우 NULL 값으로 전달
            strMessagingID = StringUtil.replaceNull(strMessagingID).isEmpty() ? null : strMessagingID;
            strRejectMediaType = StringUtil.replaceNull(strRejectMediaType).isEmpty() ? "" : strRejectMediaType;
            strDelimiter = StringUtil.replaceNull(strDelimiter).isEmpty() ? ";" : strDelimiter;            

			String RejectMediaTypeArr[] = StringUtil.replaceNull(strRejectMediaType).split(strDelimiter);
  		
            params.put("MessagingID", strMessagingID);
            params.put("RejectMediaType", RejectMediaTypeArr);
			
            messageMgrSvc.updateMessagingPartialApproval(params);
			
			LOGGER.debug("editMessagingPartialApproval execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "초기화 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("editMessagingPartialApproval Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("editMessagingPartialApproval Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
				
	/*알림 메시지 개인별 설정 제어(추후 작업 예정)*/

	/*부가기능*/
	/*
	 * sentMessagingGroup : 통합메세징(그룹대상) 발송후 처리사항(SvcImpl로 이동)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	/*@RequestMapping(value = "admin/messaging/sentmessaginggroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sentMessagingGroup(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
//		try {
//			LOGGER.debug("sentMessagingGroup execute");
//
//   		   //Com_S_MessagingSentFail_U
//           returnList.put("object", messagingSvc.sentMessagingGroup();
//			
//			LOGGER.debug("sentMessagingGroup execute complete");
//			returnList.put("status", Return.SUCCESS);
//			returnList.put("message", "초기화 되었습니다");
//			returnList.put("result", "ok");
//			
//		} catch (Exception ex) {
//			LOGGER.debug("sentMessagingGroup Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
//			returnList.put("status", Return.FAIL);
//			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
//		}
		return returnList;
	}*/
	
	/*
	 * addCheckBoxListItems : BaseCode의 코드를 통해서 CheckBoxList의 Option Item을 자동으로 추가하여 줌.(미사용 메서드로 사료됨) 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 * 기존 활용 함수
	 * - public void AddCheckBoxListItems(System.Web.UI.WebControls.CheckBoxList pChkList, string pCodeGroup, string pFirstOption, string pSelectedValue, bool pShowCodeGrop, bool pProperty, string[,] pAddList, string[] pSubtractList)
     * - public void AddCheckBoxListItems(System.Web.UI.WebControls.CheckBoxList pChkList, string pCodeGroup, string pFirstOption, string pSelectedValue, bool pShowCodeGrop, bool pProperty, string[,] pAddList)
	 * - public void AddCheckBoxListItems(System.Web.UI.WebControls.CheckBoxList pChkList, string pCodeGroup, string pFirstOption, string pSelectedValue, bool pShowCodeGrop, bool pProperty, string[] pSubtactList)
	 * - public void AddCheckBoxListItems(System.Web.UI.WebControls.CheckBoxList pChkList, string pCodeGroup, string pFirstOption, string pSelectedValue, bool pShowCodeGrop, bool pProperty) 
	 */
	/*@RequestMapping(value = "admin/messaging/addcheckboxlistitems.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addCheckBoxListItems(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		String sChkBoxConfig = null;
		
		try {
			LOGGER.debug("addCheckBoxListItems execute");

			sChkBoxConfig = request.getParameter("sChkBoxConfig");
			sChkBoxConfig = request.getParameter("sChkBoxConfig");
			sChkBoxConfig = request.getParameter("sChkBoxConfig");
			params.put("sChkBoxConfig", sChkBoxConfig);
			
   		   //Com_C_BaseCode_R ...
		   messagingSvc.addCheckBoxListItems(params);
			
			LOGGER.debug("addCheckBoxListItems execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "추가 되었습니다");
			returnList.put("result", "ok");
			
		} catch (Exception ex) {
			LOGGER.debug("addCheckBoxListItems Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}*/
	
	/**
	 * getNodeList : 통합메세징에 사용할 조직도용 Node 조회.(미사용 메서드로 사료됨) 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	/*@RequestMapping(value = "admin/messaging/getnodelist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getNodeList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("getNodeList execute");
			
			// Parameters
            String strXMLText = request.getParameter("XMLText"); 
            String strGroupType = request.getParameter("GroupType");
            String strNodeName = SessionHelper.getSession("NodeName");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strXMLText =  strXMLText.isEmpty() ? null : strXMLText;
            strGroupType = strGroupType.isEmpty() ? null : strGroupType;
            strNodeName = strNodeName.isEmpty() ? null : strNodeName;
            
			params.put("XMLText", strXMLText);
            params.put("GroupType", strGroupType);
            params.put("NodeName", strNodeName);
     
            CoviMap listData = messagingSvc.getNodeList(params);

    		returnList.put("list", listData.get("list"));
    		returnList.put("result", "ok");
    		
			LOGGER.debug("getNodeList complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "정상적으로 실행되었습니다.");
			
		} catch (Exception ex) {
			LOGGER.debug("getNodeList Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	*/
	
	/**
	 * getMemberList : 통합메세징에 사용할 멤버 리스트 조회(승인자 등).(미사용 메서드로 사료됨) 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	/*@RequestMapping(value = "admin/messaging/getmemberlist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMemberList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("getMemberList execute");
			
			// Parameters
            String strXMLText = request.getParameter("XMLText"); 
            String strGroupType = request.getParameter("GroupType");
            String strNodeName = SessionHelper.getSession("NodeName");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strXMLText =  strXMLText.isEmpty() ? null : strXMLText;
            strGroupType = strGroupType.isEmpty() ? null : strGroupType;
            strNodeName = strNodeName.isEmpty() ? null : strNodeName;
            
			params.put("XMLText", strXMLText);
            params.put("GroupType", strGroupType);
            params.put("NodeName", strNodeName);
     
            CoviMap listData = messagingSvc.getMemberList(params);

    		returnList.put("list", listData.get("list"));
    		returnList.put("result", "ok");
    		
			LOGGER.debug("getMemberList complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "정상적으로 실행되었습니다.");
			
		} catch (Exception ex) {
			LOGGER.debug("getMemberList Failed [" + ex.getMessage() + "]" + "[" + ex.getStackTrace() + "]");
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}	
	*/
		
	/*ExternalWebService*/
	//통합메세징 외부 서비스
	@RequestMapping(value = "admin/messaging/externalsendmessage.do", method=RequestMethod.POST)
	public @ResponseBody String externalSendMessage(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		String strResult = "";
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("externalSendMessage execute");
			
			// Parameters
			String strMsg = request.getParameter("pXmlStr");
			
			// String -> CoviMap parsing
			JSONParser parser = new JSONParser(); 
			CoviMap oMsgData = (CoviMap) parser.parse(strMsg);
			
			// 1. 시스템   EX) External   External
            params.put("ServiceType", oMsgData.getString("ServiceType"));
            // 2. 객체 유형(FD, MN)
            params.put("ObjectType", oMsgData.getString("ObjectType"));
            // 3. 객체 아이디(게시판 아이디)
            params.put("ObjectID", oMsgData.getString("ObjectID").equals("") ? "0" : oMsgData.getString("ObjectID"));
            // 4. 메시지 아이디
            params.put("MessageID", oMsgData.getString("MessageID").equals("") ? "0" : oMsgData.getString("MessageID"));
            // 5. 알림 유형(msg_aFor + 알림유형) => 다국어 변화 및 Format을 사용하여 메일 발송시 바인딩 가능  Ex) ExNoticeService
            params.put("MsgType", oMsgData.getString("MsgType"));
            // 6. 지연발송 여부(중요는 지연발송)
            params.put("IsDelay", oMsgData.getString("IsDelay").equals("") ? "N" : oMsgData.getString("IsDelay"));
            // 7. 알림 메체 - 미지정시 기본 설정값 중 발신가능 매체를 이용함. ex) SMS;MDM;MAIL
            params.put("MediaType", oMsgData.getString("MediaType"));
            // 8. 메일 발송 양식
            params.put("XSLPath", "Mail_Smart.xsl"); //ComUtils.XSLPath.MAIL_SMART;
            // 9. Todo 팝업 방식
            switch(oMsgData.getString("OpenType").toUpperCase())
            {
                case "PAGEMOVE":
                	params.put("OpenType", "PAGEMOVE"); // ComUtils.OpenType.PAGEMOVE;
                    break;
                case "LAYERPOPUP":
                	params.put("OpenType", "LAYERPOPUP");  //ComUtils.OpenType.LAYERPOPUP;
                    break;
                case "OPENPOPUP":
                default:
                	params.put("OpenType", "OPENPOPUP");  //ComUtils.OpenType.OPENPOPUP;
                    break;

            }
            // 10. 팝업 사이즈 W
            params.put("Width", oMsgData.getString("Width").equals("") ? "788" : oMsgData.getString("Width"));
            // 11. 팝업 사이즈 H
            params.put("Height", oMsgData.getString("Height").equals("") ? "600" : oMsgData.getString("Height"));
            // 12. 제목(타이틀)
            params.put("MessagingSubject", convertOutputValue(oMsgData.getString("MessagingSubject")).replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
            // 13. 본문 내용(HTML)
            params.put("MessageContext", oMsgData.getString("MessageContext"));
         // 14. 요약 Text(Todo에 내용에 보여짐)
            params.put("ReceiverText", oMsgData.getString("ReceiverText"));
            // 15. 팝업 URL(Todo에서)
            params.put("PopupURL", convertOutputValue(oMsgData.getString("PopupURL")).replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
            // 16. 이동 URL(메일, MDM 등)
            params.put("GotoURL", convertOutputValue(oMsgData.getString("GotoURL")).replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
            // 추가항목 - 모바일 URL (MDM)
            params.put("MobileURL", convertOutputValue(oMsgData.getString("MobileURL")).replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
            // 17. 발송자 코드
            params.put("SenderCode", oMsgData.getString("SenderCode"));
            // 18. 등록자 코드
            params.put("RegistererCode", oMsgData.getString("RegistererCode"));
            // 19. 예약 발송일시 ("" - 즉시 발송, 2015-09-10 10:00 - 지정일시)
            params.put("ReservedDate", oMsgData.getString("ReservedDate"));
            // 20. 수신자 IDs (k96mi005;kclee;bgkang)
            params.put("ReceiversCode", oMsgData.getString("ReceiversCode"));
            // 21. 메일 발송시 Summery Item 사용여부 ( YES | NO - MessageContext가 내용으로 표시됨.)
            params.put("ReservedStr3", oMsgData.getString("ReservedStr3").equals("") ? "NO" : oMsgData.getString("ReservedStr3"));
            // 22. 메일 발송시 Summery Item Node(다국어키1†데이터다국어¶다국어키1†데이터다국어¶다국어키1†데이터다국어)
            // 게시판명, 작성자, 제목, 등록일시
            /*
            cbme.ReservedStr4 = string.Format("{0}†{1}¶{2}†{3}¶{4}†{5}¶{6}†{7}"
                , "lbl_BoardNm", "{3}"
                , "lbl_subject", "{4}"
                , "lbl_Register", "{11}({12})"
                , "lbl_RegistDateHour", "{7}"
            );
            */
            params.put("ReservedStr4", oMsgData.getString("ReservedStr4"));
            /* 바인딩 가능 정보 */
            // 0 - 시스템 명칭            ex) Smart2
            // 1 - 업무 시스템 명         ex) 통합게시
            // 2 - 알림 유형              ex) 게시등록알림
            // 3 - 객체명(폴더,메뉴명)    ex) 공지사항 게시판
            // 4 - 메시지 제목            ex) "연말정상 공지"
            // 5 - 메시지 내용(다국어 처리안됨.)
            // 6 - 요약(다국어 처리됨.)   
            // 7 - 등록일시               ex) 2015-08-19 09:10
            // 8 - Summery 사용여부 ( YES | NO )
            // 9 - GotoURL 
            // 10 - 수신자명
            // 11 - 발신자명(작성자)
            // 12 - 발신자부서

            // 요약 정보
            params.put("ReservedStr4", "¶lbl_Summary†{6}");
			
			//둘 중 하나...
            //setMessagingData(request, response, params);
            messageSvc.insertMessagingData(params);
			
			LOGGER.debug("sendMessaging execute complete");		
			strResult = "true;";
			
		} catch (NullPointerException ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		} catch (Exception ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		}
		
		return strResult;
	}
	
	//업무보고 보고일 알림 서비스
	@RequestMapping(value = "admin/messaging/sendworkreportalarm.do", method=RequestMethod.POST)
	public @ResponseBody String sendWorkReportAlarm(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		String strResult = "";
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("externalSendMessage execute");
			
			// Parameters
			String strReceiveDeptCodes = request.getParameter("receiveDeptCodes"); 
			
			// 1. 시스템   EX) External   External
            params.put("ServiceType", "WorkReport");
            // 2. 객체 유형(FD, MN)
            params.put("ObjectType", "");
            // 3. 객체 아이디(게시판 아이디)
            params.put("ObjectID", null);
            // 4. 메시지 아이디
            params.put("MessageID", null);
            // 5. 알림 유형(msg_aFor + 알림유형) => 다국어 변화 및 Format을 사용하여 메일 발송시 바인딩 가능  Ex) ExNoticeService
            params.put("MsgType", "WorkReport_NOTICE");
            // 6. 지연발송 여부(중요는 지연발송)
            params.put("IsDelay", "N");
            // 7. 알림 메체 - 미지정시 기본 설정값 중 발신가능 매체를 이용함. ex) SMS;MDM;MAIL
            params.put("MediaType", "ALARMLIST");
            // 8. 메일 발송 양식
            params.put("XSLPath", ""); //ComUtils.XSLPath.NONE
            // 9. Todo 팝업 방식
            params.put("OpenType", "OPENPOPUP");  //ComUtils.OpenType.OPENPOPUP;
            // 10. 팝업 사이즈 W
            params.put("Width", 0);
            // 11. 팝업 사이즈 H
            params.put("Height", 0);
            // 12. 제목(타이틀)
            params.put("MessagingSubject", DicHelper.getDic("lbl_todayWorkReport"));
            // 13. 본문 내용(HTML)
            params.put("MessageContext", "");
            // 14. 요약 Text(Todo에 내용에 보여짐)
            params.put("ReceiverText", DicHelper.getDic("msg_todayWorkReport"));
            // 15. 팝업 URL(Todo에서)
            params.put("PopupURL", DicHelper.getDic("WorkReportURL") + "/workreport_workreport.do");
            // 16. 이동 URL(메일, MDM 등)
            params.put("GotoURL", DicHelper.getDic("WorkReportURL") + "/workreport_workreport.do");
            // 17. 발송자 코드
            params.put("SenderCode", "SuperAdmin");
            // 18. 등록자 코드
            params.put("RegistererCode", "SuperAdmin");
            // 19. 예약 발송일시 ("" - 즉시 발송, 2015-09-10 10:00 - 지정일시)
            params.put("ReservedDate", "");
            // 20. 수신자 IDs (k96mi005;kclee;bgkang)
            params.put("ReceiversCode", strReceiveDeptCodes);
            // 21. 메일 발송시 Summery Item 사용여부 ( YES | NO - MessageContext가 내용으로 표시됨.)
            params.put("ReservedStr3", "NO");
            // 22. 메일 발송시 Summery Item Node(다국어키1†데이터다국어¶다국어키1†데이터다국어¶다국어키1†데이터다국어)
            // 게시판명, 작성자, 제목, 등록일시
            /*
            cbme.ReservedStr4 = string.Format("{0}†{1}¶{2}†{3}¶{4}†{5}¶{6}†{7}"
                , "lbl_BoardNm", "{3}"
                , "lbl_subject", "{4}"
                , "lbl_Register", "{11}({12})"
                , "lbl_RegistDateHour", "{7}"
            );
            */
            params.put("ReservedStr4", "");
            /* 바인딩 가능 정보 */
            // 0 - 시스템 명칭            ex) Smart2
            // 1 - 업무 시스템 명         ex) 통합게시
            // 2 - 알림 유형              ex) 게시등록알림
            // 3 - 객체명(폴더,메뉴명)    ex) 공지사항 게시판
            // 4 - 메시지 제목            ex) "연말정상 공지"
            // 5 - 메시지 내용(다국어 처리안됨.)
            // 6 - 요약(다국어 처리됨.)   
            // 7 - 등록일시               ex) 2015-08-19 09:10
            // 8 - Summery 사용여부 ( YES | NO )
            // 9 - GotoURL 
            // 10 - 수신자명
            // 11 - 발신자명(작성자)
            // 12 - 발신자부서
			
			//둘 중 하나...
            //setMessagingData(request, response, params);
            messageSvc.insertMessagingData(params);
			
			LOGGER.debug("sendMessaging execute complete");		
			strResult = "true;";
			
		} catch (NullPointerException ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		} catch (Exception ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		}
		
		return strResult;
	}
	
	//인디메일 도착 알림 서비스(인디메일 도착 알림 PUSH 요청 서비스)
	@RequestMapping(value = "admin/messaging/sendindimailPush.do", method=RequestMethod.POST)
	public @ResponseBody String sendIndiMailPush(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		String strResult = "";
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("externalSendMessage execute");
			
			// Parameters
			String strSender = request.getParameter("pSender"); //메일발신자(bluemoon)
			String strReceivers = request.getParameter("pReceivers"); //메일수신자들(sunnyhwang;ivory;sky09)
			String strMsgTitle = request.getParameter("pMsgTitle"); //메일제목(이해의 건)
			String strMsgURL = request.getParameter("pMsgURL"); //메일URL
						
			// 1. 시스템   EX) External   External
            params.put("ServiceType", "Mail");
            // 2. 객체 유형(FD, MN)
            params.put("ObjectType", "FD");
            // 3. 객체 아이디(게시판 아이디)
            params.put("ObjectID", null);
            // 4. 메시지 아이디
            params.put("MessageID", null);
            // 5. 알림 유형(msg_aFor + 알림유형) => 다국어 변화 및 Format을 사용하여 메일 발송시 바인딩 가능  Ex) ExNoticeService
            params.put("MsgType", "MessageNew");
            // 6. 지연발송 여부(중요는 지연발송)
            params.put("IsDelay", "N");
            // 7. 알림 메체 - 미지정시 기본 설정값 중 발신가능 매체를 이용함. ex) SMS;MDM;MAIL
            params.put("MediaType", "MDM");
            // 8. 메일 발송 양식
            params.put("XSLPath", ""); //ComUtils.XSLPath.NONE
            // 9. Todo 팝업 방식
            params.put("OpenType", "OPENPOPUP");  //ComUtils.OpenType.OPENPOPUP;
            // 10. 팝업 사이즈 W
            params.put("Width", 0);
            // 11. 팝업 사이즈 H
            params.put("Height", 0);
            // 12. 제목(타이틀)
            params.put("MessagingSubject", strMsgTitle);
            // 13. 본문 내용(HTML)
            params.put("MessageContext", "");
            // 14. 요약 Text(Todo에 내용에 보여짐)
            params.put("ReceiverText", "");
            // 15. 팝업 URL(Todo에서)
            params.put("PopupURL", "");
            // 16. 이동 URL(메일, MDM 등)
            params.put("GotoURL", strMsgURL);
            // 추가항목 모바일 URL (MDM)
            params.put("MobileURL", strMsgURL);
            // 17. 발송자 코드
            params.put("SenderCode", strSender);
            // 18. 등록자 코드
            params.put("RegistererCode", strSender);
            // 19. 예약 발송일시 ("" - 즉시 발송, 2015-09-10 10:00 - 지정일시)
            params.put("ReservedDate", "");
            // 20. 수신자 IDs (k96mi005;kclee;bgkang)
            params.put("ReceiversCode", strReceivers);
            // 21. 메일 발송시 Summery Item 사용여부 ( YES | NO - MessageContext가 내용으로 표시됨.)
            params.put("ReservedStr3", "NO");
            // 22. 메일 발송시 Summery Item Node(다국어키1†데이터다국어¶다국어키1†데이터다국어¶다국어키1†데이터다국어)
            // 게시판명, 작성자, 제목, 등록일시
            /*
            cbme.ReservedStr4 = string.Format("{0}†{1}¶{2}†{3}¶{4}†{5}¶{6}†{7}"
                , "lbl_BoardNm", "{3}"
                , "lbl_subject", "{4}"
                , "lbl_Register", "{11}({12})"
                , "lbl_RegistDateHour", "{7}"
            );
            */
            params.put("ReservedStr4", "");
            /* 바인딩 가능 정보 */
            // 0 - 시스템 명칭            ex) Smart2
            // 1 - 업무 시스템 명         ex) 통합게시
            // 2 - 알림 유형              ex) 게시등록알림
            // 3 - 객체명(폴더,메뉴명)    ex) 공지사항 게시판
            // 4 - 메시지 제목            ex) "연말정상 공지"
            // 5 - 메시지 내용(다국어 처리안됨.)
            // 6 - 요약(다국어 처리됨.)   
            // 7 - 등록일시               ex) 2015-08-19 09:10
            // 8 - Summery 사용여부 ( YES | NO )
            // 9 - GotoURL 
            // 10 - 수신자명
            // 11 - 발신자명(작성자)
            // 12 - 발신자부서
			
			//둘 중 하나...
            //setMessagingData(request, response, params);
            messageSvc.insertMessagingData(params);
			
			LOGGER.debug("sendMessaging execute complete");		
			strResult = "true;";
			
		} catch (NullPointerException ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		} catch (Exception ex) {
			LOGGER.error("externalSendMessage Failed [" + ex.getMessage() + "]", ex);
			strResult = "false;" + ex.getMessage();
		}
		
		return strResult;
	}

	public String convertOutputValue(String pValue) {
		pValue = pValue.replaceAll("&amp;", "&");
        pValue = pValue.replaceAll("&lt;", "<");
        pValue = pValue.replaceAll("&gt;", ">");
        pValue = pValue.replaceAll("&quot;", "\"");
        pValue = pValue.replaceAll("&apos;", "'");
        pValue = pValue.replaceAll("&#x2F;", "\\");
        pValue = pValue.replaceAll("&nbsp;", " ");

        return pValue;
	}
	
	//페이지 이동
	@RequestMapping(value="admin/messaging/submessaginginfopop.do", method=RequestMethod.GET)
	public ModelAndView showRegionInfoPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strMsgID = request.getParameter("msgID");
		
		String returnURL = "core/messaging/messagingsublistpopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("msgID", strMsgID);

		return mav;
	}
	
	//페이지 이동
	@RequestMapping(value="admin/messaging/messagingapprovalpopup.do", method=RequestMethod.GET)
	public ModelAndView showMessagingApprovalPopUp(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strMsgID = request.getParameter("msgID");
		
		String returnURL = "core/messaging/messagingapprovalpopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("msgID", strMsgID);

		return mav;
	}
	
	// 메세지 유형 관리 - NotificationMedia
	@RequestMapping(value="admin/messaging/getBaseCode.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getGroupList(HttpServletRequest request) throws Exception {
		
		CoviMap listData = messageMgrSvc.selectBaseCode();
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	

	//페이지 이동
	@RequestMapping(value="admin/messaging/moveToLink.do", method=RequestMethod.GET)
	public ModelAndView moveToLink(HttpServletRequest request, HttpServletResponse response) throws Exception{
		boolean isMobile = ClientInfoHelper.isMobile(request);

		String returnURL = "";
		String strServiceType = request.getParameter("ServiceType"); 
		String strGotoURL = URLDecoder.decode(request.getParameter("GotoURL"), "UTF-8").replace("&amp;", "&");
		String strMobileURL = URLDecoder.decode(request.getParameter("MobileURL"), "UTF-8").replace("&amp;", "&");
		
		if(isMobile) {	//모바일인 경우
			returnURL = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
			if(StringUtil.isNotNull(strMobileURL)) {	//모바일 URL이 존재할 경우
				returnURL += strMobileURL.replace(PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"), "")
						.replace(PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path"), ""); 
				String domainId = SessionHelper.getSession("DN_ID");
				returnURL = MessageHelper.replaceLinkUrl (domainId, returnURL, isMobile);
				
			}else {
				switch(StringUtil.replaceNull(strServiceType).toUpperCase()) {
					case "APPROVAL":
						returnURL += "/approval/mobile/approval/view.do?"+strGotoURL.split("[?]")[1];
						break;
					case "BOARD":
						returnURL += "/groupware/mobile/board/view.do?"+strGotoURL.split("[?]")[1];
						break;
					case "RESOURCE":
						returnURL += "/groupware/mobile/resource/view.do?"+strGotoURL.split("[?]")[1];
						break;
					case "SCHEDULE":
						returnURL += "/groupware/mobile/schedule/view.do?"+strGotoURL.split("[?]")[1];
						break;
					case "TASK":
						returnURL += "/groupware/mobile/task/view.do?"+strGotoURL.split("[?]")[1];
						break;
					case "COMMUNITY":
						returnURL += "/groupware/mobile/community/portal.do";
						break;
					case "SURVEY":
						returnURL += "/groupware/mobile/survey/list.do?"+strGotoURL.split("[?]")[1].replace("reqType", "surveytype");
						break;
					case "MAIL":
						returnURL += "/mail/mobile/mail/Read.do";
						break;
					case "COLLAB":
						returnURL += "/groupware/mobile/collab/portal.do";
						break;
					case "EACCOUNTING":
						break;
					case "WORKREPORT":
						break;
				}
			}
		} else {	//PC일 경우 
			returnURL = strGotoURL;
			//.replace(PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"), "")
			//.replace(PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path"), "");
		}
		
		// URL 이 상대경로일 경우 절대경호 URL 로 변경한다
        if(!returnURL.matches("^(https?):\\/\\/([^:\\/\\s]+)(:([^\\/]*))?((\\/[^\\s/\\/]+)*)?\\/?([^#\\s\\?]*)(\\?([^#\\s]*))?(#(\\w*))?$")) {     // URL 여부 확인
            returnURL = (isMobile == true ? PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path") : PropertiesUtil.getGlobalProperties().getProperty("smart4j.path")) + returnURL;
        }
		
		ModelAndView mav = new ModelAndView("redirect:" + returnURL);

		return mav;
	}
	
	/*InternalWebService*/
	/*
	 * sendMessaging4MailNoti : 통합 메세징 관련 서비스-메일도착알림만처리( 매체별 처리 : 송신 및 결과 처리를 각 매체별로 처리 )
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/sendmessaging4MailNoti.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendMessaging4MailNoti(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
			CoviMap returnList = new CoviMap();
			CoviMap params = new CoviMap();
			try {
				LOGGER.info("call sendMessaging");
				if (RedisDataUtil.getBaseConfig("IsUseMailNotification").equalsIgnoreCase("Y")) {												
					//Mail도착알림을 사용하는 경우에만 처리
					params.put("IsUseMailNotification",RedisDataUtil.getBaseConfig("IsUseMailNotification"));
					
					//스케쥴러는 지연건, 재전송건등 전체메시지에 대한 처리만 담당.
					//건별 최조 발송시도는 실시간 Background 처리
					
					//1. 알림 대상 조회  및 알림 대상 상태 변경 (대기  → 진행) 
					CoviMap targetMsgObj = messageMgrSvc.sendMessagingBefore(params);				 
					//2. 알림 발송 : 스케쥴러에서 발송하는 대상 : MessagingState 값이 1 로 되어 있는 데이터 만 처리. (외부연동등 단순 Insert 만 가능한 경우)
					CoviMap resultObj = messageMgrSvc.sendMessaging(targetMsgObj);
					
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", resultObj.get("Result"));
					
				} else {
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "메일 알림 사용하지 않음");
					return returnList;
				}
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			}
			
			return returnList;							
	}
	
	/*InternalWebService*/
	/*
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/sendmessaging.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendmessaging(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
			CoviMap returnList = new CoviMap();
			CoviMap params = new CoviMap();
			try {
				LOGGER.info("call sendMessaging");

				//스케쥴러는 지연건, 재전송건등 전체메시지에 대한 처리만 담당.
				//건별 최조 발송시도는 실시간 Background 처리
				
				//1. 알림 대상 조회  및 알림 대상 상태 변경 (대기  → 진행) 
				CoviMap targetMsgObj = messageMgrSvc.sendMessagingBefore(params);				 
				//2. 알림 발송 : 스케쥴러에서 발송하는 대상 : MessagingState 값이 1 로 되어 있는 데이터 만 처리. (외부연동등 단순 Insert 만 가능한 경우)
				CoviMap resultObj = messageMgrSvc.sendMessaging(targetMsgObj);
				
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", resultObj.get("Result"));
			} catch (NullPointerException ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			} catch (Exception ex) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
			}
			
			return returnList;							
	}
	
	// 발송 메세지 데이터 조회
	@RequestMapping(value = "admin/messaging/selectMessagingList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessagingList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("domainId", request.getParameter("domainId"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			params.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			params.put("messagingState", request.getParameter("messagingState"));
			params.put("searchType", request.getParameter("searchType"));
			params.put("searchInput", request.getParameter("searchInput"));
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("exceptTypeList",new java.util.ArrayList<>(java.util.Arrays.asList("MailNotification")));
			resultList = messageMgrSvc.selectMessagingList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//페이지 이동
	@RequestMapping(value="admin/messaging/MessagingSubPopup.do", method=RequestMethod.GET)
	public ModelAndView messagingSubPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strMsgID = request.getParameter("msgID");
		
		String returnURL = "core/messaging/MessagingSubPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("msgID", strMsgID);

		return mav;
	}

	/**
	 * setMessagingBaseCode : 통합메세징 휴형수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/setMessagingType.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setMessagingType(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap reqMap = new CoviMap();
		
		try {
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("codeId", request.getParameter("codeid"));
			reqMap.put("mode", request.getParameter("mode"));
			reqMap.put("isDisplay", request.getParameter("isDisplay"));
			
			reqMap.put("mediaType", request.getParameter("mediaType"));
			reqMap.put("mediaFlag", request.getParameter("mediaFlag"));
           	messageMgrSvc.setMessagingType(reqMap);
			
			LOGGER.debug("setMessagingBaseCode execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("setMessagingBaseCode Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("setMessagingBaseCode Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteMessagingData : 통합메세징 관련 정보 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/messaging/deleteMessagingType.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteMessagingType(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			LOGGER.debug("deleteMessagingType execute");
			
			// Parameters
			String strCodeID = request.getParameter("CodeID");
            
            // 값이 비어있을경우 NULL 값으로 전달
            strCodeID = StringUtil.replaceNull(strCodeID).isEmpty() ? null : strCodeID;
                    
            params.put("CodeID", strCodeID);
            
            messageMgrSvc.deleteMessagingType(params);           
  					
			LOGGER.debug("deleteMessagingType execute complete");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제 되었습니다");
			returnList.put("result", "ok");
			
		} catch (NullPointerException ex) {
			LOGGER.error("deleteMessagingType Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("deleteMessagingType Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * addbaseconfiglayerpopup : 통합메세징 휴형수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/messaging/goMessagingTypeMngPopup.do", method = RequestMethod.GET)
	public ModelAndView goBaseCodePopup(Locale locale, Model model) {
		String returnURL = "core/messaging/MessagingTypeMngPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	
	@Autowired
	private MessagingQueueManager queueManager;
	/**
	 * sys_messaging Insert 후 즉시 발송수행 (Thread 처리)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "messaging/queueMessage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap queueMessage(HttpServletRequest request, HttpServletResponse response, @RequestBody CoviMap param) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String messagingID = param.getString("MessagingID");
		
		queueManager.offer(messagingID);
		returnList.put("status", Return.SUCCESS);
		return returnList;		
	}
	
	@RequestMapping(value = "admin/messaging/goMessagingHealthInfo.do", method = RequestMethod.GET)
	public ModelAndView goMessagingHealthInfo(HttpServletRequest request, HttpServletResponse response) {
		String returnURL = "core/messaging/MessagingHealth";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
}