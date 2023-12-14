
//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_en = {
    localLangItems: {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_ja = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_zh = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};



//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    //debugger;
    //Subject 숨김처리
    $('#tblFormSubject').hide();

    if (typeof formJson.BodyContext != 'undefined') {
        if (formJson.BodyContext.contractGubun == "0") {
            document.getElementById("trcontractCompany").style.display = "";
            document.getElementById("trceo").style.display = "";
            document.getElementById("trcontractPerson").style.display = "none";
            document.getElementById("trCard").style.display = "none";
        } else if (formJson.BodyContext.contractGubun == "1") {
            document.getElementById("trcontractCompany").style.display = "none";
            document.getElementById("trceo").style.display = "none";
            document.getElementById("trcontractPerson").style.display = "";
            document.getElementById("trCard").style.display = "";
        } else if (formJson.BodyContext.contractGubun == "2") {
            document.getElementById("trcontractCompany").style.display = "none";
            document.getElementById("trceo").style.display = "none";
            document.getElementById("trcontractPerson").style.display = "";
            document.getElementById("trCard").style.display = "none";
            document.getElementById("trLicensee").style.display = "";
        }
    }

    //debugger;
    //공통영역
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
        
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        //document.getElementById("btnline").style.display = "none";

        $('*[data-mode="writeOnly"]').each(function () {
            //직무대행 버튼 $('#spanBtnForDeputy').hide();
            //문서분류 버튼 $('#spanBtnForDocClass').hide();
            //휴가명 설명 $('#spanVacType').hide();
            $(this).hide();
        });

        //if (formJson.BodyContext.tblAdd2 !== undefined) {
		if (formJson.BodyContext != undefined && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAdd2), 'json', '#tblAdd2', 'R');
            // 멀티로우 안에 mField 후 처리
		} else {
			XFORM.multirow.load('', 'json', '#tblAdd2', 'R');
		}
        $('#totalAmount').attr('data-pattern', 'currency').text(formJson.BodyContext.totalAmount);  

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            //<span id="CommentList" data-mode="readOnly" ></span>
            $(this).hide();
        });
        

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

      		document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
		if (formJson.BodyContext != undefined && formJson.BodyContext != null && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAdd2), 'json', '#tblAdd2', 'W');


		} else {
 			XFORM.multirow.load('', 'json', '#tblAdd2', 'W', { minLength: 0 });
       	}
    }

    //setLabel과 setBodyContext 정리 후 상단으로 이동

}

function setLabel() {
   
}
function setFormInfoDraft() {

}


function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
    	if (document.getElementById("SaveTerm").value == '') {
            alert('보존년한을 선택하세요.');
            return false;
        } else {
            return EASY.check().result;
        }
    }
}

function setBodyContext(sBodyContext) {

}

//본문 XML로 구성
function makeBodyContext() {
   /* var sBodyContext = "";
    sBodyContext = "<BodyContext>" + getFields("mField") + getMultiRowFields("tblAdd2", "rField") + "</BodyContext>";
    return sBodyContext;*/
	
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblAdd2", "rField"));
    return bodyContextObj;
}



function tblAllDelRow(objName, findex, lindex) {    
    var tblObj = document.getElementById(objName);
    var i = findex;
    while (i < tblObj.rows.length - lindex) {
        tblObj.deleteRow(findex);
    }
}

