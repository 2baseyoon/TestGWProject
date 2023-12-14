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
					<!-- 새로고침 -->
					<a class="btnTypeDefault" href="#" onclick="accountCtrl.pageRefresh();"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="CapitalSummary.cptSum_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 출력 -->
					<a class="btnTypeDefault" href="#" onclick="CapitalSummary.cptSum_print();"><spring:message code="Cache.btn_print"/></a>
				</div>				
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- 검색영역 시작 -->
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="cptSum_companyCode" class="selectType02" name="searchParam" tag="CompanyCode">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 자금집행일 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_realPayDate"/></span>
							<div id="cptSum_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="cptSum_dateArea_St" edfield="cptSum_dateArea_Ed" 
								stdatafield="RealPayDateSt" eddatafield="RealPayDateEd">
							</div>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="CapitalSummary.cptSum_searchCapitalSummaryList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- 검색영역 끝 -->
			<!-- 우측버튼 영역 시작 -->
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">
					<button class="btnRefresh" type="button" onclick="CapitalSummary.cptSum_searchCapitalSummaryList();"></button>
				</div>
			</div>
			<!-- 우측버튼 영역 끝 -->
			<!-- 출력영역 시작 -->
			<div class="eaccountingPrintCont" style="margin: 25px 25px 10px; font-size: 13px; display: none;">
    			<div style="text-align: center;"><spring:message code="Cache.ACC_lbl_realPayDate"/> <span id="cptSum_realPayDateSt"></span> ~ <span id="cptSum_realPayDateEd"></span></div>
				<div style="margin-top: 30px;">
				    <span><spring:message code="Cache.ACC_lbl_companyName"/> : <span id="cptSum_companyName"></span></span>
				    <span style="float: right"><spring:message code="Cache.ACC_lbl_unitWon"/></span>
				</div>
			</div>
			<!-- 출력영역 끝 -->
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="cptSumListGrid"></div>
			</div>
			
			<div name="hiddenLinkArea" ></div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.CapitalSummary) {
	window.CapitalSummary = {};
}

