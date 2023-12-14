package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.google.gson.JsonParser;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.ExchangeRateSvc;
import egovframework.coviframework.util.ComUtils;



@Controller
public class ExchangeRateCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private ExchangeRateSvc exchangeRateSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : saveExchangeRateInfo
	 * @Description : 환률정보 저장
	 */
	@RequestMapping(value = "exchangeRate/saveExchangeRateInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveExchangeRateInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "exchangeRateID",		required = false,	defaultValue = "") String exchangeRateID,
			@RequestParam(value = "exchangeRateDate",	required = false,	defaultValue = "") String exchangeRateDate,
			@RequestParam(value = "usd",	required = false , defaultValue = "") String usd,
			@RequestParam(value = "eur",	required = false , defaultValue = "") String eur,
			@RequestParam(value = "aed",	required = false , defaultValue = "") String aed,
			@RequestParam(value = "aud",	required = false , defaultValue = "") String aud,
			@RequestParam(value = "brl",	required = false , defaultValue = "") String brl,
			@RequestParam(value = "cad",	required = false , defaultValue = "") String cad,
			@RequestParam(value = "chf",	required = false , defaultValue = "") String chf,
			@RequestParam(value = "cny",	required = false , defaultValue = "") String cny,
			@RequestParam(value = "jpy",	required = false , defaultValue = "") String jpy,
			@RequestParam(value = "sgd",	required = false , defaultValue = "") String sgd
			) throws Exception{
		
		CoviMap resultList	=	new CoviMap();
		CoviMap params		=	new CoviMap();
		
		try {
			params.put("exchangeRateID", exchangeRateID);
			params.put("exchangeRateDate", exchangeRateDate);
			params.put("usd", usd);
			params.put("eur", eur);
			params.put("aed", aed);
			params.put("aud", aud);
			params.put("brl", brl);
			params.put("cad", cad);
			params.put("chf", chf);
			params.put("cny", cny);
			params.put("jpy", jpy);
			params.put("sgd", sgd);
			resultList = exchangeRateSvc.saveExchangeRateInfo(params);
			resultList.put("status", Return.SUCCESS);
			
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : getExchangeRatelist
	 * @Description : 환률정보  목록 조회
	 */
	@RequestMapping(value = "exchangeRate/getExchangeRatelist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getExchangeRatelist(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",					required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",					required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",				required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "exchangeRateDateStart",	required = false, defaultValue="")	String exchangeRateDateStart,
			@RequestParam(value = "exchangeRateDateFinish",	required = false, defaultValue="")	String exchangeRateDateFinish) throws Exception{
			
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",				ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",				ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",					pageNo);
			params.put("pageSize",					pageSize);
			params.put("exchangeRateDateStart",		exchangeRateDateStart);
			params.put("exchangeRateDateFinish",	exchangeRateDateFinish);
			
			resultList = exchangeRateSvc.getExchangeRatelist(params);
			resultList.put("result" ,	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : getExchangeRatePopupInfo
	 * @Description : 환률정보  상세 정보 조회
	 */
	@RequestMapping(value="exchangeRate/getExchangeRatePopupInfo.do", method=RequestMethod.POST)
	public  @ResponseBody CoviMap getExchangeRatePopupInfo(
			@RequestParam (value = "exchangeRateID" , required = false , defaultValue="") String exchangeRateID) throws Exception{
		
		CoviMap resultList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("exchangeRateID" , exchangeRateID);
			resultList = exchangeRateSvc.getExchangeRatePopupInfo(params);
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteExchangeRateInfo
	 * @Description : 환률정보 삭제
	 */
	@RequestMapping(value = "exchangeRate/deleteExchangeRateInfo.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteExchangeRateInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq", required = false , defaultValue="") String deleteSeq) throws Exception{
		CoviMap resultList  = new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			params.put("deleteSeq", deleteSeq);
			exchangeRateSvc.deleteExchangeRateInfo(params);
			
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return resultList;
	}
	
	/**
	 * @Method Name : exchangeRateExcelDownload
	 * @Description : 환률정보 엑셀 다운로드
	 */
	@RequestMapping(value = "exchangeRate/exchangeRateExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView exchangeRateExcelDownload(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam(value = "start" ,		required = false, defaultValue="") String exchangeRateDateStart,
			@RequestParam(value = "finish",		required = false, defaultValue="") String exchangeRateDateFinish,
			@RequestParam(value = "headerName",	required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",	required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title
			){
		ModelAndView mav 		= new ModelAndView();
		CoviMap resultList 	= new CoviMap();
		CoviMap viewParams 		= new CoviMap();
		String returnURL 		= "UtilExcelView";
		
		try{
			
			//String[] headerNames		= commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			
			params.put("exchangeRateDateStart",		commonCon.convertUTF8(exchangeRateDateStart));
			params.put("exchangeRateDateFinish",	commonCon.convertUTF8(exchangeRateDateFinish));
			params.put("headerKey",					commonCon.convertUTF8(headerKey));
			resultList = exchangeRateSvc.getExchangeRateExcelList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL , viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
 	}
	
	/**
	 * @Method Name : getExchangeRatePopup
	 * @Description : 환률정보 팝업 호출
	 */
	@RequestMapping(value = "exchangeRate/getExchangeRatePopup.do" , method = RequestMethod.GET)
	public ModelAndView getExchangeRatePopup(){
		String returnURL = "user/account/ExchangeRatePopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * @Method Name : exchangeRateSync
	 * @Description : 환률정보 동기화
	 */
	@RequestMapping(value = "exchangeRate/exchangeRateSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap exchangeRateSync(){
		
		CoviMap	resultList	= new CoviMap();
		resultList = exchangeRateSvc.exchangeRateSync();
		return resultList;
	}
	
	@RequestMapping(value = "exchangeRate/exchangesList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap exchangesList(
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false, defaultValue="1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue="1") String pageSize,
			@RequestParam(value = "exchangeRateDateStart", required = false, defaultValue="") String exchangeRateDateStart,
			@RequestParam(value = "exchangeRateDateFinish", required = false, defaultValue="") String exchangeRateDateFinish) {
		
		CoviMap resultList	=	new CoviMap();
		CoviMap params		=	new CoviMap();
		
		try {
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",				ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",				ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",					pageNo);
			params.put("pageSize",					pageSize);
			params.put("exchangeRateDateStart",		exchangeRateDateStart);
			params.put("exchangeRateDateFinish",	exchangeRateDateFinish);
			
			resultList = exchangeRateSvc.exchangesList(params);
			resultList.put("result" ,	"ok");
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	@RequestMapping(value = "exchangeRate/exchangesRegister.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap exchangesRegister(@RequestBody Map<String, Object> param) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("YYYYMMDD", param.get("exchangeRateDate"));
			params.put("REGISTERID", SessionHelper.getSession("UR_Code"));
			params.put("MODIFIERID", SessionHelper.getSession("UR_Code"));

			resultList = exchangeRateSvc.exchangesRegister(params, new CoviMap(param.get("exchanges")));
			
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	@RequestMapping(value = "exchangeRate/exchangesModify.do", method = RequestMethod.PUT)
	public @ResponseBody CoviMap exchangesModify(@RequestBody Map<String, Object> param) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("YYYYMMDD", param.get("exchangeRateDate"));
			params.put("REGISTERID", SessionHelper.getSession("UR_Code"));
			params.put("MODIFIERID", SessionHelper.getSession("UR_Code"));
			
			resultList = exchangeRateSvc.exchangesModify(params, new CoviMap(param.get("exchanges")));
			
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	@RequestMapping(value = "exchangeRate/exchangesRead.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap exchangesRead(@RequestBody Map<String, Object> param) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("YYYYMMDD", param.get("exchangeRateDate"));
			
			resultList = exchangeRateSvc.exchangesRead(params);
			
			resultList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	@RequestMapping(value = "exchangeRate/exchangesRemove.do", method = RequestMethod.DELETE)
	public @ResponseBody CoviMap exchangesRemove(@RequestBody Map<String, Object> param) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			CoviList deleteObj = new CoviList((List) param.get("deleteObj"));
			resultList = exchangeRateSvc.exchangesRemove(deleteObj);
			
			resultList.put("status", Return.SUCCESS);
 		} catch (SQLException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
