package egovframework.covision.groupware.attend.user.web;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.groupware.attend.user.service.AttendReqSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;



import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.ArrayUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import egovframework.baseframework.util.json.JSONParser;

@Controller
@RequestMapping("/attendAPI")
public class AttendAPICon {
	private Logger LOGGER = LogManager.getLogger(AttendAPICon.class);
	
	@Autowired 
	AttendReqSvc attendReqSvc;

	// 전자결재 연동용
	@RequestMapping(value="requestApproval.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap requestApproval(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CoviMap returnList = new CoviMap();
		String formPrefix = request.getParameter("formPrefix"); 
//		String ApvMode = request.getParameter("ApvMode");
		try {
			String jsonStr = new String(Base64.decodeBase64(request.getParameter("bodyContext")), StandardCharsets.UTF_8);
			
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			if (commuteIp == null){ 
				commuteIp = request.getRemoteAddr(); 
			}

			JSONParser parser = new JSONParser();
			CoviMap ReqData = (CoviMap)parser.parse(jsonStr) ;
			CoviMap returnObj = new CoviMap();
			CoviMap coviMap= new CoviMap();
			CoviList dataList = new CoviList();
			List coviList = new ArrayList<>();
			switch (formPrefix){
		        case "WF_FORM_CALL": //소명신청서
	        		String ReqType ;
	        		
		        	if (ReqData.get("TBL_CALL_INFO") instanceof CoviMap) {
		        		dataList.add(ReqData.get("TBL_CALL_INFO"));
		        	} else {
		        		dataList = (CoviList)ReqData.get("TBL_CALL_INFO");
		        	}
		        	
		        	coviMap.put("ReqType", "C");
		        	coviMap.put("ReqGubun", "C");
//					coviMap.put("UR_Code", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));	
					
					coviMap.put("ReqTitle", request.getParameter("BillName"));	
					coviMap.put("ReqStatus", "Approval");	
					coviMap.put("ReqMethod", "Approval");	
					coviMap.put("ProcessId", request.getParameter("ProcessId"));	
					for (int i=0; i < dataList.size(); i++){
						CoviMap orgMap = (CoviMap)dataList.get(i);
						Map detailMap = new java.util.HashMap<>();
						detailMap.put("WorkDate", AttendUtils.removeMaskAll((String)orgMap.get("CallDate")));
						detailMap.put("NextDayYn", "N");
						if(orgMap.get("Division").equals("출근시간")){  
							detailMap.put("Division", "StartSts");
						}
						else{
							if ( Integer.parseInt(AttendUtils.removeMaskAll((String)orgMap.get("CallDate"))) <Integer.parseInt(AttendUtils.removeMaskAll((String)orgMap.get("changeDate"))))				detailMap.put("NextDayYn", "Y");
							detailMap.put("Division", "EndSts");
						}	
						detailMap.put("ChgTime", (String)orgMap.get("hour")+(String)orgMap.get("min"));
						detailMap.put("Comment", orgMap.get("Etc"));
						
						detailMap.put("BillName", request.getParameter("BillName"));//걸재제목
						detailMap.put("ProcessId", request.getParameter("ProcessId"));//processid
						detailMap.put("RegisterCode", request.getParameter("RegisterCode"));	

		        		detailMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
		        		detailMap.put("UserCode", orgMap.get("UserCode"));

		        		coviMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
		        		coviMap.put("UserCode", orgMap.get("UserCode"));
		        		//coviMap.put("UR_Code", orgMap.get("UserCode"));
		        		
						coviList.add(detailMap);
					}	
		        	break;
		        case "WF_FORM_HOLIDAY_WORK": //휴일근무신청서
		        case "WF_FORM_OVERTIME_WORK": //연장근무신청서
	    			if(formPrefix.equalsIgnoreCase("WF_FORM_HOLIDAY_WORK")) { //휴일
	    				ReqType = "H";
	    			} else { //연장
	    				ReqType = "O";
	    			}
	    			
	        		if (!ReqData.get("HID_PROCESSID").equals("")){
						coviMap.put("ReqGubun", "U");
						coviMap.put("orgProcessId", ReqData.get("HID_PROCESSID"));
		        	}else{
						coviMap.put("ReqGubun", "C");
		        	}
	        		
		        	if (ReqData.get("TBL_WORK_INFO") instanceof CoviMap) {
		        		dataList.add(ReqData.get("TBL_WORK_INFO"));
		        	} else {
		        		dataList = (CoviList)ReqData.get("TBL_WORK_INFO");
		        	}
		        	
		        	coviMap.put("ReqType", ReqType);
//					coviMap.put("UR_Code", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));	
					
					coviMap.put("ReqTitle", request.getParameter("BillName"));	
					coviMap.put("ReqStatus", "Approval");	
					coviMap.put("ReqMethod", "Approval");	
					coviMap.put("ProcessId", request.getParameter("ProcessId"));	
					if (dataList == null){
						coviMap.put("ReqGubun", "D");
					}
					else{
						for (int i=0; i < dataList.size(); i++){
							CoviMap orgMap = (CoviMap)dataList.get(i);
							Map detailMap = new java.util.HashMap<>();
							detailMap.put("WorkDate", AttendUtils.removeMaskAll((String)orgMap.get("JobDate")));
							detailMap.put("JobStsName", orgMap.get("JobStsName"));
							detailMap.put("StartTime", AttendUtils.removeMaskAll((String)orgMap.get("StartTime")));
							detailMap.put("EndTime", AttendUtils.removeMaskAll((String)orgMap.get("EndTime")));
							detailMap.put("WorkTime", AttendUtils.removeMaskAll((String)orgMap.get("WorkTime")));
							detailMap.put("Comment", orgMap.get("Etc"));
							detailMap.put("IdleTime", orgMap.get("IdleTime"));
							detailMap.put("AcTime", AttendUtils.removeMaskAll((String)orgMap.get("WorkTime")));
							detailMap.put("NextDayYn", orgMap.get("NextDayYn") == null ? "N":orgMap.get("NextDayYn"));
							
							detailMap.put("UserCode", orgMap.get("UserCode"));	
							detailMap.put("CompanyCode", orgMap.get("CompanyCode"));	
							detailMap.put("Comment", orgMap.get("Etc"));	

							
							detailMap.put("BillName", request.getParameter("BillName"));//걸재제목
							detailMap.put("ProcessId", request.getParameter("ProcessId"));//processid
							detailMap.put("RegisterCode", ReqData.get("InitiatorCodeDisplay"));	
							if (coviMap.get("UserCode").equals("")){
								coviMap.put("UserCode", orgMap.get("UserCode"));	
							}
//			        		coviMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
			        		
							coviList.add(detailMap);
						}	
					}
		        	break;
				case "HOLIDAY_REPLACEMENT_WORK": // 휴일대체근무신청
					coviMap.put("ReqGubun", "C");
					coviMap.put("ReqType", "HR");
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("RegisterCode", request.getParameter("RegisterCode"));

					coviMap.put("ReqTitle", request.getParameter("BillName"));
					coviMap.put("ReqStatus", "Approval");
					coviMap.put("ReqMethod", "Approval");
					coviMap.put("ProcessId", request.getParameter("ProcessId"));

					coviMap.put("HolidayDate", ReqData.get("HolidayDate")); // 휴일근무일
					coviMap.put("AlternativeHolidayDate", ReqData.get("AlternativeHolidayDate")); // 휴일대체지정일

					coviMap.put("CompanyCode", ReqData.get("CompanyCode")); //회사코드
					coviMap.put("UserCode", ReqData.get("UserCode")); // 근무자유저ID

					break;
				case "WF_FORM_VACATION_REQUEST2": // 휴가신청
				case "WF_FORM_VACATIONCANCEL": // 휴가 취소 신청서
		        	if (ReqData.get("tblVacInfo") instanceof CoviMap) {
		        		dataList.add(ReqData.get("tblVacInfo"));
		        	} else {
		        		dataList= (CoviList)ReqData.get("tblVacInfo");
		        	}
		        	
		        	coviMap.put("ReqType", "V");
//					coviMap.put("UR_Code", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));	
					coviMap.put("HID_REQUEST_FIID", ReqData.get("HID_REQUEST_FIID"));
										
					coviMap.put("ReqTitle", request.getParameter("BillName"));	
					coviMap.put("ReqStatus", "Approval");	
					coviMap.put("ReqMethod", "Approval");	
					coviMap.put("ProcessId", request.getParameter("ProcessId"));	
					String Gubun="";
					if (formPrefix.equals("WF_FORM_VACATIONCANCEL")){
						coviMap.put("ReqGubun", "D");
						Gubun = "VACATION_CANCEL";
					}else{
						coviMap.put("ReqGubun", "C");
						Gubun = "VACATION_APPLY";
					}	
					coviMap.put("Comment", ((String)ReqData.get("VAC_REASON")).replace("'","''"));
//					coviMap.put("UR_Code", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("UserName", ReqData.get("InitiatorDisplay"));
					String toDay = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
					for (int i=0; i < dataList.size(); i++){
						CoviMap orgMap = (CoviMap)dataList.get(i);
						Map detailMap = new java.util.HashMap<>();

						detailMap.put("WorkDate", ReqData.get("Sel_Year"));
						detailMap.put("VacYear", ReqData.get("Sel_Year"));
						detailMap.put("VacFlag", orgMap.get("VACATION_TYPE"));
						detailMap.put("SDate", orgMap.get("_MULTI_VACATION_SDT"));
						detailMap.put("EDate", orgMap.get("_MULTI_VACATION_EDT"));
						
						float vacDay = Float.parseFloat((formPrefix.equals("WF_FORM_VACATIONCANCEL")?"-":"")+orgMap.getString("_MULTI_DAYS").replaceAll("[^0-9.]", ""));
						detailMap.put("VacDay", vacDay);
		        		
						detailMap.put("AppDate", ReqData.get("InitiatedDate"));
						detailMap.put("EndDate", toDay);
						detailMap.put("Gubun", Gubun);
		        		
		        		if(orgMap.containsKey("VACATION_OFF_TYPE")) { // 오전/오후 반차 구분 추가
		        			detailMap.put("VacOffFlag", orgMap.get("VACATION_OFF_TYPE"));
		        		}
		        		
		        		if(orgMap.containsKey("_MULTI_VACATION_STIME")) {
		        			detailMap.put("STime", orgMap.get("_MULTI_VACATION_STIME"));
		        		}
		        		if(orgMap.containsKey("_MULTI_VACATION_ETIME")) {
		        			detailMap.put("ETime", orgMap.get("_MULTI_VACATION_ETIME"));
		        		}
		        		
		        		
		        		detailMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
		        		detailMap.put("DeputyName", ReqData.get("DEPUTY_NAME"));
		        		detailMap.put("DeputyCode", ReqData.get("DEPUTY_CODE"));
		        		detailMap.put("WorkItemId", request.getParameter("WorkItemId"));
		        		detailMap.put("ProcessId", request.getParameter("ProcessId"));

						coviMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
		        		
						coviList.add(detailMap);
					}	
					break;
				case "WF_FORM_WORK_SCHEDULE"://근무일정 생성
	
		        	if (ReqData.get("tblWorkScheduleInfo") instanceof CoviMap) {
		        		dataList.add(ReqData.get("tblWorkScheduleInfo"));
		        	} else {
		        		dataList= (CoviList)ReqData.get("tblWorkScheduleInfo");
		        	}
	
					coviMap.put("ReqType", "S");
					coviMap.put("ReqGubun", "C");
//					coviMap.put("UR_Code", ReqData.get("InitiatorCodeDisplay"));
					coviMap.put("Comment", ReqData.get("SCHEDULE_REASON"));	
	        		coviMap.put("CompanyCode", ReqData.get("HID_COMPANTYCODE"));
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));	
					
					coviMap.put("ReqTitle", request.getParameter("BillName"));	
					coviMap.put("ReqStatus", "Approval");	
					coviMap.put("ReqMethod", "Approval");	
					coviMap.put("ProcessId", request.getParameter("ProcessId"));	
	
					for (int i=0; i < dataList.size(); i++){
						CoviMap orgMap = (CoviMap)dataList.get(i);
						Map detailMap = new java.util.HashMap<>();
						detailMap.put("SchSeq", orgMap.getString("WORK_TYPE").equals("N")?"-1":orgMap.get("WORK_TYPE"));
						detailMap.put("StartDate", orgMap.get("_MULTI_SCHEDULE_SDT"));
						detailMap.put("EndDate", orgMap.get("_MULTI_SCHEDULE_EDT"));
						detailMap.put("StartTime", orgMap.getString("_MULTI_WORK_START_H")+orgMap.getString("_MULTI_WORK_START_M"));
						detailMap.put("EndTime", orgMap.getString("_MULTI_WORK_END_H")+orgMap.getString("_MULTI_WORK_END_M"));
						detailMap.put("NextDayYn", orgMap.getString("CHK_NEXT_DAY"));
						detailMap.put("EndDate", orgMap.get("_MULTI_SCHEDULE_EDT"));
						detailMap.put("JobUserCode", ReqData.get("InitiatorCodeDisplay"));
						detailMap.put("HolidayFlag", !orgMap.get("opt").equals("Y")?"N":"Y");
						detailMap.put("CompanyCode", ReqData.get("CompanyCode"));//회사코드
						coviList.add(detailMap);
					}	
	
					break;
				case "WF_OTHER_WORK": // 기타 근무 신청서	
	
		        	if (ReqData.get("TBL_OTHER_WORK_INFO") instanceof CoviMap) {
		        		dataList.add(ReqData.get("TBL_OTHER_WORK_INFO"));
		        	} else {
		        		dataList= (CoviList)ReqData.get("TBL_OTHER_WORK_INFO");
		        	}
		        	
		        	if (!ReqData.get("HID_PROCESSID").equals("")){
						coviMap.put("ReqGubun", "U");
						coviMap.put("orgProcessId", ReqData.get("HID_PROCESSID"));
		        	}else{
						coviMap.put("ReqGubun", "C");
		        	}
	
					coviMap.put("ReqType", "J");
	//				coviMap.put("ReqGubun", "C");
					coviMap.put("UserCode", ReqData.get("InitiatorCodeDisplay"));	
					coviMap.put("RegisterCode", request.getParameter("RegisterCode"));	
					
					coviMap.put("ReqTitle", request.getParameter("BillName"));	
					coviMap.put("ReqStatus", "Approval");	
					coviMap.put("ReqMethod", "Approval");	
					coviMap.put("ProcessId", request.getParameter("ProcessId"));	
	
					for (int i=0; i < dataList.size(); i++){
						CoviMap orgMap = (CoviMap)dataList.get(i);
	
						Map detailMap = new java.util.HashMap<>();
						detailMap.put("WorkDate", orgMap.get("JobDate"));
						detailMap.put("JobStsSeq", orgMap.get("WorkType"));
						detailMap.put("JobStsName", orgMap.get("WorkType_TEXT"));
						detailMap.put("StartTime", AttendUtils.removeMaskAll((String)orgMap.get("StartTime")));
						detailMap.put("EndTime", AttendUtils.removeMaskAll((String)orgMap.get("EndTime")));
						
						
						detailMap.put("CompanyCode", orgMap.get("CompanyCode"));//회사코드
						detailMap.put("Comment", orgMap.get("Etc"));
						detailMap.put("UserCode", orgMap.get("UserCode"));
						coviList.add(detailMap);
					}	
	
					break;
			}

			// 휴가신청서/취소신청서 결재중 데이터처리.
			String[] vacForms = new String[]{"WF_FORM_VACATION_REQUEST2","WF_FORM_VACATIONCANCEL"};
			String ApvMode = request.getParameter("ApvMode");
			coviMap.put("ApvMode", ApvMode);
			coviMap.put("FormInstID", request.getParameter("FormInstId"));
			coviMap.put("CommuteIp", commuteIp);
			if(ArrayUtils.contains(vacForms, formPrefix) && !"COMPLETE".equals(ApvMode)) {
				// 진행중 휴가테이블에 갱신.
				returnList = attendReqSvc.approvalAttendPApproval(coviMap, coviList);
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				return returnList;
			}
					
			returnList = attendReqSvc.approvalAttendEApproval(coviMap, coviList);
			// 진행중 휴가테이블에 갱신(삭제)
			returnList = attendReqSvc.approvalAttendPApproval(coviMap, coviList);
			CoviMap params = new CoviMap();
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
		}
		return returnList;
	}

	
}

