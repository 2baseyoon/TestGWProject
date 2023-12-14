<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
@media (min-width: 1530px) 
{
	#divTeamSelectBox {
		width: 350px;
	}
	
	#divGridBox {
		padding-left:360px; 
		position:absolute; 
		top:0px;left:0px;
	}

	#teamMemberList {
		min-height:420px; 
		max-height:490px; 
	}
}

@media (max-width: 1529px)
{
	#divTeamSelectBox {
		width:100%;
	}
	
	#divGridBox {
		padding-top: 10px;
	}

	#teamMemberList {
		height:280px; 
	}
}

.listTab {
	width:70px;
	height:38px;
	box-sizing:border-box;
	line-height:30px;
	float:left;
	text-align:center;
	border-left : 1px solid #c9c9c9;
	cursor : pointer;
	font-weight : bold;
	font-size : 12px; 
}

.listTab.off {
	border-top : 4px solid #a9a9a9;
	background-color : #d9d9d9;
	color : #666;
}

.listTab.on {
	border-top : 4px solid #f55702;
	background-color : #f9f9f9;
}

</style>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">팀 업무보고</span>
	</h3>

	<div id="resultBoxWrap" style="position:relative; margin-top:10px; z-index:5;">
		
		<!-- Select Team Member -->
		<div id="divTeamSelectBox" style="border : 1px solid rgb(128, 128, 128); z-index:10;">
			<div style="width:100%; height:40px; background-color : #f9f9f9; border-bottom : 1px solid #c9c9c9;">
				<div style='float:left; height:40px; line-height:35px; padding-left : 10px;'>
					<input id="chkAllMember" type="checkbox" onchange="toggleAllMember(this)"/>
				</div>
				
				<div style='float:left; padding-left:33px; font-weight:600; height:38px; box-sizing:border-box; line-height:38px; background : url("/HtmlSite/smarts4j_n/covicore/resources/images/theme/icn_png.png") no-repeat -472px -975px #fafbfd'></div>
				
				<div id="tabTeam" class='listTab on'>
					팀원목록
				</div>
				
				<div id="tabApproval" class='listTab off' style='border-right:1px solid #c9c9c9;'>
					승인목록
				</div>
				
				<div style='float:right; height:100%; padding:5px 5px 5px 0px;'>
					<button id="btnOrgMap" style='display:none;' type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>"><spring:message code='Cache.lbl_DeptOrgMap'/></button>
				</div>
			</div>
			<!-- Filter Box -->
			<div style='height:40px; background-color : #f9f9f9; border-bottom : 1px solid rgb(128, 128, 128); padding-left : 10px; padding-top:10px;'>
				<span style='font-weight: 600;'>이름 : </span> 
				<input type='text' class='AXInput' id='txtFilterName' onkeyup='filterMemberName()'/>
			</div>
			<div id="teamMemberList" style="width:100%; overflow-y : auto; background-color : #f9f9f9;"></div>
		</div>	
		
		<!-- Grid -->
		<div id="divGridBox" style="box-sizing:border-box; width:100%; z-index:-1;">
			<!-- 상단 필터 및 메뉴 -->
			<div style="width:100%; height:60px; margin-bottom: 10px; z-index:0;">
				<div style="margin-bottom : 5px;">
					<button type="button" id="btnRefresh" class="AXButton" onclick="refresh()">새로고침</button>
					<!-- 
						<button type="button" id="btnApproval" class="AXButton" onclick="approvalWorkReport()">승인</button>
						<button type="button" id="btnReject" class="AXButton" onclick="rejectWorkReport()">거부</button>
					 -->
				</div>
				<div style="display:inline-block;">
					<span>
						<select id="selState" class="selectSearchField">
							<option value="">승인여부</option>
							<option value="I">승인요청</option>
							<option value="A">승인</option>
							<option value="R">거부</option>
						</select>
					</span>
					
					<span style="margin-left: 10px;">
						<select id="selDivision"  class="selectSearchField" style='max-width:200px;'></select>
						<select id="selJob"  class="selectSearchField" style='max-width:200px;'></select>
						<select id="selType"  class="selectSearchField" style='max-width:200px;'></select>
					</span>
					<span style="margin-left: 10px;">
						기간
						<input type="text" id="startDate" class="AXInput W100" style="padding:0px!important;"> ~ 
					    <input type="text" kind="twindate" date_starttargetid="startDate" date_align="right" date_valign="bottom" date_separator="-" id="endDate" class="AXInput W120" data-axbind="twinDate" style="padding:0px!important;">
					</span>
					
					<button type="button" id="btnSearch" class="AXButton" onclick="searchWorkReport()"><spring:message code="Cache.btn_search"></spring:message></button>
				</div>
			</div>
			<div id="workReportGrid"></div>
		</div>
		
		
	</div>
