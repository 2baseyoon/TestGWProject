<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_vacationMsg68' /></h2>	<!-- 사용자별 연차촉진기간 -->
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="schUrNameSearch()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width: 550px;">
			<div class="selectCalView">
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
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
		<div style="width: 550px;">
			<div class="selectCalView">
				<select id="schDateType" class="selectType02">
				</select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>
				<a href="#" class="btnTypeDefault" onclick="resetVal()"><spring:message code="Cache.btn_Initialization" /></a> <!-- 초기화 -->
			</div>
		</div>
	</div>
	
	<div class="docAllCont">
		<ul id="tabList" class="tabType2 clearFloat">
			<li indexNum="1" class="active"><a><spring:message code='Cache.lbl_generalStaff' /><!-- 일반직원 --></a></li>
			<li indexNum="2"><a><spring:message code='Cache.lbl_lessAYear' /> (9<spring:message code='Cache.lbl_day' />)<!-- 1년 미만 (9일) --></a></li>
			<li indexNum="3"><a><spring:message code='Cache.lbl_lessAYear' /> (2<spring:message code='Cache.lbl_day' />)<!-- 1년 미만 (2일) --></a></li>
			<li indexNum="4"><a><spring:message code='Cache.lbl_apv_annual' /><spring:message code='Cache.lbl_usePlan' />(<spring:message code='Cache.lbl_generalStaff' />)<!-- 1년 미만 (2일) --></a></li>
			<li indexNum="5"><a><spring:message code='Cache.lbl_apv_annual' /><spring:message code='Cache.lbl_usePlan' />(<spring:message code='Cache.lbl_lessAYear' />)<!-- 1년 미만 (2일) --></a></li>
		</ul>
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a class="btnTypeDefault" id="mailReSend1st" onclick="mailReSend(1); return false;"><spring:message code='Cache.lbl_vacation_first' /> <spring:message code='Cache.btn_Mail' /> <spring:message code='Cache.CPMail_Resend' /></a> 	<!-- 1차 메일 재전송 -->
				<a class="btnTypeDefault" id="mailReSend2nd" onclick="mailReSend(2); return false;"><spring:message code='Cache.lbl_vacation_second' /> <spring:message code='Cache.btn_Mail' /> <spring:message code='Cache.CPMail_Resend' /></a> 	<!-- 2차 메일 재전송 -->
				<a href="#" class="btnTypeDefault btnExcel" id="excelDownBtn" onclick="excelDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a>
				<a class="btnTypeDefault" id="openAllFirst" onclick="openAllFirst(); return false;"><spring:message code='Cache.btn_CheckAll' />(<spring:message code='Cache.lbl_vacation_first' />)</a>
				<a class="btnTypeDefault" id="openAllSecond" onclick="openAllSecond(); return false;"><spring:message code='Cache.btn_CheckAll' />(<spring:message code='Cache.lbl_vacation_second' />)</a>
			</div>
			<div class="ATMbuttonStyleBoxRight" style="margin-top: 24px;margin-right: 260px;float: right;">
				<spring:message code='Cache.lbl_apv_SendInfo' /><spring:message code='Cache.lbl_target' />
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 selectGroup" id="notiTarget">
					<option value=""><spring:message code='Cache.lbl_ViewAll' /></option>
					<option value="D7">1<spring:message code='Cache.lbl_Week' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
					<option value="D14">2<spring:message code='Cache.lbl_Week' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
					<option value="D21">3<spring:message code='Cache.lbl_Week' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
					<option value="M1">1<spring:message code='Cache.lbl_month' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
					<option value="M2">2<spring:message code='Cache.lbl_month' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
					<option value="M3">3<spring:message code='Cache.lbl_month' /><spring:message code='Cache.lbl_apv_limitdate' /></option>
				</select>
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

		<div class="tblList tblCont Nonefix">
			<div id="gridDiv">
			</div>
		</div>
    </div>
</div>

