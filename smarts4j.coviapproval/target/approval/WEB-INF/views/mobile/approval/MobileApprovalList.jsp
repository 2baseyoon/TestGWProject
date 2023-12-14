<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path");
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>
<jsp:include page="/WEB-INF/views/cmmn/include_mobile.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>
<script>
	var title;
	var url;
	var g_mode = CFN_GetQueryString("mode") == "undefined" ? "Approval" : CFN_GetQueryString("mode");
	var mode;
	var startPage;
	var mode  	= "";
	var gloct 	= "";
	var subkind = "";
	var userID  = "";
	var divId   = 0;
	var approvalCnt; // 개인결재함-미결함
	var processCnt; // 개인결재함-진행함
	var tcInfoCnt; // 개인결재함-참조/회람함
// 	var receiveCnt; // 부서결재함-수신함
	var deptTcInfoCnt; // 부서결재함-참조/회람함
	//
	$(document).ready(function (){
	//$('#test1').on('pageinit', function() {
		//일괄호출처리 2019.02
		switch (g_mode){
			case "Approval": title = "<spring:message code='Cache.lbl_apv_doc_approve2' />"; break;		// 미결함 
			case "Process": title = "<spring:message code='Cache.lbl_apv_doc_process2' />"; break;		// 진행함
			case "Complete": title = "<spring:message code='Cache.lbl_apv_doc_complete2' />"; break;		// 완료함
			case "Reject": title = "<spring:message code='Cache.lbl_apv_doc_reject2' />"; break;		// 반려함
			case "TCInfo": title = "<spring:message code='Cache.lbl_apv_doc_circulation' />"; break;	// 참조회람함
			case "DeptComplete": title = "<spring:message code='Cache.lbl_apv_doc_complete3' />"; break;		// 완료함
			case "ReceiveComplete": title = "<spring:message code='Cache.lbl_apv_doc_receiveprocess' />"; break;		// 수신처리함
			case "DeptTCInfo": title = "<spring:message code='Cache.lbl_apv_doc_circulation' />"; break;		// 참조/회람함
		}
		$("#titleNm").html(title);
		$("#searchInput").val("");
		//getApprovalListCount();
		//selectMenuList();
		setApprovalListData();
		setSelect(mode);
		swiperEvent();
		$(".ui-icon.ui-icon-arrow-d.ui-icon-shadow").hide();
		$(".ui-btn-inner").hide();
		$(".ui-loader.ui-corner-all.ui-body-a.ui-loader-default").hide();
	});

	function swiperEvent(){
		if(g_mode == "Approval"){ //미결함인경우 모바일터치 이벤트발생
			$("li").on("swiperight", function(e){
				$("[id^='divApproveAction']").hide();
				$(this).find(".app_list_table").css('margin-left','');
			});
			$("li").on("swipeleft", function(e){
				$("[id^='divApproveAction']").hide();
				$(".app_list_table").css('margin-left','');
				$(this).find(".app_list_table").css('margin-left','-112px');
			});
		}
	}
	//셀렉트박스 그리기
	function setSelect(mode){
		var dataSearch = clientGetApprovalListSelectData("selectSearchType", mode);
		if(dataSearch.status == "SUCCESS" && dataSearch.list && dataSearch.list.length > 0){
			$(dataSearch.list).each(function(index){
				$("#selectSearchType").append("<option value='"+this.optionValue+"'>"+this.optionText+"</option>");
			});
		}
	}
	// 안읽음표시 카운트
	function getApprovalListCount(){
		//개인-미결함
		$.ajax({
			url:"../user/getApprovalCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				approvalCnt = data.cnt;
			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getApprovalCnt.do", response, status, error);
			}
		});
		//개인-진행함
 		$.ajax({
 			url:"../user/getProcessCnt.do",
 			type:"post",
 			async:false,
 			success:function (data) {
 				processCnt = data.cnt;
 			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getProcessNotDocReadCnt.do", response, status, error);
			}
 		});		
		//개인-참조/회람함
		$.ajax({
			url:"../user/getTCInfoNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				tcInfoCnt = data.cnt;
			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getTCInfoNotDocReadCnt.do", response, status, error);
			}
		});

