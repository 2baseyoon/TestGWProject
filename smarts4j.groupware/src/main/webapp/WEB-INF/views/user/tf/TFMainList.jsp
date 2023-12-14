<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String searchWordStatus = request.getParameter("searchWordStatus");
	String searchTypeStatus = request.getParameter("searchTypeStatus");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	
	String projectState = StringUtil.replaceNull(request.getParameter("projectState"),"");
%>

<style>
.selectBox .selectType02{
	width:170px;
}
.pjtroom_info{
	float: left;
	margin-top: -3px;
	width: 700px;
	text-align: center;
	border: 1px solid #c3d7df;
}
.pjtroom_info th{
	border: 1px solid #c3d7df;
	width: 70px !important;
}
.joinBtnDiv {
	text-align: center;
	padding-top: 4px;
}
</style>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_collaboration_list'/></h2><!-- 협업 룸 리스트 -->
	<div class="searchBox02">
		<span><input type="text" id="seValue"  onkeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}" /><button type="button" class="btnSearchType01" onclick="onClickSearchButton()"><spring:message code='Cache.lbl_search'/></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>
	</div>
</div>
<div class='cRContBottom mScrollVH surveyProgress'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>
				<select id="searchType" class="selectType02">
					<option value="A"><spring:message code='Cache.lbl_all'/></option>
					<option value="C"><spring:message code='Cache.lbl_tf_collaboration_name'/></option> <!-- 협업 명-->
					<option value="P"><spring:message code='Cache.lbl_tf_collaboration_pm'/></option> <!-- 협업  PM-->
					<option value="M"><spring:message code='Cache.lbl_task_performer'/></option> <!-- 수행자 -->
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text" onkeypress="if(event.keyCode==13) {goSearchDetail(); return false;}">
				</div>
			</div>
			<div>
				<a href="#" id="btnSearch" onclick="goSearchDetail()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a>
			</div>
		</div>	
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<table class="pjtroom_info" id="projectSts" style="display:none;">
			<tbody>
				<tr></tr> 
			</tbody>
		</table>
		<select class="selectType02" id="selectState">
		</select>
		<select class="selectType01" id="selectSize">
			<option>10</option>
			<option>15</option>
			<option>20</option>
			<option>30</option>
			<option>50</option>
		</select>
		<button href="#" class="btnRefresh" type="button" onclick="onClickSearchButton()"></button>
	</div>
	<div class="tblList tblCont">
		<form id="form1">
			<div id="gridDiv">
			</div>
		</form>
	</div>
</div>
<script type="text/javascript">
var searchWord = '<%=searchWord%>';
var searchType = '<%=searchType%>';

var g_sortColumn = '<%=sortColumn%>';
var g_sortDirectoin =  '<%=sortDirection%>';

var g_projectState = '<%=projectState%>';

var TFGrid = new coviGrid();
var msgHeaderData = "";
TFGrid.config.fitToWidthRightMargin=0;

var _tfDetailState = Common.getBaseCode("TFDetailState").CacheData;
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("TFListCnt")){
	pageSize = CFN_GetCookie("TFListCnt");
}

$("#selectSize").val(pageSize);

$(function(){
	$("#searchType").val(searchType == "null" ? "A" : searchType);
	searchWord = urlDecodeValue(searchWord);
	
	if(searchWord != "null" && searchWord != "" && searchWord != null){
		$("#seValue").val(searchWord);
	}else{
		$("#seValue").val("");
		searchWord = "";
	}	

	setTFGrid();
	setSelectState();
	setEvent();
});

function setSelectState() {
	$(_tfDetailState).each(function(){
		if(this.Code != ""){
			if(g_projectState != ""){
				if(g_projectState == this.Code){
					$("#selectState").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
				}
			}else{
				$("#selectState").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
			}
		}
	});
}

//폴더 그리드 세팅
function setTFGrid(){
	TFGrid.setGridHeader(GridHeader());
	selectTFList();
}

