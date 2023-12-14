package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.common.web.CommonCon;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.CostCenterSvc;
import egovframework.coviframework.util.ComUtils;



/**
 * @Class Name : CostCenterCon.java
 * @Description : CostCenter컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CostCenterCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CostCenterSvc costCenterSvc;

	@Autowired
	private CommonCon commonCon;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * @Method Name : getCostCenterlist
	 * @Description : 코스트센터 목록 조회
	 */
	@RequestMapping(value = "costCenter/getCostCenterlist.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterlist(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "soapCostCenterType",	required = false, defaultValue="")	String soapCostCenterType,
			@RequestParam(value = "soapCostCenterName",	required = false, defaultValue="")	String soapCostCenterName) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			params.put("soapCostCenterType",	soapCostCenterType);
			params.put("soapCostCenterName",	soapCostCenterName);
			params.put("searchProperty",		searchProperty);
			params.put("sortColumn",			ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",			ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",				pageNo);
			params.put("pageSize",				pageSize);
			params.put("searchType",			searchType);
			params.put("searchStr",				ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("companyCode",			companyCode);
			
			resultList = costCenterSvc.getCostCenterlist(params);
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
	 * @Method Name : getCostCenterPopup
	 * @Description : 코스트센터 팝업 호출
	 */
	@RequestMapping(value = "costCenter/getCostCenterPopup.do", method = RequestMethod.GET)
	public ModelAndView getCostCenterPopup(Locale locale, Model model) {
		String returnURL = "user/account/CostCenterPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : getCostCenterDetail
	 * @Description : 코스트센터 상세 조회
	 */
	@RequestMapping(value = "costCenter/getCostCenterDetail.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterDetail(
			@RequestParam(value = "costCenterID",	required = false, defaultValue="") String costCenterID,
			@RequestParam(value = "companyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("costCenterID",	costCenterID);
			params.put("companyCode",	companyCode);
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
	 * @Method Name : getCostCenterCodeCnt
	 * @Description : 코스트센터 코드 존재 여부 확인
	 */
	@RequestMapping(value = "costCenter/getCostCenterCodeCnt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterCodeCnt(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "costCenterCode",		required = false,	defaultValue = "") String costCenterCode
			) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			
			params.put("costCenterCode",	costCenterCode);
			
			rtValue = costCenterSvc.getCostCenterCodeCnt(params);
			
			rtValue.put("result", "ok");
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	
	/**
	 * @Method Name : saveCostCenterInfo
	 * @Description : 코스트센터 저장
	 */
	@RequestMapping(value = "costCenter/saveCostCenterInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveCostCenterInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "costCenterID",		required = false,	defaultValue = "") String costCenterID,
			@RequestParam(value = "companyCode",		required = false,	defaultValue = "") String companyCode,
			@RequestParam(value = "costCenterType",		required = false,	defaultValue = "") String costCenterType,
			@RequestParam(value = "costCenterCode",		required = false,	defaultValue = "") String costCenterCode,
			@RequestParam(value = "costCenterName",		required = false,	defaultValue = "") String costCenterName,
			@RequestParam(value = "nameCode",			required = false,	defaultValue = "") String nameCode,
			@RequestParam(value = "usePeriodStart",		required = false,	defaultValue = "") String usePeriodStart,
			@RequestParam(value = "usePeriodFinish",	required = false,	defaultValue = "") String usePeriodFinish,
			@RequestParam(value = "isPermanent",		required = false,	defaultValue = "") String isPermanent,
			@RequestParam(value = "isUse",				required = false,	defaultValue = "") String isUse,
			@RequestParam(value = "description",		required = false,	defaultValue = "") String description,
			@RequestParam(value = "listPage",			required = false,	defaultValue = "N") String listPage,
			@RequestParam(value = "saveProperty",		required = false,	defaultValue = "") String saveProperty
			) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			
			params.put("costCenterID",		costCenterID);	
			params.put("companyCode",		companyCode);	
			params.put("costCenterType",	costCenterType);	
			params.put("costCenterCode",	ComUtils.RemoveScriptAndStyle(costCenterCode));	
			params.put("costCenterName",	ComUtils.RemoveScriptAndStyle(costCenterName));	
			params.put("nameCode",			ComUtils.RemoveScriptAndStyle(nameCode));	
			params.put("usePeriodStart",	usePeriodStart);	
			params.put("usePeriodFinish",	usePeriodFinish);	
			params.put("isPermanent",		isPermanent);	
			params.put("isUse",				isUse);	
			params.put("description",		ComUtils.RemoveScriptAndStyle(description));
			params.put("listPage",			listPage);
			params.put("saveProperty",	saveProperty);	
			
			costCenterSvc.saveCostCenterInfo(params);
			
			rtValue.put("result", "ok");
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : deleteCostCenterInfo
	 * @Description : 코스트센터 삭제
	 */
	@RequestMapping(value = "costCenter/deleteCostCenterInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap deleteCostCenterInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "deleteSeq",		required = false,	defaultValue = "") String deleteSeq) throws Exception {
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap();
		
		try {
			
			params.put("deleteSeq",		deleteSeq);	
			costCenterSvc.deleteCostCenter(params);
			
			rtValue.put("result", "ok");
			rtValue.put("status", Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}
	
	/**
	 * @Method Name : costCenterExcelPopup
	 * @Description : 코스트센터 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "costCenter/costCenterExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView costCenterExcelPopup(
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty,
			Locale locale, Model model) {
		String returnURL = "user/account/CostCenterExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : costCenterExcelUpload
	 * @Description : 코스트센터 엑셀 업로드
	 */
	@RequestMapping(value = "costCenter/costCenterExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap costCenterExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			String saveProperty = RedisDataUtil.getBaseConfig("eAccCostCenterAutoCode");
			params.put("uploadfile", uploadfile);
			params.put("saveProperty", saveProperty);
			returnData = costCenterSvc.costCenterExcelUpload(params);
			
			returnData.put("status",	Return.SUCCESS);
			returnData.put("message",	"업로드 되었습니다");
		} catch (SQLException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	/**
	 * @Method Name : costCenterExcelDownload
	 * @Description : 코스트센터 엑셀 다운로드
	 */
	@RequestMapping(value = "costCenter/costCenterExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView costCenterExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "searchType",			required = false, defaultValue="")	String searchType,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "soapCostCenterType",	required = false, defaultValue="")	String soapCostCenterType,
			@RequestParam(value = "soapCostCenterName",	required = false, defaultValue="")	String soapCostCenterName,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			
			params.put("soapCostCenterType",	commonCon.convertUTF8(soapCostCenterType));
			params.put("soapCostCenterName",	commonCon.convertUTF8(soapCostCenterName));
			params.put("searchProperty",		commonCon.convertUTF8(searchProperty));
			params.put("companyCode",			commonCon.convertUTF8(companyCode));
			params.put("searchType",			commonCon.convertUTF8(searchType));
			params.put("searchStr",				commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchStr, 100)));
			params.put("headerKey",				commonCon.convertUTF8(headerKey));
			resultList = costCenterSvc.getCostCenterExcelList(params);
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("cnt",			resultList.get("cnt"));
			viewParams.put("headerName",	headerNames);
			
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			//viewParams.put("title",	accountFileUtil.getDisposition(request, title));
			viewParams.put("title",	accountFileUtil.getDisposition(request,URLDecoder.decode(title,"utf-8")));
			viewParams.put("sheetName", URLDecoder.decode(title,"utf-8"));
			viewParams.put("headerType",commonCon.convertUTF8(headerType));
			
			mav = new ModelAndView(returnURL, viewParams);
		}  catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		}catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	/**
	 * @Method Name : getCostCenterUserMappingDeptList
	 * @Description : 코스트센터 유저 맵핑 리스트 [부서]
	 */
	@RequestMapping(value = "costCenter/getCostCenterUserMappingDeptList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterUserMappingDeptList(
			@RequestParam(value = "companyCode",	required = false, defaultValue="")	String companyCode) throws Exception{ 
		
		CoviMap returnList	= new CoviMap();
		CoviList resultList	= new CoviList();
		
		try{
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			resultList = costCenterSvc.getCostCenterUserMappingDeptList(params);
			returnList.put("list",		resultList);
			returnList.put("status",	Return.SUCCESS);
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
	 * @Method Name : getCostCenterUserMappingUserList
	 * @Description : 코스트센터 유저 맵핑 리스트
	 */
	@RequestMapping(value = "costCenter/getCostCenterUserMappingUserList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCostCenterUserMappingUserList(
			@RequestParam(value = "deptCode",	required = false, defaultValue="")	String deptCode) throws Exception{ 
		CoviMap returnList	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("deptCode", deptCode);
			
			String domainID = SessionHelper.getSession("DN_ID");
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
				String[] orgOrders = orgMapOrderSet.split("\\|");
				params.put("orgOrders", orgOrders);
			}
			
			resultList = costCenterSvc.getCostCenterUserMappingUserList(params);
			returnList.put("list",		resultList);
			returnList.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	 * @Method Name : updateCostCenterUserMappingInfo
	 * @Description : 코스트센터 유저 맵핑 정보 저장
	 */
	@RequestMapping(value = "costCenter/updateCostCenterUserMappingInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap updateCostCenterUserMappingInfo(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception {
		
		CoviMap rtValue	= new CoviMap();
		CoviMap params		= new CoviMap(paramMap);
		
		try {
			rtValue = costCenterSvc.updateCostCenterUserMappingInfo(params);
			rtValue.put("paramMap",	paramMap);
			rtValue.put("status",	Return.SUCCESS);
		} catch (SQLException e) {
			rtValue.put("status",	Return.FAIL);
			rtValue.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtValue.put("status", Return.FAIL);
			rtValue.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtValue;
	}

	/**
	 * @Method Name : costCenterExcelDownload
	 * @Description : 코스트센터 엑셀 다운로드
	 */
	@RequestMapping(value = "costCenter/costCenterUserMappingExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView costCenterUserMappingExcelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",			required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",			required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "headerType",		required = false, defaultValue="")	String headerType,
			@RequestParam(value = "title",			required = false, defaultValue="")	String title,
			@RequestParam(value = "companyCode",			required = false, defaultValue="")	String companyCode){
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			
			params.put("headerKey",				commonCon.convertUTF8(headerKey));
			params.put("companyCode",				commonCon.convertUTF8(companyCode));
			resultList = costCenterSvc.getCostCenterUserMappingExcelList(params);
			
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
	 * @Method Name : costCenterUserMappingExcelPopup
	 * @Description : 사용자별 코스트센터 매핑 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "costCenter/costCenterUserMappingExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView costCenterUserMappingExcelPopup(Locale locale, Model model) {
		String returnURL = "user/account/CostCenterUserMappingExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : costCenterUserMappingExcelUpload
	 * @Description : 사용자별 코스트센터 매핑 엑셀 업로드
	 */
	@RequestMapping(value = "costCenter/costCenterUserMappingExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap costCenterUserMappingExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			returnData = costCenterSvc.costCenterUserMappingExcelUpload(params);
			
			returnData.put("status",	Return.SUCCESS);
			returnData.put("message",	"업로드 되었습니다");
		} catch (SQLException e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status",	Return.FAIL);
			returnData.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnData;		
	}
	
	/**
	 * @Method Name : costCenterSync
	 * @Description : 코스트센터 동기화
	 */
	@RequestMapping(value = "costCenter/costCenterSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap costCenterSync(){
		
		CoviMap	resultList	= new CoviMap();
		resultList = costCenterSvc.costCenterSync();
		return resultList;
	}
	
	/**
	 * @Method Name : costCenterUserMappingSync
	 * @Description : 사용자 별 코스트센터 매핑 동기화
	 */
	@RequestMapping(value = "costCenter/costCenterUserMappingSync.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap costCenterUserMappingSync(){
		
		CoviMap	resultList	= new CoviMap();
		resultList = costCenterSvc.costCenterUserMappingSync();
		return resultList;
	}
}
