package egovframework.covision.groupware.bizcard.user.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;

/**
 * @Class Name : BizCardGroupManageCon.java
 * @Description : 인명관리 그룹 CRUD 처리
 * @Modification Information 
 * @ 2017.07.31 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2017.07.31
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizcard")
public class BizCardGroupManageCon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(BizCardGroupManageCon.class);
	
	@Autowired
	private BizCardGroupManageService bizCardGroupManageService;
	
	@RequestMapping(value="CreateBizCardGroupPop.do", method=RequestMethod.GET)
	public ModelAndView CreateBizCardGroupPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("sharetype");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCardGroupPop";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="ModifyBizCardGroupPop.do", method=RequestMethod.GET)
	public ModelAndView ModifyBizCardGroupPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("sharetype");
		String strGroupID = request.getParameter("groupid");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCardGroupPop";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("GroupID", strGroupID);
		mav.addObject("UR_Code", strUR_Code);
		mav.addObject("mode", "modify");
		
		return mav;
	}
	
	@RequestMapping(value="RegistBizCardGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap RegistBizCardGroup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		int GroupId = 0;
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strShareType = request.getParameter("ShareType");
			String strGroupName = request.getParameter("GroupName");
			String strGroupPriorityOrder = request.getParameter("GroupPriorityOrder");
			String[] strGroupMember = request.getParameterValues("GroupMember[]") ;//  relaceAll("&quot;", "\"");;
			
			
			CoviMap params = new CoviMap();
			
			params.put("ShareType", strShareType);
			params.put("GroupName", strGroupName); 
			params.put("GroupPriorityOrder", strGroupPriorityOrder);
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			
			GroupId = bizCardGroupManageService.insertGroupId(params);
			if(GroupId > 0){
				if(strGroupMember != null){
					for(int i=0; i<strGroupMember.length; i++){
						String MemberData = strGroupMember[i].replaceAll("&quot;", "\"");
						
						JSONParser parser = new JSONParser();
						Object obj = parser.parse( MemberData );
						CoviMap jsonObj = (CoviMap) obj;
						
						String itemtype = (String)jsonObj.get("itemType");
						String code = (String)jsonObj.get("Code");
						String name = (String)jsonObj.get("Name");
						String email = (String)jsonObj.get("EM");
						params = new CoviMap();
						
						if(code != null && !code.equals("")){
							params.put("GroupID", Integer.toString(GroupId));
							params.put("ItemType", itemtype);
							params.put("Code", code);
							bizCardGroupManageService.insertBizcard_GroupPerson(params);
						}else{
							params.put("GroupID", Integer.toString(GroupId));
							params.put("Name", name);
							params.put("ShareType", strShareType);
							params.put("UR_Code", strUR_Code);
							params.put("DN_Code", strDN_Code);
							params.put("GR_Code", strGR_Code);				
							params.put("UR_Name", strUR_Name);					
							int BizCardID = bizCardGroupManageService.insertBizcard_Person(params);
							params = new CoviMap();
							params.put("BizCardID", Integer.toString(BizCardID));
							params.put("Email", email);
							bizCardGroupManageService.insertGroupMail(params);
						}
					}
				}
				
				returnObj.put("result", "OK");
			}else{
				returnObj.put("result", "EXIST");	
			}
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="UpdateBizCardGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap UpdateBizCardGroup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		int returnCnt = 0;
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strShareType = request.getParameter("ShareType");
			String strGroupName = request.getParameter("GroupName");
			String strGroupID = request.getParameter("GroupID");
			String strGroupPriorityOrder = request.getParameter("GroupPriorityOrder");
			String[] strGroupMember = request.getParameterValues("GroupMember[]") ;//  relaceAll("&quot;", "\"");;
			
			CoviMap params = new CoviMap();
			params.put("GroupID", strGroupID);
			params.put("ShareType", strShareType);
			params.put("GroupName", strGroupName); 
			params.put("GroupPriorityOrder", strGroupPriorityOrder);
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			
			returnCnt = bizCardGroupManageService.updateGroupId(params);
			
			if(returnCnt > 0){
				bizCardGroupManageService.deleteBizCard_GroupPerson(params);
				bizCardGroupManageService.deleteBizCard_Person(params);
				
				for(int i=0; i<strGroupMember.length; i++){
					String MemberData = strGroupMember[i].replaceAll("&quot;", "\"");
					
					JSONParser parser = new JSONParser();
					Object obj = parser.parse( MemberData );
					CoviMap jsonObj = (CoviMap) obj;
					
					String itemtype = (String)jsonObj.get("itemType");
					String code = (String)jsonObj.get("Code");
					String name = (String)jsonObj.get("Name");
					String email = (String)jsonObj.get("EM");
					String bizcardid = (String)jsonObj.get("BizCardID");
					
					params = new CoviMap();
					
					if(code != null && !code.equals("")){
						params.put("GroupID", strGroupID);
						params.put("ItemType", itemtype);
						params.put("Code", code);
						bizCardGroupManageService.insertBizcard_GroupPerson(params);
					}else{
						if(bizcardid != null && !bizcardid.equals("")){
							params.put("GroupID", strGroupID);
							params.put("ShareType", strShareType);
							params.put("BizCardID", bizcardid);
							bizCardGroupManageService.updateBizCard_Person(params);
						}
						else{
							params.put("GroupID", strGroupID);
							params.put("Name", name);
							params.put("ShareType", strShareType);
							params.put("UR_Code", strUR_Code);
							params.put("DN_Code", strDN_Code);
							params.put("GR_Code", strGR_Code);				
							params.put("UR_Name", strUR_Name);					
							int BizCardID = bizCardGroupManageService.insertBizcard_Person(params);
							params = new CoviMap();
							params.put("BizCardID", Integer.toString(BizCardID));
							params.put("Email", email);
							bizCardGroupManageService.insertGroupMail(params);	
						}
					}
				}
				returnObj.put("result", "OK");
			}else{
				returnObj.put("result", "EXIST");	
			}
			
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("result", "FAIL");
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="CreateBizCardGroup.do", method=RequestMethod.GET)
	public ModelAndView CreateBizCardGroup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("sharetype");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCardGroup";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="ModifyBizCardGroup.do", method=RequestMethod.GET)
	public ModelAndView ModifyBizCardGroup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("sharetype");
		String strGroupID = request.getParameter("groupid");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/CreateBizCardGroup";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("GroupID", strGroupID);
		mav.addObject("UR_Code", strUR_Code);
		mav.addObject("mode", "modify");
		
		return mav;
	}
	
	@RequestMapping(value="RegistGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap RegistGroup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strShareType = request.getParameter("ShareType");
			String strGroupName = request.getParameter("GroupName");
			String strGroupPriorityOrder = request.getParameter("GroupPriorityOrder");
			
			CoviMap params = new CoviMap();
			
			params.put("ShareType", strShareType);
			params.put("GroupName", strGroupName);
			params.put("GroupPriorityOrder", strGroupPriorityOrder);
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			
			returnObj = bizCardGroupManageService.insertGroup(params);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="ModifyGroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap ModifyGroup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String strGroupID = request.getParameter("GroupID");
			String strGroupName = request.getParameter("GroupName");
			String strGroupPriorityOrder = request.getParameter("GroupPriorityOrder");
			
			CoviMap params = new CoviMap();
			
			params.put("GroupID", strGroupID);
			params.put("GroupName", strGroupName);
			params.put("GroupPriorityOrder", strGroupPriorityOrder);
			
			returnObj = bizCardGroupManageService.updateGroup(params);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getGroupList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getGroupList(HttpServletRequest request) throws Exception {
		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		String strGR_Code = SessionHelper.getSession("GR_Code");
		String strDN_Code = SessionHelper.getSession("DN_Code");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		if(strShareType != null && !strShareType.isEmpty()) {
			if(strShareType.equals("P") || strShareType.equals("C")) {
				params.put("UR_Code", strUR_Code);
			}
			else if(strShareType.equals("D")) {
				params.put("GR_Code", strGR_Code);
			}
			else if(strShareType.equals("U")) {
				params.put("DN_Code", strDN_Code);
			}
		}
		
		CoviMap listData = bizCardGroupManageService.selectGroupList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value="getGroup.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getGroup(HttpServletRequest request) throws Exception {
		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		params.put("GroupID", strGroupID);
		
		CoviMap listData = bizCardGroupManageService.selectGroup(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizcardGroup.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getBizcardGroup(HttpServletRequest request) throws Exception {
		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
		String lang = SessionHelper.getSession("lang");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		params.put("GroupID", strGroupID);
		params.put("lang", lang);
		
		CoviMap listData = bizCardGroupManageService.selectBizcardGroup(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("list", listData.get("list"));
		returnObj.put("bizcardlist", listData.get("bizcardlist"));
		
		return returnObj;
	}

	@RequestMapping(value="getBizCardGroupPersonListPop.do", method=RequestMethod.GET)
	public ModelAndView getBizCardGroupPersonListPop(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("ShareType");
		String strGroupID = request.getParameter("GroupID");
		String strGroupName = request.getParameter("GroupName");
		String strPopupId = request.getParameter("PopupId");
		
		String returnUrl = "user/bizcard/SearchBizCardGroupPersonListPop";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("GroupID", strGroupID);
		mav.addObject("GroupName", strGroupName);
		mav.addObject("PopupId", strPopupId);
		
		return mav;
	}
	
	@RequestMapping(value="getBizCardGroupPersonList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardGroupPersonList(
			HttpServletRequest request,
			@RequestParam(value = "ShareType", required = false) String strShareType,
			@RequestParam(value = "GroupID", required = false) String strGroupID,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "1000000" ) int pageSize) throws Exception {
		
		strShareType = strShareType.isEmpty() ? null : strShareType;
		strGroupID = strGroupID.isEmpty() ? null : strGroupID;
		
		String sortBy = request.getParameter("sortBy");
		
		String sortKey = ( sortBy != null )? sortBy.split(" ")[0] : "Name";
		String sortDirec = ( sortBy != null )? sortBy.split(" ")[1] : "ASC";
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("pageSize", pageSize);
		params.put("pageNo", pageNo);
		params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
		
		params.put("ShareType", strShareType);
		params.put("GroupID", strGroupID);
		
		CoviMap listData = bizCardGroupManageService.selectGroupPersonList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		
		returnObj.put("page",listData.get("page")) ;
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		returnObj.put("status", Return.SUCCESS);
		
		return returnObj;
	}
}
