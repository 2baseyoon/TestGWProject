package egovframework.covision.coviflow.manage.web;


import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
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
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.admin.service.MonitoringSvc;
import egovframework.covision.coviflow.common.util.RequestHelper;



@Controller
public class MonitoringManageCon {
	
	private Logger LOGGER = LogManager.getLogger(MonitoringManageCon.class);

	@Autowired
	private MonitoringSvc monitoringSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "manage/monitoring.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringPopup(HttpServletRequest request, Locale locale, Model model) throws Exception
	{
		String returnURL = "manage/approval/Monitoring";
		ModelAndView mav = new ModelAndView(returnURL);
		
		CoviMap formJson = new CoviMap();
		CoviMap requestData = new CoviMap();
		
		String pFormInstId = StringUtil.replaceNull(request.getParameter("FormInstID"), "");
		
		requestData.put("mode", "CFADMIN");

		// 필요한 데이터에 한하여 구성
		formJson.put("SchemaContext", monitoringSvc.getFormSchema(pFormInstId));
		formJson.put("Request", requestData);
		
		mav.addObject("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
		
		return mav;
	}
	
	@RequestMapping(value = "manage/monitoringFormInstPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringFormInstPopup(Locale locale, Model model)
	{
		String returnURL = "manage/approval/MonitoringFormInstPopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringActivitiPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringActivitiPopup(Locale locale, Model model)
	{
		String returnURL = "manage/approval/MonitoringActivitiPopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringDomaindataPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringDomaindataPopup(Locale locale, Model model)
	{
		String returnURL = "manage/approval/MonitoringDomaindataPopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringUpdatePopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringUpdatePopup(Locale locale, Model model)
	{
		String returnURL = "manage/approval/MonitoringUpdatePopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringVariablePopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringVariablePopup(Locale locale, Model model)
	{
		String returnURL = "admin/approval/monitoringVariablePopup";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringApprovalPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringApprovalPopup(Locale locale, Model model)
	{
		String returnURL = "manage/approval/MonitoringApproval";
		return new ModelAndView(returnURL);
	}
	
	@RequestMapping(value = "manage/monitoringApprovalOnlyCommentPopup.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView monitoringApprovalOnlyCommentPopup(HttpServletRequest request, Locale locale, Model model)
	{
		String mode = request.getParameter("mode");
		
		String returnURL = "manage/approval/monitoringApprovalOnlyCommentPopup";
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("mode", mode);
		
		return mav;
	}
	
	/**
	 * getForminstance
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/getforminstance.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getForminstance(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String fiid = request.getParameter("fiid");
			
			returnList.put("list", monitoringSvc.getFormInstance(fiid));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * FormInstance 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/setforminstance.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setForminstance(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			
			String fiid = request.getParameter("fiid");
			String formInstData = StringEscapeUtils.unescapeHtml(request.getParameter("formInstData"));
			StringBuilder updateQuery = new StringBuilder();
			CoviMap formInstDataObj = CoviMap.fromObject(formInstData);
			
			param.put("fiid", fiid);
			param.put("FormInstID",formInstDataObj.getString("FormInstID"));
			param.put("ProcessID",formInstDataObj.getString("ProcessID"));
			param.put("SchemaID",formInstDataObj.getString("SchemaID"));
			param.put("InitiatorID",formInstDataObj.getString("InitiatorID"));
			param.put("InitiatorUnitID",formInstDataObj.getString("InitiatorUnitID"));
			param.put("InitiatedDate",formInstDataObj.getString("InitiatedDate"));
			param.put("DeletedDate",formInstDataObj.getString("DeletedDate"));
			param.put("EntName",formInstDataObj.getString("EntName"));
			param.put("DocLevel",formInstDataObj.getString("DocLevel"));
			param.put("DocClassName",formInstDataObj.getString("DocClassName"));
			param.put("AttachFileInfo",formInstDataObj.getString("AttachFileInfo"));
			param.put("SaveTerm",formInstDataObj.getString("SaveTerm"));
			param.put("AppliedTerm",formInstDataObj.getString("AppliedTerm"));
			param.put("ReceiveNames",formInstDataObj.getString("ReceiveNames"));
			param.put("BodyType",formInstDataObj.getString("BodyType"));
			param.put("BodyContext",formInstDataObj.getString("BodyContext"));
			param.put("FormID",formInstDataObj.getString("FormID"));
			param.put("Subject",formInstDataObj.getString("Subject"));
			param.put("InitiatorName",formInstDataObj.getString("InitiatorName"));
			param.put("InitiatorUnitName",formInstDataObj.getString("InitiatorUnitName"));
			param.put("CompletedDate",formInstDataObj.getString("CompletedDate"));
			param.put("EntCode",formInstDataObj.getString("EntCode"));
			param.put("DocNo",formInstDataObj.getString("DocNo"));
			param.put("DocClassID",formInstDataObj.getString("DocClassID"));
			param.put("IsPublic",formInstDataObj.getString("IsPublic"));
			param.put("AppliedDate",formInstDataObj.getString("AppliedDate"));
			param.put("ReceiveNo",formInstDataObj.getString("ReceiveNo"));
			param.put("ReceiptList",formInstDataObj.getString("ReceiptList"));
			param.put("DocLinks",formInstDataObj.getString("DocLinks"));
			
			returnList.put("list", monitoringSvc.setFormInstance(param));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}	
	
	/**
	 * 결재선 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/setDomainListData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setDomainListData(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			String formInstID = request.getParameter("FormInstID");
			String processID = request.getParameter("ProcessID");
			String taskID = request.getParameter("taskID");
			String domainDataContext = StringEscapeUtils.unescapeHtml(request.getParameter("DomainDataContext"));
			String comment = StringEscapeUtils.unescapeHtml(request.getParameter("Comment"));
			
			CoviMap param = new CoviMap();
			param.put("FormInstID", formInstID);
			param.put("ProcessID", processID);
			param.put("DomainDataContext", domainDataContext);
			
			//의견 작성 시 문서함 목록에서 의견 아이콘 표시
			if( comment != null && !comment.equals("") ) {
				monitoringSvc.setIsComment(param);
			}
			
			CoviMap domainDataObj = CoviMap.fromObject(domainDataContext); // 사용자입력이기때문에 \t , \n 등 데이터 변환을위해 CoviMap 로 받아서 string으로 변환한다
			
			monitoringSvc.setDomainData(param);
			monitoringSvc.setActivitiVariable(taskID, "g_appvLine", domainDataObj.toString());
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}	
	
	/**
	 * 이후 결재선 개수 수정되었을 때, Description 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/setProcessStep.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setProcessStep(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			String processID = request.getParameter("ProcessID");
			String stepTotalCount = request.getParameter("stepTotalCount");
			
			CoviMap param = new CoviMap();
			param.put("ProcessID", processID);
			param.put("stepTotalCount", stepTotalCount);
			
			monitoringSvc.setProcessStep(param);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * 현결재자가 변경되었을 경우, Workitem 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/setWorkitemData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setWorkitemData(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String workitemID = request.getParameter("WorkitemID");
			String chargeId = request.getParameter("chargeId");
			String chargeName = request.getParameter("chargeName");
			String deputyID = request.getParameter("deputyID");
			String deputyName = request.getParameter("deputyName");
			
			CoviMap param = new CoviMap();
			param.put("WorkitemID", workitemID);
			param.put("chargeId", chargeId);
			param.put("chargeName", chargeName);
			param.put("deputyID", deputyID);
			param.put("deputyName", deputyName);
			
			monitoringSvc.setWorkitemData(param);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * 현 결재자 변경 되었을 경우, Description 데이터 수정
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/setDescriptionData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setDescriptionData(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			String processID = request.getParameter("ProcessID");
			String chargeName = request.getParameter("chargeName");
			String chargeCode = request.getParameter("chargeCode");
			
			CoviMap param = new CoviMap();
			param.put("ProcessID", processID);
			param.put("chargeName", chargeName);
			param.put("chargeCode", chargeCode);
			
			monitoringSvc.setDescriptionData(param);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	//getSuperAdminData.do
	@RequestMapping(value = "manage/getSuperAdminData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getSuperAdminData(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String superadminID = "SuperAdmin";
			
			CoviMap param = new CoviMap();
			param.put("userID", superadminID);			
			returnList = monitoringSvc.getSuperAdminData(param);
			
			returnList.put("result", returnList);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
		
	/**
	 * getprocinfo : 프로세스 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getprocinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getProcInfo(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String fiid = request.getParameter("fiid");
			
			returnList.put("list", monitoringSvc.getProcessList(fiid));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	/**
	 * getActProcInfo : 프로세스 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getactprocdef.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getActProcDef(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			returnList.put("list", monitoringSvc.getActivitiProcessDefinition());
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getActProcInfo : 프로세스 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getactprocinfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getActProcInfo(HttpServletRequest request, 
			@RequestParam(value = "piid", required = true, defaultValue = "") String piid) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			returnList.put("list", monitoringSvc.getActivitiProcessList(piid));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getActTasks : task 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getacttasks.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getActTasks(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String piid = request.getParameter("piid");			
			returnList.put("list", monitoringSvc.getActivitiTasks(piid));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getActVariables : variables 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getactvariables.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getActVariables(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String taskId = request.getParameter("taskid");			
			returnList.put("list", monitoringSvc.getActivitiVariables(taskId));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getProcDesc : process description 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getprocdesc.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getProcDesc(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String pdescId = request.getParameter("pdescid");			
			returnList.put("list", monitoringSvc.getProcessDesc(pdescId));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getWorkitem : workitem 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getworkitem.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkitem(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String piid = request.getParameter("piid");			
			returnList.put("list", monitoringSvc.getWorkitem(piid));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * getDomaindata : 결재선 정보
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/getdomaindata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDomaindata(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String piid = request.getParameter("piid");			
			returnList.put("list", monitoringSvc.getDomaindata(piid));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	/**
	 * doAction : rest api 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "manage/doaction.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap doAction(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String taskId = paramMap.get("id");
			//CoviMap data = CoviMap.fromObject(paramMap.get("data"));
			CoviMap data = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("data")));
			String formInstID = paramMap.get("formInstID");
			boolean isAborted = false;
			boolean isAccountDoc = false;
			CoviMap approvalLine = null;
			CoviList commentFileInfos = null;
			
			CoviList variables = new CoviList();
			for (Object key : data.keySet()) {
				String keyStr = (String) key;
				
				if(keyStr.equals("isAccount") && data.get(keyStr).equals("Y")) {
					isAccountDoc = true;
					continue;
				}
				
				// 기안 취소인치 체크
				if(data.get(keyStr).equals("WITHDRAW") || data.get(keyStr).equals("ABORT")) {
					isAborted = true;
				}
				if(isAborted && keyStr.indexOf("g_appvLine") > -1) {
					approvalLine = (CoviMap) data.get(keyStr);
					continue; // 기안취소 시에는 결재선 변경 없음. 최종결재선 저장하기 위한 용도
				}
				if(isAborted && keyStr.indexOf("commentFileInfos") > -1) {
					commentFileInfos = CoviList.fromObject(data.getString(keyStr));
					continue;
				}

				CoviMap variable = new CoviMap();
				variable.put("name", keyStr);
				variable.put("value", data.get(keyStr));
				variable.put("scope", "global");
				
				variables.add(variable);
			}
						
			CoviMap param = new CoviMap();
			param.put("action", "complete");
			param.put("variables", variables);
			
			monitoringSvc.doAction(taskId, param);
			
			//문서발번 처리
			if(!formInstID.equals(""))
				monitoringSvc.updateFormInstDocNumber(formInstID);
				
			// 기안 취소일 경우, 본문 임시함에 저장
			// e-Accounting 문서는 임시함 저장 X
			if(isAborted && !isAccountDoc) {
				monitoringSvc.abortProcessFormData(formInstID, approvalLine, commentFileInfos);
			}
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "manage/doGetFormInfo.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap doGetFormInfo(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pFormInstID = paramMap.get("FormInstID");
			
			CoviMap returnData = monitoringSvc.makeFormObj(pFormInstID);
			
			returnList.put("data", returnData.toString());
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}  catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "manage/getDiagaram.do", method=RequestMethod.GET)
	public @ResponseBody void getDiagaram(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String result = "";
		try {
			String pProcessID = StringUtil.replaceNull(request.getParameter("processID"), "");
			
			String pURL = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
			pURL += "/service/runtime/process-instances/" + pProcessID + "/diagram";
			
			result = RequestHelper.sendGETForStream(pURL, request, response);
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
			result = returnList.toString();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			result = returnList.toString();
		}finally {
			if(!result.equals("OK")) {
				response.setHeader("Content-Type", "text/plain");
			    response.setHeader("success", "yes");
			    response.setCharacterEncoding("utf-8");
			    PrintWriter writer = response.getWriter();
			    writer.write(result);
			    writer.close();
			}
		}
	}
	
	@RequestMapping(value = "manage/getactvariable.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getActVariable(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();		
		try {
			String taskId = request.getParameter("taskid");
			String name = request.getParameter("name");
			
			returnList.put("list", monitoringSvc.getActivitiVariable(taskId, name));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;		
	}
	
	@RequestMapping(value = "manage/setActivitiVariable.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap setActivitiVariable(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {			
			String taskId = request.getParameter("taskid");
			String name = request.getParameter("name");
			String value = StringEscapeUtils.unescapeHtml(request.getParameter("value"));
			String type = request.getParameter("type");
			
			if(StringUtil.replaceNull(type, "").equalsIgnoreCase("json")) value = (CoviMap.fromObject(value)).toString(); // 사용자입력이기때문에 \t , \n 등 데이터 변환을위해 CoviMap 로 받아서 string으로 변환한다
			
			monitoringSvc.setActivitiVariable(taskId, name, value);
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
}
