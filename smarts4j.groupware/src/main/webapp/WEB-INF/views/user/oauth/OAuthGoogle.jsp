<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<script  type="text/javascript">
	
	$(document).ready(function(){
		$("#callurl").val(location.origin + "/groupware/oauth2/google.do");
	});

	// 팝업 닫기
	function closeLayer() {
		if(opener){
			opener.initContent();
		}else{
			parent.initContent();				
		}
		
		window.close();
		//Common.Close();
	} 
	
	function authorize(){
		$("#frm").attr("method","POST")
		$("#frm").attr("action", location.origin + "/covicore/oauth2/client/auth.do");
		$("#frm").submit();
	}
	
	setTimeout("response()",300*1);
	
	function response(){
		if($("#state").val() == "success"){
			$.ajax({
				url:"/covicore/oauth2/client/saveGoogleMail.do",
				type:"POST",
				async:false,
				data:{
					email : $("#email").val()
				},
				success:function (e) {
					alert('<spring:message code="Cache.msg_GoogleAuthSettingOK"/>');
					if (typeof(opener.window.googleAuthCallback) !== 'undefined' && $.isFunction(opener.window.googleAuthCallback)) opener.window.googleAuthCallback();
					
					if(opener){
						opener.initContent();
					}else{
						parent.initContent();				
					}
					
					window.close();
				}
			});
		}
	}
	
</script>
<form id="frm">
	<div class="layer_divpop ui-draggable">
		<input type="hidden" id="state" name="state" value="${state}"/>
		<input type="hidden" id="callurl" name="callurl" />
		<div class="divpop_contents">
		    <div class="pop_header" id="testpopup_ph">
		      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">OAuth2</span></h4>
		    </div>	
			<div class="popBox" style="overflow-x: hidden;height: 70px;">
				<table class="tableStyle">
					<colgroup>
						<col style="width:100px;">
						<col style="width:*">
					</colgroup>
					<thead>
						<tr>
							<th>Google Email</th>
							<td><input type="text" style="width: 500px;"  id="email" name="email" value="${email}"></td>
						</tr>
					</thead>
				</table>
			</div>
			<div align="center" style="padding-top: 10px;padding-bottom: 20px">
				<input type="button" value="Authorize" onclick="authorize();" class="ooBtn" />
				<input type="button" value="Close" onclick="closeLayer();"  class="gryBtn" />
			</div>
		</div>
	</div>
</form>