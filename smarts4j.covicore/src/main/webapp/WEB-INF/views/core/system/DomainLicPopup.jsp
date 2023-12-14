<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	#grid .AXgridPageBody { display: none !important; }
</style>

<div class="moduleLCpop">
	<div id="grid"></div>
	<div align="center" style="padding-top: 10px">
		<input type="button" id="btnConfirm" class="AXButton red" value="<spring:message code="Cache.btn_Confirm"/>"/> <!-- 확인 -->
		<input type="button" id="btnClose" class="AXButton" value="<spring:message code="Cache.btn_Close"/>"/> <!-- 닫기 -->
	</div>
</div>

<script>
	var domainID = "${domainID}" === "undefined" ? "-1" : "${domainID}";
	var isOpt = "${isOpt}";
	var seqList = "${seqList}";
	
	var grid = new coviGrid();
	
	function setEvent(){
		// 확인
		$("#btnConfirm").on("click", function(){
			addLicense();
		});
		
		// 닫기
		$("#btnClose").on("click", function(){
			Common.Close();
		});
	}
	
	function setGridConfig(){
		grid.setGridHeader([
			{key:'chk', label:'chk', width:'2', align:'center', sort: false, formatter: 'checkbox', disabled: function(){return seqList.indexOf(";" + this.item.LicSeq + ";") > -1;}},
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'10', align:'left', sort: false}, // 라이선스
			{key:'Description', label:'<spring:message code="Cache.lbl_licenseDescription"/>', width:'15', align:'left', sort: false}, // 라이선스 설명
			{key:'ModuleName', label:'<spring:message code="Cache.lbl_includedModule"/>', width:'20', align:'center', sort: false}, // 포함모듈
			{key:'ServiceUser', label:'<spring:message code="Cache.lbl_formApplyCnt"/>', width:'10', align:'center', sort: false, formatter: function(){ // 정식신청수량
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ServiceUser, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicUser", "style": "width: 88%;"});
				
				if (seqList.indexOf(";" + this.item.LicSeq + ";") > -1) returnObj.prop("disabled", true);
				
				return returnObj[0].outerHTML;
			}},
			{key:'ExtraExpiredate', label:'<spring:message code="Cache.lbl_tempDeadline"/>', width:'10', align:'center', sort: false, formatter: function(){ // 임시기한
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ExtraExpiredate, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicExDate", "style": "width: 88%;"});

				if (seqList.indexOf(";" + this.item.LicSeq + ";") > -1) returnObj.prop("disabled", true);
				
				return returnObj[0].outerHTML;
			}},
			{key:'ExtraServiceUser', label:'<spring:message code="Cache.lbl_tempCnt"/>', width:'10', align:'center', sort: false, formatter: function(){ // 임시수량
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ExtraServiceUser, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicExUser", "style": "width: 88%;"});

				if (seqList.indexOf(";" + this.item.LicSeq + ";") > -1) returnObj.prop("disabled", true);
				
				return returnObj[0].outerHTML;
			}}
		]);
		
		grid.setGridConfig({
			targetID: "grid",
			height: "auto",
			listCountMSG: " ",
			paging: false,
			page: {
				paging: false,
				pageSize: 10
			}
		});
		
		setGrid();
	}
	
	function setGrid(){
		grid.bindGrid({
			ajaxUrl: "/covicore/domain/getDomainLicAddList.do",
			ajaxPars: {
				"domainID": domainID,
				"isOpt": isOpt
			}
		});
	}
	
	function addLicense(){
		var checkedList = grid.getCheckedListWithIndex(0);
		
		if (checkedList.length <= 0) {
			Common.Warning('<spring:message code="Cache.ACC_msg_noDataInsert"/>'); // 추가할 항목을 선택해주세요
			return false;
		} else {
			var licList = [];
			var bool = true;
			
			checkedList.forEach(function(chk){
				var $selGrid = $("#grid .AXGridBody .gridBodyTr").eq(chk.index);
				
				if (!$selGrid.find(".inputLicUser").val()) {
					bool = false;
					return;
				}
				
				chk.item.ServiceUser = $selGrid.find(".inputLicUser").val();
				chk.item.ExtraExpiredate = $selGrid.find(".inputLicExDate").val();
				chk.item.ExtraServiceUser = $selGrid.find(".inputLicExUser").val();
				
				licList.push(chk.item);
			});
			
			if (!bool) {
				Common.Warning('<spring:message code="Cache.msg_enterApplyCnt"/>'); // 정식 신청수량을 입력해주세요.
				return false;
			}
			
			parent.$("#setDomain_if")[0].contentWindow.addRow(isOpt, licList);
			Common.Close();
		}
	}
	
	function init(){
		setEvent();
		setGridConfig();
	}
	
	init();
	
</script>