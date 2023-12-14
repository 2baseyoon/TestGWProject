package egovframework.covision.coviflow.common.web;


import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.common.service.EntInfoSvc;

@Controller
public class EntInfoCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(EntInfoCon.class);
	
	@Autowired
	private EntInfoSvc entInfoSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getEntInfoListData : 계열사 리스트 (관리회사 포함)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "common/getEntInfoListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntInfoListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String type = request.getParameter("type");
			
			CoviMap params = new CoviMap();
			
			CoviList domainList = ComUtils.getAssignedDomainID();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("assignedDomain", domainList);
			
			if("ID".equalsIgnoreCase(type))
				params.put("domainCodeType", "ID");
			
			CoviMap resultList = entInfoSvc.getEntinfoListData(params);
			
			CoviList entInfoListData = (CoviList)resultList.get("list");
			if(domainList.isEmpty() || domainList.size() > 1) {
				//entInfoListData.add(0, String.format("{optionValue:\"\",optionText: \"%s\"}", DicHelper.getDic("lbl_MngCompany"))); // 관리회사
				CoviMap entInfoData = new CoviMap();
				entInfoData.put("optionValue","");
				entInfoData.put("optionText",DicHelper.getDic("lbl_MngCompany"));
				entInfoListData.add(0,entInfoData);
			}
				
			returnList.put("list", entInfoListData);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	/**
	 * getEntInfoListDefaultData : 계열사 리스트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "common/getEntInfoListDefaultData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntInfoListDefaultData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			CoviMap resultList = entInfoSvc.getEntinfoListData(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	/**
	 * getEntInfoListDefaultData : 계열사 리스트 (소속회사만)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "common/getEntInfoListAssignData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntInfoListAssignData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			CoviList domainList = ComUtils.getAssignedDomainID();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("assignedDomain", domainList);
			
			CoviMap resultList = entInfoSvc.getEntinfoListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	/**
	 * getEntInfoListDefaultData : 계열사 리스트 (소속회사만 / domainID 사용)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "common/getEntInfoListAssignIdData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getEntInfoListAssignIdData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			CoviList domainList = ComUtils.getAssignedDomainID();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("assignedDomain", domainList);
			
			params.put("domainCodeType", "ID");
			CoviMap resultList = entInfoSvc.getEntinfoListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}

}
