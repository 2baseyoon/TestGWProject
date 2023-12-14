<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!-- 상단 끝 -->
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_vacationMsg56' /> <spring:message code='Cache.lbl_vacationMsg57' /></h2>	<!-- 휴가생성 자동규칙 -->
</div>

<div class='cRContBottom mScrollVH'>
	<form id="frm">
		<input type="hidden" name="changeMethod" value="false"/>
		<!-- 컨텐츠 시작 -->
		<div class="ATMCont">

			<div class="ATM_Config_wrap">
				<ul class="tabMenu clearFloat">
					<li class="topToggle active"><a href="#"><spring:message code='Cache.lbl_vacationMsg56' /> <spring:message code='Cache.lbl_vacationMsg57' /></a></li>		<!-- 휴가생성 자동규칙 -->
					<li class="topToggle"><a href="#"><spring:message code='Cache.MN_668' /> <spring:message code='Cache.lbl_vacationMsg66' /></a></li>
					<li class="topToggle"><a href="#"><spring:message code='Cache.VACATION_BEFOREANNUAL' /><spring:message code='Cache.lbl_Set' /></a></li>
				</ul>
				<!--휴가생성 자동 규칙 설정-->
				<div class="tabContent active">
					<div class="ATM_Config_Table_wrap">
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH">
										<spring:message code='Cache.lbl_vacationMsg56' /><br />		<!-- 휴가생성 -->
										<spring:message code='Cache.lbl_vacationMsg57' /><br />		<!-- 자동규칙 -->
										<spring:message code='Cache.lbl_Set' />						<!-- 설정 -->
									</p></td>
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="isAuto"><span></span></a></div></td>
									<td>
										<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;">
											<colgroup>
												<col width="20%">
												<col width="50%">
												<col width="30%">
											</colgroup>
											<tbody>
											<tr>
												<th><spring:message code='Cache.lbl_vacationMsg58' /></th>	<!-- 생성방법 -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="createMethod" id="radio01" value="F" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_vacationMsg59' /></h4>	<!-- 1월1일 기준 -->
														</label>
													</div>
													<div class="settingListcheck">
														<input type="radio" name="createMethod" id="radio02" value="J" class="setting_check">
														<label>
															<h4><spring:message code='Cache.msg_n_att_companySetting49' /></h4>	<!-- 입사일 기준 -->
														</label>
													</div>
												</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_createMethod' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_vacationMsg60' /></th>	<!-- 초기건수 -->
												<td style="text-align:left;"><input type="text" name="initCnt" id="initCnt" maxlength="2" style="width: 40px;" class="onlyNum" />일</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_initCnt' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_vacationMsg61' /></th>	<!-- 증가기간 -->
												<td style="text-align:left;"><input type="text" name="incTerm" id="incTerm" maxlength="2" style="width: 40px;" class="onlyNum" />년</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_incTerm' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_vacationMsg62' /></th>	<!-- 증가건수 -->
												<td style="text-align:left;"><input type="text" name="incCnt" id="incCnt" maxlength="2" style="width: 40px;" class="onlyNum" />일</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_incCnt' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_vacationMsg63' /></th>	<!-- 최대건수 -->
												<td style="text-align:left;"><input type="text" name="maxCnt" id="maxCnt" maxlength="2" style="width: 40px;" class="onlyNum" />일</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_maxCnt' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_RemainVacation' /></th>	<!-- 잔여연차 -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="remMethod" id="radio03" value="N" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_vacationMsg65' /></h4>	<!-- 소멸 -->
														</label>
													</div>
  													<div class="settingListcheck">
														<input type="radio" name="remMethod" id="radio04" value="Y" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_vacationMsg64' /></h4>	
														</label>
													</div>
													<div class="settingListcheck">
														<input type="radio" name="remMethod" id="radio05" value="E" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_apv_alreayvacation' /> <spring:message code='Cache.lbl_vacationMsg64' /></h4>
														</label>
													</div>
												</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_remMethod' /></td>
											</tr>
											
											<tr>
												<th><spring:message code='Cache.lbl_lessAYear'/> <spring:message code='Cache.lbl_RemainVacation' /></th>	<!-- 1년 미만 잔여연차 -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="yearRemMethod" id="radio03" value="N" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_vacationMsg65' /></h4>	<!-- 소멸 -->
														</label>
													</div>
  													<div class="settingListcheck">
														<input type="radio" name="yearRemMethod" id="radio04" value="Y" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_vacationMsg64' /></h4>	<!-- 이월 -->
														</label>
													</div>
													<div class="settingListcheck">
														<input type="radio" name="yearRemMethod" id="radio05" value="E" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_apv_alreayvacation' /> <spring:message code='Cache.lbl_vacationMsg64' /></h4>	<!--선연차 사용분 이월 -->
														</label>
													</div>
												</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_yearRemMethod' /></td>
											</tr>
											<tr id="trIsRemRenewal">
												<th><spring:message code='Cache.lbl_IsRemRenewal'/></th>	<!-- 이월연차갱신 -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="isRemRenewal" id="radio03" value="N" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_UseN' /></h4>	<!-- 미사용 -->
														</label>
													</div>
  													<div class="settingListcheck">
														<input type="radio" name="isRemRenewal" id="radio04" value="Y" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_Use' /></h4>	<!-- 사용 -->
														</label>
													</div>
												</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_isRemRenewal' /></td>
											</tr>
											<tr>
												<th><spring:message code='Cache.lbl_YearCreateAnnualVacation'/></th>	<!-- 만 1년까지만 월차 자동 생성 -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="yearCreateAnnualVacation" id="yearCreateAnnualVacationN" value="N" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_UseN' /></h4>	<!--미사용 -->
														</label>
													</div>
  													<div class="settingListcheck">
														<input type="radio" name="yearCreateAnnualVacation" id="yearCreateAnnualVacationY" value="Y" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_Use' /></h4>	<!-- 사용 -->
														</label>
													</div>
												</td>
												<td style="text-align:left;"><spring:message code='Cache.msg_yearCreateAnnualVacation' /></td>
											</tr>
											</tbody>
										</table>
									</td>
								</tr>
								</tbody>
							</table>
						</div>

						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.btn_save' /></a>	<!-- 저장 -->
						</div>
					</div>
				</div>
				<!--끝 - 휴가생성 자동 규칙 설정-->

				<!--시작 - 연차촉진 안내-->
				<div class="tabContent ">
					<div class="ATM_Config_Table_wrap">
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH" rowspan="4"><p class="tx_TH">
										<spring:message code='Cache.MN_668' /> <spring:message code='Cache.lbl_vacationMsg66' />
									</p></td>
									<td style="width: 105px;text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="reqInfoMethod"><span></span></a></div></td>
									<td>
										<p class="Config_mp">연차 촉구 메일 자동 발송 여부 설정</p>
									</td>
								</tr>
								<tr>
									<td style="text-align: center;"><spring:message code='Cache.lbl_apv_history_mail_sender' /></td>
									<td>
										<input type="text" name="mailSenderName" id="mailSenderName" maxlength="50" style="width:100px;" readonly/>
										<input type="text" name="mailSenderAddr" id="mailSenderAddr" maxlength="200" style="width:200px;" readonly/>
										<input type="text" name="facilitatingSenderDept" id="facilitatingSenderDept" maxlength="50" style="width:100px;" />
										<a href="#" class="btnTypeDefault" onclick="vacationVacationConfig.openOrgMapLayerPopup();"><spring:message code="Cache.lbl_apv_org" /></a>
										<a href="#" class="btnTypeDefault" onclick="vacationVacationConfig.sendTestMail();"><spring:message code="Cache.lbl_apv_test" /> <spring:message code="Cache.lbl_Mail" /> <spring:message code="Cache.lbl_Send" /></a>
									</td>
								</tr>
								<tr>
									<td style="text-align: center;"><spring:message code='Cache.lbl_apv_receive' /><spring:message code='Cache.lbl_hrMng_targetUser' /></td>
									<td>
										<p class="Config_mp">선택한 직책 대상자에게만 연차촉구 메일이 발송 됩니다.</p>
										<p class="Config_sp">미선택시 전체 발송 대상(직책 미설정 대상 포함)</p>
										<br/>
										<div class="alarm type01">
											<div id="divFacilitatingTarget" style="text-align: left; margin-left: 20px;"></div>
										</div>
									</td>
								</tr>
								<tr style="height: 500px;">
									<td style="text-align: center;"><spring:message code='Cache.lbl_apv_FormManage' /></td>
									<td style="vertical-align: top;">
										<p class="Config_mp">연차 사용 서면 촉구 및 휴가사용 시기 지정 통보 메일 양식 설정</p>
										<p class="Config_sp">연차 촉구 대상자에 따라 아래 와 같은 양식을 기준으로 자동 메일 이 발송 됩니다. 메일 양식을 설정해 주세요.</p>
										<p class="Config_mp">아래 예약 코드를 클릭 하시면 코드가 클립보드에 복사 됩니다. Ctr+V 하여 붙여 넣으면 메일 발송시 대상자별 값이 입력 되어 송신 됩니다.</p>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;YYYY" onclick="vacationVacationConfig.clipboard(this);" value="현재년도(YYYY)"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;UR_Name" onclick="vacationVacationConfig.clipboard(this);" value="직원명"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;UR_JobPosition" onclick="vacationVacationConfig.clipboard(this);" value="직급"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;EnterDate" onclick="vacationVacationConfig.clipboard(this);" value="입사일(YYYY-MM-DD)"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;EXP_YYYYMMDD" onclick="vacationVacationConfig.clipboard(this);" value="기한일(YYYY년 MM월 DD일)"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;EXP_MMDD" onclick="vacationVacationConfig.clipboard(this);" value="기한일(MM월 DD일)"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;TotVacDay" onclick="vacationVacationConfig.clipboard(this);" value="총연차수"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;UseVacDay" onclick="vacationVacationConfig.clipboard(this);" value="사용연차수"/>
										<input type="button" style="cursor: pointer;" class="btnTypeDefault" data-val="&#35;RemainVacDay" onclick="vacationVacationConfig.clipboard(this);" value="잔여연차수"/>
										<br/>
										<br/>
										<ul class="tabMenu clearFloat">
											<li class="subToggle0 active"><a href="#">1년 이상 연차계획서</a></li>
											<li class="subToggle0"><a href="#">1년 이상 1차</a></li>
											<li class="subToggle0"><a href="#">1년 이상 2차</a></li>
											<li class="subToggle0"><a href="#">1년 미만 연차계획서</a></li>
											<li class="subToggle0"><a href="#">1년 미만 연차촉구(9일) 1차</a></li>
											<li class="subToggle0"><a href="#">1년 미만 연차사용(9일) 2차</a></li>
											<li class="subToggle0"><a href="#">1년 미만 연차촉구(2일) 1차</a></li>
											<li class="subToggle0"><a href="#">1년 미만 연차사용(2일) 2차</a></li>
										</ul>
										<!--메일 발송자 설정-->

										<!--메일 발송 양식-->
										<div class="subTabContent0" style="margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn100"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle100" id="formTitle100" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm100" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn101"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle101" id="formTitle101" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm101" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn102"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle102" id="formTitle102" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm102" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn090"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle090" id="formTitle090" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm090" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn091"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle091" id="formTitle091" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm091" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn092"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle092" id="formTitle092" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm092" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn021"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle021" id="formTitle021" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm021" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
										<div class="subTabContent0" style="display: none;margin-top: 10px;">
											<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 10%;"/>
													<col style="width: 80%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.lbl_apv_useYN' /></th>	<!-- 생성방법 -->
													<td>
														<div class="alarm type01"><a href="#" class="onOffBtn" id="useYn022"><span></span></a></div>
													</td>
													<td>
														임직원의 입사일기준 또는 회계년 기준일에 따라 연차 촉구 기간에 자동 메일 발송 여부를 개별 설정 할 수 있습니다.
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<input type="text" name="formTitle022" id="formTitle022" maxlength="128" style="width: 100%;"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm022" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>
										</div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>

						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.btn_save' /></a>	<!-- 저장 -->
						</div>
					</div>
				</div>
				<!--끝 - 연차촉진 안내-->
				<!--선연차 설정-->
				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH">
										<spring:message code='Cache.VACATION_BEFOREANNUAL' />		<!-- 선연차 -->
										<spring:message code='Cache.lbl_Set' />						<!-- 설정 -->
									</p></td>
									<td>
										<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;">
											<colgroup>
												<col width="20%">
												<col width="50%">
												<col width="30%">
											</colgroup>
											<tbody>
											<tr>
												<th><spring:message code='Cache.VACATION_BEFOREANNUAL' /> <spring:message code='Cache.lbl_AllCompany' /> <spring:message code='Cache.lbl_apv_IsUse' /></th>	<!-- 선연차  전사사용여부  -->
												<td>
													<div class="settingListcheck">
														<input type="radio" name="isBeforeAnnual" id="isBeforeAnnualN" value="N" class="setting_check" checked="">
														<label>
															<h4><spring:message code='Cache.lbl_att_specifier' /> <spring:message code='Cache.lbl_Use' /></h4>	<!-- 지정자 사용 -->
														</label>
													</div>
  													<div class="settingListcheck">
														<input type="radio" name="isBeforeAnnual" id="isBeforeAnnualY"  value="Y" class="setting_check">
														<label>
															<h4><spring:message code='Cache.lbl_AllCompany' /> <spring:message code='Cache.lbl_Use' /></h4>	<!-- 전사 사용 -->
														</label>
													</div>
												</td>
												<td style="text-align:left;">
												Y: 선연차 전사 사용 <br />		
												N: 지정된 사용자만 사용 가능(BeforeAnnualMember)</td>
											</tr>
											<tr>
												<th><spring:message code='Cache.VACATION_BEFOREANNUAL' /> <spring:message code='Cache.lbl_apv_User' /> <spring:message code='Cache.lbl_list' /></th>	<!-- 선연차  사용자 리스트  -->
												<td style="text-align:left;">
													<div class="autoCompleteCustom" id="targetDetailDiv">
														<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: calc(100% - 67px); overflow: auto; max-height: 50px;">
															<input id="targetDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 60px)" autocomplete="off">
														</div>
														<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup(this)"><spring:message code='Cache.lbl_DeptOrgMap' /></a>
													</div>
												</td>
												<td style="text-align:left;">
												기존입사자 중 선연차 사용 가능한 사용자 리스트<br />		
												* 마지막에도 구분자  ;(세미콜론) 붙일 것 </td>
											</tr>
											</tbody>
										</table>
									</td>
								</tr>
								</tbody>
							</table>
						</div>

						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.btn_save' /></a>	<!-- 저장 -->
						</div>
					</div>
				</div>
				
			</div>
		</div>
			<!-- 컨텐츠 끝 -->
	</form>
