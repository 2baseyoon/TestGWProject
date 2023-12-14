package egovframework.batch.base;

import java.sql.Connection;
import java.sql.SQLException;

import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerKey;

import egovframework.coviframework.batch.BaseQuartzServer;
import egovframework.coviframework.batch.CoviApplicationContextUtils;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.MessageHelper;

public class CoviQuartzDelegate extends org.quartz.impl.jdbcjobstore.StdJDBCDelegate {

    /**
     * <p>
     * Update the state for a given trigger.
     * </p>
     * 
     * @param conn
     *          the DB Connection
     * @param state
     *          the new state for the trigger
     * @return the number of rows updated
     */
	@Override
    public int updateTriggerState(Connection conn, TriggerKey triggerKey, String state) throws SQLException { 
		try {
			return super.updateTriggerState(conn, triggerKey, state);
		}finally {
			if("ERROR".equals(state)) {
				// ERROR 상태로 변경될때 Resume 처리 ( 간헐적 Deadlock 으로 판단되므로 재시도 )
				String autoResume = PropertiesUtil.getGlobalProperties().getProperty("quartz.errorjob.auto.resume", "false"); // 기본값 false 로.
				final String resumeDelay = PropertiesUtil.getGlobalProperties().getProperty("quartz.errorjob.auto.resume.delay", "5000");
				
				// 시스템 담당자 메일발송
				String sendMailYn = PropertiesUtil.getGlobalProperties().getProperty("quartz.errorjob.send.mail", "false");
				if("true".equals(sendMailYn)) {
					final String triggerInfo = triggerKey.toString();
					new Thread(new Runnable() {
						private final Object LOCK = new Object();
						@Override
						public void run() {
							synchronized (LOCK) {
								String errorReceivers = PropertiesUtil.getGlobalProperties().getProperty("quartz.errorjob.mail.receivers", "");
								
								if(!StringUtil.isEmpty(errorReceivers)) {
									for(String recevierEmail : errorReceivers.split(";")) {
										//메일 발송. (framework)
										String senderName = "관리자";
										String senderMail = PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail");
										String timeStr = DateHelper.getCurrentDay("yyyy-MM-dd HH:mm:ss");
										String subject = "[스케쥴러 오류알림] " + timeStr;
										String notifyCont = makeExportMailContents("[스케쥴러 오류알림]", triggerInfo, timeStr);
										MessageHelper.getInstance().sendSMTP(senderName, senderMail, recevierEmail, subject, notifyCont, true); 
									}
								}
							}
						}
						
						private String makeExportMailContents(String subject, String triggerInfo, String timeStr){

							String title = subject;
							StringBuffer sb = new StringBuffer("<html><head>");
							sb.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
							sb.append("</head>");
							sb.append("<body>");
							sb.append("<div>");
							sb.append("<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">");
							sb.append("	<tbody>");
							sb.append("		<tr>");
							sb.append("			<td height=\"40\" valign=\"middle\" style=\"padding-left:26px;\" bgcolor=\"#2b2e34\">");
							sb.append("				<table width=\"90%\" height=\"40\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:url(mail_top.gif) no-repeat top left;\">");
							sb.append("					<tbody>");
							sb.append("						<tr>");
							sb.append(String.format("			<td style=\"font:bold 15px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">%s</td>",title));
							sb.append("						</tr>");
							sb.append("					</tbody>");
							sb.append("				</table>");
							sb.append("			</td>");
							sb.append("		</tr>");
							sb.append("		<tr>");
							sb.append("			<td bgcolor='#f9f9f9' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>");
							sb.append("				발생시각 : " + timeStr);
							sb.append("				<br/><br/>");
							sb.append("				중지된 Trigger 정보 : " + triggerInfo);
							sb.append("			</td");
							sb.append("		</tr>");
							sb.append("		<tr>");
							sb.append("			<td style=\"padding: 0 0 5px 20px; border-left: 1px solid #e8ebed; border-right: 1px solid #e8ebed;border-bottom: 1px solid #e8ebed;\"></td>");
							sb.append("		</tr>");
							sb.append("	</tbody>");
							sb.append("</table>");
							sb.append("</div>");
							sb.append("</body>");
							sb.append("</html>");
							
							return sb.toString();
						}
					}).start();
				}
				
				// 원인파악 전까지는 자동재시작 하지 않음.
				if("true".equalsIgnoreCase(autoResume) && !StringUtil.isEmpty(resumeDelay) && StringUtil.isNumeric(resumeDelay)) {
					new Thread(new Runnable() {
						private final Object LOCK = new Object();
						
						@Override
						public void run() {
							synchronized (LOCK) {
								try {
									Thread.sleep(Long.parseLong(resumeDelay));
									
									BaseQuartzServer qs = (BaseQuartzServer) CoviApplicationContextUtils.getApplicationContext().getBean("quartzServer");
									if(qs != null) {
										Scheduler scheduler = qs.getStdSchedulerFactory().getScheduler();
										String message = "Trigger gone ERROR State. clear Error state and resume after 5 sec. TRIGGER_KEY : " + triggerKey;
										logger.warn(message);
										Trigger newTrigger = scheduler.getTrigger(triggerKey);
										scheduler.rescheduleJob(triggerKey, newTrigger);
										// 해당 트리거를 재기동 한다.
										LoggerHelper.errorLogger(new Exception(message), CoviQuartzDelegate.class.getCanonicalName(), "RUN");
									}
									
								} catch (InterruptedException e) {
									logger.error(e.getLocalizedMessage(), e);
								} catch (SchedulerException e) {
									logger.error(e.getLocalizedMessage(), e);
								} catch (Exception e) {
									logger.error(e.getLocalizedMessage(), e);
								}
							}
						}
					}).start();
				}
			}
		}
    }
}
