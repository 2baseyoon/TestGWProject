<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="popContent">
	<div class="ulList">
		<ul>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_VacationKind' /></strong></div> <!-- 휴가구분 -->
				<div>
					<select id="reservedInt" style="width: 90px;"></select>
				</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.VACATION_TYPE_VACATION_TYPE' /></strong></div> <!-- 휴가유형 -->
				<div>
					<input type="text" id="Code" value="${Code}"  ${mode eq 'U' ? "disabled": ""} /> <input type="button" onclick="doubleCheck();" ${mode eq 'U' ? "style=\"display: none;\"": ""} value="<spring:message code='Cache.btn_CheckDouble'/>" />
				</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_apv_vacation_delvac' /></strong></div> <!-- 반차 -->
				<div>
					<%--<input type="checkbox" id="reserved3" style="display:block" ${Reserved3 eq '0.5' ? "checked": ""}/>--%>
					<select id="reserved3" style="width: 90px;" onchange="javascript:changeVacDay();">
						<option value="1">연차/DayOff</option>
						<option value="0.5">반차/HalfOff</option>
						<option value="0.125">시간차/HoursOff</option>
					</select>
					<select id="vacTime" style="display:none;width: 100px;">
						<option value="0.125">1시간/1Hour</option>
						<option value="0.25">2시간/2Hours</option>
						<option value="0.375">3시간/3Hours</option>
					</select>
					<select id="rewardVac" style="display:none;width: 100px;">
						<option value="">고정</option>
						<option value="min">최소</option>
						<option value="none">사용불가</option>
					</select>
				</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_Vaction_Name' /></strong></div> <!-- 휴가명 -->
				<div>
					<input type="text" id="CodeName" value="${CodeName}"/>
					<input type="button" value="<spring:message code='Cache.lbl__DicModify'/>" class="AXButton" onclick="dictionaryLayerPopup();" />
				</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_Sort' /></strong></div> <!-- 정열 -->
				<div><input  name="SortKey" id="SortKey"  value="${SortKey}"/>					</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_IsUse' /></strong></div> <!-- 사용여부 -->
				<div>
					<spring:message code='Cache.lbl_Use' /> : <input type="radio" ${IsUse eq 'Y' ? "checked": ""} name="isuse" id="isuse"  value="Y"/>
					<spring:message code='Cache.lbl_UseN' />: <input type="radio" ${IsUse eq 'Y' ? "": "checked"} name="isuse" id="isuse"  value="N"/>
				</div>
			</li>
			<li class="listCol">
				<div><strong><spring:message code='Cache.lbl_n_att_vacTypeDed' /></strong></div> <!-- 차감여부 -->
				<div>
					<spring:message code='Cache.lbl_Deduction' /> :   <input type="radio" ${Reserved1 eq 'Y' ? "checked": ""} name="reserved1" id="reserved1"  value="Y"/>
					<spring:message code='Cache.lbl_NoDeduction' /> : <input type="radio" ${Reserved1 eq 'Y' ? "": "checked"}  name="reserved1" id="reserved1"  value="N"/>
				</div>
			</li>
			<li id="alreayVacation" class="listCol">
				<div><strong><spring:message code='Cache.lbl_apv_alreayvacation' /></strong></div> <!-- 선연차여부 -->
				<div>
					<spring:message code='Cache.lbl_UseN' />: <input type="radio" ${Reserved2 eq '1' ? "": "checked"} name="reserved2" id="reserved2"  value=""/>
					<spring:message code='Cache.lbl_Use' /> : <input type="radio" ${Reserved2 eq '1' ? "checked": ""} name="reserved2" id="reserved2"  value="1"/>
				</div>
			</li>
		</ul>
	</div>
</div>
<div class="bottom" style="text-align: center;">
	<c:choose>
		<c:when test="${mode == 'U'}">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacationType();"><spring:message code='Cache.lbl_Modify' /></a>
		  </c:when>
		  <c:otherwise>
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="setVacationType();"><spring:message code='Cache.btn_register' /></a>
		</c:otherwise>
	</c:choose>
	<a href="#" class="btnTypeDefault" onclick="parent.Common.close('target_pop')"><spring:message code='Cache.lbl_Cancel' /></a>