// 		//부서-수신함
// 		$.ajax({
// 			url:"../user/getDeptProcessNotDocReadCnt.do",
// 			type:"post",
// 			async:false,
// 			success:function (data) {
// 				receiveCnt = data.cnt;
// 			}
// 		});
		// 부서-참조/회람함
		$.ajax({
			url:"/approval/user/getDeptTCInfoNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				deptTcInfoCnt = data.cnt;
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getDeptTCInfoNotDocReadCnt.do", response, status, error);
			}
		});
	}

	function clickMenu(mode){
		location.href = "MobileApprovalList.do?mode="+mode+"";
	}
	// 메뉴그리기
	function selectMenuList(){
		$.ajax({
			url:"../mobile/getMobileMenuList.do",
			type:"post",
			async:false,
			success:function (data) {
				var menuStr = "";
				var listCount = "";
				
				for(var i=0; i<data.list.length; i++){
					var menuMode = data.list[i].MenuMode;
					var menuName = data.list[i].MenuName;
					
					if(menuMode == "User" || menuMode == "Dept"){
						menuStr += "<li><a href=\"#\" class=\"treemenu open\"></a><a href=\"#\" class=\"appmenu_ico01\">"+menuName+"</a></li>";
					}else{
						if(menuMode == "Approval" || menuMode == "Process" || menuMode == "TCInfo" || menuMode == "DeptTCInfo"){
							switch (menuMode) {
							case "Approval": listCount = approvalCnt; break;
							case "TCInfo": listCount = tcInfoCnt; break;
							case "DeptTCInfo": listCount = deptTcInfoCnt; break;
							case "Process" : listCount = processCnt; break;
							}
							
							menuStr += "<ul class=\"treemenu_list\"><li><a href=\"#\" class=\"treemenu\"><a href=\"#\" onclick='clickMenu(\""+menuMode+"\")'>"+menuName+"<span class=\"txt_number\">"+listCount+"</span></a></a></li></ul>";
						}else if(menuMode == "Complete" || menuMode == "Reject" || menuMode == "ReceiveComplete" || menuMode == "DeptTCInfo" || menuMode == "DeptComplete" ){
							menuStr += "<ul class=\"treemenu_list\"><li><a href=\"#\" class=\"treemenu\"><a href=\"#\" onclick='clickMenu(\""+menuMode+"\")'>"+menuName+"</a></a></li></ul>";
						}
					}
				}
				
				$("#menulist").html(menuStr);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("mobile/getMobileMenuList.do", response, status, error);
			}
		});
	}

	function setApprovalListData(){
		startPage = $("#txtInputGoPagepgnPaging").val();
		if(startPage == "null" || startPage == null){
			startPage = "1";
		}
		
		url = "/approval/mobile/getMobileApprovalListData.do?mode="+g_mode+""; 
		var sessionObj = Common.getSession(); //전체호출
		selectParams={
				"userID": sessionObj["USERID"],
				"deptID": sessionObj["DEPTID"],
				"searchGroupType":"Date", "pageNo":startPage, 
				"pageSize":"10", 
				"searchType":$("#selectSearchType").val(), 
				"searchWord":$("#searchInput").val()
		};
		
		$.ajax({
			url:url,
			type:"post",
			data:selectParams,
			async:false,
			success:function (data) {
				$("#mApprovalList").empty();
				if(data.list.length > 0){
					for(var i=0; i<data.list.length; i++){
						var html = "";
				        divId++;
				        html = "<li>";
						if(g_mode == "Approval" || g_mode == "Process"){
							html += "<a href=\"javascript:setApprovalView('"+data.list[i].ProcessID+"','"+data.list[i].WorkItemID+"','"+data.list[i].PerformerID+"','"+data.list[i].ProcessDescriptionID+"','"+data.list[i].FormSubKind+"','','','','','"+data.list[i].UserCode+"')\" class=\"li5_app_list\" id=\"test1\" onclick=''>";
						}else if(g_mode == "Complete" || g_mode == "Reject"){
							html += "<a href=\"javascript:setApprovalView('"+data.list[i].ProcessArchiveID+"','"+data.list[i].WorkitemArchiveID+"','"+data.list[i].PerformerID+"','"+data.list[i].ProcessDescriptionArchiveID+"','"+data.list[i].FormSubKind+"','','','','','"+data.list[i].UserCode+"')\" class=\"li5_app_list\" id=\"test1\" onclick=''>";
						}else if(g_mode == "TCInfo"){
							html += "<a href=\"javascript:setApprovalView('"+data.list[i].ProcessID+"','','','','','','"+data.list[i].FormInstID+"','','','"+data.list[i].UserCode+"')\" class=\"li5_app_list\" id=\"test1\" onclick=''>"
						}else if(g_mode == "DeptComplete" || g_mode == "ReceiveComplete"){
							html += "<a href=\"javascript:setDeptApprovalView('"+data.list[i].ProcessArchiveID+"','"+data.list[i].WorkitemArchiveID+"','"+data.list[i].PerformerID+"','"+data.list[i].ProcessDescriptionArchiveID+"','','','','"+data.list[i].UserCode+"')\" class=\"li5_app_list\" id=\"test1\" onclick=''>";
						}else{
							html += "<a href=\"javascript:setDeptApprovalView('"+data.list[i].ProcessID+"','','','','"+data.list[i].FormInstID+"','','"+data.list[i].FormSubKind+"','"+data.list[i].UserCode+"')\" class=\"li5_app_list\" id=\"test1\" onclick=''>";
						}
						html += "	<table class=\"app_list_table\" cellpadding=\"0\" cellspacing=\"0\">"
				         + "		<tbody>"
				         + "			<tr>";
				         if(data.list[i].IsFile == "Y"){
				        	 html += "            <td><div class=\"ellipsis\"><span class=\"app_list_p\">["+data.list[i].SubKind+"]</span><img class=\"img_ico\" src=\"<%=cssPath%>/mobile/Base/images/mail_icon03.png\">"+data.list[i].FormSubject+"</div>"
				         }else{
				        	 html += "            <td><div class=\"ellipsis\"><span class=\"app_list_p\">["+data.list[i].SubKind+"]</span>"+data.list[i].FormSubject+"</div>"
				         }
				         + "				<div class=\"ellipsis5\">";
				         if(g_mode == "Approval" || g_mode == "Process"){
				        	 html += "			    <p class=\"txt_style2\" style=\"margin-left:0px !important;\">"+data.list[i].FormName+"&nbsp;<span class=\"bar_gray2\">|</span>"+getStringDateToString(g_mode == "Approval"?data.list[i].Created:data.list[i].Finished)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorUnitName)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorName)+"</p></div></td></a>";
				         }else if(g_mode == "Complete" || g_mode == "Reject" || g_mode == "DeptComplete" || g_mode == "ReceiveComplete"){
				        	 html += "			    <p class=\"txt_style2\" style=\"margin-left:0px !important;\">"+data.list[i].FormName+"&nbsp;<span class=\"bar_gray2\">|</span>"+getStringDateToString(data.list[i].EndDate)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorUnitName)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorName)+"</p></div></td></a>";
				         }else if(g_mode == "DeptTCInfo"){
				        	 html += "			    <p class=\"txt_style2\" style=\"margin-left:0px !important;\">"+data.list[i].FormName+"&nbsp;<span class=\"bar_gray2\">|</span>"+getStringDateToString(data.list[i].ReceiptDate)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorUnitName)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorName)+"</p></div></td></a>";
				         }else{
				        	 html += "			    <p class=\"txt_style2\" style=\"margin-left:0px !important;\">"+data.list[i].FormName+"&nbsp;<span class=\"bar_gray2\">|</span>"+getStringDateToString(data.list[i].InitiatedDate)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorUnitName)+"&nbsp;<span class=\"bar_gray2\">I</span>"+CFN_GetDicInfo(data.list[i].InitiatorName)+"</p></div></td></a>";
				         }
				         
				         var strRejectBtnName = "";
				         var strApprovalBtnName = "";
				         
				         if(data.list[i].FormSubKind == "T009"){
				        	 strApprovalBtn = "<a href=\"#\" class=\"app_app\" id=\"btApproved\" onclick='buttonDisplay(this,\""+divId+"\",\""+data.list[i].FormSubKind+"\",\""+data.list[i].TaskID+"\" , false, \""+data.list[i].FormInstID+"\"); return false;'><spring:message code='Cache.lbl_apv_agree'/></a>";
				        	 strRejectBtn =  "<a href=\"#\" class=\"app_gb\" id=\"btReject\" onclick='buttonDisplay(this,\""+divId+"\",\""+data.list[i].FormSubKind+"\",\""+data.list[i].TaskID+"\", false, \""+data.list[i].FormInstID+"\"); return false;'><spring:message code='Cache.lbl_apv_disagree'/></a>";
				         }else{
				        	 strApprovalBtn = "<a href=\"#\" class=\"app_app\" id=\"btApproved\" onclick='buttonDisplay(this,\""+divId+"\",\""+data.list[i].FormSubKind+"\",\""+data.list[i].TaskID+"\", false, \""+data.list[i].FormInstID+"\"); return false;'><spring:message code='Cache.btn_apv_Approved'/></a>";
				        	 strRejectBtn =  "<a href=\"#\" class=\"app_gb\" id=\"btReject\" onclick='buttonDisplay(this,\""+divId+"\",\""+data.list[i].FormSubKind+"\",\""+data.list[i].TaskID+"\", true, \""+data.list[i].FormInstID+"\"); return false;'><spring:message code='Cache.lbl_apv_reject'/></a>";
				         }
				         
				         //html += "			        </div></td></a>"
				         html +="			        <td>"+strRejectBtn+strApprovalBtn+"</td>"
				         + "			    </tr>"
				         + "		</tbody>"
				         + "	</table>"
				         + "</li>"
				         + "<div class=\"app_layer\" id=\"divApproveAction"+divId+"\" style=\"display:none;\">"
				         + "<table class=\"write1\" id=\"table_pwd\" style=\"display: none;\" cellspacing=\"0\" cellpadding=\"0\">"
				         + "<tbody>"
				         + "<tr>"
				         + "<td width=\"120\" valign=\"top\" align=\"left\"><span class=\"app_list_p4\">"+ mobile_comm_getDic("lbl_apv_ApvPwd2") +"</span></td>"
				         + "<td valign=\"top\" align=\"left\"><input type=\"text\" style=\"height:40px; width:100%; background:#ffffff;\"></td>"
				         + "</tr>"
				         + "</tbody>"
				         + "</table>"
				         + "<table class=\"write1\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-bottom:0;\">"
				         + "<tbody>"
				         + "<tr>"
				         + "<td><textarea rows=\"10\" id=\"comment\" style=\"width:99%; font-size:1.5em;\"></textarea></td>"
				         + "</tr>"
				         + "</tbody>"
				         + "</table>"
				         + "<div class=\"s_btn_down\"><a class=\"stress\" href=\"#\" id=\"\" onclick='commentSetting(this,\""+data.list[i].FormSubKind+"\",\""+data.list[i].TaskID+"\", false, \""+data.list[i].FormInstID+"\");' ><span><spring:message code='Cache.btn_ok'/></span></a><a href=\"#\" onclick='buttonDisplay(this,\""+divId+"\"); return false;'><span><spring:message code='Cache.btn_Cancel'/></span></a></div>"
				         + "</div>";
					  $("#mApprovalList").append(html);
					  $("#DivLayer99999").hide();
					}
				}else{
					html = "<li style=\"text-align: center;\">"+ mobile_comm_getDic("msg_NoDataList") +"</li>"
					$("#mApprovalList").append(html);
					$("#DivLayer99999").hide();
				}
				$("#lastNum").html("&nbsp;/&nbsp;"+Math.ceil(data.cnt / 10));
				$("#lastNum").val(Math.ceil(data.cnt / 10));
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	function onClickSearchButton(){
		startPage = "1";
		setApprovalListData();
		$("#txtInputGoPagepgnPaging").val("1");
	}
	//확인,취소버튼 보기
	function buttonDisplay(pObj,num, subkind, taskid, isCommentValidation, formInstID){
		
		if($(pObj).attr("id") == "btApproved"){
			$("#divApproveAction"+num).find("#comment").attr("placeholder", "<spring:message code='Cache.msg_apv_commentApproval' />");
		}else if($(pObj).attr("id") == "btReject"){
			$("#divApproveAction"+num).find("#comment").attr("placeholder", "<spring:message code='Cache.msg_apv_commentReject' />");
		}
		
		if($("#divApproveAction"+num+"").css('display') == 'none'){
			$("#divApproveAction"+num+"").show();
			$("#typeCheck").val($(pObj).attr("id"));
			$(".stress").attr("id",$(pObj).attr("id"));
			$(".stress").attr("onclick", "commentSetting(this, "+num+", \""+subkind+"\",\""+taskid+"\", "+isCommentValidation+", \""+formInstID+"\");");
		}else{
			$("#divApproveAction"+num+"").hide();
			$("#typeCheck").val($(pObj).attr("id"));
			$("#divApproveAction"+num).find("#comment").val("");
		}
	}

	function getStringDateToString(date){
		return date.substring(5,7)+"."+date.substring(8,10);
	}

	function openMenu(id){
		if($("#DivLayer150").css('display') == 'none'){
			if($("#DivLayer99999").css('display') != 'none'){
				$("#DivLayer99999").hide();
			}
			
			// 버튼을 눌렀을 경우에 메뉴관련 데이터 가져오기
			getApprovalListCount();
			selectMenuList();
			
			$("#DivLayer150").show();
		}else{
			$("#DivLayer150").hide();
		}
	}

	function displayShow(id){
		if($("#"+id+"").css('display') == 'none'){
			$("#"+id+"").show();
		}else{
			$("#"+id+"").hide();
		}
	}
	// 맨위로가기
	function topScroll(pStrobjId, pMargin) {
	    var position = $("#" + pStrobjId).offset();
	    $('html,body').animate({ scrollTop: position.top + pMargin }, 1000);
	}

	function setApprovalView(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode) {
		var archived = "false";
		switch (g_mode){
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;
		}
		location.href = "../approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&isMobile=Y&menuMode="+g_mode+"";
	}

	function setDeptApprovalView(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,FormInstID,Mode,SubKind,UserCode){
		var archived = "true";
		switch (g_mode){
			case "DeptComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; userID = UserCode; break;
			case "ReceiveComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; userID = UserCode; break;
			case "DeptTCInfo" : mode = "COMPLETE"; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = ""; break;
		}
		location.href = "../approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&forminstanceID="+FormInstID+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&isMobile=Y&menuMode="+g_mode+"";
	}

	function goPageing(type){
		startPage 	 = $("#txtInputGoPagepgnPaging").val();
		var lastPage = $("#lastNum").val();
		if(type == "next"){
			if(parseInt(startPage) >= parseInt(lastPage)){
				return false;
			}
			startPage++;
			$("#txtInputGoPagepgnPaging").val(startPage);
			setApprovalListData();
		}else{
			if(parseInt(startPage) == 1){
				return false;
			}
			startPage--;
			$("#txtInputGoPagepgnPaging").val(startPage);
			setApprovalListData();
		}
		swiperEvent();
	}

	function commentSetting(pObj, num, SubKind,TaskID, isCommentValidation, formInstID){
		var actionMode;
		var mode = "APPROVAL";
		if($(pObj).attr("id") == "btApproved"){
			actionMode = "approved";
		}else{
			actionMode = "reject";
		}
		
		var strCommenet = $("#divApproveAction"+num).find("#comment").val();
		
		if(isCommentValidation){
			if(strCommenet != "" && strCommenet != undefined && strCommenet != null){
				approvalDoButtonAction(mode, SubKind, TaskID, actionMode, Base64.utf8_to_b64(strCommenet), formInstID, true);
			}else{
				alert("<spring:message code='Cache.msg_apv_064' />");
				return false;
			}
		}else{
			approvalDoButtonAction(mode, SubKind, TaskID, actionMode, Base64.utf8_to_b64(strCommenet), formInstID, true);
		}
	}

	function LogOut(){
		location.href = "/covicore/logout.do";
	}
