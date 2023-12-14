<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	
	$(document).ready(function (){
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	coviMenu.render("#leftmenu", leftData, "defaultVertical");
    	/*
    	//target의 첫번째 li a tag 클릭
    	var $first = $('#leftmenu li').first().find('a');
    	if($first){
    		$first.click();
    	}
    	*/
	});
	
</script>

<div class="cLnbTop">
	<h2>설문</h2>
	<div><a class="btnType01 btnSurveyAdd">설문등록</a></div>
</div>
<div class="cLnbMiddle mScrollV scrollVType01 mCustomScrollbar _mCS_2 mCS_no_scrollbar"><div id="mCSB_2" class="mCustomScrollBox mCS-light mCSB_vertical mCSB_inside" style="max-height: none;" tabindex="0"><div id="mCSB_2_container" class="mCSB_container mCS_y_hidden mCS_no_scrollbar_y" style="position: relative; top: 0px; left: 0px;" dir="ltr">
	<ul id="leftmenu" class="contLnbMenu surveyMenu"></ul>
</div><div id="mCSB_2_scrollbar_vertical" class="mCSB_scrollTools mCSB_2_scrollbar mCS-light mCSB_scrollTools_vertical mCSB_scrollTools_onDrag" style="display: none;"><div class="mCSB_draggerContainer"><div id="mCSB_2_dragger_vertical" class="mCSB_dragger mCSB_dragger_onDrag" style="position: absolute; min-height: 0px; display: block; height: 0px; top: 0px;" oncontextmenu="return false;"><div class="mCSB_dragger_bar" style="line-height: 0px;"></div></div><div class="mCSB_draggerRail"></div></div></div></div></div>
