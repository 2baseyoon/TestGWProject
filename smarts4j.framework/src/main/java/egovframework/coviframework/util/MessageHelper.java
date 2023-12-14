package egovframework.coviframework.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Objects;

import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.baseframework.base.StaticContextAccessor;

public class MessageHelper {
	
	private static Logger LOGGER = LogManager.getLogger(MessageHelper.class);
	private static String SMTP_CHARSET = "UTF-8";
	private static String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
	
	private static class MessageHolder{
		private static final MessageHelper INSTANCE = new MessageHelper();
	}
	
	public static MessageHelper getInstance () {
		return MessageHolder.INSTANCE;
	}

	public static String replaceLinkUrl(String domainId, String  sUrl, boolean isMobile){
		if (isSaaS.equalsIgnoreCase("Y") && !domainId.equals("0")){
			if (isMobile){
				if (RedisDataUtil.getBaseConfig("MobileGWServerURL",domainId) != null && !RedisDataUtil.getBaseConfig("MobileGWServerURL",domainId).equals("")){
					return  sUrl.replace( PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path"),RedisDataUtil.getBaseConfig("MobileGWServerURL",domainId));
				}
				else{
					return sUrl;
				}	
			}
			else 
				if (RedisDataUtil.getBaseConfig("PCGWServerURL",domainId) != null && !RedisDataUtil.getBaseConfig("PCGWServerURL",domainId).equals("")){
					return  sUrl.replace( PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),RedisDataUtil.getBaseConfig("PCGWServerURL",domainId));
				}
				else{
					return sUrl;
				}	
		}
		else 
			return sUrl;
	}
	
