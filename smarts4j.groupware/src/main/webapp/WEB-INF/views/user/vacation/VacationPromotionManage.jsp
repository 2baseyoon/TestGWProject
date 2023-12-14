<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
    <h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_663' /></h2>
    <div class="searchBox02">
        <span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
        <a href="#" class="btnDetails active"><spring:message code='Cache.lbl_detail' /></a>
    </div>
</div>
<div class='cRContBottom mScrollVH'>
    <div class="inPerView type02 active">
        <div style="width: 550px;">
            <div class="selectCalView">
                <select class="selectType02" id="schYearSel">
                </select>
                <select class="selectType02" id="schEmploySel">
                    <option value=""><spring:message code='Cache.lbl_Whole' /></option>
                    <option value="INOFFICE" selected="selected"><spring:message code="Cache.lbl_inoffice" /></option>
                    <option value="RETIRE"><spring:message code="Cache.msg_apv_359" /></option>
                </select>
                <select class="selectType02" id="schTypeSel">
                    <%-- <option value=""><spring:message code='Cache.lbl_apv_searchcomment' /></option> --%>
                    <option value="deptName"><spring:message code="Cache.lbl_dept" /></option>
                    <option value="displayName" selected="selected"><spring:message code="Cache.lbl_username" /></option>
                </select>
                <div class="dateSel type02">
                    <input type="text" id="schTxt">
                </div>
            </div>
            <div>
                <a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
            </div>
        </div>
    </div>
    <div class="boardAllCont">
        <div class="boradTopCont">
            <div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
                <a href="#" class="btnTypeDefault btnTypeChk" id="insVacBtn" onclick="openVacationInsertPopup()" style="display:none"><spring:message code='Cache.btn_register' /></a>
                <a href="#" class="btnTypeDefault" id="vacPeriodBtn" onclick="openVacationPeriodManagePopup()" style="display:none"><spring:message code='Cache.lbl_apv_setVacTerm' /></a>
                <a href="#" class="btnTypeDefault btnRepeatGray" id="btnDeptInfo" onclick="updateDeptInfo()" style="display:none"><spring:message code='Cache.lbl_attend_currentYearSync' /></a><!-- 현재년도 부서정보 동기화 -->
                <a href="#" class="btnTypeDefault btnExcel" id="excelUpBtn" onclick="openVacationInsertByExcelPopup();" style="display:none"><spring:message code='Cache.lbl_ExcelUpload' /></a>

            </div>
            <div class="buttonStyleBoxRight">
                <select class="selectType02 listCount" id="listCntSel">
                    <option>10</option>
                    <option>15</option>
                    <option>20</option>
                    <option>30</option>
                    <option>50</option>
                </select>
                <button href="#" class="btnRefresh" type="button" onclick="search()"></button>
            </div>
        </div>
        <div class="tblList tblCont">
            <div id="gridDiv">
            </div>
        </div>
    </div>
</div>

