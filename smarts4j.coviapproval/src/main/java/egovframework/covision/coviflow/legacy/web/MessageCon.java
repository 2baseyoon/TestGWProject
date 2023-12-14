package egovframework.covision.coviflow.legacy.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.coviflow.legacy.service.FormCmmFunctionSvc;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;
import egovframework.covision.coviflow.legacy.service.MessageSvc;
import egovframework.covision.coviflow.user.service.ApprovalListSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;



/**
 * @Class Name : MessageCon.java
 * @Description : 알림 서비스 요청
 * @Modification Information 
 * @ 2017.01.25 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 01.25
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageCon {

	private Logger LOGGER = LogManager.getLogger(MessageCon.class);
	
	@Autowired
	private FormCmmFunctionSvc formCmmFunctionSvc;
	
	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	
	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	private ApprovalListSvc approvalListSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	CoviMap paramMapObjDic = new CoviMap();
	/**
	 * 결재문서작성
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/setmessage.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDataFormList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("openForm.path"); //ex). http://192.168.11.126:8080/approval/approval_Form.do
		String dataInfo = null;
		
		try
		{
			//1. parameter 처리
			CoviMap paramMapObj = new CoviMap();
			
			if(request.getParameter("MessageInfo") != null){
				dataInfo = request.getParameter("MessageInfo");
			} else {
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("MessageInfo"); 
			}
			
			if(dataInfo != null){
				dataInfo = dataInfo.replace("\"ApproveCode\":null", "\"ApproveCode\":\"\"");	// null로 넘어올때 처리
				String escapedJson = StringEscapeUtils.unescapeHtml(dataInfo);		
				
				CoviList jarr = CoviList.fromObject(escapedJson);
				CoviList tempJa = new CoviList();
				CoviMap tempJo = null;
				CoviMap apvLine = null; // 결재선정보 1개만 넣기

				for(int i=0; i<jarr.size(); i++){
					//현재 사용자 ID
					String userCode = jarr.getJSONObject(i).optString("UserId");
					String status = jarr.getJSONObject(i).optString("Status");
					String subject = jarr.getJSONObject(i).optString("Subject");
					String type = jarr.getJSONObject(i).optString("Type");
					String initiator = jarr.getJSONObject(i).optString("Initiator");
					String approveCode = jarr.getJSONObject(i).optString("ApproveCode");
					String senderID = (jarr.getJSONObject(i).get("SenderID") != null) ? jarr.getJSONObject(i).optString("SenderID") : "";
					String formName = "";
					String formInstId = jarr.getJSONObject(i).getString("FormInstId");
					if(i == 0) apvLine = ((jarr.getJSONObject(i).get("ApvLineObj") != null && !jarr.getJSONObject(i).get("ApvLineObj").equals("null")) ? (CoviMap)jarr.getJSONObject(i).get("ApvLineObj") : null);
					String comment = jarr.getJSONObject(i).getString("Comment"); // 회수, 기안취소 의견
					String deputyCode = (jarr.getJSONObject(i).get("DeputyCode") != null) ? jarr.getJSONObject(i).getString("DeputyCode") : "";
					
					String url = "";
					String mobileURL = "";
					String domainID = "";
					
					// 도메인 조회
					CoviMap dParam = new CoviMap();
					dParam.put("FormInstID", formInstId);
					domainID = formCmmFunctionSvc.getDomainID(dParam);
					
					// 개인환경설정과 별개로 필수로 받아야 하는 알림
					String defaultArramKind = RedisDataUtil.getBaseConfig("DefaultArramKind");
					
					if(StringUtils.isEmpty(subject)){
						// 제목 다시 쿼리
						CoviMap param = new CoviMap();
						param.put("ProcessID", jarr.getJSONObject(i).optString("ProcessId"));
						subject = messageSvc.getSubjectData(param);
					}

					Boolean isChgContext = false;
					if(status.equalsIgnoreCase("REDRAFT_WITHDRAW_COMMENT")) {
						status = "COMMENT";
						isChgContext = true;
					}
					
					// 오류 안내 메세지는 본문에 오류내용만 포함됨.
					if(!status.equalsIgnoreCase("ENGINEERROR") && !status.equalsIgnoreCase("LEGACYERROR")) {
						//2. 개인의 전자결재 알림 설정에 따른 분기처리						
						String ccType = ""; // 참조/회람 subkind 구분
						
						if(status.equalsIgnoreCase("CHARGE")) {
							status = "APPROVAL";
						} else if(status.equalsIgnoreCase("CCINFO_BEFORE")) {
							ccType = "1";
							status = "CCINFO";
						} else if(status.equalsIgnoreCase("CCINFO_AFTER")) {
							ccType = "0";
							status = "CCINFO";
						} else if(status.equalsIgnoreCase("CIRCULATION")) {
							ccType = "C";
						}
						
						/*
						 * https://gw4j.covision.co.kr:8443/approval/approval_Form.do?
						 * mode=APPROVAL&
						 * processID=2205023&
						 * workitemID=44371&
						 * userCode=ywcho&
						 * archived=false
						 * */
						
						//http|https://host:port/context/...
						url+=MessageHelper.getInstance().replaceLinkUrl(domainID, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+"/approval/approval_Form.do"+"?";
						//url += approvalURL + "?";
						url += "mode=" + getMode(status) + "&";
						url += "processID=" + jarr.getJSONObject(i).optString("ProcessId") + "&";
						if(StringUtils.isNotBlank(jarr.getJSONObject(i).optString("WorkitemId"))){
							url += "workitemID=" + jarr.getJSONObject(i).optString("WorkitemId") + "&";
						} else if(StringUtils.isNotBlank(formInstId)){
							url += "forminstanceID=" + formInstId + "&";
						}
						url += "userCode=" + userCode + "&";
						url += "archived=" + getArchived(status) + "&";
						url += "usisdocmanager=true"; // 수신함 문서 상단 버튼 표시용
						if(status.equalsIgnoreCase("CCINFO") || status.equalsIgnoreCase("CIRCULATION")) {
							url += "&subkind=" + ccType;
							
							if(type.equalsIgnoreCase("UR")){
								url += "&gloct=TCINFO";
							} else if(type.equalsIgnoreCase("GR")) {
								url += "&gloct=DEPART";
							}
						}
												
						// HTML을 그리기 위한 데이터 가져옴
						// [19-02-27] kimhs, 알림 발송 시, 현결재자의 의견/결재일자 등이 표시되지 않는 현상이 있어 수정함
						// DB에서 조회 시, JSON 데이터가 최종으로  update되어 있지 않으므로 파라미터로 받아오도록 처리함
						// [19-05-29] kimhs, 보류 등 엔진이 아니라 화면에서 알림메일 발송 처리하는 경우 결재선 없어서 오류 발생하는 경우 확인함. 결재선 없는 경우 DB에서 select 할 수 있도록 처리.
						if(apvLine == null || apvLine.isEmpty()) {
							CoviMap paramsMap = new CoviMap();
							paramsMap.put("processID", jarr.getJSONObject(i).optString("ProcessId"));
							apvLine = messageSvc.selectDomainData(paramsMap);
						}
						
						// [2020-03-05] 경비결재 양식 팝업 분기로 인해 url 파라미터 추가함
						CoviMap paramDes = new CoviMap();
						paramDes.put("FormInstID", formInstId);
						String businessData1 = ((CoviList)messageSvc.selectProcessDes(paramDes).get("list")).getJSONObject(0).getString("BusinessData1");
						String businessData2 = ((CoviList)messageSvc.selectProcessDes(paramDes).get("list")).getJSONObject(0).getString("BusinessData2");
						
						if(StringUtils.isNotEmpty(businessData1) && businessData1.equalsIgnoreCase("ACCOUNT")) {
							CoviMap param = new CoviMap();
							param.put("WorkitemID", jarr.getJSONObject(i).optString("WorkitemId"));
							
							String taskID = messageSvc.getTaskID(param);
							
							url += "&ExpAppID=" + businessData2;
							url += "&taskID=" + taskID;
							
							mobileURL += "/account/mobile/account/view.do?";
							mobileURL += "expAppID=" + businessData2;
							mobileURL += "&taskID=" + taskID;
							mobileURL += "&listmode=Approval&";
						} else {
							mobileURL += "/approval/mobile/approval/view.do?";
						}
						
						mobileURL += "mode=" + getMode(status) + "&";
						mobileURL += "processID=" + jarr.getJSONObject(i).optString("ProcessId") + "&";
						if(StringUtils.isNotBlank(jarr.getJSONObject(i).optString("WorkitemId"))){
							mobileURL += "workitemID=" + jarr.getJSONObject(i).optString("WorkitemId") + "&";
						} else if(StringUtils.isNotBlank(formInstId)){
							mobileURL += "forminstanceID=" + formInstId + "&";
						}
						mobileURL += "userCode=" + userCode + "&";
						mobileURL += "isMobile=Y&";
						mobileURL += "isNotify=Y&"; //통합알림에서 넘어왔는지 여부
						mobileURL += "archived=" + getArchived(status);
						if(status.equalsIgnoreCase("CCINFO") || status.equalsIgnoreCase("CIRCULATION")) {
							mobileURL += "&subkind=" + ccType;
							
							if(type.equalsIgnoreCase("UR")){
								mobileURL += "&gloct=TCINFO";
							} else if(type.equalsIgnoreCase("GR")) {
								mobileURL += "&gloct=DEPART";
							}
						}
					}
					
					//구성원 쿼리
					CoviList members = new CoviList();
					if(type.equalsIgnoreCase("UR")){
						CoviMap member = new CoviMap();
						member.put("UserCode", userCode);
						
						members.add(member);
						
						if(!deputyCode.equals("")) {
							CoviMap deputyMember = new CoviMap();
							deputyMember.put("UserCode", deputyCode);
							
							members.add(deputyMember);
						}
					} else if(type.equalsIgnoreCase("GR")){
						//소속원을 쿼리
						CoviMap grParam = new CoviMap();
						grParam.put("GroupID", userCode);
						members = rightApprovalConfigSvc.selectGRMemberID(grParam);
					} else if(type.equalsIgnoreCase("JF")){
						//JF 멤버 쿼리
						CoviMap jfParam = new CoviMap();
						jfParam.put("JobFunctionCode", userCode);
						jfParam.put("DomainID", domainID);
						members = rightApprovalConfigSvc.selectJFMemberID(jfParam);

						url += "&subkind=T008";
					}
					
					
					for(int j = 0; j < members.size(); j++){
						CoviMap member = (CoviMap)members.get(j);
						
						String urCode = (String)member.get("UserCode");
						
						CoviMap params = new CoviMap();
						params.put("UR_CODE", urCode);
						resultList = rightApprovalConfigSvc.selectUserSetting(params); // 여기서 다국어 가져오기
						
						if(resultList != null){
							CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
							String strAlarm = "";
							if(map.containsKey("Alarm") && !map.optString("Alarm").equals("")){
								strAlarm = map.optString("Alarm");
								if(strAlarm.indexOf("mailconfig") == -1) {
									legacyCmmnSvc.insertLegacy("MESSAGE", "error", ("urCode: " + urCode + "\n" + strAlarm), new Exception("not Fount mailconfig"));	
								}
								else {
									formName = DicHelper.getDicInfo(jarr.getJSONObject(i).optString("FormName"), map.getString("LanguageCode"));
									String strHTML = getMessagingHtml(apvLine, status, formName, subject, url, mobileURL, map.getString("LanguageCode"), comment, domainID, isChgContext); // 사용자별 언어 가져오기
									
									CoviMap jsonObject = CoviMap.fromObject(strAlarm).getJSONObject("mailconfig");
									String paramMediaType = "";
									
									if(jsonObject.containsKey(status)) {
										paramMediaType = jsonObject.optString(status);
									}
									else if(defaultArramKind.indexOf(status) > -1) {
										CoviList TodoMsgType = RedisDataUtil.getBaseCode("TodoMsgType"); // 통합결재에 표시할 타시스템
										
										for (int z=0; z< TodoMsgType.size(); z++) {
											// 사용여부 Y 인 경우
											if(TodoMsgType.getJSONObject(z).optString("Code").equalsIgnoreCase("APPROVAL_" + status)) {
												paramMediaType = TodoMsgType.getJSONObject(z).getString("IsUse") + ";" + TodoMsgType.getJSONObject(z).getString("Reserved1");
												break;
											}
										}
									}
									
									if(StringUtils.isNotBlank(paramMediaType)){
										if("Y".equals(paramMediaType.substring(0, 1))){
											if(!"Y;".equals(paramMediaType)){
												paramMapObj.put("ServiceType", "Approval");
												paramMapObj.put("MsgType", "Approval_" + status);
												paramMapObj.put("ReceiversCode", urCode);
												paramMapObj.put("MessagingSubject", subject);
												paramMapObj.put("MessageContext", strHTML);
												
												// 알림은 방금 결재한 사람이 발송하도록 함.
												// ex) 반려한 사람 or 최종결재자 등
												paramMapObj.put("SenderCode", (StringUtils.isBlank(senderID) ? (StringUtils.isBlank(approveCode) ? initiator : approveCode) : senderID));
												paramMapObj.put("ReceiverText", subject);
												paramMapObj.put("PopupURL", url);
												paramMapObj.put("GotoURL", url);
												paramMapObj.put("MobileURL", mobileURL);
												paramMapObj.put("MediaType", paramMediaType.substring(2,paramMediaType.length()));
												paramMapObj.put("DomainID", domainID );
												paramMapObj.put("ReservedStr4", paramMapObjDic.getString("ReservedStr4"));
												messageSvc.callMessagingProcedure(paramMapObj);
												
												legacyCmmnSvc.insertLegacy("MESSAGE", "complete", dataInfo, null);
											}
										}	
									}
								}
							}
						}
						
						// 오류 알림은 타임라인에서 제외
						if(!status.equalsIgnoreCase("ENGINEERROR") && !status.equalsIgnoreCase("LEGACYERROR")) {
							// 알람 등록을 위한 데이터
							tempJo = new CoviMap();
							tempJo.put("serviceType", "APPROVAL");
							tempJo.put("messageType", status);
							tempJo.put("objectId", formInstId);
							tempJo.put("formSubject", subject);
							tempJo.put("formName", formName);
							tempJo.put("initiator", initiator);
							tempJo.put("recipientCode", urCode);
							tempJo.put("approveCode", approveCode);
							tempJo.put("formInstId", formInstId);
							tempJo.put("processId", jarr.getJSONObject(0).optString("ProcessId"));
							
							String gotoUrl = url.substring(url.indexOf("/", 8));
							tempJo.put("url", gotoUrl);
							
							tempJa.add(tempJo);
						}
						
						resultList = null;
					}
				}
						
				if (!tempJa.isEmpty()) {
					CoviMap obj = new CoviMap();
					obj.put("list", tempJa);
					
					this.setTimeLineDetailData("engine", obj);	// 데이터 가공
				}
			}
			
			// 오류목록에서 재처리한 경우 재처리대상(원본) 레코드에 Flag 처리한다.
			if(!StringUtils.isEmpty(request.getParameter("LegacyID"))) {
				String legacyID = request.getParameter("LegacyID");
				legacyCmmnSvc.updateLegacyRetryFlag(legacyID);
			}
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", dataInfo);
			
		}catch(NullPointerException npE){
			legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, npE);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equals("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, e);
			
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equals("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value="legacy/setTimeLineData.do", method=RequestMethod.POST)
	public @ResponseBody void setTimeLineData(@RequestBody CoviMap formObj) throws Exception {		
		try{
			LOGGER.info("Approval :: setTimeLineData >>> : {}", formObj);
			
			String processId = formObj.has("processID") ? formObj.getString("processID") : "";
			String formInstId = formObj.getString("FormInstID");
			CoviMap ProcessDescription = null;
			String formSubject = "";
			if (formObj.has("ProcessDescription")) {
				ProcessDescription = new CoviMap(formObj.get("ProcessDescription"));
				formSubject = ProcessDescription.getString("FormSubject");
				formObj.put("ProcessDescription", ProcessDescription);
			}
			
			if (StringUtils.isEmpty(processId)) {
				formObj.put("processID", this.getFormData(processId, formInstId).get("ProcessID"));	// 양식 정보 조회
			} 
			if (StringUtils.isEmpty(formInstId)) {
				formObj.put("FormInstID", this.getFormData(processId, formInstId).get("FormInstID"));	
			} 
			if (StringUtils.isEmpty(formSubject)) {
				if (!formObj.has("ProcessDescription")) {
					CoviMap jo = new CoviMap();
					formObj.put("ProcessDescription", jo);
				}
				
				formObj.getJSONObject("ProcessDescription").put("FormSubject", this.getFormData(processId, formInstId).get("Subject"));
			}
			
			this.setTimeLineDetailData("user", formObj);	// 데이터 가공
		}catch(NullPointerException npE){
			//legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, e);
			//LoggerHelper.errorLogger(e, "setTimeLineData",  "setTimeLineData");

			LOGGER.error("MessageCon", npE);
		}catch(Exception e){
			//legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, e);
			//LoggerHelper.errorLogger(e, "setTimeLineData",  "setTimeLineData");

			LOGGER.error("MessageCon", e);
		}
	}
	
	// 데이터 가공
	// [다국어 처리 추가] 한국어;영어;일본어;중국어 순으로 처리되어 있음(필요 시 문구 수정할 것): 구글 번역기 기준임
	private void setTimeLineDetailData(String reqType, CoviMap formObj) throws Exception {
		CoviList paramList = new CoviList();
		CoviMap params = null;
		CoviMap tempJo = null;
		
		// reqType : engine(엔진에서 호출), user(기안, 결재 등)
		if (reqType.equals("engine")) {
			CoviList ja = (CoviList) formObj.get("list");
			int size = ja.size();
			
			for (int i=0; i<size; i++) {
				tempJo = (CoviMap) ja.get(i);
				params = new CoviMap();
				
				String formInstId = tempJo.getString("formInstId");
				String processId = tempJo.getString("processId");
				String status = tempJo.getString("messageType");
				String formSubject = tempJo.getString("formSubject");
				String subject = "";
				String initiator = tempJo.getString("initiator");
				String recipientCode = tempJo.getString("recipientCode");
				String approveCode = tempJo.getString("approveCode");
				String formMultiName = this.getFormData(processId, formInstId).getString("FormName");
				String initiatorMultiName = this.getUserName(initiator);
				String approveCodeMultiName = this.getUserName(approveCode);
				String context = "";
				
				if(status.equals("COMMENT")) break;
				
				switch (status) {
				case "APPROVAL" : case "CHARGE" :	// APPROVAL(도착 알림)
					subject = "이(가) 도착하였습니다.; has arrived.;が到着しました。;已经到了。";
					break;
				case "COMPLETE" :	// 완료 알림
					subject = "이(가) 완료되었습니다.; is completed.;が完了しました。;已完成。";
					break;
				case "REJECT" :	// 반려 알림
					subject = "이(가) 반려되었습니다.; has been rejected.;が返戻されました。;已被拒绝。";
					break;
				case "CCINFO" :	// 참조 알림
					subject = "이(가) 참조되었습니다.; is referenced;が参照されました。;已引用";
					break;
				case "CIRCULATION" :	// 회람 알림
					subject = "이(가) 회람되었습니다.; has been circulated;が循環しました。;已散发";
					break;
				case "HOLD" :	// 보류 알림
					subject = "이(가) 보류되었습니다.; has been suspended.;が保留された。;已被暂停。";
					break;
				case "WITHDRAW" :	// 회수 알림
					subject = "이(가) 회수되었습니다.; has been recalled.;が回収されました。;已经被召回。";
					break;
				case "ABORT" :	// 취소 알림
					subject = "이(가) 기안 취소되었습니다.; has been canceled.;がキャンセルされました。;已被取消。";
					break;
				case "APPROVECANCEL" :	// 결재취소 알림
					subject = "이(가) 승인 취소되었습니다.; has been canceled.;がキャンセルされました。;已被取消。";
					break;
				case "REDRAFT" :	// 수신 알림
					subject = "이(가) 수신되었습니다.; has been received.;が受信されました。;已收到。";
					break;
				case "CHARGEJOB" :	// 담당업무 알림
					subject = "이(가) 담당업무함에 도착하였습니다.; has arrived in your inbox.;が担当業務すること到着しました。;已到达您的收件箱。";
					break;
				case "CONSULTATION" :	// 검토 알림
					subject = "이(가) 도착하였습니다.; has arrived.;が到着しました。;已经到了。";
					break;
				case "CONSULTATIONCOMPLETE" :	// 검토 완료 알림
					subject = "이(가) 검토 완료되었습니다.; has completed the review.;が検討が完了しました。;已审核完毕。";
					break;
				case "CONSULTATIONCANCEL" :	// 검토 요청 취소 알림
					subject = "의 검토 요청이 취소되었습니다.;'s review request has been canceled.;の検討要請が取り消されました。;的检查请求已被取消 。";
					break;
				default:
				}
				
				switch (status) {
				case "APPROVAL" : case "CHARGE" : case "COMPLETE":
				case "CCINFO": case "WITHDRAW": case "ABORT": case "REDRAFT": case "CHARGEJOB": case "CONSULTATIONCOMPLETE" :
					context = "양식명 : " + formMultiName.split(";")[0];
					context += "<br/>" + "기안자 : " + initiatorMultiName.split(";")[0];	// 이름 조회

					context += ";FormName : " + (formMultiName.split(";").length > 1 ? formMultiName.split(";")[1] : formMultiName.split(";")[0]);
					context += "<br/>" + "Initiator : " + (initiatorMultiName.split(";").length > 1 ? initiatorMultiName.split(";")[1] : initiatorMultiName.split(";")[0]);

					context += ";フォーム名 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[2] : formMultiName.split(";")[0]);
					context += "<br/>" + "首謀者 : " + (initiatorMultiName.split(";").length > 2 ? initiatorMultiName.split(";")[2] : initiatorMultiName.split(";")[0]);

					context += ";表格名称 : " + (formMultiName.split(";").length > 3 ? formMultiName.split(";")[3] : formMultiName.split(";")[0]);
					context += "<br/>" + "起草人 : " + (initiatorMultiName.split(";").length > 3 ? initiatorMultiName.split(";")[3] : initiatorMultiName.split(";")[0]);
					break;
				case "REJECT" :
					context = "양식명 : " + formMultiName.split(";")[0];
					context += "<br/>" + "반려자 : " + approveCodeMultiName.split(";")[0];

					context += ";FormName : " + (formMultiName.split(";").length > 1 ? formMultiName.split(";")[1] : formMultiName.split(";")[0]);
					context += "<br/>" + "Rejecter : " + (approveCodeMultiName.split(";").length > 1 ? approveCodeMultiName.split(";")[1] : approveCodeMultiName.split(";")[0]);

					context += ";フォーム名 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[2] : formMultiName.split(";")[0]);
					context += "<br/>" + "リジェクター : " + (approveCodeMultiName.split(";").length > 2 ? approveCodeMultiName.split(";")[2] : approveCodeMultiName.split(";")[0]);

					context += ";表格名称 : " + (formMultiName.split(";").length > 3 ? formMultiName.split(";")[3] : formMultiName.split(";")[0]);
					context += "<br/>" + "拒绝者 : " + (approveCodeMultiName.split(";").length > 3 ? approveCodeMultiName.split(";")[3] : approveCodeMultiName.split(";")[0]);
					break;
				case "CIRCULATION" :
					context = "양식명 : " + formMultiName.split(";")[0];
					context += "<br/>" + "회람지정자 : " + approveCodeMultiName.split(";")[0];

					context += ";FormName : " + (formMultiName.split(";").length > 1 ? formMultiName.split(";")[1] : formMultiName.split(";")[0]);
					context += "<br/>" + "Circular designator : " + (approveCodeMultiName.split(";").length > 1 ? approveCodeMultiName.split(";")[1] : approveCodeMultiName.split(";")[0]);

					context += ";フォーム名 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[2] : formMultiName.split(";")[0]);
					context += "<br/>" + "循環指定子 : " + (approveCodeMultiName.split(";").length > 3 ? approveCodeMultiName.split(";")[2] : approveCodeMultiName.split(";")[0]);

					context += ";表格名称 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[3] : formMultiName.split(";")[0]);
					context += "<br/>" + "圆形指示符 : " + (approveCodeMultiName.split(";").length > 3 ? approveCodeMultiName.split(";")[3] : approveCodeMultiName.split(";")[0]);
					break;
				case "HOLD" : case "APPROVECANCEL" :
					context = "양식명 : " + formMultiName.split(";")[0];
					context += "<br/>" + "결재자 : " + approveCodeMultiName.split(";")[0];

					context += ";FormName : " + (formMultiName.split(";").length > 1 ? formMultiName.split(";")[1] : formMultiName.split(";")[0]);
					context += "<br/>" + "Approver : " + (approveCodeMultiName.split(";").length > 1 ? approveCodeMultiName.split(";")[1] : approveCodeMultiName.split(";")[0]);

					context += ";フォーム名 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[2] : formMultiName.split(";")[0]);
					context += "<br/>" + "決裁者 : " + (approveCodeMultiName.split(";").length > 2 ? approveCodeMultiName.split(";")[2] : approveCodeMultiName.split(";")[0]);

					context += ";表格名称 : " + (formMultiName.split(";").length > 3 ? formMultiName.split(";")[3] : formMultiName.split(";")[0]);
					context += "<br/>" + "申请者: " + (approveCodeMultiName.split(";").length > 3 ? approveCodeMultiName.split(";")[3] : approveCodeMultiName.split(";")[0]);
					break;
				case "CONSULTATION" : case "CONSULTATIONCANCEL" :
					context = "양식명 : " + formMultiName.split(";")[0];
					context += "<br/>" + "검토요청자 : " + this.getUserName(approveCode).split(";")[0];

					context += ";FormName : " + (formMultiName.split(";").length > 1 ? formMultiName.split(";")[1] : formMultiName.split(";")[0]);
					context += "<br/>" + "Review of the requester : " + (this.getUserName(approveCode).split(";").length > 1 ? this.getUserName(approveCode).split(";")[1] : this.getUserName(approveCode).split(";")[0]);

					context += ";フォーム名 : " + (formMultiName.split(";").length > 2 ? formMultiName.split(";")[2] : formMultiName.split(";")[0]);
					context += "<br/>" + "検討要請者 : " + (this.getUserName(approveCode).split(";").length > 2 ? this.getUserName(approveCode).split(";")[2] : this.getUserName(approveCode).split(";")[0]);

					context += ";表格名称 : " + (formMultiName.split(";").length > 3 ? formMultiName.split(";")[3] : formMultiName.split(";")[0]);
					context += "<br/>" + "上访者讨论: " + (this.getUserName(approveCode).split(";").length > 3 ? this.getUserName(approveCode).split(";")[3] : this.getUserName(approveCode).split(";")[0]);
					break;
				default:
				}
				
				params.put("serviceType", tempJo.getString("serviceType"));
				params.put("messageType", status);
				params.put("objectId", tempJo.getString("objectId"));
				params.put("formSubject", formSubject);
				params.put("subject", subject);
				params.put("context", context);
				params.put("gotoUrl", tempJo.getString("url"));
				params.put("recipientCode", recipientCode);
				params.put("registerCode", initiator);
				params.put("processID", processId);
				
				paramList.add(params);
			}
		} else {
			String formInstId = formObj.getString("FormInstID");
			String mode = formObj.getString("mode");
			String actionMode = formObj.getString("actionMode");
			String actionComment = StringUtils.isEmpty(formObj.getString("actionComment")) ? "" : new String(Base64.decodeBase64(formObj.getString("actionComment")),StandardCharsets.UTF_8);
			String processId = formObj.getString("processID");
			String formSubject = formObj.has("ProcessDescription") ? formObj.getJSONObject("ProcessDescription").getString("FormSubject") : "";
			String formData = formObj.has("FormData") ? formObj.getString("FormData") : "";
			String attachFileInfo = (!formData.equals("") && formObj.getJSONObject("FormData").has("AttachFileInfo")) ? formObj.getJSONObject("FormData").getString("AttachFileInfo") : "";
			final String[] diffArr = {"APPROVAL", "AGREE", "REJECT", "DISAGREE", "REJECTTO"};
			final HashMap<String, String> diffAppMap = new HashMap<String, String>() {{
			    put("DRAFT","기안");put("APPROVAL","승인");put("AGREE","동의");put("REJECT","반려");put("DISAGREE","거부");put("REJECTTO","지정반려");
			}};
			final HashMap<String, String> diffAppMap_ja = new HashMap<String, String>() {{
			    put("DRAFT","起案");put("APPROVAL","承認");put("AGREE","同意");put("REJECT","伴侶");put("DISAGREE","拒否");put("REJECTTO","指定伴侶");
			}};
			final HashMap<String, String> diffAppMap_zh = new HashMap<String, String>() {{
			    put("DRAFT","草稿");put("APPROVAL","批准");put("AGREE","同意书");put("REJECT","同伴");put("DISAGREE","拒绝");put("REJECTTO","指定同伴");
			}};
			String path = PropertiesUtil.getGlobalProperties().getProperty("openForm.path");
			path = path.substring(path.indexOf("/", 8));
			String url = "";
			String initiatorId = this.getFormData(processId, formInstId).getString("InitiatorID");	// 양식 정보 조회
			
			// 알림  대상 조회
			// 배포 부서 제외하기
			String processDefinitionID = formObj.has("processDefinitionID") ? formObj.getString("processDefinitionID") : "";
			String scIPub = "";
			if(formObj.containsKey("FormInfoExt")) {
				scIPub = formObj.getJSONObject("FormInfoExt").has("scIPub") ? formObj.getJSONObject("FormInfoExt").getString("scIPub") : "";
			} else {
				params = new CoviMap();
				params.put("formID", formObj.get("formID"));
				CoviMap schemeData = approvalListSvc.selectFormExtInfo(params);
				if(schemeData.containsKey("SchemaContext"))
					scIPub = schemeData.getJSONObject("SchemaContext").getJSONObject("scIPub").optString("isUse").equals("Y") ? "True" : "False";
			}
			String processName = formObj.has("processName") ? formObj.getString("processName") : "";
			CoviMap resultList = new CoviMap();
			if(processDefinitionID.indexOf("draft") > -1 && scIPub.equalsIgnoreCase("TRUE") && !processName.equalsIgnoreCase("Sub") && !messageSvc.checkHasSubProcess(processId)){
				params = new CoviMap();
				params.put("processID", processId);
				resultList = messageSvc.getDistributionTargetList(params);
			}else{
				params = new CoviMap();
				params.put("formInstId", formInstId);
				resultList = messageSvc.getTargetList(params);
			}
			
			// 이름 조회
			String userName = formObj.has("usid") ? this.getUserName(formObj.getString("usid")) : "";
			
			CoviList arr = (CoviList)resultList.get("list");
			int size = arr.size();
			
			for (int i=0; i<size; i++) {
				// 결재한 당사자 제외
				if (!StringUtils.isEmpty(actionMode) && !formObj.optString("usid").equalsIgnoreCase(arr.getJSONObject(i).getString("UserCode"))) {
					// 의견 등록
					if (!mode.equals("DRAFT") && !StringUtils.isEmpty(actionComment)) {
						params = new CoviMap();
						params.put("serviceType", "APPROVAL");
						params.put("messageType", "COMMENT");
						params.put("objectId", formInstId);
						params.put("formSubject", formSubject);
						params.put("subject", "에 의견이 추가되었습니다.; a comment was added;にコメントを追加しました。;评论已添加到");
						
						String context = "결재자 : " + userName + "<br/>" + "의견";
						if (diffAppMap.containsKey(actionMode)) {
							context += "(" + diffAppMap.get(actionMode) + ")";
						}
						
						context += ";Approval : " + userName + "<br/>" + "Comment(" + actionMode + ")";
						context += ";決裁者 : " + userName + "<br/>" + "意見";
						if (diffAppMap_ja.containsKey(actionMode)) {
							context += "(" + diffAppMap_ja.get(actionMode) + ")";
						}
						
						context += ";申请者 : " + userName + "<br/>" + "指定同伴";
						if (diffAppMap_zh.containsKey(actionMode)) {
							context += "(" + diffAppMap_zh.get(actionMode) + ")";
						}
						
						context += " : " + actionComment;
						params.put("context", context);
						url = path + "?mode=PROCESS&processID=" + arr.getJSONObject(i).getString("ProcessID") + "&workitemID=" + arr.getJSONObject(i).getString("WorkItemID") + "&archived=false";
						params.put("gotoUrl", url);
						params.put("recipientCode", arr.getJSONObject(i).getString("UserCode"));
						params.put("registerCode", initiatorId);
						params.put("processID", arr.getJSONObject(i).getString("ProcessID"));
						
						paramList.add(params);						
					}
					// 내용 편집
					if (Arrays.asList(diffArr).contains(actionMode) && 
						!formData.equals("") && 
						formObj.getJSONObject("FormData").size() > 0 && 
						!(formObj.getJSONObject("FormData").size() == 1 && formObj.getJSONObject("FormData").has("AttachFileInfo"))) {
							params = new CoviMap();
							params.put("serviceType", "APPROVAL");						
							params.put("messageType", "UPD_CONTEXT");
							params.put("objectId", formInstId);
							params.put("formSubject", formSubject);
							params.put("subject", "의 내용이 수정되었습니다.; has been modified.;の内容が変更されました。;已被修改。");
							params.put("context", "변경한 결재자 : " + userName);
							url = path + "?mode=PROCESS&processID=" + arr.getJSONObject(i).getString("ProcessID") + "&workitemID=" + arr.getJSONObject(i).getString("WorkItemID") + "&archived=false";
							params.put("gotoUrl", url);
							params.put("recipientCode", arr.getJSONObject(i).getString("UserCode"));
							params.put("registerCode", initiatorId);
							params.put("processID", arr.getJSONObject(i).getString("ProcessID"));
							
							paramList.add(params);
					}
					// 결제선 편집
					if (!mode.equals("REDRAFT") && !mode.equals("SUBREDRAFT")  && Arrays.asList(diffArr).contains(actionMode) && formObj.has("ChangeApprovalLine")) {
						params = new CoviMap();
						params.put("serviceType", "APPROVAL");						
						params.put("messageType", "UPD_APVLINE");
						params.put("objectId", formInstId);
						params.put("formSubject", formSubject);
						params.put("subject", "의 결재선이 수정되었습니다.; the approval line for has been modified.;の内容が変更されました。;已被修改。");
						params.put("context", "변경한 결재자 : " + userName);
						url = path + "?mode=PROCESS&processID=" + arr.getJSONObject(i).getString("ProcessID") + "&workitemID=" + arr.getJSONObject(i).getString("WorkItemID") + "&archived=false";
						params.put("gotoUrl", url);
						params.put("recipientCode", arr.getJSONObject(i).getString("UserCode"));
						params.put("registerCode", initiatorId);
						params.put("processID", arr.getJSONObject(i).getString("ProcessID"));
						
						paramList.add(params);
					}
					// 첨부파일 편집
					if (Arrays.asList(diffArr).contains(actionMode) && !StringUtils.isEmpty(attachFileInfo)) {
						params = new CoviMap();
						params.put("serviceType", "APPROVAL");						
						params.put("messageType", "UPD_ATTACH");
						params.put("objectId", formInstId);
						params.put("formSubject", formSubject);
						params.put("subject", "의 첨부파일이 수정되었습니다.; The attachment at has been modified.;の添付ファイルが変更されました。;的附件已被修改。");
						params.put("context", "변경한 결재자 : " + userName);
						url = path + "?mode=PROCESS&processID=" + arr.getJSONObject(i).getString("ProcessID") + "&workitemID=" + arr.getJSONObject(i).getString("WorkItemID") + "&archived=false";
						params.put("gotoUrl", url);
						params.put("recipientCode", arr.getJSONObject(i).getString("UserCode"));
						params.put("registerCode", initiatorId);
						params.put("processID", arr.getJSONObject(i).getString("ProcessID"));
						
						paramList.add(params);
					}
				}
			}
		}
		
		if (!paramList.isEmpty()) {
			messageSvc.insertTimeLineData(paramList);
		}
	}
	
	// 양식 정보 조회
	private CoviMap getFormData(String processId, String formInstId) throws Exception {
		CoviMap params = new CoviMap();
		if (StringUtils.isEmpty(formInstId)) {
			params.put("processId", processId);
		} else {
			params.put("formInstId", formInstId);
		}
		
		return ((CoviList)messageSvc.getFormData(params).get("map")).getJSONObject(0);
	}
	
	// 이름 조회
	private String getUserName(String userId) throws Exception {
		CoviMap params = new CoviMap();
		params.put("userId", userId);
		
		return (((CoviList)messageSvc.getUser(params).get("map")).getJSONObject(0)).getString("UR_Name");
	}
	
	// 홈 화면 알람 조회
	@RequestMapping(value = "legacy/getAlarmList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getAlarmList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("userId", SessionHelper.getSession("USERID"));
			params.put("UR_TimeZone", SessionHelper.getSession("UR_TimeZone"));
			
			String strTerm = RedisDataUtil.getBaseConfig("MyApprovalListTerm");
			String strCount = RedisDataUtil.getBaseConfig("MyApprovalListCount");
			if(strTerm.equals("") || strTerm.equals("0")) { // 건수
				params.put("count", "".equals(strCount) ? 0 : Integer.parseInt(strCount));
			}
			else { // 기간, 개월수
				params.put("term", strTerm);
			}
			
			String businessData1 = StringUtil.replaceNull(request.getParameter("businessData1"));

			// 통합결재 조건 추가
			String useTotalApproval = StringUtils.isNotEmpty(RedisDataUtil.getBaseConfig("useTotalApproval")) ? RedisDataUtil.getBaseConfig("useTotalApproval") : "N"; // 통합결재 사용여부
			if(useTotalApproval.equalsIgnoreCase("Y") || useTotalApproval.equalsIgnoreCase("N")) {
				params = approvalListSvc.getApprovalListCode(params, businessData1);	
			} else {
				params.put("isApprovalList", "X");
			}
			
			resultList = messageSvc.getAlarmList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equals("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equals("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	private String getArchived(String status){
		String ret = null;
		
		 switch(status) {
	        case "APPROVAL":
	        	ret = "false";
	          break;
	        case "REJECT":
	        	ret = "true";
	          break;
	        case "COMPLETE":
	        	ret = "true";
	          break;
	        case "CCINFO":
	        	ret = "false";
	          break;
	        case "CIRCULATION":
	        	ret = "false";
	          break;
	        case "CHARGE":
	        	ret = "false";
	          break;
	        case "CHARGEJOB":
	        	ret = "false";
	          break;
	        case "WITHDRAW":
	        	ret = "false";
	          break;
	        case "ABORT":
	        	ret = "false";
	          break;
	        case "HOLD":
	        	ret = "false";
	          break;
	        case "APPROVECANCEL":
	        	ret = "false";
	          break;
	        case "REDRAFT":
	        	ret = "false";
	          break;
	        case "COMMENT":
	        	ret = "false";
	          break;
	        case "CONSULTATION":
	        case "CONSULTATIONCANCEL":
	        case "CONSULTATIONCOMPLETE":
	        	ret = "false";
	          break; 
	        default:
	        	ret = "true";
	    }
				
		return ret;
	}
	
	private String getMode(String status){
		String ret = null;
		
		 switch(status) {
	        case "APPROVAL":
	        	ret = "APPROVAL";
	          break;
	        case "REJECT":
	        	ret = "REJECT";
	          break;
	        case "COMPLETE":
	        	ret = "COMPLETE";
	          break;
	        case "CCINFO":
	        	ret = "COMPLETE";
	          break;
	        case "CIRCULATION":
	        	ret = "COMPLETE";
	          break;
	        case "CHARGE":
	        	ret = "APPROVAL";
	          break;
	        case "CHARGEJOB":
	        	ret = "APPROVAL";
	          break;
	        case "WITHDRAW":
	        	ret = "TEMPSAVE";
	          break;
	        case "ABORT":
	        	ret = "TEMPSAVE";
	          break;
	        case "HOLD":
	        	ret = "PROCESS";
	          break;
	        case "APPROVECANCEL":
	        	ret = "PROCESS";
	          break;
	        case "REDRAFT":
	        	ret = "REDRAFT";
	          break;
	        case "COMMENT":
	        	ret = "PROCESS";
	          break;
	        case "CONSULTATION":
	        	ret = "CONSULTATION";
	          break;
	        case "CONSULTATIONCOMPLETE":
	        	ret = "APPROVAL";
	          break;
	        case "CONSULTATIONCANCEL":
	        	ret = "PROCESS";
	          break;
          default:
        	  ret = "";
	    }
				
		return ret;
	}
	
	private String getContext(String mode, String strText, String lang, Boolean isChgContext){
		String ret = "";
		
		 switch(mode) {
	        case "APPROVAL":
	        	ret += "<b> §ApprovalAlarm_APPROVAL§ </b>";
	        	ret += "§ApprovalAlarm_APPROVAL_desc§";
	        	break;
	        case "REDRAFT":
	        	ret += "<b> §ApprovalAlarm_APPROVAL§ </b>";
	        	ret += "§ApprovalAlarm_REDRAFT_desc§";
	        	break;
	        case "CCINFO":
	        case "CCINFO_U":
	        case "CIRCULATION":
	        	ret += "<b> §ApprovalAlarm_CC§ </b>";
	        	ret += "§ApprovalAlarm_CC_desc§";
	        	
	        	if(mode.equalsIgnoreCase("CIRCULATION") && StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_CC_desc2§" + strText;
	        	break;
	        case "CHARGE":
	        case "COMPLETE":
	        	ret += "<b> §ApprovalAlarm_COMPLETE§ </b>";
	        	ret += "§ApprovalAlarm_COMPLETE_desc§";
	        	break;
	        case "REDRAFT_RE":
	        	ret += "<b> §ApprovalAlarm_REDRAFT§ </b>";
	        	ret += "§ApprovalAlarm_REDRAFT_RE_desc§";
	        	break;
	        case "REJECT":
	        	ret += "<b> §ApprovalAlarm_REJECT§ </b>";
	        	ret += "§ApprovalAlarm_REJECT_desc§";
	        	break;
	        case "CHARGEJOB":
	        	ret += "<b> §ApprovalAlarm_APPROVAL§ </b>";
	        	ret += "§ApprovalAlarm_CHARGEJOB_desc§";
	        	break;
	        case "DELAY":
	        	ret += "<b> §ApprovalAlarm_DELAY§ </b>";
	        	ret += "§ApprovalAlarm_DELAY_desc§";
	        	break;
	        case "HOLD":
	        	ret += "<b> §ApprovalAlarm_HOLD§ </b>";
	        	
	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_HOLD_desc§" + strText;
	        	break;
	        case "WITHDRAW":
	        	ret += "<b> §ApprovalAlarm_WITHDRAW§ </b>";
	        	
	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_WITHDRAW_desc§" + strText;
	        	break;
	        case "ABORT":
	        	ret += "<b> §ApprovalAlarm_ABORT§ </b>";
	        	
	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_ABORT_desc§" + strText;
	        	break;
	        case "APPROVECANCEL":
	        	ret += "<b> §ApprovalAlarm_APPROVECANCEL§ </b>";
	        	
	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_APPROVECANCEL_desc§" + strText;
	        	break;
	        case "ASSIGN_APPROVAL":
	        	ret += "<b> §ApprovalAlarm_ASSIGN_APPROVAL§ </b>";
	        	ret += "§ApprovalAlarm_ASSIGN_APPROVAL_desc§";
	        	break;
	        case "ASSIGN_CHARGE":
	        	ret += "<b> §ApprovalAlarm_ASSIGN_CHARGE§ </b>";
	        	ret += "§ApprovalAlarm_ASSIGN_CHARGE_desc§";
	        	break;
	        case "ASSIGN_R":
	        	ret += "<b> §ApprovalAlarm_ASSIGN_R§ </b>";
	        	ret += "§ApprovalAlarm_ASSIGN_R_desc§";
	        	break;
	        case "COMMENT":
	        	if (isChgContext) {
		        	ret += "<b> §ApprovalAlarm_REDRAFT_WITHDRAW_COMMENT§ </b>";
		        	
		        	if(StringUtils.isNotBlank(strText))
		        		ret += "§ApprovalAlarm_REDRAFT_WITHDRAW_COMMENT_desc§" + strText;
	        	} else {
		        	ret += "<b> §ApprovalAlarm_COMMENT§ </b>";
		        	
		        	if(StringUtils.isNotBlank(strText))
		        		ret += "§ApprovalAlarm_COMMENT_desc§" + strText;
	        	}
	        	break;
	        case "ENGINEERROR": // 엔진오류
	        	ret += "<b> §ApprovalAlarm_ENGINEERROR§ </b>";
	        	ret += "§ApprovalAlarm_ENGINEERROR_desc§" + strText;
	        	break;
	        case "LEGACYERROR": // 연동오류
	        	ret += "<b> §ApprovalAlarm_LEGACYERRER§ </b>";
	        	ret += "§ApprovalAlarm_LEGACYERRER_desc§" + strText;
	        	break;
	        case "CONSULTATION":
	        	ret += "<b> §ApprovalAlarm_CONSULTATION§ </b>"; // 결재 검토 알림

	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_CONSULTATION_desc§" + strText;
	        	break;
	        case "CONSULTATIONCOMPLETE":
	        	ret += "<b> §ApprovalAlarm_CONSULTATIONCOMPLETE§ </b>"; // 결재 검토 완료 알림
	        	ret += "§ApprovalAlarm_CONSULTATIONCOMPLETE_desc§";
	        	break;
	        case "CONSULTATIONCANCEL":
	        	ret += "<b> §ApprovalAlarm_CONSULTATIONCANCEL§ </b>";
	        	
	        	if(StringUtils.isNotBlank(strText))
	        		ret += "§ApprovalAlarm_CONSULTATIONCANCEL_desc§" + strText;
	        	break;
        	default:
	    }
				
		return ret;
	}
	
	public CoviList mailMessageApvLineParsing(CoviMap apvLine) throws Exception{
		CoviList oDivisions = new CoviList();
		CoviList oSteps = new CoviList();
		CoviList oOus = new CoviList();
		CoviList oPersons = new CoviList();
		
		CoviList htmlResult = new CoviList();
		
		apvLine = apvLine.getJSONObject("steps");
		if(apvLine.has("division")){													// division
			if(apvLine.get("division") instanceof CoviMap)
				oDivisions.add(apvLine.getJSONObject("division"));
			else if(apvLine.get("division") instanceof CoviList)
				oDivisions = apvLine.getJSONArray("division");
			
			for(Object jsonObj1 : oDivisions){
				CoviMap oDivision = (CoviMap) jsonObj1;
				if(oDivision.has("step")){											// step
					if(oDivision.get("step") instanceof CoviMap)
						oSteps.add(oDivision.getJSONObject("step"));
					else if(oDivision.get("step") instanceof CoviList)
						oSteps = oDivision.getJSONArray("step");
					
					for(Object jsonObj2 : oSteps){
						CoviMap oStep = (CoviMap) jsonObj2;
						String routetype = oStep.getString("routetype");
						
						if(oStep.has("ou")){											// ou
							if(oStep.get("ou") instanceof CoviMap)
								oOus.add(oStep.getJSONObject("ou"));
							else if(oStep.get("ou") instanceof CoviList)
								oOus = oStep.getJSONArray("ou");
							
							for(Object jsonObj3 : oOus){
								CoviMap oOu = (CoviMap) jsonObj3;
								
								if(oOu.has("person")){								// person
									CoviList personArr = new CoviList();
									
									if(oOu.get("person") instanceof CoviMap)
										personArr.add(oOu.getJSONObject("person"));
									else if(oOu.get("person") instanceof CoviList)
										personArr = oOu.getJSONArray("person");
									
									String strDivisionOuCode = "";
									for(Object jsonObj4 : personArr){
										CoviMap oPerson = (CoviMap) jsonObj4;
										CoviMap taskInfo = oPerson.getJSONObject("taskinfo");
										
										boolean isDisplay = false;
										//Boolean isReceiveCharge = false;
										boolean isReceive = false;
										
										if(taskInfo.has("visible")){
											if(!taskInfo.optString("visible").equals("n"))
												isDisplay = true;
										}else if(!taskInfo.optString("kind").equals("conveyance"))
											isDisplay = true;
										
										if(oDivision.has("divisiontype")){
//											if(oDivision.optString("divisiontype").equals("receive")){
//												if(oDivision.has("oucode") && strDivisionOuCode.equals(oDivision.getString("oucode"))){
//													isReceiveCharge = true;
//												}
//												strDivisionOuCode = oDivision.getString("oucode");
//											}
											if(oDivision.optString("divisiontype").equals("receive")){
												isReceive = true;
											}
										}
										
										if(isDisplay){											
											String sKind = "";
											String sStatus = "";
											String sOuName = "";
											String sName = "";
											String sDate = "";
											//String sInitName = "";
											//String sInitOUName = "";
											String sTitle = "";
											String sComment = "";
											
											switch (routetype) {
												case "receive": sKind = "lbl_apv_receive"; break; // 수신
												case "assist": sKind = "lbl_apv_reject_consent"; break; // 협조
												case "consult": sKind = "lbl_apv_tit_consent"; break; // 합의
												case "audit":
													if(oStep.optString("name").equalsIgnoreCase("audit") || oStep.optString("name").equalsIgnoreCase("audit_dept")) 
														sKind = "lbl_apv_audit"; // 감사
													if(oStep.optString("name").equalsIgnoreCase("audit_law") || oStep.optString("name").equalsIgnoreCase("audit_law_dept")) 
														sKind = "lbl_apv_law"; // 준법
													break;
												case "approve":
													switch (taskInfo.getString("kind")) {
														case "authorize": sKind = "lbl_apv_authorize"; break; // 전결
							                            case "review": sKind = "lbl_apv_review"; break; // 후결
							                            case "charge":
							                                if (isReceive)
							                                    sKind = "lbl_apv_receive"; // 수신
							                                else
							                                    sKind = "lbl_apv_Draft"; // 기안
							                                break;
							                            case "substitute": sKind = "lbl_apv_substitue"; break; // 대결
							                            case "bypass": sKind = "lbl_apv_bypass"; break; // 후열
							                            case "consent": sKind = "lbl_apv_tit_consent"; break; // 합의
							                            case "consult": sKind = "lbl_apv_tit_consent"; break; // 합의
							                            case "confirm": sKind = "lbl_apv_Confirm"; break; // 확인
							                            case "reference": sKind = "lbl_apv_cc"; break; // 참조
							                            case "normal": 
							                            default:
							                            	sKind = "lbl_apv_app"; // 결재
													}
													break;
												default: sKind = "lbl_apv_app"; break; // 결재 
											}
					                        switch (taskInfo.getString("result"))
					                        {
					                            case "authorized": sStatus = "lbl_apv_Approved"; break; // 승인
					                            case "completed": sStatus = "lbl_apv_Approved"; break; // 승인
					                            case "reviewed": sStatus = "lbl_apv_Approved"; break; // 승인
					                            case "agreed": sStatus = "lbl_apv_agree"; break; // 동의
					                            case "rejected": sStatus = "lbl_apv_reject"; break; // 반려
					                            case "bypass": sStatus = "lbl_apv_bypass"; break; // 후열
					                            case "disagreed": sStatus = "lbl_apv_disagree"; break; // 거부
					                            case "reserved": sStatus = "lbl_apv_hold"; break; // 보류
					                            case "confirmed": sStatus = "lbl_apv_Confirm"; break; // 확인
					                            default:
					                        }
					                        
					                        if(taskInfo.optString("kind").equalsIgnoreCase("substituted") && oStep.optString("status").equalsIgnoreCase("completed")) {
					                        	sStatus = "lbl_apv_Approved"; // 승인 
					                        }
					                        
					                        sOuName = oPerson.getString("oucode");
					                        sName = oPerson.getString("code");
					                        
					                        if(taskInfo.has("datecompleted")){
					                        	sDate = ComUtils.TransDateLocalFormat(taskInfo.getString("datecompleted"));
					                        }
											/*
											 * if(taskInfo.optString("kind").equals("charge")){ sInitName = sName;
											 * sInitOUName = sOuName; }
											 */
					                        if(!oPerson.containsKey("title")){
					                        	sTitle = "";
					                        }else if(oPerson.getString("title").split(";").length > 1){
					                        	sTitle = oPerson.getString("title").substring(oPerson.getString("title").indexOf(";"));
					                        }
					                        if(taskInfo.has("comment")){
					                        	sComment = new String(Base64.decodeBase64(taskInfo.getJSONObject("comment").getString("#text").getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					                        }
					                        
					                        CoviMap htmlObj = new CoviMap();
					                        htmlObj.put("KIND", sKind);
					                        htmlObj.put("STATUS", sStatus);
					                        htmlObj.put("OUNAME", sOuName);
					                        htmlObj.put("NAME", sName);
					                        htmlObj.put("TITLE", sTitle);
					                        htmlObj.put("COMMENT", sComment);
					                        htmlObj.put("DATE", sDate);
					                        
					                        htmlResult.add(htmlObj);
										}
									}
								} else {									
									String sKind = "";
									String sStatus = "";
									String sOuName = "";
									String sName = "";
									String sDate = "";
									//String sInitName = "";
									//String sInitOUName = "";
									String sTitle = "";
									String sComment = "";
									CoviMap taskInfo = null;	
									if(oOu.has("role")){ // role
										CoviMap oRole = oOu.getJSONObject("role");
										taskInfo = oRole.getJSONObject("taskinfo");
									} else {
										taskInfo = oOu.getJSONObject("taskinfo");
									}
									
									sOuName = oOu.getString("name");
									
									switch (routetype) {
										case "receive": sKind = "lbl_apv_receive"; break; // 수신
										case "assist": sKind = "lbl_apv_reject_consent"; break; // 협조
										case "consult": sKind = "lbl_apv_tit_consent"; break; // 합의
										case "audit":
											if(oStep.optString("name").equalsIgnoreCase("audit_dept")) sKind = "lbl_apv_audit"; // 감사
											if(oStep.optString("name").equalsIgnoreCase("audit_law_dept")) sKind = "lbl_apv_law"; // 준법
											break;
										default: sKind = "lbl_apv_app"; break; // 결재 
									}
									
									switch (taskInfo.getString("result"))
			                        {
			                            case "authorized": sStatus = "lbl_apv_Approved"; break; // 승인
			                            case "completed": sStatus = "lbl_apv_Approved"; break; // 승인
			                            case "reviewed": sStatus = "lbl_apv_Approved"; break; // 승인
			                            case "agreed": sStatus = "lbl_apv_agree"; break; // 동의
			                            case "rejected": sStatus = "lbl_apv_reject"; break; // 반려
			                            case "bypass": sStatus = "lbl_apv_bypass"; break; // 후열
			                            case "disagreed": sStatus = "lbl_apv_disagree"; break; // 거부
			                            case "reserved": sStatus = "lbl_apv_hold"; break; // 보류
			                            case "confirmed": sStatus = "lbl_apv_Confirm"; break; // 확인
			                            default:
			                        }
			                        
			                        if(taskInfo.optString("kind").equalsIgnoreCase("substituted") && oStep.optString("status").equalsIgnoreCase("completed")) {
			                        	sStatus = "lbl_apv_Approved"; // 승인
			                        }
			                        
									CoviMap htmlObj = new CoviMap();
			                        htmlObj.put("KIND", sKind);
			                        htmlObj.put("STATUS", sStatus);
			                        htmlObj.put("OUNAME", sOuName);
			                        htmlObj.put("NAME", sName);
			                        htmlObj.put("TITLE", sTitle);
			                        htmlObj.put("COMMENT", sComment);
			                        htmlObj.put("DATE", sDate);
			                        
			                        htmlResult.add(htmlObj);
								}
							}
							oOus = new CoviList();
						}
					}
					oSteps = new CoviList();
				}
			}
			oDivisions = new CoviList();
		}
		return htmlResult;
	}
	
	/**
	 * 미결함 리마인드 알림
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/sendDelayMsg.do", method=RequestMethod.POST)
	public @ResponseBody void sendDelayMsg(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		
		try{
			CoviMap params = new CoviMap();
			
			int delayListCnt = Integer.parseInt(RedisDataUtil.getBaseConfig("DelayListCount"));
			
			List<String> formList = new ArrayList<>();
			
			if(RedisDataUtil.getBaseConfig("DelayFormPrefix").equals("")) {
				//formList.add("");
				
				params.put("DelayPeriodDay", RedisDataUtil.getBaseConfig("DelayPeriodDay"));
				params.put("DelayFormPrefix", null);
				params.put("DelayListCount", delayListCnt);
				
			} else {
				String[] arrFormPrefix = RedisDataUtil.getBaseConfig("DelayFormPrefix").split(";");
				for(int i=0; i<arrFormPrefix.length; i++) {
					if(StringUtils.isNotEmpty(arrFormPrefix[i]))
						formList.add(arrFormPrefix[i]);
				}
				
				params.put("DelayPeriodDay", RedisDataUtil.getBaseConfig("DelayPeriodDay"));
				params.put("DelayFormPrefix", formList);
				params.put("DelayListCount", delayListCnt);
				
			}
			

			messageSvc.getApprovalList(params);
		}catch(ArrayIndexOutOfBoundsException aioobE){
			LoggerHelper.errorLogger(aioobE, "sendDelayMsg",  "sendDelayMsg");
		}catch(NullPointerException npE){
			LoggerHelper.errorLogger(npE, "sendDelayMsg",  "sendDelayMsg");
		}catch(Exception e){
			LoggerHelper.errorLogger(e, "sendDelayMsg",  "sendDelayMsg");
		}
	}
	
	// 본사 - 사외접속 신청서
	@RequestMapping(value = "/legacy/sendAccessReqMsg.do" )
	public void sendAccessRequestMessage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		try{	
			messageSvc.sendAccessRequestMessage();
		}catch(NullPointerException npE){
			LoggerHelper.errorLogger(npE, "sendAccessReqMsg",  "sendAccessReqMsg");
		}catch(Exception e){
			LoggerHelper.errorLogger(e, "sendAccessReqMsg",  "sendAccessReqMsg");
		}
	}

	// 언어에 따른 결재 알림메일 본문 html 그리기
	@SuppressWarnings("unchecked")
	private String getMessagingHtml(CoviMap apvLine, String status, String formName, String subject, String url, String mobileURL, String lang, String comment, String domainId, Boolean isChgContext) throws Exception {
		//HTML 그리기
		// HTML 생성하기

		StringBuilder strHTML = new StringBuilder();
		CoviList dicList = new CoviList();
		CoviList nameList = new CoviList();
		CoviList ouNameList = new CoviList();
		
		strHTML.append("<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>");
		strHTML.append("<body>"
				+ "<table width=\"545\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">"
						+ "<tr>"
						+ "<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#515c81\" >"
								+ "<table width=\"690\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">"
										+ "<tr>"
										+ "<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">"
										+ subject
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
												+ getContext(status, comment, lang, isChgContext)
												+ "</span>"
												+ " <br />"
										+ "</td>"
										+ "</tr>"
								+ "</table>"
						+ "</td>"
						+ "</tr>");
		
		// 회수, 기안취소 예외 > 회수, 기안취소 시에도 본문 내용 보내도록 수정(21.10.18)
		// 오류 안내 메세지는 본문에 오류내용만 포함됨.
		if(!status.equals("ENGINEERROR") && !status.equals("LEGACYERROR")){
			strHTML.append("<tr>"
							+ "<td style=\"padding: 0 0 30px 20px; border-left: 1px solid #e8ebed; border-right: 1px solid #e8ebed;border-bottom: 1px solid #e8ebed;\">"
									+ "<table width=\"678\" cellpadding=\"0\" cellspacing=\"0\" style=\"padding: 20px; font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080; border: 1px solid #d7d9e0;\">"
											+ "<tr>"
											+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 20px; font: bold 16px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color: #666666;\">"
											+ formName
											+ "</td>"
											+ "</tr>"
											+ "<tr>"
											+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">");
			
			strHTML.append("<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
					+ "<tr>"
					+ "<th width=\"80\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
							+ "Approval"
					+ "</th>"
					+ "<th width=\"130\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
							+ "Name"
					+ "</th>"
					+ "<th width=\"120\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
							+ "Date"
					+ "</th>"
					+ "<th width=\"80\" valign=\"middle\" bgcolor=\"#f6f6f6\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #666666; border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
							+ "Status"
					+ "</th>"
					+ "<th width=\"226\" bgcolor=\"#f6f6f6\" valign=\"middle\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;line-height: 1.2em; color: #666666; border-bottom: 1px solid #b1b1b1;\">"
							+ "Comment"
					+ "</th>"
					+ "</tr>");
			
			// 결재선 반복문
			CoviList htmlResult = mailMessageApvLineParsing(apvLine);
			for(Object htmlObj : htmlResult){
				CoviMap apvObj = (CoviMap) htmlObj;
				
				strHTML.append("<tr>"
						+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
								+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
								+ "§"+apvObj.getString("KIND")+"§"
								+ "</span>"
						+ "</td>"
						+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
								+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
								+ ((apvObj.optString("NAME").equals("")) ? "§GR@@"+apvObj.getString("OUNAME")+"§" : "§UR@@"+apvObj.getString("NAME")+"§" + "(§GR@@"+apvObj.getString("OUNAME")+"§)")
								+ "</span>"
						+ "</td>"
						+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
								+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
								+ (apvObj.optString("DATE").equals("") ? "-" : apvObj.getString("DATE"))
								+ "</span>"
						+ "</td>"
						+ "<td height=\"30\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"center\" style=\"border-right: 1px solid #b1b1b1; border-bottom: 1px solid #b1b1b1;\">"
								+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
								+ (apvObj.optString("STATUS").equals("") ? "-" : "§"+apvObj.getString("STATUS")+"§")
	                            + "</span>"
	                    + "</td>"
	                    + "<td bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"padding: 0 10px; border-bottom: 1px solid #b1b1b1;\">"
	                    		+ "<span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #808080;\">"
	                    		+ (apvObj.optString("COMMENT").equals("") ? "-" : apvObj.getString("COMMENT"))
	                    		+ "</span>"
	                    + "</td>"
	                    + "</tr>");
				dicList.add(apvObj.optString("KIND"));
				dicList.add(apvObj.optString("STATUS"));
				nameList.add("UR@@"+apvObj.optString("NAME"));
				ouNameList.add("GR@@"+apvObj.optString("OUNAME"));
			}  
			
			strHTML.append("</table></td></tr>"
					+ "<tr>"
					+ "<td align=\"center\" valign=\"top\" style=\"padding-top: 10px;font-size:12px;\">"
							+ "<table width=\"636\" cellpadding=\"0\" cellspacing=\"0\" style=\"border: 1px solid #b1b1b1;\">"
									+ "<tr>"
									+ "<th width=\"100\" height=\"30\" valign=\"middle\" bgcolor=\"#f6f6f6\" align=\"left\" style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif;color: #666666; padding-left: 12px; border-right: 1px solid #b1b1b1;\">"
											+ "Title"
									+ "</th>"
									+ "<td width=\"536\" bgcolor=\"#ffffff\" valign=\"middle\" align=\"left\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #808080; padding: 0 10px;\">");
									if(!status.equals("WITHDRAW") && !status.equals("ABORT")) {
											strHTML.append("<a href=\"" 
													+ MessageHelper.getInstance().replaceLinkUrl(domainId, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false) + "/covicore/admin/messaging/moveToLink.do?GotoURL="+URLEncoder.encode(url, "UTF-8")+"&MobileURL="+URLEncoder.encode(mobileURL, "UTF-8")+"&ServiceType=Approval"
													+ "\" style=\"cursor: pointer;\" target=\"_blank\" rel=\"noreferrer\">"
											+ subject	// TODO SUBJECT : 양식 제목
											+ "</a>");
									} else {
										strHTML.append(subject);
									}
									
									strHTML.append("</td>"
									+ "</tr>"
							+ "</table>"
					+ "</td>"
					+ "</tr>"
					+ "</table></td></tr>");
		}
		
		strHTML.append("</table></body></html>");
		// status 와 다국어키 맵핑이 다름
		//dicList.add("ApprovalAlarm_"+status);
		//dicList.add("ApprovalAlarm_"+status+"_desc");
		setAlarmKeys(dicList, strHTML);
		dicList.add(formName);
		
		CoviMap dicMap = new CoviMap(); 
		CoviMap dicParams = new CoviMap(); 
		String[] dicArr = (String[]) dicList.toArray(new String[0]);
		String[] userArr = (String[]) nameList.toArray(new String[0]);
		String[] groupArr = (String[]) ouNameList.toArray(new String[0]);
		dicParams.put("dicArr", dicArr);
		dicParams.put("userArr", userArr);
		dicParams.put("groupArr", groupArr);
		 
		dicMap = messageSvc.getDicInfo(dicParams);
		  
		paramMapObjDic.put("ReservedStr4", CoviMap.toJSONString(dicMap));
		
		return strHTML.toString();
	}
	
	/**
	 * 본문에서 치환할 Alarm 관련 다국어 키추출
	 * @param disList
	 * @param strHTML
	 */
	@SuppressWarnings("unchecked")
	private void setAlarmKeys(CoviList disList, StringBuilder strHTML) {
		String regex = "§ApprovalAlarm(.*?)§";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(strHTML);
        while (matcher.find()) {
            String findStr = matcher.group();
            findStr = StringUtils.replace(findStr, "§", "");
            if(!disList.contains(findStr)) {
            	disList.add(findStr);
            }
        }
	}
}
