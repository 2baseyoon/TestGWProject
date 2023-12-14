<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!doctype html>
<html lang="ko">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
.AXGrid input:disabled{background-color:#Eaeaea}
</style>
<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104; overflow-y:auto; height:100%;">
		<div class="ATMgt_popup_wrap">
			<!-- 검색 영역 -->
			<div class="ATMgt_schbox">
				<select class="selectType02 mb5" id="deptList">
				</select>
				<select class="selectType02 mb5" id="CommStatus">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
					<option value="lbl_att_beingLate"><spring:message code='Cache.lbl_att_beginLate'/></option>
					<option value="lbl_n_att_absent"><spring:message code='Cache.lbl_n_att_absent'/></option>
					<option value="lbl_att_leaveErly"><spring:message code='Cache.lbl_att_leaveErly'/></option>
					<option value="lbl_n_att_callingTarget"><spring:message code='Cache.lbl_n_att_callingTarget'/></option>
					
				</select>
				<div class="dateSel type02" style="min-width:650px">
					<input class="adDate" type="text" id="StartDate" date_separator="." readonly="" value="${StartDate}"> 
					- 
					<input id="EndDate" date_separator="." kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly=""  value="${EndDate}">
					<a class="btnTypeDefault btnSearchBlue " id="btnSearch" href="#">검색</a>
					<a href='#' class='btnBlueType02' id='btnAllSend' style="display:none"><spring:message code='Cache.lbl_All_Send' /></a>
					<a href='#' class='btnBlueType02' id='btnSelSend' style="display:none"><spring:message code='Cache.lbl_Select_Send' /></a>
					<a href='#' class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
			</div>
			<!-- 테이블 영역 -->
			<div class="tblList tblCont boradBottomCont StateTb">
				<div id="gridDiv"></div>
			</div>
			<!-- 버튼영역 -->
			<div class="bottom">
				<a class="btnTypeDefault" id="btnClose" href="#"><spring:message code='Cache.btn_Close' /></a> <!-- 닫기 -->
			</div>
		</div>
	</div>	
</body>
</html>
<script>
var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
var grid = new coviGrid();
var pageNo = 1;
var pageSize = 10;
var lateSendYn = "${MngMst.LateSendYn}";
var absentSendYn = "${MngMst.AbsentSendYn}";
var earlySendYn = "${MngMst.EarlySendYn}";
var callingSendYn = "${MngMst.CallingSendYn}";

var headerData = [ 
       {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', disabled: function (){
   			return !AttendUtils.isSendMail(this.item, {"LateSendYn":lateSendYn,"AbsentSendYn":absentSendYn,"EarlySendYn":earlySendYn,"CallingSendYn":callingSendYn})
       }},
	   {key:'URName',			label:"<spring:message code='Cache.ObjectType_UR' />",			width:'40', align:'center', addClass:'bodyTdFile',
    		formatter:function(){
    			var sHtml = "";
				sHtml += '<div class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ this.item.UserCode +'" data-user-mail="">'+this.item.URName+'</div>';
				return sHtml;
    		}   
	   },
		{key:'DeptName',  label:'<spring:message code="Cache.NumberFieldType_DeptName" />', width:'70', align:'center'},
		{key:'JobDate',  label:'<spring:message code="Cache.lbl_date" />', width:'90', align:'center', formatter:function(){return AttendUtils.maskDate(this.item.JobDate)}}, 
		{key:'Status', sort: false, label:'<spring:message code="Cache.lbl_Status" />', width:'70', align:'center', formatter:function(){
			var sHtml = "";
			if (this.item.EndSts!= null && this.item.EndSts!='lbl_att_normal_offWork'){
				sHtml += '<span class="coState coState2">'+Common.getDic(this.item.EndSts)+'</span>';
			}	
			else if (this.item.StartSts!= null && this.item.StartSts!='lbl_att_normal_goWork'){
				sHtml += '<span class="coState coState2">'+Common.getDic(this.item.StartSts)+'</span>';
			}
			else{
				sHtml += '<span class="coState coState1">'+Common.getDic("lbl_n_att_absent")+'</span>';
			}
			
			return sHtml;
		}},
		{key:'', sort: false,  label:'<spring:message code='Cache.lbl_Send' />', width:'70', align:'center', formatter:function()
			{if (AttendUtils.isSendMail(this.item, {"LateSendYn":lateSendYn,"AbsentSendYn":absentSendYn,"EarlySendYn":earlySendYn,"CallingSendYn":callingSendYn})){
					return "<a href='#' class='btnBlueType02 btnSend' id='btnSend'><spring:message code='Cache.lbl_Send' /></a>";
	   			}
			}}
		];