</div>

<div id="divCommentBox" style="display:none;">
	<div style="width:300px; height:200px; padding : 10px;">
		<div id="divCommentContent" style="width:280px; height:140px; overflow-y : auto; border:1px solid #a0a0a0; box-sizing:border-box; padding:5px;"></div>
		<div style="margin-top : 10px; text-align:right;">
			<button type="button" class="AXButton" onclick="Common.Close('commentPop')">확인</button>
		</div>
	</div>
</div>

<script>
	var workReportGrid = new coviGrid();
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		//myGrid.setGridHeader(headerData);
		workReportGrid.setGridHeader([
		                      {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox', disabled: function() {
		                    	  return !(this.item.State == 'I');
		                      }},
			                  {key:'Month',  label:'제목', width:'150', align:'center', formatter : function() {
			                	  var statusText = "";
			                	  switch(this.item.State) {
			                	  case "I" : statusText = "승인요청"; break;
			                	  case "A" : statusText = "완료"; break;
			                	  case "R" : statusText = "거부"; break;
			                	  }
			                	  var wrid = this.item.wrid ? "" : this.item.wrid;
			                	  var tHTML = "<a href='javascript:workReportPopOpen(\"" + this.item.WorkReportID + "\", \"" + this.item.CalID + "\", \"" + this.item.UR_Code + "\")'>";
			                	  tHTML += this.item.Month + " 월 " + this.item.WeekOfMonth + " 주차 " + statusText;
			                	  tHTML += "</a>";
			                	  
			                	  return tHTML;
			                  }},
			                  {key:'UR_Name',  label:'보고자', width:'70', align:'center', formatter: function() {
			                	  return this.item.UR_Name + " " + this.item.JobPositionName;
			                  }},
			                  {key:'StartDate',  label:'시작일', width:'70', align:'center'},
			                  {key:'EndDate', label:'종료일', width:'70', align:'center'},
			                  {key:'ReportDate',  label:'보고일' + Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
			                   formatter : function() {
			                	   var dateStr = this.item.ReportDate;
			                	   if(dateStr != ""){
				                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
			                	   }else{
			                		   return "-";
			                	   }
			                   }},
			                  {key:'State', label:'승인여부', width:'70', align:'center', formatter : function() {
			                	  var statusText = "";
			                	  switch(this.item.State) {
			                	  case "I" : statusText = "승인요청"; break;
			                	  case "A" : statusText = "승인"; break;
			                	  case "R" : statusText = "거부"; break;
			                	  }
			                	  
			                	  var commentBox = "";
			                	  if(this.item.Comment) {
			                		  // icnView
			                		  commentBox = '<a href="javascript:showCommentBox(' + this.index + ')" title="의견보기" ';
			                		  commentBox += 'style="background: url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/icn_png.png) no-repeat -173px -550px; padding-left: 21px;"></a>';
			                	  }
			                	  
			                	  return statusText + commentBox;
			                  }},
			                  {key:'ApprovalDate',  label:'승인일' + Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
				                   formatter : function() {
				                	   var dateStr = this.item.ApprovalDate;
				                	   if(dateStr != ""){
					                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
				                	   }else{
				                		   return "-";
				                	   }
			                   }}
				      		]);
		setGridConfig();
		bindGridData();
	}


	function bindGridData() {	
		var division = $("#selDivision").val();
		var jobId = $("#selJob").val();
		var type = $("#selType").val();
		
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		var arrMemberList = [];
		
		/*
		if($("input[name='chkMember']:checked").length == 0) {
			$("#chkAllMember").prop("checked", true);
			$("input[name='chkMember']").prop("checked", true);
		}
		*/
		
		$("input[name='chkMember']:checked").each(function(idx, obj) {
			arrMemberList.push($(obj).val());
		});
		
		var memberList = arrMemberList.join(',');
		

		var state = $("#selState").val();		
		
		workReportGrid.bindGrid({
			ajaxUrl:"getWorkReportTeamlist.do",
			ajaxPars: {
				jobid : jobId,
				type : type,
				division : division,
				startDate : startDate,
				endDate : endDate,
				state : state,
				memberList : memberList
			},
			onLoad:function () {
				workReportGrid.fnMakeNavi("workReportGrid");
			}
		});
	}

	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "workReportGrid",		// grid target 지정
			sort : false,		// 정렬
			colHeadTool : false,	// 컬럼 툴박스 사용여부
			fitToWidth : true,		// 자동 너비 조정 사용여부
			colHeadAlign : 'center',
			height:"auto",
			
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		// Grid Config 적용
		workReportGrid.setGridConfig(configObj);
	}

	
	var workReportPopOpen = function(wrid, calid, uid) {
		if(wrid && wrid > 0) {
			Common.open("", "WorkReportPop", "업무보고", "viewWorkReport.do?wrid=" + wrid + "&calid=" + calid + "&uid=" + uid + "&mp=m", "1000px", "580px", "iframe", true, null, null, true);
		} else {
			Common.Inform("조회할 수 없는 업무보고입니다. 관리자에게 문의해주세요!", "알림");
		}
	};
	
	
	var bindSelect = function() {
		var selDiv = $("#selDivision");
		var selJob = $("#selJob");
		var selType = $("#selType");
		
		selDiv.append("<option value=''>분류전체</option>");
		selJob.append("<option value=''>업무전체</option>");
		selType.append("<option value=''>구분전체</option>");
		
		
		$.getJSON("getWorkReportDiv.do", {}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selDiv.append("<option value='" + obj.code + "'>" + obj.name + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
		});
		
		$.getJSON("getworkjob.do", {division : ""}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selJob.append("<option value='" + obj.JobID + "'>" + obj.JobName + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getworkjob.do", response, status, error);
		});
		
		$.getJSON("getWorkReportType.do", {}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selType.append("<option value='" + obj.code + "'>" + obj.name + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportType.do", response, status, error);
		});
	};
	
	var searchWorkReport = function() {
		bindGridData();
	};
		
	var showCommentBox = function(idx) {
		var strComment = workReportGrid.list[idx].Comment;
		strComment = strComment.replace(/(\r\n|\n)/igm, '<br/>').replace(/ /g, '&nbsp;');
		$("#divCommentContent").empty().html(strComment);
		Common.open("", "commentPop", "의견보기", "divCommentBox", "300px", "200px", "id", true, null, null, true);
	};
	
	var toggleAllMember = function(obj) {
		$("input[name='chkMember']").prop("checked", $(obj).prop("checked"));
	}
	
	var refresh = function() {
		$("#selState").val("");
		$("#selDivision").val("");
		$("#selJob").val("");
		$("#selType").val("");
		
		$("#startDate").val("");
		$("#endDate").val("");
		
		bindGridData();
	};
	
	/*
	var approvalWorkReport = function () {
		Common.Confirm("선택한 보고들을 일괄 승인처리 하시겠습니까?", "알림", function(result) {
			if(result) {
				
				var arrSelected = [];
				
				workReportGrid.getCheckedList(0).forEach(function(data) {
					arrSelected.push(data.WorkReportID);
				});
				
				var strSelecteds = arrSelected.join(',');
				
				
				$.post("approvalWorkReport.do", {workReportId : strSelecteds, currentState : "I"}, function(d) {
					var successCnt = d.successCnt;
					var failCnt = d.failCnt;
					
					var msg = "처리가 완료되었습니다.";
					
					if(failCnt > 0) {
						msg = "전체 " + (successCnt + failCnt) + "건 중 " + successCnt + "건을 승인 처리하였습니다. <br />( 권한 없음으로 인한 미처리 " + failCnt + "건 )";
					}
					
					Common.Inform(msg, "알림", function() {
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							workReportGrid.reloadList();
						}
					});
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("approvalWorkReport.do", response, status, error);
				});
			}			
		});
	};
	
	var rejectWorkReport = function () {
		Common.Confirm("선택한 보고들을 일괄 거부처리 하시겠습니까?", "알림", function(result) {
			if(result) {
				var arrSelected = [];
				
				workReportGrid.getCheckedList(0).forEach(function(data) {
					arrSelected.push(data.WorkReportID);
				});
				
				var strSelecteds = arrSelected.join(',');
								
				$.post("rejectWorkReport.do", {workReportId : strSelecteds, currentState : "I"}, function(d) {
					var successCnt = d.successCnt;
					var failCnt = d.failCnt;
					
					var msg = "처리가 완료되었습니다.";
					
					if(failCnt > 0) {
						msg = "전체 " + (successCnt + failCnt) + "건 중 " + successCnt + "건을 거부 처리하였습니다. <br />( 권한 없음으로 인한 미처리 " + failCnt + "건 )";
					}
					
					Common.Inform(msg, "알림", function() {
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							workReportGrid.reloadList();
						}
					});
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("rejectWorkReport.do", response, status, error);
				});
			}			
		});
	}
	*/
		
	var orgCallBackMethod = function(data) {
		var jsonData = $.parseJSON(data);
		
		if(jsonData.item.length > 0) {
			var selGRCode = jsonData.item[0].GroupPath;

			if(jsonData.item[0].GroupType.toUpperCase() == "DEPT") {
				$("#tabTeam").trigger("click");
				
				$.ajaxSetup({
					async : false
				});
				
				$.getJSON("workReportTeamMembers.do", {groupCode : selGRCode}, function(d) {					
					var members = d.members;
					var appendTarget = $("#teamMemberList");
					appendTarget.empty();
					var photoPath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
					members.forEach(function(obj) {
						var strState = "";
						var strStateColor = "";
						
						switch(obj.RecentState) {
						case 'W' : strState = "작성중"; strStateColor = "#1E4CD4"; break;  
						case 'I' : strState = "승인요청"; strStateColor = "#D4A61E"; break;
						case 'A' : strState = "승인완료"; strStateColor = "#48E609"; break;
						case 'R' : strState = "거부"; strStateColor = "#E63909"; break;
						}
						
						var sHTML = '<div class="teamMemberCard" data-memberName="' + obj.UR_Name + '" style="height:70px; box-sizing:border-box; border-bottom : 1px solid #ededed; background-color : #fff; cursor:default;">';
						sHTML += '<ul style="height:100%;">';
						sHTML += '<li style="display:inline-block; float:left; height:100%; line-height:70px; width:30px; padding-left:10px;">';
						sHTML += '<input type="checkbox" name="chkMember" class="chkMember" value="' + obj.UR_Code + '"/>';
						sHTML += '</li>';
						sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:15px; width:60px; text-align:center;">';
						// sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="this.src=\'' + Common.getBaseConfig("ProfileImagePath").replace("/{0}", "") + 'noimg.png\'"></a>';
						// 2023.09 userImg 오류 수정
						sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="coviCmn.imgError(this, true);"></a>';
						sHTML += '</li>';
						sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:10px; width:130px; line-height:17px;">';
						sHTML += '<div style="font-size:13px; font-weight:600; width: 100%; text-overflow: ellipsis; white-space: nowrap; overflow: hidden;">' + obj.UR_Name + ' ' + obj.JobPositionName + '</div>';
						sHTML += '<div style="font-size:11px;">미보고 : ' + obj.NotReportCnt + '건</div>';
						sHTML += '<div style="font-size:11px;">승인요청 : ' + obj.NotApprovalCnt + '건</div>';
						sHTML += '</li>';
						sHTML += '<li style="padding-left:5px; display:inline-block; height:100%; padding-top:5px; line-height:17px;">';
						sHTML += '<div style="padding-top : 15px;font-size:12px; font-weight:bold;">이번 주 업무보고</div>';
						sHTML += '<div style="font-size:13px; text-align:center; font-weight:bold; color:' + strStateColor + ';">' + strState + '</div>';
						sHTML += '</li>';
						sHTML += '</ul>';
						sHTML += '</div>';
						
						
						appendTarget.append(sHTML);
					});
					
					$("#chkAllMember").prop("checked", false);
					$("#chkAllMember").trigger('click');
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workReportTeamMembers.do", response, status, error);
				});
				
				$.ajaxSetup({
					async : true
				});
			} else {
				Common.Inform("선택된 [ " + CFN_GetDicInfo(jsonData.item[0].DN) + " ]는 부서가 아닙니다.", "알림");
			}
		}
	};
	
	var filterMemberName = function() {
		var currentFilter = $("#txtFilterName").val();
		
		if(currentFilter != '') {
			var filterRegx = new RegExp(currentFilter, 'i');
			
			$('.teamMemberCard').each(function(idx, obj) {
				var memberName = $(obj).attr('data-memberName');
				if(filterRegx.test(memberName)) {
					$(this).css('display', 'block');
				} else {
					$(this).css('display', 'none');
				}
			});
		} else {
			// 공백일 경우 전체다 보여줌
			$('.teamMemberCard').css('display', 'block');
		}
		
	};
	
	
	var getApprovalTargetList = function() {
		$.ajaxSetup({
			async : false
		});
		
		$.getJSON("workReportApprovalTargets.do", {}, function(d) {
			var members = d.members;
			
			var appendTarget = $("#teamMemberList");
			var photoPath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
			members.forEach(function(obj) {
				
				var strState = "";
				var strStateColor = "";
				
				switch(obj.RecentState) {
				case 'W' : strState = "작성중"; strStateColor = "#1E4CD4"; break;  
				case 'I' : strState = "승인요청"; strStateColor = "#D4A61E"; break;
				case 'A' : strState = "승인완료"; strStateColor = "#48E609"; break;
				case 'R' : strState = "거부"; strStateColor = "#E63909"; break;
				}
				
				var sHTML = '<div class="teamMemberCard" data-memberName="' + obj.UR_Name + '" style="height:70px; box-sizing:border-box; border-bottom : 1px solid #ededed; background-color : #fff; cursor:default;">';
				sHTML += '<ul style="height:100%;">';
				sHTML += '<li style="display:inline-block; float:left; height:100%; line-height:70px; width:30px; padding-left:10px;">';
				sHTML += '<input type="checkbox" name="chkMember" class="chkMember" value="' + obj.UR_Code + '"/>';
				sHTML += '</li>';
				sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:15px; width:60px; text-align:center;">';
				// sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="this.src=\'' + Common.getBaseConfig("ProfileImagePath").replace("/{0}", "") + 'noimg.png\'"></a>';
				// 2023.09 userImg 오류 수정
				sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="coviCmn.imgError(this, true);"></a>';
				sHTML += '</li>';
				sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:10px; width:130px; line-height:17px;">';
				sHTML += '<div style="font-size:13px; font-weight:600; width: 100%; text-overflow: ellipsis; white-space: nowrap; overflow: hidden;">' + obj.UR_Name + ' ' + obj.JobPositionName + '</div>';
				sHTML += '<div style="font-size:11px;">미보고 : ' + obj.NotReportCnt + '건</div>';
				sHTML += '<div style="font-size:11px;">승인요청 : ' + obj.NotApprovalCnt + '건</div>';
				sHTML += '</li>';
				sHTML += '<li style="padding-left:5px; display:inline-block; height:100%; padding-top:5px; line-height:17px;">';
				sHTML += '<div style="padding-top : 15px;font-size:12px; font-weight:bold;">이번 주 업무보고</div>';
				sHTML += '<div style="font-size:13px; text-align:center; font-weight:bold; color:' + strStateColor + ';">' + strState + '</div>';
				sHTML += '</li>';
				sHTML += '</ul>';
				sHTML += '</div>';
				
				appendTarget.append(sHTML);
			});
			
			$("#chkAllMember").prop("checked", false);
			$("#chkAllMember").trigger('click');
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("workReportApprovalTargets.do", response, status, error);
		});
		
		$.ajaxSetup({
			async : true
		});
	};
	
	
	$(function() {
		
		$.ajaxSetup({
			async : false
		});
		
		$.getJSON("workReportTeamMembers.do", {groupCode : ""}, function(d) {
			var members = d.members;
			
			var appendTarget = $("#teamMemberList");
			var photoPath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
			members.forEach(function(obj) {
				
				var strState = "";
				var strStateColor = "";
				
				switch(obj.RecentState) {
				case 'W' : strState = "작성중"; strStateColor = "#1E4CD4"; break;  
				case 'I' : strState = "승인요청"; strStateColor = "#D4A61E"; break;
				case 'A' : strState = "승인완료"; strStateColor = "#48E609"; break;
				case 'R' : strState = "거부"; strStateColor = "#E63909"; break;
				}
				
				var sHTML = '<div class="teamMemberCard" data-memberName="' + obj.UR_Name + '" style="height:70px; box-sizing:border-box; border-bottom : 1px solid #ededed; background-color : #fff; cursor:default;">';
				sHTML += '<ul style="height:100%;">';
				sHTML += '<li style="display:inline-block; float:left; height:100%; line-height:70px; width:30px; padding-left:10px;">';
				sHTML += '<input type="checkbox" name="chkMember" class="chkMember" value="' + obj.UR_Code + '"/>';
				sHTML += '</li>';
				sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:15px; width:60px; text-align:center;">';
				// sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="this.src=\'' + Common.getBaseConfig("ProfileImagePath").replace("/{0}", "") + 'noimg.png\'"></a>';
				// 2023.09 userImg 오류 수정
				sHTML += '<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt="" src="' + photoPath + obj.UR_Code + '.jpg" onerror="coviCmn.imgError(this, true);"></a>';
				sHTML += '</li>';
				sHTML += '<li style="display:inline-block; float:left; height:100%; padding-top:10px; width:130px; line-height:17px;">';
				sHTML += '<div style="font-size:13px; font-weight:600; width: 100%; text-overflow: ellipsis; white-space: nowrap; overflow: hidden;">' + obj.UR_Name + ' ' + obj.JobPositionName + '</div>';
				sHTML += '<div style="font-size:11px;">미보고 : ' + obj.NotReportCnt + '건</div>';
				sHTML += '<div style="font-size:11px;">승인요청 : ' + obj.NotApprovalCnt + '건</div>';
				sHTML += '</li>';
				sHTML += '<li style="padding-left:5px; display:inline-block; height:100%; padding-top:5px; line-height:17px;">';
				sHTML += '<div style="padding-top : 15px;font-size:12px; font-weight:bold;">이번 주 업무보고</div>';
				sHTML += '<div style="font-size:13px; text-align:center; font-weight:bold; color:' + strStateColor + ';">' + strState + '</div>';
				sHTML += '</li>';
				sHTML += '</ul>';
				sHTML += '</div>';
				
				appendTarget.append(sHTML);
			});
			
			$("#chkAllMember").trigger('click');
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("workReportTeamMembers.do", response, status, error);
		});
		
		$.ajaxSetup({
			async : true
		});
		
		$("#teamMemberList").on("mouseover", ".teamMemberCard", function() {
			$(this).css({
				"background-color" : "#eee"
			});
		}).on("mouseout", ".teamMemberCard", function() {
			$(this).css({
				"background-color" : "#fff"
			});
		});
		
		$("#teamMemberList").on("click", ".teamMemberCard", function() {
			$("#chkAllMember").prop("checked", false);
			$(".chkMember").prop("checked", false);
			
			$(this).find(".chkMember").prop("checked", true);
			
			$("#selState").val("");
			$("#selDivision").val("");
			$("#selJob").val("");
			$("#selType").val("");
			
			$("#startDate").val("");
			$("#endDate").val("");
			
			bindGridData();
		});
		
		$("#teamMemberList").on("change", ".teamMemberCard .chkMember", function() {
			var flag = $(this).prop("checked");
			
			if(!flag) {
				// false로 변환했지만 전체체크가 활성화되어있을경우 false로 변환
				$("#chkAllMember").prop("checked", false);
			}
			
			$("#selState").val("");
			$("#selDivision").val("");
			$("#selJob").val("");
			$("#selType").val("");
			
			$("#startDate").val("");
			$("#endDate").val("");
			
			bindGridData();
		});
		
		$(".chkMember").on("click", function() {
			event.stopPropagation();
		});
		
		$(".selectSearchField").on("change", function() {
			bindGridData();
		});		
		
		setGrid();
		bindSelect();
		
		
		// 조직도 버튼 관리자권한 확인
		var strManagerInfo = Common.getBaseConfig("TempWorkReportManager");
		
		var arrManagerInfo = strManagerInfo.split('|');
		var flagM = false;

		//개별호출-일괄호출
		var sessionObj = Common.getSession(); //전체호출
		
		arrManagerInfo.forEach(function(mInfo) {
			var arrInfo = mInfo.split(":");
			if(arrInfo.length == 2) {
				if(arrInfo[0] == "UR") {
					if(arrInfo[1] == sessionObj["UR_Code"]) {
						flagM = true;
						return false;
					}
				} else if(arrInfo[0] == "GR"){
					if(arrInfo[1] == sessionObj["GR_Code"]) {
						flagM = true;
						return false;
					}
				}	
			}
		});
		
		if(flagM) {
			$("#btnOrgMap").css("display", "")
						   .on("click", function() {
							   Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethod&type=C1","1000px","580px","iframe",true,null,null,true);
						   });
		} else  {
			$("#btnOrgMap").remove();
		}
		
		
		
		
		$(".listTab").on("click", function() {
			if($(this).hasClass("on")) {
				return false;
			} else if($(this).hasClass("off")) {
				var onObj = $(".listTab.on").removeClass("on").addClass("off");
				$(this).removeClass("off").addClass("on");
				
				var selectId = $(this).attr("id");
				
				var listObj = $("#teamMemberList");
				listObj.empty();
				
				if(selectId == "tabTeam") {
					var fakeData = {};
					var pData = [];
					pData.push({"GR_Code" : Common.getSession().GR_Code, "GroupType" : "DEPT"});
					fakeData.item = pData;
					
					orgCallBackMethod(JSON.stringify(fakeData));
				} else if (selectId == "tabApproval") {
					// 승인대상자 목록 가져오기
					getApprovalTargetList();
				}
			}
		});
	});
</script>