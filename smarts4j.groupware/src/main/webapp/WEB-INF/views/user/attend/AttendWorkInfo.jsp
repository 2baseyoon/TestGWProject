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
				<select class="selectType02" id="schTypeSel">
					<option value=""><spring:message code='Cache.lbl_apv_searchcomment' /></option>
				    <option value="deptName"><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName"><spring:message code="Cache.lbl_username" /></option>
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
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<!-- 근로정보 추가 -->
				<a href="#" class="btnTypeDefault btnTypeBg btnAttAdd" id="btnWorkInfoAdd"><spring:message code='Cache.btn_n_att_addWorkInfo'/></a>
				<!-- 삭제 -->
				<a href="#" class="btnTypeDefault left" id="btnWorkInfoDel"><spring:message code='Cache.btn_Delete'/></a>
				<!-- 엑셀저장 -->
				<a href="#" class="btnTypeDefault btnExcel" id="btnExcelList"><spring:message code="Cache.btn_ExcelDownload"/></a>
			</div>
			<div class="pagingType02 buttonStyleBoxRight">
				<%-- // 전체 검색 체크, start. --%>
				<div class="chkStyle10">
					<input type="checkbox" class="check_class" id="chk_IsAll" value="N" />
					<label for="chk_IsAll">
						<span class="s_check"></span>
						<spring:message code='Cache.btn_All' />
					</label>
				</div>
				<%-- // 전체 검색 체크, end. --%>
				<!-- 업로드 -->
				<a href="#" id="btnExcelUp" class="btnTypeDefault btnUpload"	><spring:message code="Cache.btn_ExcelUpload"/></a>
				<!-- 다운로드 -->
				<a href="#" id="btnExcelTemplate" class="btnTypeDefault btnExcel" ><spring:message code='Cache.lbl_templatedownload'/></a>
				
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
	
	//검색
	$('#schUrName').on('keypress', function(e){ 
		if (e.which == 13) {
	        e.preventDefault();
	        
	        var schName = $('#schUrName').val();
	        
	        $('#schTypeSel').val('displayName');
	        $('#schTxt').val(schName);
			
	        search();
	    }
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
	$("#btnExcelTemplate").on("click",function(){
		templeteDownload();
	});
	$("#btnExcelUp").on("click",function(){
		excelUpload();
	});
	
	//근로정보 추가 팝업
	$("#btnWorkInfoAdd").on('click',function(){
		goAddWorkInfoPop();
	});
	
	//근로정보 삭제
	$("#btnWorkInfoDel").on('click',function(){
		delWorkInfo();
	});
	
	// 전체보기 checkbox 클릭 이벤트
	$("#chk_IsAll").on("change", function() {
		search();
	});
}
//근로정보 템플릿 다운로드
function templeteDownload(){
	var params = {
	};
	ajax_download('/groupware/attendAdmin/workInfoTempleteDownload.do', params);
}
// templeat upload
function excelUpload(){
	var popupID		= "AttendExcelPopup";
	var openerID	= "AttendWorkInfoUpload";
	var popupTit	= "<spring:message code='Cache.lbl_uploadFile' />";	//계정관리
	var popupYN		= "N";
	var callBack	= "AttendWorkInfoUpload_CallBack";

	var popupUrl	= "/groupware/attendAdmin/goWorkInfoByExcelPopup.do?"
			+ "popupID="		+ popupID	+ "&"
			+ "openerID="		+ openerID	+ "&"
			+ "popupYN="		+ popupYN	+ "&"
			+ "mode="		+ "WORKINFO"	+ "&"
			+ "callBackFunc="	+ callBack;

	Common.open("", popupID, popupTit, popupUrl, "850px", "520px", "iframe", true, null, null, true);
}

//upload callback
function AttendWorkInfoUpload_CallBack(){
	coviCmn.traceLog("AttendWorkInfoUpload_CallBack@@@!!");
}
// 엑셀 다운로드 post 요청
function ajax_download(url, data) {
	var $iframe, iframe_doc, iframe_html;

	if (($iframe = $('#download_iframe')).length > 0) {
		$iframe.remove();
	}

	$iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");

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

//그리드 세팅
function setGrid() {
	// header
	var	headerData = [
			{ key:'PID', label:'chk', width:'30', align:'center', formatter:'checkbox'},
			{key:'ApplyDate',  label:'<spring:message code="Cache.lbl_n_att_applyDate" />', width:'100', align:'center'},
			{key:'ListType', label:'<spring:message code="Cache.lbl_Gubun" />', width:'100', align:'center',formatter:function () {
				if (this.item.ListType == "UR")	return "<p style='font-weight: bold;'><spring:message code='Cache.ObjectType_UR' /></p>";
				else if (this.item.ListType == "GR") return "<p style='color: orange; font-weight: bold;'><spring:message code='Cache.lbl_dept' /></p>";
				else return "<p style='color: blue; font-weight: bold;'><spring:message code='Cache.lbl_CompanySet' /></p>";
					
				return html;
			}},
			{key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					if (this.item.ListType == "OR") {
						html += "<a style='color:blue;' onclick='goModWorkInfoPop(\"" + this.item.ListType + "\",\"" + this.item.UserCode + "\",\"" + this.item.ApplyDate+ "\")';  class='gridLink'>";
						html += "<spring:message code='Cache.lbl_CompanySet' />";
					} else if (this.item?.DeptName) {
						if (this.item?.ListType === "GR") {
							html += "<a style='color: orange;' onclick='goModWorkInfoPop(\"" + this.item.ListType + "\",\"" + this.item.UserCode + "\",\"" + this.item.ApplyDate+ "\")';  class='gridLink'>";
						} else if (this.item?.ListType === "UR") {
							html += "<a onclick='goModWorkInfoPop(\"" + this.item.ListType + "\",\"" + this.item.UserCode + "\",\"" + this.item.ApplyDate+ "\")';  class='gridLink'>";
						}
						html += CFN_GetDicInfo(this.item.DeptName);
					}
					html += "</a></p>";
					return html;
				}
			},
			{key:'DisplayName', label:'<spring:message code="Cache.lbl_username" />', width:'100', align:'center', addClass:'bodyTdFile',
				formatter:function () {
					var html = "<div class='tx_Team btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+this.item.UserCode+"'>";
					if (this.item.ListType == "OR") html += "";
					else if (typeof(this.item.DisplayName) != 'undefined') html += this.item.DisplayName;
					html += "</div >";
						
					return html;
				}
			},
	        {key:'WorkWeek', sort:false, label:'<spring:message code="Cache.lbl_n_att_workingWeek" />', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					html += weekendFormat(this.item.WorkWeek,1);
					html += "</p>";
					return html;
				}
	        }  ,
			{key:'WorkWeek',  sort:false, label:'<spring:message code="Cache.lbl_Holiday" />(유)', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					html += weekendFormat(this.item.WorkWeek,0);
					html += "</p>";
					return html;
				}
	        }   ,   
			{key:'WorkWeek',  sort:false, label:'<spring:message code="Cache.lbl_att_sch_holidaySts" />(무)', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					html += weekendFormat(this.item.WorkWeek,2);
					html += "</p>";
					return html;
				}
	        }   ,   
			{key:'WorkRule', sort:false, label:'<spring:message code="Cache.lbl_n_att_workingRule" />', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					html += ruleFormat(this.item.WorkTime,this.item.WorkCode,this.item.UnitTerm,this.item.WorkApplyDate,'/');
					html += "</p>";
					return html;
				}
	        }  ,   
			{key:'WorkMaxRule', sort:false, label:'<spring:message code="Cache.lbl_n_att_workingMaxRule" />', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'>";
					html += ruleFormat(this.item.MaxWorkTime,this.item.MaxWorkCode,this.item.MaxUnitTerm,this.item.MaxWorkApplyDate,'/');
					html += "</p>";
					return html;
				}
	        }  ,   
			
			{ key:'ValidYn', label:"<spring:message code='Cache.lbl_IsUse' />",width:'60', align:'center',		//사용여부 <spring:message code='Cache.lbl_IsUse' />
				formatter : function () {
					var _div = $('<div />', {
						class : "alarm type01"
					});  
					
					var _a = $('<a />', {
						class : "onOffBtn"
						,"data-listtype" : this.item.ListType
						,"data-usercode" : this.item.UserCode
						,"data-applydate" : this.item.ApplyDate
					});  
					
					if(this.item.ListType!="OR"){
						_a.attr("onclick","updateWorkInfoStatus(this)");
					} else {
						_a.attr("onclick","refuseIsUseComInfo()");
					}
					
					if(this.item.ValidYn=="Y") { _a.addClass("on"); }
					_a.append("<span></span>");
					_div.append(_a);
					return _div[0].outerHTML;
				}
			},
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
			  	  sortBy : "ApplyDate DESC",
			  	  isAll : $("#chk_IsAll").is(":checked") ? "Y" : "N",
			  	  todayDate : CFN_GetLocalCurrentDate("yyyy-MM-dd")
			  	  };

	grid.page.pageNo = $("#pageNo").val();
	grid.page.pageSize = $("#listCntSel").val();

	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendAdmin/getWorkInfoList.do",
		ajaxPars : params
	});
}


