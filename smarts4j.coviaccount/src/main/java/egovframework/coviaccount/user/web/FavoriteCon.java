package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;




import java.sql.SQLException;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.FavoriteSvc;
import egovframework.coviframework.util.ComUtils;

@Controller
public class FavoriteCon {
	
	@Autowired
	private FavoriteSvc favoriteSvc;
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "/favorite/getList.do")
	public ResponseEntity<CoviMap> getList(
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo",	required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue="1") String pageSize,
			@RequestParam(value = "companyCode", required = false, defaultValue="") String companyCode,
			@RequestParam(value = "groupId", required = false, defaultValue="") String groupId, 
			@RequestParam(value = "userId", required = false, defaultValue="") String userId) throws Exception {
		
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
			params.put("companyCode", companyCode);
			params.put("groupId", groupId);
			params.put("userId", userId);
			
			jsonObject = favoriteSvc.getList(params);
			jsonObject.put("result", "ok");
			jsonObject.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return new ResponseEntity<CoviMap>(jsonObject, HttpStatus.OK);
	}
	
	@RequestMapping(value = "/favorite/register.do")
	public ResponseEntity<CoviMap> register(@RequestParam(value = "favorite", required = false, defaultValue="") String favorite) throws Exception {
		CoviMap jsonObject = new CoviMap();
		
		try {
			CoviList jsonArray = CoviList.fromObject(StringEscapeUtils.unescapeHtml(favorite));
			favoriteSvc.register(jsonArray);
			
			jsonObject.put("result", "ok");
			jsonObject.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			jsonObject.put("status", Return.FAIL);
			jsonObject.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return new ResponseEntity<CoviMap>(jsonObject, HttpStatus.OK);
	}
}
