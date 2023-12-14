<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>

<style>
.gannt-container {
    min-width: 1000px;
    max-width: 1200px;
    margin: 1em auto;
}
.simtask_box.pos { transform:translateY(0) }
.simtask_box { min-height:174px; height:auto; bottom:0; transform:translateY(100%); transition:transform 0.5s }
.simtask_box .sim_info { display:flex; flex-wrap:wrap; height:auto; }
.simtask_box .sim_info .sim_l { flex:1 0 80px; width:auto }
.simtask_box .sim_info .sim_r { flex:0 0 auto; width:auto }
.simtask_box .sim_title #sectionSelSpan {display:inline-block;line-height:27px;padding-right:10px;font-size:0.92rem;font-weight:bold;vertical-align:middle;}
</style>

<!-- task연결 팝업 -->
<script id="gantLink-popup" type="text/template">
<div id="gantLinkDialog" class="mobile_popup_wrap" style="display:block;">
	<div class="card_list_popup collabo_pop" style="width:320px; height:200px;">
		<div class="card_list_popup_cont">
			<div class="card_list_title">
        		<strong class="tit"><spring:message code='Cache.lbl_task_task'/><spring:message code='Cache.btn_Link'/></strong> <!-- 업무연결 -->
    		</div>
		  	<div class="pop_box pop_task">
				<table class="collabo_table type02" cellpadding="0" cellspacing="0">
						<colgroup>
							<col width="60">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th><spring:message code='Cache.lbl_TaskName'/></th> <!-- 업무명 -->
								<td>
									<select  id="linkTaskSeq" class="selectType02 w100">
									</select>
								</td>
							</tr>
						</tbody>
				</table>
			</div>
			<!-- 버튼영역 -->
		    <div class="mobile_popup_btn">
		    	<a href="#" class="g_btn04 ui-link" id="closeTodo"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
		    </div>
		</div>
	</div>
</div>
</script>