//근로정보 추가 팝업
function goAddWorkInfoPop(){
	var url = "/groupware/attendAdmin/goWorkInfoAddPopup.do";
	var width = "470";
	var height = "360";
	Common.open("","workInfoPop","<spring:message code='Cache.btn_n_att_addWorkInfo' />",url,width,height,"iframe",true,null,null,true);
}
//근로정보 수정팝법
function goModWorkInfoPop(ListType, UserCode, ApplyDate){
	var url = "/groupware/attendAdmin/goWorkInfoModPopup.do?ListType="+ListType+"&UserCode="+UserCode+"&ApplyDate="+ApplyDate;
	var width = "470";
	var height = "360";
	Common.open("","workInfoPop","<spring:message code='Cache.btn_n_att_addWorkInfo' />",url,width,height,"iframe",true,null,null,true);
}

//조직도 팝업
function openOrgMapLayerPopup() {
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=D9","1060","580","iframe",true,null,null,true);	//조직도
}

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	wiUrArry = new Array();
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	var str = '';
	
	
//	var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
	
	$.each(item, function (i, v) {
		wiUrArry.push(item[i]);
		var p = $('<p />', {
			class : "tx_dept"
			,text : CFN_GetDicInfo(item[i].DN)
			,attr : {type : '', code : ''}
		}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
		
		str += p[0].outerHTML;
	});
	$('#workInfoPop_if').contents().find('#wiUserCode').html(str);
}	


