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

<ul class="card_nea_right_list" id="combiCostAppEE_TableArea" name="combiCostAppEE_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationEtc<%=requestType%> = {		
				
			etcEvidPageExpenceAppList : [],

			combiCostAppEE_EtcEvidPageInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				me.etcEvidPageExpenceAppList = [];
			},
			combiCostAppEE_EtcEvidDataInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				me.etcEvidPageExpenceAppList = [];
			},


			combiCostAppEE_itemAdd : function() {
				var me = this;
				
				if(me.etcEvidPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_018' />", "Confirmation Dialog", function(result){
						if(result){
							me.combiCostAppEE_EtcEvidDataInit()
							me.combiCostAppEE_inputListDataAdd(null, true);
						}
					});
				}else{
					me.combiCostAppEE_EtcEvidDataInit()
					me.combiCostAppEE_inputListDataAdd(null, true);
				}
				
			},

			combiCostAppEE_inputListDataAdd : function(inputItem, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var item = {};
				
				if(isNew){
					var pd = item.ProofDate;

					item.IsNew = true;
					item.IsNewStr = "Y";
					me.isModified = false;
				}else{
					item = inputItem;
					me.isModified = true;
				}

				var maxKey = me.combiCostApp_getPageListMaxKey('EtcEvid');
				item.KeyNo = maxKey+1;
				item.ProofCode = "EtcEvid";
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
							ExpenceApplicationDivID : ""
							, ExpenceApplicationListID : "" 
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
				me.etcEvidPageExpenceAppList.push(item);

				me.combiCostAppEE_setListHTML();
			},

			combiCostAppEE_setListHTML : function(isAll) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				}
				
				for(var i = 0; i<me.etcEvidPageExpenceAppList.length; i++){
					var item = me.etcEvidPageExpenceAppList[i];
					
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
							VendorID : nullToBlank(item.VendorID),
							FranchiseCorpName : nullToBlank(item.FranchiseCorpName),
							RepAmount : toAmtFormat(nullToBlank(item.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(item.TaxAmount)),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank)
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppEE_TableArea").append(htmlStr);
					
					accountCtrl.getInfoStr("[name=CombiCostInputField][field=RepAmount][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]").val(toAmtFormat((item.RepAmount == null ? item.TotalAmount : item.RepAmount)));
					accountCtrl.getInfoStr("[name=CombiCostInputField][field=TaxAmount][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]").val(toAmtFormat((item.TaxAmount == null ? 0 : item.TaxAmount)));
					
					if(valMap.VendorID != "") {
						var tempObj = {};
						tempObj.KeyNo = valMap.KeyNo;
						tempObj.ProofCode = "EtcEvid";
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
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'EtcEvid', false);
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
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'EtcEvid', false);
					}
					me.combiCostAppEE_etcEvidTypeChange(null, item.KeyNo, null)
				}
				me.combiCostApp_makeDateField("EtcEvid", me.etcEvidPageExpenceAppList);
				
				//useWriteVendor == Y
				if(Common.getBaseConfig("useWriteVendor", sessionObj["DN_ID"]) == "Y") {
					$("input[field=VendorNo]").removeAttr("disabled").attr("type", "text").attr("placeholder", "사업자번호").attr("onblur", "CombineCostApplication<%=requestType%>.combiCostApp_InputVendorChange(this, 'EtcEvid', '" + item.KeyNo + "', 'VendorNo')");
					$("input[field=VendorName]").removeAttr("disabled").attr("placeholder", "거래처명").attr("onblur", "CombineCostApplication<%=requestType%>.combiCostApp_InputVendorChange(this, 'EtcEvid', '" + item.KeyNo + "', 'VendorName')");
				}

			},
			combiCostAppEE_etcEvidTypeChange : function(obj, KeyNo, inputVal) {
				var me = this;
				var val = "";
				if(obj==null
						&& inputVal != null){
					val = inputVal;			
				}
				else{
					//val =  $("input[name=etcEvidRadio"+KeyNo+"]:checked").val();
					val = accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val();
				}
				
				if(val=="N"){
					accountCtrl.getInfoStr("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "none")
					accountCtrl.getInfoStr("[tag=TaxVal]").val("");
					
				}else if(val=="Y"){
					accountCtrl.getInfoStr("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "")
				}
				var item = me.combiCostApp_findListItem(me.etcEvidPageExpenceAppList, "KeyNo", KeyNo);
				item.IsWithholdingTax  = val;
			}

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationEtc<%=requestType%>);
})(window);



</script>