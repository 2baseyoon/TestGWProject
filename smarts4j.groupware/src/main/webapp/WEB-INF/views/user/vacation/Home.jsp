<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.MN_658' /></h2>						
</div>
<div class="cRContBottom mScrollVH ">
	<div id="contentDiv" class="extensionContent">
		<section class="extensionContTop">
			<article class="cyclePrograssBarCont">
				<h3 id="myVacTxt"></h3>
				<div class="clearFloat">
					<div class="cyclePrograssBar">											
						<div class="cycleCont">			
							<div class="cycleBg">
								<div class="pie"></div>										
							</div>
							<div id="slice" class="">
								<div class="pie" id="pieDiv" style="transform: rotate(36deg);"></div>
								<div class="pie fill"></div>
							</div>
						</div>
						<div class="cycleTxt">
							<p>
								<spring:message code='Cache.lbl_apv_vacation_total_annual' />
							</p>
							<p>
								<span id="myOwnDaysTxt">0</span> days
							</p>
						</div>											
					</div>
				<div style="margin-top:0px;float:right;">
					<div class="extDayInfo" style="float:right;margin-top:0px;margin-right:20px;width: 211px;">
						<p>												
							<span class="nemo blue"></span>
							<span><spring:message code='Cache.lbl_UseVacation' /></span>
							<strong class="days"><span id="myUseDaysTxt">0</span><spring:message code='Cache.lbl_days' /></strong>
						</p>
						<p>
							<span class="nemo gray"></span>
							<span><spring:message code='Cache.lbl_RemainVacation' /></span>
							<strong class="days"><span id="myRemindDaysTxt">0</span><spring:message code='Cache.lbl_days' /></strong>
						</p>
					</div>
					<div id="extraDiv" style="margin-top:110px;width:320px;height:130px;display:none;">
						<table class="tbl tblType02" style="width: 300px;font-size: 11px;">
						<colgroup>
							<col width="70">
							<col width="130">
							<col width="50">
							<col width="50">
						</colgroup>
						<tbody>
							<tr>
								<th class="bg"><spring:message code='Cache.lbl_type'/></th>
								<th class="bg"><spring:message code='Cache.lbl_expiryDate'/></th>
								<th class="bg"><spring:message code='Cache.lbl_apv_Vacation_days'/></th>
								<th class="bg"><spring:message code='Cache.lbl_appjanyu'/></th>
							</tr>
						</tbody>
						</table>
						<div id="extraTable" class="mScrollV scrollVType01 scrollbar" style="width:320px;height:97px;" >
							<table class="tbl tblType02" style="width: 300px;">
							<colgroup>
								<col width="70">
								<col width="130">
								<col width="50">
								<col width="50">
							</colgroup>
							<tbody>
							</tbody>
							</table>
						</div>
					</div>
				</div>
				</div>
			</article>
			<article>
				<div class="extPersonList">
					<h3><spring:message code='Cache.lbl_apv_vacation_user_status' /><span id="deptNameSapn">(<%=SessionHelper.getSession("DEPTNAME")%>)</span></h3>
					<div class="mScrollV scrollVType01" style="overflow:visible;">
						<div id="vacTodayDiv">
						</div>
					</div>
				</div>
			</article>
		</section>
		<section id="defaultVacationPolicy" style="display:none;" class="extensionContMiddle">
			<h3><spring:message code='Cache.lbl_apv_vacation_rule' /></h3>
			<table class="tbl">
				<colgroup>
					<col width="125">
					<col width="130">
					<col width="180">
					<col width="140">
					<col width="304">
				</colgroup>
				<tbody>
					<tr>
						<th rowspan="2"><spring:message code='Cache.lbl_vacationMsg1' /></th>
						<td colspan="4" class="alignLeft">
							<spring:message code='Cache.lbl_vacationMsg2' />
							<br>
							<spring:message code='Cache.lbl_vacationMsg3' />
						</td>
					</tr>
					<tr>
						<td class="bg alignLeft"><spring:message code='Cache.lbl_vacationMsg4' /></td>
						<td colspan="3" class="alignLeft">
							<spring:message code='Cache.lbl_vacationMsg5' />
							<br>
							<spring:message code='Cache.lbl_vacationMsg6' />
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_vacationMsg7' /></th>
						<td colspan="4" class="alignLeft">
							<spring:message code='Cache.lbl_vacationMsg8' />
							<br>
							<spring:message code='Cache.lbl_vacationMsg9' />
						</td>
					</tr>
					<tr>
						<th rowspan="12"><spring:message code='Cache.lbl_apv_condolence' /></th>
						<td colspan="2" class="bg"><spring:message code='Cache.lbl_Gubun' /></td>
						<td class="bg"><spring:message code='Cache.lbl_apv_Vacation_days' /></td>
						<td class="bg"><spring:message code='Cache.lbl_attachedDocument' /></td>
					</tr>
					<tr>
						<td rowspan="3" class="alignLeft"><strong><spring:message code='Cache.lbl_Marriage' /></strong></td>
						<td><strong><spring:message code='Cache.lbl_OneSelf' /></td>
						<td>7<spring:message code='Cache.lbl_days' /></td>
						<td rowspan="3"><spring:message code='Cache.lbl_clearinghouse' /></td>
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_descendant' /></td>
						<td>2<spring:message code='Cache.lbl_days' /></td>
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_brotherssister' /></td>
						<td>1<spring:message code='Cache.lbl_days' /></td>
					</tr>
					<tr>
						<td class="alignLeft"><strong>회갑</strong></td>
						<td><spring:message code='Cache.lbl_vacationMsg10' /></td>
						<td>1<spring:message code='Cache.lbl_days' /></td>
						<td><spring:message code='Cache.lbl_vacationMsg11' /></td>
					</tr>
					<tr>
						<td class="alignLeft"><strong><spring:message code='Cache.lbl_childBirth' /></strong></td>
						<td><spring:message code='Cache.lbl_vacationMsg12' /></td>
						<td>3<spring:message code='Cache.lbl_days' /></td>
						<td></td>
					</tr>
					<tr>
						<td class="alignLeft" rowspan="5"><strong><spring:message code='Cache.lbl_condolence' /></strong></td>
						<td><spring:message code='Cache.lbl_marriagePartner' /></td>
						<td>7<spring:message code='Cache.lbl_days' /></td>
						<td rowspan="5">
							<spring:message code='Cache.lbl_vacationMsg13' />
							<br>
							<spring:message code='Cache.lbl_vacationMsg14' />
						</td>
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_vacationMsg15' /></td>
						<td>7<spring:message code='Cache.lbl_days' /></td>											
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_descendant' /></td>
						<td>5<spring:message code='Cache.lbl_days' /></td>											
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_vacationMsg16' /></td>
						<td>3<spring:message code='Cache.lbl_days' /></td>											
					</tr>
					<tr>											
						<td><spring:message code='Cache.lbl_vacationMsg17' /></td>
						<td>3<spring:message code='Cache.lbl_days' /></td>											
					</tr>		
					<tr>
						<td class="alignLeft" colspan="4">
							<ul class="notiList">
								<li class="noti">
									<spring:message code='Cache.lbl_vacationMsg18' />
								</li>
								<li>
									<spring:message code='Cache.lbl_vacationMsg19' />
								</li>
								<li>												
									 <spring:message code='Cache.lbl_vacationMsg20' />
								</li>
							 </ul>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Etc' /></th>
						<td colspan="4" class="alignLeft"><spring:message code='Cache.lbl_vacationMsg21' /></td>
					</tr>
					<tr>
						<th rowspan="3"><spring:message code='Cache.lbl_apv_other_rules' /></th>
						<td class="alignLeft bg"><spring:message code='Cache.lbl_vocationalTraining' /></td>
						<td class="alignLeft" colspan="3"><spring:message code='Cache.lbl_vacationMsg22' /></td>
					</tr>
					<tr>
						<td class="alignLeft bg"><spring:message code='Cache.lbl_otherThanMaternityLeave' /></td>
						<td class="alignLeft" colspan="3"><spring:message code='Cache.lbl_vacationMsg23' /></td>
					</tr>
					<tr>
						<td class="alignLeft bg"><spring:message code='Cache.lbl_sickLeave' /></td>
						<td class="alignLeft" colspan="3"><spring:message code='Cache.lbl_vacationMsg24' /></td>
					</tr>
				</tbody>
			</table>
		</section>
	</div>