<script>
	var migrationRefresh = false;
	var grid = new coviGrid();
	var tabType = 1;
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	
	// 초기화
	function init() {
		
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

		searchDateType("1");

		//탭
		$("#tabList").on('click', "li", function(obj){
			$(this).addClass("active")
				  .siblings("li").removeClass("active")
			var indexNum = $(this).attr("indexNum");
			searchDateType(indexNum);
			search();	// 검색
		});

		$("#schYearSel").change(function (){
			search();	// 검색
		});
		
		// 검색 버튼
		$('.btnSearchBlue').on('click', function (e) {
			search();
		});

		// 상세 보기
		$('.btnDetails').on('click', function () {
			var mParent = $('.inPerView');
			if (mParent.hasClass('active')) {
				mParent.removeClass('active');
				$(this).removeClass('active');
			} else {
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
		
		search();	// 검색
	}

	function searchDateType(tabId){
		var initInfos = [
			{
				target : 'schDateType',
				codeGroup : 'VacationFacilitatingDate',
				defaultVal : '',
				width : '200',
				onchange : ''
			}
		];
		coviCtrl.renderAjaxSelect(initInfos, '', Common.getSession("lang"));

		$("#schDateType option").each(function (idx, obj){
			var rsv1 = ""+$(obj).data("reserved1");
			if(rsv1.indexOf(tabId)<0){
				$(this).remove();
			}
		});
	}

	function migrationAjaxCall(){
		$.ajax({
			url: "/groupware/vacation/migrationVacationPlan.do",
			type: "POST"
			,data: {
				year : $('#schYearSel').val()
			}
			,success: function(data){
				if(data.status === "SUCCESS"){
					grid.reloadList();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/vacation/migrationVacationPlan.do", response, status, error);
			}
		});
	}

	function migrationCheckVacPlan(vacPlan, vacNextPlan, type0, type1){
		var isTodo = false;
		var existNext = false;
		var existThis = false;
		if(vacNextPlan!=null
				&& vacNextPlan.hasOwnProperty(type0)
				&& vacNextPlan[type0].hasOwnProperty(type1)
				&& vacNextPlan[type0][type1].hasOwnProperty('months')
				&& vacNextPlan[type0][type1].months.length > 0
		){
			existNext = true;
		}
		if(vacPlan!=null
				&& vacPlan.hasOwnProperty(type0)
				&& vacPlan[type0].hasOwnProperty(type1)
				&& vacPlan[type0][type1].hasOwnProperty('months')
				&& vacPlan[type0][type1].months.length > 0
		){
			existThis = true;
		}
		if(existNext===true && existThis===false){
			isTodo = true;
		}

		return isTodo;
	}
	function getDisplayTerm(ord, item){
		var sKey;
		switch (tabType){
			case 1:	// 1년이상 일반직원
				if (ord  == 1) sKey = "OneDate"; 
				else sKey = "TwoDate"; 
				break;
			case 2:	//1년미만 (9일)
				if (ord  == 1) sKey = "LessOneDate9"; 
				else sKey = "LessTwoDate9"; 
				break;
			case 3:	 //1년미만 (2일)
				if (ord  == 1) sKey = "LessOneDate2"; 
				else sKey = "LessTwoDate2"; 
				break;
			case 4:	//일반직원 연차계획서
				sKey = "VacDate";
				break;
			case 5:	// 1년 미만 입사자 연차계획서
				sKey = "LessVacDate";
				break;
		}	

		return item[sKey] + "~" + item[sKey+"Until"]; // 1년이상 일반직원
	}
	
	function getReadFlag(ord, item){
		var sKey;
		switch (tabType){
			case 1:
				if (ord  == 1) sKey = "Read12";
				else sKey = "Read18";
				break;
			case 2:
				if (ord  == 1) sKey = "Read13";
				else sKey = "Read19";
				break;
			case 3:
				if (ord  == 1) sKey = "Read14";
				else sKey = "Read20";
				break;
			case 4:
				sKey ="Read10";
				break;
			case 5:
				sKey ="Read11";
				break;
		}	
		
		if(item[sKey] != null && item[sKey] != '') 
			return '<div><a class="btn_Ok" style="cursor: unset;"><spring:message code="Cache.lbl_ReadMessage" /></a></div>';
		else
			return '<div><a class="btn_No" style="cursor: unset;"><spring:message code="Cache.lbl_UnReadMessage" /></a></div>';

	}
	function getCheckFlag(ord, item){
		const vacPlan = item.VACPLAN;
		var sKey;
		var sEmpKey ; 
		switch (tabType){
		case 1:
			sEmpKey="normal";
			if (ord  == 1) sKey = "notification1";
			else sKey = "notification2";
			break;
		case 2:
			sEmpKey="newEmpForNine";
			if (ord  == 1) sKey = "notification1";
			else sKey = "notification2";
			break;
		case 3:
			sEmpKey="newEmpForTwo";
			if (ord  == 1) sKey = "notification1";
			else sKey = "notification2";
			
			const vacNextPlan = item.NEXT_VACPLAN;
			if(migrationCheckVacPlan(vacPlan, vacNextPlan, sKey, sEmpKey)){
				return '<button href="#" class="btnRefresh" type="button" onclick="migrationAjaxCall();"></button>';
			}
			
			break;
		case 4:
			sKey="plan";
			sEmpKey="normal";
			break;
		case 5:
			sKey="plan";
			sEmpKey="newEmp";
			break;
			
		}	
		
		if(vacPlan.hasOwnProperty(sKey)
				&& vacPlan[sKey].hasOwnProperty(sEmpKey)
				&& vacPlan[sKey][sEmpKey].hasOwnProperty('months')
				&& vacPlan[sKey][sEmpKey].months.length > 0
		)
			return '<div><a class="btn_Ok" onclick="openPrintPopup(\''+ item.UserCode +'\', \''+sKey+'\', \''+ item.EnterDate +'\');"><spring:message code="Cache.lbl_Registor" /></div>';
		else
			return '<div><a class="btn_No" onclick="openPrintPopup(\''+ item.UserCode +'\', \''+sKey+'\', \''+ item.EnterDate +'\');"><spring:message code="Cache.lbl_Unregistered" /></a></div>';
	}
	// 그리드 세팅
	function setGrid() {
		// header
		var headerData = [{key:'UserCode', label:'chk', width:'30', align:'center', formatter:'checkbox' },
						{key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'60', align:'center',                     //부서
							formatter:function () {return "<label title='"+this.item.DeptName+"'>"+this.item.DeptName+"</label>";}},						
				        {key:'JobPositionName',  label:'<spring:message code="Cache.lbl_apv_jobposition" />', width:'40', align:'center'},	//직위
						{key:'DisplayName', label: '<spring:message code="Cache.lbl_username" />', width: '40', align: 'center', addClass:'bodyTdFile',
				        	formatter:function(){
				        		var html ="<div class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+ this.item.UserCode +"' data-user-mail='"+ this.item.MailAddress +"'>"
								html += this.item.DisplayName;
								html += "</div>";
									
								return html;
				        	}	
						},			//이름
						{key:'EnterDate',label:'<spring:message code="Cache.lbl_EnterDate" />',width:'50',align:'center'},					//입사일자
						{key:'OneDate',label:'<spring:message code="Cache.lbl_vacation_first" /> <spring:message code="Cache.lbl_vacationMsg51" />',width:'100',align:'center',
							formatter:function () {return getDisplayTerm(1, this.item);}},	//1차 촉진기간
						{key:'Read12',label:'<spring:message code="Cache.lbl_confrim_yn" />',width:'50',align:'center',
							formatter:function () {return getReadFlag(1, this.item)}},	//확인여부
						{key:'chk1', label:'chk1', formatter: 'checkbox',  width:'30', align:'center'},
						{key:'VACPLAN1',label:'<spring:message code="Cache.lbl_State" />',width:'45',align:'center',
							formatter:function () {return getCheckFlag(1, this.item);}},	// 상태
						];		
		if (tabType == 1 || tabType == 2 || tabType == 3){ // 1년이상 일반직원,1년미만 (9일), 1년미만 (2일)
			headerData = headerData.concat([{key:'TwoDate',label:'<spring:message code="Cache.lbl_vacation_second" /> <spring:message code="Cache.lbl_vacationMsg51" />',width:'100',align:'center',
						formatter:function () {return getDisplayTerm(2, this.item); }},	//2차 촉진기간
					{key:'Read18',label:'<spring:message code="Cache.lbl_confrim_yn" />',width:'50',align:'center',
						formatter:function () {return getReadFlag(2,this.item);}},	//확인여부
					{key:'chk2', label:'chk2', formatter: 'checkbox',  width:'30', align:'center'},
					
					{key:'VACPLAN2',label:'<spring:message code="Cache.lbl_State" />',width:'45',align:'center',
						formatter:function () {return getCheckFlag(2, this.item);	}}	// 상태	
							]);
		}
		
		// config
		grid.setGridConfig({
			targetID: "gridDiv",
			height: "auto",
			colGroup :headerData,
			page : {
				pageNo: (page != undefined && page != '')?page:1,
				pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
			},
			colHead:{rows: [[ {colSeq:0, rowspan:2},
			                  {colSeq:1, rowspan:2},
			                  {colSeq:2, rowspan:2},
			                  {colSeq:3, rowspan:2},
			                  {colSeq:4, rowspan:2},
			                  {colSeq:null, colspan:4, label:"<spring:message code="Cache.lbl_vacation_first" />", align:"center"}, 
			                  {colSeq:null, colspan:4, label:"<spring:message code="Cache.lbl_vacation_second" />", align:"center"}],
			               [{colSeq:5},{colSeq:6},{colSeq:7},{colSeq:8},{colSeq:9},{colSeq:10},{colSeq:11},{colSeq:12}]
						]}
		});
	}

	// 그리드 카운트
	$('#listCntSel').on('change', function(e) {
		grid.page.pageSize = $(this).val();
		grid.reloadList();
	});

	$('#notiTarget').on('change', function(e) {
		search();
	});
	// 검색
	function search() {
		
		$("#tabList li").each(function(i, v){
			if ($(v).hasClass('active')) {
				tabType = i + 1;
			}
		});

		switch(tabType){
			case 1:
				$("#openAllFirst").show();
				$("#openAllSecond").show();
				$("#mailReSend2nd").show();
				break;
			case 2:
				$("#openAllFirst").show();
				$("#openAllSecond").show();
				$("#mailReSend2nd").show();
				break;
			case 3:
				$("#openAllFirst").show();
				$("#openAllSecond").show();
				$("#mailReSend2nd").show();
				break;
			case 4:
				$("#openAllFirst").show();
				$("#openAllSecond").hide();
				$("#mailReSend2nd").hide();
				break;
			case 5:
				$("#openAllFirst").show();
				$("#openAllSecond").hide();
				$("#mailReSend2nd").hide();
				break;
		}
		
		setGrid();
		
		var params = {
				tabType : tabType,
				year : $('#schYearSel').val(),
				schTypeSel : $('#schTypeSel').val(),
				schTxt : $('#schTxt').val(),
				schDateType : $('#schDateType').val(),
				startDate : $('#startDate').val(),
				endDate : $('#endDate').val(),
				notiTarget : $("#notiTarget option:selected").val()
			};

		grid.page.pageNo = 1;
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationFacilitatingDateList.do",
			ajaxPars : params
			,onLoad:function() {
				if(migrationRefresh){
					migrationRefresh = false;
					grid.reloadList();
				}
			}
		});
	}
	
	//검색 초기화
	function resetVal(){
		var nowYear = new Date().getFullYear();
		$('#schYearSel').val(nowYear);
		$('#schTypeSel').val("displayName");
		$("#schTxt").val("");
		$("#schDateType option:eq(0)").prop("selected", true);
		$("#startDate").val("");
		$("#endDate").val("");
	}
	
	//등록내역 팝업
	function openPrintPopup(userCode, formType, enterDate, isAll){
		var year = $('#schYearSel').val();
		
		$("#tabList li").each(function(i, v){
			if ($(v).hasClass('active')) {
				tabType = i + 1;
			}
		});
		
		var empType =  "";
		switch(tabType){
			case 1: empType =  "normal"; break;
			case 2: empType =  "newEmpForNine";year=enterDate.substring(0,4);break;
			case 3: empType =  "newEmpForTwo";year=enterDate.substring(0,4);break;
			case 4: empType =  "normal"; break;
			case 5: empType =  "newEmp";year=enterDate.substring(0,4);break;
		}
		
		url = "/groupware/vacation/goVacationPromotionPopup.do"
				+ "?year=" + year + "&urCode=" + userCode + "&formType="+ formType + "&empType=" + empType + "&viewType=admin";
		if(isAll){
			url += "&isAll=Y";
		}
		window.open(url, "printWindow_"+userCode, 'width=960, height=' + (window.screen.height - 100) + ', resizable=yes,scrollbars=yes');
	}

	// 엑셀 저장
	function excelDownload() {
		var sortInfo = grid.getSortParam("one").split("=");
		var sortBy = sortInfo.length > 1 ? sortInfo[1] : "";
		
		var params = {
			tabType : tabType,
			year : $('#schYearSel').val(),
			schTypeSel : $('#schTypeSel').val(),
			schTxt : $('#schTxt').val(),
			schDateType : $('#schDateType').val(),
			startDate : $('#startDate').val(),
			endDate : $('#endDate').val(),
			sortBy : sortBy
		};

		ajax_download("/groupware/vacation/getVacationFacilitatingExcelDateList.do", params);	// 엑셀 다운로드 post 요청
	}


	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
		var $iframe, iframe_doc, iframe_html;

		if ($('#download_iframe').length != 0) {
			$('#download_iframe').remove();
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

	function schUrNameSearch(){
		$("#schTxt").val($("#schUrName").val());
		search();
	}

	$(document).ready(function(){
		init();

		$("#schTxt").keypress(function(){
			if (event.keyCode==13){ search(); return false;}
		});


		$("#schUrName").keypress(function(){
			if (event.keyCode==13){ schUrNameSearch(); return false;}
		});
	});

	function getGridColSeq(grid, colKey){
		for (var i=0; i< grid.config.colGroup.length; i++){
			if (grid.config.colGroup[i]["key"] == colKey){
				return i;
			}
		}
		return -1;
	}
	function openAllFirst(){
		 if($("input[name=chk1]:checked").length===0){
			 Common.Warning("<spring:message code='Cache.msg_SelectTarget' />");  // 대상을 선택해주세요.
		}
		var formType =  "";
		var index = 6;
		index = getGridColSeq(grid, "chk1");
		if (index == -1){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />");
			return;
		}

		switch(tabType){
			case 1: formType =  "notification1";  break;
			case 2: formType =  "notification1"; break;
			case 3: formType =  "notification1"; break;
			case 4: formType =  "plan"; break;
			case 5: formType =  "plan"; break;
		}
		$(grid.getCheckedList(index)).each(function(idx, obj){
			openPrintPopup(obj.UserCode, formType, obj.EnterDate, true);
		});

	}

	function openAllSecond(){
		 if($("input[name=chk2]:checked").length===0){
			 Common.Warning("<spring:message code='Cache.msg_SelectTarget' />");  // 대상을 선택해주세요.
		}
		var formType =  "";
		var index = 10;
		index = getGridColSeq(grid, "chk2");

		if (index == -1){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />");
			return;
		}

		switch(tabType){
			case 1: formType =  "notification2"; break;
			case 2: formType =  "notification2"; break;
			case 3: formType =  "notification2"; break;
			case 4: formType =  "plan"; break;
			case 5: formType =  "plan"; break;
		}
		$(grid.getCheckedList(index)).each(function(idx, obj){
			openPrintPopup(obj.UserCode, formType, obj.EnterDate, true);
		});

	}

	function mailReSend(ordinal) {

		var Params = {
			tabType: tabType,
			year: $('#schYearSel').val(),
			schTypeSel: $('#schTypeSel').val(),
			schTxt: $('#schTxt').val(),
			schDateType: $('#schDateType').val(),
			startDate: $('#startDate').val(),
			endDate: $('#endDate').val(),
			emailReSend: 'Y',
			notiTarget: $("#notiTarget option:selected").val()
		};

		// N차 촉진 메일 
		if (ordinal === 1) { 			// 1차.
			Params.schDateType = "1";
		} else if (ordinal === 2) { 	// 2차.
			Params.schDateType = "2";
		} else {
			return false;
		}
		
		if($("input[name=chk]:checked").length===0 ){
			Common.Confirm("미등록자 모두에게 연차촉구 메일을 발송 하기겠습니까?", "Confirmation Dialog", function(result) {
				if (!result) {
					return false;
				} else {
					mailReSendAjax(Params);
				}
			});
		}else {
			Common.Confirm("수신자수:"+$("input[name=chk]:checked").length, "Confirmation Dialog", function(result) {
				if (!result) {
					return false;
				} else {
					var arrChkUserId = new Array();
					for(var i=0;i<$("input[name=chk]:checked").length;i++){
						arrChkUserId.push($("input[name=chk]:checked").eq(i).val());
					}
					
					Params.sendMailUsers = JSON.stringify(arrChkUserId);
					
					mailReSendAjax(Params);
				}
			});
		}
	}
	
	function mailReSendAjax(Params) {
		$.ajax({
			type: "POST",
			data: Params,
			url: "/groupware/vacation/getVacationFacilitatingDateList.do",
			success: function (data) {
				if (data.status != 'SUCCESS') {
					Common.Warning("<spring:message code='Cache.msg_apv_030' />");
				}
				if (data.status == 'SUCCESS') {
					Common.Warning("<spring:message code='Cache.CPMail_Resend' /> <spring:message code='Cache.msg_170' />");
				}
			},
			error: function (response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
</script>			