<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<div>
	<section class="errorContainer">
			<div class="errorCont serviceError">
				<h1>(No permission) 요청한 작업에 대한 권한이 없습니다.</h1>
				<div class="bottomCont">
					<p class="txt">
						<span class="col_red"> 
						요청한 작업에 대해 권한을 부여받지 못했습니다.
						<br /> 
						권한 필요 시 운영자(또는 관리자)에게 권한을 요청하십시요.
					</p>	
					<p class="txt02 mt20">
						Authorization was not granted for the requested operation.
						<br />
						If permission is required, ask the operator (or manager) for permission.
					</p>
					<p class="errorBtnBox mt15">
						<a class="btnTypeDefault " onclick="javascript:history.go(-2);">이전페이지</a>
					</p>				
				</div>
			</div>	
	</section>
</div>							
