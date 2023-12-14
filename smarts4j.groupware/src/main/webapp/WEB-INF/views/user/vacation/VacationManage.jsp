<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_663' /></h2>
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width: 580px;">
			<div class="selectCalView">
				<covi:select className="selectType02" id="schYearSel" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>" boxType="YEAR" ></covi:select>				
				<covi:select className="selectType02" id="schEmploySel">
						<option value=""><spring:message code='Cache.lbl_Whole' /></option>
					    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
					    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
				</covi:select>
				
				<covi:select className="selectType02" id="schTypeSel">
				    <option value="deptName"><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
				</covi:select>
				
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>											
			</div>
			<div>
				<a href="#"  class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
	</div>
	<div class="boardAllCont">
		<div class="mt20 tabMenuCont">
			<ul class="tabMenu clearFloat tabMenuType02">
				<li class="topToggle active"><a href="#" onclick="vacationVacationManage.toggleTab('1');"><spring:message code='Cache.lbl_apv_annual' /> <spring:message code='Cache.lbl_Occurrence' /> <spring:message code='Cache.TodoCategory_Admin' /></a></li>
				<li class="topToggle"><a href="#" onclick="vacationVacationManage.toggleTab('4');"><spring:message code='Cache.lbl_n_att_rewardVac' /> <spring:message code='Cache.lbl_Occurrence' /> <spring:message code='Cache.TodoCategory_Admin' /></a></li>
				<li class="topToggle"><a href="#" onclick="vacationVacationManage.toggleTab('2');"><spring:message code='Cache.lbl_Etc' /><spring:message code='Cache.lbl_Vacation' /> <spring:message code='Cache.lbl_Occurrence' /> <spring:message code='Cache.TodoCategory_Admin' /></a></li>
				<li class="topToggle"><a href="#" onclick="vacationVacationManage.toggleTab('3');"><spring:message code='Cache.lbl_Joint' /><spring:message code='Cache.lbl_apv_annual' /> <spring:message code='Cache.lbl_Use' /> <spring:message code='Cache.TodoCategory_Admin' /></a></li>
			</ul>
		</div>
		<div class="boradTopCont" id="boradTopCont_1" style="display: block;">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="#" class="btnTypeDefault btnTypeChk" id="insVacBtn" onclick="vacationVacationManage.openVacationInsertPopup();" style="display:none"><spring:message code='Cache.btn_register' /></a>
				<a href="#" class="btnTypeDefault" id="vacPeriodBtn" onclick="vacationVacationManage.openVacationPeriodManagePopup();" style="display:none"><spring:message code='Cache.lbl_apv_setVacTerm' /></a>
				<a href="#" class="btnTypeDefault btnRepeatGray" id="btnDeptInfo" onclick="vacationVacationManage.updateDeptInfo();" style="display:none"><spring:message code='Cache.lbl_attend_currentYearSync' /></a><!-- 현재년도 부서정보 동기화 -->
				<a href="#" class="btnTypeDefault btnExcel" id="excelUpBtn" onclick="vacationVacationManage.openVacationInsertByExcelPopup();" style="display:none"><spring:message code='Cache.Personnel_ExcelAdd' /></a>
				<a href="#" class="btnTypeDefault btnExcel" onclick="vacationVacationManage.excelListDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a> 
				<div id=divDate>
			        <span class="dateTip">
			        	<spring:message code='Cache.msg_occVac'/>
			        </span>
		        </div>
				
			</div>
			<div class="buttonStyleBoxRight">
				<covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<div class="boradTopCont" id="boradTopCont_2" style="display: none;">
			<div class="pagingType02 buttonStyleBoxLeft" >
				<a href="#" class="btnTypeDefault btnTypeChk" id="insExtraVacBtn" onclick="vacationVacationManage.openExtraVacationInsertPopup();"><spring:message code='Cache.btn_register' /></a>
				<%--<a href="#" class="btnTypeDefault btnExcel" id="excelDownBtn2" onclick="excelDownload2();"><spring:message code='Cache.lbl_templatedownload' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelUpBtn2" onclick="openVacationInsertByExcelPopup2();"><spring:message code='Cache.btn_ExcelUpload' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelCanBtn2" onclick="openVacationCancelByExcelPopup2();"><spring:message code='Cache.lbl_common_vacation_cancel' /></a>--%>
				<a href="#" class="btnTypeDefault btnExcel" onclick="vacationVacationManage.excelListDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a> 
					
				<a href="#" class="btnTypeDefault" style="visibility: hidden"></a>
				<div id=divDate>
			        <span class="dateTip">
			        	<spring:message code='Cache.msg_occVac'/>
			        </span>
		        </div>
        	</div>
			<div class="buttonStyleBoxRight">
				<covi:select className="selectType02 listCount" id="listCntSel2" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<div class="boradTopCont" id="boradTopCont_3" style="display: none;">
			<div class="pagingType02 buttonStyleBoxLeft" >
				<a href="#" class="btnTypeDefault btnTypeChk" id="insJointVacBtn" onclick="vacationVacationManage.openJointVacationInsertPopup();"><spring:message code='Cache.btn_register' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelUpBtn3" onclick="vacationVacationManage.openVacationInsertByExcelPopup3();"><spring:message code='Cache.Personnel_ExcelAdd' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelCanBtn" onclick="vacationVacationManage.openVacationCancelByExcelPopup3();"><spring:message code='Cache.lbl_common_vacation_cancel' /></a>
				<a href="#" class="btnTypeDefault btnExcel" onclick="vacationVacationManage.excelListDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a> 
				<a href="#" class="btnTypeDefault" style="visibility: hidden"></a>
				<div id=divDate>
			        <span class="dateTip">
			        	<spring:message code='Cache.msg_useVac'/>
			        </span>
		        </div>
			</div>
			<div class="buttonStyleBoxRight">
				<covi:select className="selectType02 listCount" id="listCntSel3" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<div class="boradTopCont" id="boradTopCont_4" style="display: none;">
			<div class="pagingType02 buttonStyleBoxLeft" >
				<a href="#" class="btnTypeDefault btnTypeChk" id="insExtraVacBtn" onclick="vacationVacationManage.openRewardVacationInsertPopup();"><spring:message code='Cache.btn_register' /></a>
				<%--<a href="#" class="btnTypeDefault btnExcel" id="excelDownBtn2" onclick="excelDownload2();"><spring:message code='Cache.lbl_templatedownload' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelUpBtn2" onclick="openVacationInsertByExcelPopup2();"><spring:message code='Cache.btn_ExcelUpload' /></a>
				<a href="#" class="btnTypeDefault btnExcel" id="excelCanBtn2" onclick="openVacationCancelByExcelPopup2();"><spring:message code='Cache.lbl_common_vacation_cancel' /></a>--%>
				<a href="#" class="btnTypeDefault btnExcel" onclick="vacationVacationManage.excelListDownload();"><spring:message code='Cache.lbl_SaveToExcel' /></a> 
					
				<a href="#" class="btnTypeDefault" style="visibility: hidden"></a>
				<div id=divDate>
			        <span class="dateTip">
			        	<spring:message code='Cache.msg_occVac'/>
			        </span>
		        </div>
        	</div>
			<div class="buttonStyleBoxRight">
				<covi:select className="selectType02 listCount" id="listCntSel4" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
				<covi:grid id="gridDiv" gridVar="vacationManageGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="DeptName"		label="lbl_dept"	        width="100"  align="center"  formatter="LINK" linkEvent="vacationVacationManage.openVacationUpdatePopup"/>
					  <td key="DisplayName"		label="lbl_username"	    width="100"	align="center" formatter="FLOWER" formatAddtion="UR_Code,DisplayName" linkEvent="vacationVacationManage.openVacationUpdatePopup"/> 
					  <td key="JobPositionName"	label="lbl_apv_jobposition"	width="100"	align="center"/> <!--직위 -->
					  <td key="EnterDate"		label="lbl_EnterDate"	    width="100"	align="center"/> <!--입사일 -->
					  <td key="ExpDate"			label="lbl_expiryDate"	    width="100"	align="center" formatter="TERM" formatAddtion="ExpDateStart,ExpDateEnd"/> <!--유효기간 -->
					  <td key="VacDay"			label="lbl_TotalVacation"	width="50"	align="center" formatter="LINK"  linkEvent="vacationVacationManage.openVacationPlanHistPopup"/>
					  <td key="UseVacDay"		label="lbl_Use"		        width="50"	align="center" sort="false"/> <!-- 사용 -->
					  <td key="RemainVacDay"	label="lbl_n_att_remain"    width="50"	align="center" sort="false"/><!-- 잔여 -->
					  <td key="LastVacDay"		label="lbl_vacationMsg64"   width='50'  align='center' sort="false" hideFilter="<%=(RedisDataUtil.getBaseConfig("DisplayLastVacDay").equals("N")?"Y":"N")%>" 
					  		display="<%=(RedisDataUtil.getBaseConfig("DisplayLastVacDay").equals("N")?false:true)%>" /> <!-- 이월년차-->
					</tr>
				</covi:grid>
			</div>
			<div id="gridDiv2" style="display: none;">
				<covi:grid id="gridDiv2" gridVar="vacationManageGrid2" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="DeptName"		label="lbl_dept"	        width="100" align="center"  formatter="DIC"/>
					  <td key="DisplayName"		label="lbl_username"	    width="100"	align="center" 	formatter="FLOWER"  formatAddtion="UR_Code,DisplayName" />
					  <td key="JobPositionName"	label="lbl_apv_jobposition"	width="100"	align="center" /> <!--직위 --> 
					  <td key="ExtVacName"		label="VACATION_TYPE_VACATION_TYPE"	    width="100"		align="center" formatter="LINK" linkEvent="vacationVacationManage.openExtraVacationUpdatePopup"/>
					  <td key="ExpDate"			label="lbl_expiryDate"		width="100"	align="center" /> <!-- 유효기간 -->
					  <td key="ExpYN"			label="lbl_ExpiryYN"		width="50"	align="center"  formatter="CUSTOM" formatAddtion="vacationVacationManage.formatExpYN" /> <!-- 유효여부 -->
					  <td key="ExtVacDay"		label="lbl_Vacation"		width="50"	align="center"  formatter="LINK"  linkEvent="vacationVacationManage.openExtVacationPlanHistPopup"/>
					  <td key="ExtUseVacDay"	label="lbl_Use"    			width="50"	align="center" /><!-- 사용 -->
					  <td key="IsUse"			label="lbl_IsUse"   		width='50'  align='center' 	formatter="CUSTOM" formatAddtion="vacationVacationManage.formatUse" /> <!-- 잔여-->
					</tr>
				</covi:grid>
			</div>
			<div id="gridDiv3" style="display: none;">
				<covi:grid id="gridDiv3" gridVar="vacationManageGrid3" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="DeptName"		label="lbl_dept"	        width="80"  align="left"  formatter="DIC"/>
					  <td key="DisplayName"		label="lbl_username"	    width="70"	align="center"/>
					  <td key="GubunName"		label="lbl_Gubun"	    	width="60"	align="center" formatter="CUSTOM" formatAddtion="vacationVacationManage.formatGubunName"/> 	
					  <td key="VacFlagName"		label="VACATION_TYPE_VACATION_TYPE"		width="50"	align="center"/>
					  <td key="APPDATE"			label="lbl_ProcessDate"		width="100"	align="center"/>
					  <td key="Sdate"			label="lbl_startdate"		width="50"	align="center"/>
					  <td key="Edate"			label="lbl_EndDate"			width="50"	align="center"/>
					  <td key="VacDay"			label="lbl_UseVacation"		width="50"	align="center"/>
					  <td key="Reason"			label="lbl_Reason"			width="200"	align="left"/>
					</tr>
				</covi:grid>
			</div>
			<div id="gridDiv4" style="display: none;">
				<covi:grid id="gridDiv4" gridVar="vacationManageGrid4" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="DeptName"		label="lbl_dept"	        width="100" align="center"  formatter="DIC"/>
					  <td key="DisplayName"		label="lbl_username"	    width="100"	align="center" 	formatter="FLOWER"  formatAddtion="UR_Code,DisplayName" />
					  <td key="JobPositionName"	label="lbl_apv_jobposition"	width="100"	align="center" /> <!--직위 --> 
					  <td key="ExtVacName"		label="VACATION_TYPE_VACATION_TYPE"	    width="100"		align="center" formatter="LINK" linkEvent="vacationVacationManage.openRewardVacationUpdatePopup"/>
					  <td key="ExpDate"			label="lbl_expiryDate"		width="100"	align="center" /> <!-- 유효기간 -->
					  <td key="ExpYN"			label="lbl_ExpiryYN"		width="50"	align="center"  formatter="CUSTOM" formatAddtion="vacationVacationManage.formatExpYN" /> <!-- 유효여부 -->
					  <td key="ExtVacDay"		label="lbl_Vacation"		width="50"	align="center"  formatter="LINK"  linkEvent="vacationVacationManage.openRwdVacationPlanHistPopup"/>
					  <td key="ExtUseVacDay"	label="lbl_Use"    			width="50"	align="center" /><!-- 사용 -->
					  <td key="IsUse"			label="lbl_IsUse"   		width='50'  align='center' 	formatter="CUSTOM" formatAddtion="vacationVacationManage.formatUse" /> <!-- 잔여-->
					</tr>
				</covi:grid>
			</div>
		</div>
	</div>
