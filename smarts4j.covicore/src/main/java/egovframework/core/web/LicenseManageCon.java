package egovframework.core.web;

import java.io.IOException;
import java.net.URL;
import java.util.Map;
import java.util.Objects;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LicenseSvc;
import egovframework.coviframework.service.CoviService;
import egovframework.coviframework.util.ComUtils;


/**
 * @Class Name : LicenseManageCon.java
 * @Description : 라이선스 관리 화면 
 *
 * @author 코비젼 연구소
 * @since 2020.01.28
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class LicenseManageCon {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	LicenseSvc licenseSvc;
	
	@Autowired
	CoviService coviSvc;
	
	private Logger LOGGER = LogManager.getLogger(LicenseManageCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "/license/licenseWarning.do", method = RequestMethod.GET)
	public ModelAndView devhelper_gridpage(HttpServletRequest request) {
		ModelAndView mav = new ModelAndView("core/admin/LicenseWarning");
		
		String licenseConfirmCode = request.getParameter("licenseConfirmCode"); 
		String pDomainID = SessionHelper.getSession("DN_ID");
		String pDomainUrl = SessionHelper.getSession("DN_URL");
		if (SessionHelper.getSession("UR_LicSeq") != null){
			pDomainID += "_"+SessionHelper.getSession("UR_LicSeq");
		}
		String strJson = RedisShardsUtil.getInstance().get(RedisDataUtil.PRE_LICENSE + pDomainID + LicenseHelper.SUF_LIC_INFO);
		CoviMap jsonObj = null;
		String currentDomain = "";
		if(StringUtil.isNotNull(strJson)){
			try{
				jsonObj = new ObjectMapper().readValue(strJson, CoviMap.class);
				URL url = new URL(request.getRequestURL().toString());
				currentDomain = url.getHost();
			}
			catch(IOException e){
				LOGGER.debug(e);
			}
			catch(Exception e){
				LOGGER.debug(e);
			}
		}
		
		switch(licenseConfirmCode) {
			case "PeriodExpiration":
				mav.addObject("title", "License has expired!!");
				mav.addObject("message", "서비스 이용에 불편을 드려 죄송합니다.<br>정식 라이선스의  서비스 기간이 만료되었습니다.<br>때문에 서비스 이용이 제한됩니다.");
				mav.addObject("subMessage", "관리자에게 문의바랍니다.");
				mav.addObject("engMessage", "Sorry for the inconvenience in the use of the service. "
											+ "The full license of the service has expired. Because of the use of the service is limited.<br>"
											+ "Please contact your administrator or COVISION INC.");
				if (jsonObj != null){
					mav.addObject("etcMessage","~"+LicenseHelper.getDecryptedProperty(StringUtil.replaceNull(jsonObj.get("LicExpireDate"),""), pDomainUrl, "LIUP"));
				}	
				break;
			case "PeriodLimit":
				mav.addObject("title", "Notice that a temporary license has expired!!");
				mav.addObject("message", "서비스 이용에 불편을 드려 죄송합니다.<br>임시 라이선스 이용자의 서비스 기간이 만료되었습니다.<br>때문에 서비스 이용이 제한됩니다.");
				mav.addObject("subMessage", "관리자에게 문의바랍니다.");
				mav.addObject("engMessage", "Sorry for the inconvenience in the use of the service. "
											+ "Temporary licensing of service has expired. Because of the use of the service is limited.<br>"
											+ "Please contact your administrator or COVISION INC.");
				if (jsonObj != null){
					mav.addObject("etcMessage","~"+LicenseHelper.getDecryptedProperty(StringUtil.replaceNull(jsonObj.get("LicEx1Date"),""), pDomainUrl, "LIEx1UP"));
				}	
				break;
			case "UnConfirmedDomain":
				mav.addObject("title", "Unauthorized service domain!!");
				mav.addObject("message", "서비스 이용에 불편을 드려 죄송합니다.<br>요청하신 도메인은 서비스 도메인 라이선스를 위반하였습니다.<br>때문에 서비스 이용이 제한됩니다.");
				mav.addObject("subMessage", "관리자 또는 (주)코비젼(<a href='http://www.covision.co.kr'>www.covision.co.kr</a>)에게 문의바랍니다.");
				mav.addObject("engMessage", "Sorry for the inconvenience in the use of the service. "
											+ "The requested domain services domain license violation. Because of the use of the service is limited.<br>"
											+ "Please contact your administrator or COVISION INC.");//RedisDataUtil.PRE_LICENSE + domainID + LicenseHelper.SUF_LIC_INFO
				if (jsonObj != null){
					mav.addObject("etcMessage",currentDomain +":"+LicenseHelper.getDecryptedProperty(StringUtil.replaceNull(jsonObj.get("LicDomain"),""), pDomainUrl, "LIUD"));
				}	
				break;
			case "UserCountLimit":
				mav.addObject("title", "Unauthorized service user!!");
				mav.addObject("message", "서비스 이용에 불편을 드려 죄송합니다.<br>현 사용자는 라이선스를 초과한 사용자로 서비스 이용을 제한합니다.");
				mav.addObject("subMessage", "관리자에게 문의바랍니다.");
				mav.addObject("engMessage", "Sorry for the inconvenience in the use of the service."
											+ "Current user exceeds the license because the service has been restricted.<br>"
											+ "Please contact your administrator or COVISION INC.");
				if (jsonObj != null){
					mav.addObject("etcMessage",SessionHelper.getSession("UR_SortSeq")+":"
						+LicenseHelper.getDecryptedProperty(StringUtil.replaceNull(jsonObj.get("LicUserCount"),""), pDomainUrl, "LIUC")
						+"("+LicenseHelper.getDecryptedProperty(StringUtil.replaceNull(jsonObj.get("LicExUserCount"),""), pDomainUrl, "LIExUC")+")");
				}	
				break;
			default :
				break;
		}
		
	
		return mav;
	}
	
	@RequestMapping(value = "/license/getConnectionLogList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getConnectionLogList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0], 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1], 100));
			params.put("userCode", request.getParameter("userCode"));
			
			//timezone 적용 날짜변환
			params.put("startDate",ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd 00:00:00")));
			params.put("endDate",ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd 23:59:59")));
			
			resultList = licenseSvc.getConnectionLogList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "/license/getLicenseInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			returnList = licenseSvc.getLicenseInfo();
			
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "/license/removeLicenseCache.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap removeLicenseCache(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
			String removeMailCache = Objects.toString(request.getParameter("removeMailCache"), "N");
			String domainID = request.getParameter("domainID");
			
			//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리 
			if(isSaaS.equalsIgnoreCase("N")){
				domainID = "0";
			}else if(isSaaS.equalsIgnoreCase("Y") && domainID == null) {
				domainID = SessionHelper.getSession("DN_ID");
			}
			
			if(domainID != null) {
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + LicenseHelper.SUF_LIC_INFO);
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_CHECK);
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_STATE);				
	
				if(removeMailCache.equalsIgnoreCase("Y")) {
					instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_MAIL);
				}
				
				instance.removeAll(RedisDataUtil.PRE_LICENSE + domainID + "_*" + LicenseHelper.SUF_LIC_INFO);
				CoviList clist = ComUtils.getLicenseInfo(domainID);
				
				for (int i=0; i< clist.size(); i++){
					CoviMap licenseData =clist.getMap(i);
					String licSeq = licenseData.getString("LicSeq");
					LicenseHelper.resetLicenseSortKey(domainID+"_"+licSeq);
				}	
			}
			
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 라이선스 등록/수정 팝업 호출
	@RequestMapping(value = "/license/goLicenseManagePopup.do", method = RequestMethod.GET)
	public ModelAndView goLicenseManagePopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception{
		ModelAndView mav = new ModelAndView("core/license/LicenseManagePopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	// 라이선스 관리 목록 조회
	@RequestMapping(value = "/license/getLicenseManageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseManageList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			int pageSize = (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0) ? Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"))) : 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0], 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1], 100));
			
			resultMap = licenseSvc.getLicenseManageList(params);
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 정보 조회
	@RequestMapping(value = "/license/getLicenseManageInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseManageInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licSeq", request.getParameter("licSeq"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultMap = licenseSvc.getLicenseManageInfo(params);
			if (resultMap.get("LicModule") != null){
				resultMap.put("Module", PropertiesUtil.getDecryptedProperty(resultMap.getString("LicModule")));
			}	
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 정보key 복호화 조회
	@RequestMapping(value = "/license/decryptLicenseKey.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap decryptLicenseKey(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			if (request.getParameter("licKey") != null){
				resultMap.put("decryptVal", PropertiesUtil.getDecryptedProperty(request.getParameter("licKey")));
			}	
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 포탈 조회
	@RequestMapping(value = "/license/getLicensePortal.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicensePortal(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			
			resultMap = licenseSvc.getLicensePortal(params);
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 명 중복 체크
	@RequestMapping(value = "/license/chkDupLicenseName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap chkDupLicenseName(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licName", request.getParameter("licName"));
			
			resultMap.put("dupCnt", licenseSvc.getDupLicenseName(params));
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 등록
	@RequestMapping(value = "/license/addLicenseInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addLicenseInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licName", request.getParameter("licName"));
			params.put("licModule", request.getParameter("licModule"));
//			params.put("moduleList", StringUtil.replaceNull(request.getParameter("module")).split(";"));
			params.put("isOpt", request.getParameter("isOpt"));
			params.put("portalID", request.getParameter("portalID"));
			params.put("description", request.getParameter("description"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt = licenseSvc.addLicenseInfo(params);
			
			if (cnt > 0) {
				resultMap.put("status", Return.SUCCESS);
			} else {
				resultMap.put("status", Return.FAIL);
			}
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 수정
	@RequestMapping(value = "/license/editLicenseInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap editLicenseInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licSeq", request.getParameter("licSeq"));
			params.put("licName", request.getParameter("licName"));
			params.put("licModule", request.getParameter("licModule"));
//			params.put("moduleList", StringUtil.replaceNull(request.getParameter("module")).split(";"));
			params.put("isOpt", request.getParameter("isOpt"));
			params.put("portalID", request.getParameter("portalID"));
			params.put("description", request.getParameter("description"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("isMbPortal", request.getParameter("isMbPortal"));
			
			int cnt = licenseSvc.editLicenseInfo(params);
			
			if (cnt > 0) {
				resultMap.put("status", Return.SUCCESS);
			} else {
				resultMap.put("status", Return.FAIL);
			}
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 삭제
	@RequestMapping(value = "/license/deleteLicense.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteLicense(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("licSeqList", StringUtil.replaceNull(request.getParameter("licSeq")).split(";"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt = licenseSvc.deleteLicense(params);
			
			if (cnt > 0) {
				resultMap.put("status", Return.SUCCESS);
			} else {
				resultMap.put("status", Return.FAIL);
			}
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 라이선스 현황 목록 조회
	@RequestMapping(value = "/license/getLicenseList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLicenseList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		
		try {
			int pageSize = (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0) ? Integer.parseInt(StringUtil.replaceNull(request.getParameter("pageSize"))) : 1;			
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("selectsearch", request.getParameter("selectsearch"));
			params.put("isService", request.getParameter("isUse"));
			params.put("isSaaS", isSaaS) ;
			if(!isSaaS.equalsIgnoreCase("Y")){
				params.put("domainID", "0") ;
			}
			CoviMap licenseCnt = licenseSvc.getLicenseInfoCnt(params);
			
			resultMap.put("page", licenseCnt.get("page"));
			resultMap.put("list",coviSvc.list("framework.license.selectLicenseUserList", params));			
			resultMap.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}
	
	// 관리자페이지 > 라이선스 현황 엑셀다운로드.
	@RequestMapping(value = "/license/downloadExcel.do", produces="text/html;charset=UTF-8")
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		CoviMap params = new CoviMap();
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		CoviList clist = new CoviList();
		
		try {
			String headerName = request.getParameter("headername");		
			String headerType = request.getParameter("headerType");
			String[] headerNames = StringUtil.replaceNull(headerName).split(";");
			String selectsearch = request.getParameter("selectsearch");
			String isService = request.getParameter("isUse");
			
			if(!isSaaS.equalsIgnoreCase("Y")){
				params.put("domainID", "0") ;
			}
			
			params.put("selectsearch", ComUtils.RemoveSQLInjection(selectsearch, 100));
			params.put("isService", ComUtils.RemoveSQLInjection(isService, 100));
			
			clist = coviMapperOne.list("framework.license.selectDownloadExcel1st", params);
			
			if (!isService.equals("Y")) {
				CoviList clist2 = new CoviList();
				clist2 = coviMapperOne.list("framework.license.selectDownloadExcel2nd", params);
				clist.addAll(clist2);
			}
			
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "LicenseList");
			viewParams.put("headerType", headerType);
			viewParams.put("list", clist);
			
			mav = new ModelAndView(returnURL, viewParams);
					
		}
		catch (NullPointerException e) {
			LOGGER.error("LicenseManageCon", e);
		}
		catch (Exception e) {
			LOGGER.error("LicenseManageCon", e);
		}
		
		return mav;
	}
}
