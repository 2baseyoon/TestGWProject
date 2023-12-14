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
					<input id="productYear" type="hidden" />
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
	var recordClassNum = CFN_GetQueryString("recordClassNum") == "undefined" ? "" : CFN_GetQueryString("recordClassNum");
	var mode = CFN_GetQueryString("mode") == "undefined" ? "" : CFN_GetQueryString("mode");
	
	setPopup();
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		switch(mode){
			case "I": // 추가
			case "M": // 수정
				btnTxt = '<spring:message code="Cache.lbl_apply" />'; // 적용
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_recordFileTitle" /></th>'; // 기록물철 제목
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="recordSubject" style="width: 150px; margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_unitTask"/></th>'; // 단위업무
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="seriesName" style="width: 150px; margin-left: 5px;" readonly>';
				popupHtml += '		<button class="btnTblSearch" onclick="seriesSearchPopup();" style="display: inline-block;">기능</button>'; // 기능
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_oldRecordProductName"/></th>'; // 기록물생산기관명
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="deptName" style="width: 150px; margin-left: 5px;" readonly>';
				popupHtml += '		<button class="btnTblSearch" onclick="orgChartPopup(\'C1\', \'recordAddOrgPopup_Dept_CallBack\');" style="display:none;"><spring:message code="Cache.lbl_DeptOrgMap"/></button>'; // 조직도
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_recordForm" /></th>'; // 기록물형태
				popupHtml += '	<td>';
				popupHtml += '		<select id="selRecordType" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_productYear" /></th>'; // 생산년도
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="selproductYear" type="text" maxlength="4" onKeyup="this.value=this.value.replace(/[^-0-9]/g,\'\');" style="width: 150px; margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_endYear" /></th>'; // 종료년도
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="endYear" type="text" maxlength="4" onKeyup="this.value=this.value.replace(/[^-0-9]/g,\'\');" style="width: 150px; margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_preservationPeriod"/></th>'; // 보존기간
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepPeriod" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_preservationMethod"/></th>'; // 보존방법
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepMethod" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_preservationPlace"/></th>'; // 보존장소
				popupHtml += '	<td>';
				popupHtml += '		<select id="selKeepPlace" class="selectType02" style="margin-left: 5px;"></select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_autoyearmake"/></th>'; // 년단위 자동생성
				popupHtml += '	<td>';
				popupHtml += '		<select id="selAutoYear" class="selectType02" style="margin-left: 5px;">';
				popupHtml += '			<option value="N"><spring:message code="Cache.lbl_noUse"/></option>'; // 사용안함
				popupHtml += '			<option value="Y"><spring:message code="Cache.lbl_Use" /></option>'; // 사용
				popupHtml += '		</select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';				
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_workChargePerson"/></th>'; // 업무담당자
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" id="workCharger" style="width: 150px; margin-left: 5px;" readonly>';
				popupHtml += '		<button class="btnTblSearch" onclick="orgChartPopup(\'B1\', \'recordAddOrgPopup_User_CallBack\');" style="display: inline-block;"><spring:message code='Cache.lbl_DeptOrgMap'/></button>'; // 조직도
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr style="display: none;">';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_modifyReason"/></th>'; // 수정사유
				popupHtml += '	<td>';
				popupHtml += '		<textarea id="modifyReason" style="margin: 5px; width: 150px; resize: none;"></textarea>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_fileCount" /></th>'; // 편철량
				popupHtml += '	<td>';
				popupHtml += '		<input type="text" value="000001" id="recordFileCount" type="text" maxlength="6" onKeyup="this.value=this.value.replace(/[^-0-9]/g,\'\');" style="width: 150px; margin-left: 5px;" disabled>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font><spring:message code="Cache.lbl_provideEndDate" /></th>'; // 비치종결일자
				popupHtml += '	<td>';
				popupHtml += '		<div class="selectCalView"><div class="dateSel type02"><input class="adDate" id="provideEndDate" kind="date" type="text" data-axbind="date" style="width: 150px; margin-left: 5px;"/></div></div>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				break;
			case "R": // 조회
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_recordFileTitle"/></th>'; // 기록물철 제목
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_recordState"/></th>'; // 기록물철 상태
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_recordNumber"/></th>'; // 기록물 건수
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_oldRecordProductName"/></th>'; // 기록물생산기관명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskName"/></th>'; // 단위업무명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_recordForm"/></th>'; // 기록물형태
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_productYear" /></th>'; // 생산년도
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_endYear"/></th>'; // 종료년도
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriod"/></th>'; // 보존기간
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_handoverClass"/></th>'; // 인수인계 구분
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_apv_SerialNo"/></th>'; // 일련번호
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
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_autoyearmake"/></th>'; // 년단위 자동생성
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_workChargePerson"/></th>'; // 업무담당자
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				break;
		}
		
		$(".middle table tbody").html(popupHtml);
		setCombo();
		
		$("#btnSave").off("click").on("click", function(){
			checkValidation();
		});
		
		coviInput.setDate();
		
		if(mode != "I"){
			setData();
		}else{
			$("#btnSave").show();
			$("#btnCancel").show();
		}
	}
	
	function setCombo(){
		var lang = Common.getSession("lang");
		
		var initInfos = [
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
			},
			{
				target: "selRecordType",
				codeGroup: "RecordType",
				defaultVal: "RecordType"
			}
		];
		
		coviCtrl.renderAjaxSelect(initInfos, '', lang);
	}
	
	function setData(){
		$.ajax({
			url: "/approval/user/getRecordGFileListData.do",
			type: "POST",
			data: {
				"recordClassNum": recordClassNum
			},
			success: function(data){
				var recordData = data.list[0];
				
				if(mode == "M"){
					$("#recordSubject").val(recordData.RecordSubject);
					$("#deptName").attr("deptcode", recordData.RecordDeptCode);
					$("#deptName").val(recordData.RecordProductName);
					$("#seriesName").attr("seriescode", recordData.SeriesCode);
					$("#seriesName").val(recordData.SeriesName);
					$("#selRecordType").val(recordData.RecordType == "" ? "RecordType" : recordData.RecordType);
					$("#endYear").val(recordData.EndYear);
					$("#selKeepPeriod").val(recordData.KeepPeriod == "" ? "KeepPeriod" : recordData.KeepPeriod);
					$("#selKeepMethod").val(recordData.KeepMethod == "" ? "KeepMethod" : recordData.KeepMethod);
					$("#selKeepPlace").val(recordData.KeepPlace == "" ? "KeepPlace" : recordData.KeepPlace);
					$("#workCharger").val(recordData.WorkCharger);
					$("#productYear").val(recordData.ProductYear);
					$("#selproductYear").val(recordData.ProductYear);	
					$("#recordFileCount").val(recordData.RecordFileCount);
					$("#provideEndDate").val(recordData.ProvideEndDate);
					$("#selAutoYear").val(recordData.AutoYearYN == "" ? "N" : recordData.AutoYearYN);
					
					$("#modifyReason").closest("tr").show();
					$("#btnSave").show();
					$("#btnCancel").show();
				}else{
					var trObj = $(".middle table tbody tr");
					
					trObj.eq(0).find("td").text(recordData.RecordSubject);
					trObj.eq(1).find("td").text(recordData.RecordStatusTxt);
					trObj.eq(2).find("td").text(recordData.RCnt);
					trObj.eq(3).find("td").text(recordData.RecordProductName);
					trObj.eq(4).find("td").text(recordData.SeriesName);
					trObj.eq(5).find("td").text(recordData.RecordTypeTxt);
					trObj.eq(6).find("td").text(recordData.ProductYear);
					trObj.eq(7).find("td").text(recordData.EndYear);
					trObj.eq(8).find("td").text(recordData.KeepPeriodTxt);
					trObj.eq(9).find("td").text(recordData.TakeoverCheckTxt);
					trObj.eq(10).find("td").text(recordData.RecordSeq);
					trObj.eq(11).find("td").text(recordData.KeepMethodTxt);
					trObj.eq(12).find("td").text(recordData.KeepPlaceTxt);
					trObj.eq(13).find("td").text(recordData.AutoYearYN);
					trObj.eq(14).find("td").text(recordData.WorkCharger);
					
					$("#btnClose").show();
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
	
	// 조직도 팝업 호출
	function orgChartPopup(type, callBack){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type="+type+"&callBackFunc="+callBack,"1000px","580px","iframe",true,null,null,true);
	}
	
	// 단위업무 팝업 호출
	function seriesSearchPopup(){
		parent.Common.open("","seriesSearch_pop","<spring:message code='Cache.lbl_unitTask'/>","/approval/user/getSeriesSearchPopup.do?limitCnt=1&callBackFunc=recordAddOrgPopup_seriesCallBack","800px","500px","iframe",true,null,null,true);
	}
	
	function checkValidation(){
		var RecordSubject = $("#recordSubject").val();
		var RecordDeptCode = $("#deptName").attr("deptcode");
		var RecordDeptName = $("#deptName").val();
		var SeriesCode = $("#seriesName").attr("seriescode");
		var SeriesName = $("#seriesName").val();
		var RecordType = $("#selRecordType").val() == "RecordType" ? "" : $("#selRecordType").val();
		var EndYear = $("#endYear").val();
		var KeepPeriod = $("#selKeepPeriod").val() == "KeepPeriod" ? "" : $("#selKeepPeriod").val();
		var KeepMethod = $("#selKeepMethod").val() == "KeepMethod" ? "" : $("#selKeepMethod").val();
		var KeepPlace = $("#selKeepPlace").val() == "KeepPlace" ? "" : $("#selKeepPlace").val();
		var WorkCharger = $("#workCharger").val();
		var BaseYear = $("#selproductYear").val() == "" || $("#selproductYear").val().length!="4" ? "" : $("#selproductYear").val();
		var RecordFileCount = $("#recordFileCount").val();
		var ProvideEndDate = $("#provideEndDate").val().replace(/-/gi, "");
		var AutoYearYN = $("#selAutoYear").val();
		
		if(RecordSubject == ""){
			Common.Warning("<spring:message code='Cache.msg_enterRecordFileTitle'/>"); // 기록물철 제목을 입력해주세요.
			return false;
		}else if(RecordDeptName == "" || RecordDeptCode == ""){
			Common.Warning("<spring:message code='Cache.msg_selectProcessionDept' />"); // 처리과를 선택해주세요.
			return false;
		}else if(SeriesName == "" || SeriesCode == ""){
			Common.Warning("<spring:message code='Cache.msg_selectUnitTask'/>"); // 단위업무를 선택해주세요.
			return false;
		}else if(RecordType == ""){
			Common.Warning("<spring:message code='Cache.msg_selectRecordFileType'/>"); // 기록물철 형태를 선택해주세요.
			return false;
		}else if(BaseYear == ""){
			Common.Warning("<spring:message code='Cache.msg_selectBaseYear'/>"); // 생산년도를 입력해주세요. 
			return false;
		}else if(EndYear == ""){
			Common.Warning("<spring:message code='Cache.msg_enterEndYear'/>"); // 종료년도를 입력해주세요.
			return false;
		}else if(KeepPeriod == ""){
			Common.Warning("<spring:message code='Cache.msg_selectKeepPeriod'/>"); // 보존기간을 선택해주세요.
			return false;
		}else if(KeepMethod == ""){
			Common.Warning("<spring:message code='Cache.msg_selectKeepMethod'/>"); // 보존방법을 선택해주세요.
			return false;
		}else if(KeepPlace == ""){
			Common.Warning("<spring:message code='Cache.msg_selectKeepPlace'/>"); // 보존장소를 선택해주세요.
			return false;
		}else if(RecordFileCount == ""){
			Common.Warning("<spring:message code='Cache.msg_recordFileCount'/>"); // 편철량을 입력해주세요.
			return false;
		}else if(ProvideEndDate == ""){
			Common.Warning("<spring:message code='Cache.msg_provideEndDate'/>"); // 비치종결일자를 입력해주세요.
			return false;
		}
		
		var params = {
			"RecordSubject": RecordSubject,
			"RecordDeptCode": RecordDeptCode,
			"RecordDeptName": RecordDeptName,
			"SeriesCode": SeriesCode,
			"SeriesName": SeriesName,
			"RecordType": RecordType,
			"EndYear": EndYear,
			"KeepPeriod": KeepPeriod,
			"KeepMethod": KeepMethod,
			"KeepPlace": KeepPlace,
			"AutoYearYN": AutoYearYN,
			"WorkCharger": WorkCharger,
			"BaseYear": BaseYear,
			"RecordFileCount": RecordFileCount,
			"ProvideEndDate": ProvideEndDate
		}
		
		if(mode == "M"){
			var ModifyReason = $("#modifyReason").val() == undefined ? "" : $("#modifyReason").val();
			
			if(ModifyReason == ""){
				Common.Warning("<spring:message code='Cache.msg_enterModifyReason'/>"); // 수정사유를 입력해주세요.
				return false;
			}
			
			params.ModifyReason = ModifyReason;
		}
		
		saveSeries(params);
	}
	
	function saveSeries(params){
		var url = "";
		
		if(mode == "I"){
			url = "/approval/user/insertRecordGFileData.do";
		}else{
			url = "/approval/user/modifyRecordGFileData.do";
			params.RecordClassNum = recordClassNum;
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