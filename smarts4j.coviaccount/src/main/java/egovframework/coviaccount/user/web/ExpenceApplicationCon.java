package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.StringTokenizer;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.approvalline.service.AutoApprovalLineService;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.form.dto.FormRequest;
import egovframework.coviaccount.form.dto.UserInfo;
import egovframework.coviaccount.form.service.FormAuthSvc;
import egovframework.coviaccount.user.service.ExpenceApplicationSvc;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : ExpenceApplicationCon.java
 * @Description : 경비신청
 * @Modification Information 
 * @author Covision
 * @ 2018.05.29 최초생성
 */
@Controller
public class ExpenceApplicationCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass()); 

	@Autowired
	private ExpenceApplicationSvc expenceApplicationSvc;
	
	@Autowired
	private CommonSvc commonSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	@Autowired
	private FormAuthSvc formAuthSvc;
	
	@Autowired
	public AutoApprovalLineService autoApprovalLineService;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	* @Method Name : getCardReceipt
	* @Description : 카드정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getCardReceipt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCardReceipt(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
	
			String receiptID = request.getParameter("receiptID");
			String receiptIDList = "";
			StringTokenizer stRI = new StringTokenizer(receiptID,",");
			String getID = "";
			while(stRI.hasMoreTokens()){
				getID = stRI.nextToken();
				if("".equals(receiptIDList)){
					receiptIDList = getID;
				}else{
					receiptIDList = receiptIDList+","+getID;
				}
			}
	
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			if(receiptIDList != null && !receiptIDList.equals("")) params.put("receiptIDList", receiptIDList.split(","));
			resultList = expenceApplicationSvc.getCardReceipt(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : getTaxCodeCombo
	* @Description : 세금 코드 콤보용 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/getTaxCodeCombo.do", method= { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getTaxCodeCombo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
	
		try {
			CoviMap params = new CoviMap();

			String companyCode = request.getParameter("CompanyCode");
			String searchProofCode = request.getParameter("searchProofCode");
			String searchDeductionType = request.getParameter("searchDeductionType");
	
			params.put("companyCode", companyCode);
			params.put("searchProofCode", ComUtils.RemoveSQLInjection(searchProofCode, 100));
			params.put("searchDeductionType", searchDeductionType);
			resultList = expenceApplicationSvc.getTaxCodeCombo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getBriefCombo
	* @Description : 표준적요 콤보용 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/getBriefCombo.do", method= { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBriefCombo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String isSimp = request.getParameter("isSimp");
			String StandardBriefSearchStr = request.getParameter("StandardBriefSearchStr");
			String companyCode = request.getParameter("CompanyCode");
			
			params.put("isSimp", isSimp);
			// 기본 json정보에 들어있는 값으로 영향도 파악이 어려워 여기서 replace
			if(StandardBriefSearchStr != null && !StandardBriefSearchStr.equals("")) params.put("StandardBriefSearchStr", StandardBriefSearchStr.replace("&apos;","'").replace("'","").split(","));
			params.put("companyCode", companyCode);
			
			resultList = expenceApplicationSvc.getBriefCombo(params);
			
			returnList.put("list", resultList.get("BriefList"));
			returnList.put("userList", resultList.get("UserBriefList"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : saveCombineCostApplication
	* @Description : 통합비용 저장
	*/
	@RequestMapping(value = "expenceApplication/saveCombineCostApplication.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCombineCostApplication(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
	
			String sobj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			
			CoviMap saveObj = CoviMap.fromObject(sobj);
			String isSearched = AccountUtil.jobjGetStr(saveObj, "isSearched");
			String isNew = AccountUtil.jobjGetStr(saveObj, "isNew");
			String ApplicationStatus = AccountUtil.jobjGetStr(saveObj, "ApplicationStatus");

			String userID = SessionHelper.getSession("USERID");
			saveObj.put("UserID", userID);
			CoviMap returnObj = new CoviMap();
			
			CoviMap duplObj = expenceApplicationSvc.duplCkExpenceApplicationList(saveObj);
			int totalCnt = 0; 
			if(duplObj != null)
				totalCnt = duplObj.getInt("TotalCnt");
			if(totalCnt == 0){
				if("Y".equals(isSearched) || "N".equals(isNew)){
					returnObj = expenceApplicationSvc.updateCombineCostApplication(saveObj);
				}else{
					returnObj = expenceApplicationSvc.insertCombineCostApplication(saveObj);
				}
	
				if("T".equals(ApplicationStatus)) {
					CoviMap domainParam = new CoviMap();
					domainParam.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey"));
					domainParam.put("ApplicationTitle", AccountUtil.jobjGetStr(saveObj, "ApplicationTitle"));
					domainParam.put("ApprovalLine", saveObj.get("ApprovalLine"));
					domainParam.put("FormName", AccountUtil.jobjGetStr(saveObj, "FormName"));
					expenceApplicationSvc.savePrivateDomainData(domainParam); //임시저장 시 결재선 저장
				}
				
				returnList.put("data", returnObj);
				returnList.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey"));
				returnList.put("getSavedList", AccountUtil.jobjGetObj(returnObj, "getSavedList"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
			} else {
				returnList.put("duplObj", duplObj);
				returnList.put("result", "D");
				returnList.put("status", Return.FAIL);
			}
			
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : searchVendorDetail
	* @Description : 거래처 상세조회
	*/
	@RequestMapping(value="expenceApplication/getVendorInfo.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchVendorDetail(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String vendorID =  request.getParameter("VendorID");
			
			CoviMap params = new CoviMap();
			params.put("VendorID", vendorID);
			
			returnObj.put("data", resultMap.get("result"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
			
		} catch (NullPointerException e) {
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

	/**
	* @Method Name : getApplicationListCopy
	* @Description : 세금계산서 정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getApplicationListCopy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getApplicationListCopy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String ListID = request.getParameter("ListID");
			params.put("ListID", ListID);
			
			resultList = expenceApplicationSvc.getApplicationListCopy(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getTaxBillInfo
	* @Description : 세금계산서 정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getTaxBillInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTaxBillInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String taxBillID = request.getParameter("taxBillID");
			params.put("taxBillID", taxBillID);
			
			resultList = expenceApplicationSvc.getTaxBillInfo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getTaxBillItemInfo
	* @Description : 세금계산서 품목 정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getTaxBillItemInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTaxBillItemInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String taxBillID = request.getParameter("taxBillID");
			params.put("taxBillID", taxBillID);
			
			resultList = expenceApplicationSvc.getTaxBillItemInfo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : getVdCheck
	* @Description : 세금계산서 정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getVdCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVdCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultInfo = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String vendorNo = StringUtil.replaceNull(request.getParameter("VendorNo"));
			params.put("VendorNo", vendorNo);
			vendorNo = vendorNo.replaceAll("-", "");
			resultInfo = expenceApplicationSvc.getVdCheck(params);
			returnList.put("vdInfo", resultInfo.get("vdInfo"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getManagerList
	* @Description : 관리자정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getManagerList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getManagerList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			boolean managerCk = commonSvc.getManagerCk();
			String ckYN = "N";
			if(managerCk){
				ckYN = "Y";
			}
			
			returnList.put("check", ckYN);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getCashBillInfo
	* @Description : 카드정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getCashBillInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCashBillInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
	
			String cashBillIDs = request.getParameter("cashBillIDs");
			String cashBillIDList = "";
			StringTokenizer stRI = new StringTokenizer(cashBillIDs,",");
			String getID = "";
			while(stRI.hasMoreTokens()){
				getID = stRI.nextToken();
				if("".equals(cashBillIDList)){
					cashBillIDList = getID;
				}else{
					cashBillIDList = cashBillIDList+","+getID;
				}
			}
	
			if(cashBillIDList != null && !cashBillIDList.equals("")) params.put("cashBillIDList", cashBillIDList.split(","));
			
			resultList = expenceApplicationSvc.getCashBillInfo(params);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	
	/**
	* @Method Name : searchExpenceApplicationList
	* @Description : 비용증빙 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/searchExpenceApplicationList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplicationList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}			
			resultList = expenceApplicationSvc.searchExpenceApplicationList(params);			
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : searchExpenceApplicationUserList
	* @Description : 비용증빙 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/searchExpenceApplicationUserList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplicationUserList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}			
			resultList = expenceApplicationSvc.searchExpenceApplicationList(params);
	
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : searchExpenceApplication
	* @Description : 전표목록 상세조회
	*/
	@RequestMapping(value="expenceApplication/searchExpenceApplication.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchExpenceApplication(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String expenceApplicationID =  request.getParameter("ExpenceApplicationID");
			
			CoviMap params = new CoviMap();
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
			
			//params.put("fileSavePath", filePath);
			params.put("ExpenceApplicationID", expenceApplicationID);
			params.put("companyCode", commonSvc.getCompanyCodeOfUser());
			resultMap = expenceApplicationSvc.searchExpenceApplication(params);
			returnObj.put("data", resultMap.get("result"));
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
	

	/**
	* @Method Name : searchExpenceApplicationByListIDs
	* @Description : 증빙목록 상세조회
	*/
	@RequestMapping(value="expenceApplication/searchExpenceApplicationByListIDs.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplicationByListIDs(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String expAppListIDs =  request.getParameter("expAppListIDs");
			
			CoviMap params = new CoviMap();
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
			//params.put("fileSavePath", filePath);
			if(expAppListIDs != null && !expAppListIDs.equals("")) {
				expAppListIDs = expAppListIDs.replace("&apos;","'").replace("'","");
				params.put("expAppListIDs", expAppListIDs.split(","));
			}
			resultMap = expenceApplicationSvc.searchExpenceApplication(params);
			returnObj.put("data", resultMap.get("result"));
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

	/**
	* @Method Name : ExpenceApplicationViewPopup
	* @Description : 비용 조회용 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationViewPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView expenceApplicationViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		ModelAndView mav = new ModelAndView();
		
		boolean successYN = true;
		String errorMsg = "";
		
		CoviMap formJson = new CoviMap();
		
		try{
			String returnURL = "user/account/CombineCostApplicationView";
			mav.setViewName(returnURL);
			
			FormRequest formRequest = initFormRequest(request);
			UserInfo userInfo = initUserInfo();
			
			/* Validation
			 *  - 양식 오픈시 서명 이미지 체크
			 *  - Workitem 정보로 양식 오픈 여부 체크
			 *  - 문서 권한 체크
			*/ 
			// 양식 오픈시 서명이미지 체크
			String signFileID = expenceApplicationSvc.selectUsingSignImageId(userInfo.getUserID());
        	if(StringUtils.isNotBlank(signFileID) && RedisDataUtil.getBaseConfig("IS_USE_CHECK_SIGNIMAGE").equals("Y")){
        		throw new NoSuchElementException("개인환경설정에서 서명을 등록하세요.");
        	} else {
        		userInfo.setUserSignFileID(signFileID);
        	}
        	        	
            /* Workitem 정보로 양식 오픈 여부체크 */
        	CoviMap procData = getProcessData(formRequest);				// Process Data Setting
        	CoviMap processObj = procData.getJSONObject("processObj");
        	
            if(procData.has("strSubkind")) {
            	formRequest.setSubkind(procData.getString("strSubkind"));
            }
            if(procData.has("isArchived")){
        		formRequest.setArchived(procData.getString("isArchived"));
        	}            
            if(procData.has("bStored")){
           		formRequest.setBstored(procData.getString("bStored"));
           	}
            
            if(processObj != null && !processObj.isEmpty()){
            	if(processObj.has("ParentProcessID")) {
            		formRequest.setParentProcessID(processObj.getString("ParentProcessID"));
            	}
            	else if(processObj.has("FormInstID")) {
            		formRequest.setFormInstanceID(processObj.getString("FormInstID"));	
            	}
        	}
            
            // 오픈 여부 체크 시작
            if(processObj != null && !processObj.isEmpty()){
            	//ProcessDescription 데이터에서 다시 세팅
            	CoviMap processDescription = processObj.getJSONObject("ProcessDescription");
            	
                if(formRequest.getFormId().equals("") ){
                	formRequest.setFormId(processDescription.getString("FormID"));
                }
            	if(formRequest.getFormInstanceID().equals("") ){
                	formRequest.setFormInstanceID(processDescription.getString("FormInstID"));
                }
                if(formRequest.getIsSecdoc().equals("")){
                	formRequest.setIsSecdoc(processDescription.getString("IsSecureDoc"));
                }
            	
            	if(!formRequest.getProcessID().equals(processObj.getString("ProcessID"))){
            		successYN = false;
            	}else{
            		String processState = processObj.optString("ProcessState");
            		String workitemState = processObj.optString("State");
            		if((processState.equals("") && workitemState.equals("")) || workitemState.equals("546") || processState.equals("546") 
                				|| ( workitemState.equals("688") || processState.equals("688") )){
                    	successYN = false;
            		}
            	}
            	if (!successYN) 
            		throw new NoSuchElementException(DicHelper.getDic("msg_apv_082")); //존재하지 않는 결재문서입니다.
            }
            
            String strReadMode = formRequest.getReadMode();
            
            // 임시저장문서(form정보없음) 오픈시 먼저 조회하도록 상단으로 이동
            CoviMap forms = new CoviMap();
    		CoviMap paramsForms = new CoviMap();
    		paramsForms.put("userID", userInfo.getUserID());
    		paramsForms.put("mode", strReadMode);
    		if(strReadMode.equalsIgnoreCase("DRAFT") || strReadMode.equalsIgnoreCase("TEMPSAVE")) {
    			paramsForms.put("expAppID", formRequest.getExpAppID());
    			forms = (((CoviList)(expenceApplicationSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
    			formRequest.setFormId(forms.optString("FormID"));
    		}else {
	    		if(!formRequest.getFormId().equals("")){
	    			paramsForms.put("formID", formRequest.getFormId());
	    		}else{
	    			paramsForms.put("formPrefix", formRequest.getFormPrefix());
	    		}
	    		forms = (((CoviList)(expenceApplicationSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
    		}
    		
            // 문서 권한 체크
            if(!strReadMode.equalsIgnoreCase("DRAFT") && !strReadMode.equalsIgnoreCase("TEMPSAVE") 
            		&& !formRequest.getIsReuse().equals("Y") 
            		&& !formRequest.getWorkitemID().equals("")
            		&& !formAuthSvc.hasReadAuth(formRequest, userInfo)) {
    	        	throw new SecurityException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
            }
            
            if(strReadMode.equalsIgnoreCase("DRAFT") || strReadMode.equalsIgnoreCase("TEMPSAVE") || strReadMode.equalsIgnoreCase("COMPLETE") || strReadMode.equalsIgnoreCase("REJECT")) {
            	boolean hasWriteAuth = formAuthSvc.hasWriteAuth(formRequest, userInfo);
                userInfo.setHasWriteAuth(hasWriteAuth);
            	if(!hasWriteAuth && (strReadMode.equalsIgnoreCase("DRAFT") || strReadMode.equalsIgnoreCase("TEMPSAVE")
            			|| formRequest.getEditMode().equals("Y")))
            		throw new SecurityException(DicHelper.getDic("msg_WriteAuth")); // 작성 권한이 없습니다.
            }
            
			/* 초기 변수값 수정
			 *  - ReadMode 변경
			*/ 
            if (!strReadMode.equals("COMPLETE"))
            {
            	strReadMode = expenceApplicationSvc.getReadMode(strReadMode,  !processObj.isNullObject() ? processObj.optString("BusinessState") : "", formRequest.getSubkind(), (!processObj.isNullObject() && processObj.has("State")) ? processObj.getString("State") : "");
            	formRequest.setReadMode(strReadMode);
            } else if(processObj.optString("ProcessState").equals("288")) {
        		strReadMode = "PROCESS";
        		formRequest.setReadMode(strReadMode);
        		formRequest.setReadModeTemp(strReadMode);
            }
            
            // Form Data 생성
            CoviMap formJsonRet = createFormJSON(formRequest, userInfo, processObj, forms);
            
            formJson = formJsonRet.getJSONObject("formJson");  
		
		} catch(SecurityException securityException) {
			logger.warn("FormCon", securityException);
			LoggerHelper.errorLogger(securityException, "egovframework.coviaccount.user.web.ExpenceApplicationCon.expenceApplicationViewPopup", "CON");
			errorMsg = securityException.getMessage();
			successYN = false;
		} catch(NoSuchElementException noSuchElementException) {
			errorMsg = noSuchElementException.getMessage();
			successYN = false;
		} catch (SQLException e) {
			logger.error("FormCon", e);
			LoggerHelper.errorLogger(e, "egovframework.coviaccount.user.web.ExpenceApplicationCon.expenceApplicationViewPopup", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_030");
		} catch(Exception e){
			logger.error("FormCon", e);
			LoggerHelper.errorLogger(e, "egovframework.coviaccount.user.web.ExpenceApplicationCon.expenceApplicationViewPopup", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_030");
		}

		mav.addObject("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
		mav.addObject("strErrorMsg", errorMsg);
		mav.addObject("strSuccessYN", successYN);
		
		return mav;
	}
	
	// Process Data Setting
	public CoviMap getProcessData(FormRequest formRequest) throws Exception {
		CoviMap ret = new CoviMap();
		
		CoviMap paramsProcess = new CoviMap();
        CoviMap paramsProcessDes = new CoviMap();
        
        String strFormInstanceID = formRequest.getFormInstanceID();
        String isArchived = formRequest.getArchived();
        String bStored  = formRequest.getBstored();
        
        if(bStored.equalsIgnoreCase("true")) {
        	isArchived = "true";
        }
        else if(!isArchived.equals("") && strFormInstanceID != null && !strFormInstanceID.equals("") ){
        	CoviMap paramID = new CoviMap();
        	paramID.put("FormInstID", strFormInstanceID);
        	isArchived = expenceApplicationSvc.selectFormInstanceIsArchived(paramID);
        }
        
        String strProcessID = formRequest.getProcessID();
        String strWorkitemID = formRequest.getWorkitemID();
        if(!strProcessID.equals("")){
        	paramsProcess.put("processID", strProcessID);
        	paramsProcess.put("workitemID", strWorkitemID);
        	paramsProcess.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	paramsProcess.put("bStored", bStored);
        	
        	CoviMap resultObj = expenceApplicationSvc.selectProcess(paramsProcess);
        	
        	if(((CoviList)resultObj.get("list")).size() == 0 || (formRequest.getIsUser().equals("Y") && expenceApplicationSvc.isDeletedDoc(paramsProcess))) {
        		throw new NoSuchElementException(DicHelper.getDic("msg_apv_082")); //존재하지 않는 결재문서입니다.
        	}
        	
        	CoviMap processObj = (((CoviList)resultObj.get("list")).getJSONObject(0));	// process 및 workitem 조합 데이터
        	
        	// 프로세스 조회 후, 값이 변경된 경우 다시 세팅
        	if(resultObj.containsKey("IsArchived")) {
        		isArchived = resultObj.getString("IsArchived");
        	}
        	if(resultObj.containsKey("bStored")) {
        		bStored = resultObj.getString("bStored");
        	}
        	
        	String strProcessdescriptionID = formRequest.getProcessdescriptionID();
        	if(strProcessdescriptionID.equals("")){
        		strProcessdescriptionID= processObj.getString("ProcessDescriptionID");
        	}
        	
        	String strSubkind = formRequest.getSubkind();
        	if(strSubkind.equals("") && processObj.has("SubKind"))
        		strSubkind = processObj.optString("SubKind");
        	
        	paramsProcessDes.put("processDescID", strProcessdescriptionID);
        	paramsProcessDes.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	paramsProcessDes.put("bStored", bStored);
        	CoviMap processDesObj = (((CoviList)(expenceApplicationSvc.selectProcessDes(paramsProcessDes)).get("list")).getJSONObject(0));
        	
            processObj.put("ProcessDescription",processDesObj);
            
            ret.put("strSubkind", strSubkind);
            ret.put("isArchived", isArchived);
            ret.put("bStored", bStored);
            ret.put("processObj", processObj);
        }
        
        return ret;
	}// make FormJSON
	/**
	 * 
	 * @param formRequest
	 * @param userInfo
	 * @param processObj
	 * @return
	 * @throws Exception
	 */
	public CoviMap createFormJSON(FormRequest formRequest, UserInfo userInfo, CoviMap processObj, CoviMap forms) throws Exception{
		CoviMap ret = new CoviMap();
		
        //CoviMap paramsForms = new CoviMap();
        CoviMap paramsSchema = new CoviMap();
        CoviMap paramsChargeJob = new CoviMap();
        CoviMap paramsFormInstance = new CoviMap();
        
        //CoviMap forms = new CoviMap();
        CoviMap extInfo = new CoviMap();
        CoviMap autoApprovalLine = new CoviMap();
        String strSchemaID = null;
        CoviMap formSchema = new CoviMap();
        CoviMap schemaContext = new CoviMap();	
        CoviMap formInstance = new CoviMap();
        
        String strFormId = formRequest.getFormId();
        String strExpAppID = formRequest.getExpAppID();
        String strFormPrefix = formRequest.getFormPrefix();
        String strReadMode = formRequest.getReadMode();
        
		String strSessionUserID = userInfo.getUserID();
		
		// 임시저장문서(form정보없음) 오픈시 먼저 조회하도록 상단으로 이동
		/*
		paramsForms.put("userID", strSessionUserID);
		if(!strFormId.equals("")){
			paramsForms.put("formID", strFormId);
		}else{
			paramsForms.put("formPrefix", strFormPrefix);
		}
		forms = (((CoviList)(expenceApplicationSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
		*/
		
		if(!forms.get("FormPrefix").equals("")){
			strFormPrefix = forms.optString("FormPrefix");
			formRequest.setFormPrefix(strFormPrefix);
		}
		
		if(!forms.get("ExtInfo").equals("")){
			extInfo = forms.getJSONObject("ExtInfo");
		}
		forms.remove("ExtInfo");

		forms.remove("SubTableInfo");
		
		if(!forms.get("AutoApprovalLine").equals(""))
			autoApprovalLine = forms.getJSONObject("AutoApprovalLine");
		/* 자동결재선(설정)의 가공된 결재선 : workedApprovalLine 추가 */
		forms.remove("AutoApprovalLine");
		
		// 양식 도움말과 양식 팝업 내용 디코딩
		if(forms.has("FormHelperContext") && !forms.get("FormHelperContext").equals("")){
			forms.put("FormHelperContext", new String(Base64.decodeBase64(forms.optString("FormHelperContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		if(forms.has("FormNoticeContext") && !forms.get("FormNoticeContext").equals("")){
			forms.put("FormNoticeContext", new String(Base64.decodeBase64(forms.optString("FormNoticeContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		
		strSchemaID = forms.getString("SchemaID");
		
		String strFormInstanceID = formRequest.getFormInstanceID();
		if(strFormInstanceID != null && !strFormInstanceID.equals("")){
			paramsFormInstance.put("formInstID", strFormInstanceID);
			formInstance = (((CoviList)(expenceApplicationSvc.selectFormInstance(paramsFormInstance)).get("list")).getJSONObject(0));
			
			formInstance.remove("BodyContext");
			
			if(formInstance.has("AttachFileInfo") && !formInstance.get("AttachFileInfo").equals("")) {
				formInstance.put("AttachFileInfo", CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("AttachFileInfo").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8)));
			}
			
			if(formInstance.containsKey("SchemaID") && !strReadMode.equalsIgnoreCase("TEMPSAVE")) {
				strSchemaID = (String) formInstance.get("SchemaID");
			}
		}
		
		//SchemaContext
		paramsSchema.put("schemaID", strSchemaID);
		formSchema = (((CoviList)(expenceApplicationSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0));
		
		if(!formSchema.get("SchemaContext").equals(""))
			schemaContext = formSchema.getJSONObject("SchemaContext");
		
		paramsChargeJob.put("ExpAppID", strExpAppID);
		CoviMap expInfo = expenceApplicationSvc.selectChargeJob(paramsChargeJob);
		String strChargeJob = expInfo.optString("ChargeJob");
		String strRegisterID = expInfo.optString("RegisterID");
		
		//담당업무함 스키마 데이터 변경
		CoviMap scChgr = schemaContext.getJSONObject("scChgr");
		scChgr.put("value", strChargeJob);
		if(StringUtil.isNotNull(strChargeJob)) scChgr.put("isUse", "Y");
		
		// ApprovalLine
		CoviMap approvalLine = setDomainData(strReadMode, userInfo.getUserID(), userInfo.getDeptID(), formRequest.getProcessID(), formRequest.getArchived(), formRequest.getBstored(), formRequest.getParentProcessID(), schemaContext);
		
		String strRequestFormInstID = formRequest.getRequestFormInstID();
		
		//자동 결재선 Data 생성
		CoviMap allAutoLine = setAutoDomainData(autoApprovalLine, userInfo, formRequest.getFormTempInstanceID(), strReadMode, schemaContext.getJSONObject("scStep"), strFormPrefix, strRequestFormInstID, strExpAppID);
	
		CoviMap workedAutoApprovalLine = allAutoLine.getJSONObject("autoDomainData");
		
		autoApprovalLine = allAutoLine.getJSONObject("autoApprovalLine");
		
		// Request
		CoviMap requestData = new CoviMap();
		/* loct 포함 -> CheckLoct()함수 값 */
		requestData.put("editmode", formRequest.getEditMode());
		requestData.put("admintype", formRequest.getAdmintype());
		requestData.put("isAuth", formRequest.getIsAuth());
		requestData.put("mode", strReadMode);
		requestData.put("processID", formRequest.getProcessID());
		requestData.put("workitemID", formRequest.getWorkitemID());
		requestData.put("performerID", formRequest.getPerformerID());
		requestData.put("userCode", formRequest.getUserCode());
		requestData.put("gloct", formRequest.getGLoct());
		requestData.put("formID", strFormId);
		requestData.put("forminstanceID", strFormInstanceID);
		requestData.put("subkind", formRequest.getSubkind());
		requestData.put("formtempID", formRequest.getFormTempInstanceID());
		requestData.put("forminstancetablename", formRequest.getFormInstanceTableName());
		requestData.put("readtype", formRequest.getReadtype());
		requestData.put("processdescriptionID", formRequest.getProcessdescriptionID());
		requestData.put("reuse", formRequest.getIsReuse());
		requestData.put("ishistory", formRequest.getIsHistory());
		requestData.put("usisdocmanager", formRequest.getIsUsisdocmanager());
		requestData.put("secdoc", formRequest.getIsSecdoc());
		
		requestData.put("isTempSaveBtn", formRequest.getIsTempSaveBtn());
		requestData.put("legacyDataType", formRequest.getLegacyDataType());
		
		requestData.put("templatemode", "Read");
		
		requestData.put("expAppID", formRequest.getExpAppID());
		requestData.put("scount", formRequest.getScount());
		requestData.put("bserial", formRequest.getBserial());
		requestData.put("listpreview", formRequest.getListPreview());
		
		String strProcessID = formRequest.getProcessID();
		if(strProcessID == null || strProcessID.equals("") || processObj.isNullObject() || processObj.isEmpty() ){
			requestData.put("loct", strReadMode);
		}else{
			requestData.put("loct", getLOCTData(formRequest, strReadMode, userInfo.getUserID(), userInfo.getApvDeptID(), userInfo.getDNCode(), processObj));
		}
		
		requestData.put("isMobile", formRequest.getIsMobile());
		
		// AppInfo - Session, 기타 등
		CoviMap appInfo = new CoviMap();
		
		UserInfo tmpUserInfo = userInfo;
		if(strReadMode.equalsIgnoreCase("TEMPSAVE") && formRequest.getGLoct().equalsIgnoreCase("ADMTEMPSAVE")) {
			// 관리자페이지 임시저장문서보기 : 양식 내 세션사용자 정보를 기안자 정보로 변경 (경비결재는 관리자 전표관리)
			// 경비결재 임시문서는 forminstance가 없고 expence_application에 부서정보가 없어서 본직으로 조회
			//tmpUserInfo = initUserInfo(formInstance.optString("InitiatorID"),formInstance.optString("InitiatorUnitID"));
			tmpUserInfo = initUserInfo(strRegisterID, "");
		}
		
		appInfo.put("usid", tmpUserInfo.getUserID());
		appInfo.put("usnm", tmpUserInfo.getUserName());
		appInfo.put("dpid", tmpUserInfo.getDeptID());
		appInfo.put("dpnm", tmpUserInfo.getDeptName());	
		appInfo.put("dpid_apv", tmpUserInfo.getApvDeptID());				
		appInfo.put("dpdn_apv", tmpUserInfo.getApvDeptName());
		appInfo.put("etnm", tmpUserInfo.getDNName());
		appInfo.put("etid", tmpUserInfo.getDNCode());
		appInfo.put("ussip", tmpUserInfo.getUserMail());				// 임의. 이메일 주소
		appInfo.put("sabun",  tmpUserInfo.getUserEmpNo());										// 사번
		
		appInfo.put("uspc", tmpUserInfo.getJobPositionCode());		// 직위 코드
		appInfo.put("uspn", tmpUserInfo.getJobPositionName());		// 직위 명
		appInfo.put("ustc", tmpUserInfo.getJobTitleCode());				// 직책 명
		appInfo.put("ustn", tmpUserInfo.getJobTitleName());				// 직책 코드
		appInfo.put("uslc", tmpUserInfo.getJobLevelCode());				// 직급 명
		appInfo.put("usln", tmpUserInfo.getJobLevelName());			// 직급 코드
		
		appInfo.put("grpath", tmpUserInfo.getDeptPath());
		appInfo.put("grfullname", tmpUserInfo.getGRFullName()); 			//dppathdn
		
		appInfo.put("managercode", tmpUserInfo.getURManagerCode());
		appInfo.put("managername", tmpUserInfo.getURManagerName());
		appInfo.put("usismanager", tmpUserInfo.getURIsManager());
		
		appInfo.put("hasWriteAuth",tmpUserInfo.isHasWriteAuth());
		
		String dateFormat = "yyyy-MM-dd HH:mm:ss";
		appInfo.put("svdt", DateHelper.getCurrentDay(dateFormat));
		
		// GMT 기준시간 추가
		if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
			appInfo.put("svdt_TimeZone", DateHelper.getCurrentDay(dateFormat));
		}
		else { // 타임존 사용하는 경우
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			appInfo.put("svdt_TimeZone", sdf.format(new Date()));	
		}
		
		appInfo.put("usit", tmpUserInfo.getUserSignFileID());			// 서명이미지
		
		appInfo.put("usnm_multi", tmpUserInfo.getUserMultiName());
		appInfo.put("uspn_multi", tmpUserInfo.getUserMultiJobPositionName());
		appInfo.put("ustn_multi", tmpUserInfo.getUserMultiJobTitleName());
		appInfo.put("usln_multi", tmpUserInfo.getUserMultiJobLevelName());
		appInfo.put("dpnm_multi", tmpUserInfo.getDeptMultiName());
		
		//appInfo.put("ustp", SessionHelper.getSession("PhoneNumber"));
		//appInfo.put("usfx", SessionHelper.getSession("Fax"));
		appInfo.put("ustp", tmpUserInfo.getUserPhoneNumber());
		appInfo.put("usfx", tmpUserInfo.getUserFax());
		
		CoviMap formJson = new CoviMap();
		formJson.put("FormInfo", forms);
		formJson.put("FormInstanceInfo", formInstance);
		formJson.put("ProcessInfo", processObj);				// process 및 workitem 조합 데이터
		formJson.put("SchemaContext", schemaContext);
		formJson.put("ApprovalLine", AccountUtil.changeCommentFileInfos(approvalLine));
		formJson.put("AutoApprovalLine", autoApprovalLine);
		formJson.put("WorkedAutoApprovalLine", workedAutoApprovalLine);
		formJson.put("ExtInfo", extInfo);
		formJson.put("Request", requestData);
		formJson.put("AppInfo", appInfo);
		
		ret.put("formJson", formJson);
		
		return ret;
	}
	
	// 자동결재선 세팅 함수 -> 추가적인 개발이 필요함
	public CoviMap setAutoDomainData(CoviMap autoApprovalLine, UserInfo formSession, String strFormTempInstanceID, String strReadMode, CoviMap scStep, String strFormPrefix, String strRequestFormInstID, String strExpAppID) throws Exception{
		// 양식 설정의 자동결재선
		autoApprovalLine = autoApprovalLineService.setFormAutoApprovalData(autoApprovalLine, formSession.getDNCode(), formSession.getUserRegionCode());
		
		// 양식 설정의 자동결재선 이외의 자동결재선		
		CoviMap autoDomainData = new CoviMap();
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		CoviList selectData = new CoviList();
		
		// 임시저장 결재선 조회
		if(strFormTempInstanceID != null && !strFormTempInstanceID.equals("")){
			params.put("OwnerID", strFormTempInstanceID);
        	
        	returnData = (((CoviList)(expenceApplicationSvc.selectPravateDomainData(params)).get("list")).getJSONObject(0));
        	autoDomainData = returnData.getJSONObject("PrivateContext");
		}else if(StringUtil.replaceNull(strReadMode).equals("TEMPSAVE")){ 
			params.put("OwnerID", "ACCOUNT_" + strExpAppID);
			
			selectData = (CoviList)(expenceApplicationSvc.selectPravateDomainData(params)).get("list");
			if(!selectData.isEmpty()){
        		returnData = selectData.getJSONObject(0);
        		autoDomainData = returnData.getJSONObject("PrivateContext");
        	}
		}else{
			if(( (strReadMode.equals("DRAFT") && (strRequestFormInstID == null || strRequestFormInstID.equals(""))) || strReadMode.equals("TEMPSAVE")) ||  strReadMode.equals("REDRAFT")){
				// 주결재선 조회
				params.put("OwnerID", formSession.getUserID());
				params.put("DefaultYN", "Y");
            	
				selectData = (CoviList)(expenceApplicationSvc.selectPravateDomainData(params)).get("list");
            	if(!selectData.isEmpty()){
            		returnData = selectData.getJSONObject(0);
            		autoDomainData = returnData.getJSONObject("PrivateContext");
            	}
            	
				if(returnData.isNullObject() || returnData.isEmpty()){
					
					// 부서장 결재 단계 사용
					if (( strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE")) && scStep.getString("isUse").equals("Y") && !scStep.getString("value").equals("")){
						
						String[] aOUCodes = formSession.getDeptPath().split(";");
                        //다국어 처리를 위해 요청자 세션의 부서 명칭 가져옮
						String[] aOUNames = formSession.getGRFullName().split("@");
						int nStep = Integer.parseInt(scStep.getString("value"));
						
						int nCount = 0;
						CoviMap oSteps = new CoviMap();
						
						CoviList oStepArr = new CoviList();
						
						oSteps.put("status", "inactive");
						
						for (int i = aOUCodes.length - 1; i >= 0; i--)
						{
							if(!aOUCodes[i].equalsIgnoreCase("ORGROOT") && !(formSession.getURIsManager().equalsIgnoreCase("TRUE") && i == aOUCodes.length - 1)){				// TODO 부서장이 기안할 경우에는 자신이 포함된 부서를 제외해야 하며, ORGROOT 도 제외되어야 함
								nCount++;
								if (nCount <= nStep)
								{
									CoviMap oStep = new CoviMap();
									CoviMap oOu = new CoviMap();
									CoviMap oRole = new CoviMap();
									CoviMap oTaskInfo = new CoviMap();
									
										
										oStep.put("unittype", "role");
										oStep.put("routetype", "approve");
										oStep.put("name", "일반결재");
										
										oOu.put("code", aOUCodes[i]);
										oOu.put("name", aOUNames[i]);
										
										oRole.put("code", "UNIT_MANAGER");
										oRole.put("name", aOUNames[i]);
										oRole.put("oucode", aOUCodes[i]);
										oRole.put("ouname", aOUNames[i]);
										
										oTaskInfo.put("status", "inactive");
										oTaskInfo.put("result", "inactive");
										oTaskInfo.put("kind", "normal");
										
										oRole.put("taskinfo", oTaskInfo);
										
										oOu.put("role", oRole);
										
										oStep.put("ou", oOu);
										
										oStepArr.add(oStep);

								}
							}
						}

						oSteps.put("step", oStepArr);
						returnData.put("steps", oSteps);
						autoDomainData = returnData;
					}else{
						//양식별 개인 최종 결재선
						params.clear();
		            	
						if(strReadMode.equals("DRAFT")){
							params.put("OwnerID", formSession.getUserID() + "_" + strFormPrefix);
						}else if(strReadMode.equals("REDRAFT")){
							params.put("OwnerID", formSession.getUserID() + "_" + strFormPrefix + "_REDRAFT");
						}
						
						selectData = (CoviList)(expenceApplicationSvc.selectPravateDomainData(params)).get("list");
						if(!selectData.isEmpty()){
		            		returnData = selectData.getJSONObject(0);
		            		autoDomainData = returnData.getJSONObject("PrivateContext");
		            	}
					}
				}
			}
		}
        
		CoviMap returnObj = new CoviMap();
		returnObj.put("autoApprovalLine", autoApprovalLine);
		returnObj.put("autoDomainData", autoDomainData);
			
        return returnObj;
    }
	
	public String getLOCTData(FormRequest formRequest, String strReadMode, String strSessionUserID, String strSessionDeptID, String strSessionDNCode, CoviMap processObj) {
		String strLoct = "";

		String processState = processObj.optString("ProcessState");
		String workitemState = processObj.has("State") ? processObj.optString("State") : "";
		String strDeputyID = processObj.has("DeputyID") ? processObj.optString("DeputyID") : "";
		
        if (strReadMode.equals("APPROVAL") || strReadMode.equals("PCONSULT") || strReadMode.equals("SUBAPPROVAL") || strReadMode.equals("RECAPPROVAL") || strReadMode.equals("AUDIT")
        		|| strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){
            if (!processState.equals("288")){//(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            } else {
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                } else {
                    if (strSessionUserID.equals(formRequest.getUserCode())
                    		|| strSessionUserID.equals(processObj.has("UserCode") ? processObj.optString("UserCode") : "") 
                    		|| strSessionUserID.equals(strDeputyID)){
                        strLoct = formRequest.getReadModeTemp();
                    } else if(formRequest.getGLoct().equals("DEPART") && (
                    		strSessionDeptID.equals(formRequest.getUserCode())
                    		|| strSessionDeptID.equals(processObj.has("UserCode") ? processObj.optString("UserCode") : "")
                    		)) {
                        strLoct = formRequest.getReadModeTemp();
                    } else if(formRequest.getGLoct().equals("JOBFUNCTION")){
                    	CoviMap params = new CoviMap();
                		params.put("FormInstID", formRequest.getFormInstanceID());
                		params.put("UserID", strSessionUserID);
                		params.put("DeptID", strSessionDeptID);
                		params.put("entCode", strSessionDNCode);
                		if(expenceApplicationSvc.isJobFunctionManager(params)) strLoct = formRequest.getReadModeTemp();
                		else strLoct = "PROCESS"; 
                    } else {
                        strLoct = "PROCESS";
                    }
                }
            }
        } 
//        else if (strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){
//            if (!processState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
//                strLoct = "COMPLETE";
//            } else {
//                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
//                    strLoct = "PROCESS";
//                } else {
//                    strLoct = formRequest.getReadModeTemp();
//                }
//            }
//        } 
        else if (strReadMode.equals("REJECT")){
        	strLoct = "REJECT";
        } else if ((strReadMode.equals("CONSULT") || strReadMode.equals("CONSULTATION")) && workitemState.equals("288")){
        	strLoct = "APPROVAL";
        } else {
            strLoct = formRequest.getReadModeTemp();
        }

        return strLoct;
    }
	
	// ApprovalLine - 결재선
	public CoviMap setDomainData(String strReadMode, String strSessionUserID, String strSessionDeptID, String strProcessID, String isArchived, String bStored, String strParentProcessID, CoviMap schemaContext) throws Exception {
		// ApprovalLine
		CoviMap paramsDomain = new CoviMap();
		CoviMap domainData = new CoviMap();
		CoviMap parentDomainData = new CoviMap();
		CoviMap approvalLine = new CoviMap();
		CoviMap parentApprovalLine = new CoviMap();
		
		if (strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE") || strReadMode.equals("TEMPSAVE_BOX") || strReadMode.equals("PREDRAFT") || bStored.equalsIgnoreCase("true"))
        {
			CoviMap steps = new CoviMap();
			steps.put("status", "inactive");
			steps.put("initiatoroucode", strSessionDeptID);
			steps.put("initiatorcode", strSessionUserID);
			approvalLine.put("steps", steps);			
        }else{
			if(strProcessID != null && !strProcessID.equals("")){
				// 신청 프로세스 기준으로 분기
				String processType = ((CoviMap)schemaContext.get("pdef")).optString("value");
				if(isArchived.equals("true") && processType.indexOf("request") > -1) {
					if(!strParentProcessID.equals("0"))
						paramsDomain.put("processID", strParentProcessID);
					else
						paramsDomain.put("processID", strProcessID);
				} else {
					paramsDomain.put("processID", strProcessID);
				}
				
				paramsDomain.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
				paramsDomain.put("bStored", bStored);
				domainData = (((CoviList)(expenceApplicationSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
				
				if(!domainData.get("DomainDataContext").equals(""))
					approvalLine = domainData.getJSONObject("DomainDataContext");
				
				if(isArchived.equals("true") && processType.indexOf("request") == -1 && hasReviewerStep(approvalLine)){
					if(strParentProcessID.equals("0"))
						paramsDomain.put("processID", strProcessID);
					else
						paramsDomain.put("processID", strParentProcessID);
					
					parentDomainData = (((CoviList)(expenceApplicationSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
					parentApprovalLine = parentDomainData.getJSONObject("DomainDataContext");
					
					// Parent - domaindata
					CoviMap s = new CoviMap();
					s = (CoviMap)parentApprovalLine.get("steps");
					
					Object divisionO = s.get("division");
					CoviList divisonArr = new CoviList();
					if(divisionO instanceof CoviMap){
						CoviMap divJsonObj = (CoviMap)divisionO;
						divisonArr.add(divJsonObj);
					} else {
						divisonArr = (CoviList)divisionO;
					}
					
					// Basic - domaindata
					s = (CoviMap)approvalLine.get("steps");
					
					divisionO = s.get("division");
					CoviList divs = new CoviList();
					if(divisionO instanceof CoviMap){
						CoviMap divJsonObj = (CoviMap)divisionO;
						divs.add(divJsonObj);
					} else {
						divs = (CoviList)divisionO;
					}
					
					// parent 기준으로 기안부서 데이터 덮어쓰기
					divs.remove(0);
					divs.add(0, divisonArr.get(0));
					
					s.put("division", divs);
				}
			}
        }
		
		return approvalLine;
	}
	
	// 후결자 존재 여부 체크
	public boolean hasReviewerStep(CoviMap apvLineObj) {
		boolean ret = false;
		
		CoviMap root = (CoviMap)apvLineObj.get("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		CoviMap division = (CoviMap)divisions.get(0);
			
		Object stepO = division.get("step");
		CoviList steps = new CoviList();
		if(stepO instanceof CoviMap){
			CoviMap stepJsonObj = (CoviMap)stepO;
			steps.add(stepJsonObj);
		} else {
			steps = (CoviList)stepO;
		}
		
		String unitType = "";
		
		for(int i = 0; i < steps.size(); i++)
		{
			unitType = "";
			
			CoviMap s = (CoviMap)steps.get(i);
			
			unitType = (String)s.get("unittype");
			
			//jsonarray와 jsonobject 분기 처리
			Object ouObj = s.get("ou");
			CoviList ouArray = new CoviList();
			if(ouObj instanceof CoviList){
				ouArray = (CoviList)ouObj;
			} else {
				ouArray.add(ouObj);
			}
			
			for(int j = 0; j < ouArray.size(); j++)
			{
				CoviMap ouObject = (CoviMap)ouArray.get(j);
				CoviMap taskObject = new CoviMap();
				if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
					Object personObj = ouObject.get("person");
					CoviList persons = new CoviList();
					if(personObj instanceof CoviMap){
						CoviMap jsonObj = (CoviMap)personObj;
						persons.add(jsonObj);
					} else {
						persons = (CoviList)personObj;
					}
					
					CoviMap personObject = (CoviMap)persons.get(0);
					taskObject = (CoviMap)personObject.get("taskinfo");
					
					//전달 처리
					if(taskObject.optString("kind").equalsIgnoreCase("conveyance")){
						CoviMap forwardedPerson = (CoviMap)persons.get(1);
						taskObject = (CoviMap)forwardedPerson.get("taskinfo");
					}
					
				} else if(ouObject.containsKey("role")) {
					CoviMap role = new CoviMap();
					role = (CoviMap)ouObject.get("role");
					taskObject = (CoviMap)role.get("taskinfo");
				} else {
					taskObject = (CoviMap)ouObject.get("taskinfo");
				}
				
				if(taskObject.optString("kind").equalsIgnoreCase("review")){
					ret = true;
					break;
				}	
			}	      
		}
		
		return ret;
	}
	
	private UserInfo initUserInfo() throws Exception {
		UserInfo fSes = new UserInfo();
		//세션 값
        fSes.setUserID(SessionHelper.getSession("USERID"));
        fSes.setUserName(SessionHelper.getSession("USERNAME"));
        fSes.setUserMail(SessionHelper.getSession("UR_Mail"));
        fSes.setUserEmpNo(SessionHelper.getSession("UR_EmpNo"));
        fSes.setDeptID(SessionHelper.getSession("DEPTID"));
        fSes.setDeptName(SessionHelper.getSession("DEPTNAME"));
        fSes.setDNName(SessionHelper.getSession("DN_Name"));
        fSes.setDNCode(SessionHelper.getSession("DN_Code"));
        
        fSes.setJobPositionCode(SessionHelper.getSession("UR_JobPositionCode"));
        fSes.setJobPositionName(SessionHelper.getSession("UR_JobPositionName"));
        fSes.setJobTitleCode(SessionHelper.getSession("UR_JobTitleCode"));
        fSes.setJobTitleName(SessionHelper.getSession("UR_JobTitleName"));
        fSes.setJobLevelCode(SessionHelper.getSession("UR_JobLevelCode"));
        fSes.setJobLevelName(SessionHelper.getSession("UR_JobLevelName"));
        
        fSes.setDeptPath(SessionHelper.getSession("GR_GroupPath"));
        fSes.setGRFullName(SessionHelper.getSession("GR_FullName"));

        fSes.setURManagerCode(SessionHelper.getSession("UR_ManagerCode"));
        fSes.setURManagerName(SessionHelper.getSession("UR_ManagerName"));
        fSes.setURIsManager(SessionHelper.getSession("UR_IsManager"));
        
        // 사용자, 부서 다국어명 추가
        fSes.setUserMultiName(SessionHelper.getSession("UR_MultiName"));
        fSes.setUserMultiJobPositionName(SessionHelper.getSession("UR_MultiJobPositionName"));
        fSes.setUserMultiJobTitleName(SessionHelper.getSession("UR_MultiJobTitleName"));
        fSes.setUserMultiJobLevelName(SessionHelper.getSession("UR_MultiJobLevelName"));
        fSes.setDeptMultiName(SessionHelper.getSession("GR_MultiName"));
        
        // 사용자 사업장 추가
        fSes.setUserMultiRegionName(SessionHelper.getSession("UR_MultiRegionName"));
        fSes.setUserRegionCode(SessionHelper.getSession("UR_RegionCode"));

        // 결재 부서
        fSes.setApvDeptID(SessionHelper.getSession("ApprovalParentGR_Code"));
        fSes.setApvDeptName(StringUtil.replaceNull(SessionHelper.getSession("ApprovalParentGR_Name"),SessionHelper.getSession("GR_MultiName")));
        
        fSes.setUserPhoneNumber(SessionHelper.getSession("PhoneNumber"));
        fSes.setUserFax(SessionHelper.getSession("Fax"));
        
        return fSes;
	}
	
	private UserInfo initUserInfo(String UserCode, String DeptCode) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap userInfo = new CoviMap();
		params.put("id", UserCode);
		params.put("deptId", DeptCode);
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("idType", "UserCode");
		userInfo = expenceApplicationSvc.selectUserInfo(params);
		
		UserInfo fSes = new UserInfo();
		
		//세션 값
        fSes.setUserID(userInfo.optString("UR_ID"));
        fSes.setUserName(userInfo.optString("UR_Name"));
        fSes.setUserMail(userInfo.optString("UR_Mail"));
        fSes.setUserEmpNo(userInfo.optString("UR_EmpNo"));
        fSes.setDeptID(userInfo.optString("GR_Code"));
        fSes.setDeptName(userInfo.optString("GR_Name"));
        fSes.setDNName(userInfo.optString("DN_Name"));
        fSes.setDNCode(userInfo.optString("DN_Code"));
        
        fSes.setJobPositionCode(userInfo.optString("UR_JobPositionCode"));
        fSes.setJobPositionName(userInfo.optString("UR_JobPositionName"));
        fSes.setJobTitleCode(userInfo.optString("UR_JobTitleCode"));
        fSes.setJobTitleName(userInfo.optString("UR_JobTitleName"));
        fSes.setJobLevelCode(userInfo.optString("UR_JobLevelCode"));
        fSes.setJobLevelName(userInfo.optString("UR_JobLevelName"));
        
        fSes.setDeptPath(userInfo.optString("GR_GroupPath"));
        fSes.setGRFullName(userInfo.optString("GR_FullName")); 

        fSes.setURManagerCode(userInfo.optString("UR_ManagerCode"));
        fSes.setURManagerName(userInfo.optString("UR_ManagerName"));
        fSes.setURIsManager(userInfo.optString("UR_IsManager"));
        
        // 사용자, 부서 다국어명 추가
        fSes.setUserMultiName(userInfo.optString("UR_MultiName"));
        fSes.setUserMultiJobPositionName(userInfo.optString("UR_MultiJobPositionName"));
        fSes.setUserMultiJobTitleName(userInfo.optString("UR_MultiJobTitleName"));
        fSes.setUserMultiJobLevelName(userInfo.optString("UR_MultiJobLevelName"));
        fSes.setDeptMultiName(userInfo.optString("GR_MultiName"));
        
        // 사용자 사업장 추가
        fSes.setUserMultiRegionName(userInfo.optString("UR_MultiRegionName"));
        fSes.setUserRegionCode(userInfo.optString("UR_RegionCode"));

        // 결재 부서
        fSes.setApvDeptID(userInfo.optString("ApprovalParentGR_Code")); 
        //fSes.setApvDeptName(formSvc.selectDeptName(fSes.getApvDeptID()));
        fSes.setApvDeptName(StringUtil.replaceNull(userInfo.optString("ApprovalParentGR_Name"),userInfo.optString("GR_MultiName")));

        fSes.setUserPhoneNumber(userInfo.optString("PhoneNumber")); // PhoneNumber/PhoneNumberInter/Mobile
        fSes.setUserFax(userInfo.optString("Fax")); // Fax
        
        return fSes;
	}
	
	private FormRequest initFormRequest(HttpServletRequest request){
		FormRequest fReq = new FormRequest();
		
		/** Request */
		// ID
        fReq.setProcessID(StringUtil.replaceNull(request.getParameter("processID"), ""));
        fReq.setWorkitemID(StringUtil.replaceNull(request.getParameter("workitemID"), ""));
        fReq.setPerformerID(StringUtil.replaceNull(request.getParameter("performerID"), ""));
        fReq.setFormId(StringUtil.replaceNull(request.getParameter("formID"), ""));
        fReq.setFormInstanceID(StringUtil.replaceNull(request.getParameter("forminstanceID"), ""));
        fReq.setFormTempInstanceID(StringUtil.replaceNull(request.getParameter("formtempID"), ""));
        fReq.setProcessdescriptionID(StringUtil.replaceNull(request.getParameter("processdescriptionID"), ""));
        
        // mode 및 gloct, loct
        fReq.setReadMode(StringUtil.replaceNull(request.getParameter("mode"), "").trim());
        fReq.setReadModeTemp(StringUtil.replaceNull(request.getParameter("mode"), "").trim());
        fReq.setReadtype(StringUtil.replaceNull(request.getParameter("Readtype"), ""));
        fReq.setGLoct(StringUtil.replaceNull(request.getParameter("gloct"), ""));
        
        fReq.setUserCode(StringUtil.replaceNull(request.getParameter("userCode"), "")); // User Code (세션 정보 X, Performer 및 Workitem의 UserCode)
        fReq.setSubkind(StringUtil.replaceNull(request.getParameter("subkind"), ""));
        fReq.setFormInstanceTableName(StringUtil.replaceNull(request.getParameter("forminstancetablename"), ""));
        fReq.setFormPrefix(StringUtil.replaceNull(request.getParameter("formPrefix"), ""));
        fReq.setRequestFormInstID(StringUtil.replaceNull(request.getParameter("RequestFormInstID"), ""));
        
        //편집할 때 request로 받은 데이터로 세팅
        if(request.getParameter("DocModifyApvLine") != null && !request.getParameter("DocModifyApvLine").equals(""))
        	fReq.setDocModifyApvLine(CoviMap.fromObject(request.getParameter("DocModifyApvLine").replace("&quot;", "\"")));
        
		// 구분값 (Y | N)
        fReq.setEditMode(StringUtil.replaceNull(request.getParameter("editMode"), "N")); // 편집 모드
        fReq.setArchived(StringUtil.replaceNull(request.getParameter("archived"), "false")); // archived. 완료 여부
        fReq.setBstored(StringUtil.replaceNull(request.getParameter("bstored"), "false")); // bStored. 이관함 여부
        fReq.setAdmintype(StringUtil.replaceNull(request.getParameter("admintype"), "")); // 관리자 페이지에서 조회시 ADMIN
        fReq.setIsAuth(StringUtil.replaceNull(request.getParameter("isAuth"), "")); 									// 사용자 문서함 권한 부여 여부
        fReq.setIsReuse(StringUtil.replaceNull(request.getParameter("reuse"), "")); 									// 재사용 여부
        fReq.setIsHistory(StringUtil.replaceNull(request.getParameter("ishistory"), "")); // 히스토리 여부
        fReq.setIsUsisdocmanager(StringUtil.replaceNull(request.getParameter("usisdocmanager"), "")); // 문서 관리자 여부. Y
        fReq.setIsTempSaveBtn(StringUtil.replaceNull(request.getParameter("isTempSaveBtn"), "Y")); // 임시저장 버튼 표시 여부
        fReq.setIsgovDocReply(StringUtil.replaceNull(request.getParameter("isgovDocReply"), "N")); // 문서24 개인사용자에 대한 회신표시 여부
        fReq.setSenderInfo(StringUtil.replaceNull(request.getParameter("senderInfo"), "")); // 문서24 발신한 개인사용자 정보
        fReq.setGovFormInstID(StringUtil.replaceNull(request.getParameter("govFormInstID"), "")); // 문서24 개인회신을 위한 접수문서 frminstid
        
        fReq.setIsSecdoc(StringUtil.replaceNull(request.getParameter("secdoc"), "")); // 기밀문서 여부
        fReq.setIsMobile(StringUtil.replaceNull(request.getParameter("isMobile"), "N"));
        fReq.setIsApvLineChg(StringUtil.replaceNull(request.getParameter("isApvLineChg"), "N"));
        fReq.setIsLegacy(StringUtil.replaceNull(request.getParameter("isLegacy"), "")); // 외부 연동 여부 (기안 양식 오픈을 외부에서)
        
        fReq.setJsonBodyContext(StringUtil.replaceNull(request.getParameter("jsonBody"), "")); // 외부 연동시 기안 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setHtmlBodyContext(StringUtil.replaceNull(request.getParameter("htmlBody"), "")); // 외부 연동시 기안 html (기안 양식 오픈을 외부에서)
        fReq.setMobileBodyContext(StringUtil.replaceNull(request.getParameter("mobileBody"), "")); // 외부 연동시 기안 html - 모바일 용
        fReq.setLegacyBodyContext(StringUtil.replaceNull(request.getParameter("bodyContext"), "")); // 외부 연동시 기안 html 과 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setSubject(StringUtil.replaceNull(request.getParameter("subject"), "")); // 외부 연동시 제목 (기안 양식 오픈을 외부에서)
        fReq.setLegacyDataType(StringUtil.replaceNull(request.getParameter("legacyDataType"), ""));	// 외부 연동 데이터 타입
        
        fReq.setMenuKind(StringUtil.replaceNull(request.getParameter("menukind"), "")); // 양식 구분값(전자결재/문서유통)
        fReq.setDoclisttype(StringUtil.replaceNull(request.getParameter("doclisttype"), ""));
        fReq.setGovState(StringUtil.replaceNull(request.getParameter("GovState"), ""));
        fReq.setGovDocID(StringUtil.replaceNull(request.getParameter("GovDocID"), ""));
        fReq.setGovRecordID(StringUtil.replaceNull(request.getParameter("GovRecordID"), ""));
        
        fReq.setOwnerProcessId(StringUtil.replaceNull(request.getParameter("ownerProcessId"), ""));
        
        fReq.setExpAppID(StringUtil.replaceNull(request.getParameter("ExpAppID"), "")); // 경비결재 오픈 여부 확인
        fReq.setIsUser(StringUtil.replaceNull(request.getParameter("isUser"), "N")); // 경비결재 사용자 메뉴 여부
        fReq.setOwnerExpAppID(StringUtil.replaceNull(request.getParameter("ownerExpAppID"), "")); // 경비결재 오픈 여부 확인
        
        fReq.setIsOpen(StringUtil.replaceNull(request.getParameter("isOpen"), "")); // 사업관리 오픈 여부 확인 [21-02-01 add]
        
        fReq.setScount(StringUtil.replaceNull(request.getParameter("scount"), ""));
        fReq.setBserial(StringUtil.replaceNull(request.getParameter("bserial"), ""));
        fReq.setListPreview(StringUtil.replaceNull(request.getParameter("listpreview"), ""));
        
		return fReq;
	}

	/**
	* @Method Name : ExpenceApplicationListViewPopup
	* @Description : 증빙 조회용 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationListViewPopup.do")
	public ModelAndView expenceApplicationListViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/CombineCostApplicationListView";
		ModelAndView mav = new ModelAndView(returnURL);		
		String expAppListIDs = request.getParameter("expAppListIDs");
		mav.addObject("expAppListIDs", expAppListIDs);
		return mav;
	}

	/**
	* @Method Name : ExpenceApplicationListEditPopup
	* @Description : 증빙 수정 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationListEditPopup.do", method = RequestMethod.GET)
	public ModelAndView expenceApplicationEditPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/CombineCostApplicationListEdit";
		ModelAndView mav = new ModelAndView(returnURL);		
		String ExpAppListID = request.getParameter("ExpAppListID");
		String Revision = request.getParameter("Revision");
		if(Revision != null && !Revision.equals("")) {
			returnURL = returnURL + Revision; //CombineCostApplicationListEditV1
		}
		mav.addObject("ExpAppListID", ExpAppListID);
		return mav;
	}
	
	/**
	* @Method Name : SimpleApplicationModify
	* @Description : 
	*/
	@RequestMapping(value = "expenceApplication/SimpleApplicationModify.do", method = RequestMethod.GET)
	public ModelAndView simpleApplicationModify(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView("user/account/SimpleApplicationModify");
		mav.addObject("ExpAppListID", request.getParameter("ExpAppListID"));
		return mav;
	}
	
	/**
	 * @Method Name : ExpenceApplicationListEditPopup
	 * @Description : 증빙 조회(전체정보) 팝업 호출
	 */
	@RequestMapping(value = "expenceApplication/ExpenceApplicationListDetailViewPopup.do", method = RequestMethod.GET)
	public ModelAndView expenceApplicationListDetailViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/CombineCostApplicationListDetailView";
		ModelAndView mav = new ModelAndView(returnURL);		
		String ExpAppListID = request.getParameter("ExpAppListID");
		mav.addObject("ExpAppListID", ExpAppListID);
		return mav;
	}
	
	/**
	* @Method Name : ExpenceApplicationViewFilePopup
	* @Description : 증빙에 업로드된 파일 팝업
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationViewFilePopup.do", method = RequestMethod.GET)
	public ModelAndView expenceApplicationViewFilePopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/ExpenceApplicationViewFilePopup";
		ModelAndView mav = new ModelAndView(returnURL);		
		String expAppListID = request.getParameter("ExpAppListID");
		mav.addObject("ExpAppListID", expAppListID);
		return mav;
	}
	
	/**
	* @Method Name : searchExpenceApplicationFileList
	* @Description : 증빙 업로드 파일 목록
	*/
	@RequestMapping(value = "expenceApplication/searchExpenceApplicationFileList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplicationFileList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {

			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);

			String expAppListID =  request.getParameter("ExpAppListID");
			params.put("ExpenceApplicationListID", expAppListID);
			resultList = expenceApplicationSvc.searchExpenceApplicationFileList(params);
			
			CoviMap page = new CoviMap();
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			int cnt = resultList.getInt("cnt");
			page.put("pageNo", pageNo);
			page.put("pageSize", pageSize);

			page.addAll(ComUtils.setPagingData(page,cnt));
	
			returnList.put("page", page);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	//중복기안 체크
	@RequestMapping(value = "expenceApplication/ExpenceApplicationDuplicateCheck.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap expenceApplicationDuplicateCheck(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String StrDupl = StringEscapeUtils.unescapeHtml(request.getParameter("duplObj"));
			CoviMap duplObj = CoviMap.fromObject(StrDupl);

			CoviMap returnObj = new CoviMap();
			returnObj = expenceApplicationSvc.expenceApplicationDuplicateCheck(duplObj);
			
			returnList.put("duplChk", AccountUtil.jobjGetStr(returnObj, "duplChk"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : saveExpenceApplication
	* @Description : 경비신청 저장
	*/
	@RequestMapping(value = "expenceApplication/saveExpenceApplication.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveExpenceApplication(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String sobj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			
			CoviMap saveObj = CoviMap.fromObject(sobj);

			String isSearched = AccountUtil.jobjGetStr(saveObj, "isSearched");
			String isNew = AccountUtil.jobjGetStr(saveObj, "isNew");
			String ApplicationStatus = AccountUtil.jobjGetStr(saveObj, "ApplicationStatus");

			String userID = SessionHelper.getSession("USERID");
			saveObj.put("UserID", userID);
			
			CoviMap returnObj = new CoviMap();
			
			CoviMap duplObj = expenceApplicationSvc.duplCkExpenceApplicationList(saveObj);
			int totalCnt = 0; 
			if(duplObj != null)
				totalCnt = duplObj.getInt("TotalCnt");
			if(totalCnt == 0){
				if("Y".equals(isSearched) || "N".equals(isNew)){
					returnObj = expenceApplicationSvc.updateExpenceApplication(saveObj);
				}else{
					returnObj = expenceApplicationSvc.insertExpenceApplication(saveObj);
				}
	
				if("T".equals(ApplicationStatus)) {
					CoviMap domainParam = new CoviMap();
					domainParam.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey"));
					domainParam.put("ApplicationTitle", AccountUtil.jobjGetStr(saveObj, "ApplicationTitle"));
					domainParam.put("ApprovalLine", saveObj.get("ApprovalLine"));
					domainParam.put("FormName", AccountUtil.jobjGetStr(saveObj, "FormName"));
					expenceApplicationSvc.savePrivateDomainData(domainParam); //임시저장 시 결재선 저장
				}
				
				returnList.put("data", returnObj);
				returnList.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey"));
				returnList.put("getSavedList", AccountUtil.jobjGetObj(returnObj, "getSavedList"));
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
			}
			else{
				returnList.put("result", "D");
				returnList.put("duplObj", duplObj);
				returnList.put("status", Return.FAIL);
			}
			
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : getSimpCardInfoList
	* @Description : 법인카드 간편신청 카드사용정보 조회
	*/
	@RequestMapping(value = "expenceApplication/getSimpCardInfoList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSimpCardInfoList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);

			String expenceApplicationID = request.getParameter("ExpenceApplicationID");
			String addPageList = request.getParameter("addPageList");
			String startDate = request.getParameter("StartDate");
			String endDate = request.getParameter("EndDate");
			String cardID = request.getParameter("CardID");
			String userCode = request.getParameter("UserCode");
			userCode= "".equals(userCode)?SessionHelper.getSession("UR_Code"):userCode;
			params.put("SessionUser", userCode);
			
			params.put("ExpenceApplicationID", expenceApplicationID);
			if(addPageList != null && !addPageList.equals("")) params.put("addPageList", addPageList.split(","));
			params.put("StartDate", startDate);
			params.put("EndDate", endDate);
			params.put("CardID", cardID);
			
			resultList = expenceApplicationSvc.getSimpCardInfoList(params);

			if(resultList.get("page") == null) {
				CoviMap page = new CoviMap();
				int pageSize = params.getInt("pageSize");
				int pageNo = params.getInt("pageNo");
				
				page.put("pageNo", pageNo);
				page.put("pageSize", pageSize);
					
				int cnt = resultList.getInt("cnt");

				page.addAll(ComUtils.setPagingData(page,cnt));
				
				returnList.put("page", page);
			} else {
				returnList.put("page", resultList.get("page"));
			}

			returnList.put("list", resultList.get("list"));
			returnList.put("infoMap", resultList.get("infoMap"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getSimpReceiptInfoList
	* @Description : 간편신청 모바일 영수증 업로드 내역 조회
	*/
	@RequestMapping(value = "expenceApplication/getSimpReceiptInfoList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSimpReceiptInfoList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();

			String expenceApplicationID = request.getParameter("ExpenceApplicationID");
			String[] addPageList = null;
			
			String startDate = request.getParameter("StartDate");
			String endDate = request.getParameter("EndDate");			
			String UR_Code = SessionHelper.getSession("UR_Code");
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";

			if(request.getParameter("addPageList") != null && !request.getParameter("addPageList").isEmpty()) {
				addPageList = request.getParameter("addPageList").split(",");
			}
			
			params.put("ExpenceApplicationID", expenceApplicationID);
			params.put("addPageList", addPageList);
			params.put("SDate", startDate);
			params.put("EDate", endDate);
			params.put("UR_Code", UR_Code);
			//params.put("fileSavePath", filePath);
			params.put("companyCode", commonSvc.getCompanyCodeOfUser(UR_Code));
			
			resultList = expenceApplicationSvc.getSimpReceiptInfoList(params);
			
			CoviMap page = new CoviMap();			
			int listCount = (Integer) resultList.get("cnt");			
			page.put("listCount", listCount);
			returnList.put("page", page);

			returnList.put("list", resultList.get("list"));
			returnList.put("infoMap", resultList.get("infoMap"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : deleteExpenceApplicationManList
	* @Description : 전표 삭제
	*/
	@RequestMapping(value = "expenceApplication/deleteExpenceApplicationManList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteExpenceApplicationManList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();

		String deleteObjStr =  StringEscapeUtils.unescapeHtml(request.getParameter("deleteObj"));
		CoviMap deleteObj = CoviMap.fromObject(deleteObjStr);
		String deleteType = request.getParameter("deleteType");

		result = expenceApplicationSvc.deleteExpenceApplicationManList(deleteObj, deleteType);
		
		returnVal.put("result", "ok");
		returnVal.put("WorkItemArchiveIDs", result.getString("WorkItemArchiveIDs"));
		returnVal.put("status", Return.SUCCESS);
		returnVal.put("message", "삭제되었습니다");
		return returnVal;
	}

	/**
	* @Method Name : getUserCC
	* @Description : 유저 CC 기본값 조회
	*/
	@RequestMapping(value="expenceApplication/getUserCC.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getUserCC(HttpServletRequest request,
			@RequestParam(value = "UserCode",			required = false, defaultValue="")	String UserCode) throws Exception 
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String strUserCode = "".equals(UserCode)?SessionHelper.getSession("UR_Code"):UserCode;
			params.put("UserCode", strUserCode);
			
			result = expenceApplicationSvc.getUserCC(params);
 
			returnVal.put("CCInfo", result.get("info"));
			returnVal.put("result", "ok");
			
			returnVal.put("status", Return.SUCCESS);
			returnVal.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status",	Return.FAIL);
			returnVal.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnVal;
	}

	/**
	* @Method Name : searchExpenceApplicationReviewList
	* @Description : 신청 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/searchExpenceApplicationReviewList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplicationReviewList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("ApplicationStatus", "E");
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}
			resultList = expenceApplicationSvc.searchExpenceApplicationReviewList(params);
	
			returnList.put("page", resultList.get("page"));			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : makeSlip
	* @Description : 전표 작성
	*/
	@RequestMapping(value = "expenceApplication/makeSlip.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap makeSlip(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {

			String objStr =  StringEscapeUtils.unescapeHtml(request.getParameter("obj"));
			CoviMap obj = CoviMap.fromObject(objStr);

			result = expenceApplicationSvc.makeSlip(obj);
			
			returnVal.put("result", "ok");
			returnVal.put("status", Return.SUCCESS);
			returnVal.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnVal;
	}

	/**
	* @Method Name : unMakeSlip
	* @Description : 전표 발행 취소
	*/
	@RequestMapping(value = "expenceApplication/unMakeSlip.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap unMakeSlip(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {

			String objStr =  StringEscapeUtils.unescapeHtml(request.getParameter("obj"));
			CoviMap obj = CoviMap.fromObject(objStr);

			result = expenceApplicationSvc.unMakeSlip(obj);
			
			returnVal.put("result", "ok");
			returnVal.put("status", Return.SUCCESS);
			returnVal.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnVal;
	}

	/**
	* @Method Name : reverseExpApp
	* @Description : 역분개
	*/
	@RequestMapping(value = "expenceApplication/reverseExpApp.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap reverseExpApp(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {

			String expAppID = request.getParameter("ExpAppID");

			CoviMap params = new CoviMap();
			params.put("ExpenceApplicationID", expAppID);
			params.put("ApplicationStatus", "C");
			params.put("Active", "N");
			
			result = expenceApplicationSvc.reverseExpApp(params);
			
			returnVal.put("result", "ok");
			returnVal.put("status", Return.SUCCESS);
			returnVal.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnVal;
	}
	
	/**
	* @Method Name : statChangeExpenceApplicationManList
	* @Description : 전표 상태 승인/반려
	*/
	@RequestMapping(value = "expenceApplication/statChangeExpenceApplicationManList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap statChangeExpenceApplicationManList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {

			String searchedType = request.getParameter("searchedType");
			String objStr =  StringEscapeUtils.unescapeHtml(request.getParameter("aprvObj"));
			CoviMap obj = CoviMap.fromObject(objStr);
			boolean stCk = expenceApplicationSvc.expAppAprvStatCk(obj);
			if(stCk){
				result = expenceApplicationSvc.statChangeExpenceApplicationManList(obj, searchedType);
			//	returnVal.put("list", resultList.get("list"));
				returnVal.put("result", "ok");
				returnVal.put("status", Return.SUCCESS);
			}else{
				returnVal.put("result", "st");
				returnVal.put("status", Return.SUCCESS);
			}
		} catch (SQLException e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status", Return.FAIL);
			returnVal.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnVal;
	}

	/**
	* @Method Name : excelDownloadExpenceApplicationList
	* @Description : 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadExpenceApplicationList.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadExpenceApplicationList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			//String headerName = new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			//String headerKey = new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String searchType 			 = request.getParameter("searchType");
			String applicationStatus	 = request.getParameter("applicationStatus");
			String registerNm	  		 = request.getParameter("registerNm");
			String companyCode = request.getParameter("companyCode");
			String companyName			 = request.getParameter("companyName");
			String applicationType		 = request.getParameter("applicationType");
			String applicationTitle		 = request.getParameter("applicationTitle");
			//String chargeJob		 	 = request.getParameter("chargeJob");
			String requestType		 	 = request.getParameter("requestType");
			String docNo		 		 = request.getParameter("docNo");
			String proofCode			 = request.getParameter("proofCode");
			String vendorName  	 	 	 = request.getParameter("vendorName");
			String costCenterCode  	 	 = request.getParameter("costCenterCode");
			String accountCode  	 	 = request.getParameter("accountCode");
			String IOCode  	 	 	 	 = request.getParameter("IOCode");
			String standardBriefID  	 = request.getParameter("standardBriefID");
			String payDate  	 	 	 = request.getParameter("payDate");
			String expAppMan_dateArea_St = request.getParameter("expAppMan_dateArea_St");
			String expAppMan_dateArea_Ed = request.getParameter("expAppMan_dateArea_Ed");
			String expAppMan_applicationDateArea_St = request.getParameter("expAppMan_applicationDateArea_St");
			String expAppMan_applicationDateArea_Ed = request.getParameter("expAppMan_applicationDateArea_Ed");
			String title = request.getParameter("title");
			String headerType = request.getParameter("headerType");
			
			CoviMap params = new CoviMap();
			params.put("SearchType",			searchType);
			params.put("ApplicationStatus",		applicationStatus);
			params.put("RegisterNm",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerNm, 100)));
			params.put("CompanyCode", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(companyCode, 100)));
			params.put("CompanyName",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(companyName, 100)));
			params.put("ApplicationType",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(applicationTitle, 100)));
			params.put("ApplicationTitle",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(applicationType, 100)));
			//params.put("ChargeJob",			commonCon.convertUTF8(chargeJob));	
			params.put("RequestType",			commonCon.convertUTF8(requestType));
			params.put("DocNo",					commonCon.convertUTF8(ComUtils.RemoveSQLInjection(docNo, 100)));
			params.put("ProofCode",				commonCon.convertUTF8(proofCode));
			params.put("VendorName",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(vendorName, 100)));	
			params.put("CostCenterCode",		commonCon.convertUTF8(costCenterCode));	
			params.put("AccountCode",			commonCon.convertUTF8(accountCode));	
			params.put("IOCode",				commonCon.convertUTF8(IOCode));	
			params.put("StandardBriefID",		commonCon.convertUTF8(standardBriefID));	
			params.put("PayDate",				commonCon.convertUTF8(payDate));
			params.put("ProofDateSt",			commonCon.convertUTF8(expAppMan_dateArea_St));
			params.put("ProofDateEd",			commonCon.convertUTF8(expAppMan_dateArea_Ed));
			params.put("ApplicationDateSt",		commonCon.convertUTF8(expAppMan_applicationDateArea_St));
			params.put("ApplicationDateEd",		commonCon.convertUTF8(expAppMan_applicationDateArea_Ed));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}				
			resultList = expenceApplicationSvc.searchExpenceApplicationListExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}

	/**
	* @Method Name : excelDownloadExpenceApplicationUserList
	* @Description : 엑셀다운 사용자 화면
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadExpenceApplicationUserList.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadExpenceApplicationUserList(HttpServletRequest request, HttpServletResponse response) {ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			//String headerName = new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			//String headerKey = new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String searchType 			 = request.getParameter("searchType");
			String applicationStatus	 = request.getParameter("applicationStatus");
			String registerNm	  		 = request.getParameter("registerNm");
			String companyCode = request.getParameter("companyCode");
			String companyName			 = request.getParameter("companyName");
			String applicationTitle		 = request.getParameter("applicationTitle");
			//String chargeJob			 = request.getParameter("chargeJob");
			String requestType			 = request.getParameter("requestType");
			String docNo		 		 = request.getParameter("docNo");
			String proofCode			 = request.getParameter("proofCode");
			String vendorName  	 	 	 = request.getParameter("vendorName");
			String costCenterCode  	 	 = request.getParameter("costCenterCode");
			String accountCode  	 	 = request.getParameter("accountCode");
			String IOCode  	 	 	 	 = request.getParameter("IOCode");
			String standardBriefID  	 = request.getParameter("standardBriefID");
			String payDate  	 	 	 = request.getParameter("payDate");
			String expAppManUser_dateArea_St = request.getParameter("expAppManUser_dateArea_St");
			String expAppManUser_dateArea_Ed = request.getParameter("expAppManUser_dateArea_Ed");
			String expAppManUser_applicationDateArea_St = request.getParameter("expAppManUser_applicationDateArea_St");
			String expAppManUser_applicationDateArea_Ed = request.getParameter("expAppManUser_applicationDateArea_Ed");
			String title = request.getParameter("title");
			String headerType = request.getParameter("headerType");
			
			CoviMap params = new CoviMap();
			params.put("SearchType",			searchType);
			params.put("ApplicationStatus",		applicationStatus);
			params.put("RegisterNm",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerNm, 100)));
			params.put("CompanyCode", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(companyCode, 100)));
			params.put("CompanyName",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(companyName, 100)));
			params.put("ApplicationTitle",		commonCon.convertUTF8(ComUtils.RemoveSQLInjection(applicationTitle, 100)));	
			params.put("DocNo",					commonCon.convertUTF8(ComUtils.RemoveSQLInjection(docNo, 100)));
			//params.put("ChargeJob",			commonCon.convertUTF8(chargeJob));
			params.put("RequestType",			commonCon.convertUTF8(requestType));
			params.put("ProofCode",				commonCon.convertUTF8(proofCode));
			params.put("VendorName",			commonCon.convertUTF8(ComUtils.RemoveSQLInjection(vendorName, 100)));	
			params.put("CostCenterCode",		commonCon.convertUTF8(costCenterCode));	
			params.put("AccountCode",			commonCon.convertUTF8(accountCode));	
			params.put("IOCode",				commonCon.convertUTF8(IOCode));	
			params.put("StandardBriefID",		commonCon.convertUTF8(standardBriefID));	
			params.put("PayDate",				commonCon.convertUTF8(payDate));
			params.put("ProofDateSt",			commonCon.convertUTF8(expAppManUser_dateArea_St));
			params.put("ProofDateEd",			commonCon.convertUTF8(expAppManUser_dateArea_Ed));
			params.put("ApplicationDateSt",		commonCon.convertUTF8(expAppManUser_applicationDateArea_St));
			params.put("ApplicationDateEd",		commonCon.convertUTF8(expAppManUser_applicationDateArea_Ed));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}				
			resultList = expenceApplicationSvc.searchExpenceApplicationListExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
	
	/**
	* @Method Name : getExpenceApplicationSync
	* @Description : 전표 동기화
	*/
	@RequestMapping(value = "expenceApplication/getExpenceApplicationSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getExpenceApplicationSync(){
		CoviMap	resultList	= new CoviMap();
		resultList = expenceApplicationSvc.getExpenceApplicationSync();
		return resultList;
	}
	
	/**
	* @Method Name : setExpenceApplicationSync
	* @Description : 전표데이터 인터페이스 전송
	*/
	@RequestMapping(value = "expenceApplication/setExpenceApplicationSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap setExpenceApplicationSync(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestBody HashMap paramMap){
		
		CoviMap	resultList	= new CoviMap();
		CoviMap		params		= new CoviMap(paramMap);
		try {
			resultList = expenceApplicationSvc.setExpenceApplicationSync(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		resultList.put("status",	Return.SUCCESS);
		return resultList;
	}
	
	// 전자결재 연동 - 자동 전표 발행
	@RequestMapping(value="expenceApplication/makeSlipAuto.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap makeSlipAuto(@RequestBody Map<String, String> paramMap) throws Exception {
		
		String strExpenceApplicationID = paramMap.get("ExpenceApplicationID");
		
		CoviMap params = new CoviMap();
		params.put("ExpenceApplicationID", strExpenceApplicationID);
		
		CoviMap slipInfo = null; //추후 전표 발행일 정보 변경 시 사용
		/*
		 	PayDayCk : "N"
			PayDayDate : YYYYMMDD
			PostingDateCk : "N"
			PostingDateDate : YYYYMMDD
		*/
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.makeSlipAuto(params, slipInfo);
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
	
	// 전자결재 연동 - Active update
	@RequestMapping(value="expenceApplication/updateActive.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateActive(@RequestBody Map<String, String> paramMap) throws Exception {
		
		String strExpenceApplicationID = paramMap.get("ExpenceApplicationID");
		String strProcessID = paramMap.get("ProcessID");
		String strApplicationStatus = paramMap.get("ApplicationStatus");
		String strSessionUser = paramMap.get("SessionUser");
		String strComment = paramMap.get("Comment");
		String strActive = "";
		String strDomainID = paramMap.get("DomainID");
		
		switch(strApplicationStatus) {
		case "R":
			strActive = "N";
			break;
		case "C":
			strActive = "Y";
			break;
		default:
			strActive = "I";
			break;
		}
		
		CoviMap params = new CoviMap();
		params.put("ExpenceApplicationID", strExpenceApplicationID);
		params.put("ProcessID", strProcessID);
		params.put("ApplicationStatus", strApplicationStatus);
		params.put("UR_Code", strSessionUser);
		params.put("SessionUser", strSessionUser);
		params.put("Comment", strComment);
		params.put("Active", strActive);
		params.put("DomainID", strDomainID);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.expAppUpdateActive(params);
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
	
	// [사용안함] ApplicationStatus update (전표조회 팝업 내 재사용 버튼 클릭 시 실행)
	@RequestMapping(value="expenceApplication/updateApplicationStatus.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateApplicationStatus(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		
		String strExpenceApplicationID = request.getParameter("ExpenceApplicationID");
		String strRequestType = request.getParameter("RequestType");
		
		CoviMap params = new CoviMap();
		params.put("ExpenceApplicationID", strExpenceApplicationID);
		params.put("RequestType", strRequestType);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.expAppUpdateApplicationStatus(params);
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

	// 신청 복제 (전표조회 팝업 내 재사용 버튼 클릭 시 실행)
	@RequestMapping(value="expenceApplication/insertExpenceApplicationForReuse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap insertExpenceApplicationForReuse(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
		
		String strExpenceApplicationID = request.getParameter("ExpenceApplicationID");
		String strApplicationTitle = request.getParameter("ApplicationTitle");
		String strApprovalLine = request.getParameter("ApprovalLine");
		String strFormName = request.getParameter("FormName");
		
		CoviMap params = new CoviMap();
		params.put("ExpenceApplicationID", strExpenceApplicationID);
		params.put("ApplicationTitle", strApplicationTitle);
		params.put("ApprovalLine", strApprovalLine);
		params.put("FormName", strFormName);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.insertExpenceApplicationForReuse(params);
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

	// 전자결재 연동 - CapitalStatus update 및 완료 시 신청건 1건 새로 생성
	@RequestMapping(value="expenceApplication/createCapitalReportInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateStatusMakeNewApp(@RequestBody Map<String, String> paramMap) throws Exception {
		
		String ProcessID = paramMap.get("ProcessID");
		String UR_Code = paramMap.get("UR_Code");
		String Comment = paramMap.get("Comment");
		String ApvState = paramMap.get("ApvState");
		String CapitalStatus = paramMap.get("CapitalStatus");
		
		String Subject = paramMap.get("Subject");
		String expAppListIDs = paramMap.get("expAppListIDs");
		String InitiatorCode = paramMap.get("InitiatorCode");
		String InitiatorDisplay = paramMap.get("InitiatorDisplay");
		String RealPayDate = paramMap.get("RealPayDate");
		String RealPayAmount = paramMap.get("RealPayAmount");
		String StandardBriefID = paramMap.get("StandardBriefID");
		
		CoviMap params = new CoviMap();
		params.put("ProcessID", ProcessID);
		params.put("UR_Code", UR_Code);
		params.put("Comment", Comment);
		params.put("Subject", Subject);
		params.put("ApvState", ApvState);
		params.put("CapitalStatus", CapitalStatus);
		if(expAppListIDs != null && !expAppListIDs.equals("")) params.put("expAppListIDs", expAppListIDs.split(","));
		params.put("strExpAppListIDs", expAppListIDs);
		params.put("InitiatorCodeDisplay", InitiatorCode);
		params.put("InitiatorDisplay", InitiatorDisplay);
		params.put("RealPayDate", RealPayDate);
		params.put("RealPayAmount", RealPayAmount);
		params.put("StandardBriefID", StandardBriefID);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.createCapitalReportInfo(params);
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
	 * @Method Name : getTaxInvoiceXmlUploadPopup
	 * @Description : xml 업로드 팝업
	 */
	@RequestMapping(value = "expenceApplication/getTaxInvoiceXmlUploadPopup.do", method = RequestMethod.GET)
	public ModelAndView getTaxInvoiceXmlUploadPopup(Locale locale, Model model) {
		String returnURL = "user/account/TaxInvoiceXmlUploadPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	* @Method Name : searchCapitalSpendingStatus
	* @Description : 자금지출 현황 조회
	*/
	@RequestMapping(value = "expenceApplication/searchCapitalSpendingStatus.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchCapitalSpendingStatus(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			resultList = expenceApplicationSvc.searchCapitalSpendingStatus(params);
	
			returnList.put("page", resultList.get("page"));			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}	

	
	/**
	* @Method Name : excelDownloadCapitalSpendingList
	* @Description : 자금지출 현황 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadCapitalSpendingStatus.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadCapitalSpendingStatus(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String applicationTitle 	 = request.getParameter("applicationTitle");
			String registerNm	  		 = request.getParameter("registerNm");
			String vendorName	  		 = request.getParameter("vendorName");
			String capitalStatus		 = request.getParameter("capitalStatus");
			String proofCode  	 		 = request.getParameter("proofCode");
			String realPayDate  	 	 = request.getParameter("realPayDate");
			String costCenterCode  	 	 = request.getParameter("costCenterCode");
			String accountCode  	 	 = request.getParameter("accountCode");
			String standardBriefID  	 = request.getParameter("standardBriefID");
			String IOCode				 = request.getParameter("IOCode");
			String CompanyCode			 = request.getParameter("CompanyCode");
			String title = request.getParameter("title");
			
			CoviMap params = new CoviMap();
			params.put("ApplicationTitle", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(applicationTitle, 100)));
			params.put("RegisterNm", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerNm, 100)));
			params.put("VendorName", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(vendorName, 100)));
			params.put("CapitalStatus", commonCon.convertUTF8(capitalStatus));
			params.put("ProofCode", commonCon.convertUTF8(proofCode));
			params.put("RequestType", commonCon.convertUTF8(request.getParameter("requestType")));
			params.put("RealPayDate",	commonCon.convertUTF8(realPayDate));
			params.put("CostCenterCode", commonCon.convertUTF8(costCenterCode));
			params.put("AccountCode", commonCon.convertUTF8(accountCode));	
			params.put("StandardBriefID", commonCon.convertUTF8(standardBriefID));	
			params.put("IOCode", commonCon.convertUTF8(IOCode));	
			params.put("companyCode", commonCon.convertUTF8(CompanyCode));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = expenceApplicationSvc.searchCapitalSpendingStatusExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}

	@RequestMapping(value="expenceApplication/updateCapitalStatus.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateCapitalStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String expAppListIDs = request.getParameter("expAppListIDs");
		String capitalStatus = request.getParameter("CapitalStatus");
		
		CoviMap params = new CoviMap();
		if(expAppListIDs != null && !expAppListIDs.equals("")) params.put("expAppListIDs", expAppListIDs.split(","));
		params.put("CapitalStatus", capitalStatus);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.updateCapitalStatus(params);
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
	 * @Method Name : callCapitalEditPopup
	 * @Description : 자금지출 증빙 수정 팝업 호출
	 */
	@RequestMapping(value = "expenceApplication/callCapitalEditPopup.do" , method = RequestMethod.GET)
	public ModelAndView callCapitalEditPopup(HttpServletRequest request){
		String returnURL = "user/account/CapitalEditPopup";
		ModelAndView mav = new ModelAndView(returnURL);

		String expAppListID = request.getParameter("expAppListID");
		mav.addObject("expAppListID", expAppListID);
		
		return mav;
	}

	/**
	 * @Method Name : searchCapitalEditData
	 * @Description : 수정할 증빙 정보 가져오기
	 */
	@RequestMapping(value = "expenceApplication/searchCapitalEditData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCapitalSpendingResolutionList(
			@RequestParam(value = "expAppListID",		required = false, defaultValue="")	String expAppListID) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("expAppListID",		expAppListID);
			
			resultList = expenceApplicationSvc.searchCapitalEditData(params);
			
			returnList.put("data", resultList.get("data"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	@RequestMapping(value="expenceApplication/updateCapitalEditInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateCapitalEditInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String expAppListID = request.getParameter("expAppListID");
		String realPayDate = request.getParameter("RealPayDate");
		String realPayAmount = request.getParameter("RealPayAmount");
		String alertFlag = request.getParameter("AlertFlag");
		
		CoviMap params = new CoviMap();
		
		// Single or Multi
		String[] expAppListIDs = StringUtil.split(expAppListID, ",");
		
		params.put("expAppListID", expAppListIDs);
		params.put("RealPayDate", realPayDate);
		params.put("RealPayAmount", realPayAmount);
		params.put("AlertFlag", alertFlag);
		
		CoviMap resultList = new CoviMap();
		try {
			resultList = expenceApplicationSvc.updateCapitalEditInfo(params);
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
	 * @Method Name : getCapitalSpendingList
	 * @Description : 자금지출 목록 가져오기
	 */
	@RequestMapping(value = "expenceApplication/getCapitalSpendingList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCapitalSpendingResolutionList(
			@RequestParam(value = "queryMode",			required = false, defaultValue="")	String queryMode,
			@RequestParam(value = "realPayDate",		required = false, defaultValue="")	String realPayDate,
			@RequestParam(value = "standardBriefID",	required = false, defaultValue="")	String standardBriefID,
			@RequestParam(value = "expAppListIDs",		required = false, defaultValue="")	String expAppListIDs,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("QueryMode",			queryMode);
			params.put("RealPayDate",		realPayDate);
			params.put("StandardBriefID",	standardBriefID);
			params.put("CompanyCode",	companyCode);
			if(expAppListIDs != null && !expAppListIDs.equals("")) {
				expAppListIDs = expAppListIDs.replace("&apos;","'").replace("'","");
				params.put("expAppListIDs", expAppListIDs.split(","));
			}
			params.put("companyCode",		commonSvc.getCompanyCodeOfUser());
			
			resultList = expenceApplicationSvc.getCapitalSpendingList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}


	/**
	 * @Method Name : searchCapitalSummary
	 * @Description : 자금지출 결의완료 집계표
	 */
	@RequestMapping(value = "expenceApplication/searchCapitalSummary.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap searchCapitalSummary(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",		required = false, defaultValue="")	String sortBy) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);
			
			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = expenceApplicationSvc.searchCapitalSummary(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	/**
	* @Method Name : excelDownloadCapitalSummary
	* @Description : 자금지출 결의완료 집계표 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadCapitalSummary.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadCapitalSummary(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String companyCode = request.getParameter("CompanyCode");
			String realPayDateSt = request.getParameter("RealPayDateSt");
			String realPayDateEd = request.getParameter("RealPayDateEd");
			String title = request.getParameter("title");
			
			CoviMap params = new CoviMap();
			params.put("CompanyCode", 	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(companyCode, 100)));
			params.put("RealPayDateSt", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(realPayDateSt, 100)));
			params.put("RealPayDateEd", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(realPayDateEd, 100)));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = expenceApplicationSvc.searchCapitalSummaryExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}

	/**
	* @Method Name : ExpenceApplicationViewFilePreviewPopup
	* @Description : 첨부파일 미리보기용 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationViewFilePreviewPopup.do", method = RequestMethod.GET)
	public ModelAndView expenceApplicationViewFilePreviewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/ExpenceApplicationViewFilePreviewPopup";
		ModelAndView mav = new ModelAndView(returnURL);		
		String url = request.getParameter("url");
		String fildId = request.getParameter("fildId");
		mav.addObject("url", url);
		mav.addObject("fildId", fildId);
		return mav;
	}
	

	/**
	* @Method Name : getUserBankAccount
	* @Description : 사용자 은행 계좌 조회
	*/
	@RequestMapping(value = "expenceApplication/getUserBankAccount.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserBankAccount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
	
		try {
			CoviMap params = new CoviMap();
			
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			resultList = expenceApplicationSvc.getUserBankAccount(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : checkActVendorIsRegistered.do
	* @Description : 이미 등록되어 있는 거래처인지 체크
	*/
	@RequestMapping(value = "expenceApplication/checkActVendorIsRegistered.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkActVendorIsRegistered(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
	 
		try {
			CoviMap params = new CoviMap();
	 
			params.put(request.getParameter("FieldName"), request.getParameter("FieldValue"));
	 
			resultList = expenceApplicationSvc.checkActVendorIsRegistered(params);
	 
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",        Return.FAIL);
			returnList.put("message",		"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}


	/**
	* @Method Name : searchMonthlyAccountHeaderData
	* @Description : 월별 경비 계정별 집계표 헤더 데이터 조회
	*/
	@RequestMapping(value = "expenceApplication/searchMonthlyAccountHeaderData.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchMonthlyAccountHeaderData(HttpServletRequest request) throws Exception 
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}			
			resultList = expenceApplicationSvc.searchMonthlyAccountHeaderData(params);			
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : searchMonthlyAccountSummaryList
	* @Description : 월별 경비 계정별 집계표 조회
	*/
	@RequestMapping(value = "expenceApplication/searchMonthlyAccountSummaryList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchMonthlyAccountSummaryList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}
			
			returnList = expenceApplicationSvc.searchMonthlyAccountSummaryList(params);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : excelDownloadMonthlyAccountSummaryList
	* @Description : 월별 경비 계정별 집계표 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadMonthlyAccountSummaryList.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadMonthlyAccountSummaryList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String companyCode			 = request.getParameter("companyCode");
			String searchType 			 = request.getParameter("searchType");
			String registerNm	  		 = request.getParameter("registerNm");
			String registerDept	  		 = request.getParameter("registerDept");
			//String chargeJob			 = request.getParameter("chargeJob"); 
			String requestType			 = request.getParameter("requestType");
			String accountCode  	 	 = request.getParameter("accountCode");
			String proofDate = request.getParameter("proofDate");
			String title = request.getParameter("title");
			
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			params.put("SearchType", searchType);
			params.put("RegisterNm", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerNm, 100)));
			params.put("RegisterDept", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerDept, 100)));
			//params.put("ChargeJob", commonCon.convertUTF8(chargeJob));
			params.put("RequestType", commonCon.convertUTF8(requestType));
			params.put("AccountCode", commonCon.convertUTF8(accountCode));	
			params.put("ProofDate",	commonCon.convertUTF8(proofDate));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = expenceApplicationSvc.searchMonthlyAccountSummaryListExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
	
	/**
	* @Method Name : searchMonthlyStandardBriefHeaderData
	* @Description : 월별 경비 표준적요별 집계표 헤더 데이터 조회
	*/
	@RequestMapping(value = "expenceApplication/searchMonthlyStandardBriefHeaderData.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchMonthlyStandardBriefHeaderData(HttpServletRequest request) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}
			
			resultList = expenceApplicationSvc.searchMonthlyStandardBriefHeaderData(params);			
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : searchMonthlyStandardBriefSummaryList
	* @Description : 월별 경비 표준적요별 집계표 조회
	*/
	@RequestMapping(value = "expenceApplication/searchMonthlyStandardBriefSummaryList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchMonthlyStandardBriefSummaryList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap params = CoviMap.fromObject(searchParam);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			//timezone 적용 날짜변환
			if(params.get("ApplicationDateSt") != null && !params.get("ApplicationDateSt").equals("")){
				params.put("ApplicationDateSt",ComUtils.TransServerTime(params.get("ApplicationDateSt").toString() + " 00:00:00"));
			}
			if(params.get("ApplicationDateEd") != null && !params.get("ApplicationDateEd").equals("")){
				params.put("ApplicationDateEd",ComUtils.TransServerTime(params.get("ApplicationDateEd").toString() + " 23:59:59"));
			}
			
			returnList = expenceApplicationSvc.searchMonthlyStandardBriefSummaryList(params);	
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : excelDownloadMonthlyStandardBriefSummaryList
	* @Description : 월별 경비 표준적요별 집계표 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadMonthlyStandardBriefSummaryList.do" , method = {RequestMethod.GET,RequestMethod.POST})
	public ModelAndView excelDownloadMonthlyStandardBriefSummaryList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String companyCode			 = request.getParameter("companyCode");
			String searchType 			 = request.getParameter("searchType");
			String registerNm	  		 = request.getParameter("registerNm");
			String registerDept	  		 = request.getParameter("registerDept");
			//String chargeJob			 = request.getParameter("chargeJob"); 
			String requestType			 = request.getParameter("requestType");
			String standardBriefID  	 	 = request.getParameter("standardBriefID");
			String proofDate = request.getParameter("proofDate");
			String title = request.getParameter("title");
			
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			params.put("SearchType", searchType);
			params.put("RegisterNm", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerNm, 100)));
			params.put("RegisterDept", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(registerDept, 100)));
			//params.put("ChargeJob", commonCon.convertUTF8(chargeJob));
			params.put("RequestType", commonCon.convertUTF8(requestType));	
			params.put("StandardBriefID", commonCon.convertUTF8(standardBriefID));	
			params.put("ProofDate",	commonCon.convertUTF8(proofDate));
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = expenceApplicationSvc.searchMonthlyStandardBriefSummaryListExcel(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}

	/**
	* @Method Name : ExpenceApplicationPreviewPopup
	* @Description : 미리보기 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationPreviewPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView expenceApplicationPreviewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/CombineCostApplicationPreview";
		ModelAndView mav = new ModelAndView(returnURL);		
		String parentID = request.getParameter("parentID");
		mav.addObject("parentID", parentID);
		return mav;
	}

	/**
	* @Method Name : ExpenceApplicationBizTripPopup
	* @Description : 일비/유류비 팝업 호출
	*/
	@RequestMapping(value = "expenceApplication/ExpenceApplicationBizTripPopup.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView expenceApplicationDailyPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String popupName = request.getParameter("popupName");
		String returnURL = "user/account/"+popupName;

		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * getFormData
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "getFormData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			params.put("mode", request.getParameter("mode"));
			params.put("gloct", request.getParameter("gloct"));
			params.put("Subkind", request.getParameter("Subkind"));
			params.put("UserCode", request.getParameter("UserCode"));
			params.put("WorkitemID", request.getParameter("WorkitemID"));
			params.put("ExpAppID", request.getParameter("ExpAppID"));

			resultList = expenceApplicationSvc.getFormData(params);

			returnList.put("formData", resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	/**
	* @Method Name : getCardList
	* @Description : 카드목록 조회
	*/
	@RequestMapping(value = "expenceApplication/getCardList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCardList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "UR_Code",			required = false, defaultValue="")	String strUR_Code,
			@RequestParam(value = "RequestType",		required = false, defaultValue="")	String strRequestType,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			params.put("UR_Code", strUR_Code);
			params.put("RequestType", strRequestType);
			if(paramMap.containsKey("CompanyCode"))
				params.put("CompanyCode", paramMap.get("CompanyCode"));
			resultList = expenceApplicationSvc.getCardList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * @Method Name : saveAuditReason
	 * @Description : 감사규칙 소명사유 저장
	 */
	@RequestMapping(value = "expenceApplication/saveAuditReason.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveAuditReason(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "ExpenceApplicationID",	required = false , defaultValue="") String ExpenceApplicationID,
			@RequestParam(value = "AuditReason",			required = false , defaultValue="") String AuditReason) throws Exception{
		
		CoviMap resultList = new CoviMap();
		CoviMap params 		= new CoviMap();
		
		try {
			params.put("ExpenceApplicationID",	ExpenceApplicationID);
			params.put("AuditReason",	ComUtils.RemoveScriptAndStyle(AuditReason));
			
			resultList = expenceApplicationSvc.saveAuditReason(params);
			
			resultList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : selRecentVendorInfo
	 * @Description : 이전에 사용한 Vendor에 대한 증빙정보 가져오기
	 */
	@RequestMapping(value = "expenceApplication/selRecentVendorInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selRecentVendorInfo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("BusinessNumber",   request.getParameter("BusinessNumber"));
			params.put("proofCode",  request.getParameter("proofCode"));
			params.put("UR_Code",  request.getParameter("UR_Code"));
			
			resultList = expenceApplicationSvc.selRecentVendorInfo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	

	/**
	* @Method Name : getStoreCategoryCombo
	* @Description : 업종 콤보용 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/getStoreCategoryCombo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStoreCategoryCombo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String companyCode = request.getParameter("CompanyCode");
			
			params.put("companyCode", companyCode);
			
			resultList = expenceApplicationSvc.getStoreCategoryCombo(params);
			
			returnList.put("list", resultList.get("StoreCategoryList"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	

	/**
	* @Method Name : getStandardBriefCtrlCombo
	* @Description : 주요계정 사용내역 - 관리항목이 매핑된 표준적요 콤보
	*/
	@RequestMapping(value = "expenceApplication/getStandardBriefCtrlCombo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStandardBriefCtrlCombo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String companyCode = request.getParameter("CompanyCode");
			
			params.put("CompanyCode", companyCode);
			
			resultList = expenceApplicationSvc.getStandardBriefCtrlCombo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getCtrlCodeHeader
	* @Description : 주요계정 사용내역 - 관리항목 헤더 데이터 조회
	*/
	@RequestMapping(value = "expenceApplication/getCtrlCodeHeader.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCtrlCodeHeader(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String standardBriefID = request.getParameter("StandardBriefID");
			
			params.put("StandardBriefID", standardBriefID);
			
			resultList = expenceApplicationSvc.getCtrlCodeHeader(params);			
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getMajorAccountUsageHistory
	* @Description : 주요계정 사용내역 - 목록 조회
	*/
	@RequestMapping(value = "expenceApplication/getMajorAccountUsageHistory.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMajorAccountUsageHistory(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap jsonParams = CoviMap.fromObject(searchParam);
			
			CoviMap params = new CoviMap();
			params.addAll(jsonParams);

			AccountUtil.setSearchPage(request, params);
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			returnList = expenceApplicationSvc.getMajorAccountUsageHistory(params);	
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : getMajorAccountUsageHistoryExcel
	* @Description : 주요계정 사용내역 - 엑셀 다운로드
	*/
	@RequestMapping(value = "expenceApplication/getMajorAccountUsageHistoryExcel.do" , method = RequestMethod.GET)
	public ModelAndView getMajorAccountUsageHistoryExcel(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",			required = false, defaultValue="")	String headerType,
			@RequestParam(value = "title",				required = false, defaultValue="")	String title){
		ModelAndView mav = new ModelAndView();
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		String returnURL = "UtilExcelView";
		
		try {
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");

			String searchParam = StringEscapeUtils.unescapeHtml(request.getParameter("searchParam"));
			CoviMap jsonParams = CoviMap.fromObject(searchParam);
			
			CoviMap params = new CoviMap();
			params.addAll(jsonParams);
			
			params.put("headerKey",	commonCon.convertUTF8(headerKey));
			params.put("isExcel", "Y");
			
			resultList = expenceApplicationSvc.getMajorAccountUsageHistory(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			
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
	* @Method Name : callicubeDuzonPopup
	* @Description : 더존엑셀다운팝업
	*/
	@RequestMapping(value = "expenceApplication/callicubeDuzonePopup.do", method = RequestMethod.GET)
	public ModelAndView callicubeDuzonePopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/icubeDuzonePopup";
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	
	/**
	* @Method Name : excelDownloadExpenceApplicationList
	* @Description : 엑셀다운
	*/
	@RequestMapping(value = "expenceApplication/excelDownloadERP.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView excelDownloadERP(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = request.getParameter("headerName");
			String headerKey = request.getParameter("headerKey");
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			String slipDate = StringUtil.replaceNull(request.getParameter("slipDate"));
			slipDate = slipDate.replace(".", "");
			slipDate = slipDate.substring(0,6);
			
			String searchType 			 = request.getParameter("searchType");

			String title = request.getParameter("title");
			String headerType = request.getParameter("headerType");
			
			CoviMap params = new CoviMap();
			params.put("SearchType",			searchType);
			params.put("SlipDate",				slipDate);

			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
						
			resultList = expenceApplicationSvc.getExpenceApplicationListExcelDouzone(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
	
	@RequestMapping(value = "expence/sync/list.do", method = RequestMethod.GET)
	public ResponseEntity<CoviList> list() throws Exception {
		return ResponseEntity.ok().body(expenceApplicationSvc.selectSync());
	}
	
	@RequestMapping(value = "expence/sync/complete.do", method = RequestMethod.POST)
	public ResponseEntity complete(@RequestBody CoviMap params) throws Exception {
		expenceApplicationSvc.syncComplete(params);
		return ResponseEntity.ok().build();
	}
}