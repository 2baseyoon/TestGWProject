<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<style>
input[type='text'],input[type='number']{
 	height:25px !important;
 }
</style>

<form id="addTheme" name="addTheme">
	<div class="AXTabs" style="margin-bottom: 10px">
			<div id="searchTab_Basic">
				<table class="AXFormTable">
					<colgroup>
						<col width="15%"/>
						<col width="35%"/>
						<col width="15%"/>
						<col width="35%"/>
					</colgroup>
					<tr>
						<th><spring:message code='Cache.lbl_OwnedCompany'/> <font color="red">*</font></th>
						<td>
							<select id="selDomain"  class="AXSelect"></select>
						</td>
						<th><spring:message code='Cache.lbl_ThemeName'/> <font color="red">*</font></th>
						<td>
							<input type="text" id="themeName" style="width: 87%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
<!-- 							<input type="button" value="다국어" onclick="dictionaryLayerPopup('true', 'themeName');" class="AXButton" style="width:10pxs"/> -->
							<input type="hidden" id="hidThemeName" value="" />
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_ThemeCode'/> <font color="red">*</font></th>
						<td colspan="3">
							<input type="text" id="themeCode" style="width: 95%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr style="height: 100px">
				<th><spring:message code='Cache.lbl_Description'/></th>
				<td colspan="3">
					<textarea rows="5" style="width: 95%" id="description" class="AXTextarea HtmlCheckXSS ScriptCheckXSS" style="resize:none"></textarea>
				</td>
			</tr>
				</table>
			</div>
	</div>
	<div align="center" style="padding-top: 10px">
		<input type="button" id="btnAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="addSubmit();" style="display: none"  class="AXButton red"/>
		<input type="button" id="btnModify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifySubmit();" style="display: none"  class="AXButton red"/>
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton"/>
	</div>
