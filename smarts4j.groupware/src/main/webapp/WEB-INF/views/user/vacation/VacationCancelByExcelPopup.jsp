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
						<div><strong><spring:message code="Cache.lbl_Period" /></strong></div>
						<div>
							<div class="dateSel type02" style="display:inline-block;">				
								<input class="adDate" id="sDate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="eDate">
								~
								<input class="adDate" id="eDate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="sDate">
							</div>
							<span id="hSpan" style="display:none;"><input type="checkbox" id="isHalf"><spring:message code="Cache.lbl_apv_halfvac" /></span><!-- 반차 -->
						</div>
					</li>		
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Reason" /></strong></div>
						<div>
							<input type="text" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" id="reason">
						</div>
					</li>								
				</ul>							
			</div>
			<div class="ulList type02">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_File" /></strong></div>
						<div>
							<input type="text" id="uploadfileText" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_vacationMsg30' />"><a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
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

	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
		
		$('#sDate, #eDate').on('change', function(e) {
			if($('#sDate').val() == $('#eDate').val()) {
				$('#hSpan').show();
			} else {
				$('#isHalf').attr("checked", false);
				$('#hSpan').hide();
			}
		});
	}
	
	// 엑셀 업로드
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		var sDate = $("#sDate").val();
		var eDate = $("#eDate").val();
        if (sDate != "" && eDate != "") {
        	if ($("#isHalf").is(":checked")) {
        		tmpday = 0.5;
        	} else {
	            var start_day = sDate.split('-');
	            var finish_day = eDate.split('-');
	
	            var SOBJDATE = new Date(parseInt(start_day[0], 10), parseInt(start_day[1], 10) - 1, parseInt(start_day[2], 10));
	            var EOBJDATE = new Date(parseInt(finish_day[0], 10), parseInt(finish_day[1], 10) - 1, parseInt(finish_day[2], 10));
	            var tmpday = EOBJDATE - SOBJDATE;
	            tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24) + 1;
        	}
        	
            $("#vacDayTxt").html("(" + tmpday + "<spring:message code='Cache.lbl_day'/>" + ")");
        }
		
		formData.append("sDate",sDate);
		formData.append("eDate",eDate);
		formData.append("vacDay",tmpday);
		formData.append("reason",$("#reason").val());
		
		$.ajax({
			url: '/groupware/vacation/excelUploadForCancel.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				var totalCount = result.data.totalCount;
				var notInsertCount = result.data.notInsertCount;
				if(notInsertCount <= 0) {
					Common.Inform("<spring:message code='Cache.lbl_vacationMsg31' />", "Inform", function() { // 업로드 성공하였습니다
						parent.Common.Close("target_pop");
						parent.search();
					});
				} else {
					if(totalCount == notInsertCount) {
						Common.Warning("<spring:message code='Cache.msg_noCancelData'/>");  // 취소할 데이터가 없습니다.
					} else if(totalCount > notInsertCount) {
						Common.Inform(String.format("<spring:message code='Cache.msg_severalUpload'/>", totalCount, notInsertCount), "Inform", function() { 	// {0}개 중 {1}개를 제외하고 업로드 성공하였습니다.
							parent.Common.Close("target_pop");
							parent.search();
						});
					}
				}
			}
		});
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
