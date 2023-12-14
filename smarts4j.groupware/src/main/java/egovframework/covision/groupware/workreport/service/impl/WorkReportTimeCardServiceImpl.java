package egovframework.covision.groupware.workreport.service.impl;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.workreport.service.WorkReportTimeCardService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("WorkReportTimeCardService")
public class WorkReportTimeCardServiceImpl extends EgovAbstractServiceImpl implements WorkReportTimeCardService{

	@Autowired
	private MessageService messageSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int chkDuplicateCalendar(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("groupware.workreport.checkcalendar", params);
	}

	@Override
	public int insertCalendar(CoviMap params) throws Exception {
		int weekOfMonth = (int)coviMapperOne.getNumber("groupware.workreport.nextweekofmonth", params);
		params.put("WeekOfMonth", weekOfMonth);
		
		int insertKey = 0;
		coviMapperOne.insert("groupware.workreport.insertcalendar", params);
		insertKey = params.getInt("CalID");
		return insertKey;
	}
	
	public CoviMap selectCalendarInfo(CoviMap params) throws Exception {
		CoviMap coviMap = new CoviMap();
		coviMap.addAll(coviMapperOne.select("groupware.workreport.selectcalendar", params));
		
		return coviMap;
	}
	
	@Override
	public CoviMap selectCalendarBeforeAndNextInfo(CoviMap params)
			throws Exception {
		CoviMap returnObj = new CoviMap();

		CoviMap coviMap = new CoviMap();
		coviMap.addAll(coviMapperOne.select("groupware.workreport.selectcalendarbeforeandnext", params));
		
		returnObj.put("calendar", coviMap);
		
		return returnObj;
	}
	
	@Override
	public CoviMap selectCalendarDateInfo(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();

		CoviMap coviMap = new CoviMap();
		coviMap.addAll(coviMapperOne.select("groupware.workreport.selectcalendardate", params));
		
		returnObj.put("calendar", coviMap);
		
		return returnObj;
	}
	
	@Override
	public CoviMap getGrade(CoviMap params) throws Exception {
		CoviMap result = null;
		String memberType = params.get("memberType").toString();
		
		if(memberType.equals("O")) {
			// 외주
			// 외주관리 페이지에서 등록된 내용에 따라 등급이 관리됨
			result = coviMapperOne.select("groupware.workreport.getoutsourcinggrade", params);
		}
		else {
			// 정규직
			// 정규직의 경우 직급에 따라 등급이 구분됨 ( 가장 최근 날짜 및 등급정보 필요 )
			result = coviMapperOne.select("groupware.workreport.getregulargrade", params);
		}
		CoviMap returnObj = new CoviMap();
		returnObj.put("grade", result);
		return returnObj;
	}
	
	@Override
	public int insertWorkReport(CoviMap base, ArrayList<CoviMap> timesheets) throws Exception {
		int insertKey = 0;
		// Base 입력 후 Key Return
		coviMapperOne.insert("groupware.workreport.insertWorkReport", base);
		insertKey = base.getInt("WorkReportID");
		// TimeSheets 데이터 입력
		CoviMap params = new CoviMap();
		params.put("key", insertKey);
		params.put("list", timesheets);
		
		coviMapperOne.insert("groupware.workreport.insertTimeCard", params);
		
		return insertKey;
	}
	
	@Override
	public CoviMap getBaseReport(CoviMap params) throws Exception {
		CoviMap result = new CoviMap(); 
		result.addAll(coviMapperOne.select("groupware.workreport.selectBaseReport", params));
		return result;
	}
	
	@Override
	public CoviList getTimeSheetReport(CoviMap params) throws Exception {
		return coviMapperOne.list("groupware.workreport.selectTimeSheetReport", params);
		/*return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectTimeSheetReport", params)
				, "JobID,TypeCode,FRI,SAT,SUN,MON,TUE,WED,THU,SUM,DivisionCode,JobName,DivisionName,TypeName") ;*/
	}
	
	@Override
	public CoviMap getWorkReportIdAndStateByCalAndUser(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap result = new CoviMap(); 
		result.addAll(coviMapperOne.select("groupware.workreport.selectWorkReportID", params));
		
		return result;
	}
	
	@Override
	public void updateWorkReport(CoviMap base, ArrayList<CoviMap> timesheets, ArrayList<CoviMap> reducesheets) throws Exception {
		// Base 입력 후 Key Return
		coviMapperOne.update("groupware.workreport.updateWorkReport", base);
		
		// TimeSheets 데이터 입력
		coviMapperOne.delete("groupware.workreport.deleteAllTimeCard", base);
		CoviMap updateParams = new CoviMap();
		updateParams.put("list", timesheets);
		coviMapperOne.update("groupware.workreport.updateTimeCard", updateParams);
		
		if(reducesheets.size() > 0) {
			CoviMap deleteParams = new CoviMap();
			deleteParams.put("key", base.get("WorkReportID"));
			deleteParams.put("list", reducesheets);
			coviMapperOne.delete("groupware.workreport.deleteTimeCard", deleteParams);
		}
	}
	
