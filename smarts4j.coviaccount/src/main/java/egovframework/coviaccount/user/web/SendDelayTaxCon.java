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
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.SendDelayTaxSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : SendDelayTaxCon.java
 * @Description : 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SendDelayTaxCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private SendDelayTaxSvc sendDelayTaxSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getTaxInvoiceList
	 * @Description : 매입수신내역 목록 조회
	 */
	@RequestMapping(value = "sendDelayTax/getSendDelayTaxList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoiceList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("searchProperty",	searchProperty);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("companyCode",		companyCode);
			params.put("taxInvoiceActive",	taxInvoiceActive);
			params.put("writeDateS",		writeDateS);
			params.put("writeDateE",		writeDateE);
			params.put("searchType",		searchType);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			resultList = sendDelayTaxSvc.getSendDelayTaxList(params);
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
