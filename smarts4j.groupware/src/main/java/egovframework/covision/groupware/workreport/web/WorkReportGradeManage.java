package egovframework.covision.groupware.workreport.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.covision.groupware.workreport.service.WorkReportGradeService;




/**
 * @Class Name : WorkReportCommonCon.java
 * @Description : 업무보고 일반적 요청 처리
 * @Modification Information 
 * @ 2017.04.24 최초생성
 *
 * @author 코비젼 협업팀
 * @since 2017. 04.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/workreport")
public class WorkReportGradeManage {

	@Autowired
	private WorkReportGradeService workReportGradeService;
	
	@RequestMapping(value="addGrade.do", method=RequestMethod.GET)
	public ModelAndView getAddGradePage(HttpServletRequest request) throws Exception {
		String returnUrl = "user/workreport/addgrade";
		String mode = request.getParameter("mode");
		
		ModelAndView mav = new ModelAndView(returnUrl);
		mav.addObject("mode", mode);
		
		return mav;
	}
	
	@RequestMapping(value="workreportosgraderegist.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap outSourcingGradeRegist(@RequestParam Map<String, String> paramMap)throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strYear = paramMap.get("year");
		String strMemberType = paramMap.get("memberType");
		String strGrade = paramMap.get("grade");
		String strMmAmount = paramMap.get("mmAmount");
		String strMmExAmount = paramMap.get("mmExAmount");
		String strMdAmount = paramMap.get("mdAmount");
		String strSeq = paramMap.get("seq");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		params.put("memberType", strMemberType);
		params.put("grade", strGrade);
		params.put("mmAmount", strMmAmount);
		params.put("mmExAmount", strMmExAmount);
		params.put("mdAmount", strMdAmount);
		params.put("seq", strSeq);
		
		String resultMsg = workReportGradeService.insertOutSourcingGrade(params);
		
		returnObj.put("resultMsg", resultMsg);
		
		return returnObj;
	}
	
	@RequestMapping(value="getoutsourcinggrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOutSourcingGrade(HttpServletRequest request) throws Exception {
		CoviMap returnObj = null;
		
		String strYear = request.getParameter("year");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		
		returnObj = workReportGradeService.selectOutSourcingGrade(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="deleteoutsourcinggrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteOutSourcingGrade(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		String strYear = request.getParameter("year");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		
		cnt = workReportGradeService.deleteOutSourcingGrade(params);
		
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="ModOutSourcingGrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modOutSourcingGrade(@RequestBody List<Map<String, String>> paramList) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		
		// 빈 List 객체 생성
		List<CoviMap> coviParamList = new ArrayList<CoviMap>();
		CoviMap param = null;
		
		
		// paramList 를 돌면서 CoviMap 객체리스트 생성
		for(Map<String, String> paramMap : paramList) {
			param = new CoviMap();
			
			for(Map.Entry<String, String> entry : paramMap.entrySet()) {
				param.put(entry.getKey(), entry.getValue());
			}
			coviParamList.add(param);
		}
		
		// Service 호출을 통한 비지니스 로직 수행
		cnt = workReportGradeService.modifyOutSourcingGrade(coviParamList);
		
		// 결과 리턴
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="reuseOutSourcingGrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap reuseOutSourcingGrade(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		
		String applyYear = paramMap.get("ApplyYear");
		CoviMap params = new CoviMap();
		params.put("ApplyYear", applyYear);
		
		cnt = workReportGradeService.reuseOutSourcingGrade(params);
		
		returnObj.put("cnt", cnt);
		return returnObj;
	}
	
	//정직원-------------
	
	@RequestMapping(value="getregulargrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRegularGrade(HttpServletRequest request) throws Exception {
		CoviMap returnObj = null;
		
		String strYear = request.getParameter("year");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		
		returnObj = workReportGradeService.selectRegularGrade(params);
		
		return returnObj;
	}
	
	@RequestMapping(value="reuseRegularGrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap reuseRegularGrade(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		
		String applyYear = paramMap.get("ApplyYear");
		CoviMap params = new CoviMap();
		params.put("ApplyYear", applyYear);
		
		cnt = workReportGradeService.reuseRegularGrade(params);
		
		returnObj.put("cnt", cnt);
		return returnObj;
	}
	
	@RequestMapping(value="deleteregulargrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteRegularGrade(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		String strYear = request.getParameter("year");
		
		CoviMap params = new CoviMap();
		params.put("year", strYear);
		
		cnt = workReportGradeService.deleteRegularGrade(params);
		
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
	@RequestMapping(value="ModRegularGrade.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modRegularGrade(@RequestBody List<Map<String, String>> paramList) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		
		// 빈 List 객체 생성
		List<CoviMap> coviParamList = new ArrayList<CoviMap>();
		CoviMap param = null;
		
		
		// paramList 를 돌면서 CoviMap 객체리스트 생성
		for(Map<String, String> paramMap : paramList) {
			param = new CoviMap();
			for(Map.Entry<String, String> entry : paramMap.entrySet()) {
				param.put(entry.getKey(), entry.getValue());
			}
			
			coviParamList.add(param);
		}
		
		// Service 호출을 통한 비지니스 로직 수행
		cnt = workReportGradeService.modifyRegularGrade(coviParamList);
		
		// 결과 리턴
		returnObj.put("cnt", cnt);
		
		return returnObj;
	}
	
}
