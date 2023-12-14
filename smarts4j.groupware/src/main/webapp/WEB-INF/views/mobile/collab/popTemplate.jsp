<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 템플릿 선택 -->
<div data-role="dialog" id="collab_templatePop" adata='view'>
	<header>
		<div class="sub_header">
			<div class="l_header">
				<a id="collab_templatePop_btnClose" class="topH_close"><span class="Hicon"><spring:message code='Cache.btn_Close'/></span></a><!-- 닫기 -->
				<div class="menu_link gnb">
				<span id="ccollab_templatePop_btnSave" class="topH_tit"><spring:message code='Cache.lbl_TemplateSelect'/></span><!-- 템플릿 선택 -->
				</div>
			</div>
		</div>
	</header>
	
	
	<div class="cont_wrap templete">
		<div class="templete_top" id="collab_templatePop_kind_container">
			<div class="icon icon01">
			</div>
			<div class="icon icon02">
			</div>
			<div class="icon icon03">
			</div>
			<div class="icon icon04">
			</div>
			<div class="icon icon05">
			</div>
			<div class="icon icon06">
			</div>
			<div class="icon icon07">
			</div>
		</div>
		<div class="row tempelete_list">
			<ul class="cards">
				<!-- 
				<li>
					<div class="templete_img icon01">
					</div>
					<div class="templete_text">
						<h3>제품 프로젝트 계획</h3>
						<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				<li>
					<div class="templete_img icon02">
					</div>
					<div class="templete_text">
					<h3>제품 프로젝트 계획</h3>
					<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				<li>
					<div class="templete_img icon03">
					</div>
					<div class="templete_text">
					<h3>제품 런칭</h3>
					<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				<li>
					<div class="templete_img icon04">
					</div>
					<div class="templete_text">
					<h3>제품 로드맵</h3>
					<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				<li>
					<div class="templete_img icon01">
					</div>
					<div class="templete_text">
					<h3>고객 피드백</h3>
					<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				<li>
					<div class="templete_img icon03">
					</div>
					<div class="templete_text">
					<h3>제품 프로젝트 계획</h3>
					<p><span class="cate">프로젝트 관리</span><span class="favo">12</span></p>
					</div>
				</li>
				-->
			</ul>
		</div>
	</div>
	
	<div id="collab_projectPop" class="mobile_popup_wrap" style="display:none;">
		<div class="card_list_popup collabo_pop" style="width:316px; height:300px;">
		  	<div class="card_list_popup_cont">
		  		<div class="card_list_title">
		        	<strong class="tit"><spring:message code='Cache.lbl_AddProject'/></strong><!-- 프로젝트추가 -->
		    	</div>
			  	<div class="pop_box pop_task">
					<ul class="pop_table mb0">
						<li>
							<div class="div_th"><spring:message code='Cache.lbl_templateName'/></div><!-- 템플릿명 -->
					        <div class="div_td">
								<span id="collab_projectPop_tmplName"></span>
					        </div>
						</li>
						<li>
							<div class="div_th"><spring:message code='Cache.ACC_lbl_projectName'/></div><!-- 프로젝트명 -->
					        <div class="div_td">
								<input type="text" id="collab_projectPop_prjName" value="" class="w100">
					        </div>
						</li>
						<li>
							<div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
					        <div class="div_td" id="collab_projectPop_period">
					        	<input type="text" name="startDate" class="input_date" readonly="true"><span>-</span><input type="text" name="endDate" class="input_date" readonly="true">
					        </div>
						</li>			
						<li>
							<div class="div_th"><spring:message code='Cache.lbl_State'/></div><!-- 상태 -->
							<div class="div_td">
								<div class="div_chk" id="collab_projectPop_taskStatus">
									<label for="chk1"><span class="s_check"></span><spring:message code='Cache.lbl_Ready'/></label><input type="checkbox" value="W" id="chk1"><!-- 대기 -->
									<label for="chk2"><span class="s_check"></span><spring:message code='Cache.lbl_Progress'/></label><input type="checkbox" value="P" id="chk2"><!-- 진행 -->
									<label for="chk3"><span class="s_check"></span><spring:message code='Cache.lbl_Hold'/></label><input type="checkbox" value="H" id="chk3"><!-- 보류 -->
									<label for="chk4"><span class="s_check"></span><spring:message code='Cache.lbl_Completed'/></label><input type="checkbox" value="C" id="chk4"><!-- 완료 -->
								</div>
							</div>
						</li>
					</ul>
				</div>
				<!-- 버튼영역 -->
		        <div class="mobile_popup_btn">
		    		<a class="g_btn03 ui-link" id="collab_projectPop_add"><spring:message code='Cache.lbl_AddProject'/></a><!-- 프로젝트추가 -->
		    		<a class="g_btn04 ui-link" id="collab_projectPop_close"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
		    	</div>
		  	</div>
		</div>
	</div>
</div>