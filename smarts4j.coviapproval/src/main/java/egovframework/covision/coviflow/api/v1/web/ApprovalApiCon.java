package egovframework.covision.coviflow.api.v1.web;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.api.v1.service.ApprovalApiSvc;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.govdocs.service.OpenDocSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;
import egovframework.covision.coviflow.user.service.DeptApprovalListSvc;
import egovframework.covision.coviflow.user.service.JobFunctionListSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;
import egovframework.covision.coviflow.user.service.UserBizDocListSvc;
import egovframework.covision.coviflow.user.service.SignRegistrationSvc;



@Controller
@RequestMapping(value = "api/v1")
public class ApprovalApiCon {
	@Autowired
	private ApprovalApiSvc approvalApiSvc;

	@Autowired
	private ApvProcessSvc apvProcessSvc;

	@Autowired
	private FormSvc formSvc;

	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	@Autowired
	private OpenDocSvc openDocSvc;
	
	@Autowired
	private ApprovalListSvc approvalListSvc;

	@Autowired
	private DeptApprovalListSvc deptApprovalListSvc;
	
	@Autowired
	private JobFunctionListSvc jobFunctionListSvc;
	
	@Autowired
	private UserBizDocListSvc userBizDocListSvc;
	
	@Autowired
	private SignRegistrationSvc SignRegistrationSvc;
	
	@Autowired
	private FileUtilService fileUtilService;
	
	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	private static final String SERVICE_TYPE = "ApprovalSign";

