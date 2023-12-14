package egovframework.core.web;

import java.net.URL;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.core.sevice.CommentSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.filter.lucyXssFilter;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.XSSUtils;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : CommentCon.java
 * @Description : 댓글컨트롤러
 * @Modification Information 
 * @ 2017.08.31 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 08.31
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CommentCon {

	private Logger LOGGER = LogManager.getLogger(CommentCon.class);
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private CommentSvc commentSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "comment/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComment(HttpServletRequest request,
			@RequestParam(value = "RowCount", required = true, defaultValue = "5") String rowCnt,
			@RequestParam(value = "TargetType", required = true, defaultValue = "") String targetType,
			@RequestParam(value = "TargetID", required = true, defaultValue = "") String targetID,
			@RequestParam(value = "MemberOf", required = false, defaultValue = "0") String memberOf,
			@RequestParam(value = "LastCommentID", required = false, defaultValue = "0") String lastID,
			@RequestParam(value = "folderType", required = false, defaultValue = "") String folderType) throws Exception{
		
		CoviMap returnList = new CoviMap();
		lucyXssFilter lucyXssFilter = new lucyXssFilter();
		
		try {
			int rowCount = Integer.parseInt(rowCnt);
			CoviMap params = new CoviMap();
			params.put("lastCommentID", Integer.parseInt(lastID));
			params.put("rowCount", rowCount);
			params.put("memberOf", memberOf);
			params.put("targetServiceType", targetType);
			params.put("targetID", targetID);
			params.put("folderType", folderType);
			
			// 코멘트 체크
			boolean commentAuth = false;
			
			// 호출 URL
			URL url = new URL(request.getHeader("REFERER"));
			String queryStr = url.getQuery();			
			if(queryStr == null) {
				queryStr = "";
			}
			// 쿼리 스트링 CoviMap 변환
			CoviMap reQueryString = new CoviMap();
			String[] reParams = queryStr.split("&");
			for (String item : reParams) {
				if(StringUtils.isNotEmpty(item)) {
					String key = item.substring(0, item.indexOf('='));
				    String val = item.substring(item.indexOf('=') + 1);
					reQueryString.put(key, val);
				}
			}

			String tId = "";
			
			if (targetType.equals("Board") || targetType.equals("Community") || targetType.equals("Doc")) {
				if("Feed".equals(reQueryString.getString("CLBIZ"))) {
					tId = targetID;
				} else {
					tId = reQueryString.getString("messageID") + "_" + reQueryString.getString("version");
				}
			} else if (targetType.equals("Resource") || targetType.equals("Schedule")) {
				tId = reQueryString.getString("eventID");
			} else if (targetType.equals("Collab")) {
				tId = reQueryString.getString("taskSeq");
			}

			if(tId.equals(targetID)) {
				commentAuth = true;
			} else if (folderType.equals("QuickComment")) {
				commentAuth = true;
			} else if (folderType.equals("Feed")) {
				commentAuth = true;
			}

			if (commentAuth) {
				CoviMap resultList = commentSvc.select(params);
				CoviList commentArray = (CoviList)resultList.get("list");
				
				if(!commentArray.isEmpty()){
					CoviMap lastCommentObj = (CoviMap)commentArray.get(commentArray.size() - 1);
					int lastCommentID = lastCommentObj.getInt("CommentID");
					params.put("lastCommentID", lastCommentID);
					CoviMap moreList = commentSvc.select(params);
					CoviList moreCommentArray = (CoviList)moreList.get("list");
					returnList.put("moreCount", moreCommentArray.size());
				}else{
					returnList.put("moreCount", 0);
				}
				
				returnList.put("list",  lucyXssFilter.xssFilterString(resultList.get("list").toString()));
				returnList.put("status", Return.SUCCESS);
			}
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	@RequestMapping(value = "comment/getComment.do")
	public @ResponseBody CoviMap getComment(HttpServletRequest request,
			@RequestParam(value = "CommentID", required = true, defaultValue = "") String commentID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("commentID", commentID);
			CoviMap resultList = commentSvc.selectOne(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	@RequestMapping(value = "comment/getCommentCount.do")
	public @ResponseBody CoviMap getCommentCount(HttpServletRequest request,
			@RequestParam(value = "TargetType", required = true, defaultValue = "") String targetType,
			@RequestParam(value = "TargetID", required = true, defaultValue = "") String targetID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("targetServiceType", targetType);
			params.put("targetID", targetID);
			
			returnList.put("data", commentSvc.selectCommentCount(params));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	@RequestMapping(value = "comment/getReplyCount.do")
	public @ResponseBody CoviMap getReplyCount(HttpServletRequest request,
			@RequestParam(value = "MemberOf", required = false, defaultValue = "0") String memberOf) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			returnList.put("data", commentSvc.selectReplyCount(Integer.parseInt(memberOf)));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}	
	
	@RequestMapping(value = "comment/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addComment(HttpServletRequest request,
			@RequestBody Map<String, Object> map) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String memberOf =  Objects.toString(map.get("MemberOf"), "0");
			String targetID =  Objects.toString(map.get("TargetID"), "");
			String targetServiceType =  Objects.toString(map.get("TargetServiceType"), "");
			String comment =  XSSUtils.XSSFilter(Objects.toString(map.get("Comment"), ""));
			CoviMap context = new CoviMap();
			if(map.get("Context") != null){
				context = CoviMap.fromObject(map.get("Context"));	
			}
			String folderType =  Objects.toString(map.get("FolderType"), "");
			
			//Date today = new Date();
			//SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			CoviMap paramComment = new CoviMap();
			paramComment.put("memberOf", memberOf);
			paramComment.put("targetServiceType", targetServiceType);
			paramComment.put("targetID", targetID);
			paramComment.put("comment", comment);
			paramComment.put("context", context);
			paramComment.put("likeCnt", 0);
			paramComment.put("replyCnt", 0);
			paramComment.put("registerCode", SessionHelper.getSession("USERID"));
			paramComment.put("registDate", DateHelper.getUTCString());
			paramComment.put("deleteDate", null);
			paramComment.put("reserved1", null);
			paramComment.put("reserved2", null);
			paramComment.put("reserved3", null);
			paramComment.put("reserved4", null);
			paramComment.put("reserved5", null);
			paramComment.put("folderType", folderType);
			
			resultList = commentSvc.insert(paramComment);
			
			CoviMap objTmp = CoviMap.fromObject(CoviList.fromObject(resultList.get("list")).get(0));
			String commentID = objTmp.getString("CommentID");
			//context 내의 messageSetting의 ReceiversCode 값이 빈값이 아닌 경우 통합메시징 처리
			CoviMap msgSettingObj = context.getJSONObject("MessageSetting");
			String strServiceType = paramComment.getString("targetServiceType");
            String strMsgType = msgSettingObj.getString("MsgType");

            String strMessageID = commentID;
            String strPopupURL = msgSettingObj.getString("PopupURL");
            String strGotoURL = msgSettingObj.getString("GotoURL");
            String strMobileURL = msgSettingObj.getString("MobileURL");
            String strMessagingSubject =msgSettingObj.getString("MessagingSubject")+ (msgSettingObj.getString("ServiceType").equals("Collab")?comment:"");
            strMessagingSubject= strMessagingSubject.length()>250?ComUtils.substringBytes(strMessagingSubject, 250)+"...":strMessagingSubject;

            CoviMap dicMap = new CoviMap();
            CoviMap dicParams = new CoviMap();
            
            if(folderType.equals("QuickComment")) {//한줄 게시판 표시
            	strMessagingSubject = "[§FolderType_Line§]" + strMessagingSubject; //[한줄 게시판] 게시판 이름
            	
            	String[] dicArr = {"FolderType_Line"};
            	dicParams.put("dicArr", dicArr);
            	dicMap = messageSvc.getDicInfo(dicParams);
            }
            
            String strMessageContext =comment.replaceAll("\n", "<br>");
            String strRegistererCode = msgSettingObj.getString("RegistererCode");
            String strSenderCode = msgSettingObj.getString("SenderCode");
            String strReservedDate = msgSettingObj.getString("ReservedDate");

            String strObjectType = msgSettingObj.getString("ObjectType");
            String strObjectID = msgSettingObj.getString("ObjectID");
            String strSubMsgID = msgSettingObj.getString("SubMsgID");
            String strMediaType = msgSettingObj.getString("MediaType");
            String strIsUse = msgSettingObj.getString("IsUse");
            String strIsDelay = msgSettingObj.getString("IsDelay");
            String strApprovalState = msgSettingObj.getString("ApprovalState");
            String strXSLPath = msgSettingObj.getString("XSLPath");
            String strWidth = msgSettingObj.getString("Width");
            String strHeight = msgSettingObj.getString("Height");
            String strOpenType = msgSettingObj.getString("OpenType");

            String strReceiverText = msgSettingObj.getString("ReceiverText");
            String strReservedStr1 = msgSettingObj.getString("ReservedStr1");
            String strReservedStr2 = msgSettingObj.getString("ReservedStr2");
            String strReservedStr3 = objTmp.getString("MemberOf");//답글 ID
            String strReservedStr4 = CoviMap.toJSONString(dicMap);//한줄 게시판 다국어 처리
            String strReservedInt1 = msgSettingObj.getString("ReservedInt1");
            String strReservedInt2 = msgSettingObj.getString("ReservedInt2");
            String strReceiversCode = msgSettingObj.getString("ReceiversCode");
            String domainID = SessionHelper.getSession("DN_ID");
            
            CoviMap result = null;
			if(!"".equals(memberOf)) { // 댓글에 대한 답글(대댓글) 작성 시 게시글 등록자, 댓글 등록자에게 통합 알림 발송 -> CommentID 값으로 체크
				result = commentSvc.selectSenderCode(paramComment);
			}
            
            if(!msgSettingObj.isEmpty() && (StringUtils.isNoneBlank(msgSettingObj.getString("ReceiversCode"))|| result != null) && !"Anonymous".equals(folderType)){
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
	            strMessagingSubject = strMessagingSubject.isEmpty() ? null : strMessagingSubject;
	            strMessageContext = strMessageContext.isEmpty() ? null : strMessageContext;
	            strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
	            strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
	            strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
	            strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
	            strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
	            strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
	            strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
	            strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
	            strReceiversCode = strReceiversCode == null ? "" : (strReceiversCode.isEmpty() ? "" : strReceiversCode);
	            if (result != null) {
	            	if (strReceiversCode.indexOf(result.getString("RegisterCode")) == -1) {
	            		strReceiversCode += (!"".equals(strObjectID) ? ';' : "") + result.getString("RegisterCode");
	            	}
	            }
	            domainID = domainID == null ? null : (domainID.isEmpty() ? null : domainID);
	            
	            CoviMap params = new CoviMap();
	            params.put("ReceiversCode", strReceiversCode);
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
	            params.put("DomainID", domainID);
	            params.put("MemberOf", memberOf);
				
	            messageSvc.insertMessagingData(params);
			}
			
			//mention 추가
			CoviMap mntSettingObj = context.getJSONObject("Mention");
			if(!mntSettingObj.isEmpty()){
				String strMentionMsgType =  msgSettingObj.getString("MentionMsgType"); //TaskAddMention				
				java.util.Iterator<String> iter = mntSettingObj.keySet().iterator();
				StringBuffer menReceiver = new StringBuffer("");
	            
				if (!msgSettingObj.getString("ServiceType").equals("Collab")){
		            strMessagingSubject ="["+msgSettingObj.getString("MessagingSubject")+"]"+ comment;
		            strMessagingSubject= strMessagingSubject.length()>250?ComUtils.substringBytes(strMessagingSubject, 250)+"...":strMessagingSubject;		            
				}    
				//mntSettingObj.getString("ReceiversCode")
				while(iter.hasNext()){   
					String key = iter.next();
					if (!menReceiver.toString().equals("")) menReceiver.append(";");
					menReceiver.append(key);
				}
	            strReceiversCode =  menReceiver.toString();
				if (!menReceiver.toString().equals("")){
		            
		            CoviMap params = new CoviMap();
					params.put("ServiceType", strServiceType);
		            params.put("MsgType", strMentionMsgType);
		            params.put("MessageID", strMessageID);
		            params.put("PopupURL", strPopupURL);
		            params.put("GotoURL", strGotoURL);
		            params.put("MobileURL", strMobileURL);
		            params.put("IsUse", "Y");
		            params.put("IsDelay", "N");
		            params.put("ApprovalState", "P");
		            params.put("SenderCode", strSenderCode);
		            params.put("MessagingSubject", strMessagingSubject);
		            params.put("MessageContext", strMessageContext);
		            params.put("RegistererCode", strRegistererCode);
		            params.put("ReceiversCode", strReceiversCode);
		            params.put("ReservedInt1", "-1");
					
		            messageSvc.insertMessagingData(params);
				}     
			}
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "comment/edit.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap editComment(HttpServletRequest request, @RequestBody Map<String, Object> map) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String comment =  Objects.toString(map.get("Comment"), "");
			String commentID = Objects.toString(map.get("CommentID"), "");
			String folderType = Objects.toString(map.get("FolderType"), "");
			CoviMap context = new CoviMap();
			if(map.get("Context") != null){
				context = CoviMap.fromObject(map.get("Context"));	
			}
			
			CoviMap param = new CoviMap();
			param.put("commentID", commentID);
			param.put("folderType", folderType);

			CoviList commentArray = (CoviList)((CoviMap)commentSvc.selectOne(param)).get("list");
			CoviMap commentMap = ((CoviMap)commentArray.get(0));

			if (commentMap.getString("RegisterCode").equals(SessionHelper.getSession("USERID")) || "Y".equals(commentMap.getString("AnonymousAuthYn"))) {			
				CoviMap paramComment = new CoviMap();
				paramComment.put("comment", XSSUtils.XSSFilter(comment));
				paramComment.put("context", context);
				paramComment.put("commentID", commentID);
				paramComment.put("folderType", folderType);
				paramComment.put("registerCode", SessionHelper.getSession("USERID"));
				
				resultList = commentSvc.updateComment(paramComment);
	
				returnList.put("list", resultList.get("list"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
			} else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_noDeleteACL"));
			}
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "comment/addLike.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addLike(HttpServletRequest request,
			@RequestParam(value = "TargetType", required = true, defaultValue = "") String targetType,
			@RequestParam(value = "TargetID", required = true, defaultValue = "") String targetID,
			@RequestParam(value = "LikeType", required = false, defaultValue = "emoticon") String likeType,
			@RequestParam(value = "Emoticon", required = false, defaultValue = "heart") String emoticon,
			@RequestParam(value = "Point", required = false, defaultValue = "0") String point,
			@RequestParam(value = "FolderType", required = false, defaultValue = "0") String folderType,
			@RequestParam(value = "menuCode", required = false, defaultValue = "") String menuCode,
			@RequestParam(value = "ReservedStr1", required = false, defaultValue = "") String ReservedStr1) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			//Date today = new Date();
			//SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			CoviMap paramLike = new CoviMap();
			paramLike.put("targetServiceType", targetType);
			paramLike.put("targetID", targetID);
			paramLike.put("likeType", likeType);
			paramLike.put("emoticon", emoticon);
			paramLike.put("point", point);
			paramLike.put("folderType", folderType);
			paramLike.put("registerCode", SessionHelper.getSession("USERID"));
			paramLike.put("registDate", DateHelper.getUTCString());
			paramLike.put("reserved1", null);
			paramLike.put("reserved2", null);
			paramLike.put("reserved3", null);
			paramLike.put("menuCode", menuCode);
			paramLike.put("ReservedStr1", ReservedStr1);
			
			returnList.put("data", commentSvc.insertLike(paramLike));
			returnList.put("myLike", commentSvc.selectMyLike(paramLike));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "comment/getLike.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getLike(HttpServletRequest request,
			@RequestParam(value = "TargetType", required = true, defaultValue = "") String targetType,
			@RequestParam(value = "TargetID", required = true, defaultValue = "") String targetID) throws Exception {
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap paramLike = new CoviMap();
			paramLike.put("targetServiceType", targetType);
			paramLike.put("targetID", targetID);
			paramLike.put("registerCode", SessionHelper.getSession("USERID"));
			
			returnList.put("data", commentSvc.selectLikeCount(paramLike));
			returnList.put("myLike", commentSvc.selectMyLike(paramLike));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "comment/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap removeComment(HttpServletRequest request,
			@RequestParam(value = "CommentID", required = true, defaultValue = "") String commentID,
			@RequestParam(value = "MemberOf", required = true, defaultValue = "0") String memberOf,
			@RequestParam(value = "folderType", required = true, defaultValue = "") String folderType,
			@RequestParam(value = "commentDelAuth", required = true, defaultValue = "false") String commentDelAuth
		) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("commentID", commentID);
			param.put("folderType", folderType);
			CoviList commentArray = (CoviList)((CoviMap)commentSvc.selectOne(param)).get("list");
			CoviMap commentMap = ((CoviMap)commentArray.get(0));
			if (commentMap.getString("RegisterCode").equals(SessionHelper.getSession("USERID")) || 
					"Y".equals(commentMap.getString("AnonymousAuthYn")) || "true".equalsIgnoreCase(commentDelAuth)) {
				param.put("memberOf", memberOf);
				param.put("folderType", folderType);
				
				resultList = commentSvc.delete(param);
				returnList.put("list", resultList.get("list"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
			}	
			else{
				returnList.put("status", Return.FAIL);//msg_noWriteAuth
				returnList.put("message", DicHelper.getDic("msg_noDeleteACL"));
			}
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/*
	public String createMessageContext(CoviMap params){
		String strHTML = "";	//알림 메일 본문
		
		strHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>";
		strHTML += "<body>"
				+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
						+ "<tr>"
						+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
								+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
										+ "<tr>"
										+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
										+ DicHelper.getDic("BizSection_" + params.getString("ServiceType")) + "(" + params.get("ServiceType") + ")"	//Title
										+"</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>"
						+ "<tr>"
						+ "<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">"
								+ "<!-- 문서현황 시작-->"
								+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">"
										+ "<tr>"
										+ "<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">"
												+ "<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">"
												+ params.get("MessagingSubject")		//Context
												+ "</span>"
												+ " <br />"
										+ "</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>";
		
		strHTML += "</table></td></tr>"
				+ "<tr>"
				+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">"
						+ "<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
								+ "<tr>"
								+ "<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">"
										+ "Title"
								+ "</th>"
								+ "<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">"
										+ "<a href=\""+ params.get("GotoURL")	//URL : 페이지 연결 URL
												+ "\" style=\"cursor: pointer;\">"
										+ params.get("MessagingSubject")	//SUBJECT : 제목
										+ "</a>"
								+ "</td>"
								+ "</tr>"
						+ "</table>"
				+ "</td>"
				+ "</tr>"
				+ "</table></td></tr>";
		
		strHTML += "</table></body></html>";
		return strHTML;
	}*/
}
