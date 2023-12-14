<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>

<div data-role="dialog" id="collab_task_detail" adata='view'>	

	<script id="template-popup-addTag" type="text/template">
		<div id="addTodo" class="mobile_popup_wrap" style="display:block;">
		  <div class="card_list_popup collabo_pop" style="width:320px; height:406px;">
		  	<div class="card_list_popup_cont">
		  	<div class="card_list_title">
        		<strong class="tit"><spring:message code='Cache.lbl_TagName'/></strong><!-- 태그명 -->
    		</div>
			<div class="pop_box pop_task">
				<ul class="pop_table mb0">
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_TagName'/></div><!-- 태그명 -->
				        <div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="tagName" class="w100"></div></div>
					</li>					
				</ul>
			</div>
				<!-- 버튼영역 -->
		        <div class="mobile_popup_btn">
		    		<a href="#" class="g_btn03 ui-link" id="saveTodo"><spring:message code='Cache.btn_save'/></a><!-- 저장 -->
		    		<a href="#" class="g_btn04 ui-link" id="closeTodo"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
		    	</div>
		  	</div>
		  </div>
		</div>
	</script>

	<script id="template-popup-addDetail" type="text/template">
		<div id="addTodo" class="mobile_popup_wrap" style="display:block;">
		  <div class="card_list_popup collabo_pop" style="width:320px; height:406px;">
		  	<div class="card_list_popup_cont">
			<div class="card_list_title">
        		<strong class="tit"><spring:message code='Cache.lbl_TaskRegist'/></strong><!-- 업무 등록 -->
    		</div>
		  	<div class="pop_box pop_task">
				<ul class="pop_table mb0">
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_TaskName'/></div><!-- 업무명 -->
				        <div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="taskName" class="w100" value="{=taskName}"></div></div>
					</li>					
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
						<div class="div_td" id="collab_task_period">
		          			<div class="dateSel type02">
								<div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="startDate" class="input_date" value="{=startDate}" autocomplete="off"></div><span>-</span><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="endDate" class="input_date" kind="twindate" value="{=endDate}" autocomplete="off"></div>
		          			</div>
						</div>
					</li>
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_State'/></div><!-- 상태 -->
						<div class="div_td">
		          			<div class="div_chk" id="taskStatus">
		            			<div class="ui-checkbox active"><label for="lbl_task_dtl1"><spring:message code='Cache.lbl_Ready'/></label><input type="checkbox" value="W" id="lbl_task_dtl1"></div><!-- 대기 -->
		            
		            			<div class="ui-checkbox"><label for="lbl_task_dtl2"><spring:message code='Cache.lbl_Progress'/></label><input type="checkbox" value="P" id="lbl_task_dtl2"></div><!-- 진행 -->
		            
		            			<div class="ui-checkbox"><label for="lbl_task_dtl3"><spring:message code='Cache.lbl_Hold'/></label><input type="checkbox" value="H" id="lbl_task_dtl3"></div><!-- 보류 -->
		            
		            			<div class="ui-checkbox"><label for="lbl_task_dtl4"><spring:message code='Cache.lbl_Completed'/></label><input type="checkbox" value="C" id="lbl_task_dtl4"></div><!-- 완료 -->                    
		          			</div>
						</div>
					</li>
					<li class="colspan">
		        		<div class="div_th"><spring:message code='Cache.lbl_TFProgressing'/></div><!-- 진행률 -->
		        		<div class="div_td">
							<select id="progRate" name="progRate">
								{=progRate}
							</select>
						</div>
						<div class="div_th wd"><spring:message code='Cache.lbl_Categories'/></div><!-- 범주 -->
						<div class="div_td">
							<div class="cusSelect02" id="label">
								<input type="txt" readonly="" class="selectValue">
								<span class="sleOpTitle"><span class="urgent"></span> <spring:message code='Cache.lbl_Urgency'/></span><!-- 긴급 -->
								<ul class="selectOpList">
									<li data-selvalue="E"><span class="urgent"></span> <spring:message code='Cache.lbl_Urgency'/></li><!-- 긴급 -->
									<li data-selvalue=""><spring:message code='Cache.lbl_noexists'/></li><!-- 없음 -->
								</ul>
							</div>
						</div>
					</li>
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_Description'/></div><!-- 설명 -->
						<div class="div_td">
							<textarea id="remark" cols="30" rows="10" class="ui-input-text ui-shadow-inset ui-body-inherit ui-corner-all ui-textinput-autogrow" style="height: 44px;">{=remark}</textarea>
						</div>
					</li>
				</ul>
			</div>
				<!-- 버튼영역 -->
		        <div class="mobile_popup_btn">
		    		<a href="#" class="g_btn03 ui-link" id="saveTodo"><spring:message code='Cache.btn_save'/></a><!-- 저장 -->
		    		<a href="#" class="g_btn04 ui-link" id="closeTodo"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
		    	</div>
		  	</div>
		  </div>
		</div>
	</script>	
	
	<header>
		<div class="sub_header">
			<div class="l_header w_header menu_header">
				<a href="javascript: mobile_comm_back();mobile_collab_project.refresh();" class="topH_close ui-link"><span class="Hicon"><spring:message code='Cache.btn_Close'/></span></a><!-- 닫기 -->
			</div>
			<div class="utill">
				<div class="dropMenu">
					<a class="topH_exmenu ui-link" id="mobile_collab_HdropMenu"><span class="Hicon"><spring:message code='Cache.btn_extmenu'/></span></a><!-- 확장메뉴 -->
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a class="btn ui-link" id="btnTag"><spring:message code='Cache.lbl_Tag'/></a></li> <!-- 태그 -->
							<li><a class="btn ui-link" id="btnInvite"><spring:message code='Cache.TodoMsgType_Invited'/></a></li> <!-- 초대 -->
							<li><a class="btn ui-link" id="btnDel"><spring:message code='Cache.btn_delete'/></a></li> <!-- 삭제 -->
							<li><a class="btn ui-link" id="btnDetail"><spring:message code='Cache.lbl_change'/></a></li> <!-- 변경 -->
							<!-- <li><a class="btn ui-link" id="btnExport"><spring:message code='Cache.lbl_SendOutWork'/></a></li> 업무내보내기 -->
							<li><a class="btn ui-link" id="btnReload"><spring:message code='Cache.btn_Refresh'/></a></li> <!-- 새로고침 -->
						</ul>
					</div>
				</div>
			</div>
		</div>
	</header>
    <div class="cont_wrap task_wrap">
        <div class="post_title comment">
            <p id="collab_task_post_location" class="post_location"></p>
            <h2 id="collab_task_tit" class="tit"></h2>
            <a id="collab_task_btnFav" class="btn_bookmark"><spring:message code='Cache.lbl_Bookmark'/></a> <!-- 북마크 -->
        </div>
        <div class="pop_box_area">
            <div class="pop_box">
                <ul class="pop_table">
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_charge'/></div><!-- 담당자 --> 
                        <div class="div_td" id="collab_task_user"></div>
                    </li>
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
                        <div class="div_td" id="collab_task_date">
                            <input type="text" id="collab_task_start_date" class="input_date" disabled="disabled">
                            ~
                            <input type="text" id="collab_task_end_date" class="input_date" disabled="disabled">
                        </div>
                    </li>
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_Project'/></div><!-- 프로젝트 -->
                        <div class="div_td">
                            <select class="selectType02 wd" id="collab_task_selProject">
                            </select>
                            <!-- 
                            <div class="control_btn">
                                <a class="btn_close"></a>
                                <a class="btn_add"></a>
                            </div>
                             -->
                        </div>
                    </li>
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_Tag'/></div><!-- 태그 -->
                        <div class="div_td">
                        	<ul class="clearFloat fileUpview tagview" id="tagList" style="height: auto;">
							</ul>
                        </div>
                    </li>
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_File'/></div><!-- file -->
                        <div class="div_td">
                        	<ul class="clearFloat fileUpview" id="fileList">
							</ul>
                        </div>
                    </li>
                    <li>
                        <div class="div_th"><spring:message code='Cache.lbl_Categories'/></div><!-- 범주 -->
                        <div class="div_td">
                            <div class="cusSelect02" id="label">
                                <input id="collab_task_selCategory" type="txt" readonly="" >
                            </div>
                        </div>
                    </li>
                </ul>
                <p class="pop_txt" id="collab_task_remark"></p>
            </div>
            <div class="pop_box02" id="collab_task_subTask">
                <div class="pop_titBox">
                    <strong class="pop_title_s"><spring:message code='Cache.lbl_Subtask'/></strong><!-- 하위업무 -->
                    <div class="control_btn">
                        <a class="btn_close" id="delSubTask"></a>
                        <a class="btn_add" id="addSubTask"></a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 댓글영역 -->
        <div covi-mo-comment></div>
        <!-- //댓글영역 -->
    </div>
</div>