<script>
    var reqType = CFN_GetQueryString("reqType");	// reqType : manage(연차관리),  promotionPeriod(연차촉진 기간설정)
    var grid = new coviGrid();
    var duplChkUserIdArr = new Array();
    var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("VacListCnt")){
		pageSize = CFN_GetCookie("VacListCnt");
	}
	
	$("#listCntSel").val(pageSize);
    initContent();

    // 연차관리, 연차촉진, 연차촉진기간설정
    function initContent() {
        init();	// 초기화

        setGrid();	// 그리드 세팅

        search();	// 검색
    }

    // 초기화
    function init() {
        // 화면 처리
        if (reqType == 'manage') {
            $("#reqTypeTxt").html("<spring:message code='Cache.MN_663' />");
            $('#excelDownBtn').html('<spring:message code="Cache.lbl_templatedownload" />');
            $('#excelUpBtn').html('<spring:message code="Cache.Personnel_ExcelAdd" />');
            $('#genVacBtn, #insVacBtn, #excelDownBtn, #excelUpBtn').css('display', '');

            $('#btnDeptInfo').css('display', '');
        } else if (reqType == 'promotionPeriod') {
            $("#reqTypeTxt").html("<spring:message code='Cache.MN_668' />");
            $('#vacPeriodBtn').css('display', '');
        }

        var nowYear = new Date().getFullYear();
        // 년도 option 생성
        for (var i=2; i>-4;i--) {
            var temp = nowYear + i;
            if (temp == nowYear) {
                $('#schYearSel').append($('<option>', {
                    value: temp,
                    text : temp,
                    selected : 'selected'
                }));
            } else {
                $('#schYearSel').append($('<option>', {
                    value: temp,
                    text : temp
                }));
            }
        }

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
        $('.btnSearchBlue').on('click', function(e) {
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
    }

    // 그리드 세팅
    function setGrid() {
        // header
        var	headerData = [
            {key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'100', align:'center',
                formatter:function () {
                    var html = "<div class='tblLink'>";
                    html += "<a href='#' onclick='openVacationUpdatePopup(\"" + this.item.UR_Code + "\", \"" + this.item.YEAR + "\"); return false;'>";
                    if (typeof(this.item.DeptName) != 'undefined') html += CFN_GetDicInfo(this.item.DeptName);
                    html += "</a>";
                    html += "</div>";

                    return html;
                }
            },
            {key:'DisplayName', label:'<spring:message code="Cache.lbl_username" />', width:'100', align:'center',
                formatter:function () {
                    var html = "<div class='tblLink'>";
                    html += "<a href='#' onclick='openVacationUpdatePopup(\"" + this.item.UR_Code + "\", \"" + this.item.YEAR + "\"); return false;'>";
                    if (typeof(this.item.DisplayName) != 'undefined') html += this.item.DisplayName;
                    html += "</a>";
                    html += "</div>";

                    return html;
                }
            },
            {key:'EnterDate',  label:'<spring:message code="Cache.lbl_EnterDate" />', width:'100', align:'center'},
            {key:'JobPositionName', label:'<spring:message code="Cache.lbl_apv_jobposition" />', width:'100', align:'center',
                formatter:function () {
                    var html = "<div class='tblLink'>";
                    html += "<a href='#' onclick='openVacationUpdatePopup(\"" + this.item.UR_Code + "\", \"" + this.item.YEAR + "\"); return false;'>";
                    if (typeof(this.item.JobPositionName) != 'undefined') html += this.item.JobPositionName;
                    html += "</a>";
                    html += "</div>";

                    return html;
                }
            },
            {key:'VacDay',  label:'<spring:message code="Cache.lbl_TotalVacation" />', width:'100', align:'center', sort:false}
        ];

        grid.setGridHeader(headerData);

        // config
        grid.setGridConfig({
            targetID : "gridDiv",
            page : {
				pageNo: (page != undefined && page != '')?page:1,
				pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
			},
            height:"auto"
        });
    }

    // 검색
    function search() {
        var params = {year : $('#schYearSel').val(),
            schTypeSel : $('#schTypeSel').val(),
            schEmploySel : $('#schEmploySel').val(),
            reqType : reqType,
            schTxt : $('#schTxt').val()};

        // bind
        grid.bindGrid({
            ajaxUrl : "/groupware/vacation/getVacationDayList.do",
            ajaxPars : params
        });
    }

    // 등록 버튼
    function openVacationInsertPopup() {
        var year = $('#schYearSel').val();

        Common.open("","target_pop", year + "<spring:message code='Cache.lblNyunDo' /> : <spring:message code='Cache.lbl_apv_Vacation_days' /> <spring:message code='Cache.btn_register' />","/groupware/vacation/goVacationInsertPopup.do?year="+year,"500px","265px","iframe",true,null,null,true);
    }

    // 그리드 클릭
    function openVacationUpdatePopup(urCode, year) {
        Common.open("","target_pop","<spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goVacationUpdatePopup.do?urCode="+urCode+"&year="+year,"499px","281px","iframe",true,null,null,true);
    }

    // 연차기간설정 버튼
    function openVacationPeriodManagePopup(urCode, year) {
        Common.open("","target_pop","<spring:message code='Cache.lbl_apv_setVacTerm' />","/groupware/vacation/goVacationPeriodManagePopup.do","420px","540px","iframe",true,null,null,true);
    }

    // 엑셀 업로드
    function openVacationInsertByExcelPopup() {
        Common.open("","target_pop","<spring:message code='Cache.lbl_ExcelUpload' />","/groupware/vacation/goVacationInsertByExcel1Popup.do?reqType="+reqType,"500px","290px","iframe",true,null,null,true);
    }

    // 조직도 팝업
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
                html += '<div><span>' + CFN_GetDicInfo(v.LV.split("&")[1]) + '</span></div>';
                html += '<div><input type="text" placeholder="0"></div>';
                html += '</li>';

                duplChkUserIdArr.push(userId);
            }
        });

        $('#target_pop_if').contents().find('#listHeader').after(html);
    }

    function updateDeptInfo() {
        Common.Confirm("<spring:message code='Cache.msg_n_att_wantToSync' />", "Confirmation Dialog", function (confirmResult) { //동기화 하시겠습니까?
            if (confirmResult) {
                $.ajax({
                    type : "POST",
                    url : "/groupware/vacation/updateDeptInfo.do",
                    async:false,
                    success:function (data) {
                        if(data.status == 'SUCCESS') {
                            Common.Inform("<spring:message code='Cache.msg_apv_170' />", "Inform", function() {
                                search();
                            });
                        } else {
                            Common.Warning("<spring:message code='Cache.msg_apv_030' />");
                        }
                    },
                    error:function(response, status, error) {
                        CFN_ErrorAjax(url, response, status, error);
                    }
                });
            } else {
                return false;
            }
        });
    }
</script>