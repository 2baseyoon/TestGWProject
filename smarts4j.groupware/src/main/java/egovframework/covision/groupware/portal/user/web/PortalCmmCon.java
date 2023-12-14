package egovframework.covision.groupware.portal.user.web;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.portal.user.service.PortalSvc;

import egovframework.baseframework.data.CoviMap;

/**
 * @Class Name : PortalCmmCon.java
 * @Description : 포털 일반적 요청 처리
 * @Modification Information 
 * @ 2017.03.30 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 03.30
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class PortalCmmCon {
	
	private Logger LOGGER = LogManager.getLogger(PortalCmmCon.class);
	
	@Autowired
	PortalSvc portalSvc;
	
	//헤더
	@RequestMapping(value = "portal/getInclude.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView getInclude(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		String refTheme = "";
		String returnURL = "cmmn/PortalInclude";
		ModelAndView mav = new ModelAndView(returnURL);
		
		try{
			String portalID = request.getParameter("portalID");
			//String initPortal = SessionHelper.getSession("UR_InitPortal");
			String[] sessionTheme = SessionHelper.getSession("DN_Theme").split("[|]");
			String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
			
			String theme="";
			
			if(portalID!=null){
				CoviMap themeMap = portalSvc.getPortalTheme(portalID);
				theme = themeMap.getString("ThemeCode");
			}else{
				theme = sessionTheme[0];
				/*String[] requestURIs = request.getAttribute( "javax.servlet.forward.request_uri" ).toString().split("/"); 
				String requestURI = requestURIs[requestURIs.length-1];
				
				if(requestURI.equals("getportalhome.do")){
					if(!initPortal.equals("")){
						theme = portalSvc.getPortalTheme(initPortal);
					}
				}else{
					theme = sessionTheme[0];
				}*/
			}
			
			if(! theme.isEmpty()){
				refTheme= "<link rel='stylesheet' type='text/css' href='"+cssPath+"/covicore/resources/css/covision/"+theme+".css'/>";
			}
			
			mav.addObject("theme", refTheme);
			
		} catch(NullPointerException e){
			return mav;
		} catch(Exception e){
			return mav;
		}
		
		return mav;
	}
}