/*function changType(obj, gubun) {
    if (gubun == 'c') {
        document.getElementById("btnline").style.display = "";

        document.getElementById("contractPerson").value = "";
        document.getElementById("idCard1").value = "";
        document.getElementById("idCard2").value = "";

        document.getElementById("trcontractCompany").style.display = "";
        document.getElementById("trceo").style.display = "";
        document.getElementById("trcontractPerson").style.display = "none";
        document.getElementById("trCard").style.display = "none";
        document.getElementById("trLicensee").style.display = "none";
        document.getElementById("spanLicensee").style.display = "none";
    }
    else if (gubun == 'p') {
        document.getElementById("btnline").style.display = "none";

        //document.getElementById("tblAdd2").deleteRow(document.getElementById("tblAdd2").rows.length - 1);
        var RowCount = document.getElementById("tblAdd2").rows.length;
                
        // 1개의 행 남기기
        for (var i = RowCount; i > 4; i--) {
            DelRow();
        }
               
        AddRow();
        
        document.getElementById("contractCompany").value = "";
        document.getElementById("ceo").value = "";

        document.getElementById("trcontractCompany").style.display = "none";
        document.getElementById("trceo").style.display = "none";
        document.getElementById("trcontractPerson").style.display = "";
        document.getElementById("trCard").style.display = "";
        document.getElementById("trLicensee").style.display = "none";
        document.getElementById("spanLicensee").style.display = "none";

        document.getElementById("totalAmount").value = "";
    }

    else if (gubun == 's') {
        document.getElementById("btnline").style.display = "none";

        //document.getElementById("tblAdd2").deleteRow(document.getElementById("tblAdd2").rows.length - 1);
        var RowCount = document.getElementById("tblAdd2").rows.length;

        // 1개의 행 남기기
        for (var i = RowCount; i > 4; i--) {
            DelRow();
        }

        AddRow();

        document.getElementById("contractCompany").value = "";
        document.getElementById("ceo").value = "";

        document.getElementById("trcontractCompany").style.display = "none";
        document.getElementById("trceo").style.display = "none";
        document.getElementById("trcontractPerson").style.display = "";
        document.getElementById("trCard").style.display = "none";
        document.getElementById("trLicensee").style.display = "";
        document.getElementById("spanLicensee").style.display = "";

        document.getElementById("totalAmount").value = "";
    }
}*/

function changType(obj) {
    //trcontractCompany 회사이름
    //trcontractPerson 성명
    //trceo 대표이사
    //trCard 주민등록번호
    //trLicensee 사업자등록번호

    if (obj == 0) { //회사명,대표이사,주소
        $("#trcontractCompany").css('display', '');
        $("#trceo").css('display', '');
        $("#trcontractPerson").css('display', 'none');
        $("#trCard").css('display', 'none');
        $("#trLicensee").css('display', 'none');
    }
    else if (obj == 1) { //성명,주민등록번호,주소
        $("#trcontractPerson").css('display', '');
        $("#trCard").css('display', '');
        $("#trLicensee").css('display', 'none');
        $("#trceo").css('display', 'none');
        $("#trcontractCompany").css('display', 'none');

    }
    else { //성명,사업자등록번호,주소
        $("#trcontractPerson").css('display', '');
        $("#trLicensee").css('display', '');
        $("#trcontractCompany").css('display', 'none');
        $("#trceo").css('display', 'none');
        $("#trCard").css('display', 'none');
    }

}


/*function nameCopy() {    
    document.getElementsByName("name")[1].value = document.getElementById("contractPerson").value;
}*/

function sumtotal() {    
    var unitPrice = document.getElementsByName("unitPrice");
    var mm = document.getElementsByName("mm");
    var total = document.getElementsByName("total");
    var totalsum = 0;

    for (var i = 0; i < unitPrice.length; i++) {
        if (unitPrice[i].value != "" && mm[i].value != "") {
            total[i].value = parseInt(RemoveComma(unitPrice[i].value)) * parseInt(RemoveComma(mm[i].value));
            //totalsum = totalsum + parseInt(RemoveComma(unitPrice[i].value)) * parseInt(RemoveComma(mm[i].value));
            $(total[i]).trigger('change');
        }
    }
    //document.getElementById("totalAmount").value = totalsum;
    //$("#totalAmount").trigger('change');
}

function RemoveComma(strSrc) {
    return (strSrc.replace(/,/g, ""));
}

function checksubject(obj) {
    document.getElementById("Subject").value = obj.value;
}

function unitPriceCheck(){
    $("input[name=unitPrice]").val($("#price").val());
}

