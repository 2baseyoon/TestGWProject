package egovframework.covision.groupware.collab.user.service.impl;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.Resource;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.collab.user.service.CollabAlarmSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.baseframework.util.PropertiesUtil;



import java.text.SimpleDateFormat; import java.util.Calendar; import java.util.Date;

@Service("CollabAlarmSvc")
public class CollabAlarmSvcImpl extends EgovAbstractServiceImpl implements CollabAlarmSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private MessageService messageSvc;
	
	/**
	 * @Method Name : doAutoSummDayAlam
	 * @Description : 일일요약정버
	 */
	@Override
	public CoviMap doAutoSummDayAlam(CoviMap reqParams) throws Exception {
		CoviMap resultList	= new CoviMap();

        CoviList list			= new CoviList();
 		
 		list	= coviMapperOne.list("collab.alarm.getSummDay", reqParams);


		CoviMap sendMessage = new CoviMap();
		sendMessage.put("ServiceType", "Collab");
		sendMessage.put("MsgType", "PrjSummDay");

 		String mailSubject = "";
 		String sTarget  ="";
 		StringBuffer sbText = new StringBuffer("");
		for (int i =0 ; i < list.size(); i++)
		{
			CoviMap data = (CoviMap)list.get(i);
	 		if (i ==0 ){
		 		mailSubject =  (String)data.get("Today")+" 프로젝트요약";
		 		sTarget = (String)data.get("UserCode");
	 		}	
	 		else if (!sTarget.equals((String)data.get("UserCode"))){//대상자가 바뀌면 메세지 전송
 				MessageHelper.getInstance().insertMessageData(sendMessage, "superadmin", sTarget, mailSubject, getMailForm(sbText.toString(),"PrjSummDay",mailSubject));
 				sbText = new StringBuffer("");
 				sTarget = (String)data.get("UserCode");
	 		}
	 		
			sbText.append("<tr style='height:30px; font-size:12px;'>"+
						"<td style='text-align:center;'>"+data.getString("PrjName")+"</td>"+
						"<td style='text-align:center;'>"+ComUtils.ConvertDateFormat(data.getString("StartDate"),"-")+"~"+ComUtils.ConvertDateFormat(data.getString("EndDate"),"-")+"</td>"+
						"<td style='text-align:center;'>"+data.getString("ProgRate")+"%</td>"+
						"<td style='text-align:center;'>"+data.getInt("TotCnt")+
						"("+(data.getInt("TotCnt")-data.getInt("YesDayCnt"))+")</td>"+
						"<td style='text-align:center;'>"+data.getInt("WaitCnt")+"</td>"+
						"<td style='text-align:center;'>"+data.getInt("ProcCnt")+"</td>"+
						"<td style='text-align:center;'>"+data.getInt("HoldCnt")+"</td>"+
						"<td style='text-align:center;'>"+data.getInt("CompCnt")+
						"("+(data.getInt("CompCnt")-data.getInt("YesCompCnt"))+")</td>"+
						"<td style='text-align:center;'>"+data.getInt("DelayCnt")+"</td>"+
						"</tr>");
		}
		
		MessageHelper.getInstance().insertMessageData(sendMessage, "superadmin", sTarget, mailSubject, getMailForm(sbText.toString(),"PrjSummDay",mailSubject));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : doAutoTaskCloseAlam
	 * @Description : 마감일알림
	 */
	@Override
	public CoviMap doAutoTaskCloseAlam(CoviMap reqParams) throws Exception {
		CoviMap resultList	= new CoviMap();

        CoviList list			= new CoviList();
 		
 		list	= coviMapperOne.list("collab.alarm.getTaskClose", reqParams);


		CoviMap sendMessage = new CoviMap();
		sendMessage.put("ServiceType", "Collab");
		sendMessage.put("MsgType", "TaskCloseDate");

 		String mailSubject = "";
 		String sTarget  ="";
 		int sendCnt = 0;
 		StringBuffer sbText = new StringBuffer("");
		for (int i =0 ; i < list.size(); i++)
		{
			CoviMap data = (CoviMap)list.get(i);
	 		if (i ==0 ){
		 		mailSubject =  ComUtils.ConvertDateFormat((String)data.get("Today"),"-")+" 마감일 알람";
		 		sTarget = (String)data.get("UserCode");
	 		}	
	 		else if (!sTarget.equals((String)data.get("UserCode"))){//대상자가 바뀌면 메세지 전송
 				if (sendCnt >0 ) MessageHelper.getInstance().insertMessageData(sendMessage, "superadmin", sTarget, mailSubject, getMailForm(sbText.toString(), "TaskCloseDate",mailSubject));
 				sbText = new StringBuffer("");
 				sTarget = (String)data.get("UserCode");
 				sendCnt = 0;
	 		}
	 		
	 		if (data.getString("RepeatAlarmUse").equals("N")){//반복일 설정이 아닌 경우 해당일에만 전송
	 			if (data.getString("AlarmStartDate").equals(data.getString("Today"))){ //메일추가
					String prjName="My";
					String sectionName="";
					if (data.get("PrjDesc") != null){
						java.util.StringTokenizer  st = new java.util.StringTokenizer(data.getString("PrjDesc"), "^");
			            if (st.hasMoreTokens()){
				            st.nextToken();
				            if (st.hasMoreTokens()) prjName =st.nextToken();
				            if (st.hasMoreTokens()) st.nextToken();
				            if (st.hasMoreTokens()) sectionName = st.nextToken() ;
			            }    
			            else{
			            	prjName= "My";
			            }
					}
	 				sendCnt++;
	 				sbText.append("<tr style='height:30px; font-size:12px;'>"+
							"<td>"+prjName+"</td>"+
							"<td>"+sectionName+"</td>"+
							"<td>"+data.getString("TaskName")+"</td>"+
							"<td style='text-align:center;'>"+ComUtils.ConvertDateFormat(data.getString("EndDate"),"-")+"</td>"+
							"<td style='text-align:center;'>"+"D"+(data.getString("DDay").equals("0")?"-day":data.getString("DDay"))+"</td>"+
							"</tr>");
	 			}
	 		}else{
	 			int today = Integer.parseInt(data.getString("Today"));
	 			if (Integer.parseInt(data.getString("AlarmStartDate")) <= today){

	 				SimpleDateFormat dtFormat = new SimpleDateFormat("yyyyMMdd"); 
	 				Calendar cal = Calendar.getInstance(); 
	 				
	 				int dayTerm  = Integer.parseInt(data.getString("RepeatAlarmTerm"));
	 				String nextDate = data.getString("AlarmStartDate");
	 				Date dt = dtFormat.parse(nextDate);
	 				while (Integer.parseInt(nextDate) <= today) {
	 					if (Integer.parseInt(nextDate)== today){
	 						//mail 추가
	 						String prjName="My";
	 						String sectionName="";
	 						if (data.get("PrjDesc") != null){
	 							java.util.StringTokenizer  st = new java.util.StringTokenizer(data.getString("PrjDesc"), "^");
	 				            if (st.hasMoreTokens()){
	 					            st.nextToken();
	 					            if (st.hasMoreTokens()) prjName =st.nextToken();
	 					            if (st.hasMoreTokens()) st.nextToken();
	 					            if (st.hasMoreTokens()) sectionName = st.nextToken() ;
	 				            }    
	 				            else{
	 				            	prjName= "My";
	 				            }
	 						}
	 		 				sendCnt++;
	 		 				sbText.append("<tr style='height:30px; font-size:12px;'>"+
	 								"<td>"+prjName+"</td>"+
	 								"<td>"+sectionName+"</td>"+
	 								"<td>"+data.getString("TaskName")+"</td>"+
	 								"<td style='text-align:center;'>"+ComUtils.ConvertDateFormat(data.getString("EndDate"),"-")+"</td>"+
	 								"<td style='text-align:center;'>"+"D"+(data.getString("DDay").equals("0")?"-day":data.getString("DDay"))+"</td>"+
	 								"</tr>");
	 						break;
	 					}
	 					else{
	 						cal.setTime(dtFormat.parse(nextDate));
	 						if (data.getString("RepeatAlarmType").equals("week"))	//주마다;
			 					cal.add(Calendar.DATE,  dayTerm*7);
	 						else
	 							cal.add(Calendar.DATE,  dayTerm);
	 						
		 					nextDate = dtFormat.format(cal.getTime());
	 					}	
	 				}
	 			}
	 		}

		}
		
		if (sendCnt >0 ) MessageHelper.getInstance().insertMessageData(sendMessage, "superadmin", sTarget, mailSubject, getMailForm(sbText.toString(),"TaskCloseDate", mailSubject));
		
		return resultList; 
	}

	private String getMailForm(String detailHTML, String serviceType, String subject){
		StringBuffer sbHTML = new StringBuffer();
		sbHTML.append("<html xmlns='http://www.w3.org/1999/xhtml'>");
		sbHTML.append("<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' />");
		sbHTML.append("</head>");
		sbHTML.append("<div style='border:1px solid #c9c9c9; width:1000px; padding-bottom:10px;'>");
		sbHTML.append("<div style='width:100%; height: 50px; background-color : #2b2e34; font-weight:bold; font-size:16px; color:white; line-height:50px; padding-left:20px; box-sizing:border-box;'>");
		sbHTML.append("	CoviSmart² - "+subject);
		sbHTML.append("</div>");
		sbHTML.append("<div style='padding: 10px 10px; max-width: 1000px; font-size:13px;'>");
		sbHTML.append("</div>");

		sbHTML.append("<div style='padding: 0px 10px; max-width: 1000px;' id='divContextWrap'>");
		
		sbHTML.append("<div style='width:100%; min-height:70px; margin-bottom : 10px;'>");
		if (serviceType.equals("TaskCloseDate")){
			sbHTML.append("<b>[마감일]</b>");
			sbHTML.append("<span>마감일이 얼마 남지 않은 업무입니다. <br>협업스페이스에서 확인해보세요. </span>");
		}
		sbHTML.append("<div>");
		sbHTML.append("<table style='width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:12px;' border='1' id='tbTimeSheet'>");
		sbHTML.append("<tbody>");
		// Header
		sbHTML.append("<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>");
		if (serviceType.equals("TaskCloseDate")){
			sbHTML.append("<th width='200'>프로젝트명</th>");
			sbHTML.append("<th width='200'>섹션명</th>");
			sbHTML.append("<th width='200'>업무명</th>");
			sbHTML.append("<th width='100'>마감일</th>");
			sbHTML.append("<th width='100'>마감일까지 남은 일자</th>");
		}else{
			sbHTML.append("<th width='150'>프로젝트명</th>");
			sbHTML.append("<th width='240'>기간</th>");
			sbHTML.append("<th width='150'>진행률</th>");
			sbHTML.append("<th width='80'>전제업무</th>");
			sbHTML.append("<th width='80'>대기</th>");
			sbHTML.append("<th width='80'>진행</th>");
			sbHTML.append("<th width='80'>보류</th>");
			sbHTML.append("<th width='80'>완료</th>");
			sbHTML.append("<th width='80'>지연</th>");
		}
		sbHTML.append("</tr>");
		sbHTML.append(detailHTML);
		sbHTML.append("</tbody>");
		sbHTML.append("</table>");
		sbHTML.append("</div>");
		sbHTML.append("</div>");
		sbHTML.append("</div>");
		return sbHTML.toString();
	}
	
}
