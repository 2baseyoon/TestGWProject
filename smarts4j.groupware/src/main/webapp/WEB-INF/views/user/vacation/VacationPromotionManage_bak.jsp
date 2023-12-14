<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	 .gridBodyTr {
     	cursor: pointer;
     }
</style>

<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_697' /></h2>
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width:540px;">
			<div class="selectCalView">
				<select class="selectType02" id="schReadTypeSel">
					<option value="" selected><spring:message code='Cache.btn_All' /></option>
					<option value="read" ><spring:message code='Cache.lbl_Searcher' /></option>
					<option value="notRead"><spring:message code='Cache.lbl_unquestionedPerson' /></option>
				</select>	
				<select class="selectType02" id="schYearSel">
				</select>			
				<select class="selectType02" id="schTypeSel">
					<%-- <option value=""><spring:message code='Cache.lbl_apv_searchcomment' /></option> --%>
				    <option value="deptName"><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>											
			</div>
			<div>
				<a href="javascript:void(0)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="javscript:void(0); return false;" class="btnTypeDefault btnExcel" id="excelDownBtn" onclick="excelDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a>			
				<a href="javscript:void(0); return false;" class="btnTypeDefault" id="openAllBtn" onclick="openAll(); return false;"><spring:message code='Cache.btn_CheckAll' /></a>			
			</div>
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCntSel">
					<option>10</option>
					<option>15</option>
					<option>20</option>
					<option>30</option>
					<option>50</option>
				</select>
				<button href="#" class="btnRefresh" type="button" onclick="search()"></button>							
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
			</div>
		</div>
	</div>
</div>

