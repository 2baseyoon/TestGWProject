<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="java.util.Properties" %>
<%
	Properties accountProperties = PropertiesUtil.getExtensionProperties();
	String isUseBizMnt  = accountProperties.getProperty("isUse.bizMnt");
%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input id="requestType"	type="hidden" />
	<input id="appType" type="hidden" />
	
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:1180px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">					
					<table class="total_acooungting_table2 tableStyle" name="SelfDevelopArea" style="display:none; margin-top: 20px;">
						<tr>
							<td class="th"><spring:message code='Cache.ACC_lbl_division'/></td> <!-- 구분 -->
							<td class="th"><spring:message code='Cache.ACC_lbl_budgetAmount'/></td> <!-- 부여금액 -->
							<td class="th"><spring:message code='Cache.ACC_lbl_UsedAmt'/></td> <!-- 사용금액 -->
							<td class="th"><spring:message code='Cache.ACC_lbl_remainAmt'/></td> <!-- 잔여금액 -->
						</tr>
						<tbody id="selfDevelopTBODY">
						</tbody>
						<tr>
							<td class="th"><span id="fiscalYear" tag="FiscalYear"></span><spring:message code='Cache.lbl_year'/> <spring:message code='Cache.lbl_sum'/></td> <!-- n년 합계 -->
							<td id="totalBudgetAmt" style="text-align:right;"></td>
							<td id="totalUsedAmt" style="text-align:right;"></td>
							<td id="totalRemainAmt" style="text-align:right;"></td>
						</tr>
					</table>
					
					<table class="total_acooungting_table2 tableStyle" name="BizTripArea" style="display:none; margin-top: 20px;">
						<tbody>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_projectName'/></td> <!-- 프로젝트명 -->
									<td tag="ProjectName" name="BizTripField"></td>
									<td class="th"><spring:message code='Cache.ACC_lbl_executivePlan'/></td> <!-- 집행계획서 -->
									<td>
										<a href="#" onclick="ApplicationDetailPopup.bizTripExecLinkOpen()" tag="ExecDocSubject" name="BizTripField"></a>
										<input type="hidden" tag="ExecProcessID" name="BizTripField" />
									</td>
								</tr>         
						</tbody>
					</table>
						
					<table class="total_acooungting_table2 tableStyle" name="BizTripArea" style="display:none; margin-top: 20px;">
						<tbody>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_dept'/></td> <!-- 부서 -->
									<td colspan="2" style="width: 550px;" tag="RequesterDeptName" name="BizTripField"></td>
									<td class="th"><spring:message code='Cache.lbl_name'/></td> <!-- 이름 -->
									<td tag="RequesterName" name="BizTripField"></td>
								</tr>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_bizTripTerm'/></td> <!-- 출장기간 -->
									<td>
										<label tag="StartDate" name="BizTripField"></label> ~ <label tag="EndDate" name="BizTripField"></label>
										<label>(</label><label tag="BusinessDay" name="BizTripField"></label><label><spring:message code='Cache.ACC_lbl_day'/>)</label>
									</td>
									<td>
										<label><spring:message code='Cache.ACC_lbl_workingDay'/> : </label><label tag="WorkingDay" name="BizTripField"></label><label><spring:message code='Cache.ACC_lbl_day'/></label>
									</td>
									<td class="th"><spring:message code='Cache.ACC_lbl_bizTripPlace'/></td> <!-- 출장지 -->
									<td tag="BusinessArea" name="BizTripField"></td>
								</tr>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_bizTripPurpose'/></td> <!-- 출장목적 -->
									<td colspan="4" tag="BusinessPurpose" name="BizTripField"></td>
								</tr>         
						</tbody>
					</table>
						
					<table class="total_acooungting_table2 tableStyle" name="OverseaArea" style="display:none; margin-top: 20px;">
						<tbody>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_exchangeRate'/></td> <!-- 환율 -->
									<td></td>
								</tr>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_standard'/><spring:message code='Cache.ACC_lbl_foreignCurrency'/></td> <!-- 기준통화 -->
									<td></td>
								</tr>         
						</tbody>
					</table>
						
					<p class="taw_top_sub_title" name="BizTripArea" style="display:none;"> <!-- 출장비 내역 -->
						<spring:message code='Cache.ACC_lbl_bizTripExpenceList'/>
					</p>
					<span style="position: absolute;font-size: 12px;right: 20px;line-height: 0px; display: none;" name="BizTripArea">
						<span class="txt_send_r">*</span> &nbsp;<spring:message code='Cache.ACC_msg_checkDailyListByPopup'/>
					</span>
					<table class="total_acooungting_table2"  id="BizTripList" name="BizTripArea" style="display:none; margin-top: 20px; font-size: 13px;">
						<thead>
							<tr>
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_bizTripDate'/></td> <!-- 출장일자 -->
								<td class="th" style="width: auto;"field="Daily" 	><spring:message code='Cache.ACC_lbl_dailyExpence'/></td> <!-- 일비 -->
								<td class="th" style="width: auto;"field="Food" 	><spring:message code='Cache.ACC_lbl_foodExpence'/></td> <!-- 식비 -->
								<td class="th" style="width: auto;"field="Room" 	><spring:message code='Cache.ACC_lbl_roomExpence'/></td> <!-- 숙박비 -->
								<td class="th" style="width: auto;"field="Taxi" 	><spring:message code='Cache.ACC_lbl_taxiExpence'/></td> <!-- 택시비 -->
								<td class="th" style="width: auto;"field="Public" 	><spring:message code='Cache.ACC_lbl_publicExpence'/></td> <!-- 버스지하철 -->
								<td class="th" style="width: auto;"field="Airplain" ><spring:message code='Cache.ACC_lbl_airplainExpence'/></td> <!-- 항공철도 -->
								<td class="th" style="width: auto;"field="Fuel" 	><spring:message code='Cache.ACC_lbl_fuelExpence'/></td> <!-- 유류비 -->
								<td class="th" style="width: auto;"field="Toll" 	><spring:message code='Cache.ACC_lbl_tollExpence'/></td> <!-- 통행료 -->
								<td class="th" style="width: auto;"field="Etc" 		><spring:message code='Cache.lbl_Etc'/></td> <!-- 기타 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_daySum'/></td> <!-- 일계 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_description'/></td> <!-- 비고 -->
							</tr>
						</thead>
						<tbody>
						</tbody>
						<tfoot>
							<tr>
								<td class="th"><spring:message code='Cache.ACC_lbl_itemSum'/></td> <!-- 항목합계 -->
								<td style="padding-right:5px;" align="right" field="Daily" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Food" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Room" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Taxi" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Public" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Airplain" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Fuel" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Toll" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" field="Etc" type="CostSum"></td>
								<td style="padding-right:5px;" align="right" type="TotalSum"></td>
								<td></td>
							</tr>     
						</tfoot>
					</table>
					
					<p class="taw_top_sub_title" name="BizTripArea" style="display:none;"> <!-- 유류비 내역 -->
						<spring:message code='Cache.ACC_lbl_fuelExpenceList'/>
					</p>
					<table class="total_acooungting_table2"  id="FuelList" name="BizTripArea" style="display:none; margin-top: 20px; font-size: 13px;">
						<thead>
							<tr>
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_bizTripDate'/></td> <!-- 출장일자 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_startPoint'/></td> <!-- 출발지 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_endPoint'/></td> <!-- 도착지 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelType'/></td> <!-- 유류타입 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_distance'/>(km)</td> <!-- 이동거리 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelUnitPrice'/></td> <!-- 유류단가 -->
								<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelRealPrice'/></td> <!-- 유류실비 -->
							</tr>
						</thead>
						<tbody>
						</tbody>
						<tfoot>
							<tr>
								<td class="th" colspan="6"><spring:message code='Cache.ACC_lbl_itemSum'/></td> <!-- 항목합계 -->
								<td type="TotalSum"></td>
							</tr>     
						</tfoot>
					</table>
				</div>
				<div class="bottom">
					<a onclick="ApplicationDetailPopup.closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.ApplicationDetailPopup) {
		window.ApplicationDetailPopup = {};
	}
	
	(function(window) {		
		var appType = "";
		var requestType = "";
		var ApplicationDetailPopup = {
				funcPrefix : "",
				parentApp : {},
				
				pageDetailFormList : {
					BizTripExpenceListViewFormStr : "",
					FuelExpenceListViewFormStr : ""
				},
				
				popupInit : function() {
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.getPopupInfo();
				},
				
				getPopupInfo : function(){
					var me = this;

					appType = $("#appType").val();
					requestType = $("#requestType").val();
					
					me.getParentInfo();
					
					if(requestType == "SELFDEVELOP") {
						//잔여예산 정보 가져오기
						me.getBudgetInfo();
					} else if(requestType == "BIZTRIP" || requestType == "OVERSEA") {	
						//출장비/유류비 내역 form string 가져오기
						me.bizTripFormInit();

						$("[name=BizTripArea]").show();
						
						if(requestType == "OVERSEA") {
							$("[name=OverseaArea]").show();
						}

						//출장신청서 정보 가져오기
						me.setBizTripRequestInfo(me.parentApp.openParam.BizTripRequestID);
						//유류비 내역 가져오기
						me.loadFuelExpenceList();	 
						//출장비 내역 가져오기
						me.loadBizTripExpenceList();
					}
				},
				
				getParentInfo : function() {
					var me = this;

					me.parentApp = parent[appType+requestType];
					
					switch(appType) {
					case "SimpleApplication":
						me.funcPrefix = "simpApp_";
						me.appData = me.parentApp.pageExpenceAppData;
						break;
					case "CombineCostApplication":
						me.funcPrefix = "combiCostApp_";
						me.appData = me.parentApp.pageExpenceAppObj;
						break;
					default:
						break;
					}
				},
				
				//잔여예산 정보 가져오기
				getBudgetInfo : function() {
					var me = this;
					
					var itemArr = parent.accComm[requestType].pageExpenceFormInfo.StandardBriefInfo[0].item;
					var itemStr = "";
					for(var i = 0; i < itemArr.length; i++) {
						itemStr += itemArr[i];
						if(i != itemArr.length-1)
							 itemStr += ",";
					}
					
					var date = new Date(CFN_TransServerTime(CFN_GetLocalCurrentDate(), "", Common.getSession("UR_TimeZone")));
					date.setDate(date.getDate() + Number(Common.getBaseConfig("BudgetControlDate")));	//10일전 데이타로 예산조회 
					var useDate = date.format("yyyy.MM.dd");
					
					var userID = me.appData.RegisterID != undefined ? me.appData.RegisterID : Common.getSession("USERID"); 
					
					$.ajax({
						type:"POST",
						url:"/account/budget/getBudgetInfo.do",
						cache:false,
						async:false,
						data:{
							CostCenter : userID,
							UseDate : useDate,
							StandardBriefIDs : itemStr // AccountCodes
						},
						success:function (data) {
							if(data.result == "ok"){
								var data = data.list;
								if(data != null && data.length > 0){
									$("#fiscalYear").html(data[0].FiscalYear);
									var htmlStr = "";
									var totalBudgetAmt = totalUsedAmt = totalRemainAmt = 0;
									$(data).each(function(i, obj) {
										var budgetAmt = (isNaN(obj.BudgetAmount) || obj.BudgetAmount == "") ? 0 : obj.BudgetAmount;
										var usedAmt = (isNaN(obj.UsedAmount) || obj.UsedAmount == "") ? 0 : obj.UsedAmount;
										var remainAmt = budgetAmt - usedAmt;
										
										htmlStr += "<tr>";
										htmlStr += "<td class='th'>" + obj.StandardBriefName + "</td>";
										htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(budgetAmt) + "</td>";
										htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(usedAmt) + "</td>";
										htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(remainAmt) + "</td>";
										htmlStr += "</tr>";
										
										totalBudgetAmt += budgetAmt;
										totalUsedAmt += usedAmt;
										totalRemainAmt += remainAmt;
									});
									$("#selfDevelopTBODY").html(htmlStr);
									$("#totalBudgetAmt").html(toAmtFormat(totalBudgetAmt));
									$("#totalUsedAmt").html(toAmtFormat(totalUsedAmt));
									$("#totalRemainAmt").html(toAmtFormat(totalRemainAmt));
									
									$("[name=SelfDevelopArea]").show();
								}
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				},
				
				setFieldList : function(fieldList, isSet, isInit, pageInfo) {
					for(var i = 0; i<fieldList.length; i++){
						var field = fieldList[i];
						var tag = field.getAttribute("tag");
						var fieldType = field.tagName;
						
						if(isSet) { //필드에 값 세팅
							if(fieldType=="INPUT"){
								field.value = (isInit ? "" : nullToBlank(typeof(pageInfo[tag])=="object" ? JSON.stringify(pageInfo[tag]) : pageInfo[tag]));
							} else if(fieldType=="LABEL" || fieldType=="TD" || fieldType=="A"){
								field.innerHTML = (isInit ? "" : nullToBlank(pageInfo[tag]));
							} else if(fieldType=="SELECT"){
								$(field).val((isInit ? "" : nullToBlank(pageInfo[tag])));
							}
						} else { //json에 값 저장
							if(fieldType=="INPUT"){
								pageInfo[tag] = (isInit ? "" : field.value);
							} else if(fieldType=="LABEL" || fieldType=="TD" || fieldType=="A"){
								pageInfo[tag] = (isInit ? "" : field.innerHTML);
							} else if(fieldType=="SELECT"){
								pageInfo[tag] = (isInit ? "" : $(field).val());
							}
						}
					}
				},
				
				bizTripExecLinkOpen : function() {
					var me = this;
					
					me.parentApp[me.funcPrefix+"LinkOpen"]($("[name=BizTripField][tag=ExecProcessID]").val());
				},
				
				//////////////////// 출장신청서 ////////////////////
								
				bizTripFormInit : function() {
					var me = this;
					var formPath = Common.getBaseConfig("AccountApplicationFormPath");

					$.ajaxSetup({async:false});
					
					$.get(formPath + "ExpAppViewForm_BizTripList.html" + resourceVersion, function(val){
						me.pageDetailFormList.BizTripExpenceListViewFormStr = val;
					});
					$.get(formPath + "ExpAppViewForm_FuelList.html" + resourceVersion, function(val){
						me.pageDetailFormList.FuelExpenceListViewFormStr = val;
					});
				},
				
				//출장신청서 정보 가져오기
				setBizTripRequestInfo : function(BizTripRequestID) {
					var me = this;
					
					$.ajax({
						type:"POST",
						url:"/account/bizTrip/getBizTripRequestInfo.do",
						async: false,
						cache: false,
						data:{
							bizTripRequestID : BizTripRequestID
						},
						success:function (data) {
							if(data.result == "ok"){
								var getData = data.data;
								if(getData != null){
									if(getData.BizTripType != "P") { //프로젝트 출장이 아닐 경우
										$("[name=BizTripField][tag=ProjectName]").parents("table").hide();
									} else {
										me.getExecPlan(getData.ProjectCode); //집행계획서 연결
									}
									
									me.setFieldList($("[name=BizTripField]"), true, false, getData);
								}
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				},
				
				//출장신청서 프로젝트 집행계획서 가져오기
				getExecPlan : function(prjCode) {
					var me = this;
					
					if("<%=isUseBizMnt%>" == "Y") {
						$.ajax({
							type:"POST",
							url:"/bizmnt/approval/searchProcessIdOfExecplan.do",
							async: false,
							cache: false,
							data:{
								projectCd : prjCode
							},
							success:function (data) {
								var jsonObj = {};
								if(data.status == "SUCCESS"){
									jsonObj.ExecProcessID = data.processId;
									jsonObj.ExecDocSubject = data.DocSubject;
								}
								else{
									jsonObj.ExecProcessID = "";
									jsonObj.ExecDocSubject = "";
								}
								me.setFieldList($("[name=BizTripField]"), true, false, jsonObj);
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
							}
						});
					}
				},

				//////////////////// 출장비 내역 ////////////////////
				
				//출장비 내역 가져오기
				loadBizTripExpenceList : function() {
					var me = this;
					
					//초기화
					me.initBizTripExpenceList();
					
					var pageEvidList = [];
					if(appType == "CombineCostApplication") {
						pageEvidList = me.parentApp.pageExpenceAppEvidList;
					} else {
						pageEvidList = me.parentApp.pageExpenceAppCorpCardList.concat(me.parentApp.pageExpenceAppEtcEvidList).concat(me.parentApp.pageExpenceAppReceiptList);
					}
					
					pageEvidList.sort(function(a, b) {
					    return parseInt(a.ProofDateStr.replace(/\./gi, '')) - parseInt(b.ProofDateStr.replace(/\./gi, ''))
					});
					
					for(var i=0; i<pageEvidList.length; i++){
						var row = pageEvidList[i];
						if(row.divList != null){
							$.extend(row, row.divList[0]);
						}

						if(!row.ReservedStr3_Div==undefined||$.isEmptyObject(row.ReservedStr3_Div)||!row.ReservedStr3_Div.hasOwnProperty('D01'))
							continue;
						
						var BizTripItem = row.ReservedStr3_Div['D01'];
						 
						var ProofDateStr = row.ProofDateStr;
						var Amount = toAmtFormat(row.Amount);
						
						if(isEmptyStr(ProofDateStr))
							return;
						
						me.makeBizTripExpenceList(BizTripItem, ProofDateStr, Amount);
					}
					 
					//합계
					me.sumBizTripExpenceList();
					
					//식비는 사용 안함
					$("[field=Food]").hide();
				},

				//출장비 내역 초기화
				initBizTripExpenceList : function(){
					var me = this;
					
					//비고 백업
					me.BizTripNoteMap = {};
					if(me.appData.BizTripNoteMap != undefined && me.appData.BizTripNoteMap != "undefined") {
						if(typeof(me.appData.BizTripNoteMap) != "string") {
							me.BizTripNoteMap = me.appData.BizTripNoteMap;
						} else {
							me.BizTripNoteMap = JSON.parse(decodeURI(me.appData.BizTripNoteMap));
						}
					}
					
					$('#BizTripList').find("tbody > tr").each(function(index) {					
						var BizTripDate = $(this).find("td[field=BizTripDate]").text();
						var Note = $(this).find("td[field=Note]").find("textarea").val();
						me.BizTripNoteMap[BizTripDate] = Note;
					});
					$('#BizTripList').find("tbody > tr").remove();
					$('#BizTripList').find("td[type=CostSum]").text("0");
					$('#BizTripList').find("td[type=TotalSum]").text("0");
				},
				
				//출장비 내역 만들기
				makeBizTripExpenceList : function(BizTripItem, ProofDateStr, Amount){
					var me = this;
					var targetTr = $('#BizTripList').find("tr[proofdate=" + ProofDateStr.replace(/\./gi, '') + "]");
					
					if(BizTripItem=='')
						return;
					
					//기존에 추가된 tr이 없을 경우
					if(targetTr.length == 0) {
						
						//출장비 내역 양식
						var valMap = {
							BizTripDateStr : nullToBlank(ProofDateStr),
							BizTripDate : nullToBlank(ProofDateStr).replace(/\./gi, ''),
							RequestType : requestType
						};
						
						var html = me.pageDetailFormList.BizTripExpenceListViewFormStr;
						html = me.parentApp[me.funcPrefix+"htmlFormSetVal"](html, valMap);
						html = me.parentApp[me.funcPrefix+"htmlFormDicTrans"](html);
						
						$('#BizTripList').find("tbody").append(html);
						
						//tr 추가 후 다시 targeting
						targetTr = $('#BizTripList').find("tr[proofdate=" + ProofDateStr.replace(/\./gi, '') + "]");
					}
					
					var obj = targetTr.find("td[field="+BizTripItem+"]");
					
					var amountSum = Amount;
					if(obj == null || obj == undefined) {
						amountSum = 0;
					} else {
						if(!isEmptyStr(obj.text())) {
							if($.isNumeric(AmttoNumFormat(obj.text()))) {
								amountSum = Number(AmttoNumFormat(obj.text())) +  Number(AmttoNumFormat(Amount));
							}
						}
						obj.text(toAmtFormat(amountSum));
					}
					
					//td의 type요소가 cost인것 합해서 일계처리
					var daySum = 0;
					targetTr.find("td[type=Cost]").each(function() {
						if(!isEmptyStr($(this).text())) {
						 
							if($.isNumeric(AmttoNumFormat($(this).text()))) {
								daySum += Number(AmttoNumFormat($(this).text()));
							}
						}
					});
					targetTr.find("td[field=DaySum]").text(toAmtFormat(daySum));

					var note = me.BizTripNoteMap[ProofDateStr];
					if(!isEmptyStr(note)) {
						targetTr.find("td[field=Note]").find("textarea").val(note);
					}
				},
				
				//출장비 내역 합계
				sumBizTripExpenceList : function(){
					//초기화
					$('#BizTripList').find("td[type=CostSum]").text("0");
					$('#BizTripList').find("td[type=TotalSum]").text("0");
					
					//td의 type요소가 cost인것 합해서 항목계처리
					$('#BizTripList').find("td[type=Cost]").each(function() {
						var field = $(this).attr("field");
						var sumTd = $('#BizTripList').find("td[type=CostSum][field="+field+"]");
						
						var sumValue = 0;
						sumValue = Number(AmttoNumFormat($(this).text()));
						
						if($.isNumeric(AmttoNumFormat(sumTd.text()))) {
							var sumTotal = Number(AmttoNumFormat(sumTd.text())) + sumValue;
							sumTd.text(toAmtFormat(sumTotal));
						}
					});
					
					//일계 합해서 항목계처리
					var sumTotal = 0;
					$('#BizTripList').find("td[field=DaySum]").each(function() {
						if($.isNumeric(AmttoNumFormat($(this).text()))) {
							sumTotal += Number(AmttoNumFormat($(this).text()));
						}
					});
					$('#BizTripList').find("td[type=TotalSum]").text(toAmtFormat(sumTotal));
				},
				
				onNoteChange : function(obj, ProofDate) {
					var me = this;
					me.BizTripNoteMap[ProofDate] = $(obj).val();
					
					me.appData.BizTripNoteMap = me.BizTripNoteMap;
				},		
				
				//////////////////// 유류비 내역 ////////////////////
				
				//유류비 내역 가져오기
				loadFuelExpenceList : function(){
					var me = this;
					
					//초기화
					me.initFuelExpenceList();
					
					var pageEvidList = appType == "CombineCostApplication" ? me.parentApp.pageExpenceAppEvidList : me.parentApp.pageExpenceAppEtcEvidList;
										
					for(var i = 0; i<pageEvidList.length; i++){
						var row = pageEvidList[i];
						if(row.divList != null){
							$.extend(row, row.divList[0]);
						}
						
						me.makeFuelExpenceList(row);
					}
					 
				},
				//유류비 내역 초기화
				initFuelExpenceList : function(){
					var me = this;
					$('#FuelList').find("tbody > tr").remove();
					$('#FuelList').find("td[type=TotalSum]").text("0");
				},
				
				//유류비 내역 만들기
				makeFuelExpenceList : function(list){
					var me = this;
					
					var keyno = list.ViewKeyNo;

					if(!list.ReservedStr3_Div==undefined||$.isEmptyObject(list.ReservedStr3_Div)||!list.ReservedStr3_Div.hasOwnProperty('D02'))
						return;
					
					var list = list.ReservedStr3_Div['D02'];
					if(list==undefined || list.length==0)
						return;

					if(typeof list =='string') {
						list = JSON.parse(list);
						list = list['FuelExpenceAppEvidList']
						if(list==undefined || list.length==0)
							return;
				  	} else {
						list = list['FuelExpenceAppEvidList'];
					}
				
					for(var i=0; i<list.length; i++) {
						var item = list[i];
						
						//유류비 내역 양식
						var valMap = {
							ProofCode : item.ProofCode,
							KeyNo : item.KeyNo,
							BizTripDateStr : item.BizTripDateStr,
							BizTripDate : item.BizTripDate,
							StartPoint : item.StartPoint,
							EndPoint : item.EndPoint,
							Distance : item.Distance,
							FuelType : item.FuelType,
							FuelTypeNM : item.FuelTypeNM,
							FuelUnitPrice : toAmtFormat(item.FuelUnitPrice),
							FuelRealPrice : toAmtFormat(item.FuelRealPrice)
						};
						
						var html = me.pageDetailFormList.FuelExpenceListViewFormStr;
						html = me.parentApp[me.funcPrefix+"htmlFormSetVal"](html, valMap);
						html = me.parentApp[me.funcPrefix+"htmlFormDicTrans"](html);

						$('#FuelList').find("tbody").append(html);
					}
					
					//재정렬
					var list = $('#FuelList').find("tbody > tr");
					for(var i=0; i<list.length; i++) {
						for(var j=0; j<(list.length-1)-i; j++) {
							if($(list).eq(j).find("td[field=BizTripDate]").text().replace(/./, '') > $(list).eq(j+1).find("td[field=BizTripDate]").text().replace(/./, ''))
							{
								var html1 = $(list).eq(j)[0].outerHTML;
								var html2 = $(list).eq(j+1)[0].outerHTML;

								$(list).eq(j).replaceWith(html2);
								$(list).eq(j+1).replaceWith(html1);
					        }
					    }
					}
					
					//합계
					me.sumFuelExpenceList();
				},
				
				//유류비 내역 합계
				sumFuelExpenceList : function(){
					//유류비
					$('#FuelList').find("td[type=TotalSum]").text("0");
					var RealPriceTotal = 0;
					$('#FuelList').find("td[field=FuelRealPrice]").each(function() {
						if($.isNumeric(AmttoNumFormat($(this).text()))) {
							RealPriceTotal += Number(AmttoNumFormat($(this).text()));
						}
					});
					$('#FuelList').find("td[type=TotalSum]").text(toAmtFormat(RealPriceTotal));
				},
				
				closeLayer : function() {
					var me = this;
					
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.ApplicationDetailPopup = ApplicationDetailPopup;
	})(window);

	ApplicationDetailPopup.popupInit();
</script>