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

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<input id="ManagerID"	name="managerField" datafield="ManagerID"		type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="" style="width:400px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" >
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 120px;">
							<col style="width: auto;">
						</colgroup>
						<tbody  id="itemAdd">	
							<tr>
								<th>
									<!-- 자금집행일 -->
									<spring:message code='Cache.ACC_lbl_realPayDate'/>
									<span class="star"></span>
								</th>
								<td>
									<div id="RealPayDate" class="dateSel type02" fieldtype="Date" style="margin-left: 5px;">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<!-- 실지급금액 -->
									<spring:message code='Cache.ACC_lbl_realPayAmount'/>
									<span class="star"></span>
								</th>
								<td>
									<input id="RealPayAmount" type="text" style="width: 110px; margin-left: 5px; text-align: right;" 
										class="HtmlCheckXSS ScriptCheckXSS" 
										onkeyup="CapitalEditPopup.onSetNum(this);" 
										onblur="CapitalEditPopup.onBlurNum(this);"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="popBtnWrap bottom">
					<a onclick="CapitalEditPopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="CapitalEditPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	if (!window.CapitalEditPopup) {
		window.CapitalEditPopup = {};
	}	
	
	(function(window) {
		
		var CapitalEditPopup = {
				
				popupInit : function(){
					var me = this;
					var expAppListID = "${expAppListID}";
					
					makeDatepicker('RealPayDate', 'RealPayDate_Input', null, null, null, null);
										
					if(!isEmptyStr(expAppListID)){
						me.searchCapitalEditData(expAppListID);
					}
				},

				searchCapitalEditData : function(expAppListID){
					var me = this;	
					$.ajax({
						url:"/account/expenceApplication/searchCapitalEditData.do",
						type : "POST",
						cache: false,
						data:{
							expAppListID : expAppListID
						},
						success:function (data) {
							if(data.result == "ok"){
								var getData = data.data;
								
								me.oriRealPayDate = getData.RealPayDate;
								
								$("#RealPayDate_Input").val(getData.RealPayDate);
								$("#RealPayAmount").val(getData.RealPayAmount);
								$("#RealPayAmount")[0].onblur();
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				checkValidation : function(){
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					
					var me = this;
					var expAppListID = "${expAppListID}";
					var realPayDate = $("#RealPayDate_Input").val().replace(/\./gi, '');
					var realPayAmount = AmttoNumFormat($("#RealPayAmount").val());
					var alertFlag = false;
					
					//자금집행일이 변경되었을 때 기안자에게 메일 알림 발송
					if(me.oriRealPayDate) {
						var oriDate = new Date(me.oriRealPayDate);
						var fixDate = new Date($("#RealPayDate_Input").val());
						
						if(oriDate > fixDate || oriDate < fixDate) {
							alertFlag = true;
						}
					}
					
					$.ajax({
						url : "/account/expenceApplication/updateCapitalEditInfo.do",
						type : "POST",
						data : {
							expAppListID : expAppListID,
							RealPayDate : realPayDate,
							RealPayAmount : realPayAmount,
							AlertFlag : alertFlag
						},
						success : function(data) {
							if (data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								CapitalEditPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error : function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				onSetNum : function(obj){
					var me = this;
					var objVal = obj.value;
					var objVal = objVal.replace(/[^0-9,-.]/g, "");
					obj.value = objVal;
				},
				
				onBlurNum : function(obj){
					obj.value = toAmtFormat(obj.value);
				}
		}
		window.CapitalEditPopup = CapitalEditPopup;
	})(window);
	CapitalEditPopup.popupInit();
</script>