<div data-role="page" id="collab_main_page" class="mob_rw">
	<header data-role="header" >
		<div class="sub_header">
			<div class="l_header w_header">
				<a href="javascript:mobile_comm_TopMenuClick('collab_leftmenu_tree');" class="topH_menu"><span><spring:message code='Cache.lbl_FullMenu'/></span></a> <!-- 전체메뉴 -->
				<div class="menu_link gnb">
					<a href="javascript:mobile_comm_go('/groupware/mobile/collab/menulist.do','Y');" class="pg_tit pg_tit2 ui-link">
						<span class="Tit_ellip"><span id="collab_main_header_name"><spring:message code='Cache.lbl_Collab'/></span></span>
						<i class="arr_menu"></i>
					</a>
					<jsp:include page="/WEB-INF/views/mobile/collab/collabLeft.jsp"></jsp:include>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('collab_leftmenu_tree',true);return false;" style="display: none;"></div>
				</div>
			</div>
			<div class="utill">
				<a href="javascript:mobile_comm_opensearch();" class="btn_search ui-link"><span>검색</span></a>
				<div class="dropMenu">
					<a class="topH_exmenu ui-link" id="collab_main_btnExmenu" onclick="javascript: mobile_collab_showORhide(this);"><span class="Hicon"><spring:message code='Cache.btn_extmenu'/></span></a> <!-- 확장메뉴 -->
					<div class="exmenu_layer">
						<ul id="collab_main_ulBtnArea" class="exmenu_list">
							<li data-only="P">
								<a class="btn" id="btnCopy"><spring:message code='Cache.ACC_btn_copy' /></a><!-- 복사 -->
							</li>
							<li data-only="P">
								<a class="btn" id="btnDel"><spring:message code='Cache.lbl_delete' /></a><!--삭제 -->
							</li>
							<li data-only="P">
								<a class="btn" id="btnDetail"><spring:message code='Cache.lbl_Edit' /></a><!--수정 -->
							</li>
							<li data-only="P">
								<a class="btn" id="btnSaveTempl"><spring:message code='Cache.Collab_Save_Templ' /></a><!--탬플릿으로 저장 -->
							</li>
							<li>
								<a class="btn" id="btnAddSection"><spring:message code='Cache.btn_AddSection' /></a><!-- 섹션 추가 -->
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	  	<div class="ly_search ly_change" tabindex="0">
			<a href="javascript: mobile_comm_closesearch(); mobile_collab_closesearch();" class="topH_back"><span><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_board_clicksearch" name="" value="" placeholder="<spring:message code='Cache.msg_doc_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_collab_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /><!-- 제목, 내용으로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_collab_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del"></a>
		</div>
    </header>
    	
	<div data-role="content" class="cont_wrap" id="collab_main_content">
	    <div class="Project_list">
		    <ul>
			    <li class="bg01">
				    <a class="">
					    <span class="txt"><spring:message code='Cache.lbl_ProjectProgress2'/></span> <!-- 프로젝트<br />진행률 -->
					    <div class="Project_cycleCont">
						    <div class="cycleBg">
							    <div class="pie"></div>
							    <div class="cycleTxt">
								    <div class="inner">
									    <strong class="cNum"><span id="collab_main_progRate"></span><span>%</span></strong>
								    </div>
							    </div>
						    </div>
						    <div id="slice" class="gt50">
							    <div class="pie"></div>
							    <div class="pie fill"></div>
						    </div>
					    </div>
				    </a>
			    </li>
			    <li class="bg02">
				    <a class="">
					    <span class="txt"><spring:message code='Cache.lbl_Progress'/></span><!-- 진행 -->
					    <span class="num_case"><strong class="num"><span id="collab_main_procCnt"></span></strong> / <span id="collab_main_proctotCnt"></span><spring:message code='Cache.lbl_DocCount'/></span><!-- 건 -->
				    </a>
			    </li>
			    <li class="bg03">
				    <a class="">
					    <span class="txt"><spring:message code='Cache.lbl_Delay'/></span><!-- 지연 -->
					    <strong class="num"><span id="collab_main_delayCnt"></span></strong>
				    </a>
			    </li>
			    <li class="bg04">
				    <a class="">
					    <span class="txt"><spring:message code='Cache.lbl_Important'/></span><!-- 중요 -->
					    <strong class="num"><span id="collab_main_impCnt"></span></strong>
				    </a>
			    </li>
			    <li class="bg05">
				    <a class="">
					    <span class="txt"><spring:message code='Cache.lbl_Completed'/></span><!-- 완료 -->
					    <strong class="num"><span id="collab_main_CompCnt"></span></strong>
				    </a>
			    </li>
		    </ul>
		    <a class="btn_link"></a>
	    </div>
	    <div id="collab_main_content_container" class="container-fluid card-fluid">
		    <div class="row">
            </div>
        </div>
    </div>
    <a class="btn_simple_write" id="taskAddBtn"><spring:message code='Cache.lbl_Simple'/><br /><spring:message code='Cache.btnWrite'/></a> <!-- 간편 작성 -->
    
    <div class="simtask_pop">
      <div class="simtask_box" id="taskAddPop">
        <a class="simbtn" id="taskCloseBtn"></a>
        
        <div class="simcont">
          <div class="sim_title">
            <span id="sectionSelSpan"><spring:message code='Cache.lbl_sectionName'/></span> <!-- 섹션명 -->
            <span><select id="sectionSel"></select></span>
            <a class="g_btn03 ui-link" id="collab_regist"><spring:message code='Cache.btn_register'/></a><!-- 등록 -->
          </div>
          <div class="sim_input">
            <input type="text" name="" value="" placeholder="" id="collab_regist_title">
          </div>
          <div class="sim_info">
            <div class="sim_l">
              <strong class="sim_people" id="memberCnt">0</strong>
              <a class="btn_add" id="collab_btn_add"></a>
            </div>
            <div class="sim_r">
              <label for=""><spring:message code='Cache.lbl_Period'/></label> <!-- 기간 -->
              <input type="text" name="" value="" class="input_date" id="collab_start_date">
              <span> - </span>
              <input type="text" name="" value="" class="input_date" id="collab_end_date">
            </div>
          </div>
        </div>
      </div>
      <div class="mobile_popup_wrap"></div>
    </div>
    
    

    <!-- 내 전체 프로젝트 진행률 팝업 -->
    <div id="collab_main_myProcess_pop" class="mobile_popup_wrap myProcess_pop">
		<div class="card_list_popup" style="top:30%;">
			<div class="card_list_popup_cont">
				<div class="card_list_title">
					<div class="Project_cycleCont02">
						<div class="cycleBg">
							<div class="pie"></div>
							<div class="cycleTxt">
								<div class="inner">
									<strong class="cNum"><span id="collab_main_popup_progRate"></span><span>%</span></strong>
								</div>
							</div>
						</div>
						<div id="slice" class="gt50">
							<div class="pie"></div>
							<div class="pie fill"></div>
						</div>
					</div>
					<strong class="tit"><spring:message code='Cache.lbl_MyTotalPrjProgress'/></strong><!-- 내 전체 프로젝트 진행률 -->
				</div>
				<div class="process_area">
					<table class="process_table">
						<caption><spring:message code='Cache.lbl_ProjectProgress'/></caption><!-- 프로젝트 진행률 -->
						<colgroup>
							<col width="" />
							<col width="" />
						</colgroup>
						<thead>
							<tr>
								<th scope="col"><spring:message code='Cache.lbl_ByWorkStatus'/></th><!-- 업무상태별 -->
								<th scope="col"><spring:message code='Cache.lbl_CasesCnt'/></th><!-- 건수 -->
							</tr>
						</thead>
						<tbody>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_OngoingWork'/></th><!-- 진행중인 업무 -->
								<td>
									<span class="num_case"><strong class="num num01"><span id="collab_main_popup_procCnt"></span></strong> / <span id="collab_main_popup_proctotCnt"></span>건</span>
								</td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_DelayedWork'/></th><!-- 지연 업무 -->
								<td><strong class="num num02"><span id="collab_main_popup_delayCnt"></span></strong></td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_EmergencyWork'/></th><!-- 긴급업무 -->
								<td><strong class="num num03"><span id="collab_main_popup_emgCnt"></span></strong></td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_CriticalTasks'/></th><!-- 중요 업무 -->
								<td><strong class="num num04"><span id="collab_main_popup_impCnt"></span></strong></td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_CompletionTasks'/></th><!-- 완료 업무 -->
								<td><strong class="num num05"><span id="collab_main_popup_CompCnt"></span></strong></td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_WorkMeeting'/></th><!-- 업무 미팅 -->
								<td><strong class="num num06">0</strong></td>
							</tr>
							<tr>
								<th scope="row"><spring:message code='Cache.lbl_RelatedApproval'/></th><!-- 관련 결재 -->
								<td><strong class="num num07">0</strong></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="mobile_popup_btn">
	  				<a class="g_btn03 btn_close ui-link"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
	  			</div>
			</div>
		</div>
	</div>
</div>