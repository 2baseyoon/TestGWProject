<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil
,egovframework.coviframework.util.ComUtils,egovframework.coviframework.util.DicHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<%
String mode = ComUtils.removeMaskAll(request.getParameter("mode"));
%>
<style>
	.selectType02, .selectType02 option {
		color:#717b85;font-size:12px
	}
	.chkStyle06 {
		margin-right : 10px;
	}
	.chkStyle06 label {
		padding-left : 14px;
		font-size : 13px;
	}
</style>
<div class='cRConTop titType AtnTop'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_vacationUseStatus' /><%=(!mode.equals("DEPT")?"["+DicHelper.getDic("lbl_apv_chkShareDept")+"]":"") %></h2>
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" ><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width : 700px;">
			<div class="selectCalView">
				<covi:select className="selectType02" id="schTypeSel">
				    <option value="deptName" ><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
				</covi:select>
				<div class="dateSel type02">
					<input id="schTxt" type="text" class="HtmlCheckXSS ScriptCheckXSS">
				</div>											
				<spring:message code='Cache.lbl_Period'/>	<!-- 기간 -->
				<span><covi:select  className="selectType02" id="monthSel">
					<option value=''><spring:message code="Cache.lbl_all" /></option>
				<%for (int i=1; i <13;i++){
					out.println("<option value='"+(i<10?"0"+i:i)+"'>"+i+"월</option>");
				}%>
				</covi:select></span>
				<span><covi:select  className="selectType02 W80" id="vacFlagSel" boxType="CODE" codeGroups="VACATION_TYPE">
						<option value=''><spring:message code="Cache.lbl_all" /></option>
						<option value="VACATION_TYPE_MULTI"><spring:message code="Cache.lbl_MultiSearch" /></option>
					</covi:select></span>
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
				<div id="vacMultiCheckBox" style="display:none"></div>
			</div>
		</div>	
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<covi:select className="selectType02" id="schYearSel" boxType="YEAR" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>"  startYear="<%=(Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4)%>" yearSize="6"></covi:select>
				<%if ("DEPT".equals(mode)){ %>
				<div id="addSchOptions" style="display:inline-block">
					<span class="TopCont_option"><spring:message code='Cache.lbl_att_select_department'/></span>	<!-- 부서선택 -->
					<covi:select className="selectType02" id="deptList" queryId="groupware.vacation.selectDeptListSelect" boxType="DB">
					<option value=''><spring:message code='Cache.lbl_Whole'/></option>
					</covi:select>
				</div>
				<% }%>
				<a href="#" class="btnTypeDefault btnExcel"><spring:message code='Cache.lbl_SaveToExcel' /></a>
			</div>
			<div class="buttonStyleBoxRight">	
				<covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE">
				</covi:select>
				<button href="#" class="btnRefresh" type="button"></button>							
			</div>
		</div>
		<div class="tblList tblCont Nonefix">
			<div id="gridDiv">
				<covi:grid id="gridDiv" gridVar="vacationListByUseGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>					  
					  <td key="VacYear"		label="lblNyunDo"	        width="15"  align="center" />
					  <td key="AppDate"		label="lbl_DraftDate"	    width="40"  align="center" />
					  <td key="EndDate"		label="lbl_apv_accepted"	width="40"  align="center" />
					  <td key="UpDeptName"	label="lbl_ParentDeptName"	width="40"  align="center" />
					  <td key="DeptName"	label="lbl_dept"	        width="35"  align="center"  formatter="DIC" />
					  <td key="NameAndCode"	label="lbl_username"	width="50"  align="center"  formatter="FLOWER" formatAddtion="UR_Code,NameAndCode"/>	
					  <td key="JobPositionName"	label="lbl_JobPosition"	width="20"  align="center"/>
					  <td key="VacText"	label="lbl_Gubun"	width="30"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationListByUse.formatVacText"/>
					  <td key="Sdate"	label="lbl_startdate"	width="30"  align="center"/>
					  <td key="Edate"	label="lbl_EndDate"	width="30"  align="center"  />
					  <td key="VacDay"	label="lbl_used_days"	width="20"  align="center" />
					  <td key="Reason"	label="lbl_Reason"		width="120"  align="left"/>
					</tr>  
				</covi:grid>
			</div>
		</div>
	</div>
</div>

