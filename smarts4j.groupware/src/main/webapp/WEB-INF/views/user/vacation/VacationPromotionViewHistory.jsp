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
		<div style="width:750px;">
			<div class="selectCalView">
				<select class="selectType02" id="schYearSel">
				</select>			
				<select class="selectType02" id="schEmploySel">
						<option value=""><spring:message code='Cache.lbl_Whole' /></option>
					    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
					    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
				</select>
				<select class="selectType02" id="schReadTypeSel">
					<option value="" selected="selected"><spring:message code='Cache.btn_All' /></option>
					<option value="read" ><spring:message code='Cache.lbl_Searcher' /></option>
					<option value="notRead"><spring:message code='Cache.lbl_unquestionedPerson' /></option>
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
			<div style="display: inline;">
				<a class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
	</div>
	<div class="docAllCont">
		<ul id="tabList" class="tabType2 clearFloat">
 			<li value="normal" class="active" style="display:none"><a><spring:message code='Cache.lbl_generalStaff' /><!-- 일반직원 --></a></li>
 			<li value="newEmp" style="display:none"><a><spring:message code='Cache.lbl_lessAYear' /><!-- 1년 미만 --></a></li>
 			<li value="newEmpForNine" style="display:none"><a><spring:message code='Cache.lbl_lessAYear' /> (9<spring:message code='Cache.lbl_day' />)<!-- 1년 미만 (9일) --></a></li>
 			<li value="newEmpForTwo" style="display:none"><a><spring:message code='Cache.lbl_lessAYear' /> (2<spring:message code='Cache.lbl_day' />)<!-- 1년 미만 (2일) --></a></li>
		</ul>
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a class="btnTypeDefault btnExcel" id="excelDownBtn" onclick="excelDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a>			
				<a class="btnTypeDefault" id="openAllBtn" onclick="openAll(); return false;"><spring:message code='Cache.btn_CheckAll' /></a>			
			</div>
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCntSel">
					<option>10</option>
					<option>15</option>
					<option>20</option>
					<option>30</option>
					<option>50</option>
				</select>
				<button class="btnRefresh" type="button" onclick="search()"></button>							
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
			</div>
		</div>
	</div>
</div>

<script>
	var formType = CFN_GetQueryString("formType");	// plan/notification1/request/notification2
	var grid = new coviGrid();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
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
		if (formType == "plan") {
			$("#reqTypeTxt").html("<spring:message code='Cache.lbl_annualUsePlanViewHistory' />");  /* 연차사용계획서 조회내역  */
			$("#tabList li[value='normal'],li[value='newEmp']").show();
		} else if (formType == "notification1") {
			$("#reqTypeTxt").html("<spring:message code='Cache.MN_697' />"); /* 연차촉진제 1차 조회내역  */
			$("#tabList li[value='normal'],li[value='newEmpForNine'],li[value='newEmpForTwo']").show();
		} else if (formType == "request") {
			$("#reqTypeTxt").html("<spring:message code='Cache.lbl_annualRequestViewHistory' />"); /* 사용시기 지정요청 1차 조회내역  */
			$("#tabList li[value='normal'],li[value='newEmpForNine'],li[value='newEmpForTwo']").show();
		} else if (formType == "notification2"){
			$("#reqTypeTxt").html("<spring:message code='Cache.MN_698' />"); /* 연차촉진제 2차 조회내역  */
			$("#tabList li[value='normal'],li[value='newEmpForNine'],li[value='newEmpForTwo']").show();
		} 
		
		var nowYear = new Date().getFullYear();
		// 년도 option 생성
		for (var i=2; i>-4;i--) {
			var temp = nowYear + i;
			
			if(temp < 2020){
				continue;
			}
			
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
		
		$("#tabList").on('click', "li", function(event){
			changeTerm(this);
		});
		
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
			CFN_SetCookieDay("VacListCnt", $(this).find("option:selected").val(), 31536000000);
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
		        {key:'JobPositionName',  label:'<spring:message code="Cache.lbl_apv_jobposition" />', width:'100', align:'center'},	              
				{key:'DisplayName', label:'<spring:message code="Cache.lbl_username" />', width:'100', align:'center'},
				{key:'EnterDate', label:'<spring:message code="Cache.lbl_EnterDate" />', width:'100', align:'center'},
				{key:'RetireDate', label:'<spring:message code="Cache.lbl_RetireDate" />', width:'100', align:'center'},
		        {key:'ReadDate', label:'<spring:message code="Cache.lbl_ViewDate" />'  + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.ReadDate);
				}}
		];
		
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
			page : {
				pageNo: (page != undefined && page != '')?page:1,
				pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
			},
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
		var params = {messageId : "0",
					  formType : formType,
					  empType : $("#tabList .active").attr("value"),
					  year : $('#schYearSel').val(),
					  schTypeSel : $('#schTypeSel').val(),
					  schEmploySel : $('#schEmploySel').val(),
					  schTxt : $('#schTxt').val(),
					  schReadTypeSel : $('#schReadTypeSel').val()};
		
		grid.page.pageNo = 1;
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationMessageReadList.do",
			ajaxPars : params,
		});
	}
	
	// 엑셀 저장
	function excelDownload() {
		var sortInfo = grid.getSortParam("one").split("=");
		var	sortBy = sortInfo.length>1? sortInfo[1]:""; 	
		
		var params = {	messageId : "0",
					  	formType : formType,
					  	empType : $("#tabList .active").attr("value"),
				  	  	year : $('#schYearSel').val(),
				  	  	schTypeSel : $('#schTypeSel').val(),
				  	  	schEmploySel : $('#schEmploySel').val(),				  	  
				  	 	schTxt : $('#schTxt').val(),
				  	  	schReadTypeSel : $('#schReadTypeSel').val(), 
				  	  	sortBy: sortBy	};
		
		ajax_download('/groupware/vacation/excelDownloadForVacationMessageReadList.do', params);	// 엑셀 다운로드 post 요청
	}
	
	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
	    var $iframe, iframe_doc, iframe_html;

	    if ($('#download_iframe').length != 0) {
	    	$('#download_iframe').remove();
	    }else{
	    	$iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
	    }
	    
        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("#content");

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
		var empType =  $("#tabList .active").attr("value");
		url = "/groupware/vacation/goVacationPromotionPopup.do"
				+ "?year=" + year + "&urCode=" + obj.UserCode + "&formType="+ formType + "&empType=" + empType + "&viewType=admin";
		
		if(isAll){
			url += "&isAll=Y";
		}
		
		window.open(url, "printWindow_"+obj.UserCode, 'width=960, height=' + (window.screen.height - 100) + ', resizable=yes,scrollbars=yes');
		//CFN_OpenWindow(url, "printWindow"+number, 960, (window.screen.height - 100), "resize");
	}
	
	function openAll(){
		$(grid.getCheckedList(0)).each(function(idx, obj){
			openPrintPopup(obj, true);
		});
		
	}
	
	function changeTerm(obj){
		$(obj).addClass("active")
			  .siblings("li").removeClass("active")
		
		search();
	}
	
	
</script>			