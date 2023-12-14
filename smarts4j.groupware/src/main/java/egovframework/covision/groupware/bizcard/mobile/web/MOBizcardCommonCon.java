package egovframework.covision.groupware.bizcard.mobile.web;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartRequest;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;
import egovframework.covision.groupware.bizcard.user.service.BizCardListService;
import egovframework.covision.groupware.bizcard.user.service.BizCardManageService;

@Controller
@RequestMapping("/mobile/bizcard")
public class MOBizcardCommonCon {
	private Logger LOGGER = LogManager.getLogger(MOBizcardCommonCon.class);

	@Autowired
	private BizCardManageService bizCardManageService;

	@Autowired
	private BizCardListService bizCardListService;

	@Autowired
	private BizCardGroupManageService bizCardGroupManageService;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	static AwsS3 awsS3 = AwsS3.getInstance();

	@RequestMapping(value = "getBizCardAllList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBizCardAllList(HttpServletRequest request,
			@RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
		String strGroupIDs = StringUtil.replaceNull(request.getParameter("groupIDs"), "");
		String[] arrGroupID = null;

		if (strGroupIDs.isEmpty()) {
			strGroupIDs = null;
			arrGroupID = null;
		} else {
			arrGroupID = strGroupIDs.split(";");
		}

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "ModifyDate";
		String strSortDirection = "ASC";

		if (strSort != null && !strSort.isEmpty()) {
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

		// timezone 적용 날짜변환
		if (params.get("startDate") != null && !params.get("startDate").equals("")) {
			params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if (params.get("endDate") != null && !params.get("endDate").equals("")) {
			params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
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

	// 즐겨찾는 연락처 목록 조회
	@RequestMapping(value = "/getBizCardFavoriteList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardFavoriteList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strpageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "");
		String strpageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "");

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "ModifyDate";
		String strSortDirection = "ASC";

		if (strSort != null && !strSort.isEmpty()) {
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
		params.put("pageNo", strpageNo);
		params.put("pageSize", strpageSize);

		// timezone 적용 날짜변환
		if (params.get("startDate") != null && !params.get("startDate").equals("")) {
			params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if (params.get("endDate") != null && !params.get("endDate").equals("")) {
			params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
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

	// 전체/개인/부서/회사 연락처 목록 조회
	@RequestMapping(value = "/getBizCardPersonList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardPersonList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");
		String strGroupIDs = StringUtil.replaceNull(request.getParameter("groupIDs"), "");
		String[] arrGroupID = null;

		if (strGroupIDs.isEmpty()) {
			strGroupIDs = null;
			arrGroupID = null;
		} else {
			arrGroupID = strGroupIDs.split(";");
		}

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "ModifyDate";
		String strSortDirection = "DESC";

		if (strSort != null && !strSort.isEmpty()) {
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

		// timezone 적용 날짜변환
		if (params.get("startDate") != null && !params.get("startDate").equals("")) {
			params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if (params.get("endDate") != null && !params.get("endDate").equals("")) {
			params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
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

	// 업체 연락처 목록 조회
	@RequestMapping(value = "/getBizCardCompanyList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBizCardCompanyList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strStartDate = StringUtil.replaceNull(request.getParameter("startDate"), "");
		String strEndDate = StringUtil.replaceNull(request.getParameter("endDate"), "");
		String strTabFilter = StringUtil.replaceNull(request.getParameter("tabFilter"), "");
		String strSearchWord = StringUtil.replaceNull(request.getParameter("searchWord"), "");
		String strSearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strGroupIDs = StringUtil.replaceNull(request.getParameter("groupIDs"), "");
		String[] arrGroupID = null;

		if (strGroupIDs != null) {
			if (strGroupIDs.isEmpty()) {
				strGroupIDs = null;
				arrGroupID = null;
			} else {
				arrGroupID = strGroupIDs.split(";");
			}
		}

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "ModifyDate";
		String strSortDirection = "DESC";

		if (strSort != null && !strSort.isEmpty()) {
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

		// timezone 적용 날짜변환
		if (params.get("startDate") != null && !params.get("startDate").equals("")) {
			params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
		}
		if (params.get("endDate") != null && !params.get("endDate").equals("")) {
			params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
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

	@RequestMapping(value = "/changeFavoriteStatus.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap changeFavoriteStatus(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnData = new CoviMap();

		try {
			String BizCardID = request.getParameter("BizCardID");
			String UR_Code = SessionHelper.getSession("UR_Code");
			String StatusToBe = StringUtil.replaceNull(request.getParameter("StatusToBe"), "");

			CoviMap params = new CoviMap();

			params.put("BizCardID", BizCardID);
			params.put("UR_Code", UR_Code);

			int result;

			if (StatusToBe.equalsIgnoreCase("Y"))
				result = bizCardListService.insertIntoFavoriteList(params);
			else
				result = bizCardListService.deleteFromFavoriteList(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	// 그룹 목록 가져오기
	@RequestMapping(value = "/getBizCardGroupList.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizCardGroupList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("shareType"), "");

		// 정렬
		String strSort = request.getParameter("sortBy");

		String strSortColumn = "OrderNo";
		String strSortDirection = "ASC";

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}

		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageOffset", null);
		params.put("pageSize", null);

		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		params.put("GR_Code", SessionHelper.getSession("GR_Code"));
		params.put("DN_Code", SessionHelper.getSession("DN_Code"));
		params.put("shareType", strShareType);

		CoviMap listData = bizCardListService.selectBizCardGroupList(params);

		// 결과 반환
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();

		// 총 갯수
		int listCount = listData.getInt("cnt");

		// 총 페이지 갯수
		page.put("listCount", listCount);

		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");

		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");

		return returnObj;
	}

	// 그룹 목록 가져오기
	@RequestMapping(value = "/getGroupList.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getGroupList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strUR_Code = SessionHelper.getSession("UR_Code");
		String strGR_Code = SessionHelper.getSession("GR_Code");
		String strDN_Code = SessionHelper.getSession("DN_Code");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		if (strShareType != null && !strShareType.isEmpty() && (strShareType.equals("P") || strShareType.equals("C"))) {
			params.put("UR_Code", strUR_Code);
		} else if (strShareType != null && strShareType.equals("D")) {
			params.put("GR_Code", strGR_Code);
		} else if (strShareType != null && strShareType.equals("U")) {
			params.put("DN_Code", strDN_Code);
		}

		CoviMap listData = bizCardGroupManageService.selectGroupList(params);

		// 결과 반환
		CoviMap returnObj = new CoviMap();

		returnObj.put("status", Return.SUCCESS);
		returnObj.put("list", listData.get("list"));

		return returnObj;
	}

	// 그룹정보 조회
	@RequestMapping(value = "/getBizcardGroup.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizcardGroup(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strShareType = StringUtil.replaceNull(request.getParameter("ShareType"), "");
		String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
		
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("ShareType", strShareType);
		params.put("GroupID", strGroupID);

		CoviMap listData = bizCardGroupManageService.selectBizcardGroup(params);

		// 결과 반환
		CoviMap returnObj = new CoviMap();

		returnObj.put("list", listData.get("list"));
		returnObj.put("bizcardlist", listData.get("bizcardlist"));

		return returnObj;
	}

	// TODO: return 방식
	// 명함 정보 조회
	@RequestMapping(value = "/getBizCardPerson.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizCardPerson(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		// Parameters
		String strBizCardID = request.getParameter("BizCardID");

		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);

		CoviMap returnObj = bizCardManageService.selectBizCardPerson(params);

		return returnObj;
	}

	// TODO: return 방식
	// 업체 정보 조회
	@RequestMapping(value = "/getBizCardCompany.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizCardCompany(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");

		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);

		CoviMap returnObj = bizCardManageService.selectBizCardCompany(params);

		return returnObj;
	}

	// TODO: return 방식
	// 명함/업체에 대한 연락처 정보 조회
	@RequestMapping(value = "/getBizCardPhone.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizCardPhone(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		String strTypeCode = request.getParameter("TypeCode");

		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		params.put("TypeCode", strTypeCode);

		CoviMap returnObj = bizCardManageService.selectBizCardPhone(params);

		return returnObj;
	}

	// TODO: return 방식
	// 명함/업체에 대한 메일 정보 조회
	@RequestMapping(value = "/getBizCardEmail.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getBizCardEmail(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// Parameters
		String strBizCardID = request.getParameter("BizCardID");
		String strTypeCode = request.getParameter("TypeCode");

		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("BizCardID", strBizCardID);
		params.put("TypeCode", strTypeCode);

		CoviMap returnObj = bizCardManageService.selectBizCardEmail(params);

		return returnObj;
	}

	// TODO: return 방식
	// 명함 관리(등록)
	@RequestMapping(value = "/RegistBizCardPerson.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap registBizCardPerson(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		CoviMap returnObj = new CoviMap();

		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strShareType = request.getParameter("ShareType");
			String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			String strGroupName = StringUtil.replaceNull(request.getParameter("GroupName"), "");
			String strName = request.getParameter("Name");
			String strMessengerID = request.getParameter("MessengerID");
			String strCompanyID = request.getParameter("CompanyID");
			String strCompanyName = request.getParameter("CompanyName");
			String strJobTitle = request.getParameter("JobTitle");
			String strDeptName = request.getParameter("DeptName");
			String strMemo = request.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(request.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(request.getParameter("PhoneType"), "");
			String strPhoneNumber = StringUtil.replaceNull(request.getParameter("PhoneNumber"), "");
			String strEmail = StringUtil.replaceNull(request.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(request.getParameter("AnniversaryText"), "");
			String strBizCardID = "";
			
			// 값이 비어있을경우 NULL 값으로 전달	
			strGroupID = strGroupID.isEmpty() ? null : strGroupID; 
			strGroupName = strGroupName.isEmpty() ? null : strGroupName;

			if (strGroupID != null && !strGroupID.isEmpty()) {
				if (strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();

					paramGroup.put("ShareType", strShareType);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);

					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if (!obj.getString("result").equals("OK")) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}

			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("UR_Name", strUR_Name);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			params.put("ShareType", strShareType);
			params.put("GroupID", strGroupID);
			params.put("Name", strName);
			params.put("MessengerID", strMessengerID);
			params.put("CompanyID", strCompanyID);
			params.put("CompanyName", strCompanyName);
			params.put("JobTitle", strJobTitle);
			params.put("DeptName", strDeptName);
			params.put("Memo", strMemo);
			params.put("ImagePath", strImagePath);

			returnObj = bizCardManageService.insertBizCardPerson(params);
			if (!returnObj.getString("result").equals("OK")) {
				return returnObj;
			}
			strBizCardID = params.getString("BizCardID");

			if (!strImagePath.equals("")) {
				MultipartFile FileInfo = ((MultipartRequest) request).getFile("FileInfo");

				String domainName = "";
				ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

				if (ClientInfoHelper.isMobile(request)) {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
				} else {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				}

				String OsType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");

				String filePath;
				String savePath;
				String rootPath;
				String companyCode = SessionHelper.getSession("DN_Code");
				String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
				if (OsType.equals("WINDOWS"))
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
				else
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");

				filePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); /// GWStorage/Groupware/BizCard/
				savePath = rootPath + backStorage
						+ RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));

				CoviMap fileParam = new CoviMap();

				if (FileInfo != null) {
					long FileSize = FileInfo.getSize();

					if (FileSize > 0) {
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						// 폴더가없을 시 생성
						if (!realUploadDir.exists()) {
							if (!realUploadDir.mkdirs()) {
								LOGGER.debug("Fail to make directory : " + realUploadDir.getAbsolutePath());
							}
						}

						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						filePath += saveFileName;
						savePath += saveFileName; // 저장 될 파일 경로

						// 한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
						FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						fileParam.put("ImagePath", filePath);
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);

				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strPhoneType.equals("") && strPhoneNumber != null && !strPhoneNumber.equals("")) {
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();

				for (int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();

					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					
					if(!StringUtil.equals(phoneMap.get("PhoneType").toString(), "D")) {
						phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);
					} else {
						String[] directPhoneArr = strPhoneNumber.split(";")[i].split("\\)");
						
						if(directPhoneArr.length > 1) {
							String phoneName = strPhoneNumber.split(";")[i].split("\\)")[0].replaceAll("\\(", "");
							String phoneNumber = strPhoneNumber.split(";")[i].split("\\)")[1];
							
							phoneMap.put("PhoneName", phoneName);
							phoneMap.put("PhoneNumber", StringUtil.trim(phoneNumber));
						} else {
							phoneMap.put("PhoneName", DicHelper.getDic("lbl_DirectPhone"));
							phoneMap.put("PhoneNumber", directPhoneArr[0]);
						}
					}

					phoneList.add(phoneMap);
				}

				CoviMap obj = bizCardManageService.insertBizCardPhone(phoneList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strEmail.equals("")) {
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();

				for (int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();

					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);

					emailList.add(emailMap);
				}

				CoviMap obj = bizCardManageService.insertBizCardEmail(emailList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strAnniversaryText.equals("")) {
				CoviMap anniversaryMap = new CoviMap();

				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);

				CoviMap obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}

	// TODO: return 방식
	// 명함 관리(수정)
	@RequestMapping(value = "/ModifyBizCardPerson.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap modifyBizCardPerson(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		CoviMap returnObj = new CoviMap();

		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strShareType = request.getParameter("ShareType");
			String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			String strGroupName = StringUtil.replaceNull(request.getParameter("GroupName"), "");
			String strName = request.getParameter("Name");
			String strMessengerID = request.getParameter("MessengerID");
			String strCompanyID = request.getParameter("CompanyID");
			String strCompanyName = request.getParameter("CompanyName");
			String strJobTitle = request.getParameter("JobTitle");
			String strDeptName = request.getParameter("DeptName");
			String strMemo = request.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(request.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(request.getParameter("PhoneType"), "");
			String strPhoneNumber = StringUtil.replaceNull(request.getParameter("PhoneNumber"), "");
			String strEmail = StringUtil.replaceNull(request.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(request.getParameter("AnniversaryText"), "");
			String strBizCardID = request.getParameter("BizCardID");

			// 값이 비어있을경우 NULL 값으로 전달
			strGroupID = strGroupID.isEmpty() ? null : strGroupID;
			strGroupName = strGroupName.isEmpty() ? null : strGroupName;

			if (strGroupID != null) {
				if (strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();

					paramGroup.put("ShareType", strShareType);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);

					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if (!obj.getString("result").equals("OK")) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}

			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("ShareType", strShareType);
			params.put("GroupID", strGroupID);
			params.put("Name", strName);
			params.put("MessengerID", strMessengerID);
			params.put("CompanyID", strCompanyID);
			params.put("CompanyName", strCompanyName);
			params.put("JobTitle", strJobTitle);
			params.put("DeptName", strDeptName);
			params.put("Memo", strMemo);
			params.put("BizCardID", strBizCardID);

			returnObj = bizCardManageService.updateBizCardPerson(params);
			if (!returnObj.getString("result").equals("OK")) {
				return returnObj;
			}

			if (!strImagePath.equals("")) {
				MultipartFile FileInfo = ((MultipartRequest) request).getFile("FileInfo");

				String domainName = "";

				ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

				if (ClientInfoHelper.isMobile(request)) {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
				} else {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				}

				String filePath;
				String rootPath;
				String savePath;
				String companyCode = SessionHelper.getSession("DN_Code");
				String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
				rootPath = FileUtil.getBackPath(strDN_Code);
				filePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); /// GWStorage/Groupware/BizCard/
				savePath = rootPath + backStorage
						+ RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));

				CoviMap fileParam = new CoviMap();

				if (FileInfo != null) {
					long FileSize = FileInfo.getSize();

					if (FileSize > 0) {
						if (!awsS3.getS3Active(strDN_Code)) {
							File realUploadDir = new File(FileUtil.checkTraversalCharacter(filePath));
							// 폴더가없을 시 생성
							if (!realUploadDir.exists()) {
								if (!realUploadDir.mkdirs()) {
									LOGGER.debug("Fail to make directory : " + realUploadDir.getAbsolutePath());
								}
							}
						}

						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						filePath += saveFileName;
						savePath += saveFileName; // 저장 될 파일 경로

						// 한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
						if (savePath.contains("//")) {
							savePath = savePath.replaceAll("//", "/");
						}
						if (awsS3.getS3Active(strDN_Code)) {
							awsS3.upload(FileInfo.getInputStream(), savePath, FileInfo.getContentType(),
									FileInfo.getSize());
						} else {
							FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						}
						fileParam.put("ImagePath", filePath);
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);

				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			CoviMap phoneParams = new CoviMap();

			phoneParams.put("BizCardID", strBizCardID);
			phoneParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardPhone(phoneParams);

			if (!strPhoneType.equals("") && !strPhoneNumber.equals("")) {
				CoviMap obj = new CoviMap();
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();

				for (int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();

					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					
					if(!StringUtil.equals(phoneMap.get("PhoneType").toString(), "D")) {
						phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);
					} else {
						String[] directPhoneArr = strPhoneNumber.split(";")[i].split("\\)");
						
						if(directPhoneArr.length > 1) {
							String phoneName = strPhoneNumber.split(";")[i].split("\\)")[0].replaceAll("\\(", "");
							String phoneNumber = strPhoneNumber.split(";")[i].split("\\)")[1];
							
							phoneMap.put("PhoneName", phoneName);
							phoneMap.put("PhoneNumber", StringUtil.trim(phoneNumber));
						} else {
							phoneMap.put("PhoneName", DicHelper.getDic("lbl_DirectPhone"));
							phoneMap.put("PhoneNumber", directPhoneArr[0]);
						}
					}

					phoneList.add(phoneMap);
				}

				obj = bizCardManageService.insertBizCardPhone(phoneList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			CoviMap emailParams = new CoviMap();

			emailParams.put("BizCardID", strBizCardID);
			emailParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardEmail(emailParams);

			if (!strEmail.equals("")) {

				CoviMap obj = new CoviMap();
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();

				for (int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();

					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);

					emailList.add(emailMap);
				}

				obj = bizCardManageService.insertBizCardEmail(emailList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			CoviMap anniParams = new CoviMap();

			anniParams.put("BizCardID", strBizCardID);
			anniParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardAnniversary(anniParams);

			if (!strAnniversaryText.equals("")) {

				CoviMap obj = new CoviMap();
				CoviMap anniversaryMap = new CoviMap();

				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);

				obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}

	// 업체 관리(등록)
	@RequestMapping(value = "/RegistBizCardCompany.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap registBizCardCompany(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		CoviMap returnObj = new CoviMap();

		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			String strGroupName = StringUtil.replaceNull(request.getParameter("GroupName"), "");
			String strComName = request.getParameter("ComName");
			String strComRepName = request.getParameter("ComRepName");
			String strComWebsite = request.getParameter("ComWebsite");
			String strComZipCode = request.getParameter("ComZipCode");
			String strComAddress = request.getParameter("ComAddress");
			String strMemo = request.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(request.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(request.getParameter("PhoneType"), "");
			String strPhoneNumber = StringUtil.replaceNull(request.getParameter("PhoneNumber"), "");
			String strEmail = StringUtil.replaceNull(request.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(request.getParameter("AnniversaryText"), "");
			String strBizCardID = "";

			if (strGroupID != null) {
				if (strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();

					paramGroup.put("ShareType", strTypeCode);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);

					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if (!obj.getString("result").equals("OK")) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}

			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("UR_Name", strUR_Name);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);
			params.put("GroupID", strGroupID);
			params.put("ComName", strComName);
			params.put("ComRepName", strComRepName);
			params.put("ComWebsite", strComWebsite);
			params.put("ComZipcode", strComZipCode);
			params.put("ComAddress", strComAddress);
			params.put("Memo", strMemo);
			params.put("ImagePath", strImagePath);

			returnObj = bizCardManageService.insertBizCardCompany(params);
			if (!returnObj.getString("result").equals("OK")) {
				return returnObj;
			}
			strBizCardID = params.getString("BizCardID");

			if (!strImagePath.equals("")) {
				MultipartFile FileInfo = ((MultipartRequest) request).getFile("FileInfo");

				String domainName = "";

				ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

				if (ClientInfoHelper.isMobile(request)) {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
				} else {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				}

				String OsType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");

				String filePath;
				String rootPath;
				String savePath;
				String companyCode = SessionHelper.getSession("DN_Code");
				String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
				if (OsType.equals("WINDOWS"))
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
				else
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");

				filePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); /// GWStorage/Groupware/BizCard/
				savePath = rootPath + backStorage
						+ RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));

				CoviMap fileParam = new CoviMap();

				if (FileInfo != null) {
					long FileSize = FileInfo.getSize();

					if (FileSize > 0) {
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						// 폴더가없을 시 생성
						if (!realUploadDir.exists()) {
							if (!realUploadDir.mkdirs()) {
								LOGGER.debug("Fail to make directory : " + realUploadDir.getAbsolutePath());
							}
						}

						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						filePath += saveFileName;
						savePath += saveFileName; // 저장 될 파일 경로

						// 한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
						FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						fileParam.put("ImagePath", filePath);
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);

				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strPhoneType.equals("") && !strPhoneNumber.equals("")) {
				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();

				for (int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();

					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);

					phoneList.add(phoneMap);
				}

				CoviMap obj = bizCardManageService.insertBizCardPhone(phoneList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strEmail.equals("")) {
				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();

				for (int i = 0; i < strPhoneType.split(";").length; i++) {
					emailMap = new CoviMap();

					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);

					emailList.add(emailMap);
				}

				CoviMap obj = bizCardManageService.insertBizCardEmail(emailList);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			if (!strAnniversaryText.equals("")) {
				CoviMap anniversaryMap = new CoviMap();

				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);

				CoviMap obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}

	// 명함 관리(수정)
	@RequestMapping(value = "/ModifyBizCardCompany.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap modifyBizCardCompany(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		CoviMap returnObj = new CoviMap();

		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strUR_Name = SessionHelper.getSession("UR_Name");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strGroupID = StringUtil.replaceNull(request.getParameter("GroupID"), "");
			String strGroupName = StringUtil.replaceNull(request.getParameter("GroupName"), "");
			String strComName = request.getParameter("ComName");
			String strComRepName = request.getParameter("ComRepName");
			String strComWebsite = request.getParameter("ComWebsite");
			String strComZipCode = request.getParameter("ComZipCode");
			String strComAddress = request.getParameter("ComAddress");
			String strMemo = request.getParameter("Memo");
			String strImagePath = StringUtil.replaceNull(request.getParameter("ImagePath"), "");
			String strPhoneType = StringUtil.replaceNull(request.getParameter("PhoneType"), "");
			String strPhoneNumber = StringUtil.replaceNull(request.getParameter("PhoneNumber"), "");
			String strEmail = StringUtil.replaceNull(request.getParameter("Email"), "");
			String strAnniversaryText = StringUtil.replaceNull(request.getParameter("AnniversaryText"), "");
			String strBizCardID = request.getParameter("BizCardID");

			if (strGroupID != null) {
				if (strGroupID.equals("new")) {
					CoviMap paramGroup = new CoviMap();

					paramGroup.put("ShareType", strTypeCode);
					paramGroup.put("GroupName", strGroupName);
					paramGroup.put("GroupPriorityOrder", "0");
					paramGroup.put("UR_Code", strUR_Code);
					paramGroup.put("DN_Code", strDN_Code);
					paramGroup.put("GR_Code", strGR_Code);

					CoviMap obj = bizCardGroupManageService.insertGroup(paramGroup);
					if (!obj.getString("result").equals("OK")) {
						return obj;
					}
					strGroupID = paramGroup.getString("GroupID");
				}
			}

			CoviMap params = new CoviMap();

			params.put("UR_Code", strUR_Code);
			params.put("GroupID", strGroupID);
			params.put("ComName", strComName);
			params.put("ComRepName", strComRepName);
			params.put("ComWebsite", strComWebsite);
			params.put("ComZipcode", strComZipCode);
			params.put("ComAddress", strComAddress);
			params.put("Memo", strMemo);
			params.put("BizCardID", strBizCardID);

			returnObj = bizCardManageService.updateBizCardCompany(params);
			if (!returnObj.getString("result").equals("OK")) {
				return returnObj;
			}

			if (!strImagePath.equals("")) {
				MultipartFile FileInfo = ((MultipartRequest) request).getFile("FileInfo");

				String domainName = "";

				ClientInfoHelper clientInfoHelper = new ClientInfoHelper();

				if (ClientInfoHelper.isMobile(request)) {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path");
				} else {
					domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				}

				String OsType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");

				String filePath;
				String rootPath;
				String savePath;
				String companyCode = SessionHelper.getSession("DN_Code");
				String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
				if (OsType.equals("WINDOWS"))
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
				else
					rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");

				filePath = RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID")); /// GWStorage/Groupware/BizCard/
				savePath = rootPath + backStorage
						+ RedisDataUtil.getBaseConfig("BizCardImage_SavePath", SessionHelper.getSession("DN_ID"));

				CoviMap fileParam = new CoviMap();

				if (FileInfo != null) {
					long FileSize = FileInfo.getSize();

					if (FileSize > 0) {
						File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
						// 폴더가 없을 시 생성
						if (!realUploadDir.exists()) {
							if (!realUploadDir.mkdirs()) {
								LOGGER.debug("Fail to make directory : " + realUploadDir.getAbsolutePath());
							}
						}

						// 파일 중복명 처리
						String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");

						// 본래 파일명
						String originalfileName = FileInfo.getOriginalFilename();

						String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);

						// 저장되는 파일 이름
						String saveFileName = "bizcard_" + genId + "." + FilenameUtils.getExtension(originalfileName);

						filePath += saveFileName;
						savePath += saveFileName; // 저장 될 파일 경로

						// 한글명저장
						savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), "UTF-8");
						FileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
						fileParam.put("ImagePath", filePath);
					} else {
						fileParam.put("ImagePath", "");
					}
				} else {
					fileParam.put("ImagePath", "");
				}
				fileParam.put("BizCardID", strBizCardID);
				fileParam.put("TypeCode", strTypeCode);

				CoviMap obj = bizCardManageService.updateBizCardImagePath(fileParam);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

			CoviMap phoneParams = new CoviMap();
			CoviMap objPhone = new CoviMap();
			phoneParams.put("BizCardID", strBizCardID);
			phoneParams.put("TypeCode", strTypeCode);
			bizCardManageService.deleteBizCardPhone(phoneParams);

			if (!strPhoneType.equals("") && !strPhoneNumber.equals("")) {

				CoviMap phoneMap;
				List<CoviMap> phoneList = new ArrayList<CoviMap>();

				for (int i = 0; i < strPhoneType.split(";").length; i++) {
					phoneMap = new CoviMap();

					phoneMap.put("BizCardID", strBizCardID);
					phoneMap.put("TypeCode", strTypeCode);
					phoneMap.put("PhoneType", strPhoneType.split(";")[i]);
					phoneMap.put("PhoneNumber", strPhoneNumber.split(";")[i]);

					phoneList.add(phoneMap);
				}

				objPhone = bizCardManageService.insertBizCardPhone(phoneList);
				if (!objPhone.getString("result").equals("OK")) {
					return objPhone;
				}
			}

			CoviMap emailParams = new CoviMap();
			CoviMap objEmail = new CoviMap();
			emailParams.put("BizCardID", strBizCardID);
			emailParams.put("TypeCode", strTypeCode);
			bizCardManageService.deleteBizCardEmail(emailParams);

			if (!strEmail.equals("")) {

				CoviMap emailMap;
				List<CoviMap> emailList = new ArrayList<CoviMap>();

				for (int i = 0; i < strEmail.split(";").length; i++) {
					emailMap = new CoviMap();

					emailMap.put("BizCardID", strBizCardID);
					emailMap.put("TypeCode", strTypeCode);
					emailMap.put("Email", strEmail.split(";")[i]);

					emailList.add(emailMap);
				}

				objEmail = bizCardManageService.insertBizCardEmail(emailList);
				if (!objEmail.getString("result").equals("OK")) {
					return objEmail;
				}
			}

			if (!strAnniversaryText.equals("")) {
				CoviMap anniParams = new CoviMap();
				CoviMap obj = new CoviMap();

				anniParams.put("BizCardID", strBizCardID);
				anniParams.put("TypeCode", strTypeCode);

				bizCardManageService.deleteBizCardAnniversary(anniParams);

				CoviMap anniversaryMap = new CoviMap();

				anniversaryMap.put("BizCardID", strBizCardID);
				anniversaryMap.put("TypeCode", strTypeCode);
				anniversaryMap.put("AnniversaryText", strAnniversaryText);

				obj = bizCardManageService.insertBizCardAnniversary(anniversaryMap);
				if (!obj.getString("result").equals("OK")) {
					return obj;
				}
			}

		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}

	// 연락처 삭제
	@RequestMapping(value = "/DeleteBizCard.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap deleteBizCard(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
			// 세션정보
			String strUR_Code = SessionHelper.getSession("UR_Code");
			String strDN_Code = SessionHelper.getSession("DN_Code");
			String strGR_Code = SessionHelper.getSession("GR_Code");
			String strTypeCode = request.getParameter("TypeCode");
			String strBizCardID = request.getParameter("BizCardID");

			CoviMap params = new CoviMap();

			params.put("TypeCode", strTypeCode);
			params.put("BizCardID", strBizCardID);
			params.put("UR_Code", strUR_Code);
			params.put("DN_Code", strDN_Code);
			params.put("GR_Code", strGR_Code);

			returnObj = bizCardManageService.deleteBizCard(params);

			CoviMap phoneParams = new CoviMap();

			phoneParams.put("BizCardID", strBizCardID);
			phoneParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardPhone(phoneParams);

			CoviMap emailParams = new CoviMap();

			emailParams.put("BizCardID", strBizCardID);
			emailParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardEmail(emailParams);

			CoviMap anniParams = new CoviMap();

			anniParams.put("BizCardID", strBizCardID);
			anniParams.put("TypeCode", strTypeCode);

			bizCardManageService.deleteBizCardAnniversary(anniParams);

			CoviMap favrParams = new CoviMap();

			favrParams.put("BizCardID", strBizCardID);
			favrParams.put("UR_Code", strUR_Code);

			bizCardListService.deleteFromFavoriteList(anniParams);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}

	/*
	 * 주소 API https://www.juso.go.kr localhost
	 * U01TX0FVVEgyMDE3MDgyOTEzNTMwODEwNzI5NTI=
	 * 
	 */
	@RequestMapping(value = "/getAddrAPI.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getAddrApi(HttpServletRequest req, HttpServletResponse response,
			@RequestParam(value = "currentPage", required = false, defaultValue = "1") String currentPage,
			@RequestParam(value = "countPerPage", required = false, defaultValue = "10") String countPerPage,
			@RequestParam(value = "keyword", required = false, defaultValue = "") String keyword) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			// API 호출 URL 정보 설정
			HttpURLConnectUtil url = new HttpURLConnectUtil();

			returnList.put("list", url.jusoAPI(currentPage, keyword, countPerPage));
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
}
