<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% String activitiPath = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestatlist.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=approvalAppPath%>/resources/script/admin/json-formatter.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=approvalAppPath%>/resources/script/admin/Monitoring.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval/monitoring.css<%=resourceVersion%>" />
<script type="text/javascript">
	var c_act_explorer_url = '<%=activitiPath%>';
	
	var g_FormInstID = CFN_GetQueryString("FormInstID");
	var g_ProcessID = CFN_GetQueryString("ProcessID");
	var g_archived = CFN_GetQueryString("archived");	
	var g_domainData;
	var g_isDistribution = false;
	var g_docNo = decodeURI(CFN_GetQueryString("DocNO"));
	var g_selectedProcessID;
	var g_commentAttachList = [];
	
	var bSendComplete = false;
	
	var formJson = "${formJson}";
    
	$(document).ready(function (){
		
		formJson = Base64.b64_to_utf8(formJson);
		formJson = JSON.parse(formJson);
		
		getProcInfo();
		
		$.ajax({
			url:"/approval/getDomainListData.do",
			type:"post",
			data: {
				"ProcessID": g_ProcessID,
				"FormInstID": g_FormInstID
			},
			async:false,
			success:function (data) {
				g_domainData = Object.toJSON(data.list[0].DomainDataContext);
				
				objGraphicList = ApvGraphicView.getGraphicData(g_domainData);
				ApvGraphicView.initRender($("#graphicDiv"), objGraphicList);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("approval/getDomainListData.do", response, status, error);
			}
		});
		
		$(window).scroll(function () {
	        var scroll = $(window).scrollTop();
	        var windowHeight = $(window).height();
	        var totalHeight = scroll + windowHeight;
	        var containerHeight = $("form").height();
	    });
		
		$('#sel_table').change(function(){
	        var selectedTable = $('#sel_table option:selected').val();
	        var htmlCols = "";
			switch(selectedTable){
			case "FormInstance":
				htmlCols += "<option value='Subject'>Subject</option>";
				htmlCols += "<option value='DeletedDate'>DeletedDate</option>";
				htmlCols += "<option value='DocNo'>DocNo</option>";
				htmlCols += "<option value='DocLevel'>DocLevel</option>";
				htmlCols += "<option value='DocClassID'>DocClassID</option>";
				htmlCols += "<option value='DocClassName'>DocClassName</option>";
				htmlCols += "<option value='DocSummary'>DocSummary</option>";
				htmlCols += "<option value='IsPublic'>IsPublic</option>";
				htmlCols += "<option value='SaveTerm'>SaveTerm</option>";
				htmlCols += "<option value='BodyType'>BodyType</option>";
				htmlCols += "<option value='DocLinks'>DocLinks</option>";
				htmlCols += "<option value='BodyContext'>BodyContext</option>";
				break;
				
			case "Process":
				htmlCols += "<option value='ProcessKind'>ProcessKind</option>";
				htmlCols += "<option value='DocSubject'>DocSubject</option>";
				htmlCols += "<option value='BusinessState'>BusinessState</option>";
				htmlCols += "<option value='ProcessState'>ProcessState</option>";
				htmlCols += "<option value='DeleteDate'>DeleteDate</option>";
				break;
				
			case "ProcessDesc":
				htmlCols += "<option value='FormSubject'>FormSubject</option>";
				htmlCols += "<option value='IsSecureDoc'>IsSecureDoc</option>";
				htmlCols += "<option value='IsFile'>IsFile</option>";
				htmlCols += "<option value='FileExt'>FileExt</option>";
				htmlCols += "<option value='IsComment'>IsComment</option>";
				htmlCols += "<option value='IsReserved'>IsReserved</option>";
				htmlCols += "<option value='Priority'>Priority</option>";
				htmlCols += "<option value='IsModify'>IsModify</option>";
				htmlCols += "<option value='Reserved1'>Reserved1</option>";
				htmlCols += "<option value='Reserved2'>Reserved2</option>";
				break;
				
			case "WorkItem":
				htmlCols += "<option value='DeputyID'>DeputyID</option>";
				htmlCols += "<option value='DeputyName'>DeputyName</option>";
				htmlCols += "<option value='State'>State</option>";
				htmlCols += "<option value='Deleted'>Deleted</option>";
				htmlCols += "<option value='BusinessData1'>BusinessData1</option>";
				htmlCols += "<option value='BusinessData2'>BusinessData2</option>";
				htmlCols += "<option value='BusinessData3'>BusinessData3</option>";
				htmlCols += "<option value='BusinessData4'>BusinessData4</option>";
				htmlCols += "<option value='BusinessData5'>BusinessData5</option>";
				htmlCols += "<option value='BusinessData6'>BusinessData6</option>";
				htmlCols += "<option value='BusinessData7'>BusinessData7</option>";
				htmlCols += "<option value='BusinessData8'>BusinessData8</option>";
				htmlCols += "<option value='BusinessData9'>BusinessData9</option>";
				htmlCols += "<option value='BusinessData10'>BusinessData10</option>";
				break;
				
			case "Performer":
				htmlCols += "<option value='State'>State</option>";
				htmlCols += "<option value='SubKind'>SubKind</option>";
				break;
				
			case "DomainData":
				htmlCols += "<option value='DomainDataContext'>DomainDataContext</option>";
				break;
				
			}
			
			var htmlColKey = "";
			switch(selectedTable){
			case "FormInstance":
				htmlColKey += "<option value='FormInstID'>FormInstID</option>";
				htmlColKey += "<option value='ProcessID'>ProcessID</option>";
				break;
				
			case "Process":
				htmlColKey += "<option value='ProcessID'>ProcessID</option>";
				htmlColKey += "<option value='FormInstID'>FormInstID</option>";
				break;
				
			case "ProcessDesc":
				htmlColKey += "<option value='ProcessDescriptionID'>ProcessDescriptionID</option>";
				htmlColKey += "<option value='FormInstID'>FormInstID</option>";
				break;
				
			case "WorkItem":
				htmlColKey += "<option value='WorkItemID'>WorkItemID</option>";
				htmlColKey += "<option value='TaskID'>TaskID</option>";
				htmlColKey += "<option value='ProcessID'>ProcessID</option>";
				break;
				
			case "Performer":
				htmlColKey += "<option value='PerformerID'>PerformerID</option>";
				htmlColKey += "<option value='WorkItemID'>WorkItemID</option>";
				break;
				
			case "DomainData":
				htmlColKey += "<option value='DomainDataID'>DomainDataID</option>";
				htmlColKey += "<option value='ProcessID'>ProcessID</option>";
				break;
				
			}
			
			var $selCol = $('#sel_column');
			$selCol.find("option").remove();
			$selCol.append(htmlCols);
			
			var $selColKey = $('#sel_column_key');
			$selColKey.find("option").remove();
			$selColKey.append(htmlColKey);
			
	    });
		
		if(g_archived == "true"){
			$("#btnOpenFormInst").val("FormInstance 테이블 보기");
			$("#btnOpenActiviti").attr("disabled", "disabled");
			$("#btnOpenUpdatTable").attr("disabled", "disabled");
			
			$("#btnOpenUpdateDomaindata").attr("disabled", "disabled");
			$("#btnOpenUpdateVariable").attr("disabled", "disabled");
		}
		
	});
	
	function checkState(){
		//check error state
		$("td[name='state']").each(function(index){
			if($(this).find('div').text() == '288'){
				$(this).find('div').css("background-color", "yellow");
			} else if($(this).find('div').text() == '275'){
				$(this).find('div').css({"background-color":"red","color":"white"});	
			}
		});
	}
	
	//get process
	function getProcInfo(){
		
		$.ajax({
		    url: "getprocinfo.do",
		    type: "POST",
		    data: {
				"fiid" : g_FormInstID
			},
		    success: function (res) {
		    	getProcInfoSuccessCallback(res.list);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getprocinfo.do", response, status, error);
			}
		});
	}
	
	function getProcInfoSuccessCallback(data){
		var parentProcessState = "";
		var basicCnt = 0;
		var isProcessBasic = false;
		var isDraft = false;
		
		var tbody = $("<tbody />"),tr;
		$.each(data,function(i,obj) {
			//배포 문서인지 체크 [기준 : 부모 프로세스가 끝났는데 basic 프로세스가 진행중이며, basic 프로세스가 1개 이상인 결재 양식]
			if(obj.ParentProcessID == "0"){
				parentProcessState = obj.ProcessState;
			}
			if(obj.ProcessName == "Basic"){
				++basicCnt;
				if(obj.ProcessState == "288"){
					isProcessBasic = true;
				}
			}
			else if(obj.ProcessName == "Draft") {
				isDraft = true;
			}
			
		    tr = $("<tr />");
		    tr.append("<td><div><a style='cursor: pointer;' id='proc_" + i + "' data-piid='" + validateJsonVal(obj.ProcessID) + "' data-pdescid='" + validateJsonVal(obj.ProcessDescriptionID) + "' data-ppiid='"+obj.ParentProcessID+"' data-state='"+obj.ProcessState+"'>"+validateJsonVal(obj.ProcessID)+"</a></div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ProcessDescriptionID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ParentProcessID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ProcessName)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.DocSubject)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessState)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.InitiatorID)+"</div></td>")
		    .append("<td><div>"+CFN_GetDicInfo(validateJsonVal(obj.InitiatorName))+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.InitiatorUnitID)+"</div></td>")
		    .append("<td><div>"+CFN_GetDicInfo(validateJsonVal(obj.InitiatorUnitName))+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FormInstID)+"</div></td>")
		    .append("<td name='state'><div>"+validateJsonVal(obj.ProcessState)+"</div></td>")
		    .append("<td><div>"+CFN_TransLocalTime(validateJsonVal(obj.StartDate))+"</div></td>")
		    .append("<td><div>"+CFN_TransLocalTime(validateJsonVal(obj.EndDate))+"</div></td>");
		    
		    tr.appendTo(tbody);
		    $("<tr><td colspan='14'><div id='extra_" + i + "' style='display:none;padding:10px;border:4px dotted green; border-bottom:5px solid green;'></div></td></tr>").appendTo(tbody);
		    
		});
		if(parentProcessState == "528" && basicCnt > 1 && isProcessBasic){
			g_isDistribution = true;
		}
		if(parentProcessState == "528" && isDraft){ // 추가발송 가능한 문서라면(Draft)
			$("#btnAddReceipt").show();
			bSendComplete = true;
		}
		
		tbody.appendTo("#tblProcInfo");
		
		checkState();
		
		$("a[id^=proc_]").click(function(event) {
			event.preventDefault();
		    var idx = $(this).attr('id').substr(5);
			var $extra = $("#extra_" + idx);
		    $extra.slideToggle("fast");
		    var pi_state = $(this).attr("data-state");
		    var ppiid =  $(this).attr("data-ppiid");
		    
		    if(bSendComplete && g_isDistribution && ppiid != "0" && pi_state=="288") {
		    	$("#btnDeleteReceipt").show(); // 수신처 삭제
		    	g_selectedProcessID = $(this).attr("data-piid");
		    }
		    else {
		    	$("#btnDeleteReceipt").hide();
		    }
		    
		  	//approval process 정보를 가져온다
		    //processdescription, workitem, performer, domaindata
		    if($('#tblProcDesc_' + idx).length == 0){
		    	var html = '<br/><h3>● process description</h3>';
		    	html += '<table id="tblProcDesc_' + idx + '" class="table1_12" width="100%">';
		    	html += '	<thead>';
		    	html += '		<tr>';
		    	html += '			<th><div>ProcDescID</div></th>';
		    	html += '			<th><div>FormInstID</div></th>';
		    	html += '			<th><div>FormID</div></th>';
		    	html += '			<th><div>FormPrefix</div></th>';
		    	html += '			<th><div>FormName</div></th>';
		    	html += '			<th><div>FormSubject</div></th>';
		    	html += '			<th><div>IsSecureDoc</div></th>';
		    	html += '			<th><div>IsFile</div></th>';
		    	html += '			<th><div>FileExt</div></th>';
		    	html += '			<th><div>IsComment</div></th>';
		    	html += '			<th><div>ApproverCode</div></th>';
		    	html += '		</tr>';
		    	html += '		<tr>';
		    	html += '			<th><div>ApproverName</div></th>';
		    	html += '			<th><div>ApprovalStep</div></th>';
		    	html += '			<th><div>ApproverSIPAddress</div></th>';
		    	html += '			<th><div>IsReserved</div></th>';
		    	html += '			<th><div>ReservedGubun</div></th>';
		    	html += '			<th><div>ReservedTime</div></th>';
		    	html += '			<th><div>Priority</div></th>';
		    	html += '			<th><div>IsModify</div></th>';
		    	html += '			<th><div>Reserved1</div></th>';
		    	html += '			<th><div>Reserved2</div></th>';
		    	html += '		</tr>';
		    	html += '	</thead>';
		    	html += '</table>';
		    	$extra.append(html);
		    	getProcDesc(idx, $(this).data('pdescid'));
		    }
		    
		    if($('#tblWorkitem_' + idx).length == 0){
		    	var html = '<br/><h3>● workitem</h3>';
		    	html += '<table id="tblWorkitem_' + idx + '" class="table1_12 table1_13" width="100%">';
		    	html += '	<thead>';
		    	html += '		<tr>';
		    	html += '			<th><div>WorkItemID</div></th>';
		    	html += '			<th><div>TaskID</div></th>';
		    	html += '			<th><div>ProcessID</div></th>';
		    	html += '			<th><div>PerformerID</div></th>';
		    	html += '			<th><div>WorkItemDescriptionID</div></th>';
		    	html += '			<th><div>Name</div></th>';
		    	html += '			<th><div>DSCR</div></th>';
		    	html += '			<th><div>Priority</div></th>';
		    	html += '			<th><div>ActualKind</div></th>';
		    	html += '			<th><div>UserCode</div></th>';
		    	html += '			<th><div>UserName</div></th>';
		    	html += '			<th><div>DeputyID</div></th>';
		    	html += '			<th><div>DeputyName</div></th>';
		    	html += '			<th><div>State</div></th>';
		    	html += '			<th><div>Created</div></th>';
		    	html += '			<th><div>FinishRequested</div></th>';
		    	html += '		</tr>';
		    	html += '		<tr>';
		    	html += '			<th><div>Finished</div></th>';
		    	html += '			<th><div>Limit</div></th>';
		    	html += '			<th><div>LastRepeated</div></th>';
		    	html += '			<th><div>Finalized</div></th>';
		    	html += '			<th><div>Deleted</div></th>';
		    	html += '			<th><div>Charge</div></th>';
		    	html += '			<th><div>BusinessData1</div></th>';
		    	html += '			<th><div>BusinessData2</div></th>';
		    	html += '			<th><div>BusinessData3</div></th>';
		    	html += '			<th><div>BusinessData4</div></th>';
		    	html += '			<th><div>BusinessData5</div></th>';
		    	html += '			<th><div>BusinessData6</div></th>';
		    	html += '			<th><div>BusinessData7</div></th>';
		    	html += '			<th><div>BusinessData8</div></th>';
		    	html += '			<th><div>BusinessData9</div></th>';
		    	html += '			<th><div>BusinessData10</div></th>';
		    	html += '		</tr>';
		    	html += '	</thead>';
		    	html += '</table>';
		    	$extra.append(html);
		    	getWorkitem(idx, $(this).data('piid'));
		    }
		    
		  	//performer 정보를 가져온다.
		    /*
		  	if($('#tblPerformerInfo_' + idx).length == 0){
		    	var html = '<br/><h3>● performer</h3>';
		    	html += '<table id="tblPerformerInfo_' + idx + '" class="AXFormTable" border="1" style="width:100%;padding:3px;">';
		    	html += '	<thead>';
		    	html += '		<th>PerformerID</th>';
		    	html += '		<th>WorkitemID</th>';
		    	html += '		<th>AllotKey</th>';
		    	html += '		<th>UserCode</th>';
		    	html += '		<th>UserName</th>';
		    	html += '		<th>ActualKind</th>';
		    	html += '		<th>State</th>';
		    	html += '		<th>SubKind</th>';
		    	html += '	</thead>';
		    	html += '</table>';
		    	$extra.append(html);
		    	//getActProcInfo(idx, $(this).data('piid'));
		    }
		  	*/
		  	
		  	//결재선 정보를 가져온다.
		    if($('#tblDomaindata_' + idx).length == 0){
		    	var html = '<br/><h3>● domaindata</h3>';
		    	html += '<table id="tblDomaindata_' + idx + '" class="table1_12" width="100%">';
		    	html += '	<thead>';
		    	html += '		<th><div>DomainDataID</div></th>';
		    	html += '		<th><div>DomainDataName</div></th>';
		    	html += '		<th><div>ProcessID</div></th>';
		    	html += '		<th width="80%"><div>DomainDataContext</div></th>';
		    	html += '	</thead>';
		    	html += '</table>';
		    	$extra.append(html);
		    	getDomaindata(idx, $(this).data('piid'));
		    }
		    
		  	//activiti process 정보를 가져온다.
		    if($('#tblActProcInfo_' + idx).length == 0){
		    	var html = '<br/><h3>● activiti 프로세스 정보</h3>';
		    	html += '<table id="tblActProcInfo_' + idx + '" class="table1_12" width="100%">';
		    	html += '	<thead>';
		    	html += '		<th><div>id</div></th>';
		    	html += '		<th><div>url</div></th>';
		    	html += '		<th><div>businessKey</div></th>';
		    	html += '		<th><div>suspended</div></th>';
		    	html += '		<th><div>ended</div></th>';
		    	html += '		<th width="130px"><div>processDefinitionId</div></th>';
		    	html += '		<th width="200px"><div>processDefinitionUrl</div></th>';
		    	html += '		<th><div>activityId</div></th>';
		    	html += '		<th><div>variables</div></th>';
		    	html += '		<th><div>tenantId</div></th>';
		    	html += '		<th><div>completed</div></th>';
		    	html += '	</thead>';
		    	html += '</table>';
		    	$extra.append(html);
		    	getActProcInfo(idx, $(this).data('piid'));
		    }
		    
		});
	}
	
	//get domaindata
	function getDomaindata(idx, piid){
		$.ajax({
		    url: "getdomaindata.do",
		    type: "POST",
		    data: {
				"piid" : piid
			},
		    success: function (res) {
                //$('#divProcInfo').append(JSON.stringify(res.list));
                getDomaindataSuccessCallback(idx, res.list);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getdomaindata.do", response, status, error);
			}
		});
	}
	
	function getDomaindataSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr;
		$.each(data,function(i,obj) {
		    tr = $("<tr />");
		    var html = "";
		    html += "<td><div>" + validateJsonVal(obj.DomainDataID) + "<div></td>";
		    html += "<td><div>" + validateJsonVal(obj.DomainDataName) + "<div></td>";
		    html += "<td><div>" + validateJsonVal(obj.ProcessID) + "<div></td>";
	    	html += "<td width='80%' style='word-break:break-all;'>";
	    	html += "	<input type='button' class='AXButton' onclick='openJsonViewer(" + idx + "," + i + ");' value='open jsonviewer'/>";
	    	html += "	<div id='con_appvLine_" + idx + "_" + i + "'>" + JSON.stringify(validateJsonVal(obj.DomainDataContext)) + "</div><br/>";
	    	html += "	<div id='target_appvLine_" + idx + "_" + i + "'></div>";
	    	html += "</td>";
		    tr.append(html);
		    tr.appendTo(tbody);
		    
		    var html2 = "";
		    html2 += "<tr>";
		    html2 += "	<td colspan='4' style='border-bottom:3px dotted grey;'>";
		    html2 += "		<input type='button' class='AXButton' onclick='updateProcDesc(" + idx + "," + i + ");' value='UPDATE'/>";
		    html2 += "	</td>";
		    html2 += "</tr>";
		    //$(html2).appendTo(tbody);
		});
		
		tbody.appendTo("#tblDomaindata_" + idx);
		
	}
	
	//get processdescription
	function getProcDesc(idx, pdescid){
		$.ajax({
		    url: "getprocdesc.do",
		    type: "POST",
		    data: {
				"pdescid" : pdescid
			},
		    success: function (res) {
		    	getProcDescSuccessCallback(idx, res.list);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getprocdesc.do", response, status, error);
			}
		});
	}
	
	function getProcDescSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr1, tr2;
		$.each(data,function(i,obj) {
		    tr1 = $("<tr />");
		    tr1.append("<td><div>"+validateJsonVal(obj.ProcessDescriptionID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FormInstID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FormID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FormPrefix)+"</div></td>")
		    .append("<td><div>"+CFN_GetDicInfo(validateJsonVal(obj.FormName))+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FormSubject)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.IsSecureDoc)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.IsFile)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FileExt)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.IsComment)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ApproverCode)+"</div></td>");
		    
		    tr1.appendTo(tbody);
		    
		    tr2 = $("<tr />");
		    tr2.append("<td><div>"+CFN_GetDicInfo(validateJsonVal(obj.ApproverName))+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ApprovalStep)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ApproverSIPAddress)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.IsReserved)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ReservedGubun)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ReservedTime)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Priority)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.IsModify)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Reserved1)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Reserved2)+"</div></td>");
		    
		    tr2.appendTo(tbody);
		    
		    //var html = "";
		    //html += "<tr>";
		    //html += "	<td colspan='11' style='border-bottom:3px dotted grey;'>";
		    //html += "		<input type='button' class='AXButton' onclick='updateProcDesc(" + idx + "," + i + ");' value='UPDATE'/>";
		    //html += "	</td>";
		    //html += "</tr>";
		    //$(html).appendTo(tbody);
		    
		});
		
		tbody.appendTo("#tblProcDesc_" + idx);
	}
	
	//Workitem
	function getWorkitem(idx, piid){
		$.ajax({
		    url: "getworkitem.do",
		    type: "POST",
		    data: {
				"piid" : piid
			},
		    success: function (res) {
		    	getWorkitemSuccessCallback(idx, res.list);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getworkitem.do", response, status, error);
			}
		});
	}
	
	function getWorkitemSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr1, tr2;
		$.each(data,function(i,obj) {
		    tr1 = $("<tr />");
		    tr1.append("<td><div>"+validateJsonVal(obj.WorkItemID)+"</div></td>")
		    .append("<td name='workitem_taskid'><div>"+validateJsonVal(obj.TaskID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ProcessID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.PerformerID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.WorkItemDescriptionID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Name)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.DSCR)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Priority)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ActualKind)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.UserCode)+"</div></td>")
		    .append("<td><div>"+CFN_GetDicInfo(validateJsonVal(obj.UserName))+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.DeputyID)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.DeputyName)+"</div></td>")
		    .append("<td name='state'><div>"+validateJsonVal(obj.State)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Created)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.FinishRequested)+"</div></td>");
		    
		    tr1.appendTo(tbody);
		    
		    tr2 = $("<tr />");
		    tr2.append("<td><div>"+validateJsonVal(obj.Finished)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Limit)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.LastRepeated)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Finalized)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Deleted)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.Charge)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData1)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData2)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData3)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData4)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData5)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData6)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData7)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData8)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData9)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.BusinessData10)+"</div></td>");
		    
		    tr2.appendTo(tbody);
		    
		    var html = "";
		    html += "<tr>";
		    html += "	<td colspan='16' style='border-bottom:3px dotted grey;'>";
		    html += "		<input type='button' class='AXButton' onclick='updateWorkitem(" + idx + "," + i + ");' value='UPDATE'/>";
		    html += "	</td>";
		    html += "</tr>";
		    //$(html).appendTo(tbody);
		    
		});
		
		tbody.appendTo("#tblWorkitem_" + idx);
		
		checkState();
	}
	
	//get activiti process
	function getActProcInfo(idx, piid){
		
		$.ajax({
		    url: "getactprocinfo.do",
		    type: "POST",
		    data: {
				"piid" : piid
			},
		    success: function (res) {
		    	getActProcInfoSuccessCallback(idx, res.list.data);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getactprocinfo.do", response, status, error);
			}
		});
	}
	
	function getActProcInfoSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr;
		$.each(data,function(i,obj) {
		    tr = $("<tr />");
		    tr.append("<td><div>"+validateJsonVal(obj.id)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.url)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.businessKey)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.suspended)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.ended)+"</div></td>")
		    .append("<td width='130px'><div>"+validateJsonVal(obj.processDefinitionId)+"</div></td>")
		    .append("<td width='200px'><div>"+validateJsonVal(obj.processDefinitionUrl)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.activityId)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.variables)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.tenantId)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.completed)+"</div></td>");
		    
		    tr.appendTo(tbody);
		    
		    var html = "";
		    html += "<tr>";
		    html += "	<td colspan='11'>";
		    html += "		<div id='div_act_proc_" + idx + "' style='padding:10px;border-bottom:3px dotted grey;'>";
		    html += "			<input type='button' class='AXButton' onclick='callDiagram(" + idx + ",\"" + obj.processDefinitionId + "\", \"" + obj.id + "\");' value='Call Diagram viewer'/>";
		    html += "			<input type='button' class='AXButton' onclick='callTasks(" + idx + ",\"" + obj.id + "\");' value='Get Tasks'/>";
		    html += "		</div>";
		    html += "	</td>";
		    html += "</tr>";
		    $(html).appendTo(tbody);
			    
		    //호출되는 시점상 process 정보를 그리는 부분과 꼬일 가능성 존재함.
		    //callDiagram(idx, obj.processDefinitionId, obj.id);
		    
		});
		
		tbody.appendTo("#tblActProcInfo_" + idx);
		
	}
	
	function callTasks(idx, piid){
		var $target = $("#div_act_proc_" + idx);
		//activiti tasks
	    if($('#divActTasks_' + idx).length == 0){
	    	var html = '';
	    	html += '<div id="divActTasks_' + idx + '" >';
	    	html += '<br/><br/><h3>● activiti tasks</h3>';
	    	html += '<table id="tblActTasks_' + idx + '" class="table1_12" width="100%">';
	    	html += '	<thead>';
	    	html += '		<th><div>id</div></th>';
	    	html += '		<th><div>name</div></th>';
	    	html += '		<th><div>createTime</div></th>';
	    	html += '		<th><div>taskDefinitionKey</div></th>';
	    	html += '		<th><div>executionId</div></th>';
	    	html += '		<th><div>processInstanceId</div></th>';
	    	html += '		<th><div>processDefinitionId</div></th>';
	    	html += '	</thead>';
	    	html += '</table>';
	    	html += '</div>';
	    	$target.append(html);
	    	getActTasks(idx, piid);
	    } else {
	    	$('#divActTasks_' + idx).slideToggle("fast");
	    }
	}
	
	//get tasks
	function getActTasks(idx, piid){
		
		$.ajax({
		    url: "getacttasks.do",
		    type: "POST",
		    data: {
				"piid" : piid
			},
		    success: function (res) {
                getActTasksSuccessCallback(idx, res.list.data);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getacttasks.do", response, status, error);
			}
		});
	}
	
	function getActTasksSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr;
		$.each(data,function(i,obj) {
		    tr = $("<tr />");
		    tr.append("<td name='act_taskid'><div>"+validateJsonVal(obj.id)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.name)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.createTime)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.taskDefinitionKey)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.executionId)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.processInstanceId)+"</div></td>")
		    .append("<td><div>"+validateJsonVal(obj.processDefinitionId)+"</div></td>");
		    
		    tr.appendTo(tbody);
		    
		    var html = "";
		    html += "<tr>";
		    html += "	<td colspan='7'>";
		    html += "		<div id='div_act_task_" + i + "' style='padding:10px;border-bottom:3px dotted grey;'>";
		    html += "			<input type='button' class='AXButton' onclick='callVariables(" + i + ",\"" + obj.id + "\");' value='Get Variables'/>";
		    html += "		</div>";
		    html += "	</td>";
		    html += "</tr>";
		    $(html).appendTo(tbody);
			
		});
		
		tbody.appendTo("#tblActTasks_" + idx);
		
		$("td[name='act_taskid']").each(function(index){
			var $act_td = $(this);
			var act_taskid = $act_td.find('div').html();
			
			$("td[name='workitem_taskid']").each(function(index){
				var $work_td = $(this);
				var work_taskid = $work_td.find('div').html();
				
				if(act_taskid == work_taskid){
					//$act_td.effect('highlight',{},10000);
					//$work_td.effect('highlight',{},10000);
					$act_td.css("background-color", "#00ff00");
					$work_td.css("background-color", "#00ff00");
				}
			});
			
		});
		
		/*
		$("td[name='workitem_taskid']").each(function(index){
			var $this = $(this);
			$("td[name='act_taskid']").each(function(index){
				if($this.find('div').html() == $(this).find('div').html()){
					var $cvs = document.getElementById("cvs_monitoring");
					var ctx = $cvs.getContext("2d");
					ctx.canvas.width = window.innerWidth;
					ctx.canvas.height = window.innerHeight;
					ctx.beginPath(); 
					ctx.lineWidth="5";
					ctx.strokeStyle="red"; 
					ctx.moveTo($this.offsetRight,$this.offsetBottom);
					ctx.lineTo($(this).offsetLeft,$(this).offsetTop);
					ctx.stroke();
				}
				
			});
			
		});
		*/
		
	}
	
	function callVariables(idx, taskid){
		var $target = $("#div_act_task_" + idx);
		//3. activiti diagram을 그린다.
	    if($('#divActVariables_' + idx).length == 0){
	    	var html = '';
	    	html += '<div id="divActVariables_' + idx + '" >';
	    	html += '<br/><br/><h3>● activiti variables</h3>';
	    	html += '<table id="tblActVariables_' + idx + '" class="table1_12" width="100%">';
	    	html += '	<thead>';
	    	html += '		<th width="180px"><div>name</div></th>';
	    	html += '		<th width="70px"><div>type</div></th>';
	    	html += '		<th width="70px"><div>scope</div></th>';
	    	html += '		<th><div>value</div></th>';
	    	html += '	</thead>';
	    	html += '</table>';
	    	html += '</div>';
	    	$target.append(html);
	    	getActVariables(idx, taskid);
	    } else {
	    	$('#divActVariables_' + idx).slideToggle("fast");
	    }
	}
	
	//get variable
	function getActVariables(idx, taskid){
		$.ajax({
		    url: "getactvariables.do",
		    type: "POST",
		    data: {
				"taskid" : taskid
			},
		    success: function (res) {
                //$('#divProcInfo').append(JSON.stringify(res.list));
                getActVariablesSuccessCallback(idx, res.list);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getactvariables.do", response, status, error);
			}
		});
	}
	
	function getActVariablesSuccessCallback(idx, data){
		var tbody = $("<tbody />"),tr;
		$.each(data,function(i,obj) {
		    tr = $("<tr />");
		    var html = "";
		    html += "<td width='180px'><div>" + validateJsonVal(obj.name) + "</div></td>";
		    html += "<td width='70px'><div>" + validateJsonVal(obj.type) + "</div></td>";
		    html += "<td width='70px'><div>" + validateJsonVal(obj.scope) + "</div></td>";
		    if(obj.name == 'g_appvLine'||obj.name == 'g_context'||obj.name == 'g_isLegacy'||obj.name == 'g_config'){
		    	html += "<td style='word-break:break-all;'>";
		    	html += "	<input type='button' class='AXButton' onclick='openJsonViewer(" + idx + "," + i + ");' value='open jsonviewer'/>";
		    	html += "	<div id='con_appvLine_" + idx + "_" + i + "'>" + JSON.stringify(validateJsonVal(obj.value)) + "</div><br/>";
		    	html += "	<div id='target_appvLine_" + idx + "_" + i + "'></div>";
		    	html += "</td>";
		    } else{
		    	html += "<td style='word-break:break-all;'>" + validateJsonVal(obj.value) + "</td>";
		    }
		    tr.append(html);
		    tr.appendTo(tbody);
		    
		});
		
		tbody.appendTo("#tblActVariables_" + idx);
		
	}
		
	function openJsonViewer(idx, i){
		/*	https://github.com/mohsen1/json-formatter-js */
		var val = $('#con_appvLine_' + idx + '_' + i).text();
		
		if(val != '' || val != null){
			var formatter = new JSONFormatter(JSON.parse(val));
			if($('#target_appvLine_' + idx + '_' + i).children().length == 0){
				document.getElementById('target_appvLine_' + idx + '_' + i).appendChild(formatter.render());
				formatter.openAtDepth('Infinity');
			}
		}
		
	}
	
	function callDiagram(idx, pdefId, piid){
		/*
		하단의 iframe if_act_explorer이 열려 있지 않은 경우
		diagramviewer 호출 시 403 인증 오류가 발생함.
		*/
		var $target = $("#div_act_proc_" + idx);
		//3. activiti diagram을 그린다.
	    if($('#divDiagram_' + idx).length == 0){
	    	var html = '';
	    	var src = c_act_explorer_url + '/approval/manage/getDiagaram.do?processID=' + piid;
	    	html += '<div id="divDiagram_' + idx + '"><br/><br/>';
	    	html += '<h3>● activiti diagram</h3>';
	    	html += '<iframe src="' + src + '" frameborder="0" width="98%" height="500" marginwidth="0" marginheight="0" scrolling="yes">';
	    	html += '</div>';
	    	$target.append(html);
	    } else {
	    	$('#divDiagram_' + idx).slideToggle("fast");
	    }
	}
	
	function validateJsonVal(val){
		var ret;
		if (typeof(val) != 'undefined' && val != null)
		{
		    ret = val;
		} else {
			ret = '';
		}
		
		return ret;
	}
	
	// 새로고침
	function Refresh(){
		//CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		window.parent.location.reload();
	}
	
	function openFormInstPopup(){
		CFN_OpenWindow("monitoringFormInstPopup.do?FormInstID=" + g_FormInstID + "&archived=" + g_archived , "", 700, (window.screen.height - 100), "both");
	}
	
	function openActivitiPopup(){
		CFN_OpenWindow("monitoringActivitiPopup.do", "", 800, 465, "fix");
	}
	
	function openUpdateDomainDataPopup(){
		CFN_OpenWindow("monitoringDomaindataPopup.do", "", 800, 320, "fix");
	}
	
	function openUpdateVariablePopup(){
		CFN_OpenWindow("monitoringVariablePopup.do", "", 800, 350, "fix");
	}
	
	// 결재자 클릭시
	function onClickInMonitoring(obj, dpath){
		var domainObj = $.parseJSON(g_domainData);

		dpath = dpath.replaceAll("/", ">");
		
		$("#APVLIST").val(g_domainData);
		
		if(dpath != "" && !g_isDistribution){
			var dObj = $$(domainObj).find(dpath).nodename();
			
			$("#hidDPath").val(dpath);
			
			if(dObj == "person"){
				$("#apvLineChangeDatas").show();
				
				var person = $$(domainObj).find(dpath);
				
				var personName = $$(person).attr("name");
				var personType = "("+$$(person).parent().parent().attr("name")+")";
				var datecompleted = $$(person).find("taskinfo").attr("datecompleted");
				var comment = $$(person).find("taskinfo>comment").attr("#text");
				var result = $$(person).find("taskinfo").attr("result");
				
				if($$(person).find("taskinfo").attr("status") == "pending" || $$(person).find("taskinfo").attr("status") == "reserved"){
					// 담당자
					if($$(person).parent().parent().parent().index() > 0 && $$(person).parent().parent().parent().find("step").concat().length == 1 && $$(person).find("taskinfo").attr("kind") == "normal"){
						$("#btnChgNowApv").hide();
						$("#btnChgAfterApv").hide();
						$("#btnApprove").hide();
						$("#btnCharge").show();
						$("#btnAbort").hide();
						$("#btnWithdraw").hide();
					}else{
						$("#btnChgNowApv").show();
						$("#btnChgAfterApv").show();
						$("#btnApprove").show();
						$("#btnCharge").hide();
						
						if($$(person).parent().parent().index() == 1) { // 회수
							$("#btnWithdraw").show();	
						}
						else { // 기안취소
							$("#btnAbort").show();	
						}
					}
				}else{
					$("#btnChgNowApv").hide();
					$("#btnChgAfterApv").hide();
					$("#btnApprove").hide();
					$("#btnCharge").hide();
					$("#btnAbort").hide();
					$("#btnWithdraw").hide();
				}
				$("#btnConsent").hide();
				$("#btnChgRecApv").hide();
				
				// 합의
				if($$(person).find("taskinfo").attr("kind") == "consult"){
					$("#resultTH").show();
					$("[name=result]").parent().show();
					$("[name=result][value="+result+"]").prop("checked", true);
				}else{
					$("#resultTH").hide();
					$("[name=result]").parent().hide();
				}
				
				if($$(person).find("taskinfo").attr("status") != "completed" && $$(person).find("taskinfo").attr("status") != "rejected"){
					$("#datecompleted").attr("disabled", "disabled");
					$("#comment").attr("disabled", "disabled");
					$("[name=result]").attr("disabled", "disabled");
					$("[name=result]").prop("checked", false);
					$("#btnSaveDomainData").attr("disabled", "disabled");
				}else{
					$("#datecompleted").removeAttr("disabled");
					$("#comment").removeAttr("disabled");
					$("[name=result]").removeAttr("disabled");
					$("#btnSaveDomainData").removeAttr("disabled");
				}
				
				//데이터 바인딩
				$("#approveName").html(personName);
				$("#approveType").html(personType);
				$("#datecompleted").val(datecompleted);
				$("#comment").val(Base64.b64_to_utf8(comment != null ? comment : ""));
				
			}else if(dObj == "ou"){
				$("#apvLineChangeDatas").hide();
				
				var ou = $$(domainObj).find(dpath);
				
				if($$(ou).find("person").concat().length == 0){
					// 부서합의,부서협조
					if($$(ou).find("taskinfo").attr("kind") == "consult" || $$(ou).parent().attr("routetype") == "assist"){
						if($$(ou).find("taskinfo").attr("status") == "pending"){
							$("#btnConsent").show();
						}else{
							$("#btnConsent").hide();
						}
						$("#btnChgRecApv").hide();
					}else{
						// 수신부서
						if($$(ou).parent().parent().index() > 0 && $$(ou).parent().parent().find("step").concat().length == 1 && $$(ou).find("taskinfo").attr("status") == "pending"){
							$("#btnChgRecApv").show();
						}else{
							$("#btnChgRecApv").hide();
						}
						$("#btnConsent").hide();
					}
				}else{
					$("#btnConsent").hide();
					$("#btnChgRecApv").hide();
				}
				
				$("#btnChgAfterApv").hide();
				$("#btnChgNowApv").hide();
				$("#btnApprove").hide();
				$("#btnCharge").hide();
				$("#btnAbort").hide();
				$("#btnWithdraw").hide();
			}
		}else if(g_isDistribution){
			$("#apvLineChangeDatas").hide();
			Common.Warning("이미 배포된 결재선은 다음 화면을 이용한 결재선 변경이 불가합니다.");
		}else{
			$("#apvLineChangeDatas").hide();
		}
	}
	
	//결재선 필수체크
	function chkAutoApprovalLine(){
		
		//결재팝업 호출 여부
		var apvlinePopupYN; //결재선지정 팝업여부
		try{
			if(typeof chkAutopopup != "undefined" && chkAutopopup!='') apvlinePopupYN = true;
		}catch(e){
			
		}

	    //합의자 체크
	    if (getInfo("AutoApprovalLine.Agree.autoChk") == "Y") {
	        if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
	            var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
	            if ($$(oAutoLineAgree).find("step").concat().length > 0) {
	            	var jsonApv;
					if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	                else jsonApv = chkAutopopup.$$_m_oApvList;
	                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
	                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
	                    var oChkNode = $$(oAutoLineAgree).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
	                    if (oChkNode.length > 0) {
	                        $$(oChkNode).remove();
	                    }
	                }
	                if ($$(oAutoLineAgree).find("step>ou>person").concat().length > 0) {
	                    var sAlert = "[";
	                    $$(oAutoLineAgree).find("step>ou>person").concat().each(function(i, elm){
	                    	if (i > 0) sAlert += ", ";
	                        sAlert += getLngLabel(elm.attr("name"), false);
	                        //sAlert += " " + getLngLabel(elm.attr("position"), true);
	                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
	                    });
	                    
	                    sAlert += "]";
	                    sAlert = Common.getDic("msg_apv_autoChkAgree").replace("{0}", sAlert);
	                    if(!apvlinePopupYN){
	                    	alert(sAlert);
	                        return true;	
	                    }else{
	                    	chkAutopopup.alert(sAlert);
	                    	return true;
	                    }
	                }
	            }
	        }
	    }
	    //협조자 체크
	    if (getInfo("AutoApprovalLine.Assist.autoChk") == "Y") {
	        if (getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != undefined) {
	            var oAutoLineAssist = $.parseJSON(getInfo("AutoApprovalLine.Assist.WorkedApprovalLine"));
	            if ($$(oAutoLineAssist).find("step").concat().length > 0) {
					var jsonApv;            	
					if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	                else jsonApv = chkAutopopup.$$_m_oApvList;
	                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person']");
	                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
	                    var oChkNode = $$(oAutoLineAssist).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
	                    if (oChkNode.length > 0) {
	                        $$(oChkNode).remove();
	                    }
	                }
	                if ($$(oAutoLineAssist).find("step>ou>person").concat().length > 0) {
	                    var sAlert = "[";
	                    $$(oAutoLineAssist).find("step>ou>person").concat().each(function(i, elm){
	                    	if (i > 0) sAlert += ", ";
	                        sAlert += getLngLabel(elm.attr("name"), false);
	                        //sAlert += " " + getLngLabel(elm.attr("position"), true);
	                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
	                    });
	                    
	                    sAlert += "]";
	                    sAlert = Common.getDic("msg_apv_autoChkAssist").replace("{0}", sAlert);
	                    if(!apvlinePopupYN){
	                    	alert(sAlert);
	                        return true;	
	                    }else{
	                    	chkAutopopup.alert(sAlert);
	                    	return true;
	                    }
	                }
	            }
	        }
	    }
	    //결재자 체크
	    if (getInfo("AutoApprovalLine.Approval.autoChk") == "Y") {
	        if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
	            var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
	            if ($$(oAutoLineApproval).find("step").concat().length > 0) {
					var jsonApv;            	
					if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	                else jsonApv = chkAutopopup.$$_m_oApvList;
	                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']").has("ou>person>taskinfo[kind!=skip]");
	                for (var i = 0; i < $$(oAppList).concat().length; i++) {
	                    var oChkNode = $$(oAutoLineApproval).find("step").concat().has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
	                    if (oChkNode.length > 0) {
	                        //$$(oChkNode).remove();
	                    	$$(oAutoLineApproval).find("step").remove(oChkNode.index());
	                    }
	                }
	                if ($$(oAutoLineApproval).find("step").concat().length > 0) {
	                    var sAlert = "[";
	                    for (var i = 0; i < $$(oAutoLineApproval).find("step").concat().length; i++) {
	                        if (i > 0) sAlert += ", ";
	                        sAlert += getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("name"), false);
	                        //sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("position"), true);
	                        g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
	                    }
	                    sAlert += "]";
	                    sAlert = Common.getDic("msg_apv_autoChkApproval").replace("{0}", sAlert);
	                    if(!apvlinePopupYN){
	                    	alert(sAlert);
	                        return true;	
	                    }else{
	                    	chkAutopopup.alert(sAlert);
	                    	return true;
	                    }
	                }
	            }
	        }
	    }
	    //참조자 체크
	    if (getInfo("AutoApprovalLine.CCAfter.autoChk") == "Y") {
	        if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
	            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
	            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
					var jsonApv;
	            	if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	                else jsonApv = chkAutopopup.$$_m_oApvList;
	                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
	                for (var i = 0; i < $$(oAppList).concat().length; i++) {
	                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
	                    if (oChkNode.length > 0) {
	                        //$$(oChkNode).remove();
	                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                    }
	                }
	                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
	                for (var i = 0; i < $$(oAppList).concat().length; i++) {
	                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
	                    if (oChkNode.length > 0) {
	                    	//$$(oChkNode).remove();
	                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                    }
	                }
	                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
	                    var sAlert = "[";
	                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
	                        if (i > 0) sAlert += ", ";
	                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
	                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
	                        } else {
	                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
	                            //sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
	                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
	                        }
	                    }
	                    sAlert += "]";
	                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
	                    if(!apvlinePopupYN){
	                    	alert(sAlert);
	                        return true;	
	                    }else{
	                    	chkAutopopup.alert(sAlert);
	                        return true;
	                    }
	                }
	            }
	        }
	    }
	    //참조자 체크(사전)
	    if (getInfo("AutoApprovalLine.CCBefore.autoChk") == "Y") {
	        if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
	            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
	            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
					var jsonApv;
	            	if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	                else jsonApv = chkAutopopup.$$_m_oApvList;
	                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
	                for (var i = 0; i < $$(oAppList).concat().length; i++) {
	                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
	                    if (oChkNode.length > 0) {
	                    	//$$(oChkNode).remove();
	                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                    }
	                }
	                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
	                for (var i = 0; i < $$(oAppList).concat().length; i++) {
	                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
	                    if (oChkNode.length > 0) {
	                    	//$$(oChkNode).remove();
	                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                    }
	                }
	                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
	                    var sAlert = "[";
	                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
	                        if (i > 0) sAlert += ", ";
	                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
	                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
	                        } else {
	                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
	                            //sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
	                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
	                        }
	                    }
	                    sAlert += "]";
	                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
	                    if(!apvlinePopupYN){
	                    	alert(sAlert);
	                        return true;	
	                    }else{
	                    	chkAutopopup.alert(sAlert);
	                    	return true;
	                    }
	                }
	            }
	        }
	    }
	}
	
	// 결재선 수정 저장
	function saveDomainData(){
		var dpath = $("#hidDPath").val();
		var domainObj = $.parseJSON(g_domainData);
		var person = $$(domainObj).find(dpath);
		
		var datecompleted = $("#datecompleted").val();
		var comment = $("#comment").val();
		var result = $('input[name=result]:checked').val();
		
		// 합의
		if($$(person).find("taskinfo").attr("kind") == "consult"){
			$$(person).find("taskinfo").attr("result", result);
			
			if(result == "agreed"){
				$$(person).find("taskinfo").attr("status", "completed");
			}else{
				$$(person).find("taskinfo").attr("status", "rejected");
			}
		}
		
		if($$(person).find("taskinfo>comment").length > 0 && comment != ""){
			$$(person).find("taskinfo>comment").attr("#text", Base64.utf8_to_b64(comment));
		}else if($$(person).find("taskinfo>comment").length > 0 && comment == ""){
			$$(person).find("taskinfo").remove("comment");
		}else if($$(person).find("taskinfo>comment").length == 0 && comment != ""){
			$$(person).find("taskinfo").append("comment", {});
			$$(person).find("taskinfo>comment").attr("#text", Base64.utf8_to_b64(comment));
		}
		
		$$(person).find("taskinfo").attr("datecompleted", datecompleted);
		
		$("#APVLIST").val(JSON.stringify($$(domainObj).json()));
		
		goBatchApvLine("", true);
	}
