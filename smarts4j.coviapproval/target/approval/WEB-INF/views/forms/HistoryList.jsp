<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String mode = StringUtil.replaceNull(request.getParameter("mode"),"");
	String ProcessID  = StringUtil.replaceNull(request.getParameter("ProcessID"),"");
	String FormInstID  = StringUtil.replaceNull(request.getParameter("FormInstID"),"");
	String FormPrefix  = StringUtil.replaceNull(request.getParameter("FormPrefix"),"");
	String workitemID  = StringUtil.replaceNull(request.getParameter("workitemID"),"");
	String performerID  = StringUtil.replaceNull(request.getParameter("performerID"),"");
	String processdescriptionID  = StringUtil.replaceNull(request.getParameter("processdescriptionID"),"");
	String userCode  = StringUtil.replaceNull(request.getParameter("userCode"),"");
	String gloct  = StringUtil.replaceNull(request.getParameter("gloct"),"");
	String admintype  = StringUtil.replaceNull(request.getParameter("admintype"),"");
	String archived  = StringUtil.replaceNull(request.getParameter("archived"),"");
	String usisdocmanager  = StringUtil.replaceNull(request.getParameter("usisdocmanager"),"");
	String listpreview  = StringUtil.replaceNull(request.getParameter("listpreview"),"");
	String subkind  = StringUtil.replaceNull(request.getParameter("subkind"),"");
	String type  = StringUtil.replaceNull(request.getParameter("type"),"Pop");

%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>

<script>
	var type	= "<%=type%>";
	var ListGrid = new coviGrid();
	var FormInstID = ${FormInstID};
	var openID = CFN_GetQueryString("CFN_OpenWindowName");
	var oFormJson = new Object(); //양식에서 사용하는 변수.

	var selRevision = "1";	// 선택한 히스토리 rev
	
	$(document).ready(function () {
 		setGrid();
		SetTab();
	});
	
	// 기존 iframe
   	$(function() {
   		$("#orgFrame").load(function() {
   			$("#orgHtml").val($(this.contentDocument).find('body').html());
		});
	});
	
 	// 선택한 iframe
   	$(function() {
		$("#selFrame").load(function() {
			$("#selHtml").val($(this.contentDocument).find('body').html());
			
			getDocDiff();
		});
	});
	
	function clickURNameRow(pRevision, pRowIndex){
		selRevision = pRevision;
		
		getHistoryModifiedData(pRevision);
		openFormFrame(pRevision, pRowIndex);
	}

	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}

	function setGridHeader(){
		 var headerData =[{key:'sRevision', label:'<spring:message code="Cache.lbl_Modify" />', width:'12', align:'center', sort:false},
					      {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_chgname" />', width:'12', align:'center', sort:false, formatter: function(){
					    	return "<a href='#' onclick='clickURNameRow("+this.item.Revision+", "+this.item.sRevision+");'>" + CFN_GetDicInfo(this.item.UR_Name) + "</a>";
					      }},
		                  {key:'APST', label:'<spring:message code="Cache.lbl_ApprovalLine" />',  width:'12', align:'center', sort:false},
					      {key:'Contents', label:'<spring:message code="Cache.lbl_apv_apvcontent" />',  width:'12', align:'center', sort:false},
					      {key:'ATTACH_FILE_INFO', label:'<spring:message code="Cache.lbl_apv_AddFile" />',  width:'12', align:'center', sort:false},
					      {key:'ModDate', label:'<spring:message code="Cache.lbl_apv_chgdate" />',  width:'15', align:'center', sort:false}];
		 
		 ListGrid.setGridHeader(headerData);
	}


	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"225",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count' />",
                page: {
                	display: false,
					paging: false
                },
                body:{
                	/* onclick:function(){
                		if(this.c != 0) //this.c = 열 번호 체크 박스 말고 다른 부분을 누를 경우
                			getHistoryModifiedData(this.list[this.index].Revision);
                			openFormFrame(this.list[this.index].Revision);
                	} */
                }
		}

		ListGrid.setGridConfig(configObj);
	}

	function setListData(){

		ListGrid.bindGrid({
			ajaxUrl: "getHistoryListData.do",//조회 컨트롤러
			ajaxPars: {FormIstID : FormInstID},
			onLoad: function(){
				// 조회할 목록이 있을 경우에만
				if(ListGrid.list.length > 0)
					clickURNameRow(1, 1);
			}
		});
	}

	function SetTab(){
		$('#AXTabsLarge').bindTab({
			theme:"AXTabs",
			value:"R",
			overflow:"visible",
			options:[{optionValue:"R", optionText:"<spring:message code='Cache.lbl_apv_chglog' />"},
			         {optionValue:"F", optionText:"<spring:message code='Cache.lbl_apv_history_doc_diff' />"}],
			onchange:function(obj, value) {
				clickURNameRow(1, 1);
				
/* 				if(value == "R")
				{
					$('#formFrame').attr('src', "");
				}
				else if(value == "F")
				{
					$('#formFrame').attr('src', "");
				} */
			}
		});
	}

	function btnClose_Click(){
		Common.Close();
	}

	function openFormFrame(pRevision, pRowIndex){
		var szURL = "";

		if(type == "List"){
			var mode = "<%=mode%>";
			var ProcessID = "<%=ProcessID%>";
			var FormInstID = "<%=FormInstID%>";
			var FormPrefix = "<%=FormPrefix%>";
			var workitemID = "<%=workitemID%>";
			var performerID = "<%=performerID%>";
			var processdescriptionID = "<%=processdescriptionID%>";
			var userCode = "<%=userCode%>";
			var gloct = "<%=gloct%>";
			var admintype = "<%=admintype%>";
			var archived = "<%=archived%>";
			var usisdocmanager = "<%=usisdocmanager%>";
			var listpreview = "<%=listpreview%>";
			var subkind = "<%=subkind%>";
			szURL = "approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+workitemID+"&performerID="+performerID+"&processdescriptionID="+processdescriptionID+"&userCode="+userCode+"&gloct="+gloct+"&formID=&forminstanceID=&formtempID=&forminstancetablename=&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"";
		}else{
			szURL = top.opener.location.href;
		}

		if (szURL != "") {
            // href='#' 인 경우 # 제거
            szURL = szURL.replace("#", "");
        }

		szURL += '&ishistory=true';
        szURL += '&historyrev=' + pRevision;
		
		if (pRowIndex > 1) {
			$("#orgHtml").val("");
			$("#orgFrame").attr("src", szURL.replace(/historyrev\=\d/g, "historyrev=" + (pRowIndex - 1).toString()));
		}
		
		$("#selHtml").val("");
		$("#selFrame").attr("src", szURL);
	}

	function getHistoryModifiedData(pRevision){
		if(!oFormJson[pRevision]) {
			$.ajax({
				type:"POST",
				url:"getHistoryModifiedData.do",
				async:false,
				data:{
					formInstID:FormInstID,
					revision:pRevision
				},
				success:function(data){
					oFormJson[pRevision] = JSON.stringify(data);
				},
				error:function(response, status, error){
					CFN_ErrorAjax("getHistoryModifiedData.do", response, status, error);
				}
			});
		}
	}

 	// 본문 내용 비교
 	function getDocDiff() {
		if(!$("#orgHtml").val() || !$("#selHtml").val()) {
			setTimeout("getDocDiff()", 500);
			return;
		}
		
		// 선택한 탭 ID
		var tabId = "";
   		$('.AXTabsTray a').each(function(){
   			if($(this).hasClass('AXTab  on') || $(this).hasClass('AXTab on')) {
   		    	tabId = $(this).attr('id');
   			}
   		});
   		
		// 선택한 탭이 본문내용비교, 원본이 아닐때
		if (tabId == "AXTabsLarge_AX_Tabs_AX_1" && selRevision != "1") {
			$.ajax({
				type:"POST",
				url:"form/diffForm.do",
				async:false,
				data:{
					orgHtml:$("#orgHtml").val(),
					selHtml:$("#selHtml").val()
				},
				success:function(data){
					var $div = $(data);
					var formBox = $div.find("#formBox").html();
					
					$("#selFrame").contents().find("#formBox").html(formBox);
				},
				error:function(response, status, error){
					CFN_ErrorAjax("form/diffForm.do", response, status, error);
				}
			});
		}
 	}
