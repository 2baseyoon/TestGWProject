<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<style>
.AXGrid input:disabled { background-color:#Eaeaea; }
.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic'; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
.AXanchorDateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
.adLine { display:inline-block; vertical-align:middle; width:15px; font-size:24px; font-weight:600; }
#divDate { margin-top:-3px; }
.pagingType02 { margin-left:2px; }
</style>
	<div class="cRConTop titType AtnTop">
		<h2 class="title"><spring:message code='Cache.lbl_MyRequestList'/></h2>	
		<div id="divDate" >
			<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span>  
			<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly>
		</div>		
		<div class="pagingType02">       
			<a href="#" class="calendartoday btnTypeDefault"><spring:message code="Cache.btn_Today"/></a> <!-- 오늘 -->
		</div> 						
											
	</div>  
	<div class="cRContBottom mScrollVH">
		<div class="ATMCont">
			<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<a href="#" class="btnTypeDefault" id="btnCancel"><spring:message code="Cache.lbl_CancelRequest"/></a>
  				<a href="#" class="btnTypeDefault" id="btnDelete"><spring:message code="Cache.lbl_delete"/></a>
				<span class="TopCont_option">
					<input id="ExReqMethod" value="Approval" type="checkbox" checked>
					<label for=ExReqMethod><spring:message code="Cache.lbl_ApprovalEx"/></label><!-- 전자결재건 제외-->
				</span>
			</div>
			<div class="pagingType02 buttonStyleBoxRight" id="selectBoxDiv"> 
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
			<!-- 승인 의견 레이어 팝업 시작-->
			<div class="layer_divpop" style="width:440px; left:170px; z-index:104;display:none"  id="divWork">
				<div class="divpop_contents">
					<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico"><spring:message code="Cache.lbl_apv_comment_write"/></span></h4><a onclick='$("#divWork").hide()'  class="divpop_close" style="cursor:pointer;"></a></div>
					<div class="divpop_body" style="overflow:hidden; padding:0;">
						<div class="ATMgt_popup_wrap">
							<div class="ATMgt_opinion_wrap">
								<table class="ATMgt_popup_table" cellpadding="0" cellspacing="0">
									<tbody>
										<tr>	
											<td class="ATMgt_T_th"><spring:message code="Cache.lbl_comment"/></td>
											<td><textarea id="ApprovalComment" name="ApprovalComment" class="ATMgt_Tarea"  cols="30" rows="40"></textarea>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="bottom">
								<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnSaveCancel"><spring:message code="Cache.lbl_CancelRequest"/></a>
								<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.lbl_close"/></a>
							</div>
						</div>
					</div>
				</div>
			</div>	
			<!-- 템플릿 선택 레이어 팝업 끝 -->
		</div>
		<div class="tblList noneOver">
			<div id="gridDiv"></div>
		</div>
	</div>
</div>
<script>
	var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
	var gMode = "";
	var page = 1;
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
           {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', disabled: function (){
        	    return this.item.ReqStatus!=='ApprovalRequest';
           }},
			{key:'ReqName',			label:"<spring:message code='Cache.lbl_SchDivision' />",			width:'90', align:'center'},		//요청종류
			{key:'URName',  label:'<spring:message code="Cache.lbl_RequestUser" />', width:'90', align:'center'}, 	//요청자
			{key:'ReqTitle',  label:'<spring:message code="Cache.lbl_Title" />', width:'250', align:'left',
				formatter : function () {
	           		 return "<a id='reqInfo' data-map='" + JSON.stringify(this.item) + "' class='gridLink'>"+this.item.ReqTitle+"</a>";
				}
			},
			{key:'Comment',  label:'<spring:message code="Cache.lbl_sms_send_contents" />', width:'250', align:'left',
				formatter : function () {
	           		 return this.item.Comment;
				}
			},
			{key:'StatusName',  label:'<spring:message code="Cache.lbl_VendorStatus" />', width:'70', align:'center',
				formatter : function () {
					var className = "";
					switch (this.item.ReqStatus)
					{
						case "ApprovalRequest": //승인요청
							className ="stay";
							break;
						case "Approval": //완료
							className ="comp";
							break;
						case "Reject"://반려
							className ="stay";
							break;
						case "ApprovalCancel"://신청철회
							className ="stay";
							break;
					}
	           		 return "<p class='tx_status "+className+"'>"+this.item.StatusName+"</p>";
				}
			},
			{key:'ReqDate',  label:'<spring:message code="Cache.lbl_Application_Day" />', width:'120', align:'center', 
				formatter : function () {return AttendUtils.maskDateTime(CFN_TransLocalTime(this.item.ReqDate))}},
			{key:'ReqName',  label:'<spring:message code="Cache.TodoMsgType_Approval" />', width:'120', align:'center', sort:false,
				formatter : function () {
					if (this.item.ReqMethod == "Request"){
						if (this.item.ReqStatus== "ApprovalRequest"){ //승인요청
							return "<a class='btn_No' id='btnNo'><spring:message code='Cache.lbl_CancelRequest'/></a>";
						}	
						else{
							return "<a class='btn_Approval' style='cursor:default;'>"+this.item.StatusName+"</a>";
						}
					}	 
					else if (this.item.ReqMethod == "Approval"){
						return "<a class='btn_Approval' style='cursor:default;'><spring:message code='Cache.lbl_apv_approval'/></a>";
					}
					else{
						return "<a class='btn_Approval' style='cursor:default;'><spring:message code='Cache.CommunityJoin_D'/></a>";
					}
				}
			}
	];
	
	$(document).ready(function(){
		var configObj = {
				targetID : "gridDiv",
				height : "auto",
				page : {
					pageNo: 1,
					pageSize: $("#listCntSel").val()
				},
				paging : true
			};
			
		grid.setGridHeader(headerData);
		grid.setGridConfig(configObj);

		$("#EndDate").bindTwinDate({
			startTargetID : "StartDate",
			separator : ".",
			onChange:function(){
				searchData(1);
			},
			onBeforeShowDay : function(date){
				var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
				if(fnStr != null && fnStr != ""){
					return coviCmn.callFnBasedNamespace(fnStr, [date]);
				}
			}
		})
	
				//오늘 클릭시
		$(".calendartoday").click(function(){
			$("#StartDate").val(g_curDate);
			$("#EndDate").val(g_curDate);
			searchData(1);		
			
		});

		
		if ($("#StartDate").val()==""){
			var gDate =  $("#StartDate").val();
			$("#StartDate").val(schedule_SetDateFormat(new Date(g_curDate.substring(0,4), (g_curDate.substring(5,7) - 1), 1), '.'));
			$("#EndDate").val(AttendUtils.maskDate(g_curDate));
			$("#dateTitle").text($("#StartDate").val() + "~" + $("#EndDate").val());
		}

		$(".cal").bind("click", function(){
			//$("#inputBasic_AX_EndDate_AX_expandBox").show();
			$(".AXanchorDateHandle").trigger("click");
		});


		searchData(1);

		$("#listCntSel").change(function(){
			searchData(1);
			CFN_SetCookieDay("AttListCnt", $("#listCntSel option:selected").val(), 31536000000);
		});
		
		//검색
		$("#btnRefresh, #btnSearch, #ExReqMethod").click(function(){
			searchData(1);
		});

		//취소
		$("#btnCancel").click(function(){
			if(!validationChk())     	return ;
			gMode = "";
			$("#ApprovalComment").val("");
			$("#divWork").show();
		});	
		
		//취소
		$("#btnSaveCancel").click(function(){
			if(gMode == "" && !validationChk())     	return ;
			Common.Confirm("<spring:message code='Cache.msg_att_cancel' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					var aJsonArray = new Array();
					if (gMode == ""){
						var selectObj = grid.getCheckedList(0);
						for(var i=0; i<selectObj.length; i++){
	                        aJsonArray.push(selectObj[i].ReqSeq);
						}
					}
					else{
						aJsonArray.push(grid.getSelectedItem()["item"]["ReqSeq"]);
					}

					
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
						url:"/groupware/attendRequestMng/cancelAttendRequest.do",
						success:function (data) {
							if(data.result == "ok"){
								if(data.notUpdateCount <= 0){
									Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//성공적으로 처리되었습니다.
								}else{
									if(data.totalCnt == data.notUpdateCount){
										Common.Inform("<spring:message code='Cache.msg_noCancelData'/>");	//취소할 데이터가 없습니다.
									}else if(data.totalCnt > data.notUpdateCount){
										Common.Inform(String.format("<spring:message code='Cache.msg_severalCanceled'/>", data.totalCnt, data.notUpdateCount));	//{0}개 중 {1}개를 제외하고 요청취소되었습니다.
									}
								}
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
	});
	

	//삭제
	$("#btnDelete").click(function(){
		if(gMode == "" && !validationChk())     	return ;
		Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var aJsonArray = new Array();
				if (gMode == ""){
					var selectObj = grid.getCheckedList(0);
					for(var i=0; i<selectObj.length; i++){
                        aJsonArray.push(selectObj[i].ReqSeq);
					}
				}
				else{
					aJsonArray.push(grid.getSelectedItem()["item"]["ReqSeq"]);
				}

				
				$.ajax({
					type:"POST",
					contentType:'application/json; charset=utf-8',
					dataType   : 'json',
					data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
					url:"/groupware/attendRequestMng/deleteAttendRequest.do",
					success:function (data) {
						if(data.result == "ok"){
							if(data.notUpdateCount <= 0){
								Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//성공적으로 처리되었습니다.
							}else{
								if(data.totalCnt == data.notUpdateCount){
									Common.Inform("<spring:message code='Cache.msg_noDeleteData'/>");	//삭제할 데이터가 없습니다.
								}else if(data.totalCnt > data.notUpdateCount){
									Common.Inform(String.format("<spring:message code='Cache.msg_severalDeleted'/>", data.totalCnt, data.notUpdateCount));	//{0}개 중 {1}개를 제외하고 삭제되었습니다.
								}
							}
							searchData(-1);
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
	
	$(document).on("click","#btnNo",function(){
		gMode="DIV";
		$("#ApprovalComment").val("");
		$("#divWork").show();
	});


	
	$(document).on("click","#reqInfo",function(){
		var dataMap = JSON.parse($(this).attr("data-map"));
		if (dataMap["ReqSeq"] == null)
		{
			return;
		}
		if (dataMap["ReqMethod"] == "Approval"){
			CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+dataMap["ProcessID"], "", 790, (window.screen.height - 100), "resize");
			return;
		}

		var popupID		= "AttendRequestDetailPopup";
		var openerID	= "AttendRequestDetail";
		var popupTit	= dataMap["URName"]+' '+"("+dataMap["ReqTitle"]+")";
		var popupYN		= "N";
		var callBack	= "AttendJobDetailPopup_CallBack";
		var popupUrl	= "/groupware/attendRequestMng/AttendRequestDetailPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "UserName="		+ dataMap["UserName"]	+ "&"
						+ "ReqType="		+ dataMap["ReqType"]	+ "&"
						+ "UserCode="		+ dataMap["UserCode"]	+ "&"
						+ "ReqSeq="		+ dataMap["ReqSeq"]	+ "&"
						+ "callBackFunc="	+ callBack	;
		
		Common.open("", popupID, popupTit, popupUrl, "650px", "700px", "iframe", true, null, null, true);

		
	});

	function searchData(pageNo){
		var params = {"mode" : "L"
					 ,"StartDate": $("#StartDate").val() 
					 ,"EndDate": $("#EndDate").val()
					 ,"ExReqMethod":$("#ExReqMethod").is(":checked")?$("#ExReqMethod").val():""};

		if (pageNo !="-1"){
			grid.page.pageNo =pageNo;
			grid.page.pageSize = $("#listCntSel").val();
		}	
		// bind
		grid.bindGrid({
			ajaxPars : params,
			ajaxUrl:"/groupware/attendRequestMng/getAttendMyRequestList.do"
		});

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
