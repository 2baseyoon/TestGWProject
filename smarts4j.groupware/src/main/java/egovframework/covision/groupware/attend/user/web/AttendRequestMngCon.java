package egovframework.covision.groupware.attend.user.web;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;





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
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.covision.groupware.attend.user.service.AttendReqSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommutingSvc;
import egovframework.covision.groupware.attend.user.service.AttendRequestMngSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;

@Controller
public class AttendRequestMngCon {
	
	private Logger LOGGER = LogManager.getLogger(AttendRequestMngCon.class);
	LogHelper logHelper = new LogHelper();
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;

	@Autowired
	AttendRequestMngSvc attendRequestMngSvc;
	
	@Autowired
	AttendReqSvc attendReqSvc;
	
	@Autowired
	AttendCommutingSvc attendCommutingSvc;
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
		* @Method Name : getAttendRequestList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 근무제리스트 조회
		* @param request 
		* @param response
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "attendRequestMng/getAttendRequestList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendRequestList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll((String)params.get("EndDate")));

			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			String domainID = SessionHelper.getSession("DN_ID");

			String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
			if(!orgMapOrderSet.equals("")) {
			                String[] orgOrders = orgMapOrderSet.split("\\|");
			                params.put("orgOrders", orgOrders);
			}
			
			resultList = attendRequestMngSvc.getAttendRequestList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
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
	
