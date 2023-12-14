package egovframework.core.sevice.impl;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import javax.annotation.Resource;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.io.IOUtils;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.M365GraphAPISvc;
import egovframework.coviframework.util.SessionCommonHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("m365GraphAPISvc")
public class M365GraphAPISvcImpl extends EgovAbstractServiceImpl implements M365GraphAPISvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public void setOAuthToken() throws Exception {
		CoviList selList = coviMapperOne.list("m365.getOAuthTargetList", null);
		if(selList.size() > 0) {
			CoviMap target = new CoviMap();
			CoviMap oauthinfo = new CoviMap();
			CoviMap params = new CoviMap();
			java.time.LocalDateTime currentTime = null;
			String expireDateTime = "";
	        for (int i = 0; i < selList.size(); i++) {
				target = selList.getJSONObject(i);
				
				oauthinfo = getAccessToken_Application(target);

				currentTime = java.time.LocalDateTime.now();
				currentTime = currentTime.plusHours(1);
				expireDateTime = currentTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
				
		        params = new CoviMap();
		        params.put("scope", target.get("Scope").toString());
		        params.put("dn_id", target.get("DN_ID").toString());
		        params.put("accessToken", oauthinfo.get("AccessToken").toString());
		        params.put("expireDateTime", expireDateTime);
		        
				coviMapperOne.update("m365.updateOAuthToken", params);
	        }
		}
	}
	

	@Override
	public CoviList selectTeamList(String authToken) throws Exception {
    	CoviList returnList = new CoviList();
		        
		String userPrincipalName = SessionHelper.getSession("LogonID") + "@" + RedisDataUtil.getBaseConfig("M365Domain");
        String graphURL = "https://graph.microsoft.com/v1.0/users/" + userPrincipalName + "/ownedObjects";
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "GET");
        GraphParams.put("body", "");
        
        String response = callGraphAPI_Delegated(GraphParams);
						
		CoviMap resultObj = CoviMap.fromObject(response);
		
		CoviList resultList = resultObj.getJSONArray("value");
		
		for(int i=0; i<resultList.size(); i++){
			CoviMap tmp = new CoviMap();
			CoviMap tmpObj = CoviMap.fromObject(resultList.getJSONObject(i));
			
			if (tmpObj.getString("resourceProvisioningOptions").toUpperCase().indexOf("\"TEAM\"") > -1) {
				tmp.put("id", tmpObj.getString("id"));
				tmp.put("displayName", tmpObj.getString("displayName"));
				tmp.put("description", tmpObj.getString("description"));
				
				returnList.add(tmp);
			}
		}
	
		return returnList;
	}

	@Override
	public CoviList selectChannelList(String authToken, String teamid) throws Exception {
    	CoviList returnList = new CoviList();
		        
        String graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/channels";
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "GET");
        GraphParams.put("body", "");
        
        String response = callGraphAPI_Delegated(GraphParams);
						
		CoviMap resultObj = CoviMap.fromObject(response);
		
		CoviList resultList = resultObj.getJSONArray("value");
		
		for(int i=0; i<resultList.size(); i++){
			CoviMap tmp = new CoviMap();
			CoviMap tmpObj = CoviMap.fromObject(resultList.getJSONObject(i));
			
			if (!"GENERAL".equals(tmpObj.getString("displayName").toUpperCase())) {
				tmp.put("id", tmpObj.getString("id"));
				tmp.put("displayName", tmpObj.getString("displayName"));
				tmp.put("description", tmpObj.getString("description"));
				
				returnList.add(tmp);
			}
		}
	
		return returnList;
	}
	
	@Override
	public CoviList selectTeamMemberList(String authToken, String teamid) throws Exception {
    	CoviList returnList = new CoviList();
		        
        String graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/members";
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "GET");
        GraphParams.put("body", "");
        
        String response = callGraphAPI_Delegated(GraphParams);
						
		CoviMap resultObj = CoviMap.fromObject(response);
		
		CoviList resultList = resultObj.getJSONArray("value");
		CoviMap tmp = null;
		CoviMap tmpObj = null;
		CoviMap userParams = null;
		CoviMap userInfo = null;
		for(int i=0; i<resultList.size(); i++){
			
			tmpObj = CoviMap.fromObject(resultList.getJSONObject(i));

			userParams = new CoviMap();
			userParams.put("userCode", "");
			userParams.put("userPrincipalName", "");
			userParams.put("aadObjectId", tmpObj.getString("userId"));
			userParams.put("lang", SessionHelper.getSession("lang"));
						
			userInfo = coviMapperOne.select("m365.getUserInfo", userParams);
			
			tmp = new CoviMap();
			tmp.put("id", tmpObj.getString("id"));
			tmp.put("userId", tmpObj.getString("userId"));
			tmp.put("email", tmpObj.getString("email"));
			tmp.put("roles", tmpObj.getString("roles"));
			if (userInfo.size() > 0) {
				tmp.put("usercode", userInfo.getString("UserCode"));				
				tmp.put("displayName", userInfo.getString("DisplayName"));
				tmp.put("companyName", userInfo.getString("CompanyName"));
				tmp.put("deptName", userInfo.getString("DeptName"));
				tmp.put("regionName", userInfo.getString("RegionName"));
				tmp.put("jobPositionName", userInfo.getString("JobPositionName"));
				tmp.put("jobTitleName", userInfo.getString("JobTitleName"));
				tmp.put("jobLevelName", userInfo.getString("JobLevelName"));
			} else {
				tmp.put("usercode", "");				
				tmp.put("displayName", tmpObj.getString("displayName"));
				tmp.put("companyName", "");
				tmp.put("deptName", "");
				tmp.put("regionName", "");
				tmp.put("jobPositionName", "");
				tmp.put("jobTitleName", "");
				tmp.put("jobLevelName", "");
			}
			
			returnList.add(tmp);
		}
	
		return returnList;
	}

	@Override
	public CoviList selectPresence(String authToken, String userCodes, String aadObjectIds) throws Exception {
    	CoviList returnList = new CoviList();
    	
		StringBuilder sbIds = new StringBuilder();
		String body = "";
		CoviMap userParams = null;
		CoviMap userInfo = null;
		CoviMap userTemp = new CoviMap();
		Boolean useComma = false;
		if (!"".equals(userCodes)) {
			String arrUserCode[] = userCodes.split(",");
			userParams = new CoviMap();
			userParams.put("arrUserCode", arrUserCode);
			userParams.put("arrAadObjectId", null);
			userParams.put("lang", SessionHelper.getSession("lang"));
		} else if (!"".equals(aadObjectIds)) {
			String arrAadObjectId[] = aadObjectIds.split(",");
			userParams = new CoviMap();
			userParams.put("arrUserCode", null);
			userParams.put("arrAadObjectId", arrAadObjectId);
			userParams.put("lang", SessionHelper.getSession("lang"));
		}

		CoviList selList = coviMapperOne.list("m365.getMultiUserInfo", userParams);
		if(selList.size() > 0) {
			for (int i = 0; i < selList.size(); i++) {
				userInfo = selList.getJSONObject(i);

				if (!"".equals(userInfo.get("AadObjectId").toString())) {
					if (useComma) {
						sbIds.append(", ");
					} else {
						useComma = true;
					}
					sbIds.append("\"");
					sbIds.append(userInfo.get("AadObjectId").toString());
					sbIds.append("\"");	

					userTemp.put(userInfo.get("AadObjectId").toString(), userInfo.get("UserCode").toString());
				}
			}

			body = sbIds.toString();
		}
		
		if (!"".equals(body)) {
			body = "{ \"ids\": [" + body + "] }";
			
	        String graphURL = "https://graph.microsoft.com/v1.0/communications/getPresencesByUserId";
	        
	        CoviMap GraphParams = new CoviMap();
	        GraphParams.put("authToken", authToken);
	        GraphParams.put("scope", "TeamsApp");
	        GraphParams.put("url", graphURL);
	        GraphParams.put("method", "POST");
	        GraphParams.put("body", body);
	        
	        String response = callGraphAPI_Delegated(GraphParams);
							
			CoviMap resultObj = CoviMap.fromObject(response);
			
			CoviList resultList = resultObj.getJSONArray("value");
			CoviMap tmp = null;
			CoviMap tmpObj = null;
			
			if (resultList.size() > 0) {
				
				for(int i=0; i<resultList.size(); i++){
					tmpObj = CoviMap.fromObject(resultList.getJSONObject(i));
					
					tmp = new CoviMap();
					tmp.put("usercode", userTemp.get(tmpObj.getString("id")).toString());
					tmp.put("id", tmpObj.getString("id"));
					tmp.put("availability", tmpObj.getString("availability"));
					tmp.put("activity", tmpObj.getString("activity"));
					
					returnList.add(tmp);
				}
			}
		}

		return returnList;
	}

	
	@Override
	public void createTeam(String authToken, String displayName, String description) throws Exception {
        String graphURL = "https://graph.microsoft.com/v1.0/teams";
        CoviMap body = new CoviMap();
        body.put("template@odata.bind", "https://graph.microsoft.com/v1.0/teamsTemplates('standard')");
        body.put("displayName", displayName);
        body.put("description", description);
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "POST");
        GraphParams.put("body", body.toJSONString());
        
        String response = callGraphAPI_Delegated(GraphParams);

        if (!"".equals(response)) {
        	CoviMap resultObj = CoviMap.fromObject(response);

    		CoviMap errorObj = resultObj.getJSONObject("error");
    		if (errorObj.size() > 0) {
        		String code = errorObj.getString("code");
        		String message = errorObj.getString("message");
        		
        		throw new Exception("[" + code + "] " + message);	
    		}
        }
	}
	
	@Override
	public void updateTeam(String authToken, String teamid, String displayName, String description) throws Exception {
        String graphURL = "https://graph.microsoft.com/v1.0/groups/" + teamid;
        CoviMap body = new CoviMap();
        body.put("displayName", displayName);
        body.put("description", description);
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "PATCH");
        GraphParams.put("body", body.toJSONString());
        
        String response = callGraphAPI_Delegated(GraphParams);
        
        if (!"".equals(response)) {
        	CoviMap resultObj = CoviMap.fromObject(response);

    		CoviMap errorObj = resultObj.getJSONObject("error");
    		if (errorObj.size() > 0) {
        		String code = errorObj.getString("code");
        		String message = errorObj.getString("message");
        		
        		throw new Exception("[" + code + "] " + message);	
    		}
        }
	}

	@Override
	public void createChannel(String authToken, String teamid, String displayName, String description) throws Exception {
        String graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/channels";
        CoviMap body = new CoviMap();
        body.put("displayName", displayName);
        body.put("description", description);
        body.put("membershipType", "standard");
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "POST");
        GraphParams.put("body", body.toJSONString());
        
        String response = callGraphAPI_Delegated(GraphParams);
        
        if (!"".equals(response)) {
        	CoviMap resultObj = CoviMap.fromObject(response);

    		CoviMap errorObj = resultObj.getJSONObject("error");
    		if (errorObj.size() > 0) {
        		String code = errorObj.getString("code");
        		String message = errorObj.getString("message");
        		
        		throw new Exception("[" + code + "] " + message);	
    		}
        }
	}
	
	@Override
	public void updateChannel(String authToken, String teamid, String channelid, String displayName, String description) throws Exception {
        String graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/channels/" + channelid;
        CoviMap body = new CoviMap();
        body.put("displayName", displayName);
        body.put("description", description);
        
        CoviMap GraphParams = new CoviMap();
        GraphParams.put("authToken", authToken);
        GraphParams.put("scope", "TeamsApp");
        GraphParams.put("url", graphURL);
        GraphParams.put("method", "PATCH");
        GraphParams.put("body", body.toJSONString());
        
        String response = callGraphAPI_Delegated(GraphParams);
        
        if (!"".equals(response)) {
        	CoviMap resultObj = CoviMap.fromObject(response);

    		CoviMap errorObj = resultObj.getJSONObject("error");
    		if (errorObj.size() > 0) {
        		String code = errorObj.getString("code");
        		String message = errorObj.getString("message");
        		
        		throw new Exception("[" + code + "] " + message);	
    		}
        }
	}

	@Override
	public CoviList addTeamMember(String authToken, String teamid, String userCodes) throws Exception {
		CoviList returnList = new CoviList();
		
        String graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/members";
		String[] arrUserCodes = userCodes.split(",");
		CoviMap userParams = null;
		CoviMap userInfo = null;
		CoviMap body = null;
		CoviMap GraphParams = null;
        for (int i = 0; i < arrUserCodes.length; i++) {
			if (!"".equals(arrUserCodes[i])) {
				userParams = new CoviMap();
				userParams.put("userCode", arrUserCodes[i]);
				userParams.put("userPrincipalName", "");
				userParams.put("aadObjectId", "");
				userParams.put("lang", SessionHelper.getSession("lang"));
							
				userInfo = coviMapperOne.select("m365.getUserInfo", userParams);
				if (userInfo.size() > 0 && !"".equals(userInfo.getString("AadObjectId"))) {
					body = new CoviMap();
			        body.put("@odata.type", "#microsoft.graph.aadUserConversationMember");
			        body.put("roles", new CoviList());
			        body.put("user@odata.bind", "https://graph.microsoft.com/v1.0/users('" + userInfo.getString("AadObjectId") + "')");
					
					GraphParams = new CoviMap();
			        GraphParams.put("authToken", authToken);
			        GraphParams.put("scope", "TeamsApp");
			        GraphParams.put("url", graphURL);
			        GraphParams.put("method", "POST");
			        GraphParams.put("body", body.toJSONString());
			        
			        String response = callGraphAPI_Delegated(GraphParams);

			        if (!"".equals(response)) {
			        	CoviMap resultObj = CoviMap.fromObject(response);

			    		CoviMap errorObj = resultObj.getJSONObject("error");
			    		if (errorObj.size() > 0) {
			        		String code = errorObj.getString("code");
			        		String message = errorObj.getString("message");
			        		
			        		throw new Exception("[" + code + "] " + message);	
			    		}
			        }
				} else {
					returnList.add(arrUserCodes[i]);
				}
			}
        } 
        
        return returnList;
	}
	
	@Override
	public CoviList deleteTeamMember(String authToken, String teamid, String membershipIds) throws Exception {
		CoviList returnList = new CoviList();
		
        String graphURL = "";
		String[] arrMembershipId = membershipIds.split(";");
		CoviMap GraphParams = null;
        for (int i = 0; i < arrMembershipId.length; i++) {
			if (!"".equals(arrMembershipId[i])) {
				graphURL = "https://graph.microsoft.com/v1.0/teams/" + teamid + "/members/" + java.net.URLEncoder.encode(arrMembershipId[i], java.nio.charset.StandardCharsets.UTF_8.toString());
				
				GraphParams = new CoviMap();
		        GraphParams.put("authToken", authToken);
		        GraphParams.put("scope", "TeamsApp");
		        GraphParams.put("url", graphURL);
		        GraphParams.put("method", "DELETE");
		        GraphParams.put("body", "");
		        
		        String response = callGraphAPI_Delegated(GraphParams);

		        if (!"".equals(response)) {
		        	CoviMap resultObj = CoviMap.fromObject(response);

		    		CoviMap errorObj = resultObj.getJSONObject("error");
		    		if (errorObj.size() > 0) {
		        		String code = errorObj.getString("code");
		        		String message = errorObj.getString("message");
		        		
		        		throw new Exception("[" + code + "] " + message);	
		    		}
		        }
			}
        } 
        
        return returnList;
	}
	
	

	@Override
	public String selectUnreadMailCount() throws Exception {
		String returnStr = "";
		String userPrincipalName = SessionHelper.getSession("LogonID") + "@" + RedisDataUtil.getBaseConfig("M365Domain");
        String graphURL = "https://graph.microsoft.com/v1.0/users/" + userPrincipalName + "/mailFolders/Inbox/messages?$filter=isRead%20ne%20true&$count=true";
        CoviMap params = new CoviMap();
        params.put("scope", "Groupware");
        params.put("url", graphURL);
        params.put("method", "GET");
        params.put("body", "");
        String response = callGraphAPI_Application(params);
						
        org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		Object obj = parser.parse( response );
		org.json.simple.JSONObject jsonObj = (org.json.simple.JSONObject) obj;
		returnStr = jsonObj.get("@odata.count").toString();
	
		return returnStr;
	}
	
	@Override
	public String selectTodayCalendarCount() throws Exception {
		String returnStr = "";
		String urTimeZone = SessionHelper.getSession("UR_TimeZone");
		if(!urTimeZone.substring(0, 1).equalsIgnoreCase("-")){
			urTimeZone = "+" + urTimeZone;
		}
		urTimeZone = urTimeZone.substring(0, 6);
		
		java.time.LocalDateTime currentTime = java.time.LocalDateTime.now();
		String startDate = currentTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		currentTime = currentTime.plusDays(1);
		String endDate = currentTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		startDate = java.net.URLEncoder.encode(startDate + "T00:00:00" + urTimeZone, java.nio.charset.StandardCharsets.UTF_8.toString());
		endDate = java.net.URLEncoder.encode(endDate + "T00:00:00" + urTimeZone, java.nio.charset.StandardCharsets.UTF_8.toString());

		String userPrincipalName = SessionHelper.getSession("LogonID") + "@" + RedisDataUtil.getBaseConfig("M365Domain");
        String graphURL = "https://graph.microsoft.com/v1.0/users/" + userPrincipalName + "/calendarView?startDateTime=" + startDate + "&endDateTime=" + endDate + "&$count=true";
        CoviMap params = new CoviMap();
        params.put("scope", "Groupware");
        params.put("url", graphURL);
        params.put("method", "GET");
        params.put("body", "");
        String response = callGraphAPI_Application(params);
						
        org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		Object obj = parser.parse( response );
		org.json.simple.JSONObject jsonObj = (org.json.simple.JSONObject) obj;
		returnStr = jsonObj.get("@odata.count").toString();
	
		return returnStr;
	}
	
	
	

	public CoviMap selectM365OAuthToken(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();

		CoviList selList = coviMapperOne.list("m365.getOAuthTokenInfo", params);	
		if (selList.size() > 0) {
			CoviMap token = selList.getJSONObject(0);
			returnObj.put("Scope", token.getString("Scope"));
			returnObj.put("DN_ID", token.getString("DN_ID"));
			returnObj.put("DN_Code", token.getString("DN_Code"));
			returnObj.put("AppId", token.getString("AppId"));
			returnObj.put("TenantId", token.getString("TenantId"));
			returnObj.put("ClientSecret", token.getString("ClientSecret"));
			returnObj.put("AccessToken", token.getString("AccessToken"));
			returnObj.put("ExpireDateTime", token.getString("ExpireDateTime"));
		} else {
			returnObj.put("Scope", "");
			returnObj.put("DN_ID", "");
			returnObj.put("DN_Code", "");
			returnObj.put("AppId", "");
			returnObj.put("TenantId", "");
			returnObj.put("ClientSecret", "");
			returnObj.put("AccessToken", "");
			returnObj.put("ExpireDateTime", "");
		}
		
		return returnObj;
	}

	public String callGraphAPI_Application(CoviMap params) throws Exception {
		String response = "";

		CoviMap OAuthParams = new CoviMap();
		CoviMap resultOAuthToken = new CoviMap();
		
		OAuthParams.put("scope", params.get("scope").toString());
		OAuthParams.put("dn_id", SessionHelper.getSession("DN_ID"));
		
		resultOAuthToken = selectM365OAuthToken(params);
        String accessToken = resultOAuthToken.get("AccessToken").toString();

		params.put("accessToken", accessToken);
        
        response = callGraphAPI(params);
		
		return response;
	}

	public CoviMap getAccessToken_Application(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		StringUtil func = new StringUtil();
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int httpStatus = 404;
		String method = "";
		String url = "";
		String body = "";
		String response = "";
		
		String RequestDate = func.getCurrentTimeStr();
		org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		
		InputStream responseStream = null;
		try {
			url = "https://login.microsoftonline.com/" + params.get("TenantId").toString() + "/oauth2/v2.0/token";
			method = "POST";
			
			PostMethod connPost = new PostMethod(url);
			connPost.setRequestHeader("Accept", "application/json");
			connPost.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
						
			body += "client_id=" + java.net.URLEncoder.encode(params.get("AppId").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
			body += "&client_info=1";
			body += "&client_secret=" + java.net.URLEncoder.encode(params.get("ClientSecret").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
			body += "&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default";
			body += "&grant_type=client_credentials";
			connPost.setRequestBody(body);

			httpStatus = client.executeMethod(connPost);
			responseStream = connPost.getResponseBodyAsStream();
			response = IOUtils.toString(responseStream, StandardCharsets.UTF_8);
			
			Object obj = parser.parse( response );
			org.json.simple.JSONObject jsonObj = (org.json.simple.JSONObject) obj;

			returnObj.put("AccessToken", jsonObj.get("access_token").toString());
			returnObj.put("ExpireDateTime", jsonObj.get("expires_in").toString());
		} catch (NullPointerException e) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e.getMessage() + "\"}";
		} catch (Exception e2) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e2.getMessage() + "\"}";
		} finally {
			params = new CoviMap();
			params.put("LogType","M365");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(httpStatus));
        	params.put("RequestBody", body);

    		if(httpStatus < 299){
    			params.put("ResultType", "SUCCESS");
    		}else{
    			params.put("ResultType", "FAIL");
    		}
    		params.put("ResponseMsg", response);
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        	
        	if(responseStream != null) {
        		responseStream.close();
        	}
		}
		
		return returnObj;
	}
	
	
	public String callGraphAPI_Delegated(CoviMap params) throws Exception {
		String response = "";

		Boolean useNewToken = false;
		String tokenExpireDateTime = SessionHelper.getSession("M365_OAuthExpireDateTime");
		if (tokenExpireDateTime == null || "".equals(tokenExpireDateTime)) {
			useNewToken = true;
		} else {
			java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
			java.time.LocalDateTime expireTime = java.time.LocalDateTime.parse(tokenExpireDateTime, formatter);
			java.time.LocalDateTime currentTime = java.time.LocalDateTime.now();
			currentTime = currentTime.plusMinutes(5);
			
			if (currentTime.isAfter(expireTime)) {
				useNewToken = true;
			}
		}
		
		if (useNewToken) {
			CoviMap resultOAuthToken = new CoviMap();
			CoviMap OAuthParams = new CoviMap();
			OAuthParams.put("scope", params.get("scope").toString());
			OAuthParams.put("dn_id", SessionHelper.getSession("DN_ID"));
			
			resultOAuthToken = selectM365OAuthToken(OAuthParams);
			OAuthParams = new CoviMap();
			OAuthParams.put("AppId", resultOAuthToken.get("AppId").toString());
			OAuthParams.put("TenantId", resultOAuthToken.get("TenantId").toString());
			OAuthParams.put("ClientSecret", resultOAuthToken.get("ClientSecret").toString());
			OAuthParams.put("AuthToken", params.get("authToken").toString());
			OAuthParams.put("RefreshToken", SessionHelper.getSession("M365_OAuthRefreshToken"));
			
			resultOAuthToken = getAccessToken_Delegated(OAuthParams);
			
			java.time.LocalDateTime expireTime = java.time.LocalDateTime.now();
			expireTime = expireTime.plusSeconds(Integer.parseInt(resultOAuthToken.get("ExpiresIn").toString()));

			SessionHelper.setSession("M365_OAuthAccessToken", resultOAuthToken.get("AccessToken").toString());
			SessionHelper.setSession("M365_OAuthRefreshToken", resultOAuthToken.get("RefreshToken").toString());
			SessionHelper.setSession("M365_OAuthExpireDateTime", expireTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
		}
		
		params.put("accessToken", SessionHelper.getSession("M365_OAuthAccessToken"));

        response = callGraphAPI(params);
		
		return response;
	}

	public CoviMap getAccessToken_Delegated(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		StringUtil func = new StringUtil();
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int httpStatus = 404;
		String method = "";
		String url = "";
		String body = "";
		String response = "";
		
		String RequestDate = func.getCurrentTimeStr();
		org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		
		InputStream responseStream = null;
		try {
			url = "https://login.microsoftonline.com/" + params.get("TenantId").toString() + "/oauth2/v2.0/token";
			method = "POST";
			
			PostMethod connPost = new PostMethod(url);
			connPost.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
						
			if ("".equals(params.getString("RefreshToken"))) {
				body += "client_id=" + java.net.URLEncoder.encode(params.get("AppId").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&client_secret=" + java.net.URLEncoder.encode(params.get("ClientSecret").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&scope="+ java.net.URLEncoder.encode("https://graph.microsoft.com/.default offline_access ", java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&grant_type="+ java.net.URLEncoder.encode("urn:ietf:params:oauth:grant-type:jwt-bearer", java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&assertion="+ java.net.URLEncoder.encode(params.get("AuthToken").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&requested_token_use="+ java.net.URLEncoder.encode("on_behalf_of", java.nio.charset.StandardCharsets.UTF_8.toString());
				
			} else {
				body += "client_id=" + java.net.URLEncoder.encode(params.get("AppId").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&client_secret=" + java.net.URLEncoder.encode(params.get("ClientSecret").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&scope="+ java.net.URLEncoder.encode("https://graph.microsoft.com/.default offline_access ", java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&grant_type="+ java.net.URLEncoder.encode("refresh_token", java.nio.charset.StandardCharsets.UTF_8.toString());
				body += "&refresh_token="+ java.net.URLEncoder.encode(params.get("RefreshToken").toString(), java.nio.charset.StandardCharsets.UTF_8.toString());
			}
			connPost.setRequestBody(body);

			httpStatus = client.executeMethod(connPost);
			responseStream = connPost.getResponseBodyAsStream();
			response = IOUtils.toString(responseStream, StandardCharsets.UTF_8);

			Object obj = parser.parse( response );
			org.json.simple.JSONObject jsonObj = (org.json.simple.JSONObject) obj;

			returnObj.put("AccessToken", jsonObj.get("access_token").toString());
			returnObj.put("RefreshToken", jsonObj.get("refresh_token").toString());
			returnObj.put("ExpiresIn", jsonObj.get("expires_in").toString());
		} catch (NullPointerException e) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e.getMessage() + "\"}";
		} catch (Exception e2) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e2.getMessage() + "\"}";
		} finally {
			params = new CoviMap();
			params.put("LogType","M365");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(httpStatus));
        	params.put("RequestBody", body);

    		if(httpStatus < 299){
    			params.put("ResultType", "SUCCESS");
    		}else{
    			params.put("ResultType", "FAIL");
    		}
    		params.put("ResponseMsg", response);
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        	
        	if(responseStream != null) {
        		responseStream.close();
        	}
		}
		
		return returnObj;
	}
	
	public String callGraphAPI(CoviMap params) throws Exception {
		String response = "";
		StringUtil func = new StringUtil();
		HttpClient client = new HttpClient();
		client.getParams().setContentCharset("utf-8");
		
		int httpStatus = 404;
		String method = "";
		String url = "";
		String body = "";
		String accessToken = "";
		
		String RequestDate = func.getCurrentTimeStr();
		org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		java.net.HttpURLConnection oHttpURLConnection = null;
		
		try {
			url = params.get("url").toString();
			method = params.get("method").toString();
			accessToken = params.get("accessToken").toString();
			body = params.get("body").toString();
			
			java.net.URL oURL = new java.net.URL(url);
			oHttpURLConnection = (java.net.HttpURLConnection)oURL.openConnection();
			if ("PATCH".equals(method.toUpperCase())) {
				allowMethods("PATCH");
				oHttpURLConnection.setRequestMethod("PATCH");
			} else {
				oHttpURLConnection.setRequestMethod(method.toUpperCase());	
			}
			oHttpURLConnection.setDoOutput(true);
			oHttpURLConnection.setReadTimeout(10000);
			oHttpURLConnection.setRequestProperty("Accept", "application/json");
			oHttpURLConnection.setRequestProperty("Content-Type", "application/json");
			oHttpURLConnection.setRequestProperty("Authorization", "Bearer " + accessToken);
			
			if (!"".equals(body)) {
				byte[] byteTemp = body.getBytes(java.nio.charset.StandardCharsets.UTF_8);
				try (java.io.OutputStream oOutputStream = oHttpURLConnection.getOutputStream();) {
					oOutputStream.write(byteTemp);
				}
			}

			httpStatus = oHttpURLConnection.getResponseCode();
			//response = oHttpURLConnection.getResponseMessage();
			
			if (100 <= httpStatus && httpStatus <= 399) {
				try (java.io.BufferedReader oBufferedReader = new java.io.BufferedReader(new java.io.InputStreamReader(oHttpURLConnection.getInputStream(), StandardCharsets.UTF_8));) {
					response = oBufferedReader.lines().collect(java.util.stream.Collectors.joining());
				}
			} else {
				try (java.io.BufferedReader oBufferedReader = new java.io.BufferedReader(new java.io.InputStreamReader(oHttpURLConnection.getErrorStream(), StandardCharsets.UTF_8));) {
					response = oBufferedReader.lines().collect(java.util.stream.Collectors.joining());
				}
			}
		} catch (NullPointerException e) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e.getMessage() + "\"}";
		} catch (Exception e2) {
			httpStatus = 500;
			response = "{\"errorMsg\":\"" + e2.getMessage() + "\"}";
		} finally {
			params = new CoviMap();
			params.put("LogType","M365");
			params.put("Method",method);
        	params.put("ConnetURL",url);
        	
        	params.put("RequestDate", RequestDate);
        	params.put("ResultState", Integer.toString(httpStatus));
        	params.put("RequestBody", body);

    		if(httpStatus < 299){
    			params.put("ResultType", "SUCCESS");
    		}else{
    			params.put("ResultType", "FAIL");
    		}
    		params.put("ResponseMsg", response);
        	
        	params.put("ResponseDate", func.getCurrentTimeStr());
        	LoggerHelper.httpLog(params);
        	
        	if (oHttpURLConnection != null) {
        		oHttpURLConnection.disconnect();
        	}
		}
		
		return response;
	}
	
    private void allowMethods(String... methods) {
        try {
        	java.lang.reflect.Field methodsField = java.net.HttpURLConnection.class.getDeclaredField("methods");

        	java.lang.reflect.Field modifiersField = java.lang.reflect.Field.class.getDeclaredField("modifiers");
            modifiersField.setAccessible(true);
            modifiersField.setInt(methodsField, methodsField.getModifiers() & ~java.lang.reflect.Modifier.FINAL);

            methodsField.setAccessible(true);

            String[] oldMethods = (String[]) methodsField.get(null);
            java.util.Set<String> methodsSet = new java.util.LinkedHashSet<>(java.util.Arrays.asList(oldMethods));
            methodsSet.addAll(java.util.Arrays.asList(methods));
            String[] newMethods = methodsSet.toArray(new String[0]);

            methodsField.set(null/*static field*/, newMethods);
        } catch (NoSuchFieldException | IllegalAccessException e) {
            throw new IllegalStateException(e);
        }
    }
	
	
}
