<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 10px 24px 30px;">
	<div class="">
		<div class="top">
			<p class="tr mb10"><a href="#" class="btnTypeDefault btnExcel" id="excelDownBtn" onclick="excelDownload();"><spring:message code='Cache.lbl_templatedownload' /></a></p>
			<ul class="noticeTextGrayBox">
				※<spring:message code="Cache.lbl_vacationMsg32" />
			</ul>
			<div class="ulList type02">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Deduction"/><spring:message code="Cache.lbl_apv_vacation_year"/></strong></div> 	<!-- 차감년도 -->
						<div id="vacYearDiv"></div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Period" /></strong></div>
						<div>
							<div class="dateSel type02" style="display:inline-block;">				
								<input class="adDate" id="sDate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="eDate">
								~
								<input class="adDate" id="eDate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="sDate">
							</div>
						</div>
					</li>		
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Reason" /></strong></div>
						<div>
							<input type="text" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" id="reason">
						</div>
					</li>
					<%-- 21.10.12, 휴가 타입 지정. --%>
					<li class="listCol">
						<div><strong><spring:message code="Cache.VACATION_TYPE_VACATION_TYPE" /></strong></div> 	<!-- 휴가 유형 -->
						<div>
							<select class="selectType02" id="vacTypeSel"></select>
						</div>
					</li>
											
				</ul>							
			</div>
			<div class="ulList type02">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_File" /></strong></div>
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30' />" disabled><a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile"></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>		
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="excelUpload()"><spring:message code="Cache.btn_Upload" /></a>
			<a href="#" class="btnTypeDefault" onclick="parent.Common.Close('target_pop');"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>
	initContent();
	var langCode = Common.getSession("lang");
	
	function initContent() {
		
		// 휴가 코드 조회 및 필터링.
		setVacType();
		
		// 21.10.14. 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
		
		// 휴가유형 변경 이벤트. 반차 이하의 휴가일 경우 종료날짜를 시작날짜로 변경.
		$('#vacTypeSel').on('change', function(e) {
			if ( parseFloat($("#vacTypeSel option:selected").attr("vac_data")) < 1 ) {
                $("#eDate").val( $("#sDate").val() );
          	}
		});
		
		$("#vacYearDiv").html(parent.document.getElementById('schYearSel').outerHTML.replace('schYearSel', 'vacYear'));
	}
	
	// 초기 휴가유형 세팅.
	function setVacType() {
		var strVacType = "" + '${vacType}';
		var jsonVacType = $.parseJSON(strVacType);
		
		if ( (jsonVacType.vacationType != undefined) && (jsonVacType.vacationType.length > 0) ) {
			$.each(jsonVacType.vacationType, function (index, value) {
				$("#vacTypeSel").append('<option value="' + value.CODE + '" vac_data="' + value.Reserved3 + '">' + value.CodeName + '</option>');
			});
		}
	}
	
	// 엑셀 업로드
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		// 검증.
		if ( !validityCheck() ) {
			return;
		}
		
		var sDate = $("#sDate").val();
		var eDate = $("#eDate").val();
		var start_day = sDate.split('-');
        var finish_day = eDate.split('-');
        var tmpday = 0;
        
		var vacTypeDay = parseFloat($("#vacTypeSel option:selected").attr("vac_data"));
		
		if ( vacTypeDay < 1) {
			// 1일 미만의 연차일 경우.
			tmpday = vacTypeDay;
		} else {
			// 1일 이상의 휴가일 경우.
			var SOBJDATE = new Date(parseInt(start_day[0], 10), parseInt(start_day[1], 10) - 1, parseInt(start_day[2], 10));
            var EOBJDATE = new Date(parseInt(finish_day[0], 10), parseInt(finish_day[1], 10) - 1, parseInt(finish_day[2], 10));
            tmpday = EOBJDATE - SOBJDATE;
            tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24) + 1;
		}	

		formData.append("sDate",sDate);
		formData.append("eDate",eDate);
		formData.append("vacDay",tmpday);
		formData.append("vacYear",$("#vacYear").val());
		formData.append("reason",$("#reason").val());
		formData.append("vacFlag", $("#vacTypeSel option:selected").val() );
		
		$.ajax({
			url: '/groupware/vacation/excelUploadForCommon.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				if(result.status == 'SUCCESS'){
					var totalCount = result.data.totalCount;
					var duplicateCount = result.data.duplicateCount;
					
					if(duplicateCount <= 0) {
						Common.Inform("<spring:message code='Cache.lbl_vacationMsg31'/>", "Inform", function() { 	// 업로드 성공하였습니다
							parent.Common.Close("target_pop");
							parent.search();
						});
					} else {
						if(totalCount == duplicateCount) {
							Common.Warning("<spring:message code='Cache.msg_duplicateData'/>"); // 중복된 데이터가 있습니다. 파일을 다시 첨부해주세요.
						} else if(totalCount > duplicateCount) {
							Common.Inform(String.format("<spring:message code='Cache.msg_severalDataUpload'/>", totalCount, duplicateCount), "Inform", function() { 	// {0}개 중 중복된 데이터 {1}개를 제외하고 업로드 성공하였습니다.
								parent.Common.Close("target_pop");
								parent.search();
							});
						}
					}
				} else {
                	Common.Warning(result.message);
				}
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 유효성 검사
	function validityCheck() {
		if ( $("#sDate").val() === undefined || $("#sDate").val() === "" ) {
			Common.Warning("<spring:message code='Cache.msg_EnterStartDate'/>"); 	<!-- 시작일자를 입력하세요 -->
			return false;
		} else if ( $("#eDate").val() === undefined || $("#eDate").val() === "" ) {
			Common.Warning("<spring:message code='Cache.msg_EnterEndDate'/>"); 		<!-- 종료일자를 입력하세요 -->
			return false;
		} else if ( $("#reason").val() === undefined || $("#reason").val() === "" ) {
			Common.Warning("<spring:message code='Cache.msg_apv_chk_reason'/>"); 	<!-- 사유를 입력해주세요. -->
			return false;
		} else if ( ($("#sDate").val() != $("#eDate").val()) && ( 1 > parseFloat($("#vacTypeSel option:selected").attr("vac_data"))) ) {
			// 시작기간과 종료기간이 일치하지 않는 여러 날일 경우, 반차 이하를 선택했다면.
			Common.Warning("<spring:message code='Cache.msg_vacationdate_rangecheck'/>");   <!-- 휴가 사용 기한을 확인 하여 주세요. -->
			return false;
		} else if ( $('#uploadfileText').val() === undefined || $('#uploadfileText').val() === "" ) {
			Common.Warning("<spring:message code='Cache.msg_SelectFile'/>"); 		<!-- 파일을 선택해 주세요. -->
			return false;
		} else {
			return true;	
		}
	}
	
	// 템플릿 파일 다운로드
	function excelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles' />", "Confirm", function(result){
			if(result){
			location.href = "/groupware/vacation/excelDownload.do?reqType=commonInsert";
			}
		});
	}
</script>
