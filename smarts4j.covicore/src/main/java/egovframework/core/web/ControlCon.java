package egovframework.core.web;

import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Set;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.joda.time.DateTime;
import org.joda.time.Duration;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.json.XML;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.sevice.ControlSvc;
import egovframework.core.sevice.LoginSvc;
import egovframework.core.sevice.MessageManageSvc;
import egovframework.core.sevice.OrgChartSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.sec.Sha512;
import egovframework.baseframework.data.CoviList;

/**
 * @Class Name : ControlCon.java
 * @Description : 공통컨트롤러
 * @Modification Information 
 * @ 2016.07.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 07.20
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ControlCon {

	private Logger LOGGER = LogManager.getLogger(ControlCon.class);
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	private OrgChartSvc orgChartSvc;
	
	@Autowired
	private ControlSvc controlSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	@Autowired
	private LoginSvc loginSvc;
	
	@Autowired
	private MessageManageSvc messageManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value="control/callPasswordReset.do")
	public ModelAndView callPasswordReset(HttpServletRequest request,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "callback", required = true, defaultValue = "") String callback) throws Exception{
		
		String returnURL = "cmmn/controls/PasswordReset";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("lang", lang);
		
		return mav;
	}
	
	@RequestMapping(value="control/callSecurityPolicy.do")
	public ModelAndView callSecurityPolicy(HttpServletRequest request,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "callback", required = true, defaultValue = "") String callback) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("callback", callback);
		
		String returnURL = "cmmn/controls/SecurityPolicy";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	
	@RequestMapping(value="control/callFavoriteAdd.do")
	public ModelAndView callFavoriteAdd(HttpServletRequest request,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "callback", required = true, defaultValue = "") String callback) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("callback", callback);
		
		CoviMap params = new CoviMap();
		params.put("userID", SessionHelper.getSession("USERID"));
			
		ModelAndView mav = new ModelAndView( "cmmn/controls/FavoriteAdd");
		mav.addObject("userQuickConf",  controlSvc.selectQuickMenuConf(params));
		mav.addObject("option", option);
		
		return mav;
	}	
	
	@RequestMapping(value="control/callimage.do")
	public ModelAndView callImage(HttpServletRequest request,
			@RequestParam(value = "maxWidth", required = true, defaultValue = "") String maxWidth,
			@RequestParam(value = "maxHeight", required = true, defaultValue = "") String maxHeight,
			@RequestParam(value = "src", required = true, defaultValue = "") String src) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("maxWidth", maxWidth);
		option.put("maxHeight", maxHeight);
		option.put("src", src);
		
		String returnURL = "cmmn/controls/Image";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}	
	
	/**
	 * 권한 지정 팝업 호출 처리
	 * @param request
	 * @param lang
	 * @param allowedACL
	 * @param orgMapCallback
	 * @param aclCallback
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="control/callacl.do")
	public ModelAndView callACL(HttpServletRequest request,
			@RequestParam(value = "lang", required = true, defaultValue = "") String lang,
			@RequestParam(value = "allowedACL", required = true, defaultValue = "") String allowedACL,
			@RequestParam(value = "orgMapCallback", required = true, defaultValue = "") String orgMapCallback,
			@RequestParam(value = "aclCallback", required = true, defaultValue = "") String aclCallback) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("allowedACL", allowedACL);
		option.put("orgMapCallback", orgMapCallback);
		option.put("aclCallback", aclCallback);
		
		String returnURL = "cmmn/controls/ACLSet";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	
	/**
	 * 다국어 팝업 호출
	 * @param request
	 * @param lang
	 * @param hasTransBtn
	 * @param allowedLang
	 * @param useShort
	 * @param dicCallback
	 * @param popupTargetID
	 * @param initMethod
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="control/calldic.do")
	public ModelAndView callDic(HttpServletRequest request,
			@RequestParam(value = "lang", required = false, defaultValue = "") String lang,
			@RequestParam(value = "hasTransBtn", required = false, defaultValue = "") String hasTransBtn,
			@RequestParam(value = "allowedLang", required = true, defaultValue = "") String allowedLang,
			@RequestParam(value = "useShort", required = false, defaultValue = "") String useShort,
			@RequestParam(value = "dicCallback", required = false, defaultValue = "") String dicCallback,
			@RequestParam(value = "popupTargetID", required = true, defaultValue = "") String popupTargetID,
			@RequestParam(value = "init", required = false, defaultValue = "") String initMethod,
			@RequestParam(value = "openerID", required = false, defaultValue = "") String openerID,
			@RequestParam(value = "styleType", required = false, defaultValue = "") String styleType,
			@RequestParam(value = "initData", required = false, defaultValue = "") String initData,
			@RequestParam(value = "dicID", required = false, defaultValue = "") String dicID) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("hasTransBtn", hasTransBtn);
		option.put("allowedLang", allowedLang);
		option.put("useShort", useShort);
		option.put("dicCallback", dicCallback);
		option.put("popupTargetID", popupTargetID);
		option.put("init", initMethod);
		option.put("openerID", openerID);
		option.put("styleType", styleType);
		option.put("initData", initData);
		option.put("dicID", dicID);
		
		String returnURL = "cmmn/controls/DicSet";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	

	@RequestMapping(value="control/callFileUpload.do")
	public ModelAndView callFileUpload(HttpServletRequest request,
			//@RequestParam(value = "lang", required = false, defaultValue = "ko") String lang,
			@RequestParam(value = "listStyle", required = false, defaultValue = "table") String listStyle,
			@RequestParam(value = "callback", required = false, defaultValue = "") String callback,
			@RequestParam(value = "actionButton", required = false, defaultValue = "add") String actionBtn,
			@RequestParam(value = "multiple", required = false, defaultValue = "true") String multiple,
			@RequestParam(value = "servicePath", required = false, defaultValue = "") String servicePath,
			@RequestParam(value = "elemID", required = false, defaultValue = "") String elemID,
			@RequestParam(value = "fileSizeLimit", required = false, defaultValue = "209715200") String fileSizeLimit,
			@RequestParam(value = "image", required = false, defaultValue = "false") String image){
		
		CoviMap option = new CoviMap();
		/* option.put("lang", lang); */
		option.put("listStyle", listStyle);
		option.put("callback", callback);
		option.put("actionButton", actionBtn);
		option.put("multiple", multiple);
		option.put("servicePath", servicePath);
		option.put("elemID", elemID);
		option.put("fileSizeLimit", fileSizeLimit);
		option.put("image", image);
		
		String returnURL = "cmmn/controls/FileUpload";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	
	/*
	 * 주소 API
	 * https://www.juso.go.kr
	 * localhost
	 * U01TX0FVVEgyMDE3MDgyOTEzNTMwODEwNzI5NTI= 
	 * 
	 * */
	@RequestMapping(value = "control/getAddrAPI.do")
	public @ResponseBody CoviMap getAddrApi(HttpServletRequest req, HttpServletResponse response,
			@RequestParam(value = "currentPage", required = false, defaultValue = "1") String currentPage,
			@RequestParam(value = "countPerPage", required = false, defaultValue = "10") String countPerPage,
			//@RequestParam(value = "resultType", required = false, defaultValue = "json") String resultType,
			//@RequestParam(value = "confmKey", required = false, defaultValue = "") String confmKey,
			@RequestParam(value = "keyword", required = false, defaultValue = "") String keyword) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			// API 호출 URL 정보 설정
			HttpURLConnectUtil url = new HttpURLConnectUtil();
			
			CoviMap returnObj = CoviMap.fromObject(url.jusoAPI(currentPage, keyword, countPerPage));
			if(returnObj.getJSONObject("results").getJSONObject("common").getString("totalCount").equalsIgnoreCase("0"))
				returnObj.getJSONObject("results").put("juso", new CoviList());
				
			returnList.put("list", returnObj);
			returnList.put("status", Return.SUCCESS);	
			
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value="control/callAddr.do")
	public ModelAndView callAddr(HttpServletRequest request,
			@RequestParam(value = "lang", required = false, defaultValue = "ko") String lang,
			@RequestParam(value = "callback", required = false, defaultValue = "") String callback) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		//option.put("listStyle", listStyle);
		option.put("callback", callback);
		//option.put("actionButton", actionBtn);
		//option.put("multiple", multiple);
		
		String returnURL = "cmmn/controls/AddrSet";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	
	@RequestMapping(value="control/callMap.do")
	public ModelAndView callMap(HttpServletRequest request,
			@RequestParam(value = "lang", required = false, defaultValue = "ko") String lang,
			@RequestParam(value = "mapWidth", required = false, defaultValue = "500") String mapWidth,
			@RequestParam(value = "mapHeight", required = false, defaultValue = "400") String mapHeight,
			@RequestParam(value = "imgWidth", required = false, defaultValue = "100") String imgWidth,
			@RequestParam(value = "imgHeight", required = false, defaultValue = "100") String imgHeight,
			@RequestParam(value = "callback", required = false, defaultValue = "") String callback,
			@RequestParam(value = "elemID", required = false, defaultValue = "") String elemID) throws Exception{
		
		CoviMap option = new CoviMap();
		option.put("lang", lang);
		option.put("mapWidth", mapWidth);
		option.put("mapHeight", mapHeight);
		option.put("imgWidth", imgWidth);
		option.put("imgHeight", imgHeight);
		option.put("callback", callback);
		option.put("elemID", elemID);
		
		String returnURL = "cmmn/controls/Map";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("option", option);
		
		return mav;
	}
	
	/*
	 * 코로나19 API
	 * http://openapi.data.go.kr/openapi/service/rest/Covid19
	 * */
	@RequestMapping(value = "control/getCovid19Api.do")
	public @ResponseBody CoviMap getCovid19Api(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "sDate", required = true) String sDate,
			@RequestParam(value = "eDate", required = true) String eDate) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try{
			// API 호출 URL 정보 설정
			HttpURLConnectUtil url = new HttpURLConnectUtil();
			
			String xmlString = url.covid19API(sDate, eDate);
			org.json.JSONObject resultObj = XML.toJSONObject(xmlString).getJSONObject("response");
			
			if(resultObj.getJSONObject("header").getString("resultCode").equals("00")){
				org.json.JSONArray resultArr = resultObj.getJSONObject("body").getJSONObject("items").getJSONArray("item");
				org.json.JSONArray returnArr = new org.json.JSONArray();
				
				// Null값 체크
				for(int i = 0; i < resultArr.length(); i++){
					org.json.JSONObject itemObj = resultArr.getJSONObject(i);
					
					for(Object key : itemObj.keySet()){
						if(itemObj.isNull(key.toString())){
							itemObj.put(key.toString(), "");
						}
					}
					
					returnArr.put(itemObj);
				}
				
				CoviMap returnObj = CoviMap.fromObject(new org.json.JSONObject().put("result", returnArr).toString());
				
				returnList.put("result", returnObj.get("result"));
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", resultObj.getJSONObject("header").getString("resultMsg"));
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("message", resultObj.getJSONObject("header").getString("resultMsg"));
			}
		}
		catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/*
	 * 날씨 API
	 * HttpUrlConnectUtil의 openWeatherAPI 호출 > 결과를 레디스에 저장.
	 * 공공데이터포탈의 기상청 단기/중기예보의 경우 관측 일자 또는 시간이 변경되면 캐시 갱신.
	 * 기타 API로 변경되는 경우 매번 갱신되므로 컨트롤러에서 갱신 조건 변경 필요.
	 * */
	@RequestMapping(value = "control/getWeatherApi.do")
	public @ResponseBody CoviMap getWeatherApi(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "params", required = false, defaultValue = "") String parammeters) throws Exception{
		CoviMap returnList = new CoviMap();
		
		CoviMap params = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(parammeters));
		String apiType = params.getString("apiType");
		boolean isCached = false;
		CoviMap returnObj = new CoviMap();
		try{
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			if (instance.get("weather_"+params.getString("location")) != null) {
				String redisStr = instance.get("weather_"+params.getString("location"));
				if (redisStr.indexOf("\"baseDate\":\""+params.getString("base_date")) > -1 
						&& redisStr.indexOf("\"baseTime\":\""+params.getString("base_time")) > -1) {
					isCached = true;
					returnObj = CoviMap.fromObject(redisStr);
				}
				else {
					instance.remove("weather_"+params.getString("location"));
				}
			}
			
			if (!isCached) {
				// API 호출 URL 정보 설정
				HttpURLConnectUtil url = new HttpURLConnectUtil();
				
				switch(apiType) {
				case "kma":
					returnObj = CoviMap.fromObject(url.kmaWeatherAPI(params));
					break;
				case "openWeather":
					String cityName = params.getString("location");
					returnObj = CoviMap.fromObject(url.openWeatherAPI(cityName));
					break;
				default:
					break;
				}
				
				if (returnObj.size() > 0) {
					instance.save("weather_"+params.getString("location"), CoviMap.toJSONString(returnObj));
				}
			}
			
			returnList.put("result", returnObj);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	//환율 가져오기(시분에 따라 갱신처리)
	@RequestMapping(value = "control/getExchangeApi.do")
	public @ResponseBody CoviMap getExchangeApi(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnList = new CoviMap();
		
		boolean isCached = true;
		CoviMap returnObj = new CoviMap();
		// 시간단위로 조정 및 캐시 TTL 추가. (Redis 메모리 누수가능)
		String excKey = "exchange_"+DateHelper.getCurrentDay("yyyyMMddHH");
		try{
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			if (instance.get(excKey) != null) {
				String redisStr = instance.get(excKey);
				returnObj = CoviMap.fromObject(redisStr);
				if (returnObj != null) isCached = false;
			}
			
			if (isCached ) {
				// API 호출 URL 정보 설정
				HttpClientUtil httpClient = new HttpClientUtil();
				CoviMap paramsHeader = new CoviMap();
				returnObj = httpClient.httpRestAPIConnect(request.getParameter("connectUrl"), "json", "GET","", paramsHeader);
				
				if (returnObj.size() > 0) {
					//instance.save(excKey, CoviMap.toJSONString(returnObj));
					// 최대 1시간 Cache
					int hour = 60 * 60;
					int buffer = 60;
					instance.setex(excKey, hour + buffer, CoviMap.toJSONString(returnObj));
				}
			}
			
			returnList.put("result", returnObj);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	
	/**
	 * goOrgChart : 조직도 - 조직도 팝업
	 * @return mav
	 */
	@RequestMapping(value = "control/goOrgChart.do", method = RequestMethod.GET)
	public ModelAndView goOrgChart() {
		String returnURL = "cmmn/controls/OrgChart";
		String domainID = SessionHelper.getSession("DN_ID");
		CoviMap params = new CoviMap();
		
		String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
		if(!orgMapOrderSet.equals("")) {
            String[] orgOrders = orgMapOrderSet.split("\\|");
            params.put("orgOrders", orgOrders);
		}
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject(params);
		
		return mav;
	}
	
	/**
	 * goBizcardOrgChart : 연락처 조직도 - 조직도 팝업
	 * @return mav
	 */
	@RequestMapping(value = "control/goBizcardOrgChart.do", method = RequestMethod.GET)
	public ModelAndView goBizcardOrgChart() {
		String returnURL = "cmmn/controls/BizcardOrgChart";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}

	/**
	 * 조직도 개선 : 조직도 초기 트리 데이터 조회 ( 하위 depth 와 현재 사용자가 속한 depth까지 조회
	 * @param companyCode - 회사 코드
	 * @param groupType - dept or group
	 * @param searchText - 검색어
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getInitOrgTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getInitOrgTreeList(
		@RequestParam(value = "loadMyDept", required = true, defaultValue="N") String loadMyDept,
		@RequestParam(value = "companyCode", required = true) String companyCode,
		@RequestParam(value = "groupType", required = true, defaultValue = "dept") String groupType,
		@RequestParam(value = "searchText", required = false) String searchText,
		@RequestParam(value = "groupDivision", required = false, defaultValue = "") String groupDivision,
		@RequestParam(value = "communityId", required = false, defaultValue = "") String communityId,
		@RequestParam(value = "onlyMyDept", required = false, defaultValue = "N") String onlyMyDept,
		@RequestParam(value = "mailYn", required = false, defaultValue = "N") String mailYn,
		@RequestParam(value = "defaultValue", required = false, defaultValue = "") String defaultValue) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		
		try{
			CoviMap params = new CoviMap();

			params.put("loadMyDept", loadMyDept);
			params.put("companyCode", companyCode);
			params.put("groupType", groupType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("onlyMyDept", onlyMyDept);
			params.put("defaultValue", defaultValue);
			//params.put("schDeptType", schDeptType);
			
			if(groupType.equalsIgnoreCase("GROUP")){
				String[] arrGroupDivision = null;
				if(!func.f_NullCheck(groupDivision).equals(""))
					arrGroupDivision = groupDivision.split("\\|");
					
				params.put("groupDivision", arrGroupDivision);
				params.put("communityId", communityId);
			}
			
			params.put("mailYn", mailYn);
			
			resultList = orgChartSvc.getInitOrgTreeList(params);
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * 조직도 개선 : 조직도 초기 트리 데이터 조회 ( 하위 depth 와 현재 사용자가 속한 depth까지 조회
	 * @param companyCode - 회사 코드
	 * @param groupType - dept or group
	 * @param searchText - 검색어
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getChildrenData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getChildrenData(
			@RequestParam(value = "memberOf", required = false) String memberOf,
			@RequestParam(value = "companyCode", required = true) String companyCode,
			@RequestParam(value = "groupType", required = true, defaultValue = "dept") String groupType, 
			@RequestParam(value = "groupDivision", required = false, defaultValue = "") String groupDivision,
			@RequestParam(value = "communityId", required = false, defaultValue = "") String communityId,
			@RequestParam(value = "mailYn", required = false, defaultValue = "N") String mailYn ) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		
		try{
			CoviMap params = new CoviMap();
			
			params.put("memberOf", memberOf);
			params.put("companyCode", companyCode);
			params.put("groupType", groupType);

			if(groupType.equalsIgnoreCase("GROUP")){
				String[] arrGroupDivision = null;
				if(!func.f_NullCheck(groupDivision).equals(""))
					arrGroupDivision = groupDivision.split("\\|");
					
				params.put("groupDivision", arrGroupDivision);
				params.put("communityId", communityId);
			}
			
			resultList = orgChartSvc.getChildrenData(params);
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getDeptList : 조직도 - 부서 목록 조회
	 * @param companyCode - 회사 코드
	 * @param groupType - dept or group
	 * @param searchText - 검색어
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getDeptList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptList(
		@RequestParam(value = "companyCode", required = true) String companyCode,
		@RequestParam(value = "groupType", required = true, defaultValue = "dept") String groupType,
		@RequestParam(value = "searchText", required = false) String searchText,
		@RequestParam(value = "groupDivision", required = false, defaultValue = "") String groupDivision,
		@RequestParam(value = "communityId", required = false, defaultValue = "") String communityId) throws Exception{ 
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		StringUtil func = new StringUtil();
		
		try{
			CoviMap params = new CoviMap();

			params.put("companyCode", companyCode);
			params.put("groupType", groupType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			
			if(groupType.equalsIgnoreCase("DEPT")){
				resultList = orgChartSvc.getDeptList(params);
			}else if(groupType.equalsIgnoreCase("GROUP")){
				String[] arrGroupDivision = null;
				if(!func.f_NullCheck(groupDivision).equals(""))
					arrGroupDivision = groupDivision.split("\\|");
					
				params.put("groupDivision", arrGroupDivision);
				params.put("communityId", communityId);
				
				//params.put("schDeptType", schDeptType);
				
				resultList = orgChartSvc.getGroupList(params);
			}
			
			returnList.put("list", resultList);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getUserList : 조직도 - 사용자 목록
	 * @param companyCode - 회사 코드
	 * @param deptCode - 부서 코드
	 * @param searchType - 검색 조건
	 * @param searchText - 검색어 
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getUserList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getUserList(
		   @RequestParam(value = "companyCode", required = false) String companyCode,
		   @RequestParam(value = "deptCode", required = false) String deptCode,
		   @RequestParam(value = "groupType", required = false, defaultValue="dept") String groupType,
		   @RequestParam(value = "searchType", required = false) String searchType,
		   @RequestParam(value = "searchText", required = false) String searchText,
		   @RequestParam(value = "hasChildGroup", required = false, defaultValue="N") String hasChildGroup,
		   @RequestParam(value = "useAttendStatus", required = false, defaultValue="N") String useAttendStatus,
		   @RequestParam(value = "isMailChk", required = false, defaultValue="N") String isMailChk) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		try{
			
			if((searchType == null || "".equals(searchType))  && (searchText == null || "".equals(searchText))) {
				if(groupType.equalsIgnoreCase("DEPT") && (deptCode == null || StringUtil.isEmpty(deptCode))){
					deptCode = SessionHelper.getSession("GR_Code");
				} else if(groupType.equalsIgnoreCase("GROUP") && (deptCode == null || StringUtil.isEmpty(deptCode))){
					deptCode = SessionHelper.getSession("GR_Code");
				}
			}
		
			CoviMap params = new CoviMap();
			String domainID = SessionHelper.getSession("DN_ID");
			
			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
                String[] orgOrders = orgMapOrderSet.split("\\|");
                params.put("orgOrders", orgOrders);
			}

			params.put("companyCode", companyCode);
			params.put("deptCode", deptCode);  //groupType=dept일때
			params.put("groupCode", deptCode); //groupType=group일때
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("searchType", searchType);
			params.put("hasChildGroup", hasChildGroup); //하위 부서 포함 여부
			params.put("useAttendStatus", useAttendStatus);
			
			if(groupType.equalsIgnoreCase("DEPT")){
				result = (CoviList) orgChartSvc.getUserList(params).get("list");
			}else if(groupType.equalsIgnoreCase("GROUP")){
				result = (CoviList) orgChartSvc.getGroupUserList(params).get("list");
			}
			
			params.put("isMailChk", isMailChk); //메일사용 여부
			
			returnList.put("list", result);
			returnList.put("status", Return.SUCCESS);
		} 
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getCompanyList : 조직도 - 회사 목록 조회
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getCompanyList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getCompanyList(
			   @RequestParam(value = "allCompany", required = true, defaultValue="Y") String allCompany,
			   @RequestParam(value = "companyCode", required = true, defaultValue="") String companyCode,
			   @RequestParam(value = "isAdmin", required = true, defaultValue="") String isAdmin
			) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		companyCode = companyCode.equals("") ? SessionHelper.getSession("DN_Code") : companyCode;
		
		try {
			CoviMap params = new CoviMap();
			params.put("allCompany", allCompany);
			params.put("companyCode", companyCode);
			params.put("isAdmin", isAdmin);
			
			if(isAdmin.equals("admin")) {
				CoviList assignedDomainList = ComUtils.getAssignedDomainCode();
				params.put("assignedDomain", assignedDomainList);
			}
			
			result = (CoviList) orgChartSvc.getCompanyList(params).get("list");
			
			returnList.put("list", result);	
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 
	 * @param keyword
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getAllUserAutoTagList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getAllUserAutoTagList(
		   @RequestParam(value = "keyword", required = false) String keyword,
		   @RequestParam(value = "haveDept", required = false, defaultValue = "N") String haveDept,
		   @RequestParam(value = "searchMailAddress", required = false, defaultValue = "N") String searchMailAddress
		   ) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		try{
		
			CoviMap params = new CoviMap();
			params.put("UserName", keyword);
			
			if("Y".equalsIgnoreCase(searchMailAddress)) {
				params.put("MailAddress", keyword);
			}
			
			params.put("haveDept", haveDept);
			
			result = orgChartSvc.getAllUserAutoTagList(params);
			
			returnList.put("list", result);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	 * getAllUserGroupAutoTagList - 자동완성 태그용 모든 사용자 및 그룹(회사, 부서, 커뮤니티 그룹) 조회
	 * @param keyword
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getAllUserGroupAutoTagList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getAllUserGroupAutoTagList(
			@RequestParam(value = "keyword", required = false) String keyword,
			@RequestParam(value = "onlyUser", required = false, defaultValue = "N") String onlyUser) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		try{
			
			CoviMap params = new CoviMap();
			params.put("KeyWord", keyword);
			params.put("onlyUser", onlyUser);
			
			result = orgChartSvc.getAllUserGroupAutoTagList(params);
			
			returnList.put("list", result);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 * @description 이미지 슬라이드 팝업 호출
	 */
	@RequestMapping(value = "control/goImageSlidePopup.do", method = RequestMethod.GET)
	public ModelAndView goImageSlidePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "cmmn/controls/ImageSlide";
		
		String messageID = request.getParameter("messageID");
		String serviceType = request.getParameter("serviceType");
		String objectType = request.getParameter("objectType");
		String objectID = request.getParameter("objectID");
		
		CoviMap params = new CoviMap();
		params.put("MessageID", messageID);
		params.put("ServiceType", serviceType);
		params.put("ObjectType", objectType);
		params.put("ObjectID", objectID);
		CoviList list = fileSvc.selectAttachAll(params);
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("list", list);
		return mav;
	}
	
	/**
	 * @param locale
	 * @param model
	 * @return
	 * @description 구독 설정 팝업
	 */
	@RequestMapping(value = "subscription/goConfigPopup.do", method=RequestMethod.GET)
	public ModelAndView goSubscriptionPopup(Locale locale, Model model) {
		String returnURL = "cmmn/controls/SubscriptionConfig";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * 
	 * @param	ServiceType	: 'Schedule', 'Board'
	 * 			targetID	: FolderID
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "subscription/addSubscription.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap insertSubscription(
			@RequestParam(value = "targetServiceType", required = true) String targetServiceType,
			@RequestParam(value = "targetID", required = true) String targetID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		try{
		
			CoviMap params = new CoviMap();
			params.put("targetServiceType", targetServiceType);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("targetID", targetID);
			params.put("targetIDs", targetID.split(";"));

			if("Board".equals(targetServiceType)){
				if(controlSvc.checkDuplicateSubscription(params)> 0){
					returnList.put("message", DicHelper.getDic("msg_AlreadyRegisted"));
					returnList.put("dupFlag", "Y");
				} else {
					controlSvc.insertSubscription(params);
					returnList.put("message", DicHelper.getDic("msg_37"));
					returnList.put("dupFlag", "N");
				}
			} else {
				controlSvc.deleteSubscriptionAll(params);
				controlSvc.insertSubscription(params);
				returnList.put("message", DicHelper.getDic("msg_37"));
				returnList.put("dupFlag", "N");
			}
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @return
	 * @throws Exception
	 * @description 구독 폴더 내부 게시글, 일정 조회
	 */
	@RequestMapping(value = "subscription/getTargetList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectSubscriptionTargetList() throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			String domainID = SessionHelper.getSession("DN_ID");
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			params.put("limitDay", StringUtil.parseInt(RedisDataUtil.getBaseConfig("SubscriptionDefaultDay", domainID)));
			params.put("limitCount", StringUtil.parseInt(RedisDataUtil.getBaseConfig("SubscriptionDefaultCount", domainID)));
			CoviList list = (CoviList) controlSvc.selectSubscriptionList(params).get("list");
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 구독중인 폴더 목록 조회
	 */
	@RequestMapping(value = "subscription/getFolderList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectSubscriptionFolderList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			String targetServiceType = request.getParameter("targetServiceType");
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("targetServiceType", targetServiceType);
			
			CoviList list = (CoviList) controlSvc.selectSubscriptionFolderList(params).get("list");
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 구독목록에서 제거
	 */
	@RequestMapping(value = "subscription/deleteFolder.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteSubscription(HttpServletRequest request) throws Exception{
		
		CoviMap returnList = new CoviMap();
		try{
			String targetServiceType = request.getParameter("targetServiceType");
			String subscriptionID = request.getParameter("subscriptionID");
			CoviMap params = new CoviMap();
			params.put("targetServiceType", targetServiceType);
			params.put("subscriptionID", subscriptionID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			int cnt = controlSvc.deleteSubscription(params);
			
			returnList.put("message", DicHelper.getDic("msg_37"));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/***** 즐겨찾기 메뉴  *****/
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 즐겨찾기 메뉴 목록 조회 
	 */
	@RequestMapping(value = "favorite/getList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectFavoriteMenuList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			String targetServiceType = request.getParameter("targetServiceType");
			CoviMap params = new CoviMap();

			String domainID = SessionHelper.getSession("DN_ID");
			String userCode = SessionHelper.getSession("USERID");
			String isAdmin = SessionHelper.getSession("isAdmin");
			
			params.put("userCode",userCode);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("targetServiceType", targetServiceType);
			
			if(!"Y".equalsIgnoreCase(isAdmin)) {
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Board", "V");			
				
				// 보기 권한이 있는 커뮤니티 목록 조회
				Set<String> authorizedCommunitySet = ACLHelper.getACL(SessionHelper.getSession(), "FD", "Community", "V");
				authorizedObjectCodeSet.addAll(authorizedCommunitySet);
				
				String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
				
				params.put("aclDataArr", objectArray);
				params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
				params.put("objectType", "FD");
			}
			
			CoviList list = (CoviList) controlSvc.selectFavoriteMenuList(params).get("list");
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * 
	 * @param	ServiceType		: 'Schedule', 'Board'
	 * 			TargetObjectType: 'MN', 'FD'
	 * 			TargetID		: FolderID, MenuID
	 * @return
	 * @throws Exception
	 * @description 즐겨찾기 메뉴에 추가
	 */
	@RequestMapping(value = "favorite/create.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap insertFavoriteMenu(
			@RequestParam(value = "targetServiceType", required = true) String targetServiceType,
			@RequestParam(value = "targetObjectType", required = true) String targetObjectType,
			@RequestParam(value = "targetURL", required = true) String targetURL,
			@RequestParam(value = "targetID", required = true) String targetID) throws Exception{
		
		CoviMap returnList = new CoviMap();
		try{
		
			CoviMap params = new CoviMap();
			params.put("targetServiceType", targetServiceType);			//Board, Schedule
			params.put("targetObjectType", targetObjectType);			//MN, FD
			params.put("targetURL", targetURL);							
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("targetID", targetID);
			params.put("targetIDs", targetID.split(";"));

			if("Schedule".equals(targetServiceType)){
				// 일정의 경우 전체 삭제 후 재 삽입
				controlSvc.deleteFavoriteMenuAll(params);
				controlSvc.insertFavoriteMenu(params);
				returnList.put("message", DicHelper.getDic("msg_37"));
				returnList.put("dupFlag", "N");
			} else {
				if(controlSvc.checkDuplicateFavoriteMenu(params)> 0){
					returnList.put("message", DicHelper.getDic("msg_AlreadyRegisted"));
					returnList.put("dupFlag", "Y");
				} else {
					controlSvc.insertFavoriteMenu(params);
					returnList.put("message", DicHelper.getDic("msg_37"));
					returnList.put("dupFlag", "N");
				}
			}
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 즐겨찾기 메뉴 항목 삭제
	 */
	@RequestMapping(value = "favorite/delete.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteFavoriteMenu(HttpServletRequest request) throws Exception{
		
		CoviMap returnList = new CoviMap();
		try{
			String favoriteID = request.getParameter("favoriteID");
			CoviMap params = new CoviMap();
			params.put("favoriteID", favoriteID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			int cnt = controlSvc.deleteFavoriteMenu(params);
			
			returnList.put("message", DicHelper.getDic("msg_37"));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * @param locale
	 * @param mode
	 * @return
	 * @description 공유 팝업
	 */
	@RequestMapping(value = "share/getPopup.do", method=RequestMethod.GET)
	public ModelAndView goSharePopup(Locale locale, Model mode) {
		String returnURL = "core/devhelper/addsharepopup";
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @description 정보보기 팝업 호출
	 */
	@RequestMapping(value = "control/callTeamsInfo.do", method=RequestMethod.GET)
	public ModelAndView goTeamsInfoPopup(HttpServletRequest request, Locale locale, Model model){
		String returnURL = "cmmn/controls/TeamsInfo";
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @description 정보보기 팝업 호출
	 */
	@RequestMapping(value = "control/callMyInfo.do", method=RequestMethod.GET)
	public ModelAndView goMyInfoPopup(HttpServletRequest request, Locale locale, Model model){
		String returnURL = "cmmn/controls/MyInfo";
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 * @description 내정보 DB 조회
	 */
	@RequestMapping(value = "control/getMyInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMyInfos(HttpServletRequest request, Locale locale, Model model) throws Exception
	{
		String userId = request.getParameter("userId");
		
		CoviMap returnList = new CoviMap();
		
		try{
			returnList.put("data", loginSvc.getMyInfo(userId));
			returnList.put("addJobList", loginSvc.getAddJobList(userId));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
		
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 연락처 추가
	 */
	@RequestMapping(value = "contact/create.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertContact(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("selectedCode", request.getParameter("selectedCode"));
			
			if(controlSvc.checkDuplicateContact(params)> 0){
				returnData.put("message", DicHelper.getDic("msg_AlreadyRegisted"));
			} else {
				controlSvc.insertContact(params);
				returnData.put("message", DicHelper.getDic("msg_37"));
			}
			returnData.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 연락처 삭제
	 */
	@RequestMapping(value = "contact/delete.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteContact(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("selectedType", request.getParameter("selectedType"));
			params.put("selectedCode", request.getParameter("selectedCode"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			controlSvc.deleteContact(params);
			returnData.put("message", DicHelper.getDic("msg_50"));	//삭제 됐습니다.
			returnData.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 연락처 조회
	 */
	@RequestMapping(value = "contact/getNumberList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectContactNumberList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			CoviList list = (CoviList) controlSvc.selectContactNumberList(params).get("list");
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description Todo 조회
	 */
	@RequestMapping(value = "todo/getList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectTodoList(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("todoId", request.getParameter("todoId"));
			
			CoviList list = (CoviList) controlSvc.selectTodoList(params).get("list");
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description Todo 추가
	 */
	@RequestMapping(value = "subscription/insertTodo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertTodo(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("messageType", request.getParameter("messageType"));
			params.put("title", request.getParameter("title"));
			params.put("url", request.getParameter("url"));
			params.put("description", request.getParameter("description"));
			params.put("isComplete", request.getParameter("isComplete"));
			
			int result = controlSvc.insertTodo(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Added"));
		}
		catch(NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * @param locale
	 * @param model
	 * @return
	 * @description Todo 추가 팝업
	 */
	@RequestMapping(value = "subscription/goWriteTodoPopup.do", method=RequestMethod.GET)
	public ModelAndView goTodoPopup(Locale locale, Model model) {
		return new ModelAndView("cmmn/controls/WriteTodo");
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description Todo 수정
	 */
	@RequestMapping(value = "subscription/updateTodo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateTodo(HttpServletRequest request) throws Exception {
		CoviMap returnData = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			params.put("isComplete", request.getParameter("isComplete"));
			params.put("title", request.getParameter("title"));
			params.put("description", request.getParameter("description"));
			params.put("todoId", request.getParameter("todoId"));
			
			int result = controlSvc.updateTodo(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", DicHelper.getDic("msg_Edited"));
		}
		catch(NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}	
	
	/**
	 * @param userID
	 * @param request
	 * @return
	 * @throws Exception
	 * @description Todo삭제
	 */
	@RequestMapping(value = "subscription/deleteTodo.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteTodo(	@RequestParam(value = "userID", required = false) String userID, HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			if(userID==null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("todoId", request.getParameter("todoId"));
			
			controlSvc.deleteTodo(params);
			
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}	
	
	//공통 처리 끝
	
	/**
	 * @param userID
	 * @return
	 * @throws Exception
	 * @description 퀵메뉴(즐겨찾기 메뉴) 설정 값 조회
	 */
	@RequestMapping(value = "quick/getUserQuickMenu.do")
	public @ResponseBody CoviMap getUserQuickMenu(
			@RequestParam(value = "userID", required = false) String userID) throws Exception {
		
		/**
		 * Data Format Of QuickMenuConf
		 * {
			  "Survey": "N",
			  "Approval": "Y",
			  "Task": "N",
			  "Board": "Y",
			  "Community": "N",
			  "Mail": "N",
			  "TimeSquare": "N",
			  "Schedule": "N",
			  "Integrated": "N",
			  "ShowList": "Approval;Board;",  #실제 보여지는 항목
			  "Order": "Survey;Approval;Task;Board;Community;Mail;TimeSquare;Schedule;Integrated;" #순서
			}
		 */
		CoviMap returnList = new CoviMap();
		
		try {
			if(userID == null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			
			returnList.put("data", controlSvc.selectQuickMenuConf(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param userID
	 * @param configObj
	 * @return
	 * @throws Exception
	 * @description 퀵메뉴(즐겨찾기 메뉴) 설정 값 Update
	 */
	@RequestMapping(value = "quick/updateUserConf.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateUserConf(
			@RequestParam(value = "userID", required = false) String userID,
			@RequestParam(value = "configObj", required = true) String configObj) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			if(userID==null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("quickMenuConf", StringEscapeUtils.unescapeHtml(configObj));
			
			 controlSvc.updateUserConf(params);
			
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}	
	
	
	/**
	 * @param userID
	 * @return
	 * @throws Exception
	 * @description 통합 알림 목록 조회
	 */
	@RequestMapping(value = "quick/getIntegratedList.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getIntegratedList(
			@RequestParam(value = "userID", required = false) String userID,
			@RequestParam(value = "alarmType", required = false) String alarmType) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			if(userID==null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("alarmType",alarmType);

			returnList.put("list",  controlSvc.selectIntegratedList(params));
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}	
	
	
	//통합 알림 읽음 처리
	@RequestMapping(value = "quick/updateAlarmIsRead.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateAlarmIsRead(
			@RequestParam(value = "alarmID", required = true) String alarmID,
			@RequestParam(value = "userID", required = false) String userID) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			if(userID==null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("alarmID", alarmID);
			params.put("userID", userID);
			
			controlSvc.updateAlarmIsRead(params);

			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}	
	
	@RequestMapping(value = "quick/deleteAllAlarm.do", method={RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteAllAlarm(
			@RequestParam(value = "userID", required = false) String userID,
			@RequestParam(value = "alarmType", required = false) String alarmType) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			if(userID==null){
				userID = SessionHelper.getSession("USERID");
			}
			
			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("alarmType",alarmType);
			
			controlSvc.deleteAllAlarm(params);
			
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "quick/deleteEachAlarm.do", method={RequestMethod.POST})
	public @ResponseBody CoviMap deleteSelAlarm(@RequestParam(value = "deleteID", required = true) String deleteID) throws Exception{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap();
			params.put("userID", SessionHelper.getSession("USERID"));
			params.put("deleteID", deleteID);
			
			controlSvc.deleteEachAlarm(params);
			
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/control/sendSimpleMail.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap sendSimpleMail(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			String senderName = SessionHelper.getSession("UR_Name");
			String senderMail = SessionHelper.getSession("UR_Mail");
			
			//CHECKED:base_object_user에서 sys_object_user로 테이블이 변경 되면 세션 추출해서 사용
			//메일 전송 테스트용 ID의 경우 실제 운영서버에 존재 하지 않으면 에러 출력됨
			//String senderMail = "gypark@covision.co.kr";
			String receiverCode = request.getParameter("userCode");
			String subject = request.getParameter("subject");
			String bodyText = request.getParameter("bodyText");
			
			params.put("senderName", senderName);
			params.put("senderMail", senderMail);
			params.put("receiverCode", receiverCode);
			params.put("subject", subject);
			params.put("bodyText", bodyText);
			
			controlSvc.sendSimpleMail(params);
			
			returnList.put("status", Return.SUCCESS);
		}
		catch(NullPointerException e) {
			LOGGER.error("setMessagingBaseCode Failed [" + e.getMessage() + "]", e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception ex) {
			LOGGER.error("setMessagingBaseCode Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 * @description 비밀번호 변경
	 */
	@RequestMapping(value = "/control/changePassword.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap changePassword(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		
		CoviMap returnList = new CoviMap();
		
		String validationType = request.getParameter("validationType");
		String receptionMobile = request.getParameter("smobile");
		String receptionMail = request.getParameter("smail");
		String id = request.getParameter("id");
		String name = request.getParameter("nm");
		String emailAddress = request.getParameter("emailAddress");
		String logonPassword = "";
		String logType = (request.getParameter("logType") == null) ? "passwordReset" : request.getParameter("logType");
		int otpUseTime = Integer.parseInt(request.getParameter("otpUseTime"));
		
		CoviMap otpParams = new CoviMap();
		otpParams.put("id",id);
		otpParams.put("otpNumber",request.getParameter("otpNo"));
		otpParams.put("logType", logType);
		otpParams.put("otpUseTime", StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPUseTime"), "10"));
		if(loginSvc.selectOTPCheck(otpParams) == 0 ){
			int FailCount = 0;
			if(otpUseTime != 0) {
				FailCount = loginSvc.selectOTPFailCount(otpParams);
			}
			int baseFailCount = Integer.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPFailCount"), "5"));
			returnList.put("baseFailCount", baseFailCount);
			returnList.put("failcount", FailCount);
			returnList.put("status", Return.FAIL);
			returnList.put("code", "ero");
			return returnList;
		}
		
		try {	
			
			params.put("validationType",validationType);
			params.put("receptionMobile",receptionMobile);
			params.put("receptionMail",receptionMail);
			params.put("id",id);
			params.put("name",name);
			params.put("emailAddress",emailAddress);
			
			if(func.f_NullCheck(validationType).equals("Email")){
				params.put("validationType",validationType);
			}else{
				returnList.put("status", Return.FAIL);
				returnList.put("code", "ere");
				return returnList;
			}
			
			//외부메일의 경우 사용자가 수신받길 원하는 메일로 받을 수 있도록 validation항목에서 임시로 제외함
			if(controlSvc.externalMailCnt(params) == 0 ){
				returnList.put("status", Return.FAIL);
				returnList.put("code", "eru");
				return returnList;
			}
			
			logonPassword = func.randomValue("P", 12);
			
			if(func.f_NullCheck(logonPassword).equals("")){
				returnList.put("status", Return.FAIL);
				returnList.put("code", "erp");
				return returnList;
			}else{
				String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")); 
				
				AES aes = new AES(key, "N");
				
				String sLogonPW = aes.encrypt(logonPassword);
				
				//자릿수 변경 24 --> 8자리
				sLogonPW = sLogonPW.substring(0,8);
				params.put("LogonPassword",sLogonPW);
				params.put("loginPassword",sLogonPW);
				params.put("aeskey",key);
			}
			
			if(!controlSvc.changePassword(params)){
				returnList.put("status", Return.FAIL);
				returnList.put("code", "erf");
			}else{
				returnList.put("status", Return.SUCCESS);
				returnList.put("code", "ok");
			}
		}
		catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception ex) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "control/checkFido.do", method = RequestMethod.GET)
	public ModelAndView checkFido(HttpServletRequest request) throws Exception{
		return (new ModelAndView("cmmn/controls/FidoPopup"));
	}

	@RequestMapping(value = "control/authWarningPopup.do", method = RequestMethod.GET)
	public ModelAndView authWarningPopup(HttpServletRequest request) throws Exception{
		return (new ModelAndView("cmmn/controls/AuthWarningPopup"));
	}
	
	/**
	 * @param request
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 * @description 구독, 즐겨찾기, To-Do 추가시 안내 메시지 팝업 호출
	 */
	@RequestMapping(value = "control/goGuideMessagePopup.do", method = RequestMethod.GET)
	public ModelAndView goGuideMessagePopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		String returnURL = "cmmn/controls/GuideMessagePopup";
		String type = request.getParameter("messageType");
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("messageType", type);
		return mav;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description two factor 인증 팝업 호출
	 */
	@RequestMapping(value="control/twoFector.do")
	public ModelAndView twoFector(HttpServletRequest request) throws Exception{
		
		String returnURL = "cmmn/controls/TwoFector";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("id", request.getParameter("id"));
		return mav;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "control/sendTwoFactor.do")
	public @ResponseBody CoviMap loginTwoFactorChk(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap resultList = new CoviMap();
		
		String otpNumber = func.RandomNum();
		String logType = (request.getParameter("logType") == null) ? "login" : request.getParameter("logType");
		params.put("LogType",logType);
		params.put("LogonID",request.getParameter("id"));
		params.put("OTPNumber", otpNumber);
		params.put("IPAddress", func.getRemoteIP(request));
		params.put("PageEventType", "U");
		
		
		CoviMap userParams = new CoviMap();
		userParams.put("id",request.getParameter("id"));
		userParams.put("name",request.getParameter("nm"));
		userParams.put("emailAddress",request.getParameter("emailAddress"));
		userParams.put("LogType",logType);
		if(logType.equals("passwordReset")) {	
		
			if (controlSvc.externalMailCnt(userParams) == 0 ){
				returnList.put("result", Return.FAIL);
				returnList.put("code", "eru");
				return returnList;
			}			
		}
		int EventDate = controlSvc.recentOTP(userParams).getInt("EventDate");
		int CurrentDate = controlSvc.recentOTP(userParams).getInt("CurrentDate");
		int result = CurrentDate-EventDate;
		int OTPResendTime = Integer.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPResendTime"), "1"))*60;

		if(result < OTPResendTime && result > 0) {
			returnList.put("result", Return.FAIL);
			returnList.put("code", "wait");
			returnList.put("diff", OTPResendTime - result);
			return returnList;
		}
		
		resultList = loginSvc.checkAuthetication("SSO", request.getParameter("id"), "", "");
		
		CoviMap account = (CoviMap) resultList.get("account");
		
		String domainUrl = loginSvc.selectUserDomainUrl(params);
		params.put("DOMAINURL", domainUrl);
		
		String bodyText = OTPHtmlText(otpNumber);
		String message = "인증번호 "+otpNumber+"를 입력하세요.(Enter authentication number)";
		
		//메일 발송.
		if(!func.f_NullCheck(account.get("ExternalMailAddress").toString()).equals("")){
			LoggerHelper.auditLogger(request.getParameter("id"), "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", account.get("DN_ID").toString()), bodyText, "ExternalMailAddress");
			MessageHelper.getInstance().sendSMTP("관리자(admin)", PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("ExternalMailAddress").toString(), "그룹웨어 인증번호 발송(Send groupware authentication number)", bodyText, true); 
		}
		
		String pushUserId = request.getParameter("id");
		if (!account.get("LogonID").equals(account.get("UR_Code"))) {
			pushUserId = (String)account.get("UR_Code");
		}
		
		MessageHelper.getInstance().sendPushByUserID(pushUserId, message);
		LoggerHelper.auditLogger(request.getParameter("id"), "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", account.get("DN_ID").toString()), message, "ExternalMailAddress");
		
		if(controlSvc.createTwoFactor(params)){
			returnList.put("result", Return.SUCCESS);
		}else{
			returnList.put("result", Return.FAIL);
		}
		
		int OTPUseTime = Integer.parseInt(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPUseTime"), "10"));
		returnList.put("otp", OTPUseTime);
		
		return returnList;
	}	
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * 
	 */
	@RequestMapping(value="control/admin/twoFector.do")
	public ModelAndView adminTwoFector(HttpServletRequest request) throws Exception{
		StringUtil func = new StringUtil();
		String returnURL = "cmmn/controls/AdminTwoFector";
		CoviMap params = new CoviMap();
		
		//여기서 IP 체크
		String domainId = SessionHelper.getSession("DN_ID");
		String ipaddress = func.getRemoteIP(request);
		String[] ip = ipaddress.split("\\.");
		String partIPAddress = String.format("%03d", Integer.parseInt(ip[0]))+String.format("%03d", Integer.parseInt(ip[1]))+String.format("%03d", Integer.parseInt(ip[2]))+String.format("%03d", Integer.parseInt(ip[3]));
		
		params.put("domainID", domainId);
		if(func.f_NullCheck(partIPAddress).equals("127000000001")){
			params.put("partIPAddress", "127001");
		}else{
			params.put("partIPAddress", partIPAddress);
		}
		
		if(authSvc.selectTwoFactorIpCheck(params,"A") == 0){
			returnURL = "cmmn/controls/AdminTwoFector";
		
			ModelAndView mav = new ModelAndView(returnURL);
			return mav;
			
		}else{
			String adminContext = RedisDataUtil.getBaseConfig("AdminBaseContext");
			String cTempValue = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID")+"_PSM","TEMP");
			String targetUrl = "";
			targetUrl = adminContext+"&CSA_SC="+Sha512.encrypt("|"+SessionHelper.getSession("USERID")+"|"+cTempValue+"|"+"Y"+"|");
			
			returnURL = "cmmn/controls/Relay";
			
			ModelAndView mav = new ModelAndView(returnURL);
			mav.addObject("targetUrl", targetUrl);
			return mav;
			
		}
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 관리자 페이지 접근시 Two factor 인증
	 */
	@RequestMapping(value = "control/admin/sendTwoFactor.do")
	public @ResponseBody CoviMap adminTwoFactorChk(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap resultList = new CoviMap();
		
		String otpNumber = func.RandomNum();
		
		String userID = SessionHelper.getSession("USERID");
		
		params.put("LogType","login");
		params.put("LogonID",userID);
		params.put("OTPNumber", otpNumber);
		params.put("IPAddress", func.getRemoteIP(request));
		params.put("PageEventType", "A");
		
		resultList = loginSvc.checkAuthetication("SSO", userID, "", "");
		
		CoviMap account = (CoviMap) resultList.get("account");
		
		String domainUrl = loginSvc.selectUserDomainUrl(params);
		params.put("DOMAINURL", domainUrl);
		
		String bodyText = OTPHtmlText(otpNumber);
		String message = "["+otpNumber+"] 인증번호를 입력하세요.(Enter authentication number)";
		
		//메일 발송.
		if(!func.f_NullCheck(account.get("ExternalMailAddress").toString()).equals("")){
			LoggerHelper.auditLogger(userID, "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", account.get("DN_ID").toString()), bodyText, "ExternalMailAddress");
			MessageHelper.getInstance().sendSMTP("관리자(admin)", PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("ExternalMailAddress").toString(), "그룹웨어 인증번호 발송(Send groupware authentication number)", bodyText, true); 
		}
		
		//뱃지 카운트 조회
		String badgeCount = messageManageSvc.selectBadgeCount(userID);
		MessageHelper.getInstance().sendPushByUserID(userID, message, badgeCount);
		LoggerHelper.auditLogger(userID, "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", account.get("DN_ID").toString()), message, "ExternalMailAddress");
		
		if(controlSvc.createTwoFactor(params)){
			returnList.put("result", Return.SUCCESS);
		}else{
			returnList.put("result", Return.FAIL);
		}
		
		return returnList;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description 관리자 페이지 접근시 Two factor 인증
	 */
	@RequestMapping(value = "control/admin/TwoFactorAdminLogin.do")
	public @ResponseBody CoviMap twoFactorAdminLogin(HttpServletRequest request) throws Exception{
		//	TwoFactorAdminLogin
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		String userID = SessionHelper.getSession("USERID");
		
		params.put("id",userID);
		params.put("otpNumber",request.getParameter("otp"));
		params.put("otpUseTime", StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPUseTime"), "10"));		
		if(loginSvc.selectOTPCheck(params) == 0 ){
			returnList.put("result","fail");
		}else{
			returnList.put("result","SUCCESS");
			
			String adminContext = RedisDataUtil.getBaseConfig("AdminBaseContext");
			
			String cTempValue = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID")+"_PSM","TEMP");
			
			returnList.put("url",adminContext+"&CSA_SC="+Sha512.encrypt("|"+SessionHelper.getSession("USERID")+"|"+cTempValue+"|"+"Y"+"|"));
		}
		
		return returnList;
	}
	
	
	
	public String OTPHtmlText(String number){
		String bodyText = "";
		
			bodyText = "<html>";
			bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
				bodyText += "<tbody>";
					bodyText += "<tr>";
						bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#2b2e34'>";
							bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
										bodyText += "System";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";	
					bodyText += "<tr>";
						bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
							bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
											bodyText += "<span style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">[그룹웨어 인증번호/Groupware Authentication]</span>";
										bodyText += "</td>";
									bodyText += "</tr>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; padding:0 0 15px 20px; color:#444;\">";
											bodyText += "["+ number +"] 인증번호를 입력후 확인 버튼을 눌러주세요.<br/>";
											bodyText += "(Please click confirm button after entering this number.)";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";
				
					bodyText += "<tr>";
						bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
							bodyText += "Copyright <span style='font-weight:bold; color:#222222;'>"+PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.";
						bodyText += "</td>";
					bodyText += "</tr>";	
				bodyText += "</tbody>";
			bodyText += "</table>";
		bodyText += "</html>";
		
		return bodyText;
	}
	
	/**
	 * @param request
	 * @param pAuthKey		sys_base_fido key값
	 * @param pAuthType		Login-로그인, PwCheck-패스워드체크, Approval-결재, AuthCheck- 기타 본인인증
	 * @param pAuthToken	LogonID + UR_Code + 요청시간 + 인증키 + 요청유형 : 암호화한 값(AES)
	 * @param pLogonID		로그인ID
	 * @param pReqMode		
	 * @param pEQ_AuthKind	Finger-지문,Eye-홍체,Face-안면,Pattern-패턴,PW-패스워드
	 * @param pAuthEQ_Info	Android ...
	 * @return
	 * @throws Exception
	 * @description FIDO 인증 처리
	 */
	@RequestMapping(value = "control/fido.do")
	public @ResponseBody CoviMap checkFido(HttpServletRequest request,
			 @RequestParam(value = "authKey", required = false) String pAuthKey,
			 @RequestParam(value = "authType", required = true) String pAuthType,
			 @RequestParam(value = "authToken", required = false) String pAuthToken,		//LogonID | 요청시간 | 인증번호 | 요청유형
			 @RequestParam(value = "mauthToken", required = false) String pMAuthToken,		//LogonID | 요청시간 | 인증번호 | 요청유형 | 모바일인증 시간
			 @RequestParam(value = "logonID", required = true) String pLogonID,
			 @RequestParam(value = "reqMode", required = true) String pReqMode,
			 @RequestParam(value = "eq_AuthKind", required = false) String pEQ_AuthKind,
			 @RequestParam(value = "authEQ_Info", required = false) String pAuthEQ_Info,
			 @RequestParam(value = "description", required = false) String pDescription) throws Exception{
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap returnList = new CoviMap();
		returnList.put("status", Return.FAIL);
		
		if(!func.f_NullCheck(pAuthToken).equals("")) {
			pAuthToken = URLDecoder.decode(pAuthToken, "UTF-8");
		}
		if(!func.f_NullCheck(pMAuthToken).equals("")) {
			pMAuthToken = URLDecoder.decode(pMAuthToken, "UTF-8");
		}
		if(!func.f_NullCheck(pEQ_AuthKind).equals("")) {
			pEQ_AuthKind = URLDecoder.decode(pEQ_AuthKind, "UTF-8");
		}
		if(!func.f_NullCheck(pAuthEQ_Info).equals("")) {
			pAuthEQ_Info = URLDecoder.decode(pAuthEQ_Info, "UTF-8");
		}
		if(!func.f_NullCheck(pDescription).equals("")) {
			pDescription = URLDecoder.decode(pDescription, "UTF-8");
		}

		//TODO: siteKey는 구현 이후 추가
		params.put("isMobile", ClientInfoHelper.isMobile(request));
		params.put("authKey", pAuthKey);
		params.put("authType", pAuthType);
		params.put("authToken", pAuthToken);
		params.put("mauthToken", pMAuthToken);
		params.put("authSystem", "GW");			//TODO: GW 고정, 추가 시스템이 존재 할 경우 별도 코드 구분 추가
		params.put("logonID", pLogonID);
		params.put("reqMode", pReqMode);
		params.put("eq_AuthKind", pEQ_AuthKind);
		params.put("authEQ_Info", pAuthEQ_Info);
		params.put("description", pDescription);
		params.put("reffer", request.getRequestURI());
		
		//요청시간 체크,토큰 유효성 검사 추가 예정
		if(checkFidoValidation(params, returnList)){
	
			//pReqMode을 기준으로  분기처리
			if("ReqAuth".equals(pReqMode)){
				//인증 요청
				reqAuth(params, returnList);
			} else if("ReadAuth".equals(pReqMode)){
				//인증 상태 확인
				String status = controlSvc.selectFidoStatus(params); 
				returnList.put("authKey", params.get("authKey"));
				if(!"".equals(func.f_NullCheck(status))){
					returnList.put("resMessage", status);
					returnList.put("status", Return.SUCCESS);
				} else {
					returnList.put("resMessage", "필수 인자값이 누락되었습니다. 관리자에게 문의하세요.(Required value missing. Please contact the administrator)");
					returnList.put("status", Return.FAIL);
				}
			} else {
				//reqMode: MobileSucc, MobileFail, CancelAuth, CheckAuth
				updateFidoStatus(params, returnList);		//sys_base_fido 테이블 데이터 상태 변경
			}
		}
		LoggerHelper.auditLogger(pLogonID, "S", pReqMode, "", returnList.getString("status"), "FIDO AUTH");
		return returnList;
	}	
	
	
	/**
	 * @param params
	 * @param returnObj
	 * @return
	 * @description FIDO 파라메터 validation 체크
	 * 
	 */
	private boolean checkFidoValidation(CoviMap params, CoviMap returnObj){
		//인증토큰 체크(복호화 및 체크)
        if (!"".equals(params.getString("authToken"))){
        	String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
        	
            String[] tokenShards;
			try {
				AES aes = new AES(aeskey, "N");
				tokenShards = aes.decrypt(params.getString("authToken")).split("\\|");
			}
			catch(NullPointerException e) {
				returnObj.put("resMessage", "필수 인자값이 누락되었습니다. 관리자에게 문의하세요.(Required value missing. Please contact the administrator)");
				returnObj.put("status", Return.FAIL);
				return false;
			}
			catch (Exception e) {
				returnObj.put("resMessage", "필수 인자값이 누락되었습니다. 관리자에게 문의하세요.(Required value missing. Please contact the administrator)");
                returnObj.put("status", Return.FAIL);
                return false;
			}

            // parameter 검증
            if (!tokenShards[0].equals(params.getString("logonID")) || !tokenShards[2].equals(params.getString("authKey")) || !tokenShards[3].equals(params.getString("authType"))){
            	returnObj.put("resMessage", "인증정보가 일치하지 않습니다.(Authentication information does not match)");
            	returnObj.put("status", Return.FAIL);
            	return false;
            }

            if(!"CancelAuth".equalsIgnoreCase(params.getString("reqMode"))) {
	            //Token 시간
	            String sDate = tokenShards[1].split("_")[0];
	            String sTime = tokenShards[1].split("_")[1];
	            DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");
	            DateTime dtTokenDate = formatter.parseDateTime(sDate + " " + sTime);
	            
	            //현재 (GMT+0)
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				sdf.setTimeZone(TimeZone.getTimeZone("GMT")); 
				String sCurrentTime = sdf.format(new Date());
	            
				DateTime dtCurrentTime = formatter.parseDateTime(sCurrentTime);
	            Duration dur = new Duration(dtTokenDate, dtCurrentTime);
	            long diffSeconds = dur.getStandardSeconds();
	            
	            // 인증유효시간 체크 5분
	            if (diffSeconds > 300){
	                returnObj.put("resMessage", "인증키 유효시간(5분)을 초과하였습니다.(Authentication key validity time (5 minutes) timed out)");
	                returnObj.put("status", Return.FAIL);
	                return false;
	            }
            }
            
        } else {
        	//TODO: authToken 필수 여부 체크 MP에서는 별도로 체크 안함
        }
        return true;
	}
	
	/**
	 * @param params
	 * @param returnObj
	 * @description 인증요청: ReqAuth
	 */
	private void reqAuth(CoviMap params, CoviMap returnObj){
		try {
			
			int cnt = controlSvc.createFido(params);
			
			//authToken 생성
			String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
			AES aes = new AES(aeskey, "N");

			//지역에 상관없도록 GMT+0시간 사용
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH:mm:ss");
			sdf.setTimeZone(TimeZone.getTimeZone("GMT")); 
			String currentTime = sdf.format(new Date());
			
			String authToken = aes.encrypt(params.getString("logonID") + "|" + currentTime + "|" + params.getString("authKey") + "|" + params.getString("authType"));
			params.put("authToken", authToken);
			
			controlSvc.updateAuthToken(params);
			
			if(cnt > 0){
				//fido 인증요청  push 전송
				boolean pushFlag = MessageHelper.getInstance().sendPushByUserID(params.getString("userCode"), "REQFIDO:" + authToken);
				if(pushFlag){
					returnObj.put("status", Return.SUCCESS);
					returnObj.put("authKey", params.get("authKey"));
					returnObj.put("authToken", params.get("authToken"));
				}
			} else {
				returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
			}
		} 
		catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
		}
	}
	
	/**
	 * @param params
	 * @param returnObj
	 * @description 인증요청 상태 변경: MobileSucc, MobileFail, CancelAuth, CheckAuth, ReadAuth
	 * 
	 */
	private void updateFidoStatus(CoviMap params, CoviMap returnObj){
		try {
			int cnt = controlSvc.updateFidoStatus(params);
		
			if(cnt > 0){
				//fido 인증요청  push 전송
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("resMessage", "OK");
				returnObj.put("authKey", params.get("authKey"));
			} else {
				returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
			}
		}
		catch(NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
		}
		catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("resMessage", "인증에 실패했습니다.(Authentication failed)");
		}
	}
	
	/**
	 * @param request
	 * @return
	 * @throws Exception
	 * @description UR/GR/DN 정보 조회
	 * 세션에 없는 사용자 정보 불러올 때 등 사용(ex - EnterDate)
	 */
	@RequestMapping(value = "control/GetBaseObjectInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBaseObjectInfo(HttpServletRequest request) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap params = new CoviMap();
		
		try {
			String mode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
			String objId = request.getParameter("objId") == null ? "" : request.getParameter("objId");
			String fields = request.getParameter("fields") == null ? "" : request.getParameter("fields");
			
			params.put("objId", objId);
			
			switch(mode) {
				case "UR": // 사용자
					if(fields.equals("")) {
						params.put("fields", "A.UserCode,CompanyCode,DeptCode,EmpNo,DisplayName,MultiDisplayName,MultiDeptName");	
					} else {
						params.put("fields", fields.replaceAll("UserCode", "A.UserCode"));
					}
					
					returnList.put("result", controlSvc.selectObjectOne_UR(params));
					break;
				case "GR": // 부서
					if(fields.equals("")) {
						params.put("fields", "GroupCode,CompanyCode,GroupType,DisplayName,MultiDisplayName,ShortName,MultiShortName,PrimaryMail");	
					} else {
						params.put("fields", fields);
					}
					
					returnList.put("result", controlSvc.selectObjectOne_GR(params));
					break;
				case "DN": // 회사
					if(fields.equals("")) {
						params.put("fields", "DomainID,DomainCode,DomainURL,DisplayName,MultiDisplayName,ShortName,MultiShortName");	
					} else {
						params.put("fields", fields);
					}
					
					returnList.put("result", controlSvc.selectObjectOne_DN(params));					
					break;
				default:
					break;
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
	
	/**
	 * 공공기관 조직도 초기 트리 데이터 조회
	 * @param companyCode - 회사 코드
	 * @param groupType - dept or group
	 * @param searchText - 검색어
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "control/getGovOrgTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getGovOrgTreeList( HttpServletRequest request ) throws Exception{
		
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try{
			CoviMap params = new CoviMap();
			String memberOf = request.getParameter("memberOf");
			String parentOUCode = request.getParameter("parentOUCode");
			String searchText = request.getParameter("searchText");
			String govReceiveGubun = request.getParameter("govReceiveGubun");

			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			
			if(memberOf != null && !memberOf.equals(""))
				params.put("memberOf", memberOf);
			else if(parentOUCode != null && !parentOUCode.equals(""))
				params.put("parentOUCode", parentOUCode);
			else
				params.put("parentOUCode", "0000000");
			
			if (StringUtil.replaceNull(govReceiveGubun).equals("gov")) { //LDAP 수신처
				resultList = orgChartSvc.getGovOrgTreeList(params);
			} else { //문서24수신처
				resultList = orgChartSvc.getGov24OrgTreeList(params);
			}			
			returnList.put("list", resultList);
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
    
    /**
     * getSelectedUserList : 조직도 - 선택한 사용자 정보 조회
     * @param selections - usercode (구분자 ;)
     * @return returnMap
     * @throws Exception
     */
    @RequestMapping(value = "control/getSelectedUserList.do", method={RequestMethod.GET,RequestMethod.POST})
    public @ResponseBody CoviMap getSelectedUserList(
           @RequestParam(value = "selections", required = false, defaultValue="") String selections) throws Exception{
        
        CoviMap returnMap = new CoviMap();
        
        try{
            CoviMap params = new CoviMap();

            if(!"".equals(selections)) {
                String[] selectionArray = selections.split(";");
                params.put("selections", selectionArray);
            }
            
            returnMap = (CoviMap) orgChartSvc.getSelectedUserList(params);
        }
		catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
        
        return returnMap;
    }
    
    /**
     * getUserList : 조직도 - 선택한 부서 정보 조회
     * @param selections - groupCode (구분자 ;)
     * @return returnMap
     * @throws Exception
     */
    @RequestMapping(value = "control/getSelectedDeptList.do", method={RequestMethod.GET,RequestMethod.POST})
    public @ResponseBody CoviMap getSelectedDeptList(
           @RequestParam(value = "selections", required = false, defaultValue="") String selections) throws Exception{
        
        CoviMap returnMap = new CoviMap();
        
        try{
            CoviMap params = new CoviMap();

            if(!"".equals(selections)) {
                String[] selectionArray = selections.split(";");
                params.put("selections", selectionArray);
            }
            
            returnMap = (CoviMap) orgChartSvc.getSelectedDeptList(params);
        }
		catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
        
        return returnMap;
    }
}