</script>
<br/>
<h3 class="con_tit_box" style="padding:10px;">
	<span class="con_tit">엔진 Monitoring</span>	
</h3>
<form id="form1">
    <div id="divProcInfo" style="padding:10px;">
    	<div class="topbar_grid">
    		<b>결재진행 현황</b>
    		<div id="apvLineChageBtns">
    			<input type="button" class="AXButton Blue" value="새로고침" onclick="Refresh();">
	   			<input type="button" id="btnChgAfterApv" class="AXButton Blue" value="이후 결재자 변경" onclick="changeAfterApvLine();" style="display: none">
	   			<input type="button" id="btnChgNowApv" class="AXButton Blue" value="현결재자 변경" onclick="changeNowApvLine();" style="display: none">
	   			<input type="button" id="btnApprove" class="AXButton Blue" value="수동 결재하기" onclick="approveByAdmin();" style="display: none">
	   			<input type="button" id="btnCharge" class="AXButton Blue" value="담당자 변경" onclick="changeChargePerson();" style="display: none">
	   			<input type="button" id="btnChgRecApv" class="AXButton Blue" value="수신부서 변경" onclick="changeReceiptDept();" style="display: none">
	   			<input type="button" id="btnConsent" class="AXButton Blue" value="강제합의" onclick="consentByAdmin();" style="display: none">
	   			<input type="button" id="btnWithdraw" class="AXButton Blue" value="회수" onclick="withdrawByAdmin();" style="display: none">
	   			<input type="button" id="btnAbort" class="AXButton Blue" value="기안취소" onclick="approvalByAdminComment('ABORT');" style="display: none">
	   			<input type="button" id="btnAddReceipt" class="AXButton Blue" value="추가발송" onclick="addReceipt();" style="display: none">
	   			<input type="button" id="btnDeleteReceipt" class="AXButton Blue" value="수신처 삭제" onclick="deleteReceipt();" style="display: none">
	   		</div>
    	</div>
    	<div style="height:200px">
	    	<div id="graphicDiv">
	    	</div>
    	</div>
    	<div id="apvLineChangeDatas" style="display: none">
    		<table class="AXFormTable setStepData">
    			<tr> 
    				<th style="text-align: center">결재자 명</th>
    				<th id="resultTH" style="text-align: center;display:none">결재 상태</th>
    				<th style="text-align: center">결재 시간</th>
    				<th style="text-align: center">의견</th>
    				<td rowspan="2" style="width:10%">
    					<input type="button" class="AXButton" id="btnSaveDomainData" onclick="saveDomainData();" value="저장" />
    				</td>
    			</tr>
    			<tr>
    				<td>
    					<span id="approveName"></span>
    					<span id="approveType"></span>
    				</td>
    				<td><!-- 합의할 경우에만 보임 -->
    					<input type="radio" id ="resultAgreed" name="result" value="agreed">동의&nbsp;
    					<input type="radio" id ="resultDisagreed" name="result"  value="disagreed">거부
    				</td>
    				<td>
    					<input type="text" id ="datecompleted" style="width:95%;text-align: center">
    					<br><span style="color:red;font-size:9pt">* 날짜 형식을 반드시 지켜주시길 바랍니다.<br>(yyyy-mm-dd HH:MM:SS)</span>
    				</td>
    				<td><textarea id ="comment" style="resize:none;width:95%" rows="3"></textarea></td>
    			</tr>
    		</table>
    		<input type="hidden" id="hidDPath" value=""/>
    	</div>
    	<div class="topbar_grid">
    		<input type="button" class="AXButton Red" id="btnOpenFormInst" value="FormInstance 테이블 수정" onclick="openFormInstPopup();">
    		<input type="button" class="AXButton Red" id="btnOpenActiviti" value="Activiti 엔진 호출" onclick="openActivitiPopup();">
    		<input type="button" class="AXButton Red" id="btnOpenUpdateDomaindata" value="Activiti 결재선 변경" onclick="openUpdateDomainDataPopup();" >
    		<input type="button" class="AXButton Red" id="btnOpenUpdateVariable" value="Activiti Variable 변경" onclick="openUpdateVariablePopup();" >
    		<br><br>
    		<b>[도움말]</b><br>
    		<b>FormInstance 테이블 수정 : </b>양식의 본문 관련 정보를 가지고 있는 FormInstance 테이블의 데이터를 조회하고 수정이 가능하다.<br>
   			<b>Activiti 엔진 호출 : </b>현재 활성화 되어 있는 Task에 대해서 Activiti 엔진 요청이 가능하다.<br>
   			<b>Activiti 결재선 변경 : </b>결재선 길이가 길어서 act_ru_variable 테이블에서 수정불가한 경우 사용<br>
   			<!-- <b>테이블 데이터 업데이트 : </b>결재와 관련된 각 테이블들, 컬럼의 데이터 수정이 가능하다.<br> -->
   			<br>
    		<font color="red">
    			<b>*완료된 양식에 대해서 결재시간 및 의견 등의 결재선 데이터를 제외한 데이터 수정이 불가합니다.</b>
    		</font>
    	</div>
    	<div class="topbar_grid">
    		<b>Process 정보</b>
    	</div>
    	<table id="tblProcInfo" class="table1_12" width="100%">
   			<thead>
    			<th><div>ProcessID</div></th>
    			<th><div>ProcessDescriptionID</div></th>
    			<th><div>ParentProcessID</div></th>
    			<th><div>ProcessName</div></th>
    			<th><div>DocSubject</div></th>
    			<th><div>BusinessState</div></th>
    			<th><div>InitiatorID</div></th>
    			<th><div>InitiatorName</div></th>
    			<th><div>InitiatorUnitID</div></th>
    			<th><div>InitiatorUnitName</div></th>
    			<th><div>FormInstID</div></th>
    			<th><div>ProcessState</div></th>
    			<th><div>StartDate</div></th>
    			<th><div>EndDate</div></th>
   			</thead>
    	</table>
    	<input type="hidden" id="APVLIST" value=""/>
    </div>
</form>