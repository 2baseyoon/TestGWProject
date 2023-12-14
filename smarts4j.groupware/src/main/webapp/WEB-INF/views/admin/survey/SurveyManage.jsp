<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>    

<h3 class="con_tit_box">
	<span class="con_tit">설문 관리</span>
</h3>
<form id="form1">
    <div style="width:100%; min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
    		<input type="button" class="AXButton BtnRefresh" onclick="searchSurvey();" value="<spring:message code='Cache.btn_apv_refresh' />"><!-- 새로고침 -->
    		<input type="button" style="display:none;" class="AXButton" value="검토승인" onclick="updateSurveyState('', 'C', '검토승인');"/>
    		<input type="button" style="display:none;" class="AXButton" value="검토거부" onclick="updateSurveyState('', 'D', '검토거부');"/>
    		<input type="button" class="AXButton" value="승인" onclick="updateSurveyState('', 'F', '승인');"/>
    		<input type="button" class="AXButton" value="승인거부" onclick="updateSurveyState('', 'X', '승인거부');"/>	
    		<input type="button" class="AXButton" value="강제종료" onclick="updateSurveyState('', 'G', '강제종료');"/>
    		<input type="button" class="AXButton BtnDelete" value="삭제" onclick="updateSurveyState('', 'del', '삭제');"/>
		</div>	
		<div id="topitembar02" class="topbar_grid">
			
			<%-- 21.12.29, 도메인 관리자는 도메인 선택 화면을 안보여줍니다(CoreInclude.jsp를 통한 class domain 처리). --%>
			<span class="domain">
				<spring:message code="Cache.lbl_OwnedCompany"/>: <!-- 소유회사 -->
				<select id="companySelectBox" class="AXSelect W100"></select>
				&nbsp;&nbsp;&nbsp;
			</span>
			
			<select id="selType" class="AXSelect W80"></select>			
			<input name="search" type="text" id="schTxt" onkeypress="if (event.keyCode==13){ searchSurvey(); return false;}" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
			<input type="button" value="검색" onclick="searchSurvey();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="gridDiv"></div>
	</div>
</form>
	
