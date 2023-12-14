package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.EumSessionHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.common.enums.SyncObjectType;
import egovframework.core.sevice.EumSvc;
import egovframework.core.sevice.LocalBaseSyncSvc;
import egovframework.core.sevice.LocalStorageSyncSvc;
import egovframework.core.sevice.LoginSvc;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.util.SessionCommonHelper;


/**
 * @Class Name : MessengerBridgeSSOCon.java
 * @Description : 이음 메신저 브리지 연동
 * @ 2020.01.09 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright(C) by Covision All right reserved.
 */

@Controller
public class MessengerBridgeSSOCon{
	private Logger LOGGER = LogManager.getLogger(MessengerBridgeSSOCon.class); 
	
	@Autowired
	private EumSvc eumsvc;
	
	@Autowired
	private LoginSvc loginsvc;
	
	@Autowired
	private LocalStorageSyncSvc localStorageSyncSvc;
	
	@Autowired
	private LocalBaseSyncSvc localBaseSyncSvc;
	
	/**
	 * <pre>
	 * 1. 개요 : 메신저 토큰 인증/그룹웨어 토큰생성 
	 * </pre>
	 * @Method Name : getEumAuthTokenView
	 */ 	
	@RequestMapping(value = "/messenger/eum/sso/bride.do", method = RequestMethod.GET)
	public ModelAndView getEumAuthTokenView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		
		boolean urlFlag = false;
		boolean mobile = ClientInfoHelper.isMobile(request);
		boolean headerTK = func.f_NullCheck(request.getHeader("Covi-User-Access-Token")).equals("");
		boolean requestTk = func.f_NullCheck(request.getParameter("atk")).equals("");
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		String atk = null;
		HttpSession session = request.getSession();
		
		if(headerTK && requestTk){
		}else{
			String accessToken = null;
			
			if(headerTK){
				accessToken = request.getParameter("atk");
			}else{
				accessToken = request.getHeader("Covi-User-Access-Token");
			}
			
			String[] tokenInfo = StringUtil.replaceNull(accessToken).split("\\.");
			
			accessToken = null;

			CoviMap params = new CoviMap();
			
			params.put("id", tokenInfo[0]);
			params.put("deviceType", tokenInfo[1]);

			tokenInfo = null;
			
			//ExpireTime 인증 우선 제외 (구조는 잡혀있음)
			//인증 토큰 있는지 확인 후 해당 값으로 조회
			//해당 값 만료 시에 토큰 재 발급
			params = eumsvc.selectTokenInfo(params);
			
			if(params.getInt("cnt") > 0){

				boolean accessCreate = false;
				
				if(params.containsValue("") || params.containsValue(" ")){
					accessCreate = true;
				}else{
					
					if(isMobile){
						atk = session.getId();
					}else{
						atk = params.getString("accessToken");
					}
					
					if(EumSessionHelper.getEumSession(atk, params.getString("id")).equals("")){
						accessCreate = true;
					}else{
						accessCreate = false;
					}
				}
				
				//Redis에 세션있는 경우 세션 시간만 증가 후 쿠키 저장 
				//Redis에 세션이 없는 경우 세션 생성 후 쿠키 저장
				//DB 저장 후 페이지 Return
				CoviMap resultList = new CoviMap();
				
				resultList = eumsvc.selectUserInfo(params);
				
				CoviMap account = (CoviMap) resultList.get("account");
				
				TokenHelper tokenHelper = new TokenHelper();
					
				String date = loginsvc.checkSSO("DAY");
				
				if(accessCreate){
					//Session 생성
					
					if(isMobile){
						atk = session.getId();
					}else{
						atk =  tokenHelper.setTokenString(account.get("LogonID").toString(),date,account.get("LogonPW").toString(),params.getString("lang")
								,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString()
								,account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString()
								,account.get("Attribute").toString(),account.get("DN_ID").toString());
					}
					
					if(!"".equals(atk) && !"".equals(date)){
						//Token 업데이트
						params.put("accessToken", atk);
						
						if(eumsvc.updateAccessToken(params)){
							urlFlag = sessionCreate(params.getString("accessToken"), params.getString("lang"), date, account, response, isMobile);
						}
					}
						
				}else{
					
					if(isMobile){
						atk = session.getId();
					}else{
						atk = params.getString("accessToken");
					}
					
					//있는걸로 쓰는데 정보가 틀어질 가능성은 존재함 
					//문제 발생시 성능은 다운 시키면서 토큰을 계속 생성하는 방향으로 바꿔야함
					EumSessionHelper.setEumExpireTime(atk);
					
					urlFlag = sessionCreate(atk, params.getString("lang"), date, account, response, isMobile);
				}
				
				date = null;
				tokenHelper = null;
			}
		}
		
		String returnURL = "";
		String diffDomain = "";
		
		if(mobile){
			diffDomain = RedisDataUtil.getBaseConfig("MobileDomain", mobile);
		}else{
			diffDomain = RedisDataUtil.getBaseConfig("DesktopDomain", mobile);
		}
		
		if(urlFlag){
			returnURL = "core/eum/bridge";
		}else{
			returnURL = request.getScheme() + "://" + (diffDomain) + ":" + request.getServerPort()+PropertiesUtil.getSecurityProperties().getProperty("sendRedirectSSO.Url");
		}
		
		func = null;
		diffDomain = null;
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("url", request.getParameter("url"));
		mav.addObject("param", request.getParameter("param"));
		mav.addObject("method", request.getParameter("method"));
		mav.addObject("CLSYS", request.getParameter("CLSYS"));
		mav.addObject("CLMD", request.getParameter("CLMD"));
		mav.addObject("CLBIZ", request.getParameter("CLBIZ"));
		
		/* 
		mav.addObject("mode", request.getParameter("mode"));
		mav.addObject("processID", request.getParameter("processID"));
		mav.addObject("workitemID", request.getParameter("workitemID"));
		mav.addObject("userCode", request.getParameter("userCode"));
		mav.addObject("archived", request.getParameter("archived"));
		mav.addObject("usisdocmanager", request.getParameter("usisdocmanager"));
		mav.addObject("CFN_OpenWindowName", request.getParameter("CFN_OpenWindowName"));
		mav.addObject("forminstancetablename", request.getParameter("forminstancetablename"));
		mav.addObject("admintype", request.getParameter("admintype"));
		mav.addObject("listpreview", request.getParameter("listpreview"));
		mav.addObject("subkind", request.getParameter("subkind"));
		mav.addObject("performerID", request.getParameter("performerID"));
		mav.addObject("gloct", request.getParameter("gloct"));
		mav.addObject("formID", request.getParameter("formID"));
		mav.addObject("formtempID", request.getParameter("formtempID")); 
		*/

		return mav;
		
	}
	
	public boolean sessionCreate(String key, String lang, String accessDate, CoviMap account, HttpServletResponse response,boolean isMobile){
		try {
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
			
			HttpSession session = request.getSession();
			
			CookiesUtil cokUtil = new CookiesUtil();
			
			cokUtil.setCookies(response, key, accessDate, account.get("SubDomain").toString());
			
			cokUtil = null;
			
			session.getServletContext().setAttribute(key, account.get("UR_ID").toString() );
			
			session.setAttribute("KEY", key);
			session.setAttribute("USERID", account.get("UR_ID").toString());
			session.setAttribute("LOGIN", "Y");
			
			SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
			SessionHelper.setSession("lang", lang);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
		return true;
	}
	
}
