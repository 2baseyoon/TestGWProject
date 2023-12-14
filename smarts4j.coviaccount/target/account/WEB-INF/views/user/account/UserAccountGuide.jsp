<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.RedisDataUtil,egovframework.coviframework.util.SessionCommonHelper" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- onboarding start -->
<div class="ui_onboarding" data-name="eaccounting" style="display:none;">
    <div class="step step_intro step_active">
        <div class="card_intro">
            <h2><span><strong>코비젼 그룹웨어</strong>에</span> 오신 것을 환영합니다!</h2>
            <p>e-Accounting의 개편된 기능들을 간단히 안내드릴게요.</p>
            <div class="banner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/eaccounting/bg_intro.png" alt="이어카운팅 인트로" /></div>
            <div class="action">
                <button type="button" class="skip"><span>건너뛰기</span></button>
                <button type="button" class="start"><span>시작하기</span></button>
            </div>
            <button type="button" class="close"><span>닫기</span></button>
        </div>
        <button type="button" class="guide_close" onclick="closeGuide('eaccounting', true);"><span>가이드 페이지를 보지 않겠습니다.</span></button>
    </div>
    <%
    String basepath = cssPath + "/covicore/resources/images/onboarding/eaccounting/step%s.png";
    int imageIdx = 11;
    if("Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS"))){
    	basepath = cssPath + "/covicore/resources/images/onboarding/eaccounting/weharang/step%s.png";
        imageIdx = 9;
    }
    for(int i = 1; i <= imageIdx; i++){
    	String path = String.format(basepath, String.valueOf(i));
    %>
    <div class="step"><div class="inner"><img src="<%=path%>" alt="이어카운팅 가이드" /></div></div>
    <%
    }
    %>
    <div class="step_control">
        <div class="pagination"></div>
        <div class="action">
            <button type="button" class="skip"><span>Skip</span></button>
            <button type="button" class="prev"><span>이전</span></button>
            <button type="button" class="next" data-finish-text="e-Accounting 시작"><span>다음</span></button>
        </div>
    </div>
</div>
<script type="text/javascript">
	var guideSession = coviCmn.getCookie('USER_GUIDE_<%=SessionCommonHelper.getSession("LogonID")%>');
    function UIOnboarding(target) {
		$('.ui_onboarding[data-name="' + target + '"]').show();
        let step = 0;

        for (let i = 0; i < $('.ui_onboarding[data-name="' + target + '"] .step').length - 1; i++) {
            $('.ui_onboarding[data-name="' + target + '"] .step_control .pagination').append('<span class="bullet"></span>')
        }

        // 시작하기
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .step_intro .start', function () {
            step = 1;
            $(this).parents('.step_intro').removeClass('step_active').next().addClass('step_active');
            $(this).parents('.step_intro').siblings('.step_control').find('.pagination .bullet:first').addClass('active');
        });

        // skip
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .skip', function () {
            closeGuide(target, false);
        });

        // close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .close', function () {
            closeGuide(target, false);
        });

        // guide_close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .guide_close', function () {
            closeGuide(target, false);
        });

        // 이전
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .step_control .prev', function () {
            if (step <= 1) {
                $(this).parent().prev().find('.bullet').removeClass('active');
                step = 0;
            } else {
                step -= 1;
                if ($(this).next().hasClass('finish')) $(this).next().text('다음').removeClass('finish');
                $(this).parent().prev().find('.bullet').eq(step - 1).addClass('active').siblings().removeClass('active');
            }

            $(this).parents('.step_control').siblings('.step').eq(step).addClass('step_active').siblings().removeClass('step_active');
        });

        // 다음
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .step_control .next', function () {
            const pages = $(this).parent().prev().find('.bullet').length;
            if (step < pages) {
                step += 1;
            }

            if (step === pages) {
                const label = $(this).attr('data-finish-text');
                $(this).text(label).addClass('finish');
            }

            $(this).parents('.step_control').siblings('.step').eq(step).addClass('step_active').siblings().removeClass('step_active');
            $(this).parent().prev().find('.bullet').eq(step - 1).addClass('active').siblings().removeClass('active');
        });

        // 마지막
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .step_control .next.finish', function () {
            $('.ui_onboarding[data-name="' + target + '"]').hide();
        });
    }
    
    function closeGuide(target, doNotOpenGuide) {
		if (doNotOpenGuide){
		    guideSession += ","+target;
			coviCmn.setCookie("USER_GUIDE_" + Common.getSession("LogonID"), guideSession, 3650);
		}				
		$('.ui_onboarding[data-name="' + target + '"]').hide();
	}
    
    if ('<%=RedisDataUtil.getBaseConfig("UseWebGuidePopup")%>' == "Y" && !guideSession.split(",").includes("eaccounting") && $(".ui_onboarding[data-name=eaccounting]").length==1) { 
    	UIOnboarding('eaccounting');
    }
</script>
<!-- onboarding end -->