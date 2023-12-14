<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.cRConTop , .cRContEnd {display:none;}
.cRContBottom {top:13px;bottom:20px;}

.fileSize {
    width: auto;
    max-width: 80px;
    margin-left: 4px;
    margin-top: 1px;
}

.woRd {
   height: 18px !important;
}

.word {
    padding-left: 26px;
    line-height: 17px;
    color: #000;
    background: url('/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_word.png') no-repeat 0 center;
    text-indent: 0 !important;    
}
</style>
<div id="tarDiv" style="display:none;height:590px;">
</div>						

<script>
	var eventID = CFN_GetQueryString("eventID");
	var dateID = (CFN_GetQueryString("dateID") == 'undefined') ? '' : CFN_GetQueryString("dateID");
	var isRepeat = (CFN_GetQueryString("isRepeat") == 'undefined') ? '' : CFN_GetQueryString("isRepeat");
	var isRepeatAll = (CFN_GetQueryString("isRepeatAll") == 'undefined') ? '' : CFN_GetQueryString("isRepeatAll");
	var folderID = CFN_GetQueryString("folderID");
	var isAttendee = (CFN_GetQueryString("isAttendee") == 'undefined') ? '' : CFN_GetQueryString("isAttendee");
	//var isPopup = (CFN_GetQueryString("isPopup") == 'undefined') ? '' : CFN_GetQueryString("isPopup");
    
	initContent();

	// 승인 및 검토 요청 팝업
	function initContent(){
		var url = '/groupware/schedule/detailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule';
		url += '&eventID=' + eventID;
		url += '&dateID=' + dateID;
		url += '&folderID=' + folderID;
		url += '&isRepeat=' + isRepeat;
		url += '&isRepeatAll=' + isRepeatAll;
		url += '&isAttendee=' + isAttendee;
		$('#tarDiv').load(url, function() {
			setTimeout(function() {$('#tarDiv').css('display','');}, 500);
	    });
	}
</script>