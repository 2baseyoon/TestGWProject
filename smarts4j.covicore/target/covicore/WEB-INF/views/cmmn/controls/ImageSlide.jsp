<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %> 
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/common_controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>">	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/board/resources/css/board.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/slick.css<%=resourceVersion%>">

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/slick.min.js<%=resourceVersion%>"></script>

<div class="layer_divpop ui-draggable albumPopLayer" id="testpopup_p" style="width:800px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
		<div class="popContent abSlideLayer">
			<div class="">
				<div class="top">
					<div class="slideMainCont">
						<div class="slideMainList">
						</div>
					</div>
				</div>
				<div class="bottom">
					<div class="slideNavi">
						<div class="slideNaviList">
						</div>
						<a class="btnSlideNaviFirst btnSlideNavi">슬라이드 처음으로</a> 
						<a class="btnSlideNaviEnd btnSlideNavi">슬라이드 끝으로</a>
					</div>
					<div>
						<a class="btnAutoPlay">자동플레이</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
var imageList = '${list}';	//sys_file에서 조회한 이미지, 혹은 전체 첨부파일 JSONArray

$(function() {
	if (window.opener){
		if ($("title").length == 0) $("head").prepend("<title></title>")
		$("title").text("Image Slide");
		$("#testpopup_p").css({ width: window.innerWidth+"px", height: window.innerHeight+"px" });
		$("#testpopup_p .divpop_contents, #testpopup_p .abSlideLayer").css("height", "100%");
	}
	
	if(imageList.length > 0 && !$.isEmptyObject(imageList)){
		var imageJSON = $.parseJSON(imageList);
		
		if(imageJSON.length < 1){
			Common.Warning("<spring:message code='Cache.msg_NoDataList'/>", "Warning", function(){ //조회할 목록이 없습니다
				window.close();
			})
		}
		
		$.each(imageJSON, function(i, item){
			if(item.SaveType == "IMAGE"){
				var viewURL = item.FileID == undefined ? "/covicore/resources/images/no_image.jpg" : String.format("/covicore/common/view/{0}/{1}.do", item.ServiceType, item.FileID);
				var previewURL = item.FileID == undefined ? "/covicore/resources/images/no_image.jpg" : String.format("/covicore/common/preview/{0}/{1}.do", item.ServiceType, item.FileID);
				
				var img = $('<img>').attr({'src':viewURL, 'style': 'margin:0 auto;width:auto;height:auto;max-width:560px;max-height:420px'}).attr("onerror", "this.onerror=null; this.src='/covicore/resources/images/no_image.jpg'");
				var slideImg = $('<img>').attr({'src': previewURL, 'style':'width:105px;height:81px;', }).attr("onerror", "this.onerror=null; this.src='/covicore/resources/images/no_image.jpg'");
				var date = $('<div class="date">').text(CFN_TransLocalTime(item.RegistDate) + " " + Common.getSession("UR_TimeZoneDisplay"));
				
				$('.slideMainList').append($("<div>").append(img, date));
				
				if(window.opener){
					$('.slideNaviList').append($('<div style="height:81px;">').append(slideImg, $('<div class="border">')));
				} else {
					$('.slideNaviList').append($("<div>").append(slideImg, $('<div class="border">')));
				}
			}
		});
	}

	$('.slideMainList').slick({
		slidesToShow: 1,
		slidesToScroll: 1,
		arrows: true,
		autoplay: false,
		asNavFor: '.slideNaviList'
	});
	
	$('.slideNaviList').slick({
		slidesToShow: 5,
		slidesToScroll: 1,
		asNavFor: '.slideMainList',			  
		autoplay: false,
		arrows: true,
		focusOnSelect: true,
		centerMode: true,
		variableWidth: true
	});
	
	$.each($(".slideMainList img"), function(idx, el){
		el.onclick = function() {
			if(window.opener){
				CFN_OpenWindow(el.src, '_blank', el.naturalWidth, el.naturalHeight);
			} else {
				parent.coviComment.callImageViewer(el.src);
			}
		};
	});
})

$(window).resize(function() {
  $('.slideMainList, .slideNaviList').slick('resize');
});

$('.btnSlideNaviFirst ').on('click', function(){
	$('.slideMainList').slick('slickGoTo', 0, true);
	 $('.slideNaviList').slick('slickGoTo', 0, true);				
});
$('.btnSlideNaviEnd ').on('click', function(){
	var idx = $('.slideMainList').find('.slick-slide').not('.slick-cloned').length-1;
	$('.slideMainList').slick('slickGoTo', idx, true);
	 $('.slideNaviList').slick('slickGoTo', idx, true);				
});

$('.btnAutoPlay').on('click', function(){
	$('.slideMainList').toggleClass("active");
	if($('.slideMainList').hasClass("active")){
		$('.btnAutoPlay').css("opacity","1")
		$('.slideMainList').slick('slickPlay');
	} else {
		$('.btnAutoPlay').css("opacity","")
		$('.slideMainList').slick('slickPause');
	}
});

</script>