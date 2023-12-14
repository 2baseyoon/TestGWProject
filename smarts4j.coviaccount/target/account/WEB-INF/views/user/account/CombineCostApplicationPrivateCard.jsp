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

<ul class="card_nea_right_list" id="combiCostAppPC_TableArea" name="combiCostAppPC_TableArea">
<!-- 컨텐츠가 들어갈 자리 -->
</ul>

<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

(function(window) {
	var requestType = "<%=requestType%>";
	
	var CombineCostApplicationPriv<%=requestType%> = {		
				
			privateCardPageExpenceAppList : [],

			combiCostAppPC_PrivateCardPageInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				me.privateCardPageExpenceAppList = [];
			},
			combiCostAppPC_PrivateCardDataInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				me.privateCardPageExpenceAppList = [];
			},


			combiCostAppPC_itemAdd : function() {
				var me = this;
				
				if(me.privateCardPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_018' />", "Confirmation Dialog", function(result){	//이 유형의 증빙은 한번에 하나의 증빙만 추가할 수 있습니다. 입력창을 초기화 하시겠습니까?
						if(result){
							me.combiCostAppPC_PrivateCardDataInit();
							me.combiCostAppPC_inputListDataAdd(null, true);
						}
					});
				}else{
					me.combiCostAppPC_PrivateCardDataInit();
					me.combiCostAppPC_inputListDataAdd(null, true);
				}
				
			},

			combiCostAppPC_inputListDataAdd : function(inputItem, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var item = {};
				
				if(isNew){
					var pd = item.ProofDate;

					item.IsNew = true;
					item.IsNewStr = "Y";
				}else{
					item = inputItem;
				}

				var maxKey = me.combiCostApp_getPageListMaxKey('PrivateCard');
				item.KeyNo = maxKey+1;
				item.ProofCode = "PrivateCard";
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
				me.privateCardPageExpenceAppList.push(item);

				me.combiCostAppPC_setListHTML();
			},

			combiCostAppPC_setListHTML : function(isAll) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				}

				for(var i = 0; i<me.privateCardPageExpenceAppList.length; i++){
					var item = me.privateCardPageExpenceAppList[i];
					
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
							FranchiseCorpName : nullToBlank(item.FranchiseCorpName),
							Tax : nullToBlank(item.Tax),
							SupplyCost : nullToBlank(item.SupplyCost),
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppPC_TableArea").append(htmlStr);
					
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
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'PrivateCard', false);
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
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'PrivateCard', false);
					}
				}
				me.combiCostApp_makeDateField("PrivateCard", me.privateCardPageExpenceAppList);
			},

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationPriv<%=requestType%>);
})(window);



</script>