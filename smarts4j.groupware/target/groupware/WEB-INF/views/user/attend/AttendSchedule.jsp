<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
.ATMTable_Mgt_W td {background:#fff !important}
p.tx_Time {display:inline-block;}
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr td { width:100%; }
.gridBodyTr.gridBodyMarker .bodyNode.bodyTdText { padding:0 !important;}

.btn_close {
    display: inline-block;
    width: 18px;
    height: 16px;
    background: #fff url('/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_arrow_02_2.png') no-repeat 50% 5px;
    background-size: 8px;
    border: 1px solid #c5c5c5;
    border-radius: 2px;
    vertical-align: top;
    margin: 2px 0 0 10px;
}

.btn_open {
    display: inline-block;
    width: 18px;
    height: 16px;
    background: #fff url('/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_arrow_03.png') no-repeat 50% 5px;
    background-size: 8px;
    border: 1px solid #c5c5c5;
    border-radius: 2px;
    vertical-align: top;
    margin: 2px 0 0 10px;
}
.onOffBtn.on {
    background: #4abde1;
}

</style>

<div class='cRConTop titType AtnTop'>
	<h2 class="title"><spring:message code='Cache.lbl_n_att_selectWorkSchTemp'/></h2>
	<div class="searchBox02">
		<span><input type="text" id="schSearchTxt"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span class="TopCont_option">
					<input id="ValidCheck" value="Y" type="checkbox">
					<label for=ValidCheck><spring:message code="Cache.btn_All"/></label><!-- 전체 제외-->
				</span>
				<select class="selectType02" id="schTypeSel">
					<option value="allSearch"><spring:message code="Cache.lbl_AllSearch" /></option>
					<option value="templateName"><spring:message code="Cache.lbl_templateName" /></option>
					<option value="workPlaceName">근무지</option>
					<option value="user"><spring:message code="Cache.lbl_Applicable" /></option>
					<option value="memo"><spring:message code="Cache.lbl_Memo" /></option>
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_TemplateAdd'/></a>
				<a href="#" class="btnTypeDefault" id="btnDelete"><spring:message code='Cache.lbl_delete'/></a>
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
<!-- 반복 선택 레이어 팝업 시작 -->
			<div class="ATMgt_Work_Popup" id="divChange" style="width:282px; right:350px;top:50px; z-index:105;display:none">
				<a class="Btn_Popup_close"  id="iconChangeClose"></a>
				<div class=WTemp_cal_title id=schName></div>
				<div class="ATMgt_Cont">
				    <span id="divCalendar" class="dateSel type02">
						<input class="adDate" type="text" id="StartDate" date_separator="." readonly=""> - 
						<input id="EndDate" date_separator="." kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly="">
					</span>											
					<div class="bottom">
						<a href="#" class="btnTypeDefault btnTypeChk" id=btnApply><spring:message code='Cache.lbl_apv_apply' /></a>
						<a href="#" class="btnTypeDefault" id="btnChangeClose" ><spring:message code='Cache.lbl_close' /></a>
					</div>
				</div>
			</div>
		</div>	
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>
	</div>
</div>

<script>
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("AttListCnt")){
		pageSize = CFN_GetCookie("AttListCnt");
	}
	if(pageSize===null||pageSize===""||pageSize==="undefined"){
		pageSize=10;
	}

	$("#listCntSel").val(pageSize);
	
	var grid = new coviGrid();
	// 그리드 세팅
	var headerData = [ 
            {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	  	    {key: "showFlag", label: " " , width: "1", align: "center",	display: false},
			{key:'BaseYn',			label:"<spring:message code='Cache.lbl_BasicWork' />",			width:'40', align:'center',		//사용유무
				formatter : function () {
						return "<input type='text' kind='switch' on_value='Y' off_value='N' id='BaseYn"+this.item.SchSeq+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.BaseYn+"' onchange='updateBaseYn(\""+this.item.SchSeq+"\");' />";
				}
			},
			{key:'SchName',  label:'<spring:message code="Cache.lbl_templateName" />', width:'90', align:'left',
				formatter:function(){ 
					return String.format("<a onclick='javascript:openAttendSchedulePopup(\"save\",\"{1}\");'  class='gridLink'>{0}</a>", this.item.SchName, this.item.SchSeq);
				}	
			}, //근무제명
			{key:'WorkZone',  label:'<spring:message code="Cache.lbl_WorkingArea" />', width:'90', align:'left'}, //근무지
			{key:'WorkTimeMon',  label:'<spring:message code="Cache.lbl_att_sch_mon" />', width:'70', align:'center', 
				formatter:function(){
					return "<p class=tx_Time>"+this.item.WorkTimeMon+"</p><a class='btn_open' id='btnOpen"+this.index+"' onclick=showDetailInfo("+this.index+")></a>";
				}
			},
			<%if (RedisDataUtil.getBaseConfig("AssYn").equals("Y")){%>
				{key:'AssYn', label:'<spring:message code="Cache.lbl_Assum" />', width:'50', align:'center'},
			<%}%>	
			{key:'MemberCnt',  label:'<spring:message code="Cache.lbl_Applicable" />', width:'50', align:'center',
				formatter:function(){
					return this.item.BaseYn=="Y"?"":String.format("<a href='#' class='btnPlusAdd2' onclick='openSchMemPopup(\"{1}\");'>{0}</a>", this.item.MemberCnt, this.item.SchSeq);
				}	
			},
			{key:'AllocCnt',  label:'<spring:message code="Cache.lbl_apv_Admin" />', width:'50', align:'center',
				formatter:function(){
					return String.format("<a href='#' class='btnPlusAdd2' onclick='AttendUtils.openSchAllocPopup(\"{1}\");'>{0}</a>", this.item.AllocCnt, this.item.SchSeq);
				}	
			},
			{key:'ValidYn',			label:"<spring:message code='Cache.lbl_ComIsUse' />",			width:'40', align:'center',		//사용유무
				formatter : function () {
						return this.item.BaseYn != 'Y'? "<input type='text' kind='switch' on_value='Y' off_value='N' id='ValidYn"+this.item.SchSeq+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.ValidYn+"' onchange='updateValidYn(\""+this.item.SchSeq+"\");' />":"";
				}
			},
			{key:'Memo',  label:'<spring:message code="Cache.lbl_Memo" />', width:'200', align:'left'},
			{key:'',  label:' ', width:'150', align:'center', sort:false,
				formatter : function () {
					return "<a class='btn_Ok' id='btnApply' onclick=showChangeWindow("+this.index+")><spring:message code='Cache.lbl_Rereflect'/></a>";
				}
			}

	];

	$(document).ready(function(){
		// config
		var configObj = {
			targetID : "gridDiv",
			height : "auto",
			body: {
					marker       ://상세정보
					{	display: function () { return this.item.showFlag; },
						rows: [[{
								colSeq  : null, colspan: 11, formatter: function () {
									$.Event(event).stopPropagation();
									return '<table class="ATMTable_Mgt_W" cellspacing="0" cellpadding="0">'+
													'<thead>'+
													'<tr>'+
													'	<th><spring:message code="Cache.lbl_sch_mon" /></th>'+	//월
													'	<th><spring:message code="Cache.lbl_sch_tue" /></th>'+	//화
													'	<th><spring:message code="Cache.lbl_sch_wed" /></th>'+	//수
													'	<th><spring:message code="Cache.lbl_sch_thu" /></th>'+	//목
													'	<th><spring:message code="Cache.lbl_sch_fri" /></th>'+	//금
													'	<th><span class="tx_sat"><spring:message code="Cache.lbl_sch_sat" /></span></th>'+	//토
													'	<th><span class="tx_sun"><spring:message code="Cache.lbl_sch_sun" /></span></th>'+	//일
													'</tr>'+
												'</thead>'+
												'<tbody>'+
												'	<tr>'+
												'		<td>'+this.item.WorkTimeMon+'</td>'+
												'		<td>'+this.item.WorkTimeTue+'</td>'+
												'		<td>'+this.item.WorkTimeWed+'</td>'+
												'		<td>'+this.item.WorkTimeThe+'</td>'+
												'		<td>'+this.item.WorkTimeFri+'</td>'+
												'		<td>'+this.item.WorkTimeSat+'</td>'+
												'		<td>'+this.item.WorkTimeSun+'</td>'+
												'	</tr>'+
												'	<tr>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnMon=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnTue=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnWed=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnThu=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnFri=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnSat=="Y"?"checked":"")+'></td>'+
												'		<td><label><spring:message code="Cache.lbl_NextDay" /></label><input type="checkbox" disabled '+(this.item.NextDayYnSun=="Y"?"checked":"")+'></td>'+
												'	</tr>'+
												'</tbody>'+
											'</table>' ;
								}, align: "center"

							}]
						]
					}
					///////////////////////////////////////////
          	},
			page : {
				pageNo: 1,
				pageSize: $("#listCntSel").val(),
			},
			paging : true
		};
		
		grid.setGridHeader(headerData);
		grid.setGridConfig(configObj);
		searchList();
		
		//event 세팅
		$('#btnSearch').click(function(){
			searchList();
		});
		
		$("#listSecterSel,#listCntSel").change(function(){
			searchList();
			CFN_SetCookieDay("AttListCnt", $("#listCntSel option:selected").val(), 31536000000);
		});
		
		$("#btnRefresh").click(function(){
			refreshPage();
		});
		
		$("#btnAdd").click(function(){
			openAttendSchedulePopup('add',0);
		});	
		
		$("#btnDelete").click(function(){
			deleteList();
		});	
		$("#btnChangeClose, #iconChangeClose").click(function(){
			$("#divChange").hide();
		});
		
		$("#btnExcelDown").click(function(){
			Common.Confirm(Common.getDic("msg_ExcelDownMessage"), "<spring:message code='Cache.ACC_btn_save' />", function(result){
	       		if(result){
	       			var gridHeaderInfo = [];
	       			//gridHeaderInfo["Name"]= "템플릿명†SchSeq†근무지†일†익일여부(일)†월†익일여부(월)†화†익일여부(화)†수†익일여부(수)†목†익일여부(목)†금†익일여부(금)†토†익일여부(토)†간주†Memo†기본†적용대상자";
	       			gridHeaderInfo["Name"]= "<spring:message code='Cache.lbl_templateName' />†SchSeq†<spring:message code='Cache.lbl_WorkingArea' />"+
	       			"†<spring:message code='Cache.lbl_sch_sun' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_sun' />)"+
	       			"†<spring:message code='Cache.lbl_sch_mon' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_mon' />)"+
	       			"†<spring:message code='Cache.lbl_sch_tue' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_tue' />)"+
	       			"†<spring:message code='Cache.lbl_sch_wed' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_wed' />)"+
	       			"†<spring:message code='Cache.lbl_sch_thu' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_thu' />)"+
       				"†<spring:message code='Cache.lbl_sch_fri' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_fri' />)"+
       				"†<spring:message code='Cache.lbl_sch_sat' />†<spring:message code='Cache.mag_Attendance45' />(<spring:message code='Cache.lbl_sch_sat' />)"+
       				"†<spring:message code='Cache.mag_Attendance46' />†Memo†<spring:message code='Cache.lbll_Default' />†<spring:message code='Cache.lbl_Applicable' />";
	       			
	       			gridHeaderInfo["Key"]= "SchName,SchSeq,WorkZone,WorkTimeSun,NextDayYnSun,WorkTimeMon,NextDayYnMon,WorkTimeTue,NextDayYnTue,WorkTimeWed,NextDayYnWed,WorkTimeThe,NextDayYnThu"+
	       					",WorkTimeFri,NextDayYnFri,WorkTimeSat,NextDayYnSat,AssYn,Memo,BaseYn,MemberCnt";
	
	       			let validCheck = $("#ValidCheck").is(":checked") ? "" : "Y";
	       			var	locationStr		= "/groupware/attendSchedule/downloadExcel.do?"
						+ "headerName="		+ encodeURI(gridHeaderInfo["Name"])
						+ "&headerKey="		+ encodeURI(gridHeaderInfo["Key"])
						+ "&title="			+ "Sheet1"
						+ "&reqType=A"
						+ "&ValidCheck=" + validCheck
						+ "&schTypeSel=" + $('#schTypeSel').val()
						+ "&schTxt=" + $('#schTxt').val();
					location.href = locationStr;
	       		}
	       	});

			//AttendUtils.gridToExcel($(".title").text(), headerData, "", "/groupware/attendSchedule/downloadExcel.do");
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
							+ "mode="		+ "SCHEDULE"	+ "&"
							+ "callBackFunc="	+ callBack;
			
			Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
		});
		
		$("#btnTemplate").click(function(){
			Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
	       		if(result){
	       			//location.href = '/groupware/attendCommon/downloadTemplate.do?mode=SCHEDULE';
					var params = {};
					ajax_download('/groupware/attendAdmin/attendanceScheduleTempleteDownload.do', params);
				}
			});
		});
		
		
		$("#btnApply").click(function(){
			if ($("#StartDate").val() == ""|| $("#EndDate").val() == ""){
				 Common.Warning("<spring:message code='Cache.CPMail_TargetPeriodIsRequired'/>", "Warning Dialog", function () {     
		         });
		         return false;
			}
			if ($("#EndDate").val() < $("#StartDate").val() ){
				 Common.Warning("<spring:message code='Cache.CPMail_EndDateIsEarlierThanStartDate'/>", "Warning Dialog", function () {     
		         });
		         return false;
			}

			var strMsg = $("#StartDate").val() + "~" + $("#EndDate").val() + "<spring:message code='Cache.lbl_DayRepeat_1' /> <spring:message code='Cache.msg_Registered' /> ["+$("#divChange #schName").text()+"]"; //에 등록된
			
			Common.Confirm(strMsg+ "<spring:message code='Cache.mag_Attendance47'/>", "<spring:message code='Cache.lbl_n_att_worksch' />", function(result){	//근무일정을 재반영하시겠습니까?
	       		if(result){
	       			applySchedulJob();
	       		}
			});		
		});
	});

	//상세 조회
	function search(){
		var params = {
			reqType : "A",
			schTypeSel : $('#schTypeSel').val(),
			schTxt : $('#schTxt').val(),
			ValidCheck: ($("#ValidCheck").is(":checked")?"":"Y"),
		};
		grid.page.pageNo = 1;
		grid.page.pageSize = $("#listCntSel").val();
		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendSchedule/getAttendScheduleList.do"
		});
	}
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
	// 검색 버튼
	$('.btnSearchBlue').on('click', function(e) {
		search();
	});
	//검색
	$('#schSearchTxt').on('keypress', function(e){
		if (e.which == 13) {
			e.preventDefault();

			var schSearchTxt = $('#schSearchTxt').val();

			$('#schTypeSel').val('allSearch');
			$('#schTxt').val(schSearchTxt);

			search();
		}
	});
	//상세 검색에 input enter fun.
	$('#schTxt').on('keypress', function(e){
		if (e.which == 13) {
			e.preventDefault();
			search();
		}
	});
	//근무일정 재반영
	function showChangeWindow(index){
		var item = grid.list[index];
		$("#divChange #schName").text(item.SchName)
		$("#divChange #schName").attr("data",item.SchSeq)
		$("#divChange").show();
	}
	
	function applySchedulJob(){
		$.ajax({
			type:"POST",
			data:{ "SchSeq": $("#divChange #schName").attr("data")
				, "StartDate": $("#StartDate").val()
				, "EndDate": $("#EndDate").val()},
			url:"/groupware/attendJob/reapplyAttendScheduleJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_Been_saved' />");	//저장되었습니다.
					$("#divChange").hide();
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
	
	// 검색
	function searchList(keepYn) {		

		if(keepYn== 'Y'){
			grid.reloadList();
		}
		else{
			var params = {reqType : "A", ValidCheck: ($("#ValidCheck").is(":checked")?"":"Y")};
			grid.page.pageNo = 1;
			grid.page.pageSize = $("#listCntSel").val();
			// bind
			grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/attendSchedule/getAttendScheduleList.do"
			});
		}
		
	}
	
	function deleteList(){

		var deleteobj = grid.getCheckedList(0);
		var aJsonArray = new Array();

		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					for(var i=0; i<deleteobj.length; i++){
						var saveData = { "SchSeq":deleteobj[i].SchSeq};
		                aJsonArray.push(saveData);
					}
					
					var objParams = {
		                    "dataList" : aJsonArray       
		                };
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify(objParams),
						url:"/groupware/attendSchedule/deleteAttendSchedule.do",
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_Deleted'/>");	//저장되었습니다.
								searchList('Y');
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
			});	
		}
	}
	
	
	function refreshPage() {
		$('#searchText').val("");
		$('#listSecterSel').val("");
		$('#listSalesSel').val("");
		searchList();
	}
	
	
	function openAttendSchedulePopup(mode, SchSeq){
		var popupID		= "AttendSchedulePopup";
		var openerID	= "AttendSchedule";
		var popupTit	= "<spring:message code='Cache.lbl_TemplateAdd' />";
		if (mode == "save") popupTit	= "<spring:message code='Cache.lbl_TemplateSave' />";
		var popupYN		= "N";
		var callBack	= "AttendSchedulePopup_CallBack";
		var popupUrl	= "/groupware/attendSchedule/AttendSchedulePopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "SchSeq="	+ SchSeq	+ "&"
						+ "callBackFunc="	+ callBack	+ "&"
						+ "mode="			+ mode;
		
		Common.open("", popupID, popupTit, popupUrl, "650px", "770px", "iframe", true, null, null, true);
	}
	
	function AttendSchedulePopup_CallBack(){
		searchList('Y');
	}
	
	// 기본 스위치 버튼에 대한 값 변경
	function updateBaseYn(SchSeq){
		$.ajax({
			type:"POST",
			data:{
				"SchSeq" : SchSeq,
				"BaseYn" :  $("#BaseYn"+SchSeq).val()
			},
			url:"/groupware/attendSchedule/updateAttendScheduleBase.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred' />");	//오류가 발생하였습니다.
				}
				else {
					searchList("Y");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/modifyUse.do", response, status, error);
			}
		});
	}

	// 사용 스위치 버튼에 대한 값 변경
	function updateValidYn(SchSeq){
		$.ajax({
			type:"POST",
			data:{
				"SchSeq" : SchSeq,
				"ValidYn" :  $("#ValidYn"+SchSeq).val()
			},
			url:"/groupware/attendSchedule/updateAttendScheduleValid.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred' />");	//오류가 발생하였습니다.
				}
				else {
					searchList("Y");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/modifyUse.do", response, status, error);
			}
		});
	}


	/// 요일별 상세정보 표시하기 위해 추가함 ////
	var prevClickIdx="-1";
    function showDetailInfo(index, obj) {
		var item = grid.list[index];
//		$("a #btnOpen4").removeClass("btn_close");
//		$("a #btnOpen4").removeClass("btn_open");
//		$("a #btnOpen4").hide();
		if (prevClickIdx != "-1" && prevClickIdx !=index ){
			$("#btnOpen"+prevClickIdx).removeClass("btn_open").addClass("btn_close");
			grid.updateItem(0,1,prevClickIdx,false);

		}
		if(!item.showFlag){
			$("#btnOpen"+index).removeClass("btn_close").addClass("btn_open");
			grid.updateItem(0,1,index,true);
			prevClickIdx = index;
		}
		else{
			$("#btnOpen"+index).removeClass("btn_open").addClass("btn_close");
			grid.updateItem(0,1,index,false);
			prevClickIdx= "-1";
		}
//		grid.setFocus(index);
		grid.windowResizeApply(); //스크롤바를 리드로우한다.
    }

</script>
