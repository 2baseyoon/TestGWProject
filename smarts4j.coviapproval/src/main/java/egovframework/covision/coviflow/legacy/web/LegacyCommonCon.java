package egovframework.covision.coviflow.legacy.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;

@Controller
public class LegacyCommonCon {

	private Logger LOGGER = LogManager.getLogger(LegacyCommonCon.class);
	
	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "admin/getLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getConSendDataLogLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String searchType = StringUtil.replaceNull(request.getParameter("searchType"));
			String searchWord = StringUtil.replaceNull(request.getParameter("searchWord"));
			String icoSearch = StringUtil.replaceNull(request.getParameter("icoSearch"));
			
			CoviMap params = new CoviMap(paramMap);
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("EntCode", ComUtils.RemoveSQLInjection(request.getParameter("EntCode"), 100));
			params.put("searchType", ComUtils.RemoveSQLInjection(searchType, 100));
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			CoviMap resultList = legacyCmmnSvc.selectGrid(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	//오류관리 - 연동오류처리 - JSON수정팝업
	@RequestMapping(value = "admin/OpenJsonEditPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getOpenJsonEditPopup(Locale locale, Model model)
	{
		String returnURL = "admin/approval/OpenJsonEditPopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "admin/deleteLegacyErrorLog.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteLegacyErrorLog(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String errorID = request.getParameter("legacyID");
			
			CoviMap params = new CoviMap();
			params.put("legacyID", errorID);
			
			legacyCmmnSvc.deleteLegacyErrorLog(params);

			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "admin/retryExecuteLegacy.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap retryExecuteLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo", 1);
			params.put("pageSize", 50); // 한번에 처리할 개수 지정
			params.put("sel_Search", "Mode");
			params.put("search", "LEGACY");
			params.put("startDate",  "");
			params.put("endDate",  "");
			params.put("sortColumn", "LegacyID");
			params.put("sortDirection", "asc");
			
			// 재처리 대상
			CoviMap resultList = legacyCmmnSvc.selectGrid(params);
			CoviList list = (CoviList) resultList.get("list");
			
			String sURL = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/executeLegacy.do";
			
			for(int i=0; i<list.size(); i++) {
				String parameters = list.getJSONObject(i).getString("Parameters");
				String legacyID = list.getJSONObject(i).getString("LegacyID");
				
				String inputParams = "LegacyInfo=" + new String(Base64.encodeBase64(parameters.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
						
				HttpURLConnectUtil url = new HttpURLConnectUtil();
				url.httpURLConnect(sURL, "POST", 30000, 30000, inputParams, "");
				
				// 성공이면 로그 deleteDate 업데이트
				if(url.getResponseType().equalsIgnoreCase("SUCCESS")) {
					CoviMap params2 = new CoviMap();
					params2.put("legacyID", legacyID);
					
					legacyCmmnSvc.deleteLegacyErrorLog(params2);					
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_apv_170"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