var weekendStr = Common.getBaseCode("AttendWeekend").CacheData;
var workcodeStr = Common.getBaseCode("WorkCode").CacheData;
var unittermStr = Common.getBaseCode("UnitTerm").CacheData;
//요일변화
function weekendFormat(s,c){
	var weekArry = new Array();

	var index = 0;
	while (index < s.length) {
		if(s.charAt(index)== c ){
			weekArry.push(weekendStr[index].CodeName);
		}
		index ++;
	}
	
	var returnStr = "";
	for(var i=0;i<weekArry.length;i++){
		if(i!=0){
			returnStr += ",";
		}
		returnStr += weekArry[i];
	}
	return returnStr;
}

function ruleFormat(wt,wc,ut,ad,pr){
	var returnStr = "";
	var sWc = "";
	for(var i=0;i<workcodeStr.length;i++){
		if(workcodeStr[i].Code == wc){
			sWc = workcodeStr[i].CodeName;
			break;
		}
	}
	
	var sUt = "";
	for(var i=0;i<unittermStr.length;i++){
		if(unittermStr[i].Code == ut){
			sUt = unittermStr[i].CodeName;
			break;
		}
	}
	
	returnStr += wt+pr;
	returnStr += sWc+pr;
	returnStr += sUt+pr;
	returnStr += ad
	return returnStr;
}

//리스트 엑셀 다운로드
function excelListDownload(){
	location.href = "/groupware/attendAdmin/workInfoExcelListDownload.do"; 
}

function refuseIsUseComInfo() {
	Common.Warning("<spring:message code='Cache.CPMail_NonCancellable'/>(<spring:message code='Cache.lbl_CompanySet'/>)"); 	// 취소 불가(회사설정)
}

function updateWorkInfoStatus(o){

	var obj = $(o);

	var params = {
			listtype : obj.data("listtype")
			,usercode : obj.data("usercode")
			,applydate : obj.data("applydate")
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
		url:"/groupware/attendAdmin/setWorkInfo.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				//search();
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				search();
			}
		}
	});  
}

function isValidityDel() {
	let chkData = grid.getCheckedList(0);
	let chkCnt = 0;
	chkData.forEach(function(el) {
		if (el.ListType === "OR") { chkCnt++; }
	});
	
	return (chkCnt > 0) ? false : true;
}

//근로정보 삭제
function delWorkInfo(){
	if($("input[name=chk]:checked").length==0){
		Common.Warning("<spring:message code='Cache.msg_selectTargetDelete'/>");
	}else{
		if (!isValidityDel()) {
			Common.Warning("<spring:message code='Cache.msg_n_att_unableToDelBasicWorkInfo'/>"); 	// 기본 근로정보를 삭제할 수 없습니다.
			return;
		} else {
			Common.Confirm("<spring:message code='Cache.msg_Common_08' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					
					var delArry = new Array();
					for(var i=0;i<$("input[name=chk]:checked").length;i++){
						delArry.push($("input[name=chk]:checked").eq(i).val());
					}
					var params = {
							pid : JSON.stringify(delArry)
						}; 
					$.ajax({
						type:"POST",
						dataType : "json",
						data: params,
						url:"/groupware/attendAdmin/delWorkInfo.do",
						success:function (data) {
							if(data.status =="SUCCESS"){
								if(data.msg!=""){
									Common.Warning(data.msg);
								}
								search();
							}else{
								Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
							}
						}
					});
				}
			});
			// else end.
		}
	}
}


</script>