</form>
<script>
	var mode =CFN_GetQueryString("mode");
	var themeID = CFN_GetQueryString("themeID");
	var langCode = Common.getSession("lang");
	
	//ready
	initContent();
	
	function initContent(){ 
		setControls();
		
		if(mode=="add"){
			$("#btnAdd").show();
		}else if(mode=="modify"){
			$("#btnModify").show();
			setSelectData();
		}
	};
	
	function setControls(){
		//Domain Selectbox
		$("#selDomain").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
	}

	
	// 도메인 데이터 추가
	function addSubmit(){
		if(!chkValidation()){
			return false;
		}
			
		setFullDisplayName();
		
		$.ajax({
			type:"POST",
			data:{
				"themeCode" : $("#themeCode").val(),
				"themeName" : $("#themeName").val(),
				"domainID" :  $("#selDomain").val(),
				//"MulitiDomainName" : $("#hidThemeName").val(),
				"description" : $("#description").val(),
			},
			url:"/covicore/theme/add.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.result > 0){
						Common.Inform("추가 되었습니다.", "Information", function(){
							if(opener){
								opener.search();
							}else{
								parent.search();
							}
							
							closeLayer();
						});
					}else if(data.result == -1){
						Common.Warning("이미 존재하는 테마 코드입니다.", "Warning", function(){
							$("#themeCode").focus();	
						})
					}
				}else{
					Common.Warning("오류가 발생하였습니다.");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/theme/add.do", response, status, error);
			}
		});
		
	}
	
	// 도메인 데이터 수정
	function modifySubmit(){
		if(!chkValidation()){
			return false;
		}
		
		//다국어 제외
		//setFullDisplayName();
		
		$.ajax({
			type:"POST",
			data:{ 
				"themeID" : themeID,
				"themeCode" : $("#themeCode").val(),
				"themeName" :  $("#themeName").val(),
				"domainID": $("#selDomain").val(),
				//"MulitiDomainName" : $("#hidThemeName").val(),
				"description" : $("#description").val(),
			},
			url:"/covicore/theme/modify.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("수정 되었습니다.", "Information", function(){
						parent.search();
						closeLayer();
					});
				}else{
					Common.Warning("오류가 발생하였습니다.");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/theme/modify.do", response, status, error);
			}
		});
	}
	
	// 수정시 기존 데이터 조회
	function setSelectData(){
		$.ajax({
			type:"POST",
			data:{
				"themeID" : themeID
			},
			async: false,
			url:"/covicore/theme/get.do",
			success:function (data){
				$("#themeCode").val(data.list[0].ThemeCode);
				$("#themeName").val(data.list[0].ThemeName);
				$("#selDomain").val(data.list[0].DomainID);
				//$("#hidThemeName").val(data.list[0].MultiDisplayName);
				$("#description").val(data.list[0].Description);
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/theme/get.do", response, status, error);
			}
		});
	}
	
	function dictionaryLayerPopup(hasTransBtn, dicCallback) {
		var option = {
				lang : 'ko',
				hasTransBtn : hasTransBtn,
				allowedLang : 'ko,en,ja,zh,lang1,lang2',
				useShort : 'false',
				dicCallback : dicCallback,
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup',
				openerID : 'setTheme'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		url += "&openerID=" + option.openerID;
		
		parent.Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "400px", "280px", "iframe", true, null, null, true);
	}
	
	function initDicPopup(){
		return $('#hidThemeName').val()=="" ? $('#themeName').val() : $('#hidThemeName').val();
	}
	
	function themeName(data){
		$("#hidThemeName").val(coviDic.convertDic($.parseJSON(data)));
		if(document.getElementById('themeName').value == ''){
			document.getElementById('themeName').value = CFN_GetDicInfo($("#hidThemeName").val());
		}
		
		Common.Close("DictionaryPopup");
	}
	
	function setFullDisplayName(){
		  if ($("#hidThemeName").val() == "") {
		        switch (langCode.toUpperCase()) {
		            case "KO": sDictionaryInfo = $("#themeName").val() + ";;;;;;;;;"; break;
		            case "EN": sDictionaryInfo = ";" + $("#themeName").val() + ";;;;;;;;"; break;
		            case "JA": sDictionaryInfo = ";;" + $("#themeName").val() + ";;;;;;;"; break;
		            case "ZH": sDictionaryInfo = ";;;" + $("#themeName").val() + ";;;;;;"; break;
		            case "E1": sDictionaryInfo = ";;;;" + $("#themeName").val() + ";;;;;"; break;
		            case "E2": sDictionaryInfo = ";;;;;" + $("#themeName").val() + ";;;;"; break;
		            case "E3": sDictionaryInfo = ";;;;;;" + $("#themeName").val() + ";;;"; break;
		            case "E4": sDictionaryInfo = ";;;;;;;" + $("#themeName").val() + ";;"; break;
		            case "E5": sDictionaryInfo = ";;;;;;;;" + $("#themeName").val() + ";"; break;
		            case "E6": sDictionaryInfo = ";;;;;;;;;" + $("#themeName").val(); break;
		        }
		        document.getElementById("hidThemeName").value = sDictionaryInfo
		    }
	}

	//도메인, 테마이름, 테마 코드 설정 여부 확인
	function chkValidation(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if($("#selDomain").val() == undefined || $("#selDomain").val() == ""){
			Common.Warning("도메인을 선택해주세요", "Warning",function(){	$("#themeName").focus();	});
			return false;
		} else if($("#themeName").val() == undefined || $("#themeName").val() == ""){
			Common.Warning("테마 이름을 입력하십시오.", "Warning",function(){	$("#themeName").focus();	});
			return false;
		} else if($("#themeCode").val() == undefined || $("#themeCode").val() == ""){
			Common.Warning("테마 코드를 입력하십시오.", "Warning",function(){ 	$("#themeCode").focus();		});
			return false;
		} else{
			return true;
		}
	}
	
	// 레이어팝업 - 창닫기
	function closeLayer(){
		Common.Close();
	}
	
	
// 	//알파벳과 숫자만 입력하도록(아이디 등을 만들때 사용)
// 	function keyUpAlphabatNum(pObj) {
// 	    var strValue = pObj.value;
// 	    var strChangeValue = strValue;
// 	    var strAllow = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_."
// 	    for (var i = 0; i < pObj.value.length; i++) {
// 	        if (strAllow.indexOf(pObj.value.substring(i, i + 1)) < 0) {
// 	            strValue = strValue.replace(pObj.value.substring(i, i + 1), "");
// 	        }
// 	    }
// 	    if (strChangeValue != strValue) $(pObj).val(strValue);
// 	}
	
</script>
