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
	<input id="mode"			type="hidden" />
	<input id="corpCardID"		type="hidden" />
	<input id="CardNoReturn"	type="hidden" />
	<input id="CardCompany"		type="hidden" />	
	<input id="ReleaseYN"		type="hidden" />
	<input id="DocLink"			type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 200px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody id="corpCardInfo">
							<tr type='CorpCardPopup_cardList' hidden>
								<th>	
								<!-- 법인카드 -->
									<spring:message code='Cache.ACC_lbl_corpCard'/>
								</th>
								<td>
									<div class="box">
										<a onclick="CorpCardPopup.corpCardReleaseListPopup()" class="btnTypeDefault"><spring:message code='Cache.ACC_lbl_CardSelect'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>	
								<!-- 카드번호 -->
									<spring:message code='Cache.lbl_cardNumber'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input	id="cardNo" type="text" disabled class= "HtmlCheckXSS ScriptCheckXSS">										
									</div>
								</td>
							</tr>
							<tr type='CorpCardPopup_release' hidden>
								<th>	<!-- 불출일자 -->
									<spring:message code='Cache.ACC_lbl_ReleaseDate'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<div id="ReleaseDateArea" class="dateSel type02" style="display:inline;float:left">
										
										</div>
										<div style="display:inline;float:right;padding-left:10px;">
											<input id="ReleaseDate_H" type="text" style="width:30px;float:none" onchange="CorpCardPopup.validationTime(this,'H')">
											<spring:message code='Cache.lbl_Hour'/>
											<input id="ReleaseDate_M" type="text" style="width:30px;float:none" onchange="CorpCardPopup.validationTime(this,'M')">
											<spring:message code='Cache.lbl_Minutes'/>
										</div>
										<!-- 
										* yyyy-MM-dd 형식으로 입력하세요.
										 -->
									</div>
								</td>
							</tr> 
							<tr type='CorpCardPopup_return' hidden>
								<th>	<!-- 반납일자 -->
									<spring:message code='Cache.ACC_lbl_ReturnDate'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<div id="ReturnDateArea" class="dateSel type02" style="display:inline;float:left">
										
										</div>
										<div style="display:inline;float:right;padding-left:10px;">
											<input id="ReturnDate_H" type="text" style="width:30px;float:none" onchange="CorpCardPopup.validationTime(this,'H')">
											<spring:message code='Cache.lbl_Hour'/>
											<input id="ReturnDate_M" type="text" style="width:30px;float:none" onchange="CorpCardPopup.validationTime(this,'M')">
											<spring:message code='Cache.lbl_Minutes'/>
										</div>
										<!-- 
										* yyyy-MM-dd 형식으로 입력하세요.
										 -->
									</div>
								</td>
							</tr> 
							<tr id="releaseUserTR0">
								<th id="releaseUserTH0">	<!-- 불출자  -->
									<spring:message code='Cache.ACC_lbl_ReleaseUser'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="releaseUserNum0"			type="hidden" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="releaseUserName0"		type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="releaseUserCode0"		type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
										<input id="corpCardSearchUserID0"	type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
										<a id="releaseuserCodeSearch0"		class="btn_search03"	onclick="CorpCardPopup.userCodeSearch('0')"><spring:message code='Cache.ACC_btn_search'/></a> 
									</div>
								</td>
							</tr>
							<tr type='CorpCardPopup_linkDoc' hidden>
								<th>
									<!-- 연결문서 -->
									<spring:message code='Cache.lbl_apv_linkdoc'/>
								</th>
								<td>
									<div class="box">
										<div style="float: left;">
											<a class="btnTypeDefault" onclick="CorpCardPopup.selectDoc();"><spring:message code='Cache.lbl_apv_selectDoc'/></a> <!-- 문서선택 -->
										</div>
										<div id="docLinkTitle" style="float: right; margin-left: 5px; line-height: 30px;"></div>
									</div>
								</td>
							</tr>
							<tr type='CorpCardPopup_releaseReason' hidden>
								<th>
									<!-- 불출사유 -->
									<spring:message code='Cache.ACC_lbl_cardReleaseReason'/>
									<span class="star"></span>
								</th>
								<td>
									<textarea id="releaseReason" style="margin: 10px 15px; width: 90%; resize: none;"></textarea>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="CorpCardPopup.checkValidation('Y')"	id="btnSave_Y"	class="btnTypeDefault btnTypeBg" style="display:none;"><spring:message code='Cache.ACC_btn_release'/></a> <!-- 불출 -->
					<a onclick="CorpCardPopup.checkValidation('N')"	id="btnSave_N"	class="btnTypeDefault btnTypeBg" style="display:none;"><spring:message code='Cache.ACC_btn_return'/></a> <!-- 반납 -->
					<a onclick="CorpCardPopup.closeLayer()"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a> <!-- 취소 -->
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
					_releaseUserKeyArr	: [{"key":0}],
					_releaseUserDelArr	: [],
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
					//me.setSelectCombo();
					//me.setPopupEdit();
					me.getPopupInfo();
				},
				
				setCalendar : function(ym) {
					var target = 'issueDate';
					coviCtrl.makeSimpleCalendar(target, ym);
				},
				
				pageDatepicker : function(){
					//makeDatepicker('ReleaseDateArea','ReleaseDate','','','','');
					makeDatepicker('ReleaseDateArea','ReleaseDate','','','','');
					makeDatepicker('ReturnDateArea','ReturnDate','','','','');
					
				},
			
				getPopupInfo : function(){
					var me = this;
					var mode		= $("#mode").val();
					var corpCardID	= $("#corpCardID").val();
					
					if(corpCardID == "R"){
						$("#btnSave_Y").css('display','');
						$("[type=CorpCardPopup_cardList]").removeAttr('hidden');
						$("[type=CorpCardPopup_Release]").removeAttr('hidden');
						$("[type=CorpCardPopup_linkDoc]").removeAttr('hidden');
						$("[type=CorpCardPopup_releaseReason]").removeAttr('hidden');
					}else{
						$.ajax({
							url	:"/account/corpCard/getCorpCardDetail.do",
							type: "POST",
							data: {
									"corpCardID" : corpCardID
							},
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
										$("#ReleaseDate").val(info.ReleaseDate);
										$("#ReleaseDate_H").val(info.ReleaseDate_H);
										$("#ReleaseDate_M").val(info.ReleaseDate_M);
										$("#ReturnDate").val(info.ReturnDate);
										$("#ReturnDate_H").val(info.ReturnDate_H);
										$("#ReturnDate_M").val(info.ReturnDate_M);
										$("#payDate").val(info.PayDate);
										accountCtrl.getComboInfo("limitAmountType").bindSelectSetValue(info.LimitAmountType);
										$("#limitAmount").val(getAmountValue(info.LimitAmount));
										$("#note").val(info.Note);
										$("#releaseUserCode0").val(info.ReleaseUserCode);
										$("#vendorNo").val(info.VendorNo);
										$("#vendorName").val(info.VendorName);
										
										$("#CardNoReturn").val(info.CardNoReturn);
										$("#ReleaseYN").val(info.ReleaseYN);
										$("#CardCompany").val(info.CardCompany);
										
										if(info.ReleaseYN == "Y"){
											CorpCardPopup.getReleaseUserInfo(info.ReleaseUserCode);
											$("#btnSave_N").css('display','');
											$("#releaseuserCodeSearch0").css('visibility','hidden');
											$("[type=CorpCardPopup_return]").removeAttr('hidden');
										}else{
											$("#btnSave_Y").css('display','');
											$("[type=CorpCardPopup_Release]").removeAttr('hidden');
											$("[type=CorpCardPopup_linkDoc]").removeAttr('hidden');
											$("[type=CorpCardPopup_releaseReason]").removeAttr('hidden');
										}
									}
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}
				},
				
				getReleaseUserInfo : function(ReleaseUserCode){
					$.ajax({
						url	: "/account/corpCard/getReleaseUserInfo.do",
						type: "POST",
						data: {
								"ReleaseUserCode" : ReleaseUserCode
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								var info = data.list[0];

								$("#releaseUserName0").val(info.ReleaseUserName);
								$("#releaseUserNameEn").val(info.ReleaseUserNameEn);
								$("#releaseUserNum").val(info.ReleaseUserNum);
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				// 법인카드 목록 팝업
				corpCardReleaseListPopup : function(){
					var popupTitText ="<spring:message code='Cache.ACC_lbl_cardRelease' />"; // 카드불출
					
					var popupID		= "corpListPopup";
					var openerID	= "CorpCardList";					
					var popupTit	= popupTitText;	
					var popupYN		= "N";
					var callBack	= "corpCardPopup_CallBack";
					var popupUrl	= "/account/corpCard/getCorpCardReleaseListPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					parent.Common.open("", popupID, popupTit, popupUrl, "1000px", "500px", "iframe", true, null, null, true);
				},
				
				corpCardPopup_CallBack : function(){
					var me = this
					me.searchList();
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
					parent.Common.open(	"",popupID,popupTit,url,"700px","400px","iframe",true,null,null,true);
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
					parent.Common.open(	"",popupID,popupTit,url,"500px","190px","iframe",true,null,null,true);
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
					
					var setUserNum		= "#releaseUserNum"		+ CorpCardPopup.params._userCodeSearchKey;
					var setUserCode		= "#releaseUserCode"	+ CorpCardPopup.params._userCodeSearchKey;
					var setUserName		= "#releaseUserName"	+ CorpCardPopup.params._userCodeSearchKey;
					var setUserNameEn	= "#releaseUserNameEn"	+ CorpCardPopup.params._userCodeSearchKey;
					$(setUserNum).val(userNum[0]);
					$(setUserCode).val(UserCode[0]);
					$(setUserName).val(userName[0]);
					$(setUserNameEn).val(userName[1]);
					
					CorpCardPopup.params._userCodeSearchKey	= "";
				},
				
				releaseUserCodeAdd : function(){
					var me = this;
					var rSortArr	= CorpCardPopup.params._releaseUserKeyArr.sort(function(a,b){ return b.key - a.key});
					var maxKey		= rSortArr[0].key;
					var newKey		= maxKey + 1;
					var nowMaxId	= "#releaseUserTR" + maxKey;
					var newId		= "#releaseUserTR" + newKey;
					
					var appendStr	= "<tr id='releaseUserTR"+newKey+"'>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='releaseUserNum"			+ newKey+"'	type='text' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='releaseUserName"		+ newKey+"'	type='text' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='releaseUserCode"		+ newKey+"'	type='hidden' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<input id='corpCardSearchUserID"	+ newKey+"'	type='hidden' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a	class='btnMoreStyle02'	onclick=\"CorpCardPopup.userCodeSearch("+newKey+")\">검색</a>"
									+		"</div>"
									+	"</td>"
									+ "</tr>"
					$(nowMaxId).after(appendStr);
					$('#releaseUserTH0').attr("rowspan",rSortArr.length + 1);
					CorpCardPopup.params._releaseUserKeyArr.push({"key":newKey})
				},

				userCodeDel : function(key){
					var me = this;
					if(key == null || key == ''){
						var releaseUserCode	= "#releaseUserCode";
						var releaseUserName	= "#releaseUserName";
						var releaseUserNameEn	= "#releaseUserNameEn";
						var releaseUserNum	= "#releaseUserNum"
						$(releaseUserCode).val('');
						$(releaseUserName).val('');
						$(releaseUserNameEn).val('');
						$(releaseUserNum).val('');
					}else{
						var tableId		= "#corpCardInfo"
						var tabelList	= $(tableId).children('tr');
						var tabelLen	= tabelList.length;
						var rSortArr	= CorpCardPopup.params._releaseUserKeyArr.sort(function(a,b){ return b.key - a.key});
						var arrLen		= rSortArr.length;
						var maxKey		= rSortArr[0].key;
						var MaxId		= "releaseUserTR" + maxKey;
						var removeArr	= [];
						
						var corpCardSearchUserID 	= "#corpCardSearchUserID" + (maxKey);
						var corpCardSearchUserIDVal	= $(corpCardSearchUserID).val();
						
						if(arrLen < 2){
							var releaseUserCode	= "#releaseUserCode"	+ (maxKey);
							var releaseUserName	= "#releaseUserName"	+ (maxKey);
							var releaseUserNum	= "#releaseUserNum"	+ (maxKey);
							
							if(corpCardSearchUserIDVal != null && corpCardSearchUserIDVal != ''){
								CorpCardPopup.params._releaseUserDelArr.push({"corpCardSearchUserID":corpCardSearchUserIDVal})
							}
							
							$(releaseUserCode).val('');
							$(releaseUserName).val('');
							$(releaseUserNum).val('');
							$(corpCardSearchUserID).val('');
						}else{
							for(var i = 0; i < tabelLen; i++){
								if(tabelList[i].id == MaxId){
									removeArr.push(maxKey);
									if(corpCardSearchUserIDVal != null && corpCardSearchUserIDVal != ''){
										CorpCardPopup.params._releaseUserDelArr.push({"corpCardSearchUserID":corpCardSearchUserIDVal})
									}
									
									tabelList.eq(i).remove();
									break;
								}	
							}
							
							if(removeArr.length > 0){
								for(var ra=0; ra<removeArr.length; ra++){
									for(var rka=0; rka<CorpCardPopup.params._releaseUserKeyArr.length; rka++){
										if(removeArr[ra] == CorpCardPopup.params._releaseUserKeyArr[rka].key){
											CorpCardPopup.params._releaseUserKeyArr.splice(rka,1);
										}
									}
								}
							}
							
							$('#releaseUserTH0').attr("rowspan",CorpCardPopup.params._releaseUserKeyArr.length);
						}
					}
				},
				
				selectDoc : function(){
					CFN_OpenWindow("/approval/goDocListSelectPage.do", "", "840px", "660px", "fix");
				},
				
				checkValidation : function(ReleaseYN) {
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var params			= new Object();
					var cardNoRegExp			= /^[0-9]+$/;
					var expirationDateRegExp	= /^(\d{4})\/(0[1-9]|1[012])$/;
					
					var corpCardID		= $("#corpCardID").val();								//카드관리 ID					
					var cardNo			= $("#cardNo").val().replace(/\-/gi, '');				//카드번호
					var cardStatus		= accountCtrl.getComboInfo("cardStatus").val();			//카드상태
					var releaseUserCode	= $("#releaseUserCode0").val();							//소유자코드					
					var releaseReason	= $("#releaseReason").val();							//불출사유				
					var docLink			= $("#DocLink").val();									//연결문서				
					var ReleaseDate		= $("#ReleaseDate").val().replaceAll(/\./gi,'');		//불출일자				
					var ReleaseDate_H	= $("#ReleaseDate_H").val();							//불출일자				
					var ReleaseDate_M	= $("#ReleaseDate_M").val();							//불출일자				
					var ReturnDate		= $("#ReturnDate").val().replaceAll(/\./gi,'');			//반납일자				
					var ReturnDate_H	= $("#ReturnDate_H").val();								//반납일자				
					var ReturnDate_M	= $("#ReturnDate_M").val();								//반납일자
					ReleaseDate = ReleaseDate.substring(0,8)
					ReleaseDate_H = ReleaseDate_H.length==1?"0"+ReleaseDate_H:ReleaseDate_H;
					ReleaseDate_M = ReleaseDate_M.length==1?"0"+ReleaseDate_M:ReleaseDate_M;
					ReleaseDate = ReleaseDate+ReleaseDate_H+ReleaseDate_M+"00";

					ReturnDate = ReturnDate.substring(0,8)
					ReturnDate_H = ReturnDate_H.length==1?"0"+ReturnDate_H:ReturnDate_H;
					ReturnDate_M = ReturnDate_M.length==1?"0"+ReturnDate_M:ReturnDate_M;
					ReturnDate = ReturnDate+ReturnDate_H+ReturnDate_M+"00";
					
					var CardNoReturn	= $("#CardNoReturn").val();							//카드번호					 	
					var CardCompany		= $("#CardCompany").val();							//회사
					
					if(cardNo==undefined||cardNo==null||cardNo=='')
					{
						Common.Warning("<spring:message code='Cache.ACC_msg_selectCard'/>"); //카드를 선택해주세요.
						return;
					}
					if((ReleaseYN=='Y'&&ReleaseDate.length!=14)||(ReleaseYN=='N'&&ReturnDate.length!=14))
					{
						Common.Warning("<spring:message code='Cache.ACC_msg_Date'/>"); //날짜를 입력해주세요
						return;
					}
					if(releaseUserCode==undefined||releaseUserCode==null||releaseUserCode=='')
					{
						Common.Warning("<spring:message code='Cache.ACC_msg_ReleaseUser'/>"); //불출/반납자를 확인하세요 
						return;
					}
					if(ReleaseYN=='Y'&&(releaseReason==undefined||releaseReason==null||releaseReason==''))
					{
						Common.Warning("<spring:message code='Cache.ACC_msg_ReleaseReason'/>"); //불출사유를 입력해주세요.
						return;
					}
					
					params.corpCardID		= corpCardID;
					params.cardNo			= cardNo;
					params.cardStatus		= cardStatus;
					params.ReleaseUserCode	= releaseUserCode;
					params.ReleaseReason	= releaseReason;
					params.DocLink			= docLink;
					params.ReleaseDate		= ReleaseDate;
					params.ReleaseDate_H	= ReleaseDate_H;
					params.ReleaseDate_M	= ReleaseDate_M;
					params.ReturnDate		= ReturnDate;
					params.ReturnDate_H		= ReturnDate_H;
					params.ReturnDate_M		= ReturnDate_M;
					
					
					params.CardNoReturn		= CardNoReturn;
					params.CardCompany		= CardCompany;					
					params.ReleaseYN		= ReleaseYN;					
					params.ReturnYPerson	= "ReturnYPerson";
					params.ReturnNPerson	= "ReturnNPerson";
					
					$.ajax({
						url			: "/account/corpCard/updateCorpReturnCardInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								CorpCardPopup.closeLayer();
								parent.accountCtrl.pageRefresh();
								
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
				},
				validationTime: function(obj,type){
					var val = obj.value;
					if(type=="H")
					{
						val = val<=23&&val>=0?val:'';
					}
					else 
					{
						val = val<=59&&val>=0?val:'';
					}
					obj.value = val;
				}
		}
		window.CorpCardPopup = CorpCardPopup;
	})(window);
	
	CorpCardPopup.popupInit();
	
	function InputDocLinks(szValue){
		$("#DocLink").val(szValue);
		$("#docLinkTitle").text(szValue.split("@@@")[2]);
	}
</script>