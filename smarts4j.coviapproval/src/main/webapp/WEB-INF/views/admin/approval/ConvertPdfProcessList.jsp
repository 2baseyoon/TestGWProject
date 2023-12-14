<%@page import="egovframework.baseframework.data.CoviMap"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.concurrent.LinkedBlockingQueue"%>
<%@ page import="java.util.concurrent.ThreadPoolExecutor"%>
<%@ page import="org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.covision.coviflow.common.util.AsyncTaskPdfExport"%>
<%
	ServletContext servletContext = this.getServletContext();
	WebApplicationContext wac = WebApplicationContextUtils.getRequiredWebApplicationContext(servletContext);
	
	// custom codes
	ThreadPoolTaskExecutor executorPdfExport = (ThreadPoolTaskExecutor)wac.getBean("executorPdfExport");
	AsyncTaskPdfExport asyncTaskPdfExport = (AsyncTaskPdfExport)wac.getBean("asyncTaskPdfExport");
	
	Integer activeCount = executorPdfExport.getActiveCount();
	//int completedTaskCount = messagingPoolExecutor.getCompletedTaskCount();
	Integer corePoolSize = executorPdfExport.getCorePoolSize();
	Integer maxPoolSize = executorPdfExport.getMaxPoolSize();
	Integer currentPoolSize = executorPdfExport.getPoolSize();
	Integer currentQueueSize = executorPdfExport.getThreadPoolExecutor().getQueue().size();
	
	Map<String, CoviMap> tasks = asyncTaskPdfExport.getActiveTasks();
	
	if(tasks == null || tasks.size() == 0) {
%>
	<div>No activated tasks.</div>
<%
	}
	
	int idx = 1;
	for(Map.Entry<String, CoviMap> entry : tasks.entrySet()) {
		//executorPdfExport.getThreadPoolExecutor().
		CoviMap info = entry.getValue();
		String taskId = entry.getKey();
%>
	<div class="activeTaskListDIV" ><a href="javascript:void(0);" style="vertical-align:middle;" onclick="pdfConvertProcess.showTask('<%=taskId %>')">[<%= idx%>][<%=taskId %>]</a></div>
<%
		idx ++;
	}
%>