$(document).ready(function(){
	AttendUtils.getDeptList($("#deptList"),'', false, false, true);
	var configObj = {
			targetID : "gridDiv",
			height : "auto",
			page : {
				pageNo: 1,
				pageSize: pageSize,
			},
			paging : true
		};
		
	grid.setGridHeader(headerData);
	grid.setGridConfig(configObj);

	if ($("#StartDate").val()==""){
		$("#StartDate").val(g_curDate);
		$("#EndDate").val(g_curDate);
	}

	//상태 에 따른 조회건
	$("#deptList, #CommStatus").change(function(){
		let bSendMail = false;
		bSendMail = AttendUtils.isSendMail({"StartSts":$(this).val(),"EndSts":$(this).val()}, {"LateSendYn":lateSendYn,"AbsentSendYn":absentSendYn,"EarlySendYn":earlySendYn,"CallingSendYn":callingSendYn})
/*		switch ($(this).val()){
			case "lbl_att_beingLate":
				if (lateSendYn == "Y") bSendMail = true;
				break;
			case "lbl_n_att_absent":
				if (absentSendYn == "Y") bSendMail = true;
				break;
			case "lbl_att_leaveErly":
				if (earlySendYn == "Y") bSendMail = true;
				break;
			case "lbl_n_att_callingTarget":
				if (callingSendYn == "Y") bSendMail = true;
				break;
			default:
				break;
		}
*/		
		//전체 발송
		if ($(this).val() != ""){
			if (bSendMail) {
				$("#btnAllSend").show();
				$("#btnSelSend").show();
			}	
			else{
				$("#btnAllSend").hide();
				$("#btnSelSend").hide();
			}
		}else{
			if (lateSendYn == "Y" && absentSendYn == "Y" && 
					earlySendYn == "Y" && callingSendYn == "Y"){
				$("#btnAllSend").show();
				$("#btnSelSend").show();
			}else{
				$("#btnAllSend").hide();
				$("#btnSelSend").hide();
				
			}
		}
		
		setPage(1);
	});
	
	//검색
	$("#btnSearch").click(function(){
		setPage(1);
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
	$('#CommStatus').trigger('change')

})	


//전체발송
$(document).on("click","#btnAllSend", function(){
	Common.Confirm("<spring:message code='Cache.msg_SendQ' />  [<spring:message code='Cache.lbl_total' /> : "+$("#gridDiv_AX_gridStatus b").text()+"]", "Confirmation Dialog", function (confirmResult) { //총
		if (confirmResult) {
			var sendParam = {"StartDate": $("#StartDate").val() 
					 ,"EndDate": $("#EndDate").val()
					, "DeptUpCode":$("#deptList").val()
					, "CommStatus":$("#CommStatus").val()
					};
			sendMail(sendParam);
		}
	});

});
	
//선택발송
$(document).on("click","#btnSelSend", function(){
	var listobj = grid.getCheckedList(0);
	var toUsers="";
	var aJsonArray = new Array();
	var selectObj = grid.getCheckedList(0);
	for(var i=0; i<selectObj.length; i++){
		var saveData ={ "UserCode":selectObj[i]["UserCode"], "JobDate":selectObj[i]["JobDate"]};
		
		toUsers += (i>0?", ":"")+ selectObj[i]["URName"];
		aJsonArray.push(saveData);
	}
	if(listobj.length == 0){
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
		return false;
	}
	Common.Confirm("<spring:message code='Cache.msg_apv_191' /> [To "+toUsers+"]", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			var sendParam = {"dataList" : aJsonArray }
			sendMail(sendParam);
		}
	});
});
	
//개별발송
$(document).on("click","#btnSend",function(){
	var aJsonArray = new Array();
	Common.Confirm("<spring:message code='Cache.msg_SendQ' />  [To "+grid.getSelectedItem()["item"]["URName"]+"]", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			var aJsonArray = new Array();
			var saveData ={ "UserCode":grid.getSelectedItem()["item"]["UserCode"], JobDate:grid.getSelectedItem()["item"]["JobDate"]};
			aJsonArray.push(saveData);
			var sendParam = {"dataList" : aJsonArray }
			sendMail(sendParam);
		}
	});
	
})

function sendMail(sendParam){
	$.ajax({
	    type: "POST",
		contentType:'application/json; charset=utf-8',
		dataType   : 'json',
	    url: "/groupware/attendPortal/sendMessageTarget.do",
	    data: JSON.stringify(sendParam),
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		Common.Inform("<spring:message code='Cache.lbl_Mail_SendCompletion'/>[<spring:message code='Cache.lbl_SendNumber'/>: "+res.sendCnt+"]"); //전송 건수
	    	}else{
	    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/control/sendSimpleMail.do", response, status, error);
		}
	});
}

	function setPage (n) {
		pageNo=n;
		searchData();
	}

	function searchData(){

		var params = {"StartDate": $("#StartDate").val()
					 ,"EndDate": $("#EndDate").val()
					, "DeptUpCode":$("#deptList").val()
					, "CommStatus":$("#CommStatus").val()
					, "pageNo" : pageNo
					, "pageSize": pageSize };

		grid.page.pageNo = 1;
		grid.page.pageSize = pageSize;
		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendPortal/getCallingTarget.do"
		});

}

//엑셀다운로드
$(document).on("click","#btnExcelDown",function(){
	var aJsonArray = new Array();
	$('#download_iframe').remove();
	var url = "/groupware/attendPortal/getCallingTargetExcel.do";
	var params = {
		"StartDate": $("#StartDate").val()
		,"EndDate": $("#EndDate").val()
		,"DeptUpCode" : $("#deptList").val()
		,"CommStatus": $("#CommStatus").val()
	};
	ajax_download(url, params); 	// 엑셀 다운로드 post 요청*/

});
// 엑셀 다운로드 post 요청
function ajax_download(url, data) {
	var $iframe, iframe_doc, iframe_html;

	if (($iframe = $('#download_iframe')).length === 0) {
		$iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
	}

	iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
	if (iframe_doc.document) {
		iframe_doc = iframe_doc.document;
	}

	iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'>"
	Object.keys(data).forEach(function(key) {
		iframe_html += "<input type='hidden' name='"+key+"' value='"+data[key]+"'>";
	});
	iframe_html +="</form></body></html>";

	iframe_doc.open();
	iframe_doc.write(iframe_html);
	$(iframe_doc).find('form').submit();
}
</script>