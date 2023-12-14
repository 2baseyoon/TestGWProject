<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:400px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 45%;">
						<col style="width: 55%;">
					</colgroup>
					<tbody></tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk" style="display: none;"><spring:message code='Cache.btn_save' /></a> <!-- 저장 -->
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;" style="display: none;"><spring:message code='Cache.btn_apv_close' /></a> <!-- 닫기 -->
				<a id="btnCancel" class="btnTypeDefault" onclick="Common.Close(); return false;" style="display: none;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var seriesCode = CFN_GetQueryString("seriesCode") == "undefined" ? "" : CFN_GetQueryString("seriesCode");
	var deptCode = CFN_GetQueryString("deptCode") == "undefined" ? "" : CFN_GetQueryString("deptCode");
	var mode = CFN_GetQueryString("mode") == "undefined" ? "" : CFN_GetQueryString("mode");
	var baseYear = CFN_GetQueryString("baseYear") == "undefined" ? "" : CFN_GetQueryString("baseYear");
	
   window.onload = initOnload;
   function initOnload() {
	setPopup();
   }
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		switch(mode){
			case "I": // 추가
			case "M": // 수정
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_unitTaskType"/></th>'; // 단위업무 유형
				popupHtml += '	<td>';
				popupHtml += '		<select id="selUnitTaskType" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr id="unitZAgubun">';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_apv_ManageDept"/></th>'; // 처리과
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="deptName" style="width: 150px; margin-left: 5px;" readonly>';
				popupHtml += '		<button class="btnTblSearch" onclick="orgChartPopup();" style="display: inline-block;"><spring:message code="Cache.lbl_DeptOrgMap"/></button>'; // 조직도
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_BizSection" /></th>'; // 업무구분
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="seriesPath" style="width: 150px; margin-left: 5px;" readonly>';
				popupHtml += '		<button class="btnTblSearch" onclick="seriesFunctionPopup();" style="display: inline-block;"><spring:message code="Cache.lbl_Path" /></button>'; // 경로
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_unitTaskName"/></th>'; // 단위업무명
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="seriesName" style="width: 150px; margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_unitTaskDescription"/></th>'; // 단위업무 설명
				popupHtml += '	<td>';
				popupHtml += '		<textarea id="seriesDescription" style="margin: 5px; width: 150px; resize: none;"></textarea>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_productYear"/></th>'; // 생산년도
				popupHtml += '	<td>';
				popupHtml += '		<input id="selproductYear" type="text" maxlength="4" onKeyup="this.value=this.value.replace(/[^-0-9]/g,\'\');" style="width: 150px; margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriod"/></th>'; // 보존기간
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepPeriod" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_preservationPeriodReason"/></th>'; // 보존기간 책정사유
				popupHtml += '	<td>';
				popupHtml += '		<textarea id="keepPeriodReason" style="margin: 5px; width: 150px; resize: none;"></textarea>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationMethod"/></th>'; // 보존방법
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepMethod" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPlace"/></th>'; // 보존장소
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepPlace" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '		<input type="hidden" id="MappingID">';				
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				break;
			case "R": // 조회
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskType"/></th>'; // 단위업무 유형
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_apv_ManageDept"/></th>'; // 처리과
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_Path" /></th>'; // 경로
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskName"/></th>'; // 단위업무명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskDescription"/></th>'; // 단위업무 설명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_productYear"/></th>'; //생산년도
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriod"/></th>'; // 보존기간
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriodReason"/></th>'; // 보존기간 책정사유
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationMethod"/></th>'; // 보존방법
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPlace"/></th>'; // 보존장소
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				break;
		}
		
		$(".middle table tbody").html(popupHtml);
		setCombo();
		
		$("#btnSave").off("click").on("click", function(){
			checkValidation();
		});
		
		if(mode != "I"){
			setData();
		}else{
			$("#btnSave").show();
			$("#btnCancel").show();
		}
	}
	
	$(document).on("change", "#selUnitTaskType", function(){
		if(this.value == "ZA"){
			document.getElementById("unitZAgubun").style.display = "none";		
		}else if(this.value == "ZZ"){
			document.getElementById("unitZAgubun").style.display = "none";	
		}else{
			document.getElementById("unitZAgubun").style.display = "";			
		}
	});
	
	function setCombo(){
		var lang = Common.getSession("lang");
		
		var initInfos = [
			{
				target: "selUnitTaskType",
				codeGroup: "UnitTaskType",
				defaultVal: "UnitTaskType"
			},
			{
				target: "selKeepPeriod",
				codeGroup: "KeepPeriod",
				defaultVal: "KeepPeriod"
			},
			{
				target: "selKeepMethod",
				codeGroup: "KeepMethod",
				defaultVal: "KeepMethod"
			},
			{
				target: "selKeepPlace",
				codeGroup: "KeepPlace",
				defaultVal: "KeepPlace"
			}
		];
		
		coviCtrl.renderAjaxSelect(initInfos, '', lang);
	}
	
	function setData(){
		var seriesPath = getSeriesPath(seriesCode);
		$("#seriesPath").val(seriesPath);
		
		$.ajax({
			url: "/approval/user/getSeriesListData.do",
			type: "POST",
			data: {
				"seriesCode": seriesCode,
				"deptCode": deptCode,
				"baseYear": baseYear
			},
			success: function(data){
				var seriesData = data.list[0];
				
				if(mode == "M"){
					$("#selUnitTaskType").val(seriesData.UnitTaskType).prop("disabled", true);
					$("#deptName").val(seriesData.DeptName);
					$("#deptName").attr("deptcode", seriesData.DeptCode);
					$("#seriesPath").attr("sfcode", seriesData.SFCode);
					$("#seriesName").val(seriesData.SeriesName);
					$("#seriesDescription").text(seriesData.SeriesDescription);
					$("#selKeepPeriod").val(seriesData.KeepPeriod == "" ? "KeepPeriod" : seriesData.KeepPeriod);
					$("#keepPeriodReason").text(seriesData.KeepPeriodReason);
					$("#selKeepMethod").val(seriesData.KeepMethod == "" ? "KeepMethod" : seriesData.KeepMethod);
					$("#selKeepPlace").val(seriesData.KeepPlace == "" ? "KeepPlace" : seriesData.KeepPlace);
					$("#MappingID").val(seriesData.MappingID);
					$("#selproductYear").val(seriesData.BaseYear);	
					
					$("#btnSave").show();
					$("#btnCancel").show();
				}else if(mode == "R"){
					var trObj = $(".middle table tbody tr");
					
					trObj.eq(0).find("td").text(seriesData.UnitTaskTypeTxt);//단위업무 유형
					trObj.eq(1).find("td").text(seriesData.DeptName);//처리과
					trObj.eq(2).find("td").text(seriesPath);//경로
					trObj.eq(3).find("td").text(seriesData.SeriesName);//단위업무명
					trObj.eq(4).find("td").text(seriesData.SeriesDescription);//단위업무설명
					trObj.eq(5).find("td").text(seriesData.KeepPeriodTxt);//보존기간
					trObj.eq(6).find("td").text(seriesData.BaseYear);//생산년도
					trObj.eq(7).find("td").text(seriesData.KeepPeriodReason);//보존기간 책정사유
					trObj.eq(8).find("td").text(seriesData.KeepMethodTxt);//보존방법
					trObj.eq(9).find("td").text(seriesData.KeepPlaceTxt);//보존장소
					
					$("#btnClose").show();
				}
				
				if(seriesData.UnitTaskType == "ZA") document.getElementById("unitZAgubun").style.display = "none";						
				
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
	
	function getSeriesPath(seriesCode){
		var seriesPath = "";
		
		$.ajax({
			url: "/approval/user/getSeriesPath.do",
			type: "POST",
			data: {
				"SeriesCode": seriesCode,
				"BaseYear": baseYear
			},
			async: false,
			success: function (data) {
				seriesPath = data.SeriesPath;
			},
			error: function(response, status, error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			},
		});
		
		return seriesPath;
	}
	
	//조직도 팝업 호출
	function orgChartPopup(){
		let selectedData = $.trim($("#deptName").attr("deptcode"));
		let target = {
			selected : selectedData
		}
		let url = "/covicore/control/goOrgChart.do?type=C9&callBackFunc=seriesAddOrgPopup_CallBack";
		url += '&userParams=' + encodeURIComponent(JSON.stringify(target));
		
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />",url,"1000px","580px","iframe",true,null,null,true);
	}
	
	//단위업무 기능 팝업 호출
	function seriesFunctionPopup(){
		parent.Common.open("","seriesFunction_pop","<spring:message code='Cache.lbl_selectPath' />","/approval/user/getSeriesFunctionPopup.do?callBackFunc=seriesFunction_AddPopup_CallBack","500px","700px","iframe",true,null,null,true);
	}
	
	function checkValidation(){
		var UnitTaskType = $("#selUnitTaskType").val() == "UnitTaskType" ? "" : $("#selUnitTaskType").val();
		var DeptName = $("#deptName").val();
		var DeptCode = $("#deptName").attr("deptcode");
		var SFCode = $("#seriesPath").attr("sfcode");
		var SeriesName = $("#seriesName").val();
		var SeriesDescription = $("#seriesDescription").val();
		var KeepPeriod = $("#selKeepPeriod").val() == "KeepPeriod" ? "" : $("#selKeepPeriod").val();
		var KeepPeriodReason = $("#keepPeriodReason").val();
		var KeepMethod = $("#selKeepMethod").val() == "KeepMethod" ? "" : $("#selKeepMethod").val();
		var KeepPlace = $("#selKeepPlace").val() == "KeepPlace" ? "" : $("#selKeepPlace").val();
		var BaseYear = $("#selproductYear").val() == "" || $("#selproductYear").val().length!="4" ? "" : $("#selproductYear").val();
		var MappingID = $("#MappingID").val();
		if (UnitTaskType == 'ZA'){	
			DeptName = 'Total';
			DeptCode = 'Total';
		}else if (UnitTaskType == 'ZZ'){		
			DeptName = Common.getSession("DN_Name");
			DeptCode = '001';
		}
		if(UnitTaskType == "" || UnitTaskType == undefined){
			Common.Warning("<spring:message code='Cache.msg_selectUnitTaskType' />"); // 단위업무 유형을 선택해주세요.
			return false;
		}else if(DeptName == "" || DeptCode == ""){
			Common.Warning("<spring:message code='Cache.msg_selectProcessionDept' />"); // 처리과를 선택해주세요.
			return false;
		}else if(SeriesName == ""){
			Common.Warning("<spring:message code='Cache.msg_enterUnitTaskName' />"); // 단위업무명을 입력해주세요.
			return false;
		}else if(BaseYear == ""){
			Common.Warning("생산년도를 입력해주세요."); // 생산년도를 입력해주세요. 
			return false;
		}else if(SeriesDescription == ""){
			Common.Warning("<spring:message code='Cache.msg_enterUnitTaskDescription' />"); // 단위업무 설명을 입력해주세요.
			return false;
		}else if(KeepPeriodReason == ""){
			Common.Warning("<spring:message code='Cache.msg_enterPreservationReason' />"); // 보존기간 책정사유를 입력해주세요.
			return false;
		}
		
		var params = {
			"UnitTaskType": UnitTaskType,
			"DeptName": DeptName,
			"DeptCode": DeptCode,
			"SFCode": SFCode,
			"SeriesName": SeriesName,
			"SeriesDescription": SeriesDescription,
			"KeepPeriod": KeepPeriod,
			"KeepPeriodReason": KeepPeriodReason,
			"KeepMethod": KeepMethod,
			"KeepPlace": KeepPlace,
			"BaseYear": BaseYear,
			"MappingID" : MappingID
		}
		
		saveSeries(params);
	}
	
	function saveSeries(params){
		var url = "";
		
		if(mode == "I"){
			url = "/approval/user/insertSeriesData.do";
		}else{
			url = "/approval/user/modifySeriesData.do";
			params.SeriesCode = seriesCode;
		}
		
		$.ajax({
			url: url,
			type: "POST",
			data: params,
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform(data.message, "Information", function(result){
						if(result){
							Common.Close();
							parent.Refresh();
						}
					});
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
</script>