<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cssPathLocal = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_ProjectInfoPrint'/></h2>
	<button type="button" id="btPrint" style="" class="btnIcoComm btnPrint" onclick="openPrintView(); return false;"></button>
</div>
<div class="commIndividualInfoAdmin" id="TFInfoMain">
	<table class="pjtroom_info" cellpadding="0" cellspacing="0">
		<tbody>
		<tr>
			<th><span><spring:message code='Cache.lbl_TFProgress'/></span></th>
			<td>
				<p class="textBox" id="cState"></p>
			</td>
		</tr>
		<tr>
			<th><span><spring:message code='Cache.lbl_TFName'/></span></th>
			<td>
				<p class="textBox" id="cTFName"></p>
			</td>
		</tr>
		<tr>
			<th><span><spring:message code='Cache.lbl_Category_Folder'/></span></th>
			<td>
				<p class="textBox" id="cCategory"></p>
			</td>
		</tr>
		<tr>
			<th><span><spring:message code='Cache.lbl_HeadDept'/></span></th>
			<td>
				<p class="textBox" id="cMajorDept"></p>
			</td>
		</tr>
		<tr>
			<th><span><spring:message code='Cache.lbl_TFPeriod'/></span></th>
			<td>
				<span class="textBox" id="cStartDate"></span>~<span class="textBox" id="cEndDate"></span>(<spring:message code='Cache.lbl_total'/> <span class="textBox" id="cTFDate"></span><spring:message code='Cache.lbl_termmonth'/>)
			</td>
		</tr>
		<tr>
			<th><span><spring:message code='Cache.lbl_TFContent'/></span></th>
			<td>
				<p class="textBox" id="cSearchTitle"></p>
			</td>
		</tr>
		</tbody>
	</table>
	<p class="pjtroom_title"><spring:message code='Cache.lbl_ProgressReport'/></p>
	<div class="inputBoxSytel01 type02" id="TaskList"></div>
</div>
<script type="text/javascript">
//# sourceURL=TFPrintMain.jsp
var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
var activeKey = typeof(mActiveKey) == 'undefined' ? 1 : mActiveKey;	// 커뮤니티 메뉴 Key

$(function(){
	setCommunityPrintInfo();
});

function setCommunityPrintInfo(){
	var str = "";
	$.ajax({
		url:"/groupware/tf/getTFPrintData.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(data.TFInfo != undefined && data.TFInfo.length > 0) {
					var info = data.TFInfo[0];
					
					$("#cState").html(info.AppStatusName);
					$("#cTFName").html(info.CommunityName);
					$("#cCategory").html(info.TF_GUBUN);
					$("#cMajorDept").html(info.TF_MajorDept);
					
					$("#cStartDate").html(info.TF_StartDate);
					$("#cEndDate").html(info.TF_EndDate);
					
					var sDate = new Date(info.TF_StartDate.replaceAll(".", "/"));
					var eDate = new Date(info.TF_EndDate.replaceAll(".", "/"));
					$("#cTFDate").text(Math.floor((eDate - sDate)/(24 * 60 * 60 * 1000 * 30)) + 1);
					
					$("#cPM").html(getTFUserName(info.TF_PM));
					$("#cSearchTitle").html(unescape(info.Description).replace(/(\r\n|\n|\r)/g,"<br />"));
				}
				
				//html 그리기
				var StrHtml = '';
				StrHtml += "<table id='ProgressTable' class='ITMtrpfield_table'>";
				StrHtml += "<colgroup><col width='100'></col><col width='200'></col><col width='60'></col><col width='100'></col><col width='100'></col>";
				StrHtml += "<tbody><tr class='borderbottom'>";
				StrHtml += "<th class='HeaderCell'>"+Common.getDic("lbl_workname")+"</th>";
				StrHtml += "<th class='HeaderCell'>"+Common.getDic("lbl_scope")+"</th>";
				StrHtml += "<th class='HeaderCell'>"+Common.getDic("lbl_ProgressRate")+"</th>" ;
				StrHtml += "<th class='HeaderCell'>"+Common.getDic("lbl_task_performer")+"</th>" ;
				StrHtml += "<th class='HeaderCell RightLine'>"+Common.getDic("lbl_output")+"</th>" ;
				StrHtml += "</tr>";
				
				$.each(data.tasklist, function(idx,obj){
					StrHtml += "<tr>";
					StrHtml += "<td style='text-align:left;'>"+(obj.ParentName==""?obj.ATName: " - "+obj.ATName)+"</td>";
					StrHtml += "<td>"+obj.StartDate+"~"+obj.EndDate+"("+Common.getDic("lbl_total")+" "+obj.AT_Date+Common.getDic("lbl_termmonth")+")</td>";
					StrHtml += "<td>"+obj.Progress+"</td>";
					StrHtml += "<td>"+MemberDisplay(obj.AT_ID,data.memberlist)+"</td>";
					StrHtml += "<td>"+obj.FileName+"</td>";
					StrHtml += "</tr>";
				});
				
				StrHtml += "</tbody></table></td></tr>";
				$("#TaskList").html(StrHtml);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/getTFPrintData.do", response, status, error); 
		}
	});
}

