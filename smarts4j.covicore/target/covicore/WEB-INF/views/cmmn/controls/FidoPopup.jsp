<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%-- <jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> --%>

<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>

<script type="text/javascript" src="<%=appPath%>/resources/script/security/AesUtil.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/security/aes.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/security/pbkdf2.js<%=resourceVersion%>"></script>
	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />
	
	
	
<div class="fidopopcont" style="text-align: center;padding: 15px 23px 22px; font-family: 맑은 고딕, Malgun Gothic,sans-serif, dotum,'돋움',Apple-Gothic;">
	<div id ="imgDiv">
		<div id="fidoImg" class="fidoPimg" style="padding-top: 15px;height: 65px;text-align: center;width: 100%;margin: 0 auto;">
			<div style="width: 220px;height: 65px;margin: 0 auto;text-align: center;">
				<span style="display: inline-block;height: 65px;float: left;"><img src="/HtmlSite/smarts4j_n/covicore/resources/images/common/fido_img_pc.png"></span>
				<span style="display: inline-block;padding-top:25px;line-height: 65px;margin: 0 20px;float: left;"><img src="/HtmlSite/smarts4j_n/covicore/resources/images/common/fido_img_loading.gif"></span>
				<span style="display: inline-block;height: 65px;float: left;"><img src="/HtmlSite/smarts4j_n/covicore/resources/images/common/fido_img_mobile01.png"></span>
			</div>	
		</div>
		<div id="resultMsg" class="fidoPtxt01" style="font-size:20px; height: 54px; margin-top: 20px;"><%-- <spring:message code='Cache.msg_fido01'/> --%>모바일 앱으로 사용자 인증이 <br> 요청되었습니다.</div><!-- 모바일 앱으로 사용자 인증이 <br> 요청되었습니다.  -->
	</div>
	<div id="fidoCount" class="fidoPtime" style="margin-bottom:25px;">
		<p style="font-size:13px; margin: 34px 0 0 0;"><spring:message code='Cache.lbl_remainTime'/><!--잔여시간--></p>
		<p id="countdown" style="font-size:24px; margin:0; color: #666;"><strong style="font-size:36px; color:#4abde1;">0</strong><spring:message code='Cache.lbl_Minutes'/><!--분-->&nbsp;<strong style="font-size:36px; color:#4abde1;">0</strong><spring:message code='Cache.lbl_Sec'/><!--초--></p>
	</div>
	
	<div class="fidoPtxt02" style="background-color:#f6fafb; padding: 0 20px; width: 350px; height: 102px;display: table-cell;vertical-align: middle;">
			<span id="description" style="font-size:13px; color:#999;">모바일 앱을 실행하여 <strong style="color:#666;">[지문 및 홍채인증]</strong>을<br>통해 본인인증을 하여 주십시요.</span>
	</div>
	<div class="fidoPbtn" style="text-align:center; margin: 25px 0 0 0;">						
		<a id="confirmBtn"  onclick="confirmAuth('user'); return false;" class="fidoDefault fidobtnTypeBg" style="cursor: pointer ;  text-decoration:none; padding: 0 9px 0; display: inline-block; min-width: 40px;text-align: center; height: 30px;line-height: 30px;font-size: 13px;border-radius: 2px;transition: box-shadow .3s; background: #4abde1 !important; border: 1px solid #3eb0d4; color:#fff;"><spring:message code='Cache.lbl_Confirm'/><!--확인--></a>
		<a id="cancelBtn" onclick="cancelFido(); closePopup(); return false;" class="fidoDefault" style="cursor:pointer; text-decoration:none; padding: 0 9px 0; display: inline-block; min-width: 40px;text-align: center; height: 30px;line-height: 30px;font-size: 13px;border-radius: 2px;transition: box-shadow .3s; background: #fff !important; border: 1px solid #d6d6d6; color:#000;" ><spring:message code='Cache.lbl_close'/><!-- 닫기 --></a>
	</div>