//[hwkim] 2017.01.24  _ 행추가 함수
function Cal(obj) {
    var tblobj = document.getElementById("tblAdd2");
    var sdt = $('#SDATE').val().replace(/-/g, ''); //2016-12-19
    var edt = $('#EDATE').val().replace(/-/g, '');
    var tmpObj = $(obj).closest('tr');

    XFORM.multirow.clearRow('#tblAdd2');

    if ($(tmpObj).find("input[id=SDATE]").val() != "" && $(tmpObj).find("input[id=EDATE]").val() != "") {
        var SDATE = $(tmpObj).find("input[id=SDATE]").val().split('-');
        var EDATE = $(tmpObj).find("input[id=EDATE]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(obj).val('');
        }
            var NumSYear = parseInt($('#SDATE').val().split("-")[0]);
            var NumEYear = parseInt($('#EDATE').val().split("-")[0]);

            var NumSMon = parseInt($('#SDATE').val().split("-")[1]);
            var NumEMon = parseInt($('#EDATE').val().split("-")[1]);
                if (NumSYear == NumEYear) {
                    var rowlength = NumEMon - NumSMon + 1;
                    //alert("같은 년" + rowlength);
                    $("#hiddenVal").val(rowlength);
                    XFORM.multirow.addRow('#tblAdd2', parseInt(rowlength));
                }
                else if (NumEYear > NumSYear) {
                    var start_Array = $('#SDATE').val().split("-");
                    var end_Array = $('#EDATE').val().split("-");
                    var year_compareDate = end_Array[0] - start_Array[0];
                    var month_compareDate = end_Array[1] - start_Array[1];
                    var tmpMonth
                    if (year_compareDate >= 2) {
                        //tmpMonth = ((parseInt(end_Array[0]) - parseInt(start_Array[0])) * 12) + (12 - parseInt(start_Array[1]) + parseInt(end_Array[1]) + 1);
                        tmpMonth = ((parseInt(end_Array[0]) - parseInt(start_Array[0]) - 1) * 12) + ((12 - parseInt(start_Array[1]) + 1) + parseInt(end_Array[1]));
                    }
                    else {
                        tmpMonth = (12 - parseInt(start_Array[1]) + parseInt(end_Array[1]) + 1);
                    }
                    
                        if (year_compareDate > 0 && month_compareDate > 0) { //시작일 2017-1 //종료일 2018 -8
                            
                            //계산식 : year_compareDate*12  + month_compareDate : 차이 달수  ->  rowlength
                            var rowlength2 = parseInt(year_compareDate) * 12 + parseInt(month_compareDate) + 1;
                            //alert("년,달 모두 큼" + rowlength2);
                            $("#hiddenVal").val(rowlength2);
                            XFORM.multirow.addRow('#tblAdd2', parseInt(rowlength2));
                        }
                        else if (year_compareDate > 0 && month_compareDate <= 0) {
                            var rowlength3 = tmpMonth
                            //alert("년 만 큼" + rowlength3);
                            $("#hiddenVal").val(rowlength3);
                            XFORM.multirow.addRow('#tblAdd2', parseInt(rowlength3));
                           
                        }
                }

    }
    
    var rowSDate;//최초행 시작일
    var rowEDate;//최종행 종료일
    var rowSDateMonth = $("#SDATE").val().split("-")[1];   //시작기간(월)
    var index = 1;
    var currentYear = 0;
    var cntRow = 1;

    //[hwkim] 2017.01.24  _ 멀티로우 행추가시 동작 함수 
    XFORM.multirow.event('afterRowAdded', function ($rows) {
        var hiddenRowlength = $("#hiddenVal").val();
        //console.log(hiddenRowlength);

        var rowSDateYear = $("#SDATE").val().split("-")[0];//시작기간(년)
        var rowEDateYear = $("#EDATE").val().split("-")[0];//만료기간(년)
        var rowEDateMonth = $("#EDATE").val().split("-")[1];//만료기간(월)

        var rowEDateDay = $("input[name=EPeriod]").val().split("-")[3];//만료기간(일)
        var rowSDateDay = $("input[name=SPeriod]").val().split("-")[3];//시작기간(일)
        
        rowSDate = $("#SDATE").val();
        rowEDate = $("#EDATE").val();

        var lastSDate = (new Date(rowSDateYear, rowSDateMonth, 0)).getDate(); //마지막 일(31)

        var lastDate2 = new Date(rowSDate.split('-')[0], rowSDate.split('-')[1], 0).yyyymmdd(); //마지막일 - 김형욱

        //console.log(lastDate2);

        //var sumlastDate = rowSDateYear + "-" + rowSDateMonth + "-" + lastSDate; //마지막일 (2017-01-31)@@@

        if (((parseInt(rowSDateMonth) < 10 && parseInt(rowSDateMonth) != 1) && parseInt(rowSDateMonth) != 2)) {
            if (parseInt(rowSDateMonth) != 3 && currentYear == 0) {
                var sumlastDate = rowSDateYear + "-" + rowSDateMonth + "-" + lastSDate; //마지막일 (2017-01-31)@@@
            }
            else {
                var sumlastDate = rowSDateYear + "-" + "0" + rowSDateMonth + "-" + lastSDate; //마지막일 (2017-01-31)@@@
            }
        }
        else if (parseInt(rowSDateMonth) == 1) {
            var sumlastDate = rowSDateYear + "-" + rowSDateMonth + "-" + lastSDate; //마지막일 (2017-01-31)@@@
        }
        else {
            var sumlastDate = rowSDateYear + "-" + rowSDateMonth + "-" + lastSDate; //마지막일 (2017-01-31)@@@
        }



        if (parseInt(rowSDateMonth) < 10 && parseInt(rowSDateMonth) != 1) {
            var _firstDayOfMonth = [rowSDateYear, "0" + rowSDateMonth, "0" + 1].join('-');  // ex) 2014-04-01 

        }
        else if (parseInt(rowSDateMonth) == 1) {
            var _firstDayOfMonth = [rowSDateYear, rowSDateMonth, "0" + 1].join('-');

        }
        else {
            var _firstDayOfMonth = [rowSDateYear, rowSDateMonth, "0" + 1].join('-');  // ex) 2014-10-01 

        }

        var _firstDayOfMonthDate = new Date(_firstDayOfMonth);
        var test = _firstDayOfMonthDate.setMonth(_firstDayOfMonthDate.getMonth() + 1);  // ex) 2014-05-01
        
        //최대 행 개수 가 하나 일때--------------------------------------------------------------

        if (rowSDateYear == rowEDateYear && rowSDateMonth == rowEDateMonth) {//시작년 == 종료년 && 시작 월 == 종료 월
            if (hiddenRowlength == 1) {
                $("input[name=SPeriod]:eq(" + index + ")").val($("#SDATE").val());//해당월 1일
                $("input[name=EPeriod]:eq(" + index + ")").val($("#EDATE").val());//마지막말일
                
            } else {
                $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);//해당월 1일
                $("input[name=EPeriod]:eq(" + index + ")").val($("#EDATE").val());//마지막말일
            }
            
        }
        //행이 한개 이상일때---------------------------------------------------------------------
        else if ((rowSDateYear != rowEDateYear && rowSDateMonth != rowEDateMonth) || (rowSDateYear != rowEDateYear && rowSDateMonth == rowEDateMonth) || (rowSDateYear == rowEDateYear && rowSDateMonth != rowEDateMonth)) {
            //시작년 != 종료년 && 시작월 != 마지막월     시작년 != 종료년 && 시작월 == 종료월     시작년 == 종료년 && 시작월 != 종료월
            if (rowSDateMonth == parseInt($("#EDATE").val().split("-")[1])) {//(행)시작 월 == 종료 월
                if (index != 1) {
                    $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);//최초시작일
                    $("input[name=EPeriod]:eq(" + index + ")").val(sumlastDate);//해당달
                }
                else {
                    $("input[name=SPeriod]:eq(" + index + ")").val(rowSDate);//최초시작일
                    $("input[name=EPeriod]:eq(" + index + ")").val(sumlastDate);//해당달마지막말일
                }
            }
            else {
                if (rowSDateYear == rowEDateYear) { //시작년 == 종료년@@@@
                    if (rowSDateMonth != rowEDateMonth) {//(행)시작월 != 종료 월
                        if(index ==1) {
                            $("input[name=SPeriod]:eq(" + index + ")").val(rowSDate);
                        } else if (index != 1) {
                            $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);
                        }
                            
                            $("input[name=EPeriod]:eq(" + index + ")").val(sumlastDate);
                        
                    }
                    else {
                        $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);
                        $("input[name=EPeriod]:eq(" + index + ")").val($("#EDATE").val());//마지막말일
                    }
                }
                //행이 한개 이상이며 시작 년 과 종료년이 다를때--------------------------------------------
                else if (rowSDateYear != rowEDateYear) { //시작년 != 종료년@@@@
                    var totalLength = 12 - parseInt(rowSDateMonth) + parseInt(rowEDateMonth) + 1;
                    var firstDayOfMon;
                    var lastDayOfMon;
                    //debugger;
                    if (rowSDateMonth >= 13) {
                        if (rowSDateMonth % 13 == 0) {
                            //rowSDateMonth == 1;
                            currentYear++;
                        }

                        if (parseInt(rowSDateMonth) < 10 && parseInt(rowSDateMonth) != 1) { //시작월 10 미만 && 시작월 1 아닐때
                            firstDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-" + "0" + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-01";
                            lastDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-" + "0" + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-" + lastSDate; //마지막일 (월 10보다 작을때 2017-01-31)
                        }
                        else {
                            if (parseInt(rowSDateMonth) < 10) {
                                firstDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-" + "0" + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-01";
                            }
                            else {
                                firstDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-" + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-01";
                            }

                            if (parseInt(rowSDateMonth >= 10)) {
                                lastDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-" + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-" + lastSDate;
                            }
                            else {
                                lastDayOfMon = (parseInt(rowSDateYear) + currentYear) + "-"  + (parseInt(rowSDateMonth) - (12 * parseInt(currentYear))) + "-" + lastSDate; //마지막일 (2017-11-31)
                            }
                            
                        }

                        if (index != hiddenRowlength) {

                            $("input[name=EPeriod]:eq(" + index + ")").val(lastDayOfMon);
                        }
                        else {
                            $("input[name=EPeriod]:eq(" + index + ")").val(rowEDate);
                        }

                        $("input[name=SPeriod]:eq(" + index + ")").val(firstDayOfMon);


                    }//13월
                    else {
                        firstDayOfMon = ((parseInt(rowSDateYear) + currentYear) + "-" + 1).newDate().yyyymmdd();

                        if (rowSDateMonth != rowEDateMonth) {//(행)시작월 != 종료 월
                            if (index == 1) {
                                $("input[name=SPeriod]:eq(" + index + ")").val(rowSDate);
                            } else {
                                $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);
                            }
                            $("input[name=EPeriod]:eq(" + index + ")").val(sumlastDate);
                        }
                        else {
                            $("input[name=SPeriod]:eq(" + index + ")").val(_firstDayOfMonth);
                            $("input[name=EPeriod]:eq(" + index + ")").val(rowEDate);//마지막말일
                        }
                    }

                }
            }
            
        }
        //공수계산식 & 금액계산식
        //1. 공수 계산--------------------------------------------------------------------------
        var rowEDateDay2 = $("input[name=EPeriod]:eq(" + index + ")").val().split("-")[2];//만료기간(일) -- 해당 행
        var rowSDateDay2 = $("input[name=SPeriod]:eq(" + index + ")").val().split("-")[2];//시작기간(일)
        var tempCal;
        var hiddentempCal;
        var calval;
        var hiddencalVal;
        var tempSUse = $("input[name=SPeriod]:eq(" + index + ")");
        var tempEUse = $("input[name=EPeriod]:eq(" + index + ")");
        var sumlastDateDay = sumlastDate.split("-")[2];
        var simFirstDateDay = _firstDayOfMonth.split("-")[2];

        //var calval = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2)) / parseInt(rowEDateDay2)).toFixed(2);

        if (index == 1) {
            if (parseInt(rowSDateDay2) == 1) {
                //tempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / parseInt(rowEDateDay2)); // 첫달 1일 부터 시작 일때
                tempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay); //첫달 1일부터 시작 X
                hiddentempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay);
            }
            else {
                tempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay); //첫달 1일부터 시작 X
                hiddentempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay);
            }

            calval = tempCal.toFixed(2); //소수 2자리까지 반올림
            hiddencalVal = hiddentempCal;
        }
        else if (index > 1 && index < hiddenRowlength) {
            calval = 1;
            hiddentempCal = 1;
        }
        else {
            tempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay);
            hiddentempCal = ((parseInt(rowEDateDay2) - parseInt(rowSDateDay2) + 1) / sumlastDateDay);
            //calval = (parseInt(rowSDateDay2) / parseInt(rowEDateDay2)).toFixed(2);
            calval = tempCal.toFixed(2);
            hiddencalVal = hiddentempCal;
        }

        $("input[name=mm]:eq(" + index + ")").val(calval);
        $("input[name=hiddenMm]:eq(" + index + ")").val(hiddencalVal);

        //*****************실제 공수 (실제 가격 계산 값)
        //alert($("input[name=hiddenMm]:eq(" + index + ")").val());


        var tempindex = index - 1;
        var checkSPeriod = $("tr.multi-row input[name=SPeriod]").eq(tempindex).val();
        var checkEPeriod = $("tr.multi-row input[name=EPeriod]").eq(tempindex).val();

        var splitMonthSPeriod = checkSPeriod.split("-")[1];
        var splitMonthEPeriod = checkEPeriod.split("-")[1];
        var splitYearSPeriod = checkSPeriod.split("-")[0];
        var splitYearEPeriod = checkEPeriod.split("-")[0];
        var sumlastVal = sumlastDate.split("-")[2];
        var hiddenRowlength = $("#hiddenVal").val();
        var lastEperiod = $("#EDATE").val();

        var refreshDate;
        if (parseInt(splitMonthSPeriod) == 13) {

            $("tr.multi-row input[name=SPeriod]").eq(tempindex).val(((parseInt(splitYearSPeriod) + 1) + "-" + 1).newDate().yyyymmdd());
            if (index == (hiddenRowlength)) {
                $("input[name=EPeriod]").eq(tempindex).val($("#EDATE").val());//마지막말일
            }
            else {
                $("tr.multi-row input[name=EPeriod]").eq(tempindex).val((parseInt(splitYearSPeriod) + 1) + "-1-" + sumlastVal);
            }
            

        }
        else if (parseInt(splitMonthSPeriod) == 14) {
            $("tr.multi-row input[name=SPeriod]").eq(tempindex).val(((parseInt(splitYearSPeriod) + 1) + "-" + 2).newDate().yyyymmdd());

            if (index == hiddenRowlength) {
                $("input[name=EPeriod]").eq(tempindex).val($("#EDATE").val());//마지막말일
            }
            else {
                $("tr.multi-row input[name=EPeriod]").eq(tempindex).val((parseInt(splitYearSPeriod) + 1) + "-1-" + sumlastVal);
            }
        }

        //모든 행 시작 월 0여부 체크
        if (parseInt(splitMonthSPeriod) < 10) {
            if (splitMonthSPeriod.indexOf(0) != 0) {
                $("tr.multi-row input[name=SPeriod]").eq(tempindex).val((splitYearSPeriod + "-" + "0" + splitMonthSPeriod + "-" + 0).newDate().yyyymmdd());
                
            }
        }
        //행 시작월 - 행 마지막월 체크
        if (splitMonthSPeriod != splitMonthEPeriod) {
            //alert("월 다름");
            //시작행 월 복사
            if (index != hiddenRowlength) {
                $("tr.multi-row input[name=EPeriod]").eq(tempindex).val(splitYearSPeriod + "-" + splitMonthSPeriod + "-" + sumlastVal);
            }
            else {
                $("tr.multi-row input[name=EPeriod]").eq(tempindex).val($("#EDATE").val());
            }
            
        }

        rowSDateMonth++;
        index++;
    });  //행 생성뒤 각 행 채우기

} //cal


