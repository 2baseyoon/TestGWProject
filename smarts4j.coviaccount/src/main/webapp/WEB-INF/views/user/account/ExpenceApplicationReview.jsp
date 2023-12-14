<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault  btnTypeBg " href="#" onclick="ExpenceApplicationReview.expAppRev_makeSlip()">
						<!-- 전표발행 -->
						<spring:message code="Cache.ACC_btn_makeSlip"/>
					</a>
					<a class="btnTypeDefault" href="#" onclick="ExpenceApplicationReview.expAppRev_refresh()">
						<!-- 새로고침 -->
						<spring:message code="Cache.ACC_btn_refresh"/>
					</a>
					<a id="btnicubeDuzonExcel" class="btnTypeDefault" href="#"	onclick="ExpenceApplicationReview.expAppRev_icubeDuzonExcel();" style="display:none;"><spring:message code="Cache.ACC_icubeDuzonExcel"/></a> <!-- 더존 icube 다운 -->
				</div>				
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- 검색영역 시작 -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="expAppRev_CompanyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="ExpenceApplicationReview.changeCompanyCode()">
							</span>
						</div>							
						<div class="inPerTitbox">
							<!-- 증빙종류 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofClass"/></span>
							<span id="expAppRev_proofCode" class="selectType02" name="searchParam" tag="proofCode">
							</span>
						</div>								
						<div class="inPerTitbox">
							<!-- 구분 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
							<select class="selectType02" name="searchParam" tag="searchType">
								<!-- 제목 || 기안자 || 전표번호 || 증빙유형 -->
								<option value="title"><spring:message code="Cache.ACC_lbl_title"/></option>
								<option value="user"><spring:message code="Cache.ACC_lbl_aprvWriter"/></option>
								<option value="docno"><spring:message code="Cache.ACC_lbl_docNo"/></option>
							</select>
							<input type="text" name="searchParam" tag="searchText" onkeydown="ExpenceApplicationReview.onenter()">					
						</div>			
					</div>
					<div style="width:900px;">					
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 지급일 -->
								<spring:message code='Cache.ACC_lbl_payDay'/> 
							</span>
							<div id="expAppRev_payDateSearch" class="dateSel type02" name="searchParam" tag="payDate" fieldtype="Date">
							</div>
						</div>		
						<div class="inPerTitbox" style="margin-left: 52px;">
							<span class="bodysearch_tit">
								<!-- 전기일 -->
								<spring:message code='Cache.ACC_lbl_postDate'/> 
							</span>
							<div id="expAppRev_postingDateSearch" class="dateSel type02" name="searchParam" tag="postingDate" fieldtype="Date">
							</div>
						</div>		
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="ExpenceApplicationReview.expAppRev_searchExpenceApplicationList();">
							<spring:message code="Cache.ACC_btn_search"/>
						</a><!-- 버튼위치를 인라인으로 조정 -->
					</div>						
				</div>
			</div>
			
			<div class="inPerTitbox">
				<div class="tblList_top">
					<span class="bodysearch_tit">
						<!-- 전기일 -->
						<spring:message code="Cache.ACC_lbl_postDate"/>
					</span>
					<div class="dateSel type02">
						
						<div id="expAppRev_PostDateArea" class="dateSel type02"></div>
						
						<label>
							<input name="checkField" datafield="PostingDate" targetfield="expAppRev_PostDateArea_Date" type="checkbox" checked>
							<!-- 문서의 기장일로 처리 -->
							<spring:message code="Cache.ACC_022"/>
						</label>
					</div>								
				</div>
				<div class="tblList_top">
					<span class="bodysearch_tit">
						<!-- 지급일 -->
						<spring:message code="Cache.ACC_lbl_payDay"/>
					</span>
					<div class="dateSel type02">
						<div id="expAppRev_PayDayArea" class="dateSel type02"></div>
						<label>
							<input name="checkField" datafield="PayDay" targetfield="expAppRev_PayDayArea_Date"  type="checkbox" checked>
								<!-- 문서의 기장일로 처리 -->
							<spring:message code="Cache.ACC_022"/>
						</label>
					</div>								
				</div>
				<div class="buttonStyleBoxRight">	
					<span class="selectType02 listCount" id="expAppRev_ListCount" onchange="ExpenceApplicationReview.expAppRev_searchExpenceApplicationList();"></span>
					<button class="btnRefresh" type="button" onclick="ExpenceApplicationReview.expAppRev_searchExpenceApplicationList();"></button>
				</div>
			</div>
			<!-- 검색영역 끝 -->
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="ExpAppRevListGrid"></div>
			</div>
			
			<div name="hiddenLinkArea" ></div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.ExpenceApplicationReview) {
	window.ExpenceApplicationReview = {};
}

