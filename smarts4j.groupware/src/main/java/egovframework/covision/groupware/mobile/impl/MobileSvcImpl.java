package egovframework.covision.groupware.mobile.impl;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Set;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.covision.groupware.mobile.MobileSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("mobileService")
public class MobileSvcImpl extends EgovAbstractServiceImpl implements MobileSvc{
	
	
	private Logger LOGGER = LogManager.getLogger(MobileSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	
	//mobile.searchPhoneNumber
	public CoviMap getPhoneNumberSearch(String phoneNumber) throws Exception{
		CoviMap resultList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("number", phoneNumber);
			
			CoviList list = coviMapperOne.list("mobile.searchPhoneNumber", params);
			
			String strColumn = "UserID,UserCode,LogonID,DisplayName,JobPositionName,JobTitleName,JobLevelName,DeptName,CompanyName,PhoneNumber,Mobile,PhoneNumberInter,PhoneNumberSearch,MobileSearch,PhotoPath";
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, strColumn));
			
		} catch(NullPointerException e){
			LOGGER.error("getPhoneNumberSearch", e);
		} catch(Exception e){
			LOGGER.error("getPhoneNumberSearch", e);
		}
		
		return resultList;
	}
		
		
	
	//mobile.selectPhoneNumberList
	public CoviMap getPhoneNumberList() throws Exception{
		CoviMap resultList = new CoviMap();
		
		try{
			CoviList list = coviMapperOne.list("mobile.selectPhoneNumberList", null);
			String strColumn = "UserID,UserCode,LogonID,DisplayName,JobPositionName,JobTitleName,JobLevelName,DeptName,CompanyName,PhoneNumber,Mobile,PhoneNumberInter,PhoneNumberSearch,MobileSearch";
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, strColumn));
			
		} catch(NullPointerException e){
			LOGGER.error("getPhoneNumberList", e);
		} catch(Exception e){
			LOGGER.error("getPhoneNumberList", e);
		}
		
		return resultList;
	}



	@Override
	public CoviMap getQuickMenuCount(CoviMap params, CoviMap userDataObj) throws Exception {
		ArrayList<String> menuList = (ArrayList<String>) params.get("menuList");
		
		if(menuList.contains("Board") || menuList.contains("Schedule")){
			String[] objectArray = null;
			Set<String> authorizedObjectCodeSet = null;

			String aclFolder = "";
			authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Board", "V");
			String[] boardObjectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Schedule", "V");
			String[] scheduleObjectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			objectArray = new String[boardObjectArray.length + scheduleObjectArray.length];
			
			System.arraycopy(boardObjectArray, 0, objectArray, 0, boardObjectArray.length);
			System.arraycopy(scheduleObjectArray, 0, objectArray, boardObjectArray.length, scheduleObjectArray.length);
			
			if(objectArray.length > 0) {
				params.put("aclDataArr", objectArray);
				params.put("jobSeq", userDataObj.get("URBG_ID"));
				params.put("objectType", "FD");
				params.put("userCode", userDataObj.get("USERID"));
			}
		}
		
		CoviMap returnObj = new CoviMap();
		
		if(menuList.contains("Integrated")){
			returnObj.put("Integrated", coviMapperOne.getNumber("user.longPolling.selectAlarmListCnt", params));
		}
		
		if(menuList.contains("Approval")){
			returnObj.put("Approval", coviMapperOne.getNumber("user.longPolling.selectApprovalListCnt", params));
		}
		
		if(menuList.contains("Board")){
			// 권한 데이터가 있을때만 조회
			if(params.containsKey("aclDataArr")) {
				params.put("bizSection", "Board");				
				returnObj.put("Board", coviMapperOne.getNumber("user.longPolling.selectNonReadRecentlyMessageCnt", params));
			}
		}
		
		if(menuList.contains("Schedule")){
			// 권한 데이터가 있을때만 조회
			if(params.containsKey("aclDataArr")) {
				params.put("bizSection", "Schedule");				
				params.put("scheduleMenuID", RedisDataUtil.getBaseConfig("ScheduleMenuID", userDataObj.getString("DN_ID")));				
				returnObj.put("Schedule", coviMapperOne.getNumber("user.longPolling.selectTodayScheduleCnt", params));
			}
		}
		
		if(menuList.contains("Survey")){
			returnObj.put("Survey", coviMapperOne.getNumber("user.longPolling.selectSurveyCnt", params));
		}
		
		if(menuList.contains("Mail")){
			returnObj.put("Mail", getMailCount(userDataObj));
		}
		
		return returnObj;
	}
	
	private String getMailCount(CoviMap userDataObj) throws Exception {
	 	String retCnt = "0";
		boolean isSync = false;
		String apiURL = null;
		String sMode = "?job=NewMailCount"; //Mail 개수 조회
		String sDomain = null;
		
		LOGGER.error("LongPollingSvcImpl getMailCount error [checkpoint_1] > userDataObj" +userDataObj);
		try {
			String dnID = userDataObj.getString("DN_ID");
			LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_2] dnID > " +dnID);
			isSync = RedisDataUtil.getBaseConfig("IsSyncIndi",dnID).equals("Y") ? true : false;
			LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_3] isSync > " +isSync);
			if(isSync)
			{
				apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL",dnID) + sMode;
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_4] apiURL > " +apiURL + "/ sMode > " + sMode);		
				sDomain = userDataObj.getString("UR_Mail");
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_5] sDomain > " +sDomain);
				if(!sDomain.isEmpty()){
					sDomain = sDomain.split("@")[1];	// covision.co.kr
					LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_6] sDomain is not empty> " +sDomain);
				}
				
				String sLogonID = URLEncoder.encode(userDataObj.getString("UR_Mail").split("@")[0],"UTF-8");
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_7] sLogonID > " + sLogonID);
				
				apiURL = apiURL + "&id="+sLogonID+"&domain="+ sDomain;
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_8] apiURL > " + apiURL);
				
				CoviMap jObj = getJson(apiURL);
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_9-1]" + jObj);
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_9-2(toString)]" + jObj.toString());
				
				if(jObj.get("returnCode").toString().equals("0")) //Success
				{
					LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_10] returnCode > " + jObj.get("returnCode").toString());
					retCnt = jObj.get("result").toString();
					LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_11] retCnt > " +retCnt);
				}else{
					retCnt = "0";
					LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_12] retCnt > " +retCnt);
				}			
			}else{
				retCnt ="0";
				LOGGER.error("LongPollingSvcImpl getMailCount error | [checkpoint_13] retCnt > " +retCnt);
			}
		} catch(NullPointerException ex) {
			LOGGER.error("LongPollingSvcImpl getMailCount Error [" + userDataObj.getString("USERID") + "]" + "[Message : " +  ex.getMessage() + "]");
		} catch(Exception ex) {
			LOGGER.error("LongPollingSvcImpl getMailCount Error [" + userDataObj.getString("USERID") + "]" + "[Message : " +  ex.getMessage() + "]");
		}
		
		return retCnt;
		
	}
	
	private CoviMap getJson(String encodedUrl) throws Exception {
		CoviMap resultList = new CoviMap();
		HttpURLConnectUtil url= new HttpURLConnectUtil();
		
		try {
			resultList = url.httpConnect(encodedUrl,"GET",1000,1000,"xform", "N");
		} catch(NullPointerException ex) {
			throw ex;
		} catch(Exception ex) {
			throw ex;
		} finally {
			url.httpDisConnect();
		}
		
		return resultList;
	}
	
}