</div>


<script type="text/javascript">
var vacationVacationConfig = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var EditorType = "13";
	var g_FormBody090 = "";
	var g_FormBody091 = "";
	var g_FormBody092 = "";
	var g_FormBody021 = "";
	var g_FormBody022 = "";
	var g_FormBody100 = "";
	var g_FormBody101 = "";
	var g_FormBody102 = "";
	var g_CreateMethod = "";

	this.initContent = function(bLoad, linkUrl) {
		vacationSetting.objectInit();
		vacationSetting.initEditor();
		vacationSetting.setCheckBoxJobTitle('divFacilitatingTarget','facilitatingTarget','JobTitle');
		vacationSetting.initCheckBoxJobTitle('FacilitatingTarget','facilitatingTarget');
		vacationSetting.initTextInput("FacilitatingSenderDept","facilitatingSenderDept");

	}
	this.openOrgMapLayerPopup=function(){
		_CallBackMethod = vacationVacationConfig.choiceSenderPopupCallBack;
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org' />","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod&type=A1","520px","580px","iframe",true,null,null,true);
	}

	this.clipboard=function(obj) {
		$(obj).attr('type', 'text');
		var dataval = $(obj).data("val");
		var val = $(obj).val();
		$(obj).val(dataval);
		/* Select the text field */
		$(obj).select();
		if (!navigator.clipboard) {
			document.execCommand('copy');
		}else{
			clipboardCopy($(obj).data("val"));
		}
		/* Copy the text inside the text field */
		$(obj).val(val);
		$(obj).attr('type', 'button');

	}
	function clipboardCopy(obj){
		navigator.clipboard.writeText(obj);
	}

	this.sendTestMail=function(){
		var idxNum = 0;
		$(".subToggle0").each(function (idx, obj){
			if($(this).hasClass("active")){
				idxNum = idx;
			}
		});
		var reqType = "";
		switch (idxNum){
			case 0 :
				reqType = "100";
				break;
			case 1 :
				reqType = "101";
				break;
			case 2 :
				reqType = "102";
				break;
			case 3 :
				reqType = "090";
				break;
			case 4 :
				reqType = "091";
				break;
			case 5 :
				reqType = "092";
				break;
			case 6 :
				reqType = "021";
				break;
			case 7 :
				reqType = "022";
				break;
		}

		Common.Inform("To : "+Common.getSession("UR_Mail")+" <spring:message code='Cache.msg_SendQ' />", "Information", function(result){
			if (result){
				$.ajax({
					type:"POST",
					data: {
						reqType: reqType,
						rcvUserCode : Common.getSession("UR_Code")
					},
					url:"/groupware/vacation/testMailSend.do",
					success:function (data) {
						if(data.status === "SUCCESS"){
							Common.Inform(data.message, "Information", function(result){
								if (result) Common.Close();
							});
						}else{
							Common.Warning(data.message);
						}
					}
				});
			}
		});
	}

	//조직도 팝업 콜백
	this.choiceSenderPopupCallBack=function(orgData) {
		wiUrArry = new Array();
		var data = $.parseJSON(orgData);
		var senderInfo = data.item[0]
		//사용자 정보 표시
		$("#mailSenderName").val(CFN_GetDicInfo(senderInfo.DN));
		$("#mailSenderAddr").val(senderInfo.EM);
		$("#facilitatingSenderDept").val(CFN_GetDicInfo(senderInfo.RGNM));
	}
	//기초 값 세팅 처리
	function initVacationConfig(){
		$.ajax({
			url: "/groupware/vacation/initVacationConfig.do",
			type: "POST",
			success: function(result){
				if(result.status === "SUCCESS"){
					vacationSetting.searchData();
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/vacation/initVacationConfig.do", response, status, error);
			}
		});
	}



	function reloadCache(){
		localCache.removeAll();
		coviStorage.clear("CONFIG");

		$.ajax({
			url:"/covicore/cache/reloadCache.do",
			type:"post",
			data:{
				"replicationFlag": coviCmn.configMap["RedisReplicationMode"],
				"cacheType" : "BASECONFIG"
			},
			success: function (res) {
				Common.Inform("<spring:message code='Cache.msg_Processed' />","Information",function(){
					location.reload();
				});
			},
			error : function (error){
				alert("error : "+error);
			}
		});
	}
	
	//연동 설정
	var vacationSetting = {
		objectInit : function(){

			$(".settingListcheck").attr("style","float:left;margin-bottom:0px;");
			$(".settingListcheck label").attr("style","padding:7px;padding-right:30px;");

			onlyNumber($(".onlyNum"));

			if (Common.getBaseConfig("DisplayLastVacDay") == "N"){
				$("#trIsRemRenewal").hide();
			}else{
				$("#trIsRemRenewal").show();
			}			
			this.addEvent();
			this.searchData();
		}	,
		addEvent : function(){
			$(".createCSBtn").on('click',function(){
				vacationSetting.saveSetting('Y');
			});

			$(".topToggle").on('click',function(){
				$(".topToggle").attr("class","topToggle");
				$(".topToggle").eq($(this).index()).attr("class","topToggle active");
				$(".tabContent").removeClass("active");
				$(".tabContent").eq($(this).index()).addClass("active");
			});

			//연차촉진 안내 메일 발송요 폼 설정용 탭
			$(".subToggle0").on('click',function(){
				$(".subToggle0").attr("class","subToggle0");
				$(".subToggle0").eq($(this).index()).attr("class","subToggle0 active");
				var tabIdx = $(this).index();
				$(".subTabContent0").each(function (idx, obj){
					if(idx===tabIdx){
						$(this).show();
					}else{
						$(this).hide();
					}
				});
			});

			$(".onOffBtn").on('click',function(){
				if($(this).attr("class").lastIndexOf("on") > 0 )
					$(this).removeClass("on");
				else
					$(this).addClass("on");
			});
			
			//생성방식에 따라 만 1년까지만 월차 자동 생성 항목 활성화,비활성화
			$("input[name='createMethod']").change(function() {
				if(this.value == 'J') {
					$("input[name=yearCreateAnnualVacation]").attr('disabled', true);
				} else {
					$("input[name=yearCreateAnnualVacation]").attr('disabled', false);
				}
			});
			
		},
		searchData:function(){
			$.ajax({
				type:"POST",
				data: {
					"BeforeAnnualMember" : Common.getBaseConfig("BeforeAnnualMember")
				},
				url:"/groupware/vacation/getVacationConfig.do",
				success:function (data) {
					if (data.status == 'SUCCESS' && Number(data.count) > 0) {
						var result = data.data;

						if (result.IsAuto === "Y") $("#isAuto").addClass("on");

						g_CreateMethod = result.CreateMethod;
						//생성방법
						$("input[name=createMethod]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.CreateMethod == item.val()) $(this).click();
						});

						$("#incCnt").val(result.IncCnt);
						$("#incTerm").val(result.IncTerm);
						$("#initCnt").val(result.InitCnt);
						$("#maxCnt").val(result.MaxCnt);

						$("#formTitle090").val(result.FormTitle090);
						$("#formTitle091").val(result.FormTitle091);
						$("#formTitle092").val(result.FormTitle092);
						$("#formTitle021").val(result.FormTitle021);
						$("#formTitle022").val(result.FormTitle022);
						$("#formTitle100").val(result.FormTitle100);
						$("#formTitle101").val(result.FormTitle101);
						$("#formTitle102").val(result.FormTitle102);
						$("#mailSenderName").val(result.MailSenderName);
						$("#mailSenderAddr").val(result.MailSenderAddr);

						g_FormBody090 = result.FormBody090;
						g_FormBody091 = result.FormBody091;
						g_FormBody092 = result.FormBody092;
						g_FormBody021 = result.FormBody021;
						g_FormBody022 = result.FormBody022;
						g_FormBody100 = result.FormBody100;
						g_FormBody101 = result.FormBody101;
						g_FormBody102 = result.FormBody102;
						//잔여연차
						$("input[name=remMethod]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.RemMethod == item.val()) $(this).click();
						});

						//1년 미만 잔여연차
						$("input[name=yearRemMethod]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.YearRemMethod == item.val()) $(this).click();
						});

						//이월연차갱신
						$("input[name=isRemRenewal]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.IsRemRenewal == item.val()) $(this).click();
						});

						//만 1년까지만 월차 자동 생성
						$("input[name=yearCreateAnnualVacation]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.YearCreateAnnualVacation == item.val()) $(this).click();
						});
						//연차촉진 안내
						/*$("input[name=reqInfoMethod]").each(function (i, v) {
							var item = $(v);
							item.attr("checked", false);
							if (result.ReqInfoMethod == item.val()) $(this).click();
						});*/
						if (result.ReqInfoMethod === "Y") $("#reqInfoMethod").addClass("on");
						if (result.useYn100 === "Y") $("#useYn100").addClass("on");
						if (result.useYn101 === "Y") $("#useYn101").addClass("on");
						if (result.useYn102 === "Y") $("#useYn102").addClass("on");
						if (result.useYn090 === "Y") $("#useYn090").addClass("on");
						if (result.useYn091 === "Y") $("#useYn091").addClass("on");
						if (result.useYn092 === "Y") $("#useYn092").addClass("on");
						if (result.useYn021 === "Y") $("#useYn021").addClass("on");
						if (result.useYn022 === "Y") $("#useYn022").addClass("on");

						//선연차 설정
						$("#isBeforeAnnualN").attr("checked",false);
						$("#isBeforeAnnualY").attr("checked",false);
						if(Common.getBaseConfig("isUseBeforeAnnual") == "Y"){
							$("#isBeforeAnnualY").click();
						} else {
							$("#isBeforeAnnualN").click();
						}
						
						if(data.userList != null &&data.userList != undefined){
							$.each(data.userList, function (i, v) {
								var cloned = orgMapDivEl.clone();
								var type = 'UR';
								var code = v.UserCode;

								cloned.attr('type', type).attr('code', code);
								cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DisplayName));
								$('#targetDetailDiv .ui-autocomplete-input').before(cloned);
							});
						}
						
					}else{//기본 데이터 없을시
						Common.Confirm("기본 설정 값이 존재 하지 않습니다.\n기본 값 으로 휴가 생성 규을 설정 하시 겠습니까?", "Confirm", function(result){
							if(result){
								initVacationConfig();
							}
						});
					}
				}
			});
		},
		saveSetting : function(confirm){
			if($("input[name='createMethod']:checked").val() !== g_CreateMethod){
				$("input[name='changeMethod']").val("true")
			}
			var data = $("#frm").serializeObject();
			data.isAuto = $("#isAuto").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.reqInfoMethod = $("#reqInfoMethod").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn100 = $("#useYn100").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn101 = $("#useYn101").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn102 = $("#useYn102").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn090 = $("#useYn090").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn091 = $("#useYn091").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn092 = $("#useYn092").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn021 = $("#useYn021").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.useYn022 = $("#useYn022").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.formBody090 = coviEditor.getBody(EditorType, "tbContentElement090",true);
			data.formBody091 = coviEditor.getBody(EditorType, "tbContentElement091",true);
			data.formBody092 = coviEditor.getBody(EditorType, "tbContentElement092",true);
			data.formBody021 = coviEditor.getBody(EditorType, "tbContentElement021",true);
			data.formBody022 = coviEditor.getBody(EditorType, "tbContentElement022",true);
			data.formBody100 = coviEditor.getBody(EditorType, "tbContentElement100",true);
			data.formBody101 = coviEditor.getBody(EditorType, "tbContentElement101",true);
			data.formBody102 = coviEditor.getBody(EditorType, "tbContentElement102",true);
			//설정 변경
			$.ajax({
				url:"/groupware/vacation/updateVacationConfig.do",
				type:"POST",
				data:data,
				success : function(res) {
					if (res.status == "SUCCESS") {
						if(confirm=='Y'){
							Common.Inform(Common.getDic("msg_com_processSuccess"));
						}
					}else {
						Common.Warning("<spring:message code='Cache.msg_apv_030' />");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/adminSetting/setCompanySetting.do", response, status, error);
				}
			});

			//연차촉진 대상자 공통 코드쪽에 기록처리
			var cdata = {};
			var facilitatingTarget = "";
			var ckCnt2 = 0;
			$('input:checkbox[name="facilitatingTarget"]:checked').each(function() {
				if(ckCnt2>0){facilitatingTarget+='|'}
				facilitatingTarget += $(this).val();
				ckCnt2++;
			});
			cdata.FacilitatingTarget =  facilitatingTarget;
			//2022.08.05 연차촉구 요청서 화면내 수신자 부서 명칭 설정
			cdata.FacilitatingSenderDept =  $('input:text[name="facilitatingSenderDept"]').val();
			//기초설정 변경 후 CACHE초기화
			$.ajax({
				url:"/groupware/attendAdmin/setCompanySettingForVacations.do",
				type:"post",
				data:cdata,
				dataType:"json",
				success : function(res) {
					if (res.status == "SUCCESS") {
						reloadCache();
					}else {
						Common.Warning("<spring:message code='Cache.msg_apv_030' />");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/adminSetting/setCompanySettingForVacations.do", response, status, error);
				}
			});
			
			//선연차
			var beforeAnnualMember = "";
			$.each($("#targetDetailDiv .ui-autocomplete-multiselect-item"), function(idx, el){
				beforeAnnualMember += $(el).attr("code") + ";";
			});
			
			$.ajax({
				url:"/groupware/vacation/updateBeforeAnnual.do",
				type:"POST",
				data:{
					"isBeforeAnnual":$("input[name='isBeforeAnnual']:checked").val(),
					"beforeAnnualMember":beforeAnnualMember
				},
				success : function(res) {
					if (res.status == "SUCCESS") {
						reloadCache();
					}else {
						Common.Warning("<spring:message code='Cache.msg_apv_030' />");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/adminSetting/setCompanySetting.do", response, status, error);
				}
			});
		},
		initEditor : function(){
			coviEditor.loadEditor('divMailEditForm090', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement090'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement090' , g_FormBody090);
				}
			});
			coviEditor.loadEditor('divMailEditForm091', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement091'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement091' , g_FormBody091);
				}
			});
			coviEditor.loadEditor('divMailEditForm092', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement092'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement092' , g_FormBody092);
				}
			});
			coviEditor.loadEditor('divMailEditForm021', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement021'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement021' , g_FormBody021);
				}
			});
			coviEditor.loadEditor('divMailEditForm022', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement022'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement022' , g_FormBody022);
				}
			});
			coviEditor.loadEditor('divMailEditForm100', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement100'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement100' , g_FormBody100);
				}
			});
			coviEditor.loadEditor('divMailEditForm101', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement101'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement101' , g_FormBody101);
				}
			});
			coviEditor.loadEditor('divMailEditForm102', {
				editorType : EditorType //'dext5'
				,containerID : 'tbContentElement102'
				,frameHeight : '600'
				,focusObjID : 'ulFrom'
				,useResize : 'N'
				,bizSection: "Mail"
				,onLoad: function(){
					coviEditor.setBody(EditorType, 'tbContentElement102' , g_FormBody102);
				}
			});
		}
		,setCheckBoxJobTitle : function(objId, objName, groupType) {
			//직책
			$.ajax({
				async: false,
				type: "POST",
				data: {
					"domainCode": Common.getSession("DN_Code"),
					"groupType": groupType
				},
				url: "/covicore/admin/orgmanage/getjobinfolist.do",
				success: function (data) {
					if (data.status == "FAIL") {
						alert(data.message);
						return;
					}

					var opHtml = "";
					var list = data.list;
					for(var i = 0; i < list.length; i++){
						opHtml += "<input type='checkbox' name='"+objName+"' value='"+list[i].GroupCode+"'/>"+CFN_GetDicInfo(list[i].MultiDisplayName)+"<br/>";
					}
					$("#"+objId).html(opHtml);
				},
				error: function (response, status, error) {
					//TODO 추가 오류 처리
					CFN_ErrorAjax("/covicore/admin/orgmanage/getjobinfolist.do",
							response, status, error);
				}
			});
		}
		,initCheckBoxJobTitle : function(cfgID, ckBoxName) {
			var baseCfg = Common.getBaseConfig(cfgID).split("|");
			$.each(baseCfg, function (i, item) {
				$('input:checkbox[name='+ckBoxName+']').each(function(j, obj) {
					if ($(this).val() === item) {
						$(this).attr("checked",true);
					}
				});
			});
		}
		,initTextInput : function(cfgID, inputName) {
			var baseCfg = Common.getBaseConfig(cfgID);
			$('input:text[name='+inputName+']').val(baseCfg);
		}
	}
}();

