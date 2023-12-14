<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_manage_passwordPolicy'/><!-- 암호정책 관리 --></h2>	
</div>		

<div class="cRContBottom mScrollVH">
<form id="form1">
	<div class="sadminContent">
		<table class="sadmin_table pwPolicy">
			<colgroup>
				<col width="200px;">
				<col width="*">
			</colgroup>
			<covi:admin>
			<tr>
				<th><spring:message code='Cache.lbl_passwordComplexity'/></th><!-- 암호 복잡성 -->
				<td>
					<select id="selectPasswordIsUse" class="selectType02"></select> 
					<span><span class="thstar">*</span> <spring:message code='Cache.msg_ChangePasswordDSCR05'/></span><!-- 동일 문자 연속 3개 이상, 동일 숫자 3개 이상은 사용 불가 -->
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_max_passwordAge'/></th><!-- 최대 암호 사용 기간 -->
				<td>
					<input type="text" id="maxpasswduseddate"  /> <spring:message code='Cache.lbl_day'/><!-- 일 --> (1 ~ 365)
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_minimum_passwordLength'/></th><!-- 최소 암호 길이 -->
				<td>
					<input type="text" id="minpasswdlen" /> <spring:message code='Cache.lbl_Char'/> (4 ~ 20)
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_PwdChangeNoticeTerm'/></th> <!-- 암호변경 공지기간  -->
				<td>
					<input type="text" id="passwdrenewal"  /> <spring:message code='Cache.lbl_day'/><!-- 일 --> (1 ~ 30)
					<span><span class="thstar">*</span> <spring:message code='Cache.msg_ChangePasswordDSCR15'/></span><!-- 최대암호 사용기간의 [공지기간] 전 부터 비밀번호 변경을 유도합니다. -->
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_PwdSpecialCharTerm'/></th> <!-- 특수문자정책  -->
				<td>
					<input type="text" id="specialCharacterPolicy" style="text-align:left" />
					<span><span class="thstar">*</span> <spring:message code='Cache.msg_ChangePasswordDSCR16'/></span><!-- 비밀번호 설정시 입력한 특수문자를 포함하여야 합니다. (암호 복잡성 사용시) -->
				</td>
			</tr>
			
			</covi:admin>
			<tr>
				<th><spring:message code='Cache.lbl_initPassword'/></th> <!-- 초기 비밀번호  -->
				<td>
					<input type="text" id="initPassword" style="text-align:left" />
					<span></span><!-- (기본값 : 그룹사 설정 참조) 계정 신규생성시 초기 비밀번호로 사용됩니다. (관리자 패스워드 초기화시 사용됨.) -->
				</td>
			</tr>
			<covi:admin>
			<tr>
				<th><spring:message code='Cache.lbl_loginFailCount'/></th> <!-- 비밀번호 오류 횟수  -->
				<td>
					<input type="text" id="loginFailCount"/>
					<span></span><!-- (기본값 : 그룹사 설정 참조) 최소 3이상, 입력횟수 만큼 비밀번호를 틀릴 경우 계정 잠금 처리 됩니다. -->
				</td>
			</tr>
			</covi:admin>
		</table>
		<div class="bottomBtnWrap">
			<a id="btnSave" class="btnTypeDefault" ><spring:message code='Cache.lbl_Save'/></a>
			<a id="btnRefresh" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_Refresh'/></a>
		</div>
	</div>
