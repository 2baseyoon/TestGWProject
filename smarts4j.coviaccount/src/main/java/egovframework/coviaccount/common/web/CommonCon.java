package egovframework.coviaccount.common.web;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.lang.invoke.MethodHandles;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.security.SecureRandom;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.simple.parser.JSONParser;
import org.mortbay.jetty.Request;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
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
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.FormManageSvc;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.CommonUtil;



/**
 * @Class Name : CommonCon.java
 * @Description : 공통컨트롤러
 * @Modification Information 
 * @ 2016.05.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 11.02
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CommonCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private CommonSvc commonSvc;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private FormManageSvc formManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "layout/tab.do")
	public ModelAndView getTab(HttpServletRequest request, HttpServletResponse response) {
		String returnURL	= "layout/tab";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "accountCommon/getCompanyCodeOfUser.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCompanyCodeOfUser(@RequestParam(value = "SessionUser",	required = false, defaultValue="") String sessionUser) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			if(sessionUser.equals("")) {
				returnList.put("CompanyCode",	commonSvc.getCompanyCodeOfUser());	
			} else {
				returnList.put("CompanyCode",	commonSvc.getCompanyCodeOfUser(sessionUser));
			}
			returnList.put("result",		"ok");
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * getBaseCodeComboMulti : 기초관리코드 멀티[콤보]
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getBaseCodeComboMulti.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBaseCodeComboMulti(
			@RequestParam(value = "codeGroups",	required = false, defaultValue="") String codeGroups,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap returnList = new CoviMap();
		
		try {
			CoviList resultList = new CoviList();
			if(StringUtils.isNoneBlank(codeGroups)){
				String keyCode			= "";
				
				CoviMap params = new CoviMap();
				params.put("codeGroups", codeGroups);
				params.put("companyCode", companyCode);
				
				CoviList allList		= commonSvc.getBaseCodeComboMulti(params);
				
				String[] codeGroupArray = codeGroups.split(",");
				for(int ar=0; ar<codeGroupArray.length; ar++){
					
					CoviList addList		= new CoviList();
					CoviMap	addObject	= new CoviMap();
					
					keyCode = codeGroupArray[ar];
					
					for(int i=0; i<allList.size(); i++){
						CoviMap info	= (CoviMap) allList.get(i);
						String key		= info.get("CodeGroup") == null ? "" : info.get("CodeGroup").toString();
						if(key.equals(keyCode)){
							addList.add(info);
						}
					}
					
					addObject.put(keyCode, addList);
					resultList.add(addObject);
				}
				/*
				String codeGroupArray[] = codeGroups.split(",");
				for (String codeGroup: codeGroupArray) {
					
					//codegroup별로 jsonobject 생성
					CoviMap resultObject	= new CoviMap();
					resultObject.put(codeGroup, commonSvc.getBaseCodeComboMulti(codeGroup));
					
					//codegroup jsonobject를 jsonarray에 
					resultList.add(resultObject);
			    }
			    */
			}
			
			returnList.put("list",		resultList);
			returnList.put("result",	"ok");

			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * getBaseCodeCombo : 기초관리코드 [콤보]
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getBaseCodeCombo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBaseCodeCombo(
			@RequestParam(value = "codeGroups",	required = false, defaultValue="") String codeGroups,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap returnList = new CoviMap();
		
		try {
			CoviList resultList = new CoviList();
			if(StringUtils.isNoneBlank(codeGroups)){
				String[] codeGroupArray = codeGroups.split(",");
				
				CoviMap params = new CoviMap();
				params.put("companyCode", companyCode);
				for (String codeGroup: codeGroupArray) {
					params.put("codeGroup", codeGroup);
					
					//codegroup별로 jsonobject 생성
					CoviMap resultObject	= new CoviMap();
					resultObject.put(codeGroup, commonSvc.getBaseCodeCombo(params));
					
					//codegroup jsonobject를 jsonarray에 
					resultList.add(resultObject);
			    }
			}
			
			returnList.put("list",		resultList);
			returnList.put("result",	"ok");

			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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

	@RequestMapping(value = "accountCommon/getBaseCodeData.do", method= { RequestMethod.POST, RequestMethod.GET })
	public	@ResponseBody CoviMap getBaseCodeData(
			@RequestParam(value = "codeGroups",	required = false, defaultValue="") String codeGroups,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultObject	= new CoviMap();
			if(StringUtils.isNoneBlank(codeGroups)){
				String[] codeGroupArray = codeGroups.split(",");
				
				CoviMap params = new CoviMap();
				params.put("companyCode", companyCode);
				for (String codeGroup: codeGroupArray) {
					params.put("codeGroup", codeGroup);
					
					//codegroup별로 jsonobject 생성
					resultObject.put(codeGroup, commonSvc.getBaseCodeData(params));
			    }
			}
			
			returnList.put("list",		resultObject);
			returnList.put("result",	"ok");

			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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

	// 부가세추가 버튼을 위한 서브세트 가져오기
		@RequestMapping(value = "accountCommon/getBaseCodeSubSet.do", method=RequestMethod.POST)
		public	@ResponseBody CoviMap getBaseCodeSubSet(
				@RequestParam(value = "codeGroups",	required = false, defaultValue="") String codeGroups,
				@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

			CoviMap returnList = new CoviMap();
			
			try {
				CoviMap resultObject	= new CoviMap();
				if(StringUtils.isNoneBlank(codeGroups)){
					String[] codeGroupArray = codeGroups.split(",");
					
					CoviMap params = new CoviMap();
					params.put("companyCode", companyCode);
					for (String codeGroup: codeGroupArray) {
						params.put("codeGroup", codeGroup);
						
						//codegroup별로 jsonobject 생성
						resultObject.put("SubCodeSet", commonSvc.getBaseCodeSubSet(params));
				    }
				}
				
				returnList.put("list",		resultObject);
				returnList.put("result",	"ok");

				returnList.put("status",	Return.SUCCESS);
				returnList.put("message",	"조회되었습니다");
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

	//사용 안하는 기초코드까지 전체 조회
	@RequestMapping(value = "accountCommon/getBaseCodeDataAll.do", method= { RequestMethod.GET, RequestMethod.POST })
	public	@ResponseBody CoviMap getBaseCodeDataAll(
			@RequestParam(value = "codeGroups",	required = false, defaultValue="") String codeGroups,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultObject	= new CoviMap();
			if(StringUtils.isNoneBlank(codeGroups)){
				String[] codeGroupArray = codeGroups.split(",");
				
				CoviMap params = new CoviMap();
				params.put("companyCode", companyCode);
				for (String codeGroup: codeGroupArray) {
					params.put("codeGroup", codeGroup);
					
					//codegroup별로 jsonobject 생성
					resultObject.put(codeGroup, commonSvc.getBaseCodeDataAll(params));
			    }
			}
			
			returnList.put("list",		resultObject);
			returnList.put("result",	"ok");

			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	//사용 하는 기초코드만 전체 조회
	@RequestMapping(value = "accountCommon/getBaseCodeDataUseAll.do", method= { RequestMethod.GET, RequestMethod.POST })
	public	@ResponseBody CoviMap getBaseCodeDataUseAll(
			@RequestParam(value = "isUseCodeGroups",	required = false, defaultValue="") String isUseCodeGroups,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap resultObject	= new CoviMap();
			if(StringUtils.isNoneBlank(isUseCodeGroups)){
				String[] codeGroupArray = isUseCodeGroups.split(",");
				
				CoviMap params = new CoviMap();
				params.put("companyCode", companyCode);
				for (String codeGroup: codeGroupArray) {
					params.put("codeGroup", codeGroup);
					
					//codegroup별로 jsonobject 생성
					resultObject.put(codeGroup, commonSvc.getBaseCodeData(params));
			    }
			}
			
			returnList.put("list",		resultObject);
			returnList.put("result",	"ok");
			
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * getBaseGrpCodeCombo : 기초관리코드 [콤보]
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getBaseGrpCodeCombo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBaseGrpCodeCombo(
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviList resultList = new CoviList();

			//codegroup별로 jsonobject 생성
			CoviMap resultObject	= new CoviMap();
			CoviMap params = new CoviMap();
			params.put("companyCode", companyCode);
			resultObject.put("Group", commonSvc.getBaseGrpCodeCombo(params));
			
			//codegroup jsonobject를 jsonarray에 
			resultList.add(resultObject);
			returnList.put("list",		resultList);
			returnList.put("result",	"ok");

			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * AccountCommonPopup : Account 공통팝업 호출
	 * @return mav
	 */
	@RequestMapping(value = "accountCommon/accountCommonPopup.do",method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView accountCommonPopup(
			HttpServletRequest request,	HttpServletResponse response,
			@RequestParam(value = "popupName",	required = false,	defaultValue = "") String popupName) throws Exception {
		
		String returnURL = "cmmn/popup/" + popupName;
		
		return new ModelAndView(returnURL);
	}

	@RequestMapping(value = "CommonPopup/getBankCodeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBankCodeList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = Integer.parseInt(request.getParameter("pageSize"));
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			String searchText = request.getParameter("searchText");
			String companyCode = request.getParameter("companyCode");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("companyCode", companyCode);
			params.put("codeGroup", "Bank");
			CoviMap resultObj = commonSvc.getBankCodeList(params);

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
	
	/**
	 * getAccountCommonPopupList : 공통팝업조회 - 사용 X
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getAccountCommonPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAccountCommonPopupList(
			@RequestParam(value = "sortBy",		required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",		required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",	required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "pageing",	required = false, defaultValue="")	String pageing,
			@RequestParam(value = "popupName",	required = false, defaultValue="")	String popupName,
			@RequestParam(value = "paramTxt",	required = false, defaultValue="")	String paramTxt,
			@RequestParam(value = "ExpAppID",	required = false, defaultValue="")	String ExpAppID,
			@RequestParam(value = "idStr",	required = false, defaultValue="")	String idStr) throws Exception{

		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			if(idStr != null){
				StringTokenizer stID = new StringTokenizer(idStr,",");
				String getID = "";
				String pageList = "";
				while(stID.hasMoreTokens()){
					getID = stID.nextToken();
					if("".equals(pageList)){
						pageList = "'"+getID+"'";
					}else{
						pageList = pageList+",'"+getID+"'";
					}
				}
				params.put("pageList",		pageList);
			}
			params.put("ExpAppID",		ExpAppID);
			
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageing",		pageing);
			params.put("paramTxt",		paramTxt);
			params.put("popupName",		popupName);
			resultList = commonSvc.getAccountCommonPopupList(params);
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
	
	@RequestMapping(value = "CommonPopup/getVendorPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getVendorPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = Integer.parseInt(request.getParameter("pageSize"));
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			String searchText = request.getParameter("searchText");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			String isPE = request.getParameter("isPE");
			params.put("isPE", isPE);

			params.put("companyCode", request.getParameter("companyCode"));
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
	
	@RequestMapping(value = "CommonPopup/getCopyPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCopyPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = Integer.parseInt(request.getParameter("pageSize"));
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			/*String searchText = request.getParameter("searchText");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			String isPE = request.getParameter("isPE");
			params.put("isPE", isPE);*/

			params.put("vendorName", request.getParameter("vendorName"));
			params.put("SDate", request.getParameter("SDate"));
			params.put("EDate", request.getParameter("EDate"));
			params.put("proofCode", request.getParameter("proofCode"));
			params.put("vendorNo", request.getParameter("vendorNo"));
			params.put("usid", request.getParameter("usid"));
			params.put("companyCode", request.getParameter("companyCode"));
			
			/*params.put("SessionUser", SessionHelper.getSession("USERID"))*/;
			
			CoviMap resultObj = commonSvc.getCopyPopupList(params);
			
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
	

	@RequestMapping(value = "CommonPopup/getBaseCodeSearchCommPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCodeSearchCommPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",	required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception{
		
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			int pageSize			= Integer.parseInt(request.getParameter("pageSize"));
			int pageNo				= Integer.parseInt(request.getParameter("pageNo"));
			String sortColumn		= "";
			String sortDirection	= "";
			
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			
			String searchText	= request.getParameter("searchText");
			String codeGroup	= request.getParameter("codeGroup");
			String companyCode	= request.getParameter("companyCode");
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("searchText",	ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("codeGroup",		codeGroup);
			params.put("companyCode",	companyCode);
			
			returnList = commonSvc.getBaseCodeSearchCommPopupList(params);
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
			returnList.put("result",	"ok");
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
	

	@RequestMapping(value = "accountCommon/getCashBillPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCashBillPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {

			CoviMap params = new CoviMap();

			String idStr = request.getParameter("idStr");
			String expAppID = request.getParameter("ExpAppID");
			if(idStr != null){
				StringTokenizer stID = new StringTokenizer(idStr,",");
				String getID = "";
				String pageList = "";
				while(stID.hasMoreTokens()){
					getID = stID.nextToken();
					if("".equals(pageList)){
						pageList = getID;
					}else{
						pageList = pageList+","+getID;
					}
				}
				if(pageList != null && !pageList.equals("")) params.put("pageList", pageList.split(","));
			}
			params.put("ExpAppID",		expAppID);
			
			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = 1;
			int pageNo =  1;
			if (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			int pageOffset = (pageNo - 1) * pageSize;
			if(pageOffset < 0) {
				throw new Exception();
			}

			params.put("pageOffset", pageOffset);
			params.put("pageSize", pageSize);

			String startDD = request.getParameter("startDD");
			String endDD = request.getParameter("endDD");
			String confirmNum = request.getParameter("confirmNum");
			String franchiseCorpName = request.getParameter("franchiseCorpName");
			String franchiseCorpNum = request.getParameter("franchiseCorpNum");
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("startDD", startDD);
			params.put("endDD", endDD);
			params.put("confirmNum", ComUtils.RemoveSQLInjection(confirmNum, 100));
			params.put("franchiseCorpName", ComUtils.RemoveSQLInjection(franchiseCorpName, 100));
			params.put("franchiseCorpNum", ComUtils.RemoveSQLInjection(franchiseCorpNum, 100));
			CoviMap resultObj = commonSvc.getCashBillPopupList(params);

			CoviMap page = new CoviMap();
			page.put("pageNo", pageNo);
			page.put("pageSize", pageSize);
			int cnt = resultObj.getInt("cnt");
			page.addAll(ComUtils.setPagingData(page,cnt));

			returnList.put("page", page);
			
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

	@RequestMapping(value = "accountCommon/getLeftMenuList.do")
	public	@ResponseBody CoviMap getLeftMenuList(HttpServletRequest request, HttpServletResponse response,
			@RequestBody HashMap paramMap) throws Exception{
		CoviMap resultObj 	= new CoviMap();
		CoviMap params			= new CoviMap(paramMap);
		try{
			CoviMap returnList = commonSvc.getLeftMenuList(params);
			
			resultObj.put("list",		returnList.get("list"));
			resultObj.put("status",		Return.SUCCESS);
			resultObj.put("message",	"조회되었습니다");
			
		} catch (SQLException e) {
			resultObj.put("status", 	Return.FAIL);
			resultObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultObj.put("status", 	Return.FAIL);
			resultObj.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
	
		return resultObj;
	}

	@RequestMapping(value = "accountCommon/getExpAppDocList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getExpAppDocList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			int pageSize = Integer.parseInt(request.getParameter("pageSize"));
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			String applicationTitle =  request.getParameter("ApplicationTitle");
			params.put("ApplicationTitle", ComUtils.RemoveSQLInjection(applicationTitle, 100));
			params.put("companyCode",		commonSvc.getCompanyCodeOfUser());
			CoviMap resultObj = commonSvc.getExpAppDocList(params);
			
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

	/**
		accountCommon/getMobileReceipt.do
		모바일 영수증 목록 조회
	 */

	@RequestMapping(value = "accountCommon/getMobileReceipt.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getMobileReceipt(HttpServletRequest request, HttpServletResponse response) throws Exception{

		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			

			String expenceApplicationID = request.getParameter("ExpenceApplicationID");
			String receiptID = request.getParameter("ReceiptIDList");
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
			
			
			params.put("ExpenceApplicationID", expenceApplicationID);
			if(receiptIDList != null && !receiptIDList.equals("")) params.put("addPageList", receiptIDList.split(","));
			
			resultList = commonSvc.getMobileReceipt(params);
			resultList.put("status",	Return.SUCCESS);
			resultList.put("result",	"ok");
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
	
	

	@RequestMapping(value = "CommonPopup/getPrivateCardPopupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getPrivateCardPopupList(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = Integer.parseInt(request.getParameter("pageSize"));
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
					
			params.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);

			String searchText = request.getParameter("searchText");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));

			params.put("companyCode", request.getParameter("companyCode"));
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
	
	@RequestMapping(value = "accountCommon/getPropertyInfoSearchType.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getPropertyInfoSearchType(
			@RequestParam(value = "pageID",		required = false, defaultValue="")	String pageID
			) throws Exception {

		CoviMap resultObject = new CoviMap();
		try {
			//String searchType = accountUtil.getPropertyInfo("account.searchType." + pageID);
			String searchType = accountUtil.getBaseCodeInfo("eAccSearchType", pageID);
			resultObject.put("pageSearchTypeProperty",	searchType);
			resultObject.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			resultObject.put("status",	Return.FAIL);
			resultObject.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultObject.put("status",	Return.FAIL);
			resultObject.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}

		return resultObject;
	}

	@RequestMapping(value = "accountCommon/getPropertyInfoSyncType.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getPropertyInfoSyncType(
			@RequestParam(value = "pageID",		required = false, defaultValue="")	String pageID
			) throws Exception {

		CoviMap resultObject = new CoviMap();
		try {
			//String searchType = accountUtil.getPropertyInfo("account.syncType." + pageID);
			String searchType = accountUtil.getBaseCodeInfo("eAccSyncType", pageID);
			resultObject.put("pageSyncTypeProperty",	searchType);
			resultObject.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			resultObject.put("status",	Return.FAIL);
			resultObject.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultObject.put("status",	Return.FAIL);
			resultObject.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}

		return resultObject;
	}
	
	public String convertUTF8(String str) throws Exception {
		String returnStr = "";
		//returnStr = new String(str.getBytes("8859_1"), "UTF-8");
		returnStr = str; 
		return returnStr;
	}
	//한글파라미터변환
	public String convertURLUTF8(String str) throws Exception {
		String returnStr = "";
		returnStr = new String(str.getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8);
		return returnStr;
	}	
	//popup search List

	@RequestMapping(value = "accountCommon/getAccountSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getAccountSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "searchProperty",		required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "accountClass",		required = false, defaultValue="")	String accountClass,
			@RequestParam(value = "amSearchTypePop",	required = false, defaultValue="")	String amSearchTypePop,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode) throws Exception{
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
			params.put("searchProperty",	searchProperty);
			params.put("accountClass",		accountClass);
			params.put("amSearchTypePop",	amSearchTypePop);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("companyCode",			companyCode);
			
			resultList = commonSvc.getAccountSearchPopupList(params);
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
	@RequestMapping(value = "accountCommon/getFavoriteAccountSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFavoriteAccountSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode) throws Exception{
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
			
			resultList = commonSvc.getFavoriteAccountSearchPopupList(params);
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
	
	@RequestMapping(value = "accountCommon/setFavoriteAccountSearchPopupList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setFavoriteAccountSearchPopupList(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {

			String saveObj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			CoviMap getObj = CoviMap.fromObject(saveObj);

			int resultCnt = commonSvc.setFavoriteAccountSearchPopupList(getObj);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장");
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

	@RequestMapping(value = "accountCommon/getCardReceiptPopupInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptPopupInfo(
			@RequestParam(value = "receiptID",		required = false, defaultValue="")	String receiptID,
			@RequestParam(value = "approveNo",		required = false, defaultValue="")	String approveNo,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("receiptID",			receiptID);
			params.put("approveNo",			approveNo);
			params.put("searchProperty",	searchProperty);
			params.put("companyCode",		commonSvc.getCompanyCodeOfUser());
			
			resultList = commonSvc.getCardReceiptPopupInfo(params);
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
	
	@RequestMapping(value = "accountCommon/getCardReceiptSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getCardReceiptSearchPopupList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty,
			@RequestParam(value = "ExpAppID",		required = false, defaultValue="")	String expAppID,
			@RequestParam(value = "idStr",			required = false, defaultValue="")	String idStr,
			@RequestParam(value = "startDD",		required = false, defaultValue="")	String startDD,
			@RequestParam(value = "endDD",			required = false, defaultValue="")	String endDD,
			@RequestParam(value = "storeName",		required = false, defaultValue="")	String storeName,
			@RequestParam(value = "cardNo",			required = false, defaultValue="")	String cardNo,
			@RequestParam(value = "approveNo",		required = false, defaultValue="")	String approveNo,
			@RequestParam(value = "UR_Code",		required = false, defaultValue="")	String userCode,
			@RequestParam(value = "cardID",			required = false, defaultValue="")	String cardID) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			if(idStr != null){
				StringTokenizer stID = new StringTokenizer(idStr,",");
				String getID = "";
				String pageList = "";
				while(stID.hasMoreTokens()){
					getID = stID.nextToken();
					if("".equals(pageList)){
						pageList = getID;
					}else{
						pageList = pageList+","+getID;
					}
				}
				if(pageList != null && !pageList.equals("")) params.put("pageList", pageList.split(","));
			}
			
			params.put("searchProperty",	searchProperty);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("ExpAppID",			expAppID);
			params.put("idStr",				idStr);
			params.put("startDD",			startDD);
			params.put("endDD",				endDD);
			params.put("storeName",			ComUtils.RemoveSQLInjection(storeName, 100));
			params.put("cardNo",			ComUtils.RemoveSQLInjection(cardNo, 100));
			params.put("approveNo",			ComUtils.RemoveSQLInjection(approveNo, 100));
			params.put("cardID",			cardID);
			params.put("UR_Code",			userCode);
			
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
	
	@RequestMapping(value = "accountCommon/getCostCenterSearchPopupList.do", method=RequestMethod.POST)
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
	
	@RequestMapping(value = "accountCommon/getFavoriteCostCenterSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFavoriteCostCenterSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "popupType",			required = false, defaultValue="")	String popupType,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode) throws Exception{
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
			params.put("popupType",			popupType);
			params.put("companyCode",		companyCode);
			
			resultList = commonSvc.getFavoriteCCSearchPopupList(params);
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
	
	@RequestMapping(value = "accountCommon/setFavoriteCostCenterSearchPopupList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setFavoriteCostCenterSearchPopupList(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();


		try {

			String saveObj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			CoviMap getObj = CoviMap.fromObject(saveObj);

			int resultCnt = commonSvc.setFavoriteCCSearchPopupList(getObj);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장");
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
	
	@RequestMapping(value = "accountCommon/getStandardBriefSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getStandardBriefSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "sbSearchTypePop",	required = false, defaultValue="")	String sbSearchTypePop,
			@RequestParam(value = "searchStr",			required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "StandardBriefSearchStr",	required = false, defaultValue="")	String standardBriefSearchStr,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode
			) throws Exception{
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
			params.put("sbSearchTypePop",	sbSearchTypePop);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			// 기본 json정보에 들어있는 값으로 영향도 파악이 어려워 여기서 replace
			if(standardBriefSearchStr != null && !standardBriefSearchStr.equals("")) params.put("StandardBriefSearchStr", standardBriefSearchStr.replace("&apos;","'").replace("'","").split(","));
			params.put("companyCode",		companyCode);
			
			resultList = commonSvc.getStandardBriefSearchPopupList(params);
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
	

	@RequestMapping(value = "accountCommon/getFavoriteStandardBriefSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getFavoriteStandardBriefSearchPopupList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "StandardBriefSearchStr",	required = false, defaultValue="")	String standardBriefSearchStr,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode) throws Exception{
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
			// 기본 json정보에 들어있는 값으로 영향도 파악이 어려워 여기서 replace
			if(standardBriefSearchStr != null && !standardBriefSearchStr.equals("")) params.put("StandardBriefSearchStr", standardBriefSearchStr.replace("&apos;","'").replace("'","").split(","));
			params.put("companyCode",		companyCode);
			
			resultList = commonSvc.getFavoriteStandardBriefSearchPopupList(params);
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
	
	@RequestMapping(value = "accountCommon/setFavoriteStandardBriefSearchPopupList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setFavoriteStandardBriefSearchPopupList(
		HttpServletRequest request, HttpServletResponse response,
		@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();


		try {

			String saveObj = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			CoviMap getObj = CoviMap.fromObject(saveObj);

			int resultCnt = commonSvc.setFavoriteStandardBriefSearchPopupList(getObj);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장");
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
	
	@RequestMapping(value = "accountCommon/getTaxInvoicePopupInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoicePopupInfo(
			@RequestParam(value = "taxInvoiceID",		required = false, defaultValue="")	String taxInvoiceID) throws Exception{
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("taxInvoiceID", taxInvoiceID);
			resultList = commonSvc.getTaxInvoicePopupInfo(params);
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
	
	@RequestMapping(value = "accountCommon/getTaxinvoiceSearchPopupList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxinvoiceSearchPopupList(
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",			required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",		required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "ExpAppID",		required = false, defaultValue="")	String ExpAppID,
			@RequestParam(value = "idStr",			required = false, defaultValue="")	String idStr,
			@RequestParam(value = "writeDateS",		required = false, defaultValue="")	String writeDateS,
			@RequestParam(value = "writeDateE",		required = false, defaultValue="")	String writeDateE,
			@RequestParam(value = "tiSearchTypePop",required = false, defaultValue="")	String tiSearchTypePop,
			@RequestParam(value = "searchStr",		required = false, defaultValue="")	String searchStr,
			@RequestParam(value = "invoiceeEmail1",	required = false, defaultValue="")	String invoiceeEmail1,
			@RequestParam(value = "searchProperty",	required = false, defaultValue="")	String searchProperty) throws Exception{
			
		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= "";
			String sortDirection	= "";	
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}
			if(idStr != null){
				StringTokenizer stID = new StringTokenizer(idStr,",");
				String getID = "";
				String pageList = "";
				while(stID.hasMoreTokens()){
					getID = stID.nextToken();
					if("".equals(pageList)){
						pageList = getID;
					}else{
						pageList = pageList+","+getID;
					}
				}
				if(pageList != null && !pageList.equals("")) params.put("pageList", pageList.split(","));
			}

			params.put("searchProperty",	searchProperty);
			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			pageNo);
			params.put("pageSize",			pageSize);
			params.put("ExpAppID",			ExpAppID);
			params.put("idStr",				idStr);
			params.put("writeDateS",		writeDateS);
			params.put("writeDateE",		writeDateE);
			params.put("tiSearchTypePop",	tiSearchTypePop);
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			params.put("invoiceeEmail1",	ComUtils.RemoveSQLInjection(invoiceeEmail1, 100));
			
			resultList = commonSvc.getTaxinvoiceSearchPopupList(params);
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
	 * @Method Name : getInterfaceLogViewList
	 * @Description : 인터페이스 로그 조회
	 */
	@RequestMapping(value = "accountCommon/getInterfaceLogViewList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getInterfaceLogViewList(
			@RequestParam(value = "sortBy",				required = false, defaultValue="")	String sortBy,
			@RequestParam(value = "pageNo",				required = false, defaultValue="1")	String pageNo,
			@RequestParam(value = "pageSize",			required = false, defaultValue="1")	String pageSize,
			@RequestParam(value = "companyCode",		required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "interfaceRecvType",	required = false, defaultValue="")	String interfaceRecvType,
			@RequestParam(value = "interfaceStatus",	required = false, defaultValue="")	String interfaceStatus,
			@RequestParam(value = "interfaceType",		required = false, defaultValue="")	String interfaceType,
			@RequestParam(value = "ifTargetType",		required = false, defaultValue="")	String ifTargetType,
			@RequestParam(value = "ifMethodName",		required = false, defaultValue="")	String ifMethodName) throws Exception{
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
			params.put("interfaceRecvType",	interfaceRecvType);
			params.put("interfaceStatus",	interfaceStatus);
			params.put("interfaceType",		interfaceType);
			params.put("ifTargetType",		ComUtils.RemoveSQLInjection(ifTargetType, 100));
			params.put("ifMethodName",		ComUtils.RemoveSQLInjection(ifMethodName, 100));
			params.put("companyCode",		companyCode);
			
			resultList = commonSvc.getInterfaceLogViewList(params);
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
	 * @Method Name : getTaxInvoiceXmlInfo
	 * @Description : 인터페이스 로그 조회
	 */
	@RequestMapping(value = "accountCommon/getTaxInvoiceXmlInfo.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getTaxInvoiceXmlInfo(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile){
		CoviMap resultList	= new CoviMap();
		CoviMap params			= new CoviMap();
		try {
			params.put("uploadfile",	uploadfile);
			resultList = commonSvc.getTaxInvoiceXmlInfo(params);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList; 
	}
	
	/**
	 * getApplicationStatus : 비용신청 상태
	 * @param expenceApplicationID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getApplicationStatus.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getApplicationStatus(
			@RequestParam(value = "expenceApplicationID",	required = false, defaultValue="") String expenceApplicationID) throws Exception{

		CoviMap returnList	= new CoviMap();
		CoviMap params			= new CoviMap();
		try {
			params.put("expenceApplicationID",	expenceApplicationID);
			CoviMap resultList = commonSvc.getApplicationStatus(params);
			
			returnList.put("list",		resultList);
			returnList.put("result",	"ok");
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * searchUsageTextData : 적요 조회
	 * @param expenceApplicationID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/searchUsageTextData.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap searchUsageCommentData(
			@RequestParam(value = "ReceiptID",	required = false, defaultValue="") String receiptID,
			@RequestParam(value = "ProofCode",	required = false, defaultValue="") String proofCode,
			@RequestParam(value = "CompanyCode",	required = false, defaultValue="") String companyCode) throws Exception{

		CoviMap returnList	= new CoviMap();
		CoviMap params			= new CoviMap();
		try {
			params.put("ReceiptID",	receiptID);
			params.put("ProofCode",	proofCode);
			params.put("companyCode", "".equals(companyCode) ? SessionHelper.getSession("DN_Code") : companyCode);
			
			CoviMap resultList = commonSvc.searchUsageTextData(params);
			
			returnList.put("data",		resultList);
			returnList.put("result",	"ok");
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
	 * saveUsageTextData : 적요 저장
	 * @param expenceApplicationID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/saveUsageTextData.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap saveUsageTextData(
			@RequestParam(value = "ReceiptID",			required = false, defaultValue="") String receiptID,
			@RequestParam(value = "ProofCode",			required = false, defaultValue="") String proofCode,
			@RequestParam(value = "UsageText",			required = false, defaultValue="") String usageText,
			@RequestParam(value = "AccountCode",		required = false, defaultValue="") String accountCode,
			@RequestParam(value = "StandardBriefID",	required = false, defaultValue="") String standardBriefID) throws Exception{

		int cnt = 0;
		CoviMap returnList	= new CoviMap();
		
		CoviMap params			= new CoviMap();
		try {
			params.put("ReceiptID",	receiptID);
			params.put("ProofCode",	proofCode);
			params.put("UsageText",	usageText);
			params.put("AccountCode", accountCode);
			params.put("StandardBriefID", standardBriefID);
			
			cnt = commonSvc.saveUsageTextData(params);
			
			returnList.put("cnt",		cnt);
			returnList.put("result",	"ok");
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
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
			
	/*Tmap관련 Start*/
	/**
	 * searchMapLocations : tmap 위치 목록조회
	 * @param SearchKeyword, Count
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/searchMapLocations.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap searchMapLocations(
			@RequestParam(value = "SearchKeyword",	required = false, defaultValue="") String strSearchKeyword,
			@RequestParam(value = "Count",	required = false, defaultValue="") String strCount) throws Exception{
		
		String strAppKey = RedisDataUtil.getBaseConfig("TmapApiKey");
        String strResCoordType = "EPSG3857";
        String strReqCoordType = "WGS84GEO";
        strSearchKeyword = URLEncoder.encode(strSearchKeyword, "UTF-8");
 
        String strUrl = RedisDataUtil.getBaseConfig("TmapApiUrl_Locations");
        strUrl += String.format("&appKey=%s&searchKeyword=%s&resCoordType=%s&reqCoordType=%s&count=%s", strAppKey, strSearchKeyword, strResCoordType, strReqCoordType, strCount);
		
		return mapCommon(strUrl, "GET","application/json; charset=UTF-8");
	}
	/**
	 * getMapRoute : tmap 경로찾기
	 * @param : SearchOption : 최단거리+유/무료
	 * 			TrafficInfo : 교통정보 표출 옵션 
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "accountCommon/getMapRoute.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getRoute(
			@RequestParam(value = "StartX",	required = true) String strStartX,
			@RequestParam(value = "StartY",	required = true) String strStartY,
			@RequestParam(value = "EndX",	required = true) String strEndX,
			@RequestParam(value = "EndY",	required = true) String strEndY,
			@RequestParam(value = "SearchOption",	required = false, defaultValue="10") String strSearchOption,
			@RequestParam(value = "TrafficInfo",	required = false, defaultValue="N") String strTrafficInfo) throws Exception{ 
		
		String strAppKey = RedisDataUtil.getBaseConfig("TmapApiKey");
        String strResCoordType = "EPSG3857";
        String strReqCoordType = "WGS84GEO";
        
        String strUrl = RedisDataUtil.getBaseConfig("TmapApiUrl_Route");
        strUrl += String.format("&appKey=%s&startX=%s&startY=%s&endX=%s&endY=%s&reqCoordType=%s&resCoordType=%s&searchOption=%s&trafficInfo=%s", strAppKey, strStartX,strStartY, strEndX, strEndY, strReqCoordType, strResCoordType, strSearchOption, strTrafficInfo);
		 
		return mapCommon(strUrl, "GET","application/json; charset=UTF-8");
	}
	public	@ResponseBody CoviMap mapCommon(String strUrl
			,	String strRequestMethod
			,	String strContentType) throws Exception{
		CoviMap result = new CoviMap();
		URL url = null;
		HttpURLConnection urlc = null;
		BufferedReader br = null;
		try{
			url = new URL(strUrl);
			urlc = (HttpURLConnection) url.openConnection();

			urlc.setRequestMethod(strRequestMethod);
			urlc.setRequestProperty("Content-Type", strContentType);
		
			
			try {
				br = new BufferedReader(new InputStreamReader(urlc.getInputStream(), "UTF-8"));
			} catch (IOException ioE) {
				throw ioE;
			} catch (Exception ex) {
				throw ex;
			}

			String inputLine = "";
			StringBuffer response = new StringBuffer();
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine);
			}

			if(response.length() != 0){
				JSONParser parser = new JSONParser();
				Object returnedObj = parser.parse(response.toString());
				result.put("result", returnedObj);
			}
		} catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
		} catch(Exception ex){
			logger.error(ex.getLocalizedMessage(), ex);
		} finally{
			if(urlc != null){urlc.disconnect();urlc = null;}
			if(br != null){ br.close();;br = null;}
		}
		return result;
	}
	
	@RequestMapping(value = "accountCommon/getKakaoBizUseList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getKakaoBizUseList(
			@RequestParam(value = "StartDate",	required = true) String startDate,
			@RequestParam(value = "EndDate",	required = true) String endDate,
			@RequestParam(value = "Vertical",	required = true) String  vertical) throws Exception{ 
		
        CloseableHttpClient httpclient = HttpClients.createDefault();
        
        String kakaoDomain = RedisDataUtil.getBaseConfig("KakaoDomain"); 	//https://mob-b2b-dev.kakao.com 개발, https://b2b-api.kakaomobility.com 운영
        String kakaoCorpId = RedisDataUtil.getBaseConfig("KakaoCorpId");	//기업 ID
        String empNo = SessionHelper.getSession("UR_EmpNo");				//사번
        
        CoviMap returnList = new CoviMap();
        CloseableHttpResponse httpResponse = null;
        try {
            final Integer nonce = new SecureRandom().nextInt(100000);
            final String httpMethod = "GET";
            final Long timestamp = new Date().getTime();
            final String url = kakaoDomain + "/external/v1/orders";

            final String token = HmacEncoder.encode(nonce, url, httpMethod, kakaoCorpId, timestamp);

            HttpGet httpGet = new HttpGet(url + "?start_date="+startDate+"&end_date="+endDate+"&vertical_code="+vertical+"&member_identifier="+empNo+"&page=1&per=1000");
            //HttpGet httpGet = new HttpGet(url + "?start_date=20210501&end_date=20210527&vertical_code=TAXI&member_identifier=338&page=1&per=1000");
            httpGet.addHeader("Authorization", "Token " + token);
            
            httpGet.addHeader("x-mob-b2b-corp-id", kakaoCorpId);
            httpGet.addHeader("x-mob-b2b-nonce", nonce.toString());
            httpGet.addHeader("x-mob-b2b-timestamp", timestamp.toString());
            httpResponse = httpclient.execute(httpGet);
            
            String responseData = EntityUtils.toString(httpResponse.getEntity());
            org.json.JSONObject resultList = new org.json.JSONObject(responseData);
            
            CoviList addList = new CoviList();
			
            if(resultList.has("error")) {
            	returnList.put("list",		addList);
            	returnList.put("status",	Return.FAIL);
            	returnList.put("message",	resultList.get("error"));
            }else {
            	org.json.JSONArray useList2 = resultList.getJSONArray("orders");
            	
            	if("NAVI".equals(vertical)) {
                	for (int i = 0; i < useList2.length(); i++) {
                		org.json.JSONObject info	= (org.json.JSONObject) useList2.get(i);
                		
                		CoviMap	addObject	= new CoviMap();
                		addObject.put("departure_time", 	info.get("departure_time"));
                		addObject.put("departure_point", 	info.get("departure_point"));
                		addObject.put("arrival_point", 		"null".equals(info.get("arrival_point").toString())?"":info.get("arrival_point").toString());
                		addObject.put("total_distance", 	"null".equals(info.get("total_distance").toString())?"":info.get("total_distance").toString());
                		addList.add(addObject);
    				}
            	}else if("TAXI".equals(vertical)) {
            		CoviMap taxiInfoObj = new CoviMap();
            		for (int i = 0; i < useList2.length(); i++) {
                		org.json.JSONObject info = (org.json.JSONObject) useList2.get(i);
                		org.json.JSONArray paymentInfo = (org.json.JSONArray) info.get("payment_items");
                		
                		if(paymentInfo.length() > 0) {
                			for (int j = 0; j < paymentInfo.length(); j++) {
                				org.json.JSONObject paymentItem = (org.json.JSONObject) paymentInfo.get(j);
                				if("fare".equals(paymentItem.get("item_type")) && !"".equals(paymentItem.get("id"))){
                            		CoviMap params = new CoviMap();
                            		params.put("paymentItemId", paymentItem.get("id"));
                            		String apprNO = commonSvc.getApprovalNoData(params);
                            		
                            		if(!"".equals(apprNO) && apprNO != null) {
                      					HashMap<String, Object> taxiInfo = new HashMap<String, Object>();
                                		taxiInfo.put("departure_point", (String) info.get("departure_point"));	//출발지
                                		taxiInfo.put("arrival_point", "null".equals(info.get("arrival_point").toString())?"":info.get("arrival_point").toString()); //도착지
                                		taxiInfo.put("use_code", "null".equals(info.get("use_code").toString())?"":info.get("use_code").toString());		//목적
                                		taxiInfo.put("group_name", "null".equals(info.get("group_name").toString())?"":info.get("group_name").toString());	//그룹명
                                		taxiInfoObj.put(apprNO, taxiInfo);
                            		}
                				}
							}
                		}
    				}
            		addList.add(taxiInfoObj);
            	}
            	
                returnList.put("list",		AccountUtil.convertNullToSpace(addList));
    			returnList.put("status",	Return.SUCCESS);
    			returnList.put("message",	"조회되었습니다");
            }
            
            returnList.put("list",		AccountUtil.convertNullToSpace(addList));
			returnList.put("status",	Return.SUCCESS);
			returnList.put("message",	"조회되었습니다");
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);  		
        } catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);  		
        } finally {
        	if(httpResponse != null) {
        		httpResponse.close();
        	}
        	if(httpclient != null) {
        		httpclient.close();
        	}
        }
        return returnList;
	}
	
	@RequestMapping(value = "accountCommon/getKakaoBizApprovalList.do", method = {RequestMethod.GET, RequestMethod.POST})
	public	@ResponseBody CoviMap getKakaoBizApprovalList(
			@RequestParam(value = "StartDate",	required = false) String startDate,
			@RequestParam(value = "EndDate",	required = false) String endDate) throws Exception{ 
		
        String kakaoDomain = RedisDataUtil.getBaseConfig("KakaoDomain"); 	//https://mob-b2b-dev.kakao.com 개발, https://b2b-api.kakaomobility.com 운영
        String kakaoCorpId = RedisDataUtil.getBaseConfig("KakaoCorpId");	//기업 ID
        
        CoviMap returnList = new CoviMap();
        CloseableHttpResponse httpResponse = null;
        try(CloseableHttpClient httpclient = HttpClients.createDefault()) {
            final Integer nonce = new SecureRandom().nextInt(100000);
            final String httpMethod = "GET";
            final Long timestamp = new Date().getTime();
            final String url = kakaoDomain + "/external/v1/payment_approvals";

            final String token = HmacEncoder.encode(nonce, url, httpMethod, kakaoCorpId, timestamp);
            
            //일주일 데이터 수신
            if(startDate == null || "".equals(startDate) || endDate == null || "".equals(endDate)) {
                Calendar week = Calendar.getInstance();
                week.add(Calendar.DATE , -7);
                String beforeWeek = new java.text.SimpleDateFormat("yyyyMMdd").format(week.getTime());
                
                startDate = beforeWeek;
                endDate = new java.text.SimpleDateFormat("yyyyMMdd").format(new Date());	
            }
            
            HttpGet httpGet = new HttpGet(url + "?start_date=" + startDate + "&end_date=" + endDate + "&page=1&per=2000");
            httpGet.addHeader("Authorization", "Token " + token);
            
            httpGet.addHeader("x-mob-b2b-corp-id", kakaoCorpId);
            httpGet.addHeader("x-mob-b2b-nonce", nonce.toString());
            httpGet.addHeader("x-mob-b2b-timestamp", timestamp.toString());
            httpResponse = httpclient.execute(httpGet);
            
            String responseData = EntityUtils.toString(httpResponse.getEntity());
            org.json.JSONObject resultList = new org.json.JSONObject(responseData);
            
            if(resultList.has("error")) {
            	returnList.put("status",	Return.FAIL);
            	returnList.put("message",	resultList.get("error"));
            }else {
            	org.json.JSONArray useList2 = resultList.getJSONArray("payment_approvals");
            	for (int i = 0; i < useList2.length(); i++) {
            		org.json.JSONObject info	= (org.json.JSONObject) useList2.get(i);
            		
            		CoviMap addMap = new CoviMap();
            		addMap.put("Id", 	info.get("id"));
            		addMap.put("PaymentItemId", 	info.get("payment_item_id"));
            		addMap.put("Amount", 		"null".equals(info.get("amount").toString())?"":info.get("amount").toString());
            		addMap.put("PayType", 	"null".equals(info.get("pay_type").toString())?"":info.get("pay_type").toString());
            		addMap.put("ApprovalNo", 	"null".equals(info.get("approval_no").toString())?"":info.get("approval_no").toString());
            		addMap.put("OrgDateTime", 	"null".equals(info.get("org_date_time").toString())?"":info.get("org_date_time").toString());
            		addMap.put("CardNumber", 	"null".equals(info.get("card_number").toString())?"":info.get("card_number").toString());
            		
            		commonSvc.saveKakaoApprovalList(addMap);
				}
                
    			returnList.put("status",	Return.SUCCESS);
    			returnList.put("message",	"저장되었습니다.");
            }
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);  		
        } catch (Exception e) {
			returnList.put("status",	Return.FAIL);
			returnList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);  		
        } finally {
        	if(httpResponse != null) {
        		httpResponse.close();
        	}
        }
        return returnList;
	}
	
	@RequestMapping("accountCommon/getNoteIsUse.do")
	public ResponseEntity<CoviMap> getNoteIsUse(@RequestParam String companyCode, @RequestParam String formCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("companyCode", companyCode);
		params.put("formCode", formCode);
		
		return new ResponseEntity(formManageSvc.getNoteIsUse(params), HttpStatus.OK);
	}
	
	@RequestMapping("accountCommon/getExchangeIsUse.do")
	public ResponseEntity<CoviMap> getExchangeIsUse(@RequestParam String companyCode, @RequestParam String formCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("companyCode", companyCode);
		params.put("formCode", formCode);
		
		return new ResponseEntity(formManageSvc.getExchangeIsUse(params), HttpStatus.OK);
	}
}
