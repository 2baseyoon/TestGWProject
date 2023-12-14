package egovframework.covision.coviflow.common.web;

import java.util.Enumeration;
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
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.common.service.del_ComStorageSvc;

@Controller
public class ComStorageCon {
	@Autowired
	private AuthHelper authHelper;
	
	private Logger LOGGER = LogManager.getLogger(ComStorageCon.class);
	
	@Autowired
	private del_ComStorageSvc comStorageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "common/selectComStorage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComStorageData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap params = new CoviMap();
			CoviMap resultList = comStorageSvc.select(params);
						
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
	
	@RequestMapping(value = "common/selectComStorageList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getComStorageListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
						
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
		
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			CoviMap resultList = comStorageSvc.selectList(params);
						
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "common/insertComStorage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertComStorage(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();

			Enumeration paramName = request.getParameterNames();

			while (paramName.hasMoreElements()) {
				String key = (String) paramName.nextElement();
				params.put(key, request.getParameter(key));
			}

			returnList.put("object", comStorageSvc.insert(params));
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
	
	@RequestMapping(value = "common/updateComStorage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateComStorage(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();

			Enumeration paramName = request.getParameterNames();

			while (paramName.hasMoreElements()) {
				String key = (String) paramName.nextElement();
				params.put(key, request.getParameter(key));
			}

			returnList.put("object", comStorageSvc.update(params));
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
	
	@RequestMapping(value = "common/deleteComStorage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteComStorage(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		String deleteData = StringUtil.replaceNull(request.getParameter("DeleteData"));
		String[] saData = deleteData.split(",");

		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("fileID", saData);
			
			comStorageSvc.delete(params);

			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
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
