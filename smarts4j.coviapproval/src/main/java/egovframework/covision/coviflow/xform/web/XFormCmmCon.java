package egovframework.covision.coviflow.xform.web;

import java.util.Locale;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.coviframework.util.AuthHelper;

/**
 * @Class Name : XFormCmmCon.java
 * @Description : XForm 요청 처리
 * @2016.11.15 최초생성
 * 
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class XFormCmmCon {

	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(XFormCmmCon.class);

	/**
	 * goCommonXFormPage 
	 * @param strPage
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "/approval_XForm.do", method = RequestMethod.GET)
	public ModelAndView goCommonXFormPage(Locale locale, Model model) {
		String returnURL = "xform/XForm";
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
}
