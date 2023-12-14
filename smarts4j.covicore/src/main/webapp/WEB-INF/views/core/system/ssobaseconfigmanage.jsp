<%@page import="java.util.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String appPath = request.getContextPath(); %>

<script type="text/javascript">
	
	$(document).ready(function (){
		setSelect();
		setSelectData("");
		clickTab($("#ssomanage"));
	});
	
	// Select Box 바인드
	function setSelect(){
		$("#add_server").bindSelect({
			  reserveKeys: {
	                optionValue: "value",
	                optionText: "name"
	            },
	            options:[{"name":"Covi SSO", "value":"1"}, {"name":"New Covi SSO", "value":"2"}],
				ajaxAsync:false
        });
	} 
	
	//Selct box 데이터 세팅. 기초 코드 값
	function setSelectData(type){
			$.ajax({
				type:"POST",
				data:{
					"type" : type
				},
				url:"selectonessobaseconfig.do",
				success:function (data) {
					data.list.forEach(function(value, index){
						if("sso_server" == value.Code){
							$("#add_server").bindSelectSetValue(value.SettingValue);
						}else if("sso_expiration_day"  == value.Code){
							$("#add_day").val(value.SettingValue);
							$("#day_descript").text(value.Description);
						}else if("sso_storage_path"  == value.Code){
							$("#add_path").val(value.SettingValue);
						}else if("sso_sp_url"  == value.Code){
							$("#saml_url").val(value.SettingValue);
						}else if("sso_spacs_url"  == value.Code){
							$("#saml_acs").val(value.SettingValue);
						}else if("sso_rs_url"  == value.Code){
							$("#saml_rs").val(value.SettingValue);
						}else if("sso_goclient_id"  == value.Code){
							$("#oauth_gci").val(value.SettingValue);
						}else if("sso_goclient_key"  == value.Code){
							$("#oauth_gck").val(value.SettingValue);
						}else if("sso_goauthorize_url"  == value.Code){
							$("#oauth_gau").val(value.SettingValue);
						}else if("sso_response_type"  == value.Code){
							$("#oauth_grt").val(value.SettingValue);
						}else if("sso_redirect_url" == value.Code){
							$("#oauth_gru").val(value.SettingValue);
						}
					});
					if(type == "" || type == "O"){
						if(data.clientid == "" || data.clientid == null || data.clientid == undefined){
							$("#oauth_ci").text("");
							$("#oauth_ck").text("");
							$("#oauth_cn").val(data.clientname);
							$("#oauth_ru").val(data.redirectUri);
							
							$("#oauth_cn").hide();
							$("#oauth_ru").hide();
						}else{
							$("#oauth_ci").text(data.clientid);
							$("#oauth_ck").text(data.clientsecret);
							$("#oauth_cn").val(data.clientname);
							$("#oauth_ru").val(data.redirectUri);
							
							$("#oauth_cn").show();
							$("#oauth_ru").show();
						}

					}
				
				},
				error:function(response, status, error){
					CFN_ErrorAjax("selectonessobaseconfig.do", response, status, error);
				}
			});
	}
	
	function goReset(type){
		setSelectData(type);
	}
	
	function modifySubmit(){
		if(RequiredCheck("C")) {
			
			var path =  $("#add_path").val();
			var server = $("#add_server option:selected").val();
			var day = $("#add_day").val();
			
			//update 호출
			$.ajax({
				type:"POST",
				data:{
					"Path" : path,
					"Server" : server, 
					"Day" : day
				},
				url:"updatessobaseconfig.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_Edited'/>");
					}
					goReset("C");
				},
				error:function(response, status, error){
					CFN_ErrorAjax("updatessobaseconfig.do", response, status, error);
				}
			}); 
		}
	}
	
	function RequiredCheck(type){

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if(type == "C"){
			if($("#add_day").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_RequiredTokenDay'/>");
				return false;
			}else if($("#add_path").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_RequiredCertificatePath'/>"); 
				return false;
			}else{
				return true;
			}
		}else if(type == "S"){
			if($("#saml_rs").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_RequiredRelayState'/>"); 
				return false;
			}else if($("#saml_url").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_RequiredSpUrl'/>"); 
				return false;
			}else if($("#saml_acs").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_Required'/>"); 
				return false;
			}else{
				return true;
			}
		}else if(type == "O"){
			return true;
		}
	}
	
	function clickTab(pObj){
		$(".AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");

		var str = $(pObj).attr("value");
		
		$("#sso").hide();
		$("#saml").hide();
		$("#oauth").hide();
		
		$("#" + str).show();
		
		/* if(str == "sso"){
			goReset("C");
		}else if(str == "saml"){
			goReset("S");
		}else{
			goReset("O");
		} */
	}
	
	function smodifySubmit(){
		if(RequiredCheck("S")) {
			
 			var samlUrl = $("#saml_url").val();
			var acsUrl = $("#saml_acs").val();
			var rsUrl = $("#saml_rs").val(); 
			
			//update 호출
			$.ajax({
				type:"POST",
				data:{
					"Url" : samlUrl,
					"AcsURL" : acsUrl,
					"RsURL" : rsUrl 
				},
				url:"updatesamlbaseconfig.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_Edited'/>");
					}
					goReset("S");
				},
				error:function(response, status, error){
					CFN_ErrorAjax("updatessobaseconfig.do", response, status, error);
				}
			}); 
		}
	}
	
	function omodifySubmit(){
		if(RequiredCheck("O")) {
			
			var client_id =  $("#oauth_gci").val();
			var client_key = $("#oauth_gck").val();
			var authorize_url = $("#oauth_gau").val();
			var response_type =  $("#oauth_grt").val();
			var redirect_url = $("#oauth_ru").val(); 
			var client_name = $("#oauth_cn").val();
			var redirect_rurl = $("#oauth_gru").val();
			//update 호출
			$.ajax({
				type:"POST",
				data:{
					"clientId" : client_id,
					"clientKey" : client_key, 
					"authorizeUrl" : authorize_url,
					"responseType" : response_type,
					"redirectUrl" : redirect_url,
					"clientName" : client_name,
					"redirectGoogleUrl" : redirect_rurl
				},
				url:"updateoauthbaseconfig.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_Edited'/>");
					}
					goReset("O");
				},
				error:function(response, status, error){
					CFN_ErrorAjax("updatessobaseconfig.do", response, status, error);
				}
			}); 
		}	
	}
	function cKeyAdd(){
		var redirect_url = $("#oauth_ru").val();
		$.ajax({
			type:"POST",
			data:{
				"redirectUrl" : redirect_url
			},
			url:"createoauthbaseconfig.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_oauthCreateKey'/>"); 
				}else if(data.result == "exists"){
					Common.Warning("<spring:message code='Cache.msg_oauthKeyExists'/>"); 
				}
				goReset("O");
			},
			error:function(response, status, error){
				CFN_ErrorAjax("createoauthbaseconfig.do", response, status, error);
			}
		}); 
	}
	function cKeyDel(){
		$.ajax({
			type:"POST",
			data:{
			},
			url:"deleteoauthbaseconfig.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_oauthDelKey'/>");
				}
				goReset("O");
			},
			error:function(response, status, error){
				CFN_ErrorAjax("deleteoauthbaseconfig.do", response, status, error);
			}
		}); 
	}
	