<script>
	var reqType = CFN_GetQueryString("reqType");	// reqType : 1(연차촉진제 1차 조회내역), 2(사용시기 지정통보 조회내역), 3(연차촉진제 2차 조회내역)
	var grid = new coviGrid();
	
	initContent();

	// 연차촉진제 1차 조회내역, 연차촉진제 2차 조회내역, 사용시기 지정통보 조회내역
	function initContent() {
		init();	// 초기화
		
		setGrid();	// 그리드 세팅
		
		search();	// 검색
	}
	
	// 초기화
	function init() {
		// 화면 처리
		if (reqType == 1) {
			$("#reqTypeTxt").html("<spring:message code='Cache.MN_697' />"); /* 연차촉진제 1차 조회내역  */
		} else if (reqType == 2) {
			$("#reqTypeTxt").html("<spring:message code='Cache.lbl_vacation_period_read_first' />"); /* 사용시기 지정통보 1차 조회내역  */
		} else if (reqType == 3) {
			$("#reqTypeTxt").html("<spring:message code='Cache.MN_698' />"); /* 연차촉진제 2차 조회내역  */
		} else if (reqType == 4){
			$("#reqTypeTxt").html("<spring:message code='Cache.lbl_vacation_period_read_second' />"); /* 사용시기 지정통보 2차 조회내역  */
		} else if (reqType == 5) {
			$("#reqTypeTxt").html("<spring:message code='Cache.lbl_vacation_promotion_third' />"); /* 연차촉진제 3차 조회내역  */
		}
		
		//var nowYear = new Date().getFullYear();
		var nowYear = 2020;
		
		// 년도 option 생성
		for (var i=0; i>-4;i--) {
			var temp = nowYear + i;
			if (temp == nowYear) {
			    $('#schYearSel').append($('<option>', {
			        value: temp,
			        text : temp,
			        selected : 'selected'
			    }));				
			} else {
			    $('#schYearSel').append($('<option>', {
			        value: temp,
			        text : temp
			    }));
			}
		}
		
		$('#schUrName').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
		        
		        var schName = $('#schUrName').val();
		        
		        $('#schTypeSel').val('displayName');
		        $('#schTxt').val(schName);
			
		        search();
		    }
		});
		
		$('#schTxt').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
			
		        search();
		    }
		});
		
		// 검색 버튼
		$('.btnSearchBlue').on('click', function(e) {
			search();
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
		
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			grid.reloadList();
		});
		
 		$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		});		
	}
	
	// 그리드 세팅
	function setGrid() {
		// header
		var	headerData = [
				{key:'chk', label:'chk', formatter: 'checkbox',  width:'30', align:'center'},
				{key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'100', align:'center'},
		        {key:'JobPositionName',  label:'<spring:message code="Cache.lbl_apv_jobposition" />', width:'100', align:'center',sort:false},	              
				{key:'DisplayName', label:'<spring:message code="Cache.lbl_username" />', width:'100', align:'center'	,sort:false},
		        {key:'ReadDate', label:'<spring:message code="Cache.lbl_ViewDate" />'  + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.ReadDate);
				}}
		];
		
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
		  	body: {
                 onclick: function () {
                	 openPrintPopup(this.item, false);
                 }
		  	}
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function search() {
		var params = {messageId : reqType,
					  year : $('#schYearSel').val(),
					  schTypeSel : $('#schTypeSel').val(),
					  schTxt : $('#schTxt').val(),
					  schReadTypeSel : $('#schReadTypeSel').val(),
					  sortBy : "DeptName ASC"};
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationMessageReadList.do",
			ajaxPars : params,
		});
	}
	
	// 엑셀 저장
	function excelDownload() {
		var params = {messageId : reqType,
				  	  year : $('#schYearSel').val(),
				  	  schTypeSel : $('#schTypeSel').val(),
				  	  schTxt : $('#schTxt').val(),
				  	  schReadTypeSel : $('#schReadTypeSel').val(),
				 	  sortBy : "DeptName ASC"};
		
		ajax_download('/groupware/vacation/excelDownloadForVacationMessageReadList.do', params);	// 엑셀 다운로드 post 요청
	}
	
	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
	    var $iframe, iframe_doc, iframe_html;

	    if (($iframe = $('#download_iframe')).length === 0) {
	        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
	    }else{
	    	$iframe.remove();
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
	
	
	
	function openPrintPopup(obj, isAll){
		var year = $('#schYearSel').val();
		
		switch(reqType){
		case "1": // 연차촉진제 1차 서식출력
			url = "/groupware/vacation/goVacationPromotion1Popup.do"
					+ "?year=" + year + "&urCode=" + obj.UserCode + "&viewType=admin&time=1";
			break;
		case "2": // 사용시기 지정통보서 1차
			url = "/groupware/vacation/goVacationUsePlanPopup.do"
					+ "?year="+year + "&urCode=" + obj.UserCode + "&viewType=admin&time=1";
			break;
		case "3": // 연차촉진제 2차 서식출력
			url = "/groupware/vacation/goVacationPromotion1Popup.do"
				+ "?year="+year + "&urCode=" + obj.UserCode + "&viewType=admin&time=2";
			break;
		case "4": // 사용시기 지정통보서 2차
			url = "/groupware/vacation/goVacationUsePlanPopup.do"
				+ "?year="+year + "&urCode=" + obj.UserCode  + "&viewType=admin&time=2";
			break;
		case "5": // 연차촉진제 3차 서식출력
			url = "/groupware/vacation/goVacationPromotion3Popup.do"
				+ "?year="+year + "&urCode=" + obj.UserCode  + "&viewType=admin&time=3";
			break;
		}
		
		/* if(isAll){
			url += "&isAll=Y";
		}
		 */
		
		window.open(url, "printWindow_"+obj.UserCode, 'width=960, height=' + (window.screen.height - 100) + ', resizable=yes,scrollbars=yes');
		//CFN_OpenWindow(url, "printWindow"+number, 960, (window.screen.height - 100), "resize");
	}
	
	function openAll(){
		$(grid.getCheckedList(0)).each(function(idx, obj){
			openPrintPopup(obj, true);
		});
		
	}
	
</script>			