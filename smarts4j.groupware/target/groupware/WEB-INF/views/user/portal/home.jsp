<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>

${incResource}

<style>
	#portal_con>table{table-layout: fixed;}
	#portal_con>table td{padding: 2px;}
</style>

<div id="portal_con" class="commContRight mainContainer">${layout}</div>

<script type="text/javascript">
	${javascriptString}
</script>

<script>
	var access = '${access}' 
	var _portalInfo = '${portalInfo}';
	var _data = ${data};
	
	//ready 
	initPortal();
	function initPortal(){
		// 히스토리 추가
		var url  = location.href;
		var state = CoviMenu_makeState(url); 
		history.pushState(state, url, url);
		CoviMenu_SetState(state)
		
		if(access == 'SUCCESS'){
			loadPortal();
		}else if(access == 'NOT_AHTHENTICATION'){
			var sHtml = '';
			sHtml += '<div class="errorCont">';
			sHtml += '	<h1>포탈 접속 실패</h1>';
			sHtml += '	<div class="bottomCont">';
			sHtml += '		<p class="txt">해당 포탈에 접속 권한이 없습니다.<br>관리자에게 문의 바랍니다.</p>';
			sHtml += '		<p class="copyRight mt30">Copyright 2017. Covision Corp. All Rights Reserved.</p>';
			sHtml += '	<div/>';
			sHtml += '<div/>';
			
			$("#portal_con").html(sHtml);
		}
	}
	
	function loadPortal(){
		var oData = _data;
		
		oData.sort(sortFunc);
		
		$.each(oData, function(idx, value){
			try{
				if (parseInt(value.WebpartOrder, 10) > 100) {
					setTimeout("loadWebpart('" + JSON.stringify(value) + "')", parseInt(value.WebpartOrder, 10));
				}else{
					loadWebpart(value)
				}
			}catch(e){
				coviCmn.traceLog(e);
				$("#WP"+value.WebpartID+" .webpart").css({"border": "2px solid red"});
			}
		});
		
		setDefaultEvent();
	}

	function loadWebpart(value){
		if(typeof(value) === "string"){
			value = $.parseJSON(value);
		}
		var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
		
		if (html != ''){
			//default view로 인한 분기문
			if($("#WP"+value.WebpartID).attr("isLoad")=='Y'){
				$("#WP"+value.WebpartID).append(html);
			}else{
				$("#WP"+value.WebpartID).html(html);
				$("#WP"+value.WebpartID).attr("isLoad",'Y');
			}
		}
		
		if(value.jsModuleName != '' && typeof window[value.jsModuleName] != 'undefined' && typeof(new Function ("return "+value.jsModuleName+".webpartType").apply()) != 'undefined'){
			new Function (value.jsModuleName+".webpartType = "+ value.WebpartOrder).apply();
		}
		
		if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){
			if(typeof(value.data)=='undefined'){
				value.data = $.parseJSON("[]");
			}
			
			if(typeof(value.ExtentionJSON) == 'undefined'){
				value.ExtentionJSON = $.parseJSON("{}");
			}
			
			let ptFunc = new Function('a', 'b', Base64.b64_to_utf8(value.initMethod)+'(a, b)');
			ptFunc(value.data, value.ExtentionJSON);
		}
	}
	
	 function sortFunc(a, b) {
	       if(a.WebpartOrder < b.WebpartOrder){
	    	   return -1;
	       }else if(a.WebpartOrder > b.WebpartOrder){
	    	   return 1;
	       }else{
	    	   return 0;
	       } 
	    }
	
	 
	 function setDefaultEvent() {
	        var sLayoutType = $.parseJSON(_portalInfo).LayoutType;
	        switch (sLayoutType) {
	        	case "8": 	//1행2열 데모용
	            case "7":   // 1행3열
	            	$('.btnMyContView').on('click', function(){
	            		var parentCont = $(this).closest('.mainMyContent');
	            		if(parentCont.hasClass('active')){
	            			parentCont.removeClass('active');
	            		}else {
	            			parentCont.addClass('active');
	            		}
	            	});
	            	break;
	            case "0":   // 기타
	                break;
	            default: 
	            	break;
	        }
	        
	    }

    /*
		사용자 출 퇴근 정보 조회
	*/
    function getCommuteData(){
        //출퇴근 버튼 설정
        var data = {
            commuteChannel : "W"
        }
        $.ajax({
            type:"POST",
            data:data,
            dataType:"json",
            url:"/groupware/attendCommute/getCommuteBtnStatus.do",
            success:function (data) {
                if(data.result=="ok"){
                    //$(".cLnbMiddle").css("top","200px");
                    $("#btnSts").removeAttr("style");
                    $("#btnSts a").html(Common.getDic(data.btnLabel));
                    $("#btnSts a").off('click');
                    if(data.commuteStatus!="O"){
                        $("#btnSts a").on('click',function(){
                            AttendUtils.openCommuteAlram(data.commuteStatus,data.targetDate);
                        });
                    }

                    $("#atSts").removeAttr("style");
                    var stsStr = Common.getDic(data.atSts);
                    if(data.commuteStatus=="E"){
                        stsStr +=" : "+data.startTime;
                    }else if(data.commuteStatus=="SE"){
                        stsStr +=" : ["+data.targetDate+"]"+data.startTime;
                    }else if(data.commuteStatus=="EE"){
                        stsStr +=" : "+data.endTime;
                    }else if(data.commuteStatus=="O"){
                        stsStr +=" : "+data.startTime+"~"+data.endTime;
                    }
                    $("#atSts").html(stsStr);
                }
            }
        });
    }
	 
	/* // 레이아웃 div의 Height 값을 통일.
    function SameToLayoutHeightSize() {
        var nGroupID = 0;
        var nHeight = 0;
        var nMaxHeight = 0;
        var nOverHeight = 0;
        var nTodayHeight = 153;
        var sLayoutType = $.parseJSON(_portalInfo).LayoutType;
        $("DD[id^='ddResizeGroup_']").css({ "height": "0px" });
        switch (sLayoutType) {
            case "1":   // 2행4열
                nMaxHeight = 0;
                $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                    $(this).removeAttr("style");
                    nHeight = $(this).height();
                    if ($(this).attr("overheight_id") != null) {
                        nHeight = nHeight + $("DIV[id='" + $(this).attr("overheight_id") + "']").height() + 8;
                    }
                    if ($(this).children("dl").children("dd").length > 0) {
                        $(this).children("dl").children("dd").attr("ht", nHeight);
                    }
                    else {
                        $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                    }
                    if (nMaxHeight < nHeight) {
                        nMaxHeight = nHeight;
                    }
                });

                $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                    $(this).css({ "height": (nMaxHeight - $(this).attr("ht")) + 1 + "px" });
                });
                break;
            case "2":   // 2행3열(우측)
                nMaxHeight = 0;
                $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                    $(this).removeAttr("style");
                    nHeight = $(this).parent().height();
                    if ($(this).attr("overheight_id") != null) {
                        nHeight = nHeight + nTodayHeight;
                    }
                    if ($(this).children("dl").children("dd").length > 0) {
                        $(this).children("dl").children("dd").attr("ht", nHeight);
                    }
                    else {
                        $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                    }
                    if (nMaxHeight < nHeight) {
                        nMaxHeight = nHeight;
                    }
                });


                $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                    $(this).css({ "height": (nMaxHeight - $(this).attr("ht")) + 1 + "px" });
                });
                break;
            case "3":   // 메인
                while ($("DIV[group='" + nGroupID + "']").length > 0) {
                    if ($("DIV[group='" + nGroupID + "']").length > 1) {
                        $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                            $(this).removeAttr("style");
                            nHeight = $(this).height();
                            if ($(this).children("dl").children("dd").length > 0) {
                                $(this).children("dl").children("dd").attr("ht", nHeight);
                            }
                            else {
                                $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                            }
                        });

                        $("DIV[group='" + nGroupID + "']").equalizeHeights();
                        nHeight = $("DIV[group='" + nGroupID + "']:first").height();

                        $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                            $(this).css({ "height": (nHeight - $(this).attr("ht")) + 1 + "px" });
                        });
                    }
                    nGroupID++;
                }
                break;
            case "4":   // 2행2열
                $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                    $(this).removeAttr("style");
                    nHeight = $(this).parent().height();
                    if ($(this).children("dl").children("dd").length > 0) {
                        $(this).children("dl").children("dd").attr("ht", nHeight);
                    }
                    else {
                        $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                    }
                });

                $("DIV[group='" + nGroupID + "']").equalizeHeights();
                nHeight = $("DIV[group='" + nGroupID + "']:first").parent().height();

                $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                    $(this).css({ "height": (nHeight - $(this).attr("ht")) + 1 + "px" });
                });
                break;
            case "5":   // 2행3열(좌측)
                nMaxHeight = 0;
                $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                    $(this).removeAttr("style");
                    nHeight = $(this).height();
                    if ($(this).attr("overheight_id") != null) {
                        nHeight = $(this).parent().height() + nTodayHeight;
                    }
                    if ($(this).children("dl").children("dd").length > 0) {
                        $(this).children("dl").children("dd").attr("ht", nHeight);
                    }
                    else {
                        $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                    }
                    if (nMaxHeight < nHeight) {
                        nMaxHeight = nHeight;
                    }
                });


                $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                    $(this).css({ "height": (nMaxHeight - $(this).attr("ht")) + 1 + "px" });
                });
                break;
            case "6":   // 3단
                $("DIV[group='" + nGroupID + "']").each(function (pIntIndex) {
                    $(this).removeAttr("style");
                    nHeight = $(this).height();
                    if ($(this).children("dl").children("dd").length > 0) {
                        $(this).children("dl").children("dd").attr("ht", nHeight);
                    }
                    else {
                        $(this).append("<dl><dd id=\"ddResizeGroup_" + nGroupID + "_" + pIntIndex + "\" ht=\"" + nHeight + "\" class=\"bottom_height\" style=\"height:0px;\"></dd></dl>");
                    }
                });

                $("DIV[group='" + nGroupID + "']").equalizeHeights();
                nHeight = $("DIV[group='" + nGroupID + "']:first").height();

                $("DD[id^='ddResizeGroup_" + nGroupID + "_']").each(function () {
                    $(this).css({ "height": (nHeight - $(this).attr("ht")) + 1 + "px" });
                });
                break;
            case "0":   // 기타
                break;
        }
    } */
    
    function slideToggle(target){
		var targetArea = (typeof $(target).attr("data-target-area") != 'undefined') ? $(target).attr("data-target-area") : 'PN_myContents';
		var toggleClasses = (typeof $(target).attr("data-toggle-classes") != 'undefined') ? $(target).attr("data-toggle-classes") : '';
		var toggleClassArry = toggleClasses.split(';');
		
		$("."+targetArea).slideToggle();
		
		$.each(toggleClassArry, function(idx, el){
			if (el != '') $(target).toggleClass(el);
		});
	}
</script>

