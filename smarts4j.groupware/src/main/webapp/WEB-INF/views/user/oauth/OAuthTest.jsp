<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<script  type="text/javascript">
	// 팝업 닫기
	function closeLayer() {
		Common.Close();
	} 
	
	function authorize(){
		$("#frm").attr("method","GET")
		$("#frm").attr("action", "${authorize_url}");
		$("#frm").submit();
	}
	
</script>
<form id="frm">
	<div class="layer_divpop ui-draggable">
		<div class="divpop_contents">
		    <div class="pop_header" id="testpopup_ph">
		      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">OAuth</span></h4>
		    </div>	
			<div class="popBox" style="overflow-x: hidden;overflow-y: scroll;height: 260px;">
				<table class="tableStyle">
					<colgroup>
						<col style="width:100px;">
						<col style="width:*">
					</colgroup>
					<thead>
						<tr>
							<th>Clinet ID</th>
							<td><input type="text" style="width: 500px;"  id="client_id" name="client_id" value="${client_id}"></td>
						</tr>
						<tr>
							<th>Redirect Url</th>
							<td><input type="text" style="width: 500px;" id="redirect_uri" name="redirect_uri" value="${redirect_url}"></td>
						</tr>
						<tr>
							<th>Response Type</th>
							<td><input type="text" style="width: 500px;" id="response_type" name="response_type"  value="${response_type}"></td>
						</tr>
						<tr>
							<th>Scope</th>
							<td><input type="text" style="width: 500px;" id="scope" name="scope" value="${scope}"></td>
						</tr>
						<tr>
							<th>State</th>
							<td><input type="text" style="width: 500px;" id="state" name="state" readonly="readonly" value="${state}"></td>
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