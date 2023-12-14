<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:416px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="baseCodeViewSearchArea">	
		<div class="popContent" style="position:relative;">
			<div class="apprvalBottomCont">				
				<div class="appRelBox">
					<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
						<div style="width:100%;">
							${content}
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>