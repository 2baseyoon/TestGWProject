package egovframework.covision.coviflow.manage.web;

import java.util.ArrayList;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.PersonDirectorOfUnitSvc;



@Controller
public class PersonDirectorOfUnitManageCon {

	private Logger LOGGER = LogManager.getLogger(PersonDirectorOfUnitManageCon.class);

	@Autowired
	private PersonDirectorOfUnitSvc personDirectorOfUnitSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getPersonDirectorOfUnitList : 결재함권한부여 - 특정부서(사용자) 목록 호출
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getPersonDirectorOfUnitList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorOfUnitList(HttpServletRequest request,
			HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			int pageSize = 1;
			int pageNo = Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0) {
				pageSize = Integer.parseInt(request.getParameter("pageSize"));
			}

			String entCode = request.getParameter("EntCode");
			String userCode = request.getParameter("UserCode");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];

			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);
			params.put("UserCode", userCode);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("lang", SessionHelper.getSession("lang"));

			CoviMap resultList = personDirectorOfUnitSvc.getPersonDirectorOfUnitList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;

	}

	/**
	 * getPersonDirectorOfUnitData : 결재함권한부여 - 특정부서(사용자) 레이어팝업 수정화면에 대한 데이터 바인드
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getPersonDirectorOfUnitData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPersonDirectorOfUnitData(HttpServletRequest request,
			HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");

			CoviMap params = new CoviMap();
			params.put("UserCode", userCode);
			params.put("EntCode", entCode);

			CoviMap resultList = personDirectorOfUnitSvc.getPersonDirectorOfUnitData(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("cnt", resultList.get("cnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * goPersonDirectorOfUnitSetPopup : 결재함 권한 부여 - 특정부서(사용자) 추가 및 수정 버튼 레이어팝업
	 * 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/goPersonDirectorOfUnitSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goPersonDirectorOfUnitSetPopup(Locale locale, Model model) {
		String returnURL = "manage/approval/PersonDirectorOfUnitSetPopup";
		return new ModelAndView(returnURL);
	}

	/**
	 * insertPersonDirectorOfUnit : 결재함 권한 부여 - 특정부서(사용자) 레이어팝업 저장
	 * 
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "manage/insertPersonDirectorOfUnit.do", method = { RequestMethod.GET,
			RequestMethod.POST }, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap insertPersonDirectorOfUnit(HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {

		CoviMap returnList = new CoviMap();

		try {
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");
			String userName = request.getParameter("UserName");
			String description = request.getParameter("Description");
			String sortKey = request.getParameter("SortKey");
			String authStartDate = request.getParameter("AuthStartDate");
			String authEndDate = request.getParameter("AuthEndDate");

			String jsonString = request.getParameter("directormember");

			String escapedJson = StringEscapeUtils.unescapeHtml(jsonString);

			CoviList jarr = CoviList.fromObject(escapedJson);

			CoviMap chkDupParams = new CoviMap();
			ArrayList<String> targetUnitCodeArr = new ArrayList<>();

			for (int i = 0; i < jarr.size(); i++) {
				targetUnitCodeArr.add(jarr.getJSONObject(i).getString("UnitCode"));
			}

			chkDupParams.put("UserCode", userCode);
			chkDupParams.put("EntCode", entCode);
			chkDupParams.put("TargetUnitCodes", targetUnitCodeArr);

			// 권한자에 대하여 피권한 부서 조회 권한 중복 체크
			if (!targetUnitCodeArr.isEmpty() && personDirectorOfUnitSvc.chkDuplicateTarget(chkDupParams) > 0) {
				returnList.put("result", "fail");
				returnList.put("message", DicHelper.getDic("msg_apv_DupDirectorTarget"));
			} else {
				// 멀티 insert일 경우
				/*
				 * paramMap을 직접 넘기는 case를 검토해야 함 paramMap.get("list["+i+"][CONM]"))
				 */

				CoviMap params = new CoviMap();
				CoviMap params2 = new CoviMap();

				// 날짜의 경우 timezone 적용 할 것
				params.put("UserCode", userCode);
				params.put("EntCode", entCode);
				params2.put("EntCode", entCode);
				params.put("UserName", userName);
				params.put("Description", ComUtils.RemoveSQLInjection(description, 100));
				params.put("SortKey", sortKey);
				params.put("AuthStartDate", authStartDate);
				params.put("AuthEndDate", authEndDate);

				personDirectorOfUnitSvc.deleteJWF_DIRECTOR(params);
				personDirectorOfUnitSvc.deleteJWF_DIRECTORMEMBER(params);

				for (int i = 0; i < jarr.size(); i++) {
					CoviMap order = jarr.getJSONObject(i);
					params2.put("UserCode", order.getString("UserCode"));
					params2.put("UnitCode", order.getString("UnitCode"));
					params2.put("UnitName", order.getString("UnitName"));
					params2.put("ViewStartDate", order.getString("ViewStartDate"));
					params2.put("ViewEndDate", order.getString("ViewEndDate"));

					personDirectorOfUnitSvc.insertJWF_DIRECTORMEMBER(params2);

				}

				returnList.put("object", personDirectorOfUnitSvc.insertJWF_DIRECTOR(params));
				returnList.put("result", "ok");
				returnList.put("message", "저장되었습니다.");
			}

			returnList.put("status", Return.SUCCESS);
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? aioobE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * deletePersonDirectorOfUnit : 결재함권한부여 - 특정부서(사용자) 삭제
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/deletePersonDirectorOfUnit.do", method = { RequestMethod.GET,
			RequestMethod.POST }, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap deletePersonDirectorOfUnit(HttpServletRequest request, HttpServletResponse response,
			@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnData = new CoviMap();

		try {
			String userCode = request.getParameter("UserCode");
			String entCode = request.getParameter("EntCode");

			CoviMap params = new CoviMap();

			params.put("UserCode", userCode);
			params.put("EntCode", entCode);

			int result = personDirectorOfUnitSvc.deleteJWF_DIRECTOR(params);
			result += personDirectorOfUnitSvc.deleteJWF_DIRECTORMEMBER(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode) ? npE.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode) ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

}
