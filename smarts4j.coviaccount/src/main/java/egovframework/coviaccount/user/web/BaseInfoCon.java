package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.user.service.BaseInfoSvc;
import egovframework.coviframework.util.ComUtils;



/**
 * @Class Name : BaseInfoCon.java
 * @Description : 기초코드
 * @Modification Information 
 * @author Covision
 * @ 2018.05.08 최초생성
 */
@Controller
public class BaseInfoCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BaseInfoSvc baseInfoSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//layout 처리 시작

	//==============================거래처관리======================================
	/**
	* @Method Name : searchVendorList
	* @Description : 거래처 관리
	*/
	@RequestMapping(value = "baseInfo/searchVendorList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchVendorList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}			
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			String searchCompanyCode = request.getParameter("searchCompanyCode");
			String searchSector =request.getParameter("searchSector");
			String searchVendorNo =request.getParameter("searchVendorNo");
			String searchIndustry =request.getParameter("searchIndustry");
			String searchVendorName =request.getParameter("searchVendorName");
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchCompanyCode", searchCompanyCode);
			params.put("searchSector", ComUtils.RemoveSQLInjection(searchSector, 100));
			params.put("searchVendorNo", ComUtils.RemoveSQLInjection(searchVendorNo, 100));
			params.put("searchIndustry", ComUtils.RemoveSQLInjection(searchIndustry, 100));
			params.put("searchVendorName", ComUtils.RemoveSQLInjection(searchVendorName, 100));
			
			resultList = baseInfoSvc.searchVendorList(params);
		
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
	* @Method Name : searchVendorDetail
	* @Description : 거래처 상세조회
	*/
	@RequestMapping(value="baseInfo/searchVendorDetail.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchVendorDetail(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String vendorID =  request.getParameter("VendorID");
			String companyCode =  request.getParameter("companyCode");
			
			CoviMap params = new CoviMap();
			params.put("VendorID", vendorID);
			params.put("companyCode", companyCode);
			
			resultMap = baseInfoSvc.searchVendorDetail(params);
			
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
	* @Method Name : checkVendorDuplicate
	* @Description : 거래처 중복여부 확인
	*/
	@RequestMapping(value="baseInfo/checkVendorDuplicate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkVendorDuplicate(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String vendorNo = request.getParameter("VendorNo");
			String vendorType = request.getParameter("VendorType");
			String companyCode = request.getParameter("CompanyCode");
			
			CoviMap params = new CoviMap();
			params.put("VendorNo", ComUtils.RemoveSQLInjection(vendorNo, 100));
			params.put("VendorType", vendorType);
			params.put("CompanyCode", companyCode);
			resultMap = baseInfoSvc.checkVendorDuplicate(params);
			
			returnObj.put("duplItem", resultMap.get("duplItem"));
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
	* @Method Name : deleteVendorList
	* @Description : 거래처 삭제
	*/
	@RequestMapping(value = "baseInfo/deleteVendorList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteVendorList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			String vdList = request.getParameter("vdList");

			CoviMap params = new CoviMap();
			if(vdList != null && !vdList.equals("")) params.put("vdList", vdList.split(","));
			int resultCnt = baseInfoSvc.deleteVendorList(params);
			
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
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
	* @Method Name : saveVendorData
	* @Description : 거래처 저장
	*/
	@RequestMapping(value = "baseInfo/saveVendorData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveVendorData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			String vdo = StringEscapeUtils.unescapeHtml(request.getParameter("vendorDataObj"));
			CoviMap vendorDataObj = CoviMap.fromObject(vdo);
			
			String isNew = vendorDataObj.getString("IsNew");
			CoviMap returnObj = new CoviMap();

			vendorDataObj.put("SessionUser", SessionHelper.getSession("USERID"));
			vendorDataObj.put("UserId", SessionHelper.getSession("USERID"));	
			
			if("Y".equals(isNew)){
				returnObj = baseInfoSvc.insertVendor(vendorDataObj);
			} else {
				returnObj = baseInfoSvc.updateVendor(vendorDataObj);
			}

			if("D".equals(returnObj.getString("status"))){
				returnList.put("result", "D");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "중복");
			}
			else if("V".equals(returnObj.getString("status"))){
				returnList.put("returnObj", returnObj);
				returnList.put("result", "V");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "필수값");
			}
			else if("S".equals(returnObj.getString("status"))){
				returnList.put("returnObj", returnObj);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장");
			}
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "알수없는 에러");
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
	* @Method Name : excelDownloadVenderList
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelDownloadVenderList.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadVenderList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			
			CoviMap params = new CoviMap();

			String searchCompanyCode = request.getParameter("searchCompanyCode");
			String searchSector =request.getParameter("searchSector");
			String searchVendorNo =request.getParameter("searchVendorNo");
			String searchIndustry =request.getParameter("searchIndustry");
			String searchVendorName =request.getParameter("searchVendorName");
			params.put("searchCompanyCode", commonCon.convertUTF8(searchCompanyCode));
			params.put("searchSector", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchSector, 100)));
			params.put("searchVendorNo", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchVendorNo, 100)));
			params.put("searchIndustry", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchIndustry, 100)));
			params.put("searchVendorName", commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchVendorName, 100)));			

			/*
			String headerName	= new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			String headerKey	= new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			*/

			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			String headerType	= request.getParameter("headerType");
			
			//String[] headerNames = headerName.split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String searchType =  request.getParameter("searchType");
			
			params.put("SearchType", searchType);
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = baseInfoSvc.excelDownloadVenderList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
	* @Method Name : vendorExcelPopup
	* @Description : 엑셀업로드 팝업열기
	*/
	@RequestMapping(value = "baseInfo/vendorExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView vendorExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/VendorExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}

	/**
	* @Method Name : excelUploadVenderList
	* @Description : 엑셀업로드
	*/
	@RequestMapping(value = "baseInfo/excelUploadVenderList.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUploadVenderList(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap result = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			
			result = baseInfoSvc.excelUploadVenderList(params);
			
			if(!result.has("err")) {
				result.put("status", 	Return.SUCCESS);
				result.put("message",	DicHelper.getDic("msg_UploadOk"));
			} else {
				result.put("status",	Return.FAIL);
			}
		} catch (SQLException e) {
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status",	Return.FAIL);
			result.put("message",	"Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return result;		
	}

	/**
	* @Method Name : excelTemplateDownload
	* @Description : 템플릿 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelTemplateDownloadVendorList.do")
	public ModelAndView excelTemplateDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		
		try {
				String returnURL = "UtilExcelView";
				CoviMap viewParams = new CoviMap();
				String[] headerNames = null;
				headerNames = new String [] { "회사코드"
						, "사업자등록번호"
						, "거래처명"
						,"법인번호"
						,"대표자명"
						,"업태"
						,"업종"
						,"상세주소"
						,"은행명"
						,"은행계좌"
						,"예금주명"
						,"지급조건"
						,"지급방법"
						};
				
				viewParams.put("list", new CoviList());
				viewParams.put("cnt", 0);
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "VendorTemplate");
				mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}


	/**
	* @Method Name : callVendorPopup
	* @Description : 업체 팝업 호출
	*/
	@RequestMapping(value = "baseInfo/callVendorPopup.do", method = RequestMethod.GET)
	public ModelAndView callVendorPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		String returnURL = "user/account/VendorPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);		

		String isNew = request.getParameter("isNew");
		String vendorId = request.getParameter("vendorId");
		String vendorType = request.getParameter("vendorType");
		
		mav.addObject("isNew", isNew);
		mav.addObject("vendorType", vendorType);
		mav.addObject("vendorId", vendorId);
		return mav;
	}

	/**
	* @Method Name : vendorSync
	* @Description : 업체정보 동기화
	*/
	@RequestMapping(value = "baseInfo/vendorSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap vendorSync() throws Exception{
		CoviMap	resultList	= new CoviMap();

		try{
			resultList = baseInfoSvc.vendorSync();
			baseInfoSvc.vendorBusinessNumberSync();
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

	//==============================거래처신청관리======================================

	/**
	* @Method Name : searchVendorRequestList
	* @Description : 거래처 관리
	*/
	@RequestMapping(value = "baseInfo/searchVendorRequestList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchVendorRequestList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);
			
			String searchVendorName = request.getParameter("searchVendorName");
			String searchVendorNo = request.getParameter("searchVendorNo");
			String searchApplicationType = request.getParameter("searchApplicationType");
			String searchApplicationStatus = request.getParameter("searchApplicationStatus");
			String searchIsNew = request.getParameter("searchIsNew");
			String companyCode = request.getParameter("companyCode");
			String sortColumn		= "";
			String sortDirection	= "";	
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchVendorName", ComUtils.RemoveSQLInjection(searchVendorName, 100));
			params.put("searchVendorNo", ComUtils.RemoveSQLInjection(searchVendorNo, 100));
			params.put("searchApplicationType", searchApplicationType);
			params.put("searchApplicationStatus", searchApplicationStatus);
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = baseInfoSvc.searchVendorRequestList(params);
			
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
	* @Method Name : searchVendorRequestUserList
	* @Description : 거래처 관리
	*/
	@RequestMapping(value = "baseInfo/searchVendorRequestUserList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchVendorRequestUserList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);
	
			String searchVendorName = request.getParameter("searchVendorName");
			String searchVendorNo = request.getParameter("searchVendorNo");
			String searchApplicationType = request.getParameter("searchApplicationType");
			String searchApplicationStatus = request.getParameter("searchApplicationStatus");
			String searchIsNew = request.getParameter("searchIsNew");
			String companyCode = request.getParameter("companyCode");
			String sortColumn		= "";
			String sortDirection	= "";
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchVendorName", ComUtils.RemoveSQLInjection(searchVendorName, 100));
			params.put("searchVendorNo", ComUtils.RemoveSQLInjection(searchVendorNo, 100));
			params.put("searchApplicationType", searchApplicationType);
			params.put("searchApplicationStatus", searchApplicationStatus);
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);
			
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			
			resultList = baseInfoSvc.searchVendorRequestList(params);
	
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
	* @Method Name : callVendorRequestPopup
	* @Description : 업체 신청 팝업 호출
	*/
	@RequestMapping(value = "baseInfo/callVendorRequestPopup.do", method = RequestMethod.GET)
	public ModelAndView callVendorRequestPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{

		String isSearched = StringUtil.replaceNull(request.getParameter("isSearched"));
		String VendorApplicationID = request.getParameter("vendorApplicationID");
		String isAM = request.getParameter("isAdminMenu");

		String returnURL = "user/account/VendorRequestPopup";
		
		if(VendorApplicationID == null)
			VendorApplicationID = "";
		
		if(isSearched.equals("Y")) {
			CoviMap resultMap = new CoviMap();
			CoviMap params = new CoviMap();
			params.put("VendorApplicationID", VendorApplicationID);
			resultMap = baseInfoSvc.searchVendorRequestDetail(params);
			resultMap = (CoviMap) AccountUtil.jobjGetObj(resultMap, "result");
			if(resultMap != null) {
				String ApplicationStatus = AccountUtil.jobjGetStr(resultMap, "ApplicationStatus");
				if(!"T".equals(ApplicationStatus)){
					returnURL = "user/account/VendorRequestViewPopup";
				}
			}
		}
		
		ModelAndView mav = new ModelAndView(returnURL);

		mav.addObject("isSearched", isSearched);
		mav.addObject("isAM", isAM);
		mav.addObject("VendorApplicationID", VendorApplicationID);
		
		return mav;
	}

	/**
	* @Method Name : saveVendorRequestData
	* @Description : 거래처신청 저장
	*/
	@RequestMapping(value = "baseInfo/saveVendorRequestData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveVendorRequestData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			String vdo = StringEscapeUtils.unescapeHtml(request.getParameter("vendorRequestDataObj"));
			CoviMap vendorRequestDataObj = CoviMap.fromObject(vdo);

			String isSearched = AccountUtil.jobjGetStr(vendorRequestDataObj, "IsSearched" );
			vendorRequestDataObj.put("SessionUser", SessionHelper.getSession("USERID"));
			vendorRequestDataObj.put("UserId", SessionHelper.getSession("USERID"));			

			CoviMap returnObj = new CoviMap();

			if("N".equals(isSearched)){
				returnObj = baseInfoSvc.insertVendorRequest(vendorRequestDataObj);
			}
			else if("Y".equals(isSearched)){
				returnObj = baseInfoSvc.updateVendorRequest(vendorRequestDataObj);
			}
			
			if("S".equals(returnObj.getString("status"))){
				returnList.put("returnObj", returnObj);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장");
			}
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "알수없는 에러");
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
	* @Method Name : searchVendorRequestDetail
	* @Description : 거래처 상세조회
	*/
	@RequestMapping(value="baseInfo/searchVendorRequestDetail.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchVendorRequestDetail(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{
			String VendorApplicationID =  request.getParameter("VendorApplicationID");
			String companyCode =  request.getParameter("companyCode");
			
			CoviMap params = new CoviMap();
			params.put("VendorApplicationID", VendorApplicationID);
			params.put("companyCode", companyCode);
			resultMap = baseInfoSvc.searchVendorRequestDetail(params);
			
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
	* @Method Name : deleteVendorRequestList
	* @Description : 거래처 삭제
	*/
	@RequestMapping(value = "baseInfo/deleteVendorRequestList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteVendorRequestList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			String vdAppList = request.getParameter("vdAppList");

			CoviMap params = new CoviMap();
			if(vdAppList != null && !vdAppList.equals("")) params.put("vdAppList", vdAppList.split(","));
			int resultCnt = baseInfoSvc.deleteVendorRequestList(params);
			if(resultCnt == -1){
				returnList.put("resultCnt", resultCnt);
				returnList.put("result", "F");
				
				returnList.put("status", Return.FAIL);
				returnList.put("message", "삭제");
			}
			else{
				returnList.put("resultCnt", resultCnt);
				returnList.put("result", "ok");
				
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제");
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
	* @Method Name : excelDownloadVenderRequestList
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelDownloadVenderRequestList.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadVenderRequestList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String searchVendorName = request.getParameter("searchVendorName");
			String searchVendorNo =request.getParameter("searchVendorNo");
			String searchApplicationType =request.getParameter("searchApplicationType");
			String searchApplicationStatus =request.getParameter("searchApplicationStatus");
			String searchIsNew =request.getParameter("searchIsNew");
			String companyCode =request.getParameter("companyCode");
			
			params.put("searchVendorName", ComUtils.RemoveSQLInjection(searchVendorName, 100));
			params.put("searchVendorNo", ComUtils.RemoveSQLInjection(searchVendorNo, 100));
			params.put("searchApplicationType", searchApplicationType);
			params.put("searchApplicationStatus", searchApplicationStatus);
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);

			/*
			String headerName	= new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			String headerKey	= new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			*/

			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			String headerType	= request.getParameter("headerType");
			
			//String[] headerNames = headerName.split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String searcType =  request.getParameter("searchType");
			
			params.put("SearchType", searcType);
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = baseInfoSvc.excelDownloadVendorRequest(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
	* @Method Name : excelDownloadVenderRequestUserList
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelDownloadVenderRequestUserList.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadVenderRequestUserList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String searchVendorName = request.getParameter("searchVendorName");
			String searchVendorNo =request.getParameter("searchVendorNo");
			String searchApplicationType =request.getParameter("searchApplicationType");
			String searchApplicationStatus =request.getParameter("searchApplicationStatus");
			String searchIsNew =request.getParameter("searchIsNew");
			String companyCode =request.getParameter("companyCode");
			
			params.put("searchVendorName", ComUtils.RemoveSQLInjection(searchVendorName, 100));
			params.put("searchVendorNo", ComUtils.RemoveSQLInjection(searchVendorNo, 100));
			params.put("searchApplicationType", searchApplicationType);
			params.put("searchApplicationStatus", searchApplicationStatus);
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);
			params.put("SessionUser", SessionHelper.getSession("USERID"));

			/*
			String headerName	= new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			String headerKey	= new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			*/

			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			String headerType	= request.getParameter("headerType");
			
			//String[] headerNames = headerName.split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			String searcType =  request.getParameter("searchType");
			
			params.put("SearchType", searcType);
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = baseInfoSvc.excelDownloadVendorRequest(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);

			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
	* @Method Name : vendAprvStatChange
	* @Description : 거래처신청 승인/반려
	*/
	@RequestMapping(value = "baseInfo/vendAprvStatChange.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap vendAprvStatChange(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
	
		try {
			String objStr =  StringEscapeUtils.unescapeHtml(request.getParameter("aprvObj"));
			CoviMap obj = CoviMap.fromObject(objStr);

			boolean stCk = baseInfoSvc.vendAprvStatCk(obj);
			if(stCk){
				result = baseInfoSvc.vendAprvStatChange(obj);
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
	

	//==============================카드신청==========================================

	/**
	* @Method Name : searchCardApplicationList
	* @Description : 카드 목록 조회
	*/
	@RequestMapping(value = "baseInfo/searchCardApplicationList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchCardApplicationList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);

			String searchCardNo = request.getParameter("searchCardNo");
			String searchApplicationTitle =request.getParameter("searchApplicationTitle");
			String searchIsNew =request.getParameter("searchIsNew");
			String companyCode =request.getParameter("companyCode");
			String sortColumn		= "";
			String sortDirection	= "";	
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("searchApplicationTitle",ComUtils.RemoveSQLInjection(searchApplicationTitle, 100));
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);
			params.put("pageSize",pageSize);
			params.put("pageNo", pageNo);
			
			resultList = baseInfoSvc.searchCardApplicationList(params);

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
	* @Method Name : searchCardApplicationUserList
	* @Description : 카드 목록 조회
	*/
	@RequestMapping(value = "baseInfo/searchCardApplicationUserList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchCardApplicationUserList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
	
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);

			String searchCardNo = request.getParameter("searchCardNo");
			String searchApplicationTitle =request.getParameter("searchApplicationTitle");
			String searchIsNew =request.getParameter("searchIsNew");
			String companyCode =request.getParameter("companyCode");
			String sortColumn		= "";
			String sortDirection	= "";	
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("searchApplicationTitle",ComUtils.RemoveSQLInjection(searchApplicationTitle, 100));
			params.put("searchIsNew", searchIsNew);
			params.put("companyCode", companyCode);
			params.put("SessionUser", SessionHelper.getSession("USERID"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = baseInfoSvc.searchCardApplicationList(params);

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
	* @Method Name : excelDownloadCardApplicationList
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelDownloadCardApplicationList.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadCardApplicationList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String searchApplicationTitle = request.getParameter("searchApplicationTitle");
			String searchCardNo =request.getParameter("searchCardNo");
			String companyCode =request.getParameter("companyCode");
			params.put("searchApplicationTitle", ComUtils.RemoveSQLInjection(searchApplicationTitle, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("companyCode", ComUtils.RemoveSQLInjection(companyCode, 100));

			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			String headerType	= request.getParameter("headerType");
			
			//String[] headerNames = headerName.split("†");			
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = baseInfoSvc.excelDownloadCardApplication(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);

			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
	* @Method Name : excelDownloadCardApplicationUserList
	* @Description : 엑셀 다운로드
	*/
	@RequestMapping(value = "baseInfo/excelDownloadCardApplicationUserList.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadCardApplicationUserList(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String searchApplicationTitle = request.getParameter("searchApplicationTitle");
			String searchCardNo =request.getParameter("searchCardNo");;
			String companyCode =request.getParameter("companyCode");
			params.put("searchApplicationTitle", ComUtils.RemoveSQLInjection(searchApplicationTitle, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("companyCode", ComUtils.RemoveSQLInjection(companyCode, 100));
			params.put("SessionUser", SessionHelper.getSession("USERID"));

			/*
			String headerName	= new String( request.getParameter("headerName").getBytes("8859_1"), "UTF-8");
			String headerKey	= new String( request.getParameter("headerKey").getBytes("8859_1"), "UTF-8");
			*/

			String headerName	= request.getParameter("headerName");
			String headerKey	= request.getParameter("headerKey");
			String headerType	= request.getParameter("headerType");
			
			//String[] headerNames = headerName.split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			params.put("headerName", headerName);
			params.put("headerKey", headerKey);
			
			resultList = baseInfoSvc.excelDownloadCardApplication(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);

			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, request.getParameter("title")));
			String title = request.getParameter("title");
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
	* @Method Name : callCardApplicationPopup
	* @Description : 카드신청 팝업 열기
	*/
	@RequestMapping(value = "baseInfo/callCardApplicationPopup.do", method = RequestMethod.GET)
	public ModelAndView callCardApplicationPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{

		String isNew = request.getParameter("isNew");
		String CardApplicationID = request.getParameter("CardApplicationID");
		//String ApplicationStatus = request.getParameter("applicationStatus");
		String isAM = request.getParameter("isAdminMenu");

		CoviMap resultMap = new CoviMap();
		CoviMap params = new CoviMap();
		if(CardApplicationID == null)
			CardApplicationID = "";
		params.put("CardApplicationID", CardApplicationID);
		resultMap = baseInfoSvc.searchCardApplicationDetail(params);
		resultMap = (CoviMap) AccountUtil.jobjGetObj(resultMap, "result");
		String ApplicationStatus = resultMap != null ? AccountUtil.jobjGetStr(resultMap, "ApplicationStatus") : "T";
		
		String returnURL = "user/account/CardApplicationPopup";
		if((!"T".equals(ApplicationStatus))
				&& "N".equals(isNew)){
			returnURL = "user/account/CardApplicationViewPopup";
		}

		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("isNew", isNew);
		mav.addObject("isAM", isAM);
		mav.addObject("CardApplicationID", CardApplicationID);
		return mav;
	}
	
	/**
	* @Method Name : searchCardApplicationDetail
	* @Description : 카드신청 상세조회
	*/
	@RequestMapping(value="baseInfo/searchCardApplicationDetail.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap searchCardApplicationDetail(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();
		CoviMap companyCardList = new CoviMap();

		try{
			String CardApplicationID =  request.getParameter("CardApplicationID");
			
			CoviMap params = new CoviMap();
			params.put("CardApplicationID", CardApplicationID);
			resultMap = baseInfoSvc.searchCardApplicationDetail(params);
			companyCardList = baseInfoSvc.getCompanyCardComboList(params);
			
			returnObj.put("data", resultMap.get("result"));
			returnObj.put("list", AccountUtil.jobjGetObj(companyCardList, "list"));
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
	* @Method Name : getCompanyCardComboList
	* @Description : 카드 상세조회
	*/
	@RequestMapping(value="baseInfo/getCompanyCardComboList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getCompanyCardComboList(HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try{			
			CoviMap params = new CoviMap();
			resultMap = baseInfoSvc.getCompanyCardComboList(params);
			
			returnObj.put("list", AccountUtil.jobjGetObj(resultMap, "list"));
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
	* @Method Name : saveCardApplicationData
	* @Description : 카드신청 저장
	*/
	@RequestMapping(value = "baseInfo/saveCardApplicationData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap saveCardApplicationData(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			String cao = StringEscapeUtils.unescapeHtml(request.getParameter("cardAppObj"));
			CoviMap cardAppObj = CoviMap.fromObject(cao);
			returnList = doSaveCardApplicationData(cardAppObj);		
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
	
	private CoviMap doSaveCardApplicationData(CoviMap cardAppObj) throws Exception 
	{

		CoviMap returnList = new CoviMap();
		try {

			String isNew = AccountUtil.jobjGetStr(cardAppObj, "IsNew");
			String applicationClass = AccountUtil.jobjGetStr(cardAppObj, "ApplicationClass");
			CoviMap returnObj = new CoviMap();
			
			int duplCnt = 0;
			if("PE".equals(applicationClass)){
				
				CoviMap cm = new CoviMap();
				cm.put("CardNo", AccountUtil.jobjGetStr(cardAppObj, "CardNo"));
				cm.put("CardApplicationID", AccountUtil.jobjGetStr(cardAppObj, "CardApplicationID"));
				duplCnt = baseInfoSvc.ckPrivateCardDuplCnt(cm);
			}

			if(duplCnt != 0){
				returnList.put("status", Return.FAIL);
				returnList.put("result", "D");
				returnList.put("message", "이미 등록된 항목");
			}
			else{
				if("Y".equals(isNew)){
					returnObj = baseInfoSvc.insertCardApplication(cardAppObj);
				} else{
					returnObj = baseInfoSvc.updateCardApplication(cardAppObj);
				}
				
				if("S".equals(returnObj.getString("status"))){
					returnList.put("returnObj", returnObj);
					returnList.put("result", "ok");
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "저장");
				}
				else{
					returnList.put("status", Return.FAIL);
					returnList.put("message", "알수없는 에러");
				}
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
	* @Method Name : deleteCardApplicationList
	* @Description : 카드신청 삭제
	*/
	@RequestMapping(value = "baseInfo/deleteCardApplicationList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteCardApplicationList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String cardAppList = request.getParameter("cardAppList");
			CoviMap params = new CoviMap();
			
			if(cardAppList != null && !cardAppList.equals("")) params.put("cardAppList", cardAppList.split(","));
			int resultCnt = baseInfoSvc.deleteCardApplicationList(params);
			
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
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
	* @Method Name : cardAprvStatChange
	* @Description : 카드신청 승인/반려
	*/
	@RequestMapping(value = "baseInfo/cardAprvStatChange.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap cardAprvStatChange(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnVal = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String objStr =  StringEscapeUtils.unescapeHtml(request.getParameter("aprvObj"));
			CoviMap obj = CoviMap.fromObject(objStr);

			result = baseInfoSvc.cardAprvStatChange(obj);
			returnVal.put("result", "ok");
			returnVal.put("status", Return.SUCCESS);
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
	* @Method Name : callBaseCodeExcelUploadPoup
	* @Description : 엑셀 업로드 팝업 호출
	*/
	@RequestMapping(value = "baseInfo/callBaseCodeExcelUploadPoup.do", method = RequestMethod.GET)
	public ModelAndView callBaseCodeExcelUploadPoup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/account/BaseCodeExcelPopup");
	}
	//==============================삭제/수정필요==========================================

	/**
	* @Method Name : searchPrivateCardViewList
	* @Description : 개인카드 목록 조회(미사용)
	*/
	@RequestMapping(value = "baseInfo/searchPrivateCardViewList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap searchPrivateCardViewList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			AccountUtil.setSearchPage(request, params);

			String searchCompanyCode = request.getParameter("searchCompanyCode");
			String searchCardOwner =request.getParameter("searchCardOwner");
			String searchCardNo =request.getParameter("searchCardNo");
			String searchIsUse =request.getParameter("searchIsUse");
			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			
			params.put("searchCompanyCode", searchCompanyCode);
			params.put("searchCardOwner", ComUtils.RemoveSQLInjection(searchCardOwner, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("searchIsUse", searchIsUse);
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			resultList = baseInfoSvc.searchPrivateCardViewList(params);
			
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
	* @Method Name : callPrivateCardViewPopup
	* @Description : 개인카드 팝업 호출(미사용)
	*/
	@RequestMapping(value = "baseInfo/callPrivateCardViewPopup.do", method = RequestMethod.GET)
	public ModelAndView callPrivateCardViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String returnURL = "user/account/PrivateCardViewPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);		
		String cardApplicationID = request.getParameter("CardApplicationID");

		mav.addObject("CardApplicationID", cardApplicationID);
		mav.addObject("testVal", "TEST1");
		return mav;
	}

	/**
	* @Method Name : savePrivateCardUseyn
	* @Description : 개인카드 저장(미사용)
	*/
	@RequestMapping(value = "baseInfo/savePrivateCardUseyn.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap savePrivateCardUseyn(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {

			String cao = StringEscapeUtils.unescapeHtml(request.getParameter("privateCardAppObj"));
			CoviMap privateCardAppObj = CoviMap.fromObject(cao);
			CoviMap returnObj = new CoviMap();
			
			privateCardAppObj.put("SessionUser", SessionHelper.getSession("USERID"));
			
			returnObj = baseInfoSvc.updatePrivateCardUseYN(privateCardAppObj);

			if("S".equals(returnObj.getString("status"))){
				returnList.put("returnObj", returnObj);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장");
			}
			else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", "알수없는 에러");
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
	* @Method Name : excelDownloadPriCard
	* @Description : 엑셀 다운로드(미사용)
	*/
	@RequestMapping(value = "baseInfo/excelDownloadPriCard.do" , method = RequestMethod.GET)
	public ModelAndView excelDownloadPriCard(HttpServletRequest request, HttpServletResponse response) {
		
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {

			String headerName = new String( StringUtil.replaceNull(request.getParameter("headerName")).getBytes("8859_1"), "UTF-8");
			String[] headerNames = headerName.split("†");
			
			CoviMap params = new CoviMap();

			String searchCompanyCode = request.getParameter("searchCompanyCode");
			String searchCardOwner =request.getParameter("searchCardOwner");
			String searchCardNo =request.getParameter("searchCardNo");
			String searchIsUse =request.getParameter("searchIsUse");
			String title =StringUtil.replaceNull(request.getParameter("title"));
			
			params.put("searchCompanyCode", searchCompanyCode);
			params.put("searchCardOwner", ComUtils.RemoveSQLInjection(searchCardOwner, 100));
			params.put("searchCardNo", ComUtils.RemoveSQLInjection(searchCardNo, 100));
			params.put("searchIsUse", searchIsUse);
			resultList = baseInfoSvc.excelDownloadPriCard(params);
			
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
}
