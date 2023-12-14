<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="org.springframework.beans.factory.annotation.Autowired"%>
<%@ page import="egovframework.coviaccount.common.service.CommonSvc"%>
<%@ page import="egovframework.coviaccount.user.service.impl.ExpenceApplicationSvcImpl"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="javax.annotation.Resource"%>
<%@ page import="egovframework.baseframework.data.CoviMapperOne"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>

<%
	String requestType = request.getParameter("requesttype");
%>

<ul class="card_nea_right_list" id="combiCostAppTB_TableArea" name="combiCostAppTB_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationTax<%=requestType%> = {		
				
			taxBillPageExpenceAppList : [],
			taxBillManager : "N",
			businessNumber : "",
			businessNumberCnt : 0,
			combiCostAppTB_TaxBillPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppTB_TableArea").html("");
				me.taxBillPageExpenceAppList = [];
				me.combiCostAppTB_callManager();
			},
			
			combiCostAppTB_TaxBillDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppTB_TableArea").html("");
				me.taxBillPageExpenceAppList = [];
			},

			combiCostAppTB_callManager : function() {
				var me = this;
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getManagerList.do",
					data:{},
					success:function (data) {
						if(data.result == "ok"){
							me.taxBillManager = data.check;
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

			combiCostAppTB_TaxLoadXmlUpLoadPopup : function() {
				var me= this;

				if(me.taxBillManager != "Y"){
					Common.Inform("<spring:message code='Cache.ACC_026' />");	//담당자만 사용할 수 있습니다.
					return;
				}
				
				if(me.taxBillPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_msg_modDataConfirm' />", "Confirmation Dialog", function(result){	//작성중인 항목이 있습니다. 불러오기를 하시면 수정중인 내용이 사라집니다. 계속하시겠습니까? 
						if(result){
							
							me.combiCostAppTB_TaxBillDataInit();
							var popupID		= "taxInvoiceXmlUploadPopup";
							var popupTit	= "TaxInvoice Xml UpLoad";
							var popupYN		= "N";
							var callBack	= "combiCostAppTBTaxLoadXmlUpLoadPopup_CallBack";
							var popupUrl	= "/account/expenceApplication/getTaxInvoiceXmlUploadPopup.do?"
											+ "popupID="		+ popupID	+ "&"
											+  me.pageOpenerIDStr
											+ "popupYN="		+ popupYN	+ "&"
											+ "callBackFunc="	+ callBack;
							Common.open("", popupID, popupTit, popupUrl, "500px", "250px", "iframe", true, null, null, true);
						}
					});
				}
				else{
					var popupID		= "taxInvoiceXmlUploadPopup";
					var popupTit	= "TaxInvoice Xml UpLoad";
					var popupYN		= "N";
					var callBack	= "combiCostAppTBTaxLoadXmlUpLoadPopup_CallBack";
					var popupUrl	= "/account/expenceApplication/getTaxInvoiceXmlUploadPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+  me.pageOpenerIDStr
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "500px", "250px", "iframe", true, null, null, true);
				}
			},
			
			combiCostAppTBTaxLoadXmlUpLoadPopup_CallBack : function(data) {
				var me = this;
				var inputVal = data.info;
				
				inputVal.isXML = "Y";
				inputVal.NTSConfirmNum = inputVal.IssueID;
				inputVal.WriteDate = inputVal.IssueDTTaxInvoice;
				inputVal.FormatWriteDate = accComm.accFormatDate(inputVal.IssueDTTaxInvoice);
				inputVal.IssueDT = inputVal.IssueDTExchanged;
				inputVal.itemList = data.list;
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getVdCheck.do",
					data:{
						VendorNo : inputVal.InvoicerCorpNum
					},
					success:function (data) {
						if(data.result == "ok"){
							var vdInfo = data.vdInfo;
							if(vdInfo != null){
								inputVal.VendorNo = vdInfo.VendorNo;
								inputVal.VendorName = vdInfo.VendorName;
								inputVal.CEOName = vdInfo.CEOName;
								inputVal.Address = vdInfo.Address;
								inputVal.Industry = vdInfo.Industry;
								inputVal.Sector = vdInfo.Sector;
								inputVal.BankAccountInfo = vdInfo.BankAccountInfo;
								inputVal.BankAccountName = vdInfo.BankAccountName;
								inputVal.BankCode = vdInfo.BankCode;
							}
							me.combiCostAppTB_inputListDataAdd([inputVal], true);
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				
				
			},
			
			combiCostAppTB_TaxLoadPopup : function() {
				var me= this;
				if(me.taxBillPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_msg_modDataConfirm' />", "Confirmation Dialog", function(result){	//작성중인 항목이 있습니다. 불러오기를 하시면 수정중인 내용이 사라집니다. 계속하시겠습니까? 
						if(result){
							me.combiCostAppTB_callCardInfoPopup();
						}
					});
				}
				else{
					me.combiCostAppTB_callCardInfoPopup();
				}
			},

			combiCostAppTB_callCardInfoPopup : function() {
				var me = this;

				if(me.taxBillManager != "Y"){
					Common.Inform("<spring:message code='Cache.ACC_026' />");	//담당자만 사용할 수 있습니다.
					return;
				}

				me.combiCostAppTB_TaxBillDataInit();
//				taxBillInit();
				var popupID		=	"taxinvoiceSearchPopup";
				var openerID	=	"CostApplication";
				var popupTit	=	"<spring:message code='Cache.ACC_btn_taxBillLoad'/>";
				var popupName	=	"TaxinvoiceSearchPopup";
				var callBack	=	"combiCostAppTB_getTaxInfo";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"openerID="		+	openerID	+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"paramsetFunc=combiCostApp_CallAddLoadPopupParam&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1200px","630px","iframe",true,null,null,true);
				
			},
			combiCostAppTB_getTaxInfo : function(inputVal) {
				var me = this;
				var property = accountCtrl.getInfoStr("[name=ExpAppPropertyField][tag=TaxInvoice]").val();

				//Property값이 뭔가 있을경우 인터페이스, 공백일경우 자체 DB
				//자체DB일경우 추가적인 값 조회가 필요
				if(isEmptyStr(property)){
					$.ajax({
						type:"POST",
							url:"/account/expenceApplication/getTaxBillInfo.do",
						data:{
							taxBillID : inputVal.TaxInvoiceID
						},
						success:function (data) {
							if(data.result == "ok"){
								var getTaxBillList = data.list;
	
								var duplCk = false;
								var duplList = "";
								for(var i = 0; i<getTaxBillList.length; i++){
									var item = getTaxBillList[i];
									
									if(item.IsDuplicate=="Y"){
										duplCk = true;
										if(duplList==""){
											duplList = item.NTSConfirmNum;
										}else{
											duplList = duplList+", "+item.NTSConfirmNum;
										}
									}
									me.businessNumberCnt = item.BusinessNumberCnt;
								}
								
								if(duplCk){
									
									var msg = "<spring:message code='Cache.ACC_016' />";	//@@{appNoList}는 이미 추가된 항목입니다.
									msg = msg.replace("@@{appNoList}", duplList);	
									return;
								}
	
								me.combiCostAppTB_inputListDataAdd(getTaxBillList, true);
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				else{
					$.ajax({
						type:"POST",
							url:"/account/expenceApplication/getVdCheck.do",
						data:{
							VendorNo : inputVal.InvoicerCorpNum
						},
						success:function (data) {
							if(data.result == "ok"){
								var vdInfo = data.vdInfo;
								if(vdInfo != null){
									inputVal.VendorNo = vdInfo.VendorNo;
									inputVal.VendorName = vdInfo.VendorName;
									inputVal.CEOName = vdInfo.CEOName;
									inputVal.Address = vdInfo.Address;
									inputVal.Industry = vdInfo.Industry;
									inputVal.Sector = vdInfo.Sector;
									inputVal.BankAccountInfo = vdInfo.BankAccountInfo;
									inputVal.BankAccountName = vdInfo.BankAccountName;
									inputVal.BankCode = vdInfo.BankCode;
									inputVal.divComment = (typeof(vdInfo.ItemName) == "undefined" ? "" : vdInfo.ItemName);
								}
								me.combiCostAppTB_inputListDataAdd([inputVal], true, property);
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
			},

			combiCostAppTB_inputListDataAdd : function(itemList, isNew, property) {
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
							for(var y = 0; y<me.taxBillPageExpenceAppList.length; y++){
								oldItem = me.taxBillPageExpenceAppList[y];
								if(oldItem.TaxUID == newItem.TaxUID){
									addedCk1 = true;
									if(confirmNoList==""){
										confirmNoList = newItem.TaxNTSConfirmNum
									}else{
										confirmNoList = confirmNoList+","+newItem.TaxNTSConfirmNum
									}
									break;
								}
							}
							
							if(addedCk1){
								break;
							}
						}

						if(addedCk1){
							var msg = "<spring:message code='Cache.ACC_016' />";
							msg = msg.replace("@@{appNoList}", confirmNoList);
							Common.Error(msg);
							return;
						}
					}
					
					for(var i = 0; i<itemList.length; i++){
						var item = itemList[i];
						var divCk = false;
						if(isNew){
							if(!isEmptyStr(property)
									|| item.isXML=="Y"){
								var copyObj = objCopy(item);
								item.oriIFData = copyObj;

								item.ProofCode = "TaxBill";
								item.TaxNTSConfirmNum = item.NTSConfirmNum;
								item.SupplyCost = item.SupplyCostTotal;
								item.WriteDate = item.WriteDate;
								item.FormatWriteDate = item.FormatWriteDate;
								item.Tax = item.TaxTotal;
								item.FormatTotalAmount = toAmtFormat(item.TotalAmount);
								item.FormatTaxTotal = toAmtFormat(item.TaxTotal);
								item.FormatSupplyCostTotal = toAmtFormat(item.SupplyCostTotal);
								item.VendorName = item.VendorName;
								item.VendorNo = item.VendorNo;
								item.CEOName = item.CEOName;
								item.Addr = item.Address;
								item.Industry = item.Industry;
								item.Sector = item.Sector;
								item.AccountInfo = item.BankAccountInfo;
								item.AccountHolder = item.BankAccountName;
								item.AccountBank = item.BankCode;
								item.ItemName = item.ItemName;
							}
							item.IsNew = true;
							item.IsNewStr = "Y";
						}

						var maxKey = me.combiCostApp_getPageListMaxKey('TaxBill');
						item.KeyNo = maxKey+1;
						item.ProofCode = "TaxBill";
						
						var today = new Date();
						if(item.ProofDate == null){
							item.ProofDate = item.WriteDate;
							item.ProofDateStr = item.FormatWriteDate;
						}
						if(item.PostingDate == null){
							/* item.PostingDate = today.format("yyyyMMdd");
							item.PostingDateStr = today.format("yyyy.MM.dd"); */
							//phm
							item.PostingDate = item.ProofDate;
							item.PostingDateStr = item.ProofDateStr;
							
						}
						item.RepAmount = item.SupplyCost;
						item.TaxAmount = item.Tax;
						
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
									, Amount : item.RepAmount
									, UsageComment : item.ItemName
									, IsNew : true
									, Rownum : 0
							}
							item.divList.push(divItem);
						}
						if(item.maxDivRownum==null){
							item.maxDivRownum=0
						}

						me.businessNumberCnt = item.BusinessNumberCnt; //임시저장된 증빙 수정 시
						/* if(isNew){
							if(me.businessNumberCnt == 0){
								item.VendorNo = "";
								item.VendorName = "";
								item.CEOName = "";
								item.Address = "";
								item.Industry = "";
								item.Sector = "";
								item.BankAccountInfo = "";
								item.BankAccountName = "";
								item.BankCode = "";
							} else if ( me.businessNumberCnt > 1){
								me.businessNumber = item.VendorNo;
							}		
						} */
						me.taxBillPageExpenceAppList.push(item);
					}
					me.combiCostAppTB_setListHTML();
				}
			},

			//법인카드 사용내역 HTML 만들기
			combiCostAppTB_setListHTML : function(isAll) {
				var me = this;
				if(isAll){
					accountCtrl.getInfoName("combiCostAppTB_TableArea").html();
				}

				for(var i = 0; i<me.taxBillPageExpenceAppList.length; i++){
					var item = me.taxBillPageExpenceAppList[i];
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							TaxUID : nullToBlank(item.TaxUID),
							TaxNTSConfirmNum : nullToBlank(item.TaxNTSConfirmNum),
							
							ProofCode : nullToBlank(item.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDateStr),
							PostingDate : nullToBlank(item.PostingDateStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							VendorID : nullToBlank(item.VendorID),
							Tax : toAmtFormat(nullToBlank(item.Tax)),
							SupplyCost : toAmtFormat(nullToBlank(item.SupplyCost)),
							CEOName : nullToBlank(item.CEOName),
							Address : nullToBlank(item.Address),
							Sector : nullToBlank(item.Sector),
							Industry : nullToBlank(item.Industry),
							Remark : nullToBlank(item.Remark),
							PayDate : nullToBlank(item.PayDate),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank)
					}
					
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppTB_TableArea").append(htmlStr);
					if(isEmptyStr(item.TaxInvoiceID)){
						accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]").remove();
					}
					
					if(valMap.VendorID != "") {
						var tempObj = {};
						tempObj.KeyNo = valMap.KeyNo;
						tempObj.ProofCode = "TaxBill";
						tempObj.VendorID = valMap.VendorID;
						tempObj.AccountInfo = valMap.AccountInfo;
						tempObj.AccountHolder = valMap.AccountHolder;
						tempObj.AccountBank = valMap.AccountBank;
						me.combiCostApp_getVendorInfo(tempObj); 
					}
					
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
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'TaxBill', false);
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
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'TaxBill', false);
					}
				}
				if( me.businessNumberCnt > 1) {
					me.combiCostApp_callVendorPopup("TaxBill", 1, me.businessNumber);
				}
				
				me.combiCostApp_makeDateField("TaxBill", me.taxBillPageExpenceAppList);
			},
	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationTax<%=requestType%>);
})(window);


</script>