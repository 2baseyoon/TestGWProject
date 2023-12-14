<%@page import="java.text.DecimalFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="org.apache.commons.io.FileUtils"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="javax.management.remote.*"%>
<%@ page import="javax.management.*"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.lang.management.ManagementFactory"%>
<%@ page import="javax.management.MBeanServer"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="javax.naming.*,javax.sql.*"%>
<%@ page import="java.util.Enumeration"%>
<%! 
protected String convertToStringRepresentation(final long value){
    final long[] dividers = new long[] { FileUtils.ONE_TB, FileUtils.ONE_GB, FileUtils.ONE_MB, FileUtils.ONE_KB, 1 };
    final String[] units = new String[] { "TB", "GB", "MB", "KB", "B" };
    if(value < 1)
        throw new IllegalArgumentException("Invalid file size: " + value);
    String result = null;
    for(int i = 0; i < dividers.length; i++){
        final long divider = dividers[i];
        if(value >= divider){
            result = format(value, divider, units[i]);
            break;
        }
    }
    return result;
}

protected String format(final long value, final long divider, final String unit){ 
	final double result = divider > 1 ? (double) value / (double) divider : (double) value;
    return new DecimalFormat("#,##0.#").format(result) + " " + unit;
}
%>
<%
MBeanServer mbs = ManagementFactory.getPlatformMBeanServer();
String[] contexts = new String[]{"/covicore","/groupware","/approval","/account","/mail", "/api"};

