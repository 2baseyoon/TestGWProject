<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="vacation_main_page">

	<header data-role="header" id="vacation_main_header">
		<div class="sub_header">
			<div class="l_header">         
				<div class="menu_link gnb">
					<span href="javascript:void(0);" class="topH_tit"><spring:message code="Cache.BizSection_VacationManager"/></span>
				</div>
			</div>
			<div class="utill">			
				<a href="javascript: mobile_vacation_clickrefresh();" class="topH_reload"><span class="Hicon"><spring:message code="Cache.btn_search"/></span></a> <!-- 검색 -->				
			</div>
        </div>      
    </header>
    
	<%--
	<header data-role="header" id="vacation_main_header">
		<div class="sub_header">
	    	<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a class="pg_tit"><spring:message code="Cache.BizSection_VacationManager"/></a> <!-- 휴가관리 -->
				</div>
			</div>
	        <div class="utill">
	          <a href="javascript: mobile_vacation_clickrefresh();" class="btn_reload"><span><spring:message code="Cache.btn_search"/></span></a> <!-- 검색 -->
	          <a href="javascript: mobile_vacation_clickwrite();" class="btn_write" style="display: none;"><span><spring:message code="Cache.lbl_Write"/></span></a> <!-- 작성 -->
	        </div>
		</div>
	</header>
	--%>
	<div data-role="content" class="cont_wrap" id="vacation_main_content">
		<div class="vacation_wrap">
			<div class="my_vacation">
				<h1 id=vacation_main_title></h1> <!-- 2017 나의 총 연차 -->
				<div class="inner">
				<!--1%에 3.6deg, 180deg(50%)가 넘어 갈 경우 chart_wrap에 gt180 클래스, 추가 로테이션 값은 pie에만 입력한다.-->
					<div class="chart_wrap">
						<div class="chart">
							<span class="pie" id="vacation_main_pie"></span> <!-- style="transform:rotate(50deg)" -->
							<span class="pie fill"></span>
						</div>
						<p class="text"><span class="title"><spring:message code="Cache.lbl_TotalVacation"/></span> <strong id="vacation_main_totalDays"></strong> Days</p> <!-- 총연차 -->
					</div>
					<div class="index_wrap">
						<dl class="total">
							<dt><spring:message code="Cache.lbl_UseVacation"/></dt> <!-- 사용연차 -->
							<dd><strong id="vacation_main_useDays"></strong>Days</dd>
						</dl>
						<dl>
							<dt><spring:message code="Cache.lbl_RemainVacation"/></dt> <!-- 잔여연차 -->
							<dd><strong id="vacation_main_remainDays"></strong>Days</dd>
						</dl>
					</div>
				</div>
			</div>
			<div class="vacation_list">
				<h1><spring:message code="Cache.lbl_dept"/><spring:message code="Cache.lbl_apv_vacation_user_status"/>(<%=SessionHelper.getSession("DEPTNAME")%>)</h1> <!-- 부서휴가자 현황 -->
				<ul id="vacation_main_list"></ul>
			</div>		
		</div>
	</div>	
	<div class="list_writeBTN" style="display:none;">
		<a href="javascript: mobile_vacation_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>    
</div>