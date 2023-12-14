<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_manage_anonymousURL"/></span> <!-- 익명 접근 URL 관리  -->
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addAccessURLPopup();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteAccessURL();"/>
			<input type="button" class="AXButton"  value="<spring:message code="Cache.lbl_CacheInitialization"/>" onclick="resetAccessURLCache();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
			<select name="" class="AXSelect" id="searchType"></select>
			<input type="text" id="searchWord"  class="AXInput"  onkeypress="if (event.keyCode==13){ searchGrid(); return false;}"/>
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/>
		</div>
		<div id="accessURLGrid"></div>
	</div>
</form>
<script type="text/javascript">
var accessURLGrid;

initContent();

function initContent(){ 
	accessURLGrid = new coviGrid();
	
	setGrid();			
	setSelect();
	searchGrid();
}

//그리드 셋팅
function setGrid(){
	accessURLGrid.setGridHeader([
        {key:'AccessUrlID', label:'chk', width:'10', align:'center', formatter:'checkbox'},
        {key:'URL',  label:'URL', width:'40', align:'left',
      	  formatter:function(){
      		  return "<a href='#' onclick='modifyAccessURLPopup(\""+this.item.AccessUrlID+"\")'>" + this.item.URL + "</a>";
      	  }
        },	
        {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', width:'40', align:'center'}, /* 설명 */
        {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'15', align:'center',
      	  formatter:function () {
					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch_"+this.item.AccessUrlID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.AccessUrlID+"\");' />";
			  }
        },      /*사용유무*/
        {key:'IsAdmin', label:'<spring:message code="Cache.lbl_Anonymity"/>', width:'15', align:'center',
      	  formatter:function () {
					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitchAdmin_"+this.item.AccessUrlID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsAdmin+"' onchange='updateIsAdmin(\""+this.item.AccessUrlID+"\");' />";
			  }
        },      /*시스템호출(익명)*/
        {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'20', align:'center'},     /*등록자*/
        {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center', sort:"desc", formatter: function(){ 
				return CFN_TransLocalTime(this.item.ModifyDate);
 	  	}} /*수정일자  */
	]);
	
	accessURLGrid.setGridConfig({
		targetID : "accessURLGrid",
		height:"auto"
	});
}

//목록 조회
function searchGrid(){
	
	accessURLGrid.page.pageNo = 1;
	
	accessURLGrid.bindGrid({
			ajaxUrl:"/covicore/accessurl/getList.do",
			ajaxPars: {
				searchType : $("#searchType").val(), 
				searchWord : $("#searchWord").val()
			}
	});
}

//Select Box 바인딩
function setSelect(){
	//검색 조건
	$("#searchType").bindSelect({ 
		options: [{'optionValue':'URL','optionText':'URL'}
		,{'optionValue':'Description','optionText':'<spring:message code="Cache.lbl_Description"/>'}
		,{'optionValue':'RegisterName','optionText':'<spring:message code="Cache.lbl_Register"/>'}]
	});
}

//사용여부 수정
function updateIsUse(accessURLID){
	var isUse = $("#AXInputSwitch_"+accessURLID).val();
	
	$.ajax({
		type:"POST",
		data:{
			"accessURLID" : accessURLID,
			"isUse" : isUse
		},
		url:"/covicore/accessurl/modifyIsUse.do",
		success:function (data) {
			if(data.status!='SUCCESS'){
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function (response, status, error){
			CFN_ErrorAjax("/covicore/accessurl/modifyIsUse.do", response, status, error);
		}
	});
}
// 시스템호출 여부 ( N 으로 설정한 경우, 세션체크는 일반 URL 처럼 진행하나 세션연장은 하지 않는다. )
function updateIsAdmin(accessURLID){
	var isAdmin = $("#AXInputSwitchAdmin_"+accessURLID).val();
	
	$.ajax({
		type:"POST",
		data:{
			"accessURLID" : accessURLID,
			"isAdmin" : isAdmin
		},
		url:"/covicore/accessurl/modifyIsAdmin.do",
		success:function (data) {
			if(data.status!='SUCCESS'){
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function (response, status, error){
			CFN_ErrorAjax("/covicore/accessurl/modifyIsAdmin.do", response, status, error);
		}
	});
}


//삭제
function deleteAccessURL(){
	var deleteArr = accessURLGrid.getCheckedList(0);
	
	if(deleteArr.length == 0){
		Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
		return;
	}
	
	var deleteAccessURLIDs = "";
	
	for(var i=0; i<deleteArr.length; i++){
		if(i==0){
			deleteAccessURLIDs = deleteArr[i].AccessUrlID;
		}else{
			deleteAccessURLIDs = deleteAccessURLIDs + "|" + deleteArr[i].AccessUrlID;
		}
	}
	
	$.ajax({
		type:"POST",
		data:{
			"deleteAccessURLIDs" : deleteAccessURLIDs
		},
		url:"/covicore/accessurl/delete.do",
		success:function (data) {
			if(data.status=='SUCCESS'){
    			Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
    			accessURLGrid.reloadList();
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/accessurl/delete.do", response, status, error);
		}
	});
	
}

//캐시 초기화
function resetAccessURLCache(){
	$.ajax({
		type:"POST",
		url:"/covicore/accessurl/resetCache.do",
		success:function (data) {
			if(data.status=='SUCCESS'){
    			Common.Inform("<spring:message code='Cache.msg_apv_alert_006'/>"); // 성공적으로 처리 되었습니다.
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/accessurl/resetCache.do", response, status, error);
		}
	});
}

//새로고침
function refresh(){
	$("#searchType").bindSelectSetValue('');	
	$("#searchWord").val('');
	
	searchGrid();
}

//추가 팝업
function addAccessURLPopup(){
	parent.Common.open("","addaccessurl","<spring:message code='Cache.lbl_manage_anonymousURL'/>","/covicore/accessurl/goAccessURLPopup.do?mode=add","600px","230px","iframe",false,null,null,true);
}

//수정 팝업
function modifyAccessURLPopup(accessURLID){
	parent.Common.open("","updateaccessurl","<spring:message code='Cache.lbl_manage_anonymousURL'/>","/covicore/accessurl/goAccessURLPopup.do?mode=modify&accessURLID="+accessURLID,"600px","230px","iframe",false,null,null,true);
}

</script>