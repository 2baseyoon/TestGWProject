<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>


<div id="limitChangeArea" >
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>			<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/></th>
				<td>
					<div class="box">
						<label name="labelLimitChange" datafield="CardNoEncrypt"></label>
					</div>
				</td>		<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<label name="labelLimitChange" datafield="ExpirationDate"></label>
					</div>
				</td>
			</tr>
			<tr>			<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<label name="labelLimitChange" datafield="CurrentAmount" tag="Amt"></label>
					</div>
				</td>		<!-- 요청구분 -->
				<th><spring:message code="Cache.ACC_lbl_requestType"/></th>
				<td>
					<div class="box" >
						<label name="labelLimitChange" datafield="LimitTypeName"></label>
					</div>
				</td>
			</tr>
			<tr>			<!-- 변경한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_changeLimitAmount"/></th>
				<td colspan="3">
					<div class="box">
						<label name="labelLimitChange" datafield="ApplicationAmount" tag="Amt"></label>
					</div>
				</td>
			</tr>
			<tr id="chgExpDateArea" style="display:none">	<!-- 변경만료일 -->
				<th><spring:message code="Cache.ACC_lbl_changeExpDate"/></th>
				<td>
					<div class="box">
						<label name="labelLimitChange" datafield="ChangeExpirationDate"></label>
					</div>
				</td>
			</tr>
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="height:135px">
						<label name="labelLimitChange" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<!-- ============================================================================ -->
<div id="cardReissueArea" style="display:none">
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>			<!-- 재발급 구분 -->
				<th><spring:message code="Cache.ACC_lbl_cardReissueType"/></th>
				<td>
					<div class="box">
						<label name="labelCardReissue" datafield="ReissuanceTypeName"></label>
					</div>
				</td>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/></th>
				<td>
					<div class="box">
						<label name="labelCardReissue" datafield="CardNoEncrypt"></label>
					</div>
				</td>
			</tr>
			<tr>			<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<label name="labelCardReissue" datafield="ExpirationDate"></label>
					</div>
				</td>		<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<label name="labelCardReissue" datafield="CurrentAmount" tag="Amt"></label>
					</div>
				</td>
			</tr>
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="height:135px">
						<label name="labelCardReissue" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>

<!-- ============================================================================ -->
<div id="cardCloseArea" style="display:none">
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/></th>
				<td colspan="3">
					<div class="box">
						<label name="labelCardClose" datafield="CardNoEncrypt"></label>
					</div>
				</td>
			</tr>
			<tr>		<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<label name="labelCardClose" datafield="ExpirationDate"></label>
					</div>
				</td>	<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<label name="labelCardClose" datafield="CurrentAmount" tag="Amt"></label>
					</div>
				</td>
			</tr>
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="height:135px">
						<label name="labelCardClose" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<!-- ============================================================================ -->
<div id="publidCardArea" style="display:none">
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>		<!-- 시작일 -->
				<th><spring:message code="Cache.ACC_lbl_startDate" /></th>
				<td>
					<div class="box">
						<label name="labelPublicCard" datafield="ApplicationStartDate"></label>
					</div>
				</td>	<!-- 종료일 -->
				<th><spring:message code="Cache.ACC_lbl_endDate" /></th>
				<td>
					<div class="box">
						<label name="labelPublicCard" datafield="ApplicationFinishDate"></label>
				</td>
			</tr>
			<tr>		<!-- 신청금액 -->
				<th><spring:message code="Cache.ACC_lbl_applicationAmt" /></th>
				<td>
					<div class="box">
						<label name="labelPublicCard" datafield="ApplicationAmount" tag="Amt"></label>
					</div>
				</td>
			</tr>
			<tr style="height: 150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason" /></th>
				<td colspan="3">
					<div class="box" style="height:135px">
						<label name="labelPublicCard" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<!-- ============================================================================ -->
<div id="prCardArea" style="display:none">
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/></th>
				<td>
					<div class="box">
						<label name="labelPrCard" datafield="CardNoEncrypt"></label>
					</div>
				</td>	<!-- 카드회사 -->
				<th><spring:message code="Cache.ACC_lbl_cardCompany"/></th>
				<td>
					<div class="box">
						<label name="labelPrCard" datafield="CardCompanyName"></label>
					</div>
				</td>
			</tr>
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" >
						<label name="labelPrCard" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<!-- ============================================================================ -->
<div id="newCardArea" style="display:none">
	<table class="tableTypeRow">
		<colgroup> 
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/></th>
				<td>
					<div class="box">
						<label name="labelNewCard" datafield="CardNoEncrypt"></label>
					</div>
				</td>	<!-- 카드회사 -->
				<th><spring:message code="Cache.ACC_lbl_cardCompany"/></th>
				<td>
					<div class="box">
						<label name="labelNewCard" datafield="CardCompanyName"></label>
					</div>
				</td>
			</tr>
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" >
						<label name="labelNewCard" datafield="ApplicationReason"></label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
