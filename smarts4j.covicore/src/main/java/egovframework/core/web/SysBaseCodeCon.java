package egovframework.core.web;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SysBaseCodeSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : SysBaseConfigCon.java
 * @Description : 시스템 - 기초설정관리
 * @Modification Information 
 * @ 2016.04.07 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysBaseCodeCon {

	private Logger LOGGER = LogManager.getLogger(SysBaseCodeCon.class);
	
	@Autowired
	private SysBaseCodeSvc sysBaseCodeSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getBaseCode select 컨트롤 option 데이터 처리 
	 * @param request
	 * @param codeGroups
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCode(HttpServletRequest request,
			@RequestParam(value = "codeGroups", required = true, defaultValue = "") String codeGroups) throws Exception {
		
		CoviMap returnList = new CoviMap();

		try {
			CoviList resultList = new CoviList();
			if(StringUtils.isNoneBlank(codeGroups)){
				String codeGroupArray[] = codeGroups.split(",");
				for (String codeGroup: codeGroupArray) {
					//codegroup별로 jsonobject 생성
					CoviMap resultObject = new CoviMap();
					resultObject.put(codeGroup, RedisDataUtil.getBaseCode(codeGroup));
					//codegroup jsonobject를 jsonarray에 
					resultList.add(resultObject);
			    }
			}
			
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	
	/**
	 * getDataBaseConfig : 시스템 관리 - 기초코드 관리 목록 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "domain", required = false, defaultValue = "") String domain,
			@RequestParam(value = "bizSection", required = false, defaultValue = "") String bizSection,
			@RequestParam(value = "codeGroup", required = false, defaultValue = "") String codeGroup,
			@RequestParam(value = "selectsearch", required = false, defaultValue = "") String selectsearch,
			@RequestParam(value = "searchtext", required = false, defaultValue = "") String searchtext,
			@RequestParam(value = "startdate", required = false, defaultValue = "") String startdate,
			@RequestParam(value = "enddate", required = false, defaultValue = "") String enddate,
			@RequestParam(value = "codeName", required = false, defaultValue = "") String codeName,
			@RequestParam(value = "isUse", required = false, defaultValue = "") String isUse,
			@RequestParam(value = "reservedInt", required = false, defaultValue = "") String reservedInt,
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "10") String pageSize) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortColumn = ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirection = ( sortBy != null )? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("bizSection", bizSection);
			params.put("codeGroup", codeGroup);
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			params.put("codeName", codeName);
			params.put("isUse", isUse);
			params.put("reservedInt", reservedInt);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}		
			
			if(domain.isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			resultList = sysBaseCodeSvc.select(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * addbaseconfiglayerpopup : 시스템 관리 - 기초코드 관리 추가 및 수정 버튼 레이어팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "basecode/goBaseCodePopup.do", method = RequestMethod.GET)
	public ModelAndView goBaseCodePopup(Locale locale, Model model) {
		String returnURL = "core/system/addbasecodelayerpopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * baseconfigexcelupload : 시스템 관리 - 기초설정 관리 엑셀 업로드
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "basecode/uploadExcel.do", method = RequestMethod.GET)
	public ModelAndView uploadExcel(Locale locale, Model model) {
		String returnURL = "admin/system/baseconfigexcelupload";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	
	/**
	 * addBaseConfig : 기초설정 관리 데이터 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap addBaseCode(HttpServletRequest request, 
			@RequestParam(value = "DN_ID", required = true) String dnId,
			@RequestParam(value = "BizSection", required = true, defaultValue = "") String bizSection,
			@RequestParam(value = "SortKey", required = false, defaultValue = "") String sortKey,
			@RequestParam(value = "CodeGroup", required = true, defaultValue = "") String codeGroup,
			@RequestParam(value = "Code", required = true, defaultValue = "") String code,
			@RequestParam(value = "CodeName", required = true, defaultValue = "") String codeName,
			@RequestParam(value = "IsUse", required = false, defaultValue = "Y") String isUse,
			@RequestParam(value = "Description", required = false, defaultValue = "") String desc,
			@RequestParam(value = "MultiCodeName", required = false, defaultValue = "") String multiCodeName,
			@RequestParam(value = "Reserved1", required = false) String reserved1,
			@RequestParam(value = "Reserved2", required = false) String reserved2,
			@RequestParam(value = "Reserved3", required = false) String reserved3,
			@RequestParam(value = "ReservedInt", required = false) String reservedInt) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("DN_ID", dnId);
			params.put("bizSection", bizSection);
			params.put("codeGroup", codeGroup);
			params.put("code", code);
			params.put("sortKey", sortKey);
			params.put("isUse", isUse);
			params.put("codeName", codeName);
			params.put("multiCodeName", multiCodeName);
			params.put("reserved1", reserved1.equals("") ? null : reserved1);				// 해당 값이 빈값일 경우 NULL 넣음. TODO 향후 개선 필요
			params.put("reserved2", reserved2.equals("") ? null : reserved2);				// ..
			params.put("reserved3", reserved3.equals("") ? null : reserved3);				// ..
			params.put("reservedInt", reservedInt.equals("") ? null : reservedInt);
			params.put("description", desc);
			params.put("registerCode", SessionHelper.getSession("USERID"));
			
			returnList.put("object", sysBaseCodeSvc.insert(params));
			
			//redis set
			//String codeID = params.get("CodeID").toString();
			CoviMap selectParams = new CoviMap();
			selectParams.put("code", code);
			selectParams.put("codeGroup", codeGroup);
			selectParams.put("domainID", dnId);
			RedisDataUtil.setBaseCode(code, codeGroup, sysBaseCodeSvc.selectOneString(selectParams));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateBaseConfig : 기초설정 관리 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyBaseCode(HttpServletRequest request, 
			@RequestParam(value = "Seq", required = true, defaultValue = "") String seq,
			@RequestParam(value = "DN_ID", required = true ) String dnId,
			@RequestParam(value = "BizSection", required = true, defaultValue = "") String bizSection,
			@RequestParam(value = "SortKey", required = false, defaultValue = "") String sortKey,
			@RequestParam(value = "CodeGroup", required = true, defaultValue = "") String codeGroup,
			@RequestParam(value = "Code", required = true, defaultValue = "") String code,
			@RequestParam(value = "CodeName", required = true, defaultValue = "") String codeName,
			@RequestParam(value = "IsUse", required = false, defaultValue = "Y") String isUse,
			@RequestParam(value = "Description", required = false, defaultValue = "") String desc,
			@RequestParam(value = "MultiCodeName", required = false, defaultValue = "") String multiCodeName,
			@RequestParam(value = "Reserved1", required = false, defaultValue = "") String reserved1,
			@RequestParam(value = "Reserved2", required = false, defaultValue = "") String reserved2,
			@RequestParam(value = "Reserved3", required = false, defaultValue = "") String reserved3,
			@RequestParam(value = "ReservedInt", required = false, defaultValue = "") String reservedInt) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("codeID", seq);
			params.put("DN_ID", dnId);
			params.put("domainID", dnId);
			params.put("bizSection", bizSection);
			params.put("codeGroup", codeGroup);
			params.put("code", code);
			params.put("sortKey", sortKey);
			params.put("isUse", isUse);
			params.put("codeName", codeName);
			params.put("multiCodeName", multiCodeName);
			params.put("reserved1", reserved1);
			params.put("reserved2", reserved2);
			params.put("reserved3", reserved3);
			if(reservedInt.isEmpty())
				params.put("reservedInt", null);
			else
				params.put("reservedInt", reservedInt);
			params.put("description", desc);
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			
			returnList.put("object", sysBaseCodeSvc.update(params));
			
			//redis set
			RedisDataUtil.setBaseCode(code, codeGroup, sysBaseCodeSvc.selectOneString(params));
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * updateIsUseBaseConfig : 기초설정 관리에서 사용여부 값 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap modifyUse(HttpServletRequest request, 
			@RequestParam(value = "Code", required = true, defaultValue = "") String code,
			@RequestParam(value = "CodeGroup", required = true, defaultValue = "") String codeGroup,
			@RequestParam(value = "DomainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "IsUse", required = true, defaultValue = "") String isUse) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("code", code);
			params.put("codeGroup", codeGroup);
			params.put("domainID", domainID);
			params.put("isUse", isUse);
			params.put("modID", SessionHelper.getSession("USERID"));
			
			returnList.put("object", sysBaseCodeSvc.updateIsUse(params));
			
			CoviMap selectedMap = sysBaseCodeSvc.selectOneObject(params);
			
			if(isUse.equalsIgnoreCase("Y")){
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonString = mapperObj.writeValueAsString(selectedMap);
				//redis set
				RedisDataUtil.setBaseCode(code, codeGroup, jsonString, domainID);
			} else {
				RedisDataUtil.removeBaseCode(code, codeGroup, domainID);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			returnList.put("etcs", "");
			
		} catch (JsonMappingException e) {
			returnList.put("status", Return.FAIL);
		} catch (JsonGenerationException e) {
			returnList.put("status", Return.FAIL);
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			//returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * selectOneBaseConfig : 기초설정 관리에서 하나의 데이터 셀렉트
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/getOne.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getOneBaseCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("code", request.getParameter("code"));
			params.put("codeGroup", request.getParameter("codeGroup"));
			params.put("domainID", request.getParameter("domainID"));
			
			resultList = sysBaseCodeSvc.selectOne(params);
			
			// 22.02.28 : code값에 빈값이 들어가 있어 조회가 해당 code값을 못찾는 경우, codeID로 다시 한번 더 검색.
			if ( resultList.get("map").toString().equals("[{}]") ) {
				params.put("codeID", request.getParameter("codeID")); 	
				resultList = sysBaseCodeSvc.selectOne(params);
			}
			
			returnList.put("list", resultList.get("map"));
			returnList.put("result", "ok");
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * deleteBaseConfig : 기초설정관리 데이터 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap removeBaseCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			String selValArr[] = StringUtil.replaceNull(request.getParameter("selVal")).split(",");
			
			params.put("selValArr", selValArr);
			sysBaseCodeSvc.delete(params);
			
			for (String selVal : selValArr) {
				String codeGroup = selVal.split("\\|")[0];
				String code = selVal.split("\\|")[1];
				
				RedisDataUtil.removeBaseCode(code, codeGroup);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "basecode/checkDouble.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap checkDoubleBaseCode(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String dnId = request.getParameter("DN_ID");
		String CodeGroup = request.getParameter("CodeGroup");
		String Code = request.getParameter("Code");	
		int resultCnt = 0;
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("DN_ID", dnId);
			params.put("codeGroup", CodeGroup);
			params.put("code", Code);
			
			resultCnt = sysBaseCodeSvc.selectForCheckingDouble(params);
			
			if(resultCnt == 0)
				returnList.put("result", "ok");
			else
				returnList.put("result", "not ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	@RequestMapping(value = "basecode/encrypt.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap encryptBaseCodeValue(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String settValue = request.getParameter("SettingValue");
		String resultValue = "";
		CoviMap returnList = new CoviMap();
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")); 

		try {
			AES aes = new AES(key, "N");
			resultValue = aes.encrypt(settValue);		// 키, 설정값으로 교체
			//resultValue = TripleDES.encrypt(settValue, "");
			
			returnList.put("result", "ok");
			returnList.put("encryptText", resultValue);

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "basecode/downloadExcel.do" )
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "title", required = false, defaultValue = "BaseConfigView") String xlsTitle
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			String domain = request.getParameter("domain");
			String bizSection = request.getParameter("bizSection");
			String selectsearch = request.getParameter("selectsearch");
			String searchtext = request.getParameter("searchtext");
			String startdate = request.getParameter("startdate");
			String enddate = request.getParameter("enddate");
			String sortKey = request.getParameter("sortKey");
			String sortWay = request.getParameter("sortWay");
			String headerName = request.getParameter("headername");
			String headerType = request.getParameter("headerType");
			String[] headerNames = StringUtil.replaceNull(headerName).split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("bizSection", bizSection);
			params.put("selectsearch", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			//timezone 적용 날짜변환
			if(params.get("startdate") != null && !params.get("startdate").equals("")){
				params.put("startdate",ComUtils.TransServerTime(params.get("startdate").toString() + " 00:00:00"));
			}
			if(params.get("enddate") != null && !params.get("enddate").equals("")){
				params.put("enddate",ComUtils.TransServerTime(params.get("enddate").toString() + " 23:59:59"));
			}		
			
			if(StringUtil.replaceNull(domain).isEmpty()) {
				params.put("domainList", ComUtils.getAssignedDomainID());
			}
			
			viewParams = sysBaseCodeSvc.selectExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", xlsTitle);
			
			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (NullPointerException e) {
			LOGGER.error("SystemBaseConfigCon", e);
		} catch (Exception e) {
			LOGGER.error("SystemBaseConfigCon", e);
		}

		return mav;
	}
	
	/**
	 * getDataBaseConfig : 시스템 관리 - 업무구분 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/searchgroup.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getList(HttpServletRequest request, 
			@RequestParam(value = "bizSection", required = false, defaultValue = "") String bizSection,
			@RequestParam(value = "codeGroup", required = false, defaultValue = "") String codeGroup) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("bizSection", bizSection);
			params.put("codeGroup", codeGroup);
			
			resultList = sysBaseCodeSvc.selectBaseCodeGroupObject(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getCodeGroupList : 시스템 관리 - 기초코드관리, 코드그룹 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "basecode/getCodeGroupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getCodeGroupList(HttpServletRequest request, 
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "10") String pageSize,
			@RequestParam(value = "domainID", required = true, defaultValue = "") String domainID,
			@RequestParam(value = "bizSection", required = false, defaultValue = "") String bizSection,
			@RequestParam(value = "searchType", required = false, defaultValue = "") String searchType,
			@RequestParam(value = "searchText", required = false, defaultValue = "") String searchText) throws Exception {
			
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("domainID", domainID);
			params.put("bizSection", bizSection);
			params.put("searchType", searchType);
			params.put("searchText", searchText);
			
			resultList = sysBaseCodeSvc.selectCodeGroupList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

}