	private static final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	/**
	 * 개인함 결재건수 , 부서함 결재건수
	 * /api/approval/user/count , /api/approval/dept/count
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getApprovalCntAll.do",  method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap selectApprovalCntAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList cntList = new CoviList();
		try{
			CoviMap params = new CoviMap();
			
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("ApprovalParentGR_Code");
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String listType = StringUtil.replaceNull(request.getParameter("listType"));
			String boxList = StringUtil.replaceNull(request.getParameter("boxList"));
			
			params.put("userID", userID);
			params.put("UserCode", userID);
			params.put("deptID", deptID);

			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			String configCnt = RedisDataUtil.getBaseConfig("ApprovalBoxListCnt");
			if(!boxList.equals("")) configCnt = boxList;
			else if(configCnt.equals("")) {
				switch(listType) {
					case "USER": configCnt = "U_Approval;U_Process"; break;
					case "DEPT": configCnt = "D_Receive;D_DeptProcess"; break;
					default: configCnt = "U_Approval;U_Process;D_Receive;D_DeptProcess"; break;
				}
			}
			//String[] configUser = Arrays.stream(configCnt.split(";")).filter(item -> item.startsWith("U_")).toArray(String[]::new);
			for(String item : configCnt.split(";")) {
				if(item.startsWith("U_") && !listType.equalsIgnoreCase("DEPT")) {
					CoviMap tmpCnt = new CoviMap();
					tmpCnt.put("type", item);
					switch(item) {
						case "U_Approval":
							tmpCnt.put("cnt", approvalListSvc.selectApprovalCnt(params));
							break;
						case "U_Process":
							tmpCnt.put("cnt", approvalListSvc.selectProcessCnt(params));
							break;
						case "U_TCInfo":
							tmpCnt.put("cnt", approvalListSvc.selectTCInfoNotDocReadCnt(params));
							break;
						default:
							params.put("listGubun", item);
							tmpCnt.put("cnt", approvalListSvc.selectUserBoxListCnt(params));
							break;
					}
					cntList.add(tmpCnt);
				}else if(item.startsWith("D_") && !listType.equalsIgnoreCase("USER")) {
					CoviMap tmpCnt = new CoviMap();
					tmpCnt.put("type", item);
					switch(item) {
						case "D_Receive":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptReceptionCnt(params));
							break;
						case "D_DeptProcess":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptProcessCnt(params));
							break;
						case "D_DeptTCInfo":
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptTCInfoNotDocReadCnt(params));
							break;
						default:
							params.put("listGubun", item);
							tmpCnt.put("cnt", deptApprovalListSvc.selectDeptBoxListCnt(params));
							break;
					}
					cntList.add(tmpCnt);
				}
			}
			
			returnList.put("list", cntList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;

	}
	
	/**
	 * 결재문서 상세 조회
	 * /api/approval/form/data
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getFormData.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectFormData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try{
			CoviMap params = new CoviMap(paramMap);
			
			returnList = approvalApiSvc.getFormData(params);
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL.toString());
			returnList.put("message", npE.getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL.toString());
			returnList.put("message", e.getMessage());
		}

		return returnList;
	}

	/**
	 * 결재문서 상세 조회(Snapshot)
	 * /api/approval/form/pdf
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getFormPdf.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public void downFormPdf(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap pdfResult = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);
		
			CoviMap formInfo = new CoviMap();
			formInfo = approvalApiSvc.getFormData(params);
			
			if(formInfo.optString("status").equals(Return.SUCCESS.toString())) {
				pdfResult = approvalApiSvc.getFormPdf(request, response, formInfo);
			}else {
				pdfResult.put("status", formInfo.optString("status"));
				pdfResult.put("message", formInfo.optString("message"));
			}
		}catch(NullPointerException e){
			pdfResult.put("status", Return.FAIL.toString());
			pdfResult.put("message", e.getMessage());
	    }
	    catch(Exception e){
	    	pdfResult.put("status", Return.FAIL.toString());
			pdfResult.put("message", e.getMessage());
	    }
	    finally {
	    	if(pdfResult.optString("status").equals(Return.FAIL.toString())) {
	    		// throw new Exception(pdfResult.optString("message"));
	    		response.reset();
				//response.setContentType("text/html;charset=UTF-8");
	    		response.setContentType("tapplication/json;charset=UTF-8");
				try(PrintWriter out = response.getWriter();){
					// html 타입 오류 리턴
					//out.println("<script language='javascript'>alert('" + pdfResult.optString("message") + "');</script>");
					// json 타입 오류 리턴
					CoviMap rtnMap = new CoviMap();
					rtnMap.put("status", pdfResult.optString("status"));
					rtnMap.put("message", pdfResult.optString("message"));
					out.write(rtnMap.toString());
				}
			} 
	    }
	}
	
	/**
	 * 결재문서 승인반려
	 * /api/approval/process
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/process.do",  method = {RequestMethod.POST})
	public @ResponseBody CoviMap doProcess(HttpServletRequest request, HttpServletResponse response, @RequestBody CoviMap params) throws Exception {
		CoviMap result = new CoviMap();	
		try{
//			CoviMap params = new CoviMap(request.getParameterMap());
			
//			String formStr = new String(Base64.decodeBase64(request.getParameter("formObj").toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
//			CoviMap formObj = egovframework.covision.coviflow.common.util.ComUtils.removeFormXSS(formStr);
			
//			if(formObj.isNullObject())
//				throw new IllegalArgumentException();
			
//			List<MultipartFile> mf = request.getFiles("fileData[]");
			
			CoviMap formObj = approvalApiSvc.getFormObjForProcess(params);
			
//			보안이슈 사용자 인증 체크 2021-01-18 dgkim
			String formID = formObj.optString("formID");
			String actionMode = formObj.getString("actionMode");
			String adminType = formObj.optString("adminType");
			if(adminType.equals("ADMIN") && !SessionHelper.getSession("isAdmin").equals("Y")) {
				adminType = "";
			}
			String reqFormInstID = formObj.optString("FormInstID");
			
			if(apvProcessSvc.getIsUsePasswordForm(formID) && !adminType.equals("ADMIN")) {
				if(!actionMode.equals("WITHDRAW") && !actionMode.equals("ABORT") && !actionMode.equals("APPROVECANCEL")  && !actionMode.equals("CHARGE")){
					boolean chkUsePasswordYN = false;						
					params.put("UR_CODE", SessionHelper.getSession("UR_Code"));
					CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
					if(resultList != null){
						CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
						if(map.optString("UseApprovalPassWord").equals("Y")) {
							chkUsePasswordYN = true;
						}
					}
					if( chkUsePasswordYN ) {
						result.put("status", Return.FAIL);
						result.put("message", "보안결재 문서입니다. 그룹웨어에서 결재를 진행해 주세요.");
						return result;
					}
				}
			}
			
			//첨부파일 확장자 체크
//			if(!FileUtil.isEnableExtention(mf)){
//				result.put("status", Return.FAIL);
//				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
//				return result;
//			}		

			// 다안기안 멀티 첨부 Start
//			CoviMap multiFileList = new CoviMap();
//			Map<String, MultipartFile> list = request.getFileMap();
//			
//			Iterator<String> keys = list.keySet().iterator();
//			while(keys.hasNext()){
//				String key = keys.next();
//				if(key.equals("fileData[]")){
//					list.remove(key);
//				} else {
//					multiFileList.put(key, request.getFiles(key));
//				}
//			}
			// 다안기안 멀티 첨부 End
			
			//결재 유효값 확인
			boolean returnVal = true;		

			if (returnVal) {
				// 본문 저장관련해서 호출 분리함.
				CoviMap processFormDataReturn = new CoviMap();
				processFormDataReturn.put("formObj", formObj);
				
//				if(multiFileList.size() > 0){
//					processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf, multiFileList);
//				} else {
//					processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
//				}
				
				if(actionMode.equals("WITHDRAW") || actionMode.equals("ABORT")) {
					formObj.put("gloct", "PROCESS"); //취소시 임시함에 저장하기 위함. processFormData
					formObj.put("ProcessDescription", new CoviMap());
					processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, null);
				}
								
				// 기안 및 승인
				try {
					// formObj 가공
					String formInstID = apvProcessSvc.doProcess(formObj, processFormDataReturn);
					//문서발번 처리
					if(!formInstID.equals(""))
						apvProcessSvc.updateFormInstDocNumber(formInstID);
				}catch(NullPointerException npE) {
					throw npE;
				}catch(Exception e) {
					throw e;
				}
				
				
				// 알림 처리
				try {
					String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/setTimeLineData.do";
					HttpsUtil httpsUtil = new HttpsUtil();
					httpsUtil.httpsClientWithRequest(url, "POST", formObj, "UTF-8", null);
				} catch(NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				} catch(Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
				
				try {
					String mode = "";
					if (!formObj.isEmpty() && formObj.has("mode"))
						mode = formObj.optString("mode").toUpperCase();
					if("ADMIN".equals(mode)) {
						// 관리자에서 문서를 편집한경우. (완료문서를)
						if(formObj.has("SchemaID")) {
							CoviMap paramsSchema = new CoviMap();
							String strSchemaID = formObj.getString("SchemaID");
							paramsSchema.put("schemaID", strSchemaID);
							CoviMap formSchema = ((CoviList)(formSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0);
							
							if(!formSchema.get("SchemaContext").equals("")) {
								CoviMap schemaContext = formSchema.getJSONObject("SchemaContext");
								if(schemaContext.has("scPubOpenDoc") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scPubOpenDoc").getString("isUse"))) {
									paramsSchema.clear();
									paramsSchema.put("formInstID", formObj.getString("FormInstID"));
									openDocSvc.updateOpenDocInfo(paramsSchema);
								}
							}
							
						}
					}
					result.put("FormInstID", formObj.getString("FormInstID"));
					result.put("processID", formObj.getString("processID"));
				}catch(NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
				result.put("status", Return.SUCCESS);
				result.put("message", DicHelper.getDic("msg_apv_170"));
			}else {
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_apv_030"));
			}
			
		}catch(FileNotFoundException e) {
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}catch(NullPointerException npE){
			Throwable c = npE;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage() == null ? DicHelper.getDic("msg_apv_030") : c.getMessage());
		}catch(Exception e){
			Throwable c = e;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage());
		}
		return result;
	}
	
	/**
	 * 사용자별 담당업무함 목록 조회 : 사용자에게 권한이 부여된 담당업무 목록 조회
	 * /api/approval/jobfunction/user/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getJobFunctionUserList.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getJobFunctionUserList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap list = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String userCode = SessionHelper.getSession("USERID");
			String entCode = SessionHelper.getSession("DN_Code");
			String JobFunctionType = request.getParameter("JobFunctionType");

			params.put("isSaaS", isSaaS);
			params.put("userCode", userCode);
			params.put("entCode", entCode);
			params.put("JobFunctionType", JobFunctionType);
			
			list = jobFunctionListSvc.selectJobFunctionListData(params);
			
			returnList.put("list", list.containsKey("list") ? list.getJSONArray("list") : new CoviList());
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "처리되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	 * 담당업무함별 결재문서 목록 조회 : 담당업무의 미결/진행/완료/반려함 목록 조회
	 * /api/approval/jobfunction/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getJobFunctionListAll.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getJobFunctionListAll(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			
			String jobFunctionCode = StringUtil.replaceNull(request.getParameter("jobFunctionCode"));
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			String listType = StringUtil.replaceNull(request.getParameter("listType"));
			
			String searchType =  StringUtil.replaceNull(request.getParameter("searchType"));
			String searchWord =  StringUtil.replaceNull(request.getParameter("searchWord"));
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  StringUtil.replaceNull(request.getParameter("searchGroupWord"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("jobFunctionCode", jobFunctionCode);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			} else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = jobFunctionListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			if("APP".equals(listType)) {
				resultList = jobFunctionListSvc.selectJobFunctionApprovalListData(params);
			} else if("PROCESS".equals(listType)) {
				resultList = jobFunctionListSvc.selectJobFunctionProcessListData(params);
			} else if("COMPLETE".equals(listType)) {
				resultList = jobFunctionListSvc.selectJobFunctionCompleteListData(params);
			} else if("REJECT".equals(listType)) {
				resultList = jobFunctionListSvc.selectJobFunctionRejectListData(params);
			} else {
				throw new Exception();
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * 사용자 개인함 목록 조회
	 * /api/approval/user/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getApprovalListAll.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap selectApprovalListAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try	{
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String viewStartDate = "";
			String viewEndDate = "";
		
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String formSubject = request.getParameter("formSubject");
			String initiatorName = request.getParameter("initiatorName");
			String initiatorUnitName = request.getParameter("initiatorUnitName");
			String formName = request.getParameter("formName");
			String docNo = request.getParameter("docNo");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
			String titleNm 	= request.getParameter("titleNm");
			String userNm 	= request.getParameter("userNm");
			String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-사용자문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
			String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
			String dbName = "COVI_APPROVAL4J_ARCHIVE";
			String submode = (bstored.equals("true") && request.getParameter("submode") != null && StringUtil.replaceNull(request.getParameter("submode")).equals("Admin") ? "ADMIN" : ""); // 20210126 이관함 > 관리자문서함
			if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO"))
				dbName = "COVI_APPROVAL4J";
			if(bstored.equals("true"))
				dbName = "COVI_APPROVAL4J_STORE";
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));
			
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			
			String companyCode = request.getParameter("companyCode");
			String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
			
			CoviMap resultList = null;
			CoviMap page = null;
			if(userID != null && !userID.equals("")){
				CoviMap params = new CoviMap();
	
				params.put("userID", userID);
				params.put("searchType", searchType);
				params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
				params.put("searchGroupType", searchGroupType);
				
				if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
					params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
				}
				else {
					params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
				}
				
				params.put("formSubject", ComUtils.RemoveSQLInjection(formSubject, 100));
				params.put("initiatorName", ComUtils.RemoveSQLInjection(initiatorName, 100));
				params.put("initiatorUnitName", ComUtils.RemoveSQLInjection(initiatorUnitName, 100));
				params.put("formName", ComUtils.RemoveSQLInjection(formName, 100));
				params.put("docNo", ComUtils.RemoveSQLInjection(docNo, 100));
				
				if(StringUtil.isNotEmpty(startDate)) {
					params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
					params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
				}
				else {
					params.put("startDate", ComUtils.ConvertDateToDash(startDate));
					params.put("endDate", ComUtils.ConvertDateToDash(endDate));
				}
				params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
				params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
				params.put("mode", mode);
				params.put("adminYn", adminYn);
				params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
				params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
				params.put("pageSize", pageSize);
				params.put("pageNo", pageNo);
				params.put("DBName", dbName);
				
				// 20210126 이관함 관리자 추가
				params.put("submode", submode);
				
				// 통합결재 조건 추가
				String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
				if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
					params = approvalListSvc.getApprovalListCode(params, businessData1);	
				} else {
					params.put("isApprovalList", "X");
				}
				
				// 겸직자 개인함 법인별 보기 옵션 추가 사용 시 파라미터 추가
				String useIsUseAddJobApprovalList = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList")) ? RedisDataUtil.getBaseConfig("IsUseAddJobApprovalList") : "N"; // 개인함겸직자법이별보기 사용여부(기본값: N)
				if(useIsUseAddJobApprovalList.equalsIgnoreCase("Y")) {
					params.put("companyCode",companyCode);
				}else {
					params.put("companyCode","");
				}

				if(StringUtil.isNotEmpty(viewStartDate)) {
					params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
				}
				if(StringUtil.isNotEmpty(viewEndDate)) {
					params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
				}
				
				// [211021 add]문서연결 창 조건 추가
				params.put("requestType",requestType);
				
				resultList = approvalListSvc.selectApprovalList(params);
				page = resultList.getJSONObject("page");
			}else{
				resultList = new CoviMap();
				page = new CoviMap();
				
				resultList.put("list", new CoviList());
				resultList.put("cnt", 0);
				
				page.put("pageCount", 1);
				page.put("listCount", 0);
			}

			returnList.put("page", page);
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
				
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * 사용자 부서함 목록 조회
	 * /api/approval/dept/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getDeptApprovalListAll.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptApprovalListAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		boolean bhasAuth = false;
		try	{

			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String deptID = SessionHelper.getSession("ApprovalParentGR_Code");

			String viewStartDate = "";
			String viewEndDate = "";

			String searchType = StringUtil.replaceNull(request.getParameter("searchType"),"Subject");
			String searchWord = request.getParameter("searchWord");
			String encodeSearchWord = request.getParameter("encodeSearchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"));
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String mode 	= StringUtil.replaceNull(request.getParameter("mode"));
			String titleNm 	= request.getParameter("titleNm");
			String userNm 	= request.getParameter("userNm");
			String adminYn 	= request.getParameter("adminYn"); //관리자-전자결재-부서문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함)
			String bstored 	= StringUtil.replaceNull(request.getParameter("bstored"));
			String dbName = "COVI_APPROVAL4J_ARCHIVE";
			if(mode.equalsIgnoreCase("DEPTTCINFO"))
				dbName = "COVI_APPROVAL4J";
			if(bstored.equals("true"))
				dbName = "COVI_APPROVAL4J_STORE";
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));				
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			
			String requestType = request.getParameter("requestType") == null ? "" : request.getParameter("requestType");
			
			CoviMap params = new CoviMap();
			if(searchType.equals("Subject")){
				searchType = "FormSubject";
			}

			params.put("deptID", deptID);
			params.put("userID", userID);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			params.put("encodeSearchWord", encodeSearchWord);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			
			if(StringUtil.isBlank(startDate)) {
				params.put("startDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
				params.put("endDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			}
			else {
				params.put("startDate", ComUtils.ConvertDateToDash(startDate));
				params.put("endDate", ComUtils.ConvertDateToDash(endDate));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("mode", mode);
			params.put("adminYn", adminYn);
			params.put("titleNm", ComUtils.RemoveSQLInjection(titleNm, 100));
			params.put("userNm", ComUtils.RemoveSQLInjection(userNm, 100));
			params.put("pageSize", pageSize);
			params.put("pageNo", pageNo);
			params.put("DBName", dbName);
			
			// 통합결재 조건 추가
			String useTotalApproval = StringUtil.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부(기본값: N)
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = deptApprovalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}

			if(StringUtil.isNotEmpty(viewStartDate)) {
				params.put("viewStartDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewStartDate.equals("") ? "" : viewStartDate + " 00:00:00")));
			}
			if(StringUtil.isNotEmpty(viewEndDate)) {
				params.put("viewEndDate", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(viewEndDate.equals("") ? "" : viewEndDate + " 00:00:00")));
			}

			// [211021 add]문서연결 창 조건 추가
			params.put("requestType",requestType);
			
			CoviMap resultList = deptApprovalListSvc.selectDeptApprovalList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");


		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * 사용자별 업무문서함 목록 조회 : 사용자에게 권한이 부여된 업무문서함 목록 조회
	 * /api/approval/bizdoc/user/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getBizDocUserList.do")
	public @ResponseBody CoviMap getBizDocListUserList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			
			String userCode = SessionHelper.getSession("USERID");
			String bizDocType = request.getParameter("BizDocType");
			
			params.put("userCode", userCode);
			params.put("bizDocType", bizDocType);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			
			resultList = userBizDocListSvc.selectBizDocListData(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * 업무문서함 결재문서 목록 조회 : 업무문서함의 진행/완료함 목록 조회
	 * /api/approval/bizdoc/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "/getBizDocListAll.do")
	public @ResponseBody CoviMap getBizDocListAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			CoviMap params = new CoviMap();
			
			String userCode = SessionHelper.getSession("USERID");
			String deptCode = SessionHelper.getSession("DN_Code");
			String bizDocCode = StringUtil.replaceNull(request.getParameter("bizDocCode"));
			String listType = StringUtil.replaceNull(request.getParameter("listType"));
			
			String searchType =  StringUtil.replaceNull(request.getParameter("searchType"));
			String searchWord =  StringUtil.replaceNull(request.getParameter("searchWord"));
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  StringUtil.replaceNull(request.getParameter("searchGroupWord"));
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			String pageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
			String pageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");
			
			params.put("userCode", userCode);
			params.put("entCode", deptCode);
			params.put("isSaaS", isSaaS);
			params.put("bizDocCode", bizDocCode);
			
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if("PROCESS".equals(listType)) {
				resultList = userBizDocListSvc.selectBizDocProcessListData(params);
			} else if("COMPLETE".equals(listType)) {
				resultList = userBizDocListSvc.selectBizDocCompleteLisData(params);
			} else {
				throw new Exception();
			}
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	/**
	 * 대결 설정
	 * /api/approval/user/deputy
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/setDeputy.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap setdeputy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try	{
			CoviMap params = new CoviMap();
			String deputyCode = request.getParameter("deputyCode");
			String deputyName = request.getParameter("deputyName");
			String deputyFromDate = request.getParameter("deputyFromDate");
			String deputyToDate = request.getParameter("deputyToDate");
			String deputyYN = request.getParameter("deputyYN");
			String deputyReason = request.getParameter("deputyReason");
			String deputyOption = "Y";
			String userCode = SessionHelper.getSession("USERID");
			
			params.put("DeputyCode",deputyCode);
			params.put("DeputyName",deputyName);
			params.put("DeputyFromDate",deputyFromDate);
			params.put("DeputyToDate",deputyToDate);
			params.put("DeputyYN",deputyYN);
			params.put("DeputyReason",deputyReason);
			params.put("DeputyOption",deputyOption);
			params.put("UR_Code",userCode);
			
			approvalApiSvc.setDeputyData(params);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "정상 발송되었습니다.");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
	
	/**
	 * 양식목록 조회
	 * /api/approval/user/form/list
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getUserFormList.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getUserFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try	{
			CoviMap resultList = null;
			resultList = approvalApiSvc.getUserFormList();
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	/**
	 * 서명 등록
	 * /api/approval/user/sign
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/setSign.do",  method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap setSign(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		try	{
			MultipartFile file = request.getFile("files");
			String userCode = SessionHelper.getSession("USERID");
			
			// 본래 파일명
			String fileName = file.getOriginalFilename();

			List<MultipartFile> list = new ArrayList<>();
			list.add(file);
			CoviList savedArray = fileUtilService.uploadToBack(null, list, null, SERVICE_TYPE, "0", "NONE", "0", false, false);
			CoviMap savedFile = savedArray.getJSONObject(0);
			int fileId = savedFile.getInt("FileID");
			
			CoviMap params = new CoviMap();
			params.put("IsUse", "Y");
			params.put("UserCode", userCode);
			params.put("FileName", fileName);
			params.put("FilePath", "");
			params.put("FileID", fileId);
			
			approvalApiSvc.setSignData(params);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
	
		return returnList;
	}
	
	/**
	 * 기안하기(자동기안)
	 * /api/approval/form/draft
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/autoDraft.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap autoDraft(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		String key = "";
		String subject = "";
		String empno = "";
		String logonId = "";
		String legacyFormID = "";
		String apvline = "";
		String bodyContext = "";
		String scChgrValue = "";
		String actionComment = "";
		String signImage = "";
		String deptcode = "";
		String lang = "";

        try{
			List<MultipartFile> mf = new ArrayList<>();
		
			key = request.getParameter("key");
			subject = request.getParameter("subject");
			empno = request.getParameter("empNo");
			logonId = request.getParameter("logonId");
			legacyFormID = request.getParameter("formprefix");
			apvline = request.getParameter("apvline");
			bodyContext = request.getParameter("bodyContext");
			scChgrValue = request.getParameter("scChgrValue"); //담당업무함
			actionComment = request.getParameter("actionComment");
			signImage = request.getParameter("signImage");
			deptcode = StringUtil.replaceNull(request.getParameter("deptId"), "");
			lang = StringUtil.replaceNull(request.getParameter("language"), "");

			 mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnObj;
			}
			
			CoviMap apvLineObj = new CoviMap();
			if(StringUtil.isNotEmpty(apvline)) {
				apvLineObj.put("APRV_LINE", apvline);
				apvLineObj.put("empNo", empno);
				apvLineObj.put("formPrefix", legacyFormID);
				apvLineObj.put("entCode", SessionHelper.getSession("DN_Code"));
				apvline = forLegacySvc.getApvLineForDraft(apvLineObj).toJSONString();
			}
			
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(empno, logonId, deptcode); 
			empno = logonUserInfo.optString("LogonID");
			//deptcode = logonUserInfo.getString("DeptCode");
			if(empno.equals("")) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "사용자/부서 정보가 없습니다.");
				return returnObj;
			}
			
			CoviMap params = new CoviMap();
			params.put("key", key);
			params.put("subject", ComUtils.RemoveScriptAndStyle(subject));
			params.put("empno", empno);
			params.put("legacyFormID", legacyFormID);
			params.put("apvline", apvline);
			params.put("bodyContext", bodyContext);
			//params.put("scChgrValue", scChgrValue); api에서는 스키마옵션 사용.
			params.put("actionComment", actionComment);
			params.put("signImage", signImage);
			params.put("deptcode", deptcode);
			params.put("lang", lang);
			
			CoviMap formObj = new CoviMap();
			// 기안에 필요한 데이터 세팅
			params.put("isFile", !mf.isEmpty());
			if(!mf.isEmpty()) {
				CoviList FileInfos = new CoviList();
				for(int i=0;i<mf.size();i++) {
					CoviMap fileMap = new CoviMap();
					fileMap.put("ID", "_0");
					fileMap.put("FileName", mf.get(i).getOriginalFilename());
					fileMap.put("Type", "NEW");
					fileMap.put("AttachType", "normal");
					fileMap.put("UserCode", empno);
					fileMap.put("OriginID", "");
					fileMap.put("Size", mf.get(i).getSize());
					FileInfos.add(fileMap);
				}
				CoviMap FileObj = new CoviMap();
				FileObj.put("FileInfos", FileInfos);
				params.put("AttachFileInfo", FileObj);
			}
			formObj = forLegacySvc.makeFormObj(params);
			String reqFormInstID = formObj.optString("FormInstID");
			
			//배포처
			String sProcessGubun = formObj.optString("processDefinitionID").toLowerCase();
			if(sProcessGubun.contains("draft") && formObj.containsKey("ApprovalLine") 
				&& formObj.getJSONObject("ApprovalLine").getJSONObject("steps").get("division") instanceof CoviList) {
				 CoviMap divisionObj = formObj.getJSONObject("ApprovalLine").getJSONObject("steps").getJSONArray("division").getJSONObject(1);
				 String ouCode = divisionObj.optString("oucode");
				 CoviMap param = new CoviMap();
				 param.put("deptCode", ouCode);
				 CoviList list = approvalApiSvc.getReceiptList(param);
				 
				 String strReceiptList = ""; 
				 String strReceiveNames = ""; 
				 String strUnitType = "ou"; //수신자는 커스텀할것
				 String sRec0 = ""; //group
				 String sRec1 = ""; //user
				 String sRec2 = "";
				 String typeGubun = "";
				 for(Object obj : list) {
					 CoviMap map = (CoviMap) obj;
					 String an = map.optString("AN"); //RD02
					 String dn = map.optString("DN").replaceAll(";", "^"); //연구2팀;R&D team 2;;;;;;;;
					 String hasChild = map.optString("hasChild").equals("0") ? "X" : "N";
					 
					 switch(strUnitType) {
					 	case "ou" : 
					 		if(!sRec0.equals("")) sRec0 += ";";
					 		sRec0 += an + "|" + hasChild;
					 		typeGubun = "0";
					 		
					 		break;
					 	case "person" : 
					 		if(!sRec1.equals("")) sRec1 += ";";
					 		sRec1 += an;
					 		typeGubun = "1";
					 		
					 		break;
					 	default : break;
					 }
					 strReceiveNames = ";"+typeGubun + ":" + an + ":" + dn + ":" + hasChild; //0:RD02:연구2팀^R&amp^D team 2^^^^^^^^:N
				 }
				 strReceiptList = sRec0 + "@" + sRec1 + "@" + sRec2; //RD02|N@@
				 CoviMap formDataObj = formObj.getJSONObject("FormData");
				 formDataObj.put("ReceiptList", strReceiptList); 
				 formDataObj.put("ReceiveNames", strReceiveNames.substring(1));
			}
			
			CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
			
			try {
				formObj = forLegacySvc.draftForLegacy(formObj, processFormDataReturn);
			}catch(NullPointerException e) {
				// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
				if(processFormDataReturn != null) {
					CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
					// 신규기안일 경우만.
					String mode = formObj.optString("mode").toUpperCase();
					if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
						apvProcessSvc.deleteFormInstacne(prevFormObj);
					}
				}
				throw e;
			}catch(Exception e) {
				// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
				if(processFormDataReturn != null) {
					CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
					// 신규기안일 경우만.
					String mode = formObj.optString("mode").toUpperCase();
					if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
						apvProcessSvc.deleteFormInstacne(prevFormObj);
					}
				}
				throw e;
			}
			
			// 알림 처리
			try {
				String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/setTimeLineData.do";
				HttpsUtil httpsUtil = new HttpsUtil();
				httpsUtil.httpsClientWithRequest(url, "POST", formObj, "UTF-8", null);
			} catch(NullPointerException npE) {
				logger.error("ApvProcessCon", npE);
			} catch(Exception e) {
				logger.error("ApvProcessCon", e);
			}
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", DicHelper.getDic("msg_apv_alert_006")); //성공적으로 처리 되었습니다.
			returnObj.put("FormInstID", formObj.getString("FormInstID"));
			returnObj.put("ProcessID", formObj.getString("processID"));
			
		} catch (NullPointerException npE) {
			logger.error("ApprovalApiCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", npE.getMessage());
		} catch (Exception e) {
			logger.error("ApprovalApiCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getCause().getMessage());
		}
		
		return returnObj;
	}
	
	/**
	 * 임시저장
	 * /api/approval/form/save
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/tempSave.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap tempSave(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		String key = "";
		String subject = "";
		String empno = "";
		String logonId = "";
		String legacyFormID = "";
		String apvline = "";
		String bodyContext = "";
		String scChgrValue = "";
		String actionComment = "";
		String signImage = "";
		String deptcode = "";
		String lang = "";

        try{
			List<MultipartFile> mf = new ArrayList<>();

			key = request.getParameter("key");
			subject = request.getParameter("subject");
			empno = request.getParameter("empNo");
			logonId = request.getParameter("logonId");
			legacyFormID = request.getParameter("formprefix");
			apvline = request.getParameter("apvline");
			bodyContext = request.getParameter("bodyContext");
			scChgrValue = request.getParameter("scChgrValue"); //담당업무함
			actionComment = request.getParameter("actionComment");
			signImage = request.getParameter("signImage");
			deptcode = StringUtil.replaceNull(request.getParameter("deptId"), "");
			lang = StringUtil.replaceNull(request.getParameter("language"), "");

			 mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnObj;
			}
			
			CoviMap apvLineObj = new CoviMap();
			if(StringUtil.isNotEmpty(apvline)) {
				apvLineObj.put("APRV_LINE", apvline);
				apvLineObj.put("empNo", empno);
				apvLineObj.put("formPrefix", legacyFormID);
				apvLineObj.put("mode", "TEMPSAVE");
				apvLineObj.put("entCode", SessionHelper.getSession("DN_Code"));
				apvline = forLegacySvc.getApvLineForDraft(apvLineObj).toJSONString();
			}
			
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(empno, logonId, deptcode); 
			empno = logonUserInfo.optString("LogonID");
			//deptcode = logonUserInfo.getString("DeptCode");
			if(empno.equals("")) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "사용자/부서 정보가 없습니다.");
				return returnObj;
			}
			
			CoviMap params = new CoviMap();
			params.put("key", key);
			params.put("subject", ComUtils.RemoveScriptAndStyle(subject));
			params.put("empno", empno);
			params.put("legacyFormID", legacyFormID);
			params.put("apvline", apvline);
			params.put("bodyContext", bodyContext);
			params.put("scChgrValue", scChgrValue);
			params.put("actionComment", actionComment);
			params.put("signImage", signImage);
			params.put("deptcode", deptcode);
			params.put("lang", lang);
			
			CoviMap formObj = new CoviMap();
			// 기안에 필요한 데이터 세팅
			params.put("isFile", !mf.isEmpty());
			if(!mf.isEmpty()) {
				CoviList FileInfos = new CoviList();
				for(int i=0;i<mf.size();i++) {
					CoviMap fileMap = new CoviMap();
					fileMap.put("ID", "_0");
					fileMap.put("FileName", mf.get(i).getOriginalFilename());
					fileMap.put("Type", "NEW");
					fileMap.put("AttachType", "normal");
					fileMap.put("UserCode", empno);
					fileMap.put("OriginID", "");
					fileMap.put("Size", mf.get(i).getSize());
					FileInfos.add(fileMap);
				}
				CoviMap FileObj = new CoviMap();
				FileObj.put("FileInfos", FileInfos);
				params.put("AttachFileInfo", FileObj);
			}
			formObj = forLegacySvc.makeFormObj(params);
			
			
			//임시저장 data 재처리
			String formInstID = request.getParameter("formInstID");
			if(StringUtil.isNotEmpty(formInstID)) {
				formObj.put("mode", "TEMPSAVE");
				formObj.put("gloct", "TEMPSAVE");
				formObj.put("FormInstID", request.getParameter("formInstID"));
				
				CoviMap item = coviMapperOne.select("form.forLegacy.selectFormTempInstBoxID", formObj);
				formObj.put("FormTempInstBoxID", item.optString("FormTempInstBoxID"));
			}
			apvProcessSvc.doCreateInstance("TEMPSAVE", formObj, mf);
						
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", DicHelper.getDic("msg_apv_alert_006")); //성공적으로 처리 되었습니다.
			returnObj.put("FormInstID", formObj.getString("FormInstID"));
			returnObj.put("ProcessID", formObj.getString("processID"));
			
		} catch (NullPointerException npE) {
			logger.error("ApprovalApiCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", npE.getMessage());
		} catch (Exception e) {
			logger.error("ApprovalApiCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getCause().getMessage());
		}
		
		return returnObj;
	}
	
	/**
	 * 진행중 문서편집
	 * /api/approval/form/modify
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/modifySave.do", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	public @ResponseBody CoviMap modifySave(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap result = new CoviMap();	
		try{
			CoviMap params = new CoviMap(paramMap);
			CoviMap formObj = approvalApiSvc.getFormObjForProcess(params);
			
			//보안이슈 사용자 인증 체크 2021-01-18 dgkim
			String formID = formObj.optString("formID");
			String actionMode = formObj.getString("actionMode");
			String adminType = formObj.optString("adminType");
			if(adminType.equals("ADMIN") && !SessionHelper.getSession("isAdmin").equals("Y")) {
				adminType = "";
			}
		
			if(apvProcessSvc.getIsUsePasswordForm(formID) && !adminType.equals("ADMIN")) {
				if(!actionMode.equals("WITHDRAW") && !actionMode.equals("ABORT") && !actionMode.equals("APPROVECANCEL")  && !actionMode.equals("CHARGE")){
					boolean chkUsePasswordYN = false;						
					params.put("UR_CODE", SessionHelper.getSession("UR_Code"));
					CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
					if(resultList != null){
						CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
						if(map.optString("UseApprovalPassWord").equals("Y")) {
							chkUsePasswordYN = true;
						}
					}
					if( chkUsePasswordYN ) {
						result.put("status", Return.FAIL);
						result.put("message", "보안결재 문서입니다. 그룹웨어에서 결재를 진행해 주세요.");
						return result;
					}
				}
			}
			
			// 본문 저장관련해서 호출 분리함.
			CoviMap processFormDataReturn = new CoviMap();
			processFormDataReturn.put("formObj", formObj);
			
			processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, null);
											
			// 승인자 내용변경 저장 시 기안 및 승인 프로세스를 태우지 않음
			if("EDIT".equals(formObj.get("btnFlag"))) {
				apvProcessSvc.doEditProcess(formObj);
				
				result.put("status", Return.SUCCESS);
				result.put("message", DicHelper.getDic("msg_apv_170"));
				result.put("FormInstID", formObj.getString("FormInstID"));
				result.put("processID", formObj.getString("processID"));
				return result;
			}
		}catch(FileNotFoundException e) {
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}catch(NullPointerException npE){
			Throwable c = npE;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage() == null ? DicHelper.getDic("msg_apv_030") : c.getMessage());
		}catch(Exception e){
			Throwable c = e;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage());
		}
		
		return result;
	}
	
	/**
	 * 첨부파일 다운로드
	 * /api/approval/filedown
	 * @param request
	 * @param response
	 * @param paramMap
	 * @throws Exception
	 */
	@RequestMapping(value = "/fileDown.do" , method = {RequestMethod.GET, RequestMethod.POST})
	public void fileDownloadApi(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {
	    String fileID = "";
		String fileUUID = "";
		String serviceType = "";
		String orgFileName = "";
		String downloadResult = "N";
		String failReason = "";
		String errMsg = DicHelper.getDic("msg_ErrorOccurred"); // "오류가 발생하였습니다."
		CoviMap fileParam = new CoviMap();
		CoviMap fileResult = new CoviMap();
	    
	    try{
			fileID = StringUtil.replaceNull(request.getParameter("fileID"),"");
			String fileToken = StringUtil.replaceNull(request.getParameter("fileToken"),"");
			String userCode = SessionHelper.getSession("UR_Code");
			String companyCode = SessionHelper.getSession("DN_Code");
			
			fileParam.put("fileID",fileID);
			fileParam.put("fileUUID","");
			fileParam.put("fileToken",fileToken);
			fileParam.put("tokenCheckTime","N");
			fileParam.put("userCode",userCode);
			fileParam.put("companyCode",companyCode);
			
			fileResult = fileUtilService.fileDownloadByID(request, response, fileParam, true, true);
			
			serviceType = fileResult.optString("serviceType");
			orgFileName = fileResult.optString("orgFileName");
			downloadResult = fileResult.optString("downloadResult");
			failReason = fileResult.optString("failReason");
			errMsg = fileResult.optString("errMsg");
			
	    }
	    catch(NullPointerException e){
			downloadResult = "N";
			failReason =  e.getMessage();
	    }
	    catch(Exception e){
			downloadResult = "N";
			failReason =  e.getMessage();
	    }
	    finally {
	    	if(downloadResult.equalsIgnoreCase("N")) {
	    		// throw new Exception(errMsg);
	    		response.reset();
				//response.setContentType("text/html;charset=UTF-8");
	    		response.setContentType("tapplication/json;charset=UTF-8");
				try(PrintWriter out = response.getWriter();){
					// html 타입 오류 리턴
					//out.println("<script language='javascript'>alert('" + errMsg + "');</script>");
					// json 타입 오류 리턴
					CoviMap rtnMap = new CoviMap();
					rtnMap.put("status", Return.FAIL.toString());
					rtnMap.put("message", errMsg);
					out.write(rtnMap.toString());
				}
			} 
	    }
	}
	
	/**
	 * 재기안
	 * /api/approval/form/redraft
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/redraft.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap redraft(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		String key = "";
		String subject = "";
		String empno = "";
		String logonId = "";
		String legacyFormID = "";
		String apvline = "";
		String bodyContext = "";
		String scChgrValue = "";
		String actionComment = "";
		String signImage = "";
		String deptcode = "";
		String lang = "";

        try{
			List<MultipartFile> mf = new ArrayList<>();
		
			key = request.getParameter("key");
			subject = request.getParameter("subject");
			empno = request.getParameter("empNo");
			logonId = request.getParameter("logonId");
			legacyFormID = request.getParameter("formprefix");
			apvline = request.getParameter("apvline");
			bodyContext = request.getParameter("bodyContext");
			scChgrValue = request.getParameter("scChgrValue"); //담당업무함
			actionComment = request.getParameter("actionComment");
			signImage = request.getParameter("signImage");
			deptcode = StringUtil.replaceNull(request.getParameter("deptId"), "");
			lang = StringUtil.replaceNull(request.getParameter("language"), "");

			 mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnObj;
			}
			
			CoviMap params = new CoviMap(paramMap);
			// 기안에 필요한 데이터 세팅
			params.put("isFile", !mf.isEmpty());
			if(!mf.isEmpty()) {
				CoviList FileInfos = new CoviList();
				for(int i=0;i<mf.size();i++) {
					CoviMap fileMap = new CoviMap();
					fileMap.put("ID", "_0");
					fileMap.put("FileName", mf.get(i).getOriginalFilename());
					fileMap.put("Type", "NEW");
					fileMap.put("AttachType", "normal");
					fileMap.put("UserCode", empno);
					fileMap.put("OriginID", "");
					fileMap.put("Size", mf.get(i).getSize());
					FileInfos.add(fileMap);
				}
				CoviMap FileObj = new CoviMap();
				FileObj.put("FileInfos", FileInfos);
				params.put("AttachFileInfo", FileObj);
			}
			CoviMap processformObj = approvalApiSvc.getFormObjForProcess(params);
			
			CoviMap apvLineObj = new CoviMap();
			if(params.optString("actionMode").equals("RECAPPROVAL") && StringUtil.isEmpty(apvline)) { //접수시 결재선 안보내면 세션사용자로 접수.
				CoviMap setAvpLine = new CoviMap();
				CoviList recList = new CoviList();
				CoviMap recObj = new CoviMap();
				CoviList stepList = new CoviList();
				CoviMap stepObj = new CoviMap();
				
				stepObj.put("index", "1");
				stepObj.put("type", "Approve");
				stepObj.put("userCode", SessionHelper.getSession("USERID"));
				stepObj.put("deptCode", SessionHelper.getSession("ApprovalParentGR_Code"));
				stepList.add(stepObj);
				recObj.put("index", "1");
				recObj.put("type", "redraft");
				recObj.put("step", stepList);
				recList.add(recObj);

				setAvpLine.put("division", recList);
				apvline = setAvpLine.toString();
			}
			if(StringUtil.isNotEmpty(apvline)) {
				apvLineObj.put("APRV_LINE", apvline);
				apvLineObj.put("empNo", empno);
				apvLineObj.put("processID", processformObj.optString("processID"));
				apvLineObj.put("processDescID", processformObj.getJSONObject("ProcessDescription").optString("ProcessDescriptionID"));
				apvLineObj.put("ApprovalLine", processformObj.optString("ApprovalLine")); //기안부서 결재선 가져오기 위함.
				apvline = forLegacySvc.getApvLineForDraft(apvLineObj).toJSONString();
				
				params.put("apvline", apvline);
				processformObj.put("ChangeApprovalLine", apvline);
			}
			
			params.put("legacyFormID", processformObj.optString("FormPrefix"));
			if(!processformObj.getJSONObject("FormData").containsKey("BodyContext")) {
				params.put("bodyContext", "{}");
			}
			
			params.put("empno", processformObj.optString("userid"));
			CoviMap makeFormObj = forLegacySvc.makeFormObj(params);
			makeFormObj.remove("FormData"); //재기안시 불필요 데이터 삭제
			makeFormObj.putAll(processformObj);
			
			CoviMap formObj = makeFormObj;
			CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
			
			try {
				formObj = forLegacySvc.draftForLegacy(formObj, processFormDataReturn);
			}catch(NullPointerException e) {
				// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
				if(processFormDataReturn != null) {
					CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
					// 신규기안일 경우만.
					String mode = formObj.optString("mode").toUpperCase();
					/*if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
						apvProcessSvc.deleteFormInstacne(prevFormObj);
					}*/
				}
				throw e;
			}catch(Exception e) {
				// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
				if(processFormDataReturn != null) {
					CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
					// 신규기안일 경우만.
					String mode = formObj.optString("mode").toUpperCase();
					/*if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
						apvProcessSvc.deleteFormInstacne(prevFormObj);
					}*/
				}
				throw e;
			}
			
			// 알림 처리
			try {
				String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/setTimeLineData.do";
				HttpsUtil httpsUtil = new HttpsUtil();
				httpsUtil.httpsClientWithRequest(url, "POST", formObj, "UTF-8", null);
			} catch(NullPointerException npE) {
				logger.error("ApvProcessCon", npE);
			} catch(Exception e) {
				logger.error("ApvProcessCon", e);
			}
			
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", DicHelper.getDic("msg_apv_alert_006")); //성공적으로 처리 되었습니다.
			returnObj.put("FormInstID", formObj.getString("FormInstID"));
			returnObj.put("ProcessID", formObj.getString("processID"));
			
		} catch (NullPointerException npE) {
			logger.error("ApprovalApiCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", npE.getMessage());
		} catch (Exception e) {
			logger.error("ApprovalApiCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getCause().getMessage());
		}
		
		return returnObj;
	}
}