</div>

<script>
var vacationVacationManage  = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var tabNo = 1;
	var reqType = CFN_GetQueryString("reqType");	// reqType : manage(연차관리),  promotionPeriod(연차촉진 기간설정)
	var grid  = new coviGrid();
	var grid2 = new coviGrid();
	var grid3 = new coviGrid();
	var grid4 = new coviGrid();
	var duplChkUserIdArr = new Array();
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

	this.initContent = function(bLoad, linkUrl) {
		if(CFN_GetCookie("VacListCnt")){
			pageSize = CFN_GetCookie("VacListCnt");
		}
		$("#listCntSel").val(pageSize);
		
		init();	// 초기화
		
		if (bLoad != true){
			grid.setGridConfig(vacationManageGrid);
			search();	// 검색
		}else{
			grid.bindEvent(true);
			grid2.bindEvent(true);
			grid3.bindEvent(true);
			grid4.bindEvent(true);
		}	
	}
	
	this.formatExpYN= function (item) {
		if (item["ExpYN"]==='Y'){
			return "O";
		}else{
			return "X";
		}
	}

	this.formatUse= function (item) {
		if (item["IsUse"]==='Y'){
			return "사용가능";
		}else{
			return "사용불가";
		}
	}
	
	this.formatGubunName=function (item){
		var html = "<div>";
		var gubunName = item.GubunName;
		if (item.GUBUN == 'VACATION_PUBLIC' || item.GUBUN == 'VACATION_APPLY') {
			html += "<a href='#' onclick='vacationVacationManage.openVacationCancelPopup(\"" + item.VacationInfoID + "\", \"" + item.VacYear + "\"); return false;'>";
			html += gubunName;
			html += "</a>";
		} else {
			html += gubunName;
		}
		html += "</div>";
	
		return html;
	}
	
	// 초기화
	function init() {
		// 그리드 카운트
		$('#listCntSel').on('change', function (e) {
			var pageSize = $(this).val();
			grid.page.pageSize  = pageSize;
			grid2.page.pageSize = pageSize;
			grid3.page.pageSize = pageSize;
			$("#listCntSel2").val(pageSize).prop("selected", true);
			$("#listCntSel3").val(pageSize).prop("selected", true);
			$("#listCntSel4").val(pageSize).prop("selected", true);
			CFN_SetCookieDay("VacListCnt", $(this).find("option:selected").val(), 31536000000);
			grid.reloadList();
		});
		$('#listCntSel2').on('change', function (e) {
			var pageSize = $(this).val();
			grid.page.pageSize  = pageSize;
			grid2.page.pageSize = pageSize;
			grid3.page.pageSize = pageSize;
			$("#listCntSel").val(pageSize).prop("selected", true);
			$("#listCntSel3").val(pageSize).prop("selected", true);
			$("#listCntSel4").val(pageSize).prop("selected", true);
			grid2.reloadList();
		});
		$('#listCntSel3').on('change', function (e) {
			var pageSize = $(this).val();
			grid.page.pageSize  = pageSize;
			grid2.page.pageSize = pageSize;
			grid3.page.pageSize = pageSize;
			$("#listCntSel").val(pageSize).prop("selected", true);
			$("#listCntSel2").val(pageSize).prop("selected", true);
			$("#listCntSel4").val(pageSize).prop("selected", true);
			grid3.reloadList();
		});
		$('#listCntSel4').on('change', function (e) {
			var pageSize = $(this).val();
			grid.page.pageSize  = pageSize;
			grid2.page.pageSize = pageSize;
			grid3.page.pageSize = pageSize;
			$("#listCntSel").val(pageSize).prop("selected", true);
			$("#listCntSel2").val(pageSize).prop("selected", true);
			$("#listCntSel3").val(pageSize).prop("selected", true);
			grid4.reloadList();
		});
		
		if($$(Common.getBaseCode("VACATION_KIND")).find("CacheData[Code=REWARD]").length > 0){
			$(".topToggle").eq(1).show();
		}else{
			$(".topToggle").eq(1).hide();
		}
		
		// 화면 처리
//		$("#reqTypeTxt").html("<spring:message code='Cache.MN_663' />");
//		$('#excelDownBtn').html('<spring:message code="Cache.lbl_templatedownload" />');
//		$('#excelUpBtn').html('<spring:message code="Cache.Personnel_ExcelAdd" />');
		$('#genVacBtn, #insVacBtn, #excelDownBtn, #excelUpBtn').css('display', '');
		$('#btnDeptInfo').css('display', '');

		$('#schUrName').on('keypress', function (e) {
			if (e.which == 13) {
				e.preventDefault();

				var schName = $('#schUrName').val();

				$('#schTypeSel').val('displayName');
				$('#schTxt').val(schName);

				search();
			}
		});

		$('#schTxt').on('keypress', function (e) {
			if (e.which == 13) {
				e.preventDefault();

				search();
			}
		});


		// 검색 버튼
		$('.btnSearchType01, .btnSearchBlue, .btnRefresh').on('click', function (e) {
			search();
		});

		// 상세 보기
		$('.btnDetails').on('click', function () {
			var mParent = $('.inPerView');
			if (mParent.hasClass('active')) {
				mParent.removeClass('active');
				$(this).removeClass('active');
			} else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});


		$('.btnOnOff').unbind('click').on('click', function () {
			if ($(this).hasClass('active')) {
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			} else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');
			}
		});
	}
	// 엑셀 파일 다운로드
	this.excelListDownload=function() {
		// 연차관리
		if(tabNo===1){
			var sortInfo1 = grid.getSortParam("one").split("=");
			var sortBy1 = sortInfo1.length > 1 ? sortInfo1[1] : "";
			
 			location.href = "/groupware/vacation/excelDownVacationDayList.do?"
 				+"year="+$('#schYearSel').val()
 				+"&schTypeSel="+$('#schTypeSel').val()
 				+"&schEmploySel="+$('#schEmploySel').val()
 				+"&reqType="+reqType
 				+"&schTxt="+$('#schTxt').val()
 				+"&sortBy="+sortBy1;
 			
		// 기타연차관리
		}else if(tabNo===2){
			var sortInfo2 = grid2.getSortParam("one").split("=");
			var sortBy2 = sortInfo2.length > 1 ? sortInfo2[1] : "";
			
 			location.href = "/groupware/vacation/excelDownVacationExtraList.do?"
 				+"urName="+$('#schUrName').val()
 				+"&year="+$('#schYearSel').val()
 				+"&schTypeSel="+$('#schTypeSel').val()
 				+"&schTxt="+$('#schTxt').val()
 				+"&sortBy="+sortBy2;
		
 		// 공통연차관리
		}else if(tabNo===3){
			var sortInfo3 = grid3.getSortParam("one").split("=");
			var sortBy3 = sortInfo3.length > 1 ? sortInfo3[1] : "";
			
 			location.href = "/groupware/vacation/excelDownVacationInfoList.do?"
 				+"urName="+$('#schUrName').val()
 				+"&year="+$('#schYearSel').val()
 				+"&reqType="+reqType
 				+"&schTypeSel="+$('#schTypeSel').val()
 				+"&schTxt="+$('#schTxt').val()
 				+"&sortBy="+sortBy3;
 				+"&schTxt="+$('#schTxt').val();
 		// 보상휴가관리
		}else if(tabNo===4){
			location.href = "/groupware/vacation/excelDownVacationRewardList.do?"
				+"urName="+$('#schUrName').val()
				+"&year="+$('#schYearSel').val()
				+"&schTypeSel="+$('#schTypeSel').val()
				+"&schTxt="+$('#schTxt').val();
		}
	}
	
	// 검색
	function search() {
//		setGrid();
		var params = null;
		if(tabNo===1){
			params = {
				year : $('#schYearSel').val(),
				schTypeSel : $('#schTypeSel').val(),
				schEmploySel : $('#schEmploySel').val(),
				reqType : reqType,
				schTxt : $('#schTxt').val()
			};

			grid.page.pageSize  = $("#listCntSel option:selected").val();
			// bind
			grid.bindGrid({
				ajaxUrl : "/groupware/vacation/getVacationDayList.do",
				ajaxPars : params
			});
		}else if(tabNo===2){
			params = {
				urName : $('#schUrName').val(),
				year : $('#schYearSel').val(),
				schTypeSel : $('#schTypeSel').val(),
				schTxt : $('#schTxt').val()
			};
			grid2.page.pageSize  = $("#listCntSel2 option:selected").val();
			// bind
			grid2.bindGrid({
				ajaxUrl : "/groupware/vacation/getVacationExtraList.do",
				ajaxPars : params
			});
		}else if(tabNo===3){
			params = {
				urName : $('#schUrName').val(),
				year : $('#schYearSel').val(),
				reqType : reqType,
				schTypeSel : $('#schTypeSel').val(),
				schTxt : $('#schTxt').val(),
				sortBy : "APPDATE DESC"
			};
			grid3.page.pageSize  = $("#listCntSel3 option:selected").val();
			// bind
			grid3.bindGrid({
				ajaxUrl : "/groupware/vacation/getVacationManageList.do",
				ajaxPars : params
			});

		}else if(tabNo===4){
			params = {
					urName : $('#schUrName').val(),
					year : $('#schYearSel').val(),
					schTypeSel : $('#schTypeSel').val(),
					schTxt : $('#schTxt').val()
				};
				grid4.page.pageSize  = $("#listCntSel4 option:selected").val();
				// bind
				grid4.bindGrid({
					ajaxUrl : "/groupware/vacation/getVacationRewardList.do",
					ajaxPars : params
				});
			}
	}

	this.toggleTab=function (t) {
		$(".topToggle").attr("class","topToggle");

		if(t==="1"){
			tabNo = 1;
			$(".topToggle").eq(0).attr("class","topToggle active");
			$("#boradTopCont_1").show();
			$("#boradTopCont_2").hide();
			$("#boradTopCont_3").hide();
			$("#boradTopCont_4").hide();
			$("#gridDiv").show();
			$("#gridDiv2").hide();
			$("#gridDiv3").hide();
			$("#gridDiv4").hide();
			$("#schEmploySel").show();
			grid.setGridConfig(vacationManageGrid);
			grid.redrawGrid();
		}else if(t==="2"){
			tabNo = 2;
			$(".topToggle").eq(2).attr("class","topToggle active");
			$("#boradTopCont_1").hide();
			$("#boradTopCont_2").show();
			$("#boradTopCont_3").hide();
			$("#boradTopCont_4").hide();
			$("#gridDiv").hide();
			$("#gridDiv2").show();
			$("#gridDiv3").hide();
			$("#gridDiv4").hide();
			$("#schEmploySel").hide();
	 		grid2.setGridConfig(vacationManageGrid2);
			grid2.redrawGrid();
		}else if(t==="3"){
			tabNo = 3;
			$(".topToggle").eq(3).attr("class","topToggle active");
			$("#boradTopCont_1").hide();
			$("#boradTopCont_2").hide();
			$("#boradTopCont_3").show();
			$("#boradTopCont_4").hide();
			$("#gridDiv").hide();
			$("#gridDiv2").hide();
			$("#gridDiv3").show();
			$("#gridDiv4").hide();
			$("#schEmploySel").hide();
	 		grid3.setGridConfig(vacationManageGrid3);
			grid3.redrawGrid();
		}else if(t==="4"){
			tabNo = 4;
			$(".topToggle").eq(1).attr("class","topToggle active");
			$("#boradTopCont_1").hide();
			$("#boradTopCont_2").hide();
			$("#boradTopCont_3").hide();
			$("#boradTopCont_4").show();
			$("#gridDiv").hide();
			$("#gridDiv2").hide();
			$("#gridDiv3").hide();
			$("#gridDiv4").show();
			$("#schEmploySel").hide();
	 		grid4.setGridConfig(vacationManageGrid4);
			grid4.redrawGrid();
		}

		search();
	}
	
	// 연차등록 버튼
	this.openVacationInsertPopup=function() {
		var year = $('#schYearSel').val();
		
		Common.open("","target_pop", year + "<spring:message code='Cache.lblNyunDo' /> : <spring:message code='Cache.lbl_apv_Vacation_days' /> <spring:message code='Cache.btn_register' />","/groupware/vacation/goVacationInsertPopup.do?year="+year,"500px","265px","iframe",true,null,null,true);
	}

	// 기타휴가등록 버튼
	this.openExtraVacationInsertPopup=function() {
		var year = $('#schYearSel').val();

		Common.open("","target_pop", year + "<spring:message code='Cache.lblNyunDo' /> : <spring:message code='Cache.lbl_apv_Vacation_days' /> <spring:message code='Cache.btn_register' />","/groupware/vacation/goExtraVacationInsertPopup.do?year="+year,"630px","420px","iframe",true,null,null,true);
	}

	// 보상휴가등록 버튼
	this.openRewardVacationInsertPopup=function() {
		var year = $('#schYearSel').val();

		Common.open("","target_pop", year + "<spring:message code='Cache.lblNyunDo' /> : <spring:message code='Cache.lbl_apv_Vacation_days' /> <spring:message code='Cache.btn_register' />","/groupware/vacation/goRewardVacationInsertPopup.do?year="+year,"630px","420px","iframe",true,null,null,true);
	}
	
	// 그리드 클릭
	this.openVacationUpdatePopup=function(item) {
		let urCode = item.UR_Code;
		let year = item.YEAR;
		var parYear = $("#schYearSel option:selected").val();
		Common.open("","target_pop","<spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goVacationUpdatePopup.do?urCode="+urCode+"&year="+parYear,"499px","320px","iframe",true,null,null,true);
	}

	this.openExtraVacationUpdatePopup=function(item) {
		let urCode = item.UR_Code;
		let vacKind= item.ExtVacType;
		let sDate= item.ExtSdate;
		let eDate= item.ExtEdate;
		let year= item.ExtVacYear;
		Common.open("","target_pop","<spring:message code='Cache.lbl_apv_vacation_etc' /><spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goExtraVacationUpdatePopup.do?urCode="+urCode+"&year="+year+"&vacKind="+vacKind+"&sDate="+sDate+"&eDate="+eDate,"530px","400px","iframe",true,null,null,true);
	}
	
	this.openRewardVacationUpdatePopup=function(item) {
		let urCode = item.UR_Code;
		let vacKind= item.ExtVacType;
		let sDate= item.ExtSdate;
		let eDate= item.ExtEdate;
		let year= item.ExtVacYear;
		Common.open("","target_pop","<spring:message code='Cache.lbl_n_att_compensation' /><spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goRewardVacationUpdatePopup.do?urCode="+urCode+"&year="+year+"&vacKind="+vacKind+"&sDate="+sDate+"&eDate="+eDate,"530px","400px","iframe",true,null,null,true);
	}
	
	this.openVacationPlanHistPopup=function(item){
		let urCode = item.UR_Code;
		let startDate = item.ExpDateStart
		let endDate = item.ExpDateEnd;
		var popupTit	= "<spring:message code='Cache.lbl_vacationMsg52' />";
		var popupUrl	= "/groupware/vacation/goVacationPlanHistPopup.do?"
						+ "urCode="			+ urCode	+ "&"
						+ "startDate="		+ startDate	+ "&"
						+ "endDate="		+ endDate	+ "&"
						+ "vacKind=Public"
		
		Common.open("", "target_pop", popupTit, popupUrl, "950px", "600px", "iframe", true, null, null, true);
	}
	
	this.openExtVacationPlanHistPopup=function(item){		
		let urCode = item.UR_Code;
		let startDate = item.ExtSdate
		let endDate = item.ExtEdate;
		let vacType = item.ExtVacType;
		var popupTit	= "<spring:message code='Cache.lbl_vacationMsg52' />";
		var popupUrl	= "/groupware/vacation/goVacationPlanHistPopup.do?"
						+ "urCode="			+ urCode	+ "&"
						+ "startDate="		+ startDate	+ "&"
						+ "endDate="		+ endDate	+ "&"
						+ "vacType="		+ vacType	+ "&"
						+ "vacKind=Extra"
		
		Common.open("", "target_pop", popupTit, popupUrl, "950px", "600px", "iframe", true, null, null, true);
	}
	
	this.openRwdVacationPlanHistPopup=function(item){		
		let urCode = item.UR_Code;
		let startDate = item.ExtSdate
		let endDate = item.ExtEdate;
		let vacType = item.ExtVacType;
		var popupTit	= "<spring:message code='Cache.lbl_vacationMsg52' />";
		var popupUrl	= "/groupware/vacation/goVacationPlanHistPopup.do?"
						+ "urCode="			+ urCode	+ "&"
						+ "startDate="		+ startDate	+ "&"
						+ "endDate="		+ endDate	+ "&"
						+ "vacType="		+ vacType	+ "&"
						+ "vacKind=Reward"
		
		Common.open("", "target_pop", popupTit, popupUrl, "950px", "600px", "iframe", true, null, null, true);
	}
	
	// 연차기간설정 버튼
	this.openVacationPeriodManagePopup=function(urCode, year) {
		Common.open("","target_pop","<spring:message code='Cache.lbl_apv_setVacTerm' />","/groupware/vacation/goVacationPeriodManagePopup.do","420px","520px","iframe",true,null,null,true);
	}
	
	// 엑셀 업로드
	this.openVacationInsertByExcelPopup=function() {
		Common.open("","target_pop","<spring:message code='Cache.lbl_ExcelUpload' />","/groupware/vacation/goVacationInsertByExcel1Popup.do?reqType="+reqType,"500px","320px","iframe",true,null,null,true);
	}
	
	this.updateDeptInfo=function() {
		Common.Confirm("<spring:message code='Cache.msg_n_att_wantToSync' />", "Confirmation Dialog", function (confirmResult) { //동기화 하시겠습니까?
			if (confirmResult) {
				coviUtil.getAjaxPost("/groupware/vacation/updateDeptInfo.do",{} , function (data) {
					if(data.status == 'SUCCESS') {
						Common.Inform("<spring:message code='Cache.msg_apv_170' />", "Inform", function() {
							$this.search();
						});
	          		} else {
	          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
	          		}
		 		});
			} else {
				return false;
			}
		});	
	}


	///////////////////


	// 휴가 신청
	function openVacationApplyPopup() {
		CFN_OpenWindow("/approval/approval_Form.do?formPrefix=WF_FORM_VACATION_REQUEST2&mode=DRAFT", "", 790, (window.screen.height - 100), "resize");
	}

	// 휴가 신청/취소 내역
	function openVacationViewPopup(urCode, processId, workItemId) {
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
	}
	
	// 공동연차 등록 팝업
	this.openJointVacationInsertPopup = function() {
		Common.open("","target_pop", "<spring:message code='Cache.lbl_apv_vacation_Jointbtn2' />","/groupware/vacation/goJointVacationInsertPopup.do","630px","420px","iframe",true,null,null,true);
	}

	// 템플릿 파일 다운로드
	function excelDownload() {

		if (confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles' />")) {
			location.href = "/groupware/vacation/excelDownload.do?reqType=commonInsert";
		}
	}

	// 엑셀 업로드(공통연차)
	this.openVacationInsertByExcelPopup3=function() {
		if (reqType == 'manage') {
			Common.open("","target_pop","<spring:message code='Cache.btn_ExcelUpload' />","/groupware/vacation/goVacationInsertByExcel2Popup.do?reqType="+reqType,"499px","440px","iframe",true,null,null,true);
		}
	}

	this.openVacationCancelByExcelPopup3=function() {
		if (reqType == 'manage') {
			Common.open("","target_pop","<spring:message code='Cache.lbl_common_vacation_cancel' />","/groupware/vacation/goVacationCancelByExcelpopup.do?reqType="+reqType,"499px","358px","iframe",true,null,null,true);
		}
	}

	// 구분
	this.openVacationCancelPopup=function(vacationInfoId, vacYear) {
		Common.open("","target_pop","<spring:message code='Cache.lbl_apv_vacation_cancel' />","/groupware/vacation/goVacationCancelPopup.do?vacationInfoId="+vacationInfoId+"&vacYear="+vacYear,"499px","405px","iframe",true,null,null,true);
	}
