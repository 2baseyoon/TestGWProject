<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">내부망 관리</span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addTwoFactorPop();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteTwoFactor();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code="Cache.lbl_Domain"/>: <!-- 소유회사 -->
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
			<select name="" class="AXSelect" id="selectSearch"></select>
			<input type="text" id="searchInput"  class="AXInput"  onkeypress="if (event.keyCode==13){ searchGrid(); return false;}"/>
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/>
		</div>
		<div id="twoFactorgrid"></div>
	</div>
</form>

<script type="text/javascript">
var myGrid;
var headerData;
initContent();

function initContent(){ 
	myGrid = new coviGrid();
	// 헤더 설정
	
	headerData =[
	             {key:'SEQ', label:'chk', width:'20', align:'center', formatter:'checkbox'},
        		 {key:'COMPANYNAME', label:'<spring:message code="Cache.lbl_Domain"/>', width:'40', align:'center'}, // 소유 회사
	             {key:'STARTIP', label:'<spring:message code="Cache.lbl_StartIP"/>', width:'50', align:'center', formatter:function () {
         		 	return "<a href='#' onclick='updateTwoFactorPop(false, \""+ this.item.SEQ +"\"); return false;'>"+this.item.STARTIP+"</a>";
        		 }},
	             {key:'ENDIP',  label:'<spring:message code="Cache.lbl_EndIP"/>', width:'70', align:'center', formatter:function () {
         		 	return "<a href='#' onclick='updateTwoFactorPop(false, \""+ this.item.SEQ +"\"); return false;'>"+this.item.ENDIP+"</a>";
        		 }},
	             {key:'ISLOGIN', label:'<spring:message code="Cache.lbl_login"/>', width:'70', align:'center',
	              	  formatter:function () {
		      				return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputUserSwitch_"+this.item.SEQ+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.ISLOGIN+"' onchange='updateIsLogin(\""+this.item.SEQ+"\");' />";
		      			}},
		      	 {key:'ISADMIN', label:'<spring:message code="Cache.lbl_AdminDefaultURL"/>',   width:'70', align:'center',
			          formatter:function () {
				     		return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputAdminSwitch_"+this.item.SEQ+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.ISADMIN+"' onchange='updateIsAdmin(\""+this.item.SEQ+"\");' />";
				      }},
	             {key:'DESCRIPTION', label:'<spring:message code="Cache.lbl_Description"/>', width:'80', align:'center'},
	             {key:'REGISTERCODE', label:'<spring:message code="Cache.lbl_Register"/>', width:'80', align:'center'},
	             {key:'MODIFYDATE', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', sort:"desc", formatter: function(){
						return CFN_TransLocalTime(this.item.MODIFYDATE);
		  	  	 }}
					
		      	];
	setGrid();			// 그리드 세팅
	setSelect();		// Select Box 세팅
	searchGrid();
}

//그리드 세팅
function setGrid(){
	myGrid.setGridHeader(headerData);
	setGridConfig();
}

//그리드 Config 설정
function setGridConfig(){
	var configObj = {
		targetID : "twoFactorgrid",
		height:"auto"
	};
	
	myGrid.setGridConfig(configObj);
}

function searchGrid(){
	
	myGrid.page.pageNo = 1;
	
	myGrid.bindGrid({
			ajaxUrl:"/covicore/layout/TwoFactorManageList.do",
			ajaxPars: {
				selectsearch : $("#selectSearch").val(), 
				searchtext : $("#searchInput").val(),
				companyCode : $("#companySelectBox").val()
			}
	});
}

function setSelect(){
	var lang = Common.getSession("lang");
	
	coviCtrl.renderAXSelect('TwoFactorSearch', 'selectSearch', lang, '', '');
	coviCtrl.renderCompanyAXSelect("companySelectBox", lang, true, 'searchGrid', '');
}

function updateIsLogin(item){
	var isUseValue = $("#AXInputUserSwitch_"+item).val();
	$.ajax({
		type:"POST",
		data:{
			"seq" : item,
			"isTarget" : "U",
			"value" : isUseValue
		},
		url:"/covicore/layout/TwoFactorManageIsCheck.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_ChangeAlert'/>");
			}else{
				Common.Warning("<spring:message code='Cache.msg_changeFail'/>");
			}
		},
		error:function (response, status, error){
			CFN_ErrorAjax("/covicore/layout/TwoFactorManageIsCheck.do.do", response, status, error);
		}
	});
}

function updateIsAdmin(item){
	var isUseValue = $("#AXInputAdminSwitch_"+item).val();
	$.ajax({
		type:"POST",
		data:{
			"seq" : item,
			"isTarget" : "A",
			"value" : isUseValue
		},
		url:"/covicore/layout/TwoFactorManageIsCheck.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_ChangeAlert'/>");
			}else{
				Common.Warning("<spring:message code='Cache.msg_changeFail'/>");
			}
		},
		error:function (response, status, error){
			CFN_ErrorAjax("/covicore/layout/TwoFactorManageIsCheck.do.do", response, status, error);
		}
	});
}

//삭제
function deleteTwoFactor(){
	var deleteobj = myGrid.getCheckedList(0);
	if(deleteobj.length == 0){
		Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
		return;
	}else{
		var deleteSeq = "";
		for(var i=0; i<deleteobj.length; i++){
			if(i==0){
				deleteSeq = deleteobj[i].SEQ;
			}else{
				deleteSeq = deleteSeq + "," + deleteobj[i].SEQ;
			}
		}
		
		$.ajax({
			type:"POST",
			data:{
				"DeleteData" : deleteSeq
			},
			url:"/covicore/layout/TwoFactorDeleteList.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_138'/>");
				myGrid.reloadList();
			},
			error:function (error){
				CFN_ErrorAjax("/covicore/layout/TwoFactorDeleteList.do", response, status, error);
			}
		});
	}
}

// 새로고침
function Refresh(){
	$("#selectDomain").bindSelectSetValue('');	
	$("#selectSearch").bindSelectSetValue($("#selectSearch").find("option").eq(0).val());	
	$("#searchInput").val('');
	
	searchGrid();
}

function updateTwoFactorPop(pModal, item){
	parent.Common.open("","updatetwofactor","<spring:message code='Cache.CN_368'/>","/covicore/layout/TwoFactorInfoPopup.do?mode=modify&seq="+item,"600px","330px","iframe",pModal,null,null,true);
}

function addTwoFactorPop(){
	parent.Common.open("","addtwofactor","<spring:message code='Cache.CN_368'/>","/covicore/layout/TwoFactorInfoPopup.do?mode=add","600px","330px","iframe",false,null,null,true);
}


</script>