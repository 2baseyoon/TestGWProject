<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>

<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi">
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js"></script>
<script type="text/javascript" language="javascript">
	var loginState = "${loginState}";  //로그인 실패 시 fail 로 넘어옴.
	var samlLogin = "${samlLogin}";
	var ssoType = "${ssoType}";
	var samlRequest = "${samlRequest}";
	
	$(document).ready(function () {
	
		if(ssoType == "0"){
			$("#checkSSO").hide();
		}
		if(samlRequest != null && samlRequest != ""){
			$("#checkSSO").hide();
		}
		
		if(loginState == "fail"){
			Common.Warning("<spring:message code='Cache.msg_login_fail'/>","ERROR",function(){
				location.href='/covicore/login.do';
			});
		}

		$("#id").val("");
		$("#password").val("");

		$("#id").hide();
		$("#password").hide();

		$("#idtemp").focus(function () {
			$("#idtemp").hide();
			$("#id").show();

			$("#id").focus();
		});

		$("#passwordtemp").focus(function () {
			$("#passwordtemp").hide();
			$("#password").show();

			$("#password").focus();
		});

		$("#id").blur(function () {
			if($("#id").val() == ""){
				$("#id").hide();
				$("#idtemp").show();
			}
		});

		$("#password").blur(function () {
			if($("#password").val() == ""){
				$("#password").hide();
				$("#passwordtemp").show();
			}
		});

		//쿠키
		var cookieID = CFN_GetCookie("loginId");
		if(cookieID!=""){
			$("#id").val(cookieID);
		}

	});

	function submit(){
		if(bool_Check()){
			$("#langSelect").val($("#ddlM_Language option:selected").val());
			$("form").submit();
		}
	}
	function bool_Check() {
	    var bReturn = true;
		if (($("#id").val() == "아이디") ||($("#id").val() == "")) {
	    	bReturn = false;
	    	Common.Warning("<spring:message code='Cache.msg_enter_ID'/>","ERROR");
	    } else if (($("#password").val() == "비밀번호") ||($("#password").val() == "")) {
	    	bReturn = false;
	    	Common.Warning("<spring:message code='Cache.msg_enter_PW'/>","ERROR");
	    }
		return bReturn;
	}

	$("#chkM_SavedInfo").click(function(){
		if($("#chkM_SavedInfo").is("checked") == true){
			var loginVal = $("#id").val();
			CFN_SetCookieDate("loginId",loginVal);
			return;
		}else{
			CFN_DelCookie("loginId");
			return;
		}
	});
	
	$("#chkM_SSOInfo").click(function(){
		if($("#chkM_SSOInfo").is("checked") == true){
			
			return;
		}else{
			$("#frm").attr("method","POST")
			$("#frm").attr("action", "samlLogin.do");
			$("#frm").submit();	
			return;
		}
	});
	
	/* function setCookieID(){
		if($("#chkM_SavedInfo").is("checked") == true){
			var loginVal = $("#id").val();
			CFN_SetCookieDate("loginId",loginVal);
			return;
		}else{
			CFN_DelCookie("loginId");
			return;
		}

	} */
	
	function loginChk(){
		
		var url = "";
		var suUrl = "";
	
		if(samlLogin == "Y"){
			url = "loginbasechk.do";
			suUrl = "samlloginchk.do";
			
		}else{
			url = "loginbasechk.do";
			suUrl = "loginchk.do";
		}
		
		if(bool_Check()){
			
			$.ajax({
				method: "POST",
			    data: {id : $("#id").val(), pw : $("#password").val(), language : $(".langSelect").val()},
				url: url,
				success:function (data) {
					 if(data.result =="ok"){
						
						$("#frm").attr("method","POST")
						$("#frm").attr("action", suUrl);
						$("#frm").submit();		
					 }else{
						Common.Warning("<spring:message code='Cache.msg_login_fail'/>","ERROR");
						return ;
					 }
				
				}
			
			}); 
			
		}
	}
	
