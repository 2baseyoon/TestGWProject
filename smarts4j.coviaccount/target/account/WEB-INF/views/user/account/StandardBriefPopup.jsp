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
	<input id="accountID"	type="hidden" />
	<span id="UseYnCombo"		hidden></span>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 120px;">
							<col style = "width: auto;">
							<col style = "width: 120px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody>
							<tr>
								<th>
									<!-- 회사 -->
									<spring:message code='Cache.ACC_lbl_company'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="companyCode" class="selectType06">
										</span>
									</div>
								</td>
								<th>
									<!-- 계정이름 -->
									<spring:message code='Cache.ACC_lbl_accountName'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box" style="width: 100%;">
										<input id="accountName" 	type="text" placeholder=""	readOnly class="HtmlCheckXSS ScriptCheckXSS">
										<a onclick="StandardBriefPopup.accountSearchPopup()"	id="accountSearchPopupID"	class="btnTypeDefault btnResInfo"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
					
					<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
						<a onclick="StandardBriefPopup.addRow()"	id="addRowBtn"	class="btnTypeDefault" style = "margin-right:5px"><spring:message code='Cache.ACC_btn_add'/></a>
						<a onclick="StandardBriefPopup.delRow()"	id="delRowBtn"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_delete'/></a>
					</div>
					
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 40px;">
							<col style = "width: 60px;">
							<col style = "width: 120px;">
							<col style = "width: 150px;">
							<col style = "width: 80px;">
							<col style = "width: 80px;">
							<col style = "width: 190px;">
							<col style = "width: 100px;">
							<col style = "width: 100px;">
						</colgroup>
						<tbody id="rowInfoTable">
							<tr>
								<th></th>															<!-- 체크박스 영역 -->					
								<th><spring:message code='Cache.ACC_lbl_no'/></th>					<!-- 순번 -->
								<th><spring:message code='Cache.ACC_standardBrief'/></th>			<!-- 표준적요 -->
								<th><spring:message code='Cache.ACC_lbl_standardBriefDesc'/></th>	<!-- 표준적요설명 -->
								<th><spring:message code='Cache.ACC_lbl_isUse'/></th>				<!-- 사용여부 -->
								<th><spring:message code='Cache.ACC_lbl_simpleApplication'/></th>	<!-- 간편신청 -->
								<th><spring:message code='Cache.ACC_lbl_ctrlCode'/></th>			<!-- 관리항목 -->
								<th><spring:message code='Cache.ACC_lbl_Require_AttchFile'/></th>	<!-- 첨부파일필수여부 -->
								<th><spring:message code='Cache.ACC_lbl_Require_DocLink'/></th>		<!-- 문서연결필수여부 -->
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="StandardBriefPopup.checkValidation()"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a>
					<a onclick="StandardBriefPopup.closeLayer()"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.StandardBriefPopup) {
		window.StandardBriefPopup = {};
	}
	
	(function(window) {
		var StandardBriefPopup = {
				params	:{
					_delArr	: []
				},
				
				popupInit : function() {
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.setSelectCombo();
					me.getComboData();
					me.setPopupEdit();
					me.getPopupInfo();
					
					$("#companyCode").attr("onchange", "StandardBriefPopup.changeCompanyCode()");
				},
				
				setPopupEdit : function(){
					var mode		= $("#mode").val();
					var accountID	= $("#accountID").val();
					if (mode == 'modify') {
						$("#accountSearchPopupID").hide();
					}
				},
				
				setSelectCombo : function(pCompanyCode){
					$("#isUse").children().remove();
					$("#isUseSimp").children().remove();
					
					$("#isUse").attr("hidden", "hidden");
					$("#isUseSimp").attr("hidden", "hidden");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'CompanyCode',	'target':'companyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'IsUse',	'target':'UseYnCombo',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop();
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
					
					//accountCtrl.renderAXSelect('IsUse', 'isUseSimp', 'ko','','','');	
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				getPopupInfo : function(){
					var me = this;
					var accountID	= $("#accountID").val();
					
					if (accountID == '' || accountID == null) {
						return;
					}else{
						$.ajax({
							url	:"/account/standardBrief/getStandardBriefDetail.do",
							type: "POST",
							data: {
								"accountID" : accountID
							},
							async: false,
							success:function (data) {
								if(data.status == "SUCCESS"){
									// 신규 계정과목 셋팅 전 이전 표준적요 행 삭제
									$("#rowInfoTable").find("input[type=checkbox]").attr("checked", "checked");
									StandardBriefPopup.delRow();
									
									for(var i=0; i<data.list.length; i++){
										var info	= data.list[i];
										var len		= i+1;
										if(i==0){
											$("#accountID").val(info.AccountID);
											$("#accountName").val(info.AccountName);
											accountCtrl.getComboInfo("companyCode").bindSelectSetValue(info.CompanyCode);
										}
										
										StandardBriefPopup.addRow();
										
										var nowSBNM	= "#standardBriefName_" + (i+1);
										var nowSBDS	= "#standardBriefDesc_" + (i+1);
										var nowIU	= "#isUse_"				+ (i+1);
										var nowIUS	= "#isUseSimp_"			+ (i+1);
										var nowSBID	= "#standardBriefID_"	+ (i+1);
										var nowCtrlCD	= "#ctrlCode_"			+ (i+1);
										var nowCtrlNM	= "#ctrlName_"			+ (i+1);
										var nowFile		= "#isfile_"			+ (i+1);
										var nowDocLink	= "#isdocLink_"			+ (i+1);
										
										$(nowSBNM).val(info.StandardBriefName);
										$(nowSBDS).val(info.StandardBriefDesc);
										$(nowIU).val(info.IsUse);
										$(nowIUS).val(info.IsUseSimp);
										$(nowSBID).val(info.StandardBriefID);
										$(nowCtrlCD).val(info.CtrlCode);
										var CtrlName =me.getAccCtrlName(info.CtrlCode);
										$(nowCtrlNM).html(CtrlName);
										$(nowFile).val(info.IsFile);
										$(nowDocLink).val(info.IsDocLink);
									}
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						});
					}
				},
				
				checkValidation : function() {
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					
					var me = this;
					var params	= new Object();
					var infoArr	= [];
					var infoList= $("#rowInfoTable").children('tr');
					var len		= infoList.length;
					
					var mode		= $("#mode").val();
					var accountID	= $("#accountID").val();
					
					if(accountID == null ||  accountID == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_selectAccountCode' />");	//계정을 선택해주세요.
						return;
					}
					
					if(mode == 'add'){
						if(len < 2){
							Common.Inform("<spring:message code='Cache.ACC_msg_noAddStandardBrief' />");	//추가된 표준적요가 없습니다.
							return;
						}
					}
					
					for(var i=0; i<len-1; i++){
						var nowSBNM = "#standardBriefName_" + (i+1);
						var nowSBDS	= "#standardBriefDesc_" + (i+1);
						var nowIU	= "#isUse_"				+ (i+1);
						var nowIUS	= "#isUseSimp_"			+ (i+1);
						var nowSBID	= "#standardBriefID_"	+ (i+1);
						var nowCtrlCD	= "#ctrlCode_"			+ (i+1);
						var nowFile		= "#isfile_"			+ (i+1);
						var nowDocLink	= "#isdocLink_"			+ (i+1);
						
						var nowSBNMVal	= $(nowSBNM).val();
						var nowSBDSVal	= $(nowSBDS).val();
						var nowIUVal	= $(nowIU).val();
						var nowIUSVal	= $(nowIUS).val();
						var nowSBIDVal	= $(nowSBID).val();
						var nowCtrlCDVal	= $(nowCtrlCD).val();
						var nowFileVal		= $(nowFile).val();
						var nowDocLinkVal	= $(nowDocLink).val();
						
						if(nowSBNMVal == null || nowSBNMVal == ''){
							Common.Inform("<spring:message code='Cache.ACC_msg_inputStandardBrief' />"); //표준적요를 입력해주세요.
							return;
						}
						
						if(chkInputCode(nowSBNMVal) || chkInputCode(nowSBDSVal)){
							Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />"); //<는 사용할 수 없습니다.
							return;
						}
						
						var obj = {	"standardBriefName"	: nowSBNMVal
								,	"standardBriefDesc"	: nowSBDSVal
								,	"isUse"				: nowIUVal
								,	"isUseSimp"			: nowIUSVal
								,	"standardBriefID"	: nowSBIDVal
								,	"ctrlCode"			: nowCtrlCDVal
								,	"isfile"			: nowFileVal
								,	"isdocLink"			: nowDocLinkVal
						};
						
						infoArr.push(obj);
					}
					
					var sbNameArr = infoArr.map(function(info) { return info["standardBriefName"] });
					var uniqSbNameArr = Array.from(new Set(sbNameArr));
					if(uniqSbNameArr && sbNameArr) {
						if(uniqSbNameArr.length < sbNameArr.length) {
							Common.Inform("<spring:message code='Cache.ACC_msg_existStandardBrief' />"); //표준적요는 중복될 수 없습니다.
							return;
						}
					}
					
					params.infoArr		= infoArr;
					params.delArr		= me.params._delArr;
					params.accountID	= accountID;
					params.companyCode 	= accountCtrl.getComboInfo("companyCode").val();
					
					$.ajax({
						url			: "/account/standardBrief/saveStandardBriefInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								StandardBriefPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
						}
					});
				},
				
				accountSearchPopup : function() {
					var popupName	=	"AccountSearchPopup";
					var popupID		=	"accountSearchPopup";
					var openerID	=	"StandardBriefPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_accountSearch' />"; //회계계정
					var popupYN		=	"Y";
					var callBack	=	"accountSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"callBackFunc="	+	callBack	+	"&"
									+	"companyCode="	+	accountCtrl.getComboInfo("companyCode").val();
					parent.Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				},
				
				accountSearchPopup_CallBack : function(info){
					var me = this;
					var accountID		= info.AccountID;
					var accountName		= info.AccountName;
					$("#accountID").val(accountID);
					$("#accountName").val(accountName);
					
					me.getPopupInfo();
				},
				
				addRow : function(){
					var infoList= $("#rowInfoTable").children('tr');
					var len		= infoList.length;

					var iu		= accountCtrl.getComboInfo("UseYnCombo")[0]
					var iuLen	= iu.length;
					var iuStr	= "";
					for(var i=0; i<iuLen; i++){
						iuStr	+=	"<option value ='"+iu.options[i].value+"'>"
								+		iu.options[i].label
								+	"</option>" 
					}

					var ius		= accountCtrl.getComboInfo("UseYnCombo")[0]
					var iusLen	= ius.length;
					var iusStr	= "";
					for(var i=0; i<iusLen; i++){
						iusStr	+=	"<option value ='"+ius.options[i].value+"'>"
								+		ius.options[i].label
								+	"</option>" 
					}
					var iYNCombo	= accountCtrl.getComboInfo("UseYnCombo")[0]
					var iYNComboLen	= iYNCombo.length;
					var iYNComboStr	= "";
					for(var i=0; i<iYNComboLen; i++){
						iYNComboStr	+=	"<option value ='"+iYNCombo.options[i].value+"'>"
								+		iYNCombo.options[i].label
								+	"</option>" 
					}
					
					var appendStr	= "<tr>"
									+	"<td style='border-left: none;'>"
									+		"<div class='box'>"
									+			"<input id='standardBriefChk_"+len+"' type='checkbox'>"
									+		"</div>"
									+	"</td>"
									+	"<th>"
									+		len
									+	"</th>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='standardBriefName_"+len+"' type='text' placeholder='' style='width:100%' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='standardBriefDesc_"+len+"' type='text' placeholder='' style='width:100%' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<select id='isUse_"+len+"' class='selectType06'>"
									+				iuStr
									+			"</select>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<select id='isUseSimp_"+len+"' class='selectType06'>"
									+				iusStr
									+			"</select>"
									+		"</div>"
									+	"</td>"
									+	"<td hidden>"
									+		"<div class='box'>"
									+			"<input id='standardBriefID_"+len+"' type='text' value='' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+	"<td target='"+len+"'>"
									+		"<div class='name_box_wrap' style='width:calc(100% - 35px);'>"
									+			"<span class='name_box' name='sbNameBox' id='ctrlName_"+len+"'></span>" 
									+			"<input type = 'hidden' id='ctrlCode_"+len+"'></span>" 
									+			"<a class='btn_del03' onclick='StandardBriefPopup.delAccCtrl(this)'></a>"
									+		"</div>"
									+		"<button class='btn_search03' type='button' onclick='StandardBriefPopup.callAccCtrlPop(this);'></button>"
									//+		"<div class='box' style='padding: 0 0 0 0'>"
									//+			"<input id='ctrlCode_"+len+"' type='text' placeholder='' style='width:calc(100% - 35px);' class='HtmlCheckXSS ScriptCheckXSS'>"
									//+			"<button class='btn_search03' type='button' onclick='StandardBriefPopup.callAccCtrlPop(this);' target='ctrlCode_"+len+"' ></button>"
									//+		"</div>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<select id='isfile_"+len+"' class='selectType06'>"
									+				iYNComboStr
									+			"</select>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<select id='isdocLink_"+len+"' class='selectType06'>"
									+				iYNComboStr
									+			"</select>"
									+		"</div>"
									+	"</td>"
									+ "</tr>"
					$("#rowInfoTable").append(appendStr);
				},
				
				delRow : function(){
					var me = this;
					var infoList = $("#rowInfoTable").children('tr');
					var len	= infoList.length;
					
					if(len < 2) {
						return;
					} else {
						/*
						var nowSBID		= "#standardBriefID_" + (len-1);
						var nowSBIDVal	= $(nowSBID).val();
						
						if(nowSBIDVal != null && nowSBIDVal != ''){
							me.params._delArr.push({'standardBriefID' : nowSBIDVal})	
						}
						
						infoList.eq(len-1).remove(); 
						*/
						
						var chkList = $("#rowInfoTable").find("input[type=checkbox]:checked");
						for(var i = 0; i < chkList.length; i++) {
							var index = chkList.eq(i).attr("id").replace("standardBriefChk_", "");
							var nowSBID		= "#standardBriefID_" + index;
							var nowSBIDVal	= $(nowSBID).val();
							
							if(nowSBIDVal != null && nowSBIDVal != ''){
								me.params._delArr.push({'standardBriefID' : nowSBIDVal})	
							}
							
							$(nowSBID).parents("tr").remove();
						}
						
						var afterRemoveList = $("#rowInfoTable").children('tr');
						for(var i = 1; i <= afterRemoveList.length; i++) {
							afterRemoveList.eq(i).find("th").html(i);
						}
					}
				},

				callAccCtrlPop : function(obj) {
					var me = this;
					me.tempAccCtrltarget =obj.closest('td').getAttribute('target');
					var ctrlCode	= Base64.utf8_to_b64($(obj).prev().find("input[id^=ctrlCode]").val());
					var popupID		=	"AccCtrlPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_ctrlCode'/>";
					var openerID	=	"StandardBriefPopup";
					var popupName	=	"AccountCtrlSearchPopup";
					var callBack	=	"setAccCtrlPopCallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN=Y&"
									+	"includeAccount=N&"
									+	"companyCode="	+	accountCtrl.getComboInfo("companyCode").val()	+	"&"
									+	"ctrlCode="		+	ctrlCode	+	"&"
									+	"callBackFunc="	+	callBack;
					
					parent.Common.open(	"",popupID,popupTit,url,"550px","700px","iframe",true,null,null,true);
					
					
				},
				setAccCtrlPopCallBack : function(data){
					var me = this;
					var strCode='';
					var strName='';
					if(data.length>0)
					{
						$.each(data,function(idx,item){
							strCode +=item.Code+','
							strName +=item.CodeName+','
						});
						strCode = strCode.slice(0,-1);
						strName = strName.slice(0,-1);
					}
					else if(data.Code!=undefined)
					{
						strCode =data.Code;
						strName =data.CodeName;
					}
					$("#ctrlCode_"+me.tempAccCtrltarget).val(strCode);
					$("#ctrlName_"+me.tempAccCtrltarget).html(strName);
					me.tempAccCtrltarget = '';
				},
				closeLayer : function() {
					var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close('standardBriefPopup');
					}
				},
				delAccCtrl : function(obj){
					var AccCtrltarget =obj.closest('td').getAttribute('target');
					$("#ctrlCode_"+AccCtrltarget).val('');
					$("#ctrlName_"+AccCtrltarget).html('');
				},
				getAccCtrlName : function(ctrlCodes){
					var me = this;
					var returnVal='';
					if(ctrlCodes==undefined||ctrlCodes==null||ctrlCodes=='')
						return returnVal;
					
					ctrlCodes = ctrlCodes.split(',');
					$.each(ctrlCodes,function(idx,item){
						returnVal +=me.getAccCtrlNameSub(item)+','
					});
					returnVal = returnVal.slice(0,-1);
					return returnVal;
				},
				getAccCtrlNameSub : function(val) {
					var me = this;
					var retVal = '';
					var arrCk = Array.isArray(me.AccountCtrlList);
					if(arrCk){
						retVal = accFind(me.AccountCtrlList, 'Code', val);
						retVal = retVal.CodeName
					}
					return nullToBlank(retVal);
				},
				getComboData : function(){
					var me = this;
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeData.do",
						data:{
							codeGroups : "AccountCtrl",
							CompanyCode : accountCtrl.getComboInfo("companyCode").val()
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var codeList = data.list;
								if(codeList.hasOwnProperty('AccountCtrl'))
								{
									me.AccountCtrlList = codeList.AccountCtrl;
								}
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
		}
		window.StandardBriefPopup = StandardBriefPopup;
	})(window);

	StandardBriefPopup.popupInit();
	
</script>