<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div id="collab_templateAdd_popup" class="mobile_popup_wrap" style="display:block;">
	<div class="card_list_popup collabo_pop" style="width:316px; height:280px;">
	  	<div class="card_list_popup_cont">
	  		<div class="card_list_title">
	        	<strong class="tit"><spring:message code='Cache.Collab_Save_Templ'/></strong><!-- 템플릿으로 저장 -->
	    	</div>
		  	<div class="pop_box pop_task">
				<ul class="pop_table mb0">
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_JvCate'/></div><!-- 카테고리 -->
				        <div class="div_td">
							<select id="collab_templateAdd_tmplKind"></select>
				        </div>
					</li>
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_templateName'/></div><!-- 템플릿명 -->
				        <div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="collab_templateAdd_requestTitle" class="w100"></div></div>
					</li>			
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_RequestContent'/></div><!-- 요청내용 -->
						<div class="div_td">
							<textarea id="collab_templateAdd_requestRemark" cols="30" rows="10" class="ui-input-text ui-shadow-inset ui-body-inherit ui-corner-all ui-textinput-autogrow" style="height: 44px;"></textarea>
						</div>
					</li>
				</ul>
			</div>
			<!-- 버튼영역 -->
	        <div class="mobile_popup_btn">
	    		<a class="g_btn03 ui-link" id="collab_templateAdd_add"><spring:message code='Cache.lbl_ApprovalRequest'/></a><!-- 승인요청 -->
	    		<a class="g_btn04 ui-link" id="collab_templateAdd_close"><spring:message code='Cache.btn_Cancel'/></a><!-- 취소 -->
	    	</div>
	  	</div>
	</div>
</div>
