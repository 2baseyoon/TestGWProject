package egovframework.covision.groupware.attend.user.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.base.Enums;


import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendAdminSettingSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;

/**
 * @author sjhan0418
 *
 */
@Controller
@RequestMapping("/attendAdmin")
public class AttendAdminSettingCon {
	
	private Logger LOGGER = LogManager.getLogger(AttendAdminSettingCon.class);
	
	@Autowired 
	AttendCommonSvc attendCommonSvc;
	@Autowired
	AttendAdminSettingSvc attendAdminSettingSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	

	/**
	  * @Method Name : getCompanySettings
	  * @작성일 : 2020. 3. 31. 
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자설정 - 회사설정정보 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/getCompanySettings.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCompanySettings(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			returnList.put("data", attendAdminSettingSvc.getCompanySetting());
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

	/**
	  * @Method Name : setCompanySetting
	  * @작성일 : 2020. 4. 10.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사설정 저장
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/setCompanySetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCompanySetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			
			//checkbox / radio / select
			String[] codeArry = {
				"AssYn"
				,"AttAlarmYn"
				/*,"AttConfmYn"*/
				,"AttReqMethod"
				,"CommuModReqMethod"
				,"CoreEndTime"
				,"CoreStartTime"
				,"CoreTimeYn"
				,"EndAlarmTime"
				,"EndAlarmYn"
				,"ExtenAlarmTime"
				,"ExtenAlarmYn"
				,"ExtenDelMethod"
				,"ExtenUpdMethod"
				,"ExtenReqMethod"
				,"HoliDelMethod"
				,"HoliUpdMethod"
				,"HoliReqMethod"
				,"HoliReplReqMethod"
				,"ExtenHoliTimeMethod"
				,"LeaveAlarmYn"
				,"LeaveReqMethod"
				/*,"LeaveYn"*/
				,"NoSchYn" 
				/*,"OutUpdMethod"
				,"OutDelMethod"
				,"OutReqMethod"*/
				,"OutsideYn"
				,"CustomSchYn"
				,"RemainTimeCode"
				,"ExptVacTime"
				,"RestYn"
				,"RewardPeriod"
				,"RewardStandardDay"
				,"RewardYn"
				,"SchConfmYn"
				,"StartAlarmTime"
				,"StartAlarmYn"
				,"StaticSetMethod"
				,"TardyAlarmTime"
				,"TardyAlarmYn"
				,"VacDelMethod"
				,"VacReqMethod"
				,"WorkReqMethod"
				,"WorkDelMethod"
				,"WorkUpdMethod"
				,"AttStartTimeTermMin"
				,"AttStatusStartTimeTermMin"
				,"AttEndTimeTermMin"
				,"AttStatusEndTimeTermMin"
				,"AttBaseWeek"
				,"UserTempleteYn"
				,"UserReqAttTime"
				,"RealTimeYn"
				,"CommuteOutTerm"
				,"CommuteTimeYn"
				,"ExcelSaveYn"
				,"ExcelSaveYnAdmin"
				,"ExcelDataMode"
				,"ExtenUnit"
				,"ExtenRestYn"
				,"ExtenWorkTime"
				,"ExtenRestTime"
				,"ExtenMaxTime"
				,"ExtenMaxWeekTime"
				,"ExtenStartTime"
				,"ExtenEndTime"
				,"HoliRestYn"
				,"HoliWorkTime"
				,"HoliRestTime"
				/*알람기능 추가 2021.10.08 nkpark*/
				,"AlarmAttStartNoticeToUserYn"
				,"AlarmAttStartNoticeMin"
				,"AlarmAttEndNoticeToUserYn"
				,"AlarmAttEndNoticeMin"
				,"AlarmAttOvertimeToAdminUserYn"
				,"AlarmAttLateToAdminUserYn"
				// 일괄 출퇴근 추가
				,"AllGoWorkApplyTime"
				,"AllOffWorkApplyTime"
				//근태포탈 환경설정
				,"AttPortalDailyJobTitle"
				,"AttendanceGMJobTiltle"
				/*근태확정 설정*/
				,"AttConfirmYn"
			};
			
			CoviList paramArry = new CoviList();
			for(int i=0;i<codeArry.length;i++){
				CoviMap params = new CoviMap();
				String code = codeArry[i];
				params.put("SettingKey", code);
				params.put("SettingValue", request.getParameter(code)==null?"N":request.getParameter(code));
				
				paramArry.add(params);
			}

			//간주 유형관리
			String assArry = StringUtil.replaceNull(request.getParameter("assArry"), "[]");
			CoviList assList = CoviList.fromObject(assArry.replaceAll("&quot;", "\""));
			//보상휴가/휴게시간
			String rewardArry = StringUtil.replaceNull(request.getParameter("rewardArry"), "[]");
			String rewardHoliArry = StringUtil.replaceNull(request.getParameter("rewardHoliArry"), "[]");
			String rewardOffArry = StringUtil.replaceNull(request.getParameter("rewardOffArry"), "[]");
			String restArry = StringUtil.replaceNull(request.getParameter("restArry"), "[]");
			
			CoviList rewardList = CoviList.fromObject(rewardArry.replaceAll("&quot;", "\""));
			CoviList rewardHoliList = CoviList.fromObject(rewardHoliArry.replaceAll("&quot;", "\""));
			CoviList rewardOffList = CoviList.fromObject(rewardOffArry.replaceAll("&quot;", "\""));
			CoviList restList = CoviList.fromObject(restArry.replaceAll("&quot;", "\""));
			
			//출퇴근 기능설정
			String ipArry = StringUtil.replaceNull(request.getParameter("ipArry"), "[]");
			CoviList ipList = CoviList.fromObject(ipArry.replaceAll("&quot;", "\""));
			
			//근태마스터 정보 
			CoviMap mngMstObj = new CoviMap();
			mngMstObj.put("PcUseYn", request.getParameter("PcUseYn")==null?"N":request.getParameter("PcUseYn"));
			mngMstObj.put("MobileUseYn", request.getParameter("MobileUseYn")==null?"N":request.getParameter("MobileUseYn"));
			mngMstObj.put("OthYn", request.getParameter("OthYn")==null?"N":request.getParameter("OthYn"));
			mngMstObj.put("IpYn", request.getParameter("IpYn")==null?"N":request.getParameter("IpYn"));
			
			mngMstObj.put("LateSendYn", request.getParameter("LateSendYn")==null?"Y":request.getParameter("LateSendYn"));
			mngMstObj.put("AbsentSendYn", request.getParameter("AbsentSendYn")==null?"Y":request.getParameter("AbsentSendYn"));
			mngMstObj.put("EarlySendYn", request.getParameter("EarlySendYn")==null?"Y":request.getParameter("EarlySendYn"));
			mngMstObj.put("CallingSendYn", request.getParameter("CallingSendYn")==null?"Y":request.getParameter("CallingSendYn"));

			mngMstObj.put("MailTitle", request.getParameter("MailTitle")==null?"":request.getParameter("MailTitle"));
			mngMstObj.put("MailBody", request.getParameter("MailBody")==null?"":request.getParameter("MailBody"));
			mngMstObj.put("AttendPolicy", request.getParameter("AttendPolicy")==null?"":request.getParameter("AttendPolicy"));

			CoviMap setParams = new CoviMap();
			setParams.put("configList", paramArry);
			setParams.put("assList", assList);
			
			setParams.put("rewardList", rewardList);
			setParams.put("rewardHoliList", rewardHoliList);
			setParams.put("rewardOffList", rewardOffList);
			setParams.put("restList", restList);
			setParams.put("ipList", ipList);
			setParams.put("mngMstObj",mngMstObj);

			attendAdminSettingSvc.setCompanySetting(setParams);
			 
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
	 * @Method Name : setCompanySettingForVacations
	 * @작성일 : 2022. 07. 04.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 휴가 관리 > 휴가생성 자동 규칙
	 * @param request request
	 * @param response response
	 * @return CoviMap
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "/setCompanySettingForVacations.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCompanySettingForVacations(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {

			//checkbox / radio / select
			String[] codeArry = {
					//2022.07.04 휴가관리>휴가생성 자동규칙 > 연차촉진안내 연차촉진 대상자 기록 처리 허용
					"FacilitatingTarget"
					//2022.08.05 연차촉구 요청서 화면내 수신자 부서 명칭 설정
					,"FacilitatingSenderDept"
			};

			CoviList paramArry = new CoviList();
			for(int i=0;i<codeArry.length;i++){
				CoviMap params = new CoviMap();
				String code = codeArry[i];
				params.put("SettingKey", code);
				params.put("SettingValue", request.getParameter(code)==null?"N":request.getParameter(code));

				paramArry.add(params);
			}

			CoviMap setParams = new CoviMap();
			setParams.put("configList", paramArry);

			attendAdminSettingSvc.setCompanySettingForVacations(setParams);

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
	  * @Method Name : getWorkInfoList
	  * @작성일 : 2020. 3. 31.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자 설정 - 근로정보 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception 
	  */
	@RequestMapping(value = "/getWorkInfoList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWorkInfoList(HttpServletRequest request, HttpServletResponse response) throws Exception {
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
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			
			params.put("isAll", StringUtil.replaceNull(request.getParameter("isAll"), ""));
			params.put("todayDate", StringUtil.replaceNull(request.getParameter("todayDate"), ""));
			
			/*권한별 검색가능 부서 코드 조회
			CoviMap deptObj = attendCommonSvc.getDeptListByAuth();
			params.put("deptCodeList", deptObj.get("deptList"));
			//권한별 검색가능 사용자 코드 조회
			CoviList userCodeList = attendCommonSvc.getUserListByAuth();
			params.put("userCodeList", userCodeList);
			*/
			resultList = attendAdminSettingSvc.getWorkInfoList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}

	/**
	  * @Method Name : goWorkInfoAddPopup
	  * @작성일 : 2020. 3. 31.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자 설정 - 근로정보관리 - 근로정보 추가 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goWorkInfoAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goWorkInfoAddPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/attend/AttendWorkInfoAddPopup");
	}
	
	@RequestMapping(value = "/goWorkInfoModPopup.do", method = RequestMethod.GET)
	public ModelAndView goWorkInfoModPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap param = new CoviMap();
		param.put("ListType", request.getParameter("ListType"));
		param.put("UserCode", request.getParameter("UserCode"));
		param.put("ApplyDate", request.getParameter("ApplyDate"));
		
		CoviMap returnList = attendAdminSettingSvc.getWorkInfoDetail(param);
		
		ModelAndView mav = new ModelAndView("user/attend/AttendWorkInfoAddPopup");
		mav.addObject("result", returnList.get("list"));
		
		return mav;
	}

	/**
	  * @Method Name : workInfoExcelListDownload
	  * @작성일 : 2020. 3. 31.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자 설정 - 근로정보 엑셀 템플릿 다운로드
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/workInfoExcelListDownload.do" , method = RequestMethod.GET)
	public void workInfoExcelListDownload(HttpServletRequest request, HttpServletResponse response) {
		
		ByteArrayOutputStream baos =  null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = new CoviMap();
			
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendWorkInfoList_templete.xlsx");
			
			//권한별 검색가능 사용자 코드 조회 
			CoviList userCodeList = attendCommonSvc.getUserListByAuth();
			params.put("userCodeList", userCodeList);
			CoviMap resultList = attendAdminSettingSvc.getWorkInfoList(params);
			
			CoviList workInfoList = new CoviList();
			CoviList exList = resultList.getJSONArray("list");
			
			CoviList workcodeStr = RedisDataUtil.getBaseCode("WorkCode");
			CoviList unittermStr = RedisDataUtil.getBaseCode("UnitTerm");
			CoviList weekendStr = RedisDataUtil.getBaseCode("AttendWeekend");
			
			for(int i=0;i<exList.size();i++){
				CoviMap jo = exList.getJSONObject(i);
				
				String WorkWeek = jo.getString("WorkWeek");
				
				jo.put("WorkWeekend",weekendFormat(weekendStr,WorkWeek,'1'));
				jo.put("HoliWeekend",weekendFormat(weekendStr,WorkWeek,'0'));
				String WorkTime = jo.getString("WorkTime");
				String WorkCode = jo.getString("WorkCode");
				String UnitTerm = jo.getString("UnitTerm");
				String WorkApplyDate = jo.getString("WorkApplyDate");

				jo.put("WorkStr",ruleFormat(workcodeStr,unittermStr,WorkTime,WorkCode,UnitTerm,WorkApplyDate,'/'));
				

				String MaxWorkTime = jo.getString("MaxWorkTime");
				String MaxWorkCode = jo.getString("MaxWorkCode");
				String MaxUnitTerm = jo.getString("MaxUnitTerm");
				String MaxWorkApplyDate = jo.getString("MaxWorkApplyDate");

				jo.put("MaxWorkStr",ruleFormat(workcodeStr,unittermStr,MaxWorkTime,MaxWorkCode,MaxUnitTerm,MaxWorkApplyDate,'/'));
				
				workInfoList.add(jo);
			}

			CoviMap excelMap = new CoviMap();
			excelMap.put("list", workInfoList);
			excelMap.put("title", "근로정보 관리");
			
			baos = new ByteArrayOutputStream();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			XLSTransformer transformer = new XLSTransformer();
			resultWorkbook = transformer.transformXLS(is, excelMap);
			resultWorkbook.write(baos); 
			response.setHeader("Content-Disposition", "attachment;fileName=\""+"WorkInfoList.xlsx"+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			
			response.getOutputStream().write(baos.toByteArray());
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}  finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
	public String weekendFormat(CoviList weekendStr,String workWeek,char c){
		StringBuffer returnStr = new StringBuffer();
		try {
			
			CoviList weekArry = new CoviList();
			
			int index = 0;
			while (index < workWeek.length()) {
				if(workWeek.charAt(index)== c ){
					CoviMap jo = weekendStr.getJSONObject(index);
					weekArry.add(jo.get("CodeName")); 
				}
				index ++; 
			}
			
			for(int i=0;i<weekArry.size();i++){
				if(i!=0){
					returnStr.append(",");
				} 
				returnStr.append(weekArry.getString(i));
			}
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnStr.toString();
	}
	
	
	
	public String ruleFormat(CoviList workcodeStr,CoviList unittermStr,String wt,String wc, String ut,String ad, char pr){
		String returnStr = "";
		try {
			String sWc = "";
			for(int i=0;i<workcodeStr.size();i++){
				CoviMap jo = workcodeStr.getJSONObject(i);
				if(wc.equals(jo.getString("Code")) ){
					CoviMap code = workcodeStr.getJSONObject(i);
					sWc = code.getString("CodeName");
					break;
				}
			}
			
			String sUt = "";
			for(int i=0;i<unittermStr.size();i++){
				CoviMap jo = unittermStr.getJSONObject(i);
				if(ut.equals(jo.getString("Code"))){
					sUt = jo.getString("CodeName");
					break;
				}
			}
			
			returnStr += wt+pr;
			returnStr += sWc+pr; 
			returnStr += sUt+pr; 
			returnStr += ad;
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnStr;
	}
	

	/**
	  * @Method Name : workInfoTempleteDownload
	  * @작성일 : 2020. 3. 31.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 관리자 설정 - 근로정보 엑셀 템플릿 다운로드
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/workInfoTempleteDownload.do")
	public void workInfoTempleteDownload(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			
			CoviMap params = new CoviMap();
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendWorkInfo_templete.xlsx");
			
			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+"WorkInfo_Templete.xlsx"+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
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


	/**
	 * @Method Name : attendanceScheduleTempleteDownload
	 * @작성일 : 2021. 1. 04.
	 * @작성자 : nkpark
	 * @변경이력 : 기존, downloadTemplate.do?mode=SCHEDULE 호출(자동생성) 에서 양식 파일 다운로드형으로 변경
	 * @Method 설명 : 관리자 설정 - 근무일정 엑셀 템플릿 다운로드
	 * @param request
	 * @param response
	 */
	@RequestMapping(value = "/attendanceScheduleTempleteDownload.do")
	public void attendanceScheduleTempleteDownload(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ByteArrayOutputStream baos = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {

			CoviMap params = new CoviMap();
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Attendance_ScheduleTemplate_excel.xlsx");

			baos = new ByteArrayOutputStream();
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, params);
			resultWorkbook.write(baos);

			response.setHeader("Content-Disposition", "attachment;fileName=\""+"Schedule_Templete.xlsx"+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.getOutputStream().write(baos.toByteArray());
			response.getOutputStream().flush();
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
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




	/**
	  * @Method Name : goWorkInfoByExcelPopup
	  * @작성일 : 2020. 4. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보관리 엑셀 업로드 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goWorkInfoByExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView goWorkInfoByExcelPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new ModelAndView("user/attend/AttendWorkInfoByExcelPopup");
	}
	
	
	
	/**
	  * @Method Name : workInfoExcelUpload
	  * @작성일 : 2020. 4. 1.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 관리 엑셀업로드 유효성검사 팝업
	  * @param uploadfile
	  * @return
	  */
	@RequestMapping(value = "/workInfoExcelUpload.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap workInfoExcelUpload(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			 
			//엑셀파일 데이터 추출
			ArrayList<ArrayList<Object>> dataList = attendCommonSvc.extractionExcelData(params, 2);	// 엑셀 데이터 추출
			CoviMap workInfoObj = attendAdminSettingSvc.checkExcelWorkInfoData(dataList);
			CoviList workInfoList = workInfoObj.getJSONArray("list");
			CoviMap page = new CoviMap(); 
			page.put("listCount", workInfoList.size());
			 
			returnData.put("page", page); 
			returnData.put("list", workInfoList); 
			returnData.put("uploadYn", workInfoObj.getString("uploadYn"));
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "업로드 되었습니다");
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		 
		return returnData;		
	}


	/**
	  * @Method Name : insertWorkInfoListByExcel
	  * @작성일 : 2020. 4. 2.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보관리 엑셀 업로드 데이터 저장
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/insertWorkInfoListByExcel.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap insertWorkInfoListByExcel( HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters) {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			CoviList excelList = CoviList.fromObject(parameters.get("excelList"));
			int cnt = attendAdminSettingSvc.insertWorkInfoExcel(excelList);
			
			returnData.put("cnt", cnt);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "등록 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		 
		return returnData;		
	}
	
	
	/**
	  * @Method Name : insertWorkInfo
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 추가
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/insertWorkInfo.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap insertWorkInfo( HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters) {
		CoviMap returnData = new CoviMap();
		
		try {
			
			CoviList userInfoList = CoviList.fromObject(parameters.get("userInfo"));
			/*CoviList workWeekList = CoviList.fromObject(parameters.get("workWeek"));
			
			StringBuilder sb = new StringBuilder("0000000");
			for(int i=0;i<workWeekList.size();i++){
				String str = workWeekList.getString(i);
				if("mon".equals(str)) { sb.setCharAt(0, '1');}
				else if("tue".equals(str)) { sb.setCharAt(1, '1');}
				else if("wed".equals(str)) { sb.setCharAt(2, '1');}
				else if("thu".equals(str)) { sb.setCharAt(3, '1');}
				else if("fri".equals(str)) { sb.setCharAt(4, '1');}
				else if("sat".equals(str)) { sb.setCharAt(5, '1');}
				else if("sun".equals(str)) { sb.setCharAt(6, '1');}
			}*/
			CoviMap jo = new CoviMap();
			jo.put("ApplyDate", parameters.get("applyDate"));
			jo.put("WorkWeek", parameters.get("workWeek"));
			jo.put("WorkTime", parameters.get("workTime"));
			jo.put("WorkCode", parameters.get("workCode"));
			jo.put("UnitTerm", parameters.get("unitTerm"));
			jo.put("WorkApplyDate", parameters.get("workApplyDate"));
			jo.put("MaxWorkTime", parameters.get("maxWorkTime"));
			jo.put("MaxWorkCode", parameters.get("maxWorkCode"));
			jo.put("MaxUnitTerm", parameters.get("maxUnitTerm"));
			jo.put("MaxWorkApplyDate", parameters.get("maxWorkApplyDate"));
			jo.put("MaxWeekWorkTime", parameters.get("maxWeekWorkTime"));
			jo.put("RegUserCode", SessionHelper.getSession("USERID"));
			jo.put("ValidYn", "Y");
			
			
			CoviList userArry = new CoviList();
			CoviList deptArry = new CoviList();
			
			CoviList paramArry = new CoviList();
			for(int i=0;i<userInfoList.size();i++){
				CoviMap userInfoObj = userInfoList.getJSONObject(i);
				String itemType = userInfoObj.getString("itemType");
				String userCode = "";
				String listType = "";
				if("user".equals(itemType)){
					listType = "UR";
					userCode = userInfoObj.getString("UserCode");
				}else if("group".equals(itemType)){
					if ( userInfoObj.getString("GroupType").equals("Company")){
						listType = "OR";
					}else{
						listType = "GR";
					}	
					userCode = userInfoObj.getString("GroupCode");		
				}
				
				jo.put("TargetName", userInfoObj.getString("DN"));
				jo.put("ListType", listType);
				jo.put("UserCode", userCode);
				paramArry.add(jo);
			}
			
			/*
			 * 사용자/부서 등록 시 미리 등록된 건이 있으면 재등록 안됨
			 * */
			
			CoviMap params = new CoviMap();	
			params.put("workInfoParams", paramArry);
			params.put("ApplyDate", parameters.get("applyDate"));
			
			CoviMap chkObj = attendAdminSettingSvc.checkInsertWorkInfoData(params);
			CoviList chkList = chkObj.getJSONArray("list");
			if(chkList.size()>0){
				returnData.put("chkList", chkList);
				returnData.put("status", Return.FAIL);
			}else{
				returnData.put("status", Return.SUCCESS);
				attendAdminSettingSvc.insertWorkInfo(params);
				returnData.put("message", "등록 되었습니다");
			}
			returnData.put("result", "ok");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;		
	}
	
	@RequestMapping(value = "/updateWorkInfo.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap updateWorkInfo( HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters) {
		CoviMap returnData = new CoviMap();
		
		try {
			
			CoviList userInfoList = CoviList.fromObject(parameters.get("userInfo"));
			
			CoviMap jo = new CoviMap();
			jo.put("ApplyDate", parameters.get("applyDate"));
			jo.put("WorkWeek", parameters.get("workWeek"));
			jo.put("WorkTime", parameters.get("workTime"));
			jo.put("WorkCode", parameters.get("workCode"));
			jo.put("UnitTerm", parameters.get("unitTerm"));
			jo.put("WorkApplyDate", parameters.get("workApplyDate"));
			jo.put("MaxWorkTime", parameters.get("maxWorkTime"));
			jo.put("MaxWorkCode", parameters.get("maxWorkCode"));
			jo.put("MaxUnitTerm", parameters.get("maxUnitTerm"));
			jo.put("MaxWorkApplyDate", parameters.get("maxWorkApplyDate"));
			jo.put("MaxWeekWorkTime", parameters.get("maxWeekWorkTime"));
			jo.put("RegUserCode", SessionHelper.getSession("USERID"));
			jo.put("ValidYn", "Y");
			
			
			CoviList userArry = new CoviList();
			CoviList deptArry = new CoviList();
			
			CoviList paramArry = new CoviList();
			for(int i=0;i<userInfoList.size();i++){
				CoviMap userInfoObj = userInfoList.getJSONObject(i);
				String itemType = userInfoObj.getString("itemType");
				String userCode = "";
				String listType = "";
				if("user".equals(itemType) || "UR".equals(itemType)){
					listType = "UR";
					userCode = userInfoObj.getString("UserCode");
				}else if("group".equals(itemType) || "GR".equals(itemType)){
					listType = "GR";
					userCode = userInfoObj.getString("GroupCode");		
				}
				else{
					listType = "OR";
					userCode = userInfoObj.getString("GroupCode");		
					
				}
				jo.put("TargetName", userInfoObj.getString("DN"));
				jo.put("ListType", listType);
				jo.put("UserCode", userCode);
				paramArry.add(jo);
			}
			
			/*
			 * 사용자/부서 등록 시 미리 등록된 건이 있으면 재등록 안됨
			 * */
			
			CoviMap params = new CoviMap();	
			params.put("workInfoParams", paramArry);
			params.put("ApplyDate", parameters.get("applyDate"));
			if (parameters.get("applyDate").equals(parameters.get("orgApplyDate"))){
				returnData.put("status", Return.SUCCESS);
				attendAdminSettingSvc.updateWorkInfo(params); 				
			}else{
				
				CoviMap chkObj = attendAdminSettingSvc.checkInsertWorkInfoData(params);
				CoviList chkList = chkObj.getJSONArray("list");
				if(chkList.size()>0){
					returnData.put("chkList", chkList);
				}else{
					returnData.put("status", Return.SUCCESS);
					attendAdminSettingSvc.insertWorkInfo(params); 				
				}
			}
			returnData.put("result", "ok");
			returnData.put("message", "등록 되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnData;		
	}
	
	/**
	  * @Method Name : delWorkInfo
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근로정보 삭제
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping(value = "/delWorkInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap delWorkInfo(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		try { 
			
			CoviMap params = new CoviMap();
			
			String pidList = StringUtil.replaceNull(request.getParameter("pid"), "[]");
			CoviList pidArray =  CoviList.fromObject(pidList.replaceAll("&quot;", "\""));
			for(int i=0;i<pidArray.size();i++){	
				String[] pid = pidArray.getString(i).split("\\^");
				params.put("ListType",pid[0]);
				params.put("UserCode",pid[1]);
				params.put("ApplyDate",pid[2]); 
				
				if("OR".equals(pid[0])){
					jo.put("msg", DicHelper.getDic("msg_n_att_unableToDelBasicWorkInfo") );	//기본 근로정보를 삭제할 수 없습니다.
				}else{
					attendAdminSettingSvc.deleteWorkInfo(params);  	
					jo.put("msg", DicHelper.getDic("msg_138") );	//성공적으로 삭제되었습니다.
				}
			}
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ArrayIndexOutOfBoundsException e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	
	
	@RequestMapping(value = "/setWorkInfo.do")
	public @ResponseBody CoviMap setWorkInfo(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		try { 
			
			CoviMap wiObj = new CoviMap();

			wiObj.put("ListType",request.getParameter("listtype"));
			wiObj.put("UserCode",request.getParameter("usercode"));
			wiObj.put("ApplyDate",request.getParameter("applydate"));
			wiObj.put("ValidYn",request.getParameter("validYn"));

			CoviMap params = new CoviMap();
			CoviList workInfoParams = new CoviList();
			workInfoParams.add(wiObj);
			params.put("workInfoParams",workInfoParams);
			attendAdminSettingSvc.insertWorkInfo(params);  			
			
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	

	/**
	  * @Method Name : getHolidayList
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴일정보 리스트 조회
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/getHolidayList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getHolidayList(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters){
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
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("year", request.getParameter("year"));
			params.put("schTypeSel", request.getParameter("schTypeSel")); 
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			
			resultList = attendAdminSettingSvc.getHolidayList(params);
			 
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		
		return returnList;
	}
	
	/**
	  * @Method Name : goAttHolidayPopup
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 등록 팝업
	  * @param request
	  * @param locale
	  * @param model
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goAttHolidayPopup.do", method = RequestMethod.GET)
	public ModelAndView goAttHolidayPopup(HttpServletRequest request, Locale locale, Model model) throws Exception{
		ModelAndView mav = new ModelAndView();
		String sts = request.getParameter("Sts");
		if("UPD".equals(sts)){
			CoviMap params = new CoviMap();
			params.put("HolidayStart",request.getParameter("HolidayStart") );
			params.put("HolidayEnd",request.getParameter("HolidayEnd") );
			params.put("GoogleYn",request.getParameter("GoogleYn") );

			CoviMap holi = attendAdminSettingSvc.getHolidayList(params);
			CoviList holiList = holi.getJSONArray("list");
			mav.addObject("holi",holiList.get(0));	
			mav.addObject("sts",sts);	
		}
		mav.setViewName("user/attend/AttendHolidayPopup");
		return mav;
	}

	
	/**
	  * @Method Name : delHoliday
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 정보 삭제
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/deleteHoliday.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap delHoliday(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters){
		CoviMap returnJson = new CoviMap();
		try {
			CoviList startArray = CoviList.fromObject(parameters.get("StartDayArry"));	
	    	for(int i=0;i<startArray.size();i++){
				CoviMap params = new CoviMap();
	    		String HolidayStart = startArray.getString(i);
				params.put("HolidayStart", HolidayStart);
				params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
				attendAdminSettingSvc.deleteHoliday(params);
			}
			returnJson.put("status", Return.SUCCESS); 
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
	  * @Method Name : createHoliday
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 정보 등록
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/createHoliday.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createHoliday(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters){
		CoviMap returnJson = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("StartDate", request.getParameter("HolidayStart"));	
			params.put("EndDate",request.getParameter("HolidayEnd"));	
			params.put("GoogleCheck","Y");

			CoviMap resultList = attendAdminSettingSvc.getHolidayList(params);
			if(resultList.getJSONArray("list").size()>0){
				returnJson.put("status", "PRIMARY"); 
			}else{
				params.put("HolidayStart", request.getParameter("HolidayStart"));	
				params.put("HolidayEnd",request.getParameter("HolidayEnd"));	
				params.put("HolidayName",request.getParameter("HolidayName"));	
				params.put("GoogleYn","N");	
				params.put("Etc", request.getParameter("Etc"));	
				attendAdminSettingSvc.createHoliday(params);				
				returnJson.put("status", Return.SUCCESS); 
			}

		} catch(SQLIntegrityConstraintViolationException e){
			returnJson.put("status", "PRIMARY"); 
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e){
			returnJson.put("status", "PRIMARY"); 
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnJson.put("status", Return.FAIL); 
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnJson;
	}
	 
	/**
	  * @Method Name : setGoogleHoliday
	  * @작성일 : 2020. 4. 7.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 구글 캘린더 공휴일 정보 등록
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/setGoogleHoliday.do")
	public @ResponseBody CoviMap setGoogleHoliday(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters) {
		CoviMap jo = new CoviMap();
		try { 
			CoviMap params = new CoviMap();
			
			CoviList holiList = CoviList.fromObject(parameters.get("holi"));
			ObjectMapper mapper = new ObjectMapper();
			for(int i=0;i<holiList.size();i++){
	    		CoviMap map = holiList.getJSONObject(i);

	    		params.put("HolidayStart", map.get("startDay"));	 
				params.put("HolidayEnd", map.get("startDay"));	 
				params.put("HolidayName", map.get("summary"));	 
				params.put("GoogleYn", "Y");	 
				attendAdminSettingSvc.createHoliday(params);
	    	}	    	
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	
	/**
	  * @Method Name : updateHoliday
	  * @작성일 : 2020. 4. 8. 
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 회사 휴무일 정보 수정
	  * @param request
	  * @param response
	  * @param parameters
	  * @return
	  */
	@RequestMapping(value = "/updateHoliday.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateHoliday(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters){
		CoviMap returnJson = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			
			params.put("HolidayStart", request.getParameter("HolidayStart"));	
			params.put("HolidayEnd",request.getParameter("HolidayEnd"));	
			params.put("HolidayName",request.getParameter("HolidayName"));	
			params.put("GoogleYn",request.getParameter("GoogleYn"));	
			params.put("Etc", request.getParameter("Etc"));	
			attendAdminSettingSvc.createHoliday(params);		
			returnJson.put("status", Return.SUCCESS); 
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
	  * @Method Name : getOtherJobList
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무관리 리스트 조회
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping(value = "/getOtherJobList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getOtherJobList(HttpServletRequest request, HttpServletResponse response){
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
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));
			params.put("ValidYn", request.getParameter("ValidCheck"));
			
			resultList = attendAdminSettingSvc.getOtherJobList(params);			 
	
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}		 
		
		return returnList;
	}
	
	
	/**
	  * @Method Name : setOtherJob
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무 등록/수정
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping(value = "/setOtherJob.do")
	public @ResponseBody CoviMap setOtherJob(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		try { 
			CoviMap params = new CoviMap();
			String jobStsSeq = StringUtil.replaceNull(request.getParameter("jobStsSeq"), "");
			
			if (!jobStsSeq.equals(""))  params.put("JobStsSeq", jobStsSeq);
			params.put("ValidYn", request.getParameter("validYn"));
			params.put("JobStsName", request.getParameter("jobStsName"));
			params.put("MultiDisplayName", request.getParameter("multiDisplayName"));
			params.put("Memo", request.getParameter("memo"));
			params.put("ReqMethod", request.getParameter("reqMethod"));
			attendAdminSettingSvc.setOtherJob(params);   	
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	
	/**
	  * @Method Name : delOtherJob
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 기타근무정보 삭제
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping(value = "/delOtherJob.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap delOtherJob(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		try { 
			CoviMap params = new CoviMap();
			String jobStsSeqList = StringUtil.replaceNull(request.getParameter("jobStsSeq"), "[]");
			
			CoviList jobStsSeqArray =  CoviList.fromObject(jobStsSeqList.replaceAll("&quot;", "\""));
			for(int i=0;i<jobStsSeqArray.size();i++){	
				String jobStsSeq = jobStsSeqArray.getString(i);
				params.put("JobStsSeq", jobStsSeq);
				attendAdminSettingSvc.delteOtherJob(params);  				
			}
			
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){ 
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	
	/**
	  * @Method Name : goOtherJobAddPopup
	  * @작성일 : 2020. 4. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :  관리자 설정 - 기타근무관리 추가 팝업
	  * @param request
	  * @param response
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goOtherJobAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goOtherJobAddPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("user/attend/AttendOtherJobAddPopup");
		
		if(request.getParameter("jobStsSeq")!=null){
			CoviMap params = new CoviMap();
			params.put("JobStsSeq", request.getParameter("jobStsSeq"));
			CoviList resultList = attendAdminSettingSvc.getOtherJobList(params).getJSONArray("list");
			mav.addObject("otherJob", resultList.getJSONObject(0));
			mav.addObject("sts","UPD");
		}
		
		return mav;
	}

	/**
	 * @Method Name : getWorkPlaceList
	 * @작성일 : 2021. 8. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정 - 근무지관리 리스트 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getWorkPlaceList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getWorkPlaceList(HttpServletRequest request, HttpServletResponse response) throws Exception {
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
			
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));			

			resultList = attendAdminSettingSvc.getWorkPlaceList(params);			

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnList;
	}


	/**
	 * @Method Name : insertWorkPlace
	 * @작성일 : 2021. 8. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정 - 근무지 신규 등록
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/insertWorkPlace.do")
	public @ResponseBody CoviMap insertWorkPlace(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		int rst = -1;
		try {
			CoviMap params = new CoviMap();
			params.put("WorkZoneGroupNm",request.getParameter("WorkZoneGroupNm"));
			params.put("WorkZone",request.getParameter("WorkZone"));
			params.put("WorkAddr",request.getParameter("WorkAddr"));
			params.put("WorkPointX",request.getParameter("WorkPointX"));
			params.put("WorkPointY",request.getParameter("WorkPointY"));
			params.put("AllowRadius",request.getParameter("AllowRadius"));
			params.put("ValidYn",request.getParameter("ValidYn"));
			rst = attendAdminSettingSvc.insertWorkPlace(params);
			if(rst>0) {
				jo.put("status", Return.SUCCESS);
			}else{
				jo.put("status", Return.FAIL);
			}
		} catch(NullPointerException e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}

	/**
	 * @Method Name : updateWorkPlace
	 * @작성일 : 2021. 8. 12.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정 - 근무지 신규 등록
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/updateWorkPlace.do")
	public @ResponseBody CoviMap updateWorkPlace(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		int rst = -1;
		try {
			CoviMap params = new CoviMap();

			params.put("LocationSeq",request.getParameter("LocationSeq"));
			params.put("WorkZoneGroupNm",request.getParameter("WorkZoneGroupNm"));
			params.put("WorkZone",request.getParameter("WorkZone"));
			params.put("WorkAddr",request.getParameter("WorkAddr"));
			params.put("WorkPointX",request.getParameter("WorkPointX"));
			params.put("WorkPointY",request.getParameter("WorkPointY"));
			params.put("AllowRadius",request.getParameter("AllowRadius"));
			params.put("ValidYn",request.getParameter("ValidYn"));
			rst = attendAdminSettingSvc.updateWorkPlace(params);
			if(rst>0) {
				jo.put("status", Return.SUCCESS);
			}else{
				jo.put("status", Return.FAIL);
			}
		} catch(NullPointerException e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}
	/**
	 * @Method Name : delWorkPlace
	 * @작성일 : 2021. 08. 11.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 근무지 관리 -근무지 삭제
	 * @param request
	 * @param response
	 * @return JSONObject
	 */
	@RequestMapping(value = "/delWorkPlace.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap delWorkPlace(HttpServletRequest request, HttpServletResponse response) {
		CoviMap jo = new CoviMap();
		try {
			CoviMap params = new CoviMap();
			String LocationSeqList = StringUtil.replaceNull(request.getParameter("LocationSeqArr"), "[]");
			CoviList pidArray =  CoviList.fromObject(LocationSeqList.replaceAll("&quot;", "\""));
			for(int i=0;i<pidArray.size();i++){
				String[] LocationSeqArr = pidArray.getString(i).split("\\^");
				params.put("LocationSeq",LocationSeqArr[0]);
				attendAdminSettingSvc.deleteWorkPlace(params);
				jo.put("msg", DicHelper.getDic("msg_138") );	//성공적으로 삭제되었습니다.

			}
			jo.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			jo.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return jo;
	}

	/**
	 * @Method Name : delWorkPlace
	 * @작성일 : 2021. 08. 13.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 근무지 관리 -근무지 삭제
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping(value = "/workPlaceExcelListDownload.do" , method = RequestMethod.GET)
	public void workPlaceExcelListDownload(HttpServletRequest request, HttpServletResponse response) {

		CoviMap excelMap= new CoviMap();
		excelMap.put("title", "근무지 관리 목록");
		ByteArrayOutputStream baos =  null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendWorkPlaceList_templete.xlsx");

			CoviMap workPlaceList = new CoviMap();
			workPlaceList = attendAdminSettingSvc.getWorkPlaceList(params);
			excelMap.put("list", workPlaceList.get("list"));

			baos = new ByteArrayOutputStream();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			XLSTransformer transformer = new XLSTransformer();
			resultWorkbook = transformer.transformXLS(is, excelMap);
			resultWorkbook.write(baos);
			response.setHeader("Content-Disposition", "attachment;fileName=\""+"WorkPlaceList.xlsx"+"\";");
			response.setHeader("Content-Description", "JSP Generated Data");
			response.setContentType("application/vnd.ms-excel;charset=utf-8");

			response.getOutputStream().write(baos.toByteArray());
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
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


	/**
	 * @Method Name : getWorkPlaceListRest
	 * @작성일 : 2021. 8. 13.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 : 관리자 설정 - 근무지관리 리스트 조회 - restApi
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/getWorkPlaceList.rest", method = RequestMethod.GET)
	public @ResponseBody
	CoviMap getWorkPlaceListRest(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));

			resultList = attendAdminSettingSvc.getWorkPlaceList(params);


			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Enums.Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Enums.Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage(): DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Enums.Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage(): DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} 

		return returnList;
	}
	
	/**
	 * @Method: goAttendBaseDatePop
	 * @Comment : 근태에서 기초 데이터로 사용하는 날짜 데이터(attendance_daylist)의 조회 및 추가 생성을 위한 팝업.
	 * @작성일 : 2022.12.12
	 * @param : HttpServletRequest
	 * @param : Model
	 * @return : ModelAndView
	 */
	@RequestMapping(value = "/goBaseAttendDatePop.do", method = RequestMethod.GET)
	public ModelAndView goAttendBaseDatePop(HttpServletRequest request, Model model) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap returnList = attendAdminSettingSvc.selecAttendMaxBaseDatePop(params);
		
		ModelAndView mav = new ModelAndView("user/attend/AttendBaseDatePopup");
		if (returnList.size() > 0 ) {
			mav.addObject("result", returnList.get("list"));
		} else {
			mav.addObject("result", "");
		}
		
		return mav;
	}
	
	/**
	 * @Method : insertAttendBaseDate
	 * @작성일 : 2022.12.12
	 * @Method : 관리자가 추가로 지정한 날까지 날짜 데이터 생성(attendance_daylist).
	 * @param : HttpServletRequest
	 * @param : Model
	 * @return : ModelAndView
	 */
	@RequestMapping(value = "/addAttendBaseDate.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertAttendBaseDate(@RequestParam(value = "addDate", required = true) String addDate) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap returnMap = new CoviMap();
		
		// 전달값 오류가 생기지 않도록 최신값을 조회.
		CoviMap baseList = attendAdminSettingSvc.selecAttendMaxBaseDatePop(params);
		addDate += ".12.31";
		
		int diffDateCnt = 0;
		if (baseList.size() > 0) {
			CoviList list = (CoviList)baseList.get("list");
			params = (CoviMap)list.get(0);
			String lastDate = (String)params.get("DayList");
			diffDateCnt = DateHelper.diffDate(addDate, lastDate);
			
			params.put("lastDate", lastDate);
			params.put("diffDateCnt", diffDateCnt);
		}
		params.put("addDate", addDate);
		
		try {
			if (diffDateCnt > 0) {
				for (int i=1; diffDateCnt+1>i; i++) {
					params.put("nextDay", i);
					attendAdminSettingSvc.insertAttendBaseDate(params);
				}
			}
			
			returnMap.put("result", "ok");
			returnMap.put("status", Return.SUCCESS);
			returnMap.put("message", DicHelper.getDic("msg_37")); 	// 저장되었습니다.
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
            returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030")); 	// 오류가 발생했습니다.
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030")); 	// 오류가 발생했습니다.
		}
		
		return returnMap;
	}	

	@RequestMapping(value = "/getAttModifyHisList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAttModifyHisList(HttpServletRequest request, HttpServletResponse response) throws Exception {
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
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", sortColumn);
			params.put("sortDirection", sortDirection);
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));			
			params.put("selectSearch", request.getParameter("selectSearch"));
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));			
			params.put("deptCode", request.getParameter("deptCode"));
			
			resultList = attendAdminSettingSvc.getAttModifyHisList(params);
			
			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "/attModifyHisDownloadExcel.do" , method = RequestMethod.GET)
	public void attModifyHisDownloadExcel(HttpServletRequest request, HttpServletResponse response) {
		
		ByteArrayOutputStream baos =  null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		
		try {
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//AttendModifyHistoryList_templete.xlsx");
			
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("companyCode", SessionHelper.getSession("DN_Code"));
			params.put("schTypeSel", request.getParameter("schTypeSel"));
			params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));			
			params.put("selectSearch", request.getParameter("selectSearch"));
			params.put("startDate", request.getParameter("startDate"));
			params.put("endDate", request.getParameter("endDate"));			
			params.put("deptCode", request.getParameter("deptCode"));
			
			CoviList workInfoList = attendAdminSettingSvc.getAttModifyHisExcelList(params);

			CoviMap excelMap = new CoviMap();
			excelMap.put("list", workInfoList);
			excelMap.put("title", "근태 변경 이력");
			
			baos = new ByteArrayOutputStream();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			XLSTransformer transformer = new XLSTransformer();
			resultWorkbook = transformer.transformXLS(is, excelMap);
			resultWorkbook.write(baos); 
			response.setHeader("Content-Disposition", "attachment;fileName=\""+"AttendModifyHistoryList.xlsx"+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			
			response.getOutputStream().write(baos.toByteArray());
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}  finally {
			if (fis != null) { try{ fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (is != null) { try{ is.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (baos != null) { try{ baos.flush(); baos.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (resultWorkbook != null) { try{ resultWorkbook.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
	}
	
}