<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.SessionCommonHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
input[type="checkbox"] { display:inline-block; }
.tblList .AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr td select { min-width:56px; }
</style>

<div class='cRConTop titType AtnTop'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_n_att_vacTypeMng' /></h2>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02"></div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="vacationVacationTypeMng.addVacationTypePop('');"><spring:message code='Cache.lbl_VacationTypeAdd' /></a>
				<a href="#" class="btnTypeDefault" onclick="vacationVacationTypeMng.delVacationType();"><spring:message code='Cache.btn_Delete' /></a>
			</div>
			<div class="buttonStyleBoxRight">	
                <covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button" ></button>							
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
           		<covi:grid id="gridDiv" gridVar="vacationTypeGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="CodeID"	label="chk"	     width="20"  align="center" formatter="checkbox"/>
					  <td key="IsUse"		label="lbl_IsUse"	width="40" align="left" sort="false" formatter="SWITCH"  formatAddtion="Code" callback="vacationVacationTypeMng.switchUse"/>
					  <td key="Code"		label="lbl_Codes"	     width="100"  align="left" />
					  <td key="CodeName"	label="lbl_Vaction_Name"	     width="200"  align="left" formatter="LINK" linkEvent="vacationVacationTypeMng.addVacationTypePop"/>
					  <td key="SortKey"		label="lbl_Sort"	     width="20"  align="center" />
					  <td key="Reserved1"	label="lbl_n_att_vacTypeDed"	     width="80"  align="center" formatter="CUSTOM" formatAddtion="vacationVacationTypeMng.formatDeduction"/>
					</tr>
				</covi:grid>	  
			</div>
		</div>
	</div>
</div>

<script>
var vacationVacationTypeMng = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();

	var grid = new coviGrid();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	this.formatIsUse=function(item){
		 return (item.IsUse=="Y"?"<spring:message code='Cache.lbl_Use' />":"<spring:message code='Cache.lbl_UseN' />");
	}
	this.formatDeduction=function(item){
		 return (item.Reserved1=="Y"?"<spring:message code='Cache.lbl_Deduction' />":"<spring:message code='Cache.lbl_NoDeduction' />");
	}
	this.switchUse= function (code, isUse) {
		coviUtil.getAjaxPost("/covicore/basecode/modifyUse.do", {"Code" : code,	"CodeGroup" : "VACATION_TYPE",	"DomainID" : "<%=SessionCommonHelper.getSession("DN_ID")%>",	"IsUse" : isUse},
			 function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");
					search();
				}
			});
	}	
	
	this.initContent = function(bLoad, linkUrl) {
		if (bLoad != true){
			grid.setGridConfig(vacationTypeGrid);
			search();	// 검색
		}else{
			grid.bindEvent(true);
		}
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			CFN_SetCookieDay("VacListCnt", $(this).find("option:selected").val(), 31536000000);
			grid.reloadList();
		});
		
		$('.btnRefresh').on('click', function(e) {
			search();
		});
		
	}
	
    this.search=function() {
    	search();
    }
	// 검색
	function search() {
		var params = {
			sortBy : "SortKey asc"
			,showAll : "Y"
		};
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationTypeList.do",
			ajaxPars : params,
			onLoad : function() {
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				//$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
				//grid.fnMakeNavi("grid");
			}
		});
	}
	
	function updVacUsedYn(o){
		var id = $(o).data("swid");
		var isUse = "";
		var reserved1 = "";
		var reservedInt = "";
		if(id=="IsUse"){
			if($(o).attr("class").lastIndexOf('on')>0){
				isUse = "N";
				$(o).removeClass("on");
			}else{
				isUse = "Y";
				$(o).addClass("on");
			}
		}else if(id=="Reserved1"){
			if($(o).attr("class").lastIndexOf('on')>0){
				reserved1 = "N";
				$(o).removeClass("on");
			}else{
				reserved1 = "Y";
				$(o).addClass("on");
			}
		}else if(id=="AttGroup"){
			reservedInt = $(o).val();
		}
		
		
		
		var params = {
			IsUse : isUse,
			Reserved1 : reserved1,
			ReservedInt : reservedInt,
			CodeID : $(o).data("codeid")
		};
		
		$.ajax({
			type : "POST",
			data : params,
			async: false,
			url : "/groupware/vacation/updVacationType.do",
			success:function (list) {
				
			},
			error:function(response, status, error) {
				CFN_ErrorAjax("/groupware/vacation/updVacationType.do", response, status, error);
			}
		});
		
	}
	
	//휴가구분 등록 팝업
	this.addVacationTypePop=function(item){
		let Code = '';
		if(item != null && item != ''){
			Code = item.Code;
		}
		Common.open("","target_pop","<spring:message code='Cache.lbl_n_att_vacTypeMng' />","/groupware/vacation/goVacationTypeAddPopup.do?Code="+Code,"551px","400px","iframe",true,null,null,true);
	}
	
	//휴가구분 삭제
	this.delVacationType=function(){
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
						CodeID : delArry
					}; 
					
					jQuery.ajaxSettings.traditional = true;	
					$.ajax({
						type : "POST",
						data : params,
						async: false,
						url : "/groupware/vacation/deleteVacationType.do",
						success:function (data) {
							if(data.status =="SUCCESS"){
								//휴가 유평 변경완료시 basecode reload cache
								coviCmn.reloadCache("BASECODE", Common.getSession("DN_ID"));
								search();
							}else{
								Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
							}
						},
						error:function(response, status, error) {
							CFN_ErrorAjax("/groupware/vacation/deleteVacationType.do", response, status, error);
						}
					});
				}
			});
		}
	}
}();

$(document).ready(function(){
	vacationVacationTypeMng.initContent();
});

	
</script>			