</div>
	
<%-- 	
<div class="layer_divpop surveryAllPop" style="width:100%">
	<div class="popContent">
		<div class="popTop"><spring:message code='Cache.msg_fido01'/></div>  <!-- 모바일 앱으로 사용자 인증이 요청되었습니다.  -->
		<div class="grayBox mt5" style="padding:10px 0px; font-size: 20px; font-weight: 700; height: auto;">
			<spring:message code='Cache.lbl_remainTime'/><!--잔여시간--> <font color="red" id="countdown">0<spring:message code='Cache.lbl_Minutes'/> 0<spring:message code='Cache.lbl_Sec'/></font> <!-- 0분 0초 -->
		</div>
		<div class="mt10" style="text-align: center;" id="resultMsg">  
			<spring:message code='Cache.msg_fido02'/> <!-- 모바일 앱을 실행하여 <font color="#19abd8" >지문 및 홍채인증</font>을 통해 본인인증 후 [확인]을 눌러주십시오. -->
		</div>
		<div class="bottom mt20">						
			<a class="btnTypeDefault btnTypeBg" onclick="confirmAuth('user'); return false;" id="confirmBtn"><spring:message code='Cache.lbl_Confirm'/><!--확인--></a><a class="btnTypeDefault" onclick="cancelFido(); Common.Close(); return false;"><spring:message code='Cache.lbl_close'/><!-- 닫기 --></a>
		</div>
	</div>
</div>	 --%>

<script  type="text/javascript">
//# sourceURL=FidoPopup.jsp
init();

var g_authKey;
var g_logonID;
var g_authType;
var g_authToken;

//interval
var g_i_fidoTimer; 
var g_i_fidoCheck; 

function init(){
	//parameter 값 설정
	g_logonID = emptyDefault(CFN_GetQueryString("logonID"), "");
 	g_authType = emptyDefault(CFN_GetQueryString("authType"), "");
 	
	// FIDO 요청
	$.ajax({
		url: "/covicore/control/fido.do",
		type: "post", 
		async: false, 
		data: {
			"logonID": g_logonID, 
			"authType": g_authType,
			"reqMode": "ReqAuth"
		},
		success: function(data){
			if(data.status =="SUCCESS"){
			  g_authKey = data.authKey;
			  g_authToken = encodeURIComponent(data.authToken);
			  var counter = 300;  //5분 
			  
			  //Interval 설정
			  g_i_fidoTimer = setInterval(function(){
		          if(counter < 0) {
		        		clearInterval(g_i_fidoTimer);
		        		clearInterval(g_i_fidoCheck);
		        		cancelFido(data.authKey);
		        		$('#fidoImg').html("<div style='width: 65px;height: 65px;margin: 0 auto;text-align: center;'><span style='display: inline-block;height: 65px;float: left;'><img src='/HtmlSite/smarts4j_n/covicore/resources/images/common/fido_img_mobile02.png'></span></div>");
		          		$("#resultMsg").html("본인인증에<br>실패하였습니다.");  /* <font color='red' style='font-size: 18px;'>본인인증에 실패하였습니다.</font><br>본인인증을 다시 시도하여 주십시오. */
		          		$("#description").html("본인인증을 다시 시도하여 주십시요.");
		          		$("#imgDiv").attr("style", "padding: 62px 0;");
		          		$("#fidoCount").hide();
		          		$("#confirmBtn").hide();
		          		$("#cancelBtn").attr("onclick", "closePopup(); return false;");
		          } else {
		        	  var minutes = Math.floor(counter/60); 
		        	  var seconds = counter - (minutes*60);
		        	  
		              $('#countdown').html("<strong style='font-size:36px; color:#4abde1;'>" + minutes + "</strong><spring:message code='Cache.lbl_Minutes'/>&nbsp;<strong style='font-size:36px; color:#4abde1;'>" + seconds +"</strong><spring:message code='Cache.lbl_Sec'/>"); /*분 초*/
		          };
		          counter -= 1;
		      }, 1000);
			  
			  g_i_fidoCheck = setInterval("confirmAuth('interval')", 5000);

			}else{
				parent.Common.Error(data.resMessage, "Error", function(){
					closePopup()
				})
			}				  
		},
		error: function(response, status, error){
		     CFN_ErrorAjax("/covicore/control/fido.do", response, status, error);
		}
	}); 
}


