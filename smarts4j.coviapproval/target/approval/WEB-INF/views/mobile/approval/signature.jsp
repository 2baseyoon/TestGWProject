<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>


<div data-role="page" id="approval_signature_page">

	<header data-role="header"  id="approval_signature_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span>닫기</span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit ui-link"><spring:message code="Cache.lbl_apv_Regisign"/><!-- 서명등록 --></a>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" 	id="approval_signature_content">
		<div class="signature_wrap">
			<div class="signature_En">				
				<a onclick="mobile_signature_showSignature();" class="btn_signature">
				<i class="ico"></i><span><spring:message code="Cache.btn_addSignature"/><!-- 서명추가 --></span></a>
			</div>
			<!-- 서명 등록 상세 작성창 펼침 ui -->
			<div id="divSignature" class="signature_EnDetail" style="display: none;">
				<div class="clearSign" style="display:none;">
					<button class="clearButton"><a href="#clear"><spring:message code="Cache.btn_resetSignature"/><!-- 서명추가 --></a></button>
				</div>
				<div id="signbox" class="signaturebox">
					<div id="divCanvas" class="sig" >
						<canvas id="signpad" class="pad" ></canvas>
						<input type="hidden" name="output" class="output" value="">
						<img id="rstImg" style="display:none;"/>
					</div>
				</div>

				<div class="btn_wrap">
					<a href="javascript:mobile_signature_uploadSignature();" class="btn_approval ui-link"><spring:message code="Cache.btn_register"/><!-- 등록 --></a>
					<a href="javascript:mobile_signature_closeSign();" class="btn_return ui-link"><spring:message code="Cache.btn_Cancel"/><!-- 취소 --></a>
				</div>
			</div>

			<div id="signature_view_wrap">
				</div>
			</div>
		</div>
	</div>
</div>

	<!-- 에디터 스크립트 -->
	<script type="text/javascript">
	
	
	</script>