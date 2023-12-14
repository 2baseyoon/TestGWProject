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
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.EUMAES;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.EumSvc;
import egovframework.core.sevice.LoginSvc;


/**
 * @Class Name : MessengerAuthSSOCon.java
 * @Description : 이음 메신저 인증 / 세션 생성
 * @ 2020.01.09 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright(C) by Covision All right reserved.
 */

@Controller
public class MessengerAuthSSOCon{
	private Logger LOGGER = LogManager.getLogger(MessengerAuthSSOCon.class);
	
	@Autowired
	private LoginSvc loginsvc;
	
	@Autowired
	private EumSvc eumsvc;
	
	/**
	 * <pre>
	 * 1. 개요 : 메신저 토큰 인증/토큰 생성 API 
	 * </pre>
	 * @throws Exception 
	 * @Method Name : eumLoginAuth
	 */ 	
	@RequestMapping(value = "/messenger/eum/sso/auth.do", method = RequestMethod.GET) 
	public @ResponseBody CoviMap eumLoginAuth(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(request.getParameter("id")).equals("") || func.f_NullCheck(request.getParameter("ps")).equals("") || func.f_NullCheck(request.getParameter("ds")).equals("")){
			returnObj.put("status", Return.FAIL);
			return returnObj;
		}

		func = null;
		
		try{
			AES aes = new AES("", "");
			if(loginsvc.checkUserAuthetication(request.getParameter("id"),  aes.decrypt(request.getParameter("ps"))) > 0){
				aes = null;

				EUMAES eumAES = new EUMAES("","M");
				
				CoviMap params = new CoviMap();
				
				params.put("id", request.getParameter("id"));
				params.put("deviceType", request.getParameter("ds"));

				if(!eumsvc.messengerAuthHis(params)){
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}
				
				params = null;
				
				returnObj.put("result", eumAES.encrypt(request.getParameter("id")));
				returnObj.put("status", Return.SUCCESS);
				
				eumAES = null;
			}else{
				returnObj.put("status", Return.FAIL);
				return returnObj;
			}

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
		} catch (Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
		}
		
		return returnObj;
	}
}