/*
	this.openPromotionPopup=function(formType, empType){
		var year = $('#schYearSel').val();
		var params = "?year="+year+"&viewType=user&formType=" + formType + "&empType=" + empType;

		CFN_OpenWindow("/groupware/vacation/goVacationPromotionPopup.do" + params, "", 960, (window.screen.height - 100), "scroll");
	}

	// 연차촉진제 서식출력 1,2차
	function openVacationPromotion1Popup(time) {
		var year = $('#schYearSel').val();
		CFN_OpenWindow("/groupware/vacation/goVacationPromotion1Popup.do?year="+year+"&viewType=user&isAll=N&time="+time, "", 960, (window.screen.height - 100), "scroll");
	}

	// 연차촉진제 서식출력 3
	function openVacationPromotion3Popup() {
		var year = $('#schYearSel').val();
		CFN_OpenWindow("/groupware/vacation/goVacationPromotion3Popup.do?year="+year+"&viewType=user&time=3", "", 960, (window.screen.height - 100), "scroll");
	}

	// 사용시기 지정통보서
	function openVacationUsePlanPopup(time) {
		var year = $('#schYearSel').val();
		CFN_OpenWindow("/groupware/vacation/goVacationUsePlanPopup.do?year="+year+"&time="+time+"&viewType=user&isAll=N", "", 960, (window.screen.height - 100), "scroll");
	}*/
}();

$(document).ready(function(){
	vacationVacationManage.initContent();
});

//조직도 팝업
function openOrgMapLayerPopup() {
	duplChkUserIdArr = new Array();
	
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org' />","/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=B9","1060px","580px","iframe",true,null,null,true);
}

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	var html = '';

	$.each(item, function (i, v) {
		var userId = v.UserID;

		if ($.inArray(userId, duplChkUserIdArr) == -1) {
			html += '<li class="listCol" value="' + v.UserCode + '">';
			html += '<div><span>' + CFN_GetDicInfo(v.RGNM) + '</span></div>';
			html += '<div><span>' + CFN_GetDicInfo(v.DN) + '</span></div>';
			html += '<div><span>' + (CFN_GetDicInfo(v.LV.split("&")[1]) == "undefined" ? "" : CFN_GetDicInfo(v.LV.split("&")[1])) + '</span></div>';
			html += '<div><input type="text" placeholder="0"></div>';
			html += '</li>';

			duplChkUserIdArr.push(userId);
		}
	});
	$('#target_pop_if').contents().find('#listColNotice').hide();
	$('#target_pop_if').contents().find('#listHeader').after(html);
}
</script>			