	/**
	 * SMTP 발송처리
	 * @param pSenderName
	 * @param pSenderEmail
	 * @param pReceiverEmail
	 * @param pSubject
	 * @param pMessage
	 * @param isHtml
	 * @return
	 */
	public boolean sendSMTP(String pSenderName, String pSenderEmail, String pReceiverEmail, String pSubject, String pMessage, boolean isHtml){
		try {
			// 발신자 설정
	    	StringUtil func = new StringUtil();
			SimpleEmail email  = new SimpleEmail();
	    	
	    	email.setCharset(SMTP_CHARSET); 
	    	email.setHostName(PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"));
	    	email.setSmtpPort(Integer.parseInt(PropertiesUtil.getExtensionProperties().getProperty("mail.mailSmtpPort")));
	    	
	    	if(func.f_NullCheck(PropertiesUtil.getExtensionProperties().getProperty("mail.mailSuperAdminUseYn")).equals("Y")) {
	    		email.setAuthentication(PropertiesUtil.getExtensionProperties().getProperty("mail.mailSuperAdminId"), PropertiesUtil.getExtensionProperties().getProperty("mail.mailSuperAdminPw"));
	    	}
				
			// 수신자 추가
			if(pReceiverEmail.split(";").length > 1){
				email.addTo(pReceiverEmail.split(";")[0], pReceiverEmail.split(";")[1]);
			}
			else{
				email.addTo(pReceiverEmail, "");
			}
	    	
	    	email.setFrom(pSenderEmail, pSenderName); // 발신자 추가
	    	
	    	email.setSubject(pSubject); // 메일 제목
	    	if(isHtml){
	    		email.setContent(pMessage, "text/html; charset=utf-8");
	    	} else {
	    		email.setContent(pMessage, "text/plain; charset=euc-kr");	
	    	}	    	
	    	//승인메일 정책 무시하고록 설정
	    	email.addHeader("X-IsApproved", "Y");
	    	
	    	email.buildMimeMessage();
	    	email.sendMimeMessage();
	    	
    	} catch (EmailException e) {
    		LOGGER.error(e);
    		return false;
    	}
		return true;		
	}
	
	/**
	 * 알림 개수를 포함한 푸시메시지 발송 처리 
	 * @param userID
	 * @param message
	 * @param badgeCount
	 * @return
	 * @throws IOException 
	 */
	public boolean sendPushByUserID(String userID, String message, String badgeCount) throws IOException{
		URL url;
        HttpURLConnection connection = null;
        OutputStream outputStream = null;
		
		try{
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            String paramData = "userId=" + userID + "&message=" + encodedMessage + "&badge=" + badgeCount;

            url = new URL(RedisDataUtil.getBaseConfig("MDM_ServiceURL_Badge"));
			connection = (HttpURLConnection)url.openConnection();
			connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			connection.setRequestProperty("Accept-Language", "ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4"); // System.Globalization.CultureInfo.CurrentUICulture.ToString()
			connection.setRequestProperty("Accept-Charset", "EUC-KR");
			connection.setRequestMethod("POST");
			connection.setDoOutput(true);
			connection.connect();
			
			outputStream = connection.getOutputStream();
			outputStream.write(paramData.getBytes("EUC-KR"));
			outputStream.flush();
			outputStream.close();
			
			//inputStream = connection.getInputStream();
			int responseCode = connection.getResponseCode();

			if(responseCode == 200) return true;
			else return false;
			
			/*
			if (responseCode == 200) { // 정상 호출
				br = new BufferedReader(new InputStreamReader(inputStream, "EUC-KR"), 8*1024);
			} else {
				// 에러 발생
				// 오류 처리 추가 할 것				
				br = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
			}
			
			String inputLine;
			StringBuffer response = new StringBuffer();
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine);
			}
			br.close();
			
			CoviMap resJson = CoviMap.fromObject(response.toString());
			//System.out.println(response.toString());
			//오류 처리 추가 할 것
			if(resJson.getString("result").equalsIgnoreCase("false")
					||resJson.getString("result").equalsIgnoreCase("error")){
				return false;
			}
			
			return true;
			*/
		} catch(NullPointerException e){	
        	LOGGER.error("MessaegHelper:" + e);
            return false;
        }catch (Exception ex){
        	LOGGER.error("MessaegHelper:" + ex);
            return false;
        } finally {
    		if(outputStream != null) { outputStream.close(); }
    		if(connection != null) { connection.disconnect(); }
        }
	}
	
	/**
	 * 푸시 메시지 발송
	 * @param userID
	 * @param message
	 * @return
	 * @throws IOException 
	 */
	public boolean sendPushByUserID(String userID, String message) throws IOException {
		URL url;
        HttpURLConnection connection = null;
        OutputStream outputStream = null;
        InputStream inputStream = null;
		
		try{
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            String paramData = "userId=" + userID + "&message=" + encodedMessage;

            url = new URL(RedisDataUtil.getBaseConfig("MDM_ServiceURL"));
			connection = (HttpURLConnection)url.openConnection();
			connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			connection.setRequestProperty("Accept-Language", "ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4"); // System.Globalization.CultureInfo.CurrentUICulture.ToString()
			connection.setRequestProperty("Accept-Charset", "EUC-KR");
			connection.setRequestMethod("POST");
			//connection.setConnectTimeout(3000);
			//connection.setReadTimeout(3000);
			connection.setDoOutput(true);
			connection.connect();
			
			outputStream = connection.getOutputStream();
			outputStream.write(paramData.getBytes("EUC-KR"));
			outputStream.flush();
			outputStream.close();
			
			inputStream = connection.getInputStream();
			int responseCode = connection.getResponseCode();
			
			if(responseCode == 200) return true;
			else return false;
		} catch(NullPointerException e){	
        	LOGGER.error("MessaegHelper:" + e);
            return false;
		} catch (Exception ex){
        	LOGGER.error("MessaegHelper:" + ex);
            return false;
        } finally {
    		if(outputStream != null) { outputStream.close(); }
    		if(inputStream != null) { inputStream.close(); }
    		if(connection != null) { connection.disconnect(); }
        }
	}
	
	/**
	 * 알림 메시지 기본 포멧
	 * @param pServiceName
	 * @param pMsgType
	 * @param pDesc
	 * @param pSubject
	 * @param pRegister
	 * @param pRegistDateTime
	 * @param pGotoURL
	 * @return
	 * @throws Exception
	 */
	public String makeDefaultMessageContext(String pServiceName, String pMsgType, String pDesc, String pSubject, String pRegister, String pRegistDateTime, String pGotoURL, String pMobileURL, String pServiceType) throws Exception{
		return makeDefaultMessageContext(pServiceName, pMsgType, pDesc, pSubject, pRegister, pRegistDateTime, pGotoURL, pMobileURL, pServiceType, "0");
	}
	
	public String makeDefaultMessageContext(String pServiceName, String pMsgType, String pDesc, String pSubject, String pRegister, String pRegistDateTime, String pGotoURL, String pMobileURL, String pServiceType, String pDomainId) throws Exception{
		return makeDefaultMessageContext(pServiceName, pMsgType, pDesc, pSubject, pRegister, pRegistDateTime, pGotoURL, pMobileURL, pServiceType, pDomainId, "ko");
	}
	
	public String makeDefaultMessageContext(String pServiceName, String pMsgType, String pDesc, String pSubject, String pRegister, String pRegistDateTime, String pGotoURL, String pMobileURL, String pServiceType, String pDomainId, String lang) throws Exception{
		return makeDefaultMessageContext(pServiceName, pMsgType, pDesc, pSubject, pRegister, pRegistDateTime, pGotoURL, pMobileURL, pServiceType, pDomainId, lang, "", "", "");
	}
	
	public String makeDefaultMessageContext(String pServiceName, String pMsgType, String pDesc, String pSubject, String pRegister, String pRegistDateTime, String pGotoURL, String pMobileURL, String pServiceType, String pDomainId, String lang, String pReCommentName, String pReCommentType, String pParentReComment) throws Exception{
		
		//TODO 다국어 처리
		StringBuffer sb = new StringBuffer("<html xmlns=\"http://www.w3.org/1999/xhtml\">");
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
		sb.append(String.format("                                <td style=\"font: bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color: #fff\">%s - %s</td>", RedisDataUtil.getBaseConfig("ApplicationName"), pServiceName));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td bgcolor=\"#ffffff\" style=\"padding: 20px; border-left: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4\">");
		sb.append("                    <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
		sb.append("                        <tbody>");
		if(pReCommentType != null && !"".equals(pReCommentType)) {
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"padding: 17px 0 5px 20px\"><span style=\"font: 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">[%s]</span></td>", pMsgType));
			sb.append("                            </tr>");
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; padding: 0 0 15px 20px; color: #444\">%s</td>", pParentReComment));
			sb.append("                            </tr>");
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"padding: 17px 0 5px 20px\"><span style=\"font: bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">[%s]</span></td>", pReCommentName));
			sb.append("                            </tr>");
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; padding: 0 0 15px 20px; color: #444\">%s</td>", pDesc));
			sb.append("                            </tr>");
		}else {
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"padding: 17px 0 5px 20px\"><span style=\"font: bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">[%s]</span></td>", pMsgType));
			sb.append("                            </tr>");
			sb.append("                            <tr>");
			sb.append(String.format("                                <td bgcolor=\"#f9f9f9\" valign=\"bottom\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; padding: 0 0 15px 20px; color: #444\">%s</td>", pDesc));
			sb.append("                            </tr>");
		}
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td style=\"padding: 0 0 20px 20px; border-left: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4\">");
		sb.append("                    <div style=\"border-bottom: 2px solid #f9f9f9; margin-right: 20px\">");
		sb.append(String.format("                        <div style=\"font: normal 15px dotum,'돋움', Apple-Gothic,sans-serif; border-bottom: 1px solid #c2c2c2; height: 30px; line-height: 30px\"><strong>%s</strong></div>", DicHelper.getDic("lbl_SummaryInfo",lang)));
		sb.append("                    </div>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr style=\"height: 130px\">");
		sb.append("                <td style=\"padding: 0 20px 20px 20px; border-left: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4\">");
		sb.append("                    <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-top: 1px solid #dddddd\">");
		sb.append("                        <tbody>");
		//sb.append("                            <tr>");
		//sb.append(String.format("                                <th width=\"120\" height=\"20\" valign=\"middle\" align=\"left\" bgcolor=\"#f6f6f6\" style=\"padding: 5px 10px; border-right: 1px solid #dddddd; border-bottom: 1px solid #dddddd\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">%s</span></th>", "게시판명"));
		//sb.append(String.format("                                <td width=\"\" align=\"left\" valign=\"middle\" bgcolor=\"#ffffff\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444; padding: 5px 10px; border-bottom: 1px solid #dddddd\">%s</td>", bizFolderName));
		//sb.append("                            </tr>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <th width=\"120\" height=\"20\" valign=\"middle\" align=\"left\" bgcolor=\"#f6f6f6\" style=\"padding: 5px 10px; border-right: 1px solid #dddddd; border-bottom: 1px solid #dddddd\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">%s</span></th>", DicHelper.getDic("lbl_subject",lang)));
		sb.append(String.format("                                <td width=\"\" align=\"left\" valign=\"middle\" bgcolor=\"#ffffff\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444; padding: 5px 10px; border-bottom: 1px solid #dddddd\">%s</td>", pSubject));
		sb.append("                            </tr>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <th width=\"120\" height=\"20\" valign=\"middle\" align=\"left\" bgcolor=\"#f6f6f6\" style=\"padding: 5px 10px; border-right: 1px solid #dddddd; border-bottom: 1px solid #dddddd\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">%s</span></th>", DicHelper.getDic("lbl_Register",lang)));
		sb.append(String.format("                                <td width=\"\" align=\"left\" valign=\"middle\" bgcolor=\"#ffffff\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444; padding: 5px 10px; border-bottom: 1px solid #dddddd\">%s</td>", pRegister));
		sb.append("                            </tr>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <th width=\"120\" height=\"20\" valign=\"middle\" align=\"left\" bgcolor=\"#f6f6f6\" style=\"padding: 5px 10px; border-right: 1px solid #dddddd; border-bottom: 1px solid #dddddd\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">%s</span></th>", DicHelper.getDic("lbl_RegistDateHour",lang)));
		sb.append(String.format("                                <td width=\"\" align=\"left\" valign=\"middle\" bgcolor=\"#ffffff\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444; padding: 5px 10px; border-bottom: 1px solid #dddddd\">%s</td>", pRegistDateTime));
		sb.append("                            </tr>");
		//sb.append("                            <tr>");
		//sb.append("                                <th width=\"120\" height=\"20\" valign=\"middle\" align=\"left\" bgcolor=\"#f6f6f6\" style=\"padding: 5px 10px; border-right: 1px solid #dddddd; border-bottom: 1px solid #dddddd\"><span style=\"font: bold 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444\">요약</span></th>");
		//sb.append("                                <td width=\"\" align=\"left\" valign=\"middle\" bgcolor=\"#ffffff\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height: 1.5em; color: #444; padding: 5px 10px; border-bottom: 1px solid #dddddd\">[홍길동 - 휴가신청서]건에 대한 [완료] 알림이 도착했습니다.</td>");
		//sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td height=\"109\" bgcolor=\"\" align=\"center\" valign=\"middle\" style=\"border: 1px solid #d4d4d4; border-top: 0\">");
		sb.append("                    <table cellpadding=\"0\" cellspacing=\"0\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td height=\"32\" align=\"center\"><span style=\"font: normal 12px dotum,'돋움'; color: #444444\">%s</span></td>", (DicHelper.getDic("msg_PLZLogOnSmart",lang)).replace("{0}", RedisDataUtil.getBaseConfig("ApplicationName"))));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                    <table width=\"140\" cellpadding=\"0\" cellspacing=\"0\" bgcolor=\"#2f91e3\" style=\"cursor: pointer\">");
		sb.append("                        <tbody>");
		sb.append("                            <tr>");
		sb.append(String.format("                                <td align=\"center\" height=\"36\" style=\"cursor: pointer\"><a style=\"display: block; cursor: pointer; text-decoration: none\" href=\"%s\" target=\"_blank\" rel=\"noreferrer\"><span style=\"font: normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration: none; color: #ffffff\"><strong>%s</strong></span></a></td>" 
				, replaceLinkUrl(pDomainId, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false) + "/covicore/admin/messaging/moveToLink.do?GotoURL=" + URLEncoder.encode(pGotoURL, "UTF-8") + "&MobileURL=" + URLEncoder.encode(pMobileURL, "UTF-8") + "&ServiceType=" + pServiceType
				, DicHelper.getDic("btn_GWShortcut",lang)));
		sb.append("                            </tr>");
		sb.append("                        </tbody>");
		sb.append("                    </table>");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("            <tr>");
		sb.append("                <td height=\"25\" align=\"center\" valign=\"middle\" style=\"font: normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color: #a1a1a1\">");
		sb.append("                    Copyright <span style=\"font-weight: bold; color: #222222\">"+PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.");
		sb.append("                </td>");
		sb.append("            </tr>");
		sb.append("        </tbody>");
		sb.append("    </table>");
		sb.append("</body>");
		sb.append("</html>");
		
		return sb.toString();
	}

	/**
	 * 알림 메시지 parameter 생성
	 * @param params
	 * @throws Exception
	 */
	public void createNotificationParam(CoviMap params) throws Exception{
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
        //String strMessageContext = params.getString("MessageContext");
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
	}
	
	public void insertMessageData(CoviMap params, String senderCode, String receiverCode, String messagingSubject,String receiverText) throws Exception {
		MessageService messageSvc = StaticContextAccessor.getBean(MessageService.class);
        params.put("SenderCode",     senderCode);//발신자
        params.put("RegistererCode", senderCode);//등록자
		params.put("ReceiversCode",  receiverCode);//수신자(;로 구분)
		
        params.put("MessagingSubject", messagingSubject);	//제목
        params.put("ReceiverText",     messagingSubject);	//제목
        params.put("MessageContext",   receiverText);		//메일 발송내용
        
       createNotificationParam(params);
       messageSvc.insertMessagingData(params);
	}	
	
}
