package egovframework.coviaccount.user.service.impl;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import javax.annotation.Resource;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.user.service.AccountDelaySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.logging.LoggerHelper;

@Service("AccountDelaySvc")
public class AccountDelaySvcImpl extends EgovAbstractServiceImpl implements AccountDelaySvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private MessageService messageSvc;
	
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	
	@Override
	public CoviMap getSendFlag(CoviMap params) throws Exception {

		return coviMapperOne.selectOne("account.delay.getSendFlag",	params);
	}
	
	/**
	 * @Method Name : doDelayAlam
	 * @Description : 계정관리 목록 조회
	 */
	@Override
	public CoviMap doDelayAlam(CoviMap reqParams) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/account/layout/account_TaxInvoice.do?CLSYS=account&CLMD=user&CLBIZ=Accoun";

		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
        params.put("MsgType", "EAccountingDelay");
        params.put("IsUse", "Y");
        params.put("IsDelay", "N");
        params.put("ApprovalState", "P");
        params.put("XSLPath", "");
//         params.put("Width", "");
//         params.put("Height", "");
        params.put("PopupURL", sURL);
        params.put("GotoURL", sURL);
        params.put("MobileURL", "");
        params.put("OpenType", "");
        params.put("MessageContext", "");
        params.put("ReservedStr1", "");
        params.put("ReservedStr2", "");
        params.put("ReservedStr3", "");
        params.put("ReservedStr4", "");
         
        String mailSubject = "";
        String receiversCode = "";
        String senderCode = reqParams.get("senderCode") == null ?"superadmin":reqParams.getString("senderCode");
        CoviList list			= null;
 		StringBuffer receiverText = new StringBuffer("");
 		int msgCnt = 0;
 		int sendCnt = 0;
 		
 		// 상신 알림 일자 Validation 체크
		String accountDelayStartDay = chkDate(reqParams.getString("accountDelayStartDay"), true);
        String accountDelayEndDay = chkDate(reqParams.getString("accountDelayEndDay"), false);
        reqParams.put("accountDelayStartDay", accountDelayStartDay);
        reqParams.put("accountDelayEndDay", accountDelayEndDay);
		
 		//미정산 법인카드
        if (reqParams.get("SendType") == null || reqParams.getString("SendType").equals("Card")){
        	list = coviMapperOne.list("account.delay.getCardReceiptDelayList", reqParams);
	 		receiversCode = "";
			mailSubject =  "[법인카드-정산지연]"+(String)reqParams.get("accountDelayMessage");//"[법인카드-정산지연]미정산 내역 총 @@CNT@@건 입니다";//+newObject.getString("ApproveDate")+" "+newObject.getString("ApproveTime") + " " + newObject.getString("StoreName")  ;
			for (int i =0 ; i < list.size(); i++)
			{
				CoviMap newObject = (CoviMap)list.get(i);
				if (!receiversCode.equals("") && !receiversCode.equals(newObject.getString("CardUserCode")))
				{
					String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
					insertMessageData(params, senderCode, receiversCode, messagingSubject, receiverText.toString(), msgCnt);
					sendCnt++;
					
					receiverText = new StringBuffer("");
					msgCnt = 0;
				}
				receiversCode = newObject.getString("CardUserCode");
				msgCnt++;
				receiverText.append("<tr style='height:30px; font-size:12px;'><td   style='text-align:center;'>"+newObject.getString("ApproveDate")+" "+newObject.getString("ApproveTime")+"</td>"+
							"<td>"+newObject.getString("StoreName")+"</td>"+
							"<td  style='text-align:right;'>"+newObject.getString("AmountWon")+"</td></tr>");
			}
			
			if (msgCnt > 0){
				String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
				insertMessageData(params,  senderCode, receiversCode, messagingSubject,receiverText.toString(), msgCnt);
				sendCnt++;
			}	
        }	
		
		//미정산 세금계산서 
        if (reqParams.get("SendType") == null || reqParams.getString("SendType").equals("Tax")){
			mailSubject =  "[세금계산서-정산지연]"+(String)reqParams.get("accountDelayMessage");//+newObject.getString("ApproveDate")+" "+newObject.getString("ApproveTime") + " " + newObject.getString("StoreName")  ;
			list	= coviMapperOne.list("account.delay.getTaxInvoiceDelayList", reqParams);
			receiversCode= "";
	 		receiverText = new StringBuffer("");
	 		msgCnt = 0;
			for (int i =0 ; i < list.size(); i++)
			{
				CoviMap newObject = (CoviMap)list.get(i);
				if (!receiversCode.equals("") && !receiversCode.equals(newObject.getString("ManagerUserCode")))
				{
					String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
					insertMessageData(params, senderCode, receiversCode, messagingSubject, receiverText.toString(), msgCnt);
					sendCnt++;
					
					receiverText = new StringBuffer("");
					msgCnt = 0;
				}
				receiversCode = newObject.getString("ManagerUserCode");
				msgCnt++;
				receiverText.append("<tr style='height:30px; font-size:12px;'><td  style='text-align:center;'>"+newObject.getString("WriteDate")+"</td>"+
						"<td>"+newObject.getString("InvoicerCorpName")+"</td>"+
						"<td>"+newObject.getString("ItemName")+"</td>"+
						"<td style='text-align:right'>"+newObject.getString("TotalAmount")+"</td></tr>");
			}
			
			if (msgCnt > 0){
				String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
				insertMessageData(params, senderCode, receiversCode, messagingSubject,receiverText.toString(), msgCnt);
				sendCnt++;
			}	
        }	
		resultList.put("sendCnt", 		sendCnt);
		resultList.put("sendDateRange", accountDelayStartDay+" ~ "+accountDelayEndDay);
		return resultList; 
	}
	
	private String chkDate(String date, boolean firstDay) {
		String result = date;
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		Calendar calendar = Calendar.getInstance();
		
		try {
			//올바른 형식의 날짜인지 체크
			dateFormat.setLenient(false);
			Date dDate = dateFormat.parse(date);
			
		} catch(ParseException pe) {
			//올바른 날짜가 아니면 해당 월의 시작, 마지막 일자로 변경
			String[] arrDate = date.split("-");
			
			calendar.set(Integer.parseInt(arrDate[0]), Integer.parseInt(arrDate[1])-1, 1);
			arrDate[2] = firstDay ? "01" : Integer.toString(calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
			
			result = String.join("-", arrDate);
		}
		
		return result;
	}
	
	/**
	 * @Method Name : doManualDelayAlam
	 * @Description : 미상신내역 알림발송(미상신내역관리 메뉴)
	 */
	@Override
	public CoviMap doManualDelayAlam(CoviMap dataList, String sendMailType) throws Exception {
		CoviList list = null;
		CoviMap param = new CoviMap();
		CoviMap resultList	= new CoviMap();
 		StringBuffer receiverText = null;
 		
 		int msgCnt = 0;
 		int sendCnt = 0;
 		
		String receiversCode = "";
		String mailSubject = "";
		String taxinvoiceList = "";
		String delayMessage = RedisDataUtil.getBaseConfig("AccountDelayMessage");
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/account/layout/account_TaxInvoice.do?CLSYS=account&CLMD=user&CLBIZ=Accoun";
		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
        params.put("MsgType", "EAccountingDelay");
        params.put("IsUse", "Y");
        params.put("IsDelay", "N");
        params.put("ApprovalState", "P");
        params.put("XSLPath", "");
        params.put("PopupURL", sURL);
        params.put("GotoURL", sURL);
        params.put("MobileURL", "");
        params.put("OpenType", "");
        params.put("MessageContext", "");
        params.put("ReservedStr1", "");
        params.put("ReservedStr2", "");
        params.put("ReservedStr3", "");
        params.put("ReservedStr4", "");
		
		CoviList chkList = (CoviList) AccountUtil.jobjGetObj(dataList,"chkList");
		if(chkList != null){
			for(int i = 0; i<chkList.size(); i++){
				CoviMap item =  chkList.getJSONObject(i);
				taxinvoiceList = makeIDListPlainStr(taxinvoiceList, AccountUtil.jobjGetStr(item, "TaxInvoiceID" ));	
			}
		}
		
		//taxinvoiceID로 대상데이터 추출
		if(taxinvoiceList != null && !taxinvoiceList.equals("")) param.put("taxinvoiceID", taxinvoiceList.split(","));
		param.put("sendMailType", sendMailType);
		list = coviMapperOne.list("account.delay.selectTaxDelayList", param);
		
		if(list.size() > 0) {
			mailSubject =  "[세금계산서-정산지연]"+delayMessage;
			receiversCode= "";
	 		receiverText = new StringBuffer("");
	 		msgCnt = 0;
	 		
	 		String managerInfo = RedisDataUtil.getBaseConfig("SendDelayManagerInfo");
	 		String senderCode = managerInfo.split(";")[0];
	 		String senderMail = managerInfo.split(";")[1];
	 		
			for (int i =0 ; i < list.size(); i++)
			{
				CoviMap newObject = (CoviMap)list.get(i);
				if (!receiversCode.equals("") && !receiversCode.equals(newObject.getString("ReceiversCode")))
				{
					String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
					if("invoice".equals(sendMailType)) {	//공급받는 자 메일 발송
						LoggerHelper.auditLogger(SessionHelper.getSession("UR_Code"), "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", SessionHelper.getSession("DN_ID")), setMailForm(receiverText.toString(),msgCnt), "ExternalMailAddress");
						MessageHelper.getInstance().sendSMTP("관리자", senderMail, receiversCode , messagingSubject, setMailForm(receiverText.toString(),msgCnt), true);
					}else {
						insertMessageData(params, senderCode, receiversCode, messagingSubject, receiverText.toString(), msgCnt);	
					}
					
					sendCnt++;
					
					receiverText = new StringBuffer("");
					msgCnt = 0;
				}
				receiversCode = newObject.getString("ReceiversCode");
				msgCnt++;
				receiverText.append("<tr style='height:30px; font-size:12px;'><td  style='text-align:center;'>"+newObject.getString("WriteDate")+"</td>"+
						"<td>"+newObject.getString("InvoicerCorpName")+"</td>"+
						"<td style='text-align:right'>"+newObject.getString("TotalAmount")+"</td></tr>");
				
			}
			
			if (msgCnt > 0){
				String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
				if("invoice".equals(sendMailType)) {	//공급받는 자 메일 발송
					LoggerHelper.auditLogger(SessionHelper.getSession("UR_Code"), "S", "SMTP", RedisDataUtil.getBaseConfig("SmtpServer", SessionHelper.getSession("DN_ID")), setMailForm(receiverText.toString(),msgCnt), "ExternalMailAddress");
					MessageHelper.getInstance().sendSMTP("관리자", senderMail, receiversCode , messagingSubject, setMailForm(receiverText.toString(),msgCnt), true);
				}else {
					insertMessageData(params, senderCode, receiversCode, messagingSubject,receiverText.toString(), msgCnt);
				}
				sendCnt++;
			}
		}
		
		resultList.put("sendCnt", 		sendCnt);
		return resultList; 
	}

	/**
	 * @Method Name : doManualDelayAlam
	 * @Description : 미상신내역 알림발송(미상신내역관리 메뉴)
	 */
	@Override
	public CoviMap doManualDelayAlamCorpCard(CoviMap dataList, String sendMailType) throws Exception {
		CoviList list = null;
		CoviList listReturn = null;
		
		CoviMap resultList	= new CoviMap();
 		StringBuffer receiverText = null;
 		
 		int msgCnt = 0;
 		int sendCnt = 0;
 		
		String receiversCode = "";
		String mailSubject = "";
		String senderCode = "";
		
		String managerInfo = RedisDataUtil.getBaseConfig("SendDelayManagerInfo");
 		String chkStr = managerInfo.split(";")[0];
 		senderCode = (chkStr == null || chkStr.equals("")) ? "superadmin":chkStr;
	
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/account/layout/account_TaxInvoice.do?CLSYS=account&CLMD=user&CLBIZ=Accoun";
		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
        params.put("MsgType", "EAccountingDelay");
        params.put("IsUse", "Y");
        params.put("IsDelay", "N");
        params.put("ApprovalState", "P");
        params.put("XSLPath", "");
        params.put("PopupURL", sURL);
        params.put("GotoURL", sURL);
        params.put("MobileURL", "");
        params.put("OpenType", "");
        params.put("MessageContext", "");
        params.put("ReservedStr1", "");
        params.put("ReservedStr2", "");
        params.put("ReservedStr3", "");
        params.put("ReservedStr4", "");
        params.put("approveDateS",AccountUtil.jobjGetObj(dataList,"approveDateS"));
        params.put("approveDateE",AccountUtil.jobjGetObj(dataList,"approveDateE"));
        //
        List<CoviMap> returnTempList;
		CoviList chkList = (CoviList) AccountUtil.jobjGetObj(dataList,"chkList");
		if(chkList != null){
			// 불출자쪽 로직은 많이 다르다.
			if(sendMailType.equals("Return") ) {
				// 우선 동일하게 선택한 애들을 가지고 for문 돌고 
				for(int i = 0; i<chkList.size(); i++){
					CoviMap item =  chkList.getJSONObject(i);
					params.put("CardNo", AccountUtil.jobjGetStr(item, "CardNo" ));
					
					// 카드번호와 기간으로 카드 불출자별
					// 사용자별로 있는 리스트
					list = coviMapperOne.list("account.delay.selectCorpCardDelayReturnList", params);
					
					// 카드내역 전체
					listReturn = coviMapperOne.list("account.delay.selectCorpCardDelayReturnAllList", params);
					returnTempList = (List<CoviMap>)listReturn;
					// ttcnt = temList.stream().filter( u-> u.get("AmountWon").toString().equals("110000") ).count();
//					AmountWon
//					System.out.println();
//					temList.stream().filter(oo-> oo.containsKey(""));
//					List<CoviMap> temList = (ArrayList)listReturn;
					
					List<CoviMap> list2;
					
					if(list.size() > 0) {
						for (int j =0 ; j < list.size(); j++)
						{
							// 불출자별로 테이블에서 for문 돌면서 전체카드내역을 찾아서 같은 불출아이디로 된거만 새로 저장한다.
							CoviMap newObjectJ = (CoviMap)list.get(j);
							// 람다 표현식 사용 시 jdk 1.8 이상 사용 필요
							list2  = returnTempList.stream().filter(u-> u.get("ReleaseUserCode").toString().equals(newObjectJ.getString("ReleaseUserCode"))).collect(Collectors.toList());
							
							msgCnt =  Integer.parseInt(newObjectJ.getString("Cnt"));
							receiversCode = newObjectJ.getString("ReleaseUserCode");
							
							// 새로만든 리스트를 for문 돌린다.
							if(list2.size() >0) {
								// 제목 넣어두고
								mailSubject =  "\"[법인카드-정산지연]미정산 내역 총 @@CNT@@건 입니다\""; //"[법인카드-정산지연]미정산 내역 총 @@CNT@@건 입니다";
								receiverText = new StringBuffer("");
								
								for(int y=0; y<list2.size(); y++) {
									CoviMap newObjectY = (CoviMap)list.get(j);
									// 아래가 Detail 부분의 Html 이고 
									receiverText.append("<tr style='height:30px; font-size:12px;'><td   style='text-align:center;'>"+newObjectY.getString("ApproveDate")+" "+newObjectY.getString("ApproveTime")+"</td>"+
											"<td>"+newObjectY.getString("StoreName")+"</td>"+
											"<td  style='text-align:right;'>"+newObjectY.getString("AmountWon")+"</td></tr>");				
								}
								String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
								insertMessageData(params, senderCode, receiversCode, messagingSubject, receiverText.toString(), msgCnt);
								sendCnt++;		
							}
						}
					}
				}
				
			} else {
				for(int i = 0; i<chkList.size(); i++){
					CoviMap item =  chkList.getJSONObject(i);
					
					// 소유자 조회자 나눠서
					if(sendMailType.equals("Owner")) {
						receiversCode =  AccountUtil.jobjGetStr(item, "OwnerUser" ).split(",")[0];				
					} else if(sendMailType.equals("Search")) {
						// 조회자면 데이터 가공해서 UR_Code, UR_Code 로 만든다
						receiversCode =  makeSearchUserCode(AccountUtil.jobjGetStr(item, "SearchUser" ));						
					}
					
					params.put("CardNo", AccountUtil.jobjGetStr(item, "CardNo" ));
					params.put("receiversCode", receiversCode);	
					params.put("sendMailType", sendMailType);
					
					msgCnt = Integer.parseInt(AccountUtil.jobjGetStr(item, "CNT" ));
					
					// DB에서 카드번호로 데이터 쭈욱 가져오고 가져온 데이터로 Html ㄹfor문 돌면서 html 만든다.
					list = coviMapperOne.list("account.delay.selectCorpCardDelayList", params);
					if(list.size() > 0) {
						// 제목 넣어두고
						mailSubject =  "\"[법인카드-정산지연]미정산 내역 총 @@CNT@@건 입니다\""; //"[법인카드-정산지연]미정산 내역 총 @@CNT@@건 입니다";
						receiverText = new StringBuffer("");
						
						for (int j =0 ; j < list.size(); j++)
						{
							CoviMap newObject = (CoviMap)list.get(j);
							// 아래가 Detail 부분의 Html 이고 
							receiverText.append("<tr style='height:30px; font-size:12px;'><td   style='text-align:center;'>"+newObject.getString("ApproveDate")+" "+newObject.getString("ApproveTime")+"</td>"+
									"<td>"+newObject.getString("StoreName")+"</td>"+
									"<td  style='text-align:right;'>"+newObject.getString("AmountWon")+"</td></tr>");						
						}
						String messagingSubject = mailSubject.replace("@@CNT@@", String.valueOf(msgCnt));
						insertMessageData(params, senderCode, receiversCode, messagingSubject, receiverText.toString(), msgCnt);
						sendCnt++;				
					}
				}
			}
			
		}		
		resultList.put("sendCnt", 		sendCnt);
		return resultList; 
	}
	
	private void insertMessageData(CoviMap params, String senderCode,  String receiversCode, String messagingSubject,String receiverText, int msgCnt) throws Exception {
		//receiversCode="superadmin";
        params.put("SenderCode", senderCode);
        params.put("RegistererCode", senderCode);
		params.put("ReceiversCode",receiversCode);//수신자
		
        params.put("MessagingSubject", messagingSubject);
        params.put("ReceiverText", messagingSubject);
        params.put("MessageContext", setMailForm(receiverText, msgCnt));
        messageSvc.insertMessagingData(params);

	}
	
	private String setMailForm(String detailHTML, int msgCnt){
		StringBuffer sbHTML = new StringBuffer();
		sbHTML.append("<html xmlns='http://www.w3.org/1999/xhtml'>");
		sbHTML.append("<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' />");
		sbHTML.append("</head>");
		sbHTML.append("<div style='border:1px solid #c9c9c9; width:1000px; padding-bottom:10px;'>");
		sbHTML.append("<div style='width:100%; height: 50px; background-color : #2b2e34; font-weight:bold; font-size:16px; color:white; line-height:50px; padding-left:20px; box-sizing:border-box;'>");
		sbHTML.append("	CoviSmart² - 정산지연 ["+String.valueOf(msgCnt)+"건]");
		sbHTML.append("</div>");
		sbHTML.append("<div style='padding: 10px 10px; max-width: 1000px; font-size:13px;'>");
		sbHTML.append("</div>");

		sbHTML.append("<div style='padding: 0px 10px; max-width: 1000px;' id='divContextWrap'>");
		
		sbHTML.append("<div style='width:100%; min-height:70px; margin-bottom : 10px;'>");
		sbHTML.append("<div>");
		sbHTML.append("<table style='width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:12px;' border='1' id='tbTimeSheet'>");
		sbHTML.append("<tbody>");
		// Header
		sbHTML.append("<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>");
		sbHTML.append("<td width='150'>사용일시</td>");
		sbHTML.append("<td width='200'>가맹점명</td>");
		sbHTML.append("<td width='250'>품목명</td>");
		sbHTML.append("<td width='150'>금액</td>");
		sbHTML.append("</tr>");
		sbHTML.append(detailHTML);
		sbHTML.append("</tbody>");
		sbHTML.append("</table>");
		sbHTML.append("</div>");
		sbHTML.append("</div>");
		sbHTML.append("</div>");
		return sbHTML.toString();
	}

	public String makeIDListStr(String list, String inputID) throws Exception {
		String ret="";
		if(list != null){
			ret = list;
		}
		if(inputID != null){
			if("".equals(list)){
				ret = "'" + inputID + "'";
			}else{
				ret = ret + ",'" + inputID + "'";
			}
		}
		return ret;
	}
	
	public String makeIDListPlainStr(String list, String inputID) throws Exception {
		String ret="";
		if(list != null){
			ret = list;
		}
		if(inputID != null){
			if("".equals(list)){
				ret = inputID;
			}else{
				ret = ret + "," + inputID;
			}
		}
		return ret;
	}
	
	private String makeSearchUserCode(String SearchUser) throws Exception {
		StringBuilder rslt = new StringBuilder();
		String[] arrStepOne = SearchUser.split("n%");
		for(int i=0; i<arrStepOne.length; i++) {
			//rslt += arrStepOne[i].split(",")[0] +";";
			if(rslt.length() > 0) {
				rslt.append(";");
			}
			rslt.append(arrStepOne[i].split(",")[0]);
		}
		//rslt = rslt.substring(0,rslt.length()-1);
		return rslt.toString();
	}

	
}
