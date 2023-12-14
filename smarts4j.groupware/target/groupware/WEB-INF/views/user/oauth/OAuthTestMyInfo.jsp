<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<script  type="text/javascript">
	// 팝업 닫기
	function closeLayer() {
		window.close();
	} 
	
</script>
<form id="frm">
	<div class="layer_divpop ui-draggable">
		<div class="divpop_contents">
		    <div class="pop_header" id="testpopup_ph">
		      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">OAuth</span></h4>
		    </div>	
			<div class="popBox" style="overflow-x: hidden;overflow-y: scroll;height: 280px;">
				<table class="tableStyle">
					<colgroup>
						<col style="width:100px;">
						<col style="width:*">
					</colgroup>
					<thead>
						<tr>
							<th>소속</th>
							<td>${groupName}</td>
						</tr>
						<tr>
							<th>직급</th>
							<td>${positionName}</td>
						</tr>
						<tr>
							<th>사원번호</th>
							<td>${empNo}</td>
						</tr>
						<tr>
							<th>이름</th>
							<td>${userName}</td>
						</tr>
						<tr>
							<th>Login ID</th>
							<td>${userId}</td>
						</tr>
						<tr>
							<th>Access Token</th>
							<td>${accessToken}</td>
						</tr>
					</thead>
				</table>
			</div>
			<div align="center" style="padding-top: 10px;padding-bottom: 20px">
				<input type="button" value="Close" onclick="closeLayer();"  class="gryBtn" />
			</div>
		</div>
	</div>
</form>