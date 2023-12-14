package egovframework.coviaccount.mobile.web;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.CardReceiptSvc;
import egovframework.coviaccount.user.service.CostCenterSvc;
import egovframework.coviaccount.user.service.DeadlineSvc;
import egovframework.coviaccount.user.service.ExpenceApplicationSvc;
import egovframework.coviframework.util.ComUtils;


@Controller
@RequestMapping("/mobile/account")
public class MOAccountCommonCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
		
	@Autowired
	private CardReceiptSvc cardReceiptSvc;
	
	@Autowired
	private ExpenceApplicationSvc expenceApplicationSvc;
	
	@Autowired
	private CommonSvc commonSvc;
	
	@Autowired
	private CostCenterSvc costCenterSvc;
	
	@Autowired
	private DeadlineSvc deadlineSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	

	@RequestMapping(value = "/getBriefCombo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBriefCombo(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		CoviMap returnList = new CoviMap();
	
		try {			
			CoviMap params = new CoviMap();
			String isSimp = request.getParameter("isSimp");
			String companyCode = request.getParameter("CompanyCode");
			
			params.put("isSimp", isSimp);
			params.put("companyCode", companyCode);
	
			CoviMap resultList = expenceApplicationSvc.getBriefCombo(params);
			
			returnList.put("list", resultList.get("BriefList"));
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
	
	@RequestMapping(value = "/getVendorPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVendorPopupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			int pageSize = 10;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			/*if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}*/
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			String searchText = request.getParameter("searchText");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			CoviMap resultObj = commonSvc.getVendorPopupList(params);

			returnList.put("page", resultObj.get("page"));
			returnList.put("list", resultObj.get("list"));
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
	
	@RequestMapping(value = "/getPrivateCardPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPrivateCardPopupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			int pageSize = 10;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			/*if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}*/
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			String searchText = request.getParameter("searchText");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			CoviMap resultObj = commonSvc.getPrivateCardPopupList(params);
			
			returnList.put("page", resultObj.get("page"));
			returnList.put("list", resultObj.get("list"));
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
	
	@RequestMapping(value = "/getBaseCodeSearchCommPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCodeSearchCommPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",	required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			int pageSize = 10;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			String searchText	= request.getParameter("searchText");
			String codeGroup	= request.getParameter("codeGroup");
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("searchText",	ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("codeGroup",		codeGroup);
			
			returnList = commonSvc.getBaseCodeSearchCommPopupList(params);			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("result", "ok");
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
	
	@RequestMapping(value = "/getCostCenterSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "popupType",			required = false, defaultValue="")	String popupType,
			@RequestParam(value = "searchTypePop",		required = false, defaultValue="")	String searchTypePop,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "soapCostCenterName",	required = false, defaultValue="")	String soapCostCenterName,
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
			
			params.put("sortColumn",			ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",			ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",				pageNo);
			params.put("pageSize",				pageSize);
			params.put("companyCode",			companyCode);
			params.put("popupType",				popupType);
			params.put("searchTypePop",			searchTypePop);
			params.put("searchStr",				ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("soapCostCenterName",	soapCostCenterName);
			params.put("searchProperty",		searchProperty);
			
			resultList = commonSvc.getCostCenterSearchPopupList(params);
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
	 * getCostCenterDetail : 코스트센터 상세 조회
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getCostCenterDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterDetail(
			@RequestParam(value = "costCenterID",	required = false, defaultValue="") String costCenterID) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("costCenterID",	costCenterID);
			resultList = costCenterSvc.getCostCenterDetail(params);
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
	
	/**
	 * getUserCC.do : 사용자 코스트센터 조회
	 */
	@RequestMapping(value="/getUserCC.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserCC(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception 
	{
		CoviMap returnVal = new CoviMap();
		try {	
			CoviMap params = new CoviMap();
			String strUserCode = SessionHelper.getSession("UR_Code");
			params.put("UserCode", strUserCode);
			
			CoviMap result = expenceApplicationSvc.getUserCC(params);
			
			returnVal.put("CCInfo", result.get("info"));
			returnVal.put("result", "ok");
			
			returnVal.put("status", Return.SUCCESS);
			returnVal.put("message", "조회되었습니다");
		} catch (SQLException e) {
			returnVal.put("status",	Return.FAIL);
			returnVal.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnVal.put("status",	Return.FAIL);
			returnVal.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnVal;
	}
	
	/**
	 * getDeadlineInfo : 마감일자 정보 조회
	 * * @param companyCode
	 */
	@RequestMapping(value = "/getDeadlineInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getDeadlineInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "companyCode" , required = false , defaultValue="") String companyCode
			) throws Exception{

		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			params.put("companyCode", companyCode);
			
			resultList = deadlineSvc.getDeadlineInfo(params);
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
	 * getExpenseListAll : 사용자별 미정산 법인카드/모바일 영수증 내역 조회
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getCorpCardAndReceiptList.do", method = RequestMethod.POST)
	public	@ResponseBody CoviMap getCorpCardAndReceiptList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			String pageNo = request.getParameter("pageNo");
			String pageSize = request.getParameter("pageSize");
			String approveDateS = request.getParameter("SDate");
			String approveDateE = request.getParameter("EDate");
			String searchProperty = request.getParameter("searchProperty");
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";

			String sortColumn		= "";
			String sortDirection	= "";	
			String cardNo = "";
			
			String expAppID = "";
			String idStr = "";
			String storeName = "";
			
			params.put("searchProperty",	searchProperty);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("ExpAppID",			expAppID);
			params.put("idStr",				idStr);
			params.put("startDD",			approveDateS);
			params.put("endDD",				approveDateE);
			params.put("storeName",			storeName);
			params.put("cardNo",			cardNo);
			//params.put("fileSavePath", 		filePath);
			params.put("companyCode",		commonSvc.getCompanyCodeOfUser(SessionHelper.getSession("UR_Code")));
			
			resultList = commonSvc.getCorpCardAndReceiptList(params);
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
	 * getCorpCardList
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getCorpCardList.do", method = RequestMethod.POST)
	public	@ResponseBody CoviMap getCorpCardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String pageNo = request.getParameter("pageNo");
			String pageSize = request.getParameter("pageSize");
			String approveDateS = request.getParameter("SDate");
			String approveDateE = request.getParameter("EDate");
			String searchProperty = request.getParameter("searchProperty");

			String sortColumn		= "";
			String sortDirection	= "";	
			String cardNo = "";
			
			String expAppID = "";
			String idStr = "";
			String storeName = "";
			
			params.put("searchProperty",	searchProperty);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("ExpAppID",			expAppID);
			params.put("idStr",				idStr);
			params.put("startDD",			approveDateS);
			params.put("endDD",				approveDateE);
			params.put("storeName",			storeName);
			params.put("cardNo",			cardNo);
			
			resultList = commonSvc.getCardReceiptSearchPopupList(params);
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
	 * getReceiptList
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getReceiptList.do", method = RequestMethod.POST)
	public	@ResponseBody CoviMap getReceiptList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String pageNo = request.getParameter("pageNo");
			String pageSize = request.getParameter("pageSize");
			String startDate = request.getParameter("SDate");
			String endDate = request.getParameter("EDate");
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
			String userCode = SessionHelper.getSession("UR_Code");
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("SDate",	startDate);
			params.put("EDate",	endDate);
			params.put("UR_Code", userCode);
			//params.put("fileSavePath", filePath);
			params.put("companyCode", commonSvc.getCompanyCodeOfUser(userCode));
			
			resultList = expenceApplicationSvc.getMobileReceiptList(params);
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
	 * getCardReceipt
	 * @param ReceiptID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getCardReceipt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCardReceipt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			String receiptID = request.getParameter("receiptID");
			List<String> receiptIDList = new LinkedList<>();
			StringTokenizer stRI = new StringTokenizer(receiptID,",");
			String getID = "";
			while(stRI.hasMoreTokens()){
				getID = stRI.nextToken();
				receiptIDList.add(getID);
			}
			
			if(!receiptIDList.isEmpty()) params.put("receiptIDList", receiptIDList.stream().toArray(String[]::new));
			
			CoviMap resultList = expenceApplicationSvc.getCardReceipt(params);
			
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
	 * getCardReceiptDetail
	 * @param ReceiptID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getCardReceiptDetail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCardReceiptDetail(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
	
			String receiptID = request.getParameter("receiptID");
			String approveNo = request.getParameter("approveNo");
			String searchProperty = request.getParameter("searchProperty");
			
			params.put("receiptID",			receiptID);
			params.put("approveNo",			approveNo);
			params.put("searchProperty",	searchProperty);
			
			CoviMap resultList = commonSvc.getCardReceiptPopupInfo(params);		
			
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
	 * getExpenceApplicationUserList : 사용자 경비신청현황 조회
	 * @param ReceiptID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getExpenceApplicationUserList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getExpenceApplicationUserList(HttpServletRequest request, HttpServletResponse response, @RequestParam(value = "sortBy", required = false, defaultValue="")	String sortBy, @RequestParam Map<String, String> paramMap) throws Exception
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
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			CoviMap resultList = expenceApplicationSvc.searchExpenceApplicationList(params);
	
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
	 * getMobileReceipt
	 * @param ReceiptID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getMobileReceipt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMobileReceipt(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
	
			String receiptID = request.getParameter("receiptID");
			List<String> receiptIDList = new LinkedList<>();
			StringTokenizer stRI = new StringTokenizer(receiptID,",");
			String getID = "";
			while(stRI.hasMoreTokens()){
				getID = stRI.nextToken();
				receiptIDList.add(getID);
			}
	
			if(!receiptIDList.isEmpty()) params.put("receiptIDList", receiptIDList.stream().toArray(String[]::new));
			params.put("companyCode", commonSvc.getCompanyCodeOfUser());
			
			CoviMap resultList = expenceApplicationSvc.getMobileReceipt(params);
			
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
	 * saveExpenceApplication
	 * @param ReceiptID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/saveExpenceApplication.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCombineCostApplication(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
	
			String sobj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			
			CoviMap saveObj = CoviMap.fromObject(sobj);

			String isSearched = AccountUtil.jobjGetStr(saveObj, "isSearched" );
			String isNew = AccountUtil.jobjGetStr(saveObj, "isNew" );
			String applicationStatus = AccountUtil.jobjGetStr(saveObj, "ApplicationStatus");
			
			String userID = SessionHelper.getSession("USERID");
			saveObj.put("UserID", userID);
			
			CoviMap returnObj = null;

			CoviMap duplObj = expenceApplicationSvc.duplCkExpenceApplicationList(saveObj);
			int totalCnt = 0; 
			
			if(duplObj != null) {
				totalCnt = duplObj.getInt("TotalCnt");
			}
			
			if(totalCnt == 0){
				if("Y".equals(isSearched) || "N".equals(isNew)){
					returnObj = expenceApplicationSvc.updateExpenceApplication(saveObj);
				}else{
					returnObj = expenceApplicationSvc.insertExpenceApplication(saveObj);
				}
	
				if("T".equals(applicationStatus)) {
					CoviMap domainParam = new CoviMap();
					domainParam.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey"));
					domainParam.put("ApplicationTitle", AccountUtil.jobjGetStr(saveObj, "ApplicationTitle"));
					domainParam.put("ApprovalLine", saveObj.get("ApprovalLine"));
					domainParam.put("FormName", AccountUtil.jobjGetStr(saveObj, "FormName"));
					expenceApplicationSvc.savePrivateDomainData(domainParam); //임시저장 시 결재선 저장
				}
	
				returnList.put("data", returnObj);
				returnList.put("getSavedKey", AccountUtil.jobjGetStr(returnObj, "getSavedKey" ));
				returnList.put("getSavedList", AccountUtil.jobjGetObj(returnObj, "getSavedList" ));
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
	 * savePersonaldeleteReceipt
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/savePersonaldeleteReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCardReceiptPersonal(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
	
		try {
			if(params.getString("mode").equals("CorpCard")){
				cardReceiptSvc.saveCardReceiptPersonal(params);			//법인카드 신청제외(개인사용) 처리	
			} else if(params.getString("mode").equals("Receipt")){
				expenceApplicationSvc.deleteMobileReceipt(params);		//영수증 삭제 처리
			}
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * updateMobileReceipt
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/updateMobileReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateMobileReceipt(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
	
		try {
			String receiptID =  request.getParameter("ReceiptID");
			String standardBriefID =  request.getParameter("StandardBriefID") == null ? "" : request.getParameter("StandardBriefID");
			String accountCode =  request.getParameter("AccountCode") == null ? "" : request.getParameter("AccountCode");
			String totalAmount =  request.getParameter("TotalAmount");
			String useDate =  request.getParameter("UseDate");
			String useTime =  request.getParameter("UseTime");
			String usageText =  request.getParameter("UsageText") == null ? "" : request.getParameter("UsageText");
			String storeName =  request.getParameter("StoreName") == null ? "" : request.getParameter("StoreName");
			String receiptType =  request.getParameter("ReceiptType");
			
			params.put("ReceiptID", receiptID);
			params.put("StandardBriefID", standardBriefID);
			params.put("AccountCode", accountCode);
			params.put("TotalAmount", totalAmount);
			params.put("UseDate", useDate);
			params.put("UseTime", useTime);
			params.put("UsageText", usageText);
			params.put("StoreName", storeName);
			params.put("ReceiptType", receiptType);
			
			expenceApplicationSvc.updateMobileReceipt(params);
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * updateCorpCardReceipt
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/updateCorpCardReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateCorpCardReceipt(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
	
		try {
			String receiptID =  request.getParameter("ReceiptID");
			String standardBriefID =  request.getParameter("StandardBriefID") == null ? "" : request.getParameter("StandardBriefID");
			String accountCode =  request.getParameter("AccountCode") == null ? "" : request.getParameter("AccountCode");
			String usageText =  request.getParameter("UsageText") == null ? "" : request.getParameter("UsageText");
			
			params.put("ReceiptID", receiptID);
			params.put("StandardBriefID", standardBriefID);
			params.put("AccountCode", accountCode);
			params.put("UsageText", usageText);
			
			expenceApplicationSvc.updateCorpCardReceipt(params);
			
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * saveUploadReceipt
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/saveUploadReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveMobileReceipt(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap returnList	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		try {
			//params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			
			CoviMap returnObj = expenceApplicationSvc.insertMobileReceipt(params);		//영수증 삭제 처리
			
			returnList.put("data", returnObj);
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
	* @Method Name : searchExpenceApplication
	* @Description : 전표목록 상세조회
	*/
	@RequestMapping(value="/searchExpenceApplication.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchExpenceApplication(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnObj = new CoviMap();

		try{
			String expenceApplicationID =  request.getParameter("ExpenceApplicationID");
			
			CoviMap params = new CoviMap();
			// storage정보에서 조회하도록 변경
			//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/";
			
			//params.put("fileSavePath", filePath);
			params.put("ExpenceApplicationID", expenceApplicationID);
			params.put("companyCode", commonSvc.getCompanyCodeOfUser());
			CoviMap resultMap = expenceApplicationSvc.searchExpenceApplication(params);
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
	
}
