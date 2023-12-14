package egovframework.covision.groupware.bizcard.user.web;

import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;
import egovframework.covision.groupware.bizcard.user.service.BizCardListService;

/**
 * @Class Name : BizCardCommonCon.java
 * @Description : 인명관리 일반적 요청 처리
 * @Modification Information 
 * @ 2017.07.31 최초생성
 *
 * @author 코비젼 연구2팀
 * @since 2017.07.31
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/bizcard")
public class BizCardListCon {
	// log4j obj 
	private Logger LOGGER = LogManager.getLogger(BizCardListCon.class);
	
	@Autowired
	private BizCardListService bizCardListService;
	
	@Autowired
	private BizCardGroupManageService bizCardGroupManageService;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//페이지 이동	
	@RequestMapping(value="moveToExportFileBizCard.do", method=RequestMethod.GET)
	public ModelAndView modifyBizCard(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strBizCardID = request.getParameter("BizCardID");
		String strBizGroupID = request.getParameter("BizGroupID");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "bizcard/ExportFileBizCard.user.content";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("BizCardID", strBizCardID);
		mav.addObject("BizGroupID", strBizGroupID);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	
	@RequestMapping(value="getBizCardFavoriteList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardFavoriteList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("tabFilter", strTabFilter);
		params.put("searchWord", ComUtils.RemoveSQLInjection(strSearchWord, 100));
		params.put("searchType", strSearchType);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		//timezone 적용 날짜변환
		if(params.get("startDate") != null && !params.get("startDate").equals("")){
			params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if(params.get("endDate") != null && !params.get("endDate").equals("")){
			params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
		}

		CoviMap listData = bizCardListService.selectBizCardFavoriteList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	@RequestMapping(value="getBizCardAllList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectBizCardAllList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
		String strGroupIDs = StringUtil.replaceNull(request.getParameter("groupIDs"), "");
		String[] arrGroupID = null;
		
		if(strGroupIDs.isEmpty()){
			strGroupIDs = null;
			arrGroupID = null;
		} else{
			arrGroupID = strGroupIDs.split(";");
		}
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		params.put("lang", SessionHelper.getSession("lang"));
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("tabFilter", strTabFilter);
		params.put("searchWord", ComUtils.RemoveSQLInjection(strSearchWord, 100));
		params.put("searchType", strSearchType);
		params.put("shareType", strShareType);
		params.put("groupID", arrGroupID);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		//timezone 적용 날짜변환
		if(params.get("startDate") != null && !params.get("startDate").equals("")){
			params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if(params.get("endDate") != null && !params.get("endDate").equals("")){
			params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
		}
		
		CoviMap listData = bizCardListService.selectBizCardAllList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardPersonList.do", method = {RequestMethod.POST,RequestMethod.GET})
	public @ResponseBody CoviMap getBizCardPersonList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
		String strGroupIDs = StringUtil.replaceNull(request.getParameter("groupIDs"), "");
		String[] arrGroupID = null;
		
		if(strGroupIDs.isEmpty()){
			strGroupIDs = null;
			arrGroupID = null;
		} else{
			arrGroupID = strGroupIDs.split(";");
		}
		
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("tabFilter", strTabFilter);
		params.put("searchWord", ComUtils.RemoveSQLInjection(strSearchWord, 100));
		params.put("searchType", strSearchType);
		params.put("shareType", strShareType);
		params.put("groupID", arrGroupID);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		//timezone 적용 날짜변환
		if(params.get("startDate") != null && !params.get("startDate").equals("")){
			params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if(params.get("endDate") != null && !params.get("endDate").equals("")){
			params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
		}
		
		CoviMap listData = bizCardListService.selectBizCardPersonList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardCompanyList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardCompanyList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters		
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strGroupIDs = request.getParameter("groupIDs");
		String[] arrGroupID = null;

		if(strGroupIDs != null) { 
			if(strGroupIDs.isEmpty()){
				strGroupIDs = null;
				arrGroupID = null;
			} else{
				arrGroupID = strGroupIDs.split(";");
			}
		}
				
		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("tabFilter", strTabFilter);
		params.put("searchWord", ComUtils.RemoveSQLInjection(strSearchWord, 100));
		params.put("searchType", strSearchType);
		params.put("groupID", arrGroupID);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
				
		if(params.get("startDate") != null && !params.get("startDate").equals("")){
			params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if(params.get("endDate") != null && !params.get("endDate").equals("")){
			params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
		}
		
		CoviMap listData = bizCardListService.selectBizCardCompanyList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardGroupList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardGroupList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters		
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
		String strSearchWord = request.getParameter("searchWord");
		String strSearchType = request.getParameter("searchType");

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "";
		String strSortDirection = "";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		params.put("shareType", strShareType);
		params.put("searchWord", ComUtils.RemoveSQLInjection(strSearchWord, 100));
		params.put("searchType", strSearchType);
		
		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		
		CoviMap listData = bizCardListService.selectBizCardGroupList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap();
		
		returnObj.put("page", listData.get("page"));
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	@RequestMapping(value="getCallFuncDivList.do", method=RequestMethod.GET)
	public @ResponseBody CoviMap getWorkReportDiv() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap listObj = bizCardListService.getCallFuncDivList(new CoviMap());
		returnObj.put("list", listObj.get("list"));
		return returnObj;
	}
	
	@RequestMapping(value = "relocateBizCardList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap relocateBizCardList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
						
			String   BizCardIDTemp		= null;
			String[] BizCardID		= null;
			String Mode			= null;
			String GroupID	= null;
			String GroupName = null;
			String TypeCode = null;

			BizCardIDTemp		= StringUtil.replaceNull(request.getParameter("BizCardID"), "");
			BizCardID			= BizCardIDTemp.split(",");
			Mode		= request.getParameter("Mode");
			GroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			GroupName = request.getParameter("GroupName");
			TypeCode = request.getParameter("TypeCode");
			GroupID = GroupID.equals("none") ? null : GroupID;
			
			if(GroupID != null && !"".equals(GroupID) && GroupID.equals("new")) {
				CoviMap paramGroup = new CoviMap();
				
				paramGroup.put("ShareType", TypeCode);
				paramGroup.put("GroupName", GroupName);
				paramGroup.put("GroupPriorityOrder", "0");
				paramGroup.put("UR_Code", strUR_Code);
				paramGroup.put("DN_Code", strDN_Code);
				paramGroup.put("GR_Code", strGR_Code);
				
				CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
				if(!"OK".equals(obj.getString("result"))) {
					return obj;
				}
				GroupID = paramGroup.getString("GroupID");
			}
			
			CoviMap params = new CoviMap();

			params.put("BizCardID",BizCardID);
			params.put("Mode",Mode);
			params.put("GroupID", GroupID);
			params.put("TypeCode", TypeCode);
			params.put("UR_Code", strUR_Code);
			params.put("UR_Name", strUR_Name);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			
			int result;
			result = bizCardListService.relocateBizCardList(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "deleteBizCardAllList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteBizCardAllList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			String   BizCardIDTemp			= null;
			String[] BizCardID				= null;
			String   BizCardTypeCodeTemp	= null;
			String[] BizCardTypeCode		= null;
			String TypeCode					= null;
			
			BizCardIDTemp		= StringUtil.replaceNull(request.getParameter("BizCardID"), "");
			BizCardID			= BizCardIDTemp.split(",");
			BizCardTypeCodeTemp	= StringUtil.replaceNull(request.getParameter("BizCardTypeCode"), "");
			BizCardTypeCode		= BizCardTypeCodeTemp.split(",");
			TypeCode			= request.getParameter("TypeCode");
			
			int result = 0;
			
			CoviMap params = new CoviMap();
			for(int i=0;i<BizCardID.length;i++){
				params.put("TypeCode",TypeCode);
				if(BizCardTypeCode[i].equalsIgnoreCase("BIZCARD")){
					params.put("BizCardID",BizCardID[i]);
					result = result + bizCardListService.deleteOne(params);
				}else{
					params.put("GroupID",BizCardID[i]);
					result = result + bizCardListService.deleteGroupOne(params);					
				}
				params = new CoviMap();
			}
			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "deleteBizCardList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteBizCardList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {
			String   BizCardIDTemp		= null;
			String[] BizCardID		= null;
			String TypeCode			= null;

			BizCardIDTemp		= StringUtil.replaceNull(request.getParameter("BizCardID"), "");
			BizCardID			= BizCardIDTemp.split(",");
			TypeCode		= request.getParameter("TypeCode");

			CoviMap params = new CoviMap();

			params.put("BizCardID",BizCardID);
			params.put("TypeCode",TypeCode);

			int result;

			result = bizCardListService.delete(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "deleteBizCardGroupList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteBizCardGroupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {

			String   BizCardIDTemp		= null;
			String[] BizCardID		= null;
			String TypeCode			= null;

			BizCardIDTemp		= StringUtil.replaceNull(request.getParameter("BizCardID"), "");
			BizCardID			= BizCardIDTemp.split(",");
			TypeCode		= request.getParameter("TypeCode");

			CoviMap params = new CoviMap();

			params.put("GroupID",BizCardID);
			params.put("TypeCode",TypeCode);

			int result;

			result = bizCardListService.deleteGroup(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "changeFavoriteStatus.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap changeFavoriteStatus(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {
			String BizCardID	= request.getParameter("BizCardID");
			String UR_Code	= SessionHelper.getSession("UR_Code"); 
			String StatusToBe = StringUtil.replaceNull(request.getParameter("StatusToBe"), "N");

			CoviMap params = new CoviMap();

			params.put("BizCardID",BizCardID);
			params.put("UR_Code",UR_Code);

			int result;

			if(StatusToBe.equalsIgnoreCase("Y"))
				result = bizCardListService.insertIntoFavoriteList(params);
			else
				result = bizCardListService.deleteFromFavoriteList(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	// 엑셀 다운로드
	@RequestMapping(value = "bizCardListExcelDownload.do" , method = RequestMethod.GET)
	public ModelAndView bizCardListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		try {
			String UR_Code	= SessionHelper.getSession("UR_Code"); 
			String GR_Code	= SessionHelper.getSession("GR_Code"); 
			String DN_Code	= SessionHelper.getSession("DN_Code"); 
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String tabFilter = request.getParameter("tabFilter");
			String shareType = request.getParameter("shareType");
			String groupID = request.getParameter("groupID");
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			String[] arrGroupID = null;
			
			if(groupID != null) { 
				if(groupID.isEmpty()){
					groupID = null;
					arrGroupID = null;
				} else{
					arrGroupID = groupID.split(";");
				}
			}

			String[] headerNames = headerName.split("[|]");
			
			CoviMap params = new CoviMap();
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("UR_Code",UR_Code);
			params.put("GR_Code",GR_Code);
			params.put("DN_Code",DN_Code);
			params.put("tabFilter", tabFilter);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("searchType", searchType);
			params.put("shareType", shareType);
			params.put("groupID", arrGroupID);
			
			resultList = bizCardListService.selectBizCardExcelList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "BizCard");
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}
	
	@RequestMapping(value="AdjustBizCardLocation.do", method=RequestMethod.GET)
	public ModelAndView adjustBizCardLocation(HttpServletRequest request, HttpServletResponse response) throws Exception{
		String strShareType = request.getParameter("sharetype");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		
		String returnUrl = "user/bizcard/AdjustBizCardLocation";
		
		ModelAndView mav = new ModelAndView(returnUrl);
		
		mav.addObject("ShareType", strShareType);
		mav.addObject("UR_Code", strUR_Code);
		
		return mav;
	}
	@RequestMapping(value="getBizCardGroupMemberList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardGroupMemberList(HttpServletRequest request,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "groupID", required = false) String strGroupID,
			@RequestParam(value = "pageNo", required = false , defaultValue = "1") int pageNo,
			@RequestParam(value = "pageSize", required = false , defaultValue = "1000000" ) int pageSize) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		try {
			String sortBy = request.getParameter("sortBy");
			
			String sortKey = ( sortBy != null )? sortBy.split(" ")[0] : "Name";
			String sortDirec = ( sortBy != null )? sortBy.split(" ")[1] : "ASC";
			String strHasEmail = StringUtil.replaceNull(request.getParameter("hasEmail"), "");
			
			CoviMap params = new CoviMap();
			
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("groupIDs", strGroupID.split(","));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("hasEmail",strHasEmail);
			
			CoviMap listData = bizCardListService.selectBizCardGroupMemberList(params);

			returnObj.put("page", listData.get("page")) ;
			returnObj.put("list", listData.get("listMember"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회 성공");
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	@RequestMapping(value="getBizCardOrgMapList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardOrgMapList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap(); 
		try {
			// Parameters
			String strItemType = request.getParameter("itemType");
			String strPublicUserCode = request.getParameter("publicUserCode");
			String strSearchText = StringUtil.replaceNull(request.getParameter("searchText"), "");
			String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
			String strHasEmail = StringUtil.replaceNull(request.getParameter("hasEmail"), "");
			
			// 검색어 인젝션 공격 방어 특수문자 검증
			//Pattern specialChars = Pattern.compile("['\"\\-#()@;=*/*]");
			Pattern specialChars = Pattern.compile("'");
			if(strSearchText != null){
				strSearchText = specialChars.matcher(strSearchText).replaceAll("''");
			}
					
			// DB Parameter Setting
			CoviMap params = new CoviMap();
			//params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("DN_Code", SessionHelper.getSession("DN_Code"));
			params.put("GR_Code", SessionHelper.getSession("GR_Code"));
			params.put("UR_Code", strPublicUserCode);
			params.put("searchText", ComUtils.RemoveSQLInjection(strSearchText, 100));
			params.put("shareType", strShareType);
			params.put("itemType", strItemType);
			params.put("hasEmail", strHasEmail);
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			CoviMap listData = bizCardListService.selectBizCardOrgMapList(params);
			
			returnObj.put("page", listData.get("page"));
			returnObj.put("list", listData.get("list"));
			returnObj.put("listMember", listData.get("listMember"));
			returnObj.put("result", "ok");
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회 성공");
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
}
