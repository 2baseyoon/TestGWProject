package egovframework.core.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.core.sevice.SysPasswordPolicySvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

@Controller
public class SysPasswordPolicyCon {

	private Logger LOGGER = LogManager.getLogger(SysPasswordPolicyCon.class);
	
	@Autowired
	private SysPasswordPolicySvc sysPasswordPolicySvc;
	
	@RequestMapping(value = "passwordPolicy/getSelectPolicyComplexity.do" )
	public  @ResponseBody CoviMap getSelectPolicyComplexity(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("domainID", request.getParameter("domainID"));
		
		CoviMap returnObj = new CoviMap(); 
		
		CoviMap listData = sysPasswordPolicySvc.getSelectPolicyComplexity(params);
		
		returnObj.put("list", listData.get("list"));

		return returnObj;
		
	}
	

	@RequestMapping(value = "passwordPolicy/getPolicy.do" )
	public  @ResponseBody CoviMap getPolicy(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap params = new CoviMap();
		
		params.put("domainID", request.getParameter("domainID"));
		
		CoviMap returnObj = new CoviMap(); 
		
		CoviMap listData = sysPasswordPolicySvc.getPolicy(params);
		
		returnObj.put("list", listData.get("list"));
		returnObj.put("settingVal", listData.get("valList"));
		
		return returnObj;
		
	}
	

	@RequestMapping(value = "passwordPolicy/updatePasswordPolicy.do" )
	public  @ResponseBody CoviMap updatePasswordPolicy(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		CoviMap params = new CoviMap();
		
		params.put("userID", SessionHelper.getSession("USERID") );
		params.put("domainID", request.getParameter("domainID"));
		params.put("complexity", request.getParameter("complexity"));
		params.put("maxChangeDate", request.getParameter("maxChangeDate"));
		params.put("minmumLength", request.getParameter("minmumLength"));
		params.put("changeNotIceDate", request.getParameter("changeNotIceDate"));
		params.put("specialCharacterPolicy", request.getParameter("specialCharacterPolicy"));
		
		// 초기 비밀번호
		CoviMap parInitPass = new CoviMap();
		parInitPass.put("domainID", request.getParameter("domainID"));
		parInitPass.put("RegID", SessionHelper.getSession("USERID"));
		parInitPass.put("ModID", SessionHelper.getSession("USERID"));
		parInitPass.put("SettingKey", "InitPassword");
		parInitPass.put("SettingValue", request.getParameter("initPassword"));
		parInitPass.put("ConfigType", "InitSetRequired");
		parInitPass.put("ConfigName", "");
		parInitPass.put("Description", "비밀번호 초기화 시 사용 할 값");
		
		// 비밀번호 오류 횟수
		CoviMap parFailCount = new CoviMap();
		parFailCount.put("domainID", request.getParameter("domainID"));
		parFailCount.put("RegID", SessionHelper.getSession("USERID"));
		parFailCount.put("ModID", SessionHelper.getSession("USERID"));
		parFailCount.put("SettingKey", "loginFailCount");
		parFailCount.put("SettingValue", request.getParameter("loginFailCount"));
		parFailCount.put("ConfigType", "Mutable");
		parFailCount.put("ConfigName", "로그인실패가능건수");
		parFailCount.put("Description", "로그인 실패시 제한 건수");
		
		CoviMap returnObj = new CoviMap(); 
		
		if(!sysPasswordPolicySvc.updatePasswordPolicy(params, parInitPass, parFailCount)){
			returnObj.put("status", Return.FAIL);
		}else{
			returnObj.put("status", Return.SUCCESS);
		}
		
		
		return returnObj;
		
	}
	
}