(function(window) {
	var ExpenceApplicationReview = {
			
			gridPanel : new coviGrid(),
			gridHeaderData : [	{ key:'chk',					label:'chk',		width:'20',		align:'center',	formatter:'checkbox'},
								{ key:'CompanyCode',			label : "<spring:message code='Cache.ACC_lbl_company' />",		width:'120',		align:'center',		//회사
									formatter: function() {
										return this.item.CompanyName;
									}
								},	
								{ key:'ApplicationTitle',		label : "<spring:message code='Cache.ACC_lbl_title' />",		width:'250', align:'left'	//제목
									, formatter:function () {
										var retStr = "";
										var title = "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")";	//제목없음

										if(!isEmptyStr(this.item.ApplicationTitle)){
											title = this.item.ApplicationTitle;
										}

										retStr = "<a href='#'	onClick=\"ExpenceApplicationReview.expAppRev_evidWritePage('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"')\"><font color='blue'><u>"+title+"</u></font></a>";
										return retStr;
									}
								},
								{ key:'RegisterName',			label : "<spring:message code='Cache.ACC_lbl_aprvWriter' />",			width:'100', align:'center'},	//기안자
								{ key:'ApplicationStatusName',	label : "<spring:message code='Cache.ACC_lbl_processStatus' />",		width:'100', align:'center'},	//처리상태
								{ key:'DocNo',					label : "<spring:message code='Cache.ACC_lbl_docNo' />",				width:'100', align:'center'},	//전표번호
								{ key:'UnDocNo',				label : "<spring:message code='Cache.ACC_lbl_unDocNo' />",				width:'120', align:'center'},	//역발행 전표번호
								{ key:'ApplicationDate',		label : "<spring:message code='Cache.ACC_lbl_aprvDate' />"+Common.getSession("UR_TimeZoneDisplay"),		width:'100', align:'center',
									formatter:function(){
										return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
									}, dataType:'DateTime'
								},	//기안일
								{ key:'DocPayDate',				label : "<spring:message code='Cache.ACC_lbl_payDay' />",				width:'100', align:'center'},	//지급일
								{ key:'DocPostingDate',			label : "<spring:message code='Cache.ACC_lbl_postDate' />",				width:'100', align:'center'},	//전기일
								{ key:'VendorName',				label : "<spring:message code='Cache.ACC_lbl_vendorName' />",			width:'150', align:'center'},	//거래처명
								{ key:'TaxAmount',				label : "<spring:message code='Cache.ACC_lbl_taxValue' />",				width:'100', align:'right'},	//세액
								{ key:'RepAmount',				label : "<spring:message code='Cache.ACC_lbl_supplyValue' />",			width:'100', align:'right'},	//공급가액
								{ key:'AmountSum',				label : "<spring:message code='Cache.ACC_lbl_eviTotalAmt' />",			width:'100', align:'right'},	//증빙총액
								/*
								{ key:'AccountName',			label : "<spring:message code='Cache.ACC_lbl_account' />",				width:'70', align:'center'},	//계정과목
								{ key:'CostCenterName',			label : "<spring:message code='Cache.ACC_lbl_CostCenter' />",			width:'70', align:'center'},	//코스트센터
								{ key:'FranchiseCorpName',		label : "<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'70', align:'center'},	//가맹점명
								*/
								{ key:'ProofCodeName',			label : "<spring:message code='Cache.ACC_lbl_evidType' />",				width:'100', align:'center'},			//증빙유형
								{ key:'DocCnt',					label : "<spring:message code='Cache.ACC_lbl_viewEvid' />",				width:'150', align:'center'				//증빙보기
									, formatter:function () {
										var str = "";
										if(this.item.ProofCode=="CorpCard"||this.item.ProofCode=="TaxBill"||this.item.ProofCode=="Receipt"){
											str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationReview.expAppRev_viewEvidListItem(\''
												+this.item.ProofCode+'\', \''+this.item.CardUID+'\', \''+this.item.TaxUID+'\', \''+this.item.ReceiptFileID+'\')">'+"<spring:message code='Cache.ACC_lbl_viewEvid' />"+'</a>';
											//+this.item.ProofCode+'\', \''+this.item.ReceiptID+'\', \''+this.item.TaxInvoiceID+'\')">'+"<spring:message code='Cache.ACC_lbl_viewEvid' />"+'</a>';
										}
										return str 
									},
									sort: false
								},
							],
			auditInfo : {},

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');

				var today = new Date();
				var todayStr = today.format("yyyyMMdd")
				makeDatepicker('expAppRev_PostDateArea', 'expAppRev_PostDateArea_Date', null, todayStr, null, 100);
				makeDatepicker('expAppRev_PayDayArea', 'expAppRev_PayDayArea_Date', null, todayStr, null, 100);
				makeDatepicker('expAppRev_postingDateSearch', 'expAppRev_postingDateSearch', null, null, null, 100);
				makeDatepicker('expAppRev_payDateSearch', 'expAppRev_payDateSearch', null, null, null, 100);

				me.expAppRev_comboInit();
				me.expAppRev_getAuditInfo();
				me.expAppRev_gridInit()
				
				if(	Common.getBaseConfig("douzoniCubeYN") == "Y") {
					$("#btnicubeDuzonExcel").show();
				}
				
				return;
				
			},
			
			pageView : function() {
				var me = this;
				me.expAppRev_comboRefresh();
				
				me.expAppRev_searchExpenceApplicationList();
			},

			expAppRev_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("expAppRev_ListCount").children().remove();
				accountCtrl.getInfo("expAppRev_proofCode").children().remove();

				accountCtrl.getInfo("expAppRev_ListCount").addClass("selectType02").addClass("listCount").attr("onchange", "ExpenceApplicationReview.expAppRev_searchExpenceApplicationList();");
				accountCtrl.getInfo("expAppRev_proofCode").addClass("selectType02").attr("name", "searchParam").attr("tag", "proofCode");
				
				// 로딩속도 개선
				var __AXSelectMultiArr = [
					{
						"codeGroup":"listCountNum"
						,"target":"expAppRev_ListCount"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":null
					},
					{
						"codeGroup":"ProofCode"
						,"target":"expAppRev_proofCode"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":null
					}
				];
				accountCtrl.renderAXSelectMulti(__AXSelectMultiArr, pCompanyCode);
				
				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode',	'expAppRev_CompanyCode','ko','','','',null,pCompanyCode);
				}
			},

			expAppRev_comboRefresh : function() {
				var me = this;
				accountCtrl.refreshAXSelect('expAppRev_ListCount');
				accountCtrl.refreshAXSelect('expAppRev_proofCode');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.expAppRev_comboInit(accountCtrl.getComboInfo("expAppRev_CompanyCode").val());
			},

			expAppRev_getAuditInfo : function(defaultVal) {
				var me = this;

				$.ajax({
					type:"POST",
						url:"/account/audit/getAuditList.do",
					data:{
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							var list = data.list;
							for(var i = 0; i<list.length; i++){
								var item = list[i]
								me.auditInfo[item.RuleCode] = item;
							}
							
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
			
			expAppRev_gridInit : function() {
				var me = this;
				
				accountCtrl.setViewPageGridHeader(me.gridHeaderData, me.gridPanel);
				me.expAppRev_searchExpenceApplicationList()
			},
			
			// 그리드 Config 설정
			expAppRev_setGridConfig : function() {
				var me = this;
			},

			expAppRev_getSearchParams : function() {
				var me = this;
				
				var searchInputList =	accountCtrl.getInfoName("searchParam");
				
				var retVal = {};
					for(var i=0;i<searchInputList.length; i++){
						var item = searchInputList[i];
						if(item!= null){
							if(item.tagName == 'DIV'){

								var fieldType= item.getAttribute("fieldtype")
								if(fieldType == "Date"){
									var dateVal = accountCtrl.getInfo("expAppRev_" + item.getAttribute("tag") + "Search").val();
									dateVal = dateVal.replace(/\./gi, '');
									retVal[item.getAttribute("tag")] = dateVal;	
								}
							}else{
								retVal[item.getAttribute("tag")] = item.value;
							}
						}
					}
				return retVal;
			},
			
			expAppRev_searchExpenceApplicationList : function(YN) {
				var me = this;
	
				var searchParam = me.expAppRev_getSearchParams();				
				var pageSize	= accountCtrl.getComboInfo("expAppRev_ListCount").val();
				
				var gridAreaID		= "ExpAppRevListGrid";
				var gridPanel		= me.gridPanel;
				var gridHeader		= me.gridHeaderData;
				var ajaxUrl			= "/account/expenceApplication/searchExpenceApplicationReviewList.do";
				var ajaxPars		= {
											"searchParam" : JSON.stringify(searchParam)
											, "pageSize":pageSize,
										}
				
				var pageSizeInfo	= accountCtrl.getComboInfo("expAppRev_ListCount").val();
				var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								, 	"callback"		: me.expAppRev_searchCallback
								,	"fitToWidth"	: false
				}
				accountCtrl.setViewPageBindGrid(gridParams);
			},

			expAppRev_searchCallback : function() {
				var me = window.ExpenceApplicationReview;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;
			},
			
			expAppRev_viewEvidPopup : function(getId) {
				var me = this;
				//전표조회
				Common.open("","expenceApplicationViewPopup","<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>",
					"/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+getId,"1200px","600px","iframe",true,null,null,true);
			},
			
			expAppRev_evidWritePage : function(getId, type, requestType) {
				var me = this;

				var setParam = {
						isSearch : 'Y'
						, ExpAppId : getId
						, name : 'search'
						, isReview : 'Y'
				}			

				if(type=="CO"){
					//통합비용신청
					eAccountContentHtmlChangeAjax('account_CombineCostApplicationaccountuserAccount'+requestType
							, $("#account_CombineCostApplicationaccountuserAccount"+requestType).text()
							, '/account/layout/account_CombineCostApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account&requesttype='+requestType
							, setParam);
				}else if(type=="SC"){
					//간편신청
					eAccountContentHtmlChangeAjax('account_SimpleApplicationaccountuserAccount'+requestType
							, $("#account_SimpleApplicationaccountuserAccount"+requestType).text()
							, '/account/layout/account_SimpleApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account&requesttype='+requestType
							, setParam);
				}
			},

			expAppRev_expAppManViewFile : function(getId) {
				var me = this;
				//첨부파일
				Common.open("","expAppManViewFile","<spring:message code='Cache.ACC_lbl_addFile'/>",
					"/account/expenceApplication/ExpenceApplicationViewFilePopup.do?ExpAppListID="+getId,"350px","400px","iframe",true,null,null,true);
			},
			
			expAppRev_viewEvidListItem : function(ProofCode, ReceiptID, TaxInvoiceID, ReceiptFileID) {
				var me = this;
				if(ProofCode=="CorpCard"){
					accComm.accCardAppClick(CardUID, me.pageOpenerIDStr);
				} else if(ProofCode=="TaxBill"){
					accComm.accTaxBillAppClick(TaxUID, me.pageOpenerIDStr);
				} else if(ProofCode=="Receipt"){
					var popupID		=	"fileViewPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
					var popupName	=	"FileViewPopup";
					var callBack	=	"expAppRev_ZoomMobileAppClick";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"fileID="	+	ReceiptFileID	+	"&"
									+	me.pageOpenerIDStr
									+	"callBackFunc="	+	callBack;
					Common.open(	"",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
				}
			},
			
			expAppRev_ZoomMobileAppClick : function(info){
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="		+	info.FileID	+	"&"					
								+	me.pageOpenerIDStr				+	"&"
								+	"zoom="			+	"Y"		
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
			},
			
			expAppRev_makeSlip : function(){
				var me = this;
				
				var dateCkList = accountCtrl.getInfoStr("[name=checkField]");
				var obj = {};
				
				for(var i=0;i<dateCkList.length; i++){
					var field = dateCkList[i]
					var dataField = field.getAttribute("datafield");
					var target = field.getAttribute("targetfield");
					obj[dataField+"Bool"] = field.checked;
					if(!field.checked){
						obj[dataField+"Ck"] = "N";
						var dateStr = accountCtrl.getInfo(target).val();
						obj[dataField+"Str"] = dateStr
						obj[dataField+"Date"] = dateStr.replaceAll(".", "");
					}
					else{
						obj[dataField+"Ck"] = "Y"
					}
				}

				var makeList	= me.gridPanel.getCheckedList(0);
				if(makeList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
					return
				}
				var docCk = false
				for(var i=0;i<makeList.length; i++){
					var item = makeList[i];
					if(!isEmptyStr(item.DocNo)){
						docCk = true;
					}
				}

				if(docCk){
					Common.Inform("<spring:message code='Cache.ACC_023'/>");	//이미 전표가 발행된 항목이 선택되었습니다.
					return
				}
				
				obj.makeList = makeList;
				if(obj.PayDayBool==false && obj.PayDayDate ==""){
					Common.Inform("<spring:message code='Cache.ACC_035'/>");	//지급일이 입력되지 않았습니다.
					return
				}
				if(obj.PostingDateBool==false && obj.PostingDateDate ==""){
					Common.Inform("<spring:message code='Cache.ACC_034'/>");	//전기일이 입력되지 않았습니다.
					return
				}
		        Common.Confirm("<spring:message code='Cache.ACC_033'/>", "Confirmation Dialog", function(result){	//전표를 발행 하시겠습니까?
		       		if(result){
						me.expAppRev_callMakeSlipAjax(obj);
		       		}
		        });
			},
			
			expAppRev_callMakeSlipAjax : function(obj){

				var me = this;
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/makeSlip.do",
					data:{
						"obj"	: JSON.stringify(obj),
					},
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.ACC_061'/>");	//전표 발행을 완료하였습니다.
							me.expAppRev_searchExpenceApplicationList();
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			

			expAppRev_refresh : function(){
				accountCtrl.pageRefresh();
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.expAppRev_searchExpenceApplicationList();
				}
			},
			// 더존 icube 엑셀다운
			expAppRev_icubeDuzonExcel : function(){
				var isNew		= "Y";
				var popupID		= "icubeDuzonPopup";
				var openerID	= "icubeDuzonPopup";
				var popupTit	= "<spring:message code='Cache.ACC_icubeDuzonExcel'/>";	//카드신청
				var popupYN		= "N";
				var changeSize	= "ChangePopupSize";
				var callBack	= "CardApplicationUserPopup_CallBack";
				var popupUrl	= "/account/expenceApplication/callicubeDuzonePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "changeSizeFunc="		+ ""				+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "isNew="			+ isNew;
				Common.open(	"",popupID,popupTit,popupUrl,"500px","700px","iframe",true,null,null,true);
			}
	}
	window.ExpenceApplicationReview = ExpenceApplicationReview;
})(window);

</script>