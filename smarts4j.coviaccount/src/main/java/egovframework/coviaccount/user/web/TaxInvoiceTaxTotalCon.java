package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.TaxInvoiceTaxTotalSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : TaxInvoiceTaxTotalCon.java
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
public class TaxInvoiceTaxTotalCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 
	
	@Autowired
	private TaxInvoiceTaxTotalSvc taxInvoiceTaxTotalSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getTaxInvoiceTaxTotalList
	 * @Description : 부가세조회 목록 조회
	 */
	@RequestMapping(value = "taxInvoiceTaxTotal/getTaxInvoiceTaxTotalList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoiceTaxTotalList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
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
			
			resultList = taxInvoiceTaxTotalSvc.getTaxInvoiceTaxTotalList(params);
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
	
	/**
	 * @Method Name : taxInvoiceTaxTotalExcelDownload
	 * @Description : 부가세조회 엑셀 다운로드
	 */
	@RequestMapping(value = "taxInvoiceTaxTotal/taxInvoiceTaxTotalExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView taxInvoiceTaxTotalExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "taxInvoiceActive",	required = false, defaultValue="")	String taxInvoiceActive,
			@RequestParam(value = "writeDateS",			required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",			required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("companyCode",		commonCon.convertUTF8(companyCode));
			params.put("taxInvoiceActive",	commonCon.convertUTF8(taxInvoiceActive));
			params.put("writeDateS",		commonCon.convertUTF8(writeDateS));
			params.put("writeDateE",		commonCon.convertUTF8(writeDateE));
			params.put("searchType",		commonCon.convertUTF8(searchType));
			params.put("searchStr",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("headerKey",			commonCon.convertUTF8(headerKey));
			resultList = taxInvoiceTaxTotalSvc.taxInvoiceTaxTotalExcelDownload(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
}
