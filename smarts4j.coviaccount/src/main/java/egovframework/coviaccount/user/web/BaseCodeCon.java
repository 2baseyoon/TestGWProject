package egovframework.coviaccount.user.web;

import java.lang.invoke.MethodHandles;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviframework.util.ComUtils;



/**
 * @Class Name : BaseCodeCon.java
 * @Description : 기초코드
 * @Modification Information
 * @author Covision @ 2018.05.08 최초생성
 */
@Controller
public class BaseCodeCon {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Autowired
	private BaseCodeSvc baseCodeSvc;
	
	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");


	/**
	* @Method Name : searchBaseCode
	* @Description : 기초코드 목록 조회
	*/
	@RequestMapping(value = "baseCode/searchBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap searchBaseCode(
			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy", required = false, defaultValue = "") String sortBy)
			throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			String sortColumn = "";
			String sortDirection = "";
			if (sortBy.length() > 0) {
				sortColumn = sortBy.split(" ")[0];
				sortDirection = sortBy.split(" ")[1];
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));

			// pageNo : 현재 페이지 번호
			// pageSize : 페이지당 출력데이타 수
			int pageSize = 1;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null
					|| StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0) {
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}

			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);

			String searchText = request.getParameter("searchText");
			String searchGrp = request.getParameter("searchGrp");
			String searchGrpText = request.getParameter("searchGrpText");
			String companyCode = request.getParameter("companyCode");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("searchGrp", searchGrp);
			params.put("companyCode", companyCode);
			params.put("searchGrpText", searchGrpText);

			resultList = baseCodeSvc.searchBaseCode(params);
			
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
	* @Method Name : changeBaseCodeIsUse
	* @Description : 기초코드 사용여부변경
	*/
	@RequestMapping(value = "baseCode/changeBaseCodeIsUse.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap changeBaseCodeIsUse(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {

			String codeGroup = StringUtil.replaceNull(request.getParameter("CodeGroup"), "");
			String code = StringUtil.replaceNull(request.getParameter("Code"), "");
			String baseCodeID = StringUtil.replaceNull(request.getParameter("BaseCodeID"), "");
			String userId = StringUtil.replaceNull(request.getParameter("UserId"), "");
			String isUseValue = StringUtil.replaceNull(request.getParameter("isUseValue"), "");

			CoviMap params = new CoviMap();
			params.put("CodeGroup", codeGroup);
			params.put("Code", code);
			params.put("BaseCodeID", baseCodeID);
			params.put("UserId", userId);
			params.put("isUseValue", isUseValue);

			//회사코드는 미사용/삭제 하기전에 검증 (미사용/삭제할경우 나머지 회사코드 중 사용중인 회사코드가 하나라도 있어야 가능)
			if("CompanyCode".equals(codeGroup) && "N".equals(isUseValue)) {
				if(baseCodeSvc.checkCompanyCodeIsUse(params) < 1) {
					returnList.put("result", "fail");
					returnList.put("message", DicHelper.getDic("ACC_msg_minIsUseCompanyCode")); //회사코드는 1개 이상 사용중이어야 합니다.
					return returnList;
				}
			}
			int resultCnt = baseCodeSvc.changeBaseCodeIsUse(params);

			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("ACC_msg_saveComp")); //저장되었습니다.
		} catch (SQLException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}

	/**
	* @Method Name : callBaseCodeAddPopup
	* @Description : 기초코드 상세화면 호출 
	*/
	@RequestMapping(value = "baseCode/callBaseCodeAddPopup.do", method = RequestMethod.GET)
	public ModelAndView callBaseCodeAddPopup(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		String returnURL = "user/account/BaseCodePopup";

		String isNew = request.getParameter("isNew");
		String baseCodeId = request.getParameter("baseCodeId");
		String isGrp = request.getParameter("isGrp");

		if ("N".equals(isNew)) {
			returnURL = "user/account/BaseCodeSearchPopup";
		}

		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("isNew", isNew);
		mav.addObject("baseCodeId", baseCodeId);
		mav.addObject("isGrp", isGrp);

		return mav;
	}

	/**
	* @Method Name : searchBaseCodeDetail
	* @Description : 기초코드 상세화면 조회 
	*/
	@RequestMapping(value = "baseCode/searchBaseCodeDetail.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap searchBaseCodeDetail(
			HttpServletRequest request) throws Exception {

		CoviMap returnObj = new CoviMap();
		CoviMap resultMap = new CoviMap();

		try {
			String baseCodeID = request.getParameter("BaseCodeID");

			CoviMap params = new CoviMap();
			params.put("BaseCodeID", baseCodeID);
			resultMap = baseCodeSvc.searchBaseCodeDetail(params);

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
	* @Method Name : saveBaseCode
	* @Description : 기초코드 저장 
	*/
	@RequestMapping(value = "baseCode/saveBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveBaseCode(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String bco = StringEscapeUtils.unescapeHtml(request.getParameter("baseCodeObj"));
			CoviMap baseCodeObj = CoviMap.fromObject(bco);

			String isNew = baseCodeObj.getString("IsNew");

			CoviMap returnObj = new CoviMap();
			if ("Y".equals(isNew)) {
				returnObj = baseCodeSvc.insertBaseCode(baseCodeObj);
			} else {
				returnObj = baseCodeSvc.updateBaseCode(baseCodeObj);
			}

			if ("D".equals(returnObj.getString("status"))) {
				returnList.put("result", "D");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "중복");
			} else if ("V".equals(returnObj.getString("status"))) {
				returnList.put("returnObj", returnObj);
				returnList.put("result", "V");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "필수값");
			} else if ("G".equals(returnObj.getString("status"))) {
				returnList.put("returnObj", returnObj);
				returnList.put("result", "G");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "그룹없음");
			} else if ("S".equals(returnObj.getString("status"))) {
				returnList.put("returnObj", returnObj);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "저장");
			} else {
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
	* @Method Name : deleteBaseCode
	* @Description : 기초코드 삭제 
	*/
	@RequestMapping(value = "baseCode/deleteBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteBaseCode(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {

			CoviMap covimap = new CoviMap();
			covimap.put("deleteobj", paramMap.get("deleteobj"));
			CoviList checkList = (CoviList) AccountUtil.jobjGetObj(covimap,"deleteobj");
			
			//회사코드는 삭제 하기전에 검증 (삭제할경우 나머지 회사코드 중 사용중인 회사코드가 하나라도 있어야 가능)
			for(int i = 0; i < checkList.size(); i++) {
				CoviMap checkObj = (CoviMap) checkList.get(i);
				if(checkObj.get("CodeGroup").equals("CompanyCode")) {
					if(baseCodeSvc.checkCompanyCodeIsUse(checkObj) < 1) {
						returnList.put("result", "fail");
						returnList.put("message", DicHelper.getDic("ACC_msg_minIsUseCompanyCode")); //회사코드는 1개 이상 사용중이어야 합니다.
						return returnList;
					}
				}
			}
			
			String baseCodeList = request.getParameter("baseCodeList");
			String grpList = request.getParameter("grpList");

			CoviMap params = new CoviMap();
//			params.put("baseCodeList", baseCodeList);
//			params.put("grpList", grpList);
			if(baseCodeList != null && !baseCodeList.equals("")) params.put("baseCodeList", baseCodeList.split(","));
			if(grpList != null && !grpList.equals("")) params.put("grpList", grpList.split(","));
			int resultGrpCnt = baseCodeSvc.deleteBaseGrpCodeList(params);
			int resultCnt = baseCodeSvc.deleteBaseCodeList(params);

			returnList.put("resultCnt", resultCnt);
			returnList.put("resultGrpCnt", resultGrpCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
            returnList.put("message", DicHelper.getDic("ACC_msg_delComp")); //삭제를 완료하였습니다.
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
	* @Method Name : excelDownload
	* @Description : 엑셀 다운로드 
	*/
	@RequestMapping(value = "baseCode/excelDownload.do", method = RequestMethod.GET)
	public ModelAndView excelDownload(
			HttpServletRequest	request,
			HttpServletResponse	response,
			@RequestParam(value = "headerName",	required = false, defaultValue="")	String headerName,
			@RequestParam(value = "headerKey",	required = false, defaultValue="")	String headerKey,
			@RequestParam(value = "searchGrp",	required = false, defaultValue="")	String searchGrp,
			@RequestParam(value = "searchText",	required = false, defaultValue="")	String searchText,
			@RequestParam(value = "companyCode",required = false, defaultValue="")	String companyCode,
			@RequestParam(value = "title",		required = false, defaultValue="")	String title,
			@RequestParam(value = "headerType",	required = false, defaultValue="")	String headerType
			) {

		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			
			//String[] headerNames = commonCon.convertUTF8(headerName).split("†");
			String[] headerNames = URLDecoder.decode(headerName,"utf-8").split("†");
			
			CoviMap params = new CoviMap();
			params.put("searchGrp",		commonCon.convertUTF8(searchGrp));
			params.put("searchText",	commonCon.convertUTF8(ComUtils.RemoveSQLInjection(searchText, 100)));
			params.put("companyCode",	commonCon.convertUTF8(companyCode));
			params.put("headerKey",		commonCon.convertUTF8(headerKey));
			resultList = baseCodeSvc.searchBaseCodeExcel(params);
			
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
	* @Method Name : excelTemplateDownload
	* @Description : 템플릿 다운로드 
	*/
	@RequestMapping(value = "baseCode/excelTemplateDownload.do")
	public ModelAndView excelTemplateDownload(HttpServletRequest request,
			HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();

		try {
			String returnURL = "UtilExcelView";
			CoviMap viewParams = new CoviMap();
			String[] headerNames = null;
			headerNames = new String[] { "회사코드", "코드그룹여부", "코드그룹", "코드그룹명", "코드", "코드명", "사용여부" };

			viewParams.put("cnt", 0);
			viewParams.put("list", new CoviList());
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "BaseCodeTemplate");
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}

	/**
	* @Method Name : callBaseCodeExcelUploadPoup
	* @Description : 엑셀 업로드 팝업 호출 
	*/
	@RequestMapping(value = "baseCode/callBaseCodeExcelUploadPoup.do", method = RequestMethod.GET)
	public ModelAndView callBaseCodeExcelUploadPoup(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		return new ModelAndView("user/account/BaseCodeExcelPopup");
	}

	/**
	* @Method Name : excelUpload
	* @Description :엑셀 업로드 
	*/
	@RequestMapping(value = "baseCode/excelUpload.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap excelUpload(
			@RequestParam(value = "uploadfile", required = true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);

			returnData = baseCodeSvc.uploadExcelBaseCode(params);

			if ("D".equals(returnData.getString("status"))) {
				returnList.put("result", "D");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "중복");
			} else if ("V".equals(returnData.getString("status"))) {
				returnList.put("returnObj", returnData);
				returnList.put("result", "V");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "필수값");
			} else if ("G".equals(returnData.getString("status"))) {
				returnList.put("returnObj", returnData);
				returnList.put("result", "G");
				returnList.put("status", Return.FAIL);
				returnList.put("message", "그룹없음");
			} else if ("S".equals(returnData.getString("status"))) {
				returnList.put("returnObj", returnData);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "업로드 되었습니다");
			} else if ("T".equals(returnData.getString("status"))) {
				returnList.put("returnObj", returnData);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "액셀 내 중복데이터");
			} else {
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
	* @Method Name : searchBaseCodeView
	* @Description : 기초코드 조회용화면
	*/
	@RequestMapping(value = "baseCode/searchBaseCodeView.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap searchBaseCodeView(
			HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy",			required = false, defaultValue="")	String sortBy) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		try {

			CoviMap params = new CoviMap();
			int pageSize = 1;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null
					|| StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0) {
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}			
			
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
			String searchGrp = request.getParameter("searchGrp");
			String companyCode = request.getParameter("companyCode");
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("searchGrp", searchGrp);
			params.put("companyCode", companyCode);

			resultList = baseCodeSvc.searchBaseCodeView(params);
			
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
	* @Method Name : callBaseCodeViewPopup
	* @Description :기초코드 상세화면 호출 
	*/
	@RequestMapping(value = "baseCode/callBaseCodeViewPopup.do", method = RequestMethod.GET)
	public ModelAndView callBaseCodeViewPopup(HttpServletRequest request,
			HttpServletResponse response) throws Exception {

		String returnURL = "user/account/BaseCodeViewPopup";

		ModelAndView mav = new ModelAndView(returnURL);

		String baseCodeId = request.getParameter("baseCodeId");
		String groupCode = request.getParameter("groupCode");

		mav.addObject("groupCode", groupCode);
		mav.addObject("baseCodeId", baseCodeId);
		return mav;
	}
	
	/**
	* @Method Name : getCodeListByCodeGroup
	* @Description : 기초코드 상세화면 조회
	*/
	@RequestMapping(value = "baseCode/getCodeListByCodeGroup.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCodeListByCodeGroup(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String codeGroup = request.getParameter("codeGroup");
			String companyCode = request.getParameter("companyCode");

			CoviMap params = new CoviMap();
			params.put("codeGroup", codeGroup);
			params.put("companyCode", companyCode);
			resultList = baseCodeSvc.getCodeListByCodeGroup(params);

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
	* @Method Name : getBaseCodeName
	* @Description : code 값 통해 codename 반환
	*/
	@RequestMapping(value = "baseCode/getBaseCodeName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBaseCodeName(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String codeGroup = request.getParameter("CodeGroup");
			String code = request.getParameter("Code");
			String companyCode = request.getParameter("CompanyCode");

			CoviMap params = new CoviMap();
			params.put("codeGroup", codeGroup);
			params.put("code", code);
			params.put("companyCode", companyCode);
			
			resultList = baseCodeSvc.getBaseCodeName(params);

			returnList.put("CodeName", resultList.getString("CodeName"));
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
	

	@Autowired
	private AccountUtil accountUtil;
	/**
	* @Method Name : syncBaseCode
	* @Description : 기초코드 동기화 
	*/
	@RequestMapping(value = "baseCode/syncBaseCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap syncBaseCode(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String viewCd = request.getParameter("viewCd");
			
			CoviMap baseCodeObj = new CoviMap();
			baseCodeObj.put("viewCd", viewCd);
			baseCodeSvc.syncBaseCode(baseCodeObj);
			returnList.put("result", "ok");
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
	* @Method Name : insertProjectCode
	* @Description : 사업관리 연동 - 프로젝트 코드 발번 시 이어카운팅 프로젝트 코드/이름 정보 추가
	*/
	@RequestMapping(value = "baseCode/insertProjectCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertProjectCode(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("CodeGroupCombo", "IOCode");
			params.put("Code", request.getParameter("projectCd"));
			params.put("CodeName", request.getParameter("projectNm"));
			
			params.put("IsGroup", "N");
			params.put("IsUse", "Y");
			params.put("SortKey", baseCodeSvc.selectIOCodeMaxSortKey()+1);
			params.put("SessionUser", SessionHelper.getSession("UR_Code"));
			params.put("CompanyCode", "ALL");
			
			baseCodeSvc.insertBaseCode(params);
			
			returnList.put("result", "ok");
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

}
