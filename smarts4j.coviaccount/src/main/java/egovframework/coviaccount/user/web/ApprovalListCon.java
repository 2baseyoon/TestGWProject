package egovframework.coviaccount.user.web;


import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class ApprovalListCon {

	/**
	 * getApprovalDetailList - 개인결재함 하위메뉴별 리스트 상세  조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/ApprovalDetailList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getApprovalDetailList(Locale locale, Model model) throws Exception
	{
		String returnURL = "user/account/ApprovalDetailList";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}

	/**
	 * getApprovalIframeList - 개인결재함 하위메뉴별 양식 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "user/ApprovalIframeList.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getApprovalIframeList(Locale locale, Model model, HttpServletRequest request) throws Exception
	{
		String returnURL = "user/account/ApprovalIframeList";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
}