</form>
</div>
<script>
var confPolicy = {
		initContent:function(){
			<covi:admin>
			$("#maxpasswduseddate").validation("onlyNumber").validation("limitChar",3);
			$("#minpasswdlen").validation("onlyNumber").validation("limitChar",2);
			$("#passwdrenewal").validation("onlyNumber").validation("limitChar",2);
			$("#loginFailCount").validation("onlyNumber");
			</covi:admin>
			$("#btnRefresh").on("click",function(){
				confPolicy.getData();
			});
			
			$("#btnSave").on("click",function(){
				confPolicy.goSave();
			});
			
			$.ajax({
				type:"POST",
				data:{
					domainID : confMenu.domainId
				},
				async : true,
				url:"/covicore/passwordPolicy/getSelectPolicyComplexity.do",
				success:function (e1) {
					var HTML = "";
					$("#selectPasswordIsUse").html("");
					if(e1.list.length > 0){
						$(e1.list).each(function(ii,vv){
							HTML += '<option value="'+vv.Code+'"  >'+vv.CodeName+'</option>';
		    			});
					}
					$("#selectPasswordIsUse").append(HTML);
					confPolicy.getData();
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/passwordPolicy/getSelectPolicyComplexity.do", response, status, error);
				}
			}); 	
		},
		getData:function(){
			$.ajax({
				type:"POST",
				data:{
					domainID : confMenu.domainId
				},
				async : true,
				url:"/covicore/passwordPolicy/getPolicy.do",
				success:function (e3) {
					var defaultFailCount = 0;
					var defaultInitPassword = "";
					
					if(e3.list.length > 0){
						$(e3.list).each(function(i3,v3){
							$("#selectPasswordIsUse").val(v3.IsUseComplexity);
							$("#maxpasswduseddate").val(v3.MaxChangeDate);
							$("#minpasswdlen").val(v3.MinimumLength);
							$("#passwdrenewal").val(v3.ChangeNoticeDate);
							$("#specialCharacterPolicy").val(v3.SpecialCharacterPolicy);
		    			});
					}else{
						$("#selectPasswordIsUse").val("0");
						$("#maxpasswduseddate").val("");
						$("#minpasswdlen").val("");
						$("#passwdrenewal").val("");
						$("#specialCharacterPolicy").val("");
					}
					// 초기 비밀번호 , 비밀번호 오류 횟수
					$(e3.settingVal).each(function(i3,v3){
						defaultFailCount = v3.DefaultFailCount;			//그룹사 설정 참조
						defaultInitPassword = v3.DefaultInitPassword;	//그룹사 설정 참조
						
						if(v3.InitPassword != null && v3.InitPassword.length > 0 && v3.InitPassword != ""){
							$("#initPassword").val(v3.InitPassword);
						}else{
							$("#initPassword").val("");
						}
						if(v3.LoginFailCount != null && v3.LoginFailCount.length > 0 && v3.LoginFailCount != ""){
							$("#loginFailCount").val(v3.LoginFailCount);
						}else if(defaultFailCount != null && defaultFailCount.length > 0 && defaultFailCount != ""){
							$("#loginFailCount").val("");
						}else{
							defaultFailCount = Common.getSecurityProperties("privacy.secure.login.count");  //property 설정 참조
						}
		    		});
					$("#initPassword").next().html("<span class='thstar'>*</span> "+Common.getDic("msg_ChangePasswordDSCR17").replace("{0}",defaultInitPassword));
					$("#loginFailCount").next().html("<span class='thstar'>*</span> "+Common.getDic("msg_ChangePasswordDSCR18").replace("{0}",defaultFailCount));
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/passwordPolicy/getPolicy.do", response, status, error);
				}
			}); 
		},
		goSave:function(){
			const korean = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
			const enNumber = /[a-zA-Z0-9]/;
			
			if($("#maxpasswduseddate").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_enter_max_passwordAge'/>", "Warning", function(){ /* 최대 암호 사용 기간을 입력하세요.  */
					$("#maxpasswduseddate").focus();
				}); 
				return ;
			}
			
			if($("#minpasswdlen").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_enter_minimum_passwordLength'/>", "Warning", function(){ /* 최소 암호 길이를 입력하세요.  */
					$("#minpasswdlen").focus();
				}); 
				return ;
			}
			
			if($("#passwdrenewal").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_enter_PwdChangeNoticeTerm'/>", "Warning", function(){ /* 암호변경 공지기간을 입력하세요.  */
					$("#passwdrenewal").focus();
				}); 
				return ;
			}
			
			/* 특수문자가 포함되어있는 복잡성을 선택했을 경우 필수 체크  */
			var selectedValue = $("#selectPasswordIsUse").val();

			if (selectedValue === "2" || selectedValue === "3") {
				if($("#specialCharacterPolicy").val() == ""){
					Common.Warning("<spring:message code='Cache.msg_enter_specialCharacterPolicy'/>", "Warning", function(){ /* 특수문자를 입력하여 주십시오. */ 
						$("#specialCharacterPolicy").focus();
					}); 
					return ;
				}else if($("#specialCharacterPolicy").val().indexOf("|") > -1){
					Common.Warning(String.format("<spring:message code='Cache.msg_noEnter_specialCharacterPolicy'/>", "|(pipeline)"), "Warning", function(){ /* {0} 특수문자는 사용할 수 없습니다 */ 
						$("#specialCharacterPolicy").focus();
					}); 
					return ;
				}else if(korean.test($("#specialCharacterPolicy").val()) || enNumber.test($("#specialCharacterPolicy").val())){
					Common.Warning("<spring:message code='Cache.msg_noEnter_anyOtherCharacter'/>", "Warning", function(){ /* 특수문자 이외의 다른 문자는 사용할 수 없습니다.  */ 
						$("#specialCharacterPolicy").focus();
					}); 
					return ;
				}else if($("#specialCharacterPolicy").val().length < 3){
					Common.Warning(String.format("<spring:message code='Cache.msg_enter_moreCharacter'/>", 3), "Warning", function(){ /* {0}개 이상의 특수문자를 입력해주세요. */ 
						$("#initPassword").focus();
					}); 
					return ;
				}
			}
			
			if($("#initPassword").val().indexOf("|") > -1){
				Common.Warning(String.format("<spring:message code='Cache.msg_noEnter_specialCharacterPolicy'/>", "|(pipeline)"), "Warning", function(){ /* {0} 특수문자는 사용할 수 없습니다 */ 
					$("#initPassword").focus();
				}); 
				return ;
			}else if(korean.test($("#initPassword").val())){
				Common.Warning("<spring:message code='Cache.msg_KoreanNotAllowed'/>", "Warning", function(){ /* 한글은 사용할 수 없습니다.  */
					$("#initPassword").focus();
				}); 
				return ;
			}else if($("#initPassword").val() == "" && confMenu.domainId == "0"){
				Common.Warning("<spring:message code='Cache.CUCT_171'/> <spring:message code='Cache.msg_blankValue'/>", "Warning", function(){ /* 그룹사(공용) 빈값을 입력할 수 없습니다.  */
					$("#initPassword").focus();
				}); 
				return ;
			}
			
			if($("#loginFailCount").val() != "" && $("#loginFailCount").val() < 3){
				Common.Warning(String.format("<spring:message code='Cache.msg_enter_moreLoginFailCount'/>", 3), "Warning", function(){ /* 비밀번호 오류 횟수는 최소 {0} 이상의 값을 입력해 주세요.  */ 
					$("#loginFailCount").focus();
				}); 
				return ;
			}
			
			if($("#maxpasswduseddate").val() < 1 || $("#maxpasswduseddate").val() > 365){
				Common.Warning(String.format("<spring:message code='Cache.msg_check_inputRange'/>", 1, 365), "Warning", function(){ /* {0}부터 {1} 사이의 값만 입력할 수 있습니다.  */
					$("#maxpasswduseddate").focus();
				}); 
				return ;
			}
			
			if($("#minpasswdlen").val() < 4 || $("#minpasswdlen").val() > 20){
				Common.Warning(String.format("<spring:message code='Cache.msg_check_inputRange'/>", 4, 20), "Warning", function(){ /* {0}부터 {1} 사이의 값만 입력할 수 있습니다.  */
					$("#minpasswdlen").focus();
				}); 
				return ;
			}
			
			
			if($("#passwdrenewal").val() < 1 || $("#passwdrenewal").val() > 30){
				Common.Warning(String.format("<spring:message code='Cache.msg_check_inputRange'/>", 1, 30), "Warning", function(){ /* {0}부터 {1} 사이의 값만 입력할 수 있습니다.  */
					$("#passwdrenewal").focus();
				}); 
				return ;
			}
			
			if(($("#maxpasswduseddate").val() - $("#passwdrenewal").val()) <= 0){
				Common.Warning(String.format("<spring:message code='Cache.msg_check_max_passwordAge'/>", 1, 30)); /* 최대 암호 사용 기간은  암호변경 공지기간보다 길어야합니다. */
				
				return ;
			}
			
			Common.Confirm("<spring:message code='Cache.msg_RUSave'/>" , "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						url:"/covicore/passwordPolicy/updatePasswordPolicy.do",
						type:"post",
						data:{
							domainID : confMenu.domainId,
							complexity : $("#selectPasswordIsUse").val(),
							maxChangeDate : $("#maxpasswduseddate").val(),
							minmumLength : $("#minpasswdlen").val(),
							changeNotIceDate : $("#passwdrenewal").val(),
							specialCharacterPolicy : $("#specialCharacterPolicy").val(),
							initPassword : $("#initPassword").val(),
							loginFailCount : $("#loginFailCount").val()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								coviCmn.reloadCache("BASECONFIG", confMenu.domainId); //초기 비밀번호, 비밀번호 오류 횟수 기초설정값 캐시 적용
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_38'/>" );
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/passwordPolicy/updatePasswordPolicy.do", response, status, error); 
						}
					}); 
				}
				
			});
		}
}
window.onload = confPolicy.initContent();
</script>
