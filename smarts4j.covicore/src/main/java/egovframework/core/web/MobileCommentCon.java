package egovframework.core.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.core.sevice.CommentSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.XSSUtils;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;


@Controller
@RequestMapping("/mobile/comment/")
public class MobileCommentCon {
	
	private Logger LOGGER = LogManager.getLogger(MobileCommentCon.class);

	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private CommentSvc commentSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getCommentInfo : 댓글 - 특정 댓글 1개 정보 조회
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getCommentInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCommentInfo(
			HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String commentID = request.getParameter("commentID");
		
		CoviMap returnList = new CoviMap();
		
		CoviList resultList = new CoviList();
		
		try{
			
			CoviMap params = new CoviMap();
			params.put("commentID", commentID);
			
			//댓글 조회
			resultList = (CoviList) commentSvc.selectOne(params).get("list");
			
			//조회결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("comment", resultList);
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
	 * getCommentLike : 댓글 - 좋아요/댓글 목록
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getCommentLike.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCommentLike(
			HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String targetType = request.getParameter("targetType");
		String targetID = request.getParameter("targetID");
		String folderType = request.getParameter("folderType");
		
		CoviMap returnList = new CoviMap();
		
		CoviList resultList = new CoviList();
		
		try{
			
			CoviMap params = new CoviMap();
			params.put("registerCode", SessionHelper.getSession("USERID"));
			params.put("targetServiceType", targetType);
			params.put("targetID", targetID);
			params.put("folderType", folderType);
			
			// 1. 좋아요 카운트 조회
			int nLike = commentSvc.selectLikeCount(params);
			
			// 2. 댓글 카운트 조회
			int nComment = commentSvc.selectCommentCount(params);
			
			//3. 전체 댓글 리스트 조회
			resultList = (CoviList) commentSvc.selectListAll(params).get("list");
			
			//조회결과 리턴
			returnList.put("myLike", commentSvc.selectMyLike(params));
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("likecount", nLike);
			returnList.put("commentcount", nComment);
			returnList.put("commentlist", resultList);
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
	 * addComment : 댓글 - 추가
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "addComment.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addComment(
			HttpServletRequest request, HttpServletResponse response,
			@RequestBody Map<String, Object> map ) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		String memberOf = Objects.toString(map.get("memberOf"), "0");
		String targetID = Objects.toString(map.get("targetID"), "");
		String targetType = Objects.toString(map.get("targetType"), "");
		String comment = XSSUtils.XSSFilter(Objects.toString(map.get("comment"), ""));
		CoviMap objContext = new CoviMap();
		if(map.get("context") != null) {
			objContext = CoviMap.fromObject(map.get("context"));
		}
		String folderType = Objects.toString(map.get("folderType"), "");
		
		try{
			
			CoviMap paramComment = new CoviMap();
			paramComment.put("memberOf", memberOf);
			paramComment.put("targetServiceType", targetType);
			paramComment.put("targetID", targetID);
			paramComment.put("comment", comment);
			paramComment.put("context", objContext);
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
			CoviMap msgSettingObj = objContext.getJSONObject("MessageSetting");
			String strServiceType = msgSettingObj.getString("ServiceType");
            String strMsgType = msgSettingObj.getString("MsgType");
            
            String strMessageID = commentID;
            String strPopupURL = msgSettingObj.getString("PopupURL");
            String strGotoURL = msgSettingObj.getString("GotoURL");
            String strMobileURL = msgSettingObj.getString("MobileURL");
            String strMessagingSubject =msgSettingObj.getString("MessagingSubject")+ (msgSettingObj.getString("ServiceType").equals("Collab")?comment:"");
            strMessagingSubject= strMessagingSubject.length()>250?ComUtils.substringBytes(strMessagingSubject, 250)+"...":strMessagingSubject;

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
            String strReservedStr3 = msgSettingObj.getString("ReservedStr3");
            String strReservedStr4 = msgSettingObj.getString("ReservedStr4");
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
				
	            messageSvc.insertMessagingData(params);
			}
			
			//결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("add", resultList);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "edit.do", method=RequestMethod.POST)
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
	
	/**
	 * delComment : 댓글 - 삭제
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "delComment.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap delComment(
			HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String commentID = request.getParameter("commentID");
		String memberOf = request.getParameter("memberOf");
		String folderType = request.getParameter("folderType");
		
		CoviMap returnList = new CoviMap();
		
		CoviList resultList = new CoviList();
		
		try{
			
			CoviMap params = new CoviMap();
			params.put("commentID", commentID);
			params.put("memberOf", memberOf);
			params.put("folderType", folderType);
			
			//상위 댓글이 있을 경우 답글 개수 체크
			if(Integer.parseInt(memberOf) != 0) {
				params.put("replyCount", commentSvc.selectReplyCount(Integer.parseInt(memberOf)));
			}
			
			//댓글 삭제
			resultList = (CoviList) commentSvc.delete(params).get("list");
			
			//결과 리턴
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "OK");
			returnList.put("delete", resultList);
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
	 * like : 좋아요 추가/삭제
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "like.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap like(
			HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String targetType = request.getParameter("targetType");
		String targetID = request.getParameter("targetID");
		String likeType = "";
		String emoticon = "";
		String point = "";
		String folderType = request.getParameter("FolderType");
		String menuCode = request.getParameter("menuCode");
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("targetServiceType", targetType);
			params.put("targetID", targetID);
			params.put("likeType", likeType);
			params.put("emoticon", emoticon);
			params.put("point", point);
			params.put("folderType", folderType);
			params.put("menuCode", menuCode);
			params.put("registerCode", SessionHelper.getSession("USERID"));
			params.put("registDate", DateHelper.getUTCString());
			params.put("reserved1", null);
			params.put("reserved2", null);
			params.put("reserved3", null);
			
			returnList.put("data", commentSvc.insertLike(params));
			returnList.put("myLike", commentSvc.selectMyLike(params));
			returnList.put("result", "ok");
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
	

	/**
	 * uploadToFront : 프론트 저장소에 업로드
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "uploadToFront.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap uploadToFront(MultipartHttpServletRequest request)
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList fileInfos = CoviList.fromObject(request.getParameter("fileInfos"));
			List<MultipartFile> mf = request.getFiles("files");
			
			if(FileUtil.isEnableExtention(mf)){
				returnList.put("list", fileSvc.uploadToFront(fileInfos, mf, request.getParameter("servicePath")));
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			} else {
				returnList.put("list", "0");
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
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
	
	
	/**
	 * previewImage : 미리보기화면에서 표시할 내용 파일 조회시 사용
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	//ex) [GET] /covicore/preview/Board/282.do
	@RequestMapping(value = "preview/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public void previewImage(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
	    try{
	    	String companyCode = SessionHelper.getSession("DN_Code");
	    	String strFileID = Long.toString(fileID);
	    	fileSvc.loadImageByID(response, strFileID, companyCode, "no_image.jpg", true);
	    } catch (NullPointerException e) {
	    	  LOGGER.error("FileUtilCon", e);
		} catch(Exception e){
	      if(!e.getClass().getName().equals("org.apache.catalina.connector.ClientAbortException")) {
	    		// 해당 에러 외의 에러 처리
	    	  LOGGER.error("FileUtilCon", e);
	      }
	    }
	}
	
	/**
	 * previewImageSrc : 미리보기화면에서 표시할 이미지 경로 가져오기
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "previewsrc/{bizSection}/{fileID}.do", method = RequestMethod.GET)
	public @ResponseBody String previewImageSrc(HttpServletResponse response, @PathVariable String bizSection, @PathVariable long fileID) throws Exception {
		CoviMap params = new CoviMap();
		String fileSrc = "";
		String companyCode = SessionHelper.getSession("DN_Code");
		//String backStorageURL = RedisDataUtil.getBaseConfig("BackStorage");
		try {
			params.put("FileID", fileID);
			CoviMap fileMap = fileSvc.selectOne(params);
			companyCode = fileMap.getString("CompanyCode").equals("") ? companyCode : fileMap.getString("CompanyCode");
			//String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			//backStorageURL = backStorageURL.replace("{0}", companyCode);
			String fileName = fileMap.getString("SavedName");
			fileName = fileName.replace("."+fileMap.getString("Extention"),"_thumb.jpg");
			fileSrc = fileMap.getString("StorageFilePath").replace("{0}", companyCode) + fileMap.getString("FilePath") + fileName;
			String filePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + fileSrc;
			

	        // 파일을 읽어 스트림에 담기
		    File file = new File(FileUtil.checkTraversalCharacter(filePath));
		    
		    if(!file.exists()){
		    	//fileSrc = backStorageURL + "no_image.jpg";
		    	//fileSrc = fileSvc.getErrorImgURL("no_image.jpg", companyCode);
		    	response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		    }
		} catch (NullPointerException e) {
			//return backStorageURL + "no_image.jpg";
			//fileSrc = fileSvc.getErrorImgURL("no_image.jpg", companyCode);
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		} catch (Exception e) {
			//return backStorageURL + "no_image.jpg";
			//fileSrc = fileSvc.getErrorImgURL("no_image.jpg", companyCode);
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		}
		
		return fileSrc;
	}
	
}
