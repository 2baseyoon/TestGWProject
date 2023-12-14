<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"></span><%-- API 호출로그관리 --%>
</h3>
<style>
/* a { cursor : pointer; } */
#ErrorStackTrace_container .divpop_body {
	padding:0px;
}
#ErrorStackTrace_container .divpop_body textarea {
	margin:0;
	outline:none;
	border:none;
	font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left
}
* {
	box-sizing : border-box;
}
</style>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
<%-- 			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteAPIConfig();"/> --%>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_Company"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" maxDate="" minDate="" style="width: 85px" class="AXInput" />
			
			<select id="searchTarget" class="AXSelect W100"></select>
			<input type="text" id="searchKeyword" class="AXInput" onkeypress="if (event.keyCode==13){ searchReqLogGrid(); return false;}" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchReqLogGrid();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="requestLogGrid"></div>
	</div>
</form>

<script type="text/javascript">
	var requestLogGrid;
	var headerData;
	var lang = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		requestLogGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
// 		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'LogID', label:'ID', width:'70', align:'center', display:false},
            		 {key:'CompanyName',  label:'<spring:message code="Cache.lbl_Company"/>', width:'70', align:'center', formatter: function(){
            			 return CFN_GetDicInfo(this.item.CompanyName, lang);
            		 }},
		             {key:'SystemType', label:'<spring:message code="Cache.lbl_System_Name"/>', width:'120', align:'center'},
		             {key:'URL', label:'Path', width:'150', align:'center'},
		             {key:'Version', label:'Version', width:'70', align:'center'},
		             {key:'ReqDay', label:'<spring:message code="Cache.lbl_reqDay"/>', width:'90', align:'center'},
		             {key:'ReqTime', label:'<spring:message code="Cache.lbl_reqTimestamp"/>', width:'140', align:'center', sort:"desc"},
		             {key:'ResTime', label:'<spring:message code="Cache.lbl_resTimestamp"/>', width:'140', align:'center'},
		             {key:'ElapsedTTime', label:'<spring:message code="Cache.lbl_elapsedTime_Total"/>', width:'90', align:'center', formatter : function(){
		            	 return this.item.ElapsedTTime + " ms";
		             }},
		             {key:'State', label:'<spring:message code="Cache.lbl_State"/>', width:'90', align:'center', formatter : function(){
		            	 var msg = "";
		            	 switch(this.item.State) {
		            	 	case "SUCCESS" : msg = "<span style='color:blue'><spring:message code='Cache.SuccessState_C'/></span>"; break;
		            	 	case "EXCEEDED_LIMIT" : msg = "<span style='color:red'><spring:message code='Cache.lbl_reqExceedLimit'/></span>"; break;
		            	 	case "AUTH_ERROR" : msg = "<span style='color:red'><spring:message code='Cache.SuccessState_F'/></span>"; break;
		            	 	case "FAIL" : msg = "<span style='color:red'><spring:message code='Cache.SuccessState_F'/></span>"; break;
		            	 	default : msg = "<span style='color:red'><spring:message code='Cache.SuccessState_F'/></span>"; break;
		            	 }
		            	 return "<a href='#' onclick='showLogDetail(true, \""+ this.item.LogID +"\"); return false;'>"+msg+"</a>"
		             }},
		             {key:'IP', label:'IP',   width:'115', align:'center'},
		             {key:'Message', label:'<spring:message code="Cache.lbl_Message"/>', sort:false, width:'300', align:'left', formatter: function(){
		            	 return "<a href='#' onclick='showErrorDetail(\""+ this.index +"\"); return false;'>"+this.item.Message.substring(0, 500)+"</a>";
		             }}
			      	];
		setGrid();			// 그리드 세팅
		
		setDateTypeSelect();
		setSearchTargetSelect();
		
		setTimeout(function(){setDate();}, 10);
		
		//searchReqLogGrid();
	}
	
	//그리드 세팅
	function setGrid(){
		var hasAll = true;
		coviCtrl.renderDomainAXSelect("companySelectBox", lang, null, null, '', hasAll); // 전체표시
		
		requestLogGrid.setGridHeader(headerData);
		requestLogGrid.setGridConfig({
			targetID : "requestLogGrid",
			height:"auto"
		});
	}
	
	function setDate(){
		var date_str = $("#searchDateType option:selected").val();
		
		var thisyear = new Date();
		var startdate = "";
		var enddate = "";
		
		if(date_str == "Today"){
			startdate = XFN_getCurrDate("-", "dash");
		} else if(date_str == "Yesterday"){
			startdate = XFN_addMinusDateByCurrDate(-1, "-", "dash");
		} else if(date_str == "BeforeYesterday"){
			startdate = XFN_addMinusDateByCurrDate(-2, "-", "dash");
		} else if(date_str == "AWeek"){
			startdate = XFN_addMinusDateByCurrDate(-6, "-", "dash");
		} else if(date_str == "AMonth"){
			startdate = XFN_addMinusDateByCurrDate(-30, "-", "dash");
		} else if(date_str == "TwoMonth") {
			startdate = XFN_addMinusDateByCurrDate(-61, "-", "dash");
		} else if(date_str == "ThisYear"){
			thisyear.setMonth(0);	
			thisyear.setDate(1);
			startdate = thisyear.getFullYear() + "-" + (thisyear.getMonth()+1 < 10 ? "0"+(thisyear.getMonth()+1) : thisyear.getMonth()+1) + "-" +(thisyear.getDate() < 10 ? "0"+thisyear.getDate() : thisyear.getDate());					// XFN_TransDateLocalFormat(< % = _strThisYear % > + ".01.01");
			enddate = thisyear.getFullYear() + "-12-31"; 
		}
		
		if(enddate == ""){
			enddate = XFN_getCurrDate("-", "dash");
		}
		
		document.getElementById("startdate").value = startdate;
		document.getElementById("enddate").value = enddate;
		
		searchReqLogGrid();
	}
	
	function searchReqLogGrid(){
		
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var text = $("#searchKeyword").val();
		
		if((enddate.split("-")[0] - strdate.split("-")[0]) > 2){
			dateVali = false;
		}else if((enddate.split("-")[0] - strdate.split("-")[0]) == 2){
			if(enddate.split("-")[1] > strdate.split("-")[1]){
				dateVali = false;
			}else if(enddate.split("-")[1] == strdate.split("-")[1] && enddate.split("-")[2] > strdate.split("-")[2]){
				dateVali = false;
			}
		}
		
		if(!dateVali){
			Common.Inform("<spring:message code='Cache.msg_CanSelectTwoYearAgo'/>", "Information Dialog", function(result) {
				$("#startdate").val(XFN_getCurrDate("-", "dash"));
				$("#enddate").val(XFN_getCurrDate("-", "dash"));
				
				strdate = $("#startdate").val();
				enddate = $("#enddate").val();
			});			
			
			return false;
		}
		
		requestLogGrid.page.pageNo = 1;
		requestLogGrid.bindGrid({
 			ajaxUrl:"/covicore/api/config/getRequestLogList.do",
 			ajaxPars: {
 				"DomainID" : $("#companySelectBox").val(),
 				"SearchTarget" : $("#searchTarget").val(),
 				"StartDate":strdate,
 				"EndDate":enddate,
 				"SearchKeyword" : text
 			}
		});
	}

	function showLogDetail(pModal, LogID) {
   		parent.Common.open("","ShowRequestLog",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APIRequestLogDetailPopup.do?LogID="+LogID,"700px","500px","iframe",pModal,null,null,true);
	}
	
	function showErrorDetail(index) {
   		var ErrorMessage = requestLogGrid.list[index].Message;
   		Common.open("","ErrorStackTrace", "Error Message", "<textarea style='' readonly>"+ErrorMessage+"</textarea>", "900px","530px","html",true,null,null,true);
	}
	
	function setDateTypeSelect(){
		$("#searchDateType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"<spring:message code='Cache.btn_Today'/>", "value":"Today"},
                       {"name":"<spring:message code='Cache.btn_Yesterday'/>", "value":"Yesterday"},
                       {"name":"<spring:message code='Cache.btn_BeforeYesterday'/>", "value":"BeforeYesterday"},
                       {"name":"<spring:message code='Cache.btn_AWeek'/>", "value":"AWeek"},
                       {"name":"<spring:message code='Cache.btn_AMonth'/>", "value":"AMonth"},
                       {"name":"<spring:message code='Cache.btn_TwoMonth'/>", "value":"TwoMonth"},
                       {"name":"<spring:message code='Cache.btn_AYear'/>", "value":"ThisYear"}]
        });
	}
	
	function setSearchTargetSelect () {
		$("#searchTarget").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"Path", "value":"PATH"},
                       {"name":"IP", "value":"IP"}]
        });
	}
	// Delete
	/*
	function deleteRequestLog(){
		var deleteobj = requestLogGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteID = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteID = deleteobj[i].LogID;
				}else{
					deleteID = deleteID + "," + deleteobj[i].LogID;
				}
			}
			
			Common.Confirm('<spring:message code="Cache.msg_ReallyDelete"/>', "Confirm", function (result) {
				if(result) {
					$.ajax({
						type:"POST",
						data:{
							"LogID" : deleteID
						},
						url:"/api/config/deleteRequestLog.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							}
							requestLogGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/api/config/deleteRequestLog.do", response, status, error);
						}
					});
					
				}
			});
		}
	}
	*/
	
	// 새로고침
	function Refresh(){
		searchReqLogGrid();
	}
	
</script>