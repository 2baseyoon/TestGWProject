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

<style>
	.pad10 {padding:10px;}
</style>
<body>
<body>	
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:620px; height: 605px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="mobile_receipt_box" name="dateSetDrea">
					</div>
				</div>
				<div class="bottom">
					<a onclick="ReceiptSearchPopup.sendMobileReceipt();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_save'/></a>
					<a onclick="ReceiptSearchPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
	
	if (!window.ReceiptSearchPopup) {
		window.ReceiptSearchPopup = {};
	}
	
	(function(window) {
		var ReceiptSearchPopup = {

				receiptFormStr : 
					'<li id="MR_@@{ReceiptId}" name="mobileLI" receiptid="@@{ReceiptId}">'
						+'<div class="mobile_receipt_check">'
							+'<input type="checkbox" id="MRCK_@@{ReceiptId}" class="mr_check" receiptid="@@{ReceiptId}" name="receiptCkbox">'
							+'<label for="MRCK_@@{ReceiptId}" id="MRCKLB_@@{ReceiptId}">'
								+'<img src="@@{FullPath}" alt="">'
								+'<p class="mobile_receipt_title">@@{UsageText}</p>'
								+'<p class="mobile_receipt_cdate">@@{PhotoDateHMS}</p>'
							+'</label>'
						+'</div>'
					+'</li>',
				dateListMap : {},
				receiptListMap : {},
				params : {},
				searchParam : {},
				pageInit : function(){
					var me = this;
					
					

					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me.params[paramKey] = paramValue
					}
					
					if(me.params.openerID != null
							||me.params.paramsetFunc != null){
						if(parent[me.params.openerID] != null){
							var pa = parent[me.params.openerID];
							if(typeof(pa[me.params.paramsetFunc])=="function"){
								me.searchParam = pa[me.params.paramsetFunc]("Receipt");
							}
						}
					}
					
					if(me.params != null && me.searchParam != null){
						if(isEmptyStr(me.params.ExpAppID)){
							me.params.ExpAppID = me.searchParam.ExpAppId
						}
						if(isEmptyStr(me.params.idStr)){
							me.params.idStr = me.searchParam.idStr
						}
					}
					
					me.mobileReceipt_searchList();
				},
				

				mobileReceipt_searchList : function() {
					var me = this;
					
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getMobileReceipt.do",
						data:{
							//receiptID : inputList
							ExpenceApplicationID : nullToBlank(me.params.ExpAppID),
							ReceiptIDList : nullToBlank(me.params.idStr)
						},
						success:function (data) {
							if(data.result == "ok"){
								var list = data.list;
								
								if(list.length > 0) {
									for(var i=0; i<list.length; i++){
										var item = list[i]
										var getDate = item.PhotoDate
										var getDateYMD = item.PhotoDateYMD
									
										me.receiptListMap[item.ReceiptID] = item
										var recHtmlStr = me.receiptFormStr
											recHtmlStr = recHtmlStr.replaceAll("@@{ReceiptId}", item.ReceiptID)
											recHtmlStr = recHtmlStr.replaceAll("@@{FullPath}", item.FullPath)
											recHtmlStr = recHtmlStr.replaceAll("@@{UsageText}", item.UsageText)
											recHtmlStr = recHtmlStr.replaceAll("@@{PhotoDateHMS}", item.PhotoDateHMS)
										if(me.dateListMap[getDate] == null){
											me.dateListMap[getDate] = true;
											
											var htmlStr = "<div name='dateDiv' setdate="+getDate+">"
												+ "<p class='mobile_receipt_date'>"+getDateYMD+"</p>"
												+ "<div class='mobile_receipt_wrap' name='receiptDivArea' setdate="+getDate+">"
												+ "<ul class='mobile_receipt_list' name='receiptArea'  setdate="+getDate+">"
												+ recHtmlStr
												+ "</ul>"
												+ "</div>"
												+ "</p>"
												+ "</div>"
											$("[name=dateSetDrea]").append(htmlStr);
										}
										else{
											$("[name=receiptArea][setdate="+getDate+"]").append(recHtmlStr);
										}
									}
								} else {
									$("[name=dateSetDrea]").append("<div style='text-align: center; padding-top: 50px;'>" + "<spring:message code='Cache.msg_EmptyData' />" + "</div>");
								}
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
					
				},
				
				sendMobileReceipt: function() {
					var me = this;
					var ckList = $("[name=receiptCkbox]:checked");
					
					if(ckList.length==0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
						return;
					}
					
					var list = []
					for(var i=0; i<ckList.length; i++){
						var ckField = ckList[i];
						var getid = ckField.getAttribute("receiptid");
						list.push(me.receiptListMap[getid] )
						
					}
					me.closeLayer();
					
					try{
						accountCtrl.popupCallBackStrObj([list]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
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
		window.ReceiptSearchPopup = ReceiptSearchPopup;
	})(window);
	
	ReceiptSearchPopup.pageInit();
</script>
