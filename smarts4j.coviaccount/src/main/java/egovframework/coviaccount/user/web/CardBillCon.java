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
import egovframework.coviaccount.user.service.CardBillSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : CardBillCon.java
 * @Description : 법인카드 청구내역 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CardBillCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CardBillSvc cardBillSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * @Method Name : getCardBillList
	 * @Description : 법인카드 청구내역 목록 조회
	 */
	@RequestMapping(value = "cardBill/getCardBillList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardBillList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("approveDate",	approveDate);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("companyCode",	companyCode);
			
			resultList = cardBillSvc.getCardBillList(params);
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
	 * @Method Name : cardBillExcelDownload
	 * @Description : 법인카드 청구내역 엑셀 다운로드
	 */
	@RequestMapping(value = "cardBill/cardBillExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardBillExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("approveDate",	commonCon.convertUTF8(approveDate));
			params.put("cardNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			
			resultList = cardBillSvc.getCardBillExcelList(params);
			
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
	
	/**
	 * @Method Name : getCardBillmmSumAmountWon
	 * @Description : 법인카드 청구내역 월간 합계 금액
	 */
	@RequestMapping(value = "cardBill/getCardBillmmSumAmountWon.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardBillmmSumAmountWon(
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("approveDate",	approveDate);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			
			resultList = cardBillSvc.getCardBillmmSumAmountWon(params);
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
	 * @Method Name : getCardBillUserList
	 * @Description : 법인카드 청구내역 [사용자] 목록 조회
	 */
	@RequestMapping(value = "cardBill/getCardBillUserList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardBillUserList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("approveDate",	approveDate);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("companyCode",	companyCode);
			
			resultList = cardBillSvc.getCardBillUserList(params);
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
	 * @Method Name : cardBillUserExcelDownload
	 * @Description : 법인카드 청구내역 [사용자] 엑셀 다운로드
	 */
	@RequestMapping(value = "cardBill/cardBillUserExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView cardBillUserExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",		required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",		required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("approveDate",	commonCon.convertUTF8(approveDate));
			params.put("cardNo",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(cardNo, 100)));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			
			resultList = cardBillSvc.getCardBillUserExcelList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : getCardBillmmSumAmountWonUser
	 * @Description : 법인카드 청구내역 [사용자] 월간 합계 금액
	 */
	@RequestMapping(value = "cardBill/getCardBillmmSumAmountWonUser.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardBillmmSumAmountWonUser(
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "approveDate",	required = false, defaultValue="")	String approveDate,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("companyCode",	companyCode);
			params.put("approveDate",	approveDate);
			params.put("cardNo",		ComUtils.RemoveSQLInjection(cardNo, 100));
			
			resultList = cardBillSvc.getCardBillmmSumAmountWonUser(params);
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
	 * @Method Name : cardBillSync
	 * @Description : 법인카드 청구내역 동기화
	 */
	@RequestMapping(value = "cardBill/cardBillSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap cardBillSync(){
		CoviMap	resultList	= new CoviMap();
		resultList = cardBillSvc.cardBillSync();
		return resultList;
	}
}