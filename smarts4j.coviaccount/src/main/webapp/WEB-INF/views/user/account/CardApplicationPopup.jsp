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
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" style="width:800px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 20%;" />
						<col style="width: auto;" />
						<col style="width: 20%;" />
						<col style="width: auto;" />
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code="Cache.ACC_lbl_title"/><span class="star"></span></th>
							<td colspan="3">
								<div class="box" style="width:100%;">
									<input id="cardApplicationPopup_inputApplicationTitle" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%;" placeholder="<spring:message code='Cache.ACC_msg_noTitle' />" >	<!-- 제목을 입력하세요. -->
								</div>
							</td>
						</tr>
						<tr>							<!-- 신청유형 -->
							<th><spring:message code="Cache.ACC_lbl_vendorRequestType"/><span class="star"></span></th>
							<td >
								<div class="box">
									<span id="cardApplicationPopup_inputApplicationType" class="selectType02" onChange="CardApplicationPopup.appTypeChange(this)">
									</span>
								</div>
							</td>					<!-- 등록자 -->
							<th><spring:message code="Cache.ACC_lbl_registerName"/></th>
							<td >
								<div class="box">
									<input id="cardApplicationPopup_inputRegisterName" type="text" disabled=true class="HtmlCheckXSS ScriptCheckXSS">
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<div style="height:10px">
				</div>
				<div class="middle">
					<div id="limitChangeArea" style="display:none">
						<jsp:include page="CardAppPopupLimitChange.jsp" ></jsp:include>
					</div>
					<div id="newCardArea" style="display:none">
						<jsp:include page="CardAppPopupNew.jsp" ></jsp:include>
					</div>
					<div id="cardReissueArea" style="display:none">
						<jsp:include page="CardAppPopupReissue.jsp" ></jsp:include>
					</div>
					<div id="cardCloseArea" style="display:none">
						<jsp:include page="CardAppPopupClose.jsp" ></jsp:include>
					</div>
					<div id="publidCardArea" style="display:none">
						<jsp:include page="CardAppPopupPublicCard.jsp" ></jsp:include>
					</div>
					<div id="prCardArea" style="display:none">
						<jsp:include page="CardAppPopupPrCard.jsp" ></jsp:include>
					</div>
					
				</div>
				
				<input type="hidden" id="cardApplicationPopup_inputCardApplicationID" >
				<input type="hidden" id="cardApplicationPopup_inputIsNew" >
				<div class="popBtnWrap bottom">
					<a onclick="CardApplicationPopup.CheckValidation('T');"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="CardApplicationPopup.CheckValidation('S');"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_application' /></a>	<!-- 신청 -->
					<a onclick="CardApplicationPopup.closeLayer();"				id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>
	
	if (!window.CardApplicationPopup) {
		window.CardApplicationPopup = {};
	}
	
	(function(window) {
		var CardApplicationPopup = {
				
				params : {
					pageDataObj				: {},
					pageCardApplicationID	: "${CardApplicationID}",
					cardList				: [],
					cardMap					: {}
				},
				
				popupInit : function(){
					var me = this;
					
					accountCtrl.renderAXSelect('CardApplicationType','cardApplicationPopup_inputApplicationType','ko','','','');
					
					if("${isNew}" == "Y"){
						me.callCompanyCardList();
					}					
					
					setFieldDataPopup("cardApplicationPopup_inputIsNew", "${isNew}");
					me.pageDatepicker();
					
					me.setInit();
				},
				
				setInit : function(){
					var me = this;
					if("${isNew}" != "Y"){
						var getCardApplicationID = "${CardApplicationID}";
						me.searchDetailData(getCardApplicationID);
					}else{
						setFieldDataPopup("cardApplicationPopup_inputRegisterName",Common.getSession().USERNAME );
						var applicationType = accountCtrl.getComboInfo("cardApplicationPopup_inputApplicationType").val();
						switch(applicationType) {
						case "CoCardLimitChange":
							$("#limitChangeArea").css("display",	"");
							break;
						case "CoCardReissue":
							$("#cardReissueArea").css("display",	"");
							break;
						case "CoCardNewissue":
							$("#newCardArea").css("display",		"");
							break;
						case "CoCardClose":
							$("#cardCloseArea").css("display",		"");
							break;
						case "PublicCardRequest":
							$("#publidCardArea").css("display",		"");
							break;
						case "PrCardApp":
							$("#prCardArea").css("display",		"");
							break;
						}
						
					}
				},
				
				//법인카드 목록 조회, 콤보 생성
				callCompanyCardList : function(){
					var me = this;
					$.ajax({
						data: {},
						cache: false,
						url:"/account/baseInfo/getCompanyCardComboList.do",
						success:function (data) {
							if(data.result == "ok"){
								me.params.cardList = data.list;
								for(var i = 0; i < me.params.cardList.length; i++)	 {
									var item = me.params.cardList[i];
									me.params.cardMap["cardED_"+item.CardNo]	= item.ExpirationDate
									me.params.cardMap["cardLA_"+item.CardNo]	= item.LimitAmount
									me.params.cardMap["cardLAT_"+item.CardNo]	= item.LimitAmountType
									me.params.cardMap["cardCC_"+item.CardNo]	= item.CardCompany
								}
								me.limitChangeComboInit(me.params.cardList);
								me.reissueComboInit(me.params.cardList);
								me.closeComboInit(me.params.cardList);
								me.prCardComboInit();
								
								me.setInit();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				//상세정보 조회
				searchDetailData : function(getCardApplicationID){
					var me = this;
					var searchCardApplicationID = "";
					
					if(	getCardApplicationID == null	||
						isEmptyStr(getCardApplicationID)){
						searchCardApplicationID = me.params.pageCardApplicationID;
					}else{
						searchCardApplicationID = getCardApplicationID;
						me.params.pageCardApplicationID = getCardApplicationID;
					}
					
					setFieldDataPopup("cardApplicationPopup_inputCardApplicationID", me.params.pageCardApplicationID);

					$.ajaxSetup({
						cache : false
					});
					
					$.getJSON('/account/baseInfo/searchCardApplicationDetail.do', {CardApplicationID : getCardApplicationID}
						, function(r) {
							if(r.result == "ok"){
								setFieldDataPopup("cardApplicationPopup_inputIsNew", "N");
								var data = r.data
								accountCtrl.getComboInfo("cardApplicationPopup_inputApplicationType").bindSelectSetValue(data.ApplicationType)
								setFieldDataPopup("cardApplicationPopup_inputApplicationTitle",data.ApplicationTitle );
								setFieldDataPopup("cardApplicationPopup_inputRegisterName",data.RegisterName );
								
								//법인카드 콤보 생성
								me.params.cardList = r.list;
								for(var i = 0; i < me.params.cardList.length; i++)	 {
									var item = me.params.cardList[i];
									me.params.cardMap["cardED_"+item.CardNo]	= item.ExpirationDate
									me.params.cardMap["cardLA_"+item.CardNo]	= item.LimitAmount
									me.params.cardMap["cardLAT_"+item.CardNo]	= item.LimitAmountType
									me.params.cardMap["cardCC_"+item.CardNo]	= item.CardCompany
								}
								me.limitChangeComboInit(me.params.cardList);
								me.reissueComboInit(me.params.cardList);
								me.closeComboInit(me.params.cardList);
								me.prCardComboInit();
								
								var ApplicationType = data.ApplicationType
								if(ApplicationType == "CoCardLimitChange"){
									me.setCardLimitChangeData(data);
								}else if(ApplicationType == "CoCardReissue"){
									me.setCardReissueData(data);
								}else if(ApplicationType == "CoCardClose"){
									me.setCardCloseData(data);
								}else if(ApplicationType == "PublicCardRequest"){
									me.setPublicCardData(data);
								}else if(ApplicationType == "PrCardApp"){
									me.setPrCardData(data);
								}
								else if(ApplicationType == "CoCardNewissue"){
									me.setCardNewissueData(data);
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_erorr' />");
							}
						}).error(function(response, status, error){
					});
				},

				//유형 변경
				appTypeChange : function(input){
					var me = this;
					var val = input.value;
					if(input.tagName !="SELECT"){
						return;
					}
					
					var popupH = '0px';
					if(val == "CoCardLimitChange"){
						$("#limitChangeArea").css("display",	"");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						me.limitChangeComboRefresh();
						popupH= '560px';
						
					}else if(val == "CoCardReissue"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						me.reissueComboRefresh();
						popupH = '480px';
						
					}else if(val == "CoCardClose"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						me.closeComboRefresh();
						popupH = '480px';
						
					}else if(val == "PublicCardRequest"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						popupH = '480px';
						
					}else if(val == "PrCardApp"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display", "");
						$("#newCardArea").css("display",		"none");
						me.prCardComboRefresh();
						popupH = '440px';
						
					}else if(val == "CoCardNewissue"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"");
						popupH = '480px';
						
					}
					
					accountCtrl.changePopupSize('',popupH);
				},

				//저장전 유효성 검사
				CheckValidation : function(type){
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var me = this;
					me.params.pageDataObj	= {};
					var CardApplicationID	= getTxTFieldDataPopup("cardApplicationPopup_inputCardApplicationID");
					var ApplicationType		= accountCtrl.getComboInfo("cardApplicationPopup_inputApplicationType").val();
					var ApplicationTitle	= getTxTFieldDataPopup("cardApplicationPopup_inputApplicationTitle");
					var IsNew				= getTxTFieldDataPopup("cardApplicationPopup_inputIsNew");
					
					me.params.pageDataObj.CardApplicationID	= CardApplicationID;
					me.params.pageDataObj.SessionUser		= Common.getSession().USERID
					me.params.pageDataObj.ApplicationType	= ApplicationType;
					me.params.pageDataObj.ApplicationTitle	= ApplicationTitle;
					me.params.pageDataObj.IsNew				= IsNew;
					me.params.pageDataObj.ApplicationStatus = type;
					
					if(	ApplicationType == null	||
						isEmptyStr(ApplicationType)){
						Common.Error("<spring:message code='Cache.ACC_011'/>");		//신청유형을 선택해 주십시오
						return;
					}
					
					if(	ApplicationTitle == null	||
						isEmptyStr(ApplicationTitle)){
						Common.Error("<spring:message code='Cache.ACC_012'/>");		//제목을 입력해 주십시오
						return;
					}
					
					var reqMsg = "";
					if(ApplicationType == "CoCardLimitChange"){
						me.getCardLimitChangeData();
						me.params.pageDataObj.CardCompany = me.params.cardMap["cardCC_"+me.params.pageDataObj.CardNo ];
						reqMsg = me.checkCardLimitChange();
					}else if(ApplicationType == "CoCardReissue"){
						me.getCardReissueData();
						me.params.pageDataObj.CardCompany = me.params.cardMap["cardCC_"+me.params.pageDataObj.CardNo ];
						reqMsg = me.checkCardReissue();
					}else if(ApplicationType == "CoCardClose"){
						me.getCardCloseData();
						me.params.pageDataObj.CardCompany = me.params.cardMap["cardCC_"+me.params.pageDataObj.CardNo ];
						reqMsg = me.checkCardClose();
					}else if(ApplicationType == "PublicCardRequest"){
						me.getPublicCardData();
						reqMsg = me.checkPublicCard();
					}else if(ApplicationType == "PrCardApp"){
						me.getPrCardData();
						reqMsg = me.checkPrCard();
					}else if(ApplicationType == "CoCardNewissue"){
						me.getCardNewissueData();
					}
					
					if(reqMsg != ""){
						Common.Inform(reqMsg);
						return;
					}
					
					var msg = "ACC_isSaveCk";
					if(type=="S"){
						msg = "ACC_isAppCk"
					}
					
					if( chkInputCode(ApplicationTitle)){
								Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");	//<는 사용할수 없습니다.
								return;
							}
					
			        Common.Confirm(Common.getDic(msg), "Confirmation Dialog", function(result){	//저장하시겠습니까?
			       		if(result){
							me.saveCardRequestData();
			       		}
			        });
				},
				
				//내용 저장
				saveCardRequestData : function(){
					var me = this;
					$.ajax({
						type:"POST",
						url:"/account/baseInfo/saveCardApplicationData.do",
						data:{
							"cardAppObj" : JSON.stringify(me.params.pageDataObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								me.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e){
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else if(data.result == "D"){
								Common.Error('<spring:message code='Cache.ACC_048'/>'); // 이미 등록되었거나 신청중인 카드번호입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				//법인카드 콤보 변경
				onCardChange : function(data, page){
					var me = this;
					var cardNo = null;

					if(data.tagName !="SELECT"){
						return;
					}
					
					if(data == null){
						cardNo = getTxTFieldDataPopup("cardAppPopupLimitChange_inputCardNo");
					}else{
						var cardNo = data.value;
					}
					
					if(!isEmptyStr(cardNo)){
						var cardLA = me.params.cardMap["cardLA_"+cardNo ];
						cardLA = toAmtFormat(cardLA)
						setFieldDataPopup(page+"_inputExpirationDate",	me.params.cardMap["cardED_"+cardNo ]);
						setFieldDataPopup(page+"_inputCurrentAmount",	cardLA == '' ? 0 : cardLA);
					}else{
						setFieldDataPopup(page+"_inputExpirationDate",	"");
						setFieldDataPopup(page+"_inputCurrentAmount",	"");
					}
					
					if(page=="cardAppPopupLimitChange"){
						me.setLmtTyp();
					}
				},
				
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardApplicationPopup);
	})(window);
	
	CardApplicationPopup.popupInit();
	
</script>