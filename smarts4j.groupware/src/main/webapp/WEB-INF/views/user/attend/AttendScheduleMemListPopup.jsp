<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">



$(document).ready(function() { 
	
	init();
});

function init(){
	getMemList();
	setDateConResource();
}


function setDateConResource(){
	target = 'calendar_picker';
	
	var timeInfos = {
			width : "0",
			H : "1,2,3,4",
			W : "1,2", //주 선택
			M : "1,2", //달 선택
			Y : "1,2" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'Y',
			useTimePicker : 'N',
			useBar : 'Y',
			useSeparation : 'Y',
			minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
			timePickerwidth : '50',
			height : '200',
			use59 : 'Y'
		};
	
	coviCtrl.renderDateSelect2(target, initInfos);
	
	// onchange 함수 세팅
	$("#resourceSimpleMake").find("input,select").attr("onchange", "funcRESOnChange();");
}

var tte;
function getMemList(){
	
	var param = {
				"SchSeq":"${SchSeq}"
				,"pageNo" : $("#pageNo").val()
				,"pageSize" : 30
				,"S_StartDate" : $("#S_StartDate").val()
				,"S_EndDate" : $("#S_EndDate").val() 
				,"S_Specifier" : $("#S_Specifier").val() 
			}
	$.ajax({
		type:"POST",
		url:"/groupware/attendSchedule/getAttendSchMemList.do",
		data : param,
		dataType : "json",
		success:function (data) {
			tte = data;
			 $("#S_StartDate").val(data.S_StartDate);
			 $("#S_EndDate").val(data.S_EndDate);
			 $("#S_Specifier").val(data.S_Specifier);

			var schMemList = data.schMemList;
			var htmlStr = "";
			if(schMemList.length==0){
				htmlStr +="<tr>";
				htmlStr +="<td colspan=4 align='center'><spring:message code='Cache.msg_att_schMem_empty'/></td>";	
				htmlStr +="</tr>";
				
				$("#pagediv").html("");
			}else{
				for(var i=0;i<schMemList.length;i++){
					htmlStr +="<tr>";
					htmlStr +="<td align='center'>";
					htmlStr +="<input  ";
					if(schMemList[i].Valid=="Y"){
						htmlStr +="class='chkMem' value='"+schMemList[i].ScMemSeq+";"+schMemList[i].UserCode+"' onclick='ckboxCheck();'";						
					}else{
						htmlStr +="disabled";
					}
					htmlStr +=" type='checkbox'>";
					htmlStr +="</td>";
					htmlStr +="<td align='left'>"+schMemList[i].userMulti+"("+schMemList[i].TransChargeBusiness+")</td>";
					htmlStr +="<td align='center'>"+schMemList[i].StartDtm+"</td>";
					htmlStr +="<td align='center'>"+schMemList[i].EndDtm+"</td>";
					htmlStr +="</tr>";
				}
				
				/* table_paging */
				var page = data.page;
				
				var pageStr= "";
				pageStr+="<input type='button' class='paging_begin' onclick=\"setPage('"+page.beginPage+"');\")>";
				pageStr+="<input type='button' class='paging_prev' onclick=\"setPage('"+page.beforePage+"');\">";

				for(var i=page.startPage;i<=page.endPage;i++){
					pageStr+="<input type='button' value='"+(i)+"' onclick=\"setPage('"+(i)+"');\" class='paging ";
					if(page.page==(i)){
						pageStr+="selected";					
					}				
					pageStr+=" '>";
				}
				pageStr+="<input type='button' class='paging_next'  onclick=\"setPage('"+page.nextPage+"');\">";
				pageStr+="<input type='button' class='paging_end'  onclick=\"setPage('"+page.lastPage+"');\">";
				

				$("#pagediv").html(pageStr);			
			}
			$("#tbodySchMem").html(htmlStr);	
		}
	});
}

/*지정자목록팝업
function openSchMemAddPopup(seq,s) {
	alert(1)
	var url = "/groupware/attendSchedule/goAttSchMemAddPopup.do?SchSeq="+seq;		
	var title = "<spring:message code='Cache.lbl_att_specifier'/>"; // 지정자
	//parent.Common.open("","SchMemAddPop",title,url,"420px","500px","iframe",true,null,null,true);
	
	var g_lastURL = "";
	CoviMenu_GetContent(url);
	g_lastURL = url;

}
*/


//레이어 팝업 닫기
function closeLayer(){
	parent.Common.close("SchMemPop");
	parent.Common.Close();
}