function selectTFList(){
	var sortColumn = "";
	var sortDicrection  = "";
	
	if(g_sortColumn != "null" && g_sortColumn != "" && g_sortColumn != null){
		sortColumn = g_sortColumn;
	}
	if(g_sortDirectoin != "null" && g_sortDirectoin != "" && g_sortDirectoin != null){
		sortDicrection = g_sortDirectoin;
	}
	
	//폴더 변경시 검색항목 초기화
	setTFGridConfig();
	
	TFGrid.bindGrid({
		ajaxUrl:"/groupware/layout/selectUserTFGridList.do",
		ajaxPars: {
			"searchWord" : searchWord,
			"searchType" : $("#searchType").val(),
			"AppStatus" : g_projectState,
			"SearchStatus" : $("#selectState").val(),
			"viewType" : "list",
			"sortColumn" : sortColumn,
			"sortDirection" : sortDicrection
		},
		onLoad:function(){
			$("#projectSts tr").empty();
			
			if(g_projectState === ''){
				var pjInfo = {};
				var totalCnt = 0;
				
				$(TFGrid.list).each(function(idx, item){
					var appStatus = item.AppStatus;
					
					if (pjInfo.hasOwnProperty(appStatus)) {
						pjInfo[appStatus] += 1;
					} else {
						pjInfo[appStatus] = 1;
					}
				});
				
				$(_tfDetailState).each(function(index, code){
					if (code.Code === code.CodeGroup) return;
					
					var cnt = pjInfo.hasOwnProperty(code.Code) ? pjInfo[code.Code] : 0;
					totalCnt += cnt;
					
					$("#projectSts tr").append($("<th/>", {"text" : CFN_GetDicInfo(this.MultiCodeName, lang)})).append($("<td/>", {"text": cnt}));
				});
				
				$("#projectSts tr").append("<th>Total</th><td>"+totalCnt+"</td>");
				$("#projectSts").removeAttr("style", "display:none");
			}
		}
	});
}

function setTFGridConfig(){
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:$("#selectSize").val()
		},
		paging : true,
		colHead:{},
		body:{
		}
	};
	
	TFGrid.setGridConfig(configObj);
}

