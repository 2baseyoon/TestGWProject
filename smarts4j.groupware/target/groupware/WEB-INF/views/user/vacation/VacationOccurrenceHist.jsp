<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>

<style>
	.chkStyle06 {
		margin-right : 10px;
	}
	.chkStyle06 label {
		padding-left : 14px;
		font-size : 13px;
	}
</style>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_vacationMsg52'/></h2>	<!-- 발생이력 -->
	<div class="searchBox02">
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
	</div>	
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02 active">
		<div style="width: 700px;">
			<div class="selectCalView">
				<covi:select className="selectType02" id="schYearSel" boxType="YEAR" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>"  startYear="<%=(Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4)%>" yearSize="6"></covi:select>
				<covi:select className="selectType02" id="schEmploySel">
						<option value=""><spring:message code='Cache.lbl_Whole' /></option>
					    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
					    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
				</covi:select>
				<covi:select className="selectType02" id="schTypeSel">
					<%-- <option value=""><spring:message code='Cache.lbl_apv_searchcomment' /></option> --%>
				    <option value="deptName"><spring:message code="Cache.lbl_dept" /></option>
				    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
				</covi:select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>		
				<covi:select  className="selectType02" id="vacFlagSel">
					<option value=''><spring:message code="Cache.lbl_all" /></option>
					<option value="VACATION_TYPE_MULTI"><spring:message code="Cache.lbl_MultiSearch" /></option>
				</covi:select>			
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
			<div id="vacMultiCheckBox" style="display:none"></div>
		</div>
	</div>
	<div class="boardAllCont">
	
		<div class="boradTopCont" id="boradTopCont_1" style="display: block;">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
				<a href="#" class="btnTypeDefault btnExcel"><spring:message code='Cache.lbl_SaveToExcel' /></a>
				<%--<a href="#" class="btnTypeDefault btnTypeChk" id="insVacBtn" onclick="openVacationInsertPopup();" style="display:none"><spring:message code='Cache.btn_register' /></a>--%>
			</div>
			<div class="buttonStyleBoxRight">	
                <covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
				<button href="#" class="btnRefresh" type="button""></button>							
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
           		<covi:grid id="gridDiv" gridVar="vacationOccurrenceHistGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="ChangeDate"	label="lbl_apv_chgdate"	     width="50"  align="center" />
					  <td key="DeptName"	label="lbl_dept"	 width="50"  align="center" formatter="LINK" formatAddtion="vacationVacationOccurrenceHist.openVacationUpdatePopup"/>
					  <td key="DisplayName"	label="lbl_name"	 width="40"  align="center" formatter="FLOWER"/>
					  <td key="ExtVacName"	label="VACATION_TYPE_VACATION_TYPE"	 width="30"  align="center" />
					  <td key="ExtVacDay"	label="lbl_vacationMsg53"	 width="30"  align="center"  sort="false"/>
					  <td key="RegisterName"	label="lbl_vacationMsg54"	 width="50"  align="center" formatter="FLOWER" formatAddtion="RegisterCode,RegisterName"/>
					  <td key="ExpDate"	label="lbl_expiryDate"	 width="60"  align="center" />
					  <td key="ExtRemainVacDay"	label="lbl_n_att_remain"	 width="30"  align="center" />
					  <td key="VmComment"	label="lbl_ProcessContents"	 width="300"  align="left" sort="false"/>
					</tr>  
				</covi:grid>
			
			</div>
		</div>
	</div>
</div>

<script>
var vacationVacationOccurrenceHist = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	var grid = new coviGrid();
	
//	initContent();

	this.initContent = function(bLoad, linkUrl) {
		init();	// 초기화
		if (bLoad != true){
			grid.setGridConfig(vacationOccurrenceHistGrid);
			search();	// 검색
		}	else{
			grid.bindEvent(true);
		}
		setVacationFlagSelList();
	}

	// 초기화
	function init() {
		// 그리드 카운트
		$('#listCntSel').on('change', function (e) {
			grid.page.pageSize = $(this).val();
			grid.reloadList();
		});

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
		$('.btnSearchBlue, .btnRefresh').on('click', function (e) {
			search();
		});
		//엑셀 
		$('.btnExcel').on('click', function (e) {
			excelDownload();
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

	}
	
	// 검색
	function search() {
		var params = null;
		var sField = "";
		
		$("input[name=chkItem]:checked").each(function (index) {
			sField += $("input[name=chkItem]:checked").eq(index).val() + ",";
		});	
		
		params = {
			year : $('#schYearSel').val(),
			schEmploySel : $('#schEmploySel').val(),
			schTypeSel : $('#schTypeSel').val(),
			schTxt : $('#schTxt').val(),
			vacFlag : $('#vacFlagSel').val(),
			VacTypeArr : sField
			
		};

		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationPlanHistList.do",
			ajaxPars : params
		});
	}

	// 그리드 클릭
	this.openVacationUpdatePopup=function(item) {
		let urCode = item.UR_Code;
		let year = item.ExtVacYear;
		
		Common.open("","target_pop","<spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goVacationUpdatePopup.do?urCode="+urCode+"&year="+year,"499px","281px","iframe",true,null,null,true);
	}
	
	//휴가유형 검색 필터
	function setVacationFlagSelList(){
		$.ajax({
			url: "/groupware/vacation/selectVacationFlagSelList.do",
			type: "POST",
			async: false,
			success: function (data) {
				var vacFlagSelList = data.list;
				
				//휴가유형 필터
				var optionHtml = ""
				for(var j = 0; j < vacFlagSelList.length; j++){
					optionHtml += "<option value='"+ vacFlagSelList[j].OptionValue +"'>"+ vacFlagSelList[j].OptionName +"</option>";
				}
				$("#vacFlagSel").append(optionHtml);
				
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
						const vacationType = vacFlagSelList;
						vacationType.forEach(function(item, idx) {
							html += "<li class='chkStyle06'>";
							html += "	<input type='checkbox' value='" + item.OptionValue + "' id='ck" + i + "_p' name='chkItem'><label for='ck" + i + "_p'>" + item.OptionName + "</label>";
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
			},
			error:function (error) {
				CFN_ErrorAjax("/groupware/vacation/selectVacationFlagSelList.do", response, status, error);
			}
		});
	}
	
	// 엑셀 파일 다운로드
	function excelDownload() {
		var sField = "";
		var sortInfo = grid.getSortParam("one").split("=");
		var sortBy = sortInfo.length > 1 ? sortInfo[1] : "";
		
		$("input[name=chkItem]:checked").each(function (index) {
			sField += $("input[name=chkItem]:checked").eq(index).val() + ",";
		});	
			
		var params = {
			year : $('#schYearSel').val(),
			schTypeSel : $('#schTypeSel').val(),
			schTxt : $('#schTxt').val(),
			schEmploySel : $('#schEmploySel').val(),
			sortBy : "RegistDate desc",
			vacFlag : $('#vacFlagSel').val(),
			VacTypeArr : sField,
			sortBy : sortBy
		};

		ajax_download('/groupware/vacation/excelDownVacationOccurrenceHist.do', params);	// 엑셀 다운로드 post 요청
	}

}();

$(document).ready(function(){
	vacationVacationOccurrenceHist.initContent();
});
	
</script>			