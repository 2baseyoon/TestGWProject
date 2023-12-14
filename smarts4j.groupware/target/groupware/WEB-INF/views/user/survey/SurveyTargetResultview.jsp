<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent pd0"><!--    <--div 차후 삭제 예정 		-->
	<div class="selectSearchBox">
		<select class="selectType02" id="targetTypeSel">
			<option value="ur"><spring:message code='Cache.lbl_Participation_User' /></option>
			<option value="gr"><spring:message code='Cache.lbl_dept' /></option>
		</select>
		<span><input type="text" id="schTxt" onkeypress="if(event.keyCode==13){searchData(); return false;}"/><a class="btnSearchType01" onclick="searchData()"></a></span>
		<button class="btnRefresh" type="button" onclick="refresh()"></button>					
	</div>				
	<div class="surTargetBtm">
		<div class="tblList">					
			<div id="gridDiv">
			</div>									
		</div>
	</div>
</div><!--    <--div 차후 삭제 예정 		-->

<script>
	var surveyId = CFN_GetQueryString("surveyId");
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", ""); //프로필 이미지 경로
	var grid = new coviGrid();
	
	initContent();

	// 결과공개 대상
	function initContent(){
		setGrid();	// 그리드 세팅
		
		searchData();	// 검색
	}
	
	// 그리드 세팅
	function setGrid() {
		var headerData = [
			{key:'DisplayName', label:'<spring:message code="Cache.lbl_surveyResultList" />', width:'50', align:'center', sort: 'asc', addClass:'bodyTdFile',
				formatter:function () {
					var html = "<div class='tblParticipant'>"
					html += "<img src='" + coviCmn.loadImage(this.item.PhotoPath)+" ' alt='" + "<spring:message code='Cache.lbl_ProfilePhoto'/>" + "' style='width:30px;height:30px;border-radius:15px;' onerror='coviCmn.imgError(this, true)'>";
					html +=  "<a class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='margin-left : 10px'; data-user-code='"+ this.item.TargetCode +"' data-user-mail=''>" + this.item.DisplayName + "</a>";
 					html += "</div>";
 					
					return html;
				}
			},
			{key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'100', align:'center'}
		];
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
			colHeadTool : false
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function searchData() {
		var params = {surveyId : surveyId,
				  	  targetType : $("#targetTypeSel").val(),
				  	  schTxt : $("#schTxt").val()};
		
		grid.page.pageNo = 1;
		grid.bindGrid({
			ajaxUrl : "/groupware/survey/getTargetResultviewList.do",
			ajaxPars : params
		});
	}
	
	//새로고침
	function refresh(){
		$("#targetTypeSel").val('ur');
		$("#schTxt").val('')
		
		searchData();
	}
	
</script>