function GridHeader(){
	var TFGridHeader;
	if(g_projectState != '' && false){
		TFGridHeader = [
			{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true, formatter:function(){ 
				return formatRowNum(this);
			}, sort:false},
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_tf_collaboration_name'/>",width:'2',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
					var html = String.format("<div title='{0}'><a href='#' onclick='javascript:OpenTFInfo({1});' style='text-decoration:none'>{0}</a></div>", CommunityName, this.item.CU_ID);
					return html;
				}}, 
				{key:'Description',  label:"<spring:message code='Cache.lbl_TFContent'/>",width:'3',align:'center',display:true, sort:false, formatter:function(){
					return String.format("<div title='{0}'>{0}</div>", unescape(this.item.Description));
				}},
				{key:'TF_PM',  label:"PM",width:'2',align:'center',display:true, formatter:function(){
					return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
				}},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_tf_collaboration_pm'/>",width:'2',align:'center',display:true},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_tf_attendance'/>",width:'1',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_TFProgress'/>",width:'1',align:'center',display:true},
			{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_Period'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
				formatter:function(){
					return CFN_TransLocalTime(this.item.RegRequestDate,_StandardServerDateFormat);
				}
			},
			{key:'UserCode',  label:'UserCode', align:'center' , display:false, hideFilter : 'Y'},
			{key:'CU_ID',  label:"<spring:message code='Cache.lbl_Move'/>",width:'1', display:true, sort:false, formatter:function () {
			// T/F 팀룸으로 이동
				var html = "";
				
				if(this.item.AppStatus == "RA" || this.item.AppStatus == "RD" || this.item.AppStatus == "UV"){ //개설신청:RA,개설거부:RD,개설승인:RV,폐쇄신청UA,폐쇄거부:UD,폐쇄승인:UV,복원RS
					html = String.format("<div></div>");
				}else{
 					html = String.format("<div title='{0}'><a href='#' onclick='javascript:goCommunitySite({1});' class='btnTypeDefault btnSearchBlue01'>{2}</a></div>", this.item.CommunityName, this.item.CU_ID, "<spring:message code='Cache.lbl_Move'/>");
				}
				
				return html;
			}}
		];
	}else{
		TFGridHeader = [
			{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'1', align:'center', display:true, formatter:function(){	 
				return formatRowNum(this);
			}, sort:false},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_tf_collaboration_name'/>",width:'2',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
				var html = "";
				if(this.item.AppStatus != "RA") {	//프로젝트가 진행중인 상태에서만 커뮤니티 검색가능
					html = "<a onclick='goCommunitySite(\""+this.item.CU_ID+"\"); return false;'>";
					html += CommunityName;
					html += "</a>";
				}else{	//진행중이 아닌경우 프로젝트 상세 팝업
					html = "<a onclick='OpenTFInfo(\""+this.item.CU_ID+"\"); return false;'>";
					html += CommunityName;
					html += "</a>";
				}
				
				return html; 
			}},
			{key:'TF_PM',  label:"<spring:message code='Cache.lbl_TFPM'/>",width:'2',align:'center',display:true, formatter:function(){
				return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
			}},  
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_tf_attendance'/>",width:'1',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_ProgressState'/>",width:'1',align:'center',display:true,
				formatter : function(){
					var returnHtml = "";
					var appStatus = this.item.AppStatus;
					var cuID = this.item.CU_ID;
					
					if(this.item.TF_PM_CODE == userCode){
						var selectObj = $('<select/>',{
							  "onchange" : "setTFStatus(this);"
							, "data-cuid" : cuID
							, "style": "width: 65px;"
						});
						
						$(_tfDetailState).each(function(index, code){
							if (code.Code !== code.CodeGroup) {
								var option = $('<option/>',{
									"text" : CFN_GetDicInfo(code.MultiCodeName, lang)
									,"value" : code.Code
									,"selected" : code.Code == appStatus ? true : false 
								});
								
								selectObj.append(option);
							}
						});
						
						returnHtml = selectObj[0].outerHTML;
					}else{
						returnHtml = this.item.AppStatusName;
					}
					
					return returnHtml;
				}
			},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_Period'/>",width:'2',align:'center',display:true},
			{key:'CU_ID',  label:"<spring:message code='Cache.lbl_tf_app_for_participation'/>",width:'1', display:true, sort:false, formatter:function () {
				var html = "";
				if(this.item.MEMBER_CNT == 0 && this.item.AppStatus === "RV"){
					html += "<div class='joinBtnDiv'>";
					html += "	<a href='#' class='btnTypeDefault' onclick='approvalJoinTf(this);' ";
					html += "		data-targetid='"+this.item.CU_ID+"' ";
					html += "		data-projectnm='"+this.item.CommunityName+"' ";
					html += "		data-mailaddress='"+this.item.TF_PM_MAIL+"' ";
					html += "		data-pmnm='"+this.item.TF_PM+"' ";
					html += "	>";
					html += "		<spring:message code='Cache.lbl_tf_app_for_participation'/>";
					html += "	</a>";
					html += "</div>";
				}
				return html;
			}}
		];
	}
	
	msgHeaderData = TFGridHeader;
	return TFGridHeader;
}

function onClickSearchButton(){
	searchWord = $("#seValue").val();
	searchType = $("#searchType").val();
	
	selectTFList();	
}

function goSearchDetail(){
	searchWord = $("#searchText").val();
	searchType = $("#searchType").val();
	
	selectTFList();	
}

function goCommunitySite(cID){
	 var specs = "left=10,top=10,width=1050,height=900";
	 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
	 //window.open("/groupware/layout/userTF/TFMain.do?C="+community, "TF"+community, specs);
	 window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID, "community", specs);
}

