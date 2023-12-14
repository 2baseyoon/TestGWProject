<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>	
<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_ApprovalbaseInfo'/></h2><!-- 전자결재 환경설정 -->
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<div class="bodyMenu">
				<div class="AXTabsLarge mb15">
					<div class="AXTabsTray" id="subMenuDiv">
						<a id="subMenuDiv_RightApvConfig" name="RightApprovalConfigForm" onclick="CoviMenu_GetContent('/approval/layout/approval_RightApprovalConfig.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');" class="AXTab on" style="display: none;"><spring:message code='Cache.lbl_apv_ApprovalbaseInfo'/></a>
						<a id="subMenuDiv_ApvSignReg" name="SignRegistrationForm" onclick="CoviMenu_GetContent('/approval/layout/approval_SignRegistration.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');" class="AXTab" style="display: none;"><spring:message code='Cache.lbl_apv_Regisign'/></a>
					</div>
				</div>
				<form id="RightApprovalConfigForm" name="RightApprovalConfigForm" style="display: none;">
					<!-- 광고차단 확장프로그램 사용 시 클래스명이 문제되어 변경함. -->
					<!-- <div class="adWrap"> -->
					<div style="min-width: 980px;">
						<!--//대결설정-->
						<dl class="daeLeft">
							<dt class="daeTop">
								<span><spring:message code='Cache.lbl_apv_SubstitueSetting'/><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" id="AXInputSwitch"  onchange="changeDisplay(this,'dae');" value="Y"/></span>
							</dt>
							<dd class="daeBot">
		                      <div class="t_padding">
			                      <table>
			                        <colgroup>
			                          <col style="width:60px">
			                          <col style="width:100px">
			                          <col style="width:60px">
			                          <col style="width:60px">
			                        </colgroup>
			                        <tr>
			                          <!-- [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가 -->
			                          <td class="IsUseAutoApproval" ><spring:message code="Cache.lbl_Option"/></td>
			                          <td class="IsUseAutoApproval" colspan="2" style="font-size: 12px; color: #666;">
			                          	<label for="DeputyOption_Y" style="margin-right: 7px;">
			                          		<input type="radio" id="DeputyOption_Y" name="DeputyOption" value="Y"/> <spring:message code='Cache.lbl_apv_DeputyOption_Y'/>
			                          	</label><br/>
			                          	<label for="DeputyOption_P">
			                          		<input type="radio" id="DeputyOption_P" name="DeputyOption" value="P"/> <spring:message code='Cache.lbl_apv_DeputyOption_P'/>
			                          	</label>
			                          </td>
			                          <td><spring:message code='Cache.lbl_apv_subApprover'/></td>
			                          <td><input type="text" class="adSearch" id="DeputyName" readonly="readonly"><a class="searchBtn"  onclick="OrgMap_Open(0);" style="" id="searchId"><spring:message code='Cache.lbl_search'/> <!-- 검색 --></a></td>
			                        </tr>
			                        <tr>
			                          <td><spring:message code='Cache.lbl_apv_SubstituePeriod'/></td>
			                          <input type="hidden" id="DeputyCode"/> <!--대결자 코드(UR_CODE)-->
										<td colspan="3">											
											<!-- <input class="adDate" id="DeputyFromDate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="DeputyToDate">
										   	    - 				   	   
											<input class="adDate" id="DeputyToDate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="DeputyFromDate"> -->
											
											<!-- mail 쪽 js에서 오류 발생해서 통합게시 쪽 기간설정 형태로 변경함. -->
											<input class="adDate" type="text" id="DeputyFromDate" date_separator="-" readonly=""> - 
											<input id="DeputyToDate" date_separator="-" kind="twindate" date_startTargetID="DeputyFromDate" class="adDate" type="text" readonly="">
											<td id="TimeZone"></td>
										</td>
			                        </tr>
			                        <tr>
			                          <td><spring:message code="Cache.lbl_replacement_reason"/></td>
			                          <td colspan="3"><input type="text" class="adTArea" id="DeputyReason"></td>
			                        </tr>
			                      </table>
		                      </div>
							</dd>
						</dl>
						<!--대결설정//-->
						<!--//결재비번-->
						<dl class="pwRight">
							<dt class="pwTop">
								<span><spring:message code='Cache.lbl_apv_appPwdChg'/><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" id="AXInputSwitch2" onchange="pwChangeGubun();" value="Y"/></span>
							</dt>
							<dd class="pwBot">
		<!-- 						<dl class="pwLine"> -->
								<div class="t_padding">
			                        <table>
			                          <colgroup>
			                            <col style="width:80px">
			                            <col style="width:*">
			                          </colgroup>
			                          <tr>
			                            <td height="30px"><spring:message code='Cache.lbl_apv_ApvPwd2'/></td>
			                            <td>
			                            	<div class="chkStyle04 chkType01">
												<input type="checkbox" id="pwChange" name="pwChange" disabled onClick="pwChangeGubun();" ><label for="pwChange"><span></span><spring:message code='Cache.lbl_change'/></label>
											</div>
			                            </td>
			                          </tr>
			                          <tr>
			                            <td><spring:message code='Cache.lbl_newPasswd1'/></td>
			                            <td><input type="password" class="adPw" id="password" name="password" autocomplete="off"></td>
			                          </tr>
			                          <tr>
			                            <td><spring:message code='Cache.lbl_newPasswd2'/></td>
			                            <td><input type="password" class="adPw" id="re_password" name="re_password" autocomplete="off"></td>
			                          </tr>
			                        </table>
			                      </div>
							</dd>
						</dl>
						<!--결재비번//-->
						<!--//결재알림설정-->
						<dl class="adSound">
							<dt class="sounTop">
								<span><spring:message code='Cache.lbl_apv_setupAppNotify'/><a class="rouBtn"><input type="checkbox" onclick="checkDisplay();" id="checkAll"><spring:message code='Cache.lbl_apv_selectall'/></a></span><!-- 전체선택 -->
							</dt>
							<dd class="sounBot">
								<ul class="adLayout" id="AlarmTable">
								</ul>
							</dd>
						</dl>
						<!--결재알림설정//-->
					</div>
				</form>
				<!-- 본문 끝 -->
			</div>
			<div class="popBtn borderNon mtm10 t_center">
			  <a onclick="saveSubmit()" class=" btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_apv_save'/></a>
			</div>
		</div>
	</div>
</div>
<!-- 본문 시작 -->
<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
<script>
//# sourceURL=RightApprovalConfig.jsp'
var objPopup;
var title;

initContent();

function initContent(){
	setSubMenu();
	getPersonData();		// 사용자 정보 조회 및 화면 세팅(setData 호출)
	coviInput.setDate();

	$("[name='DeputyOption']").on("change", function(e){
		var DeputyOption = $(e.target).val();

		if(DeputyOption == "Y"){
			$("#DeputyName").attr("disabled",false);
			$("#searchId").attr('onclick', 'OrgMap_Open(0)');
			$("#searchId").css('cursor', '');
		} else {
            $("#DeputyName").val("");
            $("#DeputyCode").val("");
			$("#DeputyName").attr("disabled",true);
			$("#searchId").attr('onclick', '').unbind('click');
			$("#searchId").css('cursor', 'default');
		}
	});
}

function setSubMenu(){
	$("#subMenuDiv").find("a[id^='subMenuDiv']").each(function(i, obj) {
		if(Common.getBaseConfig("use" + $(obj).attr("id").split("_")[1]) == "Y") {
			$(obj).show();
			$("form[id='" + $(obj).attr("name") + "']").show();
		}
	});
	
	if(!$("#subMenuDiv").find("a[id^='subMenuDiv']").eq(0).is(":visible")) {
		$("#subMenuDiv").find("a[id^='subMenuDiv']").eq(1).click();
	}
}

//새로고침
function refresh(){
	CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
}


//사용자 개인정보 조회
function getPersonData(){
	$.ajax({
		type:"POST",
		url:"/approval/user/getPersonSetting.do",
		success:function (data) {
			setData(data.list[0]);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getPersonSetting.do", response, status, error);
		}
	});
}

//화면에 사용자 정보 적용
function setData(list){
	//대결설정 데이터
	if(list.UseDeputy=="Y"){
		//$("#deputy_use_chk").attr("checked",true);
		$("#DeputyName").val(list.DeputyName);
		$("#DeputyCode").val(list.DeputyCode);
		$("#DeputyReason").val(list.DeputyReason);
		$("#AXInputSwitch").attr('value','Y');
		$("#AXInputSwitch").val('Y');
		

		if(Common.getBaseConfig("useTimeZone") == "Y"){
			$("#DeputyFromDate").val(CFN_TransLocalTime(list.DeputyFromDate, "yyyy-MM-dd"));
			$("#DeputyToDate").val(CFN_TransLocalTime(list.DeputyToDate, "yyyy-MM-dd"));
			if(Common.getSession("UR_TimeZone").split(":")[1]!="00"){
				var TimeZone =  Common.getSession("UR_TimeZoneDisplay");
				document.getElementById("TimeZone").innerHTML = TimeZone;
			}
		}else{
			$("#DeputyFromDate").val(list.DeputyFromDate);
			$("#DeputyToDate").val(list.DeputyToDate);	
		}
		
		// [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
		$("input[id='DeputyOption_" + list.DeputyOption + "']").prop("checked", true); 
		
		//부재중 자동 승인 사용 여부
		if(Common.getBaseConfig("AutoApproval")=="N"){
			$(".IsUseAutoApproval").hide();
		}

		if(list.DeputyOption == "Y"){
			$("#DeputyName").attr("disabled",false);
		} else {
			$("#DeputyName").attr("disabled",true);
			$("#searchId").attr('onclick', '').unbind('click');
			$("#searchId").css('cursor', 'default');
		}
	}else{
		
		$("#inputBasic_AX_DeputyToDate").css("visibility","hidden");
		$(".AXanchor").css("visibility","hidden");
		$("#DeputyName").attr("disabled",true);
		$("#DeputyReason").attr("disabled",true);
		$("#DeputyToDate").attr("disabled",true);
		$("#DeputyFromDate").attr("disabled",true);
		//$("#DeputyToDate").attr("kind","");		
		$("#searchId").attr('onclick', '').unbind('click');
		$("#searchId").css('cursor', 'default');
		
		$("#AXInputSwitch").attr('value','N');
		$("#AXInputSwitch").val('N');
		
		// [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
		$("input[type='radio'][name='DeputyOption']").attr("disabled",true);
		$("input[id='DeputyOption_" + list.DeputyOption + "']").prop("checked", true);
	}

	//결재암호 데이터
	$("#AXInputSwitch2").val(list.UseApprovalPassWord);
	$("#AXInputSwitch2").attr('setPwUse', list.UseApprovalPassWord);
	pwChangeGubun();
	
    var todoMsgType = Common.getBaseCode("TodoMsgType")["CacheData"];
    var alarmKind = [];
    for(var idx = 0; idx < todoMsgType.length; idx++){
    	if(todoMsgType[idx].Code != 'TodoMsgType' && todoMsgType[idx].BizSection == "Approval" && todoMsgType[idx].Code.indexOf("Approval_") > -1 && todoMsgType[idx].ReservedInt == "1"){
    		todoMsgType[idx].Code = todoMsgType[idx].Code.replace("Approval_", "");
    		alarmKind.push(todoMsgType[idx]);
    	}
    }
	
    //알림매체를 사용 하는 알림 표시 : MAIL;MESSENGER;TODOLIST;MDM;
	var mediaObj = Common.getBaseCode("NotificationMedia");
	var lang = Common.getSession("lang");

    //결재암호 그리드 생성
	var divcnt = 1;
	 //행 수 만큼 가져옴
    for(var n=0;n<(Math.ceil(alarmKind.length/4));n++){
    	var row ="";

    	var colInfo = {};
    	
    	var info1 = alarmKind[n*4];
    	var info3 = alarmKind[n*4+1] || {};
    	var info5 = alarmKind[n*4+2] || {};
    	var info7 = alarmKind[n*4+3] || {};
        colInfo["col1"] = "<tr><th style='width: 160px;'><span>"+CFN_GetDicInfo(info1.MultiCodeName, lang)+"</span><input type=\"text\" class=\"swOff\" kind=\"switch\" name=\"NOTIFY\" on_value=\"Y\" off_value=\"N\" id=\"AXInputSwitched"+info1.Code+"\"  onchange=\"changeCheckBOx(this,'"+ info1.Code +"');\" value=\"N\"/></th><td>";
        colInfo["col3"] = "<tr><th style='width: 160px;'><span>"+CFN_GetDicInfo(info3.MultiCodeName, lang)+"</span><input type=\"text\" class=\"swOff\" kind=\"switch\" name=\"NOTIFY\" on_value=\"Y\" off_value=\"N\" id=\"AXInputSwitched"+info3.Code+"\"  onchange=\"changeCheckBOx(this,'"+ info3.Code +"');\" value=\"N\"/></th><td>";
        colInfo["col5"] = "<tr><th style='width: 160px;'><span>"+CFN_GetDicInfo(info5.MultiCodeName, lang)+"</span><input type=\"text\" class=\"swOff\" kind=\"switch\" name=\"NOTIFY\" on_value=\"Y\" off_value=\"N\" id=\"AXInputSwitched"+info5.Code+"\"  onchange=\"changeCheckBOx(this,'"+ info5.Code +"');\" value=\"N\"/></th><td>";
        colInfo["col7"] = "<tr><th style='width: 160px;'><span>"+CFN_GetDicInfo(info7.MultiCodeName, lang)+"</span><input type=\"text\" class=\"swOff\" kind=\"switch\" name=\"NOTIFY\" on_value=\"Y\" off_value=\"N\" id=\"AXInputSwitched"+info7.Code+"\"  onchange=\"changeCheckBOx(this,'"+ info7.Code +"');\" value=\"N\"/></th><td>";
        colInfo["col2"] = "";
        colInfo["col4"] = "";
        colInfo["col6"] = "";
        colInfo["col8"] = "";

		$(mediaObj.CacheData).each(function(idx, obj) {
			if (obj.Code == 'NotificationMedia')  return true; // Group Code
	
			var EnableMedia1 = (info1.Reserved1 || "").toUpperCase().split(";").indexOf(obj.Code.toUpperCase()) > -1;
			var EnableMedia3 = (info3.Reserved1 || "").toUpperCase().split(";").indexOf(obj.Code.toUpperCase()) > -1;
			var EnableMedia5 = (info5.Reserved1 || "").toUpperCase().split(";").indexOf(obj.Code.toUpperCase()) > -1;
			var EnableMedia7 = (info7.Reserved1 || "").toUpperCase().split(";").indexOf(obj.Code.toUpperCase()) > -1;
			
			colInfo["col2"] += !EnableMedia1 ? "" : "<input id='"+ info1.Code +"' name='NOTIFY' type='checkbox' class='bindCheckbox' value='"+obj.Code+";'/>"+CFN_GetDicInfo(obj.MultiCodeName, lang)+"";
			colInfo["col4"] += !EnableMedia3 ? "" : "<input id='"+ info3.Code +"' name='NOTIFY' type='checkbox' class='bindCheckbox' value='"+obj.Code+";'/>"+CFN_GetDicInfo(obj.MultiCodeName, lang)+"";
			colInfo["col6"] += !EnableMedia5 ? "" : "<input id='"+ info5.Code +"' name='NOTIFY' type='checkbox' class='bindCheckbox' value='"+obj.Code+";'/>"+CFN_GetDicInfo(obj.MultiCodeName, lang)+"";
			colInfo["col8"] += !EnableMedia7 ? "" : "<input id='"+ info7.Code +"' name='NOTIFY' type='checkbox' class='bindCheckbox' value='"+obj.Code+";'/>"+CFN_GetDicInfo(obj.MultiCodeName, lang)+"";
		});		
		colInfo["col2"] += "</td></tr>";
		colInfo["col4"] += "</td></tr>";
		colInfo["col6"] += "</td></tr>";
		colInfo["col8"] += "</td></tr>";
       
	      //마지막 div를 그릴 때
	    if(n == (Math.ceil(alarmKind.length/4) -1)){  
	    	var lastRow = alarmKind.length - n*4; // 마지막 div에 추가되는  row 수 
	    	
	    	row = "<li><div class=\"adTWrap0"+divcnt+"\"><table class=\"soundTable\"><tbody>";
	    	for(var r = 1; r<=lastRow; r++){
	    		row += colInfo["col"+(r*2-1)] + colInfo["col"+(r*2)];
	    	}
	    	row+="</td></tbody></table></div></li>";
	    }
	    else{
	        row = "<li><div class=\"adTWrap0"+divcnt+"\"><table class=\"soundTable\"><tbody>"+colInfo["col1"] +""+ colInfo["col2"] +""+ colInfo["col3"] + ""+ colInfo["col4"] +""+colInfo["col5"] +""+ colInfo["col6"] +""+ colInfo["col7"] + ""+ colInfo["col8"] +"</td></tbody></table></div></li>";
	    }
       
        $("#AlarmTable").append(row);
    }

    //사용자 별 설정 한 알림 체크
    var alarmData = list.Alarm;
    if(alarmData != "" && alarmData != undefined){
        // 알림설정체크
        $.each(alarmData.mailconfig, function(key, value){
        	if(value.split(";")[0] == "Y"){
        		$("[id='AXInputSwitched"+key+"']").attr("value","Y");
        		$("[id='"+key+"']").prop("disabled",false);
        	}
        });
      //설정된 암호 체크
        $.each(alarmData.mailconfig, function(key, value){
            $("input[id='"+key+"']").each(function(index,obj){
            	if(value.indexOf(obj.value)>-1) obj.checked=true;
            	else obj.checked=false;
            });
        });
    }

    coviInput.setSwitch();
}

//담당자 보기 버튼 클릭시 담당자 목록 조회.
function getMemberListPopup(pModal,jobFunctionID){
	//다국어: 담당자지정
	objPopup = parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_Charger'/>","/approval/user/goRightApprovalJobFunctionSetPopup.do?JobFunctionID="+jobFunctionID,"600","400","iframe",true,null,null,true);
}

//대결 - 사용자 지정 버튼 클릭시 호출될 조직도 팝업.
function OrgMap_Open(mapflag){
	flag = mapflag;
	//다국어: 조직도
	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=setMGRDEPTLIST&type=B1","1000px","580px","iframe",true,null,null,true);
}

//조직도선택후처리관련
var peopleObj = {};
function setMGRDEPTLIST(peopleValue){
		var dataObj = $.parseJSON(peopleValue);
		if(dataObj.item.length > 0){
			var UR_Name_Data = CFN_GetDicInfo(dataObj.item[0].DN);
			var UR_Code_Data = dataObj.item[0].AN;
			$("#DeputyName").val(UR_Name_Data);
			$("#DeputyCode").val(UR_Code_Data);
		}else if(dataObj[0].dept.length > 0){

		}else{
		}
}

//저장
function saveSubmit(){
	if (checkValidation() == true ) {
        var alarmJson = makeJSON();
		var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
        var deputyCode = $("#DeputyCode").val();
        var deputyName = $("#DeputyName").val();
        var deputyFromDate = $("#DeputyFromDate").val();
        var deputyToDate = $("#DeputyToDate").val();
        var deputyReason = $("#DeputyReason").val();
        var deputyOption = $("input[type='radio'][name='DeputyOption']:checked").val(); // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
        var ApprovalPassword = aesUtil.encrypt("<%=as%>", "<%=aI%>", "<%=app%>", $("#password").val());
        var ApprovalPWUse = $("#AXInputSwitch2").val();
        var passwordChangeYN = $("#pwChange").val();
        var deputyYN = "N";

		if($("#AXInputSwitch").val() == "Y"){
			deputyYN ='Y';
		}else{
			deputyYN ='N';
		}
		
        $.ajax({
    		type:"POST",
    		url:"/approval/user/updateUserSetting.do",
    		data:{
    			"DeputyCode" : deputyCode,
    			"DeputyName" : deputyName,
    			"DeputyFromDate" : deputyFromDate,
    			"DeputyToDate" : deputyToDate,
    			"DeputyYN" : deputyYN,
    			"DeputyReason" : deputyReason,
    			"DeputyOption" : deputyOption, // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
    			"ApprovalPassword" : ApprovalPassword,
    			"ApprovalAlarm" : alarmJson,
    			"ApprovalPWUse" : ApprovalPWUse,
    			"passwordChangeYN" : passwordChangeYN,
    		},
    		success:function (data) {
    			if(data.result=="ok" && data.cnt >= 2){
    				//저장되었습니다. 전자결재 환경설정
    				Common.Inform("<spring:message code='Cache.msg_apv_331'/>","<spring:message code='Cache.lbl_apv_ApprovalbaseInfo'/>",function(){
    					refresh();
    				});
    			}else if (data.result=="fail"){
    				//존재하지 않는 사용자입니다. 저장 실패
    				Common.Warning(data.message,"<spring:message code='Cache.msg_apv_395'/>","");
    			}else{
    				//존재하지 않는 사용자입니다. 저장 실패
    				Common.Warning("<spring:message code='Cache.msg_apv_394'/>","<spring:message code='Cache.msg_apv_395'/>",function(){
    					refresh();
    				});
    			}
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/updateUserSetting.do", response, status, error);
			}
    	});
	}
}

//저장 버튼 클릭 시 화면 validation check
function checkValidation(){
    //if ($("input[id=pw_use_chk]").is(":checked") == true && ($("#password").val() == "" || $("#re_password").val() == "")) {
    if ($("#pwChange").val() == "Y" && ($("#password").val() == "" || $("#re_password").val() == "")) {
    	//다국어 : 새암호 혹은 새암호확인을 입력하십시오. , 전자결재 비밀번호 변경
    	Common.Warning("<spring:message code='Cache.msg_apv_332'/>","<spring:message code='Cache.lbl_apv_appPwdChg'/>","");
        return false;
    }

    if ($("#password").val() != $("#re_password").val()) {
    	//다국어 : 새암호와 새암호확인이 같지 않습니다. , 전자결재 비밀번호 변경
       Common.Warning("<spring:message code='Cache.msg_apv_333'/>","<spring:message code='Cache.lbl_apv_appPwdChg'/>","") ;
       return false;
    }

    //if($("input[id=deputy_use_chk]").is(":checked") == true && $("#DeputyName").val()==""){
    if($("#AXInputSwitch").val() == "Y" && ($("#DeputyName").val()=="" && $("input[type='radio'][name='DeputyOption']:checked").val() != "P")){
    	//다국어 : 대결자를 입력하십시오. , 대결설정
    	Common.Warning("<spring:message code='Cache.msg_apv_344'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>","");
    	return false;
    }

   //if ($("input[id=pw_use_chk]").is(":checked") == true && ($("#DeputyFromDate").val() == "" || $("#DeputyToDate").val() == "")) {
	if ($("#AXInputSwitch").val() == "Y" && ($("#DeputyFromDate").val() == "" || $("#DeputyToDate").val() == "")) {
    	//다국어 : 대결기간을 입력하십시오. , 대결설정
    	Common.Warning("<spring:message code='Cache.msg_apv_334'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>","") ;  //  대결기간을 입력하십시오.
        return false;
    }
    //if ($("input[id=deputy_use_chk]").is(":checked") == true && $("#DeputyReason").val()=="") {
    if ($("#AXInputSwitch").val() == "Y" && $("#DeputyReason").val()=="") {
    	//대결사유를 입력하여 주십시오. , 대결설정
    	Common.Warning("<spring:message code='Cache.msg_apv_262'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>","") ;  //  대결기간을 입력하십시오.
        return false;
    }

    if($("#DeputyCode").val() == Common.getSession("USERID")){
    	//스스로를 대결자로 지정할 수 없습니다., 대결설정
    	Common.Warning("<spring:message code='Cache.msg_no_self_deputy'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>","") ;  //  대결기간을 입력하십시오.
        return false;
    }

 	// [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
    if($("#AXInputSwitch").val() == "Y" && !$("input[type='radio'][name='DeputyOption']:checked").val()){
    	//대결 옵션을 선택하여 주시기 바랍니다., 대결설정
    	Common.Warning("<spring:message code='Cache.msg_apv_selectDeputyOption'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>","") ;  //  대결기간을 입력하십시오.
        return false;
    }
    
    return true;
}

//저장 버튼 클릭 시  알림설정을 JSON 형식으로 만듦.
function makeJSON(){
	var alarmJson = new Object();
	alarmJson.mailconfig = new Object();


	var notifyKind;

	// 화면에 있는 데이터기준으로 생성.
	$("input[name='NOTIFY'][kind=switch]").each(function(j, obj) {
		notifyKind = obj.id.replace("AXInputSwitched","");
		alarmJson.mailconfig[notifyKind] = obj.value + ";";
	});
	
	$("input[name='NOTIFY'][type=checkbox]").each(function(j, obj) {
		notifyKind = obj.id;
		if (obj.checked == true) {
			alarmJson.mailconfig[notifyKind] += obj.value;
		}
	});
	return JSON.stringify(alarmJson);
}

//결재암호 사용여부 변경시 화면 Input 셋팅
function pwUseChange(){
	if($("input[id=pw_use_chk]").is(":checked") == true){
		$("input[id=password]").attr("readonly", false);
		$("input[id=re_password]").attr("readonly", false);
	}else{
		$("input[id=password]").val("");
		$("input[id=re_password]").val("");
		$("input[id=password]").attr("readonly", true);
		$("input[id=re_password]").attr("readonly", true);
	}
}

//대결 사용여부 변경 화면 Input 셋팅
function deputyUseChange(){
    //if($("input[id=deputy_use_chk]").is(":checked") == false) {
    if($("#AXInputSwitch").val() == 'N') {
    	//다국어 : 대결의 모든 정보가 삭제 됩니다. 계속하시겠습니까 ? , 대결설정
    	Common.Confirm("<spring:message code='Cache.msg_apv_329'/>","<spring:message code='Cache.lbl_apv_SubstitueSetting'/>",function(result){
    		 if(result) {
                 $("#DeputyName").val("");
                 $("#DeputyCode").val("");
                 $("#DeputyFromDate").val("");
                 $("#DeputyToDate").val("");
                 $("#DeputyReason").val("");
             }else {
     			$("#DeputyName").attr("disabled",false);
    			$("#DeputyReason").attr("disabled",false);
    			$("#DeputyToDate").attr("disabled",false);
    			$("#DeputyFromDate").attr("disabled",false);
     			$(".AXanchorDateHandle").show();     			
     			$("#AXInputSwitch").attr('value','Y');
     			    			
     			$("input[type='radio'][name='DeputyOption']").attr("disabled",false); // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
             }
        });
    }
}

function changeCheckBOx(pObj,inputID){
	if($(pObj).attr("value") == "Y"){
		$("[id='"+inputID+"']").prop("disabled",true).prop("checked", false);
		$(pObj).attr("value","N");
	}else{

		$("[id='"+inputID+"']").prop("disabled",false);
		$(pObj).attr("value","Y");
	}
}

function changeDisplay(pObj,type){
	if(type == "pw"){
		if($(pObj).attr("value") == "Y"){
			$("#password").attr("disabled",true);
			$("#re_password").attr("disabled",true);
			$("#password").val("");
			$("#re_password").val("");
			$(pObj).attr("value","N");
		}else{
			$("#password").attr("disabled",false);
			$("#re_password").attr("disabled",false);
			$(pObj).attr("value","Y");
		}
	}else{
		if($(pObj).attr("value") == "Y"){
			$("#DeputyName").val("");
            $("#DeputyCode").val("");
            $("#DeputyFromDate").val("");
            $("#DeputyToDate").val("");
            $("#DeputyReason").val("");
			$("#DeputyName").attr("disabled",true);
			$("#DeputyReason").attr("disabled",true);
			$("#DeputyToDate").attr("disabled",true);
			$("#DeputyFromDate").attr("disabled",true);
			$(".AXanchorDateHandle").hide();
			$("#searchId").attr('onclick', '').unbind('click');
			$("#searchId").css('cursor', 'default');
			$("input[type='radio'][name='DeputyOption']").attr("disabled",true); // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
			$(pObj).attr("value","N");
		}else{
			$("#DeputyName").attr("disabled",false);
			$("#DeputyReason").attr("disabled",false);
			$("#DeputyToDate").attr("disabled",false);
			$("#DeputyFromDate").attr("disabled",false);
			coviInput.setDate();		
			$("#searchId").attr('onclick', 'OrgMap_Open(0)');
			$("#searchId").css('cursor', '');
			$("input[type='radio'][name='DeputyOption']").attr("disabled",false); // [2019-02-20 ADD] gbhwang
			$(pObj).attr("value","Y");
		}
	}
}

function checkDisplay(){
	var checkID;
	if($("input[id=checkAll]").is(":checked") == false){
		$('input:checkbox[name="NOTIFY"]').prop('checked',false);
	}else{
		
		var allOnSwitch = true;
		
		$("[id^='AXInputSwitched'][name='NOTIFY']").each(function(idx,obj){
			if($(obj).val()=="N"){
				allOnSwitch = false;
				return false;
			}
		});
		
		if(allOnSwitch){
			$("input[name='NOTIFY']").each(function() {
				if(this.id.indexOf("AXInputSwitched") < 0){
					checkID = this.id;
				}
				if($("[id='"+checkID+"']").attr("disabled") != "disabled"){
					$("[id='"+checkID+"']").prop('checked',true);
				}
			});
		}else{
			Common.Inform("<spring:message code='Cache.msg_apv_config_alarmCheck'/>"); //전체 체크를 하시려면 알림 스위치를 모두 켜주세요
			$("input[id=checkAll]").prop('checked',false);
		}
	}
}

function pwChangeGubun(){//결재암호 데이터
	if($("#AXInputSwitch2").val() =='Y'){
		$("#pwChange").attr("disabled",false);
		if ($("#AXInputSwitch2").attr("setPwUse") == 'N') { 
			$("#pwChange").prop("checked",true);
		}
		if($("input[id=pwChange]").is(":checked") == true){
			$("#password").attr("disabled",false);
			$("#re_password").attr("disabled",false);
			$("#pwChange").val("Y");
		}else{
			$("#password").attr("disabled",true);
			$("#re_password").attr("disabled",true);
			$("#password").val("");
			$("#re_password").val("");
			$("#pwChange").val("N");
		}
	}else{
		$("#pwChange").attr("checked",false);
		$("#pwChange").attr("disabled",true);
		$("#password").attr("disabled",true);
		$("#re_password").attr("disabled",true);
		$("#password").val("");
		$("#re_password").val("");
		$("#pwChange").val("N");
	}
}
</script>