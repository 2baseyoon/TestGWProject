<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2>통합업무보고</h2>
	<div>
		<a class="btnType01 btnSurveyAdd" href="javascript:;" onclick="addDailyReport();return false;">일일업무보고</a>
	</div>	
</div>
<div class="cLnbMiddle mScrollV scrollVType01">
	<ul class="contLnbMenu reportMenu" id="leftmenu"></ul>	
</div>

<script type="text/javascript">
	//# sourceURL=VacationUserLeft.jsp
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	initLeft();
	
	function initLeft(){
		
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
		var left = new CoviMenu(opt);
		left.render('#leftmenu', leftData, 'userLeft');
		
		if(loadContent == 'true'){
			CoviMenu_GetContent('/groupware/layout/bizreport_DailyReportList.do?CLSYS=bizreport&CLMD=user&CLBIZ=BizReport');
		}
	}
	
	// 일일업무보고
	function addDailyReport() {
		CoviMenu_GetContent('/groupware/layout/bizreport_DailyReport.do?CLSYS=bizreport&CLMD=user&CLBIZ=BizReport');
	}	
	
	 $(".selOnOffBox").find('a').click(function () {	
		var cla= $(this).closest('li').find('.selOnOffBoxChk');
	
		var liname = $(this).parent().parent().attr("class");
	});  
</script>
