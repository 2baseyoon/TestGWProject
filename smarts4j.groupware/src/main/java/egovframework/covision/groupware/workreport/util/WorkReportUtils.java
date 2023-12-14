package egovframework.covision.groupware.workreport.util;

import java.util.Calendar;

public class WorkReportUtils {
	
	// 넘겨받은 일자 기준 가장 최근 이전 금요일 확인
	public static Calendar getRecentFridayInfo(Calendar pDate) {
		int iDayOfWeek = 0;
		// 오늘이 금요일일 경우 반환
		if(pDate.get(Calendar.DAY_OF_WEEK) == Calendar.FRIDAY)
			return pDate;
		else {
			// 금요일과의 차이 계산 ( 일요일의 경우 8로 대체 )
			iDayOfWeek = Calendar.FRIDAY - (pDate.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY ? 8 : pDate.get(Calendar.DAY_OF_WEEK));
			// 최근 금요일 계산
			pDate.add(Calendar.DAY_OF_MONTH, -7 + iDayOfWeek);
			return pDate;
		}
	}
	
	public static String convertOutputValue(String pValue) {
		pValue = pValue.replaceAll("&amp;", "&");
        pValue = pValue.replaceAll("&lt;", "<");
        pValue = pValue.replaceAll("&gt;", ">");
        pValue = pValue.replaceAll("&quot;", "\"");
        pValue = pValue.replaceAll("&apos;", "'");
        pValue = pValue.replaceAll("&#x2F;", "\\");
        pValue = pValue.replaceAll("&nbsp;", " ");

        return pValue;
	}
	
	public static String convertInputValue(String pValue) {
		pValue = pValue.replaceAll("&", "&amp;");
        pValue = pValue.replaceAll("<", "&lt;");
        pValue = pValue.replaceAll(">", "&gt;");
        pValue = pValue.replaceAll("\"", "&quot;");
        pValue = pValue.replaceAll("'", "&apos;");
        pValue = pValue.replaceAll("\\\\", "&#x2F;");
        pValue = pValue.replaceAll(" ", "&nbsp;");

        return pValue;
	}
	
	//TODO 메세징 변경 작업(WorkReportTimeCartServiceImpl로 이동)
	/*public static void sendWorkReportMsg(CoviMap paramJSON) throws Exception {
		Connection conn = null;
		PreparedStatement ps = null;
		try {
			conn = LegacyConnectionFactory.getDatabaseConnection();
			String insertStoreProc = "exec dbo.Com_C_Messaging_C ";
			insertStoreProc += "@ServiceType='"+paramJSON.get("ServiceType")+"',";
			insertStoreProc += "@ObjectType='"+paramJSON.get("ObjectType")+"',";
			insertStoreProc += "@ObjectID=null,";
			insertStoreProc += "@MsgType='"+paramJSON.get("MsgType")+"',";
			insertStoreProc += "@MessageID=null,";
			
			if(paramJSON.get("SubMsgID") != null && !paramJSON.get("SubMsgID").toString().isEmpty())
				insertStoreProc += "@SubMsgID='"+paramJSON.get("SubMsgID")+"',";
			else 
				insertStoreProc += "@SubMsgID=null,";
			
			insertStoreProc += "@MediaType='"+paramJSON.get("MediaType")+"',";
			insertStoreProc += "@IsUse='"+paramJSON.get("IsUse")+"',";
			insertStoreProc += "@IsDelay='"+paramJSON.get("IsDelay")+"',";
			insertStoreProc += "@MessagingSubject='"+paramJSON.getString("MessagingSubject").replace("'","''")+"',";
			insertStoreProc += "@ApprovalState='"+paramJSON.get("ApprovalState")+"',";
			insertStoreProc += "@SenderCode='"+paramJSON.get("SenderCode")+"',";
			insertStoreProc += "@ReceiverText='"+paramJSON.getString("ReceiverText").replace("'","''")+"',";
			
			if(paramJSON.get("ReservedDate") != null && !paramJSON.get("ReservedDate").toString().isEmpty())
				insertStoreProc += "@ReservedDate='"+paramJSON.get("ReservedDate")+"',";
			else
				insertStoreProc += "@ReservedDate=null,";
			
			insertStoreProc += "@XSLPath='"+paramJSON.get("XSLPath")+"',";
			insertStoreProc += "@Width='"+paramJSON.get("Width")+"',";
			insertStoreProc += "@Height='"+paramJSON.get("Height")+"',";
			insertStoreProc += "@PopupURL='"+paramJSON.get("PopupURL")+"',";
			insertStoreProc += "@GotoURL='"+paramJSON.get("GotoURL")+"',";
			insertStoreProc += "@OpenType='"+paramJSON.get("OpenType")+"',";
			insertStoreProc += "@MessageContext='"+paramJSON.getString("MessageContext").replace("'","''")+"',";
			insertStoreProc += "@ReservedStr1='"+paramJSON.get("ReservedStr1")+"',";
			insertStoreProc += "@ReservedStr2='"+paramJSON.get("ReservedStr2")+"',";
			insertStoreProc += "@ReservedStr3='"+paramJSON.get("ReservedStr3")+"',";
			
			if(paramJSON.get("ReservedStr4") != null && !paramJSON.get("ReservedStr4").toString().isEmpty())
				insertStoreProc += "@ReservedStr4='"+paramJSON.getString("ReservedStr4").replace("'","''")+"',";
			else
				insertStoreProc += "@ReservedStr4='',";
			
			if(paramJSON.get("ReservedInt1") != null && !paramJSON.get("ReservedInt1").toString().isEmpty())
				insertStoreProc += "@ReservedInt1='"+paramJSON.get("ReservedInt1")+"',";
			else
				insertStoreProc += "@ReservedInt1=null,";
			
			if(paramJSON.get("ReservedInt2") != null && !paramJSON.get("ReservedInt2").toString().isEmpty())
				insertStoreProc += "@ReservedInt2='"+paramJSON.get("ReservedInt2")+"',";
			else
				insertStoreProc += "@ReservedInt2=null,";
			
			insertStoreProc += "@RegistererCode='"+paramJSON.get("RegistererCode")+"',";
			insertStoreProc += "@ReceiversCode='"+paramJSON.get("ReceiversCode")+"'";
			
			ps = conn.prepareStatement(insertStoreProc);
			ps.setEscapeProcessing(true);
			ps.setQueryTimeout(100);
			ps.executeUpdate();
		}catch(Exception e){			
			throw e;
		}finally{
			if (ps != null) {
				ps.close();
			}

			if (conn != null) {
				conn.close();
			}
		}
	}
	*/
	
}
