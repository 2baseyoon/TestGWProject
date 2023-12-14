	<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<div style='position:relative; height:80px;'>
	<div style="width:250px; padding-left:30px; height:80px; line-height:80px; display:inline-block; float:left;">
		<img onclick="location.href ='/groupware/portal/home.do?CLSYS=portal&CLMD=user&CLBIZ=Portal';" src="/HtmlSite/smarts4j_n/covicore/resources/images/theme/blue/logo.png" width="150px" style="cursor: pointer;"/>
	</div>
	<div style="height:80px; display:inline-block; padding-top:20px; box-sizing:border-box; margin-left : 20px;">
		<ul style='height:100%;'>
			<li style="display:inline-block; float:left; margin-right : 10px; height:100%; box-sizing:border-box;">
				<div class="mainPro">
					<img id="userImg" style="max-width: 100%; height: auto;" alt="">
				</div>
			</li>
			<li style="display:inline-block; padding-top : 10px; height:100%; box-sizing:border-box;">
				<div id="spnUser" style="height: 18px; font-weight:bold; font-size:14px; color:#444;">${userName} ${userJobPosition}</div>
				<div id="spnUserDet" style="font-size : 11px; color : #444;">${userDeptName}</div>	
			</li>
			<li id="myReportInfo" style="padding-left : 20px; display:inline-block; height:100%; box-sizing:border-box;"></li>
		</ul>
	</div>
	<div style="position:absolute; right:30px; height:80px; top:0px; line-height : 80px;">
		<a href="javascript:XFN_LogOut();" class="topLogout" style="color: #666; font-size:12px;">로그아웃</a>	
	</div>
</div>

<div id="sessionInfoDiv" style="display:none;"></div>


<script>
	var viewSessionInfo = function() {
		$("#sessionInfoDiv").empty();
		var sessionObj = Common.getSession();
		
		var sHTML = "<table style='border:1px; width:100%;'>";
		sHTML += "<tr style='background-color:#222; color:#fff; height:20px;'><th>KEY</th><th>VALUE</th></tr>"
		for(var prop in sessionObj) {
			sHTML += "<tr style='text-align:center; height:20px;'>";
			sHTML += "<td>" + prop + "</td><td>" + sessionObj[prop] + "</td>";
			sHTML += "</tr>";
		}
		
		$("#sessionInfoDiv").html(sHTML);
		
		Common.open("btnOpenSessionInfo", "sessionInfoPop", "세션정보", "sessionInfoDiv", "500px", "800px", "id", true, null, null, true);
	};
	
	(function() {
		var photoPath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
		
		$("#userImg").attr("src", coviCmn.loadImage(photoPath + Common.getSession("UR_Code") + ".jpg")).on("error", function() {coviCmn.imgError(this, true);});
		
		var recentMonth = "${recentMonth}";
		var recentWeekOfMonth = "${recentWeekOfMonth}";
		var recentState = "${recentState}";
		var notReportCnt = "${notReportCnt}";
		
		if(recentState) {
			var strWeekInfo = recentMonth + "월 " + recentWeekOfMonth + "주차 업무보고 상태 : ";
			
			var strState = "";
			var strStateColor = "";
			
			switch(recentState) {
			case 'W' : strState = "작성중"; strStateColor = "#1E4CD4"; break;  
			case 'I' : strState = "승인요청"; strStateColor = "#D4A61E"; break;
			case 'A' : strState = "승인완료"; strStateColor = "#48E609"; break;
			case 'R' : strState = "거부"; strStateColor = "#E63909"; break;
			}
			
			var sHTML = "<div style='padding-bottom : 5px;'>"
			sHTML += "<font style='font-weight:bold; font-size:12px;'>" + strWeekInfo + "</font>";
			sHTML += "<span style='font-size:12px; font-weight:bold; color : " + strStateColor + "'>" + strState + "</span>";
			sHTML += "</div>";
			sHTML += "<div>";
			sHTML += "<font style='font-weight:bold; font-size:12px;'>누적 미보고 : </font> <span style='font-size:12px;'>" + notReportCnt +" 건</span>"; 
			sHTML += "</div>";
			
			$("#myReportInfo").append(sHTML);
		} else {
			$("#myReportInfo").remove();
		}
		
	})();
</script>