function delMember(){
	var delArry = new Array();
	for(var i=0;i<$(".chkMem").length;i++){
		if($(".chkMem").eq(i).is(":checked")){
			delArry.push($(".chkMem").eq(i).val());				
		}
	}
	if(delArry.length>0){
		jQuery.ajaxSettings.traditional = true;	
		$.ajax({
			type:"POST",
			dataType : "json",
			url:"/groupware/attendSchedule/delAttendSchMember.do",
			data : {"ScMemSeq":delArry , "SchSeq":"${SchSeq}"},
			success:function (data) {
				if(data.status=="SUCCESS"){
					setPage(1);
				}
			},error:function(request,status,error){
				 alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			}	 
		});
	}else{
		Common.Inform("<spring:message code='Cache.mag_Attendance48' />", "Inform","");	//삭제할 행을 선택 해 주세요
	}
}

function allCheck(o){
	$(".chkMem").prop("checked",$(o).is(":checked"));
}

function ckboxCheck(){
	var flag = $(".chkMem").length > 0 ?true:false;
	for(var i=0;i<$(".chkMem").length;i++){
		if(!($(".chkMem")[i].checked)){
			flag = false;
			break;
		}
	}
	$("#allChkMem").prop("checked",flag);
}

function openMemAddPop(seq){
	url = "/groupware/attendSchedule/goAttSchMemAddPopup.do?SchSeq="+seq;			
	title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
	var w = "420";
	var h = "480";
	top.Common.close("SchMemPop");
	top.Common.open("","SchMemAddPop",title,url,w,h,"iframe",true,null,null,true);
}

function setPage (n) {
	$("#pageNo").val(n);
	getMemList();
}

function searchList(){
	$("#pageNo").val(1);
	$("#S_StartDate").val($("#calendar_picker_StartDate").val());
	$("#S_EndDate").val($("#calendar_picker_EndDate").val());
	$("#S_Specifier").val($("#searchNm").val());
	getMemList();
}


</script>
<style type="text/css">
.searchDiv{ padding : 5px 0px 0px 0px }
#searchNm { width : 155px }
</style>
</head>
<body>
<input type="hidden" id="pageNo" value="1" />
<input type="hidden" id="S_StartDate" value="" />
<input type="hidden" id="S_EndDate" value="" />
<input type="hidden" id="S_Specifier" value="" />
<div id="content">
	<div class="ui-draggable" style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="WorkingStatus_popup">
			<div class="WorkingStatus_top">
			
				<a class="btnTypeDefault" href="#" onclick="openMemAddPop('${SchSeq}');"><spring:message code='Cache.lbl_att_specifier_add'/></a>	<!-- 지정자추가 -->
				<a class="btnTypeDefault" href="#" onclick="delMember();"><spring:message code='Cache.btn_Delete'/></a>	<!-- 삭제 -->
				<div class="searchDiv">
					<input type="text" id="searchNm" class=""  placeholder="<spring:message code='Cache.mag_Attendance62' />" /> <!-- 지정자 명 -->
					<a class="btnTypeDefault f_right" href="#" onclick="searchList();"><spring:message code='Cache.btn_search'/></a>	<!-- 검색 -->
					<div class="f_right" id="calendar_picker"></div>					
				</div>
			</div>	
			<div class="WorkingStatus_table_wrap">
				<table class="WorkingStatus_table" cellpadding="0" cellspacing="0">
					<colgroup>
						<col width="30">
						<col width="*">
						<col width="100">
						<col width="100">
					</colgroup>
					<thead>
						<tr>
							<th><input id="allChkMem" onclick="allCheck(this);" type="checkbox"></th>
							<th><spring:message code='Cache.lbl_att_specifier'/></th>	<!-- 지정자 -->
							<th><spring:message code='Cache.lbl_startdate'/></th>	<!-- 시작일 -->
							<th><spring:message code='Cache.lbl_EndDate'/></th>	<!-- 종료일 -->
						</tr>
					</thead>
					<tbody id="tbodySchMem"></tbody>
				</table>
			</div>
			<div class="table_paging" id="pagediv" ></div>
			<div class="popBtnWrap">
				<a class="btnTypeDefault btnTypeBg" href="#" id="closeBtn" onclick="closeLayer();"><spring:message code='Cache.btn_ok'/></a>	<!-- 확인 -->
			</div>
		</div>
	</div>
</div>
</body>
</html>
