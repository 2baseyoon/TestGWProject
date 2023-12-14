<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="org.springframework.beans.factory.annotation.Autowired"%>
<%@ page import="egovframework.coviaccount.common.service.CommonSvc"%>
<%@ page import="egovframework.coviaccount.user.service.impl.ExpenceApplicationSvcImpl"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="egovframework.baseframework.data.CoviMapperOne"%>
<%@ page import="javax.annotation.Resource"%>

<%
	String requestType = request.getParameter("requesttype");
%>

<ul class="card_nea_right_list" id="combiCostAppCC_TableArea" name="combiCostAppCC_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationCard<%=requestType%> = {

			cardPageExpenceAppList : [],
			
			
			combiCostAppCC_CorpCardPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppCC_TableArea").html("");
				me.cardPageExpenceAppList = [];
			},
			
			combiCostAppCC_CorpCardDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppCC_TableArea").html("");
				me.cardPageExpenceAppList = [];
			},

			combiCostAppCC_CardInfoLoadPopup : function() {
				var me = this;
				me.combiCostAppCC_callCardInfoPopup();
			},

			combiCostAppCC_callCardInfoPopup : function() {
				var me = this;
				
				var popupID		=	"cardReceiptSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_btn_corpCardLoad'/>";	//법인카드불러오기
				var popupName	=	"CardReceiptSearchPopup";
				var callBack	=	"combiCostAppCC_getCardRecInfo";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"paramsetFunc=combiCostApp_CallAddLoadPopupParam&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1300px","700px","iframe",true,null,null,true);
				
			},
			combiCostAppCC_getCardRecInfo : function(inputList) {
				var me = this;
				var property = accountCtrl.getInfoStr("[name=ExpAppPropertyField][tag=CardReceipt]").val();
				//Property값이 뭔가 있을경우 인터페이스, 공백일경우 자체 DB
				//자체DB일경우 추가적인 값 조회가 필요
				if(isEmptyStr(property)){

					var idList = ""
					for(var i = 0; i<inputList.length; i++){
						var item = inputList[i]
						if(idList==""){
							idList = item.ReceiptID
						}else{
							idList = idList+","+item.ReceiptID
						}
					}
					
					$.ajax({
						type:"POST",
							url:"/account/expenceApplication/getCardReceipt.do",
						data:{
							receiptID : idList
						},
						success:function (data) {
							
							if(data.result == "ok"){
								var getCardRecList = data.list;
								
								var duplCk = false;
								var duplList = "";
								for(var i = 0; i<getCardRecList.length; i++){
									var item = getCardRecList[i];
									/* var idx = me.cardPageExpenceAppList.findIndex(
												function(item){
													return item.ReceiptID==item.ReceiptID;
												}
											) */
									var idx = accFindIdx(me.cardPageExpenceAppList, "ReceiptID", item.ReceiptID );
									if(idx>=0){
										duplCk = true;
										duplList = duplList+", "+item.CardApproveNo;
									}
								}
								
								if(duplCk){
								var msg = "<spring:message code='Cache.ACC_017' />";		//@@{appNoList}는 이미 비용신청 된 항목입니다.
									msg = msg.replace("@@{appNoList}", duplList);
									//Common.Error(msg);
									//return;
								}
								
								me.combiCostAppCC_inputListDataAdd(getCardRecList, true);
							}
							else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				}else{
					//alert("INTERFACE TEST MSG");
					me.combiCostAppCC_inputListDataAdd(inputList, true, property);
				}
			},

			combiCostAppCC_inputListDataAdd : function(itemList, isNew, property) {
				var me = this;
				me.combiCostApp_setModified(true);
				var arrCk = Array.isArray(itemList);
				if(arrCk){
					var addedCk1 = false;
					var appNoList = "";
					if(isNew){
						
						for(var i = 0; i<itemList.length; i++){
		
							var newItem = itemList[i]
							var oldItem = null;
							for(var y = 0; y<me.cardPageExpenceAppList.length; y++){
								oldItem = me.cardPageExpenceAppList[y];
								if(oldItem.CardUID == newItem.CardUID){
									addedCk1 = true;
									if(appNoList==""){
										appNoList = newItem.CardApproveNo
									}else{
										appNoList = appNoList+","+newItem.CardApproveNo
									}
									break;
								}
							}
							
							if(addedCk1){
								break;
							}
						}
						
						if(addedCk1){
							var msg = "<spring:message code='Cache.ACC_016' />";		//@@{appNoList}는 이미 추가된 항목입니다.
							msg = msg.replace("@@{appNoList}", appNoList);
							Common.Error(msg);
							return;
						}
					}
					
					for(var i = 0; i<itemList.length; i++){
						var item = itemList[i];
						if(isNew){
							var today = new Date();
							if(!isEmptyStr(property)){
								var copyObj = objCopy(item);
								item.oriIFData = copyObj;
								item.ProofCode = "CorpCard";
								item.CardUID = item.ReceiptID;
								item.CardApproveNo = item.ApproveNo;
								item.TotalAmount = item.AmountWon;
								item.ProofDate = today.format("yyyyMMdd");
								item.ProofDateStr = today.format("yyyy.MM.dd");
								item.ProofTime = todat.format("HHmmss");
								item.ProofTimeStr = todat.format("HH:mm:ss");
								item.CardApproveNo = item.ApproveNo;
								item.StoreAddress = item.StoreAddress1 + item.StoreAddress2;
								item.AccountInfo = item.AccountInfo;
								item.AccountHolder = item.AccountHolder;
								item.AccountBank = item.AccountBank;
							}
							if(item.PostingDate == null){
								//item.PostingDate = today.format("yyyyMMdd");
								//item.PostingDateStr = today.format("yyyy.MM.dd");
								
								//phm
								item.PostingDate = item.ProofDate;
								item.PostingDateStr = item.ProofDateStr;
							}
		
							item.IsNew = true;
							item.IsNewStr = "Y";
						}
						var maxKey = me.combiCostApp_getPageListMaxKey('CorpCard');
						item.KeyNo = maxKey+1;
						item.ProofCode="CorpCard";

						var divCk = false;
						if(item.divList == null){
							divCk = true;
						}
						else if(item.divList.length==0){
							divCk = true;
						}
						if(divCk){
							item.divList = [];
							var divItem = {
									ExpenceApplicationListID : item.ExpenceApplicationListID
									, KeyNo : item.KeyNo
									, ProofCode : item.ProofCode
									
									, ExpenceApplicationDivID : ""
									, AccountCode :  ""
									, AccountName : ""
									, StandardBriefID :  ""
									, StandardBriefName : ""
									, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
									, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
									, IOCode : ""
									, IOName : ""
									, Amount : item.TotalAmount
									, UsageComment : ""
									, IsNew : true
									, Rownum : 0
							}
							item.divList.push(divItem);
						}
						me.cardPageExpenceAppList.push(item);
					}

					me.combiCostAppCC_setListHTML(false, itemList);
					
					/* if(accountCtrl.getInfo("corpCardArea").css("display") == "none"){
						accountCtrl.getInfo("corpCardArea").show();
					} */
				}
			},

			//법인카드 사용내역 HTML 만들기
			combiCostAppCC_setListHTML : function(isAll, inputList) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppCC_TableArea").html("");
				}
				var list = [];
				
				if(inputList == null){
					list = me.cardPageExpenceAppList;
				}else{
					list = inputList;
				}
				
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDateStr),
							ProofTime : nullToBlank(item.ProofTimeStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							CardUID : nullToBlank(item.CardUID),
							CardApproveNo : nullToBlank(item.CardApproveNo),
							ReceiptID : nullToBlank(item.ReceiptID),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank)
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppCC_TableArea").append(htmlStr);
					
					$("#combiCostApp" + item.ProofCode + "_repAmount_" + item.KeyNo).val(toAmtFormat(item.RepAmount));
					$("#combiCostApp" + item.ProofCode + "_taxAmount_" + item.KeyNo).val(toAmtFormat(item.TaxAmount));
					$("#combiCostApp" + item.ProofCode + "_serviceAmount_" + item.KeyNo).val(toAmtFormat(item.ServiceAmount));
					
					me.combiCostApp_makeInputDivHtmlAdd(item);
					
					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'CorpCard', false);
					}

					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'CorpCard', false);
					}
				}
				me.combiCostApp_makeDateField("CorpCard", list);
			},
	}
	
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationCard<%=requestType%>);
})(window);

</script>