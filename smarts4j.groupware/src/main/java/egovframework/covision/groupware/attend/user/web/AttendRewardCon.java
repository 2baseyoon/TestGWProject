package egovframework.covision.groupware.attend.user.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.covision.groupware.attend.user.service.AttendRewardSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.coviframework.util.RedisDataUtil;

@Controller
public class AttendRewardCon {
	private Logger LOGGER = LogManager.getLogger(AttendRewardCon.class);
	
	LogHelper logHelper = new LogHelper();
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired
	AttendRewardSvc attendRewardSvc;

	@Autowired
	private VacationSvc vacationSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
		* @Method Name : getAttendRewardList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 근무제리스트 조회
		* @param request 
		* @param response
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "attendReward/getAttendRewardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendRewardList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);

			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("RewardPeriod", RedisDataUtil.getBaseConfig("RewardPeriod"));
			params.put("RewardStandardDay", RedisDataUtil.getBaseConfig("RewardStandardDay"));
			params.put("RewardMonth", AttendUtils.removeMaskAll((String)params.get("RewardMonth")));
			params.put("NightStartTime", RedisDataUtil.getBaseConfig("NightStartTime"));
			params.put("NightEndTime", RedisDataUtil.getBaseConfig("NightEndTime"));
			params.put("HoliNightStartTime", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
			params.put("HoliNightEndTime", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
			
			resultList = attendRewardSvc.getAttendRewardList(params);
			
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultList;
	}
	
	//요청정보 상세
	@RequestMapping(value = "attendReward/AttendRewardPopup.do", method = RequestMethod.GET)
	public ModelAndView attendRewardPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendRewardPopup";

		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	/**
	* @Method Name : getAttendRewardList
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request 
	* @param response
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendReward/getAttendRewardDeatail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendRewardDeatail(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
	
			params.put("StartDate", AttendUtils.removeMaskAll(params.getString("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll(params.getString("EndDate")));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("NightStartTime", RedisDataUtil.getBaseConfig("NightStartTime"));
			params.put("NightEndTime", RedisDataUtil.getBaseConfig("NightEndTime"));
			params.put("HoliNightStartTime", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
			params.put("HoliNightEndTime", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
			params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
			
			resultList = attendRewardSvc.getAttendRewardDetail(params);
			
			resultList.put("result", "ok");
			resultList.put("status", Return.SUCCESS);
			resultList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultList;
	}

	/**
	* @Method Name : getAttendRewardList
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request 
	* @param response
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendReward/getAttendRewardInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendRewardInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
	
			params.put("RewardCode", "reward");
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			
			CoviList resultList = attendRewardSvc.getAttendRewardInfo(params);
			resultMap.put("data", resultList);
			resultMap.put("result", "ok");
			resultMap.put("status", Return.SUCCESS);
			resultMap.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			resultMap.put("status", Return.FAIL);
			resultMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return resultMap;
	}

	
	/**
	 * @Method Name : approvalAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 승인
	 * @Method 설명 : 근무일정삭제
	 * @param request Map<String, Object>
	 * @return
	 */
	@RequestMapping(value = "attendReward/createAttendReward.do")
	public  @ResponseBody CoviMap createAttendReward(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			List dataList = (List)params.get("dataList");
			reqMap.put("ApprovalCode", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("DeptCode", SessionHelper.getSession("GR_Code"));
			reqMap.put("DeptName", SessionHelper.getSession("GR_MultiName"));
			String ApprovalComment = params.get("ApprovalComment").toString();
			reqMap.put("ApprovalComment", ApprovalComment);

			int resultCnt = attendRewardSvc.createAttendReward(reqMap, dataList);


			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnList;

		
	}

	
	/**
	 * @Method Name : rejectAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 승인거부
	 * @Method 설명 : 근무일정삭제
	 * @param request Map<String, Object> params
	 */
	@RequestMapping(value = "attendReward/cancelAttendReward.do")
	public  @ResponseBody CoviMap cancelAttendReward(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List dataList = (List)params.get("dataList");
			CoviMap reqMap = new CoviMap();
			reqMap.put("ReqStatus", "Reject");
			reqMap.put("ApprovalCode", SessionHelper.getSession("USERID"));
			reqMap.put("ApprovalComment", params.get("ApprovalComment"));

			int resultCnt = attendRewardSvc.cancelAttendReward(reqMap, dataList);
			returnList.put("resultCnt", resultCnt);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);

			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			logHelper.getCurrentClassErrorLog(e);
		}
		return returnList;

		
	}
	
	/**
	 * @Method Name : downloadExcel
	 * @Description : 엑셀 다운로드
	 */
	@RequestMapping(value = "attendReward/downloadExcel.do")
	public ModelAndView downloadExcel(HttpServletRequest	request,			HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			CoviMap resultList = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("RewardPeriod", RedisDataUtil.getBaseConfig("RewardPeriod"));
			params.put("RewardStandardDay", RedisDataUtil.getBaseConfig("RewardStandardDay"));
			params.put("RewardMonth", AttendUtils.removeMaskAll((String)params.get("RewardMonth")));

			params.put("NightStartTime", RedisDataUtil.getBaseConfig("NightStartTime"));
			params.put("NightEndTime", RedisDataUtil.getBaseConfig("NightEndTime"));
			params.put("HoliNightStartTime", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
			params.put("HoliNightEndTime", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
			resultList = attendRewardSvc.getAttendRewardList(params);

			CoviList cList = (CoviList)resultList.get("list");

			viewParams.put("list",			CoviSelectSet.coviSelectJSON(cList, request.getParameter("headerKey")));
			viewParams.put("cnt",			resultList.size());
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			viewParams.put("title",			request.getParameter("title"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav;
	}


	/**
	 * @Method Name : downloadExcel - 보상 휴가 개인별 상세
	 * @Description : 엑셀 다운로드- 보상 휴가 개인별 상세
	 */
	@RequestMapping(value = "attendReward/downloadExcelAttendRewardDetail.do")
	public ModelAndView downloadExcelAttendRewardDetail(HttpServletRequest	request,			HttpServletResponse	response){
		ModelAndView mav		= new ModelAndView();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";

		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");

			CoviMap resultList = new CoviMap();
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("StartDate", AttendUtils.removeMaskAll(params.getString("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll(params.getString("EndDate")));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("NightStartTime", RedisDataUtil.getBaseConfig("NightStartTime"));
			params.put("NightEndTime", RedisDataUtil.getBaseConfig("NightEndTime"));
			params.put("HoliNightStartTime", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
			params.put("HoliNightEndTime", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
			params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));

			resultList = attendRewardSvc.getAttendRewardDetail(params);

			CoviList cList = (CoviList)resultList.get("list");

			viewParams.put("list",			CoviSelectSet.coviSelectJSON(cList, request.getParameter("headerKey")));
			viewParams.put("cnt",			resultList.size());
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			viewParams.put("title",			request.getParameter("title"));

			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return mav;
	}
}
