<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.DicHelper,egovframework.coviframework.util.StringUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	.pad10 { padding:10px;}
</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="AuditReport.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
				</div>
				<div class="buttonStyleBoxRight">	
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="AuditReport.downloadExcel();"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
			</div>
			
  			<form name="frm" method="post">
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:1200px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="companyCode" class="selectType02" onchange="AuditReport.changeCompanyCode()">
							</span>
						</div>	
						<div class="inPerTitbox">
							<!-- 감사보고서-->
							<span class="bodysearch_tit" style="width: 100px;"><spring:message code='Cache.lbl_apv_audit' /><spring:message code='Cache.lbl_UsageReport' /></span>
							<span id="reportType" class="selectType02" style="width:200px" onchange="AuditReport.searchList()">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙월 -->
	                   		<span class="bodysearch_tit"><spring:message code='Cache.lbl_evidMonth' /></span>
	                   		<input type="text" id="proofDate" kind="date" date_separator="-" date_selecttype="m" id="AXInputDate2" style="height: 25px;" data-axbind="date">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="AuditReport.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox" stuyle="">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="AuditReport.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="AuditReport.searchList();"></button>
				</div>
			</div>
  			</form>
			<div id="gaAuditReport" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	if (!window.AuditReport) 
	{
		window.AuditReport = {};
	}
	
	(function(window) {
		var AuditReport = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},
			
			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');
				var today = new Date();
				var todayStr = today.format("yyyy-MM");
				accountCtrl.getInfo("proofDate").val(todayStr);
				me.setSelectCombo();
				me.setHeaderData();
				me.searchList();
			},
			
			pageView : function() {
				var me = this;

				me.setHeaderData();
				me.refreshCombo();
				
				var gridAreaID		= "gaAuditReport";
				var gridPanel		= me.params.gridPanel;
				var pageNoInfo		= me.params.gridPanel.page.pageNo;
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				
				var gridParams		= {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
				}
				
				accountCtrl.refreshGrid(gridParams);
			},
			setSelectCombo : function(pCompanyCode){
				accountCtrl.getInfo("listCount").children().remove();
				accountCtrl.getInfo("reportType").children().remove();
				
				accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "AuditReport.searchList()");
				accountCtrl.getInfo("reportType").addClass("selectType02").css("width", "200px").attr("onchange",  "AuditReport.searchList()");
				
				var AXSelectMultiArr	= [	
											{'codeGroup':'AuditReport',		'target':'reportType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
											{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
											{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
									]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop(); //CompanyCode 제외
				}
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
			},
			
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("reportType");
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = new Array();
				var objHeader= {"DupStore":[   {key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
											  ,{key : "StoreName"    ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"center", sort:false, formatter:function (){
													return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
											   }
								              ,{key : "ProofDate"  ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center"}
							                  ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
				                              ,{key : "UserDept"     ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
				                              ,{key : "RegisterName" ,label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
				                              ,{key : "ApproveNo"    ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
				                              ,{key : "AmountSumNum" ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money" }
				                              ,{key : "StoreAddress1",label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"center" }]
				 				,"LimitAmount":[{key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
				 							  ,{key : "UserDept"      ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
				 							  ,{key : "RegisterName",label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
							                  ,{key : "ProofDate"   ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center"}
							                  ,{key : "AmountSumNum"  ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money"  }
							                  ,{key : "StoreName"     ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"left", formatter:function () {
							                	 return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
							                  }
							                  ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
						                 	  ,{key : "ApproveNo"     ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
							                  ,{key : "StoreAddress1" ,label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"left" }]
							   ,"HolidayUse":[{key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
								   			 ,{key : "UserDept"      ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
							   				 ,{key : "RegisterName",label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
							                 ,{key : "ProofDate"   ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center"}
							                 ,{key : "Anniversary"   ,label : "<%=DicHelper.getDic("lbl_Gubun")%>",   width : 25, align:"center", formatter:function () {
												 if (this.item.HolidayType == "N") //심야
								            		 	return "<font color=blue>"+Common.getDic("lbl_night")+"</font></a>";
							            		 	else 
								            		 	return "<font color=red>"+this.item.Anniversary+"</font></a>";
								            		 	
													}	
							                 }
							                 ,{key : "AmountSumNum"  ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money"  }
							                 ,{key : "StoreName"     ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"left" , formatter:function () {
													return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
											 }
							                 ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
							                 ,{key : "ApproveNo"     ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
							                 ,{key : "StoreAddress1" ,label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"left" }]
							   ,"LimitStore":[{key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
								   			 ,{key : "UserDept"      ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
							   				 ,{key : "RegisterName",label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
							                 ,{key : "ProofDate"   ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center"}
							                 ,{key : "LimitCategoryName",label : "<%=DicHelper.getDic("ACC_lbl_vendorSector")%>",       width : 25, align:"center"}
							                 ,{key : "AmountSumNum"  ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money"  }
							                 ,{key : "StoreName"     ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"left",formatter:function () {
							                	 return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
							                 }
							                 ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
							                 ,{key : "ApproveNo"     ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
							                 ,{key : "StoreAddress1" ,label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"left" }]
							 ,"UserVacation":[{key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
								 			 ,{key : "UserDept"      ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
							   				 ,{key : "RegisterName",label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
							                 ,{key : "ProofDate"   ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center", formatter:function () {
							                	 return ""+this.item.ProofDate.substring(0,4)+"."+this.item.ProofDate.substring(4,6)+"."+this.item.ProofDate.substring(6)+"";}}
							                 ,{key : "GubunName",label : "<%=DicHelper.getDic("lbl_Gubun")%>",       width : 25, align:"center"}
							                 ,{key : "AmountSumNum"  ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money"  }
							                 ,{key : "StoreName"     ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"left", formatter:function () {
							                	 return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
						                	 }
							                 ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
							                 ,{key : "ApproveNo"     ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
							                 ,{key : "StoreAddress1" ,label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"left" }]
			 					,"EnterTain":[{key : "CompanyName"	 ,label : "<spring:message code='Cache.ACC_lbl_company' />",	width:'25',	align:'center'}		//회사
			 								,{key : "UserDept"      ,label : "<%=DicHelper.getDic("NumberFieldType_DeptName")%>",  width : 25, align:"center" }
			 								,{key : "RegisterName",label : "<%=DicHelper.getDic("lbl_Applicator")%>",            width : 25, align:"center" } 
							                ,{key : "ProofDate"   ,label : "<%=DicHelper.getDic("ACC_lbl_approveDate")%>",       width : 25, align:"center"}
							                ,{key : "AmountSumNum"  ,label : "<%=DicHelper.getDic("lbl_UsedAmount")%>",            width : 25, align:"right", formatter:"money"  }
							                ,{key : "StoreName"     ,label : "<%=DicHelper.getDic("ACC_lbl_franchiseCorpName")%>", width : 27, align:"left", formatter:function () { 
							                	return String.format("<a onclick=\"AuditReport.openDetailPopup('{0}','{1}')\"><font color=blue><u>"+(this.item.StoreName == null?"["+this.item.ProofCodeName+"]": this.item.StoreName)+"</u></font></a>",this.item.ProofCode,this.item.ReceiptID); }
							                 }
							                ,{key : "ProofTime"   ,label : "<%=DicHelper.getDic("lbl_Time")%>",       width : 25, align:"center"}
							                ,{key : "ApproveNo"     ,label : "<%=DicHelper.getDic("lbl_confirmNum")%>",            width : 25, align:"center" }
							                ,{key : "StoreAddress1" ,label : "<%=DicHelper.getDic("lbl_HomeAddress")%>",           width : 25, align:"left" }]
				};
				var reportType = accountCtrl.getComboInfo("reportType").val();
				me.params.headerData = objHeader[reportType];
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				me.setHeaderData();
				var proofDate	= accountCtrl.getInfo("proofDate").val();
				var reportType  = accountCtrl.getComboInfo("reportType").val();
				var companyCode = accountCtrl.getComboInfo("companyCode").val();
				
				if(reportType != "") {
					var gridAreaID		= "gaAuditReport";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/auditReport/getAuditReportList.do";
					var ajaxPars		= 
										{	"proofDate"		: proofDate,	
											"reportType"	: reportType,
											"companyCode"	: companyCode
										};
					
					var pageNoInfo	= 1;
					if(YN== 'Y'){
						pageNoInfo	= me.params.gridPanel.page.pageNo;
					}
					
					var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: "N"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				}
			},
			downloadExcel: function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= AuditReport.getHeaderNameForExcel(me.params.headerData);
						var headerKey		= AuditReport.getHeaderKeyForExcel(me.params.headerData);
						
						var proofDate		= accountCtrl.getInfo("proofDate").val();
						var reportType		= accountCtrl.getComboInfo("reportType").val();
						var companyCode = accComm.getCompanyCodeOfUser();
						var title 			= accountCtrl.getInfo("headerTitle").text();
						
						var	locationStr		= "/account/auditReport/downloadExcel.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&proofDate="	+ proofDate
											+ "&reportType="+ reportType
											+ "&companyCode="+ companyCode;
						location.href = locationStr;
		       		}
		       	});
			},
			refresh : function(){
				accountCtrl.pageRefresh();
			},
			openDetailPopup:function(proofCode, key){
				switch(proofCode){
					case "CorpCard"://법인카드
						var popupName	=	"CardReceiptPopup";
						var popupID		=	"cardReceiptPopup";
						var openerID	= 	"AuditReport";
						var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />"; //신용카드 매출전표
						var url			=	"/account/accountCommon/accountCommonPopup.do?"
										+	"popupID="		+ popupID	+ "&"
										+	"openerID="		+ openerID	+ "&"
										+	"popupName="	+ popupName	+ "&"
										+	"approveNo="	+ key		+ "&"
										+	"receiptID="	+ key;
						Common.open("",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
						break;
					case "Receipt":
						var popupName	=	"FileViewPopup";
						var popupID		=	"fileViewPopup";
						var openerID	=	"AuditReport";
						var callBack	=	"zoomFileViewPopup";
						var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup' />"; //영수증 보기
						var url			=	"/account/accountCommon/accountCommonPopup.do?"
										+	"popupID="		+ popupID	+ "&"
										+	"popupName="	+ popupName	+ "&"
										+	"fileID="		+ key	+ "&"
										+	"openerID="		+ openerID	+ "&"
										+	"callBackFunc="	+	callBack;
						Common.open("",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
						break;
					default:	
						var popupName	=	"CombineCostApplicationListView";
						var popupID		=	"combineCostApplicationListView";
						var openerID	=	"AuditReport";
						var popupTit	=	""; 
						var url			=	"/account/expenceApplication/ExpenceApplicationListViewPopup.do?"
										+	"popupID="		+ popupID	+ "&"
										+	"popupName="	+ popupName	+ "&"
										+	"expAppListIDs="+ key		+ "&"
										+	"openerID="		+ openerID	;
						Common.open("",popupID,popupTit,url,"1070","500px","iframe",true,null,null,true);
						break;
				}
			},
			zoomFileViewPopup:function(info) {
				accComm.accZoomMobileReceiptAppClick(info);
			},
			getHeaderNameForExcel:function (headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
			   	   		returnStr += headerData[i].label + "†";
			   	   	}
				}
				return returnStr;
			},
			getHeaderKeyForExcel:function(headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
						returnStr += headerData[i].key + ",";
			   	   	}
				}
				return returnStr;
			}
		}
		window.AuditReport= AuditReport;
	})(window);
</script>