	@Override
	public void initApprovalWorkreport(CoviMap obj) throws Exception {
		coviMapperOne.update("groupware.workreport.initApprovalWorkreport", obj);
	}
	
	
	@Override
	public CoviList getManageUsers(CoviMap params) throws Exception {
		CoviList retArr = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectManageUsers", params), "OUR_Code,Name,Age,GradeKind,RegistCode,WorkSubject,FirstCode,FirstName,SecondCode,SecondName,Role,ContractStartDate,ContractEndDate,ContractState,ExProjectYN");
		return retArr;
	}
	
	@Override
	public int chkIsManagerByUserCode(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("groupware.workreport.chkIsManagerByUserCode", params);
	}
	
	@Override
	public CoviMap selectWorkReportMyList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectWorkReportMyListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
			returnObj.put("cnt", cnt);
		}
		
		CoviList listData = coviMapperOne.list("groupware.workreport.selectWorkReportMyList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(listData, "Month,StartDate,EndDate,WeekOfMonth,WorkReportID,UR_Code,GR_Code,CalID,CreateDate,ReportDate,ApprovalDate,ApproverCode,State,Comment,ApproverName"));
	
		return returnObj;
	}
	
	@Override
	public int reportWorkReport(CoviMap params) throws Exception {
		// 보고처리
		int cnt = coviMapperOne.update("groupware.workreport.reportWorkReport", params);
		
		// 0시간 삭제
		coviMapperOne.delete("clearZeroHourData", params);
		
		// 팀장코드 구하기
		String strManagerCode = selectTeamManagerByUid(params);
		
		if(strManagerCode != null && !strManagerCode.isEmpty()) {
			// 알림발송을 위해 보고내용 조회
			CoviMap calendarInfo = selectCalendarInfo(params);
			CoviMap baseReport = getBaseReport(params);
			CoviList timeSheets = getTimeSheetReport(params);
			
			CoviMap lastWeekPlan = getLastWeekPlan(params);
			
			
			CoviMap paramJSON = new CoviMap();
			
			paramJSON.put("ServiceType", "WorkReport");
			paramJSON.put("ObjectType", "");
			paramJSON.put("MediaType", "MAIL;TODOLIST");
			paramJSON.put("MsgType", "WorkReport_REPORT");
			paramJSON.put("IsUse", "Y");
			paramJSON.put("IsDelay", "N");
	
			paramJSON.put("XSLPath", "");
			
			// X월 X주차 XXX 업무보고 승인요청
			
			String strMonth = StringUtil.lpad(calendarInfo.getString("Month"), 2, '0');
			String strMsgSubject = String.format("%s월 %s주차 업무보고 승인요청", strMonth, calendarInfo.getString("WeekOfMonth"));
			paramJSON.put("MessagingSubject", strMsgSubject);
			
			// reportWorkReport 호출 세션 
			paramJSON.put("SenderCode", params.get("userCode"));
			
			paramJSON.put("Width", "1000");
			paramJSON.put("Height", "600");
			
			String strSiteDomain = PropertiesUtil.getGlobalProperties().getProperty("groupware.path");
			// 절대경로 FULL URL 보내야함
			paramJSON.put("PopupURL", String.format("%s/workreport/viewWorkReport.do?wrid=%s&calid=%s&uid=%s&CFN_OpenLayerName=WorkReportPop",
													strSiteDomain, 
													params.get("workReportId"), 
													params.get("calID"), 
													params.get("userCode")));
			
			String strGotoURL = String.format("%s/workreport/workreport_teamworkreport.do?mnp=2", strSiteDomain);
			
			paramJSON.put("GotoURL", strGotoURL);
			
			
			paramJSON.put("OpenType", "LAYERPOPUP");
			
			StringBuilder sbHTML = new StringBuilder();
			sbHTML.append("<html xmlns='http://www.w3.org/1999/xhtml'>");
			sbHTML.append("<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' />");
			sbHTML.append("</head>");
			sbHTML.append("<div style='border:1px solid #c9c9c9; width:1000px; padding-bottom:10px;'>");
			sbHTML.append("<div style='width:100%; height: 50px; background-color : #2b2e34; font-weight:bold; font-size:16px; color:white; line-height:50px; padding-left:20px; box-sizing:border-box;'>");
			sbHTML.append("	CoviSmart² - 업무보고");
			sbHTML.append("</div>");
			sbHTML.append("<div style='padding: 10px 10px; max-width: 1000px; font-size:13px;'>");
			sbHTML.append(String.format("%s님의 업무보고가 승인요청 되었습니다.", params.get("userName")));
			sbHTML.append("</div>");
			// 업무보고 내용 START
			sbHTML.append("<div style='padding: 0px 10px; max-width: 1000px;' id='divContextWrap'>");
			sbHTML.append("<div style='position:relative; margin-bottom:5px; height:40px;'>");
			sbHTML.append("<p style='text-align:center; font-size:22px; font-weight:bold;'>");
			sbHTML.append(String.format("[ <span id='spnWeekOfMonth'>%s월 %s주차</span> ]", strMonth, calendarInfo.getString("WeekOfMonth")));
			sbHTML.append("</p>");
			sbHTML.append("</div>");
			
			sbHTML.append("<div style='width:100%; min-height:70px; margin-bottom : 10px;'>");
			sbHTML.append("<div>");
			sbHTML.append("<table style='width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:12px;' border='1' id='tbTimeSheet'>");
			sbHTML.append("<tbody>");
			
			// Header
			sbHTML.append("<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>");
			sbHTML.append("<td width='150'>구분</td>");
			sbHTML.append("<td width='240'>업무</td>");
			sbHTML.append("<td width='150'>분류</td>");
			
			Calendar startDate = Calendar.getInstance();
			startDate.set(Calendar.YEAR, Integer.parseInt(calendarInfo.getString("Year")));
			startDate.set(Calendar.MONTH, Integer.parseInt(calendarInfo.getString("Month")) + 1);
			startDate.set(Calendar.DATE, Integer.parseInt(calendarInfo.getString("Day")));
			
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(금)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(토)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(일)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(월)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(화)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(수)</td>");
			startDate.add(Calendar.DATE, 1);
			sbHTML.append("<td width='30'>" + startDate.get(Calendar.DATE) + "(목)</td>");
			sbHTML.append("<td width='30'>합계</td>");
			sbHTML.append("</tr>");
			
			double sumMon = 0.0;
			double sumTue = 0.0;
			double sumWed = 0.0;
			double sumThu = 0.0;
			double sumFri = 0.0;
			double sumSat = 0.0;
			double sumSun = 0.0;
			double sumSum = 0.0;
			
			// 타임세트 row
			for(int i = 0; i < timeSheets.size(); i++) {
				CoviMap item = timeSheets.getMap(i);
				
				double timeMon = item.getDouble("MON");
				double timeTue = item.getDouble("TUE");
				double timeWed = item.getDouble("WED");
				double timeThu = item.getDouble("THU");
				double timeFri = item.getDouble("FRI");
				double timeSat = item.getDouble("SAT");
				double timeSun = item.getDouble("SUN");
				double timeSum = item.getDouble("SUM");
				
				sbHTML.append("<tr class='trTimeSheet' style='height: 30px; text-align: center; font-size: 12px;'>");
				sbHTML.append("<td width='150'>" + item.getString("DivisionName") + "</td>");
				sbHTML.append("<td width='240'>" + item.getString("JobName") + "</td>");
				sbHTML.append("<td width='150'>" + item.getString("TypeName") + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeFri * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeSat * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeSun * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeMon * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeTue * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeWed * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeThu * 10) / 10 + "</td>");
				sbHTML.append("<td width='30'>" + (double)Math.round(timeSum * 10) / 10 + "</td>");
				sbHTML.append("</tr>");
				
				// 합계 누적
				sumMon += timeMon;
				sumTue += timeTue;
				sumWed += timeWed;
				sumThu += timeThu;
				sumFri += timeFri;
				sumSat += timeSat;
				sumSun += timeSun;
				sumSum += timeSum;
			}
			
			// 합계row
			sbHTML.append("<tr style='height:30px; text-align:center; background-color : #f9f9f9; font-weight:600;' id='trSummary'>");
			sbHTML.append("<td>합계</td>");
			sbHTML.append("<td></td>");
			sbHTML.append("<td></td>");
			sbHTML.append("<td>" + (double)Math.round(sumFri * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumSat * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumSun * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumMon * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumTue * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumWed * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumThu * 10) / 10 + "</td>");
			sbHTML.append("<td>" + (double)Math.round(sumSum * 10) / 10 + "</td>");
			sbHTML.append("</tr>");
			sbHTML.append("</tbody>");
			sbHTML.append("</table>");
			sbHTML.append("</div>");
			sbHTML.append("</div>");
			
			// 보고내용
			sbHTML.append("<div>");
			sbHTML.append("<table style='width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:13px;' border='1'>");
			sbHTML.append("<thead>");
			sbHTML.append("<tr style='height:30px; line-height:30px; font-size:12px; font-weight:bold; background-color : #f1f6f9;'>");
			sbHTML.append("<td style='text-align:center; width:300px;'>전주계획</td>");
			sbHTML.append("<td style='text-align:center; width:340px;' colspan='2'>금주실적</td>");
			sbHTML.append("<td style='text-align:center; width:300px;'>차주계획</td>");
			sbHTML.append("</tr>");
			sbHTML.append("</thead>");
			sbHTML.append("<tbody>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td rowspan='7'>");
			sbHTML.append("<div id='txtLastWeekPlan' style='height:280px; border:none; overflow-y:auto; width:298px;'>");
			sbHTML.append(lastWeekPlan.getString("LastWeekPlan").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>금</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtFriReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("FriDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("<td rowspan='7'>");
			sbHTML.append("<div id='txtNextWeekPlan' style='height:280px; border:none; overflow-y:auto; width:298px;'>");
			sbHTML.append(baseReport.getString("NextWeekPlan").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>토</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtSatReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("SatDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>일</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtSunReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("SunDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>월</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtMonReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("MonDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>화</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtTueReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("TuesDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>수</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtWedReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("WedDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("<tr style='height:40px;'>");
			sbHTML.append("<td style='width:40px; text-align:center; background-color : #f7f7f7;'>목</td>");
			sbHTML.append("<td>");
			sbHTML.append("<div id='txtThuReport' style='overflow-y:auto; width:318px; height:40px; border:none;'>");
			sbHTML.append(baseReport.getString("ThuDayReport").replaceAll(" ", "&nbsp;").replaceAll("\r|\n|\r\n", "<br/>"));		// d
			sbHTML.append("</div>");
			sbHTML.append("</td>");
			sbHTML.append("</tr>");
			sbHTML.append("</tbody>");
			sbHTML.append("</table>");
			sbHTML.append("</div>");
			
			
			sbHTML.append("<div id='divBtnWrap' align='center' style='padding-top: 10px'>");
			sbHTML.append("<a style='display:inline-block; color:white; font-weight:bold; width:150px; height:45px; line-height:45px;background-color:#2f91e3; font-size: 14px;"); 
			sbHTML.append("text-decoration: none;' href='" + strGotoURL + "' target='_blank'>");
			sbHTML.append("그룹웨어 바로가기</a></div>");
			sbHTML.append("</div>");
			
			// 업무보고 내용 END
			sbHTML.append("</div></body></html>");
				
			// 본문 내용
			paramJSON.put("MessageContext", sbHTML.toString());
			
			paramJSON.put("ReceiverText", strMsgSubject);
			
			
			// 받는 사람 ( 팀장 )
			paramJSON.put("ReceiversCode", strManagerCode);
			
			// 등록자
			paramJSON.put("RegistererCode", "superadmin");
			
			// 관리급
			paramJSON.put("ReservedStr1", "");
			paramJSON.put("ReservedStr2", "");
			paramJSON.put("ReservedStr3", "NO");
			paramJSON.put("ReservedStr4", "");
			
			sendWorkReportMsg(paramJSON);
		}
		return cnt;
	}
	
	@Override
	public int collectWorkReport(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.workreport.collectWorkReport", params);
	}
	
	@Override
	public CoviList getTeamMembers(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectTeamMembers", params), 
				"JobPositionName,UR_Code,UR_Name,NotReportCnt,NotApprovalCnt,RecentYear,RecentMonth,RecentDay,RecentWeekOfMonth,RecentState");
	}
	
	@Override
	public CoviMap selectWorkReportTeamList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectWorkReportTeamListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
			returnObj.put("cnt", cnt);
		}
		
		CoviList listData = coviMapperOne.list("groupware.workreport.selectWorkReportTeamList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(listData, "Month,StartDate,EndDate,WeekOfMonth,WorkReportID,UR_Code,CalID,UR_Name,ReportDate,ApprovalDate,State,Comment,JobPositionCode,JobPositionName"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap approvalWorkReport(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		int cnt = 0;
		int noCount = 0;

		
		// 팀장코드 구하기
		String strManagerCode = "";
		
		/*
		String strDeptList = coviMapperOne.selectOne("selectDeptInfoByWrids", params);
		String[] arrDeptList = strDeptList.split(";");
		
		params.put("deptList", arrDeptList);
		strManagerCode = coviMapperOne.selectOne("selectManagersByDeptList", params);
		*/
		
		String[] workReportIds = (String[])params.get("workReportIds");
		List<String> liWorkReportId = new ArrayList(Arrays.asList(workReportIds));
		
		Iterator<String> itWorkReportId = liWorkReportId.iterator();
		
		while(itWorkReportId.hasNext()) {
			String wrid = itWorkReportId.next();
			
			CoviMap chkParams = new CoviMap();
			chkParams.put("workReportID", wrid);
			
			strManagerCode = selectTeamManagerByUid(chkParams);
			
			boolean isManager = false;
			String[] arrManagers = strManagerCode.split(";");
			
			for(String mCode : arrManagers) {
				if(mCode.equalsIgnoreCase(params.getString("approvorCode"))) {
					isManager = true;
					break;
				}
			}
			
			if(!isManager) {
				itWorkReportId.remove();
				noCount++;
			}
		}
		
		String[] filterWorkReportIds = liWorkReportId.toArray(new String[liWorkReportId.size()]);
		
		params.put("workReportIds", filterWorkReportIds);
		
		// 현재 사용자가  Manager일 경우에만 승인 사용
		if(filterWorkReportIds.length > 0) {
			cnt = coviMapperOne.update("groupware.workreport.approvalWorkReport", params); 
			
			// 알림발송
			CoviMap paramJSON = new CoviMap();
			
			paramJSON.put("ServiceType", "WorkReport");
			paramJSON.put("ObjectType", "");
			paramJSON.put("MediaType", "MAIL;TODOLIST");
			paramJSON.put("MsgType", "WorkReport_APPROVAL");
			paramJSON.put("IsUse", "Y");
			paramJSON.put("IsDelay", "N");
			paramJSON.put("XSLPath", "");
			
			// X월 X주차 XXX 업무보고 승인요청
			String strMsgSubject = "업무보고 승인";
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String strGotoURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/groupware/workreport/workreport_workreport.do";
			
			paramJSON.put("MessagingSubject", strMsgSubject);
			//TODO 다국어 처리 할 것.
			String strMsgContext = MessageHelper.getInstance().makeDefaultMessageContext(
					"업무보고", 
					strMsgSubject, 
					"업무보고가 승인되었습니다.", 
					strMsgSubject, 
					SessionHelper.getSession("UR_Name"), 
					sdf.format(new Date()), 
					strGotoURL,
					"",
					"WorkReport");
			paramJSON.put("MessageContext", strMsgContext);
			
			// reportWorkReport 호출 세션 
			paramJSON.put("SenderCode", params.get("approvorCode"));
			
			//paramJSON.put("Width", "0");
			//paramJSON.put("Height", "0");
			
			//String strSiteDomain = PropertiesUtil.getGlobalProperties().getProperty("groupware.path");
			// 절대경로 FULL URL 보내야함
			//paramJSON.put("PopupURL", String.format("%s/workreport/workreport_workreport.do", strSiteDomain));
			//paramJSON.put("GotoURL", String.format("%s/workreport/workreport_workreport.do", strSiteDomain));
			
			
			paramJSON.put("OpenType", "PAGEMOVE");
			
			String strComment = params.getString("comment");
			if(strComment == null || strComment.isEmpty())
				strComment = "의견없음";
			
			// 본문 내용
			//paramJSON.put("MessageContext", strComment.replace("&nbsp;", " "));
			
			paramJSON.put("ReceiverText", "업무보고 승인");
			
			
			CoviMap receivers = coviMapperOne.select("groupware.workreport.selectApprovalUsers", params);
			
			// 받는 사람 ( 팀장 )
			paramJSON.put("ReceiversCode",receivers.get("userCodes"));
			
			// 등록자
			paramJSON.put("RegistererCode", "superadmin");
			
			// 관리급
			paramJSON.put("ReservedStr1", "");
			paramJSON.put("ReservedStr2", "");
			paramJSON.put("ReservedStr3", "NO");
			paramJSON.put("ReservedStr4", "");
			//paramJSON.put("ReservedStr4", "게시판명†{3}¶제목†{4}¶등록자†{11}({12})¶등록일시†{7}¶의견†{6}");
			//paramJSON.put("ReservedStr4", "lbl_BoardNm†{3}¶lbl_subject†{4}¶lbl_Register†{11}({12})¶lbl_RegistDateHour†{7}¶lbl_Comment†{6}");
			
			sendWorkReportMsg(paramJSON);
		} else {
			
		}
		
		returnObj.put("successCnt", cnt);
		returnObj.put("failCnt", noCount);
		
		return returnObj;
	}
	
	@Override
	public CoviMap rejectWorkReport(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		int cnt = 0;
		int noCount = 0;

		
		// 팀장코드 구하기
		String strManagerCode = "";
		
		/*
		String strDeptList = coviMapperOne.selectOne("selectDeptInfoByWrids", params);
		String[] arrDeptList = strDeptList.split(";");
		
		params.put("deptList", arrDeptList);
		strManagerCode = coviMapperOne.selectOne("selectManagersByDeptList", params);
		*/
		
		String[] workReportIds = (String[])params.get("workReportIds");
		List<String> liWorkReportId = new ArrayList(Arrays.asList(workReportIds));
		
		Iterator<String> itWorkReportId = liWorkReportId.iterator();
				
		while(itWorkReportId.hasNext()) {
			String wrid = itWorkReportId.next();
			
			CoviMap chkParams = new CoviMap();
			chkParams.put("workReportID", wrid);
			
			strManagerCode = selectTeamManagerByUid(chkParams);
			
			boolean isManager = false;
			String[] arrManagers = strManagerCode.split(";");
			
			for(String mCode : arrManagers) {
				if(mCode.equalsIgnoreCase(params.getString("approvorCode"))) {
					isManager = true;
					break;
				}
			}
			
			if(!isManager) {
				itWorkReportId.remove();
				noCount++;
			}
		}
		
		String[] filterWorkReportIds = liWorkReportId.toArray(new String[liWorkReportId.size()]);
		
		params.put("workReportIds", filterWorkReportIds);
		
		// 현재 사용자가  Manager일 경우에만 승인 사용
		if(filterWorkReportIds.length > 0) {
			cnt = coviMapperOne.update("groupware.workreport.rejectWorkReport", params); 
			
			// 알림발송
			CoviMap paramJSON = new CoviMap();
			
			paramJSON.put("ServiceType", "WorkReport");
			paramJSON.put("ObjectType", "");
			paramJSON.put("MediaType", "MAIL;TODOLIST");
			paramJSON.put("MsgType", "WorkReport_REJECT");
			paramJSON.put("IsUse", "Y");
			paramJSON.put("IsDelay", "N");
	
			paramJSON.put("XSLPath", "");
			
			// X월 X주차 XXX 업무보고 승인요청
			String strMsgSubject = "업무보고 거부";
			paramJSON.put("MessagingSubject", strMsgSubject);
			paramJSON.put("MessageContext", "업무보고가 거부되었습니다."+ "&nbsp;<a href=\"/groupware/workreport/workreport_workreport.do\">바로가기</a>");
			
			// reportWorkReport 호출 세션 
			paramJSON.put("SenderCode", params.get("approvorCode"));
			
			//paramJSON.put("Width", "0");
			//paramJSON.put("Height", "0");
			
			//String strSiteDomain = PropertiesUtil.getGlobalProperties().getProperty("groupware.path");
			
			// 절대경로 FULL URL 보내야함
			//paramJSON.put("PopupURL", String.format("%s/workreport/workreport_workreport.do", strSiteDomain));
			//paramJSON.put("GotoURL", String.format("%s/workreport/workreport_workreport.do", strSiteDomain));
			
			
			paramJSON.put("OpenType", "PAGEMOVE");
			// X월 X주차 XXX 업무보고 승인요청
						
			
			/*String strComment = params.getString("comment");
			if(strComment == null || strComment.isEmpty())
				strComment = "의견없음";*/
			
			// 본문 내용
			//paramJSON.put("MessageContext", strComment.replace("&nbsp;", " "));
			
			//paramJSON.put("ReceiverText", strComment.replace("&nbsp;", " "));
			
			
			CoviMap receivers = coviMapperOne.select("groupware.workreport.selectApprovalUsers", params);
			
			// 받는 사람 ( 팀장 )
			paramJSON.put("ReceiversCode",receivers.get("userCodes"));
			
			// 등록자
			paramJSON.put("RegistererCode", "superadmin");
			
			// 관리급
			paramJSON.put("ReservedStr1", "");
			paramJSON.put("ReservedStr2", "");
			paramJSON.put("ReservedStr3", "NO");
			paramJSON.put("ReservedStr4", "");
			//paramJSON.put("ReservedStr4", "lbl_BoardNm†{3}¶lbl_subject†{4}¶lbl_Register†{11}({12})¶lbl_RegistDateHour†{7}¶lbl_Comment†{6}");
			//paramJSON.put("ReservedStr4", "게시판명†{3}¶제목†{4}¶등록자†{11}({12})¶등록일시†{7}¶의견†{6}");
			
			sendWorkReportMsg(paramJSON);
		}
		
		returnObj.put("successCnt", cnt);
		returnObj.put("failCnt", noCount);
		
		return returnObj;
	}
	
	@Override
	public String selectTeamManagerByUid(CoviMap params) throws Exception {
		// 팀장코드 구하기 (보고 시점이 아닌 현 시점의 팀장코드 구하도록 수정) 
		String strLeastManagerCode = "";
		CoviMap groupInfo = coviMapperOne.select("groupware.workreport.selectWorkReportGroupPath", params);
		String strGroupPath = groupInfo.getString("GroupPath");

		if(strGroupPath != null) {
			String[] arrGroupPath = strGroupPath.split(";");
			
			params.put("groupPath", arrGroupPath);
			
			CoviList managerCodeList = coviMapperOne.list("groupware.workreport.selectApproverListByDept", params);
			CoviList sortManagerCodeList = new CoviList();
			// managerCode
			// GRCode를 groupPath 순으로 정렬
			
			for(int i = arrGroupPath.length-1; i >= 0; i--) {
				Iterator<CoviMap> itCoviList = managerCodeList.iterator();
				
				while(itCoviList.hasNext()) {
					CoviMap row = (CoviMap)itCoviList.next();
					
					String strGroupCode = row.getString("GR_Code");
					if(strGroupCode.equalsIgnoreCase(arrGroupPath[i])) {
						CoviMap sortRow = new CoviMap();
						sortRow.put("ManagerCode", row.get("ManagerCode"));
						sortManagerCodeList.add(sortRow);
						
						itCoviList.remove();
						break;
					}
				}
			}
			
			String strUserCode = groupInfo.getString("UR_Code");
			// GroupPath 하위부서 순으로 조회
			for(int i = 0; i < sortManagerCodeList.size(); i++) {
				CoviMap row = (CoviMap)sortManagerCodeList.get(i);
				
				String strManagerCode = row.getString("ManagerCode");
				strLeastManagerCode = strManagerCode;
	
				if(strManagerCode.toLowerCase().indexOf(strUserCode.toLowerCase()) > -1) {
					continue;
				}
				
				break;
			}
		}
		
		return strLeastManagerCode;
	}
		
	
	@Override
	public CoviMap getLastWeekPlan(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.addAll(coviMapperOne.select("groupware.workreport.selectLastWeekPlan", params));
		
		return result;
	}
	
	
	@Override
	public CoviList getApprovalTargets(CoviMap params) throws Exception {
		CoviList liTargetMember = null;
		// 자신이 승인자로 선택된 부서의 그룹패스 조회		
		CoviList liGroupPath = coviMapperOne.list("groupware.workreport.selectGroupPathInfo", params);
		
		if(liGroupPath.size() > 0) {
			
			boolean flagMine = false;
			
			// 승인 부서 리스트
			ArrayList<String> liApprovalTargetDept = new ArrayList();
			
			// 승인 사용자 리스트
			ArrayList<String> liApprovalTargetUser = new ArrayList();
			
			// 필터링 용
			ArrayList<String> liAttachedDept = new ArrayList<String>();
			ArrayList<String> liApprovalTargetGP = new ArrayList();
			
			ArrayList<String> liParentGroups = new ArrayList();
			
			CoviMap groupPath = null;
			String strGroupPath = "";
			String[] arrGroupPath = null;
			
			CoviList liChildGroupInfo = null;
			CoviMap chkParam = new CoviMap();
			// 그룹패스에 따른 결재선 확인
			for(int i = 0; i < liGroupPath.size(); i++) {
				groupPath = (CoviMap)liGroupPath.getMap(i);
				strGroupPath = groupPath.getString("GROUPPATH");
				
				arrGroupPath = strGroupPath.split(";");
				// 자기 자신을 제외한 상위 GR_Code 들 Insert
				if(arrGroupPath.length > 1)
					liParentGroups.addAll(Arrays.asList(Arrays.copyOfRange(arrGroupPath, 0, arrGroupPath.length - 1)));
				
				// 자기 자신의 부서
				liApprovalTargetDept.add(arrGroupPath[arrGroupPath.length - 1]);
				liAttachedDept.add(arrGroupPath[arrGroupPath.length - 1]);
				
				chkParam.put("groupPath", strGroupPath);
				
				// 하위 부서 조회
				liChildGroupInfo = coviMapperOne.list("groupware.workreport.selectChildGroupInfo", chkParam);
							
				for(int j=0; j<liChildGroupInfo.size(); j++) {
					CoviMap child = (CoviMap)liChildGroupInfo.get(j);
					String strApproverUser = child.getString("ApproverUserCode");
					String strApproverGroupPath = child.getString("GroupPath");
					if(!strApproverUser.isEmpty()) {
						liApprovalTargetUser.add(strApproverUser);
						liApprovalTargetGP.add(strApproverGroupPath);
					}
				}
				
				// 승인자가 존재하는 하위부서 제거
				for(String gp : liApprovalTargetGP) {
					Iterator<CoviMap> itChildGroupInfo = liChildGroupInfo.iterator();
					while(itChildGroupInfo.hasNext()) {
						CoviMap child = itChildGroupInfo.next();
						String strApproverGroupPath = child.getString("GroupPath");
						if(strApproverGroupPath.indexOf(gp) > -1) {
							itChildGroupInfo.remove();
						}
					}
				}
				
				// 승인자가 없는 부서 추가
				for(int j=0; j<liChildGroupInfo.size(); j++) {
					CoviMap child = (CoviMap)liChildGroupInfo.get(j);
					String strApproverDept = child.getString("GR_Code");
					liApprovalTargetDept.add(strApproverDept);
				}
			}
			
			if(liParentGroups.size() > 0) {
				params.put("parentGroupCode", liParentGroups);
				int parentApprover = (int)coviMapperOne.getNumber("groupware.workreport.selectParentApprovor", params);
				
				// 상위 승인자가 없으면 자기 자신이 승인자
				flagMine = (parentApprover == 0);
			} else {
				flagMine = true;
			}
			
			// 결재선 결과에 따른 승인자 리스트 조회
			CoviMap approvalTargetParam = new CoviMap();
			if(liApprovalTargetDept.size() > 0) {
				approvalTargetParam.put("DeptList", liApprovalTargetDept.toArray());
			}
			
			if(liApprovalTargetUser.size() > 0) {
				approvalTargetParam.put("UserList", liApprovalTargetUser.toArray());
			}
			
			// 같은 부서의 타 승인자 승인자 목록에서 제거
			if(liAttachedDept.size() > 0) {
				approvalTargetParam.put("AttachDeptList", liAttachedDept.toArray());
			}
			
			// 자기자신 승인여부 확인
			approvalTargetParam.put("flagMine", flagMine ? "Y" : "N");
			approvalTargetParam.put("userCode", params.getString("userCode"));
			
			liTargetMember = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectApprovalTargetList", approvalTargetParam),
					"NotReportCnt,UR_Name,UR_Code,NotApprovalCnt,RecentYear,RecentDay,RecentState,RecentMonth,RecentWeekOfMonth,JobPositionName");
		}
		return liTargetMember;
	}
	
	public void sendWorkReportMsg(CoviMap params) throws Exception{
		String strServiceType = params.getString("ServiceType");
        String strObjectType = params.getString("ObjectType");
        String strObjectID = params.getString("ObjectID");
        String strMsgType = params.getString("MsgType");
        String strMessageID = params.getString("MessageID");
        String strSubMsgID = params.getString("SubMsgID");
        String strMediaType = params.getString("MediaType");
        String strIsUse = params.getString("IsUse");
        String strIsDelay = params.getString("IsDelay");
        String strApprovalState = params.getString("ApprovalState");
        String strSenderCode = params.getString("SenderCode");
        String strReservedDate = params.getString("ReservedDate");
        String strXSLPath = params.getString("XSLPath");
        String strWidth = params.getString("Width");
        String strHeight = params.getString("Height");
        String strPopupURL = params.getString("PopupURL");
        String strGotoURL = params.getString("GotoURL");
        String strMobileURL = params.getString("MobileURL");
        String strOpenType = params.getString("OpenType");
        String strMessagingSubject = params.getString("MessagingSubject");
        String strMessageContext = params.getString("MessageContext");
        String strReceiverText = params.getString("ReceiverText");
        String strReservedStr1 = params.getString("ReservedStr1");
        String strReservedStr2 = params.getString("ReservedStr2");
        String strReservedStr3 = params.getString("ReservedStr3");
        String strReservedStr4 = params.getString("ReservedStr4");
        String strReservedInt1 = params.getString("ReservedInt1");
        String strReservedInt2 = params.getString("ReservedInt2");
        String strRegistererCode = params.getString("RegistererCode");
        String strReceiversCode = params.getString("ReceiversCode");
        String strDomainID = SessionHelper.getSession("DN_ID");
        
        // 값이 비어있을경우 NULL 값으로 전달
        strServiceType = strServiceType == null ? null : (strServiceType.isEmpty() ? null : strServiceType);
        strObjectType = strObjectType == null ? null : (strObjectType.isEmpty() ? null : strObjectType);
        strObjectID = strObjectID == null ? null : (strObjectID.isEmpty() ? null : strObjectID);
        strMsgType = strMsgType == null ? null : (strMsgType.isEmpty() ? null : strMsgType);
        strMessageID = strMessageID == null ? null : (strMessageID.isEmpty() ? null : strMessageID);
        strSubMsgID = strSubMsgID == null ? null : (strSubMsgID.isEmpty() ? null : strSubMsgID);
        strMediaType = strMediaType == null ? null : (strMediaType.isEmpty() ? null : strMediaType);
        strIsUse = strIsUse == null ? "Y" : (strIsUse.isEmpty() ? "Y" : strIsUse);
        strIsDelay = strIsDelay == null ? "N" : (strIsDelay.isEmpty() ? "N" : strIsDelay);
        strApprovalState = strApprovalState == null ? "P" : (strApprovalState.isEmpty() ? "P" : strApprovalState);
        strSenderCode = strSenderCode == null ? null : (strSenderCode.isEmpty() ? null : strSenderCode);
        strReservedDate = strReservedDate == null ? null : (strReservedDate.isEmpty() ? null : strReservedDate);
        strXSLPath = strXSLPath == null ? null : (strXSLPath.isEmpty() ? null : strXSLPath);
        strWidth = strWidth == null ? null : (strWidth.isEmpty() ? null : strWidth);
        strHeight = strHeight == null ? null : (strHeight.isEmpty() ? null : strHeight);
        strPopupURL = strPopupURL == null ? null : (strPopupURL.isEmpty() ? null : strPopupURL);
        strGotoURL = strGotoURL == null ? null : (strGotoURL.isEmpty() ? null : strGotoURL);
        strMobileURL = strMobileURL == null ? null : (strMobileURL.isEmpty() ? null : strMobileURL);
        strOpenType = strOpenType == null ? null : (strOpenType.isEmpty() ? null : strOpenType);
        strMessagingSubject = strMessagingSubject == null ? null : (strMessagingSubject.isEmpty() ? null : strMessagingSubject);
        strMessageContext = strMessageContext == null ? null : (strMessageContext.isEmpty() ? null : strMessageContext);
        strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
        strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
        strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
        strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
        strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
        strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
        strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
        strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
        strReceiversCode = strReceiversCode == null ? null : (strReceiversCode.isEmpty() ? null : strReceiversCode);
        strDomainID = strDomainID == null ? null : (strDomainID.isEmpty() ? null : strDomainID);
		
		params.put("ServiceType", strServiceType);
        params.put("ObjectType", strObjectType);
        params.put("ObjectID", strObjectID);
        params.put("MsgType", strMsgType);
        params.put("MessageID", strMessageID);
        params.put("SubMsgID", strSubMsgID);
        params.put("MediaType", strMediaType);
        params.put("IsUse", strIsUse);
        params.put("IsDelay", strIsDelay);
        params.put("ApprovalState", strApprovalState);
        params.put("SenderCode", strSenderCode);
        params.put("ReservedDate", strReservedDate);
        params.put("XSLPath", strXSLPath);
        params.put("Width", strWidth);
        params.put("Height", strHeight);
        params.put("PopupURL", strPopupURL);
        params.put("GotoURL", strGotoURL);
        params.put("MobileURL", strMobileURL);
        params.put("OpenType", strOpenType);
        params.put("MessagingSubject", strMessagingSubject);
        params.put("MessageContext", strMessageContext);
        params.put("ReceiverText", strReceiverText);
        params.put("ReservedStr1", strReservedStr1);
        params.put("ReservedStr2", strReservedStr2);
        params.put("ReservedStr3", strReservedStr3);
        params.put("ReservedStr4", strReservedStr4);
        params.put("ReservedInt1", strReservedInt1);
        params.put("ReservedInt2", strReservedInt2);
        params.put("RegistererCode", strRegistererCode);
        params.put("ReceiversCode", strReceiversCode);
        params.put("DomainID", strDomainID);
		
        messageSvc.insertMessagingData(params);
	}
}
