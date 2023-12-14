<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_withdrawal_page">	
	
	<header data-role="header" id="community_withdrawal_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back"><span class="Hicon">이전페이지</span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.BizSection_Community' /> <spring:message code='Cache.lbl_WithdrawalOfApp' /></a> <!-- 커뮤니티 탈퇴신청 -->
				</div>
			</div>
			<div class="utill">
				<a id="community_withdrawal_btnAdd"  href="javascript: mobile_community_withdrawCommunity();" class="topH_save"><span class="Hicon">등록</span></a>
			</div>
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="community_withdrawal_content">
		<p id="community_withdrawal_cuName" class="list_tit"></p>
	
      <div class="input_data">
			<dl>
				<dt><spring:message code='Cache.lbl_FirstName' /></dt> <!-- 이름 -->
				<dd id="community_withdrawal_userName"></dd>
			</dl>
			<dl>
				<dt><spring:message code='Cache.btn_Mail' /></dt> <!-- 메일 -->
				<dd id="community_withdrawal_userMail"></dd>
			</dl>
			<!-- <dl>
				<dt>별명</dt>
					<dd id="community_withdrawal_userNickName">홍두깨</dd>
			</dl> -->
			<dl>
				<dt><spring:message code='Cache.lbl_Join_Day' /></dt> <!-- 가입일 -->
    			<dd id="community_withdrawal_userRegistDate"></dd>
			</dl>
			<dl>
				<dt><spring:message code='Cache.lbl_User_Grade' /></dt> <!-- 회원등급 -->
				<dd id="community_withdrawal_userLevel"></dd>
			</dl>
		</div>
		<div class="input_data">
  			<dl>
    			<dt><spring:message code='Cache.lbl_Withdrawal_Date' /></dt> <!-- 탈퇴일 -->
    			<dd id="community_withdrawal_userWithdrawDate"></dd>
  			</dl>
			<dl>
    			<dt><spring:message code='Cache.lbl_Withdrawal_Class' /></dt> <!-- 탈퇴구분 -->
				<dd><spring:message code='Cache.lbl_community_volunteer' /></dd> <!-- 자원 -->
			</dl>
		</div>
		<textarea id="community_withdrawal_userReason" name="name" class="full" placeholder="<spring:message code='Cache.msg_community_enterReason' />"></textarea> <!-- 탈퇴사유를 입력하세요. -->
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>