</div>					

<script>
var vacationHome = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	// 휴가관리 홈
	this.initContent=function(bLoad, linkUrl) {
		if (bLoad != true){
			init();	// 초기화
		}	
	}

	// 초기화
	function init(){
		let nowYear = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss")).getFullYear();
		
		coviUtil.getAjaxPost("/groupware/vacation/getVacationInfoForHome.do",{"year" : nowYear}, function (list) {
			if (list.list.length >0){
				var data = list.list[0];
				var per = (parseFloat(data.VacDayUse) > 0 && (parseFloat(data.VacDayUse) >= parseFloat(data.VacDay) )) ? 100 : parseFloat(parseFloat(data.VacDayUse)/parseFloat(data.VacDay)*100);
				$('#myVacTxt').html("<spring:message code='Cache.lbl_my'/>" + ' ' + data.Year+ "<spring:message code='Cache.lbl_annualLeaveStatus'/>"+"("+data.ExpDate+")" );
				$('#pieDiv').css('transform', 'rotate(' + (3.6 * per) + 'deg)');	//	1%에 3.6deg, 180deg(50%)가 넘어 갈 경우 slice 에 gt50 클래스, 추가 로테이션 값은 pie에만 입력한다.
				if (per > 49) $('#slice').addClass('gt50');
				$('#myOwnDaysTxt').html(Number(data.VacDay));
				$('#myUseDaysTxt').html(Number(data.VacDayUse));
				$('#myRemindDaysTxt').html(Number(data.RemainVacDay));
				//$('#deptNameSapn').html('(' + data.DeptName + ')');
			}	
			
			data = list.todayList;
			$.each(data, function(i, v) {
				var html = '';
				var photoPath = coviCmn.loadImage(Common.getBaseConfig('ProfileImagePath').replace('{0}', Common.getSession('DN_Code')) + v.UR_Code + '.jpg');
				var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
		        var sRepJobType = v.JobLevelName;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = v.JobPositionName;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = v.JobTitleName;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = v.JobLevelName;
		        }
				html += '<div class="personBox perBoxType02">';
				html += '<div class="perPhoto">';
				html += '<img src="' + photoPath + '" alt="' + "<spring:message code='Cache.lbl_ProfilePhoto'/>"+ '" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true);">';
				html += '</div>';
				html += '<div class="name">';
				html += '<p>';
				html += '<div><strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;" data-user-code="'+ v.UR_Code +'" data-user-mail="">' + v.UR_Name + ' ' + sRepJobType + '</strong></div>';
				html += '</p>';
				html += '<p>';
				if(v.GUBUN == "VACATION_CANCEL"){
					html += '<span class="btnType03 normal" style="line-height: 19px;">' + v.VacFlagName + ' <spring:message code="Cache.lbl_Cancel"/>' + '</span>' + v.period; // 취소
				}else{
					html += '<span class="btnType02 borderBlue">' + v.VacFlagName + '</span>' + v.period;
				}
				html += '</p>';
				html += '</div>';
				html += '</div>';
				
				$('#vacTodayDiv').append(html);
			});
			
			if(list.vacationPolicy != ""){
				$("#contentDiv").append(list.vacationPolicy);
			}else{
				$("#defaultVacationPolicy").show();
			}
			
			if(data.length > 4){
				coviCtrl.bindmScrollV($('.extPersonList > div'));
			}
		});

		//휴가현황 표 출력,"schTxt": Common.getSession('USERID')
		coviUtil.getAjaxPost("/groupware/vacation/getVacationListByKind.do",{"year" : nowYear,"schTypeSel":"userCode"}, function (list) {
			var data = list.list;

			var tot = 0;
			$.each(data, function(i, v) {
               	if ((v.VacKind=="PUBLIC" && v.CurYear == "Y") ||	v.RemainVacDay>0){
					var row = $("<tr "+(v.CurYear == "Y"?"class='ERBoxbg'":"")+">")
									.append($("<td>",{"style":"font-size: 11px;","text":(v.VacKind=="PUBLIC"?v.Year+" ":"")+v.VacName}))
									.append($("<td>",{"style":"font-size: 11px;","text":v.ExpDate}))
									.append($("<td>",{"style":"font-size: 11px;","text":v.VacDay}))
									.append($("<td>",{"style":"font-size: 11px;","text":v.RemainVacDay}));
					
					$("#extraTable tbody").append(row);
					tot = tot + Number(v.RemainVacDay);
               	}	
			});
			
			$("#extraDiv").show();
			//if(tot > 0) $("#extraDiv").show();
			
			if(data.length > 3){
				coviCtrl.bindmScrollV($('#extraTable'));
			}
		});
	}
}();

$(document).ready(function(){
	vacationHome.initContent();
});

</script>