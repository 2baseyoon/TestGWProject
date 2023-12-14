<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.miAnniversaryPopup .ulList li> div:first-child {width:130px;}
</style>
</head>
<body> 
<form id="baseDateFrm" method="post">

<div class="layer_divpop popContent ui-draggable" style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class=" miAnniversaryPopup">
			<div class="">
				<div class="top">						
					<div class="ulList"> 
						<ul>
							<li class="listCol">
								<div>
									<strong>
										<spring:message code='Cache.lbl_last'/> <spring:message code='Cache.DicSection_Base'/> 	<%-- 마지막 기초 데이터 --%>
									</strong>
								</div> 	
								<div>
									<p style="float: left; font-weight: bold;" id="lastDate">2023.12.31</p>
								</div>
							</li>	
							<li class="listCol">		
								<div><strong><spring:message code='Cache.lbl_apv_next'/> <spring:message code='Cache.lbl_Exit'/> <spring:message code='Cache.lblNyunDo'/></strong></div> 	<%-- 다음 종료 년도 --%>
								<div><select class="selectType02" id="selYear"></select></div>
							</li>	
						</ul>							
					</div>
				</div>
				<div class="bottom" style="text-align: center;">
					<a href="#" class="btnTypeDefault btnTypeChk" onclick="saveDate()"><spring:message code="Cache.btn_register" /></a> <!-- 등록 -->	
					<a href="#" class="btnTypeDefault" onclick="Common.Close()"><spring:message code="Cache.btn_att_close" /></a> <!-- 닫기 -->
				</div>
			</div>
		</div>
	</div>	
</div>

</form>
</body>

<script type="text/javascript">
$(document).ready(function() {
	setYearSelect();
});

function setYearSelect() { 	//마지막 날짜와 다음 종료일 세팅.
	
	var objLastYear = ${result};
	var lastDate = 0;
	
	if (objLastYear.length > 0 && typeof(objLastYear[0].DayList) === "string") {
		
		$("#lastDate").text(objLastYear[0].DayList);
		lastDate = objLastYear[0].DayList;
	}
	
	for(var i=0; 10>i; i++) { 	// 향후 10년의 년도를 select에 적시.
		$("#selYear").append($('<option>',{
			value : Number(lastDate.substring(0,4))+i,
			text : Number(lastDate.substring(0,4))+i
		}));
	}
}

function saveDate() {
	
	if (validityCheck()) {
		var url = "/groupware/attendAdmin/addAttendBaseDate.do";
		var params = {"addDate" : $("#selYear").val()};
		
		$.ajax({
			type:"POST"
			, dataType : "json"
			, data : params
			, url : url
			, success : function(data) {
				if (data.status === "SUCCESS") {
					Common.Inform("<spring:message code='Cache.msg_AddData'/>.", "Information", function() { 	// 데이터가 추가되었습니다
						Common.Close();
					});
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); 	// 오류가 발생했습니다. 
				}
			}
		});
	}
}

function validityCheck() {
	
	var addDate = $("#selYear").val();
	
	if ( addDate === "" || isNaN(addDate) ) {
		Common.Warning("<spring:message code='Cache.msg_invalidDateFormat'/>"); 	// 날짜 형식이 올바르지 않습니다.
		return false;
	} else if (addDate.length != 4) {
		Common.Warning("<spring:message code='Cache.msg_invalidDateFormat'/>"); 	// 날짜 형식이 올바르지 않습니다.
		return false;
	} else {
		return true;
	}
}

</script>
</html>