<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.pad10 { padding:10px;}
</style>
<body>
	<!-- 이어카운팅 포탈 시작-->
	<div class="eAccountingPortalWrap" id = "fixedTabAccViewArea" style="overflow-y: scroll; height: 100%;">
		<div class="eAPListWrap">
			<div class="eAPListBox_P">
				<div class="eAPListBox">
					<div class="eAPList_Top">
						<h3 class="eAPList_Toptitle">
							<spring:message code='Cache.ACC_lbl_corpCardUseList'/>	<!--법인카드 사용 내역-->
							<span class="eAPcountStyle c01" name="accPortal_CorpCardCnt"></span>
						</h3>
						<a href="#" class="eAPList_morebtn" onclick="AccountPortal.accPortal_moreListView('C')">more+</a>
					</div>
					<div class="eAPBoardTitleBorder c01"></div>
					<ul name="accPortal_CorpCardArea" style="height:135px">
					</ul>
				</div>
			</div>
			<div class="eAPListBox_P">
				<div class="eAPListBox">
					<div class="eAPList_Top">
						<h3 class="eAPList_Toptitle">
							<spring:message code='Cache.ACC_lbl_aprvReqList'/>	<!-- 승인요청 내역 -->
							<span class="eAPcountStyle c02" name="accPortal_ExpAppAprvCnt"></span>
						</h3>
						<a href="#" class="eAPList_morebtn" onclick="AccountPortal.accPortal_moreListView('A')">more+</a>
					</div>
					<div class="eAPBoardTitleBorder c02"></div>
					<ul name="accPortal_ExpAppAprvArea" style="height:135px">
					</ul>
				</div>
			</div>
			<div class="eAPListBox_P">
				<div class="eAPListBox">
					<div class="eAPList_Top">
						<h3 class="eAPList_Toptitle">
							<spring:message code='Cache.ACC_lbl_taxInvoiceUseList'/>	<!-- 세금게산서 내역 -->
							<span class="eAPcountStyle c03" name="accPortal_TaxInvoiceCnt"></span>
						</h3>
						<a href="#" class="eAPList_morebtn" onclick="AccountPortal.accPortal_moreListView('T')">more+</a>
					</div>
					<div class="eAPBoardTitleBorder c03"></div>
					<ul name="accPortal_TaxInvoiceArea" style="height:135px">
					</ul>
				</div>
			</div>
		</div>
		<div class="eAPBanner">
			<span class="eAPBannerText" name="accPortal_DeadlineArea" >
			<!-- 
			<strong>3월</strong> 경비 마감일 "<strong>4월 11일</strong>" 까지
			 -->
			</span>
		</div>
		<div class="eAPBoard">
			<div class="eAPBoardR">
				<h3 class="eAPBoardTitle" name="accPortal_CorpCardMonUseArea">
					<span class="pagingType01">
						<a href="#" class="pre" onclick="AccountPortal.accPortal_corpCardInfoPre()"></a>
						<a href="#" class="next" onclick="AccountPortal.accPortal_corpCardInfoNext()"></a>
						<span class="Unit" name="accPortal_CorpCardListInfo">
						</span>
					</span>
				</h3>
				<div class="eAPBoardTitleBorder"></div>
				<div class="eAPBoardContents">
					<div class="eAPBoardCardTextBox">
						<div class="Card_ico"></div>
						<div class="Card_Sum" >
							<strong name="accPortal_UseAmt"></strong>
							<spring:message code='Cache.ACC_krw'/>	<!-- 원 -->
						</div>
					</div>
					<div class="eAPBoardCardBox">
						<div class="eAPBoardCard color01">
							<div class="Card_name" name="accPortal_CorpCardCompany"></div>
							<div class="Card_ICchip"></div>
							<div class="Card_number" name="accPortal_CorpCardNo"></div>
							<div class="Card_username" name="accPortal_CorpCardOwner"></div>
						</div>
					</div>
				</div>
			</div>
			<div class="eAPBoardL">
				<h3 class="eAPBoardTitle">
					<spring:message code='Cache.ACC_043'/>
					<span class="pagingType01">
						<a href="#" class="pre" onclick="AccountPortal.accPortal_corpCardInfoPre()"></a>
						<a href="#" class="next" onclick="AccountPortal.accPortal_corpCardInfoNext()"></a>
					</span>
					<span class="Unit">
						<spring:message code='Cache.ACC_lbl_unitWon'/>	<!-- 단위:원 -->
					</span>
				</h3>
				<div class="eAPBoardTitleBorder"></div>
				<div class="eAPBoardContents">
					<ul class="eAPBoardGraphList">
						<li>
							<div class="eAPBoardGraphBox">
								<div class="eAPBoardGraphTitle">
									<span class="eAPBoardBullet01"></span>
									<spring:message code='Cache.ACC_lbl_remainAmt'/>	<!-- 잔여금액 -->
								</div>
								<div class="eAPBoardGraph01">
									<div style="width:0%;" name="accPortal_RemainPer"></div>
								</div>
								<div class="eAPBoardGrapSum" name="accPortal_RemainAmt"></div>
							</div>
						</li>
						<li>
							<div class="eAPBoardGraphBox">
								<div class="eAPBoardGraphTitle">
									<span class="eAPBoardBullet02"></span>
									<spring:message code='Cache.ACC_lbl_UsedAmt'/>	<!-- 사용금액 -->
								</div>
								<div class="eAPBoardGraph02">
									<div style="width:0%;" name="accPortal_UsePer"></div>
								</div>
								<div class="eAPBoardGrapSum"  name="accPortal_UseAmt"></div>
							</div>
						</li>
						<li>
							<div class="eAPBoardGraphBox">
								<div class="eAPBoardGraphTitle">
									<span class="eAPBoardBullet03"></span>
									<spring:message code='Cache.ACC_lbl_limitAmt'/>	<!-- 한도금액 -->
								</div>
								<div class="eAPBoardGraph03">
									<div style="width:100%;"  ></div>
								</div>
								<div class="eAPBoardGrapSum"  name="accPortal_LimitAmount"></div>
							</div>
						</li>
					</ul>
				</div>
			</div>
		</div>
	</div>
	<!-- 이어카운팅 포탈 끝 -->
	
