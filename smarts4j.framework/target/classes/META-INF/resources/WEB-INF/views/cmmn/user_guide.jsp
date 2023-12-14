<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.RedisDataUtil,egovframework.coviframework.util.SessionCommonHelper" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- onboarding start -->
<div class="ui_onboarding" data-name="portal" style="display:none;">
    <div class="step step_intro step_active">
        <div class="card_intro">
            <h2><span><strong>코비젼 그룹웨어</strong>에</span> 오신 것을 환영합니다!</h2>
            <p>새롭게 개편된 기능들을 간단히 안내드릴게요.</p>
            <div class="banner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/bg_intro.png" alt="포털 인트로" /></div>
            <div class="action">
                <button type="button" class="skip"><span>건너뛰기</span></button>
                <button type="button" class="start"><span>시작하기</span></button>
            </div>
            <button type="button" class="close"><span>닫기</span></button>
        </div>
        <button type="button" class="guide_close" onclick="closeGuide('portal', true);"><span>가이드 페이지를 보지 않겠습니다.</span></button>
    </div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step1.png" alt="포털 가이드1" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step2.png" alt="포털 가이드2" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step3.png" alt="포털 가이드3" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step4.png" alt="포털 가이드4" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step5.png" alt="포털 가이드5" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step6.png" alt="포털 가이드6" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step7.png" alt="포털 가이드7" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step8.png" alt="포털 가이드8" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step9.png" alt="포털 가이드9" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step10.png" alt="포털 가이드10" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step11.png" alt="포털 가이드11" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step12.png" alt="포털 가이드12" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step13.png" alt="포털 가이드13" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step14.png" alt="포털 가이드14" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step15.png" alt="포털 가이드15" /></div></div>
    <div class="step"><div class="inner"><img src="<%=cssPath%>/covicore/resources/images/onboarding/step16.png" alt="포털 가이드16" /></div></div>
    <div class="step_control">
        <div class="pagination"></div>
        <div class="action">
            <button type="button" class="skip"><span>Skip</span></button>
            <button type="button" class="prev"><span>이전</span></button>
            <button type="button" class="next" data-finish-text="새로운 포털 시작"><span>다음</span></button>
        </div>
    </div>
</div>
<script type="text/javascript">
	var guideSession = coviCmn.getCookie('USER_GUIDE_<%=SessionCommonHelper.getSession("LogonID")%>');
    function UIOnboarding(target) {
    	$('.ui_onboarding[data-name="'+target+'"]').show();
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
            closeGuide(false);
        });

        // close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .close', function () {
            closeGuide(false);
        });

        // guide_close
        $(document).on('click', '.ui_onboarding[data-name="' + target + '"] .guide_close', function () {
            closeGuide(false);
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
    
    function UISlider(){
        // 사용자 가이드 슬라이드
        new Swiper(".guide_swiper", {
            threshold: 13,
            fadeEffect: {
                crossFade: true
            },
            loop: true,
            autoplay: false,
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            }
        });
    }
	 
	function closeGuide(target, doNotOpenGuide) {
		if (doNotOpenGuide){
		    guideSession += ","+target;
			coviCmn.setCookie("USER_GUIDE_" + Common.getSession("LogonID"), guideSession, 3650);
		}				
		$('.ui_onboarding').hide();
		//가이드 닫을 경우 팝업 공지 표시
		$(".layer_divpop[id^='boardViewPop']").show();
	}
	
	if ('<%=RedisDataUtil.getBaseConfig("UseWebGuidePopup")%>' == "Y" && !(guideSession.split(",").includes("portal") || guideSession.split(",").includes(Common.getSession("LogonID")))) {
		 UIOnboarding('portal');
		 UISlider();
		//팝업 공지랑 겹쳐서 표시될 경우 팝업공지 숨김처리
		$(".layer_divpop[id^='boardViewPop']").hide();
	}
</script>
<!-- onboarding end -->