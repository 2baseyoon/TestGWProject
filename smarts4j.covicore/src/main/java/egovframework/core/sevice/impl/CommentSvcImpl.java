package egovframework.core.sevice.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import egovframework.core.sevice.CommentSvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("commentService")
public class CommentSvcImpl extends EgovAbstractServiceImpl implements CommentSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		params.put("UserCode", SessionHelper.getSession("USERID"));
//		CoviList clist = coviMapperOne.list("common.control.comment.selectList", params);
		CoviList clist = coviMapperOne.list("common.control.comment.selectListAll", params);
		CoviMap resultList = new CoviMap();
		CoviList commentArr = CoviSelectSet.coviSelectJSON(clist, "CommentID,MemberOf,TargetServiceType,TargetID,Comment,Context,LikeCount,MyLikeCount,ReplyCount,RegisterCode,RegistDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,AnonymousAuthYn,Depth");
		
		for(Object obj : commentArr) {
			CoviMap commentObj = (CoviMap) obj;
			
			if(!commentObj.getString("Context").isEmpty()) {
				CoviMap contextObj = CoviMap.fromObject(commentObj.getString("Context"));								
				CoviList fileArray = contextObj.getJSONArray("File");
				
				// 익명 게시판의 댓글일 경우, 댓글을 작성한 사용자를 추적할 수 없도록 정보를 삭제
				if(params.has("folderType") && "Anonymous".equals(params.getString("folderType"))) {
					CoviMap commentUserInfo = CoviMap.fromObject(contextObj.getString("User"));
					commentUserInfo.put("Dept", "");
					commentUserInfo.put("JobLevel", "");
					commentUserInfo.put("JobPosition", "");
					commentUserInfo.put("JobTitle", "");
					commentUserInfo.put("Name", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("NickName", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("Photo", "");					
					contextObj.put("User", commentUserInfo);

					if(contextObj.has("MessageSetting")) {
						CoviMap messageSettingObj = CoviMap.fromObject(contextObj.getString("MessageSetting"));
						messageSettingObj.put("ReceiversCode", "Anonymous");
						messageSettingObj.put("RegistererCode", "Anonymous");
						messageSettingObj.put("SenderCode", "Anonymous");
						contextObj.put("MessageSetting", messageSettingObj);
					}
					
					for(Object fileArrayObj : fileArray) {
						CoviMap fileObj = (CoviMap) fileArrayObj;
						fileObj.put("RegisterCode", "Anonymous");
					}
				}
				
				contextObj.put("File", FileUtil.getFileTokenArray(fileArray));
				commentObj.put("Context", contextObj);
			}
		}
		
		resultList.put("list", commentArr);		
		return resultList;
	}
	
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		params.put("UserCode", SessionHelper.getSession("USERID"));
		CoviMap map = coviMapperOne.select("common.control.comment.selectOne", params);		
		CoviMap resultList = new CoviMap();
		CoviList commentArr = CoviSelectSet.coviSelectJSON(map, "CommentID,MemberOf,TargetServiceType,TargetID,Comment,Context,LikeCount,ReplyCount,RegisterCode,RegistDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,AnonymousAuthYn,Depth");
		
		for(Object obj : commentArr) {
			CoviMap commentObj = (CoviMap) obj;
			
			if(!commentObj.getString("Context").isEmpty()) {
				CoviMap contextObj = CoviMap.fromObject(commentObj.getString("Context"));
				CoviList fileArray = contextObj.getJSONArray("File");
				
				// 익명 게시판의 댓글일 경우, 댓글을 작성한 사용자를 추적할 수 없도록 정보를 삭제
				if(params.has("folderType") && "Anonymous".equals(params.getString("folderType"))) {
					CoviMap commentUserInfo = CoviMap.fromObject(contextObj.getString("User"));
					commentUserInfo.put("Dept", "");
					commentUserInfo.put("JobLevel", "");
					commentUserInfo.put("JobPosition", "");
					commentUserInfo.put("JobTitle", "");
					commentUserInfo.put("Name", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("NickName", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("Photo", "");					
					contextObj.put("User", commentUserInfo);
					
					if(contextObj.has("MessageSetting")) {
						CoviMap messageSettingObj = CoviMap.fromObject(contextObj.getString("MessageSetting"));
						messageSettingObj.put("ReceiversCode", "Anonymous");
						messageSettingObj.put("RegistererCode", "Anonymous");
						messageSettingObj.put("SenderCode", "Anonymous");
						contextObj.put("MessageSetting", messageSettingObj);
					}
					
					for(Object fileArrayObj : fileArray) {
						CoviMap fileObj = (CoviMap) fileArrayObj;
						fileObj.put("RegisterCode", "Anonymous");
					}
				}
				
				contextObj.put("File", FileUtil.getFileTokenArray(fileArray));
				commentObj.put("Context", contextObj);
			}
		}
		
		resultList.put("list", commentArr);
		return resultList;
	}
	
	@Override
	public int selectCommentCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("common.control.comment.selectCommentCount", params);
	}
	
	@Override
	public int selectLikeCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("common.control.selectLike", params);
	}
	
	@Override
	public int selectReplyCount(int memberOf) throws Exception {
		return coviMapperOne.selectOne("common.control.comment.selectReplyCount", memberOf);
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public CoviMap insert(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		
		//context 정보 재정의
		CoviMap context = CoviMap.fromObject(params.get("context"));
		CoviList frontFileInfos = CoviList.fromObject(context.get("File"));
		CoviMap user = new CoviMap();
		//user.put("Photo", "http://www.no1.com/HtmlSite/smarts4j_n/covicore/resources/images/common/img.jpg"); //TODO 하드코딩을 제거하고 session의 photopath로 대체할 것
		user.put("Photo", SessionHelper.getSession("PhotoPath")); //TODO 하드코딩을 제거하고 session의 photopath로 대체할 것
		user.put("Name", SessionHelper.getSession("UR_Name"));
		user.put("Dept", SessionHelper.getSession("DEPTNAME"));
		user.put("JobLevel", SessionHelper.getSession("UR_JobLevelName"));
		user.put("JobTitle", SessionHelper.getSession("UR_JobTitleName"));
		user.put("JobPosition", SessionHelper.getSession("UR_JobPositionName"));		// 직위추가
		user.put("NickName", SessionHelper.getSession("UR_Name")); //TODO nick name으로 대체할 것
		context.put("User", user);
		params.put("context", context.toString());
		//Comment insert
		cnt = coviMapperOne.insert("common.control.comment.insert", params);
		String commentID = params.get("CommentID").toString();
		if(cnt > 0 || commentID != null){
			//File move
			CoviList backFileInfos = fileSvc.moveToBack(frontFileInfos, "comment/", "Comment", commentID, "NONE", "0");
			//context update
			context.put("File", FileUtil.getFileTokenArray(backFileInfos));
			
			int memberOf = Integer.parseInt(params.get("memberOf").toString());
			if(memberOf != 0){
				CoviMap replyCntUParam = new CoviMap();
				replyCntUParam.put("commentID", memberOf);
				
				coviMapperOne.update("common.control.comment.updateReplyCount", replyCntUParam);
			}
			
			
			CoviMap contextUParam = new CoviMap();
			contextUParam.put("context", context.toString());
			contextUParam.put("commentID", commentID);
			
			coviMapperOne.update("common.control.comment.updateContext", contextUParam);
			
			CoviMap selectOneParam = new CoviMap();
			selectOneParam.put("commentID", commentID);
			selectOneParam.put("folderType", params.has("folderType") == true ? params.get("folderType").toString() : "");	
			resultList = selectOne(selectOneParam);	
		}
		
		return resultList;
	}
	
	@Override
	public int insertLike(CoviMap params)throws Exception {
		int result = 0;
		int cnt = 0;
		String targetType = params.get("targetServiceType").toString();
		String targetID = params.get("targetID").toString();
		String registerCode = params.get("registerCode").toString();
		String menuCode = params.has("menuCode") == true ? params.get("menuCode").toString() : "";
		String folderType = params.has("folderType") == true ? params.get("folderType").toString() : "";
		//double check
		CoviMap selectOneParam = new CoviMap();
		selectOneParam.put("targetServiceType", targetType);
		selectOneParam.put("targetID", targetID);
		selectOneParam.put("menuCode", menuCode);
		selectOneParam.put("registerCode", registerCode);
		result = coviMapperOne.selectOne("common.control.selectMyLike", selectOneParam);
		
		if(result > 0){
			//result = -404;
			cnt = coviMapperOne.delete("common.control.deleteLike", params);
		} else {
			//like insert
			cnt = coviMapperOne.insert("common.control.insertLike", params);
			
			//TODO: 추천 알림
			if("Board".equals(targetType) && !"Anonymous".equals(folderType)){
				//통합게시 추천 게시글 정보 조회
				String sUserID = SessionHelper.getSession("USERID");
				String sdomainID = SessionHelper.getSession("DN_ID");
				CoviMap messageMap = coviMapperOne.select("common.control.selectLikeMessage", params);
				//MenuID, FolderID, MessageId, Version
				params.addAll(messageMap);
				
				String goToUrl = createMessageUrl(params);
				String mobileUrl = createMessageMobileUrl(params);
				params.put("ServiceType", targetType);
				params.put("MsgType", "Recommend");
				params.put("PopupURL", goToUrl);
				params.put("GotoURL", goToUrl);
				params.put("MobileURL", mobileUrl);
				//params.put("MessagingSubject", "[추천 알림]" + params.getString("Subject"));
				params.put("MessagingSubject", params.getString("Subject"));
				params.put("MessageContext", createMessageContext(params));
				//params.put("ReceiverText", "[추천 알림]" + params.getString("Subject"));
				params.put("ReceiverText", params.getString("Subject"));
				params.put("SenderCode", sUserID);
				params.put("RegistererCode", sUserID);
				params.put("ReceiversCode", params.getString("CreatorCode"));
				params.put("DomainID", sdomainID);
				params.put("ReservedStr1", params.getString("ReservedStr1"));
				MessageHelper.getInstance().createNotificationParam(params); 
				messageSvc.insertMessagingData(params);
			}
		}
		
		if(cnt > 0 && !targetID.contains("_")){
			selectOneParam.put("registerCode", null);
			result = coviMapperOne.selectOne("common.control.selectLike", selectOneParam);
			
			CoviMap likeCntUParam = new CoviMap();
			likeCntUParam.put("likeCount", result);
			likeCntUParam.put("commentID", targetID);
			
			coviMapperOne.update("common.control.comment.updateLikeCount", likeCntUParam);
		}else{
			result = coviMapperOne.selectOne("common.control.selectLike", selectOneParam);
		}
		
		return result;
	}
	
	@Override
	public CoviMap update(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		//menu update
		String menuID = params.get("menuID").toString();
		cnt = coviMapperOne.update("menu.updateMenu", params);
		if(cnt > 0){
			//acl update
			//delete all acl 
			CoviMap deleteAclParam = new CoviMap();
			deleteAclParam.put("objectID", menuID);
			deleteAclParam.put("objectType", "MN");
			coviMapperOne.delete("framework.authority.deleteACL", deleteAclParam);
			
			CoviMap selectOneParam = new CoviMap();
			selectOneParam.put("menuID", menuID);	
			
		}
		
		return resultList;
	}
	
	/**
	 * 데이터 삭제
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public CoviMap delete(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		int commentID = Integer.parseInt(params.get("commentID").toString());
		CoviMap deleteParam = new CoviMap();
		deleteParam.put("commentID", commentID);
		cnt = coviMapperOne.delete("common.control.comment.delete", deleteParam);
		
		if(cnt > 0){
			int memberOf = Integer.parseInt(params.get("memberOf").toString());
			if(memberOf != 0){
				CoviMap replyCntUParam = new CoviMap();
				replyCntUParam.put("commentID", memberOf);
				
				coviMapperOne.update("common.control.comment.updateReplyCount", replyCntUParam);
			}
			
			CoviMap selectOneParam = new CoviMap();
			selectOneParam.put("commentID", commentID);	
			selectOneParam.put("folderType", params.has("folderType") == true ? params.get("folderType").toString() : "");
			resultList = selectOne(selectOneParam);	
		}
		
		return resultList;
	}
	
	@Override
	public int selectMyLike(CoviMap params)throws Exception {
		int result = 0;
		String targetType = params.get("targetServiceType").toString();
		String targetID = params.get("targetID").toString();
		String registerCode = params.get("registerCode").toString();
		//double check
		CoviMap selectOneParam = new CoviMap();
		selectOneParam.put("targetServiceType", targetType);
		selectOneParam.put("targetID", targetID);
		selectOneParam.put("registerCode", registerCode);
		result = coviMapperOne.selectOne("common.control.selectMyLike", selectOneParam);
		
		return result;
	}
	
	//mobile
	
	@Override
	public CoviMap selectListAll(CoviMap params) throws Exception {
		params.put("UserCode", SessionHelper.getSession("USERID"));
		CoviList clist = coviMapperOne.list("common.control.comment.selectListAll", params);
		CoviList commentArr = CoviSelectSet.coviSelectJSON(clist, "CommentID,MemberOf,TargetServiceType,TargetID,Comment,Context,LikeCount,MyLikeCount,ReplyCount,RegisterCode,RegistDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,AnonymousAuthYn,Depth");
		
		for(Object obj : commentArr) {
			CoviMap commentObj = (CoviMap) obj;
			
			if(!commentObj.getString("Context").isEmpty()) {
				CoviMap contextObj = CoviMap.fromObject(commentObj.getString("Context"));								
				CoviList fileArray = contextObj.getJSONArray("File");
				
				// 익명 게시판의 댓글일 경우, 댓글을 작성한 사용자를 추적할 수 없도록 정보를 삭제
				if(params.has("folderType") && "Anonymous".equals(params.getString("folderType"))) {
					CoviMap commentUserInfo = CoviMap.fromObject(contextObj.getString("User"));
					commentUserInfo.put("Dept", "");
					commentUserInfo.put("JobLevel", "");
					commentUserInfo.put("JobPosition", "");
					commentUserInfo.put("JobTitle", "");					
					commentUserInfo.put("Name", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("NickName", DicHelper.getDic("lbl_Anonymity"));
					commentUserInfo.put("Photo", "");					
					contextObj.put("User", commentUserInfo);

					if(contextObj.has("MessageSetting")) {
						CoviMap messageSettingObj = CoviMap.fromObject(contextObj.getString("MessageSetting"));
						messageSettingObj.put("ReceiversCode", "Anonymous");
						messageSettingObj.put("RegistererCode", "Anonymous");
						messageSettingObj.put("SenderCode", "Anonymous");
						contextObj.put("MessageSetting", messageSettingObj);
					}
					
					for(Object fileArrayObj : fileArray) {
						CoviMap fileObj = (CoviMap) fileArrayObj;
						fileObj.put("RegisterCode", "Anonymous");
					}
				}
				
				contextObj.put("File", FileUtil.getFileTokenArray(fileArray));
				commentObj.put("Context", contextObj);
			}
		}
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", commentArr);
		
		return resultList;
	}
	
	public String createMessageUrl(CoviMap params){
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		
		ClientInfoHelper clientInfoHelper = new ClientInfoHelper();
		  
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");	
		}
		
		returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
		returnUrl += "?CLSYS=board&CLMD=user&CLBIZ=Board";
		returnUrl += String.format("&menuID=%s&version=%s&folderID=%s&messageID=%s", params.get("MenuID"), params.get("Version"), params.get("FolderID"), params.get("MessageID")) ;
		returnUrl += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
		if (!params.getString("menuCode").equals("")){	// 메뉴코드가 있는 경우 url에 포함
			returnUrl += "&menuCode="+params.getString("menuCode");
		}
		return returnUrl;
	}
	
	public String createMessageMobileUrl(CoviMap params){
		String returnUrl = "";

		//승인 요청 게시 메뉴 URL로 생성 else 게시 상세보기 URL생성
		if("ApprovalRequest_Board".equals(params.getString("MsgType"))){
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}//groupware/mobile/board/view.do
			returnUrl += "?menucode=BoardMain&boardtype=Total";
		} else {
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?boardtype=Normal";
			returnUrl += "&folderid=" + params.get("folderID");
			returnUrl += "&messageid=" + params.get("messageID");
			returnUrl += "&cuid=";
			returnUrl += "&version=1";
			returnUrl += "&page=1&searchtext=";
		}
		
		return returnUrl;
	}
	
	public String createMessageContext(CoviMap params){
		return params.getString("Subject");
//		String strHTML = "";	//알림 메일 본문
//		
//		strHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>";
//		strHTML += "<body>"
//				+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
//						+ "<tr>"
//						+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
//								+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
//										+ "<tr>"
//										+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
//										+ DicHelper.getDic("BizSection_" + params.getString("targetServiceType")) + "(" + params.get("targetServiceType") + ")"	//Title
//										+"</td>"
//										+ "</tr>"
//								+ "</table>"
//						+ "</td>"
//						+ "</tr>"
//						+ "<tr>"
//						+ "<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">"
//								+ "<!-- 문서현황 시작-->"
//								+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">"
//										+ "<tr>"
//										+ "<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">"
//												+ "<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">"
//												+ params.get("Subject")		//Context
//												+ "</span>"
//												+ " <br />"
//										+ "</td>"
//										+ "</tr>"
//								+ "</table>"
//						+ "</td>"
//						+ "</tr>";
//		
//		strHTML += "</table></td></tr>"
//				+ "<tr>"
//				+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">"
//						+ "<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
//								+ "<tr>"
//								+ "<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">"
//										+ "Title"
//								+ "</th>"
//								+ "<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">"
//										+ "<a href=\""+ params.get("GotoURL")	//URL : 페이지 연결 URL
//												+ "\" style=\"cursor: pointer;\">"
//										+ params.get("Subject")	//SUBJECT : 제목
//										+ "</a>"
//								+ "</td>"
//								+ "</tr>"
//						+ "</table>"
//				+ "</td>"
//				+ "</tr>"
//				+ "</table></td></tr>";
//		
//		strHTML += "</table></body></html>";
//		return strHTML;
	}
	/**
	 * 수정 시 데이터 Update
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public CoviMap updateComment(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		String commentID = params.getString("commentID");
		
		//context 정보 재정의
		CoviMap context = CoviMap.fromObject(params.get("context"));
		CoviList frontFileInfos = CoviList.fromObject(context.get("UploadFile"));
		CoviList existFileInfos = CoviList.fromObject(context.get("ExistFile"));
		CoviMap user = new CoviMap();
		user.put("Photo", SessionHelper.getSession("PhotoPath")); //TODO 하드코딩을 제거하고 session의 photopath로 대체할 것
		user.put("Name", SessionHelper.getSession("UR_Name"));
		user.put("Dept", SessionHelper.getSession("DEPTNAME"));
		user.put("JobLevel", SessionHelper.getSession("UR_JobLevelName"));
		user.put("JobTitle", SessionHelper.getSession("UR_JobTitleName"));
		user.put("JobPosition", SessionHelper.getSession("UR_JobPositionName"));		// 직위추가
		user.put("NickName", SessionHelper.getSession("UR_Name")); //TODO nick name으로 대체할 것
		context.put("User", user);
		
		params.put("context", context.toString());
		
		int cnt = coviMapperOne.update("common.control.comment.updateComment", params);
		
		if(cnt > 0 || commentID != null){
			List<MultipartFile> mfileList = new ArrayList<MultipartFile>();
			
			if(frontFileInfos.size() > 0) {
				for(int i = 0; i < frontFileInfos.size(); i++){
					CoviMap file = frontFileInfos.getJSONObject(i);
					String fileName = file.getString("FileName");
					String savedName = file.getString("SavedName");
					String frontAddPath = file.getString("FrontAddPath");
					
					if(!fileName.equals("") && !savedName.equals("")) {
						MultipartFile mf = FileUtil.makeMockMultipartFrontFile(fileName, frontAddPath + File.separator + savedName);
						mfileList.add(i, mf);
					}
				}
			}
			
			CoviList backFileInfos = fileSvc.uploadToBack(existFileInfos, mfileList, "comment/", "Comment", commentID, "NONE", "0");
			
			//context update
			context.put("File", FileUtil.getFileTokenArray(backFileInfos));
			context.remove("UploadFile");
			context.remove("ExistFile");
			
			CoviMap contextUParam = new CoviMap();
			contextUParam.put("context", context.toString());
			contextUParam.put("commentID", commentID);
			
			coviMapperOne.update("common.control.comment.updateContext", contextUParam);
		}
		
		CoviMap selectOneParam = new CoviMap();
		selectOneParam.put("commentID", params.get("commentID"));
		selectOneParam.put("folderType", params.has("folderType") == true ? params.get("folderType").toString() : "");
		resultList = selectOne(selectOneParam);	
		
		return resultList;
	}
	
	@Override
	public CoviMap selectSenderCode(CoviMap params)throws Exception {
		CoviMap SenderCode = new CoviMap();
		SenderCode.put("memberOf", params.get("memberOf"));
		
		CoviMap result = coviMapperOne.selectOne("common.control.comment.SelectSenderCode", SenderCode);
		return result;
	}
}
