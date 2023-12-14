<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle"></div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk" style="display: none"></a>
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var mode = CFN_GetQueryString("mode") == "undefined" ? "" : CFN_GetQueryString("mode");
	var recordClassNum = CFN_GetQueryString("recordClassNum") == "undefined" ? "" : CFN_GetQueryString("recordClassNum");
	var deptName = CFN_GetQueryString("deptName") == "undefined" ? "" : decodeURIComponent(CFN_GetQueryString("deptName"));
	var deptCode = CFN_GetQueryString("deptCode") == "undefined" ? "" : CFN_GetQueryString("deptCode");
	
	var ListGrid = new coviGrid();
	
	setPopup();
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		switch(mode){
			case "Excel":
				btnTxt = '<spring:message code="Cache.btn_Upload" />'; // 업로드
				popupHtml += '<table class="tableTypeRow">';
				popupHtml += '	<colgroup>';
				popupHtml += '		<col style="width: 30%;">';
				popupHtml += '		<col style="width: 70%;">';
				popupHtml += '	</colgroup>';
				popupHtml += '	<tbody>';
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<spring:message code="Cache.btn_addfile" />'; // 파일추가
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<input type="text" id="uploadfileText" placeholder="<spring:message code="Cache.lbl_vacationMsg30" />"><a class="btnTypeDefault" onclick="$(\'#uploadfile\').click();" style="margin-left: 5px;" readonly><spring:message code="Cache.lbl_FileUpload" /></a>';
				popupHtml += '				<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>';
				popupHtml += '			</td>';
				popupHtml += '		</tr>';
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<spring:message code="Cache.lbl_apv_filelist" />'; // 첨부파일
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<a class="btnTypeDefault" onclick="sampleFileDownload();"><spring:message code="Cache.lbl_templatedownload" /></a>';
				popupHtml += '			</td>';
				popupHtml += '		</tr>';
				popupHtml += '	</tbody>';
				popupHtml += '</table>';
				
				$("#btnSave").show();
				$("#btnSave").on("click", excelUpload);
				$(".middle").html(popupHtml);
				
				$("#uploadfile").on("change", function(e) {
					var file = $(this)[0].files[0];
					
					if(typeof(file) == "undefined"){
						$("#uploadfileText").val("");
					}else{
						$("#uploadfileText").val(file.name);
					}
				});
				break;
			case "History":
				btnTxt = '<spring:message code="Cache.lbl_apv_Confirm"/>'; // 확인
				popupHtml += '<div id="historyGrid"></div>';
				popupHtml += '<div id="historyArea" style="display: none;">';
				popupHtml += '	<span style="font-weight: bold; font-size: 18px;"><spring:message code="Cache.lbl_changeItem" /></span>'; // 변경 항목
				popupHtml += '	<table class="tableTypeRow" style="margin-top: 10px;">';
				popupHtml += '		<colgroup>';
				popupHtml += '			<col style="width: 40%;">';
				popupHtml += '			<col style="width: 60%;">';
				popupHtml += '		</colgroup>';
				popupHtml += '		<tbody>';
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_beforeChangeName"/>'; // 변경전 이름
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>';
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_afterChangeName"/>'; // 변경후 이름
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>'
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_beforeChangeType"/>'; // 변경전 유형
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>';
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_afterChangeType"/>'; // 변경후 유형
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>'
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_beforeChangeKeepPeriod"/>'; // 변경전 보존기간
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>';
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_afterChangeKeepPeriod"/>'; // 변경후 보존기간
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>'
				popupHtml += '			<tr>';
				popupHtml += '				<th>';
				popupHtml += '					<spring:message code="Cache.lbl_modifyReason"/>'; // 수정사유
				popupHtml += '				</th>';
				popupHtml += '				<td style="padding: 5px;"></td>';
				popupHtml += '			</tr>'
				popupHtml += '		</tbody>';
				popupHtml += '	</table>';
				popupHtml += '</div>';
				
				$(".middle").html(popupHtml);
				
				setGrid();
				break;
			case "Takeover":
				btnTxt = '<spring:message code="Cache.lbl_apply" />'; // 적용
				popupHtml += '<table class="tableTypeRow">';
				popupHtml += '	<colgroup>';
				popupHtml += '		<col style="width: 30%;">';
				popupHtml += '		<col style="width: 70%;">';
				popupHtml += '	</colgroup>';
				popupHtml += '	<tbody>';
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<spring:message code="Cache.lbl_handoverProcessDept" />'; // 인계처리과
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<input type="text" id="beforeDeptName" readonly>';
				popupHtml += '			</td>';
				popupHtml += '		</tr>';
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<font color="red">* </font><spring:message code="Cache.lbl_workChargePerson" />'; // 업무 담당자
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<input type="text" id="workCharger" readonly>';
				popupHtml += '				<button class="btnTblSearch" style="background-color: white; display: inline-block;" onclick="orgChartPopup();">업무 담당자</button>';
				popupHtml += '			</td>';
				popupHtml += '		</tr>'
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<spring:message code="Cache.lbl_takeoverProcessDept" />'; // 인수처리과
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<input type="text" id="afterDeptName" readonly>';
				popupHtml += '			</td>';
				popupHtml += '		</tr>';
				popupHtml += '		<tr>';
				popupHtml += '			<th>';
				popupHtml += '				<font color="red">* </font><spring:message code="Cache.lbl_unitTask" />'; // 단위업무
				popupHtml += '			</th>';
				popupHtml += '			<td style="padding: 5px;">';
				popupHtml += '				<input type="text" id="seriesName" readonly>';
				popupHtml += '				<button class="btnTblSearch" style="background-color: white; display: inline-block;" onclick="seriesSearchPopup();"><spring:message code="Cache.lbl_unitTask" /></button>'; // 단위업무
				popupHtml += '			</td>';
				popupHtml += '		</tr>'
				popupHtml += '	</tbody>';
				popupHtml += '</table>';
				
				$("#btnSave").show();
				$("#btnSave").on("click", checkValidation);
				$(".middle").html(popupHtml);
				
				$("#beforeDeptName").val(deptName);
				$("#beforeDeptName").attr("deptcode", deptCode);
				break;
		}
		
		$("#btnSave").text(btnTxt);
	}
	
	function setGrid(){
		setGridConfig();
		setRecordHistoryList();
	}

	function setGridConfig(){
		var headerData = [
							{key:'rowNum', label:'<spring:message code="Cache.lbl_Num"/>', width:'15', align:'center', formatter:function(){ 
								return formatRowNum(this); 
							}, sort:false},
							{key:'ModifyReason', label:'<spring:message code="Cache.lbl_modifyReason"/>', width:'30', align:'center'}, // 수정사유
							{key:'ModifierName', label:'<spring:message code="Cache.lbl_apv_modiuser"/>', width:'20', align:'center'}, // 수정자
							{key:'ModifyDate', label:'<spring:message code="Cache.lbl_apv_moddate"/>', width:'40', align:'center'} // 수정일자
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
	
		var configObj = {
			targetID: "historyGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {
				onclick: function(){
					showHistoryData(this.item);
				}
			},
			page: {
				pageNo: 1,
				pageSize: 10
			},
			paging: true,
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function setRecordHistoryList(){
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getRecordHistoryList.do",
			ajaxPars: {
				"RecordClassNum": recordClassNum
			},
			onLoad: function(){
				$(".gridBodyTable > tbody > tr").css("cursor", "pointer");
				coviInput.init();
			}
		});
	}
	
	function showHistoryData(hisData){
		if($("#historyArea").css("display") == "none" || $("#historyArea").attr("historyid") != hisData.GFileHistoryID){
			$("#historyArea").attr("historyid", hisData.GFileHistoryID);
			
			if(hisData.BeforeSubject != null && hisData.BeforeSubject != ""){
				$("#historyArea tbody tr td").eq(0).text(hisData.BeforeSubject);
				$("#historyArea tbody tr").eq(0).show();
			}else{
				$("#historyArea tbody tr").eq(0).hide();
			}
			
			if(hisData.AfterSubject != null && hisData.AfterSubject != ""){
				$("#historyArea tbody tr td").eq(1).text(hisData.AfterSubject);
				$("#historyArea tbody tr").eq(1).show();
			}else{
				$("#historyArea tbody tr").eq(1).hide();
			}
			
			if(hisData.BeforeTypeTxt != null && hisData.BeforeTypeTxt != ""){
				$("#historyArea tbody tr td").eq(2).text(hisData.BeforeTypeTxt);
				$("#historyArea tbody tr").eq(2).show();
			}else{
				$("#historyArea tbody tr").eq(2).hide();
			}
			
			if(hisData.AfterTypeTxt != null && hisData.AfterTypeTxt != ""){
				$("#historyArea tbody tr td").eq(3).text(hisData.AfterTypeTxt);
				$("#historyArea tbody tr").eq(3).show();
			}else{
				$("#historyArea tbody tr").eq(3).hide();
			}
			
			if(hisData.BeforeKeepPeriodTxt != null && hisData.BeforeKeepPeriodTxt != ""){
				$("#historyArea tbody tr td").eq(4).text(hisData.BeforeKeepPeriodTxt);
				$("#historyArea tbody tr").eq(4).show();
			}else{
				$("#historyArea tbody tr").eq(4).hide();
			}
			
			if(hisData.AfterKeepPeriodTxt != null && hisData.AfterKeepPeriodTxt != ""){
				$("#historyArea tbody tr td").eq(5).text(hisData.AfterKeepPeriodTxt);
				$("#historyArea tbody tr").eq(5).show();
			}else{
				$("#historyArea tbody tr").eq(5).hide();
			}
			
			$("#historyArea tbody tr td").eq(6).text(hisData.ModifyReason);
			
			$("#historyArea").show();
		}else{
			$("#historyArea").hide();
		}
	}
	
	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	function sampleFileDownload(){
		location.href = "/approval/user/downloadRecordFileTemplateFile.do";
	}
	
	function excelUpload(){
		var formData = new FormData();
		formData.append("uploadfile", $("#uploadfile")[0].files[0]);
		if ($("#uploadfileText").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_SelectFile' />");
			return false;
		}
		
		$.ajax({
			url: "/approval/user/recordGFileExcelUpload.do",
			type: "POST",
			processData: false,
			contentType: false,
			data: formData,
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
				Common.Error("<spring:message code='Cache.msg_apv_030' />");   // 오류가 발생했습니다.
			}				
		});
	}
	
	function checkValidation(){
		var beforeDeptCode = $("#beforeDeptName").attr("deptcode") == undefined ? "" : $("#beforeDeptName").attr("deptcode");
		var afterDeptCode = $("#afterDeptName").attr("deptcode") == undefined ? "" : $("#afterDeptName").attr("deptcode");
		var afterDeptName = $("#afterDeptName").val();
		var seriesCode = $("#seriesName").attr("seriescode") == undefined ? "" : $("#seriesName").attr("seriescode");
		var seriesName = $("#seriesName").val();
		var baseYear = $("#seriesName").attr("baseyear") == undefined ? "" : $("#seriesName").attr("baseyear");
		var workCharger = $("#workCharger").val();
		
		if(seriesCode == ""){
			Common.Warning("<spring:message code='Cache.msg_selectUnitTask' />"); // 단위업무를 선택해주세요.
			return false;
		}else if(workCharger == ""){
			Common.Warning("<spring:message code='Cache.msg_selectWorkCharger' />"); // 업무담당자를 선택해주세요.
			return false;
		}else if(beforeDeptCode == afterDeptCode){
			Common.Warning("<spring:message code='Cache.msg_sameHandoverDeptAndTakeoverDept' />"); // 인계처리과와 인수처리과가 같습니다.
			return false;
		}
		
		var selParams = {
			"RecordClassNum": recordClassNum,
			"BeforeDeptCode": beforeDeptCode,
			"AfterDeptCode": afterDeptCode,
			"AfterDeptName": afterDeptName,
			"SeriesCode": seriesCode,
			"SeriesName": seriesName,
			"BaseYear": baseYear,
			"WorkCharger": workCharger,
		};
		
		setTakeover(selParams);
	}
	
	function setTakeover(params){
		$.ajax({
			url: "/approval/user/setRecordTakeover.do",
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
					Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}				
		});
	}
	
	// 단위업무 팝업 호출
	function seriesSearchPopup(){
		parent.Common.open("","seriesSearch_pop","<spring:message code='Cache.lbl_unitTask' />","/approval/user/getSeriesSearchPopup.do?l&callBackFunc=seriesSearchPopup_CallBack","800px","500px","iframe",true,null,null,true);
	}
	
	//조직도 팝업 호출
	function orgChartPopup(){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type=B1&callBackFunc=recordInfoOrgPopup_user_CallBack","1000px","580px","iframe",true,null,null,true);
	}
</script>