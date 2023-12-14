	<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<div style='position:relative; height:80px;'>
	<div style="width:250px; padding-left:30px; height:80px; line-height:80px; display:inline-block; float:left;">
		<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.gif" width="150px"/>
	</div>
	<div style="height:80px; display:inline-block; padding-top:20px; box-sizing:border-box; margin-left : 20px;">
		<ul style='height:100%;'>
			<li style="display:inline-block; float:left; margin-right : 10px; height:100%; box-sizing:border-box;">
				<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt=""></a>
			</li>
			<li style="display:inline-block; padding-top : 10px; height:100%; box-sizing:border-box;">
				<div id="spnUser" style="font-weight:bold; font-size:14px; color:#444;">${userName} ${userJobPosition}</div>
				<div id="spnUserDet" style="font-size : 11px; color : #444;">${userDeptName}</div>	
			</li>
		</ul>
	</div>
	<div style="position:absolute; right:30px; height:80px; top:0px; line-height : 80px;">
		<!-- <button type="button" id="btnOpenSessionInfo" onclick="viewSessionInfo()">Session Info</button> -->
		
		<a href="javascript:XFN_LogOut();" class="topLogout" style="color: #666; font-size:12px;"><spring:message code='Cache.lbl_Logout' /></a>	
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
		var photoPath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", "");
		$("#userImg").attr("src", photoPath + Common.getSession("UR_Code") + ".jpg").on("error", coviCmn.imgError(this, true));
	})();
</script>