(function(window) {
	
	var CapitalSummary = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function() {
				var me = this;
				
				setHeaderTitle('headerTitle');
				
				me.cptSum_comboInit();
				makeDatepicker('cptSum_dateArea', 'cptSum_dateArea_St', 'cptSum_dateArea_Ed', null, null, 100);

				me.cptSum_gridInit();		
			},

			pageView : function() {
				var me = this;				
				me.cptSum_comboRefresh();
				me.cptSum_searchCapitalSummaryList();
			},
			
			cptSum_comboInit : function() {
				var me = this;
				accountCtrl.renderAXSelect('CompanyCode', 'cptSum_companyCode', 'ko', '', '', '', "<spring:message code='Cache.ACC_lbl_comboAll' />");
			},
			
			cptSum_comboRefresh : function() {
				var me = this;
				accountCtrl.refreshAXSelect('cptSum_companyCode');
			},

			cptSum_gridInit : function() {
				var me = this;
				me.cptSum_searchCapitalSummaryList();
			},

			cptSum_gridHeaderInit : function() {
				var me = this;
				me.params.headerData = [
										//{	key:'chk',			label:'chk',		width:'30', align:'center',	formatter:'checkbox'	},
										{	key:'RealPayDate',	label:"<spring:message code='Cache.ACC_lbl_realPayDate'/>",	width:'150', align:'center', //자금집행일
											formatter:function() {
												var str = this.item.RealPayDate;
												if(str != "TOTAL") {
													str = "<a onclick='CapitalSummary.cptSum_openCapitalDoc(this, \""+this.item.ProcessId+"\", \""+this.item.FormInstID+"\", \""+this.item.Subject+"\"); return false;'>"+this.item.RealPayDate+"</a>"
												}
												return str;
											}
										}, 
										{	key:'A_Sum',			label:"자동이체",		width:'100', align:'right'	},
										{	key:'D_Sum',			label:"일반이체",		width:'100', align:'right'	},
										{	key:'C_Sum',			label:"법인카드",		width:'100', align:'right'	},
										{	key:'G_Sum',			label:"현금인출",		width:'100', align:'right'	},
										{	key:'T_Sum',			label:"계좌간이체",	width:'100', align:'right'	},
										{	key:'TotalSum',			label:"지출통계",		width:'150', align:'right'	}
				]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			cptSum_getSearchParams : function() {
				var me = this;
				var searchInputList = accountCtrl.getInfoName("searchParam");
				var retVal = {};
				for(var i=0; i<searchInputList.length; i++){
					var item = searchInputList[i];
					if(item != null){
						var fieldType = item.getAttribute("fieldtype");
						if(item.tagName == 'DIV' && fieldType == 'Date'){
							var stField = item.getAttribute("stfield");
							var edField = item.getAttribute("edfield");								
							var stDataField = item.getAttribute("stdatafield");
							var edDataField = item.getAttribute("eddatafield");
							
							var stVal = accountCtrl.getInfo(stField).val();
							var edVal = accountCtrl.getInfo(edField).val();
							stVal = stVal.replaceAll(".", "");
							edVal = edVal.replaceAll(".", "");
							
							retVal[stDataField] = stVal;
							retVal[edDataField] = edVal;
						}else{
							if(fieldType == "Amt"){
								retVal[item.getAttribute("tag")] = AmttoNumFormat(item.value);
							}else{
								retVal[item.getAttribute("tag")] = item.value;
							}
						}
					}
				}
				return retVal;
			},
			
			//조회
			cptSum_searchCapitalSummaryList : function(YN) {
				var me = this;

				var searchParam = me.cptSum_getSearchParams();
				
				me.cptSum_gridHeaderInit();
								
				var gridAreaID		= "cptSumListGrid";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;				
				var ajaxUrl			= "/account/expenceApplication/searchCapitalSummary.do";
				var ajaxPars		= {
										"searchParam" : JSON.stringify(searchParam)
									}
				
				var pageSizeInfo	= 200;
				var pageNoInfo		= 1;
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								, 	"callback"		: me.cptSum_searchCallback
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			},

			//조회 후처리
			cptSum_searchCallback : function() {
				var me = window.CapitalSummary;
				accountCtrl.getInfo("cptSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr>td>div:contains('TOTAL')").parents("tr").find("td").css("font-weight", "bold");
				accountCtrl.getInfo("cptSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr>td>div:contains('TOTAL')").parents("tr").find("td").css("background-color", "rgb(220, 248, 255)");
			},
			
			//엑셀 다운로드
			cptSum_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
						var searchParam 	= me.cptSum_getSearchParams();
						var title 			= accountCtrl.getInfo("headerTitle").text();
						var	locationStr		= "/account/expenceApplication/excelDownloadCapitalSummary.do?"
											//+ "headerName="			+ encodeURIComponent(nullToBlank(headerName))
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="			+ encodeURIComponent(nullToBlank(headerKey))
											+ "&RealPayDateSt="		+ encodeURIComponent(nullToBlank(searchParam.RealPayDateSt))
											+ "&RealPayDateEd="		+ encodeURIComponent(nullToBlank(searchParam.RealPayDateEd))
											//+ "&title="				+ encodeURIComponent(accountCtrl.getInfo("headerTitle").text());
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title)); 
					
						location.href = locationStr;
			       	}
				});
			},
			
			cptSum_print : function() {
				var me = this;

			    var sBodyHTML = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=EUC-KR'><style>";
				
			    var strBodyTable = accountCtrl.getInfoStr(".eaccountingCont").parents("div.accountContent").clone();
				
				$(strBodyTable).find(".eaccountingTopCont").hide();
				$(strBodyTable).find(".bodysearch_Type01").hide();
				$(strBodyTable).find(".inPerTitbox").hide();
				$(strBodyTable).find(".AXgridPageBody").hide();
				$(strBodyTable).find(".cRConTop").css("border-bottom", "none").css("text-align", "center");
				$(strBodyTable).find(".cRContBottom").css("overflow", "hidden");
				
				$(strBodyTable).find("#cptSum_realPayDateSt").html(accountCtrl.getInfo("cptSum_dateArea_St").val());
				$(strBodyTable).find("#cptSum_realPayDateEd").html(accountCtrl.getInfo("cptSum_dateArea_Ed").val());
				$(strBodyTable).find("#cptSum_companyName").html(accountCtrl.getComboInfo("cptSum_companyCode").find("option:selected").text());
				$(strBodyTable).find(".eaccountingPrintCont").show();
				
		        /* for (var i = 0; i < document.styleSheets.length; i++) {
		            if (document.styleSheets[i].href != null) {
		                if (navigator.userAgent.match(/MSIE ([0-9]+)\./) == true && parseFloat(RegExp.$1) <= 8) //ie8 이하일때
		                    sBodyHTML += getStyle(document.styleSheets[i].href, i);
		                else
		                    sBodyHTML += getStyleChrome(document.styleSheets[i]);
		            }
		        } */
		        
		        sBodyHTML += "</style></head><body topmargin='0' leftmargin='0' scroll='auto' align='center' class='approval_form'>" + strBodyTable.html() + "</body></html>";
		        
		        printDiv = sBodyHTML;

		        var iWidth = 1000, iHeight = 700;
			    if (_ie) {
			        iWidth = 100; iHeight = 100;
			    }
		        
                CFN_OpenWindow("/approval/form/Print.do", "", iWidth, iHeight, null);
			},
			
			cptSum_openCapitalDoc : function(pObj, strProcessID, strFormInstID, strSubject) {
				var me = this;
				var arrProcessID = strProcessID.split(",");
				var arrFormInstID = strFormInstID.split(",");
				var arrSubject = strSubject.split("^^^");
				
				if(arrProcessID.length > 1) {			
					if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
						$(pObj).parent().find('.file_box').remove();
						$(pObj).parent().css("overflow", "hidden");
						return false;
					}
					
					$('.file_box').remove();

					var vHtml = "<ul class='file_box' style='right:auto;top:30px;width:250px;'><li class='boxPoint' style='right:190px;'></li>";
					for(var i=0; i<arrProcessID.length; i++){
						vHtml += "<li style='width: auto;'><a onclick='CapitalSummary.cptSum_openDoc(\""+arrProcessID[i]+"\", \""+arrFormInstID[i]+"\")'>"+arrSubject[i]+"</a></li>";
					}
					vHtml += "</ul>";
					$(pObj).parent().append(vHtml);
					$(pObj).parent().css("overflow", "visible");
					
				} else {
					me.cptSum_openDoc(strProcessID, strFormInstID);					
				}
			},
			
			cptSum_openDoc : function(processID, forminstanceID) {
				CFN_OpenWindow('/approval/approval_Form.do?mode=COMPLETE&processID='+processID+'&forminstanceID='+forminstanceID,'',1070, (window.screen.height - 100), 'scroll');
			}
	}
	window.CapitalSummary = CapitalSummary;
})(window);

var printDiv;
//ie8을 제외한 ie9, ie10, chrome등에서 현재페이지에서 사용하는 스타일 가져오기 
function getStyleChrome(sheet) {
  var style = "";
  var rules = sheet.rules || sheet.cssRules;
  for (var r = 0; r < rules.length; r++) {
      style += rules[r].cssText;
  }
  return style;
}

function getStyle(sURL, index) {
  var objStyle = "";
  if (document.styleSheets[index].cssText != null) {
      objStyle += document.styleSheets[index].cssText
  }
  return objStyle.replace("undefined", "");
}
	
</script>