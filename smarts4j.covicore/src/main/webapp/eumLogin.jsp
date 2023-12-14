<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,java.net.*,egovframework.baseframework.sec.EUMAES" %>
<%@ page import="egovframework.baseframework.util.*,egovframework.coviframework.util.*,egovframework.core.web.*,egovframework.coviframework.base.TokenParserHelper" %>
<%@ page import="java.util.*,egovframework.baseframework.data.*,egovframework.coviframework.base.TokenHelper, egovframework.core.sevice.LoginSvc"%>
<%@ page import="net.sf.json.JSONObject,javax.servlet.ServletContext,org.springframework.web.context.WebApplicationContext,org.springframework.web.context.support.WebApplicationContextUtils" %>

<%

String eumId= "";
String sPage= URLDecoder.decode(request.getParameter("ReturnURL"), "UTF-8").replaceAll("&amp;", "&");
try{
		CoviMap loginInfo = new CoviMap();

		String eumToken = request.getParameter("EumToken") ;
		try{
		    EUMAES aes = new EUMAES("", "M");
			String plainStr = aes.decrypt(eumToken);
			if (plainStr.indexOf("|") > 0){
				eumId = plainStr.substring(0, plainStr.indexOf("|"));
			}else{
				eumId = plainStr;	
			}
		} catch (NullPointerException e) {
			response.sendRedirect("/");
			return;
		} catch(Exception e){
			response.sendRedirect("/");
			return;
		}

		TokenHelper tokenHelper = new TokenHelper();
		StringUtil func = new StringUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		CookiesUtil cUtil = new CookiesUtil();
		String lang = "ko";
		/*
		String key = cUtil.getCooiesValue(request);
		
		if(!key.isEmpty()){
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			String decodeKey = tokenHelper.getDecryptToken(key);
			
			if(tokenParserHelper.parserJsonLoginVerification(decodeKey)) {
				Map<Object, Object> map = tokenParserHelper.getSSOToken(decodeKey);
				
				String cookieId = (String) map.get("id");
				lang = (String) map.get("lang");
				if (!eumId.equals(cookieId)){
					try{
						
						String subDomain = SessionHelper.getSession("SubDomain");
						key = (String) session.getAttribute("KEY");
						String key_psm =  (String) session.getAttribute("USERID");
						
						CoviMap params = new CoviMap();
						
						params.put("logonID", SessionHelper.getSession("USERID"));
						params.put("IPAddress", func.getRemoteIP(request));
						params.put("OS", ClientInfoHelper.getClientOsInfo(request));
						params.put("browser", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
						
						loginsvc.updateLogoutTime(params);
						
						cUtil.removeCookies(response, request, key, "D", "N",subDomain);
						
						if( !ClientInfoHelper.isMobile(request) && !func.f_NullCheck(key_psm).equals("")){
							key_psm = key_psm + "_PSM";
							instance.remove(key_psm);
						}
						key = "";
					}catch(Exception e){
						throw e;
					}
				}
			}
		}
	
		if (key.isEmpty()){
			String date = loginsvc.checkSSO("DAY");
			String dn = loginsvc.selectUserMailAddress(eumId);
			
			CoviMap accountList = loginsvc.checkAuthetication("SSO", eumId, "", "kr");
			CoviMap account = (CoviMap) accountList.get("account");
	
			key = tokenHelper.setTokenString(eumId,date,"",lang,dn,account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
			
			String accessDate = tokenHelper.selCookieDate(date,"");
			CoviMap returnData  = new CoviMap();
			
			if(!"".equals(key) && !"".equals(accessDate)){
				cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
				
				if(loginsvc.deleteUserFailCount(eumId)){
					loginsvc.updateUserLock(eumId, "N");
				}
				loginInfo.put("id",eumId);
				loginInfo.put("language",lang);
			}
			sPage = "redirect:"+sPage;
		}*/
		
	    
	} catch (NullPointerException e) {
		response.sendRedirect("/covicore/");
		return;
	} catch(Exception e){
		response.sendRedirect("/covicore/");
		return;
	}

	response.sendRedirect(sPage.replaceAll("\r", "").replaceAll("\n", "")+"#id="+eumId.replaceAll("\r", "").replaceAll("\n", ""));
//		response.sendRedirect(sPage);
%>