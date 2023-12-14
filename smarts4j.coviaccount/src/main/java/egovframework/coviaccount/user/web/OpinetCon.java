package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;



import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.OpinetSvc;
import egovframework.coviframework.util.ComUtils;

@Controller
public class OpinetCon {
	
	@Autowired
	private OpinetSvc opinetSvc;
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping("opinet/getList.do")
	public @ResponseBody CoviMap getList(
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo",	required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue="1") String pageSize,
			@RequestParam(value = "startDD", required = false, defaultValue="") String startDD,
			@RequestParam(value = "endDD", required = false, defaultValue="") String endDD,
			@RequestParam(value = "prodcd", required = false, defaultValue="") String prodcd) throws Exception {
		
		CoviMap params = new CoviMap();
		CoviMap jsonObject = new CoviMap();
		
		try {
			String sortColumn = "";
			String sortDirection = "";	
			if(sortBy.length() > 0){
				sortColumn = sortBy.split(" ")[0];
				sortDirection = sortBy.split(" ")[1];
			}
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("startDD", startDD);
			params.put("endDD", endDD);
			params.put("prodcd", prodcd);
			
			jsonObject = opinetSvc.getList(params);
			jsonObject.put("result", "ok");
			jsonObject.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return jsonObject;
	}
	
	@RequestMapping("opinet/getSync.do")
	public @ResponseBody CoviMap getSync() throws Exception {
		
		CoviMap jsonObject = new CoviMap();
		
		try {
			opinetSvc.getSync();
			jsonObject.put("result", "ok");
			jsonObject.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return jsonObject;
	}
	
	@RequestMapping("opinet/getOpinet.do")
	public @ResponseBody CoviMap getOpinet(
			@RequestParam(value = "YYYYMMDD", required = false, defaultValue="") String YYYYMMDD,
			@RequestParam(value = "PRODCD", required = false, defaultValue="") String PRODCD) throws Exception {
		
		CoviMap params = new CoviMap();
		CoviMap jsonObject = new CoviMap();
		
		try {
			params.put("YYYYMMDD", YYYYMMDD);
			params.put("PRODCD", PRODCD);
			
			jsonObject = opinetSvc.getOpinet(params);
			jsonObject.put("result", "ok");
			jsonObject.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return jsonObject;
	}
}