</script>
</head>
	<body>
	<%-- 	<form action="loginchk.do" method="post" onsubmit="setCookieID();submit();"> --%>
		<form method="post" id="frm">
			<input type="hidden" id="RelayState" name="RelayState" value="${relayState}"/>
			<input type="hidden" id="SamlRequest" name="SamlRequest" value="${samlRequest}"/>
			<input type="hidden" id="uid" name="uid" value="${uid}"/>
			<input type="hidden" id="acr" name="acr" value="${acr}"/>
            <div>
                <div class="login">
                    <header>
                        <h1><img src="/smarts4j/mobile/Base/images/logo_login.png" alt="coviMobile"></h1>
                    </header>
                    <section>
                        <article>
	                        <div class="login_box">
                                <table class="login_t" cellpadding="0" cellspacing="0">
		                            <thead>
			                            <tr>
			                                <td height="30" align="left"><span class="log_title_txt">로그인</span></td>
			                            </tr>
			                            <tr>
			                                <td height="2" align="left"><img src="/smarts4j/mobile/Base/images/login_box_line.png" alt="" class="login_box_line"></td>
			                            </tr>
		                            </thead>
		                        </table>
		                        <table class="login_t2" cellpadding="0" cellspacing="0">
		                            <tbody>
			                            <tr>
			                                <td valign="top" height="44" align="left">
<!-- 			                                	<input name="id" type="text" value="아이디" id="id" style="ime-mode:disabled; width:96%; height: 45px;"> -->
			                                	<input type="text" id="idtemp" name="idtemp" class="roundInput" value="아이디" style="ime-mode:disabled; width:96%; height: 45px;">
          										<input type="text" id="id" name="id" class="roundInput" value="" style="ime-mode:disabled; width:96%; height: 45px;" onkeypress="if (event.keyCode==13){ submit(); return false;}">
			                                </td>
			                                <td width="10"></td>
			                                <td rowspan="2" valign="middle"></td>
			                            </tr>
			                            <tr>
			                                <td valign="top" align="left">
			                                	<input type="text" id="passwordtemp" name="passwordtemp" class="roundInput" value="비밀번호" style="width:96%; height: 45px;">
          										<input type="password" id="password" name="password" class="roundInput" value="" autocomplete="off" style="width:96%; height: 45px;" onkeypress="if (event.keyCode==13){ submit(); return false;}">
			                                </td>
			                                <td width="10"></td>
			                            </tr>
			                            <tr>
			                                <td valign="top" height="15" align="left"></td>
			                                <td width="10"></td>
			                                <!-- <td rowspan="2" valign="middle"><a href="#" class="login_btn" onclick="setCookieID(); submit(); return false;">LOGIN</a></td> -->
			                                     <td  rowspan="2" valign="middle"><a href="#" class="login_btn" onclick="javascript:loginChk(); return false;">LOGIN</a></td>
			                            </tr>
			                            <tr>
			                                <td align="left" valign="middle"><span style="margin-top:-5px; margin-right:3px;"><input id="chkM_SavedInfo" type="checkbox" name="chkM_SavedInfo"> 아이디 저장</span></td>
			                                <td width="10"></td>
			                                <td align="left">
                                                <div id="divM_Language">
                                                <input type="hidden" name="language" class="langSelect" id="langSelect" value="ko"/>
                                                <select name="ddlM_Language" id="ddlM_Language" style="font-size:1em; width:105px;">
													<option value="ko">한국어</option>
													<option value="en">English</option>
													<option value="ja">日本語</option>
													<option value="zh">中國語</option>
												</select>
                                                </div>
                                            </td>
			                            </tr>
		                            </tbody>
		                        </table>
	                        </div>
                        </article>
                    </section>
                    <footer class="m">
	                    <img src="/smarts4j/mobile/Base/images/login_img.png" alt="">
	                    <p class="copylight">Copyright Covision All Rights Reserved</p>
                    </footer>
                </div>
            </div>
		</form>
    </body>
</html>