</body>	
<script>


if (!window.AccountPortal) {
	window.AccountPortal = {};
}


(function(window) {
	var AccountPortal = {		
			pageOpenerIDStr : "openerID=AccountPortal&",
			nowCardIdx : 0,
			nowCardID : 0,
			CCInfoList : [],
			
			accPortalForm : {
				corpCardUseInfoForm : "<li><a href='#' onclick=\"AccountPortal.accPortal_corpCardInfoClick('@@{ReceiptID}')\">"
					+"<span class='eAPList_title'>@@{StoreName}</span>"
					+"<span class='eAPList_date'>@@{UseDate}</span>"
					+"</a></li>",

				aprvListForm : "<li><a href='#' onclick=\"AccountPortal.accPortal_viewEvidPopup('@@{AprvType}', '@@{KeyNo}', '@@{ProcessID}')\">"
					+"<span class='eAPList_title'>@@{ApplicationTitle}</span>"
					+"<span class='eAPList_date'>@@{ApplicationDate}</span>"
					+"</a></li>",

				taxInvoiceInfoForm : "<li><a href='#' onclick=\"AccountPortal.accPortal_TaxInfoClick('@@{TaxInvoiceID}')\">"
					+"<span class='eAPList_title'>@@{InvoicerCorpName}</span>"
					+"<span class='eAPList_date'>@@{WriteDate}</span>"
					+"</a></li>",
					
				corpCardInfoBtnForm : '<span class="pagingType01">'
					+'<a href="#" class="pre" onclick="AccountPortal.accPortal_corpCardInfoPre()"></a>'
					+'<a href="#" class="next" onclick="AccountPortal.accPortal_corpCardInfoNext()"></a>'
					+'</span>'
			},
			
			
			
			pageInit : function(inputParam) {
				var me = this;
				me.accPortalDateInit();
				me.accPortal_searchMainData();
			},
			pageView : function(inputParam) {
				var me = this;

				me.accPortal_searchMainData();
				
			},

			//날짜 초기화
			accPortalDateInit : function() {
				var me = this;
				var nowDate = new Date();
				var nowMonCorpCard = "<spring:message code='Cache.ACC_042' />";	//법인카드 @@{Month}월 사용 금액
				nowMonCorpCard = nowMonCorpCard.replace("@@{Month}", (nowDate.getMonth()+1));
				
				$("[name=accPortal_CorpCardMonUseArea").prepend(nowMonCorpCard);
				
			},

			//화면정보 초기화
			accPortalDataInit : function(inputParam) {
				var me = this;
				$("[name=accPortal_CorpCardArea").html("");
				$("[name=accPortal_ExpAppAprvArea").html("");
				$("[name=accPortal_TaxInvoiceArea").html("");
			},
			
			//정보 조회
			accPortal_searchMainData : function() {
				var me = this;
				me.accPortalDataInit();
				$.ajax({
					url:"/account/accountPortal/searchPortalMainData.do",
					cache: false,
					data:{
					},
					success:function (r) {
						if(r.result == "ok"){
							var data = r.data;

							var CCList = data.CorpCardList
							var EAList = data.ExpAppList
							var TIList = data.TaxInvoiveList
							var DLInfo = data.DeadlineInfo
							var CCInfoList = data.CorpCardInfoList

							var CCCnt = data.CorpCardListCnt
							var EACnt = data.ExpAppListCnt
							var TICnt = data.TaxInvoiveListCnt
							
							for(var i = 0; i<CCList.length; i++){
								var item = CCList[i];
								var formStr = me.accPortalForm.corpCardUseInfoForm
								var valMap = {
										ReceiptID : item.ReceiptID
										, StoreName : item.StoreName
										, UseDate : item.UseDateStr
								};
								var formStr = accComm.accHtmlFormSetVal(formStr, valMap);
								$("[name=accPortal_CorpCardArea").append(formStr);
							}

							for(var i = 0; i<EAList.length; i++){
								var item = EAList[i];
								var formStr = me.accPortalForm.aprvListForm
								var valMap = {
										AprvType : item.ApplicationType
										, KeyNo : item.ExpenceApplicationID
										, ApplicationTitle : item.ApplicationTitle
										, ApplicationDate : item.ApplicationDateStr
										, ProcessID : item.ProcessID
								};
								var formStr = accComm.accHtmlFormSetVal(formStr, valMap);
								$("[name=accPortal_ExpAppAprvArea").append(formStr);
							}


							for(var i = 0; i<TIList.length; i++){
								var item = TIList[i];
								var formStr = me.accPortalForm.taxInvoiceInfoForm
								var valMap = {
										TaxInvoiceID : item.TaxInvoiceID
										, InvoicerCorpName : item.InvoicerCorpName
										, WriteDate : item.WriteDateStr
								};
								var formStr = accComm.accHtmlFormSetVal(formStr, valMap);
								$("[name=accPortal_TaxInvoiceArea").append(formStr);
							}

							if(ckNaN(CCCnt) > 99){
								$("[name=accPortal_CorpCardCnt").html("99+");
							}else{
								$("[name=accPortal_CorpCardCnt").html(CCCnt);
							}
							if(ckNaN(EACnt) > 99){
								$("[name=accPortal_ExpAppAprvCnt").html("99+");
							}else{
								$("[name=accPortal_ExpAppAprvCnt").html(EACnt);
							}
							if(ckNaN(TICnt) > 99){
								$("[name=accPortal_TaxInvoiceCnt").html("99+");
							}else{
								$("[name=accPortal_TaxInvoiceCnt").html(TICnt);
							}

							var DCnt = data.TaxInvoiveListCnt
							
							if(DLInfo != undefined && DLInfo != null) {
								var strMon = "<spring:message code='Cache.ACC_lbl_month' />";	//월
								var strDay = "<spring:message code='Cache.ACC_lbl_day' />";		//일
								var stMon = "<strong>" + nullToBlank(DLInfo.DeadlineFinishDateMon) + strMon + "</strong>"
								
								var finDt = 
									'"<strong>'
									+nullToBlank(DLInfo.DeadlineFinishDateMon) + strMon 
									+ nullToBlank(DLInfo.DeadlineFinishDateDay) + strDay
									+'</strong>"';
								
									
								var deadLineStr = "<spring:message code='Cache.ACC_041' />";		//@@{Month}경비 마감일@@{Deadline}까지
								//deadLineStr = deadLineStr.replace("@@{Month}", stMon);
								deadLineStr = deadLineStr.replace("@@{Month}", "");
								deadLineStr = deadLineStr.replace("@@{Deadlind}", finDt);
								$("[name=accPortal_DeadlineArea").html(deadLineStr);
							}
							
							
							//$("[name=accPortal_CorpCardMonUseArea").append(me.accPortalForm.corpCardInfoBtnForm);
							
							//$("[name=accPortal_CorpCardMonUseArea")[0].innerText = nowMonCorpCard;

							me.CCInfoList = CCInfoList
							
							if(CCInfoList != null){
								if(CCInfoList.length != 0){
									if(!CCInfoList.length>me.nowCardIdx){
										me.nowCardIdx = 0;	
									}
									var cdInfoItem = CCInfoList[me.nowCardIdx]
									if(cdInfoItem != null){
										me.nowCardID = cdInfoItem.ReceiptID
										me.accPortal_setCardInfo(cdInfoItem);
									}
								}
							}
							
						}
						else{
							Common.Error(r.message);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			},
			

			//카드정보 화면에 세팅
			accPortal_setCardInfo : function(cardInfo) {
				var me = this;
				var nowDate = new Date();
				var firstDate = new Date(nowDate.getFullYear(), nowDate.getMonth(), 1);
				var lastDate = new Date(nowDate.getFullYear(), nowDate.getMonth()+1, 0);

				var dateStr = 
						me.accPortal_getDateFormat(firstDate)
						+" ~ "
						+  me.accPortal_getDateFormat(lastDate)
				
				
				$("[name=accPortal_CorpCardLimite").html(toAmtFormat(nullToBlank(cardInfo.LimitAmount)));
				$("[name=accPortal_CorpCardDateArea").html(dateStr);
				$("[name=accPortal_CorpCardCompany").html(nullToStr(cardInfo.CardCompanyName, "&nbsp;"));
				$("[name=accPortal_CorpCardNo").html(nullToStr(cardInfo.CardNoView, "****-****-****-****"));
				$("[name=accPortal_CorpCardOwner").html(nullToStr(cardInfo.OwnerUser, "&nbsp;"));

				$("[name=accPortal_RemainPer").css("width", ckNaN(cardInfo.RemainPer)+"%" )
				$("[name=accPortal_UsePer").css("width", ckNaN(cardInfo.UsePer)+"%" )

				$("[name=accPortal_RemainAmt").html(toAmtFormat(nullToBlank(cardInfo.RemainAmt)));
				$("[name=accPortal_UseAmt").html(toAmtFormat(nullToBlank(cardInfo.UseAmt)));
				$("[name=accPortal_LimitAmount").html(toAmtFormat(nullToBlank(cardInfo.LimitAmount)));
				
				var cardListInfoStr = "("+(me.nowCardIdx+1) + "/" +me.CCInfoList.length+")"
				$("[name=accPortal_CorpCardListInfo").html(cardListInfoStr);

				
			},
			

			//화면에 표시하기 위한 날짜 포멧 생성
			accPortal_getDateFormat : function(date) {
				var me = this;
				if(date==null){
					return "";
				}
				if(date.getMonth == null
						||date.getDate == null){
					return "";
				}
				var strMon = "<spring:message code='Cache.ACC_lbl_month' />";	//월
				var strDay = "<spring:message code='Cache.ACC_lbl_day' />";	//일
				var ret = (date.getMonth()+1)+strMon + " "
							+ date.getDate()+strDay;
				
				return ret;
			},
			//사용내역 정보 표시
			accPortal_corpCardInfoClick : function(ReceiptID) {
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
			},
			accPortal_TaxInfoClick : function(TaxInvoiceID) {
				var me = this;
				accComm.accTaxBillAppClick(TaxInvoiceID, me.pageOpenerIDStr);
			},
			accPortal_viewEvidPopup : function(AprvType, KeyNo, ProcessID) {
				var me = this;
				if(AprvType == "CO"
						||AprvType == "SC"){
					Common.open("","expenceApplicationViewPopup"
							,"<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>"
							,"/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+KeyNo+"&processID="+ProcessID
							,"1000px","600px","iframe",true,null,null,true);
				}
			},
			
			//MORE클릭시 메뉴 호출
			accPortal_moreListView : function(type) {
				var me = this;
				if(type=="C"){
					eAccountContentHtmlChangeAjax('account_CardReceiptUseraccountuserAccount'
									, "<spring:message code='Cache.ACC_lbl_corpCardUseList' />"
									, '/account/layout/account_CardReceiptUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
									, {callType:"Portal"});
				}else if(type=="A"){
					eAccountContentHtmlChangeAjax('account_ExpenceApplicationManageUseraccountuserAccount'
									, "<spring:message code='Cache.ACC_lbl_expenceApplicationView' />"
									, '/account/layout/account_ExpenceApplicationManageUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
									, {callType:"Portal"});
				}else if(type=="T"){
					eAccountContentHtmlChangeAjax('account_TaxInvoiceUseraccountuserAccount'
							, "<spring:message code='Cache.ACC_lbl_taxInvoiceView' />"
							, '/account/layout/account_TaxInvoiceUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
							, {callType:"Portal"});
				}
			},
			
			//카드 사용정보 앞/뒤 이동
			accPortal_corpCardInfoPre : function(){
				var me = this;
				CCInfoList = me.CCInfoList;
				if(CCInfoList != null){
					if(CCInfoList.length != 0){
						if(me.nowCardIdx == 0){
							me.nowCardIdx = CCInfoList.length;
						}
						me.nowCardIdx--;
						var cdInfoItem = CCInfoList[me.nowCardIdx]
						if(cdInfoItem != null){
							me.nowCardID = cdInfoItem.ReceiptID
							me.accPortal_setCardInfo(cdInfoItem);
						}else{
							me.nowCardIdx = 0;	
						}
					}
				}
			},
			accPortal_corpCardInfoNext : function(){
				var me = this;
				CCInfoList = me.CCInfoList;
				if(CCInfoList != null){
					if(CCInfoList.length != 0){
						if(CCInfoList.length <= (me.nowCardIdx+1)){
							me.nowCardIdx = -1;	
						}
						me.nowCardIdx++;
						var cdInfoItem = CCInfoList[me.nowCardIdx]
						if(cdInfoItem != null){
							me.nowCardID = cdInfoItem.ReceiptID
							me.accPortal_setCardInfo(cdInfoItem);
						}else{
							me.nowCardIdx = 0;	
						}
					}
				}
			}
	}
	
	window.AccountPortal = AccountPortal;
})(window);

</script>
	
	
	