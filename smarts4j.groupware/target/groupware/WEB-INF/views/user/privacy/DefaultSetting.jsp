<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
	boolean UsePWCheckPage = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("loginAuthType")).equals("Unify") ? true : false;
	
	// for AES ecryption
	String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt"));
	String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv"));
	String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize"));
	int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount")));
	int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase")));
%>
<% if("R".equals(cryptoType)){ %>
	<script type="text/javascript" src="/covicore/resources/script/security/jsbn.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/rsa.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/prng4.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/rng.js<%=resourceVersion%>"></script>
<% }else if("A".equals(cryptoType)){ %>
	<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
<% }%>
<input type="hidden" id="rsaPublicKeyModulus" value="">
<input type="hidden" id="rsaPublicKeyExponent" value="">
<div id="pwChkDiv"></div>           
<div id="infoDiv" style="display:none;">        
	<div class="cRConTop titType">
		<h2 class="title"><spring:message code="Cache.lbl_baseInfo"/></h2> <!-- 기본정보 -->
	</div>
	<div class="cRContBottom mScrollVH">
		<div class="myInfoContainer" id="myInfoContainerDiv">
		</div>
	</div>
</div>

<form id="frm">
	<input type="hidden" id="googleMail">
</form>	
<script type="text/javascript" src="/groupware/resources/script/user/privacy.js<%=resourceVersion%>"></script>
<script type="text/javascript">
	var cryptoType = "<%=cryptoType%>";
	var privacyInfo = null;
	var params = new Object();
	
	// 달력 옵션
	var timeInfos = {
		width : '200', //기본값은 100 [필수항목X]
		H : "", //시간 선택
		W : "1", //주 선택
		M : "1", //달 선택
		Y : "1" //년도 선택
	};
	var initInfos = {
		height : '300', //그려지는 모든 select box의 길이
		width : '100',   //시간 picker에 대한 사이즈 값 기본값은 100 [필수 X]
		useCalendarPicker : 'Y',
		useTimePicker : 'N',
		useBar : 'N',
		useSeparation : 'N',
		minuteInterval : 5,  //만약, 60의 약수가 아닌 경우, 그려지지 않음.
		use59 : 'Y'
	};
	
	// 자동완성 옵션
	var autoInfos = {
		labelKey : 'UserName',
		valueKey : 'UserCode',
		minLength : 1,
		useEnter : false,
		multiselect : true,
    	select : function(event, ui) {
    		if ($('#autoCompleteDiv').find('.ui-autocomplete-multiselect-item').length > 0) {
    			Common.Warning("<spring:message code='Cache.msg_selectAfterDelete'/>"); //삭제 후 선택해주세요.
				ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
				return;
			}
    		
    		var id = $(document.activeElement).attr('id');
    		var item = ui.item;
    		var cloned = orgMapDivEl.clone();
			cloned.attr('type', 'UR').attr('code', item.UserCode);
			cloned.find('.ui-icon-close').before(item.label);

			$('#' + id).before(cloned);
			
	    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
    	}			
	};
	
	initContent();
	
	// 개인환경설정 > 기본정보
	function initContent() {
		
		Common.getBaseConfigList(["ProfileImagePath", "useTimeZone", "ImageLoadURL"]);
		
		if(cryptoType == "R"){
			cryptoTypeCheck();
		}
		
		if(<%=UsePWCheckPage%>){	
			getUserPrivacySetting();
		}else{
			setPwHtml();
		}
	}
	
	function getUserPrivacySetting() {
		var nowPassword = ""; 
		
		if(cryptoType == "R"){
			var rsaPublicKeyModulus = $("#rsaPublicKeyModulus").val();
			var rsaPublicKeyExponent = $("#rsaPublicKeyExponent").val();
			
			nowPassword = fnRsaEnc($("#nowPassword").val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			
		}else if(cryptoType == "A"){
			 var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
			 
			 nowPassword = aesUtil.encrypt("<%=as%>", "<%=aI%>", "<%=app%>", $("#nowPassword").val());
				
		}else{
			nowPassword = $("#nowPassword").val();
		}
		
		var url = "/groupware/privacy/getUserPrivacySetting.do";
		$.ajax({
			type : "POST",
			data : {id : Common.getSession("LogonID"), nowPassword : nowPassword},
			async: false,
			url : url,
			success:function (list) {
				if (list.status == 'SUCCESS') {
					privacyInfo = $.extend(true, {}, list.data[0]);
					
					setSetting();	// 초기 세팅
					setInfoHtml();	// 정보 html
					
					$('#pwChkDiv').css('display','none');
					$('#infoDiv').css('display','');
				} else if(list.status == 'NOT_ALLOW'){
					Common.Warning(list.message);
				}else{	
					Common.DetailErrPwMsg("<spring:message code='Cache.msg_OccurError'/>"+"<br/><br/>"+list.message,"Detail Info","Password Change");
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
	    var rsa = new RSAKey();

	    rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
	    var encValue = rsa.encrypt(value)
	    
	    return encValue;

	}
	
	function cryptoTypeCheck(){
		var url = "/groupware/privacy/cryptoTypeCheck.do";
		$.ajax({
			type : "POST",
			async: false,
			url : url,
		 	success: function(data) {
		 		$("#rsaPublicKeyModulus").val(data.publicKeyModulus);  
		 		$("#rsaPublicKeyExponent").val(data.publicKeyExponent);    
            },
            error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	$("#nowPassword").keypress(function(){
		if (event.keyCode==13){ 
			if($('#nowPassword').val() != ""){
				getUserPrivacySetting();
			}
		}
	});
	
	// 비밀번호 확인 html
	function setPwHtml() {
		$('#pwChkDiv').empty();
		
		var html = '<div class="cRConTop titType">';
		html += '<h2 class="title"><spring:message code="Cache.lbl_PasswordChange_03"/></h2>'; //비밀번호 재확인
		html += '</div>';
		html += '<div class="cRContBottom mScrollVH">';
		html += '<div class="myInfoContainer myInfoPassWordCont reconfirm">';
		html += '<div class="mt70 myInfoPassWordModify"><input type="password" id="nowPassword" placeholder="' + '<spring:message code="Cache.lbl_PasswordChange_01"/>' + '"></div>'; //현재 비밀번호
		html += '<div class="mt10 myInfoPassWordModify"><button href="#" id="" class="btnType01" onclick="getUserPrivacySetting();"><spring:message code="Cache.lbl_Confirm"/></button></div>'; //확인
		html += '<p class="mt70">';
		html += '<span class="blueStart">';
		html += '<spring:message code="Cache.msg_PrivacyCheckPassword"/></span>'; 
		html += '</p>';
		html += '</div>';
		html += '</div>';
		
		$('#pwChkDiv').append(html);
	}
	
	// 정보 html
 	function setInfoHtml() {
		$('#myInfoContainerDiv').empty();
		
		var html = '<div style="display:none;">';
		html += '<input type="text" id="userId" value="' + privacyInfo.UserID  + '">';
		html += '<input type="text" id="userCode" value="' + privacyInfo.UserCode  + '">';
		html += '<input type="text" id="photoFileId" value="">';
		html += '<input type="text" id="updateFileId" value="';
		if (typeof(privacyInfo.updateFileId) != 'undefined') html += privacyInfo.updateFileId;
		html += '">';
		html += '<input type="text" id="deleteFileId" value="">';
		html += '</div>';
		html += '<div class="myInfoContBox">';
		html += '<div class="myInfoProfile">';
		
		if (typeof(privacyInfo.updateFilePath) == 'undefined' || privacyInfo.updateFilePath == '') {
			// 23.09.18 : noimg.png 이미지 경로 수정.
			html += '<span><img src="/covicore/resources/images/common/noimg.png" id="myImg"></span>';
		} else {
			html += '<span><img src="' + coviCmn.configMap.ImageLoadURL + encodeURIComponent(privacyInfo.updateFilePath) + '&time=' + new Date().getTime() + '"  onerror="coviOrg.imgError(this);"  id="myImg"></span>';
//			html += '<span><img src="' + privacyInfo.updateFilePath + '?time=' + new Date().getTime() + '"  onerror="coviOrg.imgError(this);"  id="myImg"></span>';
		}
  		
		html += '<a href="#" class="bntMyInfoOption"></a>';
		html += '</div>'; 
		html += '<div class="myInfoData">'; 
		html += '<h3>' + CFN_GetDicInfo(privacyInfo.MultiDisplayName);
		if (typeof(privacyInfo.MultiJobPositionName) != 'undefined') html += ' ' + CFN_GetDicInfo(privacyInfo.MultiJobPositionName);
		if (typeof(privacyInfo.MultiJobTitleName) != 'undefined') html += '/' + CFN_GetDicInfo(privacyInfo.MultiJobTitleName);
		html += '</h3>';
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_Company"/></span></div>'; //회사			
		html +=	'<div>';
		html += '<p class="textBox">' + CFN_GetDicInfo(privacyInfo.MultiCompanyName) + '</p>';
		html += '</div>';
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';			
		html += '<div><span><spring:message code="Cache.lbl_dept"/></span></div>'; //부서
		html += '<div>';
		html += '<p class="textBox">' + CFN_GetDicInfo(privacyInfo.MultiDeptName) + '</p>';
		html += '</div>';
		html += '</div>';		
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_Mail"/></span></div>'; //메일
		html += '<div>';
		html += '<p class="textBox">';
		if (typeof(privacyInfo.MailAddress) != 'undefined') html += privacyInfo.MailAddress;
		html += '</p>';
		html += '</div>';			
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';	
		html += '<div><span><spring:message code="Cache.lbl_MyInfo_08"/></span></div>'; //생년월일
		html += '<div class="divList">';
		html += '<div><input id="birthDateCalendarPicker" style="width: 110px" kind="date" type="text" data-axbind="date" date_separator="."></div>';
		if (privacyInfo.BirthDiv == 'L') {
			html += '<div class="radioStyle04 inpBtnStyle">';	
			html += '<input type="radio" id="rd01" name="rdAll" value="S" onclick="javascript:changeDateDiv(this);"><label for="rd01"><span><span></span></span><spring:message code="Cache.lbl_Solar"/></label>'; //양력
			html += '</div>';
			html += '<div class="radioStyle04 inpBtnStyle">';
			html += '<input type="radio" id="rd02" name="rdAll" value="L" onclick="javascript:changeDateDiv(this);" checked><label for="rd02"><span><span></span></span><spring:message code="Cache.lbl_Lunar"/></label>'; //음력
			html += '</div>';			
		} else {
			html += '<div class="radioStyle04 inpBtnStyle">';	
			html += '<input type="radio" id="rd01" name="rdAll" value="S" onclick="javascript:changeDateDiv(this);" checked><label for="rd01"><span><span></span></span><spring:message code="Cache.lbl_Solar"/></label>'; //양력
			html += '</div>';
			html += '<div class="radioStyle04 inpBtnStyle">';
			html += '<input type="radio" id="rd02" name="rdAll" value="L" onclick="javascript:changeDateDiv(this);"><label for="rd02"><span><span></span></span><spring:message code="Cache.lbl_Lunar"/></label>'; //음력
			html += '</div>';	
		}
		/* html += '<div class="dateSel type02">'; */
		/* html += '<input class="adDate" type="text" readonly=""><a class="icnDate" href="#">날짜선택</a>'; */
		
		/* html += '</div>'; */
		html += '</div>';
		html += '</div>';			
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_MyInfo_11"/></span></div>'; //외부메일			
		html += '<div>';
		html += '<input type="text" id="externalMailAddress" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.ExternalMailAddress) != 'undefined') html += privacyInfo.ExternalMailAddress;
		html += '">';			
		html += '</div>';
		html += '</div>';	
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_MyInfo_12"/></span></div>'; //핸드폰	
		html += '<div>';
		html += '<input type="text" id="mobile" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.Mobile) != 'undefined') html += privacyInfo.Mobile;	
		html += '">';
		html += '</div>';
		html += '</div>';			
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_MyInfo_14"/></span></div>'; //팩스	
		html += '<div>';
		html += '<input type="text" id="fax" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.Fax) != 'undefined') html += privacyInfo.Fax;
		html += '">';			
		html += '</div>';
		html += '</div>';	
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lblOfficeCall"/></span></div>';	//내선번호
		html += '<div>';
		html += '<input type="text" id="phoneNumberInter" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.PhoneNumberInter) != 'undefined') html += privacyInfo.PhoneNumberInter;
		html += '">';		
		html += '</div>';
		html += '</div>';			
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_PhoneNum"/></span></div>';	//전화번호
		html += '<div>';
		html += '<input type="text" id="phoneNumber" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.PhoneNumber) != 'undefined') html += privacyInfo.PhoneNumber;
		html += '">';			
		html += '</div>';
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lbl_Role"/></span></div>';	//담당업무
		html += '<div>';
		html += '<input type="text" id="chargeBusiness" class="HtmlCheckXSS ScriptCheckXSS" value="';
		if (typeof(privacyInfo.ChargeBusiness) != 'undefined') html += privacyInfo.ChargeBusiness;
		html += '">';			
		html += '</div>';	
		html += '</div>';
		
		if(coviCmn.configMap.useTimeZone == "Y"){
			html += '<div class="inputBoxSytel01 type02">';
			html += '<div><span><spring:message code="Cache.lbl_TimeZone"/></span></div>';	//표준 시간대
			html += '<div id="selectTimeZone">';
			html += '</div>';
			html += '</div>';	
		}
		
		html += '</div>';
		
		html += '<div class="myInfoDataBtn mt25">';			
		html += '<a href="#" class="btnTypeDefault btnTypeChk" onclick="updateUserInfo()"><spring:message code="Cache.btn_save"/></a>'; //저장
		html += '</div>';	
		html += '</div>';
		
		if(chkUseGoogleSchedule(Common.getSession("DN_ID")) == 'Y'){
			html += '<div class="myInfoContBox">';			
			html += '<div class="myInfoData">';
			html += '<h3><spring:message code="Cache.lbl_MyInfo_GoogleAccountSet"/></h3>'; //구글계정 설정	
			html += '<div class="inputBoxSytel01 type02">';
			html += '<div><span><spring:message code="Cache.lbl_MyInfo_GoogleAccount"/></span></div>';	//구글계정		
			html += '<div>';
			if (typeof(privacyInfo.Mail) == 'undefined' || privacyInfo.Mail == '') {
				html += '<p class="textBox"><spring:message code="Cache.lbl_Unregistered"/></p>'; //미등록
			} else {
				html += '<p class="textBox">' + privacyInfo.Mail + ' <button class="btnLnbFavoriteRemove" onclick="removeGmail()"></button></p>';
			}
			/* html += '<input type="text" id="mail" placeholder="미등록" value="' + privacyInfo.Mail + '">'; */
			html += '</div>';
			html += '</div>';	
			html += '</div>';
			html += '<div class="myInfoDataBtn mt25">';			
			html += '<a href="#" class="btnTypeDefault btnTypeChk" onclick="updateGoogleAccount()"><spring:message code="Cache.lbl_Regist"/></a>'; //등록
			html += '</div>';	
			html += '</div>';
		}
		
		html += '<div class="myInfoContBox">';	
		html += '<div class="myInfoData">';
		html += '<div class="alarm type01 myInfoDataTitle">';			
		html += '<span><spring:message code="Cache.lbl_AbsenceSetting"/></span>'; //부재설정
		if (typeof(privacyInfo.AbsenseUseYN) != 'undefined' && privacyInfo.AbsenseUseYN == 'Y') {
			html += '<a href="#" class="onOffBtn on" id="absenseUseYn"><span></span></a>';	
		} else {
			html += '<a href="#" class="onOffBtn" id="absenseUseYn"><span></span></a>';
		}
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';	
		html += '<div><span><spring:message code="Cache.lbl_AbsentType"/></span></div>'; //부재유형
		html += '<div>';			
		html += '<select class="selectType02 size102" id="absenseType">';
		html += '<option value=""><spring:message code="Cache.lbl_Select"/></option>'; //선택
		if (typeof(privacyInfo.AbsenseType) != 'undefined') {
			if (privacyInfo.AbsenseType == '1') {
				html += '<option value="1" selected><spring:message code="Cache.AbsenseType_1"/></option>'; //휴가
				html += '<option value="2"><spring:message code="Cache.AbsenseType_2"/></option>'; //출장
			} else {
				html += '<option value="1"><spring:message code="Cache.AbsenseType_1"/></option>'; //휴가
				html += '<option value="2" selected><spring:message code="Cache.AbsenseType_2"/></option>'; //출장
			}
		} else {
			html += '<option value="1"><spring:message code="Cache.AbsenseType_1"/></option>'; //휴가
			html += '<option value="2"><spring:message code="Cache.AbsenseType_2"/></option>'; //출장
		}
		html += '</select>';
		html += '</div>';
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';
		html += '<div><span><spring:message code="Cache.lblAbsentTerm"/></span></div>'; //부재기간
		html += '<div>';			
/* 		html += '<div class="dateSel type02">';
		html += '<input class="adDate" type="text" readonly=""><a class="icnDate" href="#">날짜선택</a>';
		html += '<span>-</span>';
		html += '<input class="adDate" type="text" readonly=""><a class="icnDate" href="#">날짜선택</a>';			
		html += '</div>'; */
		html += '<div class="dateSel type02" id="absenseTermCalendarPicker"></div>';
		html += '</div>';
		html += '</div>';
		html += '<div class="inputBoxSytel01 type02">';			
		html += '<div><span><spring:message code="Cache.lbl_AbsentDuty"/></span></div>'; //부재시 대리자
		html += '<div>';		
		html += '<div class="autoCompleteCustom" id="autoCompleteDiv">';
		html += '<input id="myAutocompleteMultiple" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 60px)" autocomplete="off">';			
		html += '<a href="#" class="btnTypeDefault" onclick="openOrgMapLayerPopup()"><spring:message code="Cache.lbl_DeptOrgMap"/></a>';	 //조직도
		html += '</div>';
		html += '</div>';
		html += '</div>';	
		html += '<div class="inputBoxSytel01 type02">';			
		html += '<div><span><spring:message code="Cache.lblAbsentReason"/></span></div>'; //부재사유
		html += '<div>';
		if (typeof(privacyInfo.AbsenseType) != 'undefined') {
			html += '<textarea id="absenseReason" class="HtmlCheckXSS ScriptCheckXSS">' + privacyInfo.AbsenseReason + '</textarea>';			
		} else {
			html += '<textarea id="absenseReason" class="HtmlCheckXSS ScriptCheckXSS"></textarea>';
		}
		html += '</div>';
		html += '</div>';			
		html += '</div>';			
		html += '<div class="myInfoDataBtn mt25">';
		html += '<a href="#" class="btnTypeDefault btnTypeChk" onclick="updateUserAbsense()"><spring:message code="Cache.btn_Apply"/></a>'; //적용	
		html += '</div>';			
		html += '</div>';
		
	
		$('#myInfoContainerDiv').append(html);
		
		coviCtrl.setCustomAjaxAutoTags('myAutocompleteMultiple', '/covicore/control/getAllUserAutoTagList.do', autoInfos);	// 부재시 대리자 자동완성
		$('#myAutocompleteMultiple').parent().css('width', 'calc(100% - 67px)');
		if (privacyInfo.absenseDutyText != '' && privacyInfo.absenseDutyText != undefined) {
			var cloned = orgMapDivEl.clone().attr('type', 'UR').attr('code', privacyInfo.absenseDutyText.split(';')[0]);
			cloned.find('.ui-icon-close').before(privacyInfo.absenseDutyText.split(';')[1]);
		
			$('#myAutocompleteMultiple').before(cloned);
		}
		
		var birthDate = privacyInfo.BirthDate;
		if(birthDate.length > 8){
			birthDate = birthDate.replace(/-/g, '.');
		}else if(birthDate.length == 8){
			birthDate = birthDate.substring( 0, 4) + "."+ birthDate.substring( 4, 6) +"."+ birthDate.substring( 6, 8) ;
		}else{
			birthDate = "";
		}
		
		if (privacyInfo.BirthDiv == 'L'){
			initLeapMonth($('input:radio[name=rdAll]:input[value=L]'));
			$("#leapMonth").prop("checked", (privacyInfo.IsBirthLeapMonth == 'Y'));
		}
		
		coviCtrl.renderDateSelect('absenseTermCalendarPicker', timeInfos, initInfos);	// 부재기간
		if (typeof(privacyInfo.AbsenseTermStart) != 'undefined') $('#absenseTermCalendarPicker_StartDate').val(privacyInfo.AbsenseTermStart);
		if (typeof(privacyInfo.AbsenseTermEnd) != 'undefined') $('#absenseTermCalendarPicker_EndDate').val(privacyInfo.AbsenseTermEnd);
	
		$("#birthDateCalendarPicker").val(birthDate);
		
		if(coviCmn.configMap.useTimeZone == "Y"){
			var timeZoneInfos = [
		   		{
			   		target : 'selectTimeZone',				
			   		codeGroup : 'TimeZone',					
			   		hasGroupCode: "N",
			   		defaultVal : Common.getSession('UR_TimeZoneCode'),
			   		width: "auto"
		   		}
		   	];
			coviCtrl.renderAjaxSelect(timeZoneInfos, "", Common.getSession("lang"));
		}
	
	}
	
	// 조직도 팝업
	function openOrgMapLayerPopup() {
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=A1","520px","580px","iframe",true,null,null,true);
	}
	
	// 조직도 팝업 콜백
	function orgMapLayerPopupCallBack(orgData) {
		var data = $.parseJSON(orgData);
		var item = data.item
		var len = item.length;
		
		if (item != '') {	
			if (item[0].itemType == 'user') {
				if ($('#autoCompleteDiv').find('.ui-autocomplete-multiselect-item').length > 0) {				
					$('#autoCompleteDiv').find('.ui-autocomplete-multiselect-item').remove();
				}
				
				var cloned = orgMapDivEl.clone();
				cloned.attr('type', 'UR').attr('code', item[0].UserCode);
				cloned.find('.ui-icon-close').before(CFN_GetDicInfo(item[0].DN));
				
				$('#autoCompleteDiv .ui-autocomplete-input').before(cloned);
			} else {
				Common.Warning('<spring:message code="Cache.lbl_apv_alert_userselect"/>'); //사용자를 선택하십시오.
				return;
			}
			
		}
	}
	
	// 기본정보 수정
	function updateUserInfo() {
		params = new Object();
		params.userId = $('#userId').val();
		params.userCode = $('#userCode').val();		
		params.birthDiv = $('input[name=rdAll]:checked').val();
		params.birthDate = $("#birthDateCalendarPicker").val();
		params.externalMailAddress = $('#externalMailAddress').val();
		params.mobile = $('#mobile').val();
		params.fax = $('#fax').val();
		params.phoneNumberInter = $('#phoneNumberInter').val();
		params.phoneNumber = $('#phoneNumber').val();
		params.chargeBusiness = $('#chargeBusiness').val();
		params.photoFileId = $('#photoFileId').val();
		params.deleteFileId = $('#deleteFileId').val();
		if(coviCmn.configMap.useTimeZone == "Y"){
			params.timeZoneCode = coviCtrl.getSelected('selectTimeZone').val;
		}
		
		if (params.birthDiv == 'L'){
			params.isBirthLeapMonth = ($("#leapMonth").prop("checked")) ? 'Y' : 'N';
		}
		
// 		if(params.birthDate != null && params.birthDate != ""){
// 			var date_pattern = /^(19|20)\d{2}.(0[1-9]|1[012]).(0[1-9]|[12][0-9]|3[0-1])$/; 

// 			if(!date_pattern.test(params.birthDate)){
// 				Common.Warning("Can not be represented as date");
// 				return;
// 			}
// 		}
		
		var url = "/groupware/privacy/updateUserInfo.do";
		$.ajax({
			type : "POST",
			data : params,
			async: false,
			url : url,
			success:function (list) {
				Common.Inform('<spring:message code="Cache.msg_Edited"/>'); //수정되었습니다

				//TimeZone관련 sessionStorage 삭제
				localCache.remove("SESSION_all");
				localCache.remove("SESSION_UR_TimeZoneCode");
				localCache.remove("SESSION_UR_TimeZone");
				localCache.remove("SESSION_UR_TimeZoneDisplay");
				
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});		
	}	
	
	// 구글계정 등록
	function updateGoogleAccount() {
		CFN_OpenWindow("/groupware/oauth2/google.do", "", 790, (window.screen.height - 250), "resize");
	}
	
	// 구글계정 콜백
	function googleAuthCallback() {
		Common.Inform('<spring:message code="Cache.msg_Edited"/>'); //수정되었습니다
		
		getUserPrivacySetting();
		
		setInfoHtml();	// 정보 html
	}	
	
	// 부재 설정
	function updateUserAbsense() {
		params = new Object();
		params.userCode = $('#userCode').val();
		params.absenseUseYn = $('#absenseUseYn').hasClass('on') ? 'Y' : 'N';
		params.absenseType = $('#absenseType option:selected').val();
		params.absenseTermStart = $('#absenseTermCalendarPicker_StartDate').val();
		params.absenseTermEnd = $('#absenseTermCalendarPicker_EndDate').val();
		var absenseDuty = $('#autoCompleteDiv').find('.ui-autocomplete-multiselect-item');
		if ($(absenseDuty).length > 0) {
			params.absenseDuty = $(absenseDuty).attr('code');	
		} else {
			params.absenseDuty = '';
		}
		params.absenseReason = $('#absenseReason').val();
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		// 부재설정 여부가 Y 일 경우
		if(params.absenseUseYn == "Y") {
			if($('#absenseTermCalendarPicker_StartDate').val().replaceAll('.','-') == null || $('#absenseTermCalendarPicker_StartDate').val().replaceAll('.','-').trim() == "" 
					|| $('#absenseTermCalendarPicker_EndDate').val().replaceAll('.','-') == null || $('#absenseTermCalendarPicker_EndDate').val().replaceAll('.','-').trim() == "") {
				Common.Warning("<spring:message code='Cache.msg_absensePeriod'/>");
				return;
			}
		}
		
		var url = "/groupware/privacy/updateUserAbsense.do";
		$.ajax({
			type : "POST",
			data : params,
			async: false,
			url : url,
			success:function (list) {
				Common.Inform('<spring:message code="Cache.msg_Edited"/>'); //수정되었습니다
				
				getUserPrivacySetting();
				
				setInfoHtml();	// 정보 html
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});			
	}
	
	//시분 체크
	function timeChk(time, min){
		var flag = true;
		var timeValue = time.val();
		timeValue = timeValue.replace(/[^0-9.]/g, '');
		timeValue = parseFloat(timeValue);
		
		if(isNaN(timeValue)) {
			timeValue = 0;
			time.val("00");
		} else {
			if(timeValue > 24) {
				Common.Inform("24시간을 넘길 수 없습니다.", "알림");
				time.val("00").trigger("focus");
				flag = false;
			}
		}
		
		var minValue = min.val();
		minValue = minValue.replace(/[^0-9.]/g, '');
		minValue = parseFloat(minValue);
		
		if(isNaN(minValue)) {
			minValue = 0;
			min.val("00");
		} else {
			if(minValue > 60) {
				Common.Inform("60분을 넘길 수 없습니다.", "알림");
				min.val("00").trigger("focus");
				flag = false;
			}
		}
		
		return flag;
	}
	
	// 초기 세팅
	function setSetting() {
		var myInfoContainer  = $('.myInfoContainer');
		
		// 사용자나 부서 삭제
		myInfoContainer.on('click', '.ui-icon-close', function(e) {
	    	e.preventDefault();
	    	
	    	$(this).parent().remove();
		});
		
		// 부재설정 on off
		myInfoContainer.on('click', '.onOffBtn', function(e) {
	    	e.preventDefault();
	    	
 			if ($(this).hasClass('on')) {
				$(this).removeClass('on');
			} else {
				$(this).addClass('on');
			}
		});
		
		// 이미지 업로드
 	    myInfoContainer.on('click', '.bntMyInfoOption', function(e) {
			Common.open("","target_pop","<spring:message code='Cache.lbl_image'/> <spring:message code='Cache.lbl_Upload'/>","/groupware/privacy/goImageUploadPopup.do","499px","222","iframe",true,null,null,true);
		}); 
		
	 	// 이미지 클릭
	    myInfoContainer.on('click', 'img', function(e) {
	    	e.preventDefault();

	    	var imgSrc = "";
	    	
	    	if (typeof(privacyInfo.updateFilePath) == 'undefined' || privacyInfo.updateFilePath == '') {
	    		imgSrc = "/covicore/resources/images/common/noimg.png";
	    	} else {
				imgSrc = privacyInfo.updateFilePath.substr(0, privacyInfo.updateFilePath.lastIndexOf(".")) + "_org" 
						+ privacyInfo.updateFilePath.substr(privacyInfo.updateFilePath.lastIndexOf("."));
			}
	    	
	    	coviComment.callImageViewer(coviCmn.loadImage(imgSrc));
	    });		
	}
	
	function removeGmail(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var url = "/groupware/privacy/removeGmail.do"
				$.ajax({
					type : "POST",
					data : {},
					async: false,
					url : url,
					success:function (list) {
						if (list.status == 'SUCCESS') {
							Common.Inform("<spring:message code='Cache.msg_Deleted'/>","Information",function(){
								initContent();	
				    		});
						} else {
							Common.Warning("<spring:message code='Cache.msg_51'/>","Information",function(){
								initContent();	
				    		});
						}			
					},
					error:function(response, status, error) {
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			}
		});
	}
	
	function chkUseGoogleSchedule(domainID){
		var isUseGoogleSchedule = "N";
		var url = "/covicore/domain/get.do"
		$.ajax({
			type: "POST",
			data: {
				"DomainID" : domainID
			},
			async: false,
			url: url,
			success:function (data){
				isUseGoogleSchedule = data.list[0].IsUseGoogleSchedule;
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
			}
		});
		
		return isUseGoogleSchedule;
	}
	
	function changeDateDiv(target){
		if (target.value == 'S'){
			if ($("#leapMonthSpan").length > 0) $("#leapMonthSpan").remove();
		}
		else if (target.value == 'L'){
			if ($("#leapMonthSpan").length == 0) initLeapMonth(target);
		}
	}
	
	function initLeapMonth(target){
		$(target).parent().after(
			'<span class="radioStyle04 size" id="leapMonthSpan">'+
				'<input type="checkbox" id="leapMonth">'+
				'<label for="rrr03" style="margin-left: 5px;">'+Common.getDic('lbl_lunar_leap_month')+'</label>'+
			'</span>'
		);
	}
	
	onlyNumber($(".onlyNum"));
	onlyDecimal($(".onlydecimal"));
	
</script>
