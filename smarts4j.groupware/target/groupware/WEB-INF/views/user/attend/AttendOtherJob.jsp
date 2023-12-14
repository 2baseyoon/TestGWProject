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
	<h2 class="title"><spring:message code='Cache.lbl_n_att_otherjob'/></h2>
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
					<option value="workType"><spring:message code="Cache.lbl_type" /></option>
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
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnOtherJobAdd"><spring:message code='Cache.lbl_n_att_otherjob_add'/></a>
				<a href="#" class="btnTypeDefault" id="btnOtherJobDel"><spring:message code='Cache.btn_Delete'/></a>
			</div>
			<div class="buttonStyleBoxRight">
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
var _page ;
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
	
	//기타근무 등록 팝업 
	$("#btnOtherJobAdd").on('click',function(e){ 
		goAddOtherJobPop();		
	});
	
	//기차근무 삭제
	$("#btnOtherJobDel").on('click',function(e){ 
		delOtherJob();		
	});
	

}


//그리드 세팅
function setGrid() {
	
	var jobSts = Common.getBaseCode('JobStatus').CacheData;
	// header
	var	headerData = [
			{ key:'JobStsSeq', label:'chk', width:'20', align:'center', formatter:'checkbox'},
			{	key:'ValidYn',	label:"<spring:message code='Cache.lbl_IsUse' />",width:'50', align:'center',
				formatter : function () {
					var _div = $('<div />', {
						class : "alarm type01"
					});  
					
					var _a = $('<a />', {
						class : "onOffBtn"
						,"data-jobstsseq" : this.item.JobStsSeq
						,"onclick" : "updateOtherJobStatus(this)"
					});  
					if(this.item.ValidYn=="Y") { _a.addClass("on"); }
					_a.append("<span></span>");
					_div.append(_a);
					return _div[0].outerHTML;
				}
			},
/* 			{	key:'ValidYn',	label:"<spring:message code='Cache.lbl_IsUse' />",width:'50', align:'center',
				formatter : function () {
						return "<input type='text' id='switch_"+this.item.JobStsSeq+"' kind='switch' on_value='Y' off_value='N' style='width:50px;height:21px;border:0px none;' value='"+this.item.ValidYn+"' onchange='updateOtherJobStatus(\""+this.item.JobStsSeq+"\");' />";
				}
			}, */
			{key:'JobStsName',  label:'<spring:message code="Cache.lbl_type" />', width:'100', align:'center',
				formatter : function () {
					return "<a onclick='javascript:goAddOtherJobPop(\""+this.item.JobStsSeq+"\");' >"+this.item.JobStsName+"</a>";
				}	
			}   ,
			{key:'', sort:false, label:'<spring:message code="Cache.lbl_att_approval" />', width:'100', align:'center',
				formatter : function () {
					return setTxt(this.item.ReqMethod);
				}	
			}  ,
			{key:'Memo',  label:'<spring:message code="Cache.lbl_Memo" />', width:'200', align:'center'}   
	       
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
			pageSize: $("#listCntSel").val()
		}
	};
	grid.setGridConfig(configObj);
}

var AttendReqMethod = Common.getBaseCode("AttendReqMethod").CacheData;
function setTxt(str) {
	var reStr= "";

	for(var i=0;i<AttendReqMethod.length;i++){
		if(str==AttendReqMethod[i].Code){
			reStr = CFN_GetDicInfo(AttendReqMethod[i].MultiCodeName);
			break;
		}
	}
	return reStr;
}


function search(){
	
	var params = {
		schTypeSel : $('#schTypeSel').val(),
		schTxt : $('#schTxt').val(),
		ValidCheck: ($("#ValidCheck").is(":checked")?"":"Y"),
		sortBy : "JobStsSeq DESC"
	};
	grid.page.pageNo = $("#pageNo").val();
	grid.page.pageSize = $("#listCntSel").val();
	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendAdmin/getOtherJobList.do",
		ajaxPars : params
	});
}

//기타근무 추가 팝업
function goAddOtherJobPop(s){
	var url = "/groupware/attendAdmin/goOtherJobAddPopup.do";
	if(s != undefined){
		url += "?jobStsSeq="+s;
	}
	var width = "451";
	var height = "298";
	Common.open("","target_pop","<spring:message code='Cache.lbl_n_att_otherjob_add' />",url,width,height,"iframe",true,null,null,true);
}


//사용설정 변경
function updateOtherJobStatus(o){
	var obj = $(o);
	var params = {
		jobStsSeq : obj.data("jobstsseq")
	}
	if(obj.attr("class").lastIndexOf('on')>0){
		params.validYn = "N";
		obj.removeClass("on");
	}else{
		params.validYn = "Y";
		obj.addClass("on");
	}
	
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/attendAdmin/setOtherJob.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				//search();
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
				search();
			}
		}
	});
}

//기타근무 삭제
function delOtherJob(){
	if($("input[name=chk]:checked").length==0){
		Common.Warning("<spring:message code='Cache.msg_selectTargetDelete'/>");
	}else{
		Common.Confirm("<spring:message code='Cache.msg_Common_08' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				
				var delArry = new Array();
				for(var i=0;i<$("input[name=chk]:checked").length;i++){
					delArry.push($("input[name=chk]:checked").eq(i).val());
				}
				var params = {
						jobStsSeq : JSON.stringify(delArry)
					};
				
				$.ajax({
					type:"POST",
					dataType : "json",
					data: params,
					url:"/groupware/attendAdmin/delOtherJob.do",
					success:function (data) {
						if(data.status =="SUCCESS"){
							search();
						}else{
							Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
						}
					}
				});
			}
		});
		
		
	}
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
</script>