// 조직도 팝업
function openOrgMapLayerPopup(target) {
	var target = {
		selected : ''
	}

	$.each($("#targetDetailDiv .ui-autocomplete-multiselect-item"), function(idx, el){
		target.selected += ((idx > 0) ? ';' : '') + el.getAttribute('code');
	});
	
	var url = "/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=B9&groupDivision=Basic&allCompany=" + ((Common.getGlobalProperties('isSaaS') == 'Y') ? "N" : "Y");
	if (target.selected != '') url += '&userParams=' + encodeURIComponent(JSON.stringify(target));
	Common.open("","orgmap_pop","조직도", url, "1000px","580px","iframe",true,null,null,true);	
}

var orgMapDivEl = $("<div/>", {'class' : 'ui-autocomplete-multiselect-item', attr : {type : '', code : ''}})
.append($("<span/>", {'class' : 'ui-icon ui-icon-close'}));

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;

	if (item != '') {
		var duplication = false; // 중복 여부
		$('#targetDetailDiv .ui-autocomplete-multiselect-item').remove();
		$.each(item, function (i, v) {
			var cloned = orgMapDivEl.clone();
			var type = 'UR';
			var code = v.UserCode;
			
			if ($('#targetDetailDiv').find(".ui-autocomplete-multiselect-item[type='"+ type+"'][code='"+ code+"']").length > 0) {
				duplication = true;
				return true;
			}

			cloned.attr('type', type).attr('code', code);
			cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));
			$('#targetDetailDiv .ui-autocomplete-input').before(cloned);
		});
		
		if(duplication){
			Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			return;
		}
	}
}
 
$(document).on('click', '.ui-icon-close', function(e){
	e.preventDefault();
	$(this).parent().remove();
});

$(document).ready(function(){
	vacationVacationConfig.initContent();
});

/*	$(document).ready(function(){
		vacationSetting.objectInit();
		vacationSetting.initEditor();
		vacationSetting.setCheckBoxJobTitle('divFacilitatingTarget','facilitatingTarget','JobTitle');
		vacationSetting.initCheckBoxJobTitle('FacilitatingTarget','facilitatingTarget');
		vacationSetting.initTextInput("FacilitatingSenderDept","facilitatingSenderDept");
	});
*/
</script>
    