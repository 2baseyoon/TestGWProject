package egovframework.covision.coviflow.govdocs.record;

import java.net.URLEncoder;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.manager.RecordProductMgr;
import egovframework.covision.coviflow.govdocs.record.manager.RecordTransferMgr;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.legacy.service.MessageSvc;

public class ExecRecordRunnable implements Runnable{
	private static final Object LOCK = new Object();
	private Logger LOGGER = LogManager.getLogger(ExecRecordRunnable.class);
	
	private GovRecordSyncSvc govRecordSyncSvc;
	private MessageSvc messageSvc;
	private CoviMap reqParams;
	private String workDiv;
	private String userID;
	
	public ExecRecordRunnable(GovRecordSyncSvc govRecordSyncSvc, MessageSvc messageSvc, CoviMap reqParams, String workDiv, String userID){
		this.govRecordSyncSvc = govRecordSyncSvc;
		this.messageSvc = messageSvc;
		this.reqParams = reqParams;
		this.workDiv = workDiv;
		this.userID = userID;
	}
	
	@Override
	public void run() {
		synchronized (LOCK) {
			LOGGER.info("Running ......");
			String result = "99999";
			
			try{
				
				AuthHandler auth = new AuthHandler();
				auth.conStatusLog(); //@ 주석처리
				
				if(null != reqParams){
					String mode = (String) reqParams.get("mode");
					String endYear = (String) reqParams.get("endYear");
					String recordDeptCode = (String) reqParams.get("recordDeptCode");
					String[] recordClassNumArr = (String[]) reqParams.get("recordClassNumArr");
					auth.loginApi();
					
					AbstractRecordManager rif = null;
					if("PRODUCT".equals(workDiv)){
						rif = new RecordProductMgr(govRecordSyncSvc, auth);
					} else {
						rif = new RecordTransferMgr(govRecordSyncSvc, auth);
					}
						
					if("ALL".equals(mode)){
						result = rif.executeSendFile(endYear, recordDeptCode, "", recordClassNumArr);
						if("00000".equals(result)){
							sendMail(userID, "RecordFile_Complete", workDiv, recordDeptCode, "작업이 완료되었습니다.", "", "");
						} else {
							sendMail(userID, "RecordFile_Error", workDiv, recordDeptCode, "작업 중 오류가 발생하였습니다.", result, auth.getErrorContent(result));
						}
					} else {
						for(int i = 0; i < recordClassNumArr.length; i++){
							result = rif.executeSendFile(endYear, "", recordClassNumArr[i], null);
							try{
								Thread.sleep(1000);
							} catch(ArrayIndexOutOfBoundsException aioobE){
								 LOGGER.debug(aioobE);
							} catch(Exception e){
								 LOGGER.debug(e);
							}
							
							if(!"00000".equals(result)){
								sendMail(userID, "RecordFile_Error", workDiv, recordClassNumArr[i], "작업 중 오류가 발생하였습니다.", result, auth.getErrorContent(result));
							} else {
								sendMail(userID, "RecordFile_Complete", workDiv, recordClassNumArr[i], "작업이 완료되었습니다.", "", "");
							}
						}
					}
					
				}
				
			} catch (NullPointerException npE){
				LOGGER.error(npE.getMessage(), npE);
				sendMail(userID, "RecordFile_Complete", workDiv, "", "작업 중 오류가 발생하였습니다.", "99999", "내부 시스템 오류가 발생하였습니다. 관리자에게 문의하세요.");
			} catch (Exception e){
				LOGGER.error(e.getMessage(), e);
				sendMail(userID, "RecordFile_Complete", workDiv, "", "작업 중 오류가 발생하였습니다.", "99999", "내부 시스템 오류가 발생하였습니다. 관리자에게 문의하세요.");
			}
			LOGGER.info("Stopping ......");
		}
	}
	
	
	private void sendMail(String userID, String msgType, String pServiceName, String pMsgType, String pDesc, String pErrorCode, String pErrorContext){
		
		StringBuilder receiversCodes = new StringBuilder(userID); 
		
		try {
			String pGotoURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/approval/layout/approval_RecordKeepFileList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval";
			String pMobileURL = "";
			
			if("RecordFile_Error".equals(msgType)){
				CoviList mailList = govRecordSyncSvc.selectSendMailList();
				if(!mailList.isEmpty()){
					for(int i = 0; i < mailList.size(); i++){
						CoviMap map = mailList.getMap(i);
						if(!userID.equals(map.get("CODE"))){
							receiversCodes.append(";"+(String)map.get("CODE"));
						}
					}
				}
			}
			
			//1. parameter 처리
			CoviMap paramMapObj = new CoviMap();
			paramMapObj.put("ServiceType", "RecordFile");
			paramMapObj.put("MsgType", msgType);
			paramMapObj.put("ReceiversCode", receiversCodes.toString());			
			paramMapObj.put("MessagingSubject", "작업(현황보고/이관)결과를 알려드립니다.");
			if("PRODUCT".equals(pServiceName)){
				pServiceName = "현황보고 결과 알림(Report Result Notification)";
			} else {
				pServiceName = "이관 결과 알림(Transfer Result Notification)";
			}
			paramMapObj.put("MessageContext", createMessageContext(pServiceName, pMsgType, pDesc, pErrorCode, pErrorContext, pGotoURL, pMobileURL, "MAIL"));
			paramMapObj.put("SenderCode", userID);
			paramMapObj.put("MediaType", "MAIL");
			
			messageSvc.callMessagingProcedure(paramMapObj);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), e);
		}
	}

	private String createMessageContext(String pServiceName, String pMsgType, String pDesc, String pErrorCode, String pErrorContext, String pGotoURL, String pMobileURL, String pServiceType) throws Exception
	{
	
		StringBuilder sb = new StringBuilder("<html xmlns=\"http://www.w3.org/1999/xhtml\">");
		sb.append("<head>");
		sb.append("    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
		sb.append("</head>");
		sb.append("<body>");
		sb.append("    <table width=\"100%\" bgcolor=\"#ffffff\" cellpadding=\"0\" cellspacing=\"0\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.2em; color: #444; margin: 0; padding: 0\">");
		sb.append("        <tbody>");
		sb.append("            <tr>");
		sb.append("                <td height=\"40\" valign=\"middle\" style=\"padding-left: 26px\" bgcolor=\"#2b2e34\">");
		sb.append("                    <table width=\"90%\" height=\"50\" cellpadding=\"0\" cellspacing=\"0\" style=\"background: no-repeat top left\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td style=\"font: bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color: #fff\">%s</td>", pServiceName));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td bgcolor=\"#ffffff\" style=\"padding: 20px; border-left: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4\">");
		sb.append("                    <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"padding: 17px 0 5px 20px\"><span style=\"font: bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">처리부서or분류번호 [%s]</span></td>", pMsgType));
		sb.append("                            </tr>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; padding: 0 0 15px 20px; color: #444\">%s</td>", pDesc));
		sb.append("                            </tr>");
		if(null != pErrorCode && !"".equals(pErrorCode)){
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"padding: 17px 0 5px 20px\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">오류코드(Error Code) [%s]</span></td>", pErrorCode));
			sb.append("                            </tr>");
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; padding: 0 0 15px 20px; color: #444\">오류내용(Error Context) %s</td>", pErrorContext));
			sb.append("                            </tr>");
		}
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td height=\"109\" bgcolor=\"\" align=\"center\" valign=\"middle\" style=\"border: 1px solid #d4d4d4; border-top: 0\">");
		sb.append("                    <table cellpadding=\"0\" cellspacing=\"0\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td height=\"32\" align=\"center\"><span style=\"font: normal 12px dotum,'돋움'; color: #444444\">%s</span></td>", "KICS 에 접속하시어 확인해주시기 바랍니다."));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                    <table width=\"140\" cellpadding=\"0\" cellspacing=\"0\" bgcolor=\"#2f91e3\" style=\"cursor: pointer\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td align=\"center\" height=\"36\" style=\"cursor: pointer\"><a style=\"display: block; cursor: pointer; text-decoration: none\" href=\"%s\" target=\"_blank\" rel=\"noreferrer\"><span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration: none; color: #ffffff\"><strong>%s</strong></span></a></td>" 
					, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/covicore/admin/messaging/moveToLink.do?GotoURL=" + URLEncoder.encode(pGotoURL, "UTF-8") + "&MobileURL=" + URLEncoder.encode(pMobileURL, "UTF-8") + "&ServiceType=" + pServiceType
					, "그룹웨어 바로가기"));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("        </tbody>");
		sb.append("    </table>");
		sb.append("</body>");
		sb.append("</html>");
		
		return sb.toString();
	}
}