</div>
<input type="hidden" id="MultiCodeName" value="${MultiCodeName}">
<script>

	var doublecheck = false;
	var ReservedInt = "${ReservedInt}";
	var _Reserved2 = "${Reserved2}";
	$(document).ready(function(){
		init();

		$("#Code").on('change',function(){
			doublecheck = false;
		});

		$("#Code").keyup(function(event){//한글 입력 방지
			if (!(event.keyCode >=37 && event.keyCode<=40)) {
				var inputVal = $(this).val();
				var check = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
				if(check.test(inputVal)){
					$(this).val("");
				}else{//소문자->대문자화
					$(this).val($(this).val().toUpperCase());
				}
			}
		});
		
		$("#reservedInt").on('change',function(){
			if($$(Common.getBaseCode("VACATION_KIND")).find("CacheData[CodeID=" + $(this).val() + "]").attr("Code") == "REWARD"){
				$("#rewardVac").show();
				$("#alreayVacation").hide();
			} else{
				$("#rewardVac").hide();
				$("#alreayVacation").show();
			}
		});
		$("#reservedInt").trigger("change");
	});

	function init(){

		var attGroup = Common.getBaseCode("VACATION_KIND").CacheData;
		var html = "";
		for(var i=0;i<attGroup.length;i++){
			html +="<option  value='"+attGroup[i].CodeID+"' >"+attGroup[i].CodeName+"</option>";
		}
		$("#reservedInt").append(html);

		if(ReservedInt != null && ReservedInt != ""){
			$("#reservedInt").val(ReservedInt).prop("selected", true);	
		}
		
		if(_Reserved2 == "min"){
			$("#rewardVac").val("min").prop("selected", true);	
		}else if(_Reserved2 == "none"){
			$("#rewardVac").val("none").prop("selected", true);	
		}
		
		
		var vacDay = parseFloat("${Reserved3}");
		var codeName = "${CodeName}";
		if(codeName==null || codeName==""){
			codeName = "${Reserved3}";
		}
		if(vacDay<0.5){
			$("#vacTime").show();
			$("#vacTime").val(vacDay);
			$("#reserved3").val(0.125);
			if(vacDay!=parseFloat($("#vacTime").val())) {
				$("#vacTime").append("<option value='"+vacDay+"'>" +codeName+ "</option>").show();
				$("#vacTime").val(vacDay);
			}
		}else {
			$("#reserved3").val(vacDay);
		}
	}

	function changeVacDay(){
		var vacDay = parseFloat($("#reserved3").val());
		if(vacDay<0.5){
			$("#vacTime").show();
		}else{
			$("#vacTime").hide();
		}
	}
	
	//중복체크
	function doubleCheck(){
		if($("#Code").val() == "" ){
			Common.Warning("<spring:message code='Cache.msg_RequiredCode' />");
			$("#Code").focus(); 	
			return false;
		}else{
			// 중복 체크 처리
			var sessionObj = Common.getSession();
			var CodeGroup = "VACATION_TYPE";
			var Code = $("#Code").val();
			$.ajax({
				type:"POST",
				data:{
					"DN_ID" : sessionObj["DN_ID"],
					"CodeGroup" : CodeGroup,
					"Code" : Code
				},
				url:"/covicore/basecode/checkDouble.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_UseAvailable' />");
						doublecheck = true;
					}else{
						Common.Warning("<spring:message code='Cache.msg_UseUnavailable' />");
						doublecheck = false; 	
					}
				},
				error:function (error){
					CFN_ErrorAjax("covicore/basecode/checkDouble.do", response, status, error);
				}
			});
			return true;
		}
		
	}
	
	function setVacationType(){
		if(doublecheck){
			//기초코드등록
			if ($("#CodeName").val() == "") {
				Common.Warning("<spring:message code='Cache.ACC_msg_case_2' />".replace("{0}", "<spring:message code='Cache.lbl_Vaction_Name' />"), 'Warning Dialog', function() {
					$("#CodeName").focus();
				});
				return false;
			}

			if ($("#SortKey").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_apv_297' />", 'Warning Dialog', function() {
					$("#SortKey").focus();
				});
				return false;
			}

			var vacDay = parseFloat($("#reserved3").val());
			if(vacDay<0.5){
				vacDay = parseFloat($("#vacTime").val());
			}
			
			var sReserved2 = $("input[name='reserved2']:checked").val() == "1"?"1":null;
			if($$(Common.getBaseCode("VACATION_KIND")).find("CacheData[CodeID=" + $("#reservedInt").val() + "]").attr("Code") == "REWARD"){
				sReserved2 = $("#rewardVac").val();
			}
			
			var params = {
				Code : $("#Code").val()
				,CodeName : $("#CodeName").val()
				,MultiCodeName : $("#MultiCodeName").val()
				,IsUse : $("input[name='isuse']:checked").val() == "Y"?"Y":"N"
				,Reserved1 : $("input[name='reserved1']:checked").val() == "Y"?"+":null
				,Reserved2 : sReserved2
				,Reserved3 : vacDay
				,SortKey : $("#SortKey").val()
				,ReservedInt :  $("#reservedInt option:selected").val()
			}
			$.ajax({
				type:"POST",
				data:params,
				url:"/groupware/vacation/setVacationType.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						//휴가 유평 변경완료시 basecode reload cache
						coviCmn.reloadCache("BASECODE", Common.getSession("DN_ID"));
						Common.Inform("<spring:message code='Cache.lbl_apv_registered' />");
						setTimeout(function(){
							parent.Common.close('target_pop');
							parent.vacationVacationTypeMng.search();
						},1000);
					}else{
						Common.Warning("<spring:message code='Cache.msg_OccurError' />");
					}
				},
				error:function (error){
					Common.Warning("<spring:message code='Cache.msg_OccurError' />");
					CFN_ErrorAjax("covicore/basecode/checkDouble.do", response, status, error);
				}
			});
		}else{
			Common.Warning("<spring:message code='Cache.msg_CheckDoubleAlert' />")
			return false;
		}
	}

	function saveVacationType(){
		var vacDay = parseFloat($("#reserved3").val());
		if(vacDay<0.5){
			vacDay = parseFloat($("#vacTime").val());
		}
		
		var sReserved2 = $("input[name='reserved2']:checked").val() == "1"?"1":null;
		if($$(Common.getBaseCode("VACATION_KIND")).find("CacheData[CodeID=" + $("#reservedInt").val() + "]").attr("Code") == "REWARD"){
			sReserved2 = $("#rewardVac").val();
		}
		
		var params = {
			Code : $("#Code").val()
			,CodeName : $("#CodeName").val()
			,MultiCodeName : $("#MultiCodeName").val()
			,IsUse : $("input[name='isuse']:checked").val() == "Y"?"Y":"N"
			,Reserved1 : $("input[name='reserved1']:checked").val() == "Y"?"+":null
			,Reserved2 : sReserved2
			,Reserved3 : vacDay
			,ReservedInt :  $("#reservedInt option:selected").val()
			,SortKey : $("#SortKey").val()
			, CodeID : "${CodeID}"
		}
		$.ajax({
			type:"POST",
			data:params,
			url:"/groupware/vacation/updVacationType.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//휴가 유평 변경완료시 basecode reload cache
					coviCmn.reloadCache("BASECODE", Common.getSession("DN_ID"));
					Common.Inform("<spring:message code='Cache.msg_Edited' />" ,"Inform");

					parent.vacationVacationTypeMng.search();
					parent.Common.close('target_pop');
				}else{
					Common.Warning("<spring:message code='Cache.msg_OccurError' />");
				}
			},
			error:function (error){
				Common.Warning("<spring:message code='Cache.msg_OccurError' />");
				CFN_ErrorAjax("covicore/basecode/checkDouble.do", response, status, error);
			}
		});
	}

	// 기본설정 - 다국어 레이어팝업
	function dictionaryLayerPopup() {
		var option = {
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			useShort : 'false',
			dicCallback : 'addMenuDicCallback',
			popupTargetID : 'DictionaryPopup',
			init : 'initDicPopup'
		};

		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;

		//CFN_OpenWindow(url,"다국어 지정",500,300,"");
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultilanguageSettings'/>", url, "450px", "200px", "iframe", true, null, null, true);
	}

	function initDicPopup(){
		return $('#MultiCodeName').val();
	}

	function addMenuDicCallback(data){
		$('#CodeName').val(data.KoFull);
		$('#MultiCodeName').val(coviDic.convertDic(data))
		Common.close("DictionaryPopup");
	}
</script>			