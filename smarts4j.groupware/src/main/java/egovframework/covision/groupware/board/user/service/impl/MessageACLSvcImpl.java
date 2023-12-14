package egovframework.covision.groupware.board.user.service.impl;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("MessageACLSvc")
public class MessageACLSvcImpl extends EgovAbstractServiceImpl implements MessageACLSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private MessageService messageSvc;
	
	/**
	 * @param params MessageID
	 * @description 열람권한  조회: sys_read_acl
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageReadAuthList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageReadAuthList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "TargetType,TargetCode,DisplayName"));
		return resultList;
	}
	
	
	
	@Override
	public int selectMessageReadAuthListCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectMessageReadAuthListCnt",params);
	}
	
	@Override
	public int selectMessageReadAuthCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.message.selectMessageReadAuthCount",params);
	}
	
	/**
	 * @param params MessageID, FolderID, 
	 * @description 상세권한  조회: board_message_acl
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageAuthList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageAuthList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "AclList,TargetType,TargetCode,DisplayName,Version,IsSubInclude,InheritedObjectID,GroupType,SortKey"));
		return resultList;
	}
	
	/**
	 * @param params MessageID, FolderID, GroupPath, UserCode
	 * @description 상세권한  조회: board_message_acl
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessageAclList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectMessageAclList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "TargetType,AclList,Security,Create,Delete,Modify,Execute,Read"));
		return resultList;
	}
	
	/**
	 * @param params MessageID, CommunityID, UserCode
	 * @description 커뮤니티 상세권한  조회: board_message_acl
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCommunityAclList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.message.selectCommunityAclList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "CreatorCode,OwnerCode,RegistDept,AclList,TargetType,TargetCode,DisplayName,Version,Security,Create,Delete,Modify,Execute,Read"));
		return resultList;
	}
	
	public CoviMap selectMessageInfo(CoviMap params) throws Exception {
		return coviMapperOne.select("user.message.selectMessageDetail", params);
	}
	
	//권한 요청
	@Override
	public int createRequestAuth(CoviMap params) throws Exception {
		int result = coviMapperOne.insert("user.message.createRequestAuth", params);
		
		if(result > 0){
			notifyRightRequest(params);
		}
		
		return result;
	}
	
	//권한 요청 승인/거부
	@Override
	public int updateRequestAuth(CoviMap params) throws Exception {
		//권한 요청 승인 했을때는 요청 권한에 대한 값을 board_message_acl에 반영
		if("A".equals(params.get("ActType"))){
			String aclList = "";
			CoviMap reqMap = coviMapperOne.select("user.message.selectRequestAclInfo", params);
			if(params.getString("CustomAcl").isEmpty()){
				aclList = reqMap.getString("AclList");
			} else {
				aclList = params.getString("CustomAcl");
			}
			String[] aclShard = aclList.split("(?!^)");
			params.put("targetCode", reqMap.get("TargetCode"));
			params.put("aclList", aclList);
			params.put("security", aclShard[0]);
			params.put("create", aclShard[1]);
			params.put("delete", aclShard[2]);
			params.put("modify", aclShard[3]);
			params.put("execute", aclShard[4]);
			params.put("read", aclShard[5]);
			
			int result = coviMapperOne.insert("user.message.updateRequestAuthInfo", params);
			
			if(result > 0) {
				notifyRightAccepted(params);
			}
		}
		return coviMapperOne.insert("user.message.updateRequestAuth", params);
	}
	
	public CoviMap selectRequestAclDetail(CoviMap params) throws Exception{
		return coviMapperOne.select("user.message.selectRequestAclDetail", params);
	}
	
	@Override
	public int selectUserSecurityLevel(CoviMap params) throws Exception{
		return (int) coviMapperOne.getNumber("user.message.selectUserSecurityLevel", params);
	}
	
	@Override
	public String selectFolderOwnerCode(CoviMap params) throws Exception{
		String returnStr = coviMapperOne.getString("user.message.selectFolderOwnerCode", params);
		if (returnStr == null) returnStr = "";
		return returnStr;
	}
	
	@Override
	public int selectDocAuthCnt(CoviMap params) throws Exception{
		return (int) coviMapperOne.getNumber("user.message.selectDocAuthCnt", params);
	}

	@Override
	public int selectApprovalCnt(CoviMap params) throws Exception{
		return (int) coviMapperOne.getNumber("user.message.selectApprovalCnt", params);
	}
	
	@Override
	public int checkDuplicateRequest(CoviMap params) throws Exception{
		return (int) coviMapperOne.getNumber("user.message.checkDuplicateRequest", params);
	}
	
	//pType : TargetType, ObjectType acl테이블의 컬럼명
	//pShard: Security, Create, Delete, Modify, Read ( board_message_acl 기준 으로 5개의 권한 컬럼만 사용 ) 
	/**
	 * ACL 정보 파싱하여 권한 여부 확인
	 * @param pType
	 * @param pShard
	 * @param pArray
	 * @return
	 */
	@Override
	public boolean checkAclShard(String pType, String pShard, CoviList pArray) throws Exception{
		boolean bFlag = false;
		for(int i = 0; i < pArray.size(); i++){
			CoviMap aclObj = pArray.getJSONObject(i);
			
			if("UR".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
				break;
			} else if("DN".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			} else if("CM".equals(aclObj.getString(pType))){
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			} else {
				bFlag = aclObj.getString("AclList").indexOf(pShard)!=-1?true:false;
			}
		}
		return bFlag;
	}
	
	// 통합알림 - 문서권한 > 승인 요청
	public void notifyRightRequest(CoviMap params) throws Exception{
		CoviMap notiParams = coviMapperOne.select("user.message.selectMessageInfo", params);
		notiParams.put("ServiceType", "Doc");
		notiParams.put("MsgType", "RightRequest"); // 문서권한 승인 요청
		params.addAll(notiParams);
		
		String goToUrl = createMessageUrl(params);
		
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", createMessageMobileUrl(params));
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));			// 요청자
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("ownerCode"));		// 승인자
		
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}

	// 통합알림 - 문서권한 > 승인 완료
	public void notifyRightAccepted(CoviMap params) throws Exception{
		CoviMap notiParams = coviMapperOne.select("user.message.selectMessageInfo", params);
		notiParams.put("ServiceType", "Doc");
		notiParams.put("MsgType", "RightAccepted"); // 문서권한 승인 완료
		params.addAll(notiParams);
		
		String goToUrl = createMessageUrl(params);
		
		notiParams.put("PopupURL", goToUrl);
		notiParams.put("GotoURL", goToUrl);
		notiParams.put("MobileURL", createMessageMobileUrl(params));
		notiParams.put("MessagingSubject", params.getString("subject"));
		notiParams.put("MessageContext", createMessageContext(params));
		notiParams.put("ReceiverText", params.getString("subject"));
		notiParams.put("SenderCode", params.getString("userCode"));			// 승인자
		notiParams.put("RegistererCode", params.getString("userCode"));
		notiParams.put("ReceiversCode", params.getString("targetCode"));	// 요청자
		
		MessageHelper.getInstance().createNotificationParam(notiParams);
		messageSvc.insertMessagingData(notiParams);
	}

	public String createMessageUrl(CoviMap params){
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		
		String returnUrl = "";
		
		if(ClientInfoHelper.isMobile(request)){
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");			// Domain
		}else{
			returnUrl += PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");	
		}
		
		// 승인 요청 시에는 승인 목록으로 승인 완료 시에는 게시물로 이동
		if(params.getString("MsgType").equals("RightRequest")){
			returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardList.do");	// {Domain}/groupware/layout/board_BoardList.do
			returnUrl += "?CLSYS=doc&CLMD=user&CLBIZ=Doc";
			returnUrl += String.format("&boardType=DocAuth&menuID=%s", params.get("menuID"));
		}else{
			returnUrl += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
			returnUrl += "?CLSYS=doc&CLMD=user&CLBIZ=Doc";
			returnUrl += String.format("&menuID=%s&version=1&folderID=%s&messageID=%s", params.get("menuID"), params.get("folderID"), params.get("messageID")) ;
			returnUrl += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
		}
		
		return returnUrl;
	}

	public String createMessageMobileUrl(CoviMap params){
		String returnUrl = "";
		
		// 승인 요청 시에는 승인 목록으로 승인 완료 시에는 게시물로 이동
		if(params.getString("MsgType").equals("RightRequest")){
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "doc", "list.do");	// {Domain}/groupware/mobile/doc/list.do
			returnUrl += "?menucode=DocMain&boardtype=DocAuth";
		}else{
			returnUrl += String.format("/%s/%s/%s/%s","groupware", "mobile", "board", "view.do");	// {Domain}/groupware/mobile/board/view.do
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
		String strHTML = "";	// 알림 메일 본문
		
		strHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>";
		strHTML += "<body>"
			+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
				+ "<tr>"
				+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
					+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
						+ "<tr>"
						+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
						+ DicHelper.getDic("BizSection_" + params.getString("bizSection")) + "(" + params.get("bizSection") + ")"	//Title
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
							+ params.get("subject")		//Context
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
						+ params.get("subject")	//SUBJECT : 제목
						+ "</a>"
					+ "</td>"
					+ "</tr>"
				+ "</table>"
			+ "</td>"
			+ "</tr>"
			+ "</table></td></tr>";
		
		strHTML += "</table></body></html>";
		return strHTML;
	}
}
