<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> 
</head>

<style>
	.acstatus_wrap { margin-bottom: 0px; }  
	.acstatus_wrap td { height: 27px; }
	.acstatus_wrap tr:first-child td:first-child { vertical-align: middle; }
    .tit { text-align: center; width: 100px; background-color: #f4fdff; }
</style>
<jsp:useBean id="now" class="java.util.Date" />
<c:set var="sysYear"><fmt:formatDate value="${now}" pattern="yyyy" /></c:set>
<body>

	<table id="investArea" class="acstatus_wrap" style="display: none;">
		<thead>
			<tr>
				<th style="width: 120px;" rowspan="2">항목 </th>			
				<th colspan="2" rowspan="2"style="width: 200px">대상</th>
				<th colspan="2">지급 금액</th>
				<th rowspan="2">비고</th>
			</tr>				
			<tr>
				<th>2년 미만</th>
				<th>2년 이상</th>
			</tr>				
		</thead>
		<tbody>
			<tr>
				<th rowspan="3">결혼</td>
				<td colspan="2">본인</td>
				<td> <fmt:formatNumber value="${info.marrigeMyself_etc}"/></td>
				<td> <fmt:formatNumber value="${info.marrigeMyself}"/></td>
				<td></td>				
			</tr>
			<tr>				
				<td colspan="2">자녀</td>
				<td> <fmt:formatNumber value="${info.marrigeChildren_etc}"/></td>
				<td> <fmt:formatNumber value="${info.marrigeChildren}"/></td>						
				<td></td>
			</tr>
			<tr>				
				<td colspan="2">본인 친형제, 자매</td>
				<td> <fmt:formatNumber value="${info.marrigeSibiling_etc}"/></td>				
				<td> <fmt:formatNumber value="${info.marrigeSibiling}"/></td>				
				<td>배우자 친형제, 자매 제외</td>				
			</tr>		
				
			<tr>
				<th rowspan="2">					
					칠순,
					<br>팔순, 
					<br>구순
				</td>
				<td colspan="2">본인 부모</td>
				<td> <fmt:formatNumber value="${info.parentsMyself_etc}"/></td>
				<td> <fmt:formatNumber value="${info.parentsMyself}"/></td>				
				<td rowspan="3">
					주민등록등본<br>
					(가족관계증명서)
				</td>				
			</tr>
			<tr>				
				<td colspan="2">배우자 부모</td>
				<td> <fmt:formatNumber value="${info.parentsSpouse_etc}"/></td>
				<td> <fmt:formatNumber value="${info.parentsSpouse}"/></td>
			</tr>
			
			<tr>
				<th>출산</td>
				<td colspan="2">자녀 출산</td>
				<td> <fmt:formatNumber value="${info.childbirthMyself_etc}"/></td>				
				<td> <fmt:formatNumber value="${info.childbirthMyself}"/></td>				
			</tr>
			
			<tr>
				<th rowspan="6">조위</td>
				<td colspan="2">본인</td>
				<td> <fmt:formatNumber value="${info.condolenceMyself_etc}"/></td>
				<td> <fmt:formatNumber value="${info.condolenceMyself}"/></td>
				<td rowspan="4">
					사망을 확인할 수
					<br>있는 증빙
					<br>(진단서, 조전, E-mail 등)
				</td>				
			</tr>
			<tr>				
				<td colspan="2">배우자</td>
				<td> <fmt:formatNumber value="${info.condolenceSpouse_etc}"/></td>			
				<td> <fmt:formatNumber value="${info.condolenceSpouse}"/></td>			
			</tr>
			<tr>				
				<td colspan="2">자녀</td> 
				<td> <fmt:formatNumber value="${info.condolenceChildren_etc}"/></td>		
				<td> <fmt:formatNumber value="${info.condolenceChildren}"/></td>		
			</tr>
			<tr>				
				<td rowspan="2">본인 및 <br>배우자</td>
				<td>부모</td>
				<td> <fmt:formatNumber value="${info.condolenceParents_etc}"/></td>
				<td> <fmt:formatNumber value="${info.condolenceParents}"/></td>
			</tr>
			<tr>
				<td>형제,자매</td>
				<td> <fmt:formatNumber value="${info.condolenceSibling_etc}"/></td>
				<td> <fmt:formatNumber value="${info.condolenceSibling}"/></td>
				<td></td>
			</tr>
			<tr>				
				<td>본인</td>
				<td>(외)조부모</td>
				<td> <fmt:formatNumber value="${info.condolenceGrand_etc}"/></td>
				<td> <fmt:formatNumber value="${info.condolenceGrand}"/></td>
				<td></td>				
			</tr>
		</tbody>
	</table>
	
	<img id="investImg" src="">
</body>

<script>
	$(function() { });
	
	window.onload = function() {
		var eAccInvest = Common.getBaseConfig("eAccInvest");
		var eAccInvestUrl  = Common.getBaseConfig("eAccInvestUrl");
		
		if(eAccInvest == "Y") {
			$("#investArea").hide();
			$("#investImg").attr("src", eAccInvestUrl);
		} else {
			$("#investArea").show();
		}
	}
</script>