<script>	
	//#sourceURL=SurveyManage.jsp
	var grid = new coviGrid();
	var lang = Common.getSession("lang");
	
	init();
	
	// 설문관리(관리자)
	function init() {
		
		coviCtrl.renderCompanyAXSelect("companySelectBox", lang, false, "", "", '');
		
		$("#companySelectBox").on("change", searchSurvey);
		
		$("#selType").bindSelect({ //검색 조건
			options: [{'optionValue':'subject','optionText':'제목'},{'optionValue':'registerName','optionText':'등록자'}]
		});
		
		setGrid();	// 그리드 세팅
		
		searchSurvey();	// 검색
	}

	// 그리드 세팅
	function setGrid() {
		var headerData = [
		              	  {key:'SurveyID', label:'SurveyID', width:'8', align:'center', formatter:'checkbox',sort:false},
		                  {key:'Subject', label:'제목', width:'*', align:'center',
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				//if (this.item.State == 'F' || this.item.State == 'G') {
							   				html += "<a href=\"#none\" class=\"taTit\" onclick='openSurveyView(\"" + this.item.SurveyID + "\", \"" + this.item.State + "\")'>" + this.item.Subject + "</a>";
						   				//}
						   				html += "</div>";
						   			return html;
								}
		              	  },
		                  {key:'CompanyName', label:'<spring:message code="Cache.lbl_OwnedCompany"/>', width:'20', align:'center'}, // 소유회사
		                  {key:'RegisterName', label:'등록자', width:'20', align:'center'},
		                  {key:'SurveyStartDate', label:'시작일', width:'20', align:'center'},
		                  {key:'SurveyEndDate', label:'종료일', width:'20', align:'center'},
		                  {key:'StateName', label:'진행상태', width:'20', align:'center'},
		                  {key:'통계보기', label:' ', width:'25', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				if (this.item.State == 'F' || this.item.State == 'G') {
						   					html += "<input type='button' class ='AXButton' value='통계보기' onclick='openSurveyReportPop(\"" + this.item.SurveyID + "\")'>";
						   				}
						   				html += "</div>";
						   			return html;
								}
		              	  },
		                  {key:'차트보기', label:' ', width:'25', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				if (this.item.State == 'F' || this.item.State == 'G') {
						   					html += "<input type='button' class ='AXButton' value='차트보기' onclick='goSurveyChartView(\"" + this.item.SurveyID + "\")'>";
						   				}
						   				html += "</div>";
						   			return html;
								}
		              	  },
		                  {key:'', label:' ', width:'28', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   			if (this.item.State == 'B' || this.item.State == 'D') {
						   				html += "<input type='button' value='승인' class ='AXButton' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "C" + "\",\"" + "승인" + "\")'> ";
						   				html += "<input type='button' value='거부' class ='AXButton' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "D" + "\",\"" + "거부" + "\")'>";
						   			} else if (this.item.State == 'C' || this.item.State == 'X') {
						   				html += "<input type='button' value='승인' class ='AXButton' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "F" + "\",\"" + "승인" + "\")'> ";
						   				html += "<input type='button' value='거부' class ='AXButton' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "X" + "\",\"" + "거부" + "\")'>";
						   			} else if (this.item.State == 'F') {
						   				html += "<input type='button' value='강제종료' class ='AXButton' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "G" + "\",\"" + "강제종료" + "\")'>";
						   			} else if (this.item.State == 'G') {
						   				html += "<input type='button' value='삭제' class ='AXButton BtnDelete' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "del" + "\",\"" + "삭제" + "\")'>";
						   			} 
					   				html += "</div>";
					   				
						   			return html;
								}
		                  }
			      		 ];
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			colHeadTool : false,
			height:"auto",
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function searchSurvey() { 
		var params = {sortBy : "RegistDate DESC", companyCode : $("#companySelectBox").val()};
		var schTxt = $('#schTxt').val();
		if (schTxt != '') {
			params.selType = $('#selType').val();
			params.schTxt = schTxt;
		}
		
		grid.bindGrid({
			ajaxUrl : "/groupware/survey/getSurveyManageList.do",
			ajaxPars : params,
		});
	}

	// 통계보기
	function openSurveyReportPop(surveyId) {
		CoviMenu_GetContent("/groupware/layout/survey_SurveyReport.do?CLSYS=survey&CLMD=admin&CLBIZ=Survey&surveyId="+surveyId);	
	}
	
	function goSurveyChartView(surveyId){
		Common.open("","chart_popup","설문결과 차트보기", "/groupware/survey/goSurveyChartView.do?surveyId=" + surveyId,"700px","500px","iframe",true,null,null,true);	// 설문 결과 보기
	}
	
	// 설문보기
	function openSurveyView(surveyId,state) {
		if(['F','G'].includes(state) ){
			//url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&viewType=resultView&communityId=' + communityId;	// 전체 결과 보기
			//location.href='/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&viewType=resultView&listType='+(state=='F' ? 'proceed' : 'complete')+'&communityId=0';
			window.open('/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&viewType=resultView&listType='+(state=='F' ? 'proceed' : 'complete')+'&communityId=0','_blank','fullscreen=yes' );
		}else{
			Common.open("","reqApproval_pop","설문 내용보기",'/groupware/survey/goSurveyReqApproval.do?CLSYS=survey&CLMD=user&reqType=reqApproval&CLBIZ=Survey&surveyId=' + surveyId,"1050px","600px","iframe",true,null,null,true);	// 설문 승인, 거부 팝업
		}
	}
	
	
	
	// 설문 상태 변경(B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
	function updateSurveyState(surveyId, afterState, qTxt) {
		var surveyIdArr = new Array();
		if (surveyId == '') {
		    $(grid.getCheckedListWithIndex(0)).each(function () {
		    	if ((afterState == 'C' || afterState == 'D') && (this.item.State == 'B' || this.item.State == 'D')) {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if ((afterState == 'F' || afterState == 'X') && (this.item.State == 'C' || this.item.State == 'X')) {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if (afterState == 'G' && this.item.State == 'F') {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if (afterState == 'del' && this.item.State == 'G') {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else{
		    		grid.checkedColSeq(0,false,this.index);
		    	}
		    });
		} else {
			surveyIdArr.push(surveyId);
		}
		
		if(surveyIdArr.length < 1){
			Common.Warning(qTxt+"가능한 항목이 없습니다.");
			return false;
		}
		
		var params = new Object();
		params.surveyIdArr = surveyIdArr;
		params.state = afterState;
		
       	Common.Confirm(qTxt + " 하시겠습니까?", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("설문이 " + qTxt + " 되었습니다.", "Inform", function() {
									searchSurvey();	// 검색
								});
			          		} else {
			          			Common.Warning("오류가 발생 하였습니다.");
			          		}
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax("/groupware/survey/updateSurveyState.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
</script>	
</body>
</html>