</script>
    
<h3 class="con_tit_box">
     <span class="con_tit"><spring:message code="Cache.lbl_ssotitle"/></span>
</h3>
<form id="form1">
	<div class="AXTabs">
		<div class="AXTabsTray" style="height:30px">
			<a id="ssomanage" href="#" onclick="clickTab(this);" class="AXTab on" value="sso">SSO</a>
			<a id="ssosaml" href="#" onclick="clickTab(this);" class="AXTab" value="saml">SAML</a>
			<a id="ssooauth" href="#" onclick="clickTab(this);" class="AXTab" value="oauth">OAuth</a>
		</div>
		<div id="sso">	
			<table class="AXFormTable" style="margin-top: 15px;border-top: 1px solid #dddddd;">
				<tr>
					<th style="width: 145px;"><font color="red">* </font>Authentication server</th>
					<td>
						<select id="add_server" class="AXSelect" style="width: 200px; height: 26px;"></select>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Token Expiration Date</th>
					<td>
						<input type="text"  mode="numberint" max_length="2" num_max="30" id="add_day" name="add_day" style="width:50%;height:25px;" class="AXInput av-required"/> <span style="margin-left: 5px;" id="day_descript"></span>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Certificate Path</th>
					<td>
						<input type="text" maxlength="240" id="add_path" name="add_path" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
			</table> 
			<div align="center" style="padding-top: 10px">
				<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifySubmit();" class="AXButton" />
				<input type="button" value="<spring:message code="Cache.btn_Cancel"/>" onclick="goReset('C');"  class="AXButton" />
			</div>
		</div>
		<div id="saml" style="height:500px">
			<table class="AXFormTable" style="margin-top: 15px;border-top: 1px solid #dddddd;">
				<tr>
					<th style="width: 145px;"><font color="red">* </font>RelayState</th>
					<td>
						<input type="text" maxlength="240" id="saml_rs" name="saml_rs" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>SP URL</th>
					<td>
						<input type="text" maxlength="240" id="saml_url" name="saml_url" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>ACS URL</th>
					<td>
						<input type="text" maxlength="240" id="saml_acs" name="saml_acs" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
			</table> 
			<div align="center" style="padding-top: 10px">
				<input type="button" id="btn_smodify" value="<spring:message code="Cache.btn_Edit"/>" onclick="smodifySubmit();" class="AXButton" />
				<input type="button" value="<spring:message code="Cache.btn_Cancel"/>" onclick="goReset('S');"  class="AXButton" />
			</div>
		</div>
		<div id="oauth" style="height:500px">
			<ul style="margin-bottom: 10px;">
			</ul>
			<b>Google</b>
			<table class="AXFormTable" style="margin-top: 5px;margin-bottom: 10px;border-top: 1px solid #dddddd;">
				<tr>
					<th style="width: 145px;"><font color="red">* </font>Google Client ID</th>
					<td>
						<input type="text" maxlength="240" id="oauth_gci" name="oauth_ci" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Google Client Key</th>
					<td>
						<input type="text" maxlength="240" id="oauth_gck" name="oauth_gck" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Google Authorize URL</th>
					<td>
						<input type="text" maxlength="240" id="oauth_gau" name="oauth_gau" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Google Response Type</th>
					<td>
						<input type="text" maxlength="240" id="oauth_grt" name="oauth_grt" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Google Redirect URL</th>
					<td>
						<input type="text" maxlength="240" id="oauth_gru" name="oauth_gru" style="width:50%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					</td>
				</tr>
			</table>
			<b>OAuth</b>
			<table class="AXFormTable" style="margin-top: 5px;border-top: 1px solid #dddddd;">
				<tr>
					<th style="width: 145px;"><font color="red">* </font>Client ID</th>
					<td style="height: 30px;">
						<span id="oauth_ci"></span>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Client Key</th>
					<td style="height: 30px;">
						<span id="oauth_ck"></span>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Redirect URL</th>
					<td style="height: 30px;">
						<input type="text" maxlength="240" id="oauth_ru" name="oauth_ru" style="width:50%;height:25px;" class="AXInput av-required"/>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>Client Name</th>
					<td style="height: 30px;">
						<input type="text" maxlength="240" id="oauth_cn" name="oauth_cn" style="width:50%;height:25px;" class="AXInput av-required"/>
					</td>
				</tr>
			</table> 
			<div align="center" style="padding-top: 10px">
				<input type="button"  value="<spring:message code="Cache.msg_oauthKeyCreated"/>" onclick="cKeyAdd();" class="AXButton" />
				<input type="button"  value="<spring:message code="Cache.msg_oauthKeyDeleted"/>" onclick="cKeyDel();" class="AXButton" />
				<input type="button" id="btn_omodify" value="<spring:message code="Cache.btn_Edit"/>" onclick="omodifySubmit();" class="AXButton" />
				<input type="button" value="<spring:message code="Cache.btn_Cancel"/>" onclick="goReset('O');"  class="AXButton" />
			</div>
		</div>
	</div>
</form>
</section>
