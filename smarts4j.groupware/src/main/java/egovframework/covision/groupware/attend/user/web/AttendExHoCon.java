package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendExHoSvc;
 
@Controller
public class AttendExHoCon {
	private Logger LOGGER = LogManager.getLogger(AttendExHoCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Autowired
	AttendExHoSvc attendExHoSvc;

	@Autowired 
	AttendCommonSvc attendCommonSvc;
	
	/**
		* @Method Name : getExHoInfoList
		* @작성일 : 2019. 7. 1.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 연장/휴일 근무 리스트 조회
		* @param request
		* @param response 
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "attendExHo/getExHoInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getExHoInfoList(HttpServletRequest request, HttpServletResponse response, HttpSession session)  {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {	 
			CoviMap params = new CoviMap();
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params = setSessionAttendanceInfo(params);
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection); 
			
			// params.put("year", request.getParameter("year"));
			// params.put("schTypeSel", request.getParameter("schTypeSel")); 
			// params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			
			String isAdmin =  attendCommonSvc.getUserAuthType();
			if (!"ADMIN".equals(request.getParameter("isAttendAdmin")) || (isAdmin == null || !"ADMIN".equals(isAdmin)))
				params.put("p_UserCode", SessionHelper.getSession("USERID"));	
			 
			params.put("StartDate", request.getParameter("StartDate"));	 
			params.put("EndDate",request.getParameter("EndDate"));	
			params.put("ApprovalSts",request.getParameter("ApprovalSts"));	
			params.put("ApprovalStsU",request.getParameter("ApprovalStsU"));				
			params.put("ApprovalStsNot",request.getParameter("ApprovalStsNot"));				
			params.put("JobStsName",request.getParameter("JobStsName"));
			params.put("RetireUser",request.getParameter("RetireUser"));	

			params.put("DEPTIDORI", SessionHelper.getSession("DEPTID"));
			params.put("DEPTID", request.getParameter("DEPTID"));
			params.put("GroupPath", request.getParameter("GroupPath"));
			params.put("searchText", request.getParameter("searchText"));

			if("C".equals(request.getParameter("JobStsName"))){
				resultList = attendExHoSvc.getCallingInfoList(params); 
			}else{
				resultList = attendExHoSvc.getExHoInfoList(params); 
			}
			
			CoviMap cMap = (CoviMap)resultList.get("tot");
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("foot", cMap);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	/**
	* @Method Name : setSessionAttendanceInfo
	* @작성일 : 2019. 6. 20.
	* @작성자 : sjhan0418
	* @변경이력 :
	* @Method 설명 : AttendanceSoManageCon session 공통정보  parameter setting
	* @param params
	* @return
	*/
	public CoviMap setSessionAttendanceInfo(CoviMap params){
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("DeptCode", SessionHelper.getSession("DEPTID"));
		params.put("IsAdmin", SessionHelper.getSession("isAdmin"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("lang", SessionHelper.getSession("lang"));
		return params;
	}
	
	@RequestMapping(value = "attendExHo/cancelExHoStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap cancelExHoStatus(HttpServletRequest request, HttpServletResponse response,HttpSession session
			,@RequestParam Map<String, Object> parameters){
		CoviMap returnJson = new CoviMap();
		
		try{
			if(parameters.get("ApprovalSts")!=null && !("".equals(parameters.get("ApprovalSts")))){
				 
				String ApprovalSts = String.valueOf(parameters.get("ApprovalSts"));
				
				String isAdmin = SessionHelper.getSession("isAttendAdmin");
				
				String canArrayStr = parameters.get("canArray").toString();
				ObjectMapper mapper = new ObjectMapper();
				List<String> canArray = mapper.readValue(canArrayStr, new TypeReference<ArrayList<String>>(){});
				
				
				for(int i=0;i<canArray.size();i++){
					String ExHoSeq = canArray.get(i);
					
					CoviMap exHoParams = new CoviMap();
					exHoParams = setSessionAttendanceInfo(exHoParams);
					exHoParams.put("ExHoSeq", ExHoSeq);
					exHoParams.put("DEPTIDORI",SessionHelper.getSession("DEPTID"));
					
					CoviMap resultList = attendExHoSvc.getExHoInfoList(exHoParams);
					int cnt = ((CoviList)resultList.get("list")).size();

					if(cnt>0){
						CoviList exhoJson = (CoviList)resultList.get("list");
						CoviMap exho = (CoviMap)exhoJson.get(0);
						
						// Y : 신청  , S : 취소신청 , N : 취소
						if("S".equals(ApprovalSts)){	
							
							if(isAdmin.equals("ADMIN")){	//관리자의 경우 취소신청 / 승인 가능
								if("Y".equals(exho.get("ApprovalSts"))){ // 신청건만
									CoviMap updParam = new CoviMap();
									updParam.put("ExHoSeq", ExHoSeq);
									updParam.put("ApprovalSts", ApprovalSts);
									updParam.put("UserCode", exHoParams.get("UserCode"));
									
									attendExHoSvc.updExHoInfo(updParam);
								}
							}else{
								if(SessionHelper.getSession("USERID").equals(exho.get("UserCode"))){	//본인것만 가능
									if("Y".equals(exho.get("ApprovalSts"))){ // 신청건만
										CoviMap updParam = new CoviMap();
										updParam.put("ExHoSeq", ExHoSeq);
										updParam.put("ApprovalSts", ApprovalSts);
										updParam.put("UserCode", exHoParams.get("UserCode"));
										
										
										attendExHoSvc.updExHoInfo(updParam);
									}
								}else{
									
								}
							}
							
						}else if("N".equals(ApprovalSts)){	//관리자만 승인가능
							if(isAdmin.equals("ADMIN")){
								if("S".equals(exho.get("ApprovalSts"))){ // 취소신청 건만
									CoviMap updParam = new CoviMap();
									updParam.put("ExHoSeq", ExHoSeq);
									updParam.put("ApprovalSts", ApprovalSts);
									updParam.put("UserCode", exHoParams.get("UserCode"));
									
									updParam.put("TargetDate", exho.getString("JobDate"));
									updParam.put("TargetUserCode", exho.get("UserCode"));
									updParam.put("CompanyCode", exHoParams.get("CompanyCode"));

									attendExHoSvc.updExHoInfo(updParam);
								}
							}
						}
					}
				}
				returnJson.put("status", Return.SUCCESS);
			}else{
				returnJson.put("status", Return.FAIL);
			}
		} catch(NullPointerException e){
			returnJson.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnJson.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnJson;
	}
	
	

	/**
		* @Method Name : goExHoSchPop
		* @작성일 : 2019. 7. 12.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 연장/휴일 근무 시간 수정 파법
		* @param request
		* @param locale
		* @param model
		* @return
		* @throws Exception
		*/
	@RequestMapping(value = "attendExHo/goExHoSchPop.do", method = RequestMethod.GET)
	public ModelAndView goExHoSchPop(HttpServletRequest request, Locale locale, Model model) throws Exception{
		
		ModelAndView mav = new ModelAndView("user/attend/AttendExHoUpdPop");
		
		CoviMap params = new CoviMap();
		params.put("ExHoSeq", request.getParameter("ExHoSeq"));
		
		CoviMap jo = attendExHoSvc.getExHoTimeInfo(params);
		
		mav.addObject("ExHoSeq",request.getParameter("ExHoSeq")); 
		mav.addObject("ExHo",((CoviList)jo.get("list")).get(0));
		return mav;
	}

	
	/**
		* @Method Name : updExHoSchInfo
		* @작성일 : 2019. 7. 12.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 연장/휴일근무 시간 수정
		* @param request
		* @param locale 
		* @param model
		* @param parameters
		* @return
		*/
	@RequestMapping(value = "attendExHo/updExHoSchInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updExHoSchInfo(HttpServletRequest request, Locale locale, Model model
			,@RequestParam Map<String, Object> parameters){
		CoviMap returnJson = new CoviMap();
		
				try {
			CoviMap params = new CoviMap();
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("ExHoSeq", parameters.get("ExHoSeq"));
			
			String StartTime = parameters.get("JobDate")+" "+parameters.get("StartHour")+":"+parameters.get("StartMin");
			String EndTime = parameters.get("JobDate")+" "+parameters.get("EndHour")+":"+parameters.get("EndMin");
			String WorkTime = parameters.get("WorkHour")+""+parameters.get("WorkMin");
			
			
			params.put("StartTime", StartTime);
			params.put("EndTime", EndTime); 
			params.put("WorkTime", WorkTime);
			attendExHoSvc.updExHoInfo(params);
			returnJson.put("status", Return.SUCCESS);
			
			
			//
			
			
			// 임시 - 관리자
			String strManagerList = RedisDataUtil.getBaseConfig("TempWorkReportManager");
			boolean isViewManager = false;
			
			// 팀장 JobTitleCodes
			String strTeamManager = RedisDataUtil.getBaseConfig("WorkReportTMJobTitle");
			boolean isViewTeamReport = false;
			
			
			String grCode = SessionHelper.getSession("GR_Code");
			String urCode = SessionHelper.getSession("UR_Code");
			String jobTitleCode = SessionHelper.getSession("UR_JobTitleCode");
			
			

			
			StringTokenizer stringTokenizer = new StringTokenizer(strTeamManager, "|");
			
			// 팀장 권한 확인
			while(stringTokenizer.hasMoreTokens()) {
				String strJobTitle = stringTokenizer.nextToken();
				
				if(jobTitleCode.equalsIgnoreCase(strJobTitle)) {
					isViewTeamReport = true;
					break;
				}
			}
			
			
			stringTokenizer = new StringTokenizer(strManagerList, "|");
			
			// 관리자 권한 확인
			while(stringTokenizer.hasMoreTokens()) {
				String strCode = stringTokenizer.nextToken();
				
				String[] arrCode = strCode.split(":");
				
				if(arrCode.length == 2) {
					if(arrCode[0].equalsIgnoreCase("UR")) {
						if(arrCode[1].equalsIgnoreCase(urCode)){
							isViewManager = true;
							break;
						}
					} else if (arrCode[0].equalsIgnoreCase("GR")) {
						if(arrCode[1].equalsIgnoreCase(grCode)){
							isViewManager = true;
							break;
						}
					}
				}
			}
		} catch(NullPointerException e) {
			returnJson.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ArrayIndexOutOfBoundsException e) {
			returnJson.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			returnJson.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnJson;
	}
	

	/**
		* @Method Name : excelDownAttendanceExHo
		* @작성일 : 2019. 8. 7.
		* @작성자 : sjhan0418
		* @변경이력 : 최초생성
		* @Method 설명 : 연장 / 휴일 근무자 현황 리스트 엑셀다운로드
		* @param request
		* @param response
		*/
	@RequestMapping(value = "attendExHo/excelDownAttendanceExHo.do")
	public void excelDownAttendanceExHo(HttpServletRequest request, HttpServletResponse response) {
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		ByteArrayOutputStream baos = null;
		try { 
			 
			CoviMap params = new CoviMap();
			
			String[] sortBy = StringUtil.replaceNull(request.getParameter("sortBy"), "").split(" ");
			String sortColumn = "";
			String sortDirection = "";
			
			if(sortBy.length > 1) {
				sortColumn = ComUtils.RemoveSQLInjection(sortBy[0], 100);
				sortDirection = ComUtils.RemoveSQLInjection(sortBy[1], 100);
			}
			
			params = setSessionAttendanceInfo(params);
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection); 
			/*params.put("year", request.getParameter("year"));
			params.put("schTypeSel", request.getParameter("schTypeSel")); 
			params.put("schTxt", request.getParameter("schTxt"));*/
			params.put("urCode", SessionHelper.getSession("USERID"));	
			 
			params.put("StartDate", request.getParameter("StartDate"));	 
			params.put("EndDate",request.getParameter("EndDate"));	 
			params.put("ApprovalSts",request.getParameter("ApprovalSts"));	
			 
			params.put("ApprovalStsNot",request.getParameter("ApprovalStsNot"));	
			
			params.put("JobStsName",request.getParameter("JobStsName"));	
			

			params.put("DEPTIDORI", SessionHelper.getSession("DEPTID")); 
			params.put("DEPTID", request.getParameter("DEPTID"));
			params.put("GroupPath", request.getParameter("GroupPath"));

			String FileName = "";
			String ExcelPath ="";
			CoviMap resultList = new CoviMap(); 
			if("C".equals(request.getParameter("JobStsName"))){
				resultList = attendExHoSvc.getCallingInfoList(params);	
				ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendCallingList_templete.xlsx");
				FileName = "AttendanceCallingList.xlsx";
				params.put("title", "소명신청현황"); 
			}else{ 
				resultList = attendExHoSvc.getExHoInfoList(params);	
				ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendExHoList_templete.xlsx");
				FileName = "AttendanceExHoList.xlsx";
				params.put("title", "주 연장/휴일 근무자 현황"); 	
			}
			
			params.put("list",new Gson().fromJson(resultList.get("list").toString(), Object.class));
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
			
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}

	}
	
	/**
	* @Method Name : goExHoSchPop
	* @작성일 : 2019. 7. 12.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 엑셀폼 설정
	* @param request
	* @param locale
	* @param model
	* @return
	* @throws Exception
		*/
	@RequestMapping(value = "attendExHo/AttendExHoExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView attendExHoExcelPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		ModelAndView mav = new ModelAndView("user/attend/AttendExHoExcelPopup");
		mav.addObject("StartDate",request.getParameter("StartDate"));
		mav.addObject("EndDate",request.getParameter("EndDate"));
		return mav;
	}

	/**
	* @Method Name : excelDownFile
	* @작성일 : 2019. 9. 04.
	* @작성자 : sjhan0418
	* @변경이력 : 최초생성
	* @Method 설명 : 부서 근태현황 주간 엑셀리스트 다운로드
	* @param request
	* @param response
	 * @throws IOException 
	*/
	@RequestMapping(value = "attendExHo/excelDownFile.do")
	public void excelDownFile(HttpServletRequest request, HttpServletResponse response) {
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		ByteArrayOutputStream baos = null ;
		try { 
			CoviMap params = new CoviMap();
			params = setSessionAttendanceInfo(params);
			String type = request.getParameter("Type");
			String ExcelType = StringUtil.replaceNull(request.getParameter("ExcelType"), "");
			String excelFile = "";
			switch (ExcelType){
				case "Comm"://근태내역
					excelFile = "AttendComm_templete";
					break;
				case "Late50"://50분이후출근
					excelFile = "AttendLate50_templete";
					break;
				case "Late"://지각자
					excelFile = "AttendLate_templete";
					break;
				case "ExSumm"://연장근무요약
					excelFile = "AttendExSumm_templete";
					break;
				case "CommSumm"://실근무요약
					excelFile = "AttendCommSumm_templete";
					break;
				case "ExHo"://연장근무휴일근무
					excelFile = "AttendExHoList_templete";
					params.put("GroupPath", request.getParameter("DEPTID"));
					break;
				default :
					break;
			}

			params.put("StartDate", request.getParameter("StartDate"));	 
			params.put("EndDate", request.getParameter("EndDate"));	 
			params.put("DEPTID", request.getParameter("DEPTID"));	 
			params.put("RetireUser",request.getParameter("RetireUser"));
			params.put("ExcelType",ExcelType);

			String FileName = excelFile+".xlsx"; 
			String ExcelPath = "";
			CoviMap jo = new CoviMap();
			if (ExcelType.equals("ExHo"))
				jo = attendExHoSvc.getExHoInfoList(params);	
			else
				jo = attendExHoSvc.getAttendExcelList(params); 

			ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//"+excelFile+".xlsx");
 
//			params.putAll(jo); 
			jo.putAll(params);
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, jo);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
			
			
			
		} catch (IOException e) { 
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) { 
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	

}