</script>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi">
<body>
<form>
  <div class="wrap" id="test1">
    <div id="divMobileTop" class="">
      <!-- 상단 tit 시작 -->
      <div class="sub_top">
        <div class="sub_top_title"><a href="#"><spring:message code='Cache.lbl_apv_approval'/></a></div>
      </div>
      <!-- 상단 tit 끝 -->
      <!-- 본문 tit 시작 -->
      <div class="sub_title_box">
        <div class="sub_title_left"></div>
        <p class="sub_title" id="titleNm"></p>
        <div class="sub_title_right"><a href="javascript:openMenu();"><span><img src="<%=cssPath%>/mobile/Base/images/icon_treemenu.png" alt="" ></span></a></div>
      </div>
      <!-- 본문 tit 끝 -->
      <!-- 메뉴 시작 -->
      <div id="DivLayer150" class="treemenu_box" style="display:none;height:788px">
        <div class="treemenu_title_board"><a href="javascript:openMenu();" class="treemenu_close"></a></div>
        <div class="treemenu_in">
          <ul class="treemenu_list" id="menulist">
          </ul>
        </div>
      </div>
      <!-- 메뉴 끝 -->
      <!-- 리스트 시작 -->
      <table width="100%" cellpadding="0" cellspacing="0" border="0" class="tm_margin">
        <tbody>
          <tr>
            <td valign="top" bgcolor="FFFFFF"><section>
                <article>
                  <!-- 검색 버튼 시작 -->
                  <div class="s_btn_up"> <span class="btn_sr"><a class="btn_sr1" href="javascript:displayShow('DivLayer99999');"><span><img alt="" src="<%=cssPath%>/mobile/Base/images/sear.png"></span></a><a class="btn_sr2" href="#" onclick="location.reload();"><span><img alt="" src="<%=cssPath%>/mobile/Base/images/ref.png"></span></a></span></div>
                  <!-- 검색 버튼 끝 -->
                  <!-- 검색 레이어 시작 -->
                  <div class="list_search_box" id="DivLayer99999" style="display:none;">
                    <div class="list_search" >
                      <table cellspacing="0" cellpadding="0">
                        <tbody>
                          <tr>
                            <td width="120" align="left"><select id="selectSearchType" style="width:100%; height:35px; margin-top:3px; font-size:1.5em;"></select></td>
                            <td width="200" align="center" class="org_search_input"><input name="ctl00$ctl00$cphContent$cphContent$txtSearchText" id="searchInput" style="width:180px; height:35px; margin-top:3px; font-size:1.5em;" type="text"></td>
                            <td width="80" align="right"><div class="f_right"><a onclick="onClickSearchButton();"><span><img class="img_align" src="<%=cssPath%>/mobile/Base/images/btn_orz_search2.png"> <spring:message code='Cache.btn_search'/><!--검색--></span></a></div></td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <!-- 검색 레이어 끝 -->
                  <div class="li5_bg">
                    <ul class="li5" style="display:inline; overflow-x:hidden;" id="mApprovalList">
                    </ul>
                  </div>
                  <center>
                    <div class="pg" style="display: table;">
                      <table cellpadding="0" cellspacing="0">
                        <tbody>
                          <tr>
                            <td valign="top" align="left" width="70"><a href="javascript:goPageing('prev');" id="pervBtn"><img src="<%=cssPath%>/mobile/Base/images/btn_pg_left_dis.png" alt="Previous" class="btn_pg"></a></td>
                            <td valign="middle" width="50">
