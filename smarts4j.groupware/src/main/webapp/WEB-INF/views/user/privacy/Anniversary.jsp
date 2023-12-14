<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.lbl_AnniversaryManagement"/></h2> <!-- 기념일 관리 -->
	<div class="searchBox02">
		<span style="visibility: hidden;"><input type="text"><button type="button" class="btnSearchType01" onclick="search()"><spring:message code="Cache.btn_search"/></button></span> <!-- 검색 -->
		<a href="#" class="btnDetails"><spring:message code="Cache.lbl_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<select class="selectType02" id="schTypeSel">
				    <option value="subject"><spring:message code="Cache.lbl_AnniversaryName"/></option> <!-- 기념일명 -->
				    <option value="description"><spring:message code="Cache.lbl_Contents"/></option> <!-- 내용 -->
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt" onkeypress="if (event.keyCode==13){ searchData(); return false; }">
				</div>			
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchData()"><spring:message code="Cache.btn_search"/></a> <!-- 검색 -->
			</div>
		</div>
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="#" class="btnTypeDefault btnTypeChk" onclick="openAnniversaryPopup('C')"><spring:message code="Cache.btn_AnniversaryAdd"/></a> <!-- 기념일 추가 -->
				<a href="#" class="btnTypeDefault" onclick="excelUpload();"><spring:message code="Cache.btn_AnniversaryImport"/></a> <!-- 기념일 가져오기 -->
				<a href="#" class="btnTypeDefault" onclick="deleteAnniversary();"><spring:message code="Cache.btn_delete"/></a> <!-- 삭제 -->
				<a href="#" class="btnTypeDefault btnExcel" onclick="excelDownload();"><spring:message code="Cache.btn_SaveToExcel"/></a> <!-- 엑셀저장 -->
				<!-- <a href="#" class="btnTypeDefault btnExcel" onclick="csvDownload();">csv파일저장</a> -->
			</div>
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCntSel">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button href="#" class="btnRefresh" type="button" onclick="searchData()"></button>							
			</div>				
		</div>
	<div class="tblList tblCont">
		<div id="gridDiv">
		</div>
		<!-- <div class="goPage">
			<input type="text"> <span> / 총 </span><span>1</span><span>페이지</span><a href="#" class="btnGo">go</a>
		</div>		 -->
	</div>
	</div>
</div>

