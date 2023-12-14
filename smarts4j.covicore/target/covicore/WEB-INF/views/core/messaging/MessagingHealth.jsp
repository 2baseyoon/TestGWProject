<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.concurrent.LinkedBlockingQueue"%>
<%@ page import="java.util.concurrent.ThreadPoolExecutor"%>
<%@ page import="org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.core.util.AsyncTaskMessaing"%>
<%@ page import="egovframework.core.util.AsyncCovicoreConfig"%>
<%
ServletContext servletContext = this.getServletContext();
WebApplicationContext wac = WebApplicationContextUtils.getRequiredWebApplicationContext(servletContext);

// custom codes
ThreadPoolTaskExecutor messagingPoolExecutor = (ThreadPoolTaskExecutor)wac.getBean("coviExecutorForMessaging");
AsyncTaskMessaing asyncTaskMessaing = (AsyncTaskMessaing)wac.getBean("asyncTaskMessaing");

Integer activeCount = messagingPoolExecutor.getActiveCount();
//int completedTaskCount = messagingPoolExecutor.getCompletedTaskCount();
Integer corePoolSize = messagingPoolExecutor.getCorePoolSize();
Integer maxPoolSize = messagingPoolExecutor.getMaxPoolSize();
Integer currentPoolSize = messagingPoolExecutor.getPoolSize();
Integer currentQueueSize = messagingPoolExecutor.getThreadPoolExecutor().getQueue().size();
long averageExecutedTime = asyncTaskMessaing.getAverageElapsedTime();

long serverStarted = asyncTaskMessaing.getServerStarted();
Calendar cal = Calendar.getInstance();
cal.setTimeInMillis(serverStarted);
DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String serverStartedDateTime = format.format(cal.getTime());

String activeColor = "black";
String queueColor = "black";
String activeBlink = "";
String queueBlink = "";

String maxQueueSizeStr = PropertiesUtil.getGlobalProperties().getProperty("messaging.threadpool.queue.size", String.valueOf(Integer.MAX_VALUE));
Integer maxQueueSize = Integer.parseInt(maxQueueSizeStr);

if(activeCount > 0){
	activeColor = "red";
}
if(activeCount == maxPoolSize){
	activeColor = "red";
	activeBlink = "blink";
}
// Queue 가용량 표시
if(currentQueueSize.floatValue() / maxQueueSize.floatValue() * 100 > 90){
	queueColor = "red";
	queueBlink = "blink";
}
%>
<style>
.blink {
	animation: blinker 0.6s linear infinite;
	font-size: 1.2em;
	font-family: sans-serif;
}
@keyframes blinker {
	50% {
		opacity: 0;
	}
}
</style>
<span>
	Core Pool Size : <span style="color:blue;"><%=corePoolSize %></span>
	, Max Pool Size : <span style="color:blue;"><%=maxPoolSize %></span> 
	, Current Pool Size : <span style="color:blue;"><%=currentPoolSize %></span> 
	, Active Task : <span class="<%=activeBlink %>" style="font-weight:bold;color:<%=activeColor%>;"><%=activeCount %></span>
	, Current Queued / Capacity : <span class="<%=queueBlink %>" style="font-weight:bold;color:<%=queueColor%>;"><%=currentQueueSize %> / <%=maxQueueSize %></span>
	, Average elapsed time : <span style="font-weight:bold;color:green;"><%=averageExecutedTime/1000 %> s</span>
	| Server Started : <%=serverStartedDateTime %>
</span>