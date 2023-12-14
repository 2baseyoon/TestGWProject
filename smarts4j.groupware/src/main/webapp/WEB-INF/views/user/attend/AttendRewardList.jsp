<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper, 
																							egovframework.coviframework.util.RedisDataUtil, 
																							egovframework.coviframework.util.DicHelper,
																							egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
.AXGrid input:disabled { background-color:#Eaeaea; }
.tblList .AXGrid .AXgridScrollBody .AXGridColHead .colHeadTable tbody tr td { border-left:1px solid #e0e0e0; }
.tblList .AXGrid .AXgridScrollBody .AXGridColHead .colHeadTable tbody tr td:first-child { border-left:0; }
.gray{background-color:#F5F5F5; height:inherit; line-height:40px !important}
</style>
	<div class="cRConTop titType AtnTop">
		<h2 class="title"><spring:message code='Cache.lbl_n_att_rewardVac'/><spring:message code='Cache.TodoCategory_Admin'/></h2>	
		<span id="divDate" >
			<h2 class="title" id="dateTitle"></h2>
		    <div class="pagingType02">
		        <a class="pre"></a>
		        <a class="next"></a>
		    </div>
	        <span class="dateTip" title="<%=RedisDataUtil.getBaseCodeGroupDic("RewardPeriod").get( RedisDataUtil.getBaseConfig("RewardPeriod"))%> <spring:message code='Cache.lbl_BaseDate'/>  : <%=RedisDataUtil.getBaseConfig("RewardStandardDay")%> 일">
	        	<%=(!RedisDataUtil.getBaseConfig("RewardYn").equals("Y")?"보상휴가가 설정되지 않았습니다.":
	        		DicHelper.getDic("lbl_SetPeriod")+"["+RedisDataUtil.getBaseCodeGroupDic("RewardPeriod").get( RedisDataUtil.getBaseConfig("RewardPeriod"))+"]"
	        		 )%> 
	        </span>
		</span>
		<div class="searchBox02">
			<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.btn_search'/></button></span> <!-- 검색 -->
		</div>
	</div>  
	<div class="cRContBottom mScrollVH">
		<div class="ATMCont">
			<div class="ATMTopCont">
				<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
					<select class="selectType02" id="deptList">
					</select>
					<a href="#" class="btnTypeDefault  btnTypeChk" id="btnApproval" style="display:none"><spring:message code="Cache.lbl_apv_Approved" /></a>
					<a href="#" class="btnTypeDefault" id="btnReject" style="display:none"><spring:message code="Cache.lbl_Reject" /></a>
					<!-- 템플릿 선택 레이어 팝업 시작 -->
					<div class="ATMgt_Work_Popup" id="divWork" style="width:282px; left:170px; z-index:105;display:none">
						<a onclick='$("#divWork").hide()' class="Btn_Popup_close"></a>
						<div class="ATMgt_Cont">
							<div class="WTemp_search_wrap"><textarea id="ApprovalComment" name="ApprovalComment" class="ATMgt_Tarea"></textarea>
							<div class="bottom">
								<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnSaveApproval"><spring:message code="Cache.lbl_apv_Approved"/></a>
								<a href="#" class="btnTypeDefault" id="btnSaveReject"><spring:message code="Cache.lbl_Reject"/></a>
								<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.lbl_closed"/></a>
							</div>
						</div>
					</div>
					<!-- 템플릿 선택 레이어 팝업 끝 
						<span  class="dateSel type02"> 최대 근로시간 대비 초과하는 연장근로 시간에 대해  
							동안 발생 가능한 갯수를 표기합니다.</span>-->
					</div>	
					<div class="pagingType02 buttonStyleBoxRight" id="selectBoxDiv"> 	
						<a class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.btn_ExcelDownload"/></a>
						<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
						<select class="selectType02 listCount" id="listCntSel">
							<option value="10" selected>10</option>
							<option value="15">15</option>
							<option value="20">20</option>
							<option value="30">30</option>
							<option value="50">50</option>
							<option value="100">100</option>
						</select>
					</div>
				</div>
				<div class="tblList">
					<div id="gridDiv"></div>
				</div>
				<div class="pagingType02">
					<div class="TimeBox">
					    <span><spring:message code="Cache.lbl_Weekly"/> : <%=AttendUtils.maskTime(RedisDataUtil.getBaseConfig("NightStartTime"))%> ~ <%=AttendUtils.maskTime(RedisDataUtil.getBaseConfig("NightEndTime"))%></span>
					    <span><spring:message code="Cache.lbl_night"/> : 00:00 ~ <%=AttendUtils.maskTime(RedisDataUtil.getBaseConfig("NightStartTime"))%> / <%=AttendUtils.maskTime(RedisDataUtil.getBaseConfig("NightEndTime"))%> ~ 23:59</span>
					</div>
		        	<div id=rewardInfo class="mt15"></div>
		        </div>	
			</div>
		</div>
	</div>
<input type="hidden" id="RewardMonth" value="" />
<input type="hidden" id="pageNo" value="1" />
<script>
	var g_standDay  = AttendUtils.paddingStr("<%=RedisDataUtil.getBaseConfig("RewardStandardDay")%>", "R", "0",2);
	var g_standDate = CFN_GetLocalCurrentDate("yyyy.MM");
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("AttListCnt")){
		pageSize = CFN_GetCookie("AttListCnt");
	}
	if(pageSize===null||pageSize===""||pageSize==="undefined"){
		pageSize=10;
	}

	$("#listCntSel").val(pageSize);
	
	// 그리드 세팅
	var grid = new coviGrid();

	var headerData = [ 
           {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox',display:false, disabled: function (){
        	    return (this.item.Status!==null||parseFloat(this.item.RewardDay)===0);
           	}},
			{key:'DeptName',  label:'<spring:message code="Cache.NumberFieldType_DeptName" />', width:'70', align:'center'},
			{key:'URName',			label:"<spring:message code='Cache.ObjectType_UR' />",			width:'60', align:'left',
				formatter : function () {
					return String.format("<a onclick='javascript:openAttendRewardPopup(\"{1}\",\"{2}\",\"{3}\", \"{4}\");' ><font color=blue><u>{0}</u></a>", this.item.URName, this.item.UserCode, this.item.StartDate, this.item.EndDate, this.item.URName);
				}
			},	
			{key:'RewardMonth',  label:'<spring:message code="Cache.ACC_lbl_applicationDate" />', width:'70', align:'center',display:false,	
				formatter : function () {
					return String.format("<a onclick='javascript:openAttendRewardPopup(\"{1}\",\"{2}\",\"{3}\", \"{4}\");' ><font color=blue><u>{0}</u></a>", this.item.RewardMonth.substring(0,4)+"."+this.item.RewardMonth.substring(4,6), this.item.UserCode, this.item.StartDate, this.item.EndDate, this.item.URName);
				}
			}, 
			{key:'StartDate',			label:"<spring:message code='Cache.lbl_scope' />",			width:'120', align:'center',	display:false,	//사용유무
				formatter : function () {
	           		 return ""+AttendUtils.maskDate(this.item.StartDate)+"~"+AttendUtils.maskDate(this.item.EndDate)+"";
				}
			},
			{key:'AttAc',  label:"<spring:message code='Cache.lbl_att_ac_time' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.AttAc,'H')+"";
				}
			},
			{key:'ExtenAc',  label:"<spring:message code='Cache.lbl_sum' />", width:'50', align:'center',addClass: function() {	if (this.item.ExtenAc>0) return "gray";},
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.ExtenAc,'H')+"";
				}
			},
			{key:'ExtenDAc',  label:"<spring:message code='Cache.lbl_Weekly' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.ExtenDAc,'H')+"";
				}
			},
			{key:'ExtenNAc',  label:"<spring:message code='Cache.lbl_night' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.ExtenNAc,'H')+"";
				}
			},
			{key:'ExtenRewardTime',  label:"<spring:message code='Cache.lbl_n_att_compensation' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.ExtenRewardTime,'H')+"";
				}
			},
			{key:'HoliAc',  label:"<spring:message code='Cache.lbl_sum' />", width:'50', align:'center',addClass: function() {	if (this.item.HoliAc>0) return "gray";},
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.HoliAc,'H')+"";
				}
			},
			{key:'HoliDAc',  label:"<spring:message code='Cache.lbl_Weekly' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.HoliDAc,'H')+"</u></font></a>";
				}
			},
			{key:'HoliNAc',  label:"<spring:message code='Cache.lbl_night' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.HoliNAc,'H')+"</u></font></a>";
				}
			},
			{key:'HoliRewardTime',  label:"<spring:message code='Cache.lbl_n_att_compensation' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.HoliRewardTime,'H')+"";
				}
			},
			{key:'OffAc',  label:"<spring:message code='Cache.lbl_sum' />", width:'50', align:'center',addClass: function() {	if (this.item.OffAc>0) return "gray";},
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.OffAc,'H')+"";
				}
			},
			{key:'OffDAc',  label:"<spring:message code='Cache.lbl_Weekly' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.OffDAc,'H')+"</u></font></a>";
				}
			},
			{key:'OffNAc',  label:"<spring:message code='Cache.lbl_night' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.OffNAc,'H')+"</u></font></a>";
				}
			},
			{key:'OffRewardTime',  label:"<spring:message code='Cache.lbl_n_att_compensation' />", width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.OffRewardTime,'H')+"";
				}
			},
			{key:'CarryTime',  label:'<spring:message code="Cache.lbl_carryTime" />', width:'50', align:'center', display:false,
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.CarryTime,'H')+"";
				}
			},
			{key:'RewardTime',  label:'<spring:message code="Cache.lbl_compTime" />', width:'50', align:'center',
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.RewardTime,'H')+"</u></font></a>";
				}},
			{key:'RewardDay',  label:'<spring:message code="Cache.mag_Attendance42" />', width:'50', align:'center', display:false,//발생가능
				formatter : function () {
	           		 return ""+(this.item.RewardDay)+"</u></font></a>";
				}
			},
			{key:'RewardVacDay',  label:'<spring:message code="Cache.mag_Attendance43" />', width:'50', align:'center', display:false}, //생성갯수
			{key:'RemainTime',  label:'<spring:message code="Cache.lbl_remainTime" />', width:'50', align:'center',display:false,
				formatter : function () {
	           		 return ""+AttendUtils.convertSecToStr(this.item.RemainTime,'H')+"</u></font></a>";
				}},
			{key:'Comment',  label:'<spring:message code="Cache.lbl_sms_send_contents" />', width:'100', align:'left',display:false},
			{key:'ReqName',  label:'<spring:message code="Cache.TodoMsgType_Approval" />', width:'120', align:'center',display:false,
				formatter : function () {
					if (this.item.Status==null&&parseFloat(this.item.RewardDay)>0){ //승인요청
						return "<a class='btn_Ok' id='btnOk'><spring:message code='Cache.lbl_apv_Approved'/></a><a class='btn_No' id='btnNo'><spring:message code='Cache.lbl_Reject'/></a>";
					}	
					else if(parseFloat(this.item.RewardDay)>0){
						return "<a class='btn_Approval' href='#'>"+this.item.StatusName+"</a>";
					}else{
						return "";
					}
				}
			}
	];
	
	$(document).ready(function(){
		AttendUtils.getDeptList($("#deptList"),'', false, false, true);
		if ("<%=RedisDataUtil.getBaseConfig("RewardYn")%>" == "Y"){
			$.ajax({
				url : "/groupware/attendReward/getAttendRewardInfo.do",
				type: "POST",
				success:function (json) {
					
					json.data.map(function (item, i) {
						let html="<span class='boxDivTit'>";
						switch (item.HolidayFlag){
						case "1": //연장
							html += "<spring:message code='Cache.msg_n_att_companySetting14'/>";
							break;
						case "0":	//휴일
							html += "<spring:message code='Cache.lbl_n_att_calculationHoliday'/>";
							break;
						default:	//휴뮤
							html += "<spring:message code='Cache.lbl_n_att_calculationOff'/>";
							break;
						}
						html +=  " : "+item.OverTime +"<spring:message code='Cache.lbl_n_att_excessOfMin'/>  "+
						"[ <spring:message code='Cache.lbl_Weekly'/> x "+ item.RewardTime+ ""+
						"/<spring:message code='Cache.lbl_night'/> x "+ item.RewardNTime+"]</span>";
						$("#rewardInfo").append(html);
					});
				},
				error:function (error){	}
			});
		}
		
		var configObj = {
				targetID : "gridDiv",
				height : "auto",
				page : {
					pageNo: 1,
					pageSize: $("#listCntSel").val(),
				},
				colHead: { // 예제) http://dev.axisj.com/samples/AXGrid/colhead.html
			        rows: [ // 컬럼 헤더를 병합할 수 있습니다. 사용법은 colGroup과 동일하며 key 대신 colSeq를 사용할 수 있습니다.
			                [
			                    {colSeq:0, rowspan:2},
			                    {colSeq:1, rowspan:2},
			                    {colSeq:2, rowspan:2},
			                    {colSeq:3, rowspan:2},
			                    {colSeq:4, rowspan:2},
			                    {colSeq:5, rowspan:2},
			                    {colSeq:6, colspan:4, label:"<spring:message code='Cache.lbl_over' />", align:"center"},
			                    {colSeq:10, colspan:4, label:"<spring:message code='Cache.lbl_Holiday' />", align:"center"},
			                    {colSeq:14, colspan:4, label:"<spring:message code='Cache.lbl_att_sch_holidaySts' />", align:"center"},
			                    {colSeq:18, rowspan:2},
			                    {colSeq:19, rowspan:2}
			                ],
			                [  {colSeq:6},{colSeq:7},{colSeq:8},{colSeq:9}
			                	,{colSeq:10},{colSeq:11},{colSeq:12},{colSeq:13}
			                	,{colSeq:14},{colSeq:15},{colSeq:16},{colSeq:17}]
			            ],
			            onclick: function(){} // {Function} -- 그리드의 컬럼 헤드를 클릭시 발생하는 이벤트 입니다. 아래 onclick 함수를 참고하세요.
			        },
				paging : true,
			};
			
		grid.setGridHeader(headerData);
		grid.setGridConfig(configObj);

		
		if ($("#RewardMonth").val()==""){
			settingTerm(g_standDate, 0);
		}

		setPage(1);		
		
		$("#deptList,#listCntSel").change(function(){
			setPage(1);
			CFN_SetCookieDay("AttListCnt", $("#listCntSel option:selected").val(), 31536000000);
		});
		
		//검색
		$("#btnRefresh, #btnSearch").click(function(){
			setPage(1);
		});
		
		//이전
		$(".pre").click(function(){
			settingTerm($("#RewardMonth").val(), -1);
			setPage(1);
		});
		
		//이후
		$(".next").click(function(){
			
			settingTerm($("#RewardMonth").val(), 1);
			setPage(1);
		});
		
		//승인
		$("#btnApproval").click(function(){
			if(!validationChk())     	return ;
			gMode = "";
			$("#ApprovalComment").val("");
			$("#divWork").show();
			$("#btnSaveApproval").show();
			$("#btnSaveReject").hide();
		});	

		$("#btnSaveApproval").click(function(){
			if(gMode == "" && !validationChk())     	return ;
			Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					var aJsonArray = new Array();
					if (gMode == ""){
						var selectObj = grid.getCheckedList(0);
						for(var i=0; i<selectObj.length; i++){
							aJsonArray.push(selectObj[i]);
						}
					}
					else{
						aJsonArray.push(grid.getSelectedItem()["item"]);
					}
					
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
						url:"/groupware/attendReward/createAttendReward.do",
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
								searchData(-1);
								$("#divWork").hide();
							}
							else{
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (request,status,error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
						}
					});
				}	
			});				
		});
		

		//거부
		$("#btnReject").click(function(){
			if(!validationChk())     	return ;
			gMode = "";
			$("#ApprovalComment").val("");
			$("#divWork").show();
			$("#btnSaveApproval").hide();
			$("#btnSaveReject").show();
		});	
		
		//거부
		$("#btnSaveReject").click(function(){
			if(gMode == "" && !validationChk())     	return ;
			Common.Confirm("<spring:message code='Cache.msg_RUReject' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					var aJsonArray = new Array();
					if (gMode == ""){
						var selectObj = grid.getCheckedList(0);
						for(var i=0; i<selectObj.length; i++){
	                        aJsonArray.push(selectObj[i]);
						}
					}
					else{
						aJsonArray.push(grid.getSelectedItem()["item"]);
					}

					
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
						url:"/groupware/attendReward/cancelAttendReward.do",
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
								searchData(-1);
								$("#divWork").hide();
							}
							else{
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (request,status,error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
						}
					});
				}	
			});				
		});

		//사용자명 검색
		$("#searchText").on('keypress', function(e){
			if (e.which == 13) {
				setPage(1);
			}
		});
		
		

		//엑셀다운
		$("#btnExcelDown").click(function(){
			var params = "mode=L"+
				 "&RewardMonth="+ $("#RewardMonth").val()+ 
				 "&searchText="+ $("#searchText").val()+
				 "&DeptCode="+$("#deptList").val() ;
			AttendUtils.gridToExcel("<spring:message code='Cache.mag_Attendance44' />", headerData, params, "/groupware/attendReward/downloadExcel.do"); //근무일정목록
		});
	});
	
	
	function setPage (n) {
		$("#pageNo").val(n);
		searchData();
	}
	
	function settingTerm(startDate, term){

		var startDateObj = new Date(replaceDate(startDate+".01"));

		var sDate = schedule_SetDateFormat(new Date(startDateObj.getFullYear(), startDateObj.getMonth()+term, 1), '.').substring(0,7);

        $("#RewardMonth").val(AttendUtils.maskDate(sDate));
		$("#dateTitle").text ($("#RewardMonth").val() );
	}
	
	function searchData(){

		var params = {"RewardMonth": $("#RewardMonth").val() 
					 ,"searchText": $("#searchText").val()
					, "DeptCode":$("#deptList").val()
					, "pageNo" : $("#pageNo").val()
					, "pageSize": $("#listCntSel").val() };
		
		grid.page.pageNo = 1;
		grid.page.pageSize = $("#listCntSel").val();

		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendReward/getAttendRewardList.do"
		});

	}
	
	$(document).on("click","#btnOk",function(){
		gMode="DIV";
		$("#ApprovalComment").val("");
		$("#divWork").show();
		$("#btnSaveApproval").show();
		$("#btnSaveReject").hide();
	});
	
	$(document).on("click","#btnNo",function(){
		gMode="DIV";
		$("#ApprovalComment").val("");
		$("#divWork").show();
		$("#btnSaveApproval").hide();
		$("#btnSaveReject").show();
		
	});
	
	function openAttendRewardPopup(UserCode, StartDate, EndDate, URName){
		var popupID		= "AttendRewardPopup";
		var openerID	= "AttendRewardList";
		var popupTit	= URName+"&nbsp;"+"<spring:message code='Cache.lbl_n_att_rewardVac' />";
		var popupYN		= "N";
		var popupUrl	= "/groupware/attendReward/AttendRewardPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "StartDate="	+ StartDate	+ "&"
						+ "EndDate="	+ EndDate	+ "&"
						+ "UserCode="	+ UserCode	+ "&"
		
		Common.open("", popupID, popupTit, popupUrl, "950px", "600px", "iframe", true, null, null, true);
	}

	function validationChk(){
		var listobj = grid.getCheckedList(0);
		var aJsonArray = new Array();
		if(listobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
			return false;
		}
		return true;
	}

</script>
