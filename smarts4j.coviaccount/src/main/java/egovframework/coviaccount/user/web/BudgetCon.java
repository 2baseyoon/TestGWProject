package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.user.service.BudgetSvc;


/**
 * @Class Name : AuditCon.java
 * @Description : AuditCon 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BudgetCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BudgetSvc budgetSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getBudgetInfo
	 * @Description : 예산 상세 조회
	 */
	@RequestMapping(value = "budget/getBudgetInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAuditDetail(
			@RequestParam(value = "CostCenter",			required = false, defaultValue="") String CostCenter,
			@RequestParam(value = "UseDate",			required = false, defaultValue="") String UseDate,
			@RequestParam(value = "AccountCodes",		required = false, defaultValue="") String AccountCodes,
			@RequestParam(value = "StandardBriefIDs",	required = false, defaultValue="") String StandardBriefIDs) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if(CostCenter.equals("")) {
				CostCenter = SessionHelper.getSession("USERID");
			}
			params.put("CostCenter",	CostCenter);
			params.put("UseDate",		UseDate);
			if(AccountCodes != null && !AccountCodes.equals("")) params.put("AccountCodes", AccountCodes.split(","));
			if(StandardBriefIDs != null && !StandardBriefIDs.equals("")) params.put("StandardBriefIDs", StandardBriefIDs.split(","));
			resultList = budgetSvc.getBudgetInfo(params);
			resultList.put("result",	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
