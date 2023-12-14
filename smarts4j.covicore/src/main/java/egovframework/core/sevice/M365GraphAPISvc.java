package egovframework.core.sevice;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;


public interface M365GraphAPISvc {
	public void setOAuthToken() throws Exception;
	
	
	public CoviList selectTeamList(String authToken) throws Exception;
	public CoviList selectChannelList(String authToken, String teamid) throws Exception;
	public CoviList selectTeamMemberList(String authToken, String teamid) throws Exception;
	public CoviList selectPresence(String authToken, String userCodes, String aadObjectIds) throws Exception;
	
	public void createTeam(String authToken, String displayName, String description) throws Exception;
	public void updateTeam(String authToken, String teamid, String displayName, String description) throws Exception;
	public void createChannel(String authToken, String teamid, String displayName, String description) throws Exception;
	public void updateChannel(String authToken, String teamid, String channelid, String displayName, String description) throws Exception;
	public CoviList addTeamMember(String authToken, String teamid, String userCodes) throws Exception;
	public CoviList deleteTeamMember(String authToken, String teamid, String membershipIds) throws Exception;
	
	
	public String selectUnreadMailCount() throws Exception;
	public String selectTodayCalendarCount() throws Exception;
	
}
