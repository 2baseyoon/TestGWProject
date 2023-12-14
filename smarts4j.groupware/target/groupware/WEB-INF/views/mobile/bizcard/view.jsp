<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="bizcard_view_page" data-close-btn="none">
	
	<header data-role="header" id="bizcard_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link gnb">
					<a id="bizcard_view_title"  href="#" class="pg_tit"><spring:message code='Cache.lbl_BizCard' /> <spring:message code='Cache.lbl_DetailView' /></a> <!-- 명함 상세보기 -->
				</div>
			</div>
			<div class="utill">
				<div class="dropMenu">
					<a href="#" class="topH_exmenu" onclick="javascript: mobile_bizcard_showORhide(this);"><span class="Hicon">확장메뉴</span></a> <!-- 메뉴 -->
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a id="bizcard_view_modify" href="#" class="btn" style="display: none;"><spring:message code='Cache.btn_Modify' /></a></li> <!-- 수정 -->
							<li><a id="bizcard_view_delete" href="#" class="btn" style="display: none;"><spring:message code='Cache.btn_delete' /></a></li> <!-- 삭제 -->
						</ul>
					</div>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="bizcard_view_content">
		
		<!-- 명함 연락처 -->
		<div id="bizcard_view_divperson" class="bizcard_profile" style="display: none;">
			<span id="bizcard_view_personimg" class="photo" style="background-image:url('../../resources/images/user_01.jpg');overflow: hidden;"></span>
			<div id="bizcard_view_personprofile" class="profile_name">
			</div>
			<div class="contact">
				<dl id="bizcard_view_personemail">
					<dt><i class="ico_mail"></i><br><spring:message code='Cache.lbl_Email2' /></dt> <!-- 이메일 -->
				</dl>
				<dl id="bizcard_view_personphonemobile" >
					<dt><i class="ico_mobile"></i><br><spring:message code='Cache.lbl_MobilePhone' /></dt> <!-- 휴대폰 -->
				</dl>				
				<dl id="bizcard_view_personphoneoffice" >
					<dt><i class="ico_call"></i><br><spring:message code='Cache.lbl_Office_Line' /></dt> <!-- 사무실전화 -->
				</dl>
				<dl id="bizcard_view_personphonefax" >
					<dt><i class="ico_fax"></i><br><spring:message code='Cache.lbl_Office_Fax' /></dt> <!-- 사무실팩스 -->
				</dl>
				<dl id="bizcard_view_personphoneetc" >
					<dt><i class="ico_call"></i><br><spring:message code='Cache.lbl_EtcPhone' /></dt> <!-- 기타전화 -->
				</dl>
				<dl id="bizcard_view_personphonehome" >
					<dt><i class="ico_call"></i><br><spring:message code='Cache.lbl_HomePhone' /></dt> <!-- 자택전화 -->
				</dl>
				<dl id="bizcard_view_personphonedirect" >
					<dt><i class="ico_call"></i><br><spring:message code='Cache.lbl_DirectPhone' /></dt> <!-- 직접입력 -->
				</dl>
				
				<dl id="bizcard_view_personanniversary" style="display:none;" >
					<dt><i class="ico_ann"></i><br><spring:message code='Cache.lbl_AnniversarySchedule' /></dt> <!-- 기념일 -->
				</dl>
				<dl id="bizcard_view_personmessenger" >
					<dt><i class="ico_messenger"></i><br><spring:message code='Cache.BizSection_Messenger' /></dt> <!-- 메신저 -->
				</dl>
			</div>
			<div id="bizcard_view_personmemo"  class="input_text">
				<p style="overflow-x: scroll; min-height: 30px;"><spring:message code='Cache.msg_bizcard_showMemo' /></p> <!-- 메모가 표시됩니다. -->
			</div>
		</div>
		
		<!-- 업체 연락처 -->
		<div id="bizcard_view_divcompany" class="bizcard_profile" style="display: none;">
			<span id="bizcard_view_companyimg" class="photo company" style="background-image:url('../../resources/images/common/noGroupImg.png')"></span>
			<div id="bizcard_view_companyprofile" class="profile_name">
			</div>
			<div class="contact" id="bizcard_view_groupMemberList">
			</div>
			
		</div>
		
		
		
	</div>
	
</div>