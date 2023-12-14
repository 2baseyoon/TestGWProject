package egovframework.core.web;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
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
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LocalStorageSyncSvc;
import egovframework.core.sevice.SysDictionarySvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : SysDictionaryCon.java
 * @Description : 시스템 - 다국어 관리
 * @Modification Information 
 * @ 2016.04.22 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysDictionaryCon {

	private Logger LOGGER = LogManager.getLogger(SysDictionaryCon.class);
	
	@Autowired
	private SysDictionarySvc sysDicSvc;
	
	@Autowired
	private LocalStorageSyncSvc localStorageSyncSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getdictionarylist : 시스템 관리 - 다국어 목록 호출
	 * @param dicsection
	 * @param selectsearch
	 * @param searchtext
	 * @param startdate
	 * @param enddate
	 * @param sortBy
	 * @param pageNo
	 * @param pageSize
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/getList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getdictionarylist(
			@RequestParam(value = "domain", required = false, defaultValue="") String domain,
			@RequestParam(value = "dicsection", required = false, defaultValue="") String dicsection,
			@RequestParam(value = "selectsearch", required = false) String selectsearch,
			@RequestParam(value = "searchtext", required = false) String searchtext,
			@RequestParam(value = "startdate", required = false) String startdate,
			@RequestParam(value = "enddate", required = false) String enddate,
			@RequestParam(value = "sortBy", required = false, defaultValue="") String sortBy,
			@RequestParam(value = "pageNo", required = false  , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "10" ) int pageSize
			
			) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try{
			//2019.05 sortBy 중복파라미터 지정 오류 보정
			if(! sortBy.equals("") && sortBy.split(",").length > 1) sortBy = sortBy.split(",")[0];
			
			String sortKey =  (! sortBy.equals("") )? sortBy.split(" ")[0] : "";
			String sortDirec =  (! sortBy.equals("") )? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
		
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("dicsection", dicsection);
			params.put("searchtype", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
			
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
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));

			resultList = sysDicSvc.selectGrid(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
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
	 *  dictionaryexcelupload : 시스템 관리 - 다국어 관리 엑셀 업로드
	 * @param dicsection
	 * @param selectsearch
	 * @param searchtext
	 * @param startdate
	 * @param enddate
	 * @param sortKey
	 * @param sortWay
	 * @param headername
	 * @return ModelAndView
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/uploadExcel.do", method = RequestMethod.GET)
	public ModelAndView dictionaryexcelupload()throws Exception
	{
		return  (new ModelAndView( "admin/system/dictionaryexcelupload"));
	}
	
	
	/**
	 * createdictionary : 다국어 추가
	 * @param request
	 * @param dicSection
	 * @param domainID
	 * @param dicCode
	 * @param koShort
	 * @param koFull
	 * @param enShort
	 * @param enFull
	 * @param jaShort
	 * @param jaFull
	 * @param zhShort
	 * @param zhFull
	 * @param isUse
	 * @param description
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/add.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createdictionary(HttpServletRequest request, 
			@RequestParam(value = "dicSection", required = true, defaultValue = "com") String dicSection,
			@RequestParam(value = "domainID", required = true, defaultValue = "0") String domainID,
			@RequestParam(value = "dicCode", required = true, defaultValue = "") String dicCode,
			@RequestParam(value = "koShort", required = true, defaultValue = "") String koShort,
			@RequestParam(value = "koFull", required = true, defaultValue = "") String koFull,
			@RequestParam(value = "enShort", required = false, defaultValue = "") String enShort,
			@RequestParam(value = "enFull", required = false, defaultValue = "") String enFull,
			@RequestParam(value = "jaShort", required = false, defaultValue = "") String jaShort,
			@RequestParam(value = "jaFull", required = false, defaultValue = "") String jaFull,
			@RequestParam(value = "zhShort", required = false, defaultValue = "") String zhShort,
			@RequestParam(value = "zhFull", required = false, defaultValue = "") String zhFull,
			@RequestParam(value = "isUse", required = false, defaultValue = "Y") String isUse,
			@RequestParam(value = "description", required = false, defaultValue = "") String description) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			//멀티 insert일 경우
			/* paramMap을 직접 넘기는 case를 검토해야 함
			 * paramMap.get("list["+i+"][CONM]"))
			 * */
			
			CoviMap params = new CoviMap();
			params.put("domainID", domainID);
			params.put("dicCode", dicCode);
			params.put("dicSection", dicSection);
			params.put("koShort", koShort);
			params.put("koFull", koFull);
			params.put("enShort", enShort);
			params.put("enFull", enFull);
			params.put("jaShort", jaShort);
			params.put("jaFull", jaFull);
			params.put("zhShort", zhShort);
			params.put("zhFull", zhFull);
			params.put("lang1Short", null);
			params.put("lang1Full", null);
			params.put("lang2Short", null);
			params.put("lang2Full", null);
			params.put("lang3Short", null);
			params.put("lang3Full", null);
			params.put("lang4Short", null);
			params.put("lang4Full", null);
			params.put("lang5Short", null);
			params.put("lang5Full", null);
			params.put("lang6Short", null);
			params.put("lang6Full", null);
			params.put("reservedStr", null);
			params.put("reservedInt", null);
			params.put("isUse", isUse);
			params.put("isCaching", "Y");
			params.put("description", description);
			params.put("regID", SessionHelper.getSession("USERID"));
			
			sysDicSvc.insert(params);
			
			//redis set
			CoviMap selectParams = new CoviMap();
			selectParams.put("dicID", params.get("dicID").toString());
			RedisDataUtil.setDic(params.getString("dicCode"), params.getString("domainID"), sysDicSvc.selectOneString(selectParams));
			
			returnList.put("result", "ok");
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
	 * updatedictionary : 다국어 update
	 * @param request
	 * @param dicID
	 * @param dicSection
	 * @param domainID
	 * @param dicCode
	 * @param koShort
	 * @param koFull
	 * @param enShort
	 * @param enFull
	 * @param jaShort
	 * @param jaFull
	 * @param zhShort
	 * @param zhFull
	 * @param isUse
	 * @param description
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/modify.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updatedictionary(HttpServletRequest request, 
			@RequestParam(value = "dicID", required = true, defaultValue = "") String dicID,
			@RequestParam(value = "dicSection", required = true, defaultValue = "com") String dicSection,
			@RequestParam(value = "domainID", required = true, defaultValue = "0") String domainID,
			@RequestParam(value = "dicCode", required = true, defaultValue = "") String dicCode,
			@RequestParam(value = "koShort", required = true, defaultValue = "") String koShort,
			@RequestParam(value = "koFull", required = true, defaultValue = "") String koFull,
			@RequestParam(value = "enShort", required = false, defaultValue = "") String enShort,
			@RequestParam(value = "enFull", required = false, defaultValue = "") String enFull,
			@RequestParam(value = "jaShort", required = false, defaultValue = "") String jaShort,
			@RequestParam(value = "jaFull", required = false, defaultValue = "") String jaFull,
			@RequestParam(value = "zhShort", required = false, defaultValue = "") String zhShort,
			@RequestParam(value = "zhFull", required = false, defaultValue = "") String zhFull,
			@RequestParam(value = "isUse", required = true, defaultValue = "Y") String isUse,
			@RequestParam(value = "description", required = false, defaultValue = "") String description) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("dicID", dicID);
			params.put("domainID", domainID);
			params.put("dicCode", dicCode);
			params.put("dicSection", dicSection);
			params.put("koShort", koShort);
			params.put("koFull", koFull);
			params.put("enShort", enShort);
			params.put("enFull", enFull);
			params.put("jaShort", jaShort);
			params.put("jaFull", jaFull);
			params.put("zhShort", zhShort);
			params.put("zhFull", zhFull);
			params.put("lang1Short", null);
			params.put("lang1Full", null);
			params.put("lang2Short", null);
			params.put("lang2Full", null);
			params.put("lang3Short", null);
			params.put("lang3Full", null);
			params.put("lang4Short", null);
			params.put("lang4Full", null);
			params.put("lang5Short", null);
			params.put("lang5Full", null);
			params.put("lang6Short", null);
			params.put("lang6Full", null);
			params.put("reservedStr", null);
			params.put("reservedInt", null);
			params.put("isUse", isUse);
			params.put("isCaching", "Y");
			params.put("description", description);
			params.put("modID", SessionHelper.getSession("USERID"));
			
			sysDicSvc.update(params);
			
			//redis set
			RedisDataUtil.setDic(params.getString("dicCode"), params.getString("domainID"), sysDicSvc.selectOneString(params));
			
			returnList.put("result", "ok");
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
	 * updateisusedictionary : 다국어 사용여부 변경
	 * @param request
	 * @param dicID
	 * @param isUse
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/modifyUse.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap updateisusedictionary(HttpServletRequest request, 
			@RequestParam(value = "dicID", required = true, defaultValue = "") String dicID,
			@RequestParam(value = "isUse", required = true, defaultValue = "Y") String isUse) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("dicID", dicID);
			params.put("isUse", isUse);
			params.put("modID", SessionHelper.getSession("USERID"));
			
			//redis 처리
			CoviMap selectedMap =  sysDicSvc.selectOneObject(params);
			String dicCode = selectedMap.getString("DicCode");
			String domainID = selectedMap.getString("DomainID");
			
			if(isUse.equalsIgnoreCase("Y")){
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonString = mapperObj.writeValueAsString(selectedMap);
				//redis set
				RedisDataUtil.setDic(dicCode, domainID, jsonString);
			} else {
				//redis remove
				RedisDataUtil.removeDic(dicCode, domainID);
			}
			
			sysDicSvc.updateIsUse(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (JsonGenerationException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (JsonMappingException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 *  getdictionary : 다국어 조회
	 * @param request
	 * @param dicID
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/get.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getdictionary(HttpServletRequest request, 
			@RequestParam(value = "dicID", required = true, defaultValue = "") String dicID) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			
			params.put("dicID", dicID);
			resultList = sysDicSvc.selectOne(params);
			
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
	 * deletedictionary : 다국어 삭제
	 * @param deleteData
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/remove.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deletedictionary(
			@RequestParam(value = "DeleteData", required = true, defaultValue = "") String deleteData) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try {
			String[] delData = deleteData.split(",");
			CoviMap params = new CoviMap();
			params.put("dicIDs", deleteData);
			params.put("dicIDArr", delData);
			
			//redis remove
			for (String dicID: delData) {
				CoviMap selectParam = new CoviMap();
				selectParam.put("dicID", dicID);
				CoviMap selectedMap = sysDicSvc.selectOneObject(selectParam);
				if(selectedMap.containsKey("DicCode")){
					RedisDataUtil.removeDic(selectedMap.getString("DicCode"), selectedMap.getString("DomainID"));
				}
			}

			sysDicSvc.delete(params);
			
			returnList.put("result", "ok");
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
	 * dddictionarylayerpopup : 다국어 추가 및 수정 페이지 팝업
	 * @return ModelAndView
	 */
	@RequestMapping(value = "dic/goDicPopup.do", method = RequestMethod.GET)
	public ModelAndView adddictionarylayerpopup() {
		return (new ModelAndView("core/system/adddictionarylayerpopup"));
	}
	
	
	/**
	 * translate - 네이버 번역 API
	 * @param request
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "dic/translate.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap translate(HttpServletRequest request) throws Exception
	{
		String text = request.getParameter("text");
		String src_lang = request.getParameter("src_lang");
		String dest_lang = request.getParameter("dest_lang");

		CoviMap returnList = new CoviMap();
//		CoviList arrLang  = new CoviList();
		List<HashMap> arrLang = new java.util.ArrayList<HashMap>();
		Set<String> allowedLang = new HashSet<String>(Arrays.asList( new String[] {"ko", "en", "ja", "zh-CN", "zh-TW"}));
		
		try {
			if(StringUtil.replaceNull(src_lang).equalsIgnoreCase("zh")){
				src_lang = "zh-CN";
			} 
			String[] destArry = StringUtil.replaceNull(dest_lang).split(",");
			for (int i=0; i  < destArry.length; i++){
				//zh-CN:중국어(간체), zh-TW:중국어(번체)
				String lang;
				if(StringUtil.replaceNull(destArry[i]).equalsIgnoreCase("zh")){
					lang = "zh-CN";
				}else{
					lang = destArry[i];
				}
				if (StringUtil.replaceNull(src_lang).equals(lang)) continue;
				
				if(allowedLang.contains(lang)){
					String  result = sysDicSvc.translate(src_lang, lang, text);
					HashMap cmap = new HashMap();
					cmap.put ("dicLang",destArry[i]);
					cmap.put ("text",result);
					arrLang.add(cmap);
				}
			}
			
			if(arrLang.size()>0){
////				result = sysDicSvc.translate(src_lang, dest_lang, text);
			
				returnList.put("lang", arrLang);
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "조회되었습니다");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "지원되지 않는 언어입니다.");
			}
			
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
	 * dictionaryExcelDownload - 엑셀 다운로드
	 * @param dicsection
	 * @param selectsearch
	 * @param searchtext
	 * @param startdate
	 * @param enddate
	 * @param sortKey
	 * @param sortWay
	 * @param headerName
	 * @return mav
	 */
	@RequestMapping(value = "dic/downloadExcel.do" )
	public ModelAndView dictionaryExcelDownload(
			@RequestParam(value = "domain", required = false, defaultValue="") String domain,
			@RequestParam(value = "dicsection", required = false, defaultValue="") String dicsection,
			@RequestParam(value = "selectsearch", required = false) String selectsearch,
			@RequestParam(value = "searchtext", required = false) String searchtext,
			@RequestParam(value = "startdate", required = false) String startdate,
			@RequestParam(value = "enddate", required = false) String enddate,
			@RequestParam(value = "sortKey", required = false) String sortKey,
			@RequestParam(value = "sortWay", required = false) String sortWay,
			@RequestParam(value = "headername", required = false, defaultValue="") String headerName,
			@RequestParam(value = "headerType", required = false) String headerType
			
			
			) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			
			String[] headerNames = headerName.split(";");
		
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("dicsection", dicsection);
			params.put("searchtype", selectsearch);
			params.put("searchtext", ComUtils.RemoveSQLInjection(searchtext, 100));
			params.put("startdate", startdate);
			params.put("enddate", enddate);
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
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortWay, 100));
			
			viewParams = sysDicSvc.selectExcel(params);
			
			viewParams.put("headerName", headerNames);
			viewParams.put("headerType", headerType);
			viewParams.put("title", "DictionaryView");
			
			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (NullPointerException e) {
			LOGGER.error("SystemDictionaryManageCon", e);
		} catch (Exception e) {
			LOGGER.error("SystemDictionaryManageCon", e);
		}

		return mav;
	}

	/**
	 * 회사명 다국어 팝업(화면 : 사용자페이지 > 그룹웨어설정 > 시스템관리 > 회사정보관리)
	 */
	@RequestMapping(value = "dic/muitiLangSet.do" )
	public ModelAndView callDic(HttpServletRequest request,
			@RequestParam(value = "lang", required = false, defaultValue = "") String lang,
			@RequestParam(value = "hasTransBtn", required = false, defaultValue = "") String hasTransBtn,
			@RequestParam(value = "allowedLang", required = true, defaultValue = "") String allowedLang,
			@RequestParam(value = "useShort", required = false, defaultValue = "") String useShort,
			@RequestParam(value = "dicCallback", required = false, defaultValue = "") String dicCallback,
			@RequestParam(value = "popupTargetID", required = true, defaultValue = "") String popupTargetID,
			@RequestParam(value = "init", required = false, defaultValue = "") String initMethod,
			@RequestParam(value = "openerID", required = false, defaultValue = "") String openerID) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("hasTransBtn", hasTransBtn);
		option.put("allowedLang", allowedLang);
		option.put("useShort", useShort);
		option.put("dicCallback", dicCallback);
		option.put("popupTargetID", popupTargetID);
		option.put("init", initMethod);
		option.put("openerID", openerID);
		
		String returnURL = "manage/system/MultiLangPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}

}
