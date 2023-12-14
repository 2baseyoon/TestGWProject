<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	const sID = "${param.ID}"; //  CFN_GetQueryString("ID")=="undefined"? "" : CFN_GetQueryString("ID");
	const sState = "${param.State}";
	const sIndex = "${param.Index}";
	
	$(document).ready(function(){		
		setControl();
		setData();
	});
	
	// Select box 및 이벤트 바인드
	function setControl(){
		
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// data셋팅
	function setData(){		
		var oSelList = parent.myGrid.list[sIndex];
		
		$("#State").text((sState == "SUCCESS" ? '<spring:message code="Cache.lbl_apv_Success"/>' : '<spring:message code="Cache.lbl_apv_Fail"/>'));
		$("#EventStartTime").text(CFN_TransLocalTime(oSelList.EventStartTime));
		$("#EventEndTime").text(CFN_TransLocalTime(oSelList.EventEndTime));
		var elapsedTime = oSelList.ElapsedTime;
		if(elapsedTime) elapsedTime = Math.ceil(elapsedTime/1000);
		$("#ElapsedTime").text(elapsedTime + " sec");
		$("#ResultCode").text(oSelList.ResultCode);
		$("#ResultMessage").text(oSelList.ResultMessage);
		$("#RawResponse").val(oSelList.RawResponse);
		$("#ErrorStackTrace").val(oSelList.ErrorStackTrace);
	}
	
</script>
<div class="sadmin_pop">		 		
	<table class="sadmin_table sa_menuBasicSetting" >
		<colgroup>
			<col width="120px">
			<col width="*">
		</colgroup>
		<tbody>
		
			<tr>
		      	<th><spring:message code="Cache.lbl_apv_legacyResult"/></th> <!-- 결과 -->
			  	<td><span id="State"></span></td>
		    </tr>
			<tr>
		      	<th><spring:message code="Cache.lbl_StartTime"/></th> <!-- 시작시간 -->
			  	<td><span id="EventStartTime"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_EndTime"/></th> <!-- 종료시간 -->
			  	<td><span id="EventEndTime"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.btn_apv_passedTime"/></th> <!-- 경과시간 -->
			  	<td><span id="ElapsedTime"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_apv_resultCode"/></th> <!-- 응답코드 -->
			  	<td><span id="ResultCode"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_apv_resultMessage"/></th> <!-- 응답메세지 -->
			  	<td><span id="ResultMessage"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_apv_response"/></th> <!-- 응답전문 -->
			  	<td><textarea id="RawResponse" style='font-family:Consolas;resize:both;width:100%;height:100px;line-height:130%;text-align:left' readonly></textarea></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_apv_errMessage"/></th> <!-- 오류메세지 -->
			  	<td><textarea id="ErrorStackTrace" style='font-family:Consolas;resize:both;width:100%;height:240px;line-height:130%;text-align:left' readonly></textarea></td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>		
</div>
