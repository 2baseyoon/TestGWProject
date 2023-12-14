<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>

<style>
    .AXGrid input:disabled { background-color:#Eaeaea; }
</style>
<div class='cRConTop titType'>
    <h2 class="title" id="reqTypeTxt"><spring:message code='Cache.btn_apv_vacation_req' /></h2>
    <div class="searchBox02">
        <span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" ><spring:message code='Cache.btn_search' /></button></span>
        <a href="#" class="btnDetails active" ><spring:message code='Cache.lbl_detail' /></a>
    </div>
</div>
<div class='cRContBottom mScrollVH'>
    <div class="inPerView type02 active">
        <div style="width: 460px;">
            <div class="selectCalView">
				<covi:select className="selectType02" id="schYearSel" boxType="YEAR" selected="<%=ComUtils.GetLocalCurrentDate().substring(0,4)%>"  startYear="<%=(Integer.parseInt(ComUtils.GetLocalCurrentDate().substring(0,4))-4)%>" yearSize="6"></covi:select>
                <covi:select className="selectType02" id="schTypeSel">
                    <option value="displayName"><spring:message code='Cache.lbl_username' /></option>
                    <option value="deptName"><spring:message code='Cache.lbl_dept' /></option>
                </covi:select>
                <div class="dateSel type02" id="schTxtDiv">
                    <input type="text" id="schTxt">
                </div>
            </div>
            <div>
                <a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
            </div>
            <div class="chkStyle01">
                <span id="myVacText"></span>
            </div>
        </div>
    </div>
    <div class="boardAllCont">
        <div class="boradTopCont">
            <div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
                <!-- 삭제 -->
                <a href="#" class="btnTypeDefault left" id="btnVacationDel"><spring:message code='Cache.lbl_all_together'/><spring:message code='Cache.Messaging_Cancel'/></a>
            </div>

            <div class="buttonStyleBoxRight">
                <covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
                <button href="#" class="btnRefresh" type="button"></button>
            </div>
        </div>
        <div class="tblList tblCont">
            <div id="gridDiv">
           		<covi:grid id="gridDiv" gridVar="vacationCancelManagerGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td width="5"></td><!-- 공백용 태그-->
					  <td key="VacationInfoID"	label="chk"	     width="20"  align="center" formatter="checkbox" disabled="vacationVacationCancelManager.disableCancelChk"/>
					  <td key="DeptName"	label="lbl_dept"	 width="50"  align="center" formatter="DIC" />
					  <td key="DisplayName"	label="lbl_name"	 width="40"  align="center" formatter="CUSTOM" formatAddtion="vacationVacationCancelManager.formatDisplaName"/>
					  <td key="GubunName"	label="lbl_Gubun"	 width="50"  align="center" formatter="CUSTOM" formatAddtion="vacationVacationCancelManager.formatGubunName" sort="false"/>
					  
					  <td key="VacFlagName"	label="lbl_type"	 width="40"  align="center"  sort="false"/>
					  <td key="ENDDATE"	label="lbl_apv_approvdate"	 width="40"  align="center" />
					  <td key="Sdate"	label="lbl_startdate"	 width="40"  align="center" />
					  <td key="Edate"	label="lbl_EndDate"	 width="40"  align="center" />
					  <td key="VacDay"	label="lbl_att_approval"	 width="20"  align="center" />
					  <td key="VacDay"	label="ACC_btn_cancel"	 width="20"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationCancelManager.formatVacDay" sort="false"/>
					  <td key="VacDayTot"	label="lbl_used_days"	 width="40"  align="center"  sort="false"/>
					  <td key="Reason"	label="lbl_Reason"	 width="250"  align="left"  sort="false"/>
					</tr>  
				</covi:grid>
            </div>
        </div>
    </div>
</div>

<script>
var vacationVacationCancelManager = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var grid = new coviGrid();
    var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	
	this.disableCancelChk = function(item){
		return Number(item.VacDayTot)<=0;
	}
	this.formatDisplaName = function(item){
	   var html = "<div>";
       if (item.GUBUN == 'VACATION_PUBLIC' || item.GUBUN == 'VACATION_PUBLIC_CANCEL') {
           html += "<a href='#' onclick='alert(\"<spring:message code='Cache.lbl_vacationMsg25' />\"); return false;'>";
       } else if (typeof(item.ProcessID) == 'undefined' || typeof(item.WorkItemID) == 'undefined') {
           html += "<a href='#' onclick='alert(\"<spring:message code='Cache.lbl_vacationMsg26' />\"); return false;'>";
       } else {
           html += "<a href='#' onclick='vacationVacationCancelManager.openVacationViewPopup(\"" + item.UR_Code + "\", \"" + item.ProcessID + "\", \"" + item.WorkItemID + "\"); return false;'>";
       }
       html += item.DisplayName;
       html += "</a>";
       html += "</div>";

       return html;
	}
	this.formatGubunName = function(item){
		var html = "<div>";
        var gubunName = item.GubunName;
        var btnColor = "#4abde1";
        var btnTxt = "<spring:message code='Cache.lbl_att_approval' />";
        var cursor = "cursor : pointer;"
        if(parseFloat(item.VacDayTot)===0){
            btnColor = "#7c7c7c";
            btnTxt = "<spring:message code='Cache.Messaging_Cancel' />";
            cursor = "cursor : default;"
        }else if ((item.VacDay - item.VacDayTot)>0) {
        	btnTxt = "<spring:message code="Cache.CPMail_Part"/>" +"<spring:message code='Cache.Messaging_Cancel' />";;
        }
        
        if (item.GUBUN == 'VACATION_APPLY' || item.GUBUN == 'VACATION_PUBLIC') {
            html += "<a class=\"WorkBoxM Calling\" style=\"background-color: "+btnColor+" !important;height: 18px;margin-top: -1px;color:#fff;"+cursor+"\""
            if(parseFloat(item.VacDayTot)>0) {
                html += " onclick='vacationVacationCancelManager.openVacationCancelPopup(\"" + item.VacationInfoID + "\", \"" + item.VacYear + "\"); return false;'";
            }
            html += ">";
            html += btnTxt+"("+gubunName+")";
            html += "</a>";
        } else {
            html += gubunName;
        }
        html += "</div>";

        return html;
	}
	this.formatVacDay = function(item){
		if (item.VacDayTot-item.VacDay < 0 ){return item.VacDayTot-item.VacDay};
	}

    // 휴가신청, 공동연차등록, 나의휴가현황
	this.initContent = function(bLoad, linkUrl) {
        init();	// 초기화

		if (bLoad != true){
	        $("#reqTypeTxt").html("<spring:message code='Cache.MN_666' />");
			grid.setGridConfig(vacationCancelManagerGrid);
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

        // 검색 버튼
        $('.btnSearchType01, .btnSearchBlue, .btnRefresh').on('click', function(e) {
            search();
        });

        // 상세 보기
        $('.btnDetails').on('click', function() {
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

        // 년도
        $('#schYearSel').on('change', function(e) {

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
        // 삭제
        $("#btnVacationDel").on('click',function(){
            //delVacation();
            if($("input[name=chk]:checked").length==0){
                Common.Warning("<spring:message code='Cache.msg_noCancelData'/>");
            }else {
                var year = $('#schYearSel').val();
                Common.open("", "target_pop", "<spring:message code='Cache.btn_apv_vacation_req' /> <spring:message code='Cache.CPMail_CancelSendAll' />", "/groupware/vacation/goVacationDeletePopup.do?year=" + year, "630px", "420px", "iframe", true, null, null, true);
            }
        });
    }

    // 검색
    this.search=function() {
    	search();
    }
    var search=function() {
        var params = {
            urName : $('#schUrName').val(),
            year : $('#schYearSel').val(),
            schTypeSel : $('#schTypeSel').val(),
            schTxt : $('#schTxt').val(),
            reqType : "vacationCancel"
        };

        grid.page.pageNo = 1;

        // bind
        grid.bindGrid({
            ajaxUrl : "/groupware/vacation/getVacationCancelList.do",
            ajaxPars : params
        });
    }

    //근로정보 삭제
    this.delVacation=function(){
        if($("input[name=chk]:checked").length==0){
            Common.Warning("<spring:message code='Cache.msg_selectTargetDelete'/>");
        }else{
            Common.Confirm("<spring:message code='Cache.msg_Common_08' />", "Confirmation Dialog", function (confirmResult) {
                if (confirmResult) {

                    var delArry = new Array();
                    for(var i=0;i<$("input[name=chk]:checked").length;i++){
                        delArry.push($("input[name=chk]:checked").eq(i).val());
                    }
                    var params = {
                        VacationInfoID : JSON.stringify(delArry)
                        ,year : $('#schYearSel').val()
                    };
                    $.ajax({
                        type:"POST",
                        dataType : "json",
                        data: params,
                        url:"/groupware/vacation/getVacationCancelDel.do",
                        success:function (data) {
                            if(data.status =="SUCCESS"){
                                if(data.msg!=""){
                                    Common.Warning(data.msg);
                                }
                                search();
                                parent.Common.Close("target_pop");
                            }else{
                                Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
                            }
                        }
                    });
                }
            });
        }
    }
    // 연차 사용정보
    function getUserVacationInfo() {
        $.ajax({
            type : "POST",
            data : {year : $('#schYearSel').val()},
            async: false,
            url : "/groupware/vacation/getUserVacationInfo.do",
            success:function (list) {
                var data = list.list[0];
                var text = "( <spring:message code='Cache.lbl_total' /> " + data.OWNDAYS + "<spring:message code='Cache.lbl_day' />, <spring:message code='Cache.lbl_UseVacation' /> " + data.USEDAYS + "<spring:message code='Cache.lbl_day' />, <spring:message code='Cache.lbl_RemainVacation' /> " + data.REMINDDAYS + "<spring:message code='Cache.lbl_day' /> )"

                $('#myVacText').html(text);
            },
            error:function(response, status, error) {
                CFN_ErrorAjax("/groupware/vacation/getUserVacationInfo.do", response, status, error);
            }
        });
    }

    // 휴가 신청
    function openVacationApplyPopup() {
        CFN_OpenWindow("/approval/approval_Form.do?formPrefix=WF_FORM_VACATION_REQUEST2&mode=DRAFT", "", 790, (window.screen.height - 100), "resize");
    }

    // 휴가 신청/취소 내역
    function openVacationViewPopup(urCode, processId, workItemId) {
//		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&workitemID="+workItemId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
        CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
    }

    // 템플릿 파일 다운로드
    function excelDownload() {
        if (confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles' />")) {
            location.href = "/groupware/vacation/excelDownload.do";
        }
    }

    // 구분
    this.openVacationCancelPopup=function(vacationInfoId, vacYear) {
        Common.open("","target_pop","<spring:message code='Cache.lbl_apv_vacation_cancel' />","/groupware/vacation/goVacationCancelPopup.do?vacationInfoId="+vacationInfoId+"&vacYear="+vacYear,"499px","405px","iframe",true,null,null,true);
    }

    function openPromotionPopup(formType, empType){
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
    }

}();

$(document).ready(function(){
	vacationVacationCancelManager.initContent();
});

</script>