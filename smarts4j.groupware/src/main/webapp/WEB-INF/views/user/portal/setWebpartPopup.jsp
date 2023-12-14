<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<%--
	퍼스털 포털 게시판 변경 팝업.
	popupType = 0 : 변경 폴더 ID inputbox. 하나만 받고, 숫자만 입력 가능.
	popupType = 1 : 변경 폴더 ID selectbox.
	popupType = 2 : 변결 폴더 ID inputbox. 쉼표(,) 구분으로 다수 입력 가능. 툴팁 클릭 제공.
--%>

<!-- body -->
<div class="divpop_body">
	<div class="sadmin_pop">
		<table class="sadmin_table sa_menuBasicSetting">
			<colgroup>
				<col width="130px;">
				<col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th><span><spring:message code="Cache.lbl_cert_now"/> <spring:message code="Cache.lbl_Folder"/> ID</span></th> 	<!-- 현재 폴더 ID -->
					<td><span>${currentValue}</span></td>
				</tr>
				<tr>
					<th>
						<span id="strKindParameter"><spring:message code="Cache.lbl_change"/> <spring:message code="Cache.lbl_Folder"/> ID</span> 	<!-- 변경 폴더 ID -->
						<c:if test='${popupType eq "2"}'>
							<div class="collabo_help02">
								<a href="#" id="helpToggle" class="help_ico"></a>
								<div class="helppopup" style="width:130px;min-width: 100px;">
									", " <spring:message code="Cache.lbl_Gubun"/> <spring:message code="Cache.lbl_apv_grform_07"/> <!-- , 구분 사용가능 -->   
								</div>
							</div>
						</c:if>
					</th>
					
					<td>
						<c:if test='${popupType eq "0"}'>
							<input type="number" id="iptPopupSave0" placeholder='<spring:message code="Cache.lbl_change"/> <spring:message code="Cache.lbl_Folder"/> ID'/>
						</c:if>
						<c:if test='${popupType eq "2"}'>
							<input type="text" id="iptPopupSave2" placeholder='<spring:message code="Cache.lbl_change"/> <spring:message code="Cache.lbl_Folder"/> ID'/>
						</c:if>
						<c:if test='${popupType eq "1"}'>
							<select class="selectType02" id="selPopupSave">
								<option>10401</option>
								<option>10402</option>
							</select>
						</c:if>
					</td>
					
				</tr>
			</tbody>
		</table>
		
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveMessage()"><spring:message code="Cache.btn_save"/></a>   <!-- 저장 -->
			<a href="#" class="btnTypeDefault" onclick="closeMessage()"><spring:message code="Cache.btn_Close"/></a> 	<!-- 닫기 -->
		</div>
		
	</div>
</div>
<!-- // body -->
		
<script>

$("#helpToggle").on('click', function() {
	let isClass = $(this).hasClass("active");
	if (isClass) {
		$(this).removeClass("active");
	} else {
		$(this).addClass("active");
	}
});

function saveMessage(){
	let strPopupType = "${popupType}";
	let saveValue = "";
	
	if (strPopupType === "0") {
		saveValue = $("#iptPopupSave0").val();
	} else if (strPopupType === "2") {
		saveValue = $("#iptPopupSave2").val();
	} else if (strPopupType === "1") {
		saveValue = $("#selPopupSave").val();
	}
	
	window.parent.postMessage(
		{
			functionName : "${webpartID}"
	    	, params :
	    		{
	    			"status" : "SUCCESS"
	    			, "saveValue" : saveValue
	    		}
		}
		, '*' 
	);
	Common.Close();
}

function closeMessage(){
	Common.Close();
}

</script>
