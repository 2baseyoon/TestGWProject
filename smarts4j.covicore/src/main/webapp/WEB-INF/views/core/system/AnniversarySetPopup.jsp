<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<form>
	<table  class="AXFormTable">
		<colgroup>
			<col width="20%"/>
			<col width="80%"/>
		</colgroup>
		<tr>
			<th><spring:message code="Cache.lbl_Domain"/></th> <!-- 도메인  -->
			<td ><select id="selectDomain" class="AXSelect W100" ></select>	</td>
		</tr>
		<tr>
			<th><spring:message code="Cache.lbl_anniversarytype"/></th> <!-- 기념일 유형  -->
			<td><select id="selectAnniversaryType" class="AXSelect W100" ></select></td>
		</tr>
		<tr>
			<th><spring:message code="Cache.lbl_Solar"/></th> <!-- 양력  -->
			<td id="solarDateTD" style="height: 37px;"><input type="text" class="AXInput W100" id="solarDate" kind="date"  date_separator="-"></td>
		</tr>
		<tr id="repeatTr">
			<th><spring:message code="Cache.lbl_anniversaryrepeat"/></th> <!-- 반복 설정  -->
			<td style="height: 37px;">
				<input type="radio"  id="isUseY" name="isUse" onclick="clickIsUse();" value="Y"  />
				<label for="isUseY"><spring:message	code='Cache.lbl_USE_Y' />&nbsp;&nbsp;	</label> <!-- 사용 -->
				<input type="radio" id="isUseN" name="isUse" onclick="clickIsUse();" value="N"  checked="checked"/>
				<label for="isUseN"><spring:message code='Cache.lbl_USE_N' />&nbsp;&nbsp;&nbsp;</label>  <!-- 사용 안 함 -->
				<span id="repeatSpan" style="display:none;">
					<spring:message code='Cache.lbl_EveryYear' />&nbsp; <!-- 매년 -->
					<input type="input" class="AXInput W40"  style="height:14px;" kind="number"  id="repeatCnt"  value="2" num_min="1" num_max="999"/>
					<spring:message code='Cache.lbl_Inning' />&nbsp; <!--회 -->
				</span>
				
			</td>
		</tr>
		<tr>
			<th>	<spring:message code="Cache.lbl_AnniversaryName"/>	</th> <!-- 기념일명  -->
			<td>
				<input type="text" id="anniversaryName"  style="width: 80%;" class="AXInput HtmlCheckXSS ScriptCheckXSS" onclick="dictionaryLayerPopup();"/>
				<input id="hidAnniversaryNameDic" name="hidAnniversaryNameDic" type="hidden" />
				<input type="button"  value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="dictionaryLayerPopup();" /> <!-- 다국어 -->
			</td>
		</tr>
	</table>
	<div class="popBtn" style="padding-top: 10px">
		<input type="button" id="btnSave" class="AXButton red"	value="<spring:message code="Cache.btn_apv_save"/>" onclick="saveAnniversary();" /> 
		<input type="button" id="btnClose" class="AXButton"	value="<spring:message code="Cache.btn_apv_close"/>" onclick="Common.Close();" />
	</div>
</form>