</script>
</head>
<body>
<form>

	<div class="layer_divpop ui-draggable" id="testpopup_p" style="width: 100%; min-width:840px; height:95%; z-index: 51; overflow:hidden;" source="iframe" modallayer="false" layertype="iframe" pproperty="">

		<!-- 팝업 Contents 시작 -->
		<div class="divpop_contents" style=" height:95%;">
			<div class="pop_header" id="testpopup_ph">
				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title">
					<span class="divpop_header_ico"><spring:message code='Cache.lbl_apv_History' /></span>
				</h4>
			</div>
			<div class="popBox" style="padding-right: 20px;">
				<div class="AXTabsLarge" id="AXTabsLarge" /></div>
				<div class="coviGrid">
					<div id="ListGrid"></div>
				</div>
			</div>
			<div style="width:100%; height:53vh;">
				<iframe width=0 height=0 frameborder=0 scrolling=no id="orgFrame" name="orgFrame" style="margin-top:0"></iframe>
				<iframe width="97%" height="100%" id="selFrame" style="border-width: 0px; /* position:relative; */ top:-100px;"></iframe>
			</div>
		</div>
		<!-- 팝업 Contents 끝 -->

		<!-- 하단버튼 시작 -->
		<div class="popBtn" style="background-color: white; bottom: 0px; position: fixed;" >
			<input type="button" class="owBtn mr30" onclick="btnClose_Click();" value="<spring:message code='Cache.btn_apv_close' />"/>
		</div>
	</div>

</form>

<form id="diffForm" name="diffForm" method="post" style="visibility:hidden">
	<textarea id="orgHtml" name="orgHtml" rows="" cols="" style="display:none;"></textarea>
	<textarea id="selHtml" name="selHtml" rows="" cols="" style="display:none;"></textarea>
</form>
</body>
</html>

<!--본문비교 기능-->
<!-- <textarea style="display:none" id="txtHistory1" name="txtHistory1"></textarea>
<textarea style="display:none" id="txtHistory2" name="txtHistory2"></textarea> -->