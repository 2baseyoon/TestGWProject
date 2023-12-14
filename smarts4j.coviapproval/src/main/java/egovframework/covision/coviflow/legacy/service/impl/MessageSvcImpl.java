package egovframework.covision.coviflow.legacy.service.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;



import net.sf.json.JSONSerializer;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoapProxy;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;
import egovframework.covision.coviflow.legacy.service.MessageSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("appMessageService")
public class MessageSvcImpl extends EgovAbstractServiceImpl implements MessageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	
	//프로시져호출
	@Override
	public void callMessagingProcedure(CoviMap paramMap) throws Exception{
		String strServiceType = paramMap.getString("ServiceType");
        String strObjectType = paramMap.getString("ObjectType");
        String strObjectID = paramMap.getString("ObjectID");
        String strMsgType = paramMap.getString("MsgType");
        String strMessageID = paramMap.getString("MessageID");
        String strSubMsgID = paramMap.getString("SubMsgID");
        String strMediaType = paramMap.getString("MediaType");
        String strIsUse = paramMap.getString("IsUse");
        String strIsDelay = paramMap.getString("IsDelay");
        String strApprovalState = paramMap.getString("ApprovalState");
        String strSenderCode = paramMap.getString("SenderCode");
        String strReservedDate = paramMap.getString("ReservedDate");
        String strXSLPath = paramMap.getString("XSLPath");
        String strWidth = paramMap.getString("Width");
        String strHeight = paramMap.getString("Height");
        String strPopupURL = paramMap.getString("PopupURL");
        String strGotoURL = paramMap.getString("GotoURL");
        String strMobileURL = paramMap.getString("MobileURL");
        String strOpenType = paramMap.getString("OpenType");
        String strMessagingSubject = paramMap.getString("MessagingSubject");
        String strMessageContext = paramMap.getString("MessageContext");
        String strReceiverText = paramMap.getString("ReceiverText");
        String strReservedStr1 = paramMap.getString("ReservedStr1");
        String strReservedStr2 = paramMap.getString("ReservedStr2");
        String strReservedStr3 = paramMap.getString("ReservedStr3");
        String strReservedStr4 = paramMap.getString("ReservedStr4");
        String strReservedInt1 = paramMap.getString("ReservedInt1");
        String strReservedInt2 = paramMap.getString("ReservedInt2");
        String strRegistererCode = paramMap.getString("RegistererCode");
        String strReceiversCode = paramMap.getString("ReceiversCode");
        
        // 값이 비어있을경우 NULL 값으로 전달
        strServiceType = StringUtils.isEmpty(strServiceType) ? null : strServiceType;
        strObjectType = StringUtils.isEmpty(strObjectType) ? null : strObjectType;
        strObjectID = StringUtils.isEmpty(strObjectID) ? null : strObjectType;
        strMsgType = StringUtils.isEmpty(strMsgType) ? null : strMsgType;
        strMessageID = StringUtils.isEmpty(strMessageID) ? null : strMessageID;
        strSubMsgID = StringUtils.isEmpty(strSubMsgID) ? null : strSubMsgID;
        strMediaType = StringUtils.isEmpty(strMediaType) ? null : strMediaType;
        strIsUse = StringUtils.isEmpty(strIsUse) ? "Y" : strIsUse;
        strIsDelay = StringUtils.isEmpty(strIsDelay) ? "N" : strIsDelay;
        strApprovalState = StringUtils.isEmpty(strApprovalState) ? "P" : strApprovalState;
        strSenderCode = StringUtils.isEmpty(strSenderCode) ? null : strSenderCode;
        strReservedDate = StringUtils.isEmpty(strReservedDate) ? null : strReservedDate;
        strXSLPath = StringUtils.isEmpty(strXSLPath) ? null : strXSLPath;
        strWidth = StringUtils.isEmpty(strWidth) ? null : strWidth;
        strHeight = StringUtils.isEmpty(strHeight) ? null : strHeight;
        strPopupURL = StringUtils.isEmpty(strPopupURL) ? null : strPopupURL;
        strGotoURL = StringUtils.isEmpty(strGotoURL) ? null : strGotoURL;
        strMobileURL = StringUtils.isEmpty(strMobileURL) ? null : strMobileURL;
        strOpenType = StringUtils.isEmpty(strOpenType) ? null : strOpenType;
        strMessagingSubject = StringUtils.isEmpty(strMessagingSubject) ? null : strMessagingSubject;
        strMessageContext = StringUtils.isEmpty(strMessageContext) ? null : strMessageContext;
        strReceiverText = StringUtils.isEmpty(strReceiverText) ? null : strReceiverText;
        strReservedStr1 = StringUtils.isEmpty(strReservedStr1) ? null : strReservedStr1;
        strReservedStr2 = StringUtils.isEmpty(strReservedStr2) ? null : strReservedStr2;
        strReservedStr3 = StringUtils.isEmpty(strReservedStr3) ? null : strReservedStr3;
        strReservedStr4 = StringUtils.isEmpty(strReservedStr4) ? null : strReservedStr4;
        strReservedInt1 = StringUtils.isEmpty(strReservedInt1) ? null : strReservedInt1;
        strReservedInt2 = StringUtils.isEmpty(strReservedInt2) ? null : strReservedInt2;
        // mssql 의 경우 오류 발생해서 수정함.
        strRegistererCode = StringUtils.isEmpty(strRegistererCode) ? "superadmin" : strRegistererCode;
        strReceiversCode = StringUtils.isEmpty(strReceiversCode) ? null : strReceiversCode;
        
		paramMap.put("ServiceType", strServiceType);
        paramMap.put("ObjectType", strObjectType);
        paramMap.put("ObjectID", strObjectID);
        paramMap.put("MsgType", strMsgType);
        paramMap.put("MessageID", strMessageID);
        paramMap.put("SubMsgID", strSubMsgID);
        paramMap.put("MediaType", strMediaType);
        paramMap.put("IsUse", strIsUse);
        paramMap.put("IsDelay", strIsDelay);
        paramMap.put("ApprovalState", strApprovalState);
        paramMap.put("SenderCode", strSenderCode);
        paramMap.put("ReservedDate", strReservedDate);
        paramMap.put("XSLPath", strXSLPath);
        paramMap.put("Width", strWidth);
        paramMap.put("Height", strHeight);
        paramMap.put("PopupURL", strPopupURL);
        paramMap.put("GotoURL", strGotoURL);
        paramMap.put("MobileURL", strMobileURL);
        paramMap.put("OpenType", strOpenType);
        paramMap.put("MessagingSubject", strMessagingSubject);
        paramMap.put("MessageContext", strMessageContext);
        paramMap.put("ReceiverText", strReceiverText);
        paramMap.put("ReservedStr1", strReservedStr1);
        paramMap.put("ReservedStr2", strReservedStr2);
        paramMap.put("ReservedStr3", strReservedStr3);
        paramMap.put("ReservedStr4", strReservedStr4);
        paramMap.put("ReservedInt1", strReservedInt1);
        paramMap.put("ReservedInt2", strReservedInt2);
        paramMap.put("RegistererCode", strRegistererCode);
        paramMap.put("ReceiversCode", strReceiversCode);
		
        messageSvc.insertMessagingData(paramMap);
	}
	
	// 결재선 조회하기
	@Override
	public CoviMap selectDomainData(CoviMap params) throws Exception {
		
		CoviMap list;
		CoviMap resultList = new CoviMap();
		
		list = coviMapperOne.select("form.formdomaindata.selectDomaindata", params);
		resultList = CoviMap.fromObject(list.getString("DomainDataContext"));
		
		return resultList;
	}

	@Override
	public String getSubjectData(CoviMap param) throws Exception {
		return coviMapperOne.selectOne("form.process.selectSubjectData", param);
	}
	
	@Override
	public CoviMap selectProcessDes(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.process.selectProcessDes", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,BusinessData1,BusinessData2,BusinessData3,BusinessData4,BusinessData5,BusinessData6,BusinessData7,BusinessData8,BusinessData9,BusinessData10"));
		
		return resultList;
	}
	
	@Override
	public String getTaskID(CoviMap param) throws Exception {
		return coviMapperOne.selectOne("form.process.selectTaskID", param);
	}
	
	@Override
	public CoviMap getTargetList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.timelinemessaging.selectTargetList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,WorkItemID,UserCode,UserName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getDistributionTargetList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("form.timelinemessaging.selectDistributionTargetList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,WorkItemID,UserCode,UserName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap getFormData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("form.timelinemessaging.selectFormData", params);
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "ProcessID,FormInstID,FormName,Subject,InitiatorID"));
		
		return resultList;
	}
	
	@Override
	public int insertTimeLineData(CoviList params) throws Exception {
		int len = params.size();
		int cnt = 0;
		
		for (int i=0; i<len; i++) {
			cnt += coviMapperOne.insert("form.timelinemessaging.insertMessage", params.get(i));
		}
		
		return cnt;
	}
	
	@Override
	public CoviMap getAlarmList(CoviMap params) throws Exception {
		//list의 날짜를 가지고 그룹핑(2020.01.02. kimhy2. 직전 ver : 15859)
		CoviMap resultList = new CoviMap();
		CoviList returnJa = new CoviList();
		CoviList list = coviMapperOne.list("form.timelinemessaging.selectAlarmList", params);
		CoviList ja = CoviSelectSet.coviSelectJSON(list);
		
		CoviMap tempJo = new CoviMap();
		CoviList tempJa = new CoviList();
		String date = "";
		Iterator<CoviMap> it = ja.iterator();
		while(it.hasNext()) {
			CoviMap obj = it.next();
			if (date.equals("")) date = obj.getString("substrRegDate"); //처음값
			if (!date.equals(obj.getString("substrRegDate"))) {//이전값 세팅
				tempJo.put(date, tempJa);
				returnJa.add(tempJo);
				date = obj.getString("substrRegDate"); 
				tempJa = new CoviList();
				tempJo = new CoviMap();
			}
			tempJa.add(obj);
		}
			
		if (!tempJa.isEmpty()) {
			tempJo.put(date, tempJa);
			returnJa.add(tempJo);
		}
		resultList.put("list", returnJa);

		return resultList;
	}
	
	@Override
	public CoviMap getUser(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap map = coviMapperOne.select("form.timelinemessaging.selectUser", params);		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "UR_Code,UR_Name"));
		
		return resultList;
	}
	
	/***
	 * 미결함 리마인드 알림
	 */
	@Override
	public void getApprovalList(CoviMap params) throws Exception {
		CoviList userArr = new CoviList();
		CoviList approvalArr = new CoviList();
		CoviMap resultList = new CoviMap();
		
		// 통합결재에 포함되는 타 시스템 코드 s ====================================
		// 전자결재 미결함 기준
		List<String> bizDataList = new ArrayList<>();

		params.put("isApprovalList", "Y");
		
		bizDataList.add("");
		bizDataList.add("APPROVAL");
		
		// 통합결재 사용유무
		if(RedisDataUtil.getBaseConfig("useTotalApproval").equalsIgnoreCase("Y")) {
			CoviList totalApprovalListType = RedisDataUtil.getBaseCode("TotalApprovalListType"); // 통합결재에 표시할 타시스템
			
			for (int i=0; i< totalApprovalListType.size(); i++) {
				// 사용여부 Y 인 경우
				if(totalApprovalListType.getJSONObject(i).optString("IsUse").equalsIgnoreCase("Y")) {
					bizDataList.add(totalApprovalListType.getJSONObject(i).getString("Code"));
				}
			}	
		}
		params.put("bizDataList", bizDataList);
		// 통합결재에 포함되는 타 시스템 코드 e ====================================
		
		CoviList userList = coviMapperOne.list("user.approvalList.selectDelayApprovalUsers", params);
		userArr = CoviSelectSet.coviSelectJSON(userList, "UserCode");
		
		for(Object obj : userArr){
			CoviMap userObj = (CoviMap)obj;
			String userCode = userObj.getString("UserCode");
			
			params.put("UserCode", userCode);
			CoviList approvalList = coviMapperOne.list("user.approvalList.selectDelayApprovalList", params);
			approvalArr = CoviSelectSet.coviSelectJSON(approvalList, "ProcessID,WorkItemID,PerformerID,FormPrefix,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2,Created,ExtInfo");

			CoviMap params2 = new CoviMap();
			params2.put("UR_CODE", userCode);
			resultList = rightApprovalConfigSvc.selectUserSetting(params2); // 여기서 다국어 가져오기
			if(resultList != null){
				CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
				String strAlarm = "";
				if(map.containsKey("Alarm") && !map.optString("Alarm").equals("")){
					strAlarm = map.optString("Alarm");
					if(strAlarm.indexOf("mailconfig") == -1) {
						legacyCmmnSvc.insertLegacy("MESSAGE", "error", ("urCode: " + userCode + "\n" + strAlarm), new Exception("not Fount mailconfig"));	
					}
					else {
						CoviMap jsonObject = CoviMap.fromObject(JSONSerializer.toJSON(strAlarm)).getJSONObject("mailconfig");
						
						if(jsonObject.get("DELAY") == null) continue;
						
						String paramMediaType = jsonObject.optString("DELAY");
						
						if(StringUtils.isNotBlank(paramMediaType)){
							if("Y".equals(paramMediaType.substring(0, 1))){
								if(!"Y;".equals(paramMediaType)){
									CoviMap subKindDic = ComUtils.setSubKindDic();
									
									// 메시지 HTML 만들기
									//첫부분
									String lang = map.getString("LanguageCode");
									StringBuffer strHTML = new StringBuffer();
									
									strHTML.append("<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>");
									strHTML.append("<body>"
										+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
											+ "<tr>"
											+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
												+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
													+ "<tr>"
														+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
														+ "전자결재(Approval)"	//TODO Title
														+"</td>"
													+ "</tr>"
												+ "</table>"
											+ "</td>"
											+ "</tr>"
											+ "<tr>"
											+ "<td bgcolor=\"#ffffff\" style=\"padding: 30px 0 30px 20px; border-left: 1px solid #e8ebed;border-right: 1px solid #e8ebed;font-size:12px;\">"
												+ "<!-- 문서현황 시작-->"
												+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\">"
													+ "<tr>"
													+ "<td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; padding: 10px 10px 10px 10px; color: #888;\">"
														+ "<span  style=\"font: bold dotum,'돋움', Apple-Gothic,sans-serif;color: #888; font-size:12px; \" line-height=\"30\">"
														//+ "<b>결재문서 지연 알림</b>"
									        			//+ "<br>결재문서가 지연되었습니다."
									        			//+ "<br>전자결재의 미결함에서 해당 문서들을 확인하여 주시기 바랍니다."
									        			+ "<b>" + DicHelper.getDic("ApprovalAlarm_DELAY", lang) + "</b>"
									        			+ DicHelper.getDic("ApprovalAlarm_DELAY_desc", lang)
													+ "</span>"
													+ " <br />"
													+ "</td>"
													+ "</tr>"
													+ "</table>"
											+ "</td>"
											+ "</tr>");
									

									strHTML.append("<tr>"
										+ "<td style=\"padding: 0 0 30px 20px; border-left: 1px solid #e8ebed; border-right: 1px solid #e8ebed;border-bottom: 1px solid #e8ebed;\">"
											+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\" style=\"padding: 20px; font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080; border: 1px solid #d7d9e0;\">"
												+ "<tr>"
												+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 20px; font: bold 16px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color: #666666;\">" + DicHelper.getDic("lbl_apv_delayList", lang) + "</td>"
												+ "</tr>"
												+ "<tr>"
												+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">");
									
									strHTML.append("<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
										+ "<tr>"
										+ "<th width=\"80\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
											//+ "종류"
											+ DicHelper.getDic("lbl_apv_kind", lang)
										+ "</th>"
										+ "<th width=\"130\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
											//+ "기안자"
											+ DicHelper.getDic("lbl_apv_writer", lang)
										+ "</th>"
										+ "<th width=\"120\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
											//+ "도착시간"
											+ DicHelper.getDic("lbl_apv_arrived_time", lang)
										+ "</th>"
										+ "<th width=\"226\" bgcolor=\"#f6f6f6\" valign=\"middle\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;line-height: 1.2em; color: #666666; border-bottom: 1px solid #b1b1b1;\">"
											//+ "제목"
											+ DicHelper.getDic("lbl_apv_subject", lang)
										+ "</th>"
										+ "</tr>");
									
									String subject = "";
									int listCnt = approvalArr.size() - 1;
									int index = 0;
								
									for(Object obj1 : approvalArr){
										CoviMap approvalObj = (CoviMap)obj1;
										
										strHTML.append("<tr>"
											+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
												+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
												+ subKindDic.getString(approvalObj.getString("SubKind"))
												+ "</span>"
											+ "</td>"
											+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
												+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
												+ DicHelper.getDicInfo(approvalObj.getString("InitiatorName"), lang) + "(" + DicHelper.getDicInfo(approvalObj.getString("InitiatorUnitName"), lang) + ")"
												+ "</span>"
											+ "</td>"
											+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
												+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
												+ approvalObj.getString("Created")
												+ "</span>"
											+ "</td>"
						                    + "<td bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"padding: 0 10px; border-bottom: 1px solid #b1b1b1;\">"
						                    		+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
						                    		+ approvalObj.getString("FormSubject")
						                    		+ "</span>"
						                    + "</td>"
						                    + "</tr>");
										
										if(index == 0) {
											subject = approvalObj.getString("FormSubject");
										}
										
										index++;
									}
										
									if(listCnt > 0) {
										subject += " " + DicHelper.getDic("lbl_att_and", lang) + " " + listCnt + DicHelper.getDic("lbl_apv_items", lang) ;
									}
									
									String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval";		// 미결함 URL
									String mobileURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/approval/mobile/approval/list.do";
									
									//뒷부분
									strHTML.append("</table></td></tr></table></td></tr></table>"
										+ "<div align=\"center\" style=\"width:716\"><a style=\"display:inline-block; color:white; font-weight:bold; width:150px; height:45px; line-height:45px;background-color:#2f91e3; font-size: 14px;text-decoration: none;\" href=\""+approvalURL+"\" target=\"_blank\">" + DicHelper.getDic("btn_GWShortcut", lang) +"</a></div>"
										+ "</body></html>");
									
									
									// 메일 발송
									CoviMap mailMap = new CoviMap();
									mailMap.put("SenderCode", userCode);
									mailMap.put("RegistererCode", userCode);
									mailMap.put("ReceiversCode", userCode);
									mailMap.put("MessagingSubject",subject);
									mailMap.put("ReceiverText", subject);
									mailMap.put("MediaType", paramMediaType.substring(2,paramMediaType.length())); // 사용자 결재 환경설정을 따름
									mailMap.put("ServiceType", "Approval");
									mailMap.put("MsgType", "ApprovalReminder");
									mailMap.put("MessageContext", strHTML.toString());
									mailMap.put("PopupURL", approvalURL);
									mailMap.put("GotoURL", approvalURL);
									mailMap.put("MobileURL", mobileURL);
									
									callMessagingProcedure(mailMap);
								}							
							}
						}
					}
				}
			}
		}
	}

	@Override
	public Boolean checkHasSubProcess(String processID) throws Exception {
		
		CoviMap params = new CoviMap();
		params.put("processID", processID);
		
		int cnt = coviMapperOne.selectOne("form.process.selectIsHasSub", params);
		
		return (cnt > 0);
	}
	
	@Override
	public void sendAccessRequestMessage() throws Exception {
		// 시작일 기준으로 update 대상 select
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectConnectReqList", null);
		
		for(Object obj : list){
			CoviMap coviObj = (CoviMap)obj;
			
			// PW: 랜덤문자5@랜덤숫자4 형태, 10자 이상이어야 함.
			String password = "";
			password += RandomStringUtils.randomAlphabetic(5) + "@" + RandomStringUtils.randomNumeric(4);
			
			// 1. AD에 만료일 update
			SynchronizeWebServiceSoapProxy s = new SynchronizeWebServiceSoapProxy();
			s.setRdpUserEnable(coviObj.optString("UserCode") + ".rdp", password, coviObj.optString("EDATE"));
			
			// 2. 기안자에게 안내 메일발송
			CoviMap paramMapObj = new CoviMap();
			
			String messageSubject = "VDI 신청 완료 및 계정 안내";
			String messageContext = "ID: " + coviObj.optString("UserCode") + ".rdp@covision.co.kr"
									+ "<br/>PW: " + password
									+ "<br/>만료기간: " + coviObj.optString("EDATE") + "까지";
			String receiverText = "VDI 신청 완료 및 계정 안내";
			
			String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("openForm.path");
			String url = "";
			url += approvalURL + "?";
			url += "mode=COMPLETE&";
			//url += "processID=" + jarr.getJSONObject(i).optString("ProcessId") + "&";
			url += "forminstanceID=" + coviObj.optString("FIID") + "&";
			url += "userCode=" + coviObj.optString("UserCode") + "&";
			url += "archived=true";
			
			paramMapObj.put("ServiceType", "Approval");
			paramMapObj.put("MsgType", "SYSMAIL_COMPLETE");
			paramMapObj.put("ReceiversCode", coviObj.optString("UserCode"));
			paramMapObj.put("MessagingSubject", messageSubject);
			paramMapObj.put("MessageContext", messageContext);
			paramMapObj.put("SenderCode", coviObj.optString("UserCode"));
			paramMapObj.put("ReceiverText", receiverText);
			paramMapObj.put("PopupURL", url);
			paramMapObj.put("GotoURL", url);
			paramMapObj.put("MediaType", "MAIL;");
			callMessagingProcedure(paramMapObj);		
			
			paramMapObj.clear();
			paramMapObj.put("FIID", coviObj.optString("FIID"));
			coviMapperOne.update("legacy.formCmmFunction.updateConnectReqList", paramMapObj);
		}
	}

	@Override
	public CoviMap getDicInfo(CoviMap params) throws Exception {
	   	CoviMap returnMap = new CoviMap();
		
		CoviMap dicParams = new CoviMap(params);
		CoviList resultList = new CoviList();
		resultList = coviMapperOne.list("framework.messaging.selectDictionary", dicParams);
			
		for (int i = 0; i < resultList.size(); i++) {
			CoviMap dicMap = resultList.getMap(i);
			if(!"".equals(dicMap.getString("DicCode"))) returnMap.put(dicMap.getString("DicCode"), dicMap.getString("DicValue"));
		}
		if (dicParams.getString("formatterMap") != null && !"".equals(dicParams.getString("formatterMap"))) {
			returnMap.put("formatterMap", dicParams.getString("formatterMap"));
		}
	
		return returnMap;
	}
}