package egovframework.covision.groupware.workreport.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkReportMyWorkSettingService;



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
public class WorkReportMyWorkSettingCon {

	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(WorkReportMyWorkSettingCon.class);
	
	@Autowired
	private WorkReportMyWorkSettingService myWorkSettingService;
	
	@RequestMapping(value="myworksettingdivision.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkDivision() throws Exception {
		CoviMap returnObj = new CoviMap();	
		CoviMap params = new CoviMap();
		
		CoviMap listObj = myWorkSettingService.selectMyWorkDivision(params);
		returnObj.put("list", listObj.get("list"));
		
		return returnObj;
	}

	@RequestMapping(value="myworksettingproject.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkProject(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();	
		String code = request.getParameter("code");
		String searchText = request.getParameter("searchText");
		
		CoviMap params = new CoviMap();
		params.put("code", code);
		params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
		
		CoviMap listObj = myWorkSettingService.selectMyWorkProject(params);
		returnObj.put("list", listObj.get("list"));
		returnObj.put("cnt", listObj.get("cnt"));
		
		return returnObj;
	}	
	
	@RequestMapping(value="myworksettingmyjob.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkMyJob(
			@RequestParam(value="userID", required=false) String userID 	) throws Exception {
		CoviMap returnObj = new CoviMap();	
		
		// 세션정보'
		if(userID == null){
			userID = SessionHelper.getSession("USERID");
		}
		
		CoviMap params = new CoviMap();
		params.put("ur_code", userID);

		CoviMap listObj = myWorkSettingService.selectMyWorkMyJob(params);
		returnObj.put("list", listObj.get("list"));
		
		return returnObj;
	}
	
	@RequestMapping(value="saveMyJob.do", method=RequestMethod.POST , produces="application/json; charset=utf8")
	public @ResponseBody CoviMap acceptWorkType(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = null;
		// 세션정보
		String strUR_Code = SessionHelper.getSession("USERID");
		String strNewCode = paramMap.get("newcode");
		String strDelCode = paramMap.get("delcode");
	
		String[] arrNewCode = strNewCode.split(",");		
		String[] arrDelCode = strDelCode.split(",");
		
		if(arrNewCode[0].equals(""))	arrNewCode = null;
		if(arrDelCode[0].equals(""))	arrDelCode = null;
		
		CoviMap params = new CoviMap();
		
		params.put("newcode", arrNewCode);
		params.put("delcode", arrDelCode);
		params.put("ur_code", strUR_Code);

		returnObj = myWorkSettingService.setMyJob(params);

	
		return returnObj;
	}
	
	@RequestMapping(value="myworksettingcategory.do", method=RequestMethod.GET, produces="application/json; charset=utf8")
	public @ResponseBody CoviMap getWorkCategory(@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();	
		
		String code = paramMap.get("code");
		
		CoviMap params = new CoviMap();
		params.put("code", code);

		CoviMap listObj = myWorkSettingService.selectCategory(params);
		returnObj.put("list", listObj.get("list"));
		
		return returnObj;
	}
}
