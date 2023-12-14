package egovframework.covision.groupware.webpart;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.filter.XSSUtils;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;

import java.nio.charset.StandardCharsets;


public class WebpartUtils{
	private static final Logger LOGGER = LogManager.getLogger(WebpartUtils.class);
	private static String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	
	public static void appendCookie(CoviMap headers, HttpServletRequest request) {
		if(headers == null) {
			headers = new CoviMap();
		}
		if (request != null && request.getCookies() != null) {
			StringBuilder cookieData = new StringBuilder();
			for (Cookie cookie : request.getCookies()) {
				String cookieVal = cookie.getValue();
				if("CSJTK".equals(cookie.getName())) {
					cookieVal = "\""+cookieVal+"\"";
				}
				String cookieStr = String.format("%s=%s; ", cookie.getName(), cookieVal);
				cookieData.append(cookieStr);
			}
			headers.put("Cookie", cookieData.toString());
		}
	}
	
	//엑셀 데이터 다국어 처리시 사용 일반 조회로직에는 사용하지 않음
	/**
	 * @param listType
	 * @param clist
	 * @param str
	 * @return JSONArray
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static CoviMap getQuickData(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		egovframework.covision.groupware.base.service.LongPollingSvc longPollingSvc = StaticContextAccessor.getBean(egovframework.covision.groupware.base.service.LongPollingSvc.class);
		egovframework.covision.groupware.board.user.service.MessageSvc messageSvc = StaticContextAccessor.getBean(egovframework.covision.groupware.board.user.service.MessageSvc.class);
		
		try {
			CoviMap userDataObj = (CoviMap)params.get("userDataObj");
			String menuListStr = params.getString("menuListStr");
			String noticeFolderId = params.getString("folderID");
			ArrayList<String> menuList = new ArrayList<String>(Arrays.asList(menuListStr.split(";")));
		    
			params.put("menuList", menuList);
			params.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
			params.put("StartDate", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat)+" 00:00",ComUtils.ServerDateFormat));
			params.put("EndDate", ComUtils.TransServerTime(DateHelper.getAddDate(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat), 1)+" 23:59", ComUtils.ServerDateFormat));
			params.put("userCode",  StringUtil.replaceNull(userDataObj.getString("USERID")));
			params.put("userID", StringUtil.replaceNull(userDataObj.getString("USERID")));

			resultObj = longPollingSvc.getQuickMenuCount(params, userDataObj); 
			if (menuList.contains("Notice")){
				params.put("boardType","Normal");
				params.put("bizSection","Board");
				params.put("folderID",noticeFolderId);
				params.put("pageSize",1);
				params.put("pageOffset", 0);	 
				params.put("pageNo",1);
				params.put("startDate","");
				params.put("endDate","");
				CoviMap resultList = messageSvc.selectNormalMessageGridList(params);
				resultObj.put("Notice", resultList.get("list"));
			} 
			 
		} catch (NullPointerException e) {
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			resultObj.put("status", Return.FAIL);
		}

		return resultObj;
	}

	/**
	 * [전자결재]최근사용양식 목록
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getLastDraftList(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		try {
			String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/user/getLastestUsedFormListData.do";
			
			CoviMap headers = new CoviMap();
			appendCookie(headers, params.getRequest());
			
			CoviMap httpParam = new CoviMap();
			httpParam.put("userCode", params.getString("userCode"));
			CoviMap httpResult = new HttpClientUtil().httpRestAPIConnect(url, "", "POST", httpParam, headers);
			if("200".equals(httpResult.getString("status")) && httpResult.has("body")) { //성공
				resultObj = httpResult.getJSONObject("body");
			}else{	
				resultObj.put("status", Return.FAIL);
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
	
	/**
	 * 36.결재함(목록형) - 미사용
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getApprovalListData(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		try {
			String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/user/getApprovalListData.do";
			
			CoviMap headers = new CoviMap();
			appendCookie(headers, params.getRequest());
			
			//CoviMap httpParam = new CoviMap();
			//httpParam.putAll(params);
			
			CoviMap httpResult = new HttpClientUtil().httpRestAPIConnect(url, "", "POST", params, headers);
			if("200".equals(httpResult.getString("status")) && httpResult.has("body")) { //성공
				// 조회된 데이터를 covimap 형식으로 리턴하고, portal.jsp에서 '${list.data}' 와 같이 문자열 형식으로 받기 때문에 
				// 내용 중 " , ' , 탭(	) 등 escape 된 값이 있는 경우 JSON.parse('${list.data}') 하다가 오류 발생
				// 한번 더 escape 하면 되지만 ' 값으 경우 다시 covimap으로 변환하면서 문제 발생
				//resultObj = httpResult.getJSONObject("body");
				String strBody = httpResult.getJSONObject("body").toString();
				strBody = strBody.replace("\\","\\\\").replace("\\\"","\\\\\"").replace("'","\\'");
				resultObj = new CoviMap(strBody, false);
			}else{	
				resultObj.put("status", Return.FAIL);
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
	
	/**
	 * 37.결재함(아이콘)
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getApprovalListCount(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		try {
			String url = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path"),"") + "/user/getApprovalCntAll.do";
			
			CoviMap headers = new CoviMap();
			appendCookie(headers, params.getRequest());
			
			//CoviMap httpParam = new CoviMap();
			//httpParam.putAll(params);
			
			CoviMap httpResult = new HttpClientUtil().httpRestAPIConnect(url, "", "POST", params, headers);
			if("200".equals(httpResult.getString("status")) && httpResult.has("body")) { //성공
				resultObj = httpResult.getJSONObject("body");
			}else{	
				resultObj.put("status", String.valueOf(Return.FAIL));
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
	
	// 메일 리스트 호출
	@SuppressWarnings("unchecked")
public static CoviMap getMailList(CoviMap params) throws Exception{
		
		String connectUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/mail/userMail/selectWebPartUserMail.do";
		
		CoviMap resultObj = new CoviMap();
		//메일
		CoviMap returnObj = new CoviMap();
		CoviMap mailParams = new CoviMap();
		CoviList resultList = new CoviList();
		try {
			CoviMap userDataObj = (CoviMap)params.get("userDataObj");
			mailParams.put("userId", StringUtil.replaceNull(userDataObj.getString("USERID")));
			mailParams.put("userMail", StringUtil.replaceNull(userDataObj.getString("UR_Mail")));
			mailParams.put("mailBox", "INBOX");
			mailParams.put("page", "1");
			mailParams.put("type", "MAILLIST");
			mailParams.put("type2", "ALL");
			mailParams.put("viewNum", params.getString("viewNum"));
			mailParams.put("sortType", "A");
			
			CoviMap headers = new CoviMap();
			appendCookie(headers, params.getRequest());
			HttpClientUtil httpClient = new HttpClientUtil();
			returnObj = httpClient.httpRestAPIConnect(connectUrl, "json", "POST", CoviMap.toJSONString(mailParams), headers);
			CoviList list = CoviList.fromObject(((CoviMap)((CoviList)returnObj.get("body")).get(0)).get("mailList"));
			
			for(int i=0; i<list.size() ; i++){
				CoviMap resultMailObj = new CoviMap();
				//메일 읽기용
				resultMailObj.put("subject", ((CoviMap)list.get(i)).getString("subject").replaceAll("'", "&#39;").replaceAll("\"", "\\\\\""));
				resultMailObj.put("mailId", ((CoviMap)list.get(i)).getString("mailId"));
				resultMailObj.put("folder_path", ((CoviMap)list.get(i)).getString("folder_path"));
				resultMailObj.put("uid", ((CoviMap)list.get(i)).getString("uid"));
				
				//컨텐츠용
				resultMailObj.put("flag", ((CoviMap)list.get(i)).getString("flag").contains("Seen") ? "Y" : "N");
				resultMailObj.put("mailSender", ((CoviMap)list.get(i)).getString("mailSender").replaceAll("'", "&#39;").replaceAll("\"", "\\\\\""));
				String mailReceivedDateStr = ((CoviMap)list.get(i)).getString("mailReceivedDateStr");
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy.MM.dd");
				Date date = sdf.parse(mailReceivedDateStr);
				resultMailObj.put("mailReceivedDateStr", sdf2.format(date));
				
				resultList.add(resultMailObj);
			}
			resultObj.put("result", resultList);
			
		}catch(NullPointerException e) {
			resultObj.put("status", Return.FAIL);
		}
		catch (Exception e) {
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
		
	}
	
	/**
	 * 근태 데이터
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getMyAttStatus(CoviMap params) throws Exception {
		egovframework.covision.groupware.attend.user.service.AttendPortalSvc attendPortalSvc = StaticContextAccessor.getBean(egovframework.covision.groupware.attend.user.service.AttendPortalSvc.class);
		
		CoviMap resultObj = new CoviMap();
		try{
			CoviMap userDataObj = (CoviMap)params.get("userDataObj");
			CoviMap userAttMap = attendPortalSvc.getAttendDataWebpart(userDataObj);
			resultObj.put("result", userAttMap);			
			
		} catch (NullPointerException e) {
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
	
	/**
	 * ceo msaage
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static CoviMap getCeoMessage(CoviMap params) throws Exception {
		
		CoviMap resultObj = new CoviMap();
		try{
			egovframework.covision.groupware.portal.user.service.PortalSvc portalSvc = StaticContextAccessor.getBean(egovframework.covision.groupware.portal.user.service.PortalSvc .class);
			CoviMap userDataObj = (CoviMap)params.get("userDataObj");
			CoviMap webpart = (CoviMap)params.get("webpart");
			CoviMap resultMap = new CoviMap();

			CoviMap extentionJSON = (CoviMap)webpart.get("ExtentionJSON");
			params.put("domainId",userDataObj.get("DN_ID"));
			params.put("settingKey",extentionJSON.get("settingKey"));
//			RedisDataUtil.getBaseConfig("");
			String[] arrList = RedisDataUtil.getBaseConfig("ceoMsgAuth").split(";",-1);
			
			if (Arrays.asList(arrList).contains(userDataObj.getString("USERID"))){
				String str = "<button type='button' data-action='setting'><span>"+DicHelper.getDic("lbl_Set")+"</span></button>";
				String appendHtml = new String(Base64.encodeBase64(str.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
				
				CoviMap map = portalSvc.selectWebpartSettingKey(params);
				resultMap.put("appendAuth", appendHtml);
				resultMap.put("isadmin", "admin");
				if (map !=null){
					resultMap.put("message", map.getString("SettingValue"));
				}	
				resultObj.put("result", resultMap);			
			}	
			
		} catch (NullPointerException e) {
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
	
	/**
	 * FreeBoard(자유게시)
	 */
	public static CoviMap getFreeBoard(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		try{
			egovframework.covision.groupware.portal.user.service.PortalSvc portalSvc = StaticContextAccessor.getBean(egovframework.covision.groupware.portal.user.service.PortalSvc.class);
			CoviMap userDataObj = new CoviMap();
			CoviMap webpart = new CoviMap();
			CoviMap extentionJSON = new CoviMap();
			CoviMap resultMap = new CoviMap();
			
			userDataObj = (CoviMap)params.get("userDataObj");
			webpart = (CoviMap)params.get("webpart");
			extentionJSON = (CoviMap)webpart.get("ExtentionJSON");
			
			params.put("domainId",userDataObj.get("DN_ID"));
			params.put("settingKey",extentionJSON.get("settingKey"));
			
			CoviMap map = portalSvc.selectWebpartSettingKey(params);
			
			if (map !=null){
				resultMap.put("folderIDs", map.getString("SettingValue"));
			}	
			resultObj.put("result", resultMap);
			
		} catch (NullPointerException e) {
			resultObj.put("status", Return.FAIL);
		} catch (Exception e) {
			resultObj.put("status", Return.FAIL);
		}
		return resultObj;
	}
}
