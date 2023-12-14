package egovframework.covision.groupware.survey.admin.web;

import java.util.Locale;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

// 전자설문(관리자)
@Controller
@RequestMapping("surveyAdmin")
public class SurveyAdminCon {
/*	// 설문관리 페이지 이동
	@RequestMapping(value = "/goSurveyManage.do", method = RequestMethod.GET)
	public ModelAndView goSurveyManage(Locale locale, Model model) {
		String rtnUrl = "user/survey/SurveyManage";
		ModelAndView mav = new ModelAndView(rtnUrl);
		
		return mav;
	}
	
	// 결과보기 페이지 이동(개인별)
	@RequestMapping(value = "/goSurveyResultIndi.do", method = RequestMethod.GET)
	public ModelAndView goSurveyResultIndi(Locale locale, Model model) {
		String rtnUrl = "user/survey/SurveyResultIndi";
		ModelAndView mav = new ModelAndView(rtnUrl);
		
		return mav;
	}*/
	
	// 통계보기 페이지 이동
	@RequestMapping(value = "/goSurveyReport.do", method = RequestMethod.GET)
	public ModelAndView goSurveyReport(Locale locale, Model model) {
		String rtnUrl = "admin/survey/SurveyReport";
		ModelAndView mav = new ModelAndView(rtnUrl);
		
		return mav;
	}
}
