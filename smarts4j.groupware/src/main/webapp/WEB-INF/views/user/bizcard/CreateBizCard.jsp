<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js"></script>
<%
	String path = request.getRequestURL().toString();

	if (path.indexOf("CreateBizCard") > -1){
%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<% 
	} 
%>

<div> <!--  class="commContRight" -->
	<div class="cRConTop titType" >
		<h2 class="title"><spring:message code='Cache.lbl_RegistContact' /></h2>
	</div>
	<div class="cRContBottom mScrollVH ">
		<div class="bizcardAllCont">
			<div class="addContactWrap">
				<div id="divPerson" class="bizFormWrap personal">
					<input type="file" name="addFile" size="15" style="display:none;" onchange="changeBizCardImage(this);" accept=".jpg, .jpeg, .png, .gif" >
					<input type="text" id="txtImagePath_p" style="display:none;">
					<div id="bizCardImage" class="photoArea" onclick="clickBizCardImage(this);">
						<img class="ico_btn" alt="" onerror='this.src="/covicore/resources/images/common/noImg.png"' src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/file_camera.png" style="width: 50px; margin: 25px 0px 0px 20px;" />
						<img name="bizCardThumbnail"/>
					</div>
					<div class="bizFormInner">
						<dl>
							<dt class="heading"><spring:message code='Cache.lbl_BasicInfo' /></dt>
							<dd>
								<ul class="formList">
									<li class="name">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtName" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_name' />" />
													<span class="bar"></span>
												</div>
											</div>
										</div>
									</li>
									<li class="group">
										<div class="formRow">
											<div class="formBox">
												<select name="selDivision" id="selDivision" onchange="selDivisionChange(this);" class="selectType02 size102">
													<option value="P"><spring:message code='Cache.lbl_ShareType_Personal' /></option>
													<option value="D"><spring:message code='Cache.lbl_ShareType_Dept' /></option>
													<option value="U"><spring:message code='Cache.lbl_ShareType_Comp' /></option>
												</select>	
											</div>
											<div class="formBox">
												<select name="selGroup_p" id="selGroup_p" onchange="selGroupChange(this)" class="selectType02 size113" disabled="disabled">
													<option value=""><spring:message code='Cache.lbl_SelectGroup2' /></option>
												</select>	
											</div>
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtNewGroupName_p" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_EnterNewGroupName' />" style="display:none;"/>
													<span class="bar"></span>
												</div>
											</div>
										</div>
									</li>
									<!-- TODO 기념일 추가 향후 구현 (미구현 사항으로 숨기처리)  -->
									<li class="anniversary"  style="display:none;">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtAnniversary_p" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_AnniversarySchedule' />" />
													<span class="bar"></span>
												</div>
											</div>
											<div class="formBox">
												<a href="#" class="btnTypeDefault btnIco btnAnniversary" onclick="clickAddAnniversary(this);" id="btnAnniversary_p"><spring:message code='Cache.btn_AnniversaryAdd' /></a>
											</div>
										</div>
									</li>
									<li class="tel">
										<div class="formRow" name="trPhone_p">
											<div class="formBox">
												<select name="selPhoneType_p" id="selPhoneType_p" class="selectType02 size102">
													<option value=""><spring:message code='Cache.lbl_PhoneType' /></option> 			<!-- 전화 유형 -->
													<option value="C"><spring:message code='Cache.lbl_MobilePhone' /></option> 			<!-- 핸드폰 -->													
													<option value="T"><spring:message code='Cache.lbl_Office_Line' /></option> 			<!-- 사무실전화 -->
													<option value="F"><spring:message code='Cache.lbl_Office_Fax' /></option> 			<!-- 팩스 -->
													<option value="E"><spring:message code='Cache.lbl_EtcPhone' /></option> 			<!-- 기타 -->
													<option value="H"><spring:message code='Cache.lbl_HomePhone' /></option> 			<!-- 자택 -->
													<option value="D"><spring:message code='Cache.lbl_DirectPhone' /></option> 			<!-- 직접입력 -->
												</select>
											</div>
											<div class="lineBox phoneName" style="width: 125px; display: none;">
												<div class="inner">
													<input type="text" name="txtPhoneName_p" maxlength="50" placeholder="<spring:message code='Cache.lbl_Mail_DirectInput' />" />
												</div>
											</div>
											<div class="lineBox">
												<div class="inner">
													<input type="text" name="txtPhoneNum_p" placeholder="<spring:message code='Cache.lbl_PhoneNum' />" onclick="setOnlyNum(this);" onblur="setHyphen(this);"/>
													<input type="text" name="txtPhoneSeq_p" style='display:none'>
													<span class="bar"></span>
												</div>
											</div>
											<div class="formBox">
												<div class="btnBox">
													<a href="#" class="btnThemePlus" onclick="addRow(this);">추가</a>
													<a href="#" class="btnThemeMinus" onclick="delRow(this);">삭제</a>
												</div>
											</div>
										</div>
									</li>
									<li class="email">
										<div class="formRow" name="trEmail_p">
											<div class="lineBox">
												<div class="inner">
													<input type="text" name="txtEmail_p" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_Email2' />" />
													<input type="text" name="txtEmailSeq_p" style='display:none'>
													<span class="bar"></span>
												</div>
											</div>
											<div class="formBox">
												<div class="btnBox">
													<a href="#" class="btnThemePlus" onclick="addRow(this);">추가</a>
													<a href="#" class="btnThemeMinus" onclick="delRow(this);">삭제</a>
												</div>
											</div>
										</div>
									</li>
									<li class="massanger">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtMessanger" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_MESSENGER' />" />
													<span class="bar"></span>
												</div>
											</div>
										</div>
									</li>
								</ul>
							</dd>
						</dl>
						<dl>
							<dt class="heading"><spring:message code='Cache.lbl_CompanyAffiliation' /></dt>
							<dd>
								<ul class="formList">
									<li class="company">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtCompanyID" class="AXInput" style="display: none;">
													<input type="text" id="txtCompanyName_p" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_CompanyName' />" />
													<span class="bar"></span>
												</div>
											</div>
											<div class="formBox" style="display:none;">
												<a href="#" onclick="searchBizCardCompany();" class="btnTypeDefault"><spring:message code='Cache.btn_SearchCompany' /></a>
											</div>
										</div>
									</li>
									<li class="department">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
												<input type="text" id="txtDept" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_dept' />" />
												<span class="bar"></span>
												</div>
											</div>
										</div>
									</li>
									<li class="duty">
										<div class="formRow">
											<div class="lineBox">
												<div class="inner">
													<input type="text" id="txtJobTitle" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_JobTitle' />" />
													<span class="bar"></span>
												</div>
											</div>
										</div>
									</li>
								</ul>
							</dd>
						</dl>
						<dl>
							<dt class="heading"><spring:message code='Cache.lbl_Memo' /></dt>
							<dd>
								<ul class="formList">
									<li class="company">
										<div class="formRow">
											<div class="formBox">
												<textarea style="overflow-y: scroll;" rows="3" id="txtMemo_p" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
											</div>
										</div>
									</li>
								</ul>
							</dd>
						</dl>
					</div>
					<div class="btnBttmWrap">
						<a href="#" id="btnRegist_p" class="btnTypeDefault btnTypeChk" onclick="registBizCard();"><spring:message code='Cache.btn_register' /></a>
						<a href="#" id="btnModify_p" class="btnTypeDefault btnTypeChk" onclick="modifyBizCard();" style="display: none;"><spring:message code='Cache.btn_Edit' /></a>
 						<a href="#" id="btnDelete_p" class="btnTypeDefault" onclick="deleteBizCard();" style="display: none;"><spring:message code='Cache.btn_delete' /></a>
						 <a href="#" id="btnCopy_p" class="btnTypeDefault" style="display: none;"><spring:message code='Cache.btn_Copy' /></a>
						<a href="#" id="btnCancel_p" class="btnTypeDefault" onclick="closeBizCard();"><spring:message code='Cache.btn_Cancel' /></a>
					</div>
				</div>
			</div>
		</div>												
	</div>		
