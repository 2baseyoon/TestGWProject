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

<ul class="card_nea_right_list" id="combiCostAppCB_TableArea" name="combiCostAppCB_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}


(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationCash<%=requestType%> = {		
				
		cashBillPageExpenceAppList : [],

		combiCostAppCB_CashBillPageInit : function() {
			var me = this;
			accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
			me.cashBillPageExpenceAppList = [];
		},
		combiCostAppCB_CashBillDataInit : function() {
			var me = this;
			accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
			me.cashBillPageExpenceAppList = [];
		},


		combiCostAppCB_cashPopupLoad : function() {
			var me = this;
			me.combiCostAppCB_callCashPopup();
			
		},

		combiCostAppCB_callCashPopup : function() {
			var me = this;
			//me.combiCostAppCB_CashBillDataInit();
			var popupID		=	"cashBillSearchPopup";
			var popupTit	=	"<spring:message code='Cache.ACC_btn_cashBillLoad'/>";		//현금영수증 불러오기
			var popupName	=	"CashBillSearchPopup";
			var callBack	=	"combiCostAppCB_getCashInfo";
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="		+	popupID		+	"&"
							+	"popupName="	+	popupName	+	"&"
							+	"paramsetFunc=combiCostApp_CallAddLoadPopupParam&"
							+	me.pageOpenerIDStr
							+	"includeAccount=N&"
							+	"callBackFunc="	+	callBack;
			Common.open(	"",popupID,popupTit,url,"1300px","700px","iframe",true,null,null,true);
			
		},
		
		//세금코드 필요 추가정보 조회
		combiCostAppCB_getCashInfo : function(inputList, val) {
			var me = this;
			$.ajax({
				type:"POST",
					url:"/account/expenceApplication/getCashBillInfo.do",
				data:{
					cashBillIDs : inputList
				},
				success:function (data) {
					if(data.result == "ok"){
						var getCashBillList = data.list;
						
	
						var duplCk = false;
						var duplList = "";
						for(var i = 0; i<getCashBillList.length; i++){
							var item = getCashBillList[i];
							if(item.IsDuplicate=="Y"){
								duplCk = true;
								if(duplList==""){
									duplList = item.NTSConfirmNum;
								}else{
									duplList = duplList+", "+item.NTSConfirmNum;
								}
							}
						}
						if(duplCk){
							
							Common.Error("<spring:message code='Cache.ACC_016' />");		//@@{appNoList}는 이미 추가된 항목입니다.
							msg = msg.replace("@@{appNoList}", appNoList);
							Common.Error(msg);
							return;
						}

						me.combiCostAppCB_inputListDataAdd(getCashBillList, true);
					}
					else{
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error:function (error){
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			});
		},

		combiCostAppCB_inputListDataAdd : function(itemList, isNew) {
			var me = this;
			me.combiCostApp_setModified(true);
			var arrCk = Array.isArray(itemList);
			if(arrCk){
				var addedCk1 = false;
				var addedCk2 = false;
				var confirmNoList = "";
				if(isNew){
					for(var i = 0; i<itemList.length; i++){
	
						var newItem = itemList[i]
						var oldItem = null;
						for(var y = 0; y<me.cashBillPageExpenceAppList.length; y++){
							oldItem = me.cashBillPageExpenceAppList[y];
							if(oldItem.CashUID == newItem.CashUID){
								addedCk1 = true;
								if(confirmNoList==""){
									confirmNoList = newItem.CashNTSConfirmNum
								}else{
									confirmNoList = confirmNoList+","+newItem.CashNTSConfirmNum
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
						msg = msg.replace("@@{appNoList}", confirmNoList);
						Common.Error(msg);
						return;
					}
				}


				for(var i = 0; i<itemList.length; i++){
					var item = itemList[i];
					if(isNew){
	
						item.IsNew = true;
						item.IsNewStr = "Y";
					}
					var maxKey = me.combiCostApp_getPageListMaxKey('CashBill');
					item.KeyNo = maxKey+1;
					item.ProofCode = "CashBill";
					var today = new Date();
					if(item.ProofDate == null){
						item.ProofDate = today.format("yyyyMMdd");
						item.ProofDateStr = today.format("yyyy.MM.dd");
					}
					if(item.PostingDate == null){
						item.PostingDate = today.format("yyyyMMdd");
						item.PostingDateStr = today.format("yyyy.MM.dd");
					}
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
					me.cashBillPageExpenceAppList.push(item);
				}

				me.combiCostAppCB_setListHTML(false, itemList);
			}
		},

		//법인카드 사용내역 HTML 만들기
		combiCostAppCB_setListHTML : function(isAll, inputList) {
			var me = this;
			
			if(isAll){
				accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
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
						CashUID : nullToBlank(item.CashUID),
						CashNTSConfirmNum : nullToBlank(item.CashNTSConfirmNum),
						ProofCode : nullToBlank(item.ProofCode),
						TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
						ProofDate : nullToBlank(item.ProofDateStr),
						StoreName : nullToBlank(item.StoreName).trim(),
						TaxType : nullToBlank(item.TaxType),
						TaxCode : nullToBlank(item.TaxCode),
						PayMethod : nullToBlank(item.PayMethod),
						VendorName : nullToBlank(item.VendorName),
						VendorNo : nullToBlank(item.VendorNo),
						FranchiseCorpName : nullToBlank(item.FranchiseCorpName),
						Tax : toAmtFormat(nullToBlank(item.Tax)),
						SupplyCost : toAmtFormat(nullToBlank(item.SupplyCost))
				}
				var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
				accountCtrl.getInfoName("combiCostAppCB_TableArea").append(htmlStr);
				
				
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
					me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'CashBill', false);
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
					me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'CashBill', false);
				}
			}
			me.combiCostApp_makeDateField("CashBill", list);
		},

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationCash<%=requestType%>);
})(window);

</script>