function cancelFido(){
	if(g_authKey != undefined){
		
		$.ajax({
			url: "/covicore/control/fido.do",
			type: "post", 
			data: {
				"logonID": g_logonID, 
				"authKey" : g_authKey,
				"authType": g_authType,
				"authToken": g_authToken,
				"reqMode": "CancelAuth"
			},
			success: function(data){
				if(data.status !="SUCCESS"){
					parent.Common.Error(data.resMessage, "Error", function(){
						closePopup()
					})
				}				  
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/control/fido.do", response, status, error);
			}
		}); 
	}
}


function confirmAuth(callType){ //interval(10초에 한번 호출) or user(사용자가 확인 누른 경우)
	if(g_authKey != undefined){
		
		$.ajax({
			url: "/covicore/control/fido.do",
			type: "post", 
			data: {
				"logonID": g_logonID, 
				"authKey" : g_authKey,
				"authType": g_authType,
				"authToken": g_authToken,
				"reqMode": "ReadAuth"
			},
			success: function(data){
				if(data.status =="SUCCESS"){
					if(data.resMessage.toUpperCase() == "SUCC"){
						if(callType == "user"){
							parent.Common.Inform("<spring:message code='Cache.msg_CertificationSuccess'/>", "Information", function(){ //인증되었습니다.
								closePopup()
								if(opener){
									opener.fidoCallBack();
								}else{
									parent.fidoCallBack();
								}
							});
						}else{ //interval
							closePopup()
							if(opener){
								opener.fidoCallBack();
							}else{
								parent.fidoCallBack();
							}
						}
					}else if(data.resMessage.toUpperCase()  == "FAIL"){
			     		$('#fidoImg').html("<div style='width: 65px;height: 65px;margin: 0 auto;text-align: center;'><span style='display: inline-block;height: 65px;float: left;'><img src='/HtmlSite/smarts4j_n/covicore/resources/images/common/fido_img_mobile02.png'></span></div>");
		          		$("#resultMsg").html("본인인증에<br>실패하였습니다.");  /* <font color='red' style='font-size: 18px;'>본인인증에 실패하였습니다.</font><br>본인인증을 다시 시도하여 주십시오. */
		          		$("#description").html("본인인증을 다시 시도하여 주십시요.");
		          		$("#imgDiv").attr("style", "padding: 62px 0;");
		          		$("#fidoCount").hide();
		          		$("#confirmBtn").hide();
		          		clearInterval(g_i_fidoTimer);
		        		clearInterval(g_i_fidoCheck);
					}else if(data.resMessage.toUpperCase() == "CHECK"){
						parent.Common.Error("<spring:message code='Cache.msg_CertificationDup'/>", "Error", function(){ //이미 인증된 인증입니다.
							closePopup()
						})
					}else if(callType == 'user' && data.resMessage.toUpperCase()  == "REQ"){
						parent.Common.Warning("<spring:message code='Cache.msg_CertificationProceed'/>");  //인증 요청 중입니다.
					}
				}else{
					parent.Common.Error(data.resMessage);
				}
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/control/fido.do", response, status, error);
			}
		}); 
	}
}

function closePopup(){
	clearInterval(g_i_fidoTimer);
	clearInterval(g_i_fidoCheck);
	
	if(parent.$("#checkFido_if").length > 0){
		parent.Common.close('checkFido');
	}else{
		window.close();
	}
}

function emptyDefault(value, defaultVal){
	if(value=="undefined" || value=="null" || value==undefined || value == null){
		return defaultVal;
	}else{
		return value;
	}
}

</script>