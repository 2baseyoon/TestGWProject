package egovframework.coviaccount.user.web;


import java.lang.invoke.MethodHandles;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.user.service.AccountPortalSvc;


/**
 * @Class Name : AccountPortalCon.java
 * @Description : 포탈
 * @Modification Information 
 * @author Covision
 * @ 2018.07.23 최초생성
 */
@Controller
public class AccountPortalCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountPortalSvc accountPortalSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
		accountPortal/searchPortalMainData.do
		포탈 메인정보 조회
	 */
	@RequestMapping(value="accountPortal/searchPortalMainData.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchExpenceApplication(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();
		try{
			
			CoviMap params = new CoviMap();
			resultMap = accountPortalSvc.searchPortalMainData(params);
			returnObj.put("data", resultMap);
			
			
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (SQLException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	
}
