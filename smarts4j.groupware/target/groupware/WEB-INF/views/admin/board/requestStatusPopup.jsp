<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script>
	//var mode = ${mode};
	var statusList = ${statusList};
	var requestID = CFN_GetQueryString("requestID");//Request ID
	var status = CFN_GetQueryString("status");		//현재상태
	var answer = CFN_GetQueryString("answer");		//기작성된 답변

	
	$(document).ready(function () {
		$("#spnCommentInfo").text("<spring:message code='Cache.msg_RUStateChg' />");

		$("#requestStatus").bindSelect({
			reserveKeys: {
				optionValue: "optionValue",
				optionText: "optionText"
			},
			options:statusList
		});

		//작성된 답변이 있다면 설정
		if(answer!=""){
			$("#answerContent").val(decodeURIComponent(answer));	//GET방식에서 한글깨짐
		}

		//현재 상태 selectbox set
		$("#requestStatus").bindSelectSetValue(status);
	});
	
	//하단의 닫기 버튼 함수
	function closeLayer(){
		Common.Close();
	}

	function saveStatus(){
		if($("#txtAnswer").val()==""){
			parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationComment' />", "Warning Dialog", function () {     //필드명 입력
		    	$("#txtAnswer").focus();
		    });
			return;
		}

		$.ajax({
	    	type:"POST",
	    	url: "/groupware/admin/updateRequestStatus.do",
	    	dataType : 'json',
	    	data: {
		    	"requestID": requestID
		    	,"answerContent": $("#answerContent").val()
		    	,"requestStatus": $("#requestStatus").val()
		    },
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			parent.selectMessageGridList();
		    			Common.Close();
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}

	
</script>
<div>
	<form id="frmComment">	
    <!-- 팝업 Contents 시작 -->
   	<span id="spnCommentInfo"></span>
   	<br/>
   	<div style="margin:20px 0 5px 0;">
   		<span>
   		<spring:message code='Cache.lbl_ProcessContents' />
   		<select id="requestStatus" class="AXSelect"></select>
   		</span>
   	</div>
   	<textarea id="answerContent" style="width:280px; height:100px; "></textarea>
   	
	<div align="center" style="padding-top: 10px">
		<input type="button" value="<spring:message code='Cache.lbl_Confirm' />" onclick="saveStatus();" class="AXButton red">
		<input type="button" value="<spring:message code='Cache.lbl_Cancel' />" onclick="closeLayer();" class="AXButton">
	</div>
	</form>	
</div>
