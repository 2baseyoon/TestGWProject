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
import egovframework.coviaccount.user.service.BudgetRegistSvc;
import egovframework.coviframework.util.ComUtils;



/**
 * @Class Name : accountPreparCon.java
 * @Description : 예산편성관리 컨트롤러
 * @Modification Information 
 * @ 2018.05.08 최초생성
 *
 * @author 코비젼 연구소
 * @since 2018.05.08
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class BudgetRegistCon {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private BudgetRegistSvc budgetRegistSvc;

	@Autowired
	private CommonCon commonCon;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	/**
	 * @Method Name : getAccountManagelist
	 * @Description : 예산편성 목록 조회
	 */
	@RequestMapping(value = "budgetRegist/getBuggetRegistList.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap getBuggetRegistList(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			
			String sortColumn		= request.getParameter("sortColumn");
			String sortDirection	= request.getParameter("sortDirection");
			String sortBy			= StringUtil.replaceNull(request.getParameter("sortBy"),"");
			if(sortBy.length() > 0){
				sortColumn		= sortBy.split(" ")[0];
				sortDirection	= sortBy.split(" ")[1];
			}

			params.put("sortColumn",		ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",		ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("pageNo",			StringUtil.replaceNull(request.getParameter("pageNo"),"1"));
			params.put("pageSize",			StringUtil.replaceNull(request.getParameter("pageSize"),"1"));
			
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(request.getParameter("costCenterName")).trim(), 100));
			params.put("baseTerm",		request.getParameter("baseTerm"));
			params.put("isControl",			request.getParameter("isControl"));
			params.put("isUse",				request.getParameter("isUse"));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(request.getParameter("searchStr"), 100));
			
			resultList = budgetRegistSvc.getBudgetRegistList(params);
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
	 * @Method Name : changeFlag
	 * @Description : flag 변경
	 * 			HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap,
			@RequestParam(value = "sortBy", required = false, defaultValue = "") String sortBy)

	 */
	@RequestMapping(value = "budgetRegist/changeFlag.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap changeFlag(HttpServletRequest request) throws Exception{

		CoviMap resultList = new CoviMap();
			
		try {
			int resultCnt = 0;
			CoviMap params = new CoviMap();
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenter",		request.getParameter("costCenter"));
			params.put("accountCode",		request.getParameter("accountCode"));
			params.put("standardBriefID",		request.getParameter("standardBriefID"));
			params.put("baseTerm",			request.getParameter("baseTerm"));
			params.put("periodLabel",		request.getParameter("periodLabel"));
			params.put("version",			request.getParameter("version"));
			params.put("isFlag",			request.getParameter("isFlag"));
			
			if ("C".equals(request.getParameter("changeType")))
			{
				resultCnt = budgetRegistSvc.changeControl(params);
			}
			else
			{
				resultCnt = budgetRegistSvc.changeUse(params);
				
			}
			resultList.put("resultCnt", resultCnt);
			resultList.put("result", "ok");

			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "저장");
		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	
	/**
	* @Method Name : BudgetRegistChangePopup
	* @Description : 추가화면 호출 
	*/
	@RequestMapping(value = "budgetRegist/BudgetRegistAddPopup.do", method = RequestMethod.GET)
	public ModelAndView budgetRegistAddPopup(HttpServletRequest request,
		HttpServletResponse response) {
		String returnURL = "user/account/BudgetRegistAddPopup";

		ModelAndView mav = new ModelAndView(returnURL);

		mav.addObject("companyCode",		request.getParameter("companyCode"));
		return mav;
	}

	/**
	* @Method Name : BudgetRegistChangePopup
	* @Description : 수정화면 호출 
	*/
	@RequestMapping(value = "budgetRegist/BudgetRegistChangePopup.do", method = RequestMethod.GET)
	public ModelAndView budgetRegistChangePopup(HttpServletRequest request,
		HttpServletResponse response) {
		String returnURL = "user/account/BudgetRegistChangePopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("companyCode",	request.getParameter("companyCode"));
		mav.addObject("chgType", 		request.getParameter("chgType"));
		mav.addObject("registID",		request.getParameter("registID"));
		return mav;
	}
	
	/**
	* @Method Name : getBudgetRegistInfo
	* @Description : 예산편성 정보 조회
	*/
	@RequestMapping(value = "budgetRegist/getBudgetRegistInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBudgetRegistInfo(
			HttpServletRequest request) throws Exception {

		CoviMap resultList = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("registID",			request.getParameter("registID"));
			
			resultList = budgetRegistSvc.getBudgetRegistInfo(params);
			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "조회되었습니다");

		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	
	/**
	* @Method Name : getBudgetRegistItem
	* @Description : 예산변경전 상세화면 조회 
	*/
	@RequestMapping(value = "budgetRegist/getBudgetRegistItem.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBudgetRegistItem(
			HttpServletRequest request) throws Exception {

		CoviMap resultList = new CoviMap();
		try {

			CoviMap params = new CoviMap();
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenter",		request.getParameter("costCenter"));
			params.put("accountCode",		request.getParameter("accountCode"));
			params.put("standardBriefID",	request.getParameter("standardBriefID"));

			resultList = budgetRegistSvc.getBudgetRegistItem(params);
			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "조회되었습니다");

		} catch (SQLException e) {
			resultList.put("status",	Return.FAIL);
			resultList.put("message",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}

	/**
	* @Method Name : addBudgetRegist
	* @Description : 예산편정추가
	*/
	@RequestMapping(value = "budgetRegist/addBudgetRegist.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addBudgetRegist(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String saveStr = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			CoviMap saveObj = CoviMap.fromObject(saveStr);
			
			CoviMap params = new CoviMap();
			params.put("companyCode",		AccountUtil.jobjGetStr(saveObj,"companyCode"));
			params.put("fiscalYear",		AccountUtil.jobjGetStr(saveObj,"fiscalYear"));
			params.put("costCenter",		AccountUtil.jobjGetStr(saveObj,"costCenter"));
			params.put("accountCode",		AccountUtil.jobjGetStr(saveObj,"accountCode"));
			params.put("standardBriefID",	AccountUtil.jobjGetStr(saveObj,"standardBriefID"));
			params.put("baseTerm",		    AccountUtil.jobjGetStr(saveObj,"baseTerm"));
			params.put("isControl",		    AccountUtil.jobjGetStr(saveObj,"isControl"));
			params.put("isUse",		    	AccountUtil.jobjGetStr(saveObj,"isUse"));
			params.put("validFrom",		    AccountUtil.jobjGetStr(saveObj,"validFrom").replaceAll("[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
			params.put("validTo",		    AccountUtil.jobjGetStr(saveObj,"validTo").replaceAll("[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
			params.put("costCenterType",	AccountUtil.jobjGetStr(saveObj,"costCenterType"));
			

			CoviList saveList = (CoviList) AccountUtil.jobjGetObj(saveObj,"saveList");
			if(saveList != null) {
				returnList = budgetRegistSvc.addBudgetRegist(params, saveList);
				boolean dupFlag = (boolean) returnList.get("dupFlag");
				boolean typeFlag = (boolean) returnList.get("typeFlag");
				boolean ccFlag = (boolean) returnList.get("ccFlag");
				
				if (dupFlag) {
					returnList.put("result", "dup");
					returnList.put("status", Return.FAIL);
				}
				if (typeFlag) {
					returnList.put("result", "type");
					returnList.put("status", Return.FAIL);
				}
				if (ccFlag) {
					returnList.put("result", "cc");
					returnList.put("status", Return.FAIL);
				}
				if (!dupFlag && !typeFlag && !ccFlag) {
					returnList.put("result", "ok");
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "저장");
				}
			}
			
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	/**
	* @Method Name : saveBudgetRegist
	* @Description : 예산편정저장
	*/
	@RequestMapping(value = "budgetRegist/saveBudgetRegist.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveBudgetRegist(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String saveStr = StringEscapeUtils.unescapeHtml(request.getParameter("saveObj"));
			CoviMap saveObj = CoviMap.fromObject(saveStr);
			
			if(saveObj != null) {
				CoviMap registInfo = (CoviMap) saveObj.getJSONObject("registInfo");
				CoviList periodInfo = (CoviList) saveObj.getJSONArray("periodInfo");
				
				CoviMap params = new CoviMap();
				params.put("companyCode",		registInfo.get("companyCode"));
				params.put("fiscalYear",		registInfo.get("fiscalYear"));
				params.put("costCenter",		registInfo.get("costCenter"));
				params.put("accountCode",		registInfo.get("accountCode"));
				params.put("standardBriefID",	registInfo.get("standardBriefID"));
				params.put("changType",			registInfo.get("changType"));
				params.put("memo",				registInfo.get("memo"));
				params.put("baseTerm",			registInfo.get("baseTerm"));
				params.put("UR_Code",			SessionHelper.getSession("UR_Code"));
				
				int resultCnt = budgetRegistSvc.saveBudgetRegist(params, periodInfo);
				
				if(resultCnt > 0) {
					returnList.put("resultCnt", resultCnt);
					returnList.put("result", "ok");
					returnList.put("status", Return.SUCCESS);
					returnList.put("message", "저장");
				} else {
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", "저장에 실패하였습니다");
				}
			}
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
//			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	

	/**
	* @Method Name : deleteBudgetRegist
	* @Description : 예산편정삭제
	*/
	@RequestMapping(value = "budgetRegist/deleteBudgetRegist.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteBudgetRegist(HttpServletRequest request,
			HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String saveStr = StringEscapeUtils.unescapeHtml(request.getParameter("deleteObj"));
			CoviMap saveObj = CoviMap.fromObject(saveStr);
			
			CoviList saveList = (CoviList) AccountUtil.jobjGetObj(saveObj,"deleteList");
			if(saveList != null) {
				int resultCnt = budgetRegistSvc.deleteBudgetRegist(saveList);
				returnList.put("resultCnt", resultCnt);
				returnList.put("result", "ok");
	
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제");
			}
		} catch (SQLException e) {
			returnList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
//			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	/**
	 * @Method Name : RegistxcelPopup
	 * @Description : 엑셀 업로드 팝업 호출
	 */
	@RequestMapping(value = "budgetRegist/BudgetRegistExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView budgetRegistExcelPopup(HttpServletRequest request,			HttpServletResponse response) {
		String returnURL = "user/account/BudgetRegistExcelPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	 * @Method Name : BudgetRegist
	 * @Description : 예산편성 엑셀 업로드
	 */
	@RequestMapping(value = "budgetRegist/uploadExcel.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap uploadExcel(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile, @RequestParam Map<String, String> paramMap) {
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("companyCode", paramMap.get("companyCode"));
			params.put("uploadfile", uploadfile);
			
			returnData = budgetRegistSvc.uploadExcel(params);
			
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
	* @Method Name : templateDownload
	* @Description : 템플릿 다운로드
	*/
	@RequestMapping(value = "budgetRegist/downloadTemplate.do")
	public ModelAndView downloadTemplate(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		
		try {
				String returnURL = "UtilExcelView";
				CoviMap viewParams = new CoviMap();
				String[] headerNames = null;
				headerNames = new String [] {"예산년도"
						, "코스트스센터"
						,"계정코드"
						,"계정이름"
						,"표준적요"
						,"구분"
						,"유효시작일"
						,"유효종료일"
						,"기간구분"
						,"금액"
						,"사용유무"
						,"통제유무"
						,"비고"
						,"사원번호(코스트센터 모를 경우 입력)"
						};
				
				CoviList jsonArray = new CoviList();
				CoviMap jsonObject = new CoviMap();
				jsonObject.put("fiscalYear", "2023");
				jsonObject.put("costCenter", "superadmin");
				jsonObject.put("accoutCode", "833");
				jsonObject.put("accoutName", "광고선전비");
				jsonObject.put("standardBriefName", "기타 광고");
				jsonObject.put("BaseTerm", "Year");
				jsonObject.put("validFrom", "");
				jsonObject.put("validTo", "");
				jsonObject.put("periodLabel", "1Y");
				jsonObject.put("BudgetAmount", "150000");
				jsonObject.put("isUse", "Y");
				jsonObject.put("isControl", "Y");
				jsonObject.put("memo", "자기개발");

				jsonArray.add( jsonObject);
				
				jsonObject = new CoviMap();
				jsonObject.put("fiscalYear", "2023");
				jsonObject.put("costCenter", "superadmin");
				jsonObject.put("accoutCode", "833");
				jsonObject.put("accoutName", "광고선전비");
				jsonObject.put("standardBriefName", "키워드 광고");
				jsonObject.put("BaseTerm", "Year");
				jsonObject.put("validFrom", "");
				jsonObject.put("validTo", "");
				jsonObject.put("periodLabel", "1Y");
				jsonObject.put("BudgetAmount", "350000");
				jsonObject.put("isUse", "Y");
				jsonObject.put("isControl", "Y");
				jsonObject.put("memo", "직무개발");

				jsonArray.add( jsonObject);
				
				viewParams.put("list", jsonArray);
				viewParams.put("cnt", 0);
				viewParams.put("headerName", headerNames);
				viewParams.put("title", "BudgetRegistTemplate");
				mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return mav;
	}
	
	/**
	 * @Method Name : downloadExcel
	 * @Description : 계정관리 엑셀 다운로드
	 */
	@RequestMapping(value = "budgetRegist/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest request, HttpServletResponse response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			//String[] headerNames = commonCon.convertUTF8(request.getParameter("headerName")).split("†");
			String[] headerNames = URLDecoder.decode(request.getParameter("headerName"),"utf-8").split("†");
			String[] headerKeys  = commonCon.convertUTF8(StringUtil.replaceNull(request.getParameter("headerKey"))).split(",");
			
			String costCenterName = URLDecoder.decode(request.getParameter("costCenterName"),"utf-8");
			String searchStr = URLDecoder.decode(request.getParameter("searchStr"),"utf-8");
			
			CoviMap params = new CoviMap();
			
			params.put("companyCode",		request.getParameter("companyCode"));
			params.put("fiscalYear",		request.getParameter("fiscalYear"));
			params.put("costCenterName",	ComUtils.RemoveSQLInjection(StringUtil.replaceNull(costCenterName).trim(), 100));
			params.put("baseTerm",			request.getParameter("baseTerm"));
			params.put("isControl",			request.getParameter("isControl"));
			params.put("isUse",				request.getParameter("isUse"));
			params.put("costCenterType",	request.getParameter("costCenterType"));
			
			params.put("searchType",		request.getParameter("searchType"));
			params.put("searchStr",			ComUtils.RemoveSQLInjection(searchStr, 100));
			
			CoviMap resultList = budgetRegistSvc.getBudgetRegistList(params);
			AccountFileUtil accountFileUtil = new AccountFileUtil();
			
			viewParams.put("list",			resultList.get("list"));
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			//viewParams.put("title",			accountFileUtil.getDisposition(request, request.getParameter("title")));
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
}
