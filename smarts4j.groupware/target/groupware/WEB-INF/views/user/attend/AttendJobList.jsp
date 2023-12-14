<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
.AXGrid input:disabled { background-color:#Eaeaea; }
.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic'; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
.AXanchorDateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
.adLine { display:inline-block; vertical-align:middle; width:15px; font-size:24px; font-weight:600; }
#divDate { margin-top:-3px; }
.pagingType02 { margin-left:2px; }
<%=(RedisDataUtil.getBaseConfig("SchConfmYn").equals("Y")?"":".divConfm {display:none !important}")%>
</style>
	<div class="cRConTop titType AtnTop">
		<h2 class="title"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_Setting'/></h2>	
		<div id="divDate" >
			<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span> 
			<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly>
		</div>					
		<div class="pagingType02">       
			<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.btn_Today' /></a> <!-- 오늘 -->
		</div> 						
		<div class="searchBox02">
			<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
		</div>
	</div>  
	<div class="cRContBottom mScrollVH">
		<div class="ATMCont">
			<div class="ATMTopCont ATMTopCont_l">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<select class="selectType02" id="deptList">
				</select>
				<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnCreate"><spring:message code='Cache.lbl_n_att_worksch' /><spring:message code='Cache.lbl_Creation' /></a> <!-- 근무일정생성 -->
				<a href="#" onclick='AttendUtils.openVacationPopup("ADMIN");' class="btnTypeDefault btnIcon2"><spring:message code='Cache.lbl_vacationCreate' /></a>
				<span class="btnLayerWrap">	
					<a href="#" class="btnTypeDefault btnDropdown"><spring:message code='Cache.lbl_otherJobCreate' /></a>  <!-- 기타근무 생성 -->
					<div class="btnDropdown_layer" style="display:none;z-index:999999;">
						<ul class="btnDropdown_layer_list" id="jobList"></ul>
					</div>
				</span>
				<a href="#" class="btnTypeDefault" id="btnCopy"><spring:message code='Cache.lbl_Schedule' /><spring:message code='Cache.lbl_Copy' /></a> <!-- 일정복사 -->
				<a href="#" class="btnTypeDefault" id="btnDelete"><spring:message code='Cache.lbl_n_att_worksch' /><spring:message code='Cache.btn_delete' /></a> <!-- 근무일정삭제 -->
				<a href="#" class="btnTypeDefault divConfm" id="btnConfm"><spring:message code='Cache.lbl_apv_determine' /></a> <!-- 확정 -->
				<a href="#" class="btnTypeDefault divConfm" id="btnCancel"><spring:message code='Cache.lbl_Apr_ConfirmNo' /></a> <!-- 확정취소 -->
			</div>
			<div class="pagingType02 buttonStyleBoxRight" id="selectBoxDiv"> 
				<a href="#" id="btnTemplate" class="btnTypeDefault btnExcel"><spring:message code='Cache.lbl_templatedownload'/></a>	
				<a class="btnTypeDefault btnUpload" id="btnExcelUpload"><spring:message code="Cache.btn_ExcelUpload"/></a>
				<a class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.btn_ExcelDownload"/></a>
				<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
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
		<div class="tblList">
			<div id="gridDiv"></div>
		</div>
</div>
</div>
<script>
	var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("AttListCnt")){
		pageSize = CFN_GetCookie("AttListCnt");
	}
	if(pageSize===null||pageSize===""||pageSize==="undefined"){
		pageSize=10;
	}

	$("#listCntSel").val(pageSize);
	// 그리드 세팅
	var grid = new coviGrid();
	var headerData = [ 
           {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', disabled: function (){ 	    return this.item.WorkSts===null;    }},
			{	key:'UserName',			label:"<spring:message code='Cache.ObjectType_UR' />",			width:'40', align:'center',		//사용유무
				formatter : function () {
	           		 return "<a data-map='"+JSON.stringify(this.item) + "' id='jobInfo'  class='gridLink'>"+(this.item.UserName)+"</a>";
				}
			},
			{key:'JobDate',  label:'<spring:message code="Cache.lbl_date" />', width:'90', align:'center', formatter:function(){return AttendUtils.maskDate(this.item.JobDate)}}, 
			{key:'AttDay',  label:'<spring:message code="Cache.WebPartBizSection_Schedule" />', width:'70', align:'center',
				formatter : function () {
					 if (this.item.WorkSts == null)
		           		 return "<spring:message code='Cache.lbl_NoSchedule' />"; //무일정
					 else
		           		 return ""+this.item.AttDayStartTime+"~"+this.item.AttDayEndTime+"";
				}
			},
			{key:'AttDayIdle',  label:'<spring:message code="Cache.lbl_n_att_resttime" />', width:'70', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.AttDayIdle)+"</u></font></a>";
				}
			},
			{key:'AttDayAC',  label:'<spring:message code="Cache.lbl_apv_TimeTotal" />', width:'70', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.AttDayAC)+"</u></font></a>";
				}
			},
			{key:'DeptName',  label:'<spring:message code="Cache.NumberFieldType_DeptName" />', width:'70', align:'center'}
			<%if (RedisDataUtil.getBaseConfig("SchConfmYn").equals("Y")){%>
			,{key:'ConfmYn',  label:'<spring:message code="Cache.lbl_apv_determine_YN" />', width:'70', align:'center',
				formatter : function () {
					if (this.item.WorkSts == null){ //무일정
						return "";
					}else{
						if (this.item.ConfmYn == "Y")
							return "<a class='btnYes' style='cursor:default;'><span>Y</span></a>";
						else
							return "<a class='btnNo' style='cursor:default;'><span>N</span></a>";
					}
				}}
			<%}%>
			
	];
	
	$(document).ready(function(){
		AttendUtils.getOtherJobList('Y', 'ADMIN');
		AttendUtils.getDeptList($("#deptList"), Common.getSession("GR_GroupPath"), false, false, true);
		
		var configObj = {
			targetID : "gridDiv",
			height : "auto",
			page : {
				pageNo: 1,
				pageSize: $("#listCntSel").val(),
			},
			paging : true
		};
		
		grid.setGridHeader(headerData);
		grid.setGridConfig(configObj);
		
		if ($("#StartDate").val()==""){
			$("#StartDate").val(g_curDate);
			$("#EndDate").val(g_curDate);
		}
		
		setPage(1);
		
		//근무일정생성
		$("#btnCreate").click(function(){
			var popupID		= "AttendJobPopup";
			var openerID	= "AttendJob";
			var popupTit	= "<spring:message code='Cache.MN_887' />";
			var popupYN		= "N";
			var callBack	= "AttendJobPopup_CallBack";
			var popupUrl	= "/groupware/attendJob/AttendJobPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	;
			
			//Common.open("", popupID, popupTit, popupUrl, "900px", "850px", "iframe", true, null, null, true);
			CFN_OpenWindow(popupUrl, popupID, "900", "900", "","", ""); 
		});
		
		//근무신청 
		$(".btnDropdown").on('click',function(){
			var j = $(".btnDropdown_layer").index($(this).next());  // 존재하는 모든 버튼을 기준으로 index
			$(".btnDropdown_layer:not(:eq("+j+"))").hide();
		    $(this).next().toggle();
		});
		
		$("#EndDate").bindTwinDate({
			startTargetID : "StartDate",
			separator : ".",
			onChange:function(){
				setPage(1);
			},
			onBeforeShowDay : function(date){
				var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
				if(fnStr != null && fnStr != ""){
					return coviCmn.callFnBasedNamespace(fnStr, [date]);
				}
			}
		})
		
		//오늘 클릭시
		$(".calendartoday").click(function(){
			$("#StartDate").val(g_curDate);
			$("#EndDate").val(g_curDate);
			setPage(1);		
			
		});
		
		$("#deptList,#listCntSel").change(function(){
			CFN_SetCookieDay("AttListCnt", $("#listCntSel option:selected").val(), 31536000000);
			setPage(1);
		});
		
		//검색
		$("#btnRefresh, #btnSearch").click(function(){
			setPage(1);
		});
		
		//사용자명 검색
		$("#searchText").on('keypress', function(e){
			if (e.which == 13) {
				setPage(1);
			}
		});
		
		//근무일복사
		$("#btnCopy").click(function(){
			var listobj = grid.getCheckedList(0);
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_SelItemCopy'/>");
				return;
			}else if (listobj.length > 1){
				Common.Warning("<spring:message code='Cache.msg_SelectOnlyOne'/>");
				return;
			}


			var popupID		= "AttendJobCopyPopup";
			var openerID	= "AttendJobCopy";
			var popupTit	= listobj[0].UserName+' '+listobj[0].JobDate+" <spring:message code='Cache.ACC_btn_copy' />";
			var popupYN		= "N";
			var callBack	= "AttendJobDetailPopup_CallBack";
			var popupUrl	= "/groupware/attendJob/AttendJobCopyPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "UserName="		+ listobj[0].UserName	+ "&"
							+ "UserCode="		+ listobj[0].UserCode	+ "&"
							+ "JobDate="		+ listobj[0].JobDate	+ "&"
							+ "callBackFunc="	+ callBack	;
			
			
			Common.open("", popupID, popupTit, popupUrl, "720px", "720px", "iframe", true, null, null, true);
		});	
		
		//확정
		$("#btnConfm").click(function(){
			var listobj = grid.getCheckedList(0);
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
				return;
			}else{
			   	Common.Confirm("<spring:message code='Cache.msg_hr_confirm_want' />", "Confirmation Dialog", function (confirmResult) { //확정하시겠습니까?
					if (confirmResult) {			confmList();}
				})
		   	}		
		});	
		
		//확정취소
		$("#btnCancel").click(function(){
			var listobj = grid.getCheckedList(0);
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
				return;
			}else{
			   	Common.Confirm("<spring:message code='Cache.msg_hr_cancle_want' />", "Confirmation Dialog", function (confirmResult) { //확정취소하시겠습니까?
					if (confirmResult) {			cancelList();}
				})
		   	}		
		});	
		
		//삭제
		$("#btnDelete").click(function(){
			var listobj = grid.getCheckedList(0);

			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
				return;
			}else{
			   	Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {			deleteList();}
		   	})}		
		});	
		
		//엑셀다운
		$("#btnExcelDown").click(function(){
			var params = "mode=L"+
				 "&StartDate="+ $("#StartDate").val()+ 
				 "&EndDate="+ $("#EndDate").val()+
				 "&searchText="+ $("#searchText").val()+
				 "&DeptCode="+$("#deptList").val() ;
			AttendUtils.gridToExcel("<spring:message code='Cache.lbl_n_att_worksch' /><spring:message code='Cache.btn_List' />", headerData, params, "/groupware/attendJob/downloadExcel.do"); //근무일정목록
		});
		
		//엑셀업로드
		$("#btnExcelUpload").click(function(){
			var popupID		= "AttendExcelPopup";
			var openerID	= "AttendJobList";
			var popupTit	= "<spring:message code='Cache.lbl_uploadFile' />";	//계정관리
			var popupYN		= "N";
			var callBack	= "budgetRegistExcelPopup_CallBack";

			var popupUrl	= "/groupware/attendCommon/AttendExcelPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "mode="		+ "JOB"	+ "&"
							+ "callBackFunc="	+ callBack;
			
			Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
		});
		
		$("#btnTemplate").click(function(){
			Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
	       		if(result){
	       			location.href = '/groupware/attendCommon/downloadTemplate.do?mode=JOB';
	       		}
			});
		});
	});
	
	$(document).on("click","#jobInfo",function(){
		var dataMap = JSON.parse($(this).attr("data-map"));
		if (dataMap["JobDate"] == null)
		{
			Common.Inform("<spring:message code='Cache.mag_Attendance25' />");	 //지정일에 근무가 없습니다.
			return;
		}
		var popupID		= "AttendJobDetailPopup";
		var openerID	= "AttendJobDetail";
		var popupTit	= dataMap["UserName"]+' '+" <spring:message code='Cache.MN_887' />("+dataMap["JobDate"]+")";
		var popupYN		= "N";
		var callBack	= "AttendJobDetailPopup_CallBack";
		var popupUrl	= "/groupware/attendJob/AttendJobDetailPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "UserName="		+ dataMap["UserName"]	+ "&"
						+ "UserCode="		+ dataMap["UserCode"]	+ "&"
						+ "JobDate="		+ dataMap["JobDate"]	+ "&"
						+ "callBackFunc="	+ callBack	;
		
		Common.open("", popupID, popupTit, popupUrl, "600px", "600px", "iframe", true, null, null, true);

		//alert(dataMap["UserCode"]+":"+dataMap["JobDate"])
		
	});
	
	$(document).on("click",".btnDropdown_layer ul li a",function() {
		$(".btnDropdown_layer").hide()
	});
	
	function setPage (n) {
		$("#pageNo").val(n);
		searchData();
	}
	
	function searchData(){

		var params = {"mode" : "L"
					 ,"StartDate": $("#StartDate").val() 
					 ,"EndDate": $("#EndDate").val()
					 ,"searchText": $("#searchText").val()
					, "DeptCode":$("#deptList").val()
					, "pageNo" : $("#pageNo").val()
					, "pageSize": $("#listCntSel").val() };
		
		grid.page.pageNo = 1;
		grid.page.pageSize = $("#listCntSel").val();
		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendJob/getAttendJob.do"
		});

	}
	
	//확정하기
	function confmList(){
		var aJsonArray = new Array();
		var listobj = grid.getCheckedList(0);
		for(var i=0; i<listobj.length; i++){
			var saveData = { "JobDate":listobj[i].JobDate, "UserCode":listobj[i].UserCode};
               aJsonArray.push(saveData);
		}
		
		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/confirmAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.lbl_Apr_ConfirmYes'/>");	//저장되었습니다.
					searchData();
				}
				else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}
	function cancelList(){
		var aJsonArray = new Array();
		var listobj = grid.getCheckedList(0);
		for(var i=0; i<listobj.length; i++){
			var saveData = { "JobDate":listobj[i].JobDate, "UserCode":listobj[i].UserCode};
               aJsonArray.push(saveData);
		}
		
		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/confirmCancelAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.lbl_Apr_ConfirmNo'/>");	//저장되었습니다.
					searchData();
				}
				else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
		
	}
	//삭제하기
	function deleteList(){
		var aJsonArray = new Array();
		var listobj = grid.getCheckedList(0);
		for(var i=0; i<listobj.length; i++){
			var saveData = { "JobDate":listobj[i].JobDate, "UserCode":listobj[i].UserCode};
               aJsonArray.push(saveData);
		}
		
		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/delAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_Deleted'/>");	//저장되었습니다.
					searchData();
				}
				else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}
</script>
