<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
input[type="checkbox"] { display:inline-block; }
</style>
<input type="hidden" id="pageNo" value="1" />
<div class='cRConTop titType AtnTop'>
	<h2 class="title"><spring:message code='Cache.MN_890'/></h2>
	<div class="searchBox02"> 
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail' /></a>
	</div>				
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>			
				<select class="selectType02" id="schTypeSel">
					<option value=""><spring:message code='Cache.lbl_selection' /></option>
				    <option value="UserName"><spring:message code='Cache.lbl_change' /><spring:message code='Cache.lbl_TargetPerson' /></option>
				    <option value="RegisterName"><spring:message code='Cache.lbl_change' /><spring:message code='Cache.lbl_Processor' /></option>
				    <option value="Etc"><spring:message code='Cache.lbl_Remark' /></option>
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>											
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
		
		<div style="margin-bottom: 10px;">
			<div class="selectCalView">
			<span><spring:message code='Cache.lbl_Period'/></span>
				<select class="selectType02" id="selectSearch">
					<option value=""><spring:message code='Cache.lbl_selection' /></option>				    
				    <option value="Modify"><spring:message code='Cache.lbl_change' /><spring:message code='Cache.lbl_Period' /></option>
				    <option value="Process"><spring:message code='Cache.lbl_ProcessPeriod' /></option>
				</select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>											
			</div>
		</div>
	</div>
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<select class="selectType02" id="deptList">
				</select>
				<!-- 엑셀저장 -->
				<a href="#" class="btnTypeDefault btnExcel" id="btnExcelList"><spring:message code="Cache.btn_ExcelDownload"/></a>
			</div>
			<div class="pagingType02 buttonStyleBoxRight">
				<button href="#" class="btnRefresh" type="button"></button>
				<select class="selectType02 listCount" id="listCntSel">
					<option value="10" selected>10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>
	</div>
</div>

<script>
var grid = new coviGrid();
var wiUrArry = new Array();
var page = 1;
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("AttListCnt")){
	pageSize = CFN_GetCookie("AttListCnt");
}

if(pageSize===null||pageSize===""||pageSize==="undefined"){
	pageSize=10;
}

$("#listCntSel").val(pageSize);

$(document).ready(function(){
	init();
	setGrid();
	search();
});

function init(){
	
	AttendUtils.getDeptList($("#deptList"),'', false, false, true);
	
	//검색
	$('#schUrName').on('keypress', function(e){ 
		if (e.which == 13) {
	        e.preventDefault();
	        
	        var schName = $('#schUrName').val();
	        $('#schTypeSel').val("UserName");
	        $('#schTxt').val(schName);
			
	        search();
	    }
	});
	
	$("#deptList,#listCntSel,#ReqType").change(function(){
		search();
	});
	
	// 검색 버튼
	$('.btnSearchBlue').on('click', function(e) {
		search();
	});
	
	$('.btnRefresh').on('click', function(e) {
		search();
	});
	
	// 그리드 카운트
	$('#listCntSel').on('change', function(e) {
		grid.page.pageNo = 1;
		grid.page.pageSize = $(this).val();
		CFN_SetCookieDay("AttListCnt", $(this).find("option:selected").val(), 31536000000);
		grid.reloadList();
	});
	
	// 상세 보기
	$('.btnDetails').on('click', function(){
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	
	$("#btnExcelList").on("click",function(){
		excelListDownload();
	});
}

//그리드 세팅
function setGrid() {
	// header
	var	headerData = [
		{key:'Division',  label:'<spring:message code="Cache.lbl_SchDivision" />', width:'80', align:'center', formatter:function () {
			if (this.item.Division == "StartSts") { 
				return Common.getDic("lbl_startWorkTime");			
			} else {
				return Common.getDic("lbl_endWorkTime")
			}
		}},
		{key:'UserCode',  label:'<spring:message code="Cache.lbl_change" /><spring:message code="Cache.lbl_TargetPerson" />', width:'100', align:'center', addClass:'bodyTdFile', formatter:function () {
			var html = "<a class='tx_Team btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+this.item.UserCode+"'>" + this.item.UserName + "</a>";
			return html;
		}},
		{key:'DeptName',  label:'<spring:message code="Cache.lbl_DeptName" />', width:'100', align:'center'},
		{key:'BeforeAttTime',  label:'<spring:message code="Cache.lbl_BeforeChange" /> <spring:message code="Cache.lbl_RepeateDate" />', width:'120', align:'center'},
		{key:'AttTime',  label:'<spring:message code="Cache.lbl_AfterChange" /> <spring:message code="Cache.lbl_RepeateDate" />', width:'120', align:'center'},
		{key:'RegistDate',  label:'<spring:message code="Cache.lbl_ProcessDate" />', width:'120', align:'center'},
		{key:'RegisterCode',  label:'<spring:message code="Cache.lbl_change" /><spring:message code="Cache.lbl_Processor" />', width:'100', align:'center', addClass:'bodyTdFile', formatter:function () {
			var html = "<a class='tx_Team btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+this.item.RegisterCode+"'>" + this.item.RegisterName + "</a>";
			return html;
		}},
		{key:'ReqType',  label:'<spring:message code="Cache.lbl_reqClass" />', width:'80', align:'center', formatter:function () {
			if(this.item.ReqType == "None") {
				return Common.getDic("lbl_admin");	
			} else if(this.item.ReqType == "Request") {
				return Common.getDic("lbl_apv_normal") + Common.getDic("lbl_apv_Approved");
			} else {
				return Common.getDic("lbl_apv_approval");
			}
		}},
		{key:'Etc',  label:'<spring:message code="Cache.lbl_Remark" />', width:'300', align:'left', formatter:function () {
			return this.item.Etc + " " + (this.item.Etc != "" ? " - " : "") + this.item.BillName;
		}},
	];
	
	grid.setGridHeader(headerData);
	
	// config
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",			
		paging : true,
		page : {
			pageNo:1,
			pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
		}
	};
	grid.setGridConfig(configObj);
}

function search(){
	var params = {
		schTypeSel : $('#schTypeSel').val(),
	  	schTxt : $('#schTxt').val(),
	  	selectSearch : $("#selectSearch").val(),
	  	startDate : $("#startDate").val(),
	  	endDate : $("#endDate").val(),
	  	deptCode : $("#deptList").val()
	};

	grid.page.pageNo = $("#pageNo").val();
	grid.page.pageSize = $("#listCntSel").val();

	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendAdmin/getAttModifyHisList.do",
		ajaxPars : params
	});
}

// 리스트 엑셀 다운로드
function excelListDownload(){
	Common.Confirm(Common.getDic("msg_ExcelDownMessage"), "<spring:message code='Cache.ACC_btn_save' />", function(result){
   		if(result){
   			var	locationStr		= "/groupware/attendAdmin/attModifyHisDownloadExcel.do?"
   				+ "title="			+ "Sheet1"
				+ "&schTypeSel="	+ $('#schTypeSel').val()
				+ "&schTxt="		+ $('#schTxt').val()
				+ "&selectSearch="	+ $('#selectSearch').val()
				+ "&startDate="		+ $('#startDate').val()
				+ "&endDate="		+ $('#endDate').val()
				+ "&deptCode="		+ $('#deptList').val()
   			
			location.href = locationStr;
   		}
   	});
}
</script>