//금액계산&출력 식 & 합계 계산식===========================================================================================================================
var priceindexAdd = 1;

function rowNumTest(obj) {

    var calTable = $("#tblAdd2");
    var priceIndex = $("input[name=unitPrice]").index(obj); //입력 행의 가격(인덱스)
    var priceInput = $("input[name=unitPrice]").eq(priceIndex).val();//입력 행의 값(가격)

    var mmIndex = $("input[name=mm]").index(obj); //입력 행의 mm(인덱스)
    var mmSelected = $("input[name=mm]").eq(priceIndex).val();//입력 행의 값(mm)

    var hiddenMMInput = $("input[name=hiddenMm]").index(obj);//입력 행의 값(인덱스)
    var hiddenMMselected = $("input[name=hiddenMm]").eq(priceIndex).val();//입력 행의 값(mm)

    if (parseInt(mmSelected) == 1) {
        var calTotal = priceInput * 1;
    } else {
        var calTotal = priceInput * hiddenMMselected; //금액 계산 식 (입력 가격 * mm)
    }
    var priceDelete = Math.floor(calTotal / 1000) * 1000; //금액 계산 값(천단위 미만 절삭)
    var totalIndex = $("#hiddenVal").val();
    var tempPrice = 0;
    var rowPrice = $("input[name=total]").val();

    //***********[금액 출력] 수정 요청 시 아래의 주석으로 값 체크***********
    //console.log(priceInput + "입력가격");
    //console.log(mmSelected + "행의맨먼스");
    //console.log(calTotal + "금액계산 값");
    //console.log(testDelete + "절삭값");

    //1. 금액 출력--------------------------------------------------------------------------
    if (calTotal < 1000) {
        $("input[name=total]").eq(priceIndex).val(calTotal); //금액 계산값이 1000미만 시
    }
    else {
        $("input[name=total]").eq(priceIndex).val(priceDelete); //금액 계산값이 1000이상 시 =========================== 로직 묻고 수정 필요 없을시 이거 사용
    }
    //2. 합계 출력--------------------------------------------------------------------------
    //console.log(totalIndex); -- 생성된 행의 개수
    var i = $("input[name=total]").eq(priceindexAdd);
    var j = $("input[name=total]").length;

    $("tr.multi-row input[name=total]").each(function (i,obj) {
        //console.log(i);
        var temptotal = $("tr.multi-row input[name=total]").eq(i).val() //$(obj).val()과 같음
        tempPrice += parseInt(temptotal);
    });
    $("#totalAmount").val(tempPrice);
}
//2017.02.20