function OpenTFInfo(CU_ID) {
	Common.open("", "TFInfo"+CU_ID, "<spring:message code='Cache.lbl_TFView'/>", "/groupware/layout/goTFInfoViewPopup.do?CU_ID=" + CU_ID, "700px", "650px", "iframe");
}

function formatRowNum(pObj){
	return pObj.index+1;
}

function setEvent(){
	$("#selectSize").change(function(){
		CFN_SetCookieDay("TFListCnt", $(this).find("option:selected").val(), 31536000000);
		selectTFList();
	});
	
	$("#selectState").change(function(){
		selectTFList();
	});
	
	$('.btnDetails').unbind("click").bind("click",function(){
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
}

function approvalJoinTf(obj){
	Common.Confirm("<spring:message code='Cache.msg_tf_mail_send_confirm'/>","Confirm",function(result){ // 업무 참여신청 메일을 발송 하시겠습니까?
		if(result){
			var cuId = $(obj).data("targetid");
			var projectNm = $(obj).data("projectnm");
			var userNm = CFN_GetDicInfo(Common.getSession("UR_MultiName"));
			var userMail = Common.getSession("UR_Mail");	// 발신인 메일
			
			var arrTo = []; // 받는 사람
			var receiver = new Object();
			receiver['UserName'] =$(obj).data("pmnm");
			receiver['MailAddress'] = $(obj).data("mailaddress");
			arrTo.push(receiver);
			
			var specs  = "left=10,top=10,width=1050,height=900";
				specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
			var contentLink  = "<a href='/groupware/layout/userCommunity/communityMain.do?C="+cuId+"' ";
				contentLink += "onclick='window.open(this.href,\"community\",\""+specs+"\"); return false;'>";
				contentLink += projectNm;
				contentLink += "</a>";
			var content = String.format(Common.getDic("msg_TFJoinMail_Content"),userNm,projectNm,contentLink);
			var text = content.replace(/\\n/gi,'</br>');
			
			var params = {
				"subject" : String.format("<spring:message code='Cache.msg_TFJoinMail_Subject'/>",projectNm,userNm)	//제목
				,"to" : arrTo // 받는 사람
				,"content" : text
				,"contentText" : content 
				,"sentSaveYn" : 'Y' // 보낸메일함 저장 여부(Y: 저장 N: 저장안함)
				,"from" : userMail // 보낸 사람
				,"userMail" : userMail // 발신인 메일 주소
				,"userName" : userNm // 발신인 이름
			}
			
			$.ajax({
				type : "POST",
				data: JSON.stringify(params),
				contentType: "application/json",
				dataType: "json",
				url : "/mail/userMail/simpleMailSent.do",
				success:function (data) {
					if(data.resultTy == "S"){
						Common.Inform("<spring:message code='Cache.msg_tf_mail_send_ok'/>");	//참여신청 되었습니다.
					}
				},
				error:function(response, status, error) {
					CFN_ErrorAjax("/mail/userMail/simpleMailSent.do", response, status, error);
				}
				
			});
		}
	});
}

function setTFStatus(obj){
	var cID = $(obj).data("cuid");
	var appStatus = $(obj).val();
	$.ajax({
		url: "/groupware/layout/userCommunity/setCommunityStatus.do",
		type: "post",
		data: {
			"CU_ID": cID,
			"RegStatus": "R",
			"AppStatus": appStatus,
			"txtOperator": Common.getSession('UserCode')
		},
		success: function(data){
			if(data.status == "SUCCESS"){
				var statusName = "";
				Common.Inform("<spring:message code='Cache.msg_ProcessOk' />"); // 요청하신 작업이 정상적으로 처리되었습니다.
				selectTFList();
				initLeft();
			}else{
				Common.Inform("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/biztask/getHomeProjectListData.do", response, status, error);
		}
	});
}
</script>