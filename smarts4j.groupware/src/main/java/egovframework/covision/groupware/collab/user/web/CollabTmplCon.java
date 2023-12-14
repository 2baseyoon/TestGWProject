package egovframework.covision.groupware.collab.user.web;

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
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.LogHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabTmplSvc;

@Controller
@RequestMapping("collabTmpl")
public class CollabTmplCon {
	
	private Logger LOGGER = LogManager.getLogger(CollabTmplCon.class);
	LogHelper logHelper = new LogHelper();
	
	@Autowired
	CollabTmplSvc collabTmplSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
		* @Method Name : getTmplRequestList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 오청목록조회
		* @param request 
		* @param response
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "getTmplRequestList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getTmplRequestList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("reqStatus", request.getParameter("reqStatus"));
			
			resultList = collabTmplSvc.getTmplRequestList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("page", resultList.get("page"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//엑셀 다운
	@RequestMapping(value = "collabTmplRequestexcelTmplRequest.do")
	public ModelAndView excelTmplRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav		= new ModelAndView();
		CoviMap resultList	= new CoviMap();
		CoviMap viewParams		= new CoviMap();
		String returnURL		= "UtilExcelView";
		
		try {
			String[] headerNames = StringUtil.replaceNull(request.getParameter("headerName"), "").split("†");
			String[] headerKeys  = StringUtil.replaceNull(request.getParameter("headerKey"), "").split(",");
			/*CoviMap params = AttendUtils.requestToCoviMap(request);
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("UserCode", SessionHelper.getSession("UR_Code"));
			params.put("StartDate", AttendUtils.removeMaskAll((String)params.get("StartDate")));
			params.put("EndDate", AttendUtils.removeMaskAll((String)params.get("EndDate")));
			
			resultList = attendRequestMngSvc.getAttendRequestList(params);*/
			
			CoviMap convertList = new CoviMap();
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
	@RequestMapping(value = "approvalTmplRequest.do")
	public  @ResponseBody CoviMap approvalTmplRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			List dataList = (List)params.get("dataList");
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("approvalCode", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("approvalRemark", params.get("approvalRemark"));
			
			CoviMap returnObj= collabTmplSvc.approvalTmplRequest(reqMap, dataList);
			
			returnList.put("resultCnt", returnObj.get("resultCnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			//returnList.put("message", DicHelper.getDic("msg_50"));		//삭제되었습니다.

			
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
	@RequestMapping(value = "rejectTmplRequest.do")
	public  @ResponseBody CoviMap rejectTmplRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			List dataList = (List)params.get("dataList");
			CoviMap reqMap = new CoviMap();
			reqMap.put("reqStatus", "Reject");
			reqMap.put("approvalCode", SessionHelper.getSession("USERID"));
			reqMap.put("approvalComment", params.get("approvalComment"));

			//JSONObject returnObj = new CoviMap();
			CoviMap returnObj = collabTmplSvc.rejectTmplRequest(reqMap, dataList);

			returnList.put("resultCnt", returnObj.get("resultCnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			//returnList.put("message", DicHelper.getDic("msg_50"));		//삭제되었습니다.

			
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
	
	/**템플릿 삭제
	 */
	@RequestMapping(value = "deleteTmplRequest.do")
	public  @ResponseBody CoviMap deleteTmplRequest(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			List dataList = (List)params.get("dataList");
			reqMap.put("URCode", SessionHelper.getSession("USERID"));
			CoviMap returnObj= collabTmplSvc.deleteTmplRequest(reqMap, dataList);
			
			returnList.put("resultCnt", returnObj.get("resultCnt"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			//returnList.put("message", DicHelper.getDic("msg_50"));		//삭제되었습니다.

			
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
	
	//템플릿 조회
	@RequestMapping(value = "getTmplList.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getTmplList(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		CoviList returnArr = new CoviList();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("tmplKind", request.getParameter("tmplKind"));
			reqMap.put("tmplName", request.getParameter("tmplName"));
			
			CoviMap returnMap = collabTmplSvc.getTmplList(reqMap);
					
			returnObj.put("list",  returnMap.get("list"));
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;	

		
	}

	//템플릿 상세 화면
	@RequestMapping(value = "/CollabTmplViewPopup.do")
	public ModelAndView collabTmplViewPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabTmplViewPopup";
		ModelAndView mav		= new ModelAndView(returnURL);
		
		mav.addObject("mode", "VIEW");
		mav.addObject("tmplSeq", request.getParameter("tmplSeq"));
		mav.addObject("tmplName", request.getParameter("tmplName"));

		return mav;
	}
		
	//템플릿 수정세 화면
	@RequestMapping(value = "/CollabTmplSavePopup.do")
	public ModelAndView collabTmplSavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL		= "user/collab/CollabTmplViewPopup";
		ModelAndView mav		= new ModelAndView(returnURL);
		
		mav.addObject("mode", "MDF");
		mav.addObject("tmplSeq", request.getParameter("tmplSeq"));
		mav.addObject("tmplName", request.getParameter("tmplName"));

		return mav;
	}

	//템플릿 상세 조회
	@RequestMapping(value = "/getTmplMain.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getTmplMain(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("authSave", "MDF".equals(request.getParameter("mode"))?"Y":"N");
			reqMap.put("tmplSeq", Integer.parseInt(request.getParameter("tmplSeq")));
			CoviMap data = collabTmplSvc.getTmplMain(reqMap);
			
			returnObj.put("taskFilter", data.get("sectionList"));
			returnObj.put("taskData", data.get("taskData"));
			
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;		
	}

	@RequestMapping(value = "/changeTmplTaskOrder.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap changeTmplTaskOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("userCode", SessionHelper.getSession("USERID"));
			reqMap.put("tmplSeq", params.get("tmplSeq"));
			reqMap.put("sectionSeq", params.get("sectionSeq"));
			reqMap.put("taskSeq", params.get("taskSeq"));
			reqMap.put("workOrder", params.get("workOrder"));

			List ordTask = (List)params.get("ordTask");

			
			int cnt = collabTmplSvc.changeTmplTaskOrder(reqMap, ordTask );
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	//섹션 추가화면
	@RequestMapping(value = "/CollabTmplSectionPopup.do")
	public ModelAndView collabTmplSectionPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTmplSectionPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("tmplSeq", request.getParameter("tmplSeq"));
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("sectionName", request.getParameter("sectionName"));
		return mav;
	}
	
	//섹션 추가
	@RequestMapping(value = "/addTmplSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTmplSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("tmplSeq", request.getParameter("tmplSeq"));
			reqMap.put("sectionName", request.getParameter("sectionName"));
			
			result = collabTmplSvc.addTmplSection(reqMap);
			//returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	//섹션 수정
	@RequestMapping(value = "/saveTmplSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap saveTmplSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("sectionName", request.getParameter("sectionName"));
			
			result = collabTmplSvc.saveTmplSection(reqMap);
			//returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
		
	//섹션삭제
	@RequestMapping(value = "/deleteTmplSection.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTmplSection(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			
			collabTmplSvc.deleteTmplSection(reqMap);
			result.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	@RequestMapping(value = "/addTmplTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap addTmplTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("tmplSeq", request.getParameter("tmplSeq"));
			reqMap.put("sectionSeq", request.getParameter("sectionSeq"));
			reqMap.put("taskName", request.getParameter("taskName"));
			reqMap.put("remark", request.getParameter("remark"));
			reqMap.put("label", request.getParameter("label"));
			reqMap.put("parentKey", "0");
			reqMap.put("topParentKey", "0");
			reqMap.put("workOrder", "0");
			
			int cnt = collabTmplSvc.addTmplTask(reqMap);

			returnObj.put("PrjSeq", request.getParameter("tmplSeq"));
			returnObj.put("PrjType", "P");
			returnObj.put("SectionSeq", request.getParameter("sectionSeq"));
			returnObj.put("TaskName", request.getParameter("taskName"));
			returnObj.put("TaskSeq", reqMap.get("taskSeq"));
			returnObj.put("tmUser", "");
			returnObj.put("MemberCnt", "0");
			returnObj.put("CommentCnt", "0");
			returnObj.put("ProgRate", "0");
			returnObj.put("TaskStatus", "S");
			returnObj.put("ParenetKey", "0");
//			returnObj.put("taskName", request.getParameter("prjSeq"));
			returnObj.put("status", Return.SUCCESS);			

			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	@RequestMapping(value = "/saveTmplTask.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveTmplTask(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq",  request.getParameter("taskSeq"));
			reqMap.put("taskName",  request.getParameter("taskName"));
			reqMap.put("remark", request.getParameter("remark"));
			reqMap.put("label", request.getParameter("label"));

			reqMap.put("saturDay", "Y");
			reqMap.put("sunDay", "Y");
			reqMap.put("holiDay", "Y");
			int result = collabTmplSvc.saveTmplTask(reqMap);
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;

		
	}
	
	
	//삭제
	@RequestMapping(value = "/deleteTmplTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap deleteTmplTask(HttpServletRequest request) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("taskSeq", request.getParameter("taskSeq"));
			
			int cnt = collabTmplSvc.deleteTmplTask(reqMap);
			
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnObj;
	}
	
	//업쿠 복사 화면
	@RequestMapping(value = "/CollabTmplTaskCopyPopup.do")
	public ModelAndView collabTmplTaskCopyPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTmplTaskCopyPopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("taskSeq", request.getParameter("taskSeq"));
		mav.addObject("taskName", request.getParameter("taskName"));
		return mav;
	}
	
	//복사
	@RequestMapping(value = "/copyTmplTask.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap copyTmplTask(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap result = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();

			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("orgTaskSeq", request.getParameter("orgTaskSeq"));
			reqMap.put("taskName", request.getParameter("taskName"));
			
			int cnt = collabTmplSvc.copyTmplTask(reqMap);
			result.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			result.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			result.put("status", Return.FAIL);
			//returnObj.put("message", isDevMode?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;

		
	}
	
	//타스트 수정 화면
	@RequestMapping(value = "/CollabTmplTaskSavePopup.do")
	public ModelAndView collabTmplTaskSavePopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL	= "user/collab/CollabTmplTaskSavePopup";
		ModelAndView mav	= new ModelAndView(returnURL);
		if (!ComUtils.nullToString(request.getParameter("taskSeq"),"").equals("")){
			CoviMap reqMap = new CoviMap();
			reqMap.put("taskSeq", Integer.parseInt(request.getParameter("taskSeq")));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			CoviMap data = collabTmplSvc.getTmplTask(reqMap);
			mav.addObject("taskData", data.get("taskData"));
		}
		mav.addObject("sectionSeq", request.getParameter("sectionSeq"));
		mav.addObject("prjName", request.getParameter("prjName"));
		mav.addObject("sectionName", request.getParameter("sectionName"));
		return mav;
	}
	
}