<script type="text/javascript">
	//# sourceURL=AnniversarySetPopup.jsp
	var mode = CFN_GetQueryString("mode");	//add or modify
	var calendarID = CFN_GetQueryString("calendarID");
	var langCode = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		setControls();		// 컨트롤 초기화
		
		setData();
	}
	
	
	// 컨트롤 초기화
	function setControls(){
		coviCtrl.renderDomainAXSelect('selectDomain', langCode, '', '', '', false);
		coviCtrl.renderAXSelect('AnniversaryType', 'selectAnniversaryType',  langCode, '', '', 'AnniversaryType');
	}
	
	function setData(){
		if(mode=="modify" && calendarID != "undefined"){
			$.ajax({
				type: "POST"
				, url: "/covicore/anniversary/getAnniversaryData.do"
				, data: {
					"calendarID": calendarID
				}, 
				success:function (data) {
					if(data.status == "SUCCESS"){
						$("#repeatTr").hide();
						$("#selectDomain").bindSelectDisabled(true);
						$("#selectDomain").bindSelectSetValue(data.anniversary.DomainID);
						$("#selectAnniversaryType").bindSelectSetValue(data.anniversary.AnniversaryType);
						$("#solarDateTD").html(data.anniversary.SolarDate);
						$("#anniversaryName").val(CFN_GetDicInfo(data.anniversary.Anniversary));
						$("#hidAnniversaryNameDic").val(data.anniversary.Anniversary);
					}else{
						parent.Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
		    		}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/anniversary/getAnniversaryData.do", response, status, error);
				}
			});
		}
	}
	
	//저장 및 수정
	function saveAnniversary(){
		if(!chkValidataion())
			return;
		
		var sDictionaryInfo = document.getElementById("hidAnniversaryNameDic").value;
	    if (sDictionaryInfo == "") {
	        switch (langCode.toUpperCase()) {
	            case "KO": sDictionaryInfo = document.getElementById("anniversaryName").value + ";;;;;;;;;"; break;
	            case "EN": sDictionaryInfo = ";" + document.getElementById("anniversaryName").value + ";;;;;;;;"; break;
	            case "JA": sDictionaryInfo = ";;" + document.getElementById("anniversaryName").value + ";;;;;;;"; break;
	            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("anniversaryName").value + ";;;;;;"; break;
	            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("anniversaryName").value + ";;;;;"; break;
	            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("anniversaryName").value + ";;;;"; break;
	            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("anniversaryName").value + ";;;"; break;
	            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("anniversaryName").value + ";;"; break;
	            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("anniversaryName").value + ";"; break;
	            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("anniversaryName").value; break;
	        }
	        document.getElementById("hidNameDicInfo").value = sDictionaryInfo
	    }
	    
	    var url,  params; 
	    if(mode == "add"){
	    	url = "/covicore/anniversary/addAnniversaryData.do";
	    	params = {
			    			"domainID": $("#selectDomain").val(),
			    			"anniversaryType" : $("#selectAnniversaryType").val(),
			    			"solarDate": $("#solarDate").val(),
			    			"isRepeat": $('input:radio[name="isUse"]:checked').val(), 
			    			"repeatCnt": $("#repeatCnt").val(), 
			    			"hidAnniversaryNameDic" : $("#hidAnniversaryNameDic").val()
				    	};
	    }else{
	    	url = "/covicore/anniversary/modifyAnniversaryData.do";
	    	params = {
				    		"calendarID": calendarID, 
				    		"anniversaryType" : $("#selectAnniversaryType").val(),
				    		"hidAnniversaryNameDic" : $("#hidAnniversaryNameDic").val()
				    	};
	    }
	    
	    $.ajax({
	    	type:"POST",
	    	url: url, 
	    	data: params,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			if(data.duplication != undefined && data.duplication == "Y"){
	    				Common.Warning("<spring:message code='Cache.msg_exist-solardate'/>");/* 이미 기념일이 있습니다. */
	    			}else{
		    			/*저장되었습니다.*/
			    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
							parent.anniversaryGrid.reloadList();			
			    			Common.Close();
			    		});
	    			}
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	    	error:function(response, status, error){
	    	     //TODO 추가 오류 처리
	    	     CFN_ErrorAjax(url, response, status, error);
	    	}
	    	
	    });
	}
	
	// Validation check
	function chkValidataion(){

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	    // 기념일 유형
        if ($("#selectAnniversaryType").val() == "" || $("#selectAnniversaryType").val() =="AnniversaryType") {
            parent.Common.Warning("<spring:message code='Cache.msg_AnniversaryTypeInput'/>", "Validation Check"); /* 기념일 유형을 선택해주세요.  */
            return false;
        }

        // 날짜 입력 
        if (mode == "add" && $("#solarDate").val() == "" ) {
            parent.Common.Warning("<spring:message code='Cache.msg_apv_chk_date'/>", "Validation Check", function () { /* 날짜를 입력해주세요.  */
            	$("#solarDate").focus();
            });
            return false;
        }

        // 기념일명
        if ($("#anniversaryName").val() == "" ) {
        	 parent.Common.Warning("<spring:message code='Cache.msg_Anniversary_01'/>", "Validation Check", function () { /* 기념일명을 입력해주세요.  */
             	$("#anniversaryName").focus();
             });
             return false;
        }
        
        return true;
	
	}
	
	//반복 사용여부 변경 함수 
	function clickIsUse(){
		var isUse = $('input:radio[name="isUse"]:checked').val();
		
		if (isUse.toUpperCase() == "Y") {
			$("#repeatSpan").show();
			coviInput.setNumber();
		}else{
			$("#repeatSpan").hide();
		}
	}
	
	//다국어 설정 팝업
	function dictionaryLayerPopup(){
		var option = {
				lang : langCode,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh,lang1,lang2',
				useShort : 'false',
				dicCallback : 'dicCallback',
				openerID : 'setAnniversary',
				popupTargetID : 'setMultiLangData',
				init : 'dicInit'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&openerID=" + option.openerID;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		parent.Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"500px","310px","iframe",true,null,null,true);
	}

	//다국어 세팅 함수
	function dicInit(){
		if(document.getElementById("hidAnniversaryNameDic").value == ''){
			value = document.getElementById('anniversaryName').value;
		}else{
			value = document.getElementById("hidAnniversaryNameDic").value;
		}
		
		return value;
	}

	//다국어 콜백 함수
	function dicCallback(data){
		var dicObj = JSON.parse(data);
		
		$("#hidAnniversaryNameDic").val(coviDic.convertDic(dicObj));
		document.getElementById('anniversaryName').value = CFN_GetDicInfo(coviDic.convertDic(dicObj),langCode);
		
		Common.Close("setMultiLangData");
	}
	
</script>