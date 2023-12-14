<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	.arrow_box {
    min-height: 165px;
    position: absolute;
    top: 50px;
    background: #ffffff;
    border: 1px solid #e0e0e0;
    box-sizing: border-box;
    padding: 13px 25px;
    border-radius: 3px;
    display:block;
}
</style>
<div data-role="page" id="account_portal_user_page">
	<script>
		var AccountMenu = ${Menu};	//좌측 메뉴
	</script>
	<header class="header">
      <div class="sub_header">
        <div class="l_header">
		  <a class="topH_menu ui-link" href="javascript:mobile_comm_TopMenuClick('account_portal_user_topmenu');"><span></span></a>
          <div class="menu_link gnb">
            <span href="#" class="topH_tit"><%=SessionHelper.getSession("UR_Name") %>님 리포트</span>
            <div class="cover_leftmenu" style="display: none;">
				<div class="LsubHeader">
					<span class="LsubTitle approval" onclick="mobile_account_PortalLinkClick('Portal');"><spring:message code='Cache.ACC_lbl_eAccounting'/></span>
					<span class="LsubTitle_btn">
						<button type="button" onclick="mobile_comm_TopMenuClick('account_portal_user_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
					</span>
				</div>
				<div class="tree_default" id="account_portal_user_topmenu"></div>
            </div>
          </div>
        </div>
        <div class="utill">
          <a href="#" class="topH_search ui-link"><span class="Hicon">검색</span></a>
        </div>
      </div>
    </header>
    <div class="cont_wrap">
		<div class="calendar_wrap month">
			<div class="calendar_ctrl">
				<div class="month_ctrl">
					<a href="javascript: mobile_account_SetUserPortal('PREV');" class="prev_month ui-link"></a>
					<p class="t_month"><a id="account_portal_user_datetitle" class="ui-link"><a id="account_portal_user_year"></a>년 <a id="account_portal_user_month"></a>월</a></p>
					<a href="javascript: mobile_account_SetUserPortal('NEXT');" class="next_month ui-link"></a>
				</div>
			</div>
		</div>
		<div class="Newgragh_eAPBoard">
			<div class="Newgragh_eAPBoardL">
				<h3 class="Newgragh_eAPBoardTitle">증빙종류별 증빙내역</h3>
				<div class="Newgragh_Detailrank2">
					<h2>총 <span class="Newgragh_TxtBox" id="account_portal_user_proof_tot">0</span> 원</h2>
				</div>
					<div class="Newgragh_eAPBoardContents">
					<div class="Newgragh_eAPBoardCardBox_use">
						<canvas id="proofDoughnut"></canvas>
					</div>
					<div class="graph_contentbox">
						<div class="Newgragh_Detailrank">
							<ul id="account_portal_user_proof_list">
							</ul>
						</div>	
					</div>
				</div>
			</div>
			<div class="Newgragh_eAPBoardR">
				<h3 class="Newgragh_eAPBoardTitle">신청내역</h3>
				<div class="Newgragh_Detailrank2">
    				<h2>총 <span class="Newgragh_TxtBox" id="account_portal_user_account_tot">0</span> 원</h2>
				</div>
				<div class="Newgragh_eAPBoardContents">
					<div class="Newgragh_Detailrank2">
						<ul class="Newgraph_stick" id="account_portal_user_account_chart">
						</ul>
					</div>
				</div>
				<!--슬라이드 버튼 -->
				<div class="Slideroll_btn" id="account_portal_user_account_slide">
				</div>	
				<!--슬라이드 버튼 끝 -->
			</div>
		</div>
		
		<div class="squaregraph01_wrap">
			<a href="javascript: mobile_account_SetUserYearPortal('PREV');" class="prev_month ui-link"><</a>
			<span class="squaregragh_Title" style="margin-left:5px;"><a id="account_portal_user_year_flow"></a>년 월별 신청내역</span>
			<a href="javascript: mobile_account_SetUserYearPortal('NEXT');" class="next_month ui-link">></a>
		</div>
		<div class="NewColorChart_graphtext_fbox">				
			<div class="NewColorChart_graphContent">
				<canvas id="account_portal_user_month_chart" width="900" height="400"></canvas>
			</div>
		</div>
    </div>
</div>
