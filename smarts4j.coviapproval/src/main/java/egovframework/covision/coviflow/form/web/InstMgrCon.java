package egovframework.covision.coviflow.form.web;

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

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.form.service.InstMgrSvc;

@Controller
public class InstMgrCon {

	@Autowired
	private InstMgrSvc instMgrSvc;
	
	private Logger LOGGER = LogManager.getLogger(InstMgrCon.class);
	
	@RequestMapping(value = "doAbort.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAbort(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap formObj = CoviMap.fromObject(StringUtil.replaceNull(request.getParameter("formObj")).replace("&quot;", "\""));
		
		instMgrSvc.doAbort(formObj);
		
		return returnObj;
	}
	
	
	@RequestMapping(value = "doCancel.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doCancel(Locale locale, Model model) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		
		instMgrSvc.doCancel(returnObj);
		
		return returnObj;
	}
	
	
	@RequestMapping(value = "doFoward.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doFoward(Locale locale, Model model) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		
		instMgrSvc.doFoward(returnObj);
		
		return returnObj;
	}
	
	
	@RequestMapping(value = "doDelConsent.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doDelConsent(Locale locale, Model model) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		
		instMgrSvc.doDelConsent(returnObj);
		
		return returnObj;
	}
	
	
	@RequestMapping(value = "doForcedConsent.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doForcedConsent(Locale locale, Model model) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		
		instMgrSvc.doForcedConsent(returnObj);
		
		return returnObj;
	}
	
		
}
