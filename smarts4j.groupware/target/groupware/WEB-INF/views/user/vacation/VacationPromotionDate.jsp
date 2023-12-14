<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.MN_696' /></h2>	<!-- 연차촉진기간설정 -->
</div>
<div class='cRContBottom mScrollVH'>
	<div class="boardAllCont">
	
		<div class="boradTopCont" id="boradTopCont_1" style="display: block;">
			<!-- 
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="#" class="btnTypeDefault btnTypeChk" id="insVacBtn" onclick="openVacationInsertPopup();" style="display:none"><spring:message code='Cache.btn_register' /></a>
			</div>
			 -->
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>
	</div>
</div>

<script>
	var grid = new coviGrid();
	
	init();

	// 초기화
	function init() {
		// 화면 처리
		//$('#insVacBtn').css('display', '');
		
		search();	// 검색
	}

	// 그리드 세팅
	function setGrid() {
		// header
		var headerData = null;
			headerData = [
				{
					key: 'ReqTypeName',label: '<spring:message code="Cache.lbl_vacationMsg49" />',width: '100',align: 'center'		//촉진유형
				},
				{
					key: 'ReqMonth',
					label: '<spring:message code="Cache.lbl_vacation_first" /> <spring:message code="Cache.lbl_vacationMsg50" />',		//1차 촉진월
					width: '50',
					align: 'center',
					formatter: function () {
						var html = "<div class='tblLink'>";
						html += "<a href='#' onclick='openVacationInsertPopup(\"" + this.item.ReqType + "\", \"" + this.item.ReqOrd + "\"); return false;'>";
						if (typeof (this.item.ReqMonth) != 'undefined') html += CFN_GetDicInfo(this.item.ReqMonth);
						html += "</a>";
						html += "</div>";

						return html;
					}
				},
				{
					key:'ReqTermDay',label:'<spring:message code="Cache.lbl_vacation_first" /> <spring:message code="Cache.lbl_vacationMsg51" />',width:'50',align:'center'		//1차 촉진기간
				},
				{
					key: 'ReqMonth2',
					label: '<spring:message code="Cache.lbl_vacation_second" /> <spring:message code="Cache.lbl_vacationMsg50" />',		//2차 촉진월
					width: '50',
					align: 'center',
					formatter: function () {
						var html = "<div class='tblLink'>";
						html += "<a href='#' onclick='openVacationInsertPopup(\"" + this.item.ReqType2 + "\", \"" + this.item.ReqOrd2 + "\"); return false;'>";
						if (typeof (this.item.ReqMonth2) != 'undefined') html += CFN_GetDicInfo(this.item.ReqMonth2);
						html += "</a>";
						html += "</div>";

						return html;
					}
				},
				{
					key:'ReqTermDay2',label:'<spring:message code="Cache.lbl_vacation_second" /> <spring:message code="Cache.lbl_vacationMsg51" />',width:'50',align:'center'		//2차 촉진기간
				}
			];

			grid.setGridHeader(headerData);

			// config
			grid.setGridConfig({
				targetID: "gridDiv",
				height: "auto"
			});
	}

	// 검색
	function search() {
		setGrid();
		var params = null;

		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationPromotionDateList.do",
			ajaxPars : params,
			onLoad: function(){
				if(grid.page.listCount==null || grid.page.listCount==0){
					Common.Confirm("기본 설정 값이 존재 하지 않습니다.\n기본 값 으로 연차촉진 기간을 설정 하시 겠습니까?", "Confirm", function(result){
						if(result){
							initVacationPromotionDate();
						}
					});
				}
			}
		});
	}
	//기초 값 세팅 처리
	function initVacationPromotionDate(){
		$.ajax({
			url: "/groupware/vacation/initVacationPromotionDate.do",
			type: "POST",
			success: function(result){
				if(result.status === "SUCCESS"){
					search();
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/vacation/setInitVacationPromotionDate.do", response, status, error);
			}
		});
	}

	// 연차등록 버튼
	function openVacationInsertPopup(reqType, reqOrd) {
		Common.open("","target_pop", "<spring:message code='Cache.MN_696' />","/groupware/vacation/goVacationPromotionDatePopup.do?reqType="+reqType+"&reqOrd="+reqOrd,"400px","250px","iframe",true,null,null,true);
	}
	
	
</script>			