</div>

<script>
	$(function() {		
		if("${mode}" == "modify" || "${mode}" == "modifyPopup") {
			$(".title").text('<spring:message code="Cache.lbl_ModifyContact" />')
		} else if("${mode}" == "regist") {
			var name = (CFN_GetQueryString("Name") == 'undefined') ? "" : decodeURIComponent(CFN_GetQueryString("Name"));
			var email = (CFN_GetQueryString("Email") == 'undefined') ? "" : decodeURIComponent(CFN_GetQueryString("Email"));
			
			$("#txtName").val(name);
			$("input[name=txtEmail_p]").eq(0).val(email);
		}

		$('.formList .lineBox').each(function(){
			$(this).find('input').on('focus',function(){
				$(this).closest('.inner').addClass('active');
			});
			
			$(this).find('input').on('blur',function(){
				$(this).closest('.inner').removeClass('active');
			});
		});

		$('.tabTypeBizCard li, .bizCardContWrap .tabCont').removeClass('active');
		$('.tabTypeBizCard li:first, .bizCardContWrap .tabCont:first').addClass('active');

		$('.tabTypeBizCard li a').on('click',function(){
			var idxNum = $(this).parent().index();
			var $crntLi = $(this).parent();
			var $cont = $(this).closest('.tabTypeBizCard').next('.tabContWrap');
			var str = $(this).attr("value");
			
			$crntLi.siblings().removeClass('active');
			$crntLi.addClass('active');
			$cont.find('.tabCont').removeClass('active');
			$cont.find('.tabCont').eq(idxNum).addClass('active');
			
			if(str == "divCompany") {
				$('#selGroup_c').find('option').remove()
				$("#selGroup_c").append('<option value="new">' + "<spring:message code='Cache.lbl_newGroup'/>" + '</option>');
				
				$.ajaxSetup({
				     async: false
				});
				
				$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : 'C'}, function(d) {
					d.list.forEach(function(d) {
						$("#selGroup_c").append('<option value="' + d.GroupID + '">' + d.GroupName + '</option>');
					});
					$("#selGroup_c").append('<option value="none">' + "<spring:message code='Cache.lbl_NoGroup'/>" + '</option>'); //그룹 없음
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getGroupList.do", response, status, error);
				});
			}
		});

		// 파일첨부
		$('.inputFileForm input[type=file]').on('change',function(){
			if(window.FileReader){	// modern browser
				var filename = $(this)[0].files[0].name;
			}else {	// old IE
				var filename = $(this).val().split('/').pop().split('\\').pop();	// 파일명만 추출
			}
			$(this).siblings('.txtFileName').text(filename);
		});
		
		// 복사하기
		$("#btnCopy_p").on("click",function(){
			BizCardCopy("C","${BizCardID}");
		});
		
		if("${mode}" == "search" && "${TypeCode}" == "C") {
			$("#btnCancel").css("display", "none");
		}
		
		if("${mode}" == "modify" || "${mode}" == "modifyPopup") {
			if("${TypeCode}" == "P") {
				$("#btnModify_p").css("display", "");
				$("#btnRegist_p").css("display", "none");
				 $.ajaxSetup({
				      async: false
				 }); 
				 
				 $.getJSON('/groupware/bizcard/getBizCardPerson.do', {'BizCardID' : "${BizCardID}"}, function(d) {
					d = d.person[0];
					if(d.ImagePath != "" && d.ImagePath != undefined) {
						$("img[name=bizCardThumbnail]").eq(0).siblings('img').css('display','none');
						$("img[name=bizCardThumbnail]").eq(0).attr('src', coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"))+d.ImagePath));
						$("img[name=bizCardThumbnail]").eq(0).height("100%");
					}
					
					$("#txtName").val(d.Name);
					$("#selDivision").val(d.ShareType);
					
					var UR_ID = Common.getSession("UR_ID");
					
					if(d.ShareType == "U" || d.ShareType == "D"){
						$("#btnCopy_p").css("display","");
						if(d.RegisterID != UR_ID && sessionObj["isAdmin"] != "Y"){ //회사/부서일 경우 삭제 및  구분 권한 처리
							$("#btnDelete_p").css("display", "none");
							$("#selDivision").attr("disabled",true);
						}else{
							$("#btnDelete_p").css("display", "");
						}
					}
					
					$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : d.ShareType}, function(d) {
						d.list.forEach(function(d) {
							$("#selGroup_p").append('<option value="' + d.GroupID + '">' + d.GroupName + '</option>');
						});
						$("#selGroup_p").append('<option value="none">' + "<spring:message code='Cache.lbl_NoGroup'/>" + '</option>'); //그룹 없음
						$("#selGroup_p").removeAttr('disabled');
					}).error(function(response, status, error){
					     //TODO 추가 오류 처리
					     CFN_ErrorAjax("getGroupList.do", response, status, error);
					});
					
					$("#selGroup_p").val((d.GroupID == undefined || d.GroupID == "") ? 'none' : d.GroupID);					
					$("#txtAnniversary_p").val(d.AnniversaryText);
					$("#txtMessanger").val(d.MessengerID);
					$("#txtCompanyID").val(d.CompanyId);
					$("#txtCompanyName_p").val(d.CompanyName);
					$("#txtDept").val(d.DeptName);
					$("#txtJobTitle").val(d.JobTitle);
					$("#txtMemo_p").val(d.Memo.replaceAll("\\r\\n", "\r\n"));
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardPerson.do", response, status, error);
				});
				
				$.getJSON('/groupware/bizcard/getBizCardPhone.do', {'BizCardID' : "${BizCardID}", 'TypeCode' : 'P'}, function(d) {
					var i = 0;
					d.list.forEach(function(d) {
						var cloneTr = $("div[name=trPhone_p]").last().clone();
						$(cloneTr).find("select[name=selPhoneType_p]").val(d.PhoneType);
						
						if(d.PhoneType == "D") {
							$(cloneTr).find(".phoneName").css("display", "");
							$(cloneTr).find("input[name=txtPhoneName_p]").val(d.PhoneName);	
						} else {
							$(cloneTr).find(".phoneName").css("display", "none");
						}
						
						$(cloneTr).find("input[name=txtPhoneNum_p]").val(d.PhoneNumber);
						$(cloneTr).find("input[name=txtPhoneSeq_p]").val(d.SeqID);
						$(cloneTr).insertAfter($("div[name=trPhone_p]").last());
						i++;
					});
					if(i > 0) {
						$("div[name=trPhone_p]").eq(0).remove();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardPhone.do", response, status, error);
				});
				
				$.getJSON('/groupware/bizcard/getBizCardEmail.do', {'BizCardID' : "${BizCardID}", 'TypeCode' : 'P'}, function(d) {
					var i = 0;
					d.list.forEach(function(d) {
						var cloneTr = $("div[name=trEmail_p]").last().clone();
						$(cloneTr).find("input[name=txtEmail_p]").val(d.Email);
						$(cloneTr).find("input[name=txtEmailSeq_p]").val(d.SeqID);
						$("div[name=trEmail_p]").last().after(cloneTr);
						i++;
					});
					if(i > 0) {
						$("div[name=trEmail_p]").eq(0).remove();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardEmail.do", response, status, error);
				});
				
				
			}
			else if("${TypeCode}" == "C") {
				$("#btnModify_c").css("display", "");
				$("#btnDelete_c").css("display", "");
				$("#btnRegist_c").css("display", "none");
				
				//$("#bizCardCompanyTab").trigger('click');
				
				 $.ajaxSetup({
				      async: false
				 }); 
				 
				 $.getJSON('/groupware/bizcard/getBizCardCompany.do', {'BizCardID' : "${BizCardID}"}, function(d) {
					d = d.company[0];
					if(d.ImagePath != ""&& d.ImagePath != undefined) {
						$("img[name=bizCardThumbnail]").eq(1).siblings('img').css('display','none');
						$("img[name=bizCardThumbnail]").eq(1).attr('src', (d.ImagePath)); //.replace('192.168.11.126', 'localhost')
						$("img[name=bizCardThumbnail]").eq(1).height("100%");
					}
					$("#txtCompanyName").val(d.ComName);
					$("#txtComRepName").val(d.ComRepName);
					
					$("#selGroup_c").removeAttr('disabled');
					$("#selGroup_c").val(d.GroupID == 'undefined' ? 'none' : d.GroupID);
					
					$("#txtAnniversary_c").val(d.AnniversaryText);
					$("#txtComWebsite").val(d.ComWebSite);
					$("#txtComZipCode").val(d.ComZipCode);
					$("#txtComAddress").val(d.ComAddress);
					$("#txtMemo_c").val(d.Memo.replaceAll("\\r\\n", "\r\n"));
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardCompany.do", response, status, error);
				});
				
				$.getJSON('/groupware/bizcard/getBizCardPhone.do', {'BizCardID' : "${BizCardID}", 'TypeCode' : 'C'}, function(d) {
					var i = 0;
					d.list.forEach(function(d) {
						var cloneTr = $("div[name=trPhone_c]").last().clone();
						$(cloneTr).find("select[name=selPhoneType_c]").val(d.PhoneType);
						$(cloneTr).find("input[name=txtPhoneNum_c]").val(d.PhoneNumber);
						$(cloneTr).find("input[name=txtPhoneSeq_c]").val(d.SeqID);
						$(cloneTr).insertAfter($("div[name=trPhone_c]").last());
						i++;
					});
					if(i > 0) {
						$("div[name=trPhone_c]").eq(0).remove();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardPhone.do", response, status, error);
				});
				
				$.getJSON('/groupware/bizcard/getBizCardEmail.do', {'BizCardID' : "${BizCardID}", 'TypeCode' : 'C'}, function(d) {
					var i = 0;
					d.list.forEach(function(d) {
						var cloneTr = $("div[name=trEmail_c]").last().clone();
						$(cloneTr).find("input[name=txtEmail_c]").val(d.Email);
						$(cloneTr).find("input[name=txtEmailSeq_c]").val(d.SeqID);
						$("div[name=trEmail_c]").last().after(cloneTr);
						i++;
					});
					if(i > 0) {
						$("div[name=trEmail_c]").eq(0).remove();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getBizCardEmail.do", response, status, error);
				});
				 
				if($("#selGroup_c").val() == null) {
					$("#selGroup_c").val("");
				}
			}
		} else{
			selDivisionChange($('#selDivision'));
		}
		
		$("[name=txtEmail_p]").on("change",function(){
			 var eMail = $(this).val().replace(/ /gi, '');
		     $(this).val(eMail);
		});
		
		// 직접입력
		$(document).on("change", "[name=selPhoneType_p]",function(){
			if($(this).val() == "D") {
				 $(this).closest(".formRow").find(".phoneName").show();
				 $(this).closest(".formRow").find("input[name=txtPhoneName_p]").val("");
			 } else {
				 $(this).closest(".formRow").find(".phoneName").hide();
			 }
		});
	});
	
	function setOnlyNum(obj) {
		var num = $(obj).val();
		num = num.replace(/[^0-9]/g, '');
		$(obj).val(num);
	}

	function setHyphen(obj) {
    	var num = $(obj).val();
		num = num.replace(/[^0-9]/g, '');
		
		var formatNum = '';
	    
	    if(num.length==11){
            formatNum = num.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
	    }else if(num.length==7){
	        formatNum = num.replace(/(\d{3})(\d{4})/, '$1-$2');
	    }else if(num.length==8){
	        formatNum = num.replace(/(\d{4})(\d{4})/, '$1-$2');
	    }else{
	        if(num.indexOf('02')==0){
                formatNum = num.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
	        }else{
                formatNum = num.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
	        }
	    }
		
		$(obj).val(formatNum);
	}
	
	var addRow = function(obj) {
		var clonetr = $(obj).closest('.formRow').clone();
		$(clonetr).find(".phoneName").hide();
		$(clonetr).find("input[type=text]").val("");
		$(obj).closest('.formRow').after(clonetr);
	}
	
	var delRow = function(obj) {
		var trlen = $("div[name=" + $(obj).closest('.formRow').attr('name') + "]").length ;
		
		if(trlen > 1) {
			$(obj).closest('.formRow').remove();
		} else {
			Common.Warning("<spring:message code='Cache.msg_RequiredOneLine'/>"); //최소 1개의 행이 필요합니다.
		}
	}
	
	var selDivisionChange = function(obj) {
		var ShareType = $(obj).val();
		
		if($("#selGroup_p").attr('disabled') != undefined) {
			$("#selGroup_p").removeAttr('disabled');
		}
		
		$("#txtNewGroupName_p").css("display", "none");
		$("#selGroup_p").find("option").remove();
		$("#selGroup_p").append('<option value="">' + "<spring:message code='Cache.lbl_SelectGroup2'/>" + '</option>'); //그룹 선택
		$("#selGroup_p").append('<option value="new">' + "<spring:message code='Cache.lbl_newGroup'/>" + '</option>'); //새 그룹
		
		$.ajaxSetup({
		     async: true
		});
		
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : ShareType}, function(d) {
			d.list.forEach(function(d) {
				$("#selGroup_p").append('<option value="' + d.GroupID + '">' + d.GroupName + '</option>');
			});
			$("#selGroup_p").append('<option value="none">' + "<spring:message code='Cache.lbl_NoGroup'/>" + '</option>'); //그룹 없음
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
	}
	
	var selGroupChange =  function(obj) {
		var selValue = $(obj).val();
		var type = $(obj).attr('id').split('_')[1];
		
		if(selValue == "new") {
			$("#txtNewGroupName_" + type).css("display", "");
		} else {
			$("#txtNewGroupName_" + type).css("display", "none");
		}
	}
	
	function clickBizCardImage(obj) {
		$(obj).siblings("input[name=addFile]").trigger('click');
	}
	
	function changeBizCardImage(obj) {
		var ext = $(obj).val().split('.').pop().toLowerCase();

		if($.inArray(ext, ['gif','png','jpg','jpeg']) == -1) {
			Common.Warning("<spring:message code='Cache.msg_bizcard_onlyUploadJPGFiles'/>");	
			return;
		}
		$(obj).siblings("input[type=text]").val($(obj).val());
		getThumbnail($(obj) ,$(obj).siblings("div").find('img[name=bizCardThumbnail]'));
	}
	
	function getThumbnail(html, target) {
	    if (html[0].files && html[0].files[0]) {
	        var reader = new FileReader();
	        reader.onload = function (e) {
	        	$(target).siblings('img').css('display','none');
	            $(target).attr('src', e.target.result);
	            $(target).css('height', "100%");
	        }
	        reader.readAsDataURL(html[0].files[0]);
	        $(html).siblings('input[type=text]').val(html[0].value);
	    }
	}
	
	function clickAddAnniversary(obj) {
		Common.Inform("<spring:message code='Cache.msg_bizcard_preparingService'/>");
	}
	
	var registBizCard = function() {
		var TypeCode = "P";		
		var bReturn = checkValidation(TypeCode);
		
	    if(!bReturn) return false;
		
		$.ajaxSetup({
		     async: true
		});

		var PhoneType = "";
		var PhoneNumber = "";
		var PhoneName = "";
		var Email = "";
		var formData;
		var url = "";
		var message = "<spring:message code='Cache.msg_SuccessRegist'/>" //정상적으로 등록되었습니다.
		
		if(TypeCode == "P") {
			$("div[name=trPhone_p]").each(function(i){
				PhoneType += $("select[name=selPhoneType_p]").eq(i).val() + ";";
				PhoneNumber += $("input[name=txtPhoneNum_p]").eq(i).val() + ";";
				PhoneName += $("input[name=txtPhoneName_p]").eq(i).val() + ";";
			});
			
			$("div[name=trEmail_p]").each(function(i){
				Email += $("input[name=txtEmail_p]").eq(i).val() + ";";
			});
			
			formData = new FormData();
			
			formData.append("TypeCode", TypeCode);
			formData.append("ShareType", $("#selDivision").val());
			formData.append("GroupID", $("#selGroup_p").val() == "none" ? "" : $("#selGroup_p").val() );
			formData.append("GroupName", $("#txtNewGroupName_p").val());
			formData.append("Name", $("#txtName").val());
			formData.append("MessengerID", $("#txtMessanger").val());
			formData.append("CompanyID", $("#txtCompanyID").val());
			formData.append("CompanyName", $("#txtCompanyName_p").val());
			formData.append("JobTitle", $("#txtJobTitle").val());
			formData.append("DeptName", $("#txtDept").val());
			formData.append("Memo", $("#txtMemo_p").val());
			formData.append("ImagePath", $("#txtImagePath_p").val());
			formData.append("FileInfo", $('input[name=addFile]')[0].files[0]);
			formData.append("PhoneType", PhoneType.slice(0, -1));
			formData.append("PhoneNumber", PhoneNumber.slice(0, -1));
			formData.append("PhoneName", PhoneName.slice(0, -1));
			formData.append("Email", Email.slice(0, -1));
			formData.append("AnniversaryText", $("#txtAnniversary_p").val());				
			
			url = "/groupware/bizcard/RegistBizCardPerson.do";
			if("${mode}" == "modify" || "${mode}" == "modifyPopup") {
				url = "/groupware/bizcard/ModifyBizCardPerson.do";
				message = "<spring:message code='Cache.msg_SuccessModify'/>"; //정상적으로 수정되었습니다.
				
				formData.append("BizCardID", "${BizCardID}");
			}
		} else if(TypeCode == "C") {
			$("div[name=trPhone_c]").each(function(i){
				PhoneType += $("select[name=selPhoneType_c]").eq(i).val() + ";";
				PhoneNumber += $("input[name=txtPhoneNum_c]").eq(i).val() + ";";
			});
			$("div[name=trEmail_c]").each(function(i){
				Email += $("input[name=txtEmail_c]").eq(i).val() + ";";
			});
			
			formData = new FormData();
			
			formData.append("TypeCode", TypeCode);
			formData.append("GroupID", $("#selGroup_c").val() == "none" ? "" : $("#selGroup_c").val() );
			formData.append("GroupName", $("#txtNewGroupName_c").val());
			formData.append("ComName", $("#txtCompanyName").val());
			formData.append("ComRepName", $("#txtComRepName").val());
			formData.append("ComWebsite", $("#txtComWebsite").val());
			formData.append("ComZipCode", $("#txtComZipCode").val());
			formData.append("ComAddress", $("#txtComAddress").val());
			formData.append("Memo", $("#txtMemo_c").val());
			formData.append("ImagePath", $("#txtImagePath_c").val());
			formData.append("FileInfo", $('input[name=addFile]')[1].files[0]);
			formData.append("PhoneType", PhoneType.slice(0, -1));
			formData.append("PhoneNumber", PhoneNumber.slice(0, -1));
			formData.append("Email", Email.slice(0, -1));
			formData.append("AnniversaryText", $("#txtAnniversary_c").val());
			
			url = "/groupware/bizcard/RegistBizCardCompany.do";
			if("${mode}" == "modify" || "${mode}" == "modifyPopup") {
				url = "/groupware/bizcard/ModifyBizCardCompany.do";
				message = "<spring:message code='Cache.msg_SuccessModify'/>" //정상적으로 수정되었습니다.
				
				formData.append("BizCardID", "${BizCardID}");
			}
		}
		
		$.ajax({
			url : url,
			type : "POST",
			data : formData,
			dataType : 'json',
	        processData : false,
	        contentType : false,
			success : function(d) {
				try {
					if(d.result == "OK") {
						Common.Inform(message, 'Information Dialog', function (result) {
							if("${mode}" == "search") {
								parent.$("iframe#SearchBizCardCompany_if").attr('src', "/groupware/bizcard/SearchBizCardCompanyPop.do"); 
								Common.Close();
							} else {
								if("${mode}" == "newPopup" || ("${mode}" == "regist")){
									Common.Close();
								}else if("${mode}" == "modifyPopup"){
									parent.refresh();
									Common.Close();
								}else{
									CoviMenu_GetContent('/groupware/layout/bizcard_BizCardPersonList.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard');
								}
							}
				        });
					} else if(d.result == "FAIL") {
						Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCard'/>"); //연락처 등록 오류가 발생했습니다.
					}
				} catch(e) {
					coviCmn.traceLog(e);
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	var checkValidation = function(TypeCode) {
		var bReturn = true;
		var type = (TypeCode == "P" ? "_p" : "_c");
		var array = "";
		var array1 = "";
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
	    if (TypeCode == "P" && $.trim($("#txtName").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterName'/>", "", function() {
		        $("#txtName").focus();
	        }); //이름을 입력하세요
	        bReturn = false;
	    } else if (TypeCode == "C" && $.trim($("#txtCompanyName").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterCompName'/>", "", function() {
		        $("#txtCompanyName").focus();
	        }); //회사명을 입력하세요
	        bReturn = false;
	    } else if (TypeCode == "C" && $.trim($("#txtComRepName").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterRepName'/>", "", function() {
		        $("#txtComRepName").focus();
	        }); //대표자명을 입력하세요
	        bReturn = false;
	    } else if (TypeCode == "P" && $.trim($("#selDivision").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_SelectDivision'/>", "", function() {
		        $("#selDivision").focus();
	        }); //분류를 지정하세요
	        bReturn = false;
	    } else if($("#selGroup" + type).val() == "new" && $.trim($("#txtNewGroupName" + type).val()) == "") {
	    	Common.Warning("<spring:message code='Cache.msg_EnterNewGroupName'/>", "", function() {
		    	$("#txtNewGroupName" + type).focus();
	    	}); //새 그룹명을 입력하세요
	        bReturn = false;
	    } else if($.trim($("#selGroup" + type).val()) == "") {
	    	Common.Warning("<spring:message code='Cache.msg_SelectGroup'/>", "", function() {
		    	$("#selGroup" + type).focus();
	    	}); //그룹을 선택하세요
	        bReturn = false;
	    } else { 
	    	$("div[name=trPhone" + type +"]").each(function(i) {
	    		if($.trim($("select[name=selPhoneType" + type +"]").eq(i).val()) == "") {
	    			if($.trim($("input[name=txtPhoneNum" + type +"]").eq(i).val()) == "") {
	    				array += (i+1) + ",";
	    			} else {
	    				Common.Warning((i+1) + "<spring:message code='Cache.msg_SelectPhoneType'/>", ""); //번째 전화 유형을 선택하세요
	    				bReturn = false;
	    			}
	    		} else if($.trim($("select[name=selPhoneType" + type +"]").eq(i).val()) != "") { 
	    			if($.trim($("select[name=selPhoneType" + type +"]").eq(i).val()) == "D") {
	    				if($.trim($("input[name=txtPhoneName" + type +"]").eq(i).val()) == "") {
					    	Common.Warning((i+1) + "<spring:message code='Cache.msg_EnterPhoneName'/>", ""); //번째 직접입력 항목의 값을 입력하세요.
					        bReturn = false;
	    				}
	    			}	
	    			
	    			if($.trim($("input[name=txtPhoneNum" + type +"]").eq(i).val()) == "") {
					   	Common.Warning((i+1) + "<spring:message code='Cache.msg_EnterPhoneNumber'/>", ""); //번째 전화번호를 입력하세요
					       bReturn = false;
	    			}
		    	}
	    	});
	    	
	    	if(array != "") {
	    		array = array.slice(0, -1);
	    		var arr = array.split(",");
	    		if($("div[name=trPhone" + type +"]").length == 1 && arr.length == 1){
	    			//Common.Warning("전화번호 행의 1번째 행이 입력되지 않았습니다.(필수)");
	    		} else {
	    			var minusNum = 1;
	    			bReturn = false;
			    	Common.Confirm("<spring:message code='Cache.lbl_PhoneNum'/>" + " " + array.replaceAll(",", ", ") + "<spring:message code='Cache.msg_NotEnteredWantDelete'/>", "", function(result) { //전화번호 ~번째 행은 입력되지 않은 행입니다. 삭제하시겠습니까?
						if(result) {
							$("div[name=trPhone" + type +"]").each(function(i){
								$(arr).each(function(j){
									if($("div[name=trPhone" + type +"]").length > 1 && i == arr[j]-minusNum) {
										$("div[name=trPhone" + type +"]").eq(arr[j]-minusNum).remove();
										minusNum++;
									}
								});
							});
							
							if($("div[name=trPhone" + type +"]").length-1 == arr[arr.length-1]-1) {
								$("div[name=trPhone" + type +"]").eq(arr[arr.length-1-1]).remove();
							}
						}
					});
	    		}
	    	}
	    	
	    	if(bReturn == true) {
		    	$("div[name=trEmail" + type +"]").each(function(i) {
	    			if($.trim($("input[name=txtEmail" + type +"]").eq(i).val()) == "") {
	    				array1 += (i+1) + ",";
	    			}else{
	    				//이메일 형식 체크
	    				var regex=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([A-Za-z]{2,6}(?:\.[A-Za-z]{2})?)$/;
	    				if(regex.test($("input[name=txtEmail" + type +"]").eq(i).val()) === false) {  
	    				    Common.Warning("<spring:message code='Cache.msg_bizcard_invalidEmailFormat'/>");  
	    				    bReturn = false;
	    				}
	    			}
		    	});
		    	
		    	if(array1 != "") {
		    		array1 = array1.slice(0, -1);
		    		var arr = array1.split(",");
		    		
		    		if($("div[name=trEmail" + type +"]").length == 1 && arr.length == 1){
		    			//Common.Warning("이메일 행의 1번째 행이 입력되지 않았습니다.(필수)");
		    		} else {
		    			var minusNum = 1;
		    			bReturn = false;
				    	Common.Confirm("<spring:message code='Cache.lbl_Email2'/>" + " " + array1.replaceAll(",", ", ") + "<spring:message code='Cache.msg_NotEnteredWantDelete'/>", "", function(result) { //이메일 ~번째 행은 입력되지 않은 행입니다. 삭제하시겠습니까?
							if(result) {
								$("div[name=trEmail" + type +"]").each(function(i){
									$(arr).each(function(j){
										if($("div[name=trEmail" + type +"]").length > 1 && i == arr[j]-minusNum) {
											$("div[name=trEmail" + type +"]").eq(arr[j]-minusNum).remove();
											minusNum++;
										}
									});
								});
								
								if($("div[name=trEmail" + type +"]").length-1 == arr[arr.length-1]-1) {
									$("div[name=trEmail" + type +"]").eq(arr[arr.length-1-1]).remove();
								}
							}
						});
		    		}
		    	}
		    }
	    }
	    
	    return bReturn;
	}
	
	var modifyBizCard = function() {
		registBizCard();
	}
	
	var deleteBizCard = function() {
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Information Dialog", function(result) { 
			if(result) {
				if("${BizCardID}" != "" && "${BizCardID}" != undefined) {
					var TypeCode = "P";
					/*
					if($("#bizCardPersonTab").parent().hasClass('active')) TypeCode = "P";
					else if($("#bizCardCompanyTab").parent().hasClass('active')) TypeCode = "C";
					*/
					$.ajaxSetup({
					     async: true
					});
					
					$.ajax({
						url : "/groupware/bizcard/DeleteBizCard.do",
						type : "POST",
						data : {
							"BizCardID" :  "${BizCardID}",
							"TypeCode" :  TypeCode
						},
						success : function(d) {
							try {
								if(d.result == "OK") {
									Common.Inform("<spring:message code='Cache.msg_deletedOK'/>", 'Information Dialog', function (result) { //정상적으로 삭제되었습니다.
										if("${mode}" == "modifyPopup"){
											parent.refresh();
											Common.Close();
										}else{
											CoviMenu_GetContent('/groupware/layout/bizcard_BizCardPersonList.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard');
										}
										
							        }); 
								} else if(d.result == "FAIL") {
									Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); //오류가 발생했습니다.
								}
							} catch(e) {
								coviCmn.traceLog(e);
							}
						},
						error:function(response, status, error){
						     //TODO 추가 오류 처리
						     CFN_ErrorAjax("DeleteBizCard.do", response, status, error);
						}
					});
				}
			}
		});		
	}
	
	var closeBizCard = function() {
		//event.preventDefault();
		
		if (document.referrer) { // 뒤로가기
			window.history.back();
		}		
		else { // 히스토리가 없으면, 메인 페이지로
			window.location.href='bizcardhome.do';
		}
	}
	
	var searchBizCardCompany = function(obj) {
		Common.open("", "SearchBizCardCompany", "<spring:message code='Cache.lbl_bizcard_inquiryCompanyList'/>", "/groupware/bizcard/SearchBizCardCompanyPop.do?IsPopup=true", "800px", "500px", "iframe", true, null, null, true);		
		return;
	}
</script>