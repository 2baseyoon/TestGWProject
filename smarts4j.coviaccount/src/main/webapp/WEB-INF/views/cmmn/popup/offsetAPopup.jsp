<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input id="mode"		type="hidden" />
	<input id="corpCardID"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:520px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 150px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody id="corpCardInfo">
							<tr>
								<th>
									전표번호
								</th>
								<td>
									<div class="box" style="width: 100%;">
										<input type="text" style="width: 90%" id="tossComment"/>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="TossUserPopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnTypeChk">등록</a>
					<a onclick="TossUserPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.TossUserPopup) {
		window.TossUserPopup = {};
	}
	
	(function(window) {
		var TossUserPopup = {
				popupInit : function() {
					var me =this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.getPopupInfo();
				},
				
				getPopupInfo : function(){
					var mode		= $("#mode").val();
					var corpCardID	= $("#corpCardID").val();
				},
				
				checkValidation : function(){
					//var tossSenderUserCode	= $("#tossSenderUserCode").val();
					var tossComment			= $("#tossComment").val();
					
					
			
						var info = {
								'tossComment'			: tossComment
						}
						
						try{
							accountCtrl.popupCallBackStr([info]);
						}catch (e) {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
						}
		
				},
				
				tossSenderUserCodeSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "TossUserPopup";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
					var callBackFn	= "goOrgChart_CallBack";
					var type		= "B1";
					var popupUrl	= "/covicore/control/goOrgChart.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "callBackFunc="	+ callBackFn	+ "&"
									+ "type="			+ type;
					
					parent.window[callBackFn] = window[openerID][callBackFn];
					parent.Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
				},
				
				goOrgChart_CallBack : function(orgData){
					var items		= JSON.parse(orgData).item;
					var arr			= items[0];
					var userName	= arr.DN.split(';');
					var UserCode	= arr.UserCode.split(';');
					var setUserCode		= "#tossSenderUserCode";
					var setUserName		= "#tossSenderUserName";
					$(setUserCode).val(UserCode[0]);
					$(setUserName).val(userName[0]);
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.TossUserPopup = TossUserPopup;
	})(window);

	TossUserPopup.popupInit();
</script>