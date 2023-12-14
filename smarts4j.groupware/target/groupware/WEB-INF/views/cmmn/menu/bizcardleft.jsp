<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<div>
	<div id="menuDrawBox" style="padding-left: 0px;">
		<h2 class="gnb_left_tit" style="width:100%!important;"><span class="gnb_tit" style="cursor:pointer;" onclick="location.href='bizcardhome.do'"><spring:message code='Cache.BizSection_BizCard' /></span></h2>
		<div style="text-align:left;">
			${menuStr}
		</div>
	</div>
</div>

<script>
	var viewLowDepthMenu = function(target) {
		var evt = window.event;
	    if(evt.stopPropagation) {
	        evt.stopPropagation();  // W3C 표준
	    }
	    else { 
	        evt.cancelBubble = true; // 인터넷 익스플로러 방식
	    }
		
		var nextTree = $(target).parent().next();
		
		if(nextTree.length > 0) {
			var nextTreeView = nextTree.css("display");
			if(nextTreeView == "none") {
				nextTree.css("display", "block");
				$(target).removeClass("closemenu").addClass("openmenu");
			} else {
				nextTree.css("display", "none");
				$(target).removeClass("openmenu").addClass("closemenu");
			}
		}
	};
	
	var moveMenuUrl = function(target) {
		
		var parents = $(target).parents().filter("li");
		var currentMnId = $(target).attr("data-mnid");
		var currentMnType = $(target).attr("data-mntype");
		var currentGrpID = $(target).attr("data-groupid");
		
		var mnp = "";
		var mntype = "";
		var grpid = "";
		parents.each(function(idx, obj) {
			var pMnp = $(obj).attr("data-mnid");
			if($(obj).attr("data-mntype") != null)
				var pMntype = $(obj).attr("data-mntype");
			if($(obj).attr("data-groupid") != null)
				var pGrpid = $(obj).attr("data-groupid");
			mnp += pMnp + "|";
			mntype += pMntype + "|";
			grpid += pGrpid + "|";
		});
		
		mnp += currentMnId;
		mntype += currentMnType;
		grpid += currentGrpID;
		
		var url = $(target).attr("data-mnurl");
		url += "?mnp=" + encodeURIComponent(mnp);
		if(mntype != null & mntype != "undefined"){
			url += "&mntype=" + encodeURIComponent(mntype);
		}
		if(grpid != null & grpid != "undefined"){
			url += "&grpid=" + encodeURIComponent(grpid);
		}
		document.location.href = url;
		
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
	};
	
	
	var addGroup = function(target) {
		
		var currentMntype = $(target).attr("data-mntype");
		
		var url = $(target).attr("data-mnurl");
		Common.open("", "CreateBizCardGroupPop", "그룹 등록", url + "?sharetype=" + encodeURIComponent(currentMntype), "350px", "150px", "iframe", true, null, null, true);
		
		return;
	};
	
	(function() {
		var menuPath = "${menuPath}";
		
		// bold 처리
		$("#bizCardMenu > li").css("font-weight", "bold");
		
		$.getJSON('getGroupList.do', {ShareType : 'P'}, function(d) { //개인
			d.list.forEach(function(d) {
				$("#bizCardGroupList_P li:last").before('<li data-mnid=\'3\' data-mntype=\'P\' data-groupid=\'' + d.GroupID + '\' data-mnurl=\'bizcard_BizCardPersonList.do\' onclick=\'moveMenuUrl(this)\'>' + d.GroupName + '</li>');
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		$.getJSON('getGroupList.do', {ShareType : 'D'}, function(d) { //부서
			d.list.forEach(function(d) {
				$("#bizCardGroupList_D li:last").before('<li data-mnid=\'4\' data-mntype=\'D\' data-groupid=\'' + d.GroupID + '\' data-mnurl=\'bizcard_BizCardPersonList.do\' onclick=\'moveMenuUrl(this)\'>' + d.GroupName + '</li>');
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		$.getJSON('getGroupList.do', {ShareType : 'U'}, function(d) { //회사
			d.list.forEach(function(d) {
				$("#bizCardGroupList_U li:last").before('<li data-mnid=\'5\' data-mntype=\'U\' data-groupid=\'' + d.GroupID + '\' data-mnurl=\'bizcard_BizCardPersonList.do\' onclick=\'moveMenuUrl(this)\'>' + d.GroupName + '</li>');
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		$.getJSON('getGroupList.do', {ShareType : 'C'}, function(d) { //업체
			d.list.forEach(function(d) {
				$("#bizCardGroupList_C li:last").before('<li data-mnid=\'6\' data-groupid=\'' + d.GroupID + '\' data-mnurl=\'bizcard_BizCardCompanyList.do\' onclick=\'moveMenuUrl(this)\'>' + d.GroupName + '</li>');
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		// 메뉴 Visible
		$("#bizCardMenu").css("display", "block");
	})();
</script>

