package egovframework.core.web;

import java.net.URLDecoder;
import java.util.Arrays;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.minidev.json.parser.JSONParser;



import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.MessageManageSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : MessagingCon.java
 * @Description : 통합메세징관리
 * @Modification Information 
 * @ 2017.10.13 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.10.13
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageUserCon {

	private Logger LOGGER = LogManager.getLogger(MessageUserCon.class);
	
	@Autowired
	private MessageManageSvc messageMgrSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final static Object lock = new Object();
	
	// 발송 메세지 데이터 조회
	@RequestMapping(value = "user/messaging/selectMessagingList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessagingList(HttpServletRequest request) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("domainCode", SessionHelper.getSession("DN_Code"));
			params.put("lang",SessionHelper.getSession("lang"));
			params.put("startDate", ComUtils.removeMaskAll(request.getParameter("startDate")));
			params.put("endDate", ComUtils.removeMaskAll(request.getParameter("endDate")));
			params.put("urCode", SessionHelper.getSession("UR_Code"));
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("exceptTypeList",new java.util.ArrayList<>(java.util.Arrays.asList("MailNotification")));
			resultList = messageMgrSvc.selectMessagingList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	//페이지 이동
	@RequestMapping(value="user/messaging/MessagingSubPopup.do", method=RequestMethod.GET)
	public ModelAndView messagingSubPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strMsgID = request.getParameter("msgID");
		
		String returnURL = "core/messaging/MessagingSubPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("msgID", strMsgID);

		return mav;
	}

}