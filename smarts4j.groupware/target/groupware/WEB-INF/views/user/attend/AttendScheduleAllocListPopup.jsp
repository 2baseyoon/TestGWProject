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
	getAllocList();
}

function getAllocList(){
	
	var param = {
				"SchSeq":"${SchSeq}"
				,"pageNo" : $("#pageNo").val()
				,"pageSize": "5"
				,"S_Specifier" : $("#S_Specifier").val() 
			}

	$.ajax({
		type:"POST",
		url:"/groupware/attendSchedule/getAttendSchAllocList.do",
		data : param,
		success:function (data) {
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
					htmlStr +="<input  class='chkMem' value='"+schMemList[i].AllocSeq+"' onclick='ckboxCheck();' type='checkbox'>";
					htmlStr +="</td>";
					if(schMemList[i].AllocType == "GR"){
						htmlStr +="<td align='center'>"+ Common.getDic('lbl_dept') +"</td>";
					} else if(schMemList[i].AllocType == "UR"){
						htmlStr +="<td align='center'>"+ Common.getDic('lbl_User') +"</td>";
					} else {
						htmlStr +="<td align='center'>"+ Common.getDic('lbl_Company') +"</td>";
					}
					htmlStr +="<td align='center'>"+schMemList[i].AllocName+"</td>";
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

function delAlloc(){
	var delArry = [];
	for(var i=0;i<$(".chkMem").length;i++){
		if($(".chkMem").eq(i).is(":checked")){
			var saveData = { "SchSeq":"${SchSeq}", "AllocSeq":$(".chkMem").eq(i).val()};
			delArry.push(saveData);
		}
	}

	if(delArry.length>0){
		jQuery.ajaxSettings.traditional = true;	
		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			url:"/groupware/attendSchedule/delAttendSchAlloc.do",
			data : JSON.stringify( {"dataList" : delArry}),
			dataType : "json",
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

function setPage (n) {
	$("#pageNo").val(n);
	getAllocList();
}

function searchList(){
	$("#pageNo").val(1);
	$("#S_Specifier").val($("#searchNm").val());
	getAllocList();
}


function openGroupLayer(){
 	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callbackSchMember&targetID=orgChart","openGroupLayerPop",1060,580,"");
}


function callbackSchMember(result){
	var cbData =  $.parseJSON(result);
	
	var companyCode = '${params.CompanyCode}';
	var item = cbData.item;
	var flag = true;
	var aJsonArray = [];

	for(var i=0;i<item.length;i++){
		/*if(companyCode!= item[i].CompanyCode){
			flag = false;
			Common.Inform("동일 그룹사 사원만 등록 가능합니다.","warning","");
			break;
		}
		
		
		for(var j=0;j<addUserArry.length;j++){
			if(addUserArry[j][0]==item[i].UserCode){
				flag = false;
				Common.Inform("이미 추가 된 사용자입니다.","warning","");
				break;
			}
		}*/
		var sObjectType = item[i].itemType;
		var AllocType = "GR";
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			AllocType = "UR";
  		}
  		else if (item[i].GroupType.toUpperCase() == "COMPANY"){
  			AllocType = "CM";
		}
		var saveData = { "SchSeq":"${SchSeq}", "AllocType":AllocType, "AllocID":item[i].AN};
        aJsonArray.push(saveData);

	} 

	if (!flag) return;	
	
	var objParams = {"dataList" : aJsonArray};

	$.ajax({
		type:"POST",
		contentType:'application/json; charset=utf-8',
		dataType   : 'json',
		data:JSON.stringify(objParams),
		url:"/groupware/attendSchedule/setAttendSchAlloc.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){	//저장되었습니다.
					setPage(1);
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */	
			}
			
		},error:function(request,status,error){
			 alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
		}
	});
}
	
//레이어 팝업 닫기
function closeLayer(){
	parent.Common.close("SchAllocPop");
	parent.Common.Close();
}


</script>
<style type="text/css">
.searchDiv{ padding : 5px 0px 0px 0px }
#searchNm { width : 155px }
</style>
</head>
<body>
<input type="hidden" id="pageNo" value="1" />
<input type="hidden" id="S_Specifier" value="" />
<div id="content">
	<div class="ui-draggable" style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="WorkingStatus_popup">
			<div class="WorkingStatus_top">
			
				<div class="searchDiv">
					<a class="btnTypeDefault" href="#" onclick="openGroupLayer('${SchSeq}');"><spring:message code='Cache.ObjectType_UR'/><spring:message code='Cache.btn_Add'/></a>	<!-- 사용자추가 -->
					<a class="btnTypeDefault" href="#" onclick="delAlloc();"><spring:message code='Cache.btn_Delete'/></a>	<!-- 삭제 -->
					<input class="ml80" id="searchNm" class=""  placeholder="<spring:message code='Cache.CPMail_UserName'/>" /> <!-- 사용자명 -->
					<a class="btnTypeDefault f_right" href="#" onclick="searchList();"><spring:message code='Cache.btn_search'/></a>	<!-- 검색 -->
				</div>
			</div>	
			<div class="WorkingStatus_table_wrap">
				<table class="WorkingStatus_table" cellpadding="0" cellspacing="0">
					<colgroup>
						<col width="44">
						<col width="100">
						<col width="*">
					</colgroup>
					<thead>
						<tr>
							<th><input id="allChkMem" onclick="allCheck(this);" type="checkbox"></th>
							<th><spring:message code='Cache.lbl_SchDivision'/></th>	<!-- 구분 -->
							<th><spring:message code='Cache.ObjectType_UR'/></th>	<!-- 사용자 -->
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
