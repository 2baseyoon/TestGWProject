package egovframework.covision.groupware.survey.manage.web;

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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.filter.lucyXssFilter;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.survey.user.service.SurveySvc;
import egovframework.covision.groupware.survey.user.web.SurveyCon;

// 전자설문(관리자)
@Controller
@RequestMapping("manage/survey")
public class SurveyManageCon {
	private Logger LOGGER = LogManager.getLogger(SurveyCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	@Autowired
	private SurveySvc surveySvc;
	// 그룹웨어설정, 설문관리 > 통계보기 팝업.
	@RequestMapping(value = "/goSurveyReportView.do", method = RequestMethod.GET)
	public ModelAndView goSurveyReportView(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("surveyID", request.getParameter("surveyId"));
		
		CoviMap returnList = new CoviMap();
		ModelAndView mav = new ModelAndView("manage/survey/SurveyReport");
		mav.addObject("result", returnList);
		
		return mav;
	}
	
	// 설문관리(관리자) 조회	
	@RequestMapping(value = "/getSurveyManageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getSurveyManageList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			int pageSize = (request.getParameter("pageSize") != null || request.getParameter("pageSize").length() > 0) ? Integer.parseInt(request.getParameter("pageSize")) : 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("companyCode", request.getParameter("companyCode"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			params.put("selType", request.getParameter("selType"));
			params.put("state", request.getParameter("state"));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			
			// 관리자화면에서의 DomainCode가 아닌 그룹웨어설정의 DomainID가 전달되었을 경우.
			//params.put("domainId", request.getParameter("domainId"));
			
			resultList = surveySvc.getSurveyManageList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NumberFormatException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
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
		
}
