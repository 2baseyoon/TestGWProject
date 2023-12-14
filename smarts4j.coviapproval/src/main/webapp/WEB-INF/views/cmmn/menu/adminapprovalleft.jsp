<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>



<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">전자결재</span></h2>
	<ul class="lnb_list">
	</ul>
</nav>

<script type="text/javascript">
	var leftdata = ${adminapprovalleft};
// 	var leftmenuhtml = "";
	
// 	function drawleftmenu(pObj,pDepth) {
// 		var leftmenu_depth = pDepth + 1;
		
// 		$(pObj).each(function(){
// 			if(this.cn != undefined && this.cn.length > 0){
// 				leftmenuhtml += "<li class='list_" + leftmenu_depth + "dep_close' onclick='toggleleftmenu(this);'><a href='"+ this.url +"'>" + this.label + "</a>";
				
// 				leftmenuhtml+="<ul>";
// 				drawleftmenu(this.cn,leftmenu_depth);
// 				leftmenuhtml+="</ul>";
// 			} else {
// 				leftmenuhtml += "<li class='list_" + leftmenu_depth + "dep'><a href='"+ this.url +"'>" + this.label + "</a>";
// 			}
// 			leftmenuhtml += "</li>";
			
// 		});
// 	} 
	
// 	function toggleleftmenu(pObj){
// 		$(pObj).find("ul").toggle();
		
// 		if($(pObj).find("ul").is(":visible") == true ){
// 			$(pObj).attr("class",$(pObj).attr("class").replace(/_close/gi,"_open"));
// 		} else {
// 			$(pObj).attr("class",$(pObj).attr("class").replace(/_open/gi,"_close"));
// 		}
// 	}
	
// 	function leftmenu_goToPageMain(){
// 		location.href = "#";
// 	}
	
// 	$(document).ready(function (){
// 		drawleftmenu(leftdata,0);
		
// 		$(".lnb_list").html(leftmenuhtml);	
		
// 		$(".lnb_list > li > ul").each(function(){
// 			$(this).hide();
// 		});
		
// 		$("li").each(function () {
// 			if($(this).find("ul").is(":visible") == true ){
// 				$(pObj).attr("class",$(pObj).attr("class").replace(/_close/gi,"_open")); 
// 			} else {
// 				$(this).attr("class",$(this).attr("class").replace(/_open/gi,"_close"));
// 			}
// 		});	
// 	});
	function leftmenu_goToPageMain(){
		location.href = "/approval/approvaladmin_approvaladmin.do";
	}
	
	$(document).ready(function (){
		drawadminleftmenu(leftdata);
		
	});
</script>
