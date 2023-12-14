<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="ui_onboarding" data-name="approval">
    <div class="step step_intro step_active">
        <div class="card_intro">
            <h2><span><strong>코비젼 그룹웨어</strong>에</span> 오신 것을 환영합니다!</h2>
            <p>전자결재의 개편된 기능들을 간단히 안내드릴게요.</p>
            <div class="banner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/bg_intro.png" alt="전자결재 인트로" /></div>
            <div class="action">
                <button type="button" class="skip"><span>건너뛰기</span></button>
                <button type="button" class="start"><span>시작하기</span></button>
            </div>
            <button type="button" class="close"><span>닫기</span></button>
        </div>
        <button type="button" class="guide_close" onclick="closeGuide(true);"><span>가이드 페이지를 보지 않겠습니다.</span></button>
    </div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step1.png" alt="전자결재 가이드1" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step2.png" alt="전자결재 가이드2" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step3.png" alt="전자결재 가이드3" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step4.png" alt="전자결재 가이드4" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step5.png" alt="전자결재 가이드5" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step6.png" alt="전자결재 가이드6" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step7.png" alt="전자결재 가이드7" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step8.png" alt="전자결재 가이드8" /></div></div>
    <div class="step"><div class="inner"><img src="/HtmlSite/smarts4j/covicore/resources/images/onboarding/approval/step9.png" alt="전자결재 가이드9" /></div></div>
    <div class="step_control">
        <div class="pagination"></div>
        <div class="action">
            <button type="button" class="skip"><span>Skip</span></button>
            <button type="button" class="prev"><span>이전</span></button>
            <button type="button" class="next" data-finish-text="전자결재 시작"><span>다음</span></button>
        </div>
    </div>
</div>

<script type="text/javascript">
    function UIOnboarding(target) {
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
            $('.ui_onboarding[data-name="' + target + '"]').hide();
        });

        // close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .close', function () {
            $('.ui_onboarding[data-name="' + target + '"]').hide();
        });

        // guide_close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .guide_close', function () {
            $('.ui_onboarding[data-name="' + target + '"]').hide();
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
	function closeGuide(doNotOpenGuide) {
		if (doNotOpenGuide){
			coviCmn.setCookie("USER_APPROVALGUIDE_" + Common.getSession("LogonID"), Common.getSession("LogonID"), 3650);
		}				
		$('.ui_onboarding').hide();
		//가이드 닫을 경우 팝업 공지 표시
    }
    UIOnboarding('approval');
</script>