<script type="text/javascript">
	var grid = new coviGrid();

	initContent();
	
	// 개인환경설정 > 기념일 관리
	function initContent() {
		init();	// 초기화

		setGrid();	// 그리드 세팅
		
		searchData();	// 검색
	}
	
	// 초기화
	function init() {
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			grid.reloadList();
		});
		
		// 상세 보기
 		$('.btnDetails').on('click', function(){
			var mParent = $('.inPerView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});
	}
	
	// 그리드 세팅
	function setGrid() {
		var headerData = [
			{key:'MessageID', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false},		                  
			{key:'AnniDate', label:"<spring:message code='Cache.lbl_AnniversaryDate'/>", width:'60', align:'center', //기념일자
				formatter:function () {
					var html = "<div style='cursor: pointer;' onclick='openAnniversaryPopup(\"U\", \"" + this.item.MessageID + "\"); return false;'>";
					html += this.item.AnniDate;
					html += "</div>";						
					return html;
				}
			},
			{key:'AnniDateTypeText', label:"<spring:message code='Cache.lbl_SolarLunar2'/>", width:'40', align:'center', //기념일자
				formatter:function () {
					var html = Common.getBaseCodeDic('Lunar', ((this.item.AnniDateType == 'S') ? 'N' : 'Y'));
					if (this.item.AnniDateType == 'L' && this.item.IsLeapMonth == 'Y') html += '/' + Common.getDic('lbl_lunar_leap_month')
					return html;
				}
			}, //양.음력
			{key:'Subject', label:"<spring:message code='Cache.lbl_AnniversaryName'/>", width:'200', align:'center', //기념일명
				formatter:function () {
					var html = "<div style='cursor: pointer;' onclick='openAnniversaryPopup(\"U\", \"" + this.item.MessageID + "\"); return false;'>";					
					html += this.item.Subject;					
					html += "</div>";						
					return html;
				}
			},
			{key:'dDay', label:'D-Day', width:'40', align:'center', sort:false},
			{key:'PriorityText', label:"<spring:message code='Cache.lbl_importance'/>", width:'40', align:'center'}, //중요도
			{key:'alarmDay', label:"<spring:message code='Cache.TodoMsgType_PreNotify'/>", width:'40', align:'center'} //미리알림
		];
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			paging : true,
			page : {
				pageNo:1,
				pageSize:10
			},
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function searchData() {
		var params = {schTypeSel : $('#schTypeSel').val(),
					  schTxt : $('#schTxt').val(),
					  sortBy : "AnniDate DESC"};
	
		grid.bindGrid({
			ajaxUrl : "/groupware/privacy/getAnniversaryList.do",
			ajaxPars : params
		});
	}
	
 	// 추가, 수정 팝업
	function openAnniversaryPopup(reqType, messageId) {
 		if (reqType == 'C') {
 			Common.open("","target_pop","<spring:message code='Cache.lbl_AnniversaryWrite'/>","/groupware/privacy/goAnniversaryPopup.do","500px","377px","iframe",true,null,null,true); //기념일 등록
 		} else {
 			Common.open("","target_pop","<spring:message code='Cache.lbl_AnniversaryModify'/>","/groupware/privacy/goAnniversaryPopup.do?messageId="+messageId,"500px","377px","iframe",true,null,null,true); //기념일 수정
 		}
	}
 	
 	// 기념일 가져오기
	function excelUpload() {
		Common.open("","target_pop","<spring:message code='Cache.btn_AnniversaryImport'/>","/groupware/privacy/goAnniversaryExcelUploadPopup.do","600px","300px","iframe",true,null,null,true); //기념일 가져오기
	}
 	
 	// 삭제
	function deleteAnniversary() {
		var messageIdArr = '';
		$.each(grid.getCheckedList(0), function(i, v) {
			if (i > 0) messageIdArr += ',';
			messageIdArr += v.MessageID;
		});
		
		if (messageIdArr == '') {
			alert("<spring:message code='Cache.lbl_Mail_NoSelectItem'/>"); //선택된 항목이 없습니다.
			return false;
		} else {
	  		$.ajax({
				type : "POST",
				data : {messageIdArr : messageIdArr},
				async: false,
				url : "/groupware/privacy/deleteAnniversary.do",
				success: function (list) {
					Common.Inform("<spring:message code='Cache.msg_50'/>", "Inform", function() { //삭제되었습니다.
						searchData();
					});
				},
				error: function(response, status, error) {
					CFN_ErrorAjax("/groupware/privacy/insertAnniversary.do", response, status, error);
				}
			});
		}
	}
 	
 	// 엑셀저장
	function excelDownload() {
		var params = {
			schTypeSel : $('#schTypeSel').val(),
			schTxt : $('#schTxt').val()
		}
			
		ajax_download('/groupware/privacy/excelDownload.do', params);	// 엑셀 다운로드 post 요청
	}
 	
	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
	    var $iframe, iframe_doc, iframe_html;

	    if (($iframe = $('#download_iframe')).length === 0) {
	        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
	    }

	    iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
	    if (iframe_doc.document) {
	        iframe_doc = iframe_doc.document;
	    }

	    iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'>" 
	    Object.keys(data).forEach(function(key) {
	        iframe_html += "<input type='hidden' name='"+key+"' value='"+data[key]+"'>";
	    });
        iframe_html +="</form></body></html>";

	    iframe_doc.open();
	    iframe_doc.write(iframe_html);
	    $(iframe_doc).find('form').submit();
	}
	
	// 일정등록
	function openCalendarPopup(anni_StartDate, anni_EndDate, subject) {
		subject = Base64.utf8_to_b64(subject);
		Common.open("","calendar_pop","<spring:message code='Cache.lbl_AddScheduleTitle'/>",'/groupware/privacy/goCalendarPopup.do?anni_StartDate='+anni_StartDate+'&anni_EndDate='+anni_EndDate+'&subject='+subject,"740px","325px","iframe",true,null,null,true);	// 일정등록
	}
 	// csv파일저장
/* 	function csvDownload() {
 		
	} */
</script>
