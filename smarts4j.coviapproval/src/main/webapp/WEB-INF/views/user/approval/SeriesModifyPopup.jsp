<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<style>
	textarea{
		resize: none;
	}
</style>

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width: 100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow"></table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk"></a>
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var mode = CFN_GetQueryString("mode") == "undefined" ? "" : CFN_GetQueryString("mode");
	var seriesCode = CFN_GetQueryString("seriesCode") == "undefined" ? "" : CFN_GetQueryString("seriesCode");
	var deptCode = CFN_GetQueryString("deptCode") == "undefined" ? "" : CFN_GetQueryString("deptCode");
	var baseYear = CFN_GetQueryString("baseYear") == "undefined" ? "" : CFN_GetQueryString("baseYear");
	
	setPopup();
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		switch(mode){
			case "Excel":
				btnTxt = '<spring:message code="Cache.btn_Upload" />'; // 업로드
				popupHtml += '<colgroup>';
				popupHtml += '	<col style="width: 30%;">';
				popupHtml += '	<col style="width: 70%;">';
				popupHtml += '</colgroup>';
				popupHtml += '<tbody>';
				popupHtml += '	<tr>';
				popupHtml += '		<th>';
				popupHtml += '			<spring:message code="Cache.btn_addfile" />'; // 파일추가
				popupHtml += '		</th>';
				popupHtml += '		<td style="padding: 5px;">';
				popupHtml += '			<input type="text" id="uploadfileText" placeholder="<spring:message code="Cache.lbl_vacationMsg30" />"><a class="btnTypeDefault" onclick="$(\'#uploadfile\').click();" style="margin-left: 5px;" readonly><spring:message code="Cache.lbl_FileUpload" /></a>';
				popupHtml += '			<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>';
				popupHtml += '		</td>';
				popupHtml += '	</tr>';
				popupHtml += '	<tr>';
				popupHtml += '		<th>';
				popupHtml += '			<spring:message code="Cache.lbl_apv_filelist" />'; // 첨부파일
				popupHtml += '		</th>';
				popupHtml += '		<td style="padding: 5px;">';
				popupHtml += '			<a class="btnTypeDefault" onclick="sampleFileDownload();"><spring:message code="Cache.lbl_templatedownload" /></a>';
				popupHtml += '		</td>';
				popupHtml += '	</tr>';
				popupHtml += '</tbody>';
				
				$("#btnSave").on("click", excelUpload);
				break;
			case "Revoke":
				btnTxt = '<spring:message code="Cache.lbl_abolition" />'; // 폐지
				popupHtml += '<colgroup>';
				popupHtml += '	<col style="width: 30%;">';
				popupHtml += '	<col style="width: 70%;">';
				popupHtml += '</colgroup>';
				popupHtml += '<tbody>';
				popupHtml += '	<tr style="height: 150px;">';
				popupHtml += '		<th>';
				popupHtml += '			<spring:message code="Cache.lbl_abolitionReason" />'; // 폐지사유
				popupHtml += '		</th>';
				popupHtml += '		<td style="padding: 5px;">';
				popupHtml += '			<textarea id="abolitionReason" style="height: 140px;"></textarea>';
				popupHtml += '		</td>';
				popupHtml += '	</tr>';
				popupHtml += '</tbody>';
				
				$("#btnSave").on("click", setRevokeSeries);
				break;
		}
		
		$(".middle .tableTypeRow").html(popupHtml);
		$("#btnSave").text(btnTxt);
		
		if(mode == "Excel"){
			$("#uploadfile").on("change", function(e) {
				var file = $(this)[0].files[0];
				
				if(typeof(file) == "undefined"){
					$("#uploadfileText").val("");
				}else{
					$("#uploadfileText").val(file.name);
				}
			});
		}
	}
	
	function sampleFileDownload(){
		location.href = "/approval/user/downloadSeriesTemplateFile.do";
	}
	
	function excelUpload(){
		var formData = new FormData();
		formData.append("uploadfile", $("#uploadfile")[0].files[0]);
		if ($("#uploadfileText").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_SelectFile' />");
			return false;
		}
		
		$.ajax({
			url: "/approval/user/seriesExcelUpload.do",
			type: "POST",
			processData: false,
			contentType: false,
			data: formData,
			success: function(data){
				if(data.status == "SUCCESS"){
					if(data.err == 'nullErr') {
						Common.Inform("<spring:message code='Cache.ACC_msg_excelNoData' />"); // 데이터 오류.(공백)
					} else {
						Common.Inform(data.message, "Information", function(result){
							if(result){
								Common.Close();
								parent.Refresh();
							}
						});
					}
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");   // 오류가 발생했습니다.
			}				
		});
	}
	
	function setRevokeSeries(){
		var abolitionReason = $("#abolitionReason").val();
		
		if(abolitionReason == ""){
			Common.Warning("<spring:message code='Cache.msg_enterAbolitionReason' />"); // 폐지사유를 입력해주세요.
			return false;
		}
		
		$.ajax({
			url: "/approval/user/setRevokeSeries.do",
			type: "POST",
			data: {
				"SeriesCode": seriesCode,
				"DeptCode": deptCode,
				"AbolitionReason": abolitionReason,
				"BaseYear": baseYear
			},
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
	
	// 단위업무 팝업 호출
	function seriesSearchPopup(){
		parent.Common.open("","seriesSearch_pop","<spring:message code='Cache.lbl_unitTask' />","/approval/user/getSeriesSearchPopup.do?l&callBackFunc=seriesModifyPopup_CallBack","800px","500px","iframe",true,null,null,true);
	}
	
	//조직도 팝업 호출
	function orgChartPopup(mode){
		var callBackFunc = "";
		
		if(mode == "before"){
			callBackFunc = "seriesModifyOrgPopup_before_CallBack";
		}else if(mode == "after"){
			callBackFunc = "seriesModifyOrgPopup_after_CallBack";
		}else{
			callBackFunc = "seriesModifyOrgPopup_CallBack";
		}
		
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type=C1&callBackFunc="+callBackFunc,"1000px","580px","iframe",true,null,null,true);
	}
</script>