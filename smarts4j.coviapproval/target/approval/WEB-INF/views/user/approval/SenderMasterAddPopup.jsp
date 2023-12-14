<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:600px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 18%;">
						<col style="width: 31%;">
						<col style="width: 17%;">
						<col style="width: 32%;">
					</colgroup>
					<tbody></tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk" style="display: none;"><spring:message code='Cache.btn_save' /></a> <!-- 저장 -->
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;" style="display: none;"><spring:message code='Cache.btn_apv_close' /></a> <!-- 닫기 -->
				<a id="btnCancel" class="btnTypeDefault" onclick="Common.Close(); return false;" style="display: none;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var mode = CFN_GetQueryString("mode") == "undefined" ? "" : CFN_GetQueryString("mode");
	var senderID = CFN_GetQueryString("senderID") == "undefined" ? "" : CFN_GetQueryString("senderID");
	
	//var SignImagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + Common.getBaseConfig("SignImagePath");
	
   window.onload = initOnload;
   function initOnload() {
	setPopup();
   }
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		switch(mode){
			case "I": // 추가
			case "M": // 수정
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font>구분</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<select id="SENDER_TYPE" onchange="changeSenderType();" class="selectType02" style="width: 95%;margin-left: 5px;">';
				popupHtml += '			<option value="C">회사</option>';
				popupHtml += '			<option value="D">부서</option>';
				popupHtml += '		</select>';
				popupHtml += '	</td>';
				popupHtml += '	<th><font color="red">* </font>조직도</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="DEPT_NAME" value="'+Common.getSession('DN_Name')+'" onclick="goOrgChartPopup();" style="width: 95%;margin-left: 5px;cursor: pointer;" readonly>';
				popupHtml += '		<input type="text" id="DEPT_CODE" value="'+Common.getSession('DN_Code')+'" hidden>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font>표시이름</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="DISPLAY_NAME" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '	<th><font color="red">* </font>사용여부</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<select id="USAGE_STATE" class="selectType02" style="width: 95%;margin-left: 5px;">';
				popupHtml += '			<option value="Y">사용</option>';
				popupHtml += '			<option value="N">비사용</option>';
				popupHtml += '		</select>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><font color="red">* </font>기관명</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="OUNAME" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '	<th><font color="red">* </font>기관장명</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="NAME" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>TEL</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="TEL" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '	<th>FAX</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="FAX" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>홈페이지</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="HOMEPAGE" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '	<th>E-MAIL</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="EMAIL" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>우편번호</th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<input type="text" id="ZIP_CODE" style="width: 95%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '	<th></th>';
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>주소</th>';
				popupHtml += '	<td colspan="3" style="padding: 5px;">';
				popupHtml += '		<input type="text" id="ADDRESS" style="width: 98%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>캠페인(상)</th>';
				popupHtml += '	<td colspan="3" style="padding: 5px;">';
				popupHtml += '		<input type="text" id="CAMPAIGN_T" style="width: 98%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>캠페인(하)</th>';
				popupHtml += '	<td colspan="3" style="padding: 5px;">';
				popupHtml += '		<input type="text" id="CAMPAIGN_F" style="width: 98%;margin-left: 5px;">';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th>Image</th>';
				popupHtml += '	<td colspan="3" style="padding: 5px;">';
				popupHtml += '		<table class="tableTypeRow">';
				popupHtml += '			<colgroup>';
				popupHtml += '				<col style="width: 33%;">';
				popupHtml += '				<col style="width: 33%;">';
				popupHtml += '				<col style="width: *;">';
				popupHtml += '			</colgroup>';
				popupHtml += '			<tr>';
				popupHtml += '				<th style="text-align: center;">Logo</th>';
				popupHtml += '				<th style="text-align: center;">Symbol</th>';
				popupHtml += '				<th style="text-align: center;">Stamp</th>';
				popupHtml += '			</tr>';
				popupHtml += '			<tr>';
				popupHtml += '				<td style="height: 100px; text-align: center; border-left: 0px;"><img id="LOGO" src="/covicore/resources/images/no_image.jpg" width="95px" height="auto"></td>';
				popupHtml += '				<td style="height: 100px; text-align: center;"><img id="SYMBOL" src="/covicore/resources/images/no_image.jpg" width="95px" height="auto"></td>';
				popupHtml += '				<td style="height: 100px; text-align: center;"><img id="STAMP" src="/covicore/resources/images/no_image.jpg" width="95px" height="auto"></td>';
				popupHtml += '			</tr>';
				popupHtml += '			<tr id="registImageTR" style="display:none;">';
				popupHtml += '				<td style="border-left: 0px; padding: 5px; text-align: center;">';
				popupHtml += '					<input name="hidLOGO" id="hidLOGO" type="text" hidden>';
				popupHtml += '					<input name="LOGO_fileurl" id="LOGO_fileurl" type="text" class="AXButton" readonly="readonly" style="width: 50%;margin-left: 5px;display: none;">';
				popupHtml += '					<input type="button" class="AXButton" onclick="document.getElementById(\'LOGO_oFile\').click();" value="등록">';
				popupHtml += '					<input id="LOGO_delBtn" style="display:none;" type="button" class="AXButton" onclick="imgUpload_del(\'LOGO\');" value="삭제">';
				popupHtml += '					<input type="file" id="LOGO_oFile" onchange="imgUpload(this.value,\'LOGO\');" style="width:0px;filter:alpha(opacity:\'0\');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png">';
				popupHtml += '				</td>';
				popupHtml += '				<td style="padding: 5px; text-align: center;">';
				popupHtml += '					<input name="hidSYMBOL" id="hidSYMBOL" type="text" hidden>';
				popupHtml += '					<input name="SYMBOL_fileurl" id="SYMBOL_fileurl" type="text" class="AXButton" readonly="readonly" style="width: 50%;margin-left: 5px;display: none;">';
				popupHtml += '					<input type="button" class="AXButton" onclick="document.getElementById(\'SYMBOL_oFile\').click();" value="등록">';
				popupHtml += '					<input id="SYMBOL_delBtn" style="display:none;" type="button" class="AXButton" onclick="imgUpload_del(\'SYMBOL\');" value="삭제">';
				popupHtml += '					<input type="file" id="SYMBOL_oFile" onchange="imgUpload(this.value,\'SYMBOL\');" style="width:0px;filter:alpha(opacity:\'0\');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png">';
				popupHtml += '				</td>';
				popupHtml += '				<td style="padding: 5px; text-align: center;">';
				popupHtml += '					<input name="hidSTAMP" id="hidSTAMP" type="text" hidden>';
				popupHtml += '					<input name="STAMP_fileurl" id="STAMP_fileurl" type="text" class="AXButton" readonly="readonly" style="width: 50%;margin-left: 5px;display: none;">';
				popupHtml += '					<input type="button" class="AXButton" onclick="document.getElementById(\'STAMP_oFile\').click();" value="등록">';
				popupHtml += '					<input id="STAMP_delBtn" style="display:none;" type="button" class="AXButton" onclick="imgUpload_del(\'STAMP\');" value="삭제">';
				popupHtml += '					<input type="file" id="STAMP_oFile" onchange="imgUpload(this.value,\'STAMP\');" style="width:0px;filter:alpha(opacity:\'0\');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png">';
				popupHtml += '				</td>';
				popupHtml += '			</tr>';
				popupHtml += '		</table>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				break;
			case "R": // 조회
				/* popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskType"/></th>'; // 단위업무 유형
				popupHtml += '	<td style="padding: 5px;">';
				popupHtml += '		<span class="radioStyle04 size">';
				popupHtml += '			<input type="radio" id="radio_IC" name="unitTaskType" value="IC" ischeck="N">';
				popupHtml += '			<label for="radio_IC">';
				popupHtml += '				<span>';
				popupHtml += '					<span></span>';
				popupHtml += '				</span>';
				popupHtml += '				<spring:message code="Cache.lbl_uniqueWork"/>'; // 고유업무
				popupHtml += '			</label>';
				popupHtml += '		</span>';
				popupHtml += '		<br>';
				popupHtml += '		<span class="radioStyle04 size">';
				popupHtml += '			<input type="radio" id="radio_ZZ" name="unitTaskType" value="ZZ" ischeck="N">';
				popupHtml += '			<label for="radio_ZZ">';
				popupHtml += '				<span>';
				popupHtml += '					<span></span>';
				popupHtml += '				</span>';
				popupHtml += '				<spring:message code="Cache.lbl_ProcessingCommonTask"/>'; // 처리과 공통업무
				popupHtml += '			</label>';
				popupHtml += '		</span>';
				popupHtml += '		<br>';
				popupHtml += '		<span class="radioStyle04 size">';
				popupHtml += '			<input type="radio" id="radio_ZA" name="unitTaskType" value="ZA" ischeck="N">';
				popupHtml += '			<label for="radio_ZA">';
				popupHtml += '				<span>';
				popupHtml += '					<span></span>';
				popupHtml += '				</span>';
				popupHtml += '				<spring:message code="Cache.lbl_orgCommonTask"/>'; // 기관 공통업무
				popupHtml += '			</label>';
				popupHtml += '		</span>';
				popupHtml += '	</td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_apv_ManageDept"/></th>'; // 처리과
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_Path" /></th>'; // 경로
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskName"/></th>'; // 단위업무명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_unitTaskDescription"/></th>'; // 단위업무 설명
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriod"/></th>'; // 보존기간
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPeriodReason"/></th>'; // 보존기간 책정사유
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationMethod"/></th>'; // 보존방법
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>';
				popupHtml += '<tr>';
				popupHtml += '	<th><spring:message code="Cache.lbl_preservationPlace"/></th>'; // 보존장소
				popupHtml += '	<td style="padding: 10px 0px 10px 5px;"></td>';
				popupHtml += '</tr>'; */
				break;
		}
		
		$(".middle table tbody").html(popupHtml);
		
		$("#btnSave").off("click").on("click", function(){
			checkValidation();
		});
		
		if(mode != "I"){
			setData();
		}else{
			$("#btnSave").show();
			$("#btnCancel").show();
		}
		
		document.getElementById("registImageTR").style.display = "";
	}
	
	function setData(){
		$.ajax({
			url: "/approval/user/getSenderMasterData.do",
			type: "POST",
			data: {
				"senderID": senderID
			},
			success: function(data){
				var Data = data.list[0];
				
				if(mode == "M"){
					$("#SENDER_TYPE").val(Data.SENDER_TYPE);
					$("#DEPT_NAME").val(Data.DEPT_NAME);
					$("#DEPT_CODE").val(Data.DEPT_CODE);
					$("#DISPLAY_NAME").val(Data.DISPLAY_NAME);
					$("#USAGE_STATE").val(Data.USAGE_STATE).prop("selected",true);
					$("#OUNAME").val(Data.OUNAME);
					$("#NAME").val(Data.NAME);
					$("#CAMPAIGN_T").val(Data.CAMPAIGN_T);
					$("#CAMPAIGN_F").val(Data.CAMPAIGN_F);
					$("#HOMEPAGE").val(Data.HOMEPAGE);
					$("#EMAIL").val(Data.EMAIL);
					$("#TEL").val(Data.TEL);
					$("#FAX").val(Data.FAX);
					$("#ZIP_CODE").val(Data.ZIP_CODE);
					$("#ADDRESS").val(Data.ADDRESS);
					if(Data.LOGO != null && Data.LOGO != "") { mapTypeImage("LOGO", Data.LOGO); }
					if(Data.SYMBOL != null && Data.SYMBOL != "") { mapTypeImage("SYMBOL", Data.SYMBOL); }
					if(Data.STAMP != null && Data.STAMP != "") { mapTypeImage("STAMP", Data.STAMP); }
					
					$("#btnSave").show();
					$("#btnCancel").show();
				}else if(mode == "R"){
					/* var trObj = $(".middle table tbody tr");
					
					$("input[type=radio]").prop("disabled", true);
					$("label[for^=radio_]>span").attr("style", "background-color: #fff !important;");
					$("#radio_" + seriesData.SeriesCode.substr(0, 2)).prop("checked", true);
					trObj.eq(1).find("td").text(seriesData.DeptName);
					trObj.eq(2).find("td").text(seriesPath);
					trObj.eq(3).find("td").text(seriesData.SeriesName);
					trObj.eq(4).find("td").text(seriesData.SeriesDescription);
					trObj.eq(5).find("td").text(seriesData.KeepPeriodTxt);
					trObj.eq(6).find("td").text(seriesData.KeepPeriodReason);
					trObj.eq(7).find("td").text(seriesData.KeepMethodTxt);
					trObj.eq(8).find("td").text(seriesData.KeepPlaceTxt); */
					
					$("#btnClose").show();
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
	
	function mapTypeImage(type, dataType) {
	    var src = coviCmn.loadImageId(dataType,"ApprovalSender"+type);
	    
		$("#"+type).attr("src", src).attr("width","93px").attr("height","93px");
		$("#hid"+type).val(dataType);
		$("#"+type+"_delBtn").show();
	}
	
	function checkValidation(){
		var SENDER_TYPE = $("#SENDER_TYPE").val();
		var DEPT_NAME = $("#DEPT_NAME").val();
		var DEPT_CODE = $("#DEPT_CODE").val();
		var DISPLAY_NAME = $("#DISPLAY_NAME").val();
		var USAGE_STATE = $("#USAGE_STATE option:selected").val();
		var OUNAME = $("#OUNAME").val();
		var NAME = $("#NAME").val();
		var TEL = $("#TEL").val();
		var FAX = $("#FAX").val();
		var HOMEPAGE = $("#HOMEPAGE").val();
		var EMAIL = $("#EMAIL").val();
		var ZIP_CODE = $("#ZIP_CODE").val();
		var ADDRESS = $("#ADDRESS").val();
		var CAMPAIGN_T = $("#CAMPAIGN_T").val();
		var CAMPAIGN_F = $("#CAMPAIGN_F").val();
		var LOGO = $("#hidLOGO").val();
		var SYMBOL = $("#hidSYMBOL").val();
		var STAMP = $("#hidSTAMP").val();
		
		// 빈 값 체크
		if(!SENDER_TYPE){
			Common.Warning("구분을 선택해주세요.");
			return false;
		}
		if(!DEPT_NAME || !DEPT_CODE){
			if(SENDER_TYPE == "C") Common.Warning("회사를 선택해주세요.");
			if(SENDER_TYPE == "D") Common.Warning("부서를 선택해주세요.");
			return false;
		}
		if(!DISPLAY_NAME){
			Common.Warning("표시이름을 입력해주세요.");
			return false;
		}
		if(!OUNAME){
			Common.Warning("기관명을 입력해주세요.");
			return false;
		}
		if(!NAME){
			Common.Warning("기관장명을 입력해주세요.");
			return false;
		}
		
		// 값 형식 체크
		if(ZIP_CODE.match(/[^0-9]/g) != undefined){
			if(ZIP_CODE.match(/[^0-9]/g).length > 0) {
				Common.Inform("우편번호는 숫자만 입력가능합니다.");
				return false;
			}
		}
		
		
		var params = {
			"SENDER_TYPE": SENDER_TYPE,
			"DEPT_NAME": DEPT_NAME,
			"DEPT_CODE": DEPT_CODE,
			"DISPLAY_NAME": DISPLAY_NAME,
			"USAGE_STATE": USAGE_STATE,
			"OUNAME": OUNAME,
			"NAME": NAME,
			"TEL": TEL,
			"FAX": FAX,
			"HOMEPAGE": HOMEPAGE,
			"EMAIL": EMAIL,
			"ZIP_CODE": ZIP_CODE,
			"ADDRESS": ADDRESS,
			"CAMPAIGN_T": CAMPAIGN_T,
			"CAMPAIGN_F" : CAMPAIGN_F,
			"LOGO" : LOGO,
			"SYMBOL" : SYMBOL,
			"STAMP" : STAMP
		}
		
		saveSenderMaster(params);
	}
	
	function saveSenderMaster(params){
		var url = "";
		
		var formData = new FormData();
		formData.append('SENDER_TYPE', params.SENDER_TYPE);
		formData.append('DEPT_NAME', params.DEPT_NAME);
		formData.append('DEPT_CODE', params.DEPT_CODE);
		formData.append('DISPLAY_NAME', params.DISPLAY_NAME);
		formData.append('USAGE_STATE', params.USAGE_STATE);
		formData.append('OUNAME', params.OUNAME);
		formData.append('NAME', params.NAME);
		formData.append('TEL', params.TEL);
		formData.append('FAX', params.FAX);
		formData.append('HOMEPAGE', params.HOMEPAGE);
		formData.append('EMAIL', params.EMAIL);
		formData.append('ZIP_CODE', params.ZIP_CODE);
		formData.append('ADDRESS', params.ADDRESS);
		formData.append('CAMPAIGN_T', params.CAMPAIGN_T);
		formData.append('CAMPAIGN_F', params.CAMPAIGN_F);
		formData.append('LOGO', params.LOGO);
		formData.append('SYMBOL', params.SYMBOL);
		formData.append('STAMP', params.STAMP);
		
		if(mode == "I"){
			url = "/approval/user/insertSenderMasterData.do";
		}else{
			url = "/approval/user/modifySenderMasterData.do";
			formData.append('senderID', senderID);
		}
		
		$.ajax({
			url: url,
			type: "post",
			data: formData,
			dataType : 'json',
			processData : false,
			 contentType : false,
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform(data.message, "Information", function(result){
						if(result){
							Common.Close();
							parent.Refresh();
						}
					});
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
	
	function imgUpload(obj, type) {
        var check_result = fileFindCheck(type);
        if (check_result == true) {
            var url = document.getElementById(type+"_oFile");
            document.getElementById(type+'_fileurl').value = url.value;
	        if (url.value != null) {
	            if (url.files && url.files[0]) {
	            	var reader = new FileReader();
	            	reader.onload = function (e) {
	            		$('#'+type).attr('src', e.target.result).attr("width","93px").attr("height","93px");
	            		$("#"+type+"_delBtn").show();
	            	}
	            	reader.readAsDataURL(url.files[0]);
	            	insertImgUpload(type);
	            }
	        }
        }
    }
    
    function fileFindCheck(type) {
        var file = document.getElementById(type+"_oFile");
        var filename = file.files.item(0).name;
        var fileUrlexe = file.files.item(0).name.split('.');
        var filerealname = filename.substring(0,filename.lastIndexOf(".")); 
        if(filerealname.indexOf("_") >=0 ){
            Common.Warning('파일명에 "_"를 사용할 수 없습니다.');		//파일명에 "_"를 사용할 수 없습니다.
            return false;                                
        }        
        if(filerealname.lenth>20){
        	 Common.Warning("파일명은 20자 이내로 작성하여 주십시요.");		//파일명은 20자 이내로 작성하여 주십시요.
             return false;    
        }
        
        if (fileUrlexe[fileUrlexe.length - 1] != 'gif' && fileUrlexe[fileUrlexe.length - 1] != 'jpg' && fileUrlexe[fileUrlexe.length - 1] != 'bmp'&& fileUrlexe[fileUrlexe.length - 1] != 'png') {
            Common.Warning("지원하지 않는 확장자입니다.");		//지원하지 않는 확장자입니다.
            document.getElementById('hid'+type).value = "";
            document.getElementById(type+'_fileurl').value = "";
            return false;
        }
        return true;
    }
    
    function insertImgUpload(type) {
    	var formData = new FormData();
		formData.append('MyFile', $('#'+type+'_oFile')[0].files[0]);
		formData.append('serviceType', 'ApprovalSender' + type);
		
		 $.ajax({
           type : 'post',
           url : '/approval/user/insertImgUploadData.do',
           data : formData,
           dataType : 'json',
	        processData : false,
	        contentType : false,
           success : function(data){
        	   if(data.status == "SUCCESS") {
        	        Common.Inform("<spring:message code='Cache.msg_insert'/>","<spring:message code='Cache.lbl_apv_Regisign'/>");
                  	$('#hid'+type).val(data.fileID);
        	   }
           },
           error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/insertUserSign.do", response, status, error);
			}
       });
    }
    
    function imgUpload_del(type) {
    	$('#hid'+type).val('');
    	$('#'+type + '_fileurl').val('');
    	$('#'+type + '_ofile').val('');
		$("#"+type+"_delBtn").hide();
		$('#'+type).attr('src', "/covicore/resources/images/no_image.jpg").attr("width","95px").attr("height","80px");
		
    	/* $.ajax({
			url: "/approval/user/deleteImgUploadData.do",
			type: "post",
			data: { 
				'type' : type,
				'senderID' : senderID,
				'fileID' : $('#hid'+type).val()
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform(data.message, "Information", function(result){
						$('#hid'+type).val('');
						$("#"+type+"_delBtn").hide();
						$('#'+type).attr('src', "/covicore/resources/images/no_image.jpg").attr("width","95px").attr("height","80px");
					});
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		}); */
    }
    
	function goOrgChartPopup(){
		var option = {
				callBackFunc : "callBackOrgPopup",
				type:"C1",
				treeKind:"Dept",
				checkboxRelationFixed:"true"
		};
		
		coviCmn.openOrgChartPopup(encodeURIComponent(CFN_GetDicInfo(g_aclVariables.dictionary.lbl_DeptOrgMap, g_aclVariables.lang)), "C1", option);
	}
	
	function callBackOrgPopup(result) {
		if (result != null && result != undefined) {
			var resultJson = $.parseJSON(result);
			if ('item' in resultJson) {
				var item = resultJson.item[0];
				if(item.GroupType == "Company") $('#SENDER_TYPE').val('C');
				else $('#SENDER_TYPE').val('D');
				$('#DEPT_NAME').val(CFN_GetDicInfo(item.DN));
				$('#DEPT_CODE').val(item.GroupCode);
				return;
			}
		}
		
		Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
	}
	
	function changeSenderType() {
		$('#DEPT_NAME, #DEPT_CODE').val('');
	}
    
</script>