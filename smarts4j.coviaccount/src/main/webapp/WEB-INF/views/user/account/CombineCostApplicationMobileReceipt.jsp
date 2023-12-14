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

<ul class="card_nea_right_list" id="combiCostAppMR_TableArea" name="combiCostAppMR_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationReceipt<%=requestType%> = {

			receiptPageExpenceAppList : [],
			
			
			combiCostAppMR_ReceiptPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppMR_TableArea").html("");
				me.receiptPageExpenceAppList = [];
			},
			
			combiCostAppMR_ReceiptDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppMR_TableArea").html("");
				me.receiptPageExpenceAppList = [];
			},

			

			combiCostAppMR_ReceiptInfoLoadPopup : function() {
				var me = this;
				me.combiCostAppMR_callReceiptInfoPopup();
			},

			combiCostAppMR_callReceiptInfoPopup : function() {
				var me = this;
				var popupID		=	"receiptSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_btn_mobileReceiptLoad'/>";	//모바일 영수증 불러오기
				var popupName	=	"ReceiptSearchPopup";
				var callBack	=	"combiCostAppMR_getReceiptRecInfo";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"paramsetFunc=combiCostApp_CallAddLoadPopupParam&"
								//+	"ExpAppID="	+	ExpAppId	+	"&"
								//+	"idStr="	+	idStr	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","620px","iframe",true,null,null,true);
				
			},
			combiCostAppMR_getReceiptRecInfo : function(inputList) {
				var me = this;

				for(var i = 0; i<inputList.length; i++){
					var item = inputList[i];

					item.ProofDate = item.PhotoDate;
					item.ProofDateStr = item.PhotoDateStr;
					item.PostingDate = item.PhotoDate;
					item.PostingDateStr = item.PhotoDateStr;
					item.UsageComment = item.UsageText;
				}
				me.combiCostAppMR_inputListDataAdd(inputList, true);
			},

			combiCostAppMR_inputListDataAdd : function(itemList, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var arrCk = Array.isArray(itemList);
				if(arrCk){
					var addedCk1 = false;
					var addedCk2 = false;
					var confirmNoList = "";



					for(var i = 0; i<itemList.length; i++){
						var item = itemList[i];

						if(isNew){
							var pd = item.ProofDate;

							item.IsNew = true;
							item.IsNewStr = "Y";
						}
						var maxKey = me.combiCostApp_getPageListMaxKey('Receipt');
						item.KeyNo = maxKey+1;
						item.ProofCode = "Receipt";
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
						me.receiptPageExpenceAppList.push(item);
					}

					me.combiCostAppMR_setListHTML(false, itemList);
				}
			},

			//법인카드 사용내역 HTML 만들기
			combiCostAppMR_setListHTML : function(isAll, inputList) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppMR_TableArea").html("");
				}
				var list = [];
				
				if(inputList == null){
					list = me.receiptPageExpenceAppList;
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
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							PersonalCardNo : nullToBlank(item.PersonalCardNo),
							PersonalCardNoView : nullToBlank(item.PersonalCardNoView),
							FileID : nullToBlank(item.FileID),
							FileName : nullToBlank(item.FileName),
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppMR_TableArea").append(htmlStr);
					
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
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'Receipt', false);
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
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'Receipt', false);
					}
				}
				me.combiCostApp_makeDateField("Receipt", list);
			},

		}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationReceipt<%=requestType%>);
})(window);

</script>