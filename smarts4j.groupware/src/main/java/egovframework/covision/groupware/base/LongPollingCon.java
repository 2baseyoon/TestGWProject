package egovframework.covision.groupware.base;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Callable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.base.service.LongPollingSvc;

/**
 * @Class Name : LongPollingCon.java
 * @Description : long polling 요청 처리
 * @Modification Information 
 * @ 2017.04.21 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 04.21
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class LongPollingCon {
	
	private Logger LOGGER = LogManager.getLogger(LongPollingCon.class);
	
	@Autowired
	private LongPollingSvc longPollingSvc; 
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	@RequestMapping(value = "callablelongpolling.do", method = RequestMethod.POST)
	public @ResponseBody Callable<CoviMap> callableLongPolling(final HttpServletRequest request,final HttpServletResponse response) throws Exception{
		
		return new Callable<CoviMap>() {
			@Override
			public CoviMap call() throws Exception {
				CoviMap returnData = new CoviMap();
				
				try{
					String msg = request.getParameter("message");
					
					//WsServer.sendMessage(msg);
					Thread.sleep(2000);
					
					returnData.put("status", Return.SUCCESS);
					returnData.put("message", "long polling server pushed : " + msg);
					
				} catch (NullPointerException e) {
					returnData.put("status", Return.FAIL);
					returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
				} catch (Exception e) {
					returnData.put("status", Return.FAIL);
					returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
				}
				
				return returnData;
			}
		};
		
	}
	
	@RequestMapping(value = "longpolling.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap longPolling(HttpServletRequest request,HttpServletResponse response) throws Exception{
		
		CoviMap returnData = new CoviMap();

		try {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String msg = request.getParameter("message");
			
			// WsServer.sendMessage(msg);
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", sdf.format(new Date()) + " long polling server pushed : " + msg);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
		
	}
	
	@RequestMapping(value = "longpolling/getQuickData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getQuickData(
			@RequestParam(value = "menuListStr", required = true, defaultValue="") String menuListStr, HttpServletRequest request) throws Exception{
		
		CoviMap returnData = new CoviMap();
		CoviMap resultObj = new CoviMap();
		
		try {
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String userId = userDataObj.getString("USERID");
			ArrayList<String> menuList = new ArrayList<String>(Arrays.asList(menuListStr.split(";")));
			
			if(userId.equals("")) {
				returnData.put("countObj", new CoviMap());
				returnData.put("status", Return.FAIL);
				returnData.put("message", "No Session");
								
				return returnData;
			}
			String quickMenu = "";

			// Redis 에서 먼저 데이터 조회
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
		
			
			Set<String> quickMenus = instance.keys("QuickMenu_" + userId, "QuickMenu_" + userId + "*");
			Iterator<String> itMenus = quickMenus.iterator();
			if (itMenus.hasNext()) {
				quickMenu = instance.get(itMenus.next());
			}	
			
			if(menuListStr.equals(quickMenu)) {
				Set<String> names = instance.keys("QuickData" + userId, "QuickData_" + userId + "*");
				Iterator<String> it = names.iterator();
				if (it.hasNext()) {
					String quickData = instance.get(it.next());
					
					if(quickData != null && !quickData.isEmpty()) {
						returnData.put("status", Return.SUCCESS);
						returnData.put("countObj", CoviMap.fromObject(quickData));
						return returnData;
					}
				}
			}
		    
			CoviMap params = new CoviMap();
			params.put("menuList", menuList);
			params.put("userID", userId);
			params.put("userCode", userId);
			
			// 사용자 타임존의 현재일 검색 범위의 일정 검색
			params.put("StartDate", ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat)+" 00:00",ComUtils.ServerDateFormat));
			params.put("EndDate", ComUtils.TransServerTime(DateHelper.getAddDate(ComUtils.GetLocalCurrentDate(ComUtils.UR_DateSimpleFormat), 1)+" 23:59", ComUtils.ServerDateFormat));
			
			resultObj = longPollingSvc.getQuickMenuCount(params, userDataObj); 
			
			// Redis 저장 및 ExpireTime 설정
			String expireTime = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("QuickDataExpireTime")) ? RedisDataUtil.getBaseConfig("QuickDataExpireTime") : "150";
			
			instance.save("QuickMenu_" + userId, menuListStr);
			instance.setExpireTime("QuickMenu_" + userId, Integer.parseInt(expireTime));
			
			instance.save("QuickData_" + userId, resultObj.toString());
			instance.setExpireTime("QuickData_" + userId, Integer.parseInt(expireTime));
			
			returnData.put("status", Return.SUCCESS);
			returnData.put("countObj",resultObj);
		} catch (NullPointerException e) {
			returnData.put("countObj", new CoviMap());
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("countObj", new CoviMap());
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;		
	}
	
	// 메일 건수 조회
	@RequestMapping(value = "longpolling/getMailCnt.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMailCnt(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			ArrayList<String> menuList = new ArrayList<String>();
			menuList.add("Mail");
			param.put("menuList", menuList);
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			returnData.put("MailCnt", longPollingSvc.getQuickMenuCount(param, userDataObj).get("Mail"));
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
}
