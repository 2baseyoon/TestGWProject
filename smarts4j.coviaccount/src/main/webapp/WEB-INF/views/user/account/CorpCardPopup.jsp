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
	<div class="layer_divpop ui-draggable docPopLayer" style="width:815px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 200px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody id="corpCardInfo">
							<tr>
								<th>	<!-- 회사 -->
									<spring:message code='Cache.ACC_lbl_company'/>
								</th>
								<td>
									<div class="box">
										<span id="companyCode" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드번호 -->
									<spring:message code='Cache.ACC_lbl_cardNumber'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input	id="cardNo" type="text"
												onkeypress	= "return inputNumChk(event)"
												onkeydown	="pressHan(this)"
												onchange	= "CorpCardPopup.changeCardNo()"
												class		= "HtmlCheckXSS ScriptCheckXSS">
										<a id="cardNoBtn" class="btnTypeDefault" onclick="CorpCardPopup.cardNoBtn()"><spring:message code='Cache.ACC_lbl_ckExist'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 소유자 사번/이름 -->
									<spring:message code='Cache.ACC_lbl_ownerUserName'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<input id="ownerUserNum"	type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="ownerUserName"	type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="ownerUserCode"	type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
										<a id="ownerUserCodeSearch"	class="btn_search03"	onclick="CorpCardPopup.userCodeSearch('')"><spring:message code='Cache.ACC_btn_search'/></a>
										<a id="ownerUserCodeDel"	class="btn_delType03"	onclick="CorpCardPopup.userCodeDel('')"><spring:message code='Cache.ACC_btn_delete'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 소유자 영문이름 -->
									<spring:message code='Cache.ACC_lbl_ownerUserNameEn'/>
								</th>
								<td>
									<div class="box">
										<input id="ownerUserNameEn" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr id="ownerUserTR0">
								<th id="ownerUserTH0">	<!-- 조회자 사번/이름 -->
									<spring:message code='Cache.ACC_lbl_ownerUserNameNum'/>
								</th>
								<td>
									<div class="box">
										<input id="ownerUserNum0"			type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="ownerUserName0"			type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="ownerUserCode0"			type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="corpCardSearchUserID0"	type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
										<a id="owneruserCodeSearch0"		class="btn_search03"	onclick="CorpCardPopup.userCodeSearch('0')"><spring:message code='Cache.ACC_btn_search'/></a>
										<a id='ownerUserCodeDel' 			class='btn_delType03'	onclick="CorpCardPopup.userCodeDel('0')"><spring:message code='Cache.ACC_btn_delete'/></a>
										<a id="ownerUserCodeAdd"			class="btnTypeDefault"	onclick="CorpCardPopup.ownerUserCodeAdd('0')"><spring:message code='Cache.ACC_btn_add'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 지급처 -->
									<spring:message code='Cache.ACC_lbl_corpCardVendor'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<input id="vendorNo"	type="text" placeholder=""	disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="vendorName"		type="text" placeholder=""	disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<a id="" class="btn_search03"	onclick="CorpCardPopup.vendorNoSearch()"><spring:message code='Cache.ACC_btn_search'/></a>
										<a id="" class="btn_delType03"	onclick="CorpCardPopup.vendorNoDel()"><spring:message code='Cache.ACC_btn_delete'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드상태 -->
									<spring:message code='Cache.ACC_lbl_cardStatus'/>
								</th>
								<td>
									<div class="box">
										<span id="cardStatus" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드회사 -->
									<spring:message code='Cache.ACC_lbl_cardCompany'/>
								</th>
								<td>
									<div class="box">
										<span id="cardCompany" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드유형 -->
									<spring:message code='Cache.ACC_lbl_cardClass'/>
								</th>
								<td>
									<div class="box">
										<span id="cardClass" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 발급일자 -->
									<spring:message code='Cache.ACC_lbl_issueDate'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<div id="issueDateArea" class="dateSel type02">
										</div>
										<!-- 
										* yyyy-MM-dd 형식으로 입력하세요.
										 -->
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 결제일자 -->
									<spring:message code='Cache.ACC_lbl_payDate'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<label style="margin-right: 10px;"><spring:message code='Cache.lbl_EveryMonth'/></label>
										<select id="payDate" class="selectType04" style="width: 50px; border-radius: unset;"></select>
										<label><spring:message code='Cache.ACC_lbl_day'/></label>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 만료일자 -->
									<spring:message code='Cache.ACC_lbl_expirationDate'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<input id="expirationDate" type="text" placeholder="yyyy/MM" class="HtmlCheckXSS ScriptCheckXSS">
										<label><spring:message code='Cache.ACC_msg_case_3'/></label>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 한도금액 -->
									<spring:message code='Cache.ACC_lbl_limitAmt'/>
									<!-- <span class="star"></span> -->
								</th>
								<td>
									<div class="box">
										<span id="limitAmountType" class="selectType02" onchange="CorpCardPopup.limitAmountTypeChange()">
										</span>
										<input	id="limitAmount" type="text"
												onkeypress	= "return inputNumChk(event)" 
												onkeydown="pressHan(this)"
												onkeyup	= "CorpCardPopup.changeLimitAmount()"
												value = "0"
												style = "text-align: right;">
										<label><spring:message code='Cache.ACC_msg_limitAmount'/></label> <!-- * 한도금액을 작성하지 않을 경우 한도없는 카드로 분류됩니다. -->
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 비고 -->
									<spring:message code='Cache.ACC_lbl_description'/>
								</th>
								<td>
									<div class="box" style="width: 100%;">
										<textarea rows="5" style="width:100%; resize:none;" id="note" name="<spring:message code="Cache.ACC_lbl_description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS"></textarea>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="CorpCardPopup.checkValidation()"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a>
					<a onclick="CorpCardPopup.closeLayer()"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	
	if (!window.CorpCardPopup) {
		window.CorpCardPopup = {};
	}

	(function(window) {
		var CorpCardPopup = {
				params	:{
					_cardNoChk			: "fail",
					_cardNo				: 0,
					_ownerUserKeyArr	: [{"key":0}],
					_ownerUserDelArr	: [],
					_userCodeSearchKey	: "",
					_userCodeDelKey		: ""
				},
				
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.pageDatepicker();
					me.setSelectCombo();
					me.setPopupEdit();
					me.getPopupInfo();
					
					$("#companyCode").attr("onchange", "CorpCardPopup.changeCompanyCode()");
				},
				
				setCalendar : function(ym) {
					var target = 'issueDate';
					coviCtrl.makeSimpleCalendar(target, ym);
				},
				
				setPopupEdit : function(){
					var me = this;
					var mode		= $("#mode").val();
					var cardNoBtn	= $('#cardNoBtn')
					
					if (mode == 'modify') {
						$("#cardNo").attr("disabled", true);
						cardNoBtn.text("<spring:message code='Cache.ACC_lbl_changeCard' />");	//카드번호 변경
					}
				},
				
				pageDatepicker : function(){
					makeDatepicker('issueDateArea','issueDate','','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					$("#cardCompany").children().remove();
					$("#cardStatus").children().remove();
					$("#cardClass").children().remove();
					$("#limitAmountType").children().remove();

					$("#cardCompany").addClass("selectType02");
					$("#cardStatus").addClass("selectType02");
					$("#cardClass").addClass("selectType02");
					$("#limitAmountType").addClass("selectType02").attr("onchange", "CorpCardPopup.limitAmountTypeChange()");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'CardCompany',		'target':'cardCompany',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CardStatus',		'target':'cardStatus',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CardClass',		'target':'cardClass',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'LimitAmountType',	'target':'limitAmountType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_directInput' />"}	//직접입력
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
					
					var dateStr = "<option value=''>" + "<spring:message code='Cache.ACC_lbl_comboSelect' />" + "</option>";
					for(var i = 1; i <= 31; i++)
						dateStr += "<option value='" + i + "'>" + i + "</option>";
					$("#payDate").html(dateStr);
				},
				
				comboRefresh : function() {
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("cardCompany");
					accountCtrl.refreshAXSelect("cardStatus");
					accountCtrl.refreshAXSelect("cardClass");
					accountCtrl.refreshAXSelect("limitAmountType");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				getPopupInfo : function(){
					var me = this;
					var mode		= $("#mode").val();
					var corpCardID	= $("#corpCardID").val();

					if(mode == 'modify'){
						$.ajax({
							url	:"/account/corpCard/getCorpCardDetail.do",
							type: "POST",
							data: {
									"corpCardID" : corpCardID
							},
							async: false,
							success:function (data) {
								if(data.status == "SUCCESS"){
									if(data.infoList.length > 0){
										var info = data.infoList[0];
										
										CorpCardPopup.params._cardNoChk	= "ok";
										CorpCardPopup.params._cardNo	= info.CardNo;

										accountCtrl.getComboInfo("cardClass").bindSelectSetValue(info.CardClass);
										accountCtrl.getComboInfo("cardCompany").bindSelectSetValue(info.CardCompany);
										$("#cardNo").val(getCardNoValue(info.CardNo,'*'));
										accountCtrl.getComboInfo("cardStatus").bindSelectSetValue(info.CardStatus);
										accountCtrl.getComboInfo("companyCode").bindSelectSetValue(info.CompanyCode);
										$("#corpCardID").val(info.CorpCardID);
										$("#expirationDate").val(info.ExpirationDate);
										$("#issueDate").val(info.IssueDate);
										$("#payDate").val(info.PayDate);
										accountCtrl.getComboInfo("limitAmountType").bindSelectSetValue(info.LimitAmountType);
										$("#limitAmount").val(getAmountValue(info.LimitAmount));
										$("#note").val(info.Note);
										$("#ownerUserCode").val(info.OwnerUserCode);
										$("#ownerUserName").val(info.OwnerUserName);
										$("#ownerUserNameEn").val(info.OwnerUserNameEn);
										$("#ownerUserNum").val(info.OwnerUserNum);
										$("#vendorNo").val(info.VendorNo);
										$("#vendorName").val(info.VendorName);
										
										if(data.userlist.length > 0){
											for(var i=0; i<data.userlist.length; i++){
												var userInfo = data.userlist[i];
												var nowOwnerUserNum			= "#ownerUserNum"			+ i;
												var nowOwnerUserName		= "#ownerUserName"			+ i;
												var nowOwnerUserCode		= "#ownerUserCode"			+ i;
												var nowCorpCardSearchUserID	= "#corpCardSearchUserID"	+ i;
												
												if(i > 0){
													CorpCardPopup.ownerUserCodeAdd()
												}
												
												$(nowOwnerUserNum).val(userInfo.OwnerUserNum);
												$(nowOwnerUserName).val(userInfo.OwnerUserName);
												$(nowOwnerUserCode).val(userInfo.OwnerUserCode);
												$(nowCorpCardSearchUserID).val(userInfo.CorpCardSearchUserID);
											}
										}
									}
									
									CorpCardPopup.comboRefresh();
									
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}else{
						$("#issueDate").val('');
					}
				},
				
				cardNoBtn : function(){
					var me = this;
					var mode	= $("#mode").val();
					
					if (mode == 'modify') {
						me.cardNoChg();
					}else{
						me.cardNoChk();
					}
				},
				
				vendorNoDel : function() {
					$('#vendorNo').val('');
					$('#vendorName').val('');
				},
				
				vendorNoSearch : function(){
					var popupName	=	"VendorSearchPopup";
					var popupID		=	"vendorSelectPopup";
					var openerID	=	"CorpCardPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_vendor' />";	//거래처
					var popupYN		=	"Y";
					var callBack	=	"vendorNoSearch_callBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"700px","630px","iframe",true,null,null,true);
				},
				
				vendorNoSearch_callBack : function(info){
					$('#vendorNo').val(info.VendorNo);
					$('#vendorName').val(info.VendorName);
				},
				
				cardNoChg : function(){
					var corpCardID	= $("#corpCardID").val();
					var cardNo		= $("#cardNo").val();
					
					var popupName	=	"CorpCardChgPopup";
					var popupID		=	"CorpCardChgPopup";
					var openerID	=	"CorpCardPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_changeCard' />";	//카드번호변경
					var popupYN		=	"Y";
					var callBack	=	"cardNoChg_CallBack";
					var url			=	"/account/corpCard/getCorpCardChgPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"callBackFunc="	+	callBack	+	"&"
									+	"corpCardID="	+	corpCardID	+	"&"
									+	"cardNo="		+	cardNo;
					parent.Common.open(	"",popupID,popupTit,url,"500px","200px","iframe",true,null,null,true);
				},
				
				cardNoChg_CallBack : function(info){
					CorpCardPopup.params._cardNoChk	= "ok";
					CorpCardPopup.params._cardNo	= info.cardNoChgVal;
					var setCardNo = getCardNoValue('**********' + info.cardNoChgVal.substr(10,6),'*');
					$("#cardNo").val(setCardNo);
					
					try{
						accountCtrl.popupCallBackStr([]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
				},
				
				cardNoChk : function(){
					var cardNoVal = $('#cardNo').val().replaceAll('-','');
					var regExp = /^[0-9]+$/;
					
					if(cardNoVal.length < 15 || cardNoVal.length > 16){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckCardNum' />");	//16자리의 카드번호를 입력해주세요
						return;	
					}
					
					if (regExp.test(cardNoVal)){
						$.ajax({
							url	:"/account/corpCard/getCardNoChk.do",
							type: "POST",
							data: {
									"cardNo" : cardNoVal
							},
							success:function (data) {
								if(data.status == "SUCCESS"){
									
									CorpCardPopup.params._cardNoChk	= data.result;
									CorpCardPopup.params._cardNo	= cardNoVal;
									
									if(data.result == "ok"){
										Common.Inform("<spring:message code='Cache.ACC_msg_cardNumY' />");	//등록 가능한 카드번호입니다.
									}else{
										Common.Inform("<spring:message code='Cache.ACC_msg_cardNumN' />");	//이미 등록된 카드번호입니다.
										$('#cardNo').val("");
									}
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}else{
						Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");	// 카드번호를 다시 입력하세요
					}
				},
				
				userCodeSearch : function(num){
					CorpCardPopup.params._userCodeSearchKey	= num;
					
					var popupID		= "orgmap_pop";
					var openerID	= "CorpCardPopup";
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
					var userName	= arr.DN.split(';');	//이름
					var userNum		= arr.USEC.split(';');	//사번
					var UserID		= arr.UserID.split(';');
					var UserCode	= arr.UserCode.split(';');
					var trIdx = CorpCardPopup.params._userCodeSearchKey;
					CorpCardPopup.params._userCodeSearchKey = "";
					
					// 중복체크
					var isDup = false;
					$("tr[id^='ownerUserTR']").not("#ownerUserTR" + trIdx).each(function(idx,item){
						if($(item).find("input[id^='ownerUserCode']").val() == UserCode[0]){
							isDup = true;
							Common.Inform("<spring:message code='Cache.lbl_apv_already_add' />");	//이미 추가되어있습니다.
							return false;
						}
					});
					if(!isDup){
						var setUserNum		= "#ownerUserNum"		+ trIdx;
						var setUserCode		= "#ownerUserCode"		+ trIdx;
						var setUserName		= "#ownerUserName"		+ trIdx;
						var setUserNameEn	= "#ownerUserNameEn"	+ trIdx;
						$(setUserNum).val(userNum[0]);
						$(setUserCode).val(UserCode[0]);
						$(setUserName).val(userName[0]);
						$(setUserNameEn).val(userName[1]);
					}
				},
				
				ownerUserCodeAdd : function(){
					var me = this;
					var rSortArr	= CorpCardPopup.params._ownerUserKeyArr.sort(function(a,b){ return b.key - a.key});
					var maxKey		= rSortArr[0].key;
					var newKey		= maxKey + 1;
					var nowMaxId	= "#ownerUserTR" + maxKey;
					var newId		= "#ownerUserTR" + newKey;
					
					var appendStr	= "<tr id='ownerUserTR"+newKey+"'>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='ownerUserNum"			+ newKey+"'	type='text' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='ownerUserName"			+ newKey+"'	type='text' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='ownerUserCode"			+ newKey+"'	type='hidden' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='corpCardSearchUserID"	+ newKey+"'	type='hidden' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a	class='btn_search03'	onclick=\"CorpCardPopup.userCodeSearch("+newKey+")\">검색</a>"
									+			"<a class='btn_delType03'	onclick=\"CorpCardPopup.userCodeDel("+newKey+")\"><spring:message code='Cache.ACC_btn_delete'/></a>"
									+		"</div>"
									+	"</td>"
									+ "</tr>"
					$(nowMaxId).after(appendStr);
					$('#ownerUserTH0').attr("rowspan",rSortArr.length + 1);
					CorpCardPopup.params._ownerUserKeyArr.push({"key":newKey})
					me.comboRefresh();
				},

				userCodeDel : function(key){
					var me = this;
					if(key == null || key == ''){
						var ownerUserCode	= "#ownerUserCode";
						var ownerUserName	= "#ownerUserName";
						var ownerUserNameEn	= "#ownerUserNameEn";
						var ownerUserNum	= "#ownerUserNum"
						$(ownerUserCode).val('');
						$(ownerUserName).val('');
						$(ownerUserNameEn).val('');
						$(ownerUserNum).val('');
					}else{
						var tableId		= "#corpCardInfo"
						var tabelList	= $(tableId).children('tr');
						var tabelLen	= tabelList.length;
						var rSortArr	= CorpCardPopup.params._ownerUserKeyArr.sort(function(a,b){ return b.key - a.key});
						var arrLen		= rSortArr.length;
						var removeId		= "ownerUserTR" + key;
						var removeArr	= [];
						
						var corpCardSearchUserID 	= "#corpCardSearchUserID" + (key);
						var corpCardSearchUserIDVal	= $(corpCardSearchUserID).val();
						
						if(arrLen < 2){
							var ownerUserCode	= "#ownerUserCode"	+ (key);
							var ownerUserName	= "#ownerUserName"	+ (key);
							var ownerUserNum	= "#ownerUserNum"	+ (key);
							
							if(corpCardSearchUserIDVal != null && corpCardSearchUserIDVal != ''){
								CorpCardPopup.params._ownerUserDelArr.push({"corpCardSearchUserID":corpCardSearchUserIDVal})
							}
							
							$(ownerUserCode).val('');
							$(ownerUserName).val('');
							$(ownerUserNum).val('');
							$(corpCardSearchUserID).val('');
						}else{
							var strIdx = tabelList.find('[rowspan]').parent('tr').index();
							
							for(var i = 0; i < tabelLen; i++){
								if(tabelList[i].id == removeId){
									removeArr.push(key);
									if(corpCardSearchUserIDVal != null && corpCardSearchUserIDVal != ''){
										CorpCardPopup.params._ownerUserDelArr.push({"corpCardSearchUserID":corpCardSearchUserIDVal})
									}
									
									if(strIdx == i) { // 0번째 조회자 삭제 시
										tabelList.eq(strIdx + 1).find('div').append($('#ownerUserCodeAdd'));
										tabelList.eq(strIdx + 1).prepend(tabelList.eq(strIdx).find('th'));
										
										tabelList.eq(strIdx).remove();
									} else {
										tabelList.eq(i).remove();
									}
									
									break;
								}	
							}
							
							if(removeArr.length > 0){
								for(var ra=0; ra<removeArr.length; ra++){
									for(var rka=0; rka<CorpCardPopup.params._ownerUserKeyArr.length; rka++){
										if(removeArr[ra] == CorpCardPopup.params._ownerUserKeyArr[rka].key){
											CorpCardPopup.params._ownerUserKeyArr.splice(rka,1);
										}
									}
								}
							}
							
							$('#ownerUserTH0').attr("rowspan",CorpCardPopup.params._ownerUserKeyArr.length);
							me.comboRefresh();
						}
					}
				},
				
				checkValidation : function() {
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var params			= new Object();
					var ownerUserArr	= [];
					
					var cardNoRegExp			= /^[0-9]+$/;
					var expirationDateRegExp	= /^(\d{4})\/(0[1-9]|1[012])$/;
					
					var corpCardID		= $("#corpCardID").val();								//카드관리 ID
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();		//회사코드
					var cardNo			= $("#cardNo").val().replace(/\-/gi, '');									//카드번호
					var cardCompany		= accountCtrl.getComboInfo("cardCompany").val();		//카드회사
					var cardClass		= accountCtrl.getComboInfo("cardClass").val();			//카드유형
					var cardStatus		= accountCtrl.getComboInfo("cardStatus").val();			//카드상태
					var ownerUserCode	= $("#ownerUserCode").val();							//소유자코드
					var vendorNo		= $("#vendorNo").val();									//지급처등록번호
					var issueDate		= $("#issueDate").val();								//발급일자
					var payDate			= $("#payDate").val();									//결제일자
					var expirationDate	= $("#expirationDate").val();							//만료일자
					var limitAmountType	= accountCtrl.getComboInfo("limitAmountType").val();	//한도금액타입
					var limitAmount		= getNumOnly($("#limitAmount").val());					//한도금액
						limitAmount		= limitAmount == '' ? 0 : limitAmount;					//한도금액이 공백이면 0처리 (한도없는카드)
					var note			= $("#note").val();										//비고
					
					if(companyCode == null || companyCode==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_codeViewCC' />");	//회사명을 입력하세요
						return;
					}
					
					if(cardNo == null || cardNo==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataCardNum' />");	//카드번호를 입력하세요
						return;
					}
					
					/* if(vendorNo == null || vendorNo==''){
						Common.Inform("지급처를 선택하세요");	//지급처를 선택하세요
						return;
					} */
					
					if (mode == 'add') {
						if (cardNoRegExp.test(cardNo)){
							if(CorpCardPopup.params._cardNoChk == "fail"){
								Common.Inform("<spring:message code='Cache.ACC_msg_ckExistCardNum' />");	//카드번호 중복 여부를 확인하세요
								return;
							}else{
								if(cardNo != CorpCardPopup.params._cardNo){
									Common.Inform("<spring:message code='Cache.ACC_msg_ckExistCardNum' />");	//카드번호 중복여부를 확인하세요
									return;
								}
							}
						}else{
							Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");	//카드번호를 다시 입력하세요
							return;
						}
					}
					
					/* if(ownerUserCode == null || ownerUserCode==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckOwnerUser' />");	//소유자를 선택해주세요.
						return;
					} */
					
					/* if(issueDate == null || issueDate==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckIssueDate' />");	//발급일자를 확인하세요
						return;	
					} */
					
					/* if(payDate == null || payDate==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckPayDate' />");		//결제일자를 확인하세요
						return;	
					} */
					
					/* if(!expirationDateRegExp.test(expirationDate)){
						Common.Inform("<spring:message code='Cache.ACC_lbl_ckExpirationDate' />");	//만료일자를 확인하세요
						return;	
					} */
					
					var chkA	= expirationDate.split('/')[0]	+ expirationDate.split('/')[1];
					var chkB	= issueDate.split('.')[0]		+ issueDate.split('.')[1];
					
					if(chkA - chkB < 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckExIsDate' />");	//발급일자 또는 만료일자를 확인하세요
						return;	
					}
					
					/* if(limitAmount == null || limitAmount==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckLimitAmt' />");	//한도금액을 확인해주세요
						return;	
					} */
					
					for(var i=0; i<CorpCardPopup.params._ownerUserKeyArr.length; i++){
						
						var key		= CorpCardPopup.params._ownerUserKeyArr[i].key;
						var nowCode = "#ownerUserCode"			+ (key);
						var nowID	= "#corpCardSearchUserID"	+ (key);
						
						var nowCodeVal	= $(nowCode).val();
						var nowIDVal	= $(nowID).val();
						
						// 조회자 필수 입력 X
						/* if(nowCodeVal == null || nowCodeVal == ''){
							Common.Inform("<spring:message code='Cache.ACC_msg_ckOwner' />");	//조회자를 선택해주세요.
							return;
						} */
						
						var obj = {	"ownerUserCode"			: nowCodeVal
								,	"corpCardSearchUserID"	: nowIDVal};
						ownerUserArr.push(obj);
					}
					
					params.corpCardID		= corpCardID;
					params.companyCode		= companyCode;
					params.cardNo			= cardNo;
					params.cardCompany		= cardCompany;
					params.cardClass		= cardClass;
					params.cardStatus		= cardStatus;
					params.ownerUserCode	= ownerUserCode;
					params.vendorNo			= vendorNo;
					params.issueDate		= issueDate.replace('.','').replace('.','');
					params.payDate			= payDate;
					params.expirationDate	= expirationDate.replace('/','');
					params.limitAmountType	= limitAmountType;
					params.limitAmount		= limitAmount;
					params.note				= note;
					params.ownerUserArr		= ownerUserArr;
					params.ownerUserDelArr	= CorpCardPopup.params._ownerUserDelArr;
					
					$.ajax({
						url			: "/account/corpCard/saveCorpCardInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								CorpCardPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				changeCardNo : function(){
					var cardNo = $('#cardNo').val();
						cardNo = getCardNoValue(cardNo,'');
					$('#cardNo').val(cardNo);
				},
				
				changeLimitAmount : function(){
					var limitAmount = $('#limitAmount').val();
						limitAmount = getAmountValue(limitAmount);
					$('#limitAmount').val(limitAmount);
				},
				
				limitAmountTypeChange : function(){
					var limitAmountType	= accountCtrl.getComboInfo('limitAmountType').val();
					var limitAmount		= 0;
					if(limitAmountType == '' || limitAmountType == null){
						$("#limitAmount").attr("disabled", false);
						limitAmount		= 0;
					}else{
						$("#limitAmount").attr("disabled", true);
						limitAmount		= limitAmountType.split('LAT')[1] * 1000000;
					}
					
					$('#limitAmount').val(getAmountValue(limitAmount));
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
		window.CorpCardPopup = CorpCardPopup;
	})(window);
	
	CorpCardPopup.popupInit();
</script>