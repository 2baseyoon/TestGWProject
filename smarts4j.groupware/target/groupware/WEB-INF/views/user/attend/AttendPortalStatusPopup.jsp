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
.ATMgt_popup_wrap .tabMenu > li { width: 15%; }
</style>
<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104; overflow-y:auto; height:100%;">
		<div class="ATMgt_popup_wrap">
			<!-- 검색 영역 -->
			<ul class="tabMenu clearFloat">
				<li class="topToggle ${SearchStatus=='COMM'?'active':''}" data="COMM"><a href="#"  ><spring:message code='Cache.lbl_att_goWork'/></a></li>		<!-- 출근 -->
				<li class="topToggle ${SearchStatus=='LATE'?'active':''}" data="LATE"><a href="#"  ><spring:message code='Cache.lbl_att_beginLate'/></a></li>	<!-- 지각-->
				<li class="topToggle ${SearchStatus=='ABSENT'?'active':''}" data="ABSENT"><a href="#"  ><spring:message code='Cache.lbl_n_att_absent'/></a></li>	<!-- 결근-->
				<li class="topToggle ${SearchStatus=='VAC'?'active':''}" data="VAC"><a href="#"  ><spring:message code='Cache.lbl_Vacation'/></a></li>	<!--휴가 -->
				<li class="topToggle ${SearchStatus=='EXTEN'?'active':''}" data="EXTEN"><a href="#"  ><spring:message code='Cache.lbl_att_overtime_work'/></a></li>	<!--연장근무-->
				<li class="topToggle ${SearchStatus=='HOLI'?'active':''}" data="HOLI"><a href="#"  ><spring:message code='Cache.lbl_att_holiday_work'/></a></li>	<!-- 휴일근무-->
			</ul>
			<div class="ATMgt_schbox">
				<select class="selectType02" id="deptList">
				</select>
				<div class="dateSel type02">
					<input class="adDate" type="text" id="StartDate" date_separator="." readonly="" value="${StartDate}"> 
					- 
					<input id="EndDate" date_separator="." kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly=""  value="${EndDate}">
					<a class="btnTypeDefault btnSearchBlue " id="btnSearch" href="#"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
				</div>
			</div>	
			<!-- 테이블 영역 -->
			<div class="tblList tblCont boradBottomCont StateTb">
				<div id="gridDiv"></div>
			</div>
			<!-- 버튼영역 -->
			<div class="bottom mtop20">
				<a class="btnTypeDefault" href="#" id="btnClose"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
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
var searchStatus = "${SearchStatus}";
var headerData = [ 
	   {key:'URName', label:"<spring:message code='Cache.ObjectType_UR' />", width:'89', align:'center', addClass:'bodyTdFile',
			formatter:function(){
				var sHtml = "";
				sHtml += '<div class="flowerPopup" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ this.item.UserCode +'" data-user-mail=""><a class="btnFlowerName">'+this.item.URName+'</a></div>';
				return sHtml;
			}   
	   },
		{key:'DeptName',  label:'<spring:message code="Cache.NumberFieldType_DeptName" />', width:'104', align:'center'},
		{key:'TargetDate',  label:'<spring:message code="Cache.lbl_date" />', width:'134', align:'center', formatter:function(){return AttendUtils.maskDate(this.item.TargetDate)}}, 
		{key:'Status',  label:'<spring:message code="Cache.lbl_Status" />', width:'104', align:'center', formatter:function(){
			var sHtml = "";
			if (this.item.EndSts!= null && this.item.EndSts!='lbl_att_normal_offWork'){
				sHtml += '<span class="coState coState2">'+Common.getDic(this.item.EndSts)+'</span>';
			}	
			else if (this.item.StartSts!= null && this.item.StartSts!='lbl_att_normal_goWork'){
				sHtml += '<span class="coState coState2">'+Common.getDic(this.item.StartSts)+'</span>';
			}
			else if (this.item.StartSts!= null){
				sHtml += '<span class="coState coState1">'+Common.getDic(this.item.StartSts)+'</span>';
			}
			
			return sHtml;
		}},
		{key:'AttStartTime',  label:'<spring:message code="Cache.lbl_startWorkTime" />', width:'178', align:'center'},
		{key:'AttEndTime',  label:'<spring:message code="Cache.lbl_endWorkTime" />', width:'164', align:'center'}
];
var headerDataVac = [ 
           	   {key:'URName',			label:"<spring:message code='Cache.ObjectType_UR' />",			width:'163', align:'center'},
           		{key:'DeptName',  label:'<spring:message code="Cache.NumberFieldType_DeptName" />', width:'190', align:'center'},
           		{key:'dayList',  label:'<spring:message code="Cache.lbl_date" />', width:'244', align:'center', formatter:function(){return AttendUtils.maskDate(this.item.dayList)}}, 
           		{key:'VacName',  label:'<spring:message code="Cache.lbl_Vaction_Name" />', width:'176', align:'center'}
           ];
           
var configObj = {
		targetID : "gridDiv",
		height : "auto",
		fitToWidth: false,
		page : {
			pageNo: 1,
			pageSize: pageSize,
		},
		paging : true
	};

$(document).ready(function(){
	AttendUtils.getDeptList($("#deptList"),'', false, false, true);
	$("#deptList").val("${DeptUpCode}");
	
	if (searchStatus == "VAC"){
		grid.setGridHeader(headerDataVac);
	}	
	else{
		grid.setGridHeader(headerData);
	}
	grid.setGridConfig(configObj);

	if ($("#StartDate").val()==""){
		$("#StartDate").val(g_curDate);
		$("#EndDate").val(g_curDate);
	}
	setPage(1);		

	$("#deptList").change(function(){
		setPage(1);
	});
	
	//검색
	$("#btnSearch").click(function(){
		setPage(1);
	});
	
	$(".topToggle").click(function(){
		$(".topToggle").removeClass("active");
		$(this).addClass("active");
		searchStatus = $(this).attr("data");

		if (searchStatus == "VAC"){
			grid.setGridHeader(headerDataVac);
		}	
		else{
			grid.setGridHeader(headerData);
		}
		grid.setGridConfig(configObj);

			
		setPage(1);
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	

});

	function setPage (n) {
		pageNo=n;
		searchData();
	}
	
	function searchData(){

		var params = {"StartDate": $("#StartDate").val() 
					 ,"EndDate": $("#EndDate").val()
					, "DeptUpCode":$("#deptList").val()
					, "Status":searchStatus
					, "pageNo" : pageNo
					, "pageSize": pageSize };
		

		grid.page.pageNo = 1;
		grid.page.pageSize = pageSize;
		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendPortal/getUserStatus.do"
		});

	}
</script>