<!--                             	<input type="text" name="complete" id="txtInputGoPagepgnPaging" onKeyDown="javascript: (event.keyCode == 13 &amp;&amp; document.getElementById('txtInputGoPagepgnPaging').value != '') ? __doPostBack('ctl00$ctl00$cphContent$cphContent$pgnPaging', document.getElementById('txtInputGoPagepgnPaging').value) : void(0);" onKeyPress="CFN_CheckIsNum()" onKeyUp="CFN_PagingInputGoPage(this, 1)" style="margin-top:3px; width:40px; height:30px; border-radius:4px;" value="1"> -->
                            	<input type="text" name="complete" id="txtInputGoPagepgnPaging" onKeyDown="javascript: (event.keyCode == 13 &amp;&amp; document.getElementById('txtInputGoPagepgnPaging').value != '') ? __doPostBack('ctl00$ctl00$cphContent$cphContent$pgnPaging', document.getElementById('txtInputGoPagepgnPaging').value) : void(0);" onKeyPress="CFN_CheckIsNum()" onKeyUp="CFN_PagingInputGoPage(this, 1)" style="margin-top:3px; width:40px; height:30px; border-radius:4px;" value="1">
                            </td>
                            <td align="left"><span class="gray" id="lastNum"></span></td>
<!--                             <td valign="top" style="padding-left:10px" align="right"><a href="javascript:void(0);"><img src="<%=cssPath%>/Images/Mobile/Common/Controls/Paging/btn_pg_right_dis.png" alt="Next" class="btn_pg"></a></td> -->
							<td valign="top" style="padding-left:10px" align="right"><a href="javascript:goPageing('next');"><img src="<%=cssPath%>/mobile/Base/images/btn_pg_right_dis.png" alt="Next" class="btn_pg"></a></td>
                          </tr>
                        </tbody>
                      </table>
                      <span id="cphContent_cphContent_pgnPaging"></span></div>
                  </center>
                </article>
              </section></td>
          </tr>
        </tbody>
      </table>
      <!-- 리스트 끝 -->
    </div>
    <footer class="sub"><a href="javascript:LogOut();"><spring:message code='Cache.btn_Logout'/></a><span class="bar_gray">|</span> <a href="javascript:topScroll('divMobileTop', -50);"><spring:message code='Cache.lbl_Top'/></a>
      <p class="copylight">Copyright Covision All Rights Reserved</p>
    </footer>
  </div>
    <input type="hidden" id="typeCheck" value="">
    <textarea data-type="field" id="APVLIST" data-binding="pre" style="display:none"></textarea>
	<input type="hidden" data-type="field" id="PASSWORD" value="" />
	<input type="hidden" data-type="field" id="ACTIONINDEX" value="" />
	<input type="hidden" data-type="field" id="ACTIONCOMMENT" value="" />
	<input type="hidden" data-type="field" id="ACTIONCOMMENT_ATTACH" value="" />
	<input type="hidden" data-type="field" id="SIGNIMAGETYPE" value="" />
</form>
</body>