<script>
var vacationVacationListByUse = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	var reqType = CFN_GetQueryString("reqType");
	var grid = new coviGrid();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	
	this.formatVacText= function(item){
		var html = "<div>";
		if (item.Gubun == 'VACATION_PUBLIC' || item.Gubun == 'VACATION_PUBLIC_CANCEL') {
			html += "<a href='#' onclick='Common.Inform(\"<spring:message code='Cache.lbl_vacationMsg25' />\"); return false;'>";
		} else if (typeof(item.ProcessID) == 'undefined' || typeof(item.WorkItemID) == 'undefined') {
			html += "<a href='#' onclick='Common.Inform(\"<spring:message code='Cache.lbl_vacationMsg26' />\"); return false;'>";
		} else {
			html += "<a href='#' onclick='vacationVacationListByUse.openVacationViewPopup(\"" + item.UR_Code + "\", \"" + item.ProcessID + "\", \"" + item.WorkItemID + "\"); return false;'>";
		}
		html += item.VacText;
		html += "</a>";
		html += "</div>";
			
		return html;
	}	
	
	// 부서휴가월별현황, 휴가월별현황
	this.initContent = function(bLoad, linkUrl) {
		init();	// 초기화
		if (bLoad != true){
			grid.setGridConfig(vacationListByUseGrid);
	 		search();
		}else{
			grid.bindEvent(true);
		}
		
	}
	
	// 초기화
	function init() {
		$('#schUrName, #schTxt').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
		        
		        search();
		    }
		});
		
		$("#schYearSel, #deptList").on('change', function(e) {
			search();
		});
		
		// 검색 버튼
		$('.btnSearchType01, .btnSearchBlue, .btnRefresh').on('click', function(e) {
			search();
		});
		
		// 상세 보기
 		$('.btnDetails').on('click', function(){
			var mParent = $('.inPerView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});
		
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			CFN_SetCookieDay("VacListCnt", $(this).find("option:selected").val(), 31536000000);
			grid.reloadList();
		});	
		
		// 엑셀저장
		$('.btnExcel').on('click', function(e) {
			excelDownload();
		});	
		
		//다중검색
		$("#vacFlagSel").change(function(){
			var vacFlagSelVal = $("#vacFlagSel").val();
			if(vacFlagSelVal == "VACATION_TYPE_MULTI"){
				var html = "";
				var i = 0;
				
				$.ajaxSetup({
				     async: false
				});
				
				html = "<ul class='checkboxWrap'>";
				i = 1;
				const vacationType = Common.getBaseCode('VACATION_TYPE').CacheData;
				vacationType.forEach(function(item, idx) {
					html += "<li class='chkStyle06'>";
					html += "	<input type='checkbox' value='" + item.Code + "' id='ck" + i + "_p' name='chkItem'><label for='ck" + i + "_p'>" + item.CodeName + "</label>";
					html += "</li>";
						i++;
					});
				html += "</ul>";
				
				$("#vacMultiCheckBox").append(html);
				$("#vacMultiCheckBox").css("display","block");
				
			}else{
				$("#vacMultiCheckBox").css("display","none");
				$(".checkboxWrap").remove();
			}
		});
	}
	// 검색
	function search() {
		var sField = "";
		
		$("input[name=chkItem]:checked").each(function (index) {
			sField += $("input[name=chkItem]:checked").eq(index).val() + ",";
		});	
		
		var params = {"mode":"<%=mode%>"
				,"year":$('#schYearSel').val()
				,"DEPTID":($("#deptList").val() == null ? "" : $("#deptList").val())
				,"schUrName":$('#schUrName').val()
				,"schTypeSel":$('#schTypeSel').val()
				,"schTxt":$('#schTxt').val()
				,"month":$('#monthSel').val()
				,"vacFlag":$('#vacFlagSel').val()
				,"gubun":$('#gubunSel').val()
				,"VacTypeArr" : sField}; // DeptSortKey, B.SortKey ASC
				
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationListByUse.do",
			ajaxPars : params
		});
	}
	

	// 휴가 신청/취소 내역
	this.openVacationViewPopup=function(urCode, processId, workItemId) {
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
	}

	// 엑셀 파일 다운로드
	function excelDownload() {
		var sField = "";
		var sortInfo = grid.getSortParam("one").split("=");
		var sortBy = sortInfo.length > 1 ? sortInfo[1] : "";
		
		$("input[name=chkItem]:checked").each(function (index) {
			sField += $("input[name=chkItem]:checked").eq(index).val() + ",";
		});	
		// 페이지 이동 시, 예전 엑셀 파일 내려받아지는 경우 있어서 수정함.
		location.href = "/groupware/vacation/excelDownloadForVacationListByUse.do?"
			+"mode=<%=mode%>"
			+"&year="+$('#schYearSel').val()
			+"&DEPTID="+($("#deptList").val() == null ? "" : $("#deptList").val())
			+"&displayName="+$('#schUrName').val()
			+"&schTypeSel="+$('#schTypeSel').val()
			+"&schTxt="+$('#schTxt').val()
			+"&month="+$('#monthSel').val()
			+"&vacFlag="+$('#vacFlagSel').val()
			+"&gubun="+$('#gubunSel').val()
			+"&deptName="+($("#deptList").val() == null ? "" : $("#deptList option:selected" ).text())
			+"&VacTypeArr="+sField
			+"&sortBy="+sortBy;
		
	}
}();

$(document).ready(function(){
	vacationVacationListByUse.initContent();
});
</script>			