function getTFUserName(data) {
	var result = "";
	var data = data.split("@");
	
	for(var i = 0; i < data.length; i++) {
		if(data[i] != "") {
			var temp = data[i];
			result += temp.split("|")[1] + ",";
		}
	}
	
	if(result.length > 0) {
		result = result.substring(0, result.length-1);
	}
	
	return result;
}

function MemberDisplay(pAT_ID, Objmemberlist){
	var returnText="";
	$(Objmemberlist).each(function(idx,obj){
		if(obj.AT_ID == pAT_ID){
			returnText += (returnText==""?"":",")+CFN_GetDicInfo(obj.MultiDisplayName);
		}
	});
	return returnText;
}

function setCurrentLocation(categoryID){
	var locationText= "";
	$.ajax({
		type:"POST",
		data:{
			"CategoryID" : categoryID
		},
		async : false,
		url:"/groupware/layout/userCommunity/setCurrentLocation.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					
					if(v.num == '1'){
						locationText += v.DisplayName;
					}else{
						if(data.list.length == 1){
							locationText += v.DisplayName;
						}else{
							locationText += v.DisplayName+" > ";
						}
					}
				});
			}
			$("#cCategoryNm").html(locationText);
			
		},
		error:function (error){
			CFN_ErrorAjax("/groupware/layout/community/setCurrentLocation.do", response, status, error);
		}
	});
}

function getTFUserName(data) {
	var result = "";
	var data = data.split("@");
	
	for(var i = 0; i < data.length; i++) {
		if(data[i] != "") {
			var temp = data[i];
			result += temp.split("|")[1] + ",";
		}
	}
	
	if(result.length > 0) {
		result = result.substring(0, result.length-1);
	}
	
	return result;
}

function G_displaySpnDocLinkInfo() {//수정본
	var szdoclinksinfo = "";
	var szdoclinks =  $("#hidDocLinks").val();
	szdoclinks = szdoclinks.replace("undefined^", "");
	szdoclinks = szdoclinks.replace("undefined", "");
	var bEdit = false; 
	//if (document.location.href.indexOf("Info.") > -1 || document.location.href.indexOf("InfoViewPopup.") > -1) {
	//	bEdit = false;
	//} else {
	//	bEdit = true;
	//}
	
	if (szdoclinks != "") {
		if (bEdit) {
			szdoclinksinfo += "<a onclick='openDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_linkdoc' />"+"</a>";
			szdoclinksinfo += "&nbsp;<a onclick='deleteDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_link_delete' />"+"</a><br />";
		}
		var adoclinks = szdoclinks.split("^^^");
		for (var i = 0; i < adoclinks.length; i++) {

			var adoc = adoclinks[i].split("@@@");
			var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
			var iWidth = 790;
			var iHeight = window.screen.height - 82;
			if (bEdit) {
					szdoclinksinfo += "<input type=checkbox id='chkDoc' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
					szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
			} else {
					szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
			}
		}
	}
	$("#docLinksList").html(szdoclinksinfo);
}

function openPrintView(){
	//Theme 타입 체크 후 적용
	var themeType = Common.getSession("UR_ThemeType");
		if(themeType == "" || themeType == undefined){
			themeType = "blue";
		}
	
	//인쇄용 팝업 호출
	var contentsHtml = window.open('', 'PRINT', 'height=768,width=1024');
	
	contentsHtml.document.write('<html><head><title>' + document.title  + '</title>');
	contentsHtml.document.write('<link rel="stylesheet" href="<%=cssPathLocal%>/covicore/resources/css/axisj/arongi/AXGrid.css" type="text/css" />');
	contentsHtml.document.write('<link rel="stylesheet" href="<%=cssPathLocal%>/covicore/resources/css/common.css" type="text/css" />');
	contentsHtml.document.write('<link rel="stylesheet" href="<%=cssPathLocal%>/community/resources/css/community.css" type="text/css" />');
	contentsHtml.document.write('<link rel="stylesheet" href="/HtmlSite/smarts4j_n/covicore/resources/css/theme/'+themeType+'.css" type="text/css" />');
	contentsHtml.document.write('<link rel="stylesheet" href="<%=cssPathLocal%>/IntegratedTaskManagement/resources/css/IntegratedTaskManagement.css" type="text/css" />');
	contentsHtml.document.write('</head><body >');
	contentsHtml.document.write('<div id="content"/>');
	contentsHtml.document.write('<div class="commIndividualInfoAdmin">');
	contentsHtml.document.write($("#TFInfoMain").html());
	contentsHtml.document.write('</div></div>');
	contentsHtml.document.write('</body></html>');
	
	contentsHtml.document.close();	// necessary for IE >= 10
	contentsHtml.focus(); 			// necessary for IE >= 10
	
	setTimeout(function(){
		contentsHtml.print();
		contentsHtml.close();
	}, 1000);
	
	return true;
}
</script>