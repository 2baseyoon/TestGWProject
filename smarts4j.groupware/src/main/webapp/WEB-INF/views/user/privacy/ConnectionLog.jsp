<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.lbl_AccessHistory"/></h2> <!-- 접속이력 -->
	<div class="searchBox02">
		<div class="dateSel type02">
			<div id="logCalendarPicker"></div>
<!--  			<input class="adDate" type="text" readonly="">
				<a class="icnDate" href="#">날짜선택</a> 
				<span>- </span>
			<input class="adDate" type="text" readonly="">
				<a class="icnDate" href="#">날짜선택</a> -->
		</div>
	</div>		
</div>
<div class="cRContBottom mScrollVH">
	<div class="myInfoContainer myInfoAccessHistoryCont">
		<div class="boradTopCont accessHistoryTop">								
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCntSel">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button href="#" class="btnRefresh" type="button" onclick="search()"></button>
			</div>
		</div>
		<div class="accessHistoryBottom">
			<div class="tblList tblCont ">
				<div id="gridDiv">
				</div>
				<!-- <div class="goPage">
					<input type="text"> <span> / 총 </span><span>1</span><span>페이지</span><a href="#" class="btnGo">go</a>
				</div>	 -->						
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	var grid = new coviGrid();

	// 달력 옵션
	var timeInfos = {
		width : '105', //기본값은 100 [필수항목X]
		H : "", // 날짜 단위기 때문에 H는 없음.
		W : "1,2,3", //주 선택
		M : "1,2,3", //달 선택
		Y : "1" //년도 선택
	};
	var initInfos = {
		height : '300', //그려지는 모든 select box의 길이
		width : '105',   //시간 picker에 대한 사이즈 값 기본값은 100 [필수 X]
		useCalendarPicker : 'Y',
		useTimePicker : 'N',
		useBar : 'Y',
		useSeparation : 'N',
		changeTarget : 'start'
	};
	
	initContent();
	
	// 개인환경설정 > 접속이력
	function initContent() {
		init();	// 초기화
		
		setGrid();	// 그리드 세팅
		
		search();	// 검색
	}
	
	// 초기화
	function init() {
		coviCtrl.renderDateSelect('logCalendarPicker', timeInfos, initInfos);	// 설문기간
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			grid.reloadList();
		});
	}
	
	// 그리드 세팅
	function setGrid() {
		var headerData = [
			{key:'days', label:"<spring:message code='Cache.lbl_LogonOnlyDate'/>", width:'150', align:'center'}, //로그온 일자
			{key:'LogonDate', label:"<spring:message code='Cache.lbl_FirstLogonTime'/>"  + Common.getSession("UR_TimeZoneDisplay"), width:'150', align:'center', formatter: function(){
				return CFN_TransLocalTime(this.item.LogonDate);
			}}, //최초 로그온 시간
			{key:'LogoutDate', label:"<spring:message code='Cache.lbl_LastLogoutTime'/>"  + Common.getSession("UR_TimeZoneDisplay"), width:'150', align:'center', formatter: function(){
				return CFN_TransLocalTime(this.item.LogoutDate);
			}}, //최종 로그아웃 시간
			{key:'LogonID', label:"<spring:message code='Cache.lbl_LogonID'/>", width:'150', align:'center'} //로그온 아이디	                  
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
	function search() {
		var resultDate = coviCtrl.getDataByParentId('logCalendarPicker');
		var params = {startDate : resultDate.startDate.replaceAll('.', '-'),
       				  endDate : resultDate.endDate.replaceAll('.', '-'),
       				  sortBy : "days DESC"};
		
		grid.bindGrid({
			ajaxUrl : "/groupware/privacy/getConnectionLogList.do",
			ajaxPars : params,
			onLoad : function() {
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
				grid.fnMakeNavi("grid");
			}
		});
	}
</script>
