package egovframework.covision.coviflow.admin.web;

import java.util.Locale;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.coviframework.util.AuthHelper;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.util.SessionHelper;

/**
 * @Class Name : ApprovalAdminCmnCon.java
 * @Description : 전자결재 관리자 화면
 * @Modification Information 
 * @ 2016.08.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016.08.03
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ApprovalAdminCmnCon {

	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(ApprovalAdminCmnCon.class);
	
	@RequestMapping(value = "/approvaladmin_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView logadminview(@PathVariable String strPage, Locale locale, Model model) {
		
		LOGGER.info("strPage : {}", strPage);
		
		String returnURL = "approval/" + strPage + ".admin";
		
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "/adminapprovalleft.do", method = RequestMethod.GET)
	public ModelAndView adminLogLeft(Locale locale, Model model) throws Exception {
		
		/*String returnURL = "cmmn/menu/adminapprovalleft";
	    
		String listdata = "[{label:'양식프로세스 관리', url:'#', cn:[{label:'프로세스 목록', url:'#'}]},{label:'결재양식자동생성', url:'#', cn:[{label:'양식분류 관리', url:'#'}, {label:'양식 관리', url:'#'}]}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminapprovalleft", listdata);*/
		
		String returnURL = "cmmn/menu/adminapprovalleft";
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "15", locale.getLanguage());
	    
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminapprovalleft", resultList);
		
		return mav;
	}
	
	//헤더
	@RequestMapping(value = "/adminheader.do", method = RequestMethod.GET)
	public ModelAndView adminHeader(Locale locale, Model model) throws Exception {
		//전체 메뉴에서 home의 top값과 topsub값을 쿼리
	    CoviList jsonList = authHelper.getRedisCachedTopMenu(SessionHelper.getSession("USERID"), locale.getLanguage()); //하드코딩을 제거 할 것
	    
		String returnURL = "cmmn/menu/adminheader";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminheader", jsonList);
		
		return mav;
	}
	
}