	//엑셀  다운
	@RequestMapping(value = "attendRequestMng/excelAttendRequest.do")
	public ModelAndView excelAttendRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll((String)params.get("EndDate")));
			
			resultList = attendRequestMngSvc.getAttendRequestList(params);
			
			CoviMap convertList = new CoviMap ();
			convertList.put("list", resultList.get("list"));
			
			viewParams.put("list",			convertList.get("list"));
			viewParams.put("cnt",			resultList.size());
			viewParams.put("headerName",	headerNames);
			viewParams.put("headerKey",		headerKeys);
			viewParams.put("title",			request.getParameter("title"));
			
			mav = new ModelAndView(returnURL, viewParams);
		} catch (NullPointerException e) {
			logHelper.getCurrentClassErrorLog(e);
		} catch (Exception e) {
			logHelper.getCurrentClassErrorLog(e);
		}
	
		return mav;
	}

	
	//요청정보 상세
	@RequestMapping(value = "attendRequestMng/AttendRequestDetailPopup.do", method = RequestMethod.GET)
	public ModelAndView attendRequestDetailPopup(HttpServletRequest request,		HttpServletResponse response) throws Exception {
		
		String returnURL = "user/attend/AttendRequestDetailPopup";

		CoviMap reqMap = new CoviMap();
		reqMap.put("ReqSeq", request.getParameter("ReqSeq"));
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));

		CoviMap jsonData = attendRequestMngSvc.getAttendRequestDetail(reqMap);
		CoviMap attendObj = (CoviMap)jsonData.get("data");
		List<CoviMap> workPlaceList = null;
		if (attendObj.getString("ReqType").equals("A") || attendObj.getString("ReqType").equals("L"))//출근/퇴근 신청서 거리
		{
			JSONParser parser = new JSONParser();
			CoviList obj = (CoviList)parser.parse(attendObj.getString("ReqData")) ;
			CoviMap resultMap = (CoviMap)obj.get(0);
			if (resultMap.get("CommutePointX") != null && resultMap.get("CommutePointY") != null){
				double distance = AttendUtils.getPointDistance(attendObj.getDouble("WorkPointX"), attendObj.getDouble("WorkPointY"), Double.parseDouble(resultMap.get("CommutePointX").toString()),Double.parseDouble(resultMap.get("CommutePointY").toString()));
				attendObj.put("WorkDis",Math.round(distance));
				attendObj.put("CommutePointX",resultMap.get("CommutePointX"));
				attendObj.put("CommutePointY",resultMap.get("CommutePointY"));
				
				reqMap.put("SchSeq",attendObj.getString("SchSeq"));
				reqMap.put("WorkPlaceType",	attendObj.getString("ReqType").equals("A")?"0":"1");	
				workPlaceList = attendCommutingSvc.getWorkPlaceList(reqMap);
				for(Object objDetail : workPlaceList) {
					CoviMap work = (CoviMap)objDetail;
					work.put("WorkDis",Math.round(AttendUtils.getPointDistance(work.getDouble("WorkPointX"), work.getDouble("WorkPointY"), Double.parseDouble(resultMap.get("CommutePointX").toString()),Double.parseDouble(resultMap.get("CommutePointY").toString()))));
				}
			}
		}	

		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("data",	attendObj);
		mav.addObject("workPlace",	workPlaceList);
		mav.addObject("reqList", jsonData.get("reqList"));

		
		return mav;
	}
	
	/**
	 * @Method Name : approvalAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 승인
	 * @Method 설명 : 근무일정삭제
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendRequestMng/approvalAttendRequest.do")
	public  @ResponseBody CoviMap approvalAttendRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap reqMap = new CoviMap();
			
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			if (commuteIp == null){ 
				commuteIp = request.getRemoteAddr(); 
			}
			
			List dataList = (List)params.get("dataList");
			
			reqMap.put("ApprovalCode", SessionHelper.getSession("USERID"));
			reqMap.put("domainID", SessionHelper.getSession("DN_ID"));
			reqMap.put("ApprovalComment", params.get("ApprovalComment"));
			reqMap.put("CommuteIp", commuteIp);
			
			CoviMap returnObj = new CoviMap();
			returnList = attendReqSvc.approvalAttendRequest(reqMap, dataList);
			
			//dataList.returnList.put("resultCnt", resultCnt);
			//returnList.put("result", "ok");

			//returnList.put("status", Return.SUCCESS);
			//returnList.put("message", "삭제");

			
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
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendRequestMng/rejectAttendRequest.do")
	public  @ResponseBody CoviMap rejectAttendRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List dataList = (List)params.get("dataList");
			CoviMap reqMap = new CoviMap();
			reqMap.put("ReqStatus", "Reject");
			reqMap.put("ApprovalCode", SessionHelper.getSession("USERID"));
			reqMap.put("ApprovalComment", params.get("ApprovalComment"));
			reqMap.put("flag", "AttendRequest");
			CoviMap returnObj = new CoviMap();
			
			CoviMap resultCnt = attendReqSvc.changeAttendRequestStatus(reqMap, dataList);
			returnList.put("resultCnt", resultCnt.get("cnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
			
			
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
	* @Method Name : getAttendRequestList
	* @작성일 : 2019. 7. 1.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 근무제리스트 조회
	* @param request 
	* @param response
	* @return
	* @throws Exception
	*/
	@RequestMapping(value = "attendRequestMng/getAttendMyRequestList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttendMyRequestList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll((String)params.get("EndDate")));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("authMode", "A");

			String sortBy = request.getParameter("sortBy");
			
			String sortKey =  ( sortBy != null )? sortBy.split(" ")[0] : "";
			String sortDirec =  ( sortBy != null )? sortBy.split(" ")[1] : "";
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			resultList = attendRequestMngSvc.getAttendRequestList(params);
			
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
	 * @Method Name : cancelAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 취소
	 * @Method 설명 : 근무일정취소
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendRequestMng/cancelAttendRequest.do")
	public  @ResponseBody CoviMap cancelAttendRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List dataList = (List)params.get("dataList");
			CoviMap reqMap = new CoviMap();
			reqMap.put("ReqStatus", "ApprovalCancel");
			reqMap.put("ApprovalCode", SessionHelper.getSession("USERID"));
			reqMap.put("ApprovalComment", params.get("ApprovalComment"));

			CoviMap returnObj = new CoviMap();
			CoviMap resultCnt = attendReqSvc.changeAttendRequestStatus(reqMap, dataList);
			returnList.put("resultCnt", resultCnt.get("cnt"));
			returnList.put("notUpdateCount", resultCnt.get("notUpdateCount"));
			returnList.put("totalCnt", resultCnt.get("totalCnt"));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");

			
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
	 * @Method Name : cancelAttendRequest
	 * @작성일 : 2019. 6. 18.
	 * @작성자 :
	 * @변경이력 : 취소
	 * @Method 설명 : 근무일정취소
	 * @param request
	 * @param response
	 * @param ScMemSeq
	 * @param SchSeq
	 * @return
	 */
	@RequestMapping(value = "attendRequestMng/deleteAttendRequest.do")
	public  @ResponseBody CoviMap deleteAttendRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List dataList = (List)params.get("dataList");
			CoviMap reqMap = new CoviMap();

			CoviMap returnObj = new CoviMap();
			CoviMap resultCnt = attendReqSvc.deleteAttendRequest(reqMap, dataList);
			returnList.put("resultCnt", resultCnt.get("cnt"));
			returnList.put("notUpdateCount", resultCnt.get("notUpdateCount"));
			returnList.put("totalCnt", resultCnt.get("totalCnt"));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");

			
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

}
