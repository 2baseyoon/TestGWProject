<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<style>
.serviceError {
	margin: -180px 0 0 -370px;
	width: 670px;
	height: 360px;
}
</style>
<div>
	<section class="errorContainer">
			<div class="errorCont serviceError">
				<h1>(Message not found) 해당 게시물을 찾을 수 없습니다.</h1>
				<div class="bottomCont">
					<p class="txt">
						<span class="col_red"> 
						게시글의 삭제, 이동, 만료, 잠금 등의 사유로 조회할 수 없는 상태가 발생할 수도 있습니다.
						<br /> 
						필요 시 작성자 또는 운영자에게 문의하십시요.
					</p>	
					<p class="txt02 mt20">
						Messages may be unretrieved due to reasons such as deletion, movement, expiration, or locking.
						<br />
						If necessary, contact the author or operator.
					</p>
					<p class="errorBtnBox mt15">
						<a class="btnTypeDefault " onclick="javascript:history.go(-2);">이전페이지</a>
					</p>				
				</div>
			</div>	
	</section>
</div>