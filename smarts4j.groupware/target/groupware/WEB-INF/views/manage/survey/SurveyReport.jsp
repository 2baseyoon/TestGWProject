<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title></title>
</head>
<style>	
.topbar_grid { line-height:30px; border-radius:5px; font-size:12px; color:#222; border:1px solid #ececec !important; margin-bottom:10px !important; background-color:#f9f9f9; padding:5px 7px 7px 7px !important;}
</style>

<body>
	<div id="popBox" style="margin: 15px;" class="sadmin_pop">
		<table class="sadmin_table" >
			<colgroup>
				<col style="width:18%">
				<col style="width:16%">
				<col style="width:18%">
				<col style="width:16%">
				<col style="width:18%">
				<col style="width:16%">										
			</colgroup>
			<tbody>
				<tr>
					<th><spring:message code='Cache.lbl_subject' /></th> 	<!-- 제목 -->
					<td colspan="3" style="height:27px;"><span id="subject"></span>.
					</td>
					<th><spring:message code='Cache.lbl_ParticipantsNum'/></th><!-- 총 참여자 수 -->
					<td id="respondentCnt"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_StatisticsDeptPos'/></th> 	<!-- 부서/직급별 통계 -->
					<td>
						<select id="reqTypesel" class="AXSelect" style="width: 90%">
						    <option value="all"><spring:message code='Cache.lbl_all'/></option>  	<!-- 전체 -->
						    <option value="job"><spring:message code='Cache.lbl_JobLevel'/></option> 	<!-- 직급 -->
						    <option value="dept"><spring:message code='Cache.lbl_dept'/></option> 	<!-- 부서 -->
						</select>
					</td>
					<th><spring:message code='Cache.lbl_User_Statistics'/></th> 	<!-- 사용자별통계 -->
					<td id="userReportBtn">
						<input type="button" class="AXButton" onclick="userReport()" value='<spring:message code="Cache.btn_User_Statistics"/>'> <!-- 사용자 통계 -->
					</td>
					<th><spring:message code='Cache.lbl_ParticipantStatistics'/></th> <!-- 설문 참여자 통계 -->
					<td>
						<input type="button" class="AXButton" onclick="search('respondent')" value='<spring:message code="Cache.btn_ParticipantStatistics"/>'> <!-- 참여자 통계 -->
					</td>											
				</tr>											
			</tbody>
		</table>

		<div class="topbar_grid" style=" background-color: #fff; margin-top: 10px;  padding: 17px !important;">
			<div class='topbar_grid' style="display:none" id="searchBar">
				<input type='button' class='AXButton BtnRefresh' onclick='search("respondent")' value='<spring:message code="Cache.btn_Refresh"/>'>&nbsp;&nbsp;&nbsp; <!-- 새로고침 -->
				 <select id='targetJoinSel' class='AXSelect selectType02 ' onchange='search("respondent")' style='float: right; width: 100px;'>
					<option value=''><spring:message code='Cache.lbl_Select'/></option> 	<!-- 선택 -->
					<option value='attendance'><spring:message code='Cache.lbl_survey_participation'/></option> 	<!-- 참여 -->
					<option value='nonAttendance'><spring:message code='Cache.lbl_Nonparticipation'/></option> 	<!-- 미참여 -->
				</select> 
				<select id='targetTypeSel' class='AXSelect selectType02' style='width: 70px;'></select> 
				<input type='text' id='schTxt'  style='height: 30px !important;' onkeypress='if (event.keyCode==13){ search("respondent"); return false;}' class='AXInput HtmlCheckXSS ScriptCheckXSS' />
				<input type='button' id='schBtn' class='AXButton' onclick='search("respondent")' value='<spring:message code="Cache.btn_search"/>'><!-- 검색 -->
			</div>
			<div  id="reportDiv" >
			</div>
		</div>
		
	</div>			
<script>
	//#sourceURL=SurveyReport.jsp
	var surveyId = CFN_GetQueryString("surveyId");
	
	var grid = new coviGrid();
	var reqType = "all";
	var IsAnonymouse = false;
	init();

	// 설문 통계보기
	function init(){
		
		$('#reqTypesel').bindSelect({
			option: [
				{'optionValue':'all','optionText':'<spring:message code="Cache.lbl_all"/>'} 			<!-- 전체 -->
				, {'optionValue':'job','optionText':'<spring:message code="Cache.lbl_JobLevel"/>'} 		<!-- 직급 -->
				, {'optionValue':'dept','optionText':'<spring:message code="Cache.lbl_dept"/>'} 		<!-- 부서 -->
				] 		
		});
		
		search('report');
		
		$("#targetTypeSel").bindSelect({ //검색 조건
			options: [
				{'optionValue':'ur','optionText':'<spring:message code="Cache.lbl_Participation_User"/>'} 	<!-- 참여자 -->
				,{'optionValue':'gt','optionText':'<spring:message code="Cache.lbl_dept"/>'}] 	<!-- 부서 -->
		});
		
		$("#targetJoinSel").bindSelect({ //참여 여부
			options: [{'optionValue':'','optionText':'<spring:message code="Cache.lbl_all"/>'} 		<!-- 전체 -->
			,{'optionValue':'attendance','optionText':'<spring:message code="Cache.lbl_survey_participation"/>'} 	<!-- 참여 -->
			,{'optionValue':'nonAttendance','optionText':'<spring:message code="Cache.lbl_Nonparticipation"/>'}] 	<!-- 미참여 -->
		});
		
	}

	$(function() {
		// 승인 거부 버튼
		$("#reqTypesel").change(function() {
			reqType = $(this).val();
		
			search('report');	// 검색
		});
	});
	
	// 검색
	function search(type) {
		var params = {surveyId : surveyId,
					 targetType : $("#targetTypeSel").val(),
					 schTxt : $("#schTxt").val(),
					  targetJoin : $("#targetJoinSel").val(),
					  reqType : reqType};
		
		if (type == 'report') {
	 		$.ajax({
				type : "POST",
				data : params,
				url : "/groupware/survey/getSurveyReportList.do",
				success:function (data) {
					if(data.result == "ok") {
						if(data.status == 'SUCCESS') {
							if(data.list.survey[0].IsAnonymouse == "Y"){
								$("#userReportBtn").html("<spring:message code='Cache.msg_AnonymousQuestion'/>");
								IsAnonymouse = true;
							}
							setReportHtml(data.list);	// 통계 html
		          		} else {
		          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
		          		}
					}
				},
				error:function(response, status, error) {
					CFN_ErrorAjax("/groupware/survey/getSurveyReportList.do", response, status, error);
				}
			});
		}else if(type == 'respondent') {	//익명 설문이면 참여자 표시 X
			if(IsAnonymouse){
				$("#searchBar").show();
				$("#targetTypeSel").hide();
				$("#AXselect_AX_targetTypeSel").hide();
				$("#schBtn").hide();
				$("#schTxt").hide();
				
				$("#reportDiv").empty();
				$("#reportDiv").html('<div id="gridDiv"></div>');
				
				grid.setGridHeader( [{key:'RespondentID', label:"<spring:message code='Cache.lbl_hrMng_targetUser'/>", width:'15', align:'center'},
										{key:'RegistDate', label:"<spring:message code='Cache.lbl_Participation_Check'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', formatter: function(){
					              			if(this.item.RegistDate == null || typeof(this.item.RegistDate) == 'undefined'){
					              				return "<spring:message code='Cache.lbl_Nonparticipation'/>"
					              			}else{
					              				return CFN_TransLocalTime(this.item.RegistDate);
					              			}
					              		}},
					              		{key:'EtcOpinion', label:"<spring:message code='Cache.lbl_comment'/>" , width:'65', align:'center'}]);
				
				grid.setGridConfig( {
					targetID : "gridDiv",
					height:"auto",
					paging: true,
					page : {
						pageNo:1,
						pageSize:10
					}
				});
				
	 	 		grid.bindGrid({
					ajaxUrl : "/groupware/survey/getTargetRespondentList.do",
					ajaxPars : params
				});
			} else {
				$("#searchBar").show();
				$("#reportDiv").empty();
				$("#reportDiv").html('<div id="gridDiv"></div>');
				
				grid.setGridHeader( [{key:'DisplayName', label:"<spring:message code='Cache.lbl_Participation_User'/>", width:'10', align:'center'}, // 참여자
					              		{key:'DeptName', label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'10', align:'center'}, // 부서
					              		{key:'RegistDate', label:"<spring:message code='Cache.lbl_Participation_Check'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', formatter: function(){ //침여여부
					              			if(this.item.RegistDate == null || typeof(this.item.RegistDate) == 'undefined'){
					              				return "<spring:message code='Cache.lbl_Nonparticipation'/>" // 미참여
					              			}else{
					              				return CFN_TransLocalTime(this.item.RegistDate);
					              			}
					              		}},
					              		{key:'EtcOpinion', label:"<spring:message code='Cache.lbl_comment'/>" /*의견*/, width:'65', align:'center'}]);
	
				
				grid.setGridConfig( {
					targetID : "gridDiv",
					height:"auto",
					paging: true,
					page : {
						pageNo:1,
						pageSize:10
					}
				});
				
	 	 		grid.bindGrid({
					ajaxUrl : "/groupware/survey/getTargetRespondentList.do",
					ajaxPars : params
				});
			}
		}
	}

 	// 통계 html
    function setReportHtml(list) {
 		$("#subject").html(list.survey[0].Subject);
 		$("#respondentCnt").html(list.survey[0].respondentCnt);
 		
 		var isNType = false;	// 순위선택 문항 존재 여부
 		var questions = list.questions;
 		var itemRecords = list.itemRecords;
 		var calcItemWidth = 0;
 		
 		$("#searchBar").hide();
		$("#reportDiv").empty();
		
    	var html = "";
    	html += "<tbody>";
    	html += "<tr>";
    	html += "<th rowspan='3' style='width:70px'>";
    	html += "<spring:message code='Cache.lbl_question'/>";
    	html += "</th>";
    	
    	var titleHtml1 = "";
    	var titleHtml2 = "";
    	var titleHtml3 = "";
    	
    	//타이틀 생성
		$(questions).each(function() {
	    	if (this.questionType == 'N') isNType = true;
			
	    	var colspan = 0;
	    	if (reqType == 'user') {
	    		colspan = this.items.length;
	    	} else {
	    		colspan = this.itemLen;
	    	}
	    	
	    	if(this.items !== undefined && this.items.length > 0) {
	    		calcItemWidth += this.items.length;
	    	}
	    	
	    	if(this.groupingNo != null && this.groupingNo != "0" && this.groupingNo != 0){//ellipsis
		    	titleHtml1 += "<th colspan='" + colspan + "'  class='center'>" + this.groupingNo + "-" + this.questionNo +"</th>";
	    	}else{
	    		titleHtml1 += "<th colspan='" + colspan + "'  class='center'>" + this.questionNo +"</th>";
	    	}
	    	titleHtml2 += "<td colspan='" + colspan + "'   class='center' title='"+this.question+"'><span class='ellip'>" + this.question + "</span></td>";
	    	titleHtml3 += "<td colspan='" + colspan + "'   class='center'><span class='ellip'>" + this.questionTypeNm + "</span></td>";
		});
		
    	html += titleHtml1+ "</tr>";
    	html += "<tr>"+titleHtml2+ "</tr>";
    	html += "<tr>"+titleHtml3+ "</tr>";

     	if (reqType == 'user') {
    		html += "<tr>";
    		html += "<th>" + "<spring:message code='Cache.lbl_User'/>" + "</th>"; //사용자
    		
    		$(questions).each(function() {
     	    	$(this.items).each(function() {
    	    		html += "<td>" + this.itemNo + "</td>";		
    	    	});
    		}); 
    		
    		html += "</tr>";
    		
     		$(itemRecords).each(function() {
     			html += "<tr>";
     			html += "<td>" + CFN_GetDicInfo(this.userNm) + "</td>";
     			
    	    	$(this.questionRecords).each(function() {
    	    		var questionType = this.questionType;
         	    	$(this.items).each(function() {
         	    		var cnt = this.cnt;
						var str = "";         	    		
         	    		
         	    		if (typeof(cnt) == 'undefined') {
         	    			$(this.items).each(function() {
         	    			    if (this.cnt == '1') return str += "<td>" + this.itemNo + "</td>";
         	    			});
         	    		} else {
            	    		if (questionType == 'D') {	//주관식
            	    			str += "<td title='"+(this.answerItem==undefined?"": this.answerItem)+"'><span class='ellip'>" + (this.answerItem==undefined?"": this.answerItem)+ "</span></td>";
            	    		}
            	    		else{
	         	    			str += "<td>" + cnt + "</td>";
            	    		}	
         	    		}

         	    		if (str == "") str = "<td>0</td>";
         	    		html += str;
        	    	});   	    		
    	    	});
    	    	html += "</tr>";
    		});    		
    	} else {
    		html += "<tr>";
    		
    		var txt = "";
    		if (reqType == 'job') {
    			txt = "<spring:message code='Cache.lbl_JobLevel'/>"; // 직급
    		} else if (reqType == 'dept') {
    			txt = "<spring:message code='Cache.lbl_apv_dept'/>"; // 부서
    		} else {
    			txt = "<spring:message code='Cache.lbl_all'/>"; // 전체
    		}
    		
    		var rspan = 1;			// UI 깨짐 수정
    		var subRankhtml = "";
    		if (isNType) rspan = reqType == "all" ? 4 : 2;
    		else 		 rspan = reqType == "all" ? 3 : 2;
    		html += "<th  rowspan='"+ rspan +"'>" + txt + "</th>";    			
    
    		
    		$(questions).each(function() {
    			var itemLen = this.items.length;
    			var questionType = this.questionType;
    			
     	    	$(this.items).each(function() {
     	    		if (questionType == 'N') {
	    	    		html += "<td colspan='" + itemLen + "' class='center' title='"+this.itemName+"'>" + this.itemNo + "<br><span class='ellip'>"+this.itemName + "</span></td>";	
	    	    		$(this.items).each(function() {
		    	    		subRankhtml += "<td  class='center'>" + this.itemNo+"</td>";
	        	    	});	
     	    		} else {
     	    			html += "<td rowspan='2'  class='center'  title='"+this.itemName+"'>" + this.itemNo+"<br><span class='ellip'>"+this.itemName + "</span></td>";
     	    		}
    	    	});
    		});
    		
    		html += "</tr>";
    		html += "<tr>"+subRankhtml+"</tr>";
    		
      		$(itemRecords).each(function() {
     			html += "<tr>";
     			
        		var rowTxt = "";
        		if (reqType == 'job') {
        			rowTxt = CFN_GetDicInfo(this.jobLevelName);
        		} else if (reqType == 'dept') {
        			rowTxt = CFN_GetDicInfo(this.deptName);
        		} 
        		
        		if(reqType != 'all'){
	     			html += "<td>" + rowTxt + "</td>";
        		}
     			
    	    	$(this.questionRecords).each(function() {
    	    		var questionType = this.questionType;
    	    		
         	    	$(this.items).each(function() {
         	    		if (questionType == 'N') {
         	    			$(this.items).each(function() {
         	    			    html += "<td  class='center'>" + this.cnt + "</td>";
         	    			});
         	    		} else if (questionType == 'D') {
         	    			html += "<td  class='center'>"+ this.cnt +"명 응답</td>";
         	    		}else {
         	    			html += "<td  class='center'>" + this.cnt + "</td>";
         	    		}
        	    	});   	    		
    	    	});
    	    	
    	    	html += "</tr>";
    		});
    	}
    	
    	html += "</tbody>";
    	html += "</table>";
    	
    	var isPopup = CFN_GetQueryString("isPopup");	// 통계보기 : 문항이 많아질경우 layer popup 의 iframe 내의 Table 깨짐을 방지
    	
    	if(isPopup == 'y') {
	    	calcItemWidth = calcItemWidth * 60;
	    	html = '<table class="sadmin_table tableStyle linePlus" style="width:'+(calcItemWidth < 800?'100%':calcItemWidth+'px')+'">' + html;
    	} else {
	    	html = '<table class="sadmin_table tableStyle linePlus">' + html;
    	}
    	
    	$("#reportDiv").append(html);	 
 	}
 	
	// 관리자(설문 관리) 이동
    function goSurveyManage() {
		CoviMenu_GetContent('/groupware/layout/survey_SurveyManage.do?CLSYS=survey&CLMD=admin&CLBIZ=Survey');	
    }
	
	// 사용자통계
    function userReport() {
		reqType = 'user';
		
		search('report');	// 검색
    }
	
</script>	
</body>
</html>
