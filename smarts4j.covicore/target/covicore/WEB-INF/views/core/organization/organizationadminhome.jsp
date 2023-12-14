<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	/* 테이블 디자인 */
	.linePlus tr:first-child td, .linePlus tr:first-child th {border-top:1px solid #c3d7df;}
	.linePlus tr:last-child td, .linePlus tr:last-child th {border-bottom:1px solid #c3d7df !important;}
	.linePlus td,  .linePlus th {border-right:1px solid #c3d7df;}
	.linePlus td:first-child, .linePlus th:first-child {border-left:1px solid #c3d7df;}
	.tableStyle { 
		width:100%;
		table-layout:fixed;
		z-index:50;
		word-break:break-all; 
	}
	.tableStyle thead th , .tableStyle tbody th  { 
		height:40px;
		border-bottom:1px solid #d2d7de;
		font-size:13px;
		font-weight:bold;
		color:#454545;
		background:#f1f6f9;
	}
	.tableStyle thead td , .tableStyle tbody td { 
		color:#696969;
		border-bottom:1px solid #c3d7df;
		padding:6px;
		height:20px;
	}
	.tableStyle.hover tbody tr:hover td { 
		background:#f7f7f7; cursor:pointer;
	}
	.tableStyle thead tr:last-child td , .tableStyle thead tr:last-child th {
		border-bottom:1px solid #eaecef;
	}
	.tableStyle tbody tr:last-child td , .tableStyle tbody tr:last-child th {
		border-bottom:1px solid #eaecef;
	}
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_144"/></span>
</h3>
<form>
	<div style="width:100%;min-height: 500px">
		<table class="tableStyle linePlus">
			<colgroup>	
				<col style="width: 20%">
				<col style="width: 80%">
			</colgroup>
			<tr>
				<th><spring:message code="Cache.CN_191"/></th>
				<td>회사별로 부서/사용자를 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.CN_146"/></th>
				<td>그룹을 추가하거나 삭제할 수 있습니다.</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.CN_188"/></th>
				<td>회사별로 직책을 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.CN_189"/></th>
				<td>회사별로 직위를 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.CN_190"/></th>
				<td>회사별로 직급을 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr>
<%-- 			<tr>
				<th><spring:message code="Cache.CN_192"/></th>
				<td>지역(사업장)을 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr> --%>
			<tr>
				<th><spring:message code="Cache.CN_193"/></th>
				<td>겸직을 추가/수정하거나 삭제할 수 있습니다.</td>
			</tr>
		</table>
	</div>
</form>