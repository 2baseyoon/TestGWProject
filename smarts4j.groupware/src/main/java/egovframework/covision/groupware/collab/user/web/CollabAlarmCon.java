package egovframework.covision.groupware.collab.user.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.groupware.collab.user.service.CollabAlarmSvc;

@Controller
@RequestMapping("collabAlarm")
public class CollabAlarmCon {

	@Autowired
	private CollabAlarmSvc collabAlarmSvc;
	private static final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
	
//	private Logger LOGGER = LogManager.getLogger(ApvProcessCon.class);
	
//	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 일일 요약
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doAutoSummDayAlam.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAutoSummDayAlam(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		CoviMap params =new CoviMap();
		params.put("CompanyCode", request.getParameter("DN_Code"));
		params.put("isSaas", isSaaS);
		
		try{
			CoviMap data = collabAlarmSvc.doAutoSummDayAlam(params);
			
		} catch(NullPointerException e){
			result.put("status", Return.FAIL);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			result.put("status", Return.FAIL);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 마감일
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doAutoTaskCloseAlam.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAutoTaskCloseAlam(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		CoviMap params =new CoviMap();
		params.put("CompanyCode", request.getParameter("DN_Code"));
		params.put("isSaas", isSaaS);

		try{
			CoviMap data = collabAlarmSvc.doAutoTaskCloseAlam(params);
			
		} catch(NullPointerException e){
			result.put("status", Return.FAIL);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			result.put("status", Return.FAIL);
//			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	
}
