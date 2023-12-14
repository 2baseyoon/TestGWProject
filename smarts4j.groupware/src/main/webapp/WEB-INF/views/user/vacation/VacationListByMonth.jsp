<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<style>
#gridDiv_AX_fixedTbody tr td { height:40px !important; } 
#gridDiv_AX_fixedTbody tr:first-child td { height:39px !important; }
.AXGrid .AXgridScrollBody .AXGridBody .gridFixedBodyTable tbody tr td .bodyNode.bodyTdText.bodyTdFile {overflow:visible}
</style>
<div class='cRConTop titType AtnTop'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_702' /></h2>
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div  >
			<div class="selectCalView">
				<covi:select className="selectType02" id="schYearSel" boxType="YEAR" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>"  startYear="<%=(Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4)%>" yearSize="6"></covi:select>
				<covi:select className="selectType02" id="schEmploySel">
					<option value=""><spring:message code='Cache.lbl_Whole' /></option>
				    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
				    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
				</covi:select>
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
		<div>
			<div class="chkStyle10">
				<input type="checkbox" class="check_class" id="stndCur" value="Y" onclick="$('#schYearSel').attr('disabled',$(this).is(':checked'))">
				<label for="stndCur"><span class="s_check"></span>[<%=ComUtils.GetLocalCurrentDate("yyyy/MM/dd")%>]<spring:message code='Cache.lbl_OnlyValid' /></label>
			</div>	
		</div>
		
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<%if (request.getParameter("reqType") != null && request.getParameter("reqType").equals("user")){ %>
				<div id="addSchOptions" style="display:inline-block">
					<span class="TopCont_option"><spring:message code='Cache.lbl_att_select_department'/></span>	<!-- 부서선택 -->
					<covi:select className="selectType02" id="deptList" queryId="groupware.vacation.selectDeptListSelect" boxType="DB">
					<option value=''><spring:message code='Cache.lbl_Whole'/></option>
					</covi:select>
				</div>
				<%} %>
				<a href="#" class="btnTypeDefault btnExcel"><spring:message code='Cache.lbl_SaveToExcel' /></a>
			</div>
			<div class="buttonStyleBoxRight">
				<div class="ATMbuttonStyleBoxRight" style="font-size:12px;">
					<covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
					<button href="#" class="btnRefresh" type="button" ></button>
				</div>
			</div>
		</div>
		<div class="tblList tblCont Nonefix">
			<div id="gridDiv">
				<covi:grid id="gridDiv" gridVar="vacationListByMonthGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="year"		label="lblNyunDo"	        width="60"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationListByMonth.formatYear"/>
					  <td key="DeptName"	label="lbl_dept"	        width="100"  align="center"  formatter="DIC"/>
					  <td key="DisplayName"	label="lbl_username"	width="60"  align="center"  formatter="FLOWER" formatAddtion="UR_Code,DisplayName"/>
					  <td key="EnterDate"	label="lbl_EnterDate"	width="80"  align="center"  formatter="DATE"/>
					  <td key="RetireDate"	label="lbl_RetireDate"	width="80"  align="center"  />
					  <td key="planVacDay"	label="lbl_TotalVacation"	width="60"  align="center"  formatter="NUMBER"/>
					  <td key="useDays"		label="lbl_apv_Use"		width="60"  align="center"  formatter="NUMBER"/>
					  <td key="remindDays"	label="lbl_appjanyu"	width="60"  align="center"  formatter="NUMBER"/>
					  <c:forEach begin="1" end="12" varStatus="st">
						  <td key="VacDay_${st.index}"	label="lbl_Month_${st.index}"	width="50"  align="center" />
					  </c:forEach>
					  <td key="1"		label=""	width="60"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationListByMonth.formatView"/>
					</tr>  
				</covi:grid>
			</div>
		</div>
		<div id=divDate>
	        <span class="dateTip">
	        	<spring:message code='Cache.msg_onlyDeduc'/>
	        </span>
        </div>
	</div>
</div>

<script>
var vacationVacationListByMonth = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var reqType = CFN_GetQueryString("reqType");
	var grid = new coviGrid();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);

	this.formatYear=function(item) {
		var html = "";
  		if ($("#stndCur").is(':checked') && "<%=ComUtils.GetLocalCurrentDate("yyyy")%>"!= this.item.year)
  			html = "<font style='font-weight:bold;color:#4ABDE1'>";
  		html+=coviCmn.isNull(item.year,'');
  		return html;
	}
	
	this.formatView=function(item) {
		var html = "<div>";
		html += "<a href='#' class='btnDocView' onclick='vacationVacationListByMonth.openVacationInfoPopup(\"" + item.UR_Code + "\", \"" + item.year + "\"); return false;'>";
		html += "<spring:message code='Cache.lbl_view' />";
		html += "</a>";
		html += "</div>";
			
		return html;
	}
		
	// 부서휴가월별현황, 휴가월별현황
	this.initContent=function(bLoad, linkUrl) {
		reqType = CFN_GetQueryString("reqType", linkUrl);

		init();	// 초기화

		if (bLoad != true){
			if (reqType == 'user') {
				$('#reqTypeTxt').text('<spring:message code="Cache.MN_665" />');
	 			$("#schEmploySel").show();
			}
			
	 		grid.setGridConfig(vacationListByMonthGrid);
			search();	// 검색
		}else{
			grid.bindEvent(true);
		}
	}
	
	// 초기화
	function init() {
		$('#schUrName').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
		        
		        search();
		    }
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

		$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		});	
		
 		$("#deptList").change(function(){
 			search();
 		});

 		
	}
	
	// 검색
	function search() {
 		//console.log(grid.config)
		var params = {
			displayName : $('#schUrName').val(),
			reqType : reqType,
			year : $('#schYearSel').val(),
			stndCur :$("#stndCur").is(':checked')?"Y":"N",
			schEmploySel : $('#schEmploySel').val(),
			DEPTID : ($("#deptList").val() == null ? "" : $("#deptList").val())
		}; // DeptSortKey, B.SortKey ASC
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationListByMonth.do",
			ajaxPars : params
		});
	}
	
	// 이름 클릭
	this.openVacationInfoPopup=function(urCode, year) {
		Common.open("","target_pop","<spring:message code='Cache.MN_657' />","/groupware/vacation/goVacationInfoPopup.do?urCode="+urCode+"&year="+year,"1000px","550px","iframe",true,null,null,true);
	}
	
	// 엑셀 파일 다운로드
	function excelDownload() {
		var sortInfo = grid.getSortParam("one").split("=");
		var	sortBy = sortInfo.length>1? sortInfo[1]:"";

		// 페이지 이동 시, 예전 엑셀 파일 내려받아지는 경우 있어서 수정함.
		location.href = "/groupware/vacation/excelDownloadForVacationListByMonth.do?"
			+"reqType="+reqType
			+"&year="+$('#schYearSel').val()
			+"&displayName="+$('#schUrName').val()
			+"&schEmploySel="+$('#schEmploySel').val()
			+"&deptName="+($("#deptList").val() == null ? "" : $("#deptList option:selected" ).text())
			+"&DEPTID="+($("#deptList").val() == null ? "" : $("#deptList").val())
			+"&sortBy="+sortBy;
		
	}
}();	

$(document).ready(function(){
	vacationVacationListByMonth.initContent();
});

</script>			