%>
<style type="text/css">
	#wrapper h4 { font-weight:bold; font-size:16px; margin-bottom:8px; margin-top:32px;}
	#wrapper { 
 		width:auto; 
	}
	#wrapper * { 
		font-family:Courier New, Consolas, Calibri !important;
		font-size:13px;
	}
	td {padding:4px; border: 1px solid #aaa;}
	td:first-child {border-left:none;}
	td:last-child {border-right:none;}
	td.Cnt { font-weight:bold; }
	.tblArea > div:last-child tr:last-child td {border-bottom:none;}
	td.head { background-color: #fae3b1; font-weight:bold; }
	.label { font-size:18px; font-weight:bold; margin-bottom:5px;}
	.tblArea { min-height: 50px; border: 1px solid #aaa; }
/* 	.DatasourceInfo .contextArea {margin-right:10px;} */
	
	.Emphasis {color: red;}
	a.btnRefresh { font-size:12px; text-decoration:underline; cursor:pointer; }
	
	.TypeSection {margin-top:16px;}
	.TypeSection:first-child {margin-top:0px;}
	
	.DatasourceInfo table {margin-left:10px;}
	.DatasourceInfo table:first-child {margin-left:0px;}
	
	.headerTR > td {border-top:none;}
</style>
<script>
function Refresh() {
	CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
}
</script>
<h3 class="con_tit_box">
	<span class="con_tit">DBCP (Connection Pool) Statistics for Tomcat</span>
	<a onclick="Refresh()" class="btnRefresh" style="margin-left: 10px;">Refresh</a>
</h3>
<%
ObjectInstance was = null;
try {
	was = mbs.getObjectInstance(new ObjectName("Catalina:type=Server"));
}catch(javax.management.InstanceNotFoundException e) {
	out.print("<h4>Sorry, This page only works in a Tomcat environment.</h4>");
	return;
}
%>
<div style="display:inline-block; min-height: 500px">
	<div id="wrapper">
		<div class="TypeSection ServerInfo">
			<h4>Basic Information.</h4>
			<%
			Object serverInfo = mbs.getAttribute(was.getObjectName(), "serverInfo");
			%>
			<table cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
				<tr>
					<td class="head" style="width:120px;">Host Name</td>
					<td>
						<%=InetAddress.getLocalHost().getHostName() %>
					</td>
				</tr>
				<tr>
					<td class="head" style="width:120px;">Server Name</td>
					<td>
						<%=serverInfo %>
					</td>
				</tr>
				<tr>
					<td class="head" style="width:120px;">Server IP</td>
					<td>
						<%
						Object localPort = null;
						try {
							ObjectInstance service = mbs.getObjectInstance(new ObjectName("Catalina:type=Service"));
							Object connectors = mbs.getAttribute(service.getObjectName(), "connectorNames");
							if(connectors instanceof ObjectName[]) {
								ObjectName[] connectorsNames = (ObjectName[])connectors;
								for(ObjectName on : connectorsNames) {
									//ObjectInstance connector = mbs.getObjectInstance(on);
									localPort = mbs.getAttribute(on, "port");
									break;
								}
							}
						}catch(javax.management.InstanceNotFoundException e) {
							localPort = null;
						}
						%>
						<%=InetAddress.getLocalHost().getHostAddress() + " (" + localPort + ")"%>
					</td>
				</tr>
			</table>
		</div>
		<div class="TypeSection CPUInfo">
			<h4>CPU(JVM) Usage</h4>
			<%
			ObjectInstance cpu = mbs.getObjectInstance(new ObjectName("java.lang:type=OperatingSystem"));
			Object cpuLoad = mbs.getAttribute(cpu.getObjectName(), "ProcessCpuLoad");
			%>
			<table cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
				<tr>
					<td class="head" style="width:120px;">Process</td>
					<td>
					<%
					Double value = (Double)cpuLoad;
					double cpuRate = ((int)(value * 1000) / 10.0);
					out.print(cpuRate + "%");
					%>
					</td>
				</tr>
			</table>
		</div>
		
		<div class="TypeSection ActiveSessions" style="display:none;">
			<h4>Number of Sessions</h4>
				<table cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
					<tr>
						<td class="head" style="width:120px;">Context</td>
						<td class="head">Current Active</td>
						<td class="head">Max Active</td>
						<td class="head">Hit Max Active</td>
					</tr>
			<%
			for(String context : contexts) {
				ObjectInstance manager = null;
				try {
					manager = mbs.getObjectInstance(new ObjectName("Catalina:type=Manager,host=localhost,context="+context));
				}catch(javax.management.InstanceNotFoundException e) {
					continue;
				}
				Object maxActiveSessions = mbs.getAttribute(manager.getObjectName(), "maxActiveSessions");
				Object activeSessions = mbs.getAttribute(manager.getObjectName(), "activeSessions");
				Object hitMaxActive = mbs.getAttribute(manager.getObjectName(), "maxActive");
				%>
					<tr>
						<td class="head"><%=context %></td>
						<td><%=activeSessions %></td>
						<td><%=maxActiveSessions %></td>
						<td><%=hitMaxActive %></td>
					</tr>
				<%
			}
			%>
				</table>
		</div>
		
		<div class="TypeSection MemoyInfo">
			<h4>Memory(Heap) Usage</h4>
		<%
		ObjectInstance memoryInstance = mbs.getObjectInstance(new ObjectName("java.lang:type=Memory"));
		javax.management.openmbean.CompositeDataSupport heapUsedInfo  = (javax.management.openmbean.CompositeDataSupport)mbs.getAttribute(memoryInstance.getObjectName(), "HeapMemoryUsage");
		
		
		Long used = (Long)heapUsedInfo.get("used");
		Long max = (Long)heapUsedInfo.get("max");
		String usedStr = convertToStringRepresentation(used);
		String maxStr = convertToStringRepresentation(max);
		float rate = 100 * ((float)used / max);
		%>
			<table cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
				<tr>
					<td class="head" style="width:120px;">Usage</td>
					<td><%=usedStr + " / " + maxStr + " ( " + rate + "% )" %></td>
				</tr>
			</table>
		</div>
		
		<div class="TypeSection DatasourceInfo">
			<h4>Database Connection Pool</h4>
		<%
		for(String contextName : contexts) {
		%>	
		<div id="<%=contextName%>" class="TypeSection contextArea">
			<div class="label"><%=contextName%></div>
			<div class="tblArea">
<%
			/**
			* Datasources 
			*/
			Set<ObjectInstance> objInstances = mbs.queryMBeans(new ObjectName("*:type=DataSource,context="+ contextName +",*"), null); // context.xml 바인딩 datasources
			Set<ObjectInstance> objInstancesExt = mbs.queryMBeans(new ObjectName("*:type=GenericObjectPool,name=ExtDataSource["+ contextName +"]*"), null); // 외부DB Datasource 등록된 Pool.
			objInstances.addAll(objInstancesExt);
			List<ObjectInstance> objInstanceList = new ArrayList<ObjectInstance>(objInstances);
			Collections.sort(objInstanceList, new Comparator<ObjectInstance>(){
				@Override
				public int compare (ObjectInstance obj1, ObjectInstance obj2) {
					return obj1.getObjectName().toString().compareTo(obj2.getObjectName().toString());
				}
				@Override
				public boolean equals(Object obj) {
					return true;
				}
			});
			if(objInstanceList.size() == 0) {
				out.print("No information.");
			}else{
%>
				<div>
					<table cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
						<tr class="headerTR">
							<td class="head" align="center" style="width:520px" title="Datasource Name">Datasource Name</td>
							<td class="head" align="center" style="width:120px" title="Connections that are processing">Current ACTIVE Connections</td>
							<td class="head" align="center" style="width:120px" title="Connections that are idle in the pool">Current IDLE Connections</td>
							<td class="head" align="center" style="width:120px" title="Created Count in this Pool">Created Count (Not Peak Count)<br>Tomcat8+ 가능</td>
							<td class="head" align="center" style="width:120px" title="Total size of pool">MAX Total Connections</td>
							<td class="head" align="center" style="width:120px" title="Wait timeout for connection">MAX Wait Timeout(ms)</td>
						</tr>
<%
				boolean beanInfoShow = false;
				for (ObjectInstance obj : objInstanceList) {
					beanInfoShow = false;
					String className = "";
					String dsName = "";
					Integer numActive = 0;
					Integer maxTotal = 0;
					Integer numIdle = 0;
					Object maxWait = 0;
					String warnningCSS = "";
					Object createdCount = -1;
					int perc = 0;
					if("org.apache.tomcat.util.modeler.BaseModelMBean".equals(obj.getClassName())) {
						beanInfoShow = true;
						ObjectName objectName = obj.getObjectName();
						
						// Active Connections
						numActive = 0;
						try {
							numActive = (Integer)mbs.getAttribute(objectName, "numActive");
						}catch(javax.management.AttributeNotFoundException anfe){
							numActive = -1;
						}
						
						// Maximum total Counts
						maxTotal = 0;
						try {
							maxTotal = (Integer)mbs.getAttribute(objectName, "maxActive");
						}catch(javax.management.AttributeNotFoundException anfe){
							try{
								maxTotal = (Integer)mbs.getAttribute(objectName, "maxTotal");
							}catch(NullPointerException e){
								maxTotal = -1;	
							}catch(Exception e){
								maxTotal = -1;	
							}
						}
						
						// Idle Connections
						numIdle = 0;
						try {
							numIdle = (Integer)mbs.getAttribute(objectName, "numIdle");
						}catch(javax.management.AttributeNotFoundException anfe){
							numIdle = -1;
						}
						
						// Maximum wait timeout
						maxWait = 0;
						try {
							maxWait = mbs.getAttribute(objectName, "maxWaitMillis"); // BasicDataSource
						}catch(javax.management.AttributeNotFoundException anfe){
							try{
								maxWait = mbs.getAttribute(objectName, "maxWait");
							}catch(NullPointerException e){
								maxWait = -1;
							}catch(Exception e){
								maxWait = -1;
							} // XADataSource
						}
	
						if(maxTotal > 0) {
							perc = 100 * numActive / maxTotal;
							warnningCSS = "";
							if(perc > 15) {
								warnningCSS = "color:#fff;background-color:red";
							}
						}
						
						className = (String)objectName.getKeyProperty("class");
						dsName = (String)objectName.getKeyProperty("name");
						
						createdCount = 0;
						Set<ObjectInstance> connections = mbs.queryMBeans(new ObjectName(obj.getObjectName().getCanonicalName() + ",connectionpool=connections"), null); // Connection 이 1개 이상 생성된 경우 조회가능
						if(connections != null && !connections.isEmpty()) {
							for(ObjectInstance conn : connections){
								
								createdCount = mbs.getAttribute(conn.getObjectName(), "CreatedCount"); // 생성된 Connections ( Peak Concurrent Connection 이 아님. 참고용 )
								break;
							}
						}
				%>
<%
					}// end if
					else if("org.apache.commons.pool2.impl.GenericObjectPool".equals(obj.getClassName())) {
						beanInfoShow = true;
						ObjectName objectName = obj.getObjectName();
						
						// Active Connections
						numActive = 0;
						try {
							numActive = (Integer)mbs.getAttribute(objectName, "NumActive");
						}catch(javax.management.AttributeNotFoundException anfe){
							numActive = -1;
						}
						
						// Maximum total Counts
						maxTotal = 0;
						try {
							maxTotal = (Integer)mbs.getAttribute(objectName, "MaxTotal");
						}catch(javax.management.AttributeNotFoundException anfe){
							maxTotal = -1;
						}
						
						// Idle Connections
						numIdle = 0;
						try {
							numIdle = (Integer)mbs.getAttribute(objectName, "NumIdle");
						}catch(javax.management.AttributeNotFoundException anfe){
							numIdle = -1;
						}
						
						// Maximum wait timeout
						maxWait = 0;
						try {
							maxWait = mbs.getAttribute(objectName, "MaxWaitMillis");
						}catch(javax.management.AttributeNotFoundException anfe){
							maxWait = -1;
						}
						if(maxTotal > 0) {
							perc = 100 * numActive / maxTotal;
							warnningCSS = "";
							if(perc > 15) {
								warnningCSS = "color:#fff;background-color:red";
							}
						}
						
						className = (String)objectName.getKeyProperty("type");
						dsName = (String)objectName.getKeyProperty("name");
						
						createdCount = 0;
						try {
							createdCount = mbs.getAttribute(objectName, "CreatedCount");
						}catch(javax.management.AttributeNotFoundException anfe){
							createdCount = -1;
						}
					}
					
					if(beanInfoShow) {
%>
						<tr id="<%=dsName%>">
							<td align="left" class=""><b id="jndiNameTitle"><%=dsName %>( <%=className %> )</b></td>
							<td align="right" id="CurrentActive" class="Cnt Emphasis" style="<%=warnningCSS%>"><%=numActive %> ( <%=perc %>% )</td>
							<td align="right" id="CurrentIdle" class="Cnt"><%=numIdle %></td>
							<td align="right" id="CreatedCount" class="Cnt"><%=createdCount %></td>
							<td align="right" id="MaxTotal" class="Cnt"><%=maxTotal %></td>
							<td align="right" id="MaxWaitMillis" class="Cnt"><%=maxWait %></td>
						</tr>
<%
					}
				}//end for
%>
					</table>
				</div>
<%
			}//end if
			%>
			</div>
		</div>
		<%
		}// end outer for.
		%>
		</div>
	</div>
</div>
