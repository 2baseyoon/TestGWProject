package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.M365GraphAPISvc;
import egovframework.coviframework.base.TokenHelper;


@Controller
@RequestMapping("/m365")
public class M365GraphAPICon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(M365GraphAPICon.class);
	
	@Autowired
	private M365GraphAPISvc m365GraphAPISvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	@RequestMapping(value="setOAuthToken.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap setOAuthToken(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			m365GraphAPISvc.setOAuthToken();
			
			// 결과 반환
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("setOAuthToken Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("setOAuthToken Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	

	@RequestMapping(value="selectTeamList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectTeamList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			CoviList resultList = m365GraphAPISvc.selectTeamList(authToken);
			
			// 결과 반환
			returnObj.put("list", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamList Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamList Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamList Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}

	@RequestMapping(value="selectChannelList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectChannelList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String teamid = request.getParameter("teamid");
			CoviList resultList = m365GraphAPISvc.selectChannelList(authToken, teamid);
			
			// 결과 반환
			returnObj.put("list", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectChannelList Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectChannelList Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectChannelList Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}

	@RequestMapping(value="selectTeamMemberList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectTeamMemberList(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String teamid = request.getParameter("teamid");
			CoviList resultList = m365GraphAPISvc.selectTeamMemberList(authToken, teamid);
			
			// 결과 반환
			returnObj.put("list", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamMemberList Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamMemberList Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamMemberList Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}

	@RequestMapping(value="selectPresence.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectPresence(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = StringUtil.replaceNull(request.getParameter("authToken"), "");
			String userCodes = StringUtil.replaceNull(request.getParameter("userCodes"), "");
			String aadObjectIds = StringUtil.replaceNull(request.getParameter("aadObjectIds"), "");
			CoviList resultList = m365GraphAPISvc.selectPresence(authToken, userCodes, aadObjectIds);
			
			// 결과 반환
			returnObj.put("list", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectPresence Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectPresence Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectPresence Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="createTeam.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createTeam(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String displayName = request.getParameter("displayName");
			String description = request.getParameter("description");
			m365GraphAPISvc.createTeam(authToken, displayName, description);
			
			// 결과 반환
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("createTeam Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("createTeam Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}

	@RequestMapping(value="updateTeam.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateTeam(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String teamid = request.getParameter("teamid");
			String displayName = request.getParameter("displayName");
			String description = request.getParameter("description");
			m365GraphAPISvc.updateTeam(authToken, teamid, displayName, description);
			
			// 결과 반환
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("updateTeam Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("updateTeam Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="createChannel.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createChannel(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String teamid = request.getParameter("teamid");
			String displayName = request.getParameter("displayName");
			String description = request.getParameter("description");
			m365GraphAPISvc.createChannel(authToken, teamid, displayName, description);
			
			// 결과 반환
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("createChannel Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("createChannel Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="updateChannel.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateChannel(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = request.getParameter("authToken");
			String teamid = request.getParameter("teamid");
			String channelid = request.getParameter("channelid");
			String displayName = request.getParameter("displayName");
			String description = request.getParameter("description");
			m365GraphAPISvc.updateChannel(authToken, teamid, channelid, displayName, description);
			
			// 결과 반환
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("updateChannel Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("updateChannel Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="addTeamMember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addTeamMember(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = StringUtil.replaceNull(request.getParameter("authToken"), "");
			String teamid = StringUtil.replaceNull(request.getParameter("teamid"), "");
			String userCodes = StringUtil.replaceNull(request.getParameter("userCodes"), "");
			CoviList resultList = m365GraphAPISvc.addTeamMember(authToken, teamid, userCodes);
			
			// 결과 반환
			returnObj.put("failList", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("addTeamMember Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("addTeamMember Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("addTeamMember Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}

	@RequestMapping(value="deleteTeamMember.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteTeamMember(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String authToken = StringUtil.replaceNull(request.getParameter("authToken"), "");
			String teamid = StringUtil.replaceNull(request.getParameter("teamid"), "");
			String membershipIds = StringUtil.replaceNull(request.getParameter("membershipIds"), "");
			CoviList resultList = m365GraphAPISvc.deleteTeamMember(authToken, teamid, membershipIds);
			
			// 결과 반환
			returnObj.put("failList", resultList);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("deleteTeamMember Failed [" + e.getMessage() + "]", e);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("deleteTeamMember Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("deleteTeamMember Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="selectTeamsSLOToken.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap selectTeamsSLOToken(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			TokenHelper tokenHelper = new TokenHelper();
			
			String date = "1";
			String token = tokenHelper.setTokenString(SessionHelper.getSession("LogonID"),date,"",SessionHelper.getSession("lang"),"",SessionHelper.getSession("DN_Code"),SessionHelper.getSession("UR_EmpNo"),"",SessionHelper.getSession("UR_Name"),SessionHelper.getSession("UR_Mail"),"","","",SessionHelper.getSession("DN_ID"));
			
			returnObj.put("token", token);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamsSLOToken Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("selectTeamsSLOToken Failed [" + e.getMessage() + "]", e);   
		}

		return returnObj;
	}

	
	
	@RequestMapping(value="getUnreadMailCount.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getUnreadMailCount(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String cnt = m365GraphAPISvc.selectUnreadMailCount();
			
			// 결과 반환
			returnObj.put("cnt", cnt);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("getUnreadMailCount Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("getUnreadMailCount Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getTodayCalendarCount.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getTodayCalendarCount(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			String cnt = m365GraphAPISvc.selectTodayCalendarCount();
			
			// 결과 반환
			returnObj.put("cnt", cnt);
			returnObj.put("result", "ok");		
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("getTodayCalendarCount Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			returnObj.put("result", "error");		
			returnObj.put("status", Return.FAIL);	
			returnObj.put("message", e.getMessage());
			LOGGER.error("getTodayCalendarCount Failed [" + e.getMessage() + "]", e);
		}
		
		return returnObj;
	}
	
}
