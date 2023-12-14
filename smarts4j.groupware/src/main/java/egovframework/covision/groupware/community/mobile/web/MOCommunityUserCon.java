package egovframework.covision.groupware.community.mobile.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import egovframework.covision.groupware.util.BoardUtils;


@Controller
@RequestMapping("/mobile/community/")
public class MOCommunityUserCon {
	
	@Autowired
	CommunityUserSvc communitySvc;
	
	@Autowired
	MessageSvc boardMessageSvc;
	
	@Autowired
	PortalSvc portalSvc;
	
	@Autowired
	private MessageService messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	@RequestMapping(value = "communityNotice.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityNotice(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			params.put("bizSection", request.getParameter("bizSection"));

			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", "V");
			if(authorizedObjectCodeSet.size() < 1) {
				authorizedObjectCodeSet.add("-1");
			}
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr",objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			
			if (ClientInfoHelper.isMobile(request)) {
				params.put("IsMobileSupport", "Y");
			}
			
			/*내가 가입한 커뮤니티 중 공지 게시판의 cnt*/
			int cnt = communitySvc.selectCommunityNoticeCnt(params);
			
			CoviMap page = new CoviMap();
			String pageNo = request.getParameter("page");
			String pageSize = request.getParameter("pageSize");
			int nPageNo = Integer.parseInt(pageNo);
			int nPageSize = Integer.parseInt(pageSize);
			params.put("pageNo", nPageNo);
			params.put("pageSize", nPageSize);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			
			if(cnt > 0){
				resultList = communitySvc.selectCommunityNotice(params);
				returnData.put("cnt",cnt);
				returnData.put("totalCnt",resultList.get("totalCnt"));
				returnData.put("list", resultList.get("list"));
			}else{
				returnData.put("cnt",cnt);
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
	
	
	@RequestMapping(value = "communitySelectNotice.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communitySelectNotice(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("lang",SessionHelper.getSession("lang"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", "V");
			if(authorizedObjectCodeSet.size() < 1) {
				authorizedObjectCodeSet.add("-1");
			}
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr",objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");	
			
			if (ClientInfoHelper.isMobile(request)) {
				params.put("IsMobileSupport", "Y");
			}
			
			int cnt = 0;
			cnt = communitySvc.selectCommunitySelectNoticeCount(params);
				
			params.addAll(ComUtils.setPagingData(params,cnt));	
				
			resultList = communitySvc.selectCommunitySelectNoticeList(params);
			
			returnData.put("pageSize", params.get("pageSize"));
			returnData.put("pageCount", params.get("pageCount"));
			
			returnData.put("cnt",cnt);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "communityLeft.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityLeft(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultHeaderList = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		CoviList result = new CoviList();
		
		boolean flag = true;
		String checkValue = "";
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("lang",SessionHelper.getSession("lang"));
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr",objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("userCode", SessionHelper.getSession().get("USERID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Community");
			
			flag = communityUserInfoCheck(params);
			
			if (ClientInfoHelper.isMobile(request)) {
				params.put("IsMobileSupport", "Y");
			}
					
			result = (CoviList) communitySvc.selectCommunityBoardLeft(params).get("list");
			for(Object jsonobject : result){
				CoviMap folderData = new CoviMap();
				folderData = (CoviMap) jsonobject;
				// 트리를 그리기 위한 데이터
				folderData.put("no", StringUtil.getSortNo(folderData.get("SortPath").toString()));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", StringUtil.getParentSortNo(folderData.get("SortPath").toString()));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				 
				resultList.add(folderData);
			}
			
			if(communityUserInfoCheck(params)){
				resultHeaderList =  communitySvc.selectCommunityHeaderSettingList(params);
			}
			
			CoviMap communityInfo = communitySvc.selectCommunityInfo(params);

			checkValue =  communitySvc.selectCommunityUserLevelCheck(params);
			
			returnData.put("communityName", communityInfo.getString("CommunityName"));
			returnData.put("memberLevel", checkValue);
			returnData.put("flag", flag);
			returnData.put("list", resultList);
			returnData.put("headerList", resultHeaderList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}

	@RequestMapping(value = "communityHeaderSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityHeaderSetting(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultListHead = new CoviMap();
		CoviMap resultListSub = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("CU_ID", params.getString("communityID") );
			
			resultListHead = communitySvc.selectcommunityHeaderSetting(params);
			resultListSub = communitySvc.communitySubHeaderSetting(params);
			
			returnData.put("headlist", resultListHead.get("list"));
			returnData.put("sublist", resultListSub.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}

	@RequestMapping(value = "communityJoinInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityJoinInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviMap resultUser = new CoviMap();
		CoviMap resultCommunity = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("CU_ID", request.getParameter("CU_ID"));
			
			resultUser = communitySvc.selectCommunityJoinUserInfo(params);
			resultCommunity = communitySvc.selectCommunityDetailInfo(params);
			
			returnData.put("userInfo", resultUser.get("list"));
			returnData.put("communityInfo", resultCommunity.get("list"));
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
	
	public boolean communityUserInfoCheck(CoviMap params){
		StringUtil func = new StringUtil();
		
		try {
			String checkValue = communitySvc.selectCommunityUserLevelCheck(params);
			if(!func.f_NullCheck(checkValue).equals("") && !func.f_NullCheck(checkValue).equals("0")){
				return true;
			}else{
				return false;
			}
			
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
		
	}

	@RequestMapping(value = "selectCommunityMemberInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityMemberInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultMemberInfo = new CoviMap();
		CoviMap resultBoardRankInfo = new CoviMap();
		CoviMap resultVisitRankInfo = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);

			String pageNo = request.getParameter("page");
			String pageSize = request.getParameter("pageSize");
			
			int nPageNo = Integer.parseInt(pageNo);
			int nPageSize = Integer.parseInt(pageSize);
			
			int cnt = communitySvc.selectCommunityMemberGridListCount(params);
			
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("pageNo", nPageNo);
			params.put("pageSize", nPageSize);
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultMemberInfo = communitySvc.selectCommunityMemberGridList(params);
			resultBoardRankInfo = communitySvc.selectCommunityBoardRankInfo(params);
			resultVisitRankInfo = communitySvc.selectCommunityVisitRankInfo(params);
			
			returnData.put("cnt", cnt);
			returnData.put("page", params);
			returnData.put("memberInfo", resultMemberInfo.get("list"));
			returnData.put("boardRankInfo", resultBoardRankInfo.get("list"));
			returnData.put("visitRankInfo", resultVisitRankInfo.get("list"));
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
	
	@RequestMapping(value = "selectUserCommunityGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserCommunityGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UR_Code",SessionHelper.getSession("USERID"));
			
			int cnt = communitySvc.selectUserCommunityGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectUserCommunityGridList(params);
			
			returnData.put("cnt", cnt);
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

	@RequestMapping(value = "selectCommunityAllianceGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityAllianceGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			
			params.put("isSaaS", isSaaS);
			
			int cnt = communitySvc.selectCommunityAllianceGridListCount(params);
			
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityAllianceGridList(params);
			
			returnData.put("cnt", cnt);
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
	
	@RequestMapping(value = "selectUserJoinCommunity.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserJoinCommunity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//JSONObject resultList = new CoviMap();
		CoviList resultList = new CoviList();
		CoviList result = new CoviList();
		
		try {
			CoviMap params = new CoviMap();

			params.put("UR_CODE", SessionHelper.getSession("USERID"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			
			//resultList = communitySvc.selectUserJoinCommunity(params);
			result = (CoviList)communitySvc.selectUserJoinCommunity(params).get("list");
						
			for(Object jsonobject : result){
				CoviMap tempobj = new CoviMap();
				String strDisplayName = "";
				tempobj = (CoviMap) jsonobject;
				tempobj.put("optionValue", tempobj.get("optionValue"));
				tempobj.put("optionText", tempobj.get("optionText"));
				tempobj.put("FilePath", tempobj.get("FilePath"));				
				resultList.add(tempobj);
			}
						
			returnData.put("list", resultList);
			
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
	
	@RequestMapping(value = "selectCommunityTreeData.do" )
	public  @ResponseBody CoviMap selectCommunityTreeData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap params = new CoviMap();
		
		params.put("DN_ID", SessionHelper.getSession("DN_ID"));
		
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		CoviMap returnList = new CoviMap();
		
		result = (CoviList) communitySvc.selectCommunityTreeData(params).get("list");
		
		for(Object jsonobject : result){
			CoviMap folderData = new CoviMap();
			folderData = (CoviMap) jsonobject;
			
			String strDisplayName = "";
			strDisplayName = DicHelper.getDic(Integer.parseInt(params.get("DN_ID").toString()), "CUCT_"+folderData.get("FolderID"));
			strDisplayName = strDisplayName.equals("CUCT_"+folderData.get("FolderID")) ? folderData.get("DisplayName").toString() : strDisplayName;
			
			// 트리를 그리기 위한 데이터
			folderData.put("DisplayName", strDisplayName);
			folderData.put("no", StringUtil.getSortNo(folderData.get("SortPath").toString()));
			folderData.put("nodeName", strDisplayName);
			folderData.put("nodeValue", folderData.get("FolderID"));
			folderData.put("pno", StringUtil.getParentSortNo(folderData.get("SortPath").toString()));
			folderData.put("chk", "N");
			folderData.put("rdo", "N");
			//folderData.put("url", "javascript:selectCommunityTreeListByTree(\"" + folderData.get("FolderID") + "\", \"" + folderData.get("FolderType") + "\", \"" + folderData.get("FolderPath") + "\", \"" + folderData.get("FolderName") + "\" );");
			
			resultList.add(folderData);			
		}
		
		returnList.put("list", resultList);
		returnList.put("result", "ok");
		
		return returnList;
	}
	
	@RequestMapping(value = "communityUserJoin.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityUserJoin(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("RegMessage", request.getParameter("RegMessage") );
			params.put("MailAddress", request.getParameter("MailAddress") );
			params.put("NickName", request.getParameter("NickName") );
			params.put("CU_ID", request.getParameter("CU_ID") );
			
			if(communitySvc.selectCommunityMemberDuplyCnt(params) > 0){
				if(func.f_NullCheck(request.getParameter("JoinOption")).equals("A")){
					//즉시 승인.
					if(!communitySvc.communityJoinProcess(params,"CC")){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}else{
					//승인
					if(!communitySvc.communityJoinProcess(params,"PP")){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}
			}else{
				if(func.f_NullCheck(request.getParameter("JoinOption")).equals("A")){
					//즉시 승인.
					if(!communitySvc.communityUserJoin(params,request.getParameter("JoinOption"))){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}else{
					//승인
					if(!communitySvc.communityUserJoin(params,request.getParameter("JoinOption"))){
						returnData.put("status", Return.FAIL);
						return returnData;
					}
				}
			}
			
			//가입요청 시 알림처리 추가
			List list = new ArrayList();
			
			if(!func.f_NullCheck( request.getParameter("JoinOption")).equals("A")){
				list = communitySvc.sendMessagingCommunityOperator(params);
				
				if(list.size() > 0){
					CoviMap FolderParams = new CoviMap();
					
					for(int j = 0; j < list.size(); j ++){
						FolderParams = (CoviMap) list.get(j);
						
						FolderParams.put("Category", "Community");
						FolderParams.put("Code", "JoiningRequest");
						FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" "+request.getParameter("NickName") +" 가입요청 알림.");
						FolderParams.put("Message", FolderParams.get("CommunityName")+" "+request.getParameter("NickName") +" 가입요청 하였습니다.");
						FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
						FolderParams.put("MobileURL", "/groupware/mobile/community/portal.do?menucode=CommunityMain");
						notifyCommunityAlarm(FolderParams);
					}
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}
		
		return returnData;
	}
	
	@RequestMapping(value = "selectCommunityLeaveInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityLeaveInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
		
			BoardUtils.setRequestParam(request, params);
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			
			params.put("lang",SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityLeaveInfo(params);
			
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
	
	@RequestMapping(value = "communityMemberLeave.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap communityMemberLeave(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("UR_Code", SessionHelper.getSession("USERID"));
			params.put("CU_ID", request.getParameter("CU_ID") );
			params.put("LeaveMessage", request.getParameter("LeaveMessage") );
			params.put("isForce", "false");
			
			//즉시 승인.
			if(!communitySvc.communityMemberLeave(params)){
				returnData.put("status", Return.FAIL);
				return returnData;
			}
			
			returnData.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
		}

		return returnData;
	}
	
	@RequestMapping(value = "selectCommunityInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCommunityInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("CU_ID",request.getParameter("CU_ID"));
			params.put("UR_Code", SessionHelper.getSession("USERID") );
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCommunityDetailInfo(params);
			
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
	
	@RequestMapping(value = "setCurrentLocation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCurrentLocation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("CategoryID",request.getParameter("CategoryID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultList = communitySvc.selectCurrentLocation(params);
			
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
	
	
	
	//커뮤니티 알림 메시지 Parameter 셋팅
	private void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
    	CoviMap notiParam = new CoviMap();
    	notiParam.put("ObjectType", "CU");
    	notiParam.put("ServiceType", "Community");
    	notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
    	notiParam.put("PopupURL", pNotifyParam.getString("URL"));
    	notiParam.put("GotoURL", pNotifyParam.getString("URL"));
    	notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
    	notiParam.put("OpenType", "PAGEMOVE");									//페이지 이동 처리
    	notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
    	notiParam.put("MessageContext", pNotifyParam.get("Message"));
    	notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
    	notiParam.put("SenderCode", SessionHelper.getSession("USERID"));		//송신자 (세션 값 참조)
    	notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
    	notiParam.put("ReceiversCode", pNotifyParam.getString("UserCode"));		//조회된 수신자 코드
		MessageHelper.getInstance().createNotificationParam(notiParam);
		messageSvc.insertMessagingData(notiParam);
    }
	
}
