<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>


<div>
	<div id="menuDrawBox" style="padding-left: 0px;">
		<h2 class="gnb_left_tit" style="width:100%!important;"><span class="gnb_tit" style="cursor:pointer;" onclick="location.href='workreporthome.do'">업무보고</span></h2>
		<div style="text-align:left;">
			${menuStr}
		</div>
	</div>
</div>

<script>
	var viewLowDepthMenu = function(target) {
		var childTree = $(target).find(">ul");
		
		if(childTree.length > 0) {
			var childTreeView = childTree.css("display");
			if(childTreeView == "none") {
				childTree.css("display", "block");
				$(target).find(".closemenu").removeClass("closemenu").addClass("openmenu");
			} else {
				childTree.css("display", "none");
				$(target).find(".openmenu").removeClass("openmenu").addClass("closemenu");
			}
		}
	};
	
	var moveMenuUrl = function(target) {
		
		var parents = $(target).parents().filter("li");
		var currentMnId = $(target).attr("data-mnid");
		
		var mnp = "";
		parents.each(function(idx, obj) {
			var pMnp = $(obj).attr("data-mnid");
			mnp += pMnp + "|";
		});
		
		mnp += currentMnId;
		
		var url = $(target).attr("data-mnurl");
		document.location.href = url + "?mnp=" + encodeURIComponent(mnp);
		
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
	};
	
	(function() {
		var menuPath = "${menuPath}";
		
		arrMenuPath = menuPath.split('|');
		
		if(arrMenuPath[arrMenuPath.length - 1] == "") {
			arrMenuPath.pop();
		}
		
		if(arrMenuPath.length == 1) {
			$("li[data-mnid='" + arrMenuPath[0] + "']").css("font-weight", "bold");
		} else {
			// 하위 path Division open
			for(var i=0; i < arrMenuPath.length - 1; i++) {
				viewLowDepthMenu($("li[data-mnid='" + arrMenuPath[0] + "']"));
			}
			
			// bold 처리
			$("li[data-mnid='" + arrMenuPath[arrMenuPath.length - 1] + "']").css("font-weight", "bold");
		}
		
		
		// 메뉴 Visible
		$("#workReportMenu").css("display", "block");
	})();
</script>

