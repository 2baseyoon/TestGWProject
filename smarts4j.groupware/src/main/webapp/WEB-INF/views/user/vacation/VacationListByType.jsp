<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<div class='cRConTop titType AtnTop'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_701' /></h2>
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width:580px;">
			<div class="selectCalView">
				<covi:select className="selectType02" id="schYearSel" boxType="YEAR" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>"  startYear="<%=(Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4)%>" yearSize="6"></covi:select>
				<covi:select className="selectType02" id="schTypeSel">
				    <option value="deptName" ><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
				</covi:select>
				<covi:select className="selectType02" id="schEmploySel" style="display: none;">
					<option value=""><spring:message code='Cache.lbl_Whole' /></option>
				    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
				    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
				</covi:select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
		<div style="width:550px;">
			<div class="chkStyle10" style="display:block">
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
				<div class="ATMbuttonStyleBoxRight" style="font-size:12px;display:none">
					<input type="checkbox" id="ckb_extra_vacation"> 기타휴가
				</div>
				<covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE">
				</covi:select>
				<button href="#" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
				<covi:grid id="gridDiv" gridVar="vacationListByTypeGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="year"		label="lblNyunDo"	    width="80"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationListByType.formatYear"/>
					  <td key="DeptName"	label="lbl_dept"	    width="130"  align="center"  formatter="DIC" />
					  <td key="DisplayName"	label="lbl_username"	width="100"  align="center"  formatter="FLOWER" formatAddtion="UR_Code,DisplayName" linkEvent="vacationVacationListByType.openVacationInfoPopup"/>
					  <td key="JobPositionName"	label="lbl_JobPosition"	width="100"  align="center"  />
					  <td key="EnterDate"	label="lbl_EnterDate"	width="120"  align="center"  formatter="DATE"/>
					  <td key="RetireDate"	label="lbl_RetireDate"	width="120"  align="center"  />
					  <td key="planVacDay"	label="lbl_TotalVacation"	width="60"  align="center"  formatter="NUMBER"/>
					  <td key="useDays"		label="lbl_apv_Use"		width="60"  align="center"  formatter="NUMBER"/>
					  <td key="remindDays"	label="lbl_appjanyu"	width="80"  align="center"  formatter="NUMBER"/>
					</tr>  
				</covi:grid>
			</div>
		</div>
	</div>
</div>

<script>
/*공통 load*/
var vacationVacationListByType = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var lang = Common.getSession("lang");
	var reqType = CFN_GetQueryString("reqType");	// reqType : dept(부서휴가유형별조회), user(휴가유형별현황)
	var grid = new coviGrid();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	
	this.formatYear = function(item){
  		var html = "";
  		if ($("#stndCur").is(':checked') && "<%=ComUtils.GetLocalCurrentDate("yyyy")%>"!= item.year)
  			html = "<font style='font-weight:bold;color:#4ABDE1'>";
  		html+=item.year;
  		return html;

	}
	
	// 부서휴가유형별조회, 휴가유형별현황
	this.initContent = function(bLoad, linkUrl) {
		init();	// 초기화

		reqType = CFN_GetQueryString("reqType", linkUrl);
		
		if (bLoad != true){
			$.ajax({
				url : "/groupware/vacation/getVacTypeCol.do",
				type: "POST",
				dataType : 'json',
				data :{ "vacPageSize":5, "hideExtraVacation":$("#ckb_extra_vacation").is(":checked")?'N':'Y'},
				async: false,
				success:function (data) {
					var listData = data.list;
					for(var i=0;i<listData.length;i++){
						var listCode = "VAC_"+listData[i].Code;
						vacationListByTypeGrid["colGroup"].push({key:listCode, label:CFN_GetDicInfo(listData[i].MultiCodeName, lang), width:'100', align:'center',sort:false});
					}
					vacationListByTypeGrid["colGroup"].push({key:"EtcVac",  label:"<spring:message code='Cache.lbl_hr_base'/> <spring:message code='Cache.lbl_att_and'/>", width:'100', align:'center',sort:false});
				}
			});

	 		if (reqType == 'user') {
	 			$("#schEmploySel").show();
	 		}
			grid.setGridConfig(vacationListByTypeGrid);
			search();	// 검색
		}else{
			grid.bindEvent(true);
		}
	}
	
	// 초기화
	var init=function() {
		
		$('#schUrName').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
		        
		        var schName = $('#schUrName').val();
		        
		        $('#schTypeSel').val('displayName');
		        $('#schTxt').val(schName);
				
		        search();
		    }
		});
		
		$('#schTxt').on('keypress', function(e){ 
			if (e.which == 13) {
		        e.preventDefault();
			
		        search();
		    }
		});

		$("#ckb_extra_vacation").change(function() {
			search();
		});
		
		// 검색 버튼
//		tab.addEventListener('keydown', this.onKeydown.bind(this));
//		$('.btnSearchBlue').addEventListener('click', this.search());
		
		
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
		
 		$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		});
 		
		// 엑셀저장
		$('.btnExcel').on('click', function(e) {
			excelDownload();
		});	

 		$("#deptList").change(function(){
 			search();
 		});
	}
	
	// 검색
	function search() {
		var params =getRequestParams();
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationListByType.do",
			ajaxPars : params
		});
	}
	
	function getRequestParams(){
		var params = {
			urName : $('#schUrName').val(),
			reqType : reqType,
			stndCur :$("#stndCur").is(':checked')?"Y":"N",
			year : $('#schYearSel').val(),
			hideExtraVacation : $("#ckb_extra_vacation").is(":checked")?'N':'Y',
			schTypeSel : $('#schTypeSel').val(),
			schEmploySel : $('#schEmploySel').val(),
			DEPTID : ($("#deptList").val() == null ? "" : $("#deptList").val()),
			schTxt : $('#schTxt').val()
		};
		return params;
	}
	// 이름 클릭
	this.openVacationInfoPopup=function(item) {
		let urCode = item.UR_Code;
		let year = item.year;
		Common.open("","target_pop","<spring:message code='Cache.MN_657' />","/groupware/vacation/goVacationInfoPopup.do?urCode="+urCode+"&year="+year,"1000px","550px","iframe",true,null,null,true);
	}
	
	// 엑셀 파일 다운로드 (기초코드 설정에 따라 컬럼이 달라지므로 공통 엑셀 다운로드 사용)
	function excelDownload(){
		coviUtil.exportGridExcel("/groupware/vacation/excelDownloadForVacationListByType.do",getRequestParams() , grid);
	}
}();

$(document).ready(function(){
